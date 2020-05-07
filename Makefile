.PHONY: bundle validate

OUTPUT_DIR ?= $(shell pwd)
OUTPUT_DIR := $(shell realpath $(OUTPUT_DIR))
VALIDATOR_IMAGE ?= quay.io/app-sre/qontract-validator
VALIDATOR_IMAGE_TAG ?= latest
BUNDLE_FILENAME ?= data.json
PWD := $(shell pwd)

bundle:
	mkdir -p $(OUTPUT_DIR)
	# cp --parents docs/**/*.md resources
	@docker pull $(VALIDATOR_IMAGE):$(VALIDATOR_IMAGE_TAG)
	@docker run --rm \
		-v $(PWD)/schemas:/schemas:z \
		-v $(PWD)/graphql-schemas:/graphql:z \
		-v $(PWD)/data:/data:z \
		-v $(PWD)/resources:/resources:z \
		$(VALIDATOR_IMAGE):$(VALIDATOR_IMAGE_TAG) \
		qontract-bundler /schemas /graphql/schema.yml /data /resources > $(OUTPUT_DIR)/$(BUNDLE_FILENAME)

validate:
	@docker run --rm \
		-v $(OUTPUT_DIR):/bundle:z \
		$(VALIDATOR_IMAGE):$(VALIDATOR_IMAGE_TAG) \
		qontract-validator --only-errors /bundle/$(BUNDLE_FILENAME)

toc:
	./hack/toc.py
