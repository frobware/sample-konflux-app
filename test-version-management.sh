#!/bin/bash
set -euo pipefail

# Test script for Konflux multiple version management pattern
# This script validates the template expansion and demonstrates the workflow

echo "=== Testing Konflux Multiple Version Management Pattern ==="
echo

# Check if required files exist
echo "Checking project structure..."
required_files=(
    "konflux/project/project.yaml"
    "konflux/project/stream-template.yaml" 
    "konflux/project/streams/v1-0-stream.yaml"
    "konflux/project/streams/v2-0-stream.yaml"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

echo

# Check git branches
echo "Checking git branches..."
if git rev-parse --verify release/v1.0 >/dev/null 2>&1; then
    echo "✓ release/v1.0 branch exists"
else
    echo "✗ release/v1.0 branch missing"
fi

if git rev-parse --verify release/v2.0 >/dev/null 2>&1; then
    echo "✓ release/v2.0 branch exists"  
else
    echo "✗ release/v2.0 branch missing"
fi

echo

# Display template structure
echo "=== ProjectDevelopmentStreamTemplate Variables ==="
echo "The template defines these variables:"
grep -A 10 "variables:" konflux/project/stream-template.yaml | grep -E "^\s*- name:" | sed 's/^.*name: /- /'

echo

# Display example development streams
echo "=== Development Streams ==="
for stream in konflux/project/streams/*.yaml; do
    stream_name=$(basename "$stream" .yaml)
    echo "Stream: $stream_name"
    echo "  Values:"
    grep -A 5 "values:" "$stream" | grep -E "^\s*(version|branch|namespace):" | sed 's/^/    /'
    echo
done

echo "=== Template Pattern Benefits ==="
echo "1. Consistent naming: todoapp-operator-v1-0, todoapp-bundle-v1-0, etc."
echo "2. Branch isolation: Each version builds from its own branch"
echo "3. Independent pipelines: CEL expressions work automatically for any branch"
echo "4. Scalable: Easy to add new versions by creating new streams"
echo "5. Separation: Each version has separate Application, Components, and ImageRepositories"

echo

echo "=== Next Steps ==="
echo "To use this pattern in Konflux:"
echo "1. kubectl apply -f konflux/project/project.yaml"
echo "2. kubectl apply -f konflux/project/stream-template.yaml"  
echo "3. kubectl apply -f konflux/project/streams/v1-0-stream.yaml"
echo "4. kubectl apply -f konflux/project/streams/v2-0-stream.yaml"
echo "5. Push commits to release/v1.0 and release/v2.0 branches to trigger builds"

echo
echo "=== Pattern Validation Complete ==="