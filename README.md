# Wahlspiegel 2024

This dashboard illustrates the comparison of election results for municipalities in the Grossratswahlen 2024 in Thurgau.

The dashboard can be accessed [here](https://statistiktg.shinyapps.io/gr_dashboard/).


# Contents

## app.R

The main shiny app. After cloning the repo to your local machine, you can run the app locally by clicking the "Run App" button in the top right corner of RStudio.

## R

### 01_load_data.R

This script loads necessary R packages for data manipulation and visualization. It also sets a switch (bullets) to TRUE for using bullet points or full text.

Loads various datasets from RDS files stored in the "shinydata" folder:
- partycolor: Colors associated with political parties.
- gemeinden_vec: List of municipalities, sorted alphabetically.
- year: Sets the year of the election.
- win_lose: Data for determining winners and losers.
- pstk_gem: Data for the percentage of votes per municipality.
- wb_data: Data for voter turnout.
- listen: Data related to election lists and their respective parties.
- panasch_data: Data for Panaschierstimmen of the election.
- attrakt: Data related to attractiveness of parties.
- modal_start: Data for a modal window display.


### 02_ui_boxes.R

#### Introduction Box
- Offers an introduction to the dashboard for comparing results of municipalities in the Grossratswahl 2024 in Thurgau.
- Allows selection of two municipalities for comparison via the sidebar.
- Contains an action button to start a tutorial.

#### Voter Turnout
- Displays the heading and text related to voter turnout.
- Shows an interactive chart (echarts4rOutput) for visualizing voter turnout over time.
- Provides a legend for interpreting the chart.

#### Party Strength
- Displays the heading and text related to party strength.
- Shows an interactive chart (echarts4rOutput) for visualizing party strength in the Grossratswahlen 2004.
- Provides a legend for interpreting the chart.

#### Change in Party Strength
- Displays the heading and text related to changes in party strength.
- Shows an interactive chart (echarts4rOutput) for visualizing the change in party strength compared to the Grossratswahl 2020.
- Provides a legend for interpreting the chart.

#### Change in Party Strength over Time A
- Displays the heading
- Shows an interactive chart (Area Chart) for visualizing time series data on party strength.

#### Change in Party Strength over Time B
- Displays the heading 
- Shows an interactive chart (Area Chart) for visualizing time series data on party strength.

#### End Box
- Displays contact information for the Statistik Office and the address.
- Provides a mailto link for contacting the office.
- Contains a button to access the GitHub repository of the dashboard.


### 03_wb.R

Prepares data on election turnout (Wahlbeteiligung), creates texts and headings as well as charts using echarts4r.

### 04_pstk.R

Prepares data on party strength (Parteistärke), creates texts and headings as well as charts using echarts4r.

### 041_pstk_history.R

Prepares time series data on party strength and prepares headings as well as charts using echarts4r.

### 05_winlose.R

Prepares data on changes party strength in comparison to the election in 2020 (Veränderung Parteistärke), creates texts and headings as well as charts using echarts4r.

### 06_panasch.R

Prepares data on Panaschierstatistik, creates texts and headings as well as charts using echarts4r.

### 07_render_functions.R

Contains Functions to render text and charts in shiny


## www

Contains all images, gifs, and CSS Stylesheets used in the Dashboard


## shinydata

Contains all data used in the dashboard as RDS files

## create_modals.R

Script to create the modal dialog windows used for tutorials and introduction into the dashboard

## prepare_data.R

Script to prepare all datasets from data.tg.ch. Downloads the data, prepares it, and saves it in the shinydata directory.
All datasets can be accessed via data.tg.ch

The only datasets that are not available on data.tg.ch are:

- partycolor.rds: This dataset is based on the [Swiss party colors by SRF](https://github.com/srfdata/swiss-party-colors). Some Thurgau-specific partycolors were added manually.
- listen.rds: This dataset contains the names of the lists that participated in the Grossratswahl 2024 as well as the parties the lists belong to. This data was manually created.
