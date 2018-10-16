.PHONY: validate build

APP_ROOT := /validator
IMAGE_NAME := app-interface-validator

validate:
	@docker run \
		-v ${PWD}/schemas:$(APP_ROOT)/schemas:z \
		-v ${PWD}/data:$(APP_ROOT)/data:z \
		$(IMAGE_NAME) \
		--metaschema metaschema.json \
		--schemas-root $(APP_ROOT)/schemas \
		--data-root $(APP_ROOT)/data

build:
	@docker build -t $(IMAGE_NAME) .
