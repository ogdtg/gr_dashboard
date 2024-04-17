# Render Functions




#' Generates Text or Bullets for Wahlbeteiligung
#'
#' @param wb_text result of genrate_wb_text()
#'
#' @return rendered Text or rendered UI (HTML)
#'
render_wb_text <- function(wb_text){

  if ( bullets){
    renderUI(wb_text)
    } else {
    renderText(wb_text)
  }
}

#' Render Text or Bullets for Parteistaerke
#'
#' @param ... see generate_text_pstk()
#'
#' @return rendered Text or rendered UI (HTML)
#'
render_ptsk_text <- function(...){
  if ( bullets){
    renderUI(generate_bullets_pstk(...))
  } else {
    renderText(generate_text_pstk(...))
  }
}


#' Render Text or Bullets for Veraenderung Parteistaerke
#'
#' @param ... see generate_text_winlose()
#'
#' @return rendered Text or rendered UI (HTML)
#'
render_winlose_text <- function(...){
  if ( bullets){
    renderUI(generate_bullets_winlose(...))
  } else {
    renderText(generate_text_winlose(...))
  }
}

#' Render Text or Bullets for Panaschierstatistik
#'
#' @param ... see generate_text_panasch()
#'
#' @return rendered Text or rendered UI (HTML)
#'
render_panasch_text <- function(...){

  if (bullets){
    renderUI( generate_bullets_panasch(...))
  } else {
    renderText( generate_text_panasch(...))

  }

}
