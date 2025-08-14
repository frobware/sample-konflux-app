# Sample Konflux App Catalog

This is a separate catalog repository for the sample-konflux-app operator, following the NetObserv pattern.

## Structure

- `templates/` - Template files for different streams
- `auto-generated/` - Generated catalog files (committed to git)
- `Dockerfile` - Simple catalog container build
- `Makefile` - Commands for generating catalogs

## Manual Update Process

When the bundle image changes:

1. Update the `image:` reference in `templates/alpha.yaml` with the new bundle digest
2. Run `make generate` to regenerate catalog files  
3. Commit the updated files
4. CI will build the new catalog container

## Commands

- `make generate` - Regenerate catalog files from templates
- `make build-image` - Build catalog container locally
- `make deploy` - Deploy catalog to cluster
- `make undeploy` - Remove catalog from cluster

## Note

This manual process is how NetObserv handles catalog updates. Yes, it requires human intervention when bundle images change. The OLM ecosystem doesn't provide good automation for this workflow.