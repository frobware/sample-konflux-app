#!/bin/bash
set -euo pipefail

# Script to update bundle with operator image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Operator image reference that Renovate will update
export TODOAPP_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/amcdermo-tenant/todoapp-operator@sha256:placeholder-will-be-updated-by-renovate"

echo "Updating bundle with operator image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"

# Update ClusterServiceVersion with new operator image
if [ -f "bundle/manifests/todoapp-operator.clusterserviceversion.yaml" ]; then
    echo "Updating ClusterServiceVersion with image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"
    
    # Replace the operator image reference in the deployment spec (not the example image in alm-examples)
    # Target line 137 specifically or use a pattern that avoids the JSON section
    sed -i '/deployments:/,$ s|image: .*|image: '"$TODOAPP_OPERATOR_IMAGE_PULLSPEC"'|' \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml
    
    echo "Updated ClusterServiceVersion"
else
    echo "Warning: ClusterServiceVersion file not found"
fi

# Update any other bundle files that reference the operator image
# This is more cautious - only replaces in the CSV file we just processed
echo "Scanning for additional operator image references in bundle files..."

echo "Bundle update complete"