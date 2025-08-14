FROM quay.io/operator-framework/opm:latest

# Default to alpha stream, can be overridden at build time
ARG INDEX_FILE=./catalog/auto-generated/alpha.yaml

# Copy pre-generated catalog file
COPY ${INDEX_FILE} /configs/index.yaml

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Pre-build cache (like netobserv does)
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

# Set FBC-specific label for the location of the FBC root directory
LABEL operators.operatorframework.io.index.configs.v1=/configs
