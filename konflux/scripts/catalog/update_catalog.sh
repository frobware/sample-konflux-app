#!/bin/bash
set -euo pipefail

# Script to update catalog with bundle image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Source bundle image reference from centralised file
if [ ! -f "/tmp/konflux/image-refs/bundle.txt" ]; then
    echo "ERROR: Bundle image reference file not found: /tmp/konflux/image-refs/bundle.txt"
    exit 1
fi

export TODOAPP_BUNDLE_IMAGE_PULLSPEC=$(cat /tmp/konflux/image-refs/bundle.txt)

if [ -z "$TODOAPP_BUNDLE_IMAGE_PULLSPEC" ]; then
    echo "ERROR: Empty bundle image reference in /tmp/konflux/image-refs/bundle.txt"
    exit 1
fi

echo "Updating catalog with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"

# Update catalog.yaml with new bundle image
CATALOG_FILE="/configs/catalog.yaml"
if [ -f "$CATALOG_FILE" ]; then
    echo "Found catalog file: $CATALOG_FILE"
    echo "Updating with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"
    
    # Show current bundle image references before update
    echo "Current bundle image references:"
    grep -n "image:.*todoapp-bundle" "$CATALOG_FILE" || echo "No todoapp-bundle image references found"
    
    # Verify we can find bundle image references to update
    if ! grep -q "image:.*todoapp-bundle" "$CATALOG_FILE"; then
        echo "ERROR: Could not find any 'image:.*todoapp-bundle' references in $CATALOG_FILE"
        echo "Cannot update catalog - expected bundle image reference not found"
        exit 1
    fi
    
    # Replace any todoapp-bundle image references with the new pullspec
    # Regex breakdown:
    #   image:                    - literal "image:" field
    #   [^[:space:]]*            - any non-whitespace chars (registry/path)
    #   todoapp-bundle           - literal component name to match
    #   [^[:space:]]*            - any non-whitespace chars (tag/digest)
    # This matches: image: quay.io/.../todoapp-bundle:tag or @sha256:...
    # But stops at whitespace to avoid greedy matching
    sed -i 's|image: [^[:space:]]*todoapp-bundle[^[:space:]]*|image: '"$TODOAPP_BUNDLE_IMAGE_PULLSPEC"'|g' \
        "$CATALOG_FILE"
    
    # Verify the update actually happened
    if ! grep -q "$TODOAPP_BUNDLE_IMAGE_PULLSPEC" "$CATALOG_FILE"; then
        echo "ERROR: Updated bundle image reference not found in file"
        exit 1
    fi
    
    # Show what changed
    echo "Updated bundle image references:"
    grep -n "image:.*todoapp-bundle\\|$TODOAPP_BUNDLE_IMAGE_PULLSPEC" "$CATALOG_FILE" || echo "No bundle image references found after update"
    
    echo "Successfully updated catalog.yaml"
else
    echo "ERROR: Catalog file not found at $CATALOG_FILE"
    echo "Looking for catalog files in /configs/:"
    ls -la /configs/*.yaml 2>/dev/null || echo "No YAML files found"
    echo "Catalog update failed - required catalog file missing"
    exit 1
fi

echo "Catalog update complete"