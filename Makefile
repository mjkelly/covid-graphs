OUTPUT := csv
TYPE := infections
METRIC := total_per_1k
REPORT_DIR := ~/public_html/covid/

.PHONY: setup
setup: venv venv/install covid-19-data ## Set up environment

nyla-i.csv: extract.py venv/install
	make --quiet ny-la OUTPUT=csv TYPE=infections > $@.tmp
	mv $@.tmp $@
nyla-d.csv: extract.py venv/install
	make --quiet ny-la OUTPUT=csv TYPE=deaths > $@.tmp
	mv $@.tmp $@
nyla-idaily.csv: extract.py venv/install
	make --quiet ny-la OUTPUT=csv TYPE=infections METRIC=daily_per_1k > $@.tmp
	mv $@.tmp $@
nyla-ddaily.csv: extract.py venv/install
	make --quiet ny-la OUTPUT=csv TYPE=deaths METRIC=daily_per_1k > $@.tmp
	mv $@.tmp $@

.PHONY: csvs
csvs: nyla-i.csv nyla-d.csv nyla-idaily.csv nyla-ddaily.csv

.PHONY: pngs
pngs: graph.py csvs ## generate PNG files with matplotlib
	./venv/bin/python3 graph.py --infile nyla-i.csv --outfile nyla-i-linear.png --title "Cumulative Infections (linear)" --ylabel "Infections per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-i.csv --outfile nyla-i-log.png --title "Cumulative Infections (logarithmic)" --ylabel "Infections per 1000 people" --ylog
	./venv/bin/python3 graph.py --infile nyla-d.csv --outfile nyla-d-linear.png --title "Cumulative Deaths (linear)" --ylabel "Deaths per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-d.csv --outfile nyla-d-log.png --title "Cumulative Deaths (logarithmic)" --ylabel "Deaths per 1000 people" --ylog
	./venv/bin/python3 graph.py --infile nyla-idaily.csv --outfile nyla-idaily-linear.png --title "Infections per Day (linear)" --ylabel "Infections per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-idaily.csv --outfile nyla-idaily-log.png --title "Infections per Day (logarithmic)" --ylabel "Infections per 1000 people" --ylog
	./venv/bin/python3 graph.py --infile nyla-ddaily.csv --outfile nyla-ddaily-linear.png --title "Deaths per Day (linear)" --ylabel "Deaths per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-ddaily.csv --outfile nyla-ddaily-log.png --title "Deaths per Day (logarithmic)" --ylabel "Deaths per 1000 people" --ylog


.PHONY: report
report: pngs ## Generate a full report
	cp *.png ${REPORT_DIR}/
	cp report.html ${REPORT_DIR}/index.html
	echo "<hr>Generated: $$(date)" >> ${REPORT_DIR}/index.html

.PHONY: ny-la
ny-la: setup ## Output data for NY and LA
	@./venv/bin/python3 extract.py --pop-file population.csv \
		--case-file ./covid-19-data/us-counties.csv \
		--after-date 2020-03-13 \
		--county="New York City" --county="Los Angeles" \
		--output ${OUTPUT} \
		--case-type ${TYPE} \
	  --metric ${METRIC}

venv: ## Set up virtualenv
	python3 -m venv venv

venv/install: venv requirements.txt ## Install packages in venv
	./venv/bin/pip3 install -r requirements.txt
	touch venv/install

covid-19-data: ## Clone the New York Times COVID-19 data repo
	git clone https://github.com/nytimes/covid-19-data.git covid-19-data

.PHONY: covid-19-data-update
covid-19-data-update: covid-19-data ## Update COVID-19 data repo
	cd covid-19-data && git pull

.PHONY: update-pngs
update-pngs: clean covid-19-data-update pngs

.PHONY: clean
clean: ## Clean up output
	rm -f nyla-*.csv nyla-*.tsv nyla-*.png

.PHONY: clean-all
clean-all: clean ## Clean up everything (virtualenv, downloaded data)
	rm -rf venv covid-19-data

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
