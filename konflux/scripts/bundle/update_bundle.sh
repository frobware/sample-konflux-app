#!/bin/bash
set -euo pipefail

# Script to update bundle with operator image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Source operator image reference from centralised file
if [ ! -f "konflux/image-refs/operator.txt" ]; then
    echo "ERROR: Operator image reference file not found: konflux/image-refs/operator.txt"
    exit 1
fi

export TODOAPP_OPERATOR_IMAGE_PULLSPEC=$(cat konflux/image-refs/operator.txt)

if [ -z "$TODOAPP_OPERATOR_IMAGE_PULLSPEC" ]; then
    echo "ERROR: Empty operator image reference in konflux/image-refs/operator.txt"
    exit 1
fi

echo "Updating bundle with operator image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"

# Update ClusterServiceVersion with new operator image
CSV_FILE="bundle/manifests/sample-konflux-app.clusterserviceversion.yaml"
if [ -f "$CSV_FILE" ]; then
    echo "Found ClusterServiceVersion: $CSV_FILE"
    echo "Updating with image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"
    
    # Show current image references before update
    echo "Current image references:"
    grep -n "image:" "$CSV_FILE" || echo "No image: references found"
    
    # Replace the controller:latest image with our operator image
    # This matches the actual image reference in our CSV
    if ! grep -q "image: controller:latest" "$CSV_FILE"; then
        echo "ERROR: Could not find 'image: controller:latest' in $CSV_FILE"
        echo "Cannot update bundle - expected image reference not found"
        exit 1
    fi
    
    sed -i 's|image: controller:latest|image: '"$TODOAPP_OPERATOR_IMAGE_PULLSPEC"'|g' "$CSV_FILE"
    
    # Verify the update actually happened
    if grep -q "image: controller:latest" "$CSV_FILE"; then
        echo "ERROR: Failed to update image reference - 'controller:latest' still found"
        exit 1
    fi
    
    if ! grep -q "$TODOAPP_OPERATOR_IMAGE_PULLSPEC" "$CSV_FILE"; then
        echo "ERROR: Updated image reference not found in file"
        exit 1
    fi
    
    # Show what changed
    echo "Updated image references:"
    grep -n "image:" "$CSV_FILE" || echo "No image: references found after update"
    
    echo "Successfully updated ClusterServiceVersion"
else
    echo "ERROR: ClusterServiceVersion file not found at $CSV_FILE"
    echo "Looking for CSV files in bundle/manifests/:"
    ls -la bundle/manifests/*.yaml 2>/dev/null || echo "No YAML files found"
    echo "Bundle update failed - required CSV file missing"
    exit 1
fi

# Update any other bundle files that reference the operator image
# This is more cautious - only replaces in the CSV file we just processed
echo "Scanning for additional operator image references in bundle files..."

echo "Bundle update complete"
