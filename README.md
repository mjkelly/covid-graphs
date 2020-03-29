# covid-graphs

Helpers for reading the New York Times' COVID-19 case and death data. There is
a particular focus on adjusting for population.

## Using this

You have to download the New York Times data first, here:
https://github.com/nytimes/covid-19-data.git

Every other step will refer to `../covid-19-data`, which is this data.

Set up the environment like this (you need python3):
```
make
```

Then generate data like this:
```
./venv/bin/python3 extract.py --pop-file population.csv \
  --case-file ../covid-19-data/us-counties.csv\
  --after-date 2020-03-13 \
  --county={"New York City","Los Angeles"} \
  --output csv \
  --case-type deaths
```

`--output tsv` gives more gnuplot-friendly output:
```
./venv/bin/python3 extract.py --pop-file population.csv \
  --case-file ../covid-19-data/us-counties.csv\
  --after-date 2020-03-13 \
  --county={"New York City","Los Angeles"} \
  --output tsv \
  --case-type deaths > deaths.tsv
```

## Caveats

* I'm not a scientist. Don't trust me.
* Right now it's just tracking all cumulative cases because we that's the
  simplest and I'm tracking mostly the first 2 weeks. That should be fixed
  eventually.
