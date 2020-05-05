#!/usr/bin/python3

import click
import collections
import csv
import datetime
import matplotlib.pyplot as plt
import matplotlib.dates
import matplotlib.ticker
import numpy as np


def get_data(pop_file):
    # indices to county names
    county_map = {}
    output = {}
    first_line = True
    with open(pop_file, "r") as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            if first_line:
                for i, county in enumerate(row[1:]):
                    county_map[i] = county
                    output[county] = {}
                first_line = False
                continue
            date = datetime.datetime.strptime(row[0], "%Y-%m-%d").date()
            for i, value in enumerate(row[1:]):
                output[county_map[i]][date] = float(value)
    return output


@click.command()
@click.option("--infile", type=str, help="Input CSV file", required=True)
@click.option("--outfile", type=str, help="Input PNG file", required=True)
@click.option("--title", type=str, help="Title of graph", default=None)
@click.option("--ylabel", type=str, help="Y label for graph", required=True)
@click.option("--ylog", type=str, is_flag=True, help="Make Y axis log scale")
def main(infile, outfile, title, ylabel, ylog):
    data = get_data(infile)
    formatter = matplotlib.dates.DateFormatter("%m/%d")
    loc = matplotlib.dates.DayLocator()
    size_mult = 1.5
    fig, ax = plt.subplots(figsize=[6.4*size_mult, 4.8*size_mult])

    if ylog:
        plt.yscale("log")
    for county, county_data in data.items():
        dates = sorted(county_data.keys())
        one_day_delta = datetime.timedelta(days=1)
        x_values = matplotlib.dates.drange(dates[0], dates[-1] + one_day_delta,
                                           one_day_delta)
        y_values = np.array(
            [county_data[k] for k in sorted(county_data.keys())])
        plt.plot_date(
            x_values, y_values, linestyle="-", marker=".", label=county)
    ax.grid(True)
    ax.yaxis.set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax.legend(loc="upper left")
    if title is not None:
        ax.set_title(title, fontweight="bold", pad=20)
    ax.xaxis.set_major_locator(loc)
    ax.xaxis.set_major_formatter(formatter)
    ax.xaxis.set_tick_params(rotation=45, labelsize=8)
    for label in ax.xaxis.get_ticklabels()[::2]:
        label.set_visible(False)
    ax.set_ylabel(ylabel)
    plt.savefig(outfile)


if __name__ == "__main__":
    main()
