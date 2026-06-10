.PHONY: build clean

build:
	docker build -t $(NODE_MDNS_IMAGE) --build-arg version=$(NODE_MDNS_VERSION) .

clean:
	docker rmi $(NODE_MDNS_IMAGE)
