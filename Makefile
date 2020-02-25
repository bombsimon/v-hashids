V ?= v

.PHONY: fmt
fmt:
	$(V) fmt -w */**.v

.PHONY: hooks
hooks:
	./script/install-hooks
