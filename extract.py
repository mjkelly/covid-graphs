#!/usr/bin/python3

import click
import collections
import csv


def get_populations(pop_file):
    # we look for only one population value per county
    locations = {}
    first_line = True
    with open(pop_file, "r") as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            if first_line:
                first_line = False
                continue
            county, population = row
            locations[county] = int(population)
    return locations


def get_cases(case_file, start_date, case_type):
    locations = collections.defaultdict(dict)
    first_line = True
    with open(case_file, "r") as csvfile:
        reader = csv.reader(csvfile, delimiter=",")
        for row in reader:
            if first_line:
                first_line = False
                continue
            if len(row) != 6:
                print(f"Unknown row: {row}")
                continue
            date, county, state, fips, cases, deaths = row
            if date < start_date:
                continue
            if case_type == "infections":
                locations[date][county] = int(cases)
            elif case_type == "deaths":
                locations[date][county] = int(deaths)
    return locations


@click.command()
@click.option(
    "--date", type=str, help="exact date of case data to use (YYYY-mm-dd)")
@click.option(
    "--after-date",
    type=str,
    help="use all case data after this date (YYYY-mm-dd)")
@click.option(
    "--case-file",
    type=str,
    required=True,
    help="CSV file to read case data from")
@click.option(
    "--pop-file",
    type=str,
    required=True,
    help="CSV file to read population data from")
@click.option(
    "--county",
    type=str,
    multiple=True,
    help="County to show. May be repeated.")
@click.option("--header/--no-header", default=True, help="Show output header")
@click.option(
    "--output",
    default="tsv",
    type=click.Choice(["tsv", "csv"]),
    help="Output type")
@click.option(
    "--case-type",
    default="infections",
    type=click.Choice(["infections", "deaths"]),
    help="Type of case to track")
def main(date, after_date, case_file, pop_file, county, header, output,
         case_type):
    pop = get_populations(pop_file)
    cases = get_cases(case_file, after_date, case_type)
    if output == "csv":
        sep = ","
    elif output == "tsv":
        sep = "\t"

    def print_line(data):
        print(sep.join(data))

    if header:
        print_line(["date"] + list(county))
    for d in sorted(cases.keys()):
        fields = [d]
        for c in county:
            if c in cases[d]:
                cases_per_1000 = cases[d][c] / (pop[c] / 1000)
                fields.append("%.6f" % cases_per_1000)
            else:
                print(f"Warning: Couldn't find {d}/{c} in case data")
        print_line(fields)


if __name__ == "__main__":
    main()
