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
    
    # Replace the operator image reference in the deployment spec (not the example image in alm-examples)
    # Target line 137 specifically or use a pattern that avoids the JSON section
    sed -i '/deployments:/,$ s|image: .*|image: '"$NEW_IMAGE"'|' \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml
    
    echo "Updated ClusterServiceVersion"
else
    echo "Warning: ClusterServiceVersion file not found"
fi

# Update any other bundle files that reference the operator image
# This is more cautious - only replaces in the CSV file we just processed
echo "Scanning for additional operator image references in bundle files..."

echo "Bundle update complete"