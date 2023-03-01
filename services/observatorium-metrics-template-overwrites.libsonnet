// This is the file overwriting and extending the upstream objects to, in the end,
// generate a OpenShift template specifically for AppSRE.

local jaegerAgent = import './sidecars/jaeger-agent.libsonnet';
local oauthProxy = import './sidecars/oauth-proxy.libsonnet';
local thanosRuleSyncer = import './sidecars/thanos-rule-syncer.libsonnet';

{
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

  // JaegerAgent sidecar shared across components, thus instantiated outside components.
  local jaegerAgentSidecar = jaegerAgent({
    image: '${JAEGER_AGENT_IMAGE}:${JAEGER_AGENT_IMAGE_TAG}',
    collectorAddress: 'dns:///jaeger-collector-headless.${JAEGER_COLLECTOR_NAMESPACE}.svc:14250',
  }),

  local ruleSyncerVolume = 'rule-syncer',
  local ruleSyncerSidecar = thanosRuleSyncer({
    image: '${THANOS_RULE_SYNCER_IMAGE}:${THANOS_RULE_SYNCER_IMAGE_TAG}',
    rulesBackendURL: 'http://rules-objstore.${OBSERVATORIUM_NAMESPACE}.svc:8080',
    volumeName: ruleSyncerVolume,
    fileName: 'observatorium.yaml',
  }),

  thanos+:: {
    local thanos = self,
    config+:: {
      serviceAccountName: '${SERVICE_ACCOUNT_NAME}',
    },

    // This extends and overwrites the objects generated by the upstream function for OpenShift specific needs.
    compact+:: {
      local compact = self,
      // Create oauthProxy instance for compact and then merge its objects with the existing ones.
      local oauth = oauthProxy({
        name: 'compact',
        image: '${OAUTH_PROXY_IMAGE}:${OAUTH_PROXY_IMAGE_TAG}',
        upstream: 'http://localhost:10902',
        serviceAccountName: thanos.config.serviceAccountName,
        sessionSecretName: 'compact-proxy',
        resources: {
          requests: {
            cpu: '${OAUTH_PROXY_CPU_REQUEST}',
            memory: '${OAUTH_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${OAUTH_PROXY_CPU_LIMITS}',
            memory: '${OAUTH_PROXY_MEMORY_LIMITS}',
          },
        },
      }),

      proxySecret: oauth.proxySecret {
        metadata+: { labels+: compact.config.commonLabels },
      },

      service+: oauth.service,

      statefulSet+: {
        spec+: {
          replicas: '${{THANOS_COMPACTOR_REPLICAS}}',
          local disableDownsamplingFlag =
            if !compact.config.disableDownsampling then
              ['${THANOS_COMPACTOR_RETENTION_DISABLE_DOWNSAMPLING}']
            else [],
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                // Overwrite and extend the thanos-compact container only
                if c.name == 'thanos-compact' then c {
                  env+: s3EnvVars,
                  // Temporary workaround on high cardinality blocks for 2w.
                  // Since we have only 2w retention, there is no point in having 2w blocks.
                  // See: https://issues.redhat.com/browse/OBS-437
                  args+: ['--debug.max-compaction-level=3'] + disableDownsamplingFlag,
                } else c
                for c in super.containers
              ],
            },
          },
        },
      } + oauth.statefulSet,
    },

    rule+:: {
      service+: ruleSyncerSidecar.service,
      serviceMonitor+: ruleSyncerSidecar.serviceMonitor,
      statefulSet+: jaegerAgentSidecar.statefulSet + ruleSyncerSidecar.statefulSet {
        spec+: {
          replicas: '${{THANOS_RULER_REPLICAS}}',
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-rule' then c {
                  env+: s3EnvVars,
                  volumeMounts+: [{
                    name: ruleSyncerVolume,
                    mountPath: '/etc/thanos/rules/rule-syncer',
                  }],
                  readinessProbe+: {
                    failureThreshold: 3,
                    periodSeconds: 180,
                    initialDelaySeconds: 60,
                  },
                  livenessProbe+: {
                    failureThreshold: 10,
                    periodSeconds: 120,
                  },
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    statelessRule+:: {
      statefulSet+: jaegerAgentSidecar.statefulSet + ruleSyncerSidecar.statefulSet {
        spec+: {
          replicas: '${{THANOS_RULER_REPLICAS}}',
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-rule' then c {
                  env+: s3EnvVars,
                  volumeMounts+: [{
                    name: ruleSyncerVolume,
                    mountPath: '/etc/thanos/rules/rule-syncer',
                  }],
                  readinessProbe+: {
                    failureThreshold: 3,
                    periodSeconds: 180,
                    initialDelaySeconds: 60,
                  },
                  livenessProbe+: {
                    failureThreshold: 10,
                    periodSeconds: 120,
                  },
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    metricFederationRule+:: {
      statefulSet+: jaegerAgentSidecar.statefulSet {
        spec+: {
          replicas: '${{THANOS_RULER_REPLICAS}}',
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-rule' then c {
                  env+: s3EnvVars,
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    metricFederationStatelessRule+:: {
      statefulSet+: jaegerAgentSidecar.statefulSet {
        spec+: {
          replicas: '${{THANOS_RULER_REPLICAS}}',
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-rule' then c {
                  env+: s3EnvVars,
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    stores+:: {
      shards:
        std.mapWithKey(function(shard, obj) obj {  // loops over each [shard-n]:obj
          statefulSet+: jaegerAgentSidecar.statefulSet {
            spec+: {
              replicas: '${{THANOS_STORE_REPLICAS}}',
              template+: {
                spec+: {
                  securityContext: {},
                  containers: [
                    if c.name == 'thanos-store' then c {
                      env+: s3EnvVars,
                      args+: [
                        '--store.grpc.touched-series-limit=${THANOS_STORE_SERIES_TOUCHED_LIMIT}',
                        '--store.grpc.series-sample-limit=${THANOS_STORE_SERIES_SAMPLE_LIMIT}',
                        '--max-time=${THANOS_STORE_MAX_TIME}',
                      ],
                    } else c
                    for c in super.containers
                  ],
                },
              },
            },
          },
        }, super.shards),
    },

    receiveController+:: {
      deployment+: {
        spec+: {
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-receive-controller' then c {
                  securityContext: {},
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    storeIndexCache+:: {
      statefulSet+: {
        spec+: {
          template+: {
            spec+: {
              securityContext: {},
            },
          },
          replicas: '${{THANOS_STORE_INDEX_CACHE_REPLICAS}}',
          volumeClaimTemplates:: null,
        },
      },
    },

    storeBucketCache+:: {
      statefulSet+: {
        spec+: {
          template+: {
            spec+: {
              securityContext: {},
            },
          },
          replicas: '${{THANOS_STORE_BUCKET_CACHE_REPLICAS}}',
          volumeClaimTemplates:: null,
        },
      },
    },

    query+:: {
      local query = self,
      local oauth = oauthProxy({
        name: 'query',
        image: '${OAUTH_PROXY_IMAGE}:${OAUTH_PROXY_IMAGE_TAG}',
        upstream: 'http://localhost:9090',
        ports: { https: 9091 },
        serviceAccountName: thanos.config.serviceAccountName,
        sessionSecretName: 'query-proxy',
        resources: {
          requests: {
            cpu: '${OAUTH_PROXY_CPU_REQUEST}',
            memory: '${OAUTH_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${OAUTH_PROXY_CPU_LIMITS}',
            memory: '${OAUTH_PROXY_MEMORY_LIMITS}',
          },
        },
      }),

      proxySecret: oauth.proxySecret {
        metadata+: { labels+: query.config.commonLabels },
      },

      service+: oauth.service,

      deployment+: oauth.deployment + jaegerAgentSidecar.deployment {
        spec+: {
          replicas: '${{THANOS_QUERIER_REPLICAS}}',
          securityContext: {},
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-query' then c {
                  args+: [
                    '--grpc.proxy-strategy=${THANOS_QUERIER_PROXY_STRATEGY}',
                    '--query.promql-engine=${THANOS_QUERIER_ENGINE}',
                    '--query.max-concurrent=${THANOS_QUERIER_MAX_CONCURRENT}',
                  ],
                } else c
                for c in super.containers
              ],
            },
          },
        },
      },
    },

    volcanoQuery+:: {
      local query = self,
      local oauth = oauthProxy({
        name: 'query',
        image: '${OAUTH_PROXY_IMAGE}:${OAUTH_PROXY_IMAGE_TAG}',
        upstream: 'http://localhost:9090',
        ports: { https: 9091 },
        serviceAccountName: thanos.config.serviceAccountName,
        sessionSecretName: 'query-proxy',
        resources: {
          requests: {
            cpu: '${OAUTH_PROXY_CPU_REQUEST}',
            memory: '${OAUTH_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${OAUTH_PROXY_CPU_LIMITS}',
            memory: '${OAUTH_PROXY_MEMORY_LIMITS}',
          },
        },
      }),

      proxySecret: oauth.proxySecret {
        metadata+: { labels+: query.config.commonLabels },
      },

      service+: oauth.service,

      deployment+: oauth.deployment + jaegerAgentSidecar.deployment {
        spec+: {
          securityContext: {},
          template+: {
            spec+: {
              securityContext: {},
            },
          },
        },
      },
    },

    queryFrontendCache+:: {
      statefulSet+: {
        spec+: {
          template+: {
            spec+: {
              securityContext: {},
            },
          },
          volumeClaimTemplates:: null,
        },
      },
    },

    queryFrontend+:: {
      local queryFrontend = self,
      local oauth = oauthProxy({
        name: 'query-frontend',
        image: '${OAUTH_PROXY_IMAGE}:${OAUTH_PROXY_IMAGE_TAG}',
        upstream: 'http://localhost:9090',
        ports: { https: 9091 },
        serviceAccountName: thanos.config.serviceAccountName,
        sessionSecretName: 'query-frontend-proxy',
        resources: {
          requests: {
            cpu: '${OAUTH_PROXY_CPU_REQUEST}',
            memory: '${OAUTH_PROXY_MEMORY_REQUEST}',
          },
          limits: {
            cpu: '${OAUTH_PROXY_CPU_LIMITS}',
            memory: '${OAUTH_PROXY_MEMORY_LIMITS}',
          },
        },
      }),

      proxySecret: oauth.proxySecret {
        metadata+: { labels+: queryFrontend.config.commonLabels },
      },

      service+: oauth.service,

      deployment+: {
        spec+: {
          replicas: '${{THANOS_QUERY_FRONTEND_REPLICAS}}',
          template+: {
            spec+: {
              securityContext: {},
              containers: [
                if c.name == 'thanos-query-frontend' then c {
                  args: std.filter(function(arg)
                          !std.member([
                            '--query-range.split-interval',
                            '--query-range.max-retries-per-request',
                            '--labels.split-interval',
                            '--labels.max-retries-per-request',
                            '--labels.default-time-range',
                            '--cache-compression-type',
                          ], std.split(arg, '=')[0]), super.args)
                        + [
                          '--query-range.split-interval=%s' % '${THANOS_QUERY_FRONTEND_SPLIT_INTERVAL}',
                          '--labels.split-interval=%s' % '${THANOS_QUERY_FRONTEND_SPLIT_INTERVAL}',
                          '--query-range.max-retries-per-request=%s' % '${THANOS_QUERY_FRONTEND_MAX_RETRIES}',
                          '--labels.max-retries-per-request=%s' % '${THANOS_QUERY_FRONTEND_MAX_RETRIES}',
                          '--labels.default-time-range=336h',
                          '--cache-compression-type=snappy',
                        ],
                } else c
                for c in super.containers
              ],
            },
          },
        },
      } + oauth.deployment + jaegerAgentSidecar.deployment,
    },

    receivers+:: {
      hashrings:
        std.mapWithKey(function(hashring, obj) obj {  // loops over each [hashring]:obj
          statefulSet+: jaegerAgentSidecar.statefulSet {
            spec+: {
              podManagementPolicy: 'Parallel',
              replicas: '${{THANOS_RECEIVE_REPLICAS}}',
              template+: {
                spec+: {
                  securityContext: {},
                  containers: [
                    if c.name == 'thanos-receive' then c {
                      args+: [
                        '--receive.default-tenant-id=FB870BF3-9F3A-44FF-9BF7-D7A047A52F43',
                        '--receive.grpc-compression=none',
                        '--receive.hashrings-algorithm=${THANOS_RECEIVE_HASHRINGS_ALGORITHM}',
                      ],
                      env+: s3EnvVars + [{
                        name: 'DEBUG',
                        value: '${THANOS_RECEIVE_DEBUG_ENV}',
                      }],
                      readinessProbe+: {
                        failureThreshold: 20,
                        periodSeconds: 30,
                        initialDelaySeconds: 60,
                      },
                    } + {
                      args: [
                        if std.startsWith(a, '--tsdb.path') then '--tsdb.path=${THANOS_RECEIVE_TSDB_PATH}'
                        else if std.startsWith(a, '--tsdb.retention') then '--tsdb.retention=${THANOS_RECEIVE_TSDB_RETENTION}' else a
                        for a in super.args
                      ],
                    } else c
                    for c in super.containers
                  ],
                },
              },
            },
          },
        }, super.hashrings),
    },
  },
} + {
  thanos+:: {
    [name]+: {
      serviceMonitor+: {
        metadata+: {
          labels+: {
            prometheus: 'app-sre',
            'app.kubernetes.io/version':: 'hidden',
          },
        },
        spec+: {
          namespaceSelector: {
            // NOTICE:
            // When using the ${{PARAMETER_NAME}} syntax only a single parameter reference is allowed and leading/trailing characters are not permitted.
            // The resulting value will be unquoted unless, after substitution is performed, the result is not a valid json object.
            // If the result is not a valid json value, the resulting value will be quoted and treated as a standard string.
            matchNames: '${{NAMESPACES}}',
          },
          selector+: { matchLabels+: { 'app.kubernetes.io/version':: 'hidden' } },
        },
      },
    }
    for name in std.objectFieldsAll(super.thanos)
    if std.objectHas(super.thanos[name], 'serviceMonitor')
  },
}
