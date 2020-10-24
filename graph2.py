import pandas as pd
import matplotlib.pyplot as plt
import click
import jinja2

import datetime
import subprocess
import os
import sys

def update_data(data_dir):
    print(f"Updating data in {data_dir}...")
    oldcwd = os.getcwd()
    os.chdir(data_dir)
    print(subprocess.check_output(["git", "pull"]))
    os.chdir(oldcwd)

def show_graphs(data, title, logy, avg_days, output_prefix='out'):    
    figsize = (14, 8)
    if avg_days > 1:
        data = data.copy().rolling(window=avg_days).mean()

    scale_note = "log" if logy else "linear"
    maybe_avg_note = f", {avg_days}-day rolling avg" if avg_days > 1 else ""
    full_title_per_day = f"{title} per day ({scale_note}{maybe_avg_note})"
    full_title_cum = f"{title} cumulative ({scale_note}{maybe_avg_note})"
    
    plot = data.diff().plot(figsize=figsize, rot=45, grid=True, logy=logy, title=full_title_per_day)
    plot_cum = data.plot(figsize=figsize, rot=45, grid=True, logy=logy, title=full_title_cum)
    
    plot.get_figure().savefig(output_prefix + ".png")
    plot_cum.get_figure().savefig(output_prefix + "_cum.png")

def write_html(template, report_dir):
    now = datetime.datetime.now()
    file_path = os.path.join(report_dir, 'index.html')
    with open(template, 'r') as fh:
        template = jinja2.Template(fh.read())
    
    with open(file_path, 'w') as fh:
        fh.write(template.render(time=now))

@click.command()
@click.option("--data-dir", type=str, help="Git checkout for data", default=os.path.join(os.getenv('HOME'), 'git', 'covid-19-data'))
@click.option("--data-file", type=str, help="Input CSV file", default='us-counties.csv')
@click.option("--report-dir", type=str, help="Where to write report", default='report')
@click.option("--template-file", type=str, help="template to use", default='report.tmpl')
@click.option("--debug-days", type=int, help="Show this many days of debug data", default=0)
def render(data_dir, data_file, report_dir, template_file, debug_days):
    full_data_file = os.path.join(data_dir, data_file)
    # === update data from git ===
    update_data(data_dir)

    # === read data ===
    d = pd.read_csv(full_data_file)

    counties = [
        # county, state, population
        # all populations based on Wikipedia 2020 estimates
        ('New York City, New York', 8398748),
        ('Los Angeles, California', 10105518),
        ('Cook, Illinois', 5150233), # Chicago
        ('King, Washington', 753675), # Seattle
        ('San Francisco, California', 881549),
        ('San Diego, California', 3338330),
    ]
    # pivot_table is simpler if we have one combined column with county + state.
    # This matches the format of 'counties' above.
    d.loc[:, 'county_state'] = d['county'] + ', ' + d['state']

    # Filter to only the counties we care about
    d_filtered = d[d.county_state.isin([c[0] for c in counties])]

    cases_tot_df = d_filtered.pivot_table('cases', 'date', 'county_state')
    deaths_tot_df = d_filtered.pivot_table('deaths', 'date', 'county_state')

    cases_by_pop_df = cases_tot_df.copy()
    deaths_by_pop_df = deaths_tot_df.copy()

    for county, pop in counties:
        cases_by_pop_df.loc[:, county] /= (pop / 1000)
        deaths_by_pop_df.loc[:, county] /= (pop / 1000)

    # === show some previews for sanity checking ===
    if debug_days > 0:
        print(f"cases total (last {debug_days}):")
        print(cases_tot_df.tail(debug_days))
        print(f"deaths total (last {debug_days}):")
        print(deaths_tot_df.tail(debug_days))

        print(f"cases per 1000 people (last {debug_days}):")
        print(deaths_by_pop_df.tail(debug_days))
        print(f"deaths per 1000 people (last {debug_days}):")
        print(deaths_by_pop_df.tail(debug_days))

    if not os.path.isdir(report_dir):
        os.mkdir(report_dir)
    show_graphs(cases_tot_df, "Cases total", False, 5, output_prefix=os.path.join(report_dir, 'cases_total'))
    show_graphs(cases_by_pop_df, "Cases per 1000 pop", False, 5, output_prefix=os.path.join(report_dir, 'cases_by_pop'))
    show_graphs(deaths_tot_df, "Deaths total", False, 5, output_prefix=os.path.join(report_dir, 'deaths_total'))
    show_graphs(deaths_by_pop_df, "Deaths per 1000 people", False, 5, output_prefix=os.path.join(report_dir, 'deaths_by_pop'))

    write_html(template_file, report_dir)


if __name__ == '__main__':
    render()