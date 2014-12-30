all:
	$(MAKE) -C notes all
	$(MAKE) -C slides all

all_key:
	$(MAKE) -C slides all_key

clean:
	$(MAKE) -C notes clean
	$(MAKE) -C slides clean

reallyclean:
	$(MAKE) -C notes reallyclean
	$(MAKE) -C slides reallyclean

.PHONY: all all_key clean reallyclean
