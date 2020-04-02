OUTPUT := csv
TYPE := infections
REPORT_DIR := ~/public_html/covid/

.PHONY: setup
setup: venv venv/install covid-19-data ## Set up environment

nyla-i.csv: venv/install ## Output data
	make --quiet ny-la OUTPUT=csv TYPE=infections > $@.tmp
	mv $@.tmp $@
nyla-d.csv: venv/install ## Output data
	make --quiet ny-la OUTPUT=csv TYPE=deaths > $@.tmp
	mv $@.tmp $@

.PHONY: csvs
csvs: nyla-i.csv nyla-d.csv

.PHONY: pngs
pngs: csvs # generate PNG files, matplotlib version
	./venv/bin/python3 graph.py --infile nyla-i.csv --outfile nyla-i-linear.png --ylabel "Infections per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-i.csv --outfile nyla-i-log.png --ylabel "Infections per 1000 people" --ylog 
	./venv/bin/python3 graph.py --infile nyla-d.csv --outfile nyla-d-linear.png --ylabel "Deaths per 1000 people"
	./venv/bin/python3 graph.py --infile nyla-d.csv --outfile nyla-d-log.png --ylabel "Deaths per 1000 people" --ylog 


.PHONY: report
report: pngs
	cp *.png report.html ${REPORT_DIR}
	echo "<hr>Generated: $$(date)" >> ${REPORT_DIR}/report.html

.PHONY: ny-la
ny-la: setup ## Output data for NY and LA
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

.PHONY: covid-19-data-update
covid-19-data-update: covid-19-data ## Update COVID-19 data repo
	cd covid-19-data && git pull

.PHONY: update-pngs
update-pngs: clean covid-19-data-update pngs

.PHONY: clean
clean: ## Clean up output
	rm -f nyla-i.* nyla-d.* nyla-*.png

.PHONY: clean-all
clean-all: clean ## Clean up everything (virtualenv, downloaded data)
	rm -rf venv covid-19-data

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ----------
# These aren't used by default. They're the old gnuplot way of generating
# graphs.
# ----------
.PHONY: tsvs
tsvs: nyla-i.tsv nyla-d.tsv

.PHONY: gnupngs
gnupngs: tsvs nyla-i-linear.png nyla-i-log.png nyla-d-linear.png nyla-d-log.png # generate PNG files, gnuplot version

%.png: %.plot
	gnuplot < $<

nyla-i.tsv: venv/install ## Output data
	make --quiet ny-la OUTPUT=tsv TYPE=infections > $@.tmp
	mv $@.tmp $@
nyla-d.tsv: venv/install ## Output data
	make --quiet ny-la OUTPUT=tsv TYPE=deaths > $@.tmp
	mv $@.tmp $@

.PHONY: update-gnupngs
update-gnupngs: clean covid-19-data-update gnupngs
