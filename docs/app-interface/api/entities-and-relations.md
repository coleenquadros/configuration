# Entities and Relations

App-interface data is represented by files that correspond to a schema. Files of one schema may reference files of another schema.

The following sections explain the different entities in app-interface and the relations they have.

## Products, Environments, Namespaces and Apps

An environment is a set of namespaces, that when working together create a complete Product. A Product is a set of Apps working together to deliver functionality. An App is a generic term to describe a service or a set of services that contribute to a Product.

Relations:
- A Namespace will reference the App it is serving and the Environment it is a part of.
- An Environment will reference a Product it serves.
- An Environment may reference another environment it depends on for gating/automated promotions.
- An App may reference a parentApp to allow an App to be comprised of Components (We treat apps/services/components just as Apps).

![](docs/app-interface/api/images/products-environments-namespaces-apps.png)
