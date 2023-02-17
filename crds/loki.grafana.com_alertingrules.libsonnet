{
  apiVersion: 'apiextensions.k8s.io/v1',
  kind: 'CustomResourceDefinition',
  metadata: {
    annotations: {
      'controller-gen.kubebuilder.io/version': 'v0.10.0',
    },
    creationTimestamp: null,
    labels: {
      'app.kubernetes.io/instance': 'loki-operator-v0.1.0',
      'app.kubernetes.io/managed-by': 'operator-lifecycle-manager',
      'app.kubernetes.io/name': 'loki-operator',
      'app.kubernetes.io/part-of': 'loki-operator',
      'app.kubernetes.io/version': '0.1.0',
    },
    name: 'alertingrules.loki.grafana.com',
  },
  spec: {
    group: 'loki.grafana.com',
    names: {
      kind: 'AlertingRule',
      listKind: 'AlertingRuleList',
      plural: 'alertingrules',
      singular: 'alertingrule',
    },
    scope: 'Namespaced',
    versions: [
      {
        name: 'v1beta1',
        schema: {
          openAPIV3Schema: {
            description: 'AlertingRule is the Schema for the alertingrules API',
            properties: {
              apiVersion: {
                description: 'APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources',
                type: 'string',
              },
              kind: {
                description: 'Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds',
                type: 'string',
              },
              metadata: {
                type: 'object',
              },
              spec: {
                description: 'AlertingRuleSpec defines the desired state of AlertingRule',
                properties: {
                  groups: {
                    description: 'List of groups for alerting rules.',
                    items: {
                      description: 'AlertingRuleGroup defines a group of Loki alerting rules.',
                      properties: {
                        interval: {
                          default: '1m',
                          description: 'Interval defines the time interval between evaluation of the given alerting rule.',
                          pattern: '((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)',
                          type: 'string',
                        },
                        limit: {
                          description: 'Limit defines the number of alerts an alerting rule can produce. 0 is no limit.',
                          format: 'int32',
                          type: 'integer',
                        },
                        name: {
                          description: 'Name of the alerting rule group. Must be unique within all alerting rules.',
                          type: 'string',
                        },
                        rules: {
                          description: 'Rules defines a list of alerting rules',
                          items: {
                            description: 'AlertingRuleGroupSpec defines the spec for a Loki alerting rule.',
                            properties: {
                              alert: {
                                description: 'The name of the alert. Must be a valid label value.',
                                type: 'string',
                              },
                              annotations: {
                                additionalProperties: {
                                  type: 'string',
                                },
                                description: 'Annotations to add to each alert.',
                                type: 'object',
                              },
                              expr: {
                                description: 'The LogQL expression to evaluate. Every evaluation cycle this is evaluated at the current time, and all resultant time series become pending/firing alerts.',
                                type: 'string',
                              },
                              'for': {
                                description: 'Alerts are considered firing once they have been returned for this long. Alerts which have not yet fired for long enough are considered pending.',
                                pattern: '((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)',
                                type: 'string',
                              },
                              labels: {
                                additionalProperties: {
                                  type: 'string',
                                },
                                description: 'Labels to add to each alert.',
                                type: 'object',
                              },
                            },
                            required: [
                              'expr',
                            ],
                            type: 'object',
                          },
                          type: 'array',
                        },
                      },
                      required: [
                        'name',
                        'rules',
                      ],
                      type: 'object',
                    },
                    type: 'array',
                  },
                  tenantID: {
                    description: 'TenantID of tenant where the alerting rules are evaluated in.',
                    type: 'string',
                  },
                },
                required: [
                  'tenantID',
                ],
                type: 'object',
              },
              status: {
                description: 'AlertingRuleStatus defines the observed state of AlertingRule',
                properties: {
                  conditions: {
                    description: 'Conditions of the AlertingRule generation health.',
                    items: {
                      description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }",
                      properties: {
                        lastTransitionTime: {
                          description: 'lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.',
                          format: 'date-time',
                          type: 'string',
                        },
                        message: {
                          description: 'message is a human readable message indicating details about the transition. This may be an empty string.',
                          maxLength: 32768,
                          type: 'string',
                        },
                        observedGeneration: {
                          description: 'observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.',
                          format: 'int64',
                          minimum: 0,
                          type: 'integer',
                        },
                        reason: {
                          description: "reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.",
                          maxLength: 1024,
                          minLength: 1,
                          pattern: '^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$',
                          type: 'string',
                        },
                        status: {
                          description: 'status of the condition, one of True, False, Unknown.',
                          enum: [
                            'True',
                            'False',
                            'Unknown',
                          ],
                          type: 'string',
                        },
                        type: {
                          description: 'type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)',
                          maxLength: 316,
                          pattern: '^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$',
                          type: 'string',
                        },
                      },
                      required: [
                        'lastTransitionTime',
                        'message',
                        'reason',
                        'status',
                        'type',
                      ],
                      type: 'object',
                    },
                    type: 'array',
                  },
                },
                type: 'object',
              },
            },
            type: 'object',
          },
        },
        served: true,
        storage: true,
        subresources: {
          status: {},
        },
      },
    ],
  },
  status: {
    acceptedNames: {
      kind: '',
      plural: '',
    },
    conditions: null,
    storedVersions: null,
  },
}
