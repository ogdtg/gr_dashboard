# Create modals

# Create Modals for Tutorial

modal_1 <- modalDialog(
  title = tags$b("Gemeinden auswählen"),
  p("Über die beiden Dropdown-Felder in der Sidebar können die beiden Gemeinden ausgewählt werden, die miteinander verglichen werden sollen. Sämtliche Grafiken und Texte passen sich nach einem kurzen Moment auf Ihre Auswahl an."),
  tags$img(src = "sidebar_dropdown.PNG", width = "200px"),
  p("Die Sidebar kann jederzeit über das ",tags$img(src="toggle.PNG")," geöffnet und geschlossen werden"),
  footer = list(actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),

)

saveRDS(modal_1,"shinydata/modal_1.rds")


modal_2 <- modalDialog(
  title = tags$b("Grafiken bedienen"),
  p("Alle Grafiken sind interaktiv. Fährt man mit der Maus über einen Balken, so erscheinen die jeweiligen Informationen in einem sogenannten Tooltip."),
  tags$img(src = "tooltip.PNG", width = "80%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE
)

saveRDS(modal_2,"shinydata/modal_2.rds")

modal_3 <- modalDialog(
  title = tags$b("Grafiken bedienen"),
  p("Die Daten für die beiden Gemeinden werden nebeneinander dargestellt. Die transparenten Farben werden in der Legende durch",tags$img(src="grey.PNG")," symbolisiert, die gesättigten durch ",tags$img(src="black.PNG"),"."),
  p("Durch einen Klick auf den jeweiligen Legendeneintrag kann eine Gemeinde entfernt werden. Das Legendensymbol ist dann ausgegraut. Ein erneuter Klick bringt die Daten der entsprechenden Gemeinde wieder in die Grafik"),
  tags$img(src = "one_gemeinde.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_3,"shinydata/modal_3.rds")




modal_4 <- modalDialog(
  title = tags$b("Parteistärke"),
  p("Die Parteistärke für alle Parteien ist in Prozent angegeben. Der Datensatz, welcher diese Informationen enthält findet, sich ",tags$a("hier",href = "https://data.tg.ch/explore/dataset/sk-stat-9/table/?sort=wahljahr")," auf data.tg.ch"),
  tags$img(src = "parteistaerke.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_4,"shinydata/modal_4.rds")


modal_5 <- modalDialog(
  title = tags$b("Veränderung Parteistärken im Vergleich zu den Grossratswahlen 2020"),
  p("Die Veränderung Parteistärken im Vergleich zu den Grossratswahlen 2020 wird in Prozentpunkten angegeben. Der Datensatz, aus welchem diese Daten berechnet wurden, findet sich ",tags$a("hier",href = "https://data.tg.ch/explore/dataset/sk-stat-9/table/?sort=wahljahr")," auf data.tg.ch"),
  tags$img(src = "veraenderung.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_5,"shinydata/modal_5.rds")

modal_6 <- modalDialog(
  title = tags$b("Veränderung Parteistärken als Zeitreihe"),
  p("Die Grafik zeigt die Veränderung der Parteistärken als Zeitreihe in einem sogenannten Area Chart. Je grösser die Fläche zu einem bestimmten Zeitpunkt, desto stärker die Partei."),
  p("Bewegen Sie die Maus über die Grafik, um die Parteistärken im jeweiligen Wahljahr aufgelistet zu sehen.
    Durch Klicken auf einen Parteinamen in der Legende wird diese Partei deaktiviert und aus der Grafik ausgeblendet. So können Sie ganz einfach einzelne Parteien miteinander vergleichen."),

  p(tags$b("Bitte beachten Sie, dass aus Gründen der Übersichtlichket nur Parteien betrachtet werden, die auch einen Sitz im Grossen Rat gewonnen haben. Daher kann es sein, dass sich die Parteistärken in einzelnen Jahen nicht auf 100 % aufsummieren.")),
  tags$img(src = "hist.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_6,"shinydata/modal_6.rds")








modal_7 <- modalDialog(
  title = tags$b("Wahlbeteiligung"),
  p("Die Wahlbeteiligung ab 2008 ist in Prozent angegeben. Der Datensatz, welcher diese Informationen enthält, findet sich ",tags$a("hier",href = "https://data.tg.ch/explore/dataset/sk-stat-11/table/?sort=wahljahr")," auf data.tg.ch."),
  tags$img(src = "wahlbeteiligung.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_7,"shinydata/modal_7.rds")




modal_8 <- modalDialog(
  title = tags$b("Weiterführende Informationen"),
  p("Über die Links gelangen Sie zu weiteren Daten und Informationen der Dienststelle für Statistik zu den Grossratswahlen 2024 im Thurgau."),
  tags$img(src = "links.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_8,"shinydata/modal_8.rds")




modal_9 <- modalDialog(
  title = tags$b("Offene Daten, offener Code"),
  p("Den Code sowie alle verwendeten Daten und deren Beschreibung finden Sie auf Github. Dazu können Sie einfach auf den schwarzen Button am Ende der Seite klicken."),
  tags$img(src = "github.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_9,"shinydata/modal_9.rds")





modal_10 <- modalDialog(
  title = tags$b("Panaschierstatistik"),
  p("Die Panaschierstatistik gibt an wie viele Panaschierstimmen pro 1000 Wahlzettel der Herkunftspartei und pro kandiderender Person der Empfängerpartei fliessen. Die genaue Berechnung kann ",
    tags$a("Konzepte zur Analyse der Panaschierstatistik (Burger 2001)", href = "https://www.bfs.admin.ch/bfsstatic/dam/assets/337885/master"),
    " entnommen werden. Die Datensätze aus denen diese Werte berechnet wurden finden sich ",tags$a("hier",href = "https://data.tg.ch/explore/?q=Panaschierstatistik+2024&sort=title")," auf data.tg.ch"),
  tags$img(src = "panaschier.PNG", width = "100%"),
  footer = list(actionButton("last_modal", label = "Zurück"),actionButton("next_modal", label = "Weiter"), modalButton("Schliessen")),
  fade = FALSE

)

saveRDS(modal_10,"shinydata/modal_10.rds")


# start modal

modal_start <- modalDialog(
  title = tags$b("Herzlich Willkommen beim Wahlspiegel 2024"),
  p("Auf diesem Dashboard können die Parteistärke, die Veränderung der Parteistärke im Zeitverlauf sowie die Wahlbeteiligung der 80 Thurgauer Gemeinden bei den Grossratswahlen 2024 miteinander verglichen werden.
            Wählen Sie über die Seitenleiste zwei Gemeinden zum Vergleich aus und klicken Sie sich durch unsere Daten."),
  p("Sollten Sie eine nähere Einführung in die Funktionsweise benötigen, klicken Sie  auf den Button 'Tutorial starten'."),
  br(),
  p("Das Team der Dienststelle für Statistik wünscht Ihnen viele wertvolle Erkenntnisse!"),
  tags$img(src = "dashboard.gif", width = "100%"),
  footer = list(actionButton("close_modal_start","Los geht's")),
  fade = TRUE,
  size = "l",
  easyClose = F

)

saveRDS(modal_start,"shinydata/modal_start.rds")
