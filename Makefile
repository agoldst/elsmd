all:
	$(MAKE) -C notes all
	$(MAKE) -C slides all

all_key:
	$(MAKE) -C slides all_key

.PHONY: all all_key
