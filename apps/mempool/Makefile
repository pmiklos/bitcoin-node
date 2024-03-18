.PHONY: build clean init build-frontend build-backend clean-frontend clean-backend

build: init build-frontend build-backend
clean: clean-frontend clean-backend

init:
	cd source && ./docker/init.sh

build-frontend:
	docker build -t $(APP_MEMPOOL_FRONTEND_IMAGE) -f source/docker/frontend/Dockerfile source/frontend

build-backend:
	docker build -t $(APP_MEMPOOL_BACKEND_IMAGE) -f source/docker/backend/Dockerfile source/backend

clean-frontend:
	docker rmi $(APP_MEMPOOL_FRONTEND_IMAGE)

clean-backend:
	docker rmi $(APP_MEMPOOL_BACKEND_IMAGE)
