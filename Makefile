
.PHONY: spec

spec:
	@if tty -s; then \
	  crystal spec -v; \
	else \
	  crystal spec; \
	fi
