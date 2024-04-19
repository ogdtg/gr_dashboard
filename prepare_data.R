# Create Data

# Download data from data.tg.ch and prepare it for dashboard usage

# Check if the package is installed
if (!requireNamespace("odsAPI", quietly = TRUE)) {
  # If not installed, install the package
  install_github("ogdtg/odsAPI")
}
library(tidyverse)
library(odsAPI)
source("R/06_panasch.R")

odsAPI::set_domain("kantonthurgau.opendatasoft.com")
election_year <- 2024

# Data from SRF
partycolor <- readRDS("shinydata/partycolor.rds") %>%
  mutate(abbr_de = str_replace(abbr_de,"Grüne","GRÜNE"))


# Manual matching lit -> party
listen <- readRDS("shinydata/listen.rds")

# Parteistaerke
pstk_gem <- get_dataset(dataset_id = "sk-stat-9")

# Gemeinden
gemeinden_vec <- pstk_gem %>%
  pull(gemeinde_name) %>%
  unique() %>%
  sort()


saveRDS(gemeinden_vec,"shinydata/gemeinden_vec.rds")
saveRDS(pstk_gem,"shinydata/pstk_gem.rds")



# Veraenderung Parteistaerke

win_lose <- pstk_gem %>%
  mutate(category = case_when(
    wahljahr %in% c(election_year,election_year-4)~paste0(gemeinde_name,"_",election_year),
    TRUE~NA
  )) %>%
  filter(!is.na(category)) %>%
  group_by(category) %>%
  arrange(desc(wahljahr)) %>%
  mutate_at(vars(svp:uebrige),~ifelse(is.na(.x),0,.x)) %>%
  mutate_at(vars(svp:uebrige),~c(diff(.x)*-1,NA)) %>%
  filter(wahljahr==election_year) %>%
  pivot_longer(cols = svp:uebrige,values_to = "share",names_to = "party") %>%
  mutate(party = stringr::str_replace(party,"cvp","die mitte")) %>%
  left_join(partycolor %>%
              select(party,abbr_de,name_de,color),"party") %>%
  ungroup()

saveRDS(win_lose,"shinydata/win_lose.rds")


# Wahlbeteiligung

wb_data <- get_dataset(dataset_id="sk-stat-11")

saveRDS(wb_data,"shinydata/wb_data.rds")


# Wahlzettel

wz_data <- get_dataset(dataset_id = "sk-stat-12")

saveRDS(wz_data,"shinydata/wz_data.rds")

# Panaschierstatistik

panasch_data <- prepare_full_panaschier_data(wz_data = wz_data,
                                             partycolor=partycolor,
                                             year=election_year,
                                             dataset_ids = paste0(c("sk-stat-"),129:133))


saveRDS(panasch_data,"shinydata/panasch_data.rds")


# Attraktivitaet Parteien

attrakt_data <- prepare_attrakt_data(panasch_data = panasch_data,
                     wz_data = wz_data)

saveRDS(attrakt_data,"shinydata/attrakt.rds")

