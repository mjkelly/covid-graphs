OUTPUT=csv

.PHONY: all
all: venv venv/install ## Set up environment

.PHONY: ny-la-infections
ny-la-infections: venv/install ## Output data
	./venv/bin/python3 extract.py --pop-file population.csv \
		--case-file ../covid-19-data/us-counties.csv \
		--after-date 2020-03-13 \
		--county="New York City" --county="Los Angeles" \
		--output ${OUTPUT} \
		--case-type infections

.PHONY: ny-la-deaths
ny-la-deaths: venv/install ## Output data
	./venv/bin/python3 extract.py --pop-file population.csv \
		--case-file ../covid-19-data/us-counties.csv \
		--after-date 2020-03-13 \
		--county="New York City" --county="Los Angeles" \
		--output ${OUTPUT} \
		--case-type deaths

venv: ## Set up virtualenv
	python3 -m venv venv

venv/install: venv requirements.txt ## Install packages in venv
	./venv/bin/pip3 install -r requirements.txt
	touch venv/install

.PHONY: clean
clean: ## Clean up virtualenv
	rm -rf venv

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
