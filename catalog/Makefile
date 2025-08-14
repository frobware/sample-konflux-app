IMAGE ?= localhost/sample-konflux-app-catalog:latest
BUILD_STREAM ?= alpha
OCI_BIN ?= $(shell which podman 2>/dev/null || which docker 2>/dev/null || echo docker)
OCI_BIN := $(shell basename $(OCI_BIN))
OPM := ./bin/opm
YQ := ./bin/yq

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  generate     - Generate catalog from templates"
	@echo "  build-image  - Build catalog container image"
	@echo "  push-image   - Push catalog image to registry"
	@echo "  deploy       - Deploy catalog to cluster"
	@echo "  undeploy     - Remove catalog from cluster"
	@echo "  test-local   - Build, push, and deploy in one step"

$(OPM):
	GOBIN=$(CURDIR)/bin go install github.com/operator-framework/operator-registry/cmd/opm@v1.51.0

$(YQ):
	GOBIN=$(CURDIR)/bin go install github.com/mikefarah/yq/v4@v4.35.2

.PHONY: generate
generate: $(OPM)
	rm -f ./auto-generated/*
	for i in $(shell ls ./templates/); do \
		$(OPM) alpha render-template basic --migrate-level=bundle-object-to-csv-metadata -o yaml ./templates/$$i > ./auto-generated/$$i; \
	done

.PHONY: build-image
build-image:
	$(OCI_BIN) build --build-arg INDEX_FILE="./catalog/auto-generated/$(BUILD_STREAM).yaml" -t $(IMAGE) -f ../catalog.Dockerfile ..

.PHONY: push-image
push-image:
	$(OCI_BIN) push ${IMAGE}

.PHONY: deploy
deploy: $(YQ)
	$(YQ) '.spec.image="$(IMAGE)"' ./catalog-source.yaml | oc apply -f -

.PHONY: undeploy
undeploy: $(YQ)
	$(YQ) '.spec.image="$(IMAGE)"' ./catalog-source.yaml | oc delete --ignore-not-found=true -f -

.PHONY: test-local
test-local: generate build-image push-image deploy

.PHONY: test-yaml
test-yaml:
	./test-bundle.sh
