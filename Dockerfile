# docker build -t otelmock:latest .
# docker run --rm -p 8080:8080 otelmock:latest
FROM wiremock/wiremock:3.13.2

LABEL maintainer="Gerardo Gomez <gerardo.gomez@tutanota.com>"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unzip

# Download protoc
ENV protoc_version=35.1
RUN curl -L -s -O https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip \
  && unzip protoc-${protoc_version}-linux-x86_64.zip \
  && mv bin/protoc /usr/local/bin \
  && rm protoc-${protoc_version}-linux-x86_64.zip

# Download wiremock-grpc-extension
ENV wiremock_grpc_extension_version=0.11.0
RUN mkdir -p /var/wiremock/extensions \
  && curl -L -s -o /var/wiremock/extensions/wiremock-grpc-extension-standalone.jar https://repo1.maven.org/maven2/org/wiremock/wiremock-grpc-extension-standalone/${wiremock_grpc_extension_version}/wiremock-grpc-extension-standalone-${wiremock_grpc_extension_version}.jar

# Download OpenTelemetry protos
ENV opentelemetry_proto_version=1.10.0
RUN curl -L -s -o opentelemetry-proto.tar.gz https://github.com/open-telemetry/opentelemetry-proto/archive/refs/tags/v${opentelemetry_proto_version}.tar.gz \
  && tar -xvzf opentelemetry-proto.tar.gz \
  && mv opentelemetry-proto-${opentelemetry_proto_version} opentelemetry-proto \
  && rm opentelemetry-proto.tar.gz

# Generate metrics service dsc
RUN mkdir -p grpc \
  && protoc --proto_path=opentelemetry-proto --include_imports --descriptor_set_out grpc/metrics_service.dsc opentelemetry-proto/opentelemetry/proto/collector/metrics/v1/metrics_service.proto

COPY mappings /home/wiremock/mappings

ENTRYPOINT ["/docker-entrypoint.sh", "--global-response-templating", "--verbose", "--port", "4317"]
