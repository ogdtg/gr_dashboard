# Wahlkompass 2024

This dashboard visualizes the comparison of election results for Gemeinden at the Grossratswahlen 2024 in Thurgau.

The dashboard can be accessed [here]().


# Content

## app.R

The actual shiny app. After cloning the repo to your local machine you should be able to run the app locally by clicking the Run App button in the top right corner of RStudio.

## R

### 01_load_data.R

Loads necessary R packages for data manipulation and visualization.
Sets a switch (bullets) to TRUE for using bullet points or full text.

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
- Provides an introduction to the dashboard for comparing results of Gemeinden at the Grossratswahl 2024 in Thurgau.
- Allows selection of two Gemeinden for comparison via the sidebar.
- Contains an action button to start a tutorial.

#### Wahlbeteiligung (Voter Turnout)
- Displays the heading and text related to voter turnout.
- Shows an interactive chart (echarts4rOutput) for visualizing voter turnout over time.
- Provides a legend for interpreting the chart.

#### Parteistaerke (Party Strength)
- Displays the heading and text related to party strength.
- Shows an interactive chart (echarts4rOutput) for visualizing party strength in the Grossratswahlen 2004.
- Provides a legend for interpreting the chart.

#### Veränderung Parteistaerke (Change in Party Strength)
- Displays the heading and text related to changes in party strength.
- Shows an interactive chart (echarts4rOutput) for visualizing the change in party strength compared to the Grossratswahl 2020.
- Provides a legend for interpreting the chart.

#### Panaschierstatistik A (Panasch Statistics A)
- Displays the heading and text related to Panasch Statistics for Gemeinde A.
- Shows an interactive chart (echarts4rOutput) for visualizing Panasch Statistics.

#### Panaschierstatistik B (Panasch Statistics B)
- Displays the heading and text related to Panasch Statistics for Gemeinde B.
- Shows an interactive chart (echarts4rOutput) for visualizing Panasch Statistics.

#### Volle Panaschierstatistik (Full Panasch Statistics)
- Provides an explanation of Panasch Statistics and its calculation.
- Contains links to resources for understanding the concept and accessing the datasets used.
- Displays visualizations of Panasch Statistics for both Gemeinde A and Gemeinde B.
- Provides a legend for interpreting the visualizations.

#### End Box
- Displays contact information for the Statistik Office and the address.
- Provides a mailto link for contacting the office.
- Contains a button to access the GitHub repository of the dashboard.


### 03_wb.R

Prepares data on election turnout (Wahlbeteiligung), creates texts and headings as well as charts using echarts4r.

### 04_pstk.R

Prepares data on party strength (Parteistärke), creates texts and headings as well as charts using echarts4r.

### 05_winlose.R

Prepares data on changes party strength in comparision to the election in 2020 (Veränderung Parteistärke), creates texts and headings as well as charts using echarts4r.

### 06_panasch.R

Prepares data on Panaschierstatistik, creates texts and headings as well as charts using echarts4r.

### 07_render_functions.R

Contains Functions to render text and charts in shiny


## www

Contains all images, gifs and also CSS Stylesheets that are used in the Dashboard


## shinydata

Contains all data used in the dashboard as rds files

## create_modals.R

Script to create th modal dialog windows that are used to create the tutorial and the introduction into the dashboard

## prepare_data.R

Script to prepare all datasets from data.tg.ch. Downloads the data, prepares it and saves it in the shinydata directory.
All datasets can be accessed via data.tg.ch

The only datasets tha are not available on data.tg.ch is 

- partycolor.rds: This dataset is based on the [Swiss party colors by SRF](https://github.com/srfdata/swiss-party-colors). Some Thurgau specific partycolors were added manually.
- listen.rds: This datasets contains the name of the lists that were taking part at the Grossratswahl 2024 as well as the parties the lists belong to. This data was manually created.
