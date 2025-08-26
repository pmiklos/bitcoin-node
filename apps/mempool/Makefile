.PHONY: build clean init build-frontend build-backend clean-frontend clean-backend

build: init build-frontend build-backend
clean: clean-frontend clean-backend

init:
	cd source && cmp -s backend/Dockerfile docker/backend/Dockerfile || ./docker/init.sh

build-frontend:
	docker build -t $(APP_MEMPOOL_FRONTEND_IMAGE) -f source/docker/frontend/Dockerfile source/frontend

build-backend:
	cd source && docker buildx build -t $(APP_MEMPOOL_BACKEND_IMAGE) \
		--build-context rustgbt=./rust \
		--build-context backend=./backend \
		--output "type=docker" \
		--build-arg commitHash=$(APP_MEMPOOL_VERSION) \
		backend

clean-frontend:
	docker rmi $(APP_MEMPOOL_FRONTEND_IMAGE)

clean-backend:
	docker rmi $(APP_MEMPOOL_BACKEND_IMAGE)
