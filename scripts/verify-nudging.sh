#!/bin/bash
set -euo pipefail

# Nudging Configuration Verification Script

echo "🔍 Konflux Nudging Configuration Verification"

# Function to check component relationships
check_components() {
    echo ""
    echo "📦 Component Relationships:"
    
    echo "  Operator component:"
    if oc get component todoapp-operator &>/dev/null; then
        nudges=$(oc get component todoapp-operator -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        nudge_files=$(oc get component todoapp-operator -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "none")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges"  
        echo "    📄 Nudge files: $nudge_files"
    else
        echo "    ❌ Not found"
    fi
    
    echo "  Bundle component:"
    if oc get component todoapp-bundle &>/dev/null; then
        nudges=$(oc get component todoapp-bundle -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        nudge_files=$(oc get component todoapp-bundle -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "none")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges"
        echo "    📄 Nudge files: $nudge_files"
    else
        echo "    ❌ Not found"
    fi
    
    echo "  Catalog component:"
    if oc get component todoapp-catalog &>/dev/null; then
        nudges=$(oc get component todoapp-catalog -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        nudge_files=$(oc get component todoapp-catalog -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "none")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges"
        echo "    📄 Nudge files: $nudge_files"
    else
        echo "    ❌ Not found"
    fi
}

# Function to check pipeline files
check_pipelines() {
    echo ""
    echo "🚀 Pipeline Configuration:"
    
    for component in operator bundle catalog; do
        pipeline=".tekton/todoapp-${component}-push.yaml"
        echo "  ${component^} pipeline:"
        
        if [ -f "$pipeline" ]; then
            echo "    ✅ File exists"
            
            # Check for CEL expressions
            if grep -q "pathChanged" "$pipeline"; then
                echo "    ✅ Has CEL path filtering"
            else
                echo "    ❌ Missing CEL path filtering"
            fi
            
            # Check for nudging annotations (not catalog)
            if [ "$component" != "catalog" ]; then
                if grep -q "build-nudge-files" "$pipeline"; then
                    echo "    ✅ Has nudge-files annotation"
                else
                    echo "    ❌ Missing nudge-files annotation"
                fi
            fi
            
            # Check for skip-checks
            if grep -q "skip-checks" "$pipeline"; then
                echo "    ✅ Has skip-checks parameter"
            else
                echo "    ❌ Missing skip-checks parameter"
            fi
        else
            echo "    ❌ File not found"
        fi
    done
}

# Function to check update scripts
check_scripts() {
    echo ""
    echo "📜 Update Scripts:"
    
    echo "  Bundle update script:"
    if [ -f "bundle-hack/update_bundle.sh" ]; then
        echo "    ✅ File exists"
        if [ -x "bundle-hack/update_bundle.sh" ]; then
            echo "    ✅ Executable"
        else
            echo "    ⚠️  Not executable"
        fi
    else
        echo "    ❌ File not found"
    fi
    
    echo "  Catalog update script:"
    if [ -f "catalog-hack/update_catalog.sh" ]; then
        echo "    ✅ File exists"
        if [ -x "catalog-hack/update_catalog.sh" ]; then
            echo "    ✅ Executable"
        else
            echo "    ⚠️  Not executable"
        fi
    else
        echo "    ❌ File not found"
    fi
}

# Function to check recent pipeline runs
check_pipeline_runs() {
    echo ""
    echo "🏃 Recent Pipeline Runs:"
    
    runs=$(oc get pipelineruns -l appstudio.openshift.io/application=todoapp --sort-by=.metadata.creationTimestamp -o custom-columns="NAME:.metadata.name,COMPONENT:.metadata.labels.appstudio\.openshift\.io/component,STATUS:.status.conditions[?(@.type=='Succeeded')].status,AGE:.metadata.creationTimestamp" --no-headers 2>/dev/null | tail -5)
    
    if [ -n "$runs" ]; then
        echo "$runs" | while read -r line; do
            echo "    $line"
        done
    else
        echo "    No recent pipeline runs found"
    fi
}

# Function to check open PRs
check_prs() {
    echo ""
    echo "📋 Open Pull Requests:"
    
    prs=$(gh pr list --state=open --json number,title,createdAt 2>/dev/null | jq -r '.[] | "\(.number): \(.title) (\(.createdAt | split("T")[0]))"' || echo "")
    
    if [ -n "$prs" ]; then
        echo "$prs" | while read -r line; do
            echo "    $line"
        done
    else
        echo "    ✅ No open PRs"
    fi
}

# Function to show next steps based on current state
suggest_next_steps() {
    echo ""
    echo "🎯 Recommendations:"
    
    # Check if we have components
    if ! oc get component todoapp-operator &>/dev/null; then
        echo "  1. Create components: ./scripts/reset-components.sh create"
        return
    fi
    
    # Check for open PAC PRs
    open_prs=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    if [ "$open_prs" -gt 0 ]; then
        echo "  1. Handle PAC PRs: ./scripts/setup-nudging.sh all"
        return
    fi
    
    # Check pipeline configuration
    if ! grep -q "pathChanged" .tekton/todoapp-operator-push.yaml 2>/dev/null; then
        echo "  1. Configure pipelines: ./scripts/setup-nudging.sh pipeline-config"
        echo "  2. Commit changes: git add .tekton/ && git commit -m 'Configure nudging pipeline filters'"
        return
    fi
    
    echo "  ✅ Configuration appears complete!"
    echo "  🧪 Test by making a code change to trigger operator build"
}

# Main execution
main() {
    check_components
    check_pipelines
    check_scripts
    check_pipeline_runs
    check_prs
    suggest_next_steps
}

main "$@"