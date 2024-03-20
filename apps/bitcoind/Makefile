.PHONY: build clean

build:
	docker build -t $(APP_BITCOIND_IMAGE) $(APP_BITCOIND_DOCKER)

clean:
	docker rmi $(APP_BITCOIND_IMAGE)
