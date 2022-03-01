# Assisting checkpoints with qontract-cli

As part of the periodic checkpointing we perform on all onboarded and
in-onboarding services, we verify that the metadata they provide in
app-interface is correct. In particular:

* There are owners with emails
* The URLs for grafana, SOPs and architecture document are valid (i.e,
  no http://TODO left around)
* Escalation paths are valid
  
And we cut tickets for any fields that don't exist or don't make
sense.

We assist this process with `qontract-cli`. In its most basic form:

``` shell
# Most URLs will be HTTPS so ensure the CAs are reachable from
# REQUESTS_CA_BUNDLE
$ export REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem
$ qontract-cli --config config.toml sre-checkpoint-metadata --app-path=/services/insights/compliance/app.yml --parent-ticket=$parent_ticket
```

This command will look up all the fields we mention above, confirm
they are somewhat valid and cut tickets for any missing or invalid
ones. These tickets will go to the application's JIRA board, which can
be found in its [escalation
policy](https://github.com/app-sre/qontract-schemas/blob/4901fb53eff1b56dbf97b0a9a7719f29d695d02b/schemas/app-sre/app-1.yml#L266)
and they will be linked to the given `$parent_ticket` for easier
tracking.

## What about malformed or early services without escalation policies?

Glad you asked!

The `sre-checkpoint-metadata` command can accept a path to an
escalation policy in app-interface. In that case, `--jiradef` will
indicate the path to the escalation of some other application, from it
we will read the URL to the JIRA instance and the secret holding the
credentials to said JIRA. Then, we can specify the board for this
service with the `--jiraboard`. For instance, when reviewing Drift for
their onboarding I did:

``` shell
$ qontract-cli --config config.local.toml sre-checkpoint-metadata \
  --app-path=/services/insights/historical-system-profiles/app.yml \
  --parent-ticket=APPSRE-3801 \
  --jiraboard=DRFT \
  --jiradef=/teams/insights/jira/compliance.yaml
```
