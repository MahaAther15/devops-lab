SRC_DIR := src
OUT_DIR := out

SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help

all: test ## Build and test everything

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check: ## Check that source files exist
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "ERROR: source directory $(SRC_DIR) does not exist"; \
		exit 1; \
	elif [ "$(words $(SOURCES))" -eq 0 ]; then \
		echo "ERROR: no .txt files found in $(SRC_DIR)"; \
		exit 1; \
	else \
		echo "CHECK PASSED: found $(words $(SOURCES)) source file(s)"; \
	fi

build: $(OUTPUTS) ## Build all output files

test: build ## Test that outputs contain no lowercase
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
		echo "TEST FAILED: lowercase characters remain"; \
		exit 1; \
	fi
	@echo "TEST PASSED"

clean: ## Remove all generated output
	rm -rf $(OUT_DIR)

ci: clean check test ## Run clean, check, and test

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*##' Makefile | \
	awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'
