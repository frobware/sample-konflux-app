# Use a builder image that has shell capabilities
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest as shell-builder

# Set working directory first
WORKDIR /repo

# Copy entire repo structure to current working directory
COPY . .

# Run the update script with relative paths
RUN chmod +x konflux/scripts/catalog/update_catalog.sh && konflux/scripts/catalog/update_catalog.sh

# Use the OPM image for final stage
FROM quay.io/operator-framework/opm:latest as builder

# Copy updated catalog files from shell-builder
COPY --from=shell-builder /repo/catalog /configs
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

FROM quay.io/operator-framework/opm:latest
# The base image is expected to contain
# /bin/opm (with serve subcommand) and /bin/grpc_health_probe

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

COPY --from=builder /configs /configs
COPY --from=builder /tmp/cache /tmp/cache

# Set FBC-specific label for the location of the FBC root directory
# in the image
LABEL operators.operatorframework.io.index.configs.v1=/configs
