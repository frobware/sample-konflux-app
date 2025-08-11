# Use Red Hat approved operator-registry base image for Konflux builds  
# Using RHEL9 variant which should be accessible in Konflux
FROM registry.redhat.io/openshift4/ose-operator-registry-rhel9:latest

# File-Based Catalog labels
LABEL operators.operatorframework.io.index.configs.v1=/configs

# Copy the catalog configs into the expected directory structure
COPY catalog/todoapp-operator/catalog.yaml /configs/todoapp-operator/catalog.yaml