SUBDIRS := bitcoincore bitcoinknots mempool electrs

.PHONY: all $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@
