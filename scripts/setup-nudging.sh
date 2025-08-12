#!/bin/bash
set -euo pipefail

# Automated Nudging Setup Script
# This script automates the repeatable parts of nudging configuration

echo "🚀 Konflux Nudging Setup Automation"

# Function to close PAC purge PRs
close_purge_prs() {
    echo "📝 Closing purge PRs..."
    
    # Get open purge PRs
    purge_prs=$(gh pr list --state=open --json number,title | jq -r '.[] | select(.title | contains("purge")) | .number')
    
    if [ -n "$purge_prs" ]; then
        for pr in $purge_prs; do
            echo "  Closing purge PR #$pr"
            gh pr close "$pr" --comment "Automated: Closing purge PR - keeping pipeline configuration"
        done
    else
        echo "  No purge PRs found"
    fi
}

# Function to merge PAC update PRs
merge_update_prs() {
    echo "📝 Merging update PRs..."
    
    # Get open update PRs (but not purge PRs)
    update_prs=$(gh pr list --state=open --json number,title | jq -r '.[] | select(.title | contains("update") and (contains("purge") | not)) | .number')
    
    if [ -n "$update_prs" ]; then
        for pr in $update_prs; do
            echo "  Merging update PR #$pr"
            if gh pr merge "$pr" --squash --delete-branch 2>/dev/null; then
                echo "    ✅ Merged successfully"
            else
                echo "    ⚠️  Could not merge (conflicts?) - trying auto-merge"
                gh pr merge "$pr" --auto --squash 2>/dev/null || echo "    ❌ Auto-merge also failed"
            fi
        done
    else
        echo "  No update PRs found"
    fi
}

# Function to add CEL expressions to pipeline files
add_cel_expressions() {
    echo "🔧 Adding CEL expressions for efficient builds..."
    
    # Operator pipeline CEL
    if [ -f ".tekton/todoapp-operator-push.yaml" ]; then
        echo "  Updating operator pipeline CEL expression"
        sed -i 's|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch.*|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch\n      == "main" && (".tekton/todoapp-operator-pull-request.yaml".pathChanged() \|\|\n      ".tekton/todoapp-operator-push.yaml".pathChanged() \|\| "Dockerfile".pathChanged() \|\|\n      "api/***".pathChanged() \|\| "internal/***".pathChanged() \|\| "cmd/***".pathChanged() \|\|\n      "config/***".pathChanged() \|\| "bundle-hack/***".pathChanged())|' \
            .tekton/todoapp-operator-push.yaml
    fi
    
    # Bundle pipeline CEL
    if [ -f ".tekton/todoapp-bundle-push.yaml" ]; then
        echo "  Updating bundle pipeline CEL expression"
        sed -i 's|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch.*|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch\n      == "main" && (".tekton/todoapp-bundle-pull-request.yaml".pathChanged() \|\|\n      ".tekton/todoapp-bundle-push.yaml".pathChanged() \|\| "bundle.Dockerfile".pathChanged() \|\|\n      "bundle/***".pathChanged() \|\| "bundle-hack/***".pathChanged())|' \
            .tekton/todoapp-bundle-push.yaml
    fi
    
    # Catalog pipeline CEL
    if [ -f ".tekton/todoapp-catalog-push.yaml" ]; then
        echo "  Updating catalog pipeline CEL expression"
        sed -i 's|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch.*|pipelinesascode.tekton.dev/on-cel-expression: event == "push" && target_branch\n      == "main" && (".tekton/todoapp-catalog-pull-request.yaml".pathChanged() \|\|\n      ".tekton/todoapp-catalog-push.yaml".pathChanged() \|\| "catalog.Dockerfile".pathChanged() \|\|\n      "catalog/***".pathChanged() \|\| "catalog-hack/***".pathChanged())|' \
            .tekton/todoapp-catalog-push.yaml
    fi
}

# Function to add nudging annotations to pipeline files
add_nudging_annotations() {
    echo "🔧 Adding nudging annotations to pipeline files..."
    
    # Add to operator pipeline
    if [ -f ".tekton/todoapp-operator-push.yaml" ]; then
        if ! grep -q "build-nudge-files" ".tekton/todoapp-operator-push.yaml"; then
            echo "  Adding nudge annotation to operator pipeline"
            sed -i '/build.appstudio.redhat.com\/target_branch:/a\    build.appstudio.openshift.io/build-nudge-files: bundle-hack/update_bundle.sh' \
                .tekton/todoapp-operator-push.yaml
        fi
    fi
    
    # Add to bundle pipeline  
    if [ -f ".tekton/todoapp-bundle-push.yaml" ]; then
        if ! grep -q "build-nudge-files" ".tekton/todoapp-bundle-push.yaml"; then
            echo "  Adding nudge annotation to bundle pipeline"
            sed -i '/build.appstudio.redhat.com\/target_branch:/a\    build.appstudio.openshift.io/build-nudge-files: catalog-hack/update_catalog.sh' \
                .tekton/todoapp-bundle-push.yaml
        fi
    fi
}

# Function to add skip-checks parameter
add_skip_checks() {
    echo "🔧 Adding skip-checks parameter for faster testing..."
    
    for pipeline in .tekton/*-push.yaml; do
        if [ -f "$pipeline" ]; then
            if ! grep -q "skip-checks" "$pipeline"; then
                echo "  Adding skip-checks to $(basename "$pipeline")"
                # Add skip-checks parameter after dockerfile parameter
                sed -i '/- name: dockerfile/a\  - name: skip-checks\n    value: "true"' "$pipeline"
            fi
        fi
    done
}

# Function to verify component configuration
verify_components() {
    echo "🔍 Verifying component nudging configuration..."
    
    echo "  Operator nudges:"
    oc get component todoapp-operator -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "    ❌ Not configured"
    
    echo "  Bundle nudges:"
    oc get component todoapp-bundle -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "    ❌ Not configured"
    
    echo "  Bundle nudge script:"
    oc get component todoapp-bundle -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "    ❌ Not configured"
}

# Main execution
main() {
    case "${1:-all}" in
        "close-purge")
            close_purge_prs
            ;;
        "merge-updates")
            merge_update_prs
            ;;
        "add-cel")
            add_cel_expressions
            ;;
        "add-annotations")
            add_nudging_annotations
            ;;
        "add-skip-checks")
            add_skip_checks
            ;;
        "verify")
            verify_components
            ;;
        "pipeline-config")
            add_cel_expressions
            add_nudging_annotations
            add_skip_checks
            ;;
        "all")
            close_purge_prs
            merge_update_prs
            sleep 5  # Wait for merges to complete
            git pull origin main
            add_cel_expressions
            add_nudging_annotations
            add_skip_checks
            verify_components
            ;;
        *)
            echo "Usage: $0 [close-purge|merge-updates|add-cel|add-annotations|add-skip-checks|pipeline-config|verify|all]"
            exit 1
            ;;
    esac
}

main "$@"