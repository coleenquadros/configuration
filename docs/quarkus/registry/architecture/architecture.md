# Quarkus Extension Registry Architecture


## Service Description

The Quarkus Extension Registry application (registry.quarkus.io) provides a centralized place for tooling to query for extensions and
platforms. It is a Quarkus Application that has a PostgreSQL Database in the backend and exposes REST endpoints performing queries and insertions
in the underlying database.

## Components

![](figures/components.png)


### Use Case diagram

![](figures/use_case_diagram.png)

### Sequence diagram

#### Query Registry Configuration

![](figures/seq_query_registry_configuration.png)

#### Query Platforms

![](figures/seq_query_platforms.png)

#### Query Non-Platform Extensions

![](figures/seq_query_non_platform_extensions.png)

#### Insert new Platforms and Extensions

![](figures/seq_insert_new_platforms_extensions.png)

## Routes

- Community
  - [https://registry.quarkus.io]() - Production
  - [https://stage.registry.quarkus.io]() - Staging

- Productized
    - [https://registry.quarkus.redhat.com]() - Production
    - [https://registry.quarkus.stage.redhat.com]() - Staging

## Dependencies

-   PostgreSQL 14 DB. API Endpoints should return 5xx errors if the Database isn't available.

## Service Diagram 

![](figures/service_diagram.png)

## Application Success Criteria

The application should return information about the released Quarkus platforms and extension versions including their metadata.

## State

- The app requires a PostgreSQL Database (RDS) to function. The service should return an Internal Server error response if the Database is not available

## Business Continuity Plan

The data provided by the application is stored in the PostgreSQL Database (RDS) and is updated based on the data in https://github.com/quarkusio/quarkus-extension-catalog-redhat repository (when a new Red Hat Build of Quarkus release is out).
In case there is a database failure (data corruption?), the publishing process can be executed again to restore the expected data in the Database. See [this section about publishing](https://github.com/quarkusio/quarkus-extension-catalog-redhat#publishing) for more information.

## Load Testing 

- N/A

## Capacity

### CPU

- 0.4 - 1 CPU per pod

### Memory

- 300-1Gb RAM per pod

### Storage

- ~100Gb for the PostgreSQL Database

### Forecast for the next year (2023)

No plans to increase for the next year
