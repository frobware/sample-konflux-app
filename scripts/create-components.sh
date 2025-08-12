#!/bin/bash
set -euo pipefail

# Component Creation Script
# Creates Konflux components with nudging configuration

echo "🚀 Creating Konflux Components"

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    # Check for required files
    required_files=(
        "konflux-application.yaml"
        "konflux-operator-component.yaml"
        "konflux-bundle-component.yaml"
        "konflux-catalog-component.yaml"
        "bundle-hack/update_bundle.sh"
        "catalog-hack/update_catalog.sh"
    )
    
    missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "  ❌ Missing required files:"
        printf "    - %s\n" "${missing_files[@]}"
        exit 1
    fi
    
    # Check if components already exist
    existing_components=$(oc get components 2>/dev/null | grep todoapp | wc -l || echo "0")
    if [ "$existing_components" -gt 0 ]; then
        echo "  ⚠️  Components already exist:"
        oc get components | grep todoapp || echo "    Could not list existing components"
        echo ""
        echo "  To delete existing components first:"
        echo "    ./scripts/delete-components.sh"
        echo ""
        read -p "  Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo "  ✅ Prerequisites checked"
}

# Function to show current status
show_current_status() {
    echo ""
    echo "📊 Current status:"
    
    echo "  Components:"
    component_count=$(oc get components 2>/dev/null | grep todoapp | wc -l || echo "0")
    echo "    $component_count todoapp component(s) exist"
    
    echo "  Open PRs:"
    pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    echo "    $pr_count open PR(s)"
}

# Function to create components in correct order
create_components() {
    echo ""
    echo "🚀 Creating components..."
    
    echo "  Creating application..."
    if oc apply -f konflux-application.yaml; then
        echo "    ✅ Application created"
    else
        echo "    ❌ Failed to create application"
        exit 1
    fi
    
    echo "  Creating operator component..."
    if oc apply -f konflux-operator-component.yaml; then
        echo "    ✅ Operator component created"
    else
        echo "    ❌ Failed to create operator component"
        exit 1
    fi
    
    echo "  Creating bundle component..."
    if oc apply -f konflux-bundle-component.yaml; then
        echo "    ✅ Bundle component created"
    else
        echo "    ❌ Failed to create bundle component"
        exit 1
    fi
    
    echo "  Creating catalog component..."
    if oc apply -f konflux-catalog-component.yaml; then
        echo "    ✅ Catalog component created"
    else
        echo "    ❌ Failed to create catalog component"
        exit 1
    fi
}

# Function to verify component configuration
verify_components() {
    echo ""
    echo "🔍 Verifying component nudging configuration..."
    
    # Check operator component
    echo "  Operator component:"
    if oc get component todoapp-operator &>/dev/null; then
        nudges=$(oc get component todoapp-operator -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        nudge_files=$(oc get component todoapp-operator -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "none")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges"
        echo "    📄 Nudge files: $nudge_files"
        
        if [[ "$nudges" == *"todoapp-bundle"* ]]; then
            echo "    ✅ Correctly configured to nudge bundle"
        else
            echo "    ⚠️  Not configured to nudge bundle"
        fi
    else
        echo "    ❌ Not found"
    fi
    
    # Check bundle component
    echo "  Bundle component:"
    if oc get component todoapp-bundle &>/dev/null; then
        nudges=$(oc get component todoapp-bundle -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        nudge_files=$(oc get component todoapp-bundle -o jsonpath='{.metadata.annotations.build\.appstudio\.openshift\.io/build-nudge-files}' 2>/dev/null || echo "none")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges"
        echo "    📄 Nudge files: $nudge_files"
        
        if [[ "$nudges" == *"todoapp-catalog"* ]]; then
            echo "    ✅ Correctly configured to nudge catalog"
        else
            echo "    ⚠️  Not configured to nudge catalog"
        fi
    else
        echo "    ❌ Not found"
    fi
    
    # Check catalog component
    echo "  Catalog component:"
    if oc get component todoapp-catalog &>/dev/null; then
        nudges=$(oc get component todoapp-catalog -o jsonpath='{.spec.build-nudges-ref}' 2>/dev/null || echo "[]")
        echo "    ✅ Exists"
        echo "    📤 Nudges: $nudges (should be empty - end of chain)"
        
        if [[ "$nudges" == "[]" ]] || [[ "$nudges" == "" ]]; then
            echo "    ✅ Correctly configured (no downstream nudging)"
        else
            echo "    ⚠️  Has unexpected nudging configuration"
        fi
    else
        echo "    ❌ Not found"
    fi
}

# Function to wait for PAC PRs
wait_for_pac_prs() {
    echo ""
    echo "⏳ Waiting for Konflux to create configuration PRs..."
    
    initial_pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    
    # Wait up to 30 seconds for PRs to appear
    for i in {1..6}; do
        sleep 5
        current_pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
        
        if [ "$current_pr_count" -gt "$initial_pr_count" ]; then
            break
        fi
        
        if [ $i -lt 6 ]; then
            echo "  Waiting... ($((i * 5))s elapsed)"
        fi
    done
    
    final_pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    
    if [ "$final_pr_count" -gt "$initial_pr_count" ]; then
        new_prs=$((final_pr_count - initial_pr_count))
        echo "  ✅ $new_prs new PR(s) created:"
        
        gh pr list --state=open --json number,title,createdAt 2>/dev/null | \
            jq -r '.[] | select(.createdAt > (now - 300 | todate)) | "    #\(.number): \(.title)"' 2>/dev/null || \
            gh pr list --state=open 2>/dev/null | head -"$new_prs" | sed 's/^/    /'
        
        echo ""
        echo "🔄 Next steps:"
        echo "  1. Handle PAC PRs: ./scripts/setup-nudging.sh all"
        echo "  2. Or manually:"
        echo "     - Close purge PRs: ./scripts/setup-nudging.sh close-purge"  
        echo "     - Merge update PRs: ./scripts/setup-nudging.sh merge-updates"
        echo "  3. Verify configuration: ./scripts/verify-nudging.sh"
        
    else
        echo "  ⏳ No new PRs detected yet"
        echo "     This may take a few more minutes, or check manually with: gh pr list"
        echo ""
        echo "🔄 Next steps when PRs appear:"
        echo "  1. Handle PAC PRs: ./scripts/setup-nudging.sh all"
        echo "  2. Verify setup: ./scripts/verify-nudging.sh"
    fi
}

# Main execution
main() {
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        echo "Usage: $0"
        echo ""
        echo "Creates todoapp Konflux components with nudging configuration."
        echo "This will trigger Konflux to create 'update' PRs to add pipeline files."
        echo ""
        echo "Components created:"
        echo "  - todoapp (Application)"
        echo "  - todoapp-operator (nudges bundle)"
        echo "  - todoapp-bundle (nudges catalog)"
        echo "  - todoapp-catalog (end of chain)"
        echo ""
        echo "After creation, use setup-nudging.sh to handle PAC PRs."
        exit 0
    fi
    
    check_prerequisites
    show_current_status
    create_components
    verify_components
    wait_for_pac_prs
}

main "$@"