library(shiny)
library(shinydashboard)



# Start the App over the "Run App" button in the top right corner of R Studio


# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Wahlkompass 2024",
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
      includeCSS("www/dashboard_style.css"),
      tags$script('
        var dimension = [0, 0];
        $(document).on("shiny:connected", function(e) {
          dimension[0] = window.innerWidth;
          dimension[1] = window.innerHeight;
          Shiny.onInputChange("dimension", dimension);
        });
        $(window).resize(function(e) {
          dimension[0] = window.innerWidth;
          dimension[1] = window.innerHeight;
          Shiny.onInputChange("dimension", dimension);
        });
      ')
    ),
    tags$script(HTML("$('body').addClass('fixed');")),
    tags$div(
      modal_start, # Modal with introduction
      style = "margin-top: 70px;",  # Add margin-top CSS style
      fluidRow(
        box(
          h2("Gemeindevergleich: Grossratswahlen 2024"),
          p("Auf diesem Dashboard können die Ergebnisse der 80 Thurgauer Gemeinden bei den Grossrtaswahlen 2024 miteinander verglichen werden.
            Wählen Sie über die Sidebar zwei Gemeinden zum Vergleich aus und klicken Sie sich durch unsere Daten."),

          p("Sollten Ihnen etwas unklar sein, können sie gerne einen Blick in unser Tutorial werfen."),

          actionButton("start_tutorial","Tutorial starten", icon = icon("graduation-cap")),


          width = 12,
          title = NULL,
          id = "wb_box"
        ),
        box(
          uiOutput("wb_heading"),
          textOutput("wb_text"),
          br(),
          echarts4rOutput("wb_chart"),
          p(tags$b("Lesehilfe:"), " Wahlbeteiligung in % (Y-Achse) im Zeitverlauf seit 2008."),

          width = 12,
          title = NULL,
          id = "wb_box"
        ),
        box(
          uiOutput("pstk_heading"),
          textOutput("pstk_text"),
          br(),
          echarts4rOutput("pstk_chart"),
          p(tags$b("Lesehilfe:"), " Parteistaerke in % (Y-Achse) für die Grossratswahlen 2004 in den jeweiligen Gemeinden."),

          width = 6,
          title = NULL,
          id = "pstk_box"
        ),
        box(
          uiOutput("winlose_heading"),
          textOutput("winlose_text"),
          br(),
          echarts4rOutput("winlose_chart"),
          p(tags$b("Lesehilfe:"), " Veränderung der Parteistaerke im Vergleich zur Grossratswahl 2020 in Prozentpunkten (Y-Achse) in den jeweiligen Gemeinden."),

          width = 6,
          title = NULL,
          id = "winlose_box"
        ),
        box(
          uiOutput("panasch_heading"),
          textOutput("panasch_text"),
          br(),
          width = 12,
          title = NULL,
          id = "panasch_box",
          box(
            uiOutput("gemeinde_a_heading"),
            textOutput("panasch_text_a"),
            echarts4rOutput("panasch_chart_a"),
            p("<b>Lesehilfe</b>"),
            width = 6,
            title = NULL,
            id = "panasch_chart_box_a"
          ),
          box(
            uiOutput("gemeinde_b_heading"),
            textOutput("panasch_text_b"),
            echarts4rOutput("panasch_chart_b"),
            p("Lesehilfe"),
            width = 6,
            title = NULL,
            id = "panasch_chart_box_b"
          )
        ),
        box(
          width = 12,
          title = NULL,
          p(tags$b("Dienststelle für Statistik")),
          p("Grabenstrasse 8"),
          p("8500 Frauenfeld"),
          p("Schweiz"),
          br(),
          p("Sie finden den Code für dieses Dashbord auf GitHub"),
          actionButton(inputId='gh_button', label="GitHub Repository",
                       icon = icon("github"),
                       onclick ="window.open('https://github.com/ogdtg/gr_dashboard', '_blank')")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {


  click_count <- reactiveVal(1)


  observeEvent(input$start_tutorial,{
    showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))

  })

  observeEvent(input$next_modal,{
    if (click_count()==7){
      removeModal()
      click_count <- reactiveVal(1)
    } else{
      click_count(click_count() + 1)  # Increment the click count
      showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))
    }



  })

  observeEvent(input$last_modal,{
    click_count(click_count() - 1)  # Decrease the click count
    showModal(readRDS(paste0("shinydata/modal_",click_count(),".rds")))


  })

  observeEvent({length(c(input$gemeinde_a,input$gemeinde_b))==2},{



      # Vektor of Selected Gemeinden
      selected_gemeinden <-
        sort(c(input$gemeinde_a, input$gemeinde_b))

      if (length(selected_gemeinden)==2 ){
        if (input$gemeinde_a != input$gemeinde_b){
          print(selected_gemeinden)
          # Data to visualize election turnout
          echart_wb_data <- prepare_wb_data(wb_data, selected_gemeinden)


          # Data to visualize Win/lose of Parties in different
          echart_winlose_data <-
            prepare_winlose_data(win_lose, selected_gemeinden)

          # Data to visualize party strength
          echart_pstk_data <-
            prepare_pstk_data(pstk_gem, selected_gemeinden, year = year)


          # Data to visualize panasch a
          echart_sankey_data_a <-
            prepare_sankey_panasch_data(panasch_data, input$gemeinde_a)
          echart_sankey_data_b <-
            prepare_sankey_panasch_data(panasch_data, input$gemeinde_b)


          attrakt_a <- prepare_attrakt_data_gemeinden(attrakt_data = attrakt,gemeinde = input$gemeinde_a)
          attrakt_b <- prepare_attrakt_data_gemeinden(attrakt_data = attrakt,gemeinde = input$gemeinde_b)

          # Generate Text and title election turnout
          wb_text <-
            generate_wahlbeteiligung_text(wb_data, selected_gemeinden, year = year, threshold)



          # Generate Title election turnout
          output$wb_heading <- renderUI({
            h3(wb_text$title)
          })

          output$wb_text <- renderText({
            wb_text$text
          })

          # Generate Title Party Strength pstk_heading
          output$pstk_heading <- renderUI({
            h3(generate_title_pstk(echart_pstk_data, selected_gemeinden))
          })

          # Generate text Party Strength
          output$pstk_text <- renderText({
            generate_text_pstk(echart_pstk_data, selected_gemeinden)
            # Add your dynamic text generation logic here
          })

          # Generate title winlose
          output$winlose_heading <- renderUI({
            h3(generate_title_winlose(echart_winlose_data, selected_gemeinden))
          })

          # Generate text winlose
          output$winlose_text <- renderText({
            generate_text_winlose(winlose_data = win_lose,selected_gemeinden = selected_gemeinden)
          })

          # Generate Box Gemeinde A heading
          output$gemeinde_a_heading <- renderUI({
            h3(generate_title_panasch(attrakt_data = attrakt_a,gemeinde = input$gemeinde_a))
          })

          # Generate Box Gemeinde B heading
          output$gemeinde_b_heading <- renderUI({
            h3(generate_title_panasch(attrakt_data = attrakt_b,gemeinde = input$gemeinde_b))
          })

          output$panasch_text_a <- renderText({
            generate_text_panasch_gemeinde(sankey_panasch_data = echart_sankey_data_a,attrakt_data = attrakt_a,gemeinde = input$gemeinde_a)
          })

          output$panasch_text_b <- renderText({
            generate_text_panasch_gemeinde(sankey_panasch_data = echart_sankey_data_b,attrakt_data = attrakt_b,gemeinde = input$gemeinde_b)
          })




          output$wb_chart <-
            render_wb_chart(echart_wb_data, selected_gemeinden)

          output$pstk_chart <-
            render_pstk_chart(echart_pstk_data, selected_gemeinden)


          output$winlose_chart <-
            render_winlose_chart(echart_winlose_data, selected_gemeinden, year)

          # Panaschierstatistik
          output$panasch_chart_a <-
            render_panasch_chart(echart_sankey_data_a,partycolor=partycolor)

          output$panasch_chart_b <-
            render_panasch_chart(echart_sankey_data_b,partycolor=partycolor)
        } else {
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

