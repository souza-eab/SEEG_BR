# About SEEG c9 [Estimates.R](https://github.com/souza-eab/SEEG_BR/blob/main/2._Estimates/Estimates_v0.R)
  Script for the calculations of emissions and removals by applying stocks and increment values to the transitions areas obtained in the previous steps of the land-use sector method.

Created by: Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza

For clarification or an issue/bug report, please write to barbara.zimbres@ipam.org.br and/or edriano.souza@ipam.org.br
Key activities in sections

## Setting your project.R 
```javascript
## Setting your project.R 
```
## Requerid packages
```javascript
library(pacman)
pacman::p_load(usethis, geojsonR, jsonlite, googledrive, openxlsx, ggplot2, tidyverse, tidyr, dplyr, rlang)
``` 
# Base file with codes for biome (bioma) and states (estado)
```javascript
# e.g.
# biomasestados <- read.csv("../biomas_estados.csv")
biomasestados <- read.csv("data/aux_data/biomas_estados.csv")

# Folder containing the GeoJSON files
folder <- "data/SEEG_c9_v1"
```
## Recode GeoJson && .csv // <Processing 2H> //
```javascript
# Base files of the transitions
# containing the information: code of the municipality (codigo), code of the biome/state (codigobiomasestados),
# biome (bioma), state (estado), protected area (ap, 1 or 0), year of the transition (periodo),
# class transitioned from (de) and to (para), and area of the transition (area_ha, in hectares)

biomasestado.data <- list.files(folder, full.names = TRUE) %>%
  map_df(function (file) {
    dt = fromJSON(file,flatten = TRUE, simplifyDataFrame = TRUE)$features
    1:length(dt$properties.featureid) %>% 
      map_df(function(x) {
        if(ncol(dt$properties.data[[x]] %>% as.tibble())==0) {
          dt$properties.data[[x]] = tibble(V1=NA, V2 = NA)
        }
        as.tibble(dt$properties.data[[x]]) %>%
          mutate(codigo = dt$properties.featureid[x],
                 biomasestados =  as.numeric(str_sub(dt$properties.featureid[x],1,3)),
                 areaprotegida = dt$properties.AP[x],
                 periodo = sprintf("%s a %s", 
                                   str_sub(dt$properties.ANO[x], 1,4), 
                                   str_sub(dt$properties.ANO[x], 5,8)),
                 para = V1 %% 10000, de = (V1-para)/10000)
      })
  })%>% 
  left_join(biomasestados, by = c("biomasestados"="id"))%>%
  select(codigo, codigobiomasestados = biomasestados, bioma = descricaobiomas, estado = descricaoestados, ap=areaprotegida, periodo, de, para, 
         area_ha = V2) %>%
  mutate(area_ha = area_ha*100)
```

## 0_Exporting intermediate file && Rearranging the table
```javascript
write.csv(biomasestado.data, file = "Results/1_0_Dadosbrutos.csv", row.names = F, fileEncoding = "UTF-8")
tran_mun <- biomasestado.data %>%
  arrange(codigo, periodo, de, para) %>%
  spread(key = periodo, value = area_ha, fill = 0) %>%
  filter(!is.na(bioma))

### ReClass matching Mapbiomas ---------------------------------------------------
# Reclassify some of the agriculture classes from MapBiomas to group them into less detailed classes (e.g. classes 46-48 into 36)
# and remove secondary identification (*100) from anthropic classes <more_information>
tran_mun <- tran_mun %>%
  mutate(de = recode(de,
                     `0` = "0", `3` = "3", `4` = "4", `5` = "5", `9` = "9", `11` = "11", `12` = "12", `13` = "13", `15` = "15", `20` = "20",
                     `21` = "21", `23` = "23", `24` = "24", `25` = "25", `29` = "29", `30` = "30", `31` = "31", `33` = "33", `39` = "39",
                     `40` = "39", `41` = "41", `46` = "36", `47` = "36", `48` = "36", `49` = "49", `300` = "300", `400` = "400",
                     `500` = "500", `900` = "9", `1100` = "1100", `1200` = "1200", `1300` = "1300", `1500` = "1500",
                     `2000` = "20", `2100` = "21", `2500` = "25", `2900` = "29", `3300` = "33", `3900` = "39",
                     `4000` = "39", `4100` = "41", `4600` = "36", `4700` = "36", `4800` = "36",
                     `4900` = "49"
  )) %>%
  mutate(para = recode(para,
                       `0` = "0", `3` = "3", `4` = "4", `5` = "5", `9` = "9", `11` = "11", `12` = "12", `13` = "13", `15` = "15", `20` = "20",
                       `21` = "21", `23` = "23", `24` = "24", `25` = "25", `29` = "29", `30` = "30", `31` = "31", `33` = "33",
                       `39` = "39", `40` = "39", `41` = "41", `46` = "36", `47` = "36", `48` = "36", `49` = "49",
                       `300` = "300", `400` = "400", `500` = "500", `900` = "9", `1100` = "1100",
                       `1200` = "1200", `1300` = "1300", `1500` = "1500", `2000` = "20",
                       `2100` = "21", `2500` = "25", `2900` = "29", `3300` = "33",
                       `3900` = "39", `4000` = "39", `4100` = "41",
                       `4600` = "36", `4700` = "36",
                       `4800` = "36", `4900` = "49"
  ))

```
### 1_Exporting intermediate file 
```javascript
write.csv(tran_mun, file = "Results/1_0_DadosbrutosRECT.csv", row.names = F, fileEncoding = "UTF-8") # !!!
```
## List of classes Mapbiomas (Collection 6) present in each biome 
```javascript
### Amazon ------------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "AMAZONIA"])))
classesAM <- c(
  3, # Forest Formation
  4, # Savanna Formation
  5, # Mangrove
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  15, # Pasture
  20, # Sugar cane
  21, # Mosaic Agriculture and Pasture
  23, # Beach, Dune and Sand Spot
  24, # Urban Area
  25, # Other non Vegetaded Areas
  30, # Mining
  31, # Aquaculture
  33, # River,Lake and Ocean,
  39, # Soybean
  36, # Perennial Corp
  41, # Other temporary Crops
  300,
  400,
  500,
  1100,
  1200
)

### Cerrado -----------------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "CERRADO"])))
classesCE <- c(
  3, # Forest Formation
  4, # Savanna Formation
  5, # Mangrove
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  15, # Pasture
  20, # Sugar cane
  21, # Mosaic Agriculture and Pasture
  23, # Beach, Dune and Sand Spot
  24, # Urban Area
  25, # Other non Vegetaded Areas
  30, # Mining
  31, # Aquaculture
  33, # River,Lake and Ocean
  36, # Perennial Corp
  39, # Soybean
  41, # Other temporary Crops
  300,
  400,
  500,
  1100,
  1200
)

### Atlantic Forest ---------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "MATA ATLANTICA"])))
classesMA <- c(
  3, # Forest Formation
  4, # Savanna Formation
  5, # Mangrove
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  13, # Other non Forest Formation
  15, # Pasture
  20, # Sugar cane
  21, # Mosaic Agriculture and Pasture
  23, # Beach, Dune and Sand Spot
  24, # Urban Area
  25, # Other non Vegetaded Areas
  29, # Rocky Outcrop
  30, # Mining
  31, # Aquaculture
  33, # River,Lake and Ocean
  36, # Perennial Corp
  39, # Soybean
  41, # Other temporary Crops
  49, # Wooded Restinga
  300,
  400,
  500,
  1100,
  1200,
  1300,
  4900
)

### Caatinga ----------------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "CAATINGA"])))
classesCA <- c(
  3, # Forest Formation
  4, # Savanna Formation
  5, # Mangrove
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  15, # Pasture
  20, # Sugar cane
  21, # Mosaic Agriculture and Pasture
  23, # Beach, Dune and Sand Spot
  24, # Urban Area
  25, # Other non Vegetaded Areas
  29, # Rocky Outcrop
  30, # Mining
  31, # Aquaculture
  33, # River,Lake and Ocean
  36, # Perennial Corp
  39, # Soybean
  41, # Other temporary Crops
  300,
  400,
  500,
  1200,
  1300
)

### Pantanal ----------------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "PANTANAL"])))
classesPN <- c(
  3, # Forest Formation
  4, # Savanna Formation
  5, # Mangrove
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  15, # Pasture
  20, # Sugar cane
  21, # Mosaic Agriculture and Pasture
  24, # Urban Area
  25, # Other non Vegetaded Areas
  30, # Mining
  33, # River,Lake and Ocean
  39, # Soybean
  41, # Other temporary Crops
  300,
  400,
  1100,
  1200
)

### Pampa -------------------------------------------------------------------
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "PAMPA"])))
classesPM <- c(
  3, # Forest Formation
  9, # Forest Plantation
  11, # Wetlands
  12, # Grassland
  15, # Pasture
  21, # Mosaic Agriculture and Pasture  23,
  24, # Urban Area
  25, # Other non Vegetaded Areas
  29, # Rocky Outcrop
  30, # Mining
  31, # Aquaculture
  33, # River,Lake and Ocean
  39, # Soybean
  41, # Other temporary Crops
  300,
  1100,
  1200
)

# Vetor
biomas <- c(
  "AMAZONIA", "CAATINGA", "CERRADO", "MATA_ATLANTICA",
  "PAMPA", "PANTANAL"
)
``````

## Correspondence between Mapbiomas classes and the classes from 4NI
``````javascript
# Correspondence between Mapbiomas classes and the classes from the Fourth National Inventory
FM <- c(3, 4, 5, 49)
FNM <- c(3, 4, 5, 49)
FSec <- c(300, 400, 500, 4900)
GM <- c(11, 12, 13)
GNM <- c(11, 12, 13)
GSec <- c(1100, 1200, 1300)
Ref <- 9

Ac <- c(20, 21, 36, 39, 41)
Ap <- 15
O <- c(23, 24, 25, 29, 30, 31, 33)

classes <- sort(unique(c(FM, FNM, FSec, Ref, GM, GNM, GSec, Ac, Ap, O)))
uso <- sort(unique(c(Ref, Ac, Ap, O)))
nat <- c(FM, GM, FSec, GSec)
``````
## Stocks in the Cerrado biome vary according to state
``````javascript
estadosCerrado <- c(
  "BA",
  "DF",
  "GO",
  "MA",
  "MT",
  "MS",
  "MG",
  "PA",
  "PR",
  "PI",
  "SP",
  "TO"
)

estados_cer <- sort(c(
  "BAHIA",
  "DISTRITO FEDERAL",
  "GOIAS",
  "MARANHAO",
  "MINAS GERAIS",
  "MATO GROSSO DO SUL",
  "MATO GROSSO",
  "PARA",
  "PIAUI",
  "PARANA",
  "SAO PAULO",
  "TOCANTINS"
))


colnames(tran_mun) <- c(
  "codigo", "codigobiomasestados", "bioma", "estado", "ap", "de", "para",
  "X1989.a.1990", "X1990.a.1991",
  "X1991.a.1992", "X1992.a.1993",
  "X1993.a.1994", "X1994.a.1995",
  "X1995.a.1996", "X1996.a.1997",
  "X1997.a.1998", "X1998.a.1999",
  "X1999.a.2000", "X2000.a.2001",
  "X2001.a.2002", "X2002.a.2003",
  "X2003.a.2004", "X2004.a.2005",
  "X2005.a.2006", "X2006.a.2007",
  "X2007.a.2008", "X2008.a.2009",
  "X2009.a.2010", "X2010.a.2011",
  "X2011.a.2012", "X2012.a.2013",
  "X2013.a.2014", "X2014.a.2015",
  "X2015.a.2016", "X2016.a.2017",
  "X2017.a.2018", "X2018.a.2019", "X2019.a.2020"
)
``````
### Aggregate and sum the transition areas according to the zones
``````javascript
# Aggregate and sum the transition areas according to the zones (municipalities, states, biomes and protected areas)
tran_mun <- tran_mun %>%
  group_by(
    codigo,
    codigobiomasestados, bioma, estado, ap, de, para
  ) %>%
  summarise(
    X1989.a.1990 = sum(X1989.a.1990), X1990.a.1991 = sum(X1990.a.1991),
    X1991.a.1992 = sum(X1991.a.1992), X1992.a.1993 = sum(X1992.a.1993),
    X1993.a.1994 = sum(X1993.a.1994), X1994.a.1995 = sum(X1994.a.1995),
    X1995.a.1996 = sum(X1995.a.1996), X1996.a.1997 = sum(X1996.a.1997),
    X1997.a.1998 = sum(X1997.a.1998), X1998.a.1999 = sum(X1998.a.1999),
    X1999.a.2000 = sum(X1999.a.2000), X2000.a.2001 = sum(X2000.a.2001),
    X2001.a.2002 = sum(X2001.a.2002), X2002.a.2003 = sum(X2002.a.2003),
    X2003.a.2004 = sum(X2003.a.2004), X2004.a.2005 = sum(X2004.a.2005),
    X2005.a.2006 = sum(X2005.a.2006), X2006.a.2007 = sum(X2006.a.2007),
    X2007.a.2008 = sum(X2007.a.2008), X2008.a.2009 = sum(X2008.a.2009),
    X2009.a.2010 = sum(X2009.a.2010), X2010.a.2011 = sum(X2010.a.2011),
    X2011.a.2012 = sum(X2011.a.2012), X2012.a.2013 = sum(X2012.a.2013),
    X2013.a.2014 = sum(X2013.a.2014), X2014.a.2015 = sum(X2014.a.2015),
    X2015.a.2016 = sum(X2015.a.2016), X2016.a.2017 = sum(X2016.a.2017),
    X2017.a.2018 = sum(X2017.a.2018), X2018.a.2019 = sum(X2018.a.2019),
    X2019.a.2020 = sum(X2019.a.2020)
  ) %>%
  ungroup()

tran_mun <- data.frame(tran_mun)

tran_mun$bioma <- as.factor(tran_mun$bioma)
tran_mun$estado <- as.factor(tran_mun$estado)
tran_mun$ap <- as.factor(tran_mun$ap)
tran_mun$de <- as.factor(tran_mun$de)
tran_mun$para <- as.factor(tran_mun$para)
levels(tran_mun$bioma) <- c("AMAZONIA", "CAATINGA", "CERRADO", "MATA_ATLANTICA", "PAMPA", "PANTANAL")
``````
### Checking biome area quantified 
``````javascript
nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "AMAZONIA", ])

nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "CERRADO", ])

nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "CAATINGA", ])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "MATA_ATLANTICA", ])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "PAMPA", ])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1 &
                tran_mun$bioma == "PANTANAL", ])
                
# Selecting only those transition types that make sense for each given biome
tran_mun <- tran_mun[(tran_mun$para %in% classes), ]
tran_mun <- tran_mun[(tran_mun$de %in% classes), ]
``````
### Relate transitions involving forest in the Cerrado with each state 

``````javascript
# Relate transitions involving forest in the Cerrado with each state (keep UF=others for the other biomes)
# UF = unit of the federation
tran_mun$uf <- "OUTROS"

for (i in 1:length(estadosCerrado)) {
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$de == 3, "uf"] <- estadosCerrado[i]
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$para == 3, "uf"] <- estadosCerrado[i]
}
``````

### Remove transitions of very small areas (< 1ha)

``````javascript
tran_mun <- tran_mun[!!rowSums(abs(tran_mun[(names(tran_mun) %in% c(
  "X1989.a.1990", "X1990.a.1991", "X1991.a.1992",
  "X1992.a.1993", "X1993.a.1994", "X1994.a.1995",
  "X1995.a.1996", "X1996.a.1997", "X1997.a.1998",
  "X1998.a.1999", "X1999.a.2000", "X2000.a.2001",
  "X2001.a.2002", "X2002.a.2003", "X2003.a.2004",
  "X2004.a.2005", "X2005.a.2006", "X2006.a.2007",
  "X2007.a.2008", "X2008.a.2009", "X2009.a.2010",
  "X2010.a.2011", "X2011.a.2012", "X2012.a.2013",
  "X2013.a.2014", "X2014.a.2015", "X2015.a.2016",
  "X2016.a.2017", "X2017.a.2018", "X2018.a.2019", "X2019.a.2020"
))])) > 1, ]

``````

## Importing auxiliary data (Stock and increment tables)

``````javascript
stk <- read.csv(file = "data/aux_data/estoques_biomas_QCN.csv", header = TRUE, sep = ";")
cer_uf <- read.table(file = "data/aux_data/estoques-floresta-cer-uf_QCN.txt", header = T)
incr <- read.csv(file = "data/aux_data/incremento_QCN.csv", header = TRUE, sep = ";")

``````

### Rearranging stock table -------------------------------------------------
``````javascript
bio <- rep(stk$Bioma, each = 12)
estq <- reshape(stk,
                varying = list(colnames(stk[-1])),
                times = names(stk[-1]),
                timevar = "classe",
                idvar = "Bioma",
                ids = stk$Bioma,
                direction = "long"
)
rownames(estq) <- NULL
colnames(estq)[3] <- "estoque"
head(estq, 72)

### Rearranging increment table -------------------------------------------------
inc <- reshape(incr,
               varying = list(colnames(incr[-1])),
               times = names(incr[-1]),
               timevar = "classe",
               idvar = "Bioma",
               ids = incr$Bioma,
               direction = "long"
)
rownames(inc) <- NULL
colnames(inc)[3] <- "incremento"
head(inc)
``````

### 2_Exporting intermediate file
``````javascript
# Exporting intermediate file
write.csv(tran_mun, "Results/2_tran_mun_intermediario.csv", row.names = F, fileEncoding = "UTF-8")
``````

## Function SEEG built to associate the 4NI equation witch each  
``````javascript
#' Title: Function built to associate the Inventory equations with each transition type
#'
#' @param t1 class transition_time1
#' @param t2 class transition_time2
#' @param bi biomes
#' @param uf states
#' @param ap protected áreas
#'
#' @return
#' @export
#'
#' @examples
seeg <- function(t1, t2, bi, uf, ap) {
``````
