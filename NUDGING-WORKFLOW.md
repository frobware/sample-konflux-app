# Konflux Component Nudging Setup Workflow

This document outlines the steps required to set up automated component nudging for operator → bundle → catalog workflows in Konflux. While the end result provides automation, the initial setup requires manual intervention due to Konflux's Pipelines as Code (PAC) management.

## Overview

The nudging system automatically creates pull requests to update downstream components when upstream components build successfully:

- **Operator builds** → triggers bundle update PR
- **Bundle builds** → triggers catalog update PR

## Prerequisites

- Konflux components configured with nudging relationships
- Update scripts for handling image reference changes
- Proper CEL expressions for efficient builds

## Initial Setup Workflow

### 1. Clean Slate Approach

Start with a clean component setup:

```bash
# Delete existing components (if any)
oc delete -f konflux-application.yaml
oc delete -f konflux-operator-component.yaml  
oc delete -f konflux-bundle-component.yaml
oc delete -f konflux-catalog-component.yaml

# Recreate components with nudging configuration
oc apply -f konflux-application.yaml
oc apply -f konflux-operator-component.yaml
oc apply -f konflux-bundle-component.yaml
oc apply -f konflux-catalog-component.yaml
```

### 2. Handle PAC Configuration PRs

Konflux will automatically create PRs for pipeline configuration:

#### Expected PRs:
- "Red Hat Konflux purge [component]" (if recreating)
- "Red Hat Konflux update [component]" (for new/updated components)

#### Actions Required:
```bash
# Close purge PRs (they remove pipeline files we want to keep)
gh pr close [purge-pr-number] --comment "Closing purge PR - keeping pipeline configuration"

# Merge update PRs (they add baseline pipeline configuration)
gh pr merge [update-pr-number] --squash --delete-branch
```

**⚠️ Important:** Merge conflicts are common. Close conflicting PRs and let Konflux recreate them.

### 3. Post-PAC Setup Configuration

After PAC PRs are merged, customize the pipeline files:

#### 3.1 Add CEL Expressions for Efficient Builds

Edit `.tekton/*-push.yaml` files to add path-based filtering:

**Operator (`todoapp-operator-push.yaml`):**
```yaml
pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch 
  == "main" && (".tekton/todoapp-operator-pull-request.yaml".pathChanged() ||
  ".tekton/todoapp-operator-push.yaml".pathChanged() || "Dockerfile".pathChanged() ||
  "api/***".pathChanged() || "internal/***".pathChanged() || "cmd/***".pathChanged() ||
  "config/***".pathChanged() || "bundle-hack/***".pathChanged())
```

**Bundle (`todoapp-bundle-push.yaml`):**
```yaml
pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch
  == "main" && (".tekton/todoapp-bundle-pull-request.yaml".pathChanged() ||
  ".tekton/todoapp-bundle-push.yaml".pathChanged() || "bundle.Dockerfile".pathChanged() ||
  "bundle/***".pathChanged() || "bundle-hack/***".pathChanged())
```

**Catalog (`todoapp-catalog-push.yaml`):**
```yaml
pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch
  == "main" && (".tekton/todoapp-catalog-pull-request.yaml".pathChanged() ||
  ".tekton/todoapp-catalog-push.yaml".pathChanged() || "catalog.Dockerfile".pathChanged() ||
  "catalog/***".pathChanged() || "catalog-hack/***".pathChanged())
```

#### 3.2 Add Build Nudge Files Annotations

Add to `.tekton/*-push.yaml` metadata annotations:

**Operator:**
```yaml
build.appstudio.openshift.io/build-nudge-files: bundle-hack/update_bundle.sh
```

**Bundle:**
```yaml
build.appstudio.openshift.io/build-nudge-files: catalog-hack/update_catalog.sh
```

**Catalog:** (no annotation needed - end of chain)

#### 3.3 Add Skip Checks Parameters

For faster testing, add to all push pipelines:
```yaml
- name: skip-checks
  value: "true"
```

### 4. Commit and Test

```bash
git add .tekton/
git commit -m "Configure CEL expressions and nudging for automated builds"
git push origin main
```

## Component Configuration

### Required Component Specifications

**Operator Component (`konflux-operator-component.yaml`):**
```yaml
spec:
  build-nudges-ref:
  - todoapp-bundle
```

**Bundle Component (`konflux-bundle-component.yaml`):**
```yaml
metadata:
  annotations:
    build.appstudio.openshift.io/build-nudge-files: "catalog-hack/update_catalog.sh"
spec:
  build-nudges-ref:
  - todoapp-catalog
```

**Catalog Component (`konflux-catalog-component.yaml`):**
```yaml
# No nudging configuration (end of chain)
```

## Update Scripts

### Bundle Update Script (`bundle-hack/update_bundle.sh`)
```bash
#!/bin/bash
set -euo pipefail

# Get the new operator image from Konflux environment variables
NEW_IMAGE="${TODOAPP_OPERATOR_IMAGE_DIGEST:-${TODOAPP_OPERATOR_IMAGE_URL:-controller:latest}}"

echo "Updating bundle with operator image: $NEW_IMAGE"

# Update ClusterServiceVersion with new operator image (only in deployments section)
if [ -f "bundle/manifests/todoapp-operator.clusterserviceversion.yaml" ]; then
    sed -i '/deployments:/,$ s|image: .*|image: '"$NEW_IMAGE"'|' \
        bundle/manifests/todoapp-operator.clusterserviceversion.yaml
    echo "Updated ClusterServiceVersion"
fi
```

### Catalog Update Script (`catalog-hack/update_catalog.sh`)
```bash
#!/bin/bash
set -euo pipefail

# Get the new bundle image from Konflux environment variables
NEW_IMAGE="${TODOAPP_BUNDLE_IMAGE_DIGEST:-${TODOAPP_BUNDLE_IMAGE_URL:-bundle:latest}}"

echo "Updating catalog with bundle image: $NEW_IMAGE"

# Update catalog.yaml with new bundle image
if [ -f "catalog/todoapp-operator/catalog.yaml" ]; then
    sed -i 's|image: .*todoapp.*bundle.*|image: '"$NEW_IMAGE"'|g' \
        catalog/todoapp-operator/catalog.yaml
    echo "Updated catalog.yaml"
fi
```

## Environment Variables

Konflux sets component-specific environment variables:

- `TODOAPP_OPERATOR_IMAGE_DIGEST` / `TODOAPP_OPERATOR_IMAGE_URL`
- `TODOAPP_BUNDLE_IMAGE_DIGEST` / `TODOAPP_BUNDLE_IMAGE_URL`
- `TODOAPP_CATALOG_IMAGE_DIGEST` / `TODOAPP_CATALOG_IMAGE_URL`

## Testing the Workflow

1. **Trigger operator build** (make code change, push)
2. **Watch for bundle nudging PR** (automated)
3. **Merge bundle PR** → triggers bundle build
4. **Watch for catalog nudging PR** (automated)
5. **Merge catalog PR** → triggers catalog build

## Troubleshooting

### Common Issues

1. **Missing nudging PRs:** Verify component `build-nudges-ref` configuration
2. **Script failures:** Check environment variables and file paths
3. **CEL expression not filtering:** Verify pathChanged() syntax
4. **Pipeline conflicts:** Close and recreate conflicting PAC PRs

### Verification Commands

```bash
# Check component nudging configuration
oc get component todoapp-operator -o jsonpath='{.spec.build-nudges-ref}'
oc get component todoapp-bundle -o jsonpath='{.spec.build-nudges-ref}'

# Check pipeline runs
oc get pipelineruns -l appstudio.openshift.io/application=todoapp --sort-by=.metadata.creationTimestamp

# Test update scripts locally
TODOAPP_OPERATOR_IMAGE_DIGEST="test:image" ./bundle-hack/update_bundle.sh
TODOAPP_BUNDLE_IMAGE_DIGEST="test:bundle" ./catalog-hack/update_catalog.sh
```

## Limitations

- **Manual PAC PR management** required during setup
- **Pipeline configuration can be overwritten** by Konflux updates
- **Not fully infrastructure-as-code** due to manual intervention requirements
- **Component deletion requires full setup repeat**

## Automation Status

- ✅ **Runtime nudging**: Fully automated once configured
- ❌ **Initial setup**: Requires manual PR management
- ❌ **Configuration maintenance**: May require periodic manual intervention