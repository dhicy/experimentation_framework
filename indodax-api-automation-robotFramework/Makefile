## ─── Indodax Robot Framework — Run Commands ─────────────────────────────────
##
##  Prerequisites:
##    pip install -r requirements.txt
##
##  Usage:
##    make smoke            → CI gate (fastest)
##    make all              → full regression
##    make ticker           → ticker tests only
##    make orderbook        → order book tests only
##    make trades           → trade history tests only
##    make general          → server time, pairs, summaries
##    make negative         → all negative/edge-case tests
##    make performance      → all SLA/perf tests
##    make clean            → remove results directory
## ─────────────────────────────────────────────────────────────────────────────

RESULTS_DIR := results
RF         := python -m robot
OPTS       := --outputdir $(RESULTS_DIR)

.PHONY: smoke all ticker orderbook trades general negative performance clean help

help:
	@grep -E '^##' Makefile | sed 's/^## //'

smoke:
	$(RF) $(OPTS) --include smoke --name "Smoke Tests" tests/

all:
	$(RF) $(OPTS) --name "Full Regression" tests/

ticker:
	$(RF) $(OPTS) --suite test_ticker --name "Ticker Tests" tests/

orderbook:
	$(RF) $(OPTS) --suite test_orderbook --name "Order Book Tests" tests/

trades:
	$(RF) $(OPTS) --suite test_trades --name "Trade History Tests" tests/

general:
	$(RF) $(OPTS) --suite test_general_api --name "General API Tests" tests/

negative:
	$(RF) $(OPTS) --include negative --name "Negative Tests" tests/

performance:
	$(RF) $(OPTS) --include performance --name "Performance Tests" tests/

contract:
	$(RF) $(OPTS) --include contract --name "Contract Tests" tests/

clean:
	rm -rf $(RESULTS_DIR)
	mkdir -p $(RESULTS_DIR)
