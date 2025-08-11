FROM quay.io/operator-framework/opm:v1.53.0
ARG CATALOG_PATH=catalog

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Copy only the catalog YAML files, not the entire directory
ADD $CATALOG_PATH/todoapp-operator /configs/todoapp-operator
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

# Set DC-specific label for the location of the DC root directory
# in the image
LABEL operators.operatorframework.io.index.configs.v1=/configs