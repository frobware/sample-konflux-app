#!/bin/bash
set -euo pipefail

# Script to update bundle with operator image reference
# This script is referenced by the build-nudge-files annotation

echo "Updating bundle with new operator image reference..."

# Get the new operator image from environment variables set by Konflux
# Konflux sets component-specific environment variables:
# - TODOAPP_OPERATOR_IMAGE_DIGEST for the operator component
# - TODOAPP_OPERATOR_IMAGE_URL for the operator component
NEW_IMAGE="${TODOAPP_OPERATOR_IMAGE_DIGEST:-${TODOAPP_OPERATOR_IMAGE_URL:-controller:latest}}"

echo "New operator image: $NEW_IMAGE"

# Update ClusterServiceVersion with new operator image
if [ -f "bundle/manifests/todoapp-operator.clusterserviceversion.yaml" ]; then
    echo "Updating ClusterServiceVersion with image: $NEW_IMAGE"
    
    # Replace the image reference in the deployment spec
    # This handles both initial (controller:latest) and subsequent updates (with digest)
    sed -i 's|image: .*controller.*|image: '"$NEW_IMAGE"'|g' \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml
    
    echo "Updated ClusterServiceVersion"
else
    echo "Warning: ClusterServiceVersion file not found"
fi

# Update any other bundle files that reference the operator image
find bundle/ -name "*.yaml" -type f -exec sed -i 's|image: .*controller.*|image: '"$NEW_IMAGE"'|g' {} \;

echo "Bundle update complete"