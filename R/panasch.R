#' Prepare Data for Panaschierstatistik
#'
#' @param wz_data data containing information on Wahlzettel (sk-stat-12)
#' @param kand_stimmen Data containing Panaschierstimmen
#' @param partycolor Data.frame with partycolor for matching purposes
#' @param listen data.frame with listen/party matching
#' @param year election year
#'
#' @return tibble with panaschierstatistik per gemeinde
#'
prepare_panaschier_data <- function(wz_data,kand_stimmen,partycolor,listen,year){
  # Leere WZ
  total_wz_leer <- wz_data %>%
    filter(jahr ==year) %>%
    distinct(bfs_nr_gemeinde,gemeinde_name,wahlzettel_veraendert_ohne_listenbez)

  kand_stimmen_long <- kand_stimmen %>%
    select(geschaeft:`99_wop`) %>%
    pivot_longer(cols =  matches("\\d\\d\\_"), values_to = "stimmen", names_to = "from_list") %>%
    separate(from_list,sep ="_", into= c("from_nr","from_code")) %>%
    mutate(stimmen = ifelse(is.na(stimmen),0,stimmen)) %>%
    left_join(listen, by = c("from_nr"="ListNr")) %>%
    mutate(to_nr = as.character(liste_id)) %>%
    left_join(listen, by = c("to_nr"="ListNr")) %>%
    group_by(bfs_nr_gemeinde,liste_kand_id,kand_nachname,kand_vorname,partei_code.y,partei_code.x) %>%
    summarise(stimmen = sum(as.numeric(stimmen),na.rm = T))  %>%
    rename(to = "partei_code.y",
           from = "partei_code.x")

  # Parteistimmen
  party_stimmen <- kand_stimmen_long %>%
    group_by(bfs_nr_gemeinde,to,from) %>%
    summarise(stimmen = sum(stimmen, na.rm = T))

  # WZ aufsummieren
  partei_wz_veraendert <- kand_stimmen %>%
    distinct(geschaeft,bfs_nr_gemeinde,liste_id,liste_wahlzettel_veraendert,liste_wahlzettel_unveraendert) %>%
    left_join(listen, by = c("liste_id"="ListNr")) %>%
    group_by(bfs_nr_gemeinde,partei_code) %>%
    summarise_if(is.numeric,sum) %>%
    mutate(wz_total_party = liste_wahlzettel_veraendert+liste_wahlzettel_unveraendert) %>%
    ungroup() %>%
    left_join(total_wz_leer) %>%
    group_by(bfs_nr_gemeinde) %>%
    mutate(wz_total = sum(liste_wahlzettel_veraendert)+sum(liste_wahlzettel_unveraendert)+wahlzettel_veraendert_ohne_listenbez ,
           wz_parteifremd = wz_total - wz_total_party)


  # WZ of zweitlisten

  wz_zweitlisten <-  kand_stimmen %>%
    distinct(geschaeft,bfs_nr_gemeinde,liste_id,liste_wahlzettel_veraendert,liste_wahlzettel_unveraendert) %>%
    left_join(listen, by = c("liste_id"="ListNr")) %>%
    group_by(bfs_nr_gemeinde,partei_code,hauptliste) %>%
    summarise_if(is.numeric,sum) %>%
    mutate(wz_total_party = liste_wahlzettel_veraendert+liste_wahlzettel_unveraendert) %>%
    ungroup() %>%
    left_join(total_wz_leer) %>%
    group_by(bfs_nr_gemeinde) %>%
    mutate(wz_total = sum(liste_wahlzettel_veraendert)+sum(liste_wahlzettel_unveraendert)+wahlzettel_veraendert_ohne_listenbez ,
           wz_parteifremd = wz_total - wz_total_party) %>%
    filter(hauptliste == 0) %>%
    select(bfs_nr_gemeinde,partei_code,wz_total_party) %>%
    rename(wz_total_party_zl = "wz_total_party")

  partei_wz_veraendert_full <- partei_wz_veraendert %>%
    left_join(wz_zweitlisten)

  # Anzahl kandidaten pro Partei

  partei_kand <- kand_stimmen %>%
    group_by(liste_id) %>%
    summarise(kand = n_distinct(liste_kand_id)) %>%
    left_join(listen, by = c("liste_id"="ListNr")) %>%
    group_by(partei_code) %>%
    summarise(num_kand = sum(kand)) %>%
    mutate(non_party_kand = sum(num_kand)- num_kand)

  # Anzahl kandidaten zwiteliste
  partei_kand_zweitliste <- kand_stimmen %>%
    group_by(liste_id) %>%
    summarise(kand = n_distinct(liste_kand_id)) %>%
    left_join(listen, by = c("liste_id"="ListNr")) %>%
    group_by(partei_code,hauptliste) %>%
    summarise(num_kand_zl = sum(kand)) %>%
    mutate(non_party_kand_zl = sum(num_kand_zl)- num_kand_zl) %>%
    filter(hauptliste==0)

  partei_kand_full <- partei_kand %>%
    left_join(partei_kand_zweitliste,"partei_code")

  # Berechnung Panaschierstatistik
  panschierstat <- party_stimmen %>%
    left_join(partei_wz_veraendert_full, by = c("bfs_nr_gemeinde","from"="partei_code")) %>%
    filter(!is.na(from)) %>%
    left_join(partei_kand_full, by = c("to"="partei_code")) %>%
    mutate(panasch = stimmen/(wz_total_party)/num_kand*1000)

  panaschierstat_other <- panschierstat %>%
    select(bfs_nr_gemeinde,gemeinde_name,from,to,stimmen,num_kand,non_party_kand,wz_parteifremd,wz_total,panasch,wz_total_party_zl,num_kand_zl) %>%
    filter(stimmen>0) %>%
    filter(to!=from) %>%
    mutate(party = from %>% tolower %>% str_replace_all(" ","_") %>% str_replace("ü","ue")) %>%
    left_join(partycolor %>%
                select(party,color))

  return(panaschierstat_other)
}

#' Download and Prepare Panaschierdaten per Bezirk from data.tg.ch
#'
#' @param wz_data data containing information on Wahlzettel (sk-stat-12)
#' @param partycolor Data.frame with partycolor for matching purposes
#' @param year election year
#' @param dataset_ids dataset_ids of the respective datasets on data.tg.ch
#'
#' @return tibble
#'
prepare_full_panaschier_data <- function(wz_data,partycolor,year,dataset_ids = paste0(c("sk-stat-"),129:133)){

  full_data <- lapply(dataset_ids, function(id){
    kand_stimmen <- odsAPI::get_dataset(dataset_id = id)

    prepare_panaschier_data(wz_data,kand_stimmen,partycolor,listen,year)


  }) %>% bind_rows()

  return(full_data)



}

#' Prepare panaschierstatistik for sankey
#'
#' @param panasch_data result of prepare_panaschier_data
#' @param gemeinde name of the gemeinde
#'
#' @return tibble
#'
prepare_sankey_panasch_data <- function(panasch_data,gemeinde){
  panasch_data %>%
    filter(gemeinde_name == gemeinde) %>%
    filter(!to %in% c("DSM","MASS-VOLL")) %>%
    filter(!from %in% c("DSM","MASS-VOLL")) %>%
    mutate(to_mod = paste0(to," (Empf.)")) %>%
    ungroup()
}




#' Create data on Attraktivitaet
#'
#' @param panasch_data shinydata/panasch_data.rds
#' @param wz_data shinydata/wz_data (sk-stat-112)
#'
#' @return tibble
#'
prepare_attrakt_data <- function(panasch_data,wz_data){

  candidates_party <- panasch_data %>%
    ungroup() %>%
    # filter(gemeinde_name == gemeinde) %>%
    select(bfs_nr_gemeinde,to,num_kand,non_party_kand,num_kand_zl) %>%
    distinct(bfs_nr_gemeinde,to,.keep_all = T) %>%
    mutate(num_kand = ifelse(!is.na(num_kand_zl),num_kand-num_kand_zl,num_kand),
           non_party_kand  = ifelse(!is.na(num_kand_zl),non_party_kand + num_kand_zl,non_party_kand )) %>%
    select(-num_kand_zl) %>%
    rename(partei = "to")

  wz_party <- panasch_data %>%
    ungroup() %>%
    # filter(gemeinde_name == gemeinde) %>%
    select(bfs_nr_gemeinde,from,wz_parteifremd,wz_total,wz_total_party_zl) %>%
    mutate(wz_total_party = wz_total-wz_parteifremd) %>%
    mutate(wz_total_party = ifelse(!is.na(wz_total_party_zl),wz_total_party-wz_total_party_zl,wz_total_party),
           wz_parteifremd  = ifelse(!is.na(wz_total_party_zl),wz_parteifremd + wz_total_party_zl,wz_parteifremd )) %>%
    select(-wz_total_party_zl) %>%
    rename(partei = "from")

  stimmen_abgegeben <- panasch_data %>%
    # filter(gemeinde_name == gemeinde) %>%
    ungroup() %>%
    group_by(bfs_nr_gemeinde,from) %>%
    summarise(stimmen_abgegeben = sum(stimmen)) %>%
    rename(partei = "from")

  stimmen_erhalten <- panasch_data %>%
    # filter(gemeinde_name == gemeinde) %>%
    ungroup() %>%
    group_by(bfs_nr_gemeinde,to) %>%
    summarise(stimmen_erhalten = sum(stimmen)) %>%
    rename(partei = "to")


  panasch_data %>%
    ungroup() %>%
    select(bfs_nr_gemeinde,gemeinde_name,from,color) %>%
    rename(partei = "from") %>%
    left_join(candidates_party) %>%
    left_join(wz_party) %>%
    left_join(stimmen_abgegeben) %>%
    left_join(stimmen_erhalten) %>%
    distinct(bfs_nr_gemeinde,partei,color,.keep_all = T) %>%
    mutate(attrakt =stimmen_erhalten/num_kand/wz_parteifremd*1000)


}

#' Filter data by gemeinde
#'
#' @param attrakt_data shinydata/attrakt.rds
#' @param gemeinde name of a gemeinde
#'
#' @return tbl
#' @export
#'
#' @examples
prepare_attrakt_data_gemeinden <- function(attrakt_data,gemeinde){
  attrakt_data %>%
    filter(gemeinde_name == gemeinde)
}


#' Create echart sankey diagram for panaschierstatistik
#'
#' @param sankey_panasch_data result of prepare_sankey_panasch_data
#' @param partycolor Data.frame with partycolor for matching purposes
#'
#' @return echart sankey
#'
prepare_sankey_gemeinde <- function(sankey_panasch_data,partycolor){
  base_sankey <- sankey_panasch_data %>%
    mutate(panasch = round(panasch,1)) %>%
    # arrange(panasch) %>%
    ungroup() %>%
    e_charts() %>%
    e_sankey(from, to_mod, panasch) %>%
    # e_tooltip()
    e_tooltip(
      formatter = htmlwidgets::JS(paste0("
      function (params) {
            if (params.dataType === 'edge') { // Customize tooltip for edges
                var nameNodes = params.name.split(' > ');
                var fromParty = '<strong>' + nameNodes[0] + '</strong>';
                var toParty = '<strong>' + nameNodes[1] + '</strong>';
                var panasch = '<strong>' + params.value + '</strong>';
                return 'Von der ' + fromParty + ' fließen ' + panasch + ' Panaschierstimmen<br>pro 1000 Wahzettel der Herkunftspartei und kandidierender<br>Person der Empfängerpartei zur ' + toParty;
            } else { // Customize tooltip for nodes
                return '<strong>' + params.name + '</strong>';
            }
        }")))

  # Color
  for (i in seq_along(base_sankey$x$opts$series[[1]]$data)){
    party_name <- base_sankey$x$opts$series[[1]]$data[[i]]$name
    party_name <- party_name %>% str_remove(" \\(Empf.\\)") %>% tolower %>% str_replace_all(" ","_") %>% str_replace("ü","ue")
    color <- partycolor$color[which(partycolor$party==party_name)]
    base_sankey$x$opts$series[[1]]$data[[i]]$itemStyle$color <- color
    base_sankey$x$opts$series[[1]]$data[[i]]$itemStyle$borderColor <- color
    # base_sankey$x$opts$series[[1]]$data[[i]]$lineStyle$color <- color
    # base_sankey$x$opts$series[[1]]$data[[i]]$itemStyle$borderColor <- color

  }

  # Line Color
  for (i in seq_along(base_sankey$x$opts$series[[1]]$links)){
    party_name <- base_sankey$x$opts$series[[1]]$links[[i]]$source
    party_name <- party_name %>% str_remove(" \\(Empf.\\)") %>% tolower %>% str_replace_all(" ","_") %>% str_replace("ü","ue")
    color <- partycolor$color[which(partycolor$party==party_name)]
    base_sankey$x$opts$series[[1]]$links[[i]]$lineStyle$color <- color
    # base_sankey$x$opts$series[[1]]$links[[i]]$lineStyle$borderColor <- color

  }
  base_sankey$x$opts$series[[1]]$emphasis <- list(focus = "adjacency")

  return(base_sankey)

}


#' Render sankey echart
#'
#' @param panasch_data result of prepare_panaschier_data
#' @param gemeinde name of the gemeinde
#'
#' @return rendered sankey
#'
render_panasch_chart <- function(sankey_panasch_data,partycolor){

  renderEcharts4r({
    prepare_sankey_gemeinde(sankey_panasch_data,partycolor)
  })
}




generate_text_panasch_gemeinde <- function(sankey_panasch_data,attrakt_data , gemeinde){

  sankey_panasch_data <- sankey_panasch_data %>%
    mutate(to = str_replace_all(to,"GRÜNE$","GRÜNEN")) %>%
    mutate(from = str_replace_all(from,"GRÜNE$","GRÜNEN"))


  attrakt_gemeinden <- prepare_attrakt_data_gemeinden(attrakt_data,gemeinde) %>%
    arrange(desc(attrakt)) %>%
    mutate(partei = str_replace_all(partei,"GRÜNE$","GRÜNEN"))


  largest <- sankey_panasch_data %>%
    filter(panasch == max(panasch))

  smallest <- sankey_panasch_data %>%
    filter(panasch == min(panasch))

  der_to <- "der"
  der_from <- "der"
  der_from2 <- "der"
  war_gruen <- "war"
  die_win <- "die"
  schnitt <- "schnitt"
  die_last <- "die"
  erhielt <- "erhielt"

  if (largest$to %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    der_to <- ""


  }
  if (largest$to %in% c("GRÜNEN")){
    der_to <- "den"
  }

  if (largest$from %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    der_from <- ""
    der_from2 <- "von"

  }
  if (largest$from %in% c("GRÜNEN")){
    der_from <- "den"
    erhielt <- "erhielten"
  }

  if (attrakt_gemeinden$partei[1]=="GRÜNEN"){
    war_gruen <- "waren"
  }
  if (attrakt_gemeinden$partei[nrow(attrakt_gemeinden)]=="GRÜNEN"){
    schnitt <- "schnitten"
  }

  if (attrakt_gemeinden$partei[1]%in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_win <- ""
  }
  if (attrakt_gemeinden$partei[nrow(attrakt_gemeinden)]%in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_last <- ""
  }


    panaschier_text <- glue::glue("In {gemeinde} {war_gruen} {die_win} {attrakt_gemeinden$partei[1]} die insgesamt attraktivste Partei bei den Grossratswahlen 2024. Insgesamt {erhielt} {die_win} {attrakt_gemeinden$partei[1]} je kandidierender Person auf 1000 parteifremden Wahlzetteln {attrakt_gemeinden$attrakt[1] %>% round(1)} Panaschierstimme.
                                Am schwächsten {schnitt} bei der Attraktivität  {die_last} {attrakt_gemeinden$partei[nrow(attrakt_gemeinden)]} ab. Pro kandiderender Person erhielt die Partei nur {attrakt_gemeinden$attrakt[nrow(attrakt_gemeinden)] %>% round(1)} Panaschierstimmen auf 1000 parteifremden Wahlzetteln.
                                Der stärkste Panaschierfluss war zwischen {der_from} {largest$from} und {der_to} {largest$to} zu beobachten. Insgesamt flossen hier {largest$stimmen} Stimmen.
                                Pro 1000 Wahlzetteln {der_from2} {largest$from} und kandiderender Person auf Seiten von {der_to} {largest$to}, flossen somit {round(largest$panasch,1)} Stimmen von {der_from} {largest$from} zu {der_to} {largest$to}")


  return(panaschier_text)


}



formulierungen_panasch_title <- c(
  "Partei X als attraktivste Partei in Gemeinde A.",
  "Partei X erzielte den höchsten Zustrom von Panaschierstimmen in Gemeinde A",
  "Gemeinde A bevorzugte Partei X, wenn es um Panaschierstimmen ging",
  "Partei X genoss den verhältnismässig größten Zuspruch an Panaschierstimmen in Gemeinde A",
  "Gemeinde A präferierte Partei X in Bezug auf Panaschierstimmen",
  "Partei X erhielt den größten Anteil an Panaschierstimmen in Gemeinde A",
  "Partei X als attraktivste Wahl für Panaschierstimmen in Gemeinde A",
  "In Gemeinde A entschieden sich die Wähler vermehrt für Partei X bei Panaschierstimmen",
  "Partei X als führende Kraft bei der Gewinnung von Panaschierstimmen in Gemeinde A"
)

generate_title_panasch <- function(attrakt_data, gemeinde) {

  attrakt_gemeinden <- prepare_attrakt_data_gemeinden(attrakt_data,gemeinde) %>%
    arrange(desc(attrakt)) %>%
    mutate(partei = str_replace_all(partei,"GRÜNE$","GRÜNEN"))

  partei1 <- attrakt_gemeinden$partei[1]



  if (!partei1 %in% c("Die Mitte","MASS-VOLL","AUFTG")){
    partei1 <- paste0("die ",partei1)
  }


  auswahl <- sample(formulierungen_panasch_title, 1)
  aussage <- gsub("Partei X", partei1, auswahl)
  aussage <- gsub("Gemeinde A", gemeinde, aussage)



  start_char <- stringr::str_extract(aussage,"^.")
  aussage <- stringr::str_replace(aussage,"^.",toupper(start_char))
  return(aussage)
}
