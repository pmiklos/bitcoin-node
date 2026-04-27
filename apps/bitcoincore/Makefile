.PHONY: build clean

build:
ifeq ($(APP_BITCOINCORE_ENABLED),yes)
	docker build -t $(APP_BITCOINCORE_IMAGE) $(APP_BITCOINCORE_DOCKER)
endif

clean:
ifeq ($(APP_BITCOINCORE_ENABLED),yes)
	docker rmi $(APP_BITCOINCORE_IMAGE)
endif
