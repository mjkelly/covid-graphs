# covid-graphs

Helpers for reading the New York Times' COVID-19 case and death data. There is
a particular focus on adjusting for population. I'm using it to compare rates
between New York and Los Angeles.

This uses every nice python module I know of, because this is partly a way for me to play around with data visualization stuff.

`make help` tells you the various commands you can run via the Makefile.

## Using this

- cd into this git repo
- Set up the environment like this (you need python3): `make setup`
- To generate a report, run `make report`

`make setup` will download dependencies, set up a virtualenv, and download the New York Times COVID-19 data.

`make report` will generate a report, to `./report` by You can change where it goes like this:
```
make report REPORT_DIR="foo"
```
`make report` really just calls `graph2.py`, where all the logic is. `graph2.py` automatically refreshes the data from the covid-19 repo every time it runs.

## Caveats

I'm not a scientist. Don't trust me. This is an example of how to use these tools to slice and dice some publicly available data. I'm not telling you what conclusions to draw!

There are lots of things hardcoded in `graph2.py` -- particularly the cities we report on and their populations.