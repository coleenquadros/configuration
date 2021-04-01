# aws-rds-resources

- [aws-rds-resources](#aws-rds-resources)
  - [RDSMaxConnectionsMapping](#rdsmaxconnectionsmapping)
  - [RDSMaxConnections](#rdsmaxconnections)
  - [RDSStorageLow](#rdsstoragelow)

## RDSMaxConnectionsMapping

This alert indicates that the aws-resource-exporter service doesn't know about an instance type a database is using.

It is necessary to update the mapping [upstream](https://github.com/app-sre/aws-resource-exporter/blob/master/rds.go#L16) to include the desired instance type as well as the DB Parameter group and the corresponding actual max_connections value.

One can retrieve the actual max_connections value by running the following SQL on a DB running on that instance type: `SELECT * FROM pg_settings WHERE name = 'max_connections';`

## RDSMaxConnections

The AWS database is within 90% of its _max_connections_ setting. As we typically use the AWS defaults for _max_connections_ this usually mean there is an issue with the application leaking connections or an unusual spike in traffic.

The SRE should investigate if the application is running normally, receiving normal traffic (ie. no DDoS) attack.

If everything is running normally, the database instance might have to be scaled up to accommodate the increase in concurrent connections.

*A database with many thousands of active connections is very rare. This is normally seen for applications with a LOT of concurrent traffic*

## RDSStorageLow

The AWS database is within 10% of its allocated storage.

The SRE should check with the service team if that usage seems normal. If the usage is determined to be normal or if the information cannot be verified, it may be desirable to increase the database allocated storage.
