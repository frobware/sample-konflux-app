# Use Red Hat approved operator-registry base image for Konflux builds
FROM registry.redhat.io/openshift4/ose-operator-registry:latest

# File-Based Catalog labels
LABEL operators.operatorframework.io.index.configs.v1=/configs

# Copy the catalog configs into the expected directory structure
COPY catalog/todoapp-operator/catalog.yaml /configs/todoapp-operator/catalog.yaml