# load packages
library(dplyr)
library(echarts4r)
library(tidyr)
library(stringr)
library(colorspace)

# Functions

#' Customize Echart to add correct Axis Title
#'
#' @param echart echart object
#'
#' @return
#' @export
#'
#' @examples
customize_echart <- function(echart){


  echart$x$opts$yAxis[[1]]$nameLocation <- "middle"
  echart$x$opts$yAxis[[1]]$nameGap <- 50
  echart$x$opts$yAxis[[1]]$nameTextStyle  <- list(color = "black",fontSize = 14)
  return(echart)

}

# Set Arial as default font for echarts
e_common(
  font_family = "Arial",
  theme = NULL
)
#' Prepare winlose data for further processing
#'
#' @param data full win_lose dataset
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return processed data as tibble
#'
prepare_winlose_data <- function(data,selected_gemeinden){
  data %>%
    filter(gemeinde_name %in% selected_gemeinden) %>%
    group_by(party) %>%
    filter(sum(abs(share))>0) %>%
    # mutate(color = ifelse(gemeinde_name == selected_gemeinden[1], adjust_transparency(color, 0.5), color)) %>%
    group_by(gemeinde_name) %>%
    arrange(gemeinde_name) %>%
    filter(!party %in% c("bdp", "uebrige")) %>%
    mutate(share = round(share, 1)) %>%
    mutate(borderType = "solid") %>%
    mutate(borderWidth = 1) %>%
    mutate(borderColor = "black") %>%
    mutate(borderColor = ifelse(gemeinde_name == selected_gemeinden[1], "black", "black")) %>%
    mutate(#shadowColor = ifelse(gemeinde_name == selected_gemeinden[1], "black", "grey"),
      # shadowBlur = 2,
      opacity = ifelse(gemeinde_name == selected_gemeinden[1], .5, 1))
}


#' Render win_lose echart (bar chart)
#'
#' @param win_lose_data result of prepare_winlose_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#' @param year electiopn year
#'
#' @return rendered echart
#'
render_winlose_chart <- function(win_lose_data,selected_gemeinden,year){
  renderEcharts4r({
    winlose_chart <- win_lose_data %>%
      e_charts(abbr_de) %>%
      e_bar(share,bind = gemeinde_name) %>%
      e_color(color = c("#0000004D","black")) %>%
      # e_color(color = echart_winlose_data$c1) %>%
      e_add_nested("itemStyle",
                   color,
                   #borderType,
                   #borderWidth,
                   #borderColor,

                   # shadowColor,
                   # shadowBlur,
                   opacity
      ) %>%
      # e_add_nested("itemStyle", borderType) %>%

      e_tooltip(
        formatter = htmlwidgets::JS(paste0("
      function(params){
        return('<strong>' +  params.value[0] +
                '</strong><br />Gemeinde: ' + params.name +
                '<br />Veränderung zu ",year-4,": ' + params.value[1])
                }"))) %>%
      e_x_axis(axisLabel = list(rotate = 45)) %>%
      e_axis_labels(
        x = "",
        y = "Veränderung zu 2020 in Prozentpunkten"
      )

    customize_echart(winlose_chart)

    # output$generaeted_text <-

  })
}




#' Prepare list for winlose text
#'
#' @param winlose_data result of prepare_winlose_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return list
#'
prepare_winner_loser <- function(winlose_data , selected_gemeinden){
  winlose_sort <- winlose_data %>%
    group_by(gemeinde_name) %>%
    arrange(share) %>%
    filter(share == max(share)|share == min(share)) %>%
    mutate(partei_name = ifelse(abbr_de == "Grüne","Grünen",abbr_de)) %>%
    mutate(partei_name = ifelse(partei_name %in% c("Die Mitte","MASS-VOLL","AUFTG"),partei_name,paste0("die ",partei_name )))


  result_list <- list()

  for (gemeinde in selected_gemeinden){
    tmp_win <- winlose_sort %>% filter(gemeinde_name==gemeinde) %>% filter(share == max(share))
    tmp_lose <- winlose_sort %>% filter(gemeinde_name==gemeinde) %>% filter(share == min(share))

    result_list[[paste0(gemeinde,"_winner")]] <- tmp_win %>% pull(partei_name) %>% paste0(.,collapse = " und ")
    result_list[[paste0(gemeinde,"_win")]] <- tmp_win %>% pull(share) %>% unique() %>% round(1)
    result_list[[paste0(gemeinde,"_loser")]] <- tmp_lose %>% pull(partei_name) %>% paste0(.,collapse = " und ")
    result_list[[paste0(gemeinde,"_loss")]] <- tmp_lose %>% pull(share) %>% unique() %>% round(1)
  }

  names(result_list) <- c(paste0(c("winner","win","loser","loss"),c("_a")),paste0(c("winner","win","loser","loss"),c("_b")))
  result_list
}



formulierungen_winlose_dif <- c(
  "Grösster Stimmenzuwachs für Partei X in Gemeinde A und Partei Y in Gemeinde B",
  "In Gemeinde A verzeichnet Partei X den stärksten Stimmenzuwachs, Partei Y gewinnt in Gemeinde B am meisten an Zustimmung",
  "Partei X und Partei Y sind grösste Gewinner in Gemeinde A bzw. Gemeinde B",
  "Partei X und Partei Y mit dem grössten Stimmenzuwachs in Gemeinde A bzw. Gemeinde B"
)

formulierungen_winlose_same <- c(
  "Grösster Stimmenzuwachs für Partei X in Gemeinde A und Gemeinde B",
  "In Gemeinde A und Gemeinde B verzeichnet Partei X den stärksten Stimmenzuwachs",
  "Partei X als grösste Gewinner in Gemeinde A und Gemeinde B",
  "Partei X mit dem grössten Stimmenzuwachs in Gemeinde A und Gemeinde B"
)


#' Generate title for winlose chart
#'
#' @param winlose_data result of prepare_winlose_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return title for winlose chart
#'
generate_title_winlose <- function(winlose_data , selected_gemeinden) {

  winner_party_data <- winlose_data  %>%
    group_by(gemeinde_name) %>%
    arrange(desc(share)) %>%
    slice(1) %>%
    ungroup() %>%
    arrange(gemeinde_name)

  partei1 <- winner_party_data$abbr_de[1]
  partei2 <- winner_party_data$abbr_de[2]
  gemeinde1 <- selected_gemeinden[1]
  gemeinde2 <- selected_gemeinden[2]


  if (!partei1 %in% c("Die Mitte","MASS-VOLL","AUFTG")){
    partei1 <- paste0("die ",partei1)
  }

  if (!partei2 %in% c("Die Mitte","MASS-VOLL","AUFTG")){
    partei2 <- paste0("die ",partei2)
  }

  if (partei1 == partei2) {
    auswahl <- sample(formulierungen_winlose_same, 1)
    aussage <- gsub("Partei X", partei1, auswahl)
    aussage <- gsub("Gemeinde A", gemeinde1, aussage)
    aussage <- gsub("Gemeinde B", gemeinde2, aussage)
  } else if (partei1 != partei2) {
    auswahl <- sample(formulierungen_winlose_dif, 1)
    aussage <- gsub("Partei X", partei1, auswahl)
    aussage <- gsub("Partei Y", partei2, aussage)
    aussage <- gsub("Gemeinde A", gemeinde1, aussage)
    aussage <- gsub("Gemeinde B", gemeinde2, aussage)
  } else {
    return("Ungültige Möglichkeit. Bitte wählen Sie entweder 1 oder 2.")
  }

  start_char <- stringr::str_extract(aussage,"^.")
  aussage <- stringr::str_replace(aussage,"^.",toupper(start_char))
  return(aussage)
}

#' Generate text for winlose chart
#'
#' @param winlose_data result of prepare_winlose_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return text for winlose chart
#'
generate_text_winlose <- function(winlose_data , selected_gemeinden){

  winlose_sort <- winlose_data %>%
    group_by(gemeinde_name) %>%
    arrange(share) %>%
    filter(share == max(share)|share == min(share))

  # Was wenn mehrer Parteien den gleichen win/loss haben?

  wl_list <- prepare_winner_loser(winlose_sort , selected_gemeinden)

  green_win_kann <- ifelse(wl_list$winner_a=="die Grünen","können","kann")
  green_win_konnte <- ifelse(wl_list$winner_a=="die Grünen","konnten","konnte")
  green_lose_busste <- ifelse(wl_list$loser_a=="die Grünen","büssten","büsste")
  green_lose_verlor <- ifelse(wl_list$loser_a=="die Grünen","verloren","verlor")
  green_lose_musste <- ifelse(wl_list$loser_b=="die Grünen","mussten","musste")



  immerhin_sogar_win <- ifelse(wl_list$win_a>wl_list$win_b,"immerhin",
                               ifelse(wl_list$win_a==wl_list$win_b,"ebenfalls",
                                      "sogar"))
  immerhin_sogar_lose <- ifelse(wl_list$loss_a>wl_list$loss_b,"sogar",
                                ifelse(wl_list$loss_a==wl_list$loss_b,"ebenfalls",
                                       "immerhin"))



  # Same winner, same loser
  if (wl_list$winner_a==wl_list$winner_b & wl_list$loser_a==wl_list$loser_b){



    winlose_text <- glue::glue("Als Partei mit den grössten Stimmenzuwächsen {green_win_kann} sich sowohl in {selected_gemeinden[1]} als auch in {selected_gemeinden[2]} {wl_list$winner_a} feiern lassen.
                       In {selected_gemeinden[1]} konnte sie {wl_list$win_a} Prozentpunkte hinzugewinnen, in {selected_gemeinden[2]} waren es {immerhin_sogar_win} {wl_list$win_b} Prozentpunkte.
                       Auch bei den grössten Verlieren zeigt sich in den beiden Gemeinden ein ähnliches Bild. In beiden Fällen {green_lose_busste} {wl_list$loser_a} prozentual die meisten Stimmen im Vergleich zur Grossratswahl 2020 ein.
                       Während {wl_list$loser_a} in {selected_gemeinden[1]} {wl_list$loss_a} Prozentpunkte {green_lose_verlor}, waren es in {selected_gemeinden[2]} {immerhin_sogar_lose} {wl_list$loss_b} Prozentpunkte Verlust."
    )
  }
  # Same winner, different loser
  if (wl_list$winner_a==wl_list$winner_b & wl_list$loser_a!=wl_list$loser_b){


    winlose_text <- glue::glue("Als Partei mit den grössten Stimmenzuwächsen {green_win_kann} sich sowohl in {selected_gemeinden[1]} als auch in {selected_gemeinden[2]} {wl_list$winner_a} feiern lassen.
                       In {selected_gemeinden[1]} konnte sie {wl_list$win_a} Prozentpunkte hinzugewinnen, in {selected_gemeinden[2]} waren es {immerhin_sogar_win} {wl_list$win_b} Prozentpunkte.
                       Bei den grössten Verlieren zeigt sich in den beiden Gemeinden ein unterschiedliches Bild. Während in  {selected_gemeinden[1]} {wl_list$loser_a} mit {wl_list$loss_a} Prozentpunkten am meisten Stimmen ein{green_lose_busste},
                       mussten in {selected_gemeinden[2]} {wl_list$loser_b} mit {wl_list$loss_b} Prozentpunkten die grössten Verluste hinnehmen."
    )
  }
  # Differnt winner, same loser
  if (wl_list$winner_a!=wl_list$winner_b & wl_list$loser_a==wl_list$loser_b){
    winlose_text <- glue::glue("Als Partei mit den grössten Stimmenzuwächsen {green_win_kann} sich in {selected_gemeinden[1]} {wl_list$winner_a} feiern lassen. Die Parei erreichte einen Zuwachs von {wl_list$win_a} Prozentpunkten.
                       Im Gegensatz dazu {green_win_konnte} in {selected_gemeinden[2]} {wl_list$winner_b} mit {wl_list$win_b} Prozentpunkte die prozentual die meisten Stimmen hinzugewinnen.
                       Bei den grössten Verlieren zeigt sich in den beiden Gemeinden ein ähnliches Bild. In beiden Fällen {green_lose_busste} {wl_list$loser_a} prozentual die meisten Stimmen im Vergleich zur Grossratswahl 2020 ein.
                       Während {wl_list$loser_a} in {selected_gemeinden[1]} {wl_list$loss_a} Prozentpunkte {green_lose_verlor}, waren es in {selected_gemeinden[2]} {immerhin_sogar_lose} {wl_list$loss_b} Prozentpunkte Verlust"

    )

  }

  # Different winner,different loser
  if (wl_list$winner_a!=wl_list$winner_b & wl_list$loser_a!=wl_list$loser_b){
    winlose_text <- glue:: glue("Als Partei mit den grössten Stimmenzuwächsen {green_win_kann} sich in {selected_gemeinden[1]} {wl_list$winner_a} feiern lassen. Die Parei erreichte einen Zuwachs von {wl_list$win_a} Prozentpunkten.
                       Im Gegensatz dazu {green_win_konnte} in {selected_gemeinden[2]} {wl_list$winner_b} mit {wl_list$win_b} Prozentpunkte die prozentual die meisten Stimmen hinzugewinnen.
                       Auch bei den grössten Verlieren zeigt sich in den beiden Gemeinden ein unterschiedliches Bild. Während in {selected_gemeinden[1]} {wl_list$loser_a} mit {wl_list$loss_a} Prozentpunkten am meisten Stimmen ein{green_lose_busste},
                       {green_lose_musste} in {selected_gemeinden[2]} {wl_list$loser_b} mit {wl_list$loss_b} Prozentpunkten die grössten Verluste verkraften."
    )


  }

  return(winlose_text)


}




generate_bullets_winlose <- function(winlose_data , selected_gemeinden){

  winlose_sort <- winlose_data %>%
    group_by(gemeinde_name) %>%
    arrange(share) %>%
    filter(share == max(share)|share == min(share))

  # Was wenn mehrer Parteien den gleichen win/loss haben?

  wl_list <- prepare_winner_loser(winlose_sort , selected_gemeinden)

  names(wl_list) <- names(wl_list) %>% str_replace_all("_a",paste0("_",selected_gemeinden[1]))
  names(wl_list) <- names(wl_list) %>% str_replace_all("_b",paste0("_",selected_gemeinden[2]))

  bullets <- lapply(selected_gemeinden,function(gemeinde){
    glue::glue("
      <br>
      <b>{gemeinde}</b>
      <ul>
        <li><i>Grösster Gewinner:</i> <b>{wl_list[[paste0('winner_',gemeinde)]] %>% str_remove('die') %>% str_replace('Grünen','GRÜNE')}</b> ({wl_list[[paste0('win_',gemeinde)]]} Prozentpunkte Gewinn im Vergleich zu den Wahlen 2020)</li>
        <li><i>Grösster Verlierer</i>: <b>{wl_list[[paste0('loser_',gemeinde)]] %>% str_remove('die') %>% str_replace('Grünen','GRÜNE')}</b> ({wl_list[[paste0('loss_',gemeinde)]]} Prozentpunkte Verlust im Vergleich zu den Wahlen 2020)</li>
      </ul>
    ")
  })

  bullet_list <- paste0(bullets,collapse = "<br>")


  HTML(bullet_list)

}
