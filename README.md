# otelmock

Wiremock + OpenTelemetry = <3

## Verify

```shell
# Send test metric
cat examples/metrics.json | grpcurl -plaintext -proto opentelemetry/proto/collector/metrics/v1/metrics_service.proto -d @ localhost:4317 opentelemetry.proto.collector.metrics.v1.MetricsService.Export

# Check Wiremock request journal
docker-compose exec --index 1 otelmock curl -s -d '{"method": "POST", "url": "/opentelemetry.proto.collector.metrics.v1.MetricsService/Export"}' http://localhost:4317/__admin/requests/count
```
