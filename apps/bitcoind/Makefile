.PHONY: build clean

build:
	docker build -t $(APP_BITCOIN_IMAGE) $(APP_BITCOIN_DOCKER)

clean:
	docker rmi $(APP_BITCOIN_IMAGE)
