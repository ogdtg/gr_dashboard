# Start the App over the "Run App" button in the top right corner of R Studio


# Define UI
ui <- dashboardPage(

  dashboardHeader(title = "Wahlspiegel 2024",
                  tags$li(a(href = 'https://statistik.tg.ch/themen-und-daten/staat-und-politik/wahlen-und-abstimmungen/grossratswahlen.html/10545',
                            img(src = 'https://www.tg.ch/public/upload/assets/20/logo-kanton-thurgau.svg',
                                title = "Company Home", height = "30px",
                                class = "logoTg"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")
  ),
  dashboardSidebar(
    selectInput("gemeinde_a", label = "Vergleiche", choices = unique(gemeinden_vec), selected = "Frauenfeld"),
    selectInput("gemeinde_b", label = "mit", choices = unique(gemeinden_vec), selected = "Weinfelden")
  ),
  dashboardBody(
    shinybrowser::detect(),
    tags$head(
      includeCSS("www/dashboard_style.css")
    ),
    HTML('<script src="https://cdn.jsdelivr.net/npm/js-cookie@rc/dist/js.cookie.min.js"></script>'),
    tags$script(HTML(
      '
    $(document).on("shiny:connected", function(){
      var newUser = Cookies.get("new_user");
      if(newUser === "false") return;
      Shiny.setInputValue("new_user", true);
      Cookies.set("new_user", false);
    });
    '
    )),
    tags$script(HTML("$('body').addClass('fixed');")),
    tags$div(
      style = "margin-top: 70px;",  # Add margin-top CSS style
      fluidRow(
        start_box, # Introduction
        pstk_box, # Parteistaerke
        winlose_box, # Veränderung Parteistaerke
        # panasch_box, #Panaschierstatistik
        pstk_hist_box, # Historische Veränderung Parteistärke
        wb_box, # Wahlbeteiligung
        link_box,
        end_box # End box

      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {

  # Show Introduction at start up of App
  # showModal(modal_start)
  observeEvent(input$new_user, {
    req(input$new_user)
    showModal(modal_start)
    })



  # Close Introduction Modal when "Los geht's" i clicked
  observeEvent(input$close_modal_start,{
    removeModal()
  })


  # Click Count for Tutorial so that R knows which modal to load
  click_count <- reactiveVal(1)


  # When "Tutorial Starten" is clicked the first Tutorial Modal will be displayed
  observeEvent(input$start_tutorial,{
    showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))

  })

  # Click "Weiter" to load next modal
  observeEvent(input$next_modal,{
    if (click_count()==9){
      removeModal()
      click_count <- reactiveVal(1)
    } else{
      click_count(click_count() + 1)  # Increment the click count
      showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))
    }



  })

  # Click "Zurück" to reload the last modal
  observeEvent(input$last_modal,{
    click_count(click_count() - 1)  # Decrease the click count
    showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))


  })


  # When two gemeinden are selected this part is executed
  # Per design there are always to Gemeinden selected
  observeEvent({length(c(input$gemeinde_a,input$gemeinde_b))==2},{



    # Vektor of Selected Gemeinden
    selected_gemeinden <-c(input$gemeinde_a, input$gemeinde_b) # Sort vector for easier data processing
    # Disadvantage of sorting: The order of the Bars in the Chart changes

    if (length(selected_gemeinden)==2 ){

      # Check if the same Gemeinde is selected twice. If yes a modal is showed and the page is not recaluclted since this would lead to problems
      if (input$gemeinde_a != input$gemeinde_b){

        # Print for logging reasons
        print(selected_gemeinden)

        # Data to visualize election turnout
        echart_wb_data <- prepare_wb_data(wb_data, selected_gemeinden)


        # Data to visualize Win/lose of Parties in different
        echart_winlose_data <-
          prepare_winlose_data(win_lose, selected_gemeinden)

        # Data to visualize party strength
        echart_pstk_data <-
          prepare_pstk_data(pstk_gem, selected_gemeinden, year = year)

        # Data on historic changes
        pstk_hist_data <- prepare_pstk_hist_data(pstk_gem,selected_gemeinden)


        # Data to visualize panasch a
        # echart_sankey_data_a <-
        #   prepare_sankey_panasch_data(panasch_data, input$gemeinde_a)
        # echart_sankey_data_b <-
        #   prepare_sankey_panasch_data(panasch_data, input$gemeinde_b)


        # Data on attraktivitaet of a party
        # attrakt_a <- prepare_attrakt_data_gemeinden(attrakt_data = attrakt,gemeinde = input$gemeinde_a)
        # attrakt_b <- prepare_attrakt_data_gemeinden(attrakt_data = attrakt,gemeinde = input$gemeinde_b)

        # Generate Text and title election turnout
        wabt_text <- generate_wahlbeteiligung_bullets(wb_data, selected_gemeinden, year = year, threshold)


        # Generate Title election turnout
        output$wb_heading <- renderUI({
          h3("Wo gingen mehr Wählerinnen und Wähler zur Urne?")
        })


        # Rendr Wahlbeteiligung text
        output$wb_text <- render_wb_text(wabt_text$text)

        # Generate Title Party Strength pstk_heading
        output$pstk_heading <- renderUI({
          # h3(generate_title_pstk(echart_pstk_data, selected_gemeinden))
          h3("Welche Partei schnitt am besten ab?")
        })

        # Generate text Party Strength
        output$pstk_text <- render_ptsk_text(echart_pstk_data, selected_gemeinden)


        # Generate title winlose
        output$winlose_heading <- renderUI({
          # h3(generate_title_winlose(echart_winlose_data, selected_gemeinden))
          h3("Wer gewann oder verlor am meisten Parteistimmenanteile?")

        })

        # Generate text winlose
        output$winlose_text <- render_winlose_text(winlose_data = win_lose,selected_gemeinden = selected_gemeinden)


        # Generate Box Gemeinde A heading
        # output$gemeinde_a_heading <- renderUI({
        #   h3(generate_title_panasch(attrakt_data = attrakt_a,gemeinde = input$gemeinde_a))
        # })

        # Generate Box Gemeinde B heading
        # output$gemeinde_b_heading <- renderUI({
        #   h3(generate_title_panasch(attrakt_data = attrakt_b,gemeinde = input$gemeinde_b))
        # })

        # Title for Historic changes
        output$gemeinde_a_heading <- renderUI({
          h3(selected_gemeinden[1])
        })

        output$gemeinde_b_heading <- renderUI({
          h3(selected_gemeinden[2])
        })

        # Render Panasch text
        # output$panasch_text_a <- render_panasch_text(sankey_panasch_data = echart_sankey_data_a,attrakt_data = attrakt_a,gemeinde = input$gemeinde_a)
        # output$panasch_text_b <- render_panasch_text(sankey_panasch_data = echart_sankey_data_b,attrakt_data = attrakt_b,gemeinde = input$gemeinde_b)



        # Render Wahlbeteiligung chart
        output$wb_chart <-
          render_wb_chart(echart_wb_data, selected_gemeinden)

        # Wender Parteistaerke chart
        output$pstk_chart <-
          render_pstk_chart(echart_pstk_data, selected_gemeinden)


        # Render Veraenderung Parteistaerke chart
        output$winlose_chart <-
          render_winlose_chart(echart_winlose_data, selected_gemeinden, year)

        # Panaschierstatistik
        # output$panasch_chart_a <-
        #   render_panasch_chart(echart_sankey_data_a,partycolor=partycolor)
        #
        # output$panasch_chart_b <-
        #   render_panasch_chart(echart_sankey_data_b,partycolor=partycolor)
        #

        output$pstk_hist_chart_b <-
          render_pstk_hist_chart(pstk_hist_data, selected_gemeinden[1])

        output$pstk_hist_chart_a <-
          render_pstk_hist_chart(pstk_hist_data, selected_gemeinden[2])


      } else {

        # Modal if the same Gemeinde is selected twice
        showModal(modalDialog(
          title = "Identische Gemeinden ausgewählt",
          "Bitte wählen Sie zwei unterschiedliche Gemeinden aus.",
          footer = modalButton("OK"),
          easyClose = T
        ))
      }
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)

