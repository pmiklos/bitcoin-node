.PHONY: build clean checkout

MAJOR_VERSION := $(word 1,$(subst ., ,$(APP_BITCOINCORE_VERSION)))
DOCKER_DIR ?= $(if $(APP_BITCOINCORE_DOCKER),$(APP_BITCOINCORE_DOCKER),docker/$(MAJOR_VERSION).x)
DOCKER_FILE := $(if $(wildcard $(DOCKER_DIR)/Dockerfile),$(DOCKER_DIR)/Dockerfile,$(DOCKER_DIR))
SOURCE_DIR := source
GIT_TAG := v$(APP_BITCOINCORE_VERSION)

checkout:
ifneq ($(APP_BITCOINCORE_VERSION),)
	@if [ ! -e "$(SOURCE_DIR)/.git" ]; then \
		echo "Initializing submodule $(SOURCE_DIR)..."; \
		git submodule update --init --recursive $(SOURCE_DIR); \
	fi
	@if ! git -C $(SOURCE_DIR) rev-parse --verify -q "refs/tags/$(GIT_TAG)" > /dev/null 2>&1; then \
		echo "Tag $(GIT_TAG) not found locally, fetching tags from origin..."; \
		git -C $(SOURCE_DIR) fetch --tags origin; \
	fi
	@echo "Synchronizing $(SOURCE_DIR) to tag $(GIT_TAG)..."
	@git -C $(SOURCE_DIR) checkout $(GIT_TAG)
endif

build:
ifeq ($(APP_BITCOINCORE_ENABLED),yes)
	@$(MAKE) checkout
	@if [ ! -f "$(DOCKER_FILE)" ]; then \
		echo "Error: Dockerfile not found at $(DOCKER_FILE) for version $(APP_BITCOINCORE_VERSION)" >&2; \
		exit 1; \
	fi
	docker buildx build --load \
		--build-arg VERSION=$(APP_BITCOINCORE_VERSION) \
		-t $(APP_BITCOINCORE_IMAGE) \
		-f $(DOCKER_FILE) \
		$(SOURCE_DIR)
endif

clean:
ifeq ($(APP_BITCOINCORE_ENABLED),yes)
	docker rmi $(APP_BITCOINCORE_IMAGE)
endif
