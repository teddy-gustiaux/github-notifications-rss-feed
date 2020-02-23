# Variables
DOCKER_ID := teddygustiaux
REPOSITORY := github-notifications-rss-feed
TAG_PROD := latest
TAG_DEV := latest-dev
IMAGE_PROD := $(DOCKER_ID)/$(REPOSITORY):$(TAG_PROD)
IMAGE_DEV := $(DOCKER_ID)/$(REPOSITORY):$(TAG_DEV)

# Parameters
ifeq ($(ENV_DIR),)
ENV_DIR := ${CURDIR}
endif

ifeq ($(OUTPUT_DIR),)
OUTPUT_DIR := ${CURDIR}
endif

ifeq ($(APP_DIR),)
APP_DIR := ${CURDIR}
endif

# Targets
default:
	$(error Please provide a target)

build_production:
	docker build --target production --tag $(IMAGE_PROD) .

build_development:
	docker build --target entrypoint --tag $(IMAGE_DEV) .

run_production:
	docker run \
	--rm \
	--name ghnrf \
	--env-file "${ENV_DIR}/.env" \
	--mount type=bind,source="${OUTPUT_DIR}/output",target=/app/output \
	$(IMAGE_PROD)

run_development:
	docker run \
	--rm \
	--name ghnrf-dev \
	--env-file "${ENV_DIR}/.env" \
	--mount type=bind,source="${APP_DIR}/output",target=/app/output \
	--mount type=bind,source="${OUTPUT_DIR}/src",target=/app/src \
	$(IMAGE_DEV)
