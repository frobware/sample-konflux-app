#!/bin/bash
set -euo pipefail

# Script to update catalog with bundle image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Bundle image reference that Renovate will update
export TODOAPP_BUNDLE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/amcdermo-tenant/todoapp-bundle@sha256:351e8c9e8cb8b0bcb635c560e23df9d28fecbc5f2a9f1780b354ed1189fe9b79"

echo "Updating catalog with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"

# Update catalog.yaml with new bundle image
if [ -f "catalog/todoapp-operator/catalog.yaml" ]; then
    echo "Updating catalog.yaml with image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"
    
    # Replace any todoapp-bundle image references with the new pullspec
    # Regex breakdown:
    #   image:                    - literal "image:" field
    #   [^[:space:]]*            - any non-whitespace chars (registry/path)
    #   todoapp-bundle           - literal component name to match
    #   [^[:space:]]*            - any non-whitespace chars (tag/digest)
    # This matches: image: quay.io/.../todoapp-bundle:tag or @sha256:...
    # But stops at whitespace to avoid greedy matching
    sed -i 's|image: [^[:space:]]*todoapp-bundle[^[:space:]]*|image: '"$TODOAPP_BUNDLE_IMAGE_PULLSPEC"'|g' \
        catalog/todoapp-operator/catalog.yaml
    
    echo "Updated catalog.yaml"
else
    echo "Warning: catalog.yaml file not found"
fi

echo "Catalog update complete"