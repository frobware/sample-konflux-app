#!/bin/bash
set -euo pipefail

# Script to update bundle with operator image reference
# This script is referenced by the build-nudge-files annotation

echo "Updating bundle with new operator image reference..."

# Get the new operator image from environment variables set by Konflux
NEW_IMAGE="${BUILD_IMAGE_DIGEST:-controller:latest}"

echo "New operator image: $NEW_IMAGE"

# Update ClusterServiceVersion with new operator image
if [ -f "bundle/manifests/todoapp-operator.clusterserviceversion.yaml" ]; then
    echo "Updating ClusterServiceVersion with image: $NEW_IMAGE"
    
    # Replace the image reference in the deployment spec
    sed -i "s|image: controller:latest|image: $NEW_IMAGE|g" \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml
    
    echo "Updated ClusterServiceVersion"
else
    echo "Warning: ClusterServiceVersion file not found"
fi

# Update any other bundle files that reference the operator image
find bundle/ -name "*.yaml" -type f -exec sed -i "s|controller:latest|$NEW_IMAGE|g" {} \;

echo "Bundle update complete"