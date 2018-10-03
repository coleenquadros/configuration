.PHONY: validate build

APP_ROOT := /validator
IMAGE_NAME := app-interface-validator

validate:
	@docker run \
		-v ${PWD}/services:$(APP_ROOT)/services:z \
		-v ${PWD}/schemas:$(APP_ROOT)/schemas:z \
		$(IMAGE_NAME) \
		'$(APP_ROOT)/services/**/*'

build:
	@docker build -t $(IMAGE_NAME) .
