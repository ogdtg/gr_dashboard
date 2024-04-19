# load packages
library(dplyr)
library(echarts4r)
library(tidyr)
library(stringr)
library(colorspace)

#' Prepare Parteistaerke data
#'
#' @param data shinydata/pstk_gem.rds
#' @param selected_gemeinden vector of exactly two gemeinden
#' @param year election year
#'
#' @return tibble
prepare_pstk_data <- function(data,selected_gemeinden,year){
  data %>%
    ungroup() %>%
    filter(gemeinde_name %in% selected_gemeinden) %>%
    filter(wahljahr==year) %>%
    pivot_longer(cols = svp:uebrige,values_to = "share",names_to = "party") %>%
    mutate(party = stringr::str_replace(party,"cvp","die mitte")) %>%
    left_join(partycolor %>%
                select(party,abbr_de,name_de,color),"party") %>%
    mutate(color = ifelse(gemeinde_name==selected_gemeinden[1],adjust_transparency(color,0.5),color)) %>%
    group_by(party) %>%
    mutate(test = sum(is.na(share))) %>%
    ungroup() %>%
    filter(test<2) %>%
    group_by(gemeinde_name) %>%
    mutate(gemeinde_name = factor(gemeinde_name,levels=selected_gemeinden)) %>%
    arrange(gemeinde_name)
}







formulierungen_pstk_title_dif <- c(
  # "In Gemeinde A setzt man auf Partei X, in Gemeinde B herrscht Partei Y",
  # "Partei X dominiert Gemeinde A, während Partei Y in Gemeinde B führt",
  # "Partei X ist in Gemeinde A vorne, während Partei Y in Gemeinde B die Mehrheit hat",
  "Gemeinde A favorisiert Partei X, während in Gemeinde B Partei Y die Oberhand hat",
  # "Partei X führt in Gemeinde A, während Partei Y in Gemeinde B die Spitze hält",
  "In Gemeinde A hat Partei X die Nase vorn, in Gemeinde B ist es Partei Y",
  "Partei X gewinnt in Gemeinde A, während in Gemeinde B Partei Y die stärkste Kraft ist"
  # "Gemeinde A unterstützt Partei X, in Gemeinde B setzt man auf Partei Y",
  # "Partei X regiert in Gemeinde A, während Partei Y in Gemeinde B die Szene beherrscht",
  # "Gemeinde A schwört auf Partei X, in Gemeinde B hat Partei Y die Mehrheit"
)

formulierungen_pstk_title_same <- c(
  "Partei X dominiert in Gemeinde A und Gemeinde B.",
  "Gemeinde A und Gemeinde B setzen auf Partei X.",
  "Partei X ist die Nummer eins in Gemeinde A und Gemeinde B",
  "In Gemeinde A und Gemeinde B liegt Partei X ganz vorne",
  "Partei X triumphiert sowohl in Gemeinde A als auch in Gemeinde B",
  "Die Wähler in Gemeinde A und Gemeinde B vertrauen auf Partei X",
  "Partei X führt in Gemeinde A und Gemeinde B"
  # "In Gemeinde A und Gemeinde B ist Partei X die klare Gewinnerin",
  # "Partei X thront an der Spitze von Gemeinde A und Gemeinde B"#,
  # "Gemeinde A und Gemeinde B stehen eindeutig hinter Partei X."
)

#' Generate title for pstk chart
#'
#' @param pstk_data result of prepare_pstk_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return text
#' @export
#'
#' @examples
generate_title_pstk <- function(pstk_data, selected_gemeinden) {

  strongest_party_data <- pstk_data %>%
    group_by(gemeinde_name) %>%
    arrange(desc(share)) %>%
    slice(1) %>%
    ungroup() %>%
    arrange(gemeinde_name)

  partei1 <- strongest_party_data$abbr_de[1]
  partei2 <- strongest_party_data$abbr_de[2]
  gemeinde1 <- selected_gemeinden[1]
  gemeinde2 <- selected_gemeinden[2]


  if (!partei1 %in% c("Die Mitte","MASS-VOLL","AUFTG")){
    partei1 <- paste0("die ",partei1)
  }

  if (!partei2 %in% c("Die Mitte","MASS-VOLL","AUFTG")){
    partei2 <- paste0("die ",partei2)
  }

  if (partei1 == partei2) {
    auswahl <- sample(formulierungen_pstk_title_same, 1)
    aussage <- gsub("Partei X", partei1, auswahl)
    aussage <- gsub("Gemeinde A", gemeinde1, aussage)
    aussage <- gsub("Gemeinde B", gemeinde2, aussage)
  } else if (partei1 != partei2) {
    auswahl <- sample(formulierungen_pstk_title_dif, 1)
    aussage <- gsub("Partei X", partei1, auswahl)
    aussage <- gsub("Partei Y", partei2, aussage)
    aussage <- gsub("Gemeinde A", gemeinde1, aussage)
    aussage <- gsub("Gemeinde B", gemeinde2, aussage)
  } else {
    return("Ungültige Möglichkeit. Bitte wählen Sie entweder 1 oder 2.")
  }

  start_char <- stringr::str_extract(aussage,"^.")
  aussage <- stringr::str_replace(aussage,"^.",toupper(start_char))%>%
    str_replace_all("(?<!\\A|\\.\\s)Die Mitte", "die Mitte")
  return(aussage)
}




#' Generate text for pstk chart
#'
#' @param pstk_data result of prepare_pstk_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return text
#' @export
#'
#' @examples
generate_text_pstk <- function(pstk_data, selected_gemeinden) {

  strongest_party_data <- pstk_data %>%
    group_by(gemeinde_name) %>%
    arrange(desc(share)) %>%
    slice(1:2) %>%
    ungroup() %>%
    arrange(gemeinde_name) %>%
    mutate(share = round(share,1)) %>%
    mutate(abbr_de = str_replace(abbr_de,"Grüne$","Grünen"))

  gemeinde_a <- selected_gemeinden[1]
  gemeinde_b <- selected_gemeinden[2]


  partei_a1 <- strongest_party_data$abbr_de[1]
  partei_a2 <- strongest_party_data$abbr_de[2]
  partei_b1 <- strongest_party_data$abbr_de[3]
  partei_b2 <- strongest_party_data$abbr_de[4]


  anteil_a_a1 <- strongest_party_data$share[1]
  anteil_a_a2 <- strongest_party_data$share[2]
  anteil_b_b1 <- strongest_party_data$share[3]
  anteil_b_b2 <- strongest_party_data$share[4]


  die_a1 <- "die"
  die_a2 <- "die"
  die_b1 <- "die"
  die_b2 <- "die"
  Die_a2 <- "Die"
  der_a1 <-"der"
  der_a2 <-"der"
  der_b1 <-"der"
  der_b2 <-"der"

  if (partei_a1 %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_a1 <- ""
    der_a1 <- ""

    if (partei_a1 %in% c("Grünen")){
      der_a1 <- "den"
    }
  }

  if (partei_a2 %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_a2 <- ""
    der_a2 <- ""
    Die_a2 <- ""
    if (partei_a2 %in% c("Grünen")){
      der_a1 <- "den"
    }

  }

  if (partei_b1 %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_b1 <- ""
    der_b1 <- ""
    if (partei_b1 %in% c("Grünen")){
      der_b1 <- "den"
    }

  }

  if (partei_b2 %in% c("AUFTG","Die Mitte","MASS-VOLL")){
    die_b2 <- ""
    der_b2 <- ""

    if (partei_b2 %in% c("Grünen")){
      der_b2 <- "den"
    }
  }

  if (partei_a1==partei_b1 & partei_a2 == partei_b2){
    text <- glue::glue("Die Grossratswahlen 2024 ergaben, dass {die_a1} {partei_a1} sowohl in {gemeinde_a} als auch in {gemeinde_b} die stärkste politische Kraft war.
                       In {gemeinde_a} konnte {die_a1} {partei_a1} {anteil_a_a1}% der Stimmen für sich geltend machen, in  {gemeinde_b} {anteil_b_b1}%.
                       Auch auf Rang zwei findet sich in beiden Gemeinden die gleiche Partei. {Die_a2} {partei_a2} erreichte in {gemeinde_a} {anteil_a_a2}% und in {gemeinde_b} {anteil_b_b2}% der Stimmen.
                       In {gemeinde_a} lag {die_a1} {partei_a1} mit {anteil_a_a1-anteil_a_a2} Prozentpunkten vor {der_a2} {partei_a2}, in {gemeinde_b} waren es {anteil_b_b1-anteil_b_b2}"
    )
  }
  if (partei_a1==partei_b1 & partei_a2 != partei_b2){
    text <- glue::glue("Bei den Grossratswahlen 2024 war {die_a1} {partei_a1} sowohl in {gemeinde_a} als auch in {gemeinde_b} die stärkste politische Kraft war.
                      In {gemeinde_a} erreichte {die_a1} {partei_a1} einen Anteil von {anteil_a_a1}% der Stimmen, während es in {gemeinde_b} {anteil_b_b1}% waren.
                      Jedoch gab es Unterschiede bei der zweitstärksten Partei. In {gemeinde_a} konnte {die_a2} {partei_a2} mit {anteil_a_a2}% der Stimmen den zweiten Platz erreichen.
                      Sie lag damit {anteil_a_a1-anteil_a_a2} Prozentpunkte hinter {der_a1} {partei_a1}. In {gemeinde_b} erreichte {die_b2} {partei_b2} mit {anteil_b_b2}% den zweiten Rang und lag damit {anteil_b_b1-anteil_b_b2} Prozentpunkte hinter {der_b1} {partei_b1}."
    )
  }

  if (partei_a1!=partei_b1 & partei_a2 == partei_b2){
    text <- glue::glue("Die Grossratswahlen 2024 zeigten in {gemeinde_a} die grösste Unterstützung für {die_a1} {partei_a1}, die {anteil_a_a1}% der Stimmen erhielt und somit den ersten Platz einnahm.
                      Im Gegensatz dazu führte in {gemeinde_b} {die_b1} {partei_b1} mit {anteil_b_b1}% der Stimmen.
                      In beiden Gemeinden landete {die_a2} {partei_a2} auf dem zweiten Platz, wobei sie in {gemeinde_a} {anteil_a_a2}% der Stimmen erhielt und damit {anteil_a_a1-anteil_a_a2} Prozentpunkte hinter {der_a2} {partei_a1} lag.
                      In {gemeinde_b} erreichte {die_a2} {partei_a2} {anteil_b_b2}% der Stimmen erhielt und lag damit {anteil_b_b1-anteil_b_b2}. Prozentpunkte hinter {der_b1} {partei_b1}."
    )

  }

  if (partei_a1!=partei_b1 & partei_a2 != partei_b2){
    text <- glue:: glue("In {gemeinde_a} zeigte sich, dass {die_a1} {partei_a1} die stärkste politische Kraft war, wobei sie {anteil_a_a1}% der Stimmen erhielt und somit {die_a2} {partei_a2} ({anteil_a_a2}%) auf Rang zwei verwies.
                      Der Vorsprung lag somit bei {anteil_a_a1-anteil_a_a2} Prozentpunkten.
                      In {gemeinde_b} hingegen war Partei {die_b1} {partei_b1} die dominierende Kraft, wobei sie {anteil_b_b1}% der Stimmen erhielt und mit {anteil_b_b1-anteil_b_b2}  vor {der_b2} {partei_b2} ({anteil_b_b2}%) führte."
    )


  }
  return(text %>%
           str_replace_all("(?<!\\A|\\.\\s)Die Mitte", "die Mitte")  )
}




#' Render pstk echart (bar chart)
#'
#' @param pstk_data result of prepare_pstk_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return rendered echart
#'
render_pstk_chart <- function(pstk_data,selected_gemeinden){
  renderEcharts4r({
    pstk_chart <- pstk_data %>%
      mutate(share = round(share,1)) %>%
      e_charts(abbr_de) %>%
      e_bar(share) %>%
      e_color(color = c("#0000004D","black")) %>%
      e_add_nested("itemStyle", color) %>%
      e_tooltip(
        formatter = htmlwidgets::JS(paste0("
      function(params){
        return('<strong>' +  params.value[0] +
                '</strong><br />Gemeinde: ' + params.seriesName +
                '<br />Parteistärke: ' + params.value[1] + ' %')
                }"))) %>%
      e_x_axis(axisLabel = list(rotate = 45)) %>%
      e_axis_labels(
        x = "",
        y = "Parteistaerke in %"
      )
    customize_echart(pstk_chart)



  })
}

prepare_ptsk_list <- function(pstk_data, selected_gemeinden){

  strongest_party_data <- pstk_data %>%
    group_by(gemeinde_name) %>%
    arrange(desc(share)) %>%
    slice(1:2) %>%
    ungroup() %>%
    mutate(gemeinde_name = factor(gemeinde_name,levels=selected_gemeinden)) %>%
    arrange(gemeinde_name) %>%
    mutate(share = round(share,1))

  partei_a1 <- strongest_party_data$abbr_de[1]
  partei_a2 <- strongest_party_data$abbr_de[2]
  partei_b1 <- strongest_party_data$abbr_de[3]
  partei_b2 <- strongest_party_data$abbr_de[4]


  anteil_a1 <- strongest_party_data$share[1]
  anteil_a2 <- strongest_party_data$share[2]
  anteil_b1 <- strongest_party_data$share[3]
  anteil_b2 <- strongest_party_data$share[4]

  result <- list(partei_a1,anteil_a1,partei_a2,anteil_a2,
                 partei_b1,anteil_b1,partei_b2,anteil_b2)

  name_results <- expand.grid(c("partei_","anteil_"),c("1_","2_"),selected_gemeinden)

  combination_strings <- apply(name_results, 1, function(x) paste0(x, collapse = ""))

  names(result) <- combination_strings
  return(result)

}

generate_bullets_pstk <- function(pstk_data , selected_gemeinden){



  wl_list <- prepare_ptsk_list(pstk_data , selected_gemeinden)



  bullets <- lapply(selected_gemeinden,function(gemeinde){
    glue::glue("
      <br>
      <b>{gemeinde}</b>
      <ul>
        <li><i>Stärkste Partei:</i> <b>{wl_list[[paste0('partei_1_',gemeinde)]]}</b> ({wl_list[[paste0('anteil_1_',gemeinde)]]} %)</li>
        <li><i>Zweitstärkste Partei:</i> <b>{wl_list[[paste0('partei_2_',gemeinde)]]}</b> ({wl_list[[paste0('anteil_2_',gemeinde)]]} %)</li>
      </ul>
    ")
  })

  bullet_list <- paste0(bullets,collapse = "")


  HTML(bullet_list)

}
