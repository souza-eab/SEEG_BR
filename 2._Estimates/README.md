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
## Recode GeoJson && .csv                           //Processing 2H //
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

## 0_Exporting intermediate file && 
```javascript
write.csv(biomasestado.data, file = "Results/1_0_Dadosbrutos.csv", row.names = F, fileEncoding = "UTF-8")
tran_mun <- biomasestado.data %>%
  arrange(codigo, periodo, de, para) %>%
  spread(key = periodo, value = area_ha, fill = 0) %>%
  filter(!is.na(bioma))
```
Rearranging the table
```javescript
### ReClass matching Mapbiomas 
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
## Organizing matrices with all possible transition cases
``````javascript
# (combinations of "de", "para", "ap", and "uf" in the case of forests in the Cerrado) per biome

mCER1 <- expand.grid(  t1 = classesCE,
                       t2 = classesCE,
                       bioma = "CERRADO",
                       uf = "OUTROS",
                       ap = 0,
                       stringsAsFactors = FALSE)


mCER2 <- expand.grid(  t1 = classesCE,
                       t2 = classesCE,
                       bioma = "CERRADO",
                       uf = "OUTROS",
                       ap = 1,
                       stringsAsFactors = FALSE)


mCER3 <- expand.grid(  t1 = c(3, 300),
                       t2 = classesCE,
                       bioma = "CERRADO",
                       uf = estadosCerrado,
                       ap = 0,
                       stringsAsFactors = FALSE)

mCER4 <- expand.grid(  t1 = classesCE,
                       t2 = c(3, 300),
                       bioma = "CERRADO",
                       uf = estadosCerrado,
                       ap = 0,
                       stringsAsFactors = FALSE)


mCER5 <- expand.grid(  t1 = c(3, 300),
                       t2 = classesCE,
                       bioma = "CERRADO",
                       uf = estadosCerrado,
                       ap = 1,
                       stringsAsFactors = FALSE)

mCER6 <- expand.grid(  t1 = classesCE,
                       t2 = c(3, 300),
                       bioma = "CERRADO",
                       uf = estadosCerrado,
                       ap = 1,
                       stringsAsFactors = FALSE)

mCA1 <- expand.grid(  t1 = classesCA,
                      t2 = classesCA,
                      bioma = "CAATINGA",
                      uf = "OUTROS",
                      ap = 0,
                      stringsAsFactors = FALSE)

mCA2 <- expand.grid(  t1 = classesCA,
                      t2 = classesCA,
                      bioma = "CAATINGA",
                      uf = "OUTROS",
                      ap = 1,
                      stringsAsFactors = FALSE)

mMA1 <- expand.grid(  t1 = classesMA,
                      t2 = classesMA,
                      bioma = "MATA_ATLANTICA",
                      uf = "OUTROS",
                      ap = 0,
                      stringsAsFactors = FALSE)

mMA2 <- expand.grid(  t1 = classesMA,
                      t2 = classesMA,
                      bioma = "MATA_ATLANTICA",
                      uf = "OUTROS",
                      ap = 1,
                      stringsAsFactors = FALSE)

mAM1 <- expand.grid(  t1 = classesAM,
                      t2 = classesAM,
                      bioma = "AMAZONIA",
                      uf = "OUTROS",
                      ap = 0,
                      stringsAsFactors = FALSE)


mAM2 <- expand.grid(  t1 = classesAM,
                      t2 = classesAM,
                      bioma = "AMAZONIA",
                      uf = "OUTROS",
                      ap = 1,
                      stringsAsFactors = FALSE)


mPM1 <- expand.grid(  t1 = classesPM,
                      t2 = classesPM,
                      bioma = "PAMPA",
                      uf = "OUTROS",
                      ap = 0,
                      stringsAsFactors = FALSE)


mPM2 <- expand.grid(  t1 = classesPM,
                      t2 = classesPM,
                      bioma = "PAMPA",
                      uf = "OUTROS",
                      ap = 1,
                      stringsAsFactors = FALSE)


mPN1 <- expand.grid(  t1 = classesPN,
                      t2 = classesPN,
                      bioma = "PANTANAL",
                      uf = "OUTROS",
                      ap = 0,
                      stringsAsFactors = FALSE)

mPN2 <-expand.grid(  t1 = classesPN,
                     t2 = classesPN,
                     bioma = "PANTANAL",
                     uf = "OUTROS",
                     ap = 1,
                     stringsAsFactors = FALSE)
``````
### Grouping all matrices 
``````javascript
matriz <- rbind(
  mCA1, mCA2,
  mPM1, mPM2,
  mAM1, mAM2,
  mMA1, mMA2,
  mCER1, mCER2, mCER3, mCER4, mCER5, mCER6,
  mPN1, mPN2
)
matriz <- matriz[!duplicated(matriz), ]
``````
## Applying function 'seeg' to attribute the specific equatio to each transition type
``````javasript
myTab <- data.frame(t(mapply(seeg, t1 = matriz$t1, t2 = matriz$t2, bi = matriz$bioma, uf = matriz$uf, ap = matriz$ap)))

for (i in 1:ncol(myTab)) {
  myTab[, i] <- unlist(myTab[, i])
}

myTab <- myTab[!duplicated(myTab), ]
colnames(myTab) <- c("t1", "t2", "bioma", "uf", "equacao", "ap", "nota", "processo")
``````
### Filtering out not inventoried cases
``````javascript
myTab <- myTab[myTab$nota != "not inventoried transition", ]
myTab[grep("NA", myTab$equacao), "equacao"] <- "class absent in the biome"
``````
### Matrices where the equations will be calculated to generate
``````javascript
# Matrices where the equations will be calculated to generate emission/removal estimates
emiss_mun <- tran_mun
emiss_mun$eq_inv <- "NULL"
emiss_mun$processo <- "NULL"
``````
## Applying calculations ---------------------------------------------------
``````javascript
for (i in 1:nrow(emiss_mun)) {
  print(paste0(i, "of", nrow(emiss_mun)))
  thisRow <- emiss_mun[i, ]
  eq <- as.character(myTab[myTab$t1 == thisRow$de &
                             myTab$t2 == thisRow$para &
                             as.character(myTab$bioma) == as.character(thisRow$bioma) &
                             as.character(myTab$uf) == as.character(thisRow$uf) &
                             myTab$ap == thisRow$ap, "equacao"])
  
  
  note <- as.character(myTab[myTab$t1 == thisRow$de &
                               myTab$t2 == thisRow$para &
                               as.character(myTab$bioma) == as.character(thisRow$bioma) &
                               as.character(myTab$uf) == as.character(thisRow$uf) &
                               myTab$ap == thisRow$ap, "nota"])
  
  processo <- as.character(myTab[myTab$t1 == thisRow$de &
                                   myTab$t2 == thisRow$para &
                                   as.character(myTab$bioma) == as.character(thisRow$bioma) &
                                   as.character(myTab$uf) == as.character(thisRow$uf) &
                                   myTab$ap == thisRow$ap, "processo"])
  
  if (length(eq) == 0 || length(processo) == 0) {
    emiss_mun[i, "eq_inv"] <- "not inventoried transition"
    emiss_mun[i, "processo"] <- "not inventoried transition"
  } else {
    emiss_mun[i, "eq_inv"] <- note
    emiss_mun[i, "processo"] <- processo
    eq <- sub("A\\*", "", eq) # [2])
    emiss_mun[i, !(names(emiss_mun) %in% c(
      "codigo",
      "codigobiomasestados",
      "bioma",
      "estado",
      "ap",
      "de",
      "para",
      "uf",
      "eq_inv",
      "processo"
    ))] <- paste(emiss_mun[i, !(names(emiss_mun) %in% c(
      "codigo",
      "codigobiomasestados",
      "bioma",
      "estado",
      "ap",
      "de",
      "para",
      "uf",
      "eq_inv",
      "processo"
    ))], "*", eq, sep = "")
    
    for (j in 1:ncol(emiss_mun[i, !(names(emiss_mun) %in% c(
      "codigo",
      "codigobiomasestados",
      "bioma",
      "estado",
      "de",
      "para",
      "uf",
      "eq_inv",
      "processo",
      "ap"
    ))])) {
      emiss_mun[i, j + 7] <- as.numeric(round(eval(parse(text = emiss_mun[i, j + 7]))))
    }
  }
}

# Definition of columns with annual estimates as numeric
emiss_mun[, 8:38] <- as.numeric(unlist(emiss_mun[, 8:38]))

``````

### 3_Exporting intermediate files ------

``````javascript
write.csv(emiss_mun, file = "3_emiss_mun_col6_municipios.csv")

``````

### Organizing resulting matrix 
``````javascript
emiss_mun_filt <- emiss_mun
emiss_mun_filt <- emiss_mun_filt[-grep("not inventoried transition", emiss_mun_filt$processo), ]
unique(emiss_mun_filt$processo)

# Generation oF the column "Atividade", differentiating the economic activity responsible for the transition (either CONSERVATION or PASTURE/AGRICULTURE
emiss_mun_filt$atividade <- NA
emiss_mun_filt$atividade[emiss_mun_filt$processo == "Removal in protected areas"] <- "CONSERV"
emiss_mun_filt$atividade[emiss_mun_filt$processo != "Removal in protected areas"] <- "AGROPEC"

# Generation oF the column "Tipo", differentiating between removal or emission
emiss_mun_filt$tipo <- NA
emiss_mun_filt[grep("Removal", emiss_mun_filt$processo), "tipo"] <- "Removal"
emiss_mun_filt[-grep("Removal", emiss_mun_filt$processo), "tipo"] <- "Emission"
``````
### Associating transitions considered in the National Inventory
``````javascript
simp <- read.csv(file = "data/aux_data/class_inv_simpl_eng.csv", header = TRUE, sep = ";")
emiss_mun_filt$transic <- emiss_mun_filt$eq_inv
emiss_mun_filt$transic <- gsub("[[:digit:]]", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub("\\.", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub(" ", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub("-", " -- ", emiss_mun_filt$transic)

for (i in 1:nrow(simp)) {
  emiss_mun_filt$transic <- gsub(simp$inv[i], simp$seeg[i], emiss_mun_filt$transic)
}

unique(paste(emiss_mun_filt$transic, emiss_mun_filt$eq_inv))

``````

### Organizing column order 
``````javascript
emiss_mun_filt <- emiss_mun_filt[, c(
  "processo", "bioma", "ap", "transic", "tipo", "estado", "atividade", "X1989.a.1990", "X1990.a.1991",
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
  "X2017.a.2018", "X2018.a.2019", "X2019.a.2020", "codigo",
  "codigobiomasestados", "de", "para", "uf", "eq_inv"
)]
``````

## Grouping and summarizing cases
``````javascript
emiss_aggr <- emiss_mun_filt %>%
  group_by(
    processo,
    bioma,
    ap,
    transic,
    tipo,
    codigo,
    codigobiomasestados,
    estado,
    atividade,
    de,
    para
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
  )
``````

### Building the final matrix in the format of SEEG
``````javascript
emiss_aggr$ano1970 <- 0
emiss_aggr$ano1971 <- 0
emiss_aggr$ano1972 <- 0
emiss_aggr$ano1973 <- 0
emiss_aggr$ano1974 <- 0
emiss_aggr$ano1975 <- 0
emiss_aggr$ano1976 <- 0
emiss_aggr$ano1977 <- 0
emiss_aggr$ano1978 <- 0
emiss_aggr$ano1979 <- 0
emiss_aggr$ano1980 <- 0
emiss_aggr$ano1981 <- 0
emiss_aggr$ano1982 <- 0
emiss_aggr$ano1983 <- 0
emiss_aggr$ano1984 <- 0
emiss_aggr$ano1985 <- 0
emiss_aggr$ano1986 <- 0
emiss_aggr$ano1987 <- 0
emiss_aggr$ano1988 <- 0
emiss_aggr$ano1989 <- 0
emiss_aggr$gases <- "CO2e (t) GWP-AR5"
emiss_aggr$SETOR <- "Land use change and forests"
emiss_aggr$LEVEL_5 <- "NA"
emiss_aggr$PRODUCT <- "NA"
newNames <- c(
  "LEVEL_2",
  "LEVEL_3",
  "LEVEL_4",
  "LEVEL_6",
  "TYPE",
  "CODIBGE",
  "CODBIOMASESTADOS",
  "STATE",
  "ECONOMIC_ACTIVITY",
  "DE",
  "PARA",
  "1990",
  "1991",
  "1992",
  "1993",
  "1994",
  "1995",
  "1996",
  "1997",
  "1998",
  "1999",
  "2000",
  "2001",
  "2002",
  "2003",
  "2004",
  "2005",
  "2006",
  "2007",
  "2008",
  "2009",
  "2010",
  "2011",
  "2012",
  "2013",
  "2014",
  "2015",
  "2016",
  "2017",
  "2018",
  "2019",
  "2020",
  "1970",
  "1971",
  "1972",
  "1973",
  "1974",
  "1975",
  "1976",
  "1977",
  "1978",
  "1979",
  "1980",
  "1981",
  "1982",
  "1983",
  "1984",
  "1985",
  "1986",
  "1987",
  "1988",
  "1989",
  "GAS",
  "SECTOR",
  "LEVEL_5",
  "PRODUCT"
)

i <- sapply(emiss_aggr, is.factor)
emiss_aggr[i] <- lapply(emiss_aggr[i], as.character)

str(emiss_aggr)
names(emiss_aggr)
names(emiss_aggr) <- newNames

emiss_aggr <- emiss_aggr[, c(
  "SECTOR", "LEVEL_2", "LEVEL_3", "LEVEL_4", "LEVEL_5", "LEVEL_6", "TYPE", "GAS", "CODIBGE",
  "CODBIOMASESTADOS", "STATE", "ECONOMIC_ACTIVITY", "PRODUCT", "DE", "PARA",
  "1970", "1971", "1972", "1973", "1974", "1975", "1976", "1977", "1978", "1979",
  "1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989",
  "1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999",
  "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009",
  "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"
)]
i <- sapply(emiss_aggr, is.factor)
emiss_aggr[i] <- lapply(emiss_aggr[i], as.character)

tabelao_full_mun <- emiss_aggr

# type
tabelao_full_mun$LEVEL_4 <- as.character(tabelao_full_mun$LEVEL_4)
tabelao_full_mun$LEVEL_5 <- as.character(tabelao_full_mun$LEVEL_5)
tabelao_full_mun$PRODUCT <- as.character(tabelao_full_mun$PRODUCT)
tabelao_full_mun$DE <- as.character(tabelao_full_mun$DE)
tabelao_full_mun$PARA <- as.character(tabelao_full_mun$PARA)
tabelao_full_mun$CODBIOMASESTADOS <- as.character(tabelao_full_mun$CODBIOMASESTADOS)
``````

### 4_ Exporting intermediate file ---------------------------------------------
``````javascript
write.csv(Results/tabelao_full_mun, file = "tabelao_full_col6.csv") # !!!
``````

## Classifying transitions that comprise deforestation 
``````javascript
# Definition of process type (SEEG LEVEL_5)
deforestation<-c("Primary forest -- Non vegetated area",
                 "Primary forest -- Planted forest",
                 "Primary forest -- Pasture/Agriculture",
                 "Secondary forest -- Non vegetated area",
                 "Secondary forest -- Planted forest",
                 "Secondary forest -- Pasture/Agriculture",
                 "Primary non forest vegetation -- Non vegetated area",
                 "Primary non forest vegetation -- Planted forest",
                 "Primary non forest vegetation -- Pasture/Agriculture",
                 "Secondary non forest vegetation -- Non vegetated area",
                 "Secondary non forest vegetation -- Planted forest",
                 "Secondary non forest vegetation -- Pasture/Agriculture")
regeneration<-c("Planted forest -- Secondary forest",
                "Planted forest -- Secondary non forest vegetation",
                "Pasture/Agriculture -- Secondary forest",
                "Pasture/Agriculture -- Secondary non forest vegetation",
                "Non vegetated area -- Secondary forest",
                "Non vegetated area -- Secondary non forest vegetation")
others<-c("Planted forest -- Non vegetated area",
          "Planted forest -- Pasture/Agriculture",
          "Pasture/Agriculture -- Non vegetated area",
          "Pasture/Agriculture -- Planted forest",
          "Pasture/Agriculture -- Pasture/Agriculture",
          "Non vegetated area -- Planted forest",
          "Non vegetated area -- Pasture/Agriculture")
stable<-c("Primary forest -- Primary forest",
          "Primary non forest vegetation -- Primary non forest vegetation",
          "Secondary forest -- Secondary forest",
          "Secondary non forest vegetation -- Secondary non forest vegetation")

tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  regeneration] <- "Regeneration"
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  stable] <- "Stable native vegetation"
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  deforestation] <- "Deforestation"
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  others] <- "Other types of land use change"
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 == "NA"] <- "NA"
``````

## Correction of the last year of the series
``````javascript
## Correction of the last year of the series based on the deforestation rates provided by official sources (PRODES Amazonia and PRODES Cerrado)
#Official rates are input as auxiliary tables

### PRODES rates at the level of biome --------------------------------------
prodesam_bi<-read.csv("data/aux_data/prodesam_bi.csv",head=T,sep=";")
prodesce_bi<-read.csv("data/aux_data/prodesce_bi.csv",head=T,sep=";")


### PRODES rates at the level of state (UF) ---------------------------------
prodesam_uf<-read.csv("data/aux_data/prodesam_uf.csv",head=T,sep=";")
prodesce_uf<-read.csv("data/aux_data/ prodesce_uf.csv",head=T,sep=";")
``````

### Linear regression between PRODES rates and the emissions by SEEG 
desm<-tabelao_full_mun[tabelao_full_mun$LEVEL_5=="Deforestation"& tabelao_full_mun$TYPE == "Emission",]

``````javascript

biomas_AUS<-desm%>%
  group_by(LEVEL_3) %>% 
  summarise(`X1970`=sum(`X1970`),`X1971`=sum(`X1971`),`X1972`=sum(`X1972`),`X1973`=sum(`X1973`),`X1974`=sum(`X1974`),`X1975`=sum(`X1975`),`X1976`=sum(`X1976`),
            `X1977`=sum(`X1977`),`X1978`=sum(`X1978`),`X1979`=sum(`X1979`),`X1980`=sum(`X1980`),`X1981`=sum(`X1981`),
            `X1982`=sum(`X1982`),`X1983`=sum(`X1983`),`X1984`=sum(`X1984`),`X1985`=sum(`X1985`),`X1986`=sum(`X1986`),`X1987`=sum(`X1987`),`X1988`=sum(`X1988`),`X1989`=sum(`X1989`),
            `X1990`=sum(`X1990`),`X1991`=sum(`X1991`),`X1992`=sum(`X1992`),`X1993`=sum(`X1993`),`X1994`=sum(`X1994`),`X1995`=sum(`X1995`),`X1996`=sum(`X1996`),`X1997`=sum(`X1997`),
            `X1998`=sum(`X1998`),`X1999`=sum(`X1999`),`X2000`=sum(`X2000`),`X2001`=sum(`X2001`),`X2002`=sum(`X2002`),`X2003`=sum(`X2003`),`X2004`=sum(`X2004`),`X2005`=sum(`X2005`),
            `X2006`=sum(`X2006`),`X2007`=sum(`X2007`),`X2008`=sum(`X2008`),`X2009`=sum(`X2009`),`X2010`=sum(`X2010`),`X2011`=sum(`X2011`),`X2012`=sum(`X2012`),`X2013`=sum(`X2013`),
            `X2014`=sum(`X2014`),`X2015`=sum(`X2015`),`X2016`=sum(`X2016`),`X2017`=sum(`X2017`),`X2018`=sum(`X2018`),`X2019`=sum(`X2019`),`X2020`=sum(`X2020`))

``````
#Final equations per biome
```javascript
#### Amazon ------------------------------------------------------------------
#Amazonia
summary(lm(t(biomas_AUS[1,22:51])~prodesam_bi$PRODES[1:30])) #a=173920094, b1= 49731, R2= 0.87

#### Cerrado -----------------------------------------------------------------
summary(lm(t(biomas_AUS[3,33:51])~prodesce_bi$PRODES[1:19])) #a=52829269, b1= 4828, R2= 0.80

```
#### Applying the equation to predict emissions in the final year
```javascript
#Applying the equation to predict emissions in the final year (2020)
am2020<-173920094+49731*prodesam_bi$PRODES[31]
ce2020<-52829269+4828*prodesce_bi$PRODES[20]

tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="AMAZONIA"& tabelao_full_mun$LEVEL_5=="Desmatamento"),66]<-
  tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="AMAZONIA"&tabelao_full_mun$LEVEL_5=="Desmatamento"),66]/
  sum(tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="AMAZONIA"&tabelao_full_mun$LEVEL_5=="Desmatamento"),66])*am2020
sum(tabelao_full_mun[tabelao_full_mun$LEVEL_3=="AMAZONIA"&tabelao_full_mun$LEVEL_5=="Desmatamento",66])

tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="CERRADO"&tabelao_full_mun$LEVEL_5=="Desmatamento"),66]<-
  tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="CERRADO"&tabelao_full_mun$LEVEL_5=="Desmatamento"),66]/
  sum(tabelao_full_mun[(tabelao_full_mun$LEVEL_3=="CERRADO"&tabelao_full_mun$LEVEL_5=="Desmatamento"),66])*ce2020

```

#### For the other biomes
```javascript
#For the other biomes, emissions in 2020 (related to deforestation) are assumed to be the same as in 2019
tabelao_full_mun[tabelao_full_mun$LEVEL_3=="CAATINGA"&tabelao_full_mun$LEVEL_5=="Deforestation",66]<-
  tabelao_full_mun[tabelao_full_mun$LEVEL_3=="CAATINGA"&tabelao_full_mun$LEVEL_5=="Deforestation",65]

tabelao_full_mun[tabelao_full_mun$LEVEL_3=="MATA_ATLANTICA"&tabelao_full_mun$LEVEL_5=="Deforestation",66]<-
  tabelao_full_mun[tabelao_full_mun$LEVEL_3=="MATA_ATLANTICA"&tabelao_full_mun$LEVEL_5=="Deforestation",65]

tabelao_full_mun[tabelao_full_mun$LEVEL_3=="PAMPA"&tabelao_full_mun$LEVEL_5=="Deforestation",66]<-
  tabelao_full_mun[tabelao_full_mun$LEVEL_3=="PAMPA"&tabelao_full_mun$LEVEL_5=="Deforestation",65]

tabelao_full_mun[tabelao_full_mun$LEVEL_3=="PANTANAL"&tabelao_full_mun$LEVEL_5=="Deforestation",66]<-
  tabelao_full_mun[tabelao_full_mun$LEVEL_3=="PANTANAL"&tabelao_full_mun$LEVEL_5=="Deforestation",65]
```
## Calculating emissions by the burning of vegetation residuals
```javascript
desm$LEVEL_4[desm$LEVEL_4 == 1 ] <- 0 #does not matter whether it is within or without protected areas
```
### Grouping and summarizing emissions due to deforestation 
```javascript
desm<-desm%>%
  group_by(SECTOR,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,TYPE,GAS,CODIBGE,
           CODBIOMASESTADOS,STATE,ECONOMIC_ACTIVITY,PRODUCT,DE,PARA) %>% 
  summarize(`1970`=sum(`1970`),`1971`=sum(`1971`),`1972`=sum(`1972`),`1973`=sum(`1973`),`1974`=sum(`1974`),`1975`=sum(`1975`),`1976`=sum(`1976`),
            `1977`=sum(`1977`),`1978`=sum(`1978`),`1979`=sum(`1979`),`1980`=sum(`1980`),`1981`=sum(`1981`),
            `1982`=sum(`1982`),`1983`=sum(`1983`),`1984`=sum(`1984`),`1985`=sum(`1985`),`1986`=sum(`1986`),`1987`=sum(`1987`),`1988`=sum(`1988`),`1989`=sum(`1989`),
            `1990`=sum(`1990`),`1991`=sum(`1991`),`1992`=sum(`1992`),`1993`=sum(`1993`),`1994`=sum(`1994`),`1995`=sum(`1995`),`1996`=sum(`1996`),`1997`=sum(`1997`),
            `1998`=sum(`1998`),`1999`=sum(`1999`),`2000`=sum(`2000`),`2001`=sum(`2001`),`2002`=sum(`2002`),`2003`=sum(`2003`),`2004`=sum(`2004`),`2005`=sum(`2005`),
            `2006`=sum(`2006`),`2007`=sum(`2007`),`2008`=sum(`2008`),`2009`=sum(`2009`),`2010`=sum(`2010`),`2011`=sum(`2011`),`2012`=sum(`2012`),`2013`=sum(`2013`),
            `2014`=sum(`2014`),`2015`=sum(`2015`),`2016`=sum(`2016`),`2017`=sum(`2017`),`2018`=sum(`2018`),`2019`=sum(`2019`),`2020`=sum(`2020`))

desm$LEVEL_6 <- "NA"
names(desm)
desm <- desm[c(1:5, 66, 6:65)]
```

## Applying calculations of CH4 and N2O
```javascript
#Applying calculations of CH4 and N2O emissions based on the emissions of CO2 caused by deforestation

### Emissions per state -----------------------------------------------------
desmUF<-aggregate(desm[, c(36:66)], by = list(
  desm$STATE),
  FUN = "sum")


### Emissions per state and biome -------------------------------------------
desmUFBioma<-aggregate(desm[, c(36:66)], by = list(
  desm$STATE,
  desm$LEVEL_3),
  FUN = "sum")

#PS: CASES WHERE DEFORESTATION AREA EQUALS ZERO PREVENTS THE CALCULATIONS. ADDING 1 SOLVES THE PROBLEM
zeros<-which(desmUFBioma==0,arr.ind = T)
desmUFBioma[zeros]<-1
```
