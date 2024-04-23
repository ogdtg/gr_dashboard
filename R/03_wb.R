# load packages
library(dplyr)
library(echarts4r)
library(tidyr)
library(stringr)
library(colorspace)

# Wahlbeteiligung

threshold <- 5




#' Prepare wahlbeteiligung data
#'
#' @param data shinydata/wb_data.rds
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return tibble
#'
prepare_wb_data <- function(data,selected_gemeinden){
  data %>%
    ungroup() %>%
    filter(gemeinde_name %in% selected_gemeinden) %>%
    group_by(gemeinde_name) %>%
    mutate(gemeinde_name = factor(gemeinde_name,levels=selected_gemeinden)) %>%
    arrange(gemeinde_name) %>%
    arrange(wahljahr)
}




#' Render echart wahlbeteiligung (bar chart)
#'
#' @param wb_data result of prepare_wb_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return rendered echart
#'
render_wb_chart <- function(wb_data,selected_gemeinden){

  js_formatter <- "
    function(params) {
  // Define the bold heading
  var heading = '<strong>' + params[0].axisValueLabel + '</strong><br />';
  // Concatenate the heading with the tooltip content for each series
  var content = params.map(function(item) {
    // Get the color of the series as a circle
    var colorCircle = '<span style=\"display:inline-block;margin-right:5px;border-radius:50%;width:10px;height:10px;background-color:' + item.color + ';\"></span>';
    // Format the value with a % sign and make it bold and right-aligned
    var value = '<span style=\"float:right;font-weight:bold;\">' + item.value[1] + '%</span>';
    return colorCircle + '<span>' + item.seriesName + ': </span>' + value + '<br />';
  }).join('');
  // Combine the heading and content
  return heading + content;
    }"

  # js_formatter <- "
  #     function(params){
  #       return('<strong>' +  params.value[0] +
  #               '</strong><br />Gemeinde: ' + params.name +
  #               '<br />Wahlbeteiligung : ' + params.value[1] + '%')
  #               }"

  renderEcharts4r({
    wb_chart <- wb_data %>%
      e_charts(wahljahr) %>%
      e_line(wahlbeteiligung_in_prozent ,bind = gemeinde_name) %>%
      e_color(color = c("#0000004D","black")) %>%
      e_tooltip(
        trigger = "axis",
        formatter = htmlwidgets::JS(js_formatter)) %>%
      e_axis_labels(
        x = "",
        y = "Wahlbeteiligung in %"
      )
    wb_chart$x$opts$series[[1]]$lineStyle <- list(width=4)
    wb_chart$x$opts$series[[2]]$lineStyle <- list(width=4)

    customize_echart(wb_chart)

  })
}






#' Generate title and text on Wahlbeteiligung
#'
#' @param gemeinde_a Gemeindename A
#' @param gemeinde_b Gemeindename B
#' @param wahlbeteiligung_a Wahlbeteiligung Gemeinde A
#' @param wahlbeteiligung_b Wahlbeteiligung Gemeinde B
#' @param wahlbeteiligung_a_letzte Wahlbeteiligung Gemeinde A last election
#' @param wahlbeteiligung_b_letzte Wahlbeteiligung Gemeinde B last election
#' @param wahlbeteiligung_a_zeitreihe Wahlbeteiligung Gemeinde A since election 2008
#' @param wahlbeteiligung_b_zeitreihe Wahlbeteiligung Gemeinde B since election 2008
#' @param threshold
#'
#' @return text
#'
generate_wahlbeteiligung_title_text <- function(gemeinde_a, gemeinde_b, wahlbeteiligung_a, wahlbeteiligung_b, wahlbeteiligung_a_letzte, wahlbeteiligung_b_letzte, wahlbeteiligung_a_zeitreihe,wahlbeteiligung_b_zeitreihe ,threshold) {




  if (wahlbeteiligung_a == wahlbeteiligung_b) {
    title <- glue::glue("Wahlbeteiligung in {gemeinde_a} und {gemeinde_b} gleich")
    text_wb_gemeinde_vergleich <- glue::glue("Die Wahlbeteiligung in {gemeinde_a} und {gemeinde_b} liegt bei {wahlbeteiligung_a}%.")

  } else if (wahlbeteiligung_a > wahlbeteiligung_b + threshold) {
    title <- glue::glue("Deutlich höhere Wahlbeteiligung in {gemeinde_a} als in {gemeinde_b}")

    text_wb_gemeinde_vergleich <- glue::glue("Die Wahlbeteiligung in {gemeinde_a} ({wahlbeteiligung_a}%) lag 2024 deutlich höher als in {gemeinde_b}, wo nur {wahlbeteiligung_b}% der Stimmberechtigten ihre Stimme abgaben.")

  } else if (wahlbeteiligung_a > wahlbeteiligung_b & wahlbeteiligung_a <= wahlbeteiligung_b + threshold){
    title <- glue::glue("Wahlbeteiligung in {gemeinde_a} etwas höher als in {gemeinde_b}")
    text_wb_gemeinde_vergleich <- glue::glue("Die Wahlbeteiligung in {gemeinde_a} ({wahlbeteiligung_a}%) lag 2024 etwas höher als in {gemeinde_b}, wo {wahlbeteiligung_b}% der Stimmberechtigten ihre Stimme abgaben.")

  } else if (wahlbeteiligung_a + threshold < wahlbeteiligung_b_letzte){
    title <- glue::glue("{gemeinde_b} mit deutlich höherer Wahlbeteiligung als {gemeinde_a}")
    text_wb_gemeinde_vergleich <- glue::glue("Die Wahlbeteiligung in {gemeinde_b} ({wahlbeteiligung_b}%) lag 2024 deutlich höher als in {gemeinde_a}, wo nur {wahlbeteiligung_a}% der Stimmberechtigten ihre Stimme abgaben.")

  } else if (wahlbeteiligung_a < wahlbeteiligung_b & wahlbeteiligung_a + threshold >= wahlbeteiligung_b_letzte){
    title <- glue::glue("Leicht erhöhte Wahlbeteiligung in {gemeinde_b} im Vergleich zu {gemeinde_a}")
    text_wb_gemeinde_vergleich <- glue::glue("Die Wahlbeteiligung in {gemeinde_b} ({wahlbeteiligung_b}%) lag 2024 etwas höher als in {gemeinde_a}, wo {wahlbeteiligung_a}% der Stimmberechtigten ihre Stimme abgaben.")

  }

  text_wb_gemeinde_vergleich_letzte <- list()
  text_wb_gemeinde_vergleich_tiefstand <- list()

  # Vergleich Gemeinde B
    var_list <- list(list(gemeinde = gemeinde_a,wb = wahlbeteiligung_a,wb_last = wahlbeteiligung_a_letzte,zeitreihe = wahlbeteiligung_a_zeitreihe),
         list(gemeinde = gemeinde_b,wb = wahlbeteiligung_b,wb_last = wahlbeteiligung_b_letzte, zeitreihe = wahlbeteiligung_b_zeitreihe))

    for (i in 1:2){
      if (var_list[[i]]$wb == var_list[[i]]$wb_last) {
        text <- glue::glue("Verglichen mit den Grossratswahlen vor 4 Jahren, blieb die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% konstant.")

      } else if (var_list[[i]]$wb > var_list[[i]]$wb_last + threshold) {

        if (i == 1){
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren lag die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% deutlich höher als 2020. Damals nahmen nur {var_list[[i]]$wb_last}% der Stimmberechtigten an den Grossratswahlen teil.")
        } else {
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Blickt man auf {var_list[[i]]$gemeinde}, so lag die Wahlbeteiligung im Vergleich zu den letzten Grossratswahlen bei {var_list[[i]]$wb}% und somit deutlich höher als 2020. Nur {var_list[[i]]$wb_last}% der Stimmberechtigten gaben damals ihre Stimme ab.")
        }

      } else if (var_list[[i]]$wb > var_list[[i]]$wb_last & var_list[[i]]$wb <= var_list[[i]]$wb_last + threshold){

        if (i == 1){
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren war die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% leicht erhöht. Bei den Grossratswahlen 2020 nahmen nur {var_list[[i]]$wb_last}% der Stimmberechtigten teil.")

        } else {
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Blickt man auf {var_list[[i]]$gemeinde}, so lag die Wahlbeteiligung im Vergleich zu den letzten Grossratswahlen bei {var_list[[i]]$wb}% und somit etwas höher als 2020. Damals gaben {var_list[[i]]$wb_last}% der Stimmberechtigten ihre Stimme ab.")

        }

      } else if (var_list[[i]]$wb + threshold < var_list[[i]]$wb_last){
        text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren lag die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% deutlich niedriger als 2020. Damals nahmen noch {var_list[[i]]$wb_last}% der Stimmberechtigten an den Grossratswahlen teil.")

        if (i == 1){
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren lag die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% deutlich niedriger als 2020. Damals nahmen noch {var_list[[i]]$wb_last}% der Stimmberechtigten an den Grossratswahlen teil.")

        } else {
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Blickt man auf {var_list[[i]]$gemeinde}, so lag die Wahlbeteiligung im Vergleich zu den letzten Grossratswahlen bei {var_list[[i]]$wb}% und somit deutlich niedriger als 2020. Damals gaben noch {var_list[[i]]$wb_last}% der Stimmberechtigten ihre Stimme ab.")

        }

      } else if (var_list[[i]]$wb < var_list[[i]]$wb_last & var_list[[i]]$wb + threshold >= var_list[[i]]$wb_last){
        text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren ist die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% leicht gesunken. Bei den Grossratswahlen 2020 nahmen noch {var_list[[i]]$wb_last}% der Stimmberechtigten teil.")

        if (i == 1){
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Im Vergleich zu den Wahlen vor 4 Jahren ist die Wahlbeteiligung in {var_list[[i]]$gemeinde} mit {var_list[[i]]$wb}% leicht gesunken. Bei den Grossratswahlen 2020 nahmen noch {var_list[[i]]$wb_last}% der Stimmberechtigten teil.")

        } else {
          text_wb_gemeinde_vergleich_letzte[[i]] <- glue::glue("Blickt man auf {var_list[[i]]$gemeinde}, so lag die Wahlbeteiligung im Vergleich zu den letzten Grossratswahlen bei {var_list[[i]]$wb}% und somit etwas niedriger als 2020. Damals gaben {var_list[[i]]$wb_last}% der Stimmberechtigten ihre Stimme ab.")

        }
      }

      if (var_list[[i]]$wb> min(var_list[[i]]$zeitreihe)){
        text_wb_gemeinde_vergleich_tiefstand[[i]] <- ""
      } else {
        if (which(var_list[[i]]$wb==min(var_list[[i]]$zeitreihe))>1){
          if (i == 1){
            text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Für {var_list[[i]]$gemeinde} ergibt sich daraus ein erneuter historischer Tiefstand.")
          } else {
            if (text_wb_gemeinde_vergleich_tiefstand[[i-1]]!=""){
              text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Auch in {var_list[[i]]$gemeinde} liegt die Wahlbeteiligung somit zum widerholten Male auf einem historischen Tief.")
            } else {
              text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Für {var_list[[i]]$gemeinde} ergibt sich daraus ein erneuter historischer Tiefstand.")
            }
          }
        } else {
          if (i == 1){
            text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Für {var_list[[i]]$gemeinde} ergibt sich daraus ein historischer Tiefstand.")
          } else {
            if (text_wb_gemeinde_vergleich_tiefstand[[i-1]]!=""){
              text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Auch in {var_list[[i]]$gemeinde} liegt die Wahlbeteiligung somit auf einem historischen Tief.")
            } else {
              text_wb_gemeinde_vergleich_tiefstand[[i]] <- glue::glue("Für {var_list[[i]]$gemeinde} ergibt sich daraus ein historischer Tiefstand.")
            }
          }
        }
      }
    }

    full_text <- paste(text_wb_gemeinde_vergleich,
                        text_wb_gemeinde_vergleich_letzte[[1]],
                        text_wb_gemeinde_vergleich_tiefstand[[1]],
                        text_wb_gemeinde_vergleich_letzte[[2]],
                        text_wb_gemeinde_vergleich_tiefstand[[2]], collapse = " ") %>%
      str_replace_all("(?<!\\A|\\.\\s)Die Mitte", "die Mitte")



  return(list(title = title %>%
                str_replace_all("(?<!\\A|\\.\\s)Die Mitte", "die Mitte")  ,
              text = full_text))
}



#' Prepare WB data for creating text and bulltes
#'
#' @param wb_data result of prepare_wb_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#' @param year year of election
#'
#' @return list
#' @export
#'
#' @examples
prepare_wb_list <- function(wb_data, selected_gemeinden,year){
  wb_list <- list(list(),list())

  names(wb_list) <- selected_gemeinden

  for (i in seq_along(selected_gemeinden)){

    gem_data <- wb_data %>%
      filter(gemeinde_name == selected_gemeinden[[i]])

    wb_list[[i]]$wb <- gem_data %>%
      filter(wahljahr==year) %>%
      pull(wahlbeteiligung_in_prozent)

    wb_list[[i]]$wb_last <- gem_data %>%
      filter(wahljahr==year-4) %>%
      pull(wahlbeteiligung_in_prozent)

    wb_list[[i]]$zeitreihe <- gem_data %>%
      pull(wahlbeteiligung_in_prozent)

  }
  return(wb_list)
}

#' Prepare data and generate text and title for wahlbeteiligung chart
#'
#' @param wb_data result of prepare_wb_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#' @param year election year
#' @param threshold from when one you speak of a strong difference between two gemeinden
#'
#' @return list
#' @export
#'
#' @examples
generate_wahlbeteiligung_text <- function(wb_data, selected_gemeinden,year,threshold){


  wb_list <- prepare_wb_list(wb_data, selected_gemeinden,year)

  generate_wahlbeteiligung_title_text(gemeinde_a = selected_gemeinden[1],
                                      gemeinde_b = selected_gemeinden[2],
                                      wahlbeteiligung_a = wb_list[[1]]$wb,
                                      wahlbeteiligung_b = wb_list[[2]]$wb,
                                      wahlbeteiligung_a_letzte = wb_list[[1]]$wb_last,
                                      wahlbeteiligung_b_letzte = wb_list[[2]]$wb_last,
                                      wahlbeteiligung_a_zeitreihe = wb_list[[1]]$zeitreihe,
                                      wahlbeteiligung_b_zeitreihe = wb_list[[2]]$zeitreihe,
                                      threshold = threshold)



}



#' Prepare data and generate text/bullets and title for wahlbeteiligung chart
#'
#' @param wb_data result of prepare_wb_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#' @param year election year
#' @param threshold from when one you speak of a strong difference between two gemeinden
#'
#' @return list
#' @export
#'
#' @examples

generate_wahlbeteiligung_bullets <- function(wb_data, selected_gemeinden,year,threshold){

  wb_list <- prepare_wb_list(wb_data, selected_gemeinden,year)

  temp <-   generate_wahlbeteiligung_title_text(gemeinde_a = selected_gemeinden[1],
                                                gemeinde_b = selected_gemeinden[2],
                                                wahlbeteiligung_a = wb_list[[1]]$wb,
                                                wahlbeteiligung_b = wb_list[[2]]$wb,
                                                wahlbeteiligung_a_letzte = wb_list[[1]]$wb_last,
                                                wahlbeteiligung_b_letzte = wb_list[[2]]$wb_last,
                                                wahlbeteiligung_a_zeitreihe = wb_list[[1]]$zeitreihe,
                                                wahlbeteiligung_b_zeitreihe = wb_list[[2]]$zeitreihe,
                                                threshold = threshold)
  if (!bullets){
    return(temp)
  }

  bullet_points <- lapply(selected_gemeinden,function(gemeinde){

    change <- wb_list[[gemeinde]][['wb']]-wb_list[[gemeinde]][['wb_last']]
    abs_change <- abs(change) %>% round(1)
    change_symbol <- ifelse(change>0,"+",
                            ifelse(change==0,"+–",
                                   ifelse(change<0,"–","")))

    glue::glue("
      <br>
      <b>{gemeinde}</b>
      <ul>
        <li><i>Wahlbeteiligung:</i> <b>{wb_list[[gemeinde]][['wb']]}%</b> ({change_symbol}{abs_change} Prozentpunkte im Vergleich zur Grossratswahl 2020)</li>
      </ul>
    ")
  })

  bullet_list <- paste0(bullet_points,collapse = "")


  temp$text <- HTML(bullet_list)

  return(temp)


}



