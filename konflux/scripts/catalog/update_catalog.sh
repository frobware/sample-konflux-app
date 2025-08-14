#!/bin/bash
set -euo pipefail

# Script to update catalog with bundle image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# First generate catalogs from templates (if not already generated)
echo "Generating catalogs from templates..."
if [ -d "catalog" ]; then
    cd catalog && make generate && cd ..
fi

# Source bundle image reference from centralised file
if [ ! -f "konflux/image-refs/bundle.txt" ]; then
    echo "ERROR: Bundle image reference file not found: konflux/image-refs/bundle.txt"
    exit 1
fi

export TODOAPP_BUNDLE_IMAGE_PULLSPEC=$(cat konflux/image-refs/bundle.txt)

if [ -z "$TODOAPP_BUNDLE_IMAGE_PULLSPEC" ]; then
    echo "ERROR: Empty bundle image reference in konflux/image-refs/bundle.txt"
    exit 1
fi

echo "Updating catalog with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"

# Update generated catalog files with new bundle image
for CATALOG_FILE in catalog/auto-generated/*.yaml; do
    if [ -f "$CATALOG_FILE" ]; then
        echo "Found generated catalog file: $CATALOG_FILE"
        echo "Updating with bundle image: $TODOAPP_BUNDLE_IMAGE_PULLSPEC"
        
        # Show current bundle image references before update
        echo "Current bundle image references:"
        grep -n "image:.*todoapp-bundle" "$CATALOG_FILE" || echo "No todoapp-bundle image references found"
        
        # Verify we can find bundle image references to update
        if ! grep -q "image:.*todoapp-bundle" "$CATALOG_FILE"; then
            echo "WARNING: Could not find any 'image:.*todoapp-bundle' references in $CATALOG_FILE"
            continue
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
            echo "ERROR: Updated bundle image reference not found in $CATALOG_FILE"
            exit 1
        fi
        
        # Show what changed
        echo "Updated bundle image references in $CATALOG_FILE:"
        grep -n "image:.*todoapp-bundle\\|$TODOAPP_BUNDLE_IMAGE_PULLSPEC" "$CATALOG_FILE" || echo "No bundle image references found after update"
        
        echo "Successfully updated $CATALOG_FILE"
    fi
done

echo "Catalog update complete"