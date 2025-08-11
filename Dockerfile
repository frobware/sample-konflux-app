# Build the manager binary using Red Hat Go image
FROM registry.redhat.io/ubi9/go-toolset:1.23 AS builder
ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY cmd/main.go cmd/main.go
COPY api/ api/
COPY internal/ internal/

# Build
# the GOARCH has not a default value to allow the binary be built according to the host where the command
# was called. For example, if we call make docker-build in a local env which has the Apple Silicon M1 SO
# the docker BUILDPLATFORM arg will be linux/arm64 when for Apple x86 it will be linux/amd64. Therefore,
# by leaving it empty we can ensure that the container and binary shipped on it will have the same platform.
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o manager cmd/main.go

# Use Red Hat UBI Micro as minimal base image to package the manager binary
FROM registry.redhat.io/ubi9/ubi-micro:latest
WORKDIR /
COPY --from=builder /workspace/manager .

# Create non-root user for security
RUN useradd -r -u 65532 -g root nonroot
USER 65532:root

ENTRYPOINT ["/manager"]
