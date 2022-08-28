library(shinyjs)
library(leaflet.extras2)
library(scales)
library(shinymanager)
library(shinydashboard)
library(dplyr)
library(tidyverse)
library(tidytext)
library(DT)
library(plotly)
library(ggplot2)
library(rjson)
library(tm)
library(data.table)
library(htmltools)
library(data.tree)
library(tidyr)
library(reshape2)
library(stringr)
library(plyr)
library(dplyr)
library(shinyBS)
library(tableHTML)
library(htmlwidgets)
library(shiny)
library(shinythemes)
library(leaflet.extras)
library(plotly)
library(leaflet)
library(shinydashboardPlus)
library(DT)
library(data.table)
library(dashboardthemes)
library(shinyWidgets)
library(sf)
library(readr)
library(apputils)
library(shinycustomloader)
library(shinyalert)
library(treemap)
library(d3treeR)









css <- "
.nowrap {
  white-space: nowrap;
}"


dataset1 <- read_delim("mappadat.csv", 
                       ";", escape_double = FALSE, col_types = cols(Latitude = col_number(), 
                                                                    Longitude = col_number(), Year = col_number()), 
                       trim_ws = TRUE)

df_reasons_all <- read_delim("df_reasons_all.csv", 
                             delim = ";", escape_double = FALSE, col_types = cols(Year = col_number(), 
                                                                                  freq = col_number(), id = col_number()), 
                             trim_ws = TRUE)

df_party_all <- read_delim("df_party_all.csv", 
                           delim = ";", escape_double = FALSE, col_types = cols(Year = col_number(), 
                                                                                freq = col_number()), trim_ws = TRUE)

df_reasons_all<-as.data.frame(df_reasons_all)
df_reasons_all<-as.data.table(df_reasons_all)

df_party_all<-as.data.frame(df_party_all)
df_party_all<-as.data.table(df_party_all)

dataset1 <- data.table(dataset1)
loc <- unique(dataset1$Revolt)
Location <- c(dataset1$Revolt)
Latitude <- c(dataset1$Latitude)
Longitude <- c(dataset1$Longitude)
Synopsis <-c(dataset1$Synopsis)
Start <-c(dataset1$`Date/ start`)
End <-(dataset1$`Date/ end`)
Reasons <-(dataset1$Reasons)
Revolt <- (dataset1$Revolt)
Year <-(dataset1$Year)
Country <- (dataset1$Country)
Continent <- (dataset1$Continent)
Monarchy <- (dataset1$Monarchy)
DF <- data.frame(Location,Latitude,Longitude,Synopsis,Start, End, Monarchy,Reasons)
names <- dataset1$identitynew
revolts <-dataset1$Revolt
books <-dataset1$References
DFgraph <- data.frame(Year, Revolt, Monarchy, Country,Continent)


names <- dataset1$identitynew
revolts <-dataset1$Revolt
books <-dataset1$References

reasons <- c("Anti-colonial", "Labour Conditions", "Anti-seigneurial", "Political", "Freedom",  "Multiple", "Religion", "Fiscal", "Natural resources", "Food", "Economic reforms", "Others")



actors <- c("Indigenous", "Local elites", "Artisans", "Peasants", "Soldiers", "Settlers/Colonists", "Enslaved", "Maroons",   "Clergymen", "Undifferentiated", "Africans",   "Women",  "Workers",   "Muncipal Council / Cabildo", "Others")

markerColorPalette <- c("red", "green", "lightred", "orange", "beige", "darkgreen", "lightgreen", "blue", "darkblue", "lightblue", "purple", "darkpurple", "pink", "cadetblue", "white", "gray", "lightgray", "black")

pal <- colorFactor(c("navy", "red"), domain = c("Spanish", "Portuguese"))

ui<-fluidPage(
  theme = shinytheme("cosmo"),
  
  
  chooseSliderSkin("Flat", color = "#cc3429"),
  sidebarLayout(position = "left", fluid = T,
                sidebarPanel(style = "overflow-y:scroll; height: 800px; width: 200px, position:relative;",
                             h4('Filters'),
                             h5("Switch between custom and historical mode. In historical mode borders on the map are changing in accordance with time period. In custom mode map setting is manual"),
                             prettySwitch(
                               inputId = "mode",
                               label = "Historical mode map off/on:",
                               slim = TRUE
                             ),
                             h5("In the sidebar you can choose and combine several criteria and different categories. For example, you can select 'Spanish Monarchy', 'Political Reasons' and 'Local Elites' and see on the map, what events happened at this particular period and correspond to these choises. You can choose years on the slider below the map"), 
                             h5('Click on the "Earth" in the left corner of the map and choose a map with border of different time periods. Maps are taken from DARIAH Geo Browser https://ref.de.dariah.eu/geoserver/web/'),
                             bsCollapse(id = "collapseExample1", open = "Choose the Monarchy",
                                        bsCollapsePanel("Choose the Monarchy", style = "danger",
                                                        selectInput(inputId="columnSelect", label="Colorize icons", choices=c('Monarchy','Country')),
                                                        
                                                        prettyCheckboxGroup(
                                                          inputId = "choice",
                                                          thick = TRUE,
                                                          label=h4("Monarchy"),
                                                          choices = c(unique(as.character(dataset1$Monarchy))),
                                                          selected = c('Portuguese', 'Spanish'),
                                                          status = "default"
                                                          
                                                        ))),
                             bsCollapse(id = "collapseExample2", open = "Choose the Reason",
                                        bsCollapsePanel("Choose the Reason", style = "warning",
                                                        actionButton("select_reasons","Select All"),
                                                        prettyCheckboxGroup(inputId="reasons",label="", 
                                                                            choices=c(reasons),
                                                                            selected = c(reasons)))),
                             
                             bsCollapse(id = "collapseExample3", open = "Choose the Participants",
                                        bsCollapsePanel("Choose the Participants", style = "success",
                                                        actionButton("select_actors","Select All"),
                                                        prettyCheckboxGroup(inputId="actors",label="", 
                                                                            choices=c(actors),
                                                                            selected=c(actors))))),                                  
                mainPanel(tags$style(type = "text/css", "#map {height: calc(90vh - 80px) !important;}"),
                          withLoader(leafletOutput("map"), type = 'html', loader = 'loader4'),
                          p(),
                          useShinyalert(),
                          fluidRow(
                            chooseSliderSkin("Flat"),
                            
                            sliderInput(
                              chooseSliderSkin("Flat"),
                              
                              width = '300%',
                              inputId = "range",
                              min=min(dataset1$Year), max=max(dataset1$Year),
                              value=c(min(dataset1$Year),max(dataset1$Year)), sep = ""
                              
                            )                 )
                )
  ))

server <- function(input, output, session) { 
  
  
  
  ##############selectors##########
  
  observe({
    if(input$select_actors == 0) return(NULL) 
    else if (input$select_actors%%2 == 0)
    {
      updatePrettyCheckboxGroup(session,"actors","",choices=actors)
    }
    else
    {
      updatePrettyCheckboxGroup(session,"actors","",choices=actors,selected=actors)
    }
  })
  
  observe({
    if(input$select_reasons == 0) return(NULL) 
    else if (input$select_reasons%%2 == 0)
    {
      updatePrettyCheckboxGroup(session,"reasons","",choices=reasons)
    }
    else
    {
      updatePrettyCheckboxGroup(session,"reasons", "",choices=reasons,selected=reasons)
    }
  })
  

  
  
  #########map########
  
  dsub <- reactive({
    MatSearch <- paste0(c('xxx',input$reasons),collapse = "|")
    MatSearch <- gsub(",","|",MatSearch)
    ActSearch <- paste0(c('xxx',input$actors),collapse = "|")
    ActSearch <- gsub(",","|",ActSearch)
    dataset1[dataset1$Year >= input$range[1] & dataset1$Year <= input$range[2] & grepl(MatSearch,Reasons) & grepl(ActSearch,Participants) & Monarchy %in% input$choice ]
    
  })
  
  
  icons <- reactive({
    columnLevels <- unique(dataset1[[input$columnSelect]])
    colorDT <- data.table(columnLevels = columnLevels, levelColor = markerColorPalette[seq(length(columnLevels))])
    setnames(colorDT, "columnLevels", input$columnSelect)
    dataset1 <- colorDT[dsub(), on = input$columnSelect]
    
    icons <- awesomeIcons(
      icon = 'fire',
      iconColor = 'black',
      library = 'glyphicon',
      markerColor = dataset1$levelColor
    )
    
    return(icons)
  })
  
  
  
  
  observe({
    if(nrow(dsub())==0) {
      leafletProxy("map") %>%
        clearMarkers()
    } else { #print(paste0("Selected: ", unique(input$InFlags&input$InFlags2)))
      leafletProxy("map", data=dsub()) %>% 
        
        clearMarkers()%>% 
        addAwesomeMarkers(
          data = dsub(), layerId = dsub()$id, lng = ~Longitude, lat = ~Latitude, label = dsub()$Revolt, icon=icons(),
          popup =
            paste0('<font face="helvetica"',
                   '<font size="3">', '<strong>', dsub()$Revolt, '</strong>', '</font>',
                   '<br/>','<strong>', 'Year: ', '</strong>', dsub()$Year, 
                   '<br/>','<strong>', 'Leaders: ', '</strong>', dsub()$Leaders,
                   '<br/>','<strong>', 'Reason: ','</strong>', dsub()$Reasons,
                   '<br/>','<strong>', 'Participants: ','</strong>', dsub()$Participants,
                   
                   '<br/>', dsub()$Synopsis,' ',
                   '</font>',' ',
                   actionButton("showmodal", "Expand to show more details", 
                                onclick = 'Shiny.onInputChange("button_click1",  Math.random())'))
          
        ) 
      
    }
  })
  
  
  
  observeEvent(input$mode, {
    if(input$mode == T){
      output$map <- renderLeaflet({
        req(icons())
        if(input$range <= 1530){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'EuropaUniversalisFull',
              "https://ref.de.dariah.eu/geoserver/historic/wms",
              layers = "historic:cntry1492",
              attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/")%>%
            setView(0, 0, zoom = 2)%>%
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }else if(input$range <= 1650){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'EU',
              "http://prova19century.nextgis.com/api/resource/11/wms",
              layers = "EU_New_map",
              options = WMSTileOptions(format = "image/png", transparent = TRUE, minZoom = 2, maxZoom = 10),
              attribution = "")%>%
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            setView(0, 0, zoom = 2)%>%
            
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }else if(input$range <= 1715){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'Map of 1650 borders',
              "https://ref.de.dariah.eu/geoserver/historic/wms",
              layers = "historic:cntry1650",
              attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/") %>%
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            setView(0, 0, zoom = 2)%>%
            
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }else if(input$range <= 1783){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'Map of 1715 borders',
              "https://ref.de.dariah.eu/geoserver/historic/wms",
              layers = "historic:cntry1715",
              attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/") %>% 
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            setView(0, 0, zoom = 2)%>%
            
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }else if(input$range <= 1800){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'Map of 1783 borders',
              "https://ref.de.dariah.eu/geoserver/historic/wms",
              layers = "historic:cntry1783",
              attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/") %>% 
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            setView(0, 0, zoom = 2)%>%
            
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }else if(input$range <= 1864){
          leaflet(dataset1) %>%
            addWMSTiles(
              group = 'Map of 1880 borders',
              "https://ref.de.dariah.eu/geoserver/historic/wms",
              layers = "historic:cntry1880",
              attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/") %>% 
            fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
            setView(0, 0, zoom = 2)%>%
            
            addAwesomeMarkers(
              layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
              popup =
                paste0('<font face="helvetica"',
                       '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                       '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                       '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                       '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                       '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                       
                       '<br/>', dataset1$Synopsis,' ',
                       
                       '</font>',' ',
                       actionButton("showmodal", "Expand to show more details", 
                                    onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        }
        
        
      })
    }else if(input$mode == F){
      output$map <- renderLeaflet({
        
        req(icons())
        leaflet(dataset1) %>% 
          addMapPane("left", zIndex = 0) %>%
          addMapPane("right", zIndex = 0) %>%
          addTiles(group = "base", layerId = "baseid",
                   options = pathOptions(pane = "right")) %>%
          addWMSTiles(
            group = '17th century map - Typys Orbis Terrarum',
            "http://prova19century.nextgis.com/api/resource/11/wms",
            layers = "Typys", layerId = "cartoid", options = pathOptions(pane = "left")) %>%
          addWMSTiles(
            group = '19th century world map',
            "http://prova19century.nextgis.com/api/resource/11/wms",
            layers = "modern",
            attribution = "", 
            layerId = "cart_id_3", 
            options = pathOptions(pane = "left")) %>% 
          addWMSTiles(
            group = 'Map of 1650 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1650",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/", 
            layerId = "cart_id_4", options = pathOptions(pane = "left")) %>%  
          addWMSTiles(
            group = 'Map of 1715 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1715",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/",
            layerId = "cart_id_5", options = pathOptions(pane = "left")) %>% 
          addWMSTiles(
            group = 'Map of 1783 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1783",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/",
            layerId = "cart_id_6", options = pathOptions(pane = "left")) %>% 
          addWMSTiles(
            group = 'Map of 1880 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1880",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/",
            layerId = "cart_id_7", options = pathOptions(pane = "left")) %>% 
          addWMSTiles(
            group = 'Map of 1492 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1492",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/",
            layerId = "cart_id_8", options = pathOptions(pane = "left")) %>% 
          addWMSTiles(
            group = 'Map of 1530 borders',
            "https://ref.de.dariah.eu/geoserver/historic/wms",
            layers = "historic:cntry1530",
            attribution = "Dariah-DE https://ref.de.dariah.eu/geoserver/web/",
            layerId = "cart_id_9", options = pathOptions(pane = "left")) %>% 
          
          addLayersControl(
            position = 'topright',
            baseGroups = c(
              'Map of 1492 borders',
              'Map of 1530 borders',
              'Map of 1650 borders',
              'Map of 1715 borders',
              'Map of 1783 borders',
              'Map of 1880 borders',
              '17th century map - Typys Orbis Terrarum',
              '19th century world map'
            )) %>%
          
          fitBounds(~min(Longitude), ~min(Latitude), ~max(Longitude), ~max(Latitude)) %>%
          addSidebyside(layerId = "sidecontrols",
                        rightId = "baseid",
                        leftId = c("cart_id_2", "cart_id_3", "cart_id_4", "cart_id_5", "cart_id_6", "cart_id_7", "cart_id_8", "cart_id_9"))%>%
          
          addAwesomeMarkers(
            layerId = dataset1$id, lng = ~Longitude, lat = ~Latitude, label = dataset1$Revolt, icon=icons(),
            popup =
              paste0('<font face="helvetica"',
                     '<font size="3">', '<strong>', dataset1$Revolt, '</strong>', '</font>',
                     '<br/>','<strong>', 'Year: ', '</strong>', dataset1$Year, 
                     '<br/>','<strong>', 'Leaders: ', '</strong>', dataset1$Leaders,
                     '<br/>','<strong>', 'Reason: ','</strong>', dataset1$Reasons,
                     '<br/>','<strong>', 'Participants: ','</strong>', dataset1$Participants,
                     
                     '<br/>', dataset1$Synopsis,' ',
                     
                     '</font>',' ',
                     actionButton("showmodal", "Expand to show more details", 
                                  onclick = 'Shiny.onInputChange("button_click",  Math.random())')))
        
        
      })
    }else{return}
  })
  
  
  
  observeEvent( input$button_click,{
    print("observed button_click and get id from map_marker_click$id")
    id <- input$map_marker_click$id
    shinyalert(
      html = TRUE,
      size = "l",
      closeOnEsc = TRUE,
      closeOnClickOutside = T,
      title = paste0(dataset1$Revolt[id]),
      text = tagList(
        fluidRow(style = "overflow-y:scroll; max-height: 500px",
                 box(                  
                   title = htmltools::span(
                     tags$img(src="https://sun9-3.userapi.com/c857728/v857728812/1b0048/M-yOUb8X7uw.jpg", width = '100%'), 
                     column(8, class="title-box")),
                   width=12, solidHeader = TRUE, status = "primary",
                   h3(renderText(dataset1$`Name in sources`[id])),
                   panel(infoBox(h3("Date"),renderText(dataset1$`Date/ start`[id]), renderText(dataset1$`Date/ end`[id]), color = "red", fill = T, width = 4),
                         infoBox(h3("Reasons"),renderText(dataset1$Reasons[id]), color = "red", fill = T, width = 4),
                         infoBox(h3("Participants"),renderText(dataset1$Participants[id]), color = "red", fill = T, width = 
                                   4),
                         infoBox(h3("Number of Participants"),renderText(dataset1$`Number of participants`[id]),  color = "red", fill = T, width = 
                                   4),
                         infoBox(h3("Leaders"),renderText(dataset1$Leaders[id]), color = "red", fill = T, width = 
                                   4)
                   )),
                 panel(
                   title = "Synopsis", solidHeader = TRUE, status = "danger",
                   renderText(dataset1$Synopsis[id])),
                 h4("Bibliography"),
                 panel(renderText(dataset1$References[id])),
                 h4("Author of the text"),
                 panel(renderText(dataset1$Author[id]))
        )
      )
      
    )
  })
  
  
  observeEvent( input$button_click1,{
    print("observed button_click and get id from map_marker_click$id")
    id <- input$map_marker_click$id
    shinyalert(
      html = TRUE,
      size = "l",
      closeOnEsc = TRUE,
      closeOnClickOutside = T,
      title = paste0(dataset1$Revolt[id]),
      text = tagList(
        fluidRow(style = "overflow-y:scroll; max-height: 500px",
                 box(                  
                   title = htmltools::span(
                     tags$img(src="https://sun9-3.userapi.com/c857728/v857728812/1b0048/M-yOUb8X7uw.jpg", width = '100%'), 
                     column(8, class="title-box")),
                   width=12, solidHeader = TRUE, status = "primary",
                   h3(renderText(dataset1$`Name in sources`[id])),
                   panel(infoBox(h3("Date"),renderText(dataset1$`Date/ start`[id]),renderText(dataset1$`Date/ end`[id]), color = "red", fill = T, width = 4),
                         infoBox(h3("Reasons"),renderText(dataset1$Reasons[id]), color = "red", fill = T, width = 4),
                         infoBox(h3("Participants"),renderText(dataset1$Participants[id]),  color = "red", fill = T, width = 
                                   4),
                         infoBox(h3("Number of Participants"),renderText(dataset1$`Number of participants`[id]),  color = "red", fill = T, width = 
                                   4),
                         infoBox(h3("Leaders"),renderText(dataset1$Leaders[id]), color = "red", fill = T, width = 
                                   4)
                   )),
                 panel(
                   title = "Synopsis", solidHeader = TRUE, status = "danger",
                   renderText(dataset1$Synopsis[id])),
                 h4("Bibliography"),
                 panel(renderText(dataset1$References[id])),
                 h4("Author of the text"),
                 panel(renderText(dataset1$Author[id]))
        )
      )
      
    )
  })
  
} 
shinyApp(ui, server)
