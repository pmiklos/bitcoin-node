.PHONY: build clean

build:
ifeq ($(APP_BITCOINKNOTS_ENABLED),yes)
	docker buildx build --load --build-arg VERSION=${APP_BITCOINKNOTS_VERSION} --build-arg RDTS_CONSENT=${APP_BITCOINKNOTS_RDTS_CONSENT} -t $(APP_BITCOINKNOTS_IMAGE) $(APP_BITCOINKNOTS_DOCKER)
endif

clean:
ifeq ($(APP_BITCOINKNOTS_ENABLED),yes)
	docker rmi $(APP_BITCOINKNOTS_IMAGE)
endif
