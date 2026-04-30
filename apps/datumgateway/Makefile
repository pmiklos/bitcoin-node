.PHONY: build checkout clean

build: checkout
ifeq ($(APP_DATUMGATEWAY_ENABLED),yes)
	docker buildx build --load -t $(APP_DATUMGATEWAY_IMAGE) $(APP_DATUMGATEWAY_DOCKER)
endif

checkout:
	@if [ ! -d release/"${APP_DATUMGATEWAY_VERSION}" ]; then \
		cd source; git worktree add --detach ../release/"${APP_DATUMGATEWAY_VERSION}" "v${APP_DATUMGATEWAY_VERSION}"; \
	fi

clean:
ifeq ($(APP_DATUMGATEWAY_ENABLED),yes)
	@if docker inspect $(APP_DATUMGATEWAY_IMAGE) >/dev/null 2>&1; then \
		docker rmi $(APP_DATUMGATEWAY_IMAGE) ; \
	fi
	@if [ -d release/"${APP_DATUMGATEWAY_VERSION}" ]; then \
		cd source; git worktree remove ../release/"${APP_DATUMGATEWAY_VERSION}" ; \
	fi
endif
