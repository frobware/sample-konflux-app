FROM quay.io/operator-framework/opm:v1.54.0

ARG BUILD_STREAM=alpha

# Copy pre-generated catalog file (like netobserv does)
COPY catalog/auto-generated/${BUILD_STREAM}.yaml /configs/index.yaml

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Pre-build cache (like netobserv does)
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

# Set FBC-specific label for the location of the FBC root directory
LABEL operators.operatorframework.io.index.configs.v1=/configs