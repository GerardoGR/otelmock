# otelmock

Wiremock + OpenTelemetry = <3

## Verify

```shell
# Send test metric
cat examples/metrics.json | grpcurl -plaintext -proto opentelemetry/proto/collector/metrics/v1/metrics_service.proto -d @ localhost:8080 opentelemetry.proto.collector.metrics.v1.MetricsService.Export

# Check Wiremock request journal
curl -s -d '{"method": "POST", "url": "/opentelemetry.proto.collector.metrics.v1.MetricsService/Export"}' http://localhost:8080/__admin/requests/count | jq -e '.count == 1'
```
