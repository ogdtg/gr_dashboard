# Boxes

# Introduction Box
start_box <- box(
  h2("Grossratswahlen 2024: Gemeinden im Vergleich"),
  p("Auf diesem Dashboard können Sie die Parteistärken, die Veränderung der Parteistärken im Zeitverlauf sowie die Wahlbeteiligung in den 80 Thurgauer Gemeinden bei den Grossratswahlen 2024 miteinander vergleichen.
            Wählen Sie über die Seitenleiste zwei Gemeinden zum Vergleich aus und klicken Sie sich durch die Grafiken."),

  p("Sollte Ihnen etwas unklar sein, können Sie gerne einen Blick in unser Tutorial werfen."),

  actionButton("start_tutorial","Tutorial starten", icon = icon("graduation-cap")),
  br(),
  br(),
  p(tags$b("Alle Texte und Grafiken basieren auf Open Government Data, die über ",tags$a("data.tg.ch",href = "https://data.tg.ch/pages/start/")," bezogen werden können.")),

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
  p(tags$b("Lesehilfe:"), " Parteistärke in % (Y-Achse) für die Grossratswahlen 2024 in den jeweiligen Gemeinden."),

  width = 12,
  title = NULL,
  id = "pstk_box"
)

# Veränderung Parteistärke
winlose_box <- box(
  uiOutput("winlose_heading"),
  if(bullets){
    uiOutput("winlose_text")
  } else {
    textOutput("winlose_text")
  },
  br(),
  echarts4rOutput("winlose_chart"),
  p(tags$b("Lesehilfe:"), " Veränderung der Parteistärke im Vergleich zu den Grossratswahlen 2020 in Prozentpunkten (Y-Achse) in den jeweiligen Gemeinden."),

  width = 12,
  title = NULL,
  id = "winlose_box"
)

# Panaschierstatistik A
panasch_box_a <- box(
  tags$head(tags$style(HTML('.box{-webkit-box-shadow: none; -moz-box-shadow: none;box-shadow: none;}'))),
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
  tags$head(tags$style(HTML('.box{-webkit-box-shadow: none; -moz-box-shadow: none;box-shadow: none;}'))),
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
  p("Bitte beachten Sie, dass aus Gründen der Übersichtlichket nur Parteien betrachtet werden, die auch einen Sitz im Grossen Rat gewonnen haben."),
  width = 12,
  title = NULL,
  id = "panasch_box",
  panasch_box_a,
  panasch_box_b,
  br(),
  box(
    tags$head(tags$style(HTML('.box{-webkit-box-shadow: none; -moz-box-shadow: none;box-shadow: none;}'))),
    width = 12,
    title = NULL,
    id = "panasch_box_lesehilfe",
    p(tags$b("Lesehilfe:"), " Die Diagramme zeigen den Fluss der Panaschierstimmen von der Herkunftspartei links zur Empfängerpartei rechts.
    Die angegebenen Werte entsprechen der Anzahl der fliessenden Panaschierstimmen pro 1000 Wahlzettel der Herkunftspartei und pro kandiderender Person der Empfängerpartei.")

  )

)


# Panaschierstatistik A
pstk_hist_box_a <- box(
  uiOutput("gemeinde_a_heading"),
  echarts4rOutput("pstk_hist_chart_a"),
  width = 6,
  title = NULL,
  id = "panasch_chart_box_a"
)

# Panaschierstatistik B
pstk_hist_box_b <- box(
  uiOutput("gemeinde_b_heading"),
  echarts4rOutput("pstk_hist_chart_b"),
  width = 6,
  title = NULL,
  id = "panasch_chart_box_b"
)



# Volle Zeitreighen box
pstk_hist_box <- box(
  h3("Wie entwickelten sich die Parteistärken?"),
  p("Die Grafik zeigt die Veränderung der Parteistärken als Zeitreihe in einem sogenannten Area Chart. Je grösser die Fläche zu einem bestimmten Zeitpunkt, desto stärker die Partei."),
  p("Bewegen Sie die Maus über die Grafik, um die Parteistärken im jeweiligen Wahljahr aufgelistet zu sehen.
    Durch Klicken auf einen Parteinamen in der Legende wird diese Partei deaktiviert und aus der Grafik ausgeblendet. So können Sie ganz einfach einzelne Parteien miteinander vergleichen."),

  p(tags$b("Bitte beachten Sie, dass aus Gründen der Übersichtlichket nur Parteien betrachtet werden, die auch einen Sitz im Grossen Rat gewonnen haben. Daher kann es sein, dass sich die Parteistärken in einzelnen Jahen nicht auf 100 % aufsummieren.")),
  width = 12,
  title = NULL,
  id = "pstk_hist_box",
  pstk_hist_box_a,
  pstk_hist_box_b,
  br()

)




link_box <- box(
  width = 12,
  title = NULL,
  id = "link_box",
  p(tags$b("Weiterführende Informationen")),
  br(),
  p(tags$a("Statistische Mitteilung zu den Grossratswahlen 2024",href = "https://statistik.tg.ch/public/upload/assets/158794/2024_Nr_3_Grossratswahlen_2024.pdf?fp=1713789932840")),
  p(tags$a("Internetseite zu den Grossratswahlen 2024 auf statistik.tg.ch",href = "https://statistik.tg.ch/themen-und-daten/staat-und-politik/wahlen-und-abstimmungen/grossratswahlen.html/10545")),
  p(tags$a("Wahlergebnisse auf wahlen.tg.ch",href="https://wahlen.tg.ch/2024/7424/grossratswahlen.html/15176")),
  p(tags$a("Thurgauer Themenatlas",href="https://themenatlas-tg.ch/#c=indicator&view=map3")),
  p(tags$a("Open Government Data",href="https://data.tg.ch/pages/start/")),
  p(tags$a("wahlen.tg.ch",href="https://wahlen.tg.ch/2024/7424/grossratswahlen.html/15176"))



)


end_box <- box(
  width = 12,
  title = NULL,
  p(tags$b("Dienststelle für Statistik - Kanton Thurgau")),
  p("Grabenstrasse 8"),
  p("8510 Frauenfeld"),
  p("Schweiz"),
  br(),
  p("Bei Fragen und Anmerkungen kontaktieren Sie uns gerne per ",tags$a("Email.",href = "mailto:statistik@tg.ch?cc=felix.lorenz@tg.ch")),
  br(),
  p("Sie finden den Code für dieses Dashbord auf GitHub."),
  actionButton(inputId='gh_button', label="GitHub Repository",
               icon = icon("github"),
               onclick ="window.open('https://github.com/ogdtg/gr_dashboard', '_blank')")
)
