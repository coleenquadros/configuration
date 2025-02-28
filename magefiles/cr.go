package main

import (
	"sort"

	kghelpers "github.com/observatorium/observatorium/configuration_go/kubegen/helpers"
	"github.com/observatorium/observatorium/configuration_go/kubegen/openshift"
	routev1 "github.com/openshift/api/route/v1"
	templatev1 "github.com/openshift/api/template/v1"
	"github.com/philipgough/mimic/encoding"
	"github.com/thanos-community/thanos-operator/api/v1alpha1"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/utils/ptr"
)

// OperatorCR Generates the RHOBS-specific CRs for Thanos Operator.
func (s Stage) OperatorCR() {
	templateDir := "rhobs-thanos-operator"

	gen := s.generator(templateDir)

	var objs []runtime.Object

	objs = append(objs, receiveCR(s.namespace(), StageMaps))
	objs = append(objs, queryCR(s.namespace(), StageMaps, true)...)
	objs = append(objs, rulerCR(s.namespace(), StageMaps))
	// TODO: Add compact CRs for stage once we shut down previous
	// objs = append(objs, compactCR(s.namespace(), StageMaps, true)...)
	objs = append(objs, storeCR(s.namespace(), StageMaps)...)

	// Sort objects by Kind then Name
	sort.Slice(objs, func(i, j int) bool {
		iMeta := objs[i].(metav1.Object)
		jMeta := objs[j].(metav1.Object)
		iType := objs[i].GetObjectKind().GroupVersionKind().Kind
		jType := objs[j].GetObjectKind().GroupVersionKind().Kind

		if iType != jType {
			return iType < jType
		}
		return iMeta.GetName() < jMeta.GetName()
	})

	gen.Add("rhobs.yaml", encoding.GhodssYAML(
		openshift.WrapInTemplate(
			objs,
			metav1.ObjectMeta{Name: "thanos-rhobs"},
			[]templatev1.Parameter{},
		),
	))

	gen.Generate()
}

// OperatorCR Generates the RHOBS-specific CRs for Thanos Operator for a local environment.
func (l Local) OperatorCR() {
	templateDir := "rhobs-thanos-operator"

	gen := l.generator(templateDir)

	var objs []runtime.Object

	objs = append(objs, receiveCR(l.namespace(), LocalMaps))
	objs = append(objs, queryCR(l.namespace(), LocalMaps, false)...)
	objs = append(objs, rulerCR(l.namespace(), LocalMaps))
	objs = append(objs, compactCR(l.namespace(), LocalMaps, false)...)
	objs = append(objs, storeCR(l.namespace(), LocalMaps)...)

	// Sort objects by Kind then Name
	sort.Slice(objs, func(i, j int) bool {
		iMeta := objs[i].(metav1.Object)
		jMeta := objs[j].(metav1.Object)
		iType := objs[i].GetObjectKind().GroupVersionKind().Kind
		jType := objs[j].GetObjectKind().GroupVersionKind().Kind

		if iType != jType {
			return iType < jType
		}
		return iMeta.GetName() < jMeta.GetName()
	})

	gen.Add("rhobs.yaml", encoding.GhodssYAML(
		objs[0],
		objs[1],
		objs[2],
		objs[3],
		objs[4],
		objs[5],
		objs[6],
		objs[7],
		objs[8],
	))

	gen.Generate()
}

// tracingSidecar is the jaeger-agent sidecar container for tracing.
func tracingSidecar(m TemplateMaps) corev1.Container {
	return corev1.Container{
		Name:            "jaeger-agent",
		Image:           TemplateFn("JAEGER_AGENT", m.Images),
		ImagePullPolicy: corev1.PullIfNotPresent,
		Args: []string{
			"--reporter.grpc.host-port=dns:///otel-trace-writer-collector-headless.observatorium-tools.svc:14250",
			"--reporter.type=grpc",
			"--agent.tags=pod.namespace=$(NAMESPACE),pod.name=$(POD)",
		},
		Env: []corev1.EnvVar{
			{
				Name: "NAMESPACE",
				ValueFrom: &corev1.EnvVarSource{
					FieldRef: &corev1.ObjectFieldSelector{
						FieldPath: "metadata.namespace",
					},
				},
			},
			{
				Name: "POD",
				ValueFrom: &corev1.EnvVarSource{
					FieldRef: &corev1.ObjectFieldSelector{
						FieldPath: "metadata.name",
					},
				},
			},
		},
		Ports: []corev1.ContainerPort{
			{
				ContainerPort: 5778,
				Name:          "configs",
			},
			{
				ContainerPort: 6831,
				Name:          "jaeger-thrift",
			},
			{
				ContainerPort: 14271,
				Name:          "metrics",
			},
		},
		ReadinessProbe: &corev1.Probe{
			ProbeHandler: corev1.ProbeHandler{
				HTTPGet: &corev1.HTTPGetAction{
					Path:   "/",
					Port:   intstr.FromInt(14271),
					Scheme: corev1.URISchemeHTTP,
				},
			},
			InitialDelaySeconds: 1,
		},
		LivenessProbe: &corev1.Probe{
			ProbeHandler: corev1.ProbeHandler{
				HTTPGet: &corev1.HTTPGetAction{
					Path:   "/",
					Port:   intstr.FromInt(14271),
					Scheme: corev1.URISchemeHTTP,
				},
			},
			FailureThreshold:    5,
			InitialDelaySeconds: 1,
		},
		Resources: corev1.ResourceRequirements{
			Requests: corev1.ResourceList{
				corev1.ResourceCPU:    resource.MustParse("32m"),
				corev1.ResourceMemory: resource.MustParse("64Mi"),
			},
			Limits: corev1.ResourceList{
				corev1.ResourceCPU:    resource.MustParse("128m"),
				corev1.ResourceMemory: resource.MustParse("128Mi"),
			},
		},
	}
}

func storeCR(namespace string, m TemplateMaps) []runtime.Object {
	store0to2w := &v1alpha1.ThanosStore{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosStore",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "telemeter-0to2w",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosStoreSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("STORE02W", m.Images)),
				Version:              ptr.To(TemplateFn("STORE02W", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("STORE02W", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("STORE02W", m.ResourceRequirements)),
			},
			Replicas:            TemplateFn("STORE02W", m.Replicas),
			ObjectStorageConfig: TemplateFn("TELEMETER", m.ObjectStorageBucket),
			ShardingStrategy: v1alpha1.ShardingStrategy{
				Type:   v1alpha1.Block,
				Shards: 1,
			},
			IndexHeaderConfig: &v1alpha1.IndexHeaderConfig{
				EnableLazyReader:      ptr.To(true),
				LazyDownloadStrategy:  ptr.To("lazy"),
				LazyReaderIdleTimeout: ptr.To(v1alpha1.Duration("5m")),
			},
			StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
				StoreLimitsRequestSamples: 627040000,
				StoreLimitsRequestSeries:  1000000,
			},
			BlockConfig: &v1alpha1.BlockConfig{
				BlockDiscoveryStrategy:    v1alpha1.BlockDiscoveryStrategy("concurrent"),
				BlockFilesConcurrency:     ptr.To(int32(1)),
				BlockMetaFetchConcurrency: ptr.To(int32(32)),
			},
			IgnoreDeletionMarksDelay: v1alpha1.Duration("24h"),
			MaxTime:                  ptr.To(v1alpha1.Duration("-2w")),
			StorageSize:              TemplateFn("STORE02W", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-store"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	store2wto90d := &v1alpha1.ThanosStore{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosStore",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "telemeter-2wto90d",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosStoreSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("STORE2W90D", m.Images)),
				Version:              ptr.To(TemplateFn("STORE2W90D", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("STORE2W90D", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("STORE2W90D", m.ResourceRequirements)),
			},
			Replicas:            TemplateFn("STORE2W90D", m.Replicas),
			ObjectStorageConfig: TemplateFn("TELEMETER", m.ObjectStorageBucket),
			ShardingStrategy: v1alpha1.ShardingStrategy{
				Type:   v1alpha1.Block,
				Shards: 1,
			},
			IndexHeaderConfig: &v1alpha1.IndexHeaderConfig{
				EnableLazyReader:      ptr.To(true),
				LazyDownloadStrategy:  ptr.To("lazy"),
				LazyReaderIdleTimeout: ptr.To(v1alpha1.Duration("5m")),
			},
			StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
				StoreLimitsRequestSamples: 627040000,
				StoreLimitsRequestSeries:  1000000,
			},
			BlockConfig: &v1alpha1.BlockConfig{
				BlockDiscoveryStrategy:    v1alpha1.BlockDiscoveryStrategy("concurrent"),
				BlockFilesConcurrency:     ptr.To(int32(1)),
				BlockMetaFetchConcurrency: ptr.To(int32(32)),
			},
			IgnoreDeletionMarksDelay: v1alpha1.Duration("24h"),
			MinTime:                  ptr.To(v1alpha1.Duration("-90d")),
			MaxTime:                  ptr.To(v1alpha1.Duration("-2w")),
			StorageSize:              TemplateFn("STORE2W90D", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-store"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
				PodDisruptionBudgetConfig: &v1alpha1.PodDisruptionBudgetConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	store90dplus := &v1alpha1.ThanosStore{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosStore",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "telemeter-90dplus",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosStoreSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("STORE90D+", m.Images)),
				Version:              ptr.To(TemplateFn("STORE90D+", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("STORE90D+", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("STORE90D+", m.ResourceRequirements)),
			},
			Replicas:            TemplateFn("STORE90D+", m.Replicas),
			ObjectStorageConfig: TemplateFn("TELEMETER", m.ObjectStorageBucket),
			ShardingStrategy: v1alpha1.ShardingStrategy{
				Type:   v1alpha1.Block,
				Shards: 1,
			},
			IndexHeaderConfig: &v1alpha1.IndexHeaderConfig{
				EnableLazyReader:      ptr.To(true),
				LazyDownloadStrategy:  ptr.To("lazy"),
				LazyReaderIdleTimeout: ptr.To(v1alpha1.Duration("5m")),
			},
			StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
				StoreLimitsRequestSamples: 627040000,
				StoreLimitsRequestSeries:  1000000,
			},
			BlockConfig: &v1alpha1.BlockConfig{
				BlockDiscoveryStrategy:    v1alpha1.BlockDiscoveryStrategy("concurrent"),
				BlockFilesConcurrency:     ptr.To(int32(1)),
				BlockMetaFetchConcurrency: ptr.To(int32(32)),
			},
			IgnoreDeletionMarksDelay: v1alpha1.Duration("24h"),
			MinTime:                  ptr.To(v1alpha1.Duration("-90d")),
			StorageSize:              TemplateFn("STORE90D+", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-store"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	storeDefault := &v1alpha1.ThanosStore{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosStore",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "default",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosStoreSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("STORE_DEFAULT", m.Images)),
				Version:              ptr.To(TemplateFn("STORE_DEFAULT", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("STORE_DEFAULT", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("STORE_DEFAULT", m.ResourceRequirements)),
			},
			Replicas:            TemplateFn("STORE_DEFAULT", m.Replicas),
			ObjectStorageConfig: TemplateFn("DEFAULT", m.ObjectStorageBucket),
			ShardingStrategy: v1alpha1.ShardingStrategy{
				Type:   v1alpha1.Block,
				Shards: 1,
			},
			IndexHeaderConfig: &v1alpha1.IndexHeaderConfig{
				EnableLazyReader:      ptr.To(true),
				LazyDownloadStrategy:  ptr.To("lazy"),
				LazyReaderIdleTimeout: ptr.To(v1alpha1.Duration("5m")),
			},
			StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
				StoreLimitsRequestSamples: 0,
				StoreLimitsRequestSeries:  0,
			},
			BlockConfig: &v1alpha1.BlockConfig{
				BlockDiscoveryStrategy:    v1alpha1.BlockDiscoveryStrategy("concurrent"),
				BlockFilesConcurrency:     ptr.To(int32(1)),
				BlockMetaFetchConcurrency: ptr.To(int32(32)),
			},
			IgnoreDeletionMarksDelay: v1alpha1.Duration("24h"),
			MaxTime:                  ptr.To(v1alpha1.Duration("-22h")),
			StorageSize:              TemplateFn("STORE_DEFAULT", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-store"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	return []runtime.Object{store0to2w, store2wto90d, store90dplus, storeDefault}
}

func receiveCR(namespace string, m TemplateMaps) runtime.Object {
	return &v1alpha1.ThanosReceive{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosReceive",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "rhobs",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosReceiveSpec{
			Router: v1alpha1.RouterSpec{
				CommonFields: v1alpha1.CommonFields{
					Image:                ptr.To(TemplateFn("RECEIVE_ROUTER", m.Images)),
					Version:              ptr.To(TemplateFn("RECEIVE_ROUTER", m.Versions)),
					ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
					LogLevel:             ptr.To(TemplateFn("RECEIVE_ROUTER", m.LogLevels)),
					LogFormat:            ptr.To("logfmt"),
					ResourceRequirements: ptr.To(TemplateFn("RECEIVE_ROUTER", m.ResourceRequirements)),
				},
				Replicas:          TemplateFn("RECEIVE_ROUTER", m.Replicas),
				ReplicationFactor: 3,
				ExternalLabels: map[string]string{
					"receive": "true",
				},
				Additional: v1alpha1.Additional{
					Containers: []corev1.Container{
						tracingSidecar(m),
					},
					Args: []string{
						`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-receive-router"
"type": "JAEGER"`,
					},
				},
			},
			Ingester: v1alpha1.IngesterSpec{
				DefaultObjectStorageConfig: TemplateFn("TELEMETER", m.ObjectStorageBucket),
				Additional: v1alpha1.Additional{
					Containers: []corev1.Container{
						tracingSidecar(m),
					},
					Args: []string{
						`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-receive-ingester"
"type": "JAEGER"`,
					},
				},
				Hashrings: []v1alpha1.IngesterHashringSpec{
					{
						Name: "telemeter",
						CommonFields: v1alpha1.CommonFields{
							Image:                ptr.To(TemplateFn("RECEIVE_INGESTOR_TELEMETER", m.Images)),
							Version:              ptr.To(TemplateFn("RECEIVE_INGESTOR_TELEMETER", m.Versions)),
							ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
							LogLevel:             ptr.To(TemplateFn("RECEIVE_INGESTOR_TELEMETER", m.LogLevels)),
							LogFormat:            ptr.To("logfmt"),
							ResourceRequirements: ptr.To(TemplateFn("RECEIVE_INGESTOR_TELEMETER", m.ResourceRequirements)),
						},
						ExternalLabels: map[string]string{
							"replica": "$(POD_NAME)",
						},
						Replicas: TemplateFn("RECEIVE_INGESTOR_TELEMETER", m.Replicas),
						TSDBConfig: v1alpha1.TSDBConfig{
							Retention: v1alpha1.Duration("4h"),
						},
						AsyncForwardWorkerCount:  ptr.To(uint64(50)),
						TooFarInFutureTimeWindow: ptr.To(v1alpha1.Duration("5m")),
						StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
							StoreLimitsRequestSamples: 627040000,
							StoreLimitsRequestSeries:  1000000,
						},
						TenancyConfig: &v1alpha1.TenancyConfig{
							TenantMatcherType: "exact",
							DefaultTenantID:   "FB870BF3-9F3A-44FF-9BF7-D7A047A52F43",
							TenantHeader:      "THANOS-TENANT",
							TenantLabelName:   "tenant_id",
						},
						StorageSize: TemplateFn("RECEIVE_TELEMETER", m.StorageSize),
					},
					{
						Name: "default",
						CommonFields: v1alpha1.CommonFields{
							Image:                ptr.To(TemplateFn("RECEIVE_INGESTOR_DEFAULT", m.Images)),
							Version:              ptr.To(TemplateFn("RECEIVE_INGESTOR_DEFAULT", m.Versions)),
							ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
							LogLevel:             ptr.To(TemplateFn("RECEIVE_INGESTOR_DEFAULT", m.LogLevels)),
							LogFormat:            ptr.To("logfmt"),
							ResourceRequirements: ptr.To(TemplateFn("RECEIVE_INGESTOR_DEFAULT", m.ResourceRequirements)),
						},
						ExternalLabels: map[string]string{
							"replica": "$(POD_NAME)",
						},
						Replicas: TemplateFn("RECEIVE_INGESTOR_DEFAULT", m.Replicas),
						TSDBConfig: v1alpha1.TSDBConfig{
							Retention: v1alpha1.Duration("1d"),
						},
						AsyncForwardWorkerCount:  ptr.To(uint64(5)),
						TooFarInFutureTimeWindow: ptr.To(v1alpha1.Duration("5m")),
						StoreLimitsOptions: &v1alpha1.StoreLimitsOptions{
							StoreLimitsRequestSamples: 0,
							StoreLimitsRequestSeries:  0,
						},
						TenancyConfig: &v1alpha1.TenancyConfig{
							TenantMatcherType: "exact",
							DefaultTenantID:   "FB870BF3-9F3A-44FF-9BF7-D7A047A52F43",
							TenantHeader:      "THANOS-TENANT",
							TenantLabelName:   "tenant_id",
						},
						ObjectStorageConfig: ptr.To(TemplateFn("DEFAULT", m.ObjectStorageBucket)),
						StorageSize:         TemplateFn("RECEIVE_DEFAULT", m.StorageSize),
					},
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}
}

func queryCR(namespace string, m TemplateMaps, oauth bool) []runtime.Object {
	var objs []runtime.Object

	query := &v1alpha1.ThanosQuery{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosQuery",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "rhobs",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosQuerySpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("QUERY", m.Images)),
				Version:              ptr.To(TemplateFn("QUERY", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("QUERY", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("QUERY", m.ResourceRequirements)),
			},
			StoreLabelSelector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"operator.thanos.io/store-api": "true",
					"app.kubernetes.io/part-of":    "thanos",
				},
			},
			Replicas: TemplateFn("QUERY", m.Replicas),
			ReplicaLabels: []string{
				"prometheus_replica",
				"replica",
				"rule_replica",
			},
			WebConfig: &v1alpha1.WebConfig{
				PrefixHeader: ptr.To("X-Forwarded-Prefix"),
			},
			GRPCProxyStrategy: "lazy",
			TelemetryQuantiles: &v1alpha1.TelemetryQuantiles{
				Duration: []string{
					"0.1", "0.25", "0.75", "1.25", "1.75", "2.5", "3", "5", "10", "15", "30", "60", "120",
				},
			},
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-query"
"type": "JAEGER"`,
				},
			},
			QueryFrontend: &v1alpha1.QueryFrontendSpec{
				CommonFields: v1alpha1.CommonFields{
					Image:                ptr.To(TemplateFn("QUERY_FRONTEND", m.Images)),
					Version:              ptr.To(TemplateFn("QUERY_FRONTEND", m.Versions)),
					ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
					LogLevel:             ptr.To(TemplateFn("QUERY_FRONTEND", m.LogLevels)),
					LogFormat:            ptr.To("logfmt"),
					ResourceRequirements: ptr.To(TemplateFn("QUERY_FRONTEND", m.ResourceRequirements)),
				},
				Replicas:             TemplateFn("QUERY_FRONTEND", m.Replicas),
				CompressResponses:    true,
				LogQueriesLongerThan: ptr.To(v1alpha1.Duration("10s")),
				LabelsMaxRetries:     3,
				QueryRangeMaxRetries: 3,
				QueryLabelSelector: &metav1.LabelSelector{
					MatchLabels: map[string]string{
						"operator.thanos.io/query-api": "true",
					},
				},
				QueryRangeSplitInterval: ptr.To(v1alpha1.Duration("48h")),
				LabelsSplitInterval:     ptr.To(v1alpha1.Duration("48h")),
				LabelsDefaultTimeRange:  ptr.To(v1alpha1.Duration("336h")),
				Additional: v1alpha1.Additional{
					Containers: []corev1.Container{
						tracingSidecar(m),
					},
					Args: []string{
						`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-query-frontend"
"type": "JAEGER"`,
					},
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
				PodDisruptionBudgetConfig: &v1alpha1.PodDisruptionBudgetConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}
	if oauth {
		route := &routev1.Route{
			TypeMeta: metav1.TypeMeta{
				APIVersion: "route.openshift.io/v1",
				Kind:       "Route",
			},
			ObjectMeta: metav1.ObjectMeta{
				Name:      "thanos-query-frontend-rhobs",
				Namespace: namespace,
				Labels: map[string]string{
					"app.kubernetes.io/part-of": "thanos",
				},
			},
			Spec: routev1.RouteSpec{
				To: routev1.RouteTargetReference{
					Kind:   "Service",
					Name:   "thanos-query-frontend-rhobs",
					Weight: ptr.To(int32(100)),
				},
				Port: &routev1.RoutePort{
					TargetPort: intstr.FromString("https"), // Assuming the oauth-proxy is exposing on https port
				},
				TLS: &routev1.TLSConfig{
					Termination:                   routev1.TLSTerminationReencrypt,
					InsecureEdgeTerminationPolicy: routev1.InsecureEdgeTerminationPolicyRedirect,
				},
			},
		}
		objs = append(objs, route)
		query.Annotations = map[string]string{
			"service.beta.openshift.io/serving-cert-secret-name":               "query-frontend-tls",
			"serviceaccounts.openshift.io/oauth-redirectreference.application": `{"kind":"OAuthRedirectReference","apiVersion":"v1","reference":{"kind":"Route","name":"thanos-query-frontend-rhobs"}}`,
		}
		query.Spec.QueryFrontend.Additional.ServicePorts = append(query.Spec.QueryFrontend.Additional.ServicePorts, corev1.ServicePort{
			Name: "https",
			Port: 8443,
			TargetPort: intstr.IntOrString{
				Type:   intstr.Int,
				IntVal: 8443,
			},
		})
		query.Spec.QueryFrontend.Additional.Containers = append(query.Spec.QueryFrontend.Additional.Containers, makeOauthProxy(9090, namespace, "thanos-query-frontend-rhobs", "query-frontend-tls").GetContainer())
		query.Spec.QueryFrontend.Additional.Volumes = append(query.Spec.QueryFrontend.Additional.Volumes, kghelpers.NewPodVolumeFromSecret("tls", "query-frontend-tls"))
	}

	objs = append(objs, query)
	return objs
}

func rulerCR(namespace string, m TemplateMaps) runtime.Object {
	return &v1alpha1.ThanosRuler{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosRuler",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "rhobs",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosRulerSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("RULER", m.Images)),
				Version:              ptr.To(TemplateFn("RULER", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("RULER", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("RULER", m.ResourceRequirements)),
			},
			Paused:   ptr.To(true),
			Replicas: TemplateFn("RULER", m.Replicas),
			RuleConfigSelector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"operator.thanos.io/rule-file": "true",
				},
			},
			PrometheusRuleSelector: metav1.LabelSelector{
				MatchLabels: map[string]string{
					"operator.thanos.io/prometheus-rule": "true",
				},
			},
			QueryLabelSelector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"operator.thanos.io/query-api": "true",
					"app.kubernetes.io/part-of":    "thanos",
				},
			},
			ExternalLabels: map[string]string{
				"rule_replica": "$(NAME)",
			},
			ObjectStorageConfig: TemplateFn("DEFAULT", m.ObjectStorageBucket),
			AlertmanagerURL:     "dnssrv+http://alertmanager-cluster." + namespace + ".svc.cluster.local:9093",
			AlertLabelDrop:      []string{"rule_replica"},
			Retention:           v1alpha1.Duration("48h"),
			EvaluationInterval:  v1alpha1.Duration("1m"),
			StorageSize:         string(TemplateFn("RULER", m.StorageSize)),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-ruler"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}
}

func compactCR(namespace string, m TemplateMaps, oauth bool) []runtime.Object {
	defaultCompact := &v1alpha1.ThanosCompact{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosCompact",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "rhobs",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosCompactSpec{
			CommonFields: v1alpha1.CommonFields{
				Image:                ptr.To(TemplateFn("COMPACT_DEFAULT", m.Images)),
				Version:              ptr.To(TemplateFn("COMPACT_DEFAULT", m.Versions)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("COMPACT_DEFAULT", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("COMPACT_DEFAULT", m.ResourceRequirements)),
			},
			ObjectStorageConfig: TemplateFn("DEFAULT", m.ObjectStorageBucket),
			RetentionConfig: v1alpha1.RetentionResolutionConfig{
				Raw:         v1alpha1.Duration("365d"),
				FiveMinutes: v1alpha1.Duration("365d"),
				OneHour:     v1alpha1.Duration("365d"),
			},
			DownsamplingConfig: &v1alpha1.DownsamplingConfig{
				Concurrency: ptr.To(int32(1)),
				Disable:     ptr.To(false),
			},
			CompactConfig: &v1alpha1.CompactConfig{
				CompactConcurrency: ptr.To(int32(1)),
			},
			DebugConfig: &v1alpha1.DebugConfig{
				AcceptMalformedIndex: ptr.To(true),
				HaltOnError:          ptr.To(true),
				MaxCompactionLevel:   ptr.To(int32(3)),
			},
			StorageSize: TemplateFn("COMPACT_DEFAULT", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-compact"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	if oauth {
		defaultCompact.Spec.Additional.Containers = append(defaultCompact.Spec.Additional.Containers, makeOauthProxy(10902, namespace, "thanos-compact-rhobs", "compact-tls").GetContainer())
		defaultCompact.Spec.Additional.Volumes = append(defaultCompact.Spec.Additional.Volumes, kghelpers.NewPodVolumeFromSecret("tls", "compact-tls"))
	}

	telemeterCompact := &v1alpha1.ThanosCompact{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "monitoring.thanos.io/v1alpha1",
			Kind:       "ThanosCompact",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "telemeter",
			Namespace: namespace,
		},
		Spec: v1alpha1.ThanosCompactSpec{
			CommonFields: v1alpha1.CommonFields{
				Version:              ptr.To(TemplateFn("COMPACT_TELEMETER", m.Versions)),
				Image:                ptr.To(TemplateFn("COMPACT_TELEMETER", m.Images)),
				ImagePullPolicy:      ptr.To(corev1.PullIfNotPresent),
				LogLevel:             ptr.To(TemplateFn("COMPACT_TELEMETER", m.LogLevels)),
				LogFormat:            ptr.To("logfmt"),
				ResourceRequirements: ptr.To(TemplateFn("COMPACT_TELEMETER", m.ResourceRequirements)),
			},
			ObjectStorageConfig: TemplateFn("TELEMETER", m.ObjectStorageBucket),
			RetentionConfig: v1alpha1.RetentionResolutionConfig{
				Raw:         v1alpha1.Duration("365d"),
				FiveMinutes: v1alpha1.Duration("365d"),
				OneHour:     v1alpha1.Duration("365d"),
			},
			DownsamplingConfig: &v1alpha1.DownsamplingConfig{
				Concurrency: ptr.To(int32(1)),
				Disable:     ptr.To(false),
			},
			CompactConfig: &v1alpha1.CompactConfig{
				CompactConcurrency: ptr.To(int32(1)),
			},
			DebugConfig: &v1alpha1.DebugConfig{
				AcceptMalformedIndex: ptr.To(true),
				HaltOnError:          ptr.To(true),
				MaxCompactionLevel:   ptr.To(int32(3)),
			},
			StorageSize: TemplateFn("COMPACT_TELEMETER", m.StorageSize),
			Additional: v1alpha1.Additional{
				Containers: []corev1.Container{
					tracingSidecar(m),
				},
				Args: []string{
					`--tracing.config="config":
  "sampler_param": 2
  "sampler_type": "ratelimiting"
  "service_name": "thanos-compact"
"type": "JAEGER"`,
				},
			},
			FeatureGates: &v1alpha1.FeatureGates{
				ServiceMonitorConfig: &v1alpha1.ServiceMonitorConfig{
					Enable: ptr.To(false),
				},
			},
		},
	}

	if oauth {
		telemeterCompact.Spec.Additional.Containers = append(telemeterCompact.Spec.Additional.Containers, makeOauthProxy(10902, namespace, "thanos-compact-telemeter", "compact-tls").GetContainer())
		telemeterCompact.Spec.Additional.Volumes = append(telemeterCompact.Spec.Additional.Volumes, kghelpers.NewPodVolumeFromSecret("tls", "compact-tls"))
	}

	return []runtime.Object{defaultCompact, telemeterCompact}
}
