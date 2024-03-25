include .env
export $(shell sed 's/=.*//' .env)

SUBDIRS := node apps

.PHONY: all init up down $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

init:
	./init.sh

up:
	@docker compose -p $(PROJECT) \
		-f node/docker-compose.yml \
		-f node/haproxy/docker-compose.yml \
		-f apps/bitcoind/docker-compose.yml \
		-f apps/mempool/docker-compose.yml \
		-f apps/electrs/docker-compose.yml \
		 up -d

down:
	@docker compose -p $(PROJECT) down
