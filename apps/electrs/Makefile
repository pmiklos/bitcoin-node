.PHONY: build clean

build:
	docker build -t $(APP_ELECTRS_IMAGE) --build-arg VERSION=${APP_ELECTRS_VERSION} .

clean:
	docker rmi $(APP_ELECTRS_IMAGE)
