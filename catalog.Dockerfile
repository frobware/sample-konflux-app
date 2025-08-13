# Use a builder image that has shell capabilities
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest as shell-builder

# Copy the update script and files
COPY konflux/scripts/catalog/update_catalog.sh /tmp/update_catalog.sh  
COPY catalog /configs
COPY konflux /tmp/konflux

# Run the update script to modify catalog files
WORKDIR /tmp
RUN chmod +x update_catalog.sh && ./update_catalog.sh && rm ./update_catalog.sh

# Use the OPM image for final stage
FROM quay.io/operator-framework/opm:latest as builder

# Copy updated catalog files from shell-builder
COPY --from=shell-builder /configs /configs
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
