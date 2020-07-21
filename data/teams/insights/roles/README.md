The goal is to have each role set up such that:
* the name of the role makes it obvious what its purpose is
* roles applying the same duplicated permissions are reduced


Set up your users like this:

* Give all insights engineers the 'insights-engineers' role. This gives access to most resources such as the ability to log in to the OpenShift clusters, Jenkins, Prometheus/Grafana, etc.
* Give them the team role that applies to their team. This role should do two main things: add them to their specific github team (which controls their access to vault), and gives them higher access on their specific openshift namespaces.
* For any additional access users need above and beyond the 'insights-engineers', create a new role that gives those users the additional permissions. For example, the 'insights-tools' role only includes permissions that are in excess of insights-engineers. All SRE engineers can then be assigned the 'insights-engineers' and 'insights-tools' role.
