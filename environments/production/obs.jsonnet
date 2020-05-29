local t = (import 'kube-thanos/thanos.libsonnet');
local trc = (import 'thanos-receive-controller/thanos-receive-controller.libsonnet');
local api = (import 'observatorium/observatorium-api.libsonnet');
local cqf = (import 'configuration/components/cortex-query-frontend.libsonnet');
local mc = (import 'configuration/components/memcached.libsonnet');
local up = (import 'configuration/components/up.libsonnet');

(import 'configuration/components/observatorium.libsonnet') {
  local obs = self,

  local s3EnvVars = [
    {
      name: 'AWS_ACCESS_KEY_ID',
      valueFrom: {
        secretKeyRef: {
          key: 'aws_access_key_id',
          name: '${THANOS_S3_SECRET}',
        },
      },
    },
    {
      name: 'AWS_SECRET_ACCESS_KEY',
      valueFrom: {
        secretKeyRef: {
          key: 'aws_secret_access_key',
          name: '${THANOS_S3_SECRET}',
        },
      },
    },
  ],

  compact+::
    t.compact.withVolumeClaimTemplate +
    t.compact.withResources +
    (import 'configuration/components/oauth-proxy.libsonnet') +
    (import 'configuration/components/oauth-proxy.libsonnet').statefulSetMixin {
      statefulSet+: {
        spec+: {
          template+: {
            spec+: {
              containers: [
                if c.name == 'thanos-compact' then c {
                  env+: s3EnvVars,
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

  thanosReceiveController+::
    trc.withResources,

  rule+::
    local nameResource = obs.config.name + '-rule';
    local nameFile = obs.config.name + '.yaml';
    t.rule.withResources +
    (import 'configuration/components/jaeger-agent.libsonnet').statefulSetMixin {
      statefulSet+: {
        spec+: {
          template+: {
            spec+: {
              containers: [
                if c.name == 'thanos-rule' then c {
                  env+: s3EnvVars,
                  args+: ['--rule-file=/var/thanos/config/rules/' + nameFile],
                  volumeMounts+: [{
                    name: nameResource,
                    mountPath: '/var/thanos/config/rules',
                  }],
                } else c
                for c in super.containers
              ],
              volumes+: [{
                name: nameResource,
                configMap: {
                  name: nameResource,
                },
              }],
            },
          },
        },
      },
    } + {
      configmap:
        local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
        local configmap = k.core.v1.configMap;
        configmap.new() +
        configmap.mixin.metadata.withName(nameResource) +
        configmap.mixin.metadata.withLabels(obs.config.commonLabels) +
        configmap.withData({
          [nameFile]: std.manifestYamlDoc({
            groups: [{
              name: 'observatorium.rules',
              interval: '1m',
              rules: [
                {
                  expr: "count by (name,reason) (cluster_operator_conditions{condition='Degraded'} == 1)",
                  record: 'name_reason:cluster_operator_degraded:count',
                },
                {
                  expr: "count by (name,reason) (cluster_operator_conditions{condition='Available'} == 0)",
                  record: 'name_reason:cluster_operator_unavailable:count',
                },
                {
                  expr: "sort_desc(max by (_id,code) (code:apiserver_request_count:rate:sum{code=~'(4|5)\\\\d\\\\d'}) > 0.5)",
                  record: 'id_code:apiserver_request_error_rate_sum:max',
                },
                {
                  expr: "bottomk by (_id) (1, max by (_id, version) (0 * cluster_version{type='failure'}) or max by (_id, version) (1 + 0 * cluster_version{type='current'}))",
                  record: 'id_version:cluster_available',
                },
                {
                  expr: "topk by (_id) (1, max by (_id, managed, ebs_account, internal) (label_replace(label_replace((subscription_labels{support=~'Standard|Premium|Layered'} * 0 + 1) or subscription_labels * 0, 'internal', 'true', 'email_domain', 'redhat.com|(.*\\\\.|^)ibm.com'), 'managed', '', 'managed', 'false')) + on(_id) group_left(version) (topk by (_id) (1, 0*cluster_version{type='current'})))",
                  record: 'id_version_ebs_account_internal:cluster_subscribed',
                },
              ],
            }],
          }),
        }),
    },

  store+:: {
    ['shard' + i]+:
      t.store.withVolumeClaimTemplate +
      t.store.withResources + {
        config+:: {
          memcached+: {
            local memcached = obs.store['shard' + i].config.memcached,
            indexCache: memcached {
              addresses: ['dnssrv+_client._tcp.%s.%s.svc' % [obs.storeIndexCache.service.metadata.name, obs.storeIndexCache.service.metadata.namespace]],
            },
            bucketCache: memcached {
              addresses: ['dnssrv+_client._tcp.%s.%s.svc' % [obs.storeBucketCache.service.metadata.name, obs.storeBucketCache.service.metadata.namespace]],
            },
          },
        },
      } +
      (import 'configuration/components/jaeger-agent.libsonnet').statefulSetMixin {
        statefulSet+: {
          spec+: {
            template+: {
              spec+: {
                containers: [
                  if c.name == 'thanos-store' then c {
                    env+: s3EnvVars,
                  } else c
                  for c in super.containers
                ],
              },
            },
          },
        },
      }
    for i in std.range(0, obs.config.store.shards - 1)
  },

  storeCache:: {},

  storeIndexCache::
    mc +
    mc.withResources {
      config+:: {
        local cfg = self,
        name: obs.config.name + '-thanos-store-index-cache-' + cfg.commonLabels['app.kubernetes.io/name'],
        namespace: obs.config.namespace,
        commonLabels+:: obs.config.commonLabels,
      },
      statefulSet+: {
        spec+: {
          volumeClaimTemplates:: null,
        },
      },
    },

  storeBucketCache::
    mc +
    mc.withResources {
      config+:: {
        local cfg = self,
        name: obs.config.name + '-thanos-store-bucket-cache-' + cfg.commonLabels['app.kubernetes.io/name'],
        namespace: obs.config.namespace,
        commonLabels+:: obs.config.commonLabels,
      },
      statefulSet+: {
        spec+: {
          volumeClaimTemplates:: null,
        },
      },
    },

  receivers+:: {
    [hashring.hashring]+:
      t.receive.withVolumeClaimTemplate +
      t.receive.withPodDisruptionBudget +
      t.receive.withResources {
        statefulSet+: {
          spec+: {
            template+: {
              spec+: {
                containers: [
                  if c.name == 'thanos-receive' then c {
                    args+: [
                      '--receive.default-tenant-id=FB870BF3-9F3A-44FF-9BF7-D7A047A52F43',
                    ],
                    env+: s3EnvVars,
                  } + {
                    args: [
                      if std.startsWith(a, '--tsdb.path') then '--tsdb.path=${THANOS_RECEIVE_TSDB_PATH}'
                      else if std.startsWith(a, '--tsdb.retention') then '--tsdb.retention=15d' else a
                      for a in super.args
                    ],
                  } else c
                  for c in super.containers
                ],
              },
            },
          },
        },
      } + (import 'configuration/components/jaeger-agent.libsonnet').statefulSetMixin
    for hashring in obs.config.hashrings
  },

  query+::
    t.query.withResources +
    (import 'configuration/components/oauth-proxy.libsonnet') +
    (import 'configuration/components/oauth-proxy.libsonnet').deploymentMixin +
    (import 'configuration/components/jaeger-agent.libsonnet').deploymentMixin,

  queryCache+::
    cqf.withResources +
    (import 'configuration/components/oauth-proxy.libsonnet') +
    (import 'configuration/components/oauth-proxy.libsonnet').deploymentMixin,

  api+::
    api.withResources +
    (import 'configuration/components/oauth-proxy.libsonnet') +
    (import 'configuration/components/oauth-proxy.libsonnet').deploymentMixin,

  up+:: up,

  manifests+:: {
    ['observatorium-up-' + name]: obs.up[name]
    for name in std.objectFields(obs.up)
    if obs.up[name] != null
  },
} + {
  local obs = self,

  config+:: {
    name: 'observatorium',
    namespace:: '${NAMESPACE}',
    thanosImage:: '${THANOS_IMAGE}:${THANOS_IMAGE_TAG}',
    thanosVersion: '${THANOS_IMAGE_TAG}',
    oauthProxyImage:: '${PROXY_IMAGE}:${PROXY_IMAGE_TAG}',
    jaegerAgentImage:: '${JAEGER_AGENT_IMAGE}:${JAEGER_AGENT_IMAGE_TAG}',
    jaegerAgentCollectorAddress:: 'dns:///jaeger-collector-headless.$(NAMESPACE).svc:14250',
    objectStorageConfig:: {
      name: '${THANOS_CONFIG_SECRET}',
      key: 'thanos.yaml',
    },

    hashrings: [
      {
        hashring: 'default',
        tenants: [
          // Match all for now
          // 'foo',
          // 'bar',
        ],
      },
    ],

    compact+: {
      image: obs.config.thanosImage,
      version: obs.config.thanosVersion,
      objectStorageConfig: obs.config.objectStorageConfig,
      retentionResolutionRaw: '14d',
      retentionResolution5m: '1s',
      retentionResolution1h: '1s',
      replicas: '${{THANOS_COMPACTOR_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${THANOS_COMPACTOR_CPU_REQUEST}',
          memory: '${THANOS_COMPACTOR_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_COMPACTOR_CPU_LIMIT}',
          memory: '${THANOS_COMPACTOR_MEMORY_LIMIT}',
        },
      },
      oauthProxy: {
        image: obs.config.oauthProxyImage,
        httpsPort: 8443,
        upstream: 'http://localhost:' + obs.compact.service.spec.ports[0].port,
        tlsSecretName: 'compact-tls',
        sessionSecretName: 'compact-proxy',
        sessionSecret: '',
        serviceAccountName: 'prometheus-telemeter',
        resources: {
          requests: {
            cpu: '${JAEGER_PROXY_CPU_REQUEST}',
            memory: '${JAEGER_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${JAEGER_PROXY_CPU_LIMITS}',
            memory: '${JAEGER_PROXY_MEMORY_LIMITS}',
          },
        },
      },
      volumeClaimTemplate: {
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: '${THANOS_COMPACTOR_PVC_REQUEST}',
            },
          },
          storageClassName: '${STORAGE_CLASS}',
        },
      },
    },

    thanosReceiveController+: {
      image: '${THANOS_RECEIVE_CONTROLLER_IMAGE}:${THANOS_RECEIVE_CONTROLLER_IMAGE_TAG}',
      version: '${THANOS_RECEIVE_CONTROLLER_IMAGE_TAG}',
      hashrings: obs.config.hashrings,
      resources: {
        requests: {
          cpu: '10m',
          memory: '24Mi',
        },
        limits: {
          cpu: '64m',
          memory: '128Mi',
        },
      },
      jaegerAgent: {
        image: obs.config.jaegerAgentImage,
        collectorAddress: obs.config.jaegerAgentCollectorAddress,
      },
    },

    receivers+: {
      image: obs.config.thanosImage,
      version: obs.config.thanosVersion,
      objectStorageConfig: obs.config.objectStorageConfig,
      hashrings: obs.config.hashrings,
      replicas: '${{THANOS_RECEIVE_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${THANOS_RECEIVE_CPU_REQUEST}',
          memory: '${THANOS_RECEIVE_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_RECEIVE_CPU_LIMIT}',
          memory: '${THANOS_RECEIVE_MEMORY_LIMIT}',
        },
      },
      volumeClaimTemplate: {
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: '50Gi',
            },
          },
          storageClassName: '${STORAGE_CLASS}',
        },
      },
      jaegerAgent: {
        image: obs.config.jaegerAgentImage,
        collectorAddress: obs.config.jaegerAgentCollectorAddress,
      },
    },

    rule+: {
      image: obs.config.thanosImage,
      version: obs.config.thanosVersion,
      objectStorageConfig: obs.config.objectStorageConfig,
      replicas: '${{THANOS_RULER_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${THANOS_RULER_CPU_REQUEST}',
          memory: '${THANOS_RULER_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_RULER_CPU_LIMIT}',
          memory: '${THANOS_RULER_MEMORY_LIMIT}',
        },
      },
      jaegerAgent: {
        image: obs.config.jaegerAgentImage,
        collectorAddress: obs.config.jaegerAgentCollectorAddress,
      },
    },

    store+: {
      image: obs.config.thanosImage,
      version: obs.config.thanosVersion,
      shards: 3,
      objectStorageConfig: obs.config.objectStorageConfig,
      replicas: '${{THANOS_STORE_REPLICAS}}',
      memcached+: {
        indexCache+: {
          timeout: '10s',  // TODO(kakkoyun): Adjust using metrics!
          maxAsyncBufferSize: 10000000,
          maxGetMultiBatchSize: 100,
        },
        bucketCache+: {
          timeout: '2s',  // TODO(kakkoyun): Adjust using metrics after running for awhile!
        },
      },
      resources: {
        requests: {
          cpu: '${THANOS_STORE_CPU_REQUEST}',
          memory: '${THANOS_STORE_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_STORE_CPU_LIMIT}',
          memory: '${THANOS_STORE_MEMORY_LIMIT}',
        },
      },
      volumeClaimTemplate: {
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: '50Gi',
            },
          },
          storageClassName: '${STORAGE_CLASS}',
        },
      },
      jaegerAgent: {
        image: obs.config.jaegerAgentImage,
        collectorAddress: obs.config.jaegerAgentCollectorAddress,
      },
    },

    storeIndexCache+: {
      local scConfig = self,
      version: '${MEMCACHED_IMAGE_TAG}',
      image: '%s:%s' % ['${MEMCACHED_IMAGE}', scConfig.version],
      exporterVersion: '${MEMCACHED_EXPORTER_IMAGE_TAG}',
      exporterImage: '%s:%s' % ['${MEMCACHED_EXPORTER_IMAGE}', scConfig.exporterVersion],
      connectionLimit: '${THANOS_STORE_INDEX_CACHE_CONNECTION_LIMIT}',
      memoryLimitMb: '${THANOS_STORE_INDEX_CACHE_MEMORY_LIMIT_MB}',
      replicas: '${{THANOS_STORE_INDEX_CACHE_REPLICAS}}',
      resources: {
        memcached: {
          requests: {
            cpu: '${THANOS_STORE_INDEX_CACHE_MEMCACHED_CPU_REQUEST}',
            memory: '${THANOS_STORE_INDEX_CACHE_MEMCACHED_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${THANOS_STORE_INDEX_CACHE_MEMCACHED_CPU_LIMIT}',
            memory: '${THANOS_STORE_INDEX_CACHE_MEMCACHED_MEMORY_LIMIT}',
          },
        },

        exporter: {
          requests: {
            cpu: '${MEMCACHED_EXPORTER_CPU_REQUEST}',
            memory: '${MEMCACHED_EXPORTER_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${MEMCACHED_EXPORTER_CPU_LIMIT}',
            memory: '${MEMCACHED_EXPORTER_MEMORY_LIMIT}',
          },
        },
      },
    },

    storeBucketCache+: {
      local scConfig = self,
      version: '${MEMCACHED_IMAGE_TAG}',
      image: '%s:%s' % ['${MEMCACHED_IMAGE}', scConfig.version],
      exporterVersion: '${MEMCACHED_EXPORTER_IMAGE_TAG}',
      exporterImage: '%s:%s' % ['${MEMCACHED_EXPORTER_IMAGE}', scConfig.exporterVersion],
      connectionLimit: '${THANOS_STORE_BUCKET_CACHE_CONNECTION_LIMIT}',
      memoryLimitMb: '${THANOS_STORE_BUCKET_CACHE_MEMORY_LIMIT_MB}',
      replicas: '${{THANOS_STORE_BUCKET_CACHE_REPLICAS}}',
      resources: {
        memcached: {
          requests: {
            cpu: '${THANOS_STORE_BUCKET_CACHE_MEMCACHED_CPU_REQUEST}',
            memory: '${THANOS_STORE_BUCKET_CACHE_MEMCACHED_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${THANOS_STORE_BUCKET_CACHE_MEMCACHED_CPU_LIMIT}',
            memory: '${THANOS_STORE_BUCKET_CACHE_MEMCACHED_MEMORY_LIMIT}',
          },
        },

        exporter: {
          requests: {
            cpu: '${MEMCACHED_EXPORTER_CPU_REQUEST}',
            memory: '${MEMCACHED_EXPORTER_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${MEMCACHED_EXPORTER_CPU_LIMIT}',
            memory: '${MEMCACHED_EXPORTER_MEMORY_LIMIT}',
          },
        },
      },
    },

    query+: {
      image: obs.config.thanosImage,
      version: obs.config.thanosVersion,
      replicas: '${{THANOS_QUERIER_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${THANOS_QUERIER_CPU_REQUEST}',
          memory: '${THANOS_QUERIER_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_QUERIER_CPU_LIMIT}',
          memory: '${THANOS_QUERIER_MEMORY_LIMIT}',
        },
      },
      oauthProxy: {
        image: obs.config.oauthProxyImage,
        httpsPort: 9091,
        upstream: 'http://localhost:' + obs.query.service.spec.ports[1].port,
        tlsSecretName: 'query-tls',
        sessionSecretName: 'query-proxy',
        sessionSecret: '',
        serviceAccountName: 'prometheus-telemeter',
        resources: {
          requests: {
            cpu: '${JAEGER_PROXY_CPU_REQUEST}',
            memory: '${JAEGER_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${JAEGER_PROXY_CPU_LIMITS}',
            memory: '${JAEGER_PROXY_MEMORY_LIMITS}',
          },
        },
      },
      jaegerAgent: {
        image: obs.config.jaegerAgentImage,
        collectorAddress: obs.config.jaegerAgentCollectorAddress,
      },
    },

    queryCache+: {
      local qcConfig = self,
      version: 'master-fdcd992f',
      image: 'quay.io/cortexproject/cortex:' + qcConfig.version,
      replicas: '${{THANOS_QUERIER_CACHE_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${THANOS_QUERIER_CACHE_CPU_REQUEST}',
          memory: '${THANOS_QUERIER_CACHE_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${THANOS_QUERIER_CACHE_CPU_LIMIT}',
          memory: '${THANOS_QUERIER_CACHE_MEMORY_LIMIT}',
        },
      },
      oauthProxy: {
        image: obs.config.oauthProxyImage,
        httpsPort: 9091,
        upstream: 'http://localhost:' + obs.query.service.spec.ports[1].port,
        tlsSecretName: 'query-cache-tls',
        sessionSecretName: 'query-cache-proxy',
        sessionSecret: '',
        serviceAccountName: 'prometheus-telemeter',
        resources: {
          requests: {
            cpu: '${JAEGER_PROXY_CPU_REQUEST}',
            memory: '${JAEGER_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${JAEGER_PROXY_CPU_LIMITS}',
            memory: '${JAEGER_PROXY_MEMORY_LIMITS}',
          },
        },
      },
    },

    api+: {
      local api = self,
      version: '${OBSERVATORIUM_API_IMAGE_TAG}',
      image: '%s:%s' % ['${OBSERVATORIUM_API_IMAGE}', api.version],
      replicas: '${{OBSERVATORIUM_API_REPLICAS}}',
      resources: {
        requests: {
          cpu: '${OBSERVATORIUM_API_CPU_REQUEST}',
          memory: '${OBSERVATORIUM_API_MEMORY_REQUEST}',
        },
        limits: {
          cpu: '${OBSERVATORIUM_API_CPU_LIMIT}',
          memory: '${OBSERVATORIUM_API_MEMORY_LIMIT}',
        },
      },
      oauthProxy: {
        image: obs.config.oauthProxyImage,
        httpsPort: 9091,
        upstream: 'http://localhost:' + obs.api.service.spec.ports[1].port,
        tlsSecretName: 'observatorium-api-tls',
        sessionSecretName: 'observatorium-api-proxy',
        sessionSecret: '',
        serviceAccountName: 'prometheus-telemeter',
        resources: {
          requests: {
            cpu: '${JAEGER_PROXY_CPU_REQUEST}',
            memory: '${JAEGER_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${JAEGER_PROXY_CPU_LIMITS}',
            memory: '${JAEGER_PROXY_MEMORY_LIMITS}',
          },
        },
      },
    },

    up: {
      local cfg = self,
      name: obs.config.name + '-' + cfg.commonLabels['app.kubernetes.io/name'],
      namespace: obs.config.namespace,
      readEndpoint: 'http://%s.%s.svc:9090/api/metrics/v1/api/v1/query' % [obs.api.service.metadata.name, obs.api.service.metadata.namespace],
      version: 'master-2020-03-25-6d4f944',
      image: 'quay.io/observatorium/up:' + cfg.version,
      queryConfig: (import 'queries.libsonnet'),
      serviceMonitor: true,
      resources: {
        requests: {
          cpu: '5m',
          memory: '10Mi',
        },
        limits: {
          cpu: '20m',
          memory: '50Mi',
        },
      },

      commonLabels+:: obs.config.commonLabels,
    },
  },
} + (import 'configuration/components/observatorium-configure.libsonnet') + {
  local obs = self,
  up+:: {
    config+:: obs.config.up {
      queryConfig: (import 'queries.libsonnet'),
    },
  },

  storeIndexCache+:: {
    config+:: obs.config.storeIndexCache,
  },

  storeBucketCache+:: {
    config+:: obs.config.storeBucketCache,
  },
} + {
  local obs = self,

  local telemeter = (import 'telemeter.jsonnet') {
    _config+:: {
      namespace: obs.config.namespace,
    },
  },

  local prometheusAMS = (import 'telemeter-prometheus-ams.jsonnet') {
    _config+:: {
      namespace: obs.config.namespace,
    },
  },

  openshiftTemplate:: {
    apiVersion: 'v1',
    kind: 'Template',
    metadata: {
      name: 'observatorium',
    },
    objects:
      [
        obs.manifests[name]
        for name in std.objectFields(obs.manifests)
      ] +
      [
        obs.storeIndexCache[name]
        for name in std.objectFields(obs.storeIndexCache)
      ] +
      [
        obs.storeBucketCache[name]
        for name in std.objectFields(obs.storeBucketCache)
      ] +
      telemeter.objects +
      prometheusAMS.objects,
    parameters: [
      {
        name: 'NAMESPACE',
        value: 'telemeter',
      },
      {
        name: 'THANOS_IMAGE',
        value: 'quay.io/thanos/thanos',
      },
      {
        name: 'THANOS_IMAGE_TAG',
        value: 'master-2020-05-25-c733564d',  // Right after v0.13.0-rc.0
      },
      {
        name: 'STORAGE_CLASS',
        value: 'gp2',
      },
      {
        name: 'PROXY_IMAGE',
        value: 'quay.io/openshift/origin-oauth-proxy',
      },
      {
        name: 'PROXY_IMAGE_TAG',
        value: '4.4.0',
      },
      {
        name: 'JAEGER_AGENT_IMAGE',
        value: 'jaegertracing/jaeger-agent',
      },
      {
        name: 'JAEGER_AGENT_IMAGE_TAG',
        value: '1.14.0',
      },
      {
        name: 'THANOS_RECEIVE_CONTROLLER_IMAGE',
        value: 'quay.io/observatorium/thanos-receive-controller',
      },
      {
        name: 'THANOS_RECEIVE_CONTROLLER_IMAGE_TAG',
        value: 'master-2019-10-18-d55fee2',
      },
      {
        name: 'THANOS_QUERIER_REPLICAS',
        value: '3',
      },
      {
        name: 'THANOS_STORE_REPLICAS',
        value: '5',
      },
      {
        name: 'THANOS_COMPACTOR_REPLICAS',
        value: '1',
      },
      {
        name: 'THANOS_RECEIVE_REPLICAS',
        value: '5',
      },
      {
        name: 'THANOS_CONFIG_SECRET',
        value: 'thanos-objectstorage',
      },
      {
        name: 'THANOS_S3_SECRET',
        value: 'telemeter-thanos-stage-s3',
      },
      {
        name: 'THANOS_QUERIER_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'THANOS_QUERIER_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'THANOS_QUERIER_MEMORY_REQUEST',
        value: '256Mi',
      },
      {
        name: 'THANOS_QUERIER_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'THANOS_QUERIER_CACHE_REPLICAS',
        value: '3',
      },
      {
        name: 'THANOS_QUERIER_CACHE_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'THANOS_QUERIER_CACHE_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'THANOS_QUERIER_CACHE_MEMORY_REQUEST',
        value: '256Mi',
      },
      {
        name: 'THANOS_QUERIER_CACHE_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'THANOS_STORE_CPU_REQUEST',
        value: '500m',
      },
      {
        name: 'THANOS_STORE_CPU_LIMIT',
        value: '2',
      },
      {
        name: 'THANOS_STORE_MEMORY_REQUEST',
        value: '1Gi',
      },
      {
        name: 'THANOS_STORE_MEMORY_LIMIT',
        value: '8Gi',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_REPLICAS',
        value: '3',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_MEMORY_LIMIT_MB',
        value: '2048',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_CONNECTION_LIMIT',
        value: '3072',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_MEMCACHED_CPU_REQUEST',
        value: '500m',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_MEMCACHED_CPU_LIMIT',
        value: '3',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_MEMCACHED_MEMORY_REQUEST',
        value: '2558Mi',
      },
      {
        name: 'THANOS_STORE_INDEX_CACHE_MEMCACHED_MEMORY_LIMIT',
        value: '3Gi',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_REPLICAS',
        value: '3',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_MEMORY_LIMIT_MB',
        value: '2048',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_CONNECTION_LIMIT',
        value: '3072',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_MEMCACHED_CPU_REQUEST',
        value: '500m',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_MEMCACHED_CPU_LIMIT',
        value: '3',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_MEMCACHED_MEMORY_REQUEST',
        value: '2558Mi',
      },
      {
        name: 'THANOS_STORE_BUCKET_CACHE_MEMCACHED_MEMORY_LIMIT',
        value: '3Gi',
      },
      {
        name: 'THANOS_RECEIVE_CPU_REQUEST',
        value: '1',
      },
      {
        name: 'THANOS_RECEIVE_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'THANOS_RECEIVE_MEMORY_REQUEST',
        value: '1Gi',
      },
      {
        name: 'THANOS_RECEIVE_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'THANOS_COMPACTOR_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'THANOS_COMPACTOR_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'THANOS_COMPACTOR_MEMORY_REQUEST',
        value: '1Gi',
      },
      {
        name: 'THANOS_COMPACTOR_MEMORY_LIMIT',
        value: '5Gi',
      },
      {
        name: 'THANOS_COMPACTOR_PVC_REQUEST',
        value: '50Gi',
      },
      {
        name: 'THANOS_RULER_REPLICAS',
        value: '2',
      },
      {
        name: 'THANOS_RULER_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'THANOS_RULER_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'THANOS_RULER_MEMORY_REQUEST',
        value: '512Mi',
      },
      {
        name: 'THANOS_RULER_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'THANOS_QUERIER_SVC_URL',
        value: 'http://thanos-querier.observatorium.svc:9090',
      },
      {
        name: 'OBSERVATORIUM_API_IMAGE',
        value: 'quay.io/observatorium/observatorium',
      },
      {
        name: 'OBSERVATORIUM_API_IMAGE_TAG',
        value: 'master-2020-04-21-v0.1.1-3-gfd8b3bb',
      },
      {
        name: 'OBSERVATORIUM_API_REPLICAS',
        value: '3',
      },
      {
        name: 'OBSERVATORIUM_API_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'OBSERVATORIUM_API_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'OBSERVATORIUM_API_MEMORY_REQUEST',
        value: '256Mi',
      },
      {
        name: 'OBSERVATORIUM_API_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'JAEGER_PROXY_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'JAEGER_PROXY_MEMORY_REQUEST',
        value: '100Mi',
      },
      {
        name: 'JAEGER_PROXY_CPU_LIMITS',
        value: '200m',
      },
      {
        name: 'JAEGER_PROXY_MEMORY_LIMITS',
        value: '200Mi',
      },
      {
        name: 'IMAGE',
        value: 'quay.io/openshift/origin-telemeter',
      },
      {
        name: 'IMAGE_TAG',
        value: 'v4.0',
      },
      {
        name: 'REPLICAS',
        value: '10',
      },
      {
        name: 'IMAGE_CANARY',
        value: 'quay.io/openshift/origin-telemeter',
      },
      {
        name: 'IMAGE_CANARY_TAG',
        value: 'v4.0',
      },
      {
        name: 'REPLICAS_CANARY',
        value: '0',
      },
      {
        name: 'TELEMETER_SERVER_CPU_REQUEST',
        value: '100m',
      },
      {
        name: 'TELEMETER_SERVER_CPU_LIMIT',
        value: '1',
      },
      {
        name: 'TELEMETER_SERVER_MEMORY_REQUEST',
        value: '500Mi',
      },
      {
        name: 'TELEMETER_SERVER_MEMORY_LIMIT',
        value: '1Gi',
      },
      {
        name: 'MEMCACHED_IMAGE',
        value: 'docker.io/memcached',
      },
      {
        name: 'MEMCACHED_IMAGE_TAG',
        value: '1.5.20-alpine',
      },
      {
        name: 'MEMCACHED_EXPORTER_IMAGE',
        value: 'docker.io/prom/memcached-exporter',
      },
      {
        name: 'MEMCACHED_EXPORTER_IMAGE_TAG',
        value: 'v0.6.0',
      },
      {
        name: 'MEMCACHED_CPU_REQUEST',
        value: '500m',
      },
      {
        name: 'MEMCACHED_CPU_LIMIT',
        value: '3',
      },
      {
        name: 'MEMCACHED_MEMORY_REQUEST',
        value: '1329Mi',
      },
      {
        name: 'MEMCACHED_MEMORY_LIMIT',
        value: '1844Mi',
      },
      {
        name: 'MEMCACHED_EXPORTER_CPU_REQUEST',
        value: '50m',
      },
      {
        name: 'MEMCACHED_EXPORTER_CPU_LIMIT',
        value: '200m',
      },
      {
        name: 'MEMCACHED_EXPORTER_MEMORY_REQUEST',
        value: '50Mi',
      },
      {
        name: 'MEMCACHED_EXPORTER_MEMORY_LIMIT',
        value: '200Mi',
      },
      {
        name: 'TELEMETER_FORWARD_URL',
        value: '',
      },
      {
        name: 'PROMETHEUS_AMS_REMOTE_WRITE_PROXY_IMAGE',
        value: 'quay.io/app-sre/observatorium-receive-proxy',
      },
      {
        name: 'PROMETHEUS_AMS_REMOTE_WRITE_PROXY_VERSION',
        value: '14e844d',
      },
      {
        name: 'THANOS_RECEIVE_TSDB_PATH',
        value: '/var/thanos/receive',
      },
      {
        name: 'PROMETHEUS_AMS_REMOTE_WRITE_PROXY_TARGET',
        value: 'observatorium-thanos-receive',
      },
    ],
  },
}
