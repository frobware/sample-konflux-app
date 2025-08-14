#!/bin/bash
set -euo pipefail

TEST_DIR=/tmp/test-catalog
mkdir -p "$TEST_DIR"

# Check if catalog image exists from Konflux builds
if [ -f "../konflux/image-refs/catalog.txt" ]; then
    CATALOG_IMAGE=$(cat ../konflux/image-refs/catalog.txt | tr -d '\n')
    echo "Using existing Konflux catalog image: $CATALOG_IMAGE"
else
    echo "No Konflux catalog image found. Building locally with latest bundle..."
    
    BUNDLE_IMAGE=$(cat ../konflux/image-refs/bundle.txt | tr -d '\n')
    CATALOG_IMAGE="${USER:-test}/test-catalog:latest"
    
    # Generate catalog with latest bundle
    sed "s|image:.*todoapp-bundle.*|image: $BUNDLE_IMAGE|g" ./templates/alpha.yaml > "$TEST_DIR/test-template.yaml"
    opm alpha render-template basic --migrate-level=bundle-object-to-csv-metadata -o yaml "$TEST_DIR/test-template.yaml" > "$TEST_DIR/index.yaml"
    
    # Copy catalog to build context
    cp "$TEST_DIR/index.yaml" ../catalog/auto-generated/test.yaml
    
    # Build catalog container image
    echo "Building container image: $CATALOG_IMAGE"
    podman build --build-arg INDEX_FILE="./catalog/auto-generated/test.yaml" -t "$CATALOG_IMAGE" -f ../catalog.Dockerfile ..
    
    echo "NOTE: Push image to test on cluster: podman push $CATALOG_IMAGE"
fi

# Create CatalogSource YAML
cat > "$TEST_DIR/all.yaml" << EOF
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: test-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: $CATALOG_IMAGE
EOF

echo
echo "Apply: oc apply -f $TEST_DIR/all.yaml"
echo "Delete: oc delete -f $TEST_DIR/all.yaml"