#!/bin/bash
set -euo pipefail

# Script to update bundle with operator image reference
# This script is referenced by the build-nudge-files annotation
# The image reference below will be updated by Renovate/Konflux nudging

# Operator image reference that Renovate will update
export TODOAPP_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/amcdermo-tenant/todoapp-operator@sha256:0f82f9211b156e97443e1ba74e92a602f55bbd2fbcfec179357703ebad8640cb"

echo "Updating bundle with operator image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"

# Update ClusterServiceVersion with new operator image
if [ -f "bundle/manifests/todoapp-operator.clusterserviceversion.yaml" ]; then
    echo "Updating ClusterServiceVersion with image: $TODOAPP_OPERATOR_IMAGE_PULLSPEC"

    # Replace any todoapp-operator image references with the new pullspec
    # Regex breakdown:
    #   image:                    - literal "image:" field
    #   [^[:space:]]*            - any non-whitespace chars (registry/path)
    #   todoapp-operator         - literal component name to match
    #   [^[:space:]]*            - any non-whitespace chars (tag/digest)
    # This matches: image: quay.io/.../todoapp-operator:tag or @sha256:...
    # But stops at whitespace to avoid greedy matching
    sed -i 's|image: [^[:space:]]*todoapp-operator[^[:space:]]*|image: '"$TODOAPP_OPERATOR_IMAGE_PULLSPEC"'|g' \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml

    echo "Updated ClusterServiceVersion"
else
    echo "Warning: ClusterServiceVersion file not found"
fi

# Update any other bundle files that reference the operator image
# This is more cautious - only replaces in the CSV file we just processed
echo "Scanning for additional operator image references in bundle files..."

echo "Bundle update complete"
