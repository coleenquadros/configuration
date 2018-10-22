.PHONY: validate build build-app-interface

APP_ROOT := /validator
IMAGE_NAME_VALIDATOR := app-interface-validator:latest
IMAGE_NAME_APP_INTERFACE := quay.io/app-sre/app-interface:latest

validate:
	@docker run \
		-v ${PWD}/schemas:$(APP_ROOT)/schemas:z \
		-v ${PWD}/data:$(APP_ROOT)/data:z \
		$(IMAGE_NAME_VALIDATOR) \
		--schemas-root $(APP_ROOT)/schemas \
		--data-root $(APP_ROOT)/data

build:
	@docker build -t $(IMAGE_NAME_VALIDATOR) -f dockerfiles/Dockerfile.validator .
build-app-interface:
	@docker build -t $(IMAGE_NAME_APP_INTERFACE) -f dockerfiles/Dockerfile.app-interface .
