# Konflux Multiple Version Management Experiment

This repository now includes an experimental implementation of Konflux's multiple version management pattern, as documented at https://konflux-ci.dev/docs/patterns/managing-multiple-versions/.

## Overview

The experiment demonstrates how to manage multiple versions of the TodoApp operator using Konflux's Project, ProjectDevelopmentStreamTemplate, and ProjectDevelopmentStream resources.

## Implementation Structure

```
konflux/project/
├── project.yaml                    # Project resource definition
├── stream-template.yaml           # Template for creating development streams
└── streams/
    ├── v1-0-stream.yaml           # v1.0 development stream
    └── v2-0-stream.yaml           # v2.0 development stream
```

## Key Components

### 1. Project Resource (`project.yaml`)
Defines the overall TodoApp project that encompasses all versions.

### 2. ProjectDevelopmentStreamTemplate (`stream-template.yaml`)
Template with variables for:
- `version`: Version identifier (e.g., v1-0, v2-0)
- `branch`: Git branch to build from (e.g., release/v1.0, release/v2.0)  
- `namespace`: Kubernetes namespace (defaults to amcdermo-tenant)

Creates templated resources for each version:
- Application: `todoapp-{{.version}}`
- Components: `todoapp-operator-{{.version}}`, `todoapp-bundle-{{.version}}`, `todoapp-catalog-{{.version}}`
- ImageRepositories: Corresponding repositories for each component

### 3. Development Streams
- **v1-0-stream.yaml**: References `release/v1.0` branch
- **v2-0-stream.yaml**: References `release/v2.0` branch

## Git Branch Structure

- `main`: Current development (existing)
- `release/v1.0`: Version 1.0 release branch (created)
- `release/v2.0`: Version 2.0 release branch (created)

## How It Works

1. **Branch-Based Isolation**: Each version builds from its own git branch
2. **Automatic Pipeline Triggering**: Existing CEL expressions work automatically because they use `target_branch` from git events
3. **Component Chaining**: Maintains operator → bundle → catalog nudging workflow per version
4. **Independent Resources**: Each version has separate Applications, Components, and ImageRepositories

## Template Expansion Example

For v1.0 stream, the template creates:
- Application: `todoapp-v1-0`
- Operator Component: `todoapp-operator-v1-0` (builds from `release/v1.0`)
- Bundle Component: `todoapp-bundle-v1-0` (builds from `release/v1.0`)
- Catalog Component: `todoapp-catalog-v1-0` (builds from `release/v1.0`)

## Benefits Demonstrated

1. **Scalability**: Easy to add new versions by creating new streams
2. **Consistency**: Template ensures uniform resource naming and configuration
3. **Isolation**: Each version operates independently
4. **Maintainability**: Single template to maintain instead of duplicated manifests
5. **Automation**: Existing pipeline logic works without modification

## Testing

Run the validation script:

```bash
./test-version-management.sh
```

This script:
- Verifies all files exist
- Checks git branches are created
- Shows template variables and stream values
- Explains the benefits and usage

## Usage Instructions

To deploy this pattern to Konflux:

```bash
# 1. Create the project
kubectl apply -f konflux/project/project.yaml

# 2. Create the template
kubectl apply -f konflux/project/stream-template.yaml

# 3. Create development streams
kubectl apply -f konflux/project/streams/v1-0-stream.yaml
kubectl apply -f konflux/project/streams/v2-0-stream.yaml
```

Once deployed:
- Push commits to `release/v1.0` to trigger v1.0 component builds
- Push commits to `release/v2.0` to trigger v2.0 component builds
- Each version maintains its own operator → bundle → catalog workflow

## Key Insights

1. **No Pipeline Changes Required**: The branch is specified in Component resources (`source.git.revision`), not in CEL expressions
2. **CEL Expressions Work Automatically**: They use `target_branch` from git events, which works for any branch
3. **Template Variables Enable Flexibility**: Can parameterize any aspect of the resource definitions
4. **Branch Isolation is Natural**: Git branches provide natural separation for different versions

## Limitations

As noted in the Konflux documentation:
- Resources created by templates aren't automatically realigned if template is modified
- Changing templates doesn't automatically delete existing resources
- Manual cleanup may be required when removing versions

## Conclusion

This experiment successfully demonstrates the Konflux multiple version management pattern. It provides a foundation for actual multi-version workflows while maintaining the existing component nudging and build automation.