.PHONY: build clean

build:
	docker build -t $(NODE_HAPROXY_IMAGE) --build-arg version=$(NODE_HAPROXY_VERSION) .

clean:
	docker rmi $(NODE_HAPROXY_IMAGE)
