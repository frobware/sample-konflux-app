#!/bin/bash
set -euo pipefail

# Script to update catalog with bundle image reference
# This script is referenced by the build-nudge-files annotation

echo "Updating catalog with new bundle image reference..."

# Get the new bundle image from environment variables set by Konflux
# Konflux sets component-specific environment variables:
# - TODOAPP_BUNDLE_IMAGE_DIGEST for the bundle component
# - TODOAPP_BUNDLE_IMAGE_URL for the bundle component
NEW_IMAGE="${TODOAPP_BUNDLE_IMAGE_DIGEST:-${TODOAPP_BUNDLE_IMAGE_URL:-bundle:latest}}"

echo "New bundle image: $NEW_IMAGE"

# Update catalog.yaml with new bundle image
if [ -f "catalog/todoapp-operator/catalog.yaml" ]; then
    echo "Updating catalog.yaml with image: $NEW_IMAGE"
    
    # Replace the bundle image reference in the catalog
    # This handles both initial setup and subsequent updates with any registry/digest
    sed -i 's|image: .*todoapp.*bundle.*|image: '"$NEW_IMAGE"'|g' \
        catalog/todoapp-operator/catalog.yaml
    
    echo "Updated catalog.yaml"
else
    echo "Warning: catalog.yaml file not found"
fi

echo "Catalog update complete"