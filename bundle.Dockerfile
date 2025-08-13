FROM registry.access.redhat.com/ubi9/ubi-minimal:latest as builder

# Copy entire repo structure
COPY . .

# Run the update script with relative paths
RUN chmod +x konflux/scripts/bundle/update_bundle.sh && konflux/scripts/bundle/update_bundle.sh

FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=sample-konflux-app
LABEL operators.operatorframework.io.bundle.channels.v1=alpha
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-unknown
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=go.kubebuilder.io/v4

# Labels for testing.
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/

# Copy files to locations specified by labels.
COPY --from=builder bundle/manifests /manifests/
COPY --from=builder bundle/metadata /metadata/
COPY --from=builder bundle/tests/scorecard /tests/scorecard/
