### Author / Date
Bhushan Thakur 06/08/2022
### Tracking JIRA
https://issues.redhat.com/browse/APPSRE-2694
### Problem Statement
Currently graphql schema as defined within https://github.com/app-sre/qontract-schemas/blob/main/graphql-schemas/schema.yml is not validated against any
specific schema. Having a strict schema to validate against will help us catch any errors that may arise in future when we make any changes.

### Goals

- Introduce a new json-schema that can be used to validate GraphQL schema.yml

### Non-objectives

### Proposal

To accomplish this change, we can create following json-schema retrofitting existing graphql specification. 

```
---
"$schema": /metaschema-1.json
version: '1.0'
type: object

additionalProperties: false
properties:
  "$schema":
    type: string
    enum:
    - /app-interface/graphql-schemas-1.yml
  
  confs:
    type: array
    items:
      "$ref": "#/definitions/conf"

definitions:
  conf:
    type: object
    additionalProperties: false
    properties:
      name:
        type: string
      fields:
        type: array
        items:
          "$ref": "#/definitions/field"
      datafile:
        type: string
      isInterface:
        type: boolean
      interface:
        type: string
      interfaceResolve:
        type: object
        additionalProperties: false
        properties:
          strategy:
            type: string
            enum:
            - "fieldMap"
          field:
            type: string
          fieldMap:
            type: object
            properties:
              "/": {}
  field:
    type: object
    additionalProperties: false
    properties:
      name:
        type: string
      type:
        type: string
      isInterface:
        type: boolean
      isUnique:
        type: boolean
      isRequired:
        type: boolean
      isSearchable:
        type: boolean
      isList:
        type: boolean
      isResource:
        type: boolean
      synthetic:
        type: object
        additionalProperties: false
        properties:
          schema:
            type: string
          subAttr:
            type: string
      datafileSchema:
        type: string

```

Then we can update `schema.yml` to introduce `$schema` that points to graphql json schema and `confs` that wraps existing list. These two new fields are necessary for validation.

#### CHANGES 

##### qontract-schema
Introduce graphql json-schema as defined above and update `schema.yml` accordingly. This will result in a new bundle format with change reflected in `graphql` field.

See https://github.com/app-sre/qontract-schemas/pull/167 for reference.
##### qontract-validator
We need to update qontract-validator so that it can perform validation of `schema.yml`. In addition, we also need to ensure validator only tries to validate the graphql schemas if the schema header is present. This will support a transition period where validator might be faced with schemas with and without explicit schema information. This validation will be added in main method in validator.py on top of existing validation checks.

The qontract-validator will be run as part of PR checks in qontract-schemas repository.

See https://github.com/app-sre/qontract-validator/pull/39/files for reference.

##### qontract-server
qontract-server utilizes `graphql` field within bundle to create schema on the server. We need to ensure qontract-server is compatible with different bundle format during transition period.

See https://github.com/app-sre/qontract-server/pull/137 for reference.

### Alternatives considered


### Milestones

- Release new `qontract-validator` that can validate different bundle format. 
- Release updated `qontract-server` that can run with different bundles and deploy it to production through saas file change. 
- Update `qontract-schema` with newly added json-schema.
- Update `SCHEMAS_IMAGE_TAG` to utilize new schemas for bundle creation and `VALIDATOR_IMAGE_TAG` for validation within [.env](/.env)

