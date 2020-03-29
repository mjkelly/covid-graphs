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
make
```

There are some preloaded invocations of `extract.py`:

```
make ny-la-infections
```

You can set `OUTPUT` to change to tsv (gnuplot-friendly):

```
make ny-la-infections OUTPUT=tsv
```

## Caveats

- I'm not a scientist. Don't trust me.
- Right now it's just tracking all cumulative cases because we that's the
  simplest and I'm tracking mostly the first 2 weeks. That should be fixed
  eventually.
