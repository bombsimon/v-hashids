V ?= v

.PHONY: fmt
fmt:
	$(V) fmt -w $(shell find . -name "*.v")

.PHONY: hooks
hooks:
	./script/install-hooks
