OUTPUT := csv
TYPE := infections
REPORT_DIR := ~/public_html/covid/

.PHONY: all
setup: venv venv/install covid-19-data ## Set up environment

nyla-i.tsv: venv/install ## Output data
	make --quiet ny-la OUTPUT=tsv TYPE=infections > $@.tmp
	mv $@.tmp $@
nyla-i.csv: venv/install ## Output data
	make --quiet ny-la OUTPUT=csv TYPE=infections > $@.tmp
	mv $@.tmp $@
nyla-d.tsv: venv/install ## Output data
	make --quiet ny-la OUTPUT=tsv TYPE=deaths > $@.tmp
	mv $@.tmp $@
nyla-d.csv: venv/install ## Output data
	make --quiet ny-la OUTPUT=csv TYPE=deaths > $@.tmp
	mv $@.tmp $@

%.png: %.plot
	gnuplot < $<

.PHONY: data
data: nyla-i.csv nyla-i.tsv nyla-d.csv nyla-d.tsv

.PHONY: pngs
pngs: data nyla-i-linear.png nyla-i-log.png nyla-d-linear.png nyla-d-log.png

.PHONY: report
report: pngs
	cp *.png report.html ${REPORT_DIR}

.PHONY: ny-la
ny-la: venv/install ## Output data for NY and LA
	@./venv/bin/python3 extract.py --pop-file population.csv \
		--case-file ./covid-19-data/us-counties.csv \
		--after-date 2020-03-13 \
		--county="New York City" --county="Los Angeles" \
		--output ${OUTPUT} \
		--case-type ${TYPE}

venv: ## Set up virtualenv
	python3 -m venv venv

venv/install: venv requirements.txt ## Install packages in venv
	./venv/bin/pip3 install -r requirements.txt
	touch venv/install

covid-19-data: ## Clone the New York Times COVID-19 data repo
	git clone https://github.com/nytimes/covid-19-data.git covid-19-data

.PHONY: clean
clean: ## Clean up output
	rm -f nyla-i.* nyla-d.* nyla-*.png

.PHONY: clean-all
clean-all: clean ## Clean up everything (virtualenv, downloaded data)
	rm -rf venv covid-19-data

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
