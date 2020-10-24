REPORT_DIR := ~/public_html/covid/

.PHONY: setup
setup: venv venv/install covid-19-data ## Set up environment

venv: ## Set up virtualenv
	python3 -m venv venv

venv/install: venv requirements.txt ## Install packages in venv
	./venv/bin/pip3 install -r requirements.txt
	touch venv/install

.PHONY: report
report:
	./venv/bin/python3 ./graph2.py --report-dir ${REPORT_DIR}

covid-19-data: ## Clone the New York Times COVID-19 data repo
	git clone https://github.com/nytimes/covid-19-data.git covid-19-data

.PHONY: clean
clean: ## Clean up output
	rm -f nyla-*.csv nyla-*.tsv nyla-*.png

.PHONY: clean-all
clean-all: clean ## Clean up everything (virtualenv, downloaded data)
	rm -rf venv covid-19-data

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
