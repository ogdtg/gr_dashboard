# Boxes

# Introduction Box
start_box <- box(
  h2("Gemeindevergleich: Grossratswahlen 2024"),
  p("Auf diesem Dashboard können die Ergebnisse der 80 Thurgauer Gemeinden bei den Grossrtaswahlen 2024 miteinander verglichen werden.
            Wählen Sie über die Sidebar zwei Gemeinden zum Vergleich aus und klicken Sie sich durch unsere Daten."),

  p("Sollten Ihnen etwas unklar sein, können sie gerne einen Blick in unser Tutorial werfen."),

  actionButton("start_tutorial","Tutorial starten", icon = icon("graduation-cap")),


  width = 12,
  title = NULL,
  id = "wb_box"
)


# Wahlbeteiligung
wb_box <- box(
  uiOutput("wb_heading"),
  if(bullets){
    uiOutput("wb_text")
  } else {
    textOutput("wb_text")
  },
  br(),
  echarts4rOutput("wb_chart"),
  p(tags$b("Lesehilfe:"), " Wahlbeteiligung in % (Y-Achse) im Zeitverlauf seit 2008."),

  width = 12,
  title = NULL,
  id = "wb_box"
)


# Parteistaerke
pstk_box <- box(
  uiOutput("pstk_heading"),
  if(bullets){
    uiOutput("pstk_text")
  } else {
    textOutput("pstk_text")
  },
  br(),
  echarts4rOutput("pstk_chart"),
  p(tags$b("Lesehilfe:"), " Parteistaerke in % (Y-Achse) für die Grossratswahlen 2004 in den jeweiligen Gemeinden."),

  width = 6,
  title = NULL,
  id = "pstk_box"
)

# Veränderung Parteistaerke
winlose_box <- box(
  uiOutput("winlose_heading"),
  if(bullets){
    uiOutput("winlose_text")
  } else {
    textOutput("winlose_text")
  },
  br(),
  echarts4rOutput("winlose_chart"),
  p(tags$b("Lesehilfe:"), " Veränderung der Parteistaerke im Vergleich zur Grossratswahl 2020 in Prozentpunkten (Y-Achse) in den jeweiligen Gemeinden."),

  width = 6,
  title = NULL,
  id = "winlose_box"
)

# Panaschierstatistik A
panasch_box_a <- box(
  uiOutput("gemeinde_a_heading"),
  if(bullets){
    uiOutput("panasch_text_a")
  } else {
    textOutput("panasch_text_a")
  },
  echarts4rOutput("panasch_chart_a"),
  width = 6,
  title = NULL,
  id = "panasch_chart_box_a"
)

# Panaschierstatistik B
panasch_box_b <- box(
  uiOutput("gemeinde_b_heading"),
  if(bullets){
    uiOutput("panasch_text_b")
  } else {
    textOutput("panasch_text_b")
  },  echarts4rOutput("panasch_chart_b"),
  width = 6,
  title = NULL,
  id = "panasch_chart_box_b"
)

# Volle Panaschierstatistik
panasch_box <- box(
  h3("Panaschierstatistik"),
  p("Die Panaschierstatistik gibt an wie viele Panaschierstimmen pro 1000 Wahlzettel der Herkunftspartei und pro kandiderender Person der Empfängerpartei fliessen. Die genaue Berechnung kann ",
    tags$a("Konzepte zur Analyse der Panaschierstatistik (Burger 2001)", href = "https://www.bfs.admin.ch/bfsstatic/dam/assets/337885/master"),
    " entnommen werden. Die Datensätze aus denen diese Werte berechnet wurden finden sich ",tags$a("hier",href = "https://data.tg.ch/explore/?q=Panaschierstatistik+2024&sort=title")," auf data.tg.ch"),
  br(),
  width = 12,
  title = NULL,
  id = "panasch_box",
  panasch_box_a,
  panasch_box_b,
  br(),
  p(tags$b("Lesehilfe:"), " Die Diagramme zeigen den Fluss der Panaschierstimmen von der Herkunftspartei links zur Empfängerpartei rechts.
    Die angegebenen Werte entsprechen der Anzahl der fliessenden Panaschierstimmen pro 1000 Wahlzettel der Herkunftspartei und pro kandiderender Person der Empfängerpartei."),

)




end_box <- box(
  width = 12,
  title = NULL,
  p(tags$b("Dienststelle für Statistik")),
  p("Grabenstrasse 8"),
  p("8500 Frauenfeld"),
  p("Schweiz"),
  br(),
  p("Bei Fragen und Anmerkungen kontaktieren Sie uns gerne per ",tags$a("Mail",href = "mailto:statistik@tg.ch?cc=felix.lorenz@tg.ch")),
  br(),
  p("Sie finden den Code für dieses Dashbord auf GitHub"),
  actionButton(inputId='gh_button', label="GitHub Repository",
               icon = icon("github"),
               onclick ="window.open('https://github.com/ogdtg/gr_dashboard', '_blank')")
)