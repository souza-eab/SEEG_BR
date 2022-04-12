# About
SEEG - Script for the calculations of emissions and removals GHG_BR

Script for the calculations of emissions and removals by applying stocks and increment values to the transitions areas obtained in the previous steps of the land-use sector method.

Created by: 'Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza'.

For clarification or an issue/bug report, please write to barbara.zimbres@ipam.org.br and/or edriano.souza@ipam.org.br

Key activities in sections



```javascript
## Setting your project.R 

```


```javascript
## Requerid packages
library(pacman)
pacman::p_load(usethis, geojsonR, jsonlite, googledrive, openxlsx, ggplot2, tidyverse, tidyr, dplyr, rlang)
```


```javascript
## Reading the GeoJSON files
# biomasestados <- read.csv("../biomas_estados.csv")
biomasestados <- read.csv("data/aux_data/biomas_estados.csv")
# Folder containing the GeoJSON files
folder <- "data/SEEG_c9_v1"

```
