# Use proper FBC base image for OpenShift 4.16+
FROM registry.redhat.io/openshift4/ose-operator-registry-rhel9:v4.16

# File-Based Catalog labels
LABEL operators.operatorframework.io.index.configs.v1=/configs

# Copy the catalog configs into the expected directory structure
COPY catalog/todoapp-operator/catalog.yaml /configs/todoapp-operator/catalog.yaml