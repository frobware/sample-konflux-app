# Use publicly accessible operator-registry base image
FROM quay.io/operator-framework/opm:latest

# File-Based Catalog labels
LABEL operators.operatorframework.io.index.configs.v1=/configs

# Copy the catalog configs into the expected directory structure
COPY catalog/todoapp-operator/catalog.yaml /configs/todoapp-operator/catalog.yaml