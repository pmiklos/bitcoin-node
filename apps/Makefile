SUBDIRS := bitcoincore bitcoinknots datumgateway mempool electrs

.PHONY: all $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
