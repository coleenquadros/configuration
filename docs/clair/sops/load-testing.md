# Clair Load Testing

## Load testing
In order to apply load to Clair instances without the need for Quay you can run the [clair-load-test](https://github.com/quay/clair-load-test) tool. The tool submits manifests to be indexed at a given `--rate` per second until the `--timeout` is reached. After running the load test it will print stats about the test to stdout e.g.:

```json
{
  "total_index_report_requests": 1799,
  "total_vulnerability_report_requests": 1799,
  "total_index_report_latency_milliseconds": 8098653,
  "total_vulnerability_report_latency_milliseconds": 696237,
  "latency_per_index_report_request": 4501.752640355753,
  "latency_per_vulnerability_report_request": 387.0133407448583,
  "non_2XX_index_report_responses": 0,
  "non_2XX_vulnerability_report_responses": 0,
  "max_index_report_request_latency_milliseconds": 27901,
  "max_vulnerability_report_request_latency_milliseconds": 1583
}
```

## Running
### Dependencies
* git
* podman

The load testing tool can be built and run as an image like so:
```sh
git clone git clone https://github.com/quay/clair-load-test.git
cd clair-load-test
podman build . -t clair-load-test
podman run -e HOST=https://clair.stage.quay.io -e TIMEOUT=1m -e DELETE=1 -e PSK=<secret> -e RATE=0.5 -it clair-load-test
```
> Note: PSKs for existing environments can be found in [vault](https://vault.devshift.net/ui/vault/secrets/app-interface/show/clair).
