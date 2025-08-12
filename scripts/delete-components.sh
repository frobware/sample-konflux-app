#!/bin/bash
set -euo pipefail

# Component Deletion Script
# Clean deletion of all todoapp Konflux components

echo "🗑️  Deleting Konflux Components"

# Function to show current status before deletion
show_current_status() {
    echo "📊 Current status before deletion:"
    
    echo "  Components:"
    if oc get components 2>/dev/null | grep -q todoapp; then
        oc get components | grep todoapp || echo "    No todoapp components found"
    else
        echo "    No components found"
    fi
    
    echo ""
    echo "  Open PRs:"
    pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    if [ "$pr_count" -gt 0 ]; then
        echo "    $pr_count open PR(s)"
        gh pr list --state=open --json number,title 2>/dev/null | jq -r '.[] | "    #\(.number): \(.title)"' || echo "    Could not list PRs"
    else
        echo "    No open PRs"
    fi
}

# Function to delete components
delete_components() {
    echo ""
    echo "🗑️  Deleting components..."
    
    # Delete in reverse dependency order to avoid issues
    echo "  Deleting catalog component..."
    if oc delete -f konflux-catalog-component.yaml 2>/dev/null; then
        echo "    ✅ Catalog component deleted"
    else
        echo "    ℹ️  Catalog component not found or already deleted"
    fi
    
    echo "  Deleting bundle component..."
    if oc delete -f konflux-bundle-component.yaml 2>/dev/null; then
        echo "    ✅ Bundle component deleted"
    else
        echo "    ℹ️  Bundle component not found or already deleted"
    fi
    
    echo "  Deleting operator component..."
    if oc delete -f konflux-operator-component.yaml 2>/dev/null; then
        echo "    ✅ Operator component deleted"
    else
        echo "    ℹ️  Operator component not found or already deleted"
    fi
    
    echo "  Deleting application..."
    if oc delete -f konflux-application.yaml 2>/dev/null; then
        echo "    ✅ Application deleted"
    else
        echo "    ℹ️  Application not found or already deleted"
    fi
}

# Function to wait and show expected PAC PRs
wait_for_purge_prs() {
    echo ""
    echo "⏳ Waiting for Konflux to create purge PRs..."
    
    sleep 10
    
    pr_count=$(gh pr list --state=open 2>/dev/null | wc -l || echo "0")
    
    if [ "$pr_count" -gt 0 ]; then
        echo "  Found $pr_count open PR(s):"
        gh pr list --state=open --json number,title 2>/dev/null | jq -r '.[] | "    #\(.number): \(.title)"' || echo "    Could not list PR details"
        
        purge_count=$(gh pr list --state=open --json title 2>/dev/null | jq -r '.[] | select(.title | contains("purge")) | .title' | wc -l || echo "0")
        
        if [ "$purge_count" -gt 0 ]; then
            echo ""
            echo "✅ Purge PRs detected - deletion triggered PAC correctly"
            echo ""
            echo "🔄 Next steps:"
            echo "  1. Close purge PRs: ./scripts/setup-nudging.sh close-purge"
            echo "  2. Or handle all: ./scripts/setup-nudging.sh all"
        else
            echo ""
            echo "⚠️  No purge PRs found - may be other types of PRs"
        fi
    else
        echo "  No PRs created yet - may need to wait longer or check manually"
        echo ""
        echo "🔄 Next step:"
        echo "  Create components: ./scripts/create-components.sh"
    fi
}

# Function to verify deletion
verify_deletion() {
    echo ""
    echo "🔍 Verifying deletion..."
    
    remaining_components=$(oc get components 2>/dev/null | grep todoapp | wc -l || echo "0")
    remaining_app=$(oc get application todoapp 2>/dev/null | wc -l || echo "0")
    
    if [ "$remaining_components" -eq 0 ] && [ "$remaining_app" -eq 0 ]; then
        echo "  ✅ All components and application successfully deleted"
    else
        echo "  ⚠️  Some resources may still exist:"
        [ "$remaining_components" -gt 0 ] && echo "    - $remaining_components component(s) remaining"
        [ "$remaining_app" -gt 0 ] && echo "    - Application still exists"
    fi
}

# Main execution
main() {
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        echo "Usage: $0"
        echo ""
        echo "Deletes all todoapp Konflux components and application."
        echo "This will trigger Konflux to create 'purge' PRs to remove pipeline files."
        echo ""
        echo "After deletion, use create-components.sh to recreate the components."
        exit 0
    fi
    
    show_current_status
    delete_components
    verify_deletion
    wait_for_purge_prs
}

main "$@"