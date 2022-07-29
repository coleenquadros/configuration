
# Service Description

The Receptor-Controller service is designed to receive work requests from internal
clients and route the work requests to the target receptor node which runs in
the customer's environment.

# Components

Receptor-Controller is composed of 3 parts:

- Websocket gateway pod
- Message switch pod
- Redis

<img alt="Architecture diagram" src="https://raw.githubusercontent.com/RedHatInsights/platform-receptor-controller/master/docs/receptor-controller-arch-split-service.svg"/>

The Websocket gateway pod sits behind the 3scale gateway.  The 3scale gateway is responsible for
handling the certificate based authentication.  Once a connection is received by the Websocket gateway,
the Websocket gateway performs a receptor handshake and then registers the connection in a Redis instance.
The connection registration process records the account number, node id and gateway
pod name where the websocket connection lives.

Redis is responsible for maintaining a mapping of where the websocket connections live within the
Websocket gateway pods.

The Message switch pod allows internal applications to send messages down to the clients that are connected
over the websocket connection.  When the switch pod receives a message to send to a connected client, the 
switch pod looks up the account number and destination node id in Redis.
The result of this account number / destination node id lookup is the name of the pod where the
websocket connection lives.  The switch pod can now send the message to the correct gateway pod as the switch
pod now knows on which gateway pod that the correct websocket connection lives.

Responses from the receptor workers are read from the websocket and written to kafka.

# Routes

Receptor-Controller does not have an exposed OpenShift route.  Receptor-Controller has an OpenShift service
which is tied to the receptor-gateway.  This is the service/deployment that is responsible for handling
the websocket traffic.

Receptor-Controller depends on the 3scale Gateway application for the console.redhat.com application platform
to route the external traffic into the OpenShift service.

The OpenShift service for receptor-controller
http://receptor-controller.platform-prod.svc.cluster.local:8080/wss/receptor-controller/gateway

# Dependencies
Redis - used to store the location of which receptor-gateway pod an open websocket connection lives on

Kafka - used to deliver response messages to message consumers

# Service Diagram
<img alt="Architecture diagram" src="https://raw.githubusercontent.com/RedHatInsights/platform-receptor-controller/master/docs/receptor-controller-arch-split-service.svg"/>

# Application Success Criteria
Receptor-Controller maintains bi-directional connections between the console.redhat.com application
platform and receptor nodes running on customer sites.  Receptor-Controller allows applications internal
to the console.redhat.com application platform to send messages to receptor nodes on customer sites.

# State
Receptor-Controller maintains open websocket connections to receptor nodes running customer sites.
These connections can be thought of as state as they can only exist on a single pod.  The connections
are tied to that pod for their lifetime.

The mapping between the receptor node-id and the pod where the websocket connection lives is state.
This state exists in Redis.

Receptor-Controller is built in such a way that if the redis instance is cleared, Receptor-Controller
will rebuild the connection mapping state.

# Load Testing
https://docs.google.com/document/d/1DFyiGX2eSO9W5sEZh4-FSoAUAelwxypgADV5UbEpZig/edit#heading=h.av9emkusr482

# Capacity

### Current Resource Usage
| Deployment | Replicas | CPU Limit (cores) | Memory Limit (MB) | Total CPU (core) | Total memory (MB) |
|------------|----------:|-------------------:|-------------------:|------------------:|-------------------:|
| receptor-gateway | 3 | 0.5 | 1024 | 1.5 | 3072 |
| receptor-switch | 3 | 0.5 | 1024 | 1.5 | 3072 |


### Resource Forecast (1yr out)
| Deployment | Replicas | CPU Limit (cores) | Memory Limit (MB) | Total CPU (core) | Total memory (MB) |
|------------|----------:|-------------------:|-------------------:|------------------:|-------------------:|
| receptor-gateway | 3 | 0.5 | 1024 | 1.5 | 3072 |
| receptor-switch | 3 | 0.5 | 1024 | 1.5 | 3072 |
