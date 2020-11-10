# DB migrations

Database migrations are a process intended to update the schema and/or data in an application's databse. Databse migrations should life-cycle together with application components (as such changes will require changes to the source code).

Database migrations should be handled by the application consuming the database and each migration should be forward/backward compatible (preferably backwards compatible to all previous versions).

Tooling recommendations:
- Golang - [SDB example service migrations package](https://gitlab.cee.redhat.com/service/sdb-ocm-example-service/-/tree/master/pkg/db)
- Python - [Alembic](https://alembic.sqlalchemy.org/en/latest/)
