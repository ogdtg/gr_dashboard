# Parteistaerke Area Chart

#' Prepare data for time series of changes in party strength
#'
#' @param pstk_data result of prepare_pstk_data()
#' @param selected_gemeinden vector of exactly two gemeinden
#'
#' @return tibble
#'
prepare_pstk_hist_data <- function(pstk_gem,selected_gemeinden){

  pstk_hist_data <- pstk_gem %>%
    pivot_longer(cols = svp:uebrige,values_to = "share",names_to = "party") %>%
    filter(gemeinde_name %in% selected_gemeinden) %>%
    mutate(party = stringr::str_replace(party,"cvp","die mitte")) %>%
    left_join(partycolor %>%
                select(party,abbr_de,name_de,color),"party") %>%
    mutate(color = ifelse(gemeinde_name==selected_gemeinden[1],adjust_transparency(color,0.5),color)) %>%
    filter(!party %in% c("mass_voll","dsm","uebrige"))

  expand.grid(unique(pstk_hist_data$abbr_de),as.character(seq(2008,2024,4))) %>%
    setNames(c("abbr_de","wahljahr")) %>%
    left_join(pstk_hist_data %>%
                select(wahljahr, gemeinde_name,abbr_de,name_de,share,color),multiple = "all") %>%
    mutate(share = ifelse(is.na(share),0,share))

}

#' Render Area Chart for time series of changes in party strength
#'
#' @param pstk_hist_data result of prepare_pstk_hist_data()
#' @param gemeinde name of a gemeinde
#'
#'
render_pstk_hist_chart <- function(pstk_hist_data, gemeinde) {
  js_formatter <- "
function(params) {
  // Define the bold heading
  var heading = '<strong>' + params[0].axisValueLabel + '</strong><br />';
  // Reverse the order of tooltip items
  params = params.reverse();
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

  base_area <- pstk_hist_data %>%
    filter(gemeinde_name == gemeinde) %>%
    mutate(share = round(share, 1)) %>%
    arrange(wahljahr) %>%
    group_by(abbr_de) %>%
    e_charts(x = wahljahr) %>%
    e_area(share, stack = T) %>%
    e_y_axis(name = "Parteistärke in %", min = 0, max = 100) %>%
    e_x_axis(boundaryGap = FALSE) %>%
    e_tooltip(
      formatter = htmlwidgets::JS(js_formatter),
      trigger = "axis",
      axisPointer = list(
        type = "cross",
        label = list(backgroundColor = '#6a7985')
      )
    )

  base_area[["x"]][["opts"]][["color"]] <-
    sapply(base_area$x$opts$series, function(x) {
      partycolor$color[which(partycolor$abbr_de == x[["name"]])]

    })

  renderEcharts4r({
    customize_echart(base_area)
  })
}

