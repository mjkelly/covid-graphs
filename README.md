# covid-graphs

Helpers for reading the New York Times' COVID-19 case and death data. There is
a particular focus on adjusting for population. I'm using it to compare rates
between New York and Los Angeles.

- `extract.py` is where all the logic is.
- The Makefile has useful invocations.

## Using this

You have to download the New York Times data first, here:
https://github.com/nytimes/covid-19-data.git

Every other step will refer to `../covid-19-data`, which is this data.

Set up the environment like this (you need python3):
```
make setup
```

To generate graphs of the data, you can run `make pngs`, which will generate a
few .png files. Each file is just the result of an `extract.py` call that
creates a .tsv file, and a `gnuplot` (which references `.tsv` file in a `.plot` file).

If you write more makefile rules to generate .tsv files, and more .plot files
saying how to graph the data, it should be straightforward to create more
graphs.

To update existing png images, `make update-pngs`


## Caveats

- I'm not a scientist. Don't trust me.
- Right now it's just tracking all cumulative cases because we that's the
  simplest and I'm tracking mostly the first 2 weeks. That should be fixed
  eventually.
