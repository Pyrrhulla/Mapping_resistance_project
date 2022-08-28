# Mapping Resistance

A project for visualization of the historical dataset of Revolutions and Rebellions in Iberian world in 15th-19th centuries. This is a part of [RESISTANCE – Rebellion and Resistance in the Iberian Empires, 16th-19th centuries. EU Horizon 2020 Research and Innovation Programme, Marie Skłodowska-Curie Grant Agreement n. 778076](http://www.resistance.uevora.pt)

A text project in shiny: https://alexandra-an.shinyapps.io/MappingResistance/ 

This project consists of two parts: 

**Map**

This part focuses on the spatial visualization of the revolutions and rebellions on the global historical level. 

The application board has the main part with the global map, which has two rendering options:

Firstly, a static historical maps, which can be chosen by a user. 

Secondly, a dynamic mapping, which is connected with a timeslider. Therefore, a map is changed in accordance with a chosen time period by the slider. The side part has three content filters -- participants, reasons, monarchy that specify a dataset for rendering on the map.

<img width="1440" alt="Снимок экрана 2022-08-28 в 20 10 51" src="https://user-images.githubusercontent.com/55465730/187088640-fec4b2e7-b051-42c1-bf2a-16a479fe599c.png">

The selection options for the map contains as vector maps (DARIAH historical maps) as raster maps (Typus Orbius Terrarum). For the released version a raster map with more detailed historical borders of the Iberian territories will be added instead of general maps. 

IMPORTANT! At this moment a new WMS server for hosting custom raster maps is under construction. 

![photo_2022-08-28 20 18 20](https://user-images.githubusercontent.com/55465730/187088811-66297d94-c2f0-4ada-ac31-73bd4a2e6c65.jpeg)

![photo_2022-08-28 20 18 15](https://user-images.githubusercontent.com/55465730/187088812-8c67176d-4c12-48f2-a51e-99f4752525b3.jpeg)

Each event calls a popup on click, which can be extended as a window with the information about the event. 

<img width="1440" alt="Снимок экрана 2022-08-28 в 21 22 16" src="https://user-images.githubusercontent.com/55465730/187091027-d12b9dbc-6074-4b16-bc8f-caac5dc3e853.png">

A popup example

<img width="1440" alt="Снимок экрана 2022-08-28 в 21 22 25" src="https://user-images.githubusercontent.com/55465730/187091026-01e15b91-14f6-42bd-a872-f839be10ca87.png">

A window example

A light test version:  https://alexandra-an.shinyapps.io/Presentation-map/

##Graph##

A graphic part aims to provide analytical instruments for the dataset of rebellions. The board has a similar structure as the map. 
The main part locates an interactive board, made with ggplot2 and its extensions. Y, X, Z axis provide the graph orientation settings. Filters with checkboxes aim to specify the render via adding and excluding groups of input. A user can select an area on the board and the results will appear in the data table below.
<img width="1440" alt="Снимок экрана 2022-08-28 в 21 13 20" src="https://user-images.githubusercontent.com/55465730/187090723-3c5f4420-692f-462d-a357-6dbafb102bad.png">

A side part provides options for setting filters and types of the graphs. At the first option, made in ggplot2, possible graphs include bubbles, bars, comparative tables and pie. 

<img width="1440" alt="Снимок экрана 2022-08-28 в 21 06 06" src="https://user-images.githubusercontent.com/55465730/187090666-a53e1a2d-b25b-46a3-9393-11954564aef0.png">

Bar graph example 

<img width="1440" alt="Снимок экрана 2022-08-28 в 21 05 56" src="https://user-images.githubusercontent.com/55465730/187090667-b82328bc-e02c-4303-b35a-265c2c4940b4.png">
Bubble graph exmple 


The second option is made with D3.js and provides treemaps render with responsive graphs, which are built in accordance with the main specification, such as reasons, participants, country/participants and country/reasons. 

<img width="1440" alt="Снимок экрана 2022-08-28 в 21 06 25" src="https://user-images.githubusercontent.com/55465730/187090730-8624c071-e4f2-4cd8-93f2-c4fe720e85e4.png">

Test app: https://alexandra-an.shinyapps.io/Presentation-graph/

All the results — the graph and data table can be downloaded as .png and .csv accordingly. 


##Encyclopaedia##

Encyclopaedia aims to provide the information about each particular event of the dataset. All events are sorted in chronological order.

Each event has a page with several panels: map, summary, additional information, further reading, author.
<img width="1440" alt="Снимок экрана 2022-08-28 в 21 20 28" src="https://user-images.githubusercontent.com/55465730/187091080-1fb47167-4cb6-49df-8938-ba09a79ef258.png">
<img width="930" alt="Снимок экрана 2022-08-28 в 21 20 40" src="https://user-images.githubusercontent.com/55465730/187091094-dd271a83-3c0a-414d-9f68-4ad61e755a36.png">

A map selection contains options of the contemporary map and historical map. 



