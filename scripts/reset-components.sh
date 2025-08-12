#!/bin/bash
set -euo pipefail

# Component Reset Script
# Provides clean slate for nudging setup

echo "🗑️  Konflux Component Reset"

# Function to clean delete components
delete_components() {
    echo "Deleting all todoapp components..."
    
    oc delete -f konflux-operator-component.yaml 2>/dev/null || echo "  Operator component not found"
    oc delete -f konflux-bundle-component.yaml 2>/dev/null || echo "  Bundle component not found"
    oc delete -f konflux-catalog-component.yaml 2>/dev/null || echo "  Catalog component not found"
    oc delete -f konflux-application.yaml 2>/dev/null || echo "  Application not found"
    
    echo "  ✅ Components deleted"
}

# Function to recreate components with nudging config
create_components() {
    echo "Creating components with nudging configuration..."
    
    oc apply -f konflux-application.yaml
    echo "  ✅ Application created"
    
    oc apply -f konflux-operator-component.yaml
    echo "  ✅ Operator component created"
    
    oc apply -f konflux-bundle-component.yaml  
    echo "  ✅ Bundle component created"
    
    oc apply -f konflux-catalog-component.yaml
    echo "  ✅ Catalog component created"
}

# Function to wait for PAC PRs
wait_for_pac_prs() {
    echo "⏳ Waiting for PAC PRs to be created..."
    
    sleep 10
    
    pr_count=$(gh pr list --state=open | wc -l)
    echo "  Found $pr_count open PR(s)"
    
    if [ "$pr_count" -gt 0 ]; then
        gh pr list --state=open
        echo ""
        echo "🔄 Next steps:"
        echo "  1. Run: ./scripts/setup-nudging.sh close-purge"
        echo "  2. Run: ./scripts/setup-nudging.sh merge-updates"
        echo "  3. Run: ./scripts/setup-nudging.sh pipeline-config"
        echo "  Or run: ./scripts/setup-nudging.sh all"
    else
        echo "  No PAC PRs created yet - may need to wait longer"
    fi
}

# Function to show component status
show_status() {
    echo "📊 Current component status:"
    
    echo "Components:"
    oc get components 2>/dev/null | grep todoapp || echo "  No todoapp components found"
    
    echo ""
    echo "Open PRs:"
    gh pr list --state=open || echo "  No open PRs"
    
    echo ""
    echo "Pipeline files:"
    ls -la .tekton/ 2>/dev/null || echo "  No pipeline files found"
}

# Main execution
main() {
    case "${1:-reset}" in
        "delete")
            delete_components
            ;;
        "create")
            create_components
            wait_for_pac_prs
            ;;
        "status")
            show_status
            ;;
        "reset")
            delete_components
            echo "⏳ Waiting 5 seconds..."
            sleep 5
            create_components
            wait_for_pac_prs
            ;;
        *)
            echo "Usage: $0 [delete|create|status|reset]"
            echo ""
            echo "Commands:"
            echo "  delete  - Delete all components"
            echo "  create  - Create components with nudging config"
            echo "  status  - Show current status"
            echo "  reset   - Delete then recreate (default)"
            exit 1
            ;;
    esac
}

main "$@"