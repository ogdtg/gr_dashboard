# load packages
library(shiny)
library(shinydashboard)
library(dplyr)
library(echarts4r)
library(tidyr)
library(stringr)
library(colorspace)

# Load data

bullets <- TRUE

partycolor <- readRDS("shinydata/partycolor.rds")  %>%
  mutate(abbr_de = str_replace(abbr_de,"Grüne","GRÜNE"))

gemeinden_vec <- sort(readRDS("shinydata/gemeinden_vec.rds"))
year <- 2024
election_year <- year
win_lose <- readRDS("shinydata/win_lose.rds")
pstk_gem <- readRDS("shinydata/pstk_gem.rds")
wb_data <- readRDS("shinydata/wb_data.rds")
listen <- readRDS("shinydata/listen.rds")
panasch_data <- readRDS("shinydata/panasch_data.rds")
attrakt <- readRDS("shinydata/attrakt.rds")
modal_start <- readRDS("shinydata/modal_start.rds")
