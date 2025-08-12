#!/bin/bash
set -euo pipefail

# Script to update catalog with bundle image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Bundle image reference that Renovate will update
export TODOAPP_BUNDLE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/amcdermo-tenant/todoapp-bundle@sha256:placeholder-will-be-updated-by-renovate"

echo "Updating catalog with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"

# Update catalog.yaml with new bundle image
if [ -f "catalog/todoapp-operator/catalog.yaml" ]; then
    echo "Updating catalog.yaml with image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"
    
    # Replace the bundle image reference in the catalog
    # This handles both initial setup and subsequent updates with any registry/digest
    sed -i 's|image: .*todoapp.*bundle.*|image: '"$TODOAPP_BUNDLE_IMAGE_PULLSPEC"'|g' \
        catalog/todoapp-operator/catalog.yaml
    
    echo "Updated catalog.yaml"
else
    echo "Warning: catalog.yaml file not found"
fi

echo "Catalog update complete"