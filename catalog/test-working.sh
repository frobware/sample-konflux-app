#!/bin/bash
set -euo pipefail

echo "Building test catalog with working index..."

TEST_DIR=/tmp/test-catalog
CATALOG_IMAGE="${USER:-test}/working-catalog:latest"

mkdir -p "$TEST_DIR"

# Build catalog with working index
echo "Building container image: $CATALOG_IMAGE"
podman build --build-arg INDEX_FILE="./catalog/working-index.yaml" -t "$CATALOG_IMAGE" -f ../catalog.Dockerfile ..

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
echo "Built image: $CATALOG_IMAGE"
echo "NOTE: Push to test on cluster: podman push $CATALOG_IMAGE"
echo
echo "Apply: oc apply -f $TEST_DIR/all.yaml"
echo "Delete: oc delete -f $TEST_DIR/all.yaml"