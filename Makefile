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
		$(if $(filter yes,$(APP_BITCOINCORE_ENABLED)),-f apps/bitcoincore/docker-compose.yml) \
		$(if $(filter yes,$(APP_BITCOINKNOTS_ENABLED)),-f apps/bitcoinknots/docker-compose.yml) \
		-f apps/mempool/docker-compose.yml \
		-f apps/electrs/docker-compose.yml \
		 up -d

down:
	@docker compose -p $(PROJECT) down
