FROM brew.registry.redhat.io/rh-osbs/openshift-ose-operator-registry-rhel9:v4.17
ARG CATALOG_PATH=catalog

# Configure the entrypoint and command
ENTRYPOINT ["opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Copy only the catalog YAML files, not the entire directory
ADD $CATALOG_PATH/todoapp-operator /configs/todoapp-operator
RUN opm serve /configs --cache-dir=/tmp/cache --cache-only

# Set DC-specific label for the location of the DC root directory
# in the image
LABEL operators.operatorframework.io.index.configs.v1=/configs