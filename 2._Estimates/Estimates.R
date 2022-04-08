# Script for the calculations of emissions and removals -------------------
---
  Title: 'Script for the calculations of emissions and removals
  by apllying stocks and increment values to the transitions 
  areas obtained in the previous steps of the land use 
  sector method'
#Created by: 'Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza'
#Key activities in sections
---

#Start
gc()
memory.limit(9999999999) # or your memory 

## Setting your project.R  -------------

### Requerid packages  -------------------------------------------------------
# e.g.
## install.packages("pacman") // or
## install.packages("usethis")
library(pacman)
pacman::p_load(usethis, geojsonR, jsonlite, googledrive, openxlsx, ggplot2, tidyverse, tidyr, dplyr, rlang)

### Reading the GeoJSON files -------------
# Base file with codes for biome (bioma) and states (estado)
# e.g.
# biomasestados <- read.csv("../biomas_estados.csv")
biomasestados <- read.csv("biomas_estados.csv")

# Folder containing the GeoJSON files
folder <- "/SEEG_c9_v1/"

## Recode ------------------------------------------------------------------
# Base files of the transitions
# containing the information: code of the municipality (codigo), code of the biome/state (codigobiomasestados),
# biome (bioma), state (estado), protected area (ap, 1 or 0), year of the transition (periodo),
# class transitioned from (de) and to (para), and area of the transition (area_ha, in hectares)
biomasestado.data <- list.files(folder, full.names = TRUE) %>%
  map_df(function(file) {
    dt <- fromJSON(file, flatten = TRUE, simplifyDataFrame = TRUE)$features
    1:length(dt$properties.featureid) %>%
      map_df(function(x) {
        if (ncol(dt$properties.data[[x]] %>% as.tibble()) == 0) {
          dt$properties.data[[x]] <- tibble(V1 = NA, V2 = NA)
        }
        as.tibble(dt$properties.data[[x]]) %>%
          mutate(
            codigo = dt$properties.featureid[x],
            biomasestados = as.numeric(str_sub(dt$properties.featureid[x], 1, 3)),
            areaprotegida = dt$properties.AP[x],
            periodo = sprintf(
              "%s a %s",
              str_sub(dt$properties.ANO[x], 1, 4),
              str_sub(dt$properties.ANO[x], 5, 8)
            ),
            para = V1 %% 10000, de = (V1 - para) / 10000
          )
      })
  }) %>%
  left_join(biomasestados, by = c("biomasestados" = "id")) %>%
  select(codigo,
    codigobiomasestados = biomasestados, bioma = descricaobiomas, estado = descricaoestados, areaprotegida, periodo, de, para,
    area_ha = V2
  ) %>%
  mutate(area_ha = area_ha * 100)


### 0_Exporting intermediate file ---------------------------------------------
setwd("C:/Users/edriano.souza/GitHub/Estimates/OUTPUT")
write.csv(biomasestado.data, file = "1_0_Dadosbrutos.csv", row.names = F, fileEncoding = "UTF-8")


# Rearranging the table ---------------------------------------------------
tran_mun <- biomasestado.data %>%
  arrange(codigo, periodo, de, para) %>%
  spread(key = periodo, value = area_ha, fill = 0) %>%
  filter(!is.na(bioma))



# Reclassify --------------------------------------------------------------
# Reclassify some of the agriculture classes from MapBiomas to group them into less detailed classes (e.g. classes 46-48 into 36)
# and remove secondary identification (*100) from anthropic classes
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


write.csv(tran_mun, file = "1_0_DadosbrutosRECT.csv", row.names = F, fileEncoding = "UTF-8") # !!!

# List of classes from Mapbiomas (Collection 6) present in each biome

# Amazonia
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

# Cerrado
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

# Atlantic Forest
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
  30,
  31,
  33,
  36,
  39,
  41,
  49, # Wooded Restinga
  300,
  400,
  500,
  1100,
  1200,
  1300,
  4900
)

# Caatinga
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "CAATINGA"])))
classesCA <- c(
  3,
  4,
  5,
  9,
  11,
  12,
  15,
  20,
  21,
  23,
  24,
  25,
  29,
  30,
  31,
  33,
  36,
  39,
  41,
  300,
  400,
  500,
  1200,
  1300
)

# Pantanal
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "PANTANAL"])))
classesPN <- c(
  3,
  4,
  9,
  11,
  12,
  15,
  20,
  21,
  24,
  25,
  30,
  33,
  39,
  41,
  300,
  400,
  1100,
  1200
)

# Pampa
sort(as.numeric(unique(tran_mun$de[tran_mun$bioma == "PAMPA"])))
classesPM <- c(
  3,
  9,
  11,
  12,
  15,
  21,
  23,
  24,
  25,
  29,
  30,
  31,
  33,
  39,
  41,
  300,
  1100,
  1200
)


biomas <- c(
  "AMAZONIA", "CAATINGA", "CERRADO", "MATA_ATLANTICA",
  "PAMPA", "PANTANAL"
)

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

# Stocks in the Cerrado biome vary according to state
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

# Checking biome area quantified
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

# Relate transitions involving forest in the Cerrado with each state (keep UF=others for the other biomes)
# UF = unit of the federation
tran_mun$uf <- "OUTROS"

for (i in 1:length(estadosCerrado)) {
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$de == 3, "uf"] <- estadosCerrado[i]
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$para == 3, "uf"] <- estadosCerrado[i]
}

# Remove transitions of very small areas (< 1ha)
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

# Importing auxiliary data
# Stock and increment tables
setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/Auxiliares c<U+FFFD>lculo") # !!!
stk <- read.csv(file = "estoques_biomas_QCN.csv", header = TRUE, sep = ";")
cer_uf <- read.table(file = "estoques-floresta-cer-uf_QCN.txt", header = T)
incr <- read.csv(file = "incremento_QCN.csv", header = TRUE, sep = ";")

# Rearranging stock table
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

# Rearranging increment table
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

# Exporting intermediate file
write.csv(tran_mun, "tran_mun_intermediario.csv", row.names = F, fileEncoding = "UTF-8")


#' Title: Function built to associate the Inventory equations with each transition type
#'
#' @param t1 class transition_time1
#' @param t2 class transition_time1
#' @param bi 
#' @param uf 
#' @param ap 
#'
#' @return
#' @export
#'
#' @examples

seeg <- function(t1, t2, bi, uf, ap) {
  ####### Considering state stocks for forest class in the Cerrado
  if (bi == "CERRADO" & t1 == 3 ||
    bi == "CERRADO" & t1 == 300 ||
    bi == "CERRADO" & t2 == 3 ||
    bi == "CERRADO" & t1 == 300) {
    if (t1 %in% FM & t2 %in% FM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.2 FM-FM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% FSec & t2 %in% FSec) {
      equacao <- paste("A*(", 0, "-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.3 FSec-FSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% FNM & t2 %in% FM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
          3
        ],
        "*)(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.7 FNM-FM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% Ref & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep = ""), 3],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.10 Ref-FSec"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ref & ap == 1) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.12 FM-Ref"
      proc <- "Land use change"
    } else if (t1 %in% FNM & t2 %in% Ref & ap == 0) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )

      newAP <- ap
      notes <- "2.3.1.11 FNM-Ref"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ref) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2], "*0.44",
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )
      if (is.na(cer_uf[cer_uf$uf == as.character(uf), 2]) == FALSE) {
        if (round((cer_uf[cer_uf$uf == as.character(uf), 2]) * 0.44) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
      newAP <- ap
      notes <- "2.3.1.13 FSec-Ref"
    } else if (t1 %in% Ap & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == "AP.FSEC", 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.1 Ap-FSec"
      proc <- "Land use change"
    } else if (t1 %in% Ac & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3],
      ")*(44/12)",
      sep = ""
      )

      newAP <- ap
      notes <- "2.3.2.2 Ac-FSec"
      proc <- "Land use change"
    } else if (t1 %in% O & t2 %in% FSec) {
      equacao <- paste("A*(", 0,
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == "O.FSEC", 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.3 O-FSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% FNM & t2 %in% Ap & ap == 0) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.4 FNM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ap & ap == 1) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.5 FM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ap) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2], "*0.44",
        "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.6 FSec-Ap"
      proc <- "Land use change"
    } else if (t1 %in% FNM & t2 %in% Ac & ap == 0) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.1 FNM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ac & ap == 1) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.2 FM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ac) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2], "*0.44",
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.3 FSec-Ac"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% O & ap == 1) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.2 FM-O"
      proc <- "Land use change"
    } else if (t1 %in% FNM & t2 %in% O & ap == 0) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.1 FNM-O"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% O) {
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2], "*0.44",
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.3 FSec-O"
      proc <- "Land use change"
    } else {
      equacao <- NA
      newAP <- NA
      notes <- "not inventoried transition"
      proc <- "not inventoried transition"
    }

    ############ other biomes: forest stock does not vary per state
  } else {
    if (t1 %in% FM & t2 %in% FM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.2 FM-FM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% FSec & t2 %in% FSec) {
      equacao <- paste("A*(", 0, "-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.3 FSec-FSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% FNM & t2 %in% FM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.7 FNM-FM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% Ref & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep = ""), 3],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.10 Ref-FSec"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ref & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep = ""), 3],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.1.12 FM-Ref"
      proc <- "Land use change"
    } else if (t1 %in% FNM & t2 %in% Ref & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep = ""), 3],
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )

      newAP <- ap
      notes <- "2.3.1.11 FNM-Ref"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ref) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
          sep = ""
        ), 3]) * 0.44 >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }

      newAP <- ap
      notes <- "2.3.1.13 FSec-Ref"
    } else if (t1 %in% Ap & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == "AP.FSEC", 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.1 Ap-FSec"
      proc <- "Land use change"
    } else if (t1 %in% Ac & t2 %in% FSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3],
      ")*(44/12)",
      sep = ""
      )
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
      newAP <- ap
      notes <- "2.3.2.2 Ac-FSec"
    } else if (t1 %in% O & t2 %in% FSec) {
      equacao <- paste("A*(", 0,
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == "O.FSEC", 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.3 O-FSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% GM & t2 %in% Ref & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
      newAP <- ap
      notes <- "2.3.2.4 GM-Ref"
    } else if (t1 %in% GNM & t2 %in% Ref & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )

      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
      newAP <- ap
      notes <- "2.3.2.4 GNM-Ref"
    } else if (t1 %in% GSec & t2 %in% Ref) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.5 GSec-Ref"
      if (is.na((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3])) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
          sep = ""
        ), 3]) * 0.44 >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% Ap & t2 %in% Ref) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.6 Ap-Ref"
      proc <- "Removal by land use change"
    } else if (t1 %in% Ac & t2 %in% Ref) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.7 Ac-Ref"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1)),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% O & t2 %in% Ref) {
      equacao <- paste("A*(", 0,
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.2.8 O-Ref"
      proc <- "Removal by land use change"
    } else if (t1 %in% GM & t2 %in% GM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.2 GM-GM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% GSec & t2 %in% GSec) {
      equacao <- paste("A*(", 0, "-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.3 GSec-GSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% GNM & t2 %in% GM & ap == 1) {
      equacao <- paste("A*(-",
        inc[
          inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""),
          3
        ],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.5 GNM-GM"
      proc <- "Removal in protected areas"
    } else if (t1 %in% Ap & t2 %in% GSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.8 Ap-GSec"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE &
        is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by secondary vegetation"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% GNM & t2 %in% Ap & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.9 GNM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% GM & t2 %in% Ap & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.10 GM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% GSec & t2 %in% Ap) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.3.11 GSec-Ap"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3]) == FALSE &
        is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
          sep = ""
        ), 3]) * 0.44 >
          estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
            sep = ""
          ), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% Ref & t2 %in% GSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.1 Ref-GSec"
      proc <- "Land use change"
    } else if (t1 %in% Ac & t2 %in% GSec) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.2 Ac-GSec"
      proc <- "Land use change"
    } else if (t1 %in% O & t2 %in% GSec) {
      equacao <- paste("A*(", 0,
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep = ""), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.3 O-GSec"
      proc <- "Removal by secondary vegetation"
    } else if (t1 %in% FNM & t2 %in% Ap & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.4 FNM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ap & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.5 FM-Ap"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ap) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.6 FSec-Ap"
      proc <- "Land use change"
    } else if (t1 %in% Ref & t2 %in% Ap) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.7 Ref-Ap"
      proc <- "Land use change"
    } else if (t1 %in% Ac & t2 %in% Ap) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.9 Ac-Ap"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE &
        is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
            sep = ""
          ), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% O & t2 %in% Ap) {
      equacao <- paste("A*(", 0,
        "-", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.4.10 O-Ap"
      proc <- "Removal by land use change"
    } else if (t1 %in% FNM & t2 %in% Ac & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.1 FNM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% FM & t2 %in% Ac & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.2 FM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% Ac) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.3 FSec-Ac"
      proc <- "Land use change"
    } else if (t1 %in% Ref & t2 %in% Ac) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.4 Ref-Ac"
      proc <- "Land use change"
    } else if (t1 %in% GM & t2 %in% Ac & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.7 GM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% GNM & t2 %in% Ac & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.6 GNM-Ac"
      proc <- "Land use change"
    } else if (t1 %in% GSec & t2 %in% Ac) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.8 GSec-Ac"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3]) == FALSE &
        is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
          sep = ""
        ), 3] * 0.44) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
            sep = ""
          ), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% Ap & t2 %in% Ac) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.9 Ap-Ac"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3]) == FALSE &
        is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3]) == FALSE) {
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
          sep = ""
        ), 3]) >
          inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
            sep = ""
          ), 3]) {
          proc <- "Land use change"
        } else {
          proc <- "Removal by land use change"
        }
      } else {
        equacao <- paste("class absent in the biome",
          sep = ""
        )
        proc <- "not inventoried transition"
      }
    } else if (t1 %in% O & t2 %in% Ac) {
      equacao <- paste("A*(", 0,
        "-", inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
          sep = ""
        ), 3],
        ")*(44/12)",
        sep = ""
      )
      newAP <- ap
      notes <- "2.3.6.10 O-Ac"
      proc <- "Removal by land use change"
    } else if (t1 %in% FM & t2 %in% O & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.2 FM-O"
      proc <- "Land use change"
    } else if (t1 %in% FNM & t2 %in% O & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.1 FNM-O"
      proc <- "Land use change"
    } else if (t1 %in% FSec & t2 %in% O) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.3 FSec-O"
      proc <- "Land use change"
    } else if (t1 %in% Ref & t2 %in% O) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.4 Ref-O"
      proc <- "Land use change"
    } else if (t1 %in% GM & t2 %in% O & ap == 1) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.7 GM-O"
      proc <- "Land use change"
    } else if (t1 %in% GNM & t2 %in% O & ap == 0) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.6 GNM-O"
      proc <- "Land use change"
    } else if (t1 %in% GSec & t2 %in% O) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1 / 100)),
        sep = ""
      ), 3], "*0.44",
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.8 GSec-O"
      proc <- "Land use change"
    } else if (t1 %in% Ap & t2 %in% O) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.9 Ap-O"
      proc <- "Land use change"
    } else if (t1 %in% Ac & t2 %in% O) {
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
        sep = ""
      ), 3],
      ")*(44/12)",
      sep = ""
      )
      newAP <- ap
      notes <- "2.3.12.10 Ac-O"
      proc <- "Land use change"
    } else {
      equacao <- NA
      newAP <- NA
      notes <- "not inventoried transition"
      proc <- "not inventoried transition"
    }
  }
  # { equacao <- null }
  out <- data.frame(t1, t2, bi, uf, equacao, newAP, notes, proc, stringsAsFactors = FALSE)
  return(out)
}


#### Organizing matrices with all possible transition cases
# (combinations of "de", "para", "ap", and "uf" in the case of forests in the Cerrado) per biome

mCER1 <- expand.grid(
  t1 = classesCE,
  t2 = classesCE,
  bioma = "CERRADO",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)


mCER2 <- expand.grid(
  t1 = classesCE,
  t2 = classesCE,
  bioma = "CERRADO",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)


mCER3 <- expand.grid(
  t1 = c(3, 300),
  t2 = classesCE,
  bioma = "CERRADO",
  uf = estadosCerrado,
  ap = 0,
  stringsAsFactors = FALSE
)

mCER4 <- expand.grid(
  t1 = classesCE,
  t2 = c(3, 300),
  bioma = "CERRADO",
  uf = estadosCerrado,
  ap = 0,
  stringsAsFactors = FALSE
)


mCER5 <- expand.grid(
  t1 = c(3, 300),
  t2 = classesCE,
  bioma = "CERRADO",
  uf = estadosCerrado,
  ap = 1,
  stringsAsFactors = FALSE
)

mCER6 <- expand.grid(
  t1 = classesCE,
  t2 = c(3, 300),
  bioma = "CERRADO",
  uf = estadosCerrado,
  ap = 1,
  stringsAsFactors = FALSE
)

mCA1 <- expand.grid(
  t1 = classesCA,
  t2 = classesCA,
  bioma = "CAATINGA",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)

mCA2 <- expand.grid(
  t1 = classesCA,
  t2 = classesCA,
  bioma = "CAATINGA",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)

mMA1 <- expand.grid(
  t1 = classesMA,
  t2 = classesMA,
  bioma = "MATA_ATLANTICA",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)

mMA2 <- expand.grid(
  t1 = classesMA,
  t2 = classesMA,
  bioma = "MATA_ATLANTICA",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)

mAM1 <- expand.grid(
  t1 = classesAM,
  t2 = classesAM,
  bioma = "AMAZONIA",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)


mAM2 <- expand.grid(
  t1 = classesAM,
  t2 = classesAM,
  bioma = "AMAZONIA",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)


mPM1 <- expand.grid(
  t1 = classesPM,
  t2 = classesPM,
  bioma = "PAMPA",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)


mPM2 <- expand.grid(
  t1 = classesPM,
  t2 = classesPM,
  bioma = "PAMPA",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)


mPN1 <- expand.grid(
  t1 = classesPN,
  t2 = classesPN,
  bioma = "PANTANAL",
  uf = "OUTROS",
  ap = 0,
  stringsAsFactors = FALSE
)

mPN2 <- expand.grid(
  t1 = classesPN,
  t2 = classesPN,
  bioma = "PANTANAL",
  uf = "OUTROS",
  ap = 1,
  stringsAsFactors = FALSE
)


# Grouping all matrices
matriz <- rbind(
  mCA1, mCA2,
  mPM1, mPM2,
  mAM1, mAM2,
  mMA1, mMA2,
  mCER1, mCER2, mCER3, mCER4, mCER5, mCER6,
  mPN1, mPN2
)
matriz <- matriz[!duplicated(matriz), ]

# Applying function 'seeg' to attribute the specific equation to each transition type
myTab <- data.frame(t(mapply(seeg, t1 = matriz$t1, t2 = matriz$t2, bi = matriz$bioma, uf = matriz$uf, ap = matriz$ap)))

for (i in 1:ncol(myTab)) {
  myTab[, i] <- unlist(myTab[, i])
}

myTab <- myTab[!duplicated(myTab), ]
colnames(myTab) <- c("t1", "t2", "bioma", "uf", "equacao", "ap", "nota", "processo")

# Filtering out not inventoried cases
myTab <- myTab[myTab$nota != "not inventoried transition", ]
myTab[grep("NA", myTab$equacao), "equacao"] <- "class absent in the biome"

# Matrices where the equations will be calculated to generate emission/removal estimates
emiss_mun <- tran_mun
emiss_mun$eq_inv <- "NULL"
emiss_mun$processo <- "NULL"

# Applying calculations
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

# Exporting intermediate files #!!!
write.csv(emiss_mun, file = "emiss_mun_col6_municipios.csv")

#### Organizing resulting matrix
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

# Associating transitions considered in the National Inventory
setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/Auxiliares c<U+FFFD>lculo") # !!!
simp <- read.csv(file = "class_inv_simpl_eng.csv", header = TRUE, sep = ";")
emiss_mun_filt$transic <- emiss_mun_filt$eq_inv
emiss_mun_filt$transic <- gsub("[[:digit:]]", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub("\\.", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub(" ", "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub("-", " -- ", emiss_mun_filt$transic)

for (i in 1:nrow(simp)) {
  emiss_mun_filt$transic <- gsub(simp$inv[i], simp$seeg[i], emiss_mun_filt$transic)
}

unique(paste(emiss_mun_filt$transic, emiss_mun_filt$eq_inv))

# Organizing column order
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

# Grouping and summarizing cases
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


# Building the final matrix in the format of SEEG
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
  # "CODIBGE",
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

# Exporting intermediate file
write.csv(tabelao_full_mun, file = "tabelao_full_col6.csv") # !!!

tabelao_full_mun$LEVEL_4 <- as.character(tabelao_full_mun$LEVEL_4)
tabelao_full_mun$LEVEL_5 <- as.character(tabelao_full_mun$LEVEL_5)
tabelao_full_mun$PRODUCT <- as.character(tabelao_full_mun$PRODUCT)
tabelao_full_mun$DE <- as.character(tabelao_full_mun$DE)
tabelao_full_mun$PARA <- as.character(tabelao_full_mun$PARA)
tabelao_full_mun$CODBIOMASESTADOS <- as.character(tabelao_full_mun$CODBIOMASESTADOS)


#### Calculating emissions by the burning of vegetation residuals

# Classifying transitions that comprise deforestation
deforestation <- c(
  "Primary forest -- Non vegetated area",
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
  "Secondary non forest vegetation -- Pasture/Agriculture"
)

desm <- tabelao_full_mun[(tabelao_full_mun$LEVEL_6 %in% deforestation) &
  tabelao_full_mun$TYPE == "Emission", ]

desm$LEVEL_4[desm$LEVEL_4 == 1] <- 0 # does not matter whether it is within or without protected areas

# Grouping and summarizing emissions due to deforestation
desm <- desm %>%
  group_by(
    SECTOR, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, TYPE, GAS, CODIBGE,
    CODBIOMASESTADOS, STATE, ECONOMIC_ACTIVITY, PRODUCT, DE, PARA
  ) %>%
  summarize(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )


desm$LEVEL_6 <- "NA"
names(desm)
desm <- desm[c(1:5, 66, 6:65)]

# Applying calculations of CH4 and N2O emissions based on the emissions of CO2 caused by deforestation

# Emissions per state
desmUF <- aggregate(desm[, c(36:66)],
  by = list(
    desm$STATE
  ),
  FUN = "sum"
)

# Emissions per state and biome
desmUFBioma <- aggregate(desm[, c(36:66)],
  by = list(
    desm$STATE,
    desm$LEVEL_3
  ),
  FUN = "sum"
)

# PS: CASES WHERE DEFORESTATION AREA EQUALS ZERO PREVENTS THE CALCULATIONS. ADDING 1 SOLVES THE PROBLEM
zeros <- which(desmUFBioma == 0, arr.ind = T)
desmUFBioma[zeros] <- 1

# Emissions (CO2) into dry biomass (Kg), where: CO2/44/12 -> C/0.47 -> Biomass
desmC <- desmUF
desmC[2:32] <- desmC[2:32] / (44 / 12)
desmBiomassa <- desmC
desmBiomassa[2:32] <- desmBiomassa[2:32] / 0.47 # final unit: tonnes

# Discount from the dry biomass the amount of logs and firewood removed from the areas (data obtained per state from IBGE and saved as an auxiliary table)
setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/Auxiliares c<U+FFFD>lculo") # !!!
ltve <- read.csv("LenhaTora_UF.csv", sep = ";")

# Stereo volume into dry biomass (factors from the Fourth National Inventory)
ltb <- ltve
ltb[2:32] <- ltb[2:32] * 0.6141 * 0.631 # final unit: tonnes

biomassaQueimada <- desmUF
for (i in 2:ncol(biomassaQueimada)) {
  for (j in 1:nrow(biomassaQueimada)) {
    biomassaQueimada[j, i] <- biomassaQueimada[j, i] - ltb[j, i]
  }
}

# Emissions by the burning of biomass residuals (where combustion factors depend on vegetation type and biome)
# Vegetation differentiated between Forest and Grassland (Floresta e Campo)
veg <- data.frame(
  c(
    "floresta", "floresta", "floresta", "floresta", "floresta", "floresta", "floresta", "floresta",
    "campo", "campo", "campo", "campo", "campo", "campo"
  ),
  c(3, 4, 5, 49, 300, 400, 500, 4900, 11, 12, 13, 1100, 1200, 1300)
)
colnames(veg) <- c("tipo", "cod")
veg$cod <- as.character(veg$cod)

desmVeg <- desm %>%
  left_join(x = desm, y = veg, by = c("DE" = "cod"))

desmUFVeg <- aggregate(desmVeg[, c(36:66)],
  by = list(
    desmVeg$STATE,
    desmVeg$tipo
  ),
  FUN = "sum"
)

# Proportion of deforestation in each state/vegetation type
desmUFProp <- desmUFVeg %>%
  left_join(x = desmUFVeg, y = desmUF, by = c("Group.1"))
for (i in 3:33) {
  desmUFProp[, i + 62] <- desmUFProp[, i] / desmUFProp[, i + 31]
}
desmUFProp <- desmUFProp[, -c(3:64)]

desmQueimadaProp <- desmUFProp %>%
  left_join(x = desmUFProp, y = biomassaQueimada, by = c("Group.1"))
for (i in 3:33) {
  desmQueimadaProp[, i + 31] <- desmQueimadaProp[, i] * desmQueimadaProp[, i + 31]
}
desmQueimadaVeg <- desmQueimadaProp[, -c(3:33)]

# Joining biome information and distributes deforestation amount according to the proportions calculated
desmUFBiomaProp <- desmUFBioma %>%
  left_join(x = desmUFBioma, y = desmUF, by = "Group.1")

for (i in 3:33) {
  desmUFBiomaProp[, i] <- desmUFBiomaProp[, i] / desmUFBiomaProp[, i + 31]
}
desmUFBiomaProp <- desmUFBiomaProp[, -c(34:64)]

desmQueimadaVegBioma <- desmQueimadaVeg %>%
  left_join(x = desmQueimadaVeg, y = desmUFBiomaProp, by = "Group.1")

for (i in 3:33) {
  desmQueimadaVegBioma[, i] <- desmQueimadaVegBioma[, i] * desmQueimadaVegBioma[, i + 32]
}
desmQueimadaVegBioma <- desmQueimadaVegBioma[, c(1, 2, 34, 3:33)]

# Applying combustion factors
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "AMAZONIA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "AMAZONIA", 4:34] * 0.368
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "AMAZONIA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "AMAZONIA", 4:34] * mean(c(0.771, 0.539))

desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "CERRADO", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "CERRADO", 4:34] * 0.379
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "CERRADO", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "CERRADO", 4:34] * mean(c(0.920, 0.840))

desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "CAATINGA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "CAATINGA", 4:34] * 0.383
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "CAATINGA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "CAATINGA", 4:34] * mean(c(0.840, 0.840))

desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "MATA_ATLANTICA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "MATA_ATLANTICA", 4:34] * 0.368
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "MATA_ATLANTICA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "MATA_ATLANTICA", 4:34] * mean(c(0.920, 0.539))

desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "PAMPA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "PAMPA", 4:34] * 0.368
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "PAMPA", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "PAMPA", 4:34] * mean(c(0.944, 0.539))

desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "PANTANAL", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "floresta" & desmQueimadaVegBioma$Group.2.y == "PANTANAL", 4:34] * 0.379
desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "PANTANAL", 4:34] <-
  desmQueimadaVegBioma[desmQueimadaVegBioma$Group.2.x == "campo" & desmQueimadaVegBioma$Group.2.y == "PANTANAL", 4:34] * mean(c(0.920, 0.840))


# Distributing the burned biomass data per state/vegetation type into the municipal level
# according to the proportion of deforestation in each municipality
# Total de emissao por estado/veg/bioma: desmQueimadaVegBioma

# Emission caused by deforestation in each municipality/vegetation type/biome case
desmMunVegBioma <- aggregate(desmVeg[, c(36:66)],
  by = list(
    desmVeg$LEVEL_3,
    desmVeg$CODIBGE,
    desmVeg$STATE,
    desmVeg$tipo
  ),
  FUN = "sum"
)

# Proportion of emission caused by deforestation in each municipality/vegetation type/biome case in the total deforestation amount in each state/veg/biome
desmUFVegBioma <- aggregate(desmVeg[, c(36:66)],
  by = list(
    desmVeg$LEVEL_3,
    desmVeg$STATE,
    desmVeg$tipo
  ),
  FUN = "sum"
)

# PS: CASES WHERE DEFORESTATION AREA EQUALS ZERO PREVENTS THE CALCULATIONS. ADDING 1 SOLVES THE PROBLEM
zeros <- which(desmUFVegBioma == 0, arr.ind = T)
desmUFVegBioma[zeros] <- 1

desmMunVegBiomaProp <- desmMunVegBioma %>%
  left_join(x = desmMunVegBioma, y = desmUFVegBioma, by = c("Group.1" = "Group.1", "Group.3" = "Group.2", "Group.4" = "Group.3"))
for (i in 5:35) {
  desmMunVegBiomaProp[, i + 62] <- desmMunVegBiomaProp[, i] / desmMunVegBiomaProp[, i + 31]
}
desmMunVegBiomaProp <- desmMunVegBiomaProp[, -c(5:66)]

# Multiplying the proportions and the total emissions caused by burning residual biomass: END OF THE CALCULATION
desmQueimadaMunVegBioma <- desmMunVegBiomaProp %>%
  left_join(x = desmMunVegBiomaProp, y = desmQueimadaVegBioma, by = c("Group.1" = "Group.2.y", "Group.3" = "Group.1", "Group.4" = "Group.2.x"))

for (i in 5:35) {
  desmQueimadaMunVegBioma[, i] <- desmQueimadaMunVegBioma[, i] * desmQueimadaMunVegBioma[, i + 31]
}
desmQueimadaMunVegBioma <- desmQueimadaMunVegBioma[, c(1:35)]

# Emission factor per gas and vegetation type (factors in kg/ton of burned biomass residuals)
ch4 <- desmQueimadaMunVegBioma
n2o <- desmQueimadaMunVegBioma
ch4[ch4$Group.4 == "campo", 5:35] <- ch4[ch4$Group.4 == "campo", 5:35] * 2.3 / 1000
ch4[ch4$Group.4 == "floresta", 5:35] <- ch4[ch4$Group.4 == "floresta", 5:35] * 6.8 / 1000
n2o[n2o$Group.4 == "campo", 5:35] <- n2o[n2o$Group.4 == "campo", 5:35] * 0.21 / 1000
n2o[n2o$Group.4 == "floresta", 5:35] <- n2o[n2o$Group.4 == "floresta", 5:35] * 0.2 / 1000


# Organizing the results
ch4$GAS <- "CH4 (t)"
n2o$GAS <- "N2O (t)"

ch4$SECTOR <- "Land use change and forests"
n2o$SECTOR <- "Land use change and forests"

ch4$LEVEL_2 <- "Vegetation residuals"
n2o$LEVEL_2 <- "Vegetation residuals"

ch4$LEVEL_3 <- ch4$Group.1
n2o$LEVEL_3 <- n2o$Group.1

ch4$LEVEL_4 <- "NA"
n2o$LEVEL_4 <- "NA"

ch4$LEVEL_5 <- "NA"
n2o$LEVEL_5 <- "NA"

ch4$LEVEL_6 <- "NA"
n2o$LEVEL_6 <- "NA"

ch4$TYPE <- "Emission"
n2o$TYPE <- "Emission"

ch4$CODIBGE <- ch4$Group.2
n2o$CODIBGE <- n2o$Group.2

ch4$CODBIOMASESTADOS <- substr(ch4$CODIBGE, start = 1, stop = 3)
n2o$CODBIOMASESTADOS <- substr(n2o$CODIBGE, start = 1, stop = 3)

ch4$STATE <- ch4$Group.3
n2o$STATE <- n2o$Group.3

ch4$ECONOMIC_ACTIVITY <- "AGROPEC"
n2o$ECONOMIC_ACTIVITY <- "AGROPEC"

ch4$PRODUCT <- "NA"
n2o$PRODUCT <- "NA"

colnames(ch4)[5:35] <- colnames(desm)[36:66]
colnames(n2o)[5:35] <- colnames(desm)[36:66]

str(ch4)
names(ch4)
ch4 <- ch4[, c(37:43, 36, 44:48, 5:35)]
names(n2o)
n2o <- n2o[, c(37:43, 36, 44:48, 5:35)]

names(ch4)
names(n2o)

# Generation of CO2 equivalent emissions according to GTP and GWP from AR 2, 4, 5, and 6
TAR2 <- round((ch4[, 14:44] * 5) + (n2o[, 14:44] * 270))
WAR2 <- round((ch4[, 14:44] * 21) + (n2o[, 14:44] * 310))
TAR4 <- round((ch4[, 14:44] * 5) + (n2o[, 14:44] * 270))
WAR4 <- round((ch4[, 14:44] * 25) + (n2o[, 14:44] * 298))
TAR5 <- round((ch4[, 14:44] * 4) + (n2o[, 14:44] * 234))
WAR5 <- round((ch4[, 14:44] * 28) + (n2o[, 14:44] * 265))
TAR6 <- round((ch4[, 14:44] * 5.38) + (n2o[, 14:44] * 233))
WAR6 <- round((ch4[, 14:44] * 27.9) + (n2o[, 14:44] * 273))

TAR2 <- cbind(ch4[, 1:13], TAR2)
TAR2$GAS <- "CO2e (t) GTP-AR2"

WAR2 <- cbind(ch4[, 1:13], WAR2)
WAR2$GAS <- "CO2e (t) GWP-AR2"

TAR4 <- cbind(ch4[, 1:13], TAR4)
TAR4$GAS <- "CO2e (t) GTP-AR4"

WAR4 <- cbind(ch4[, 1:13], WAR4)
WAR4$GAS <- "CO2e (t) GWP-AR4"

TAR5 <- cbind(ch4[, 1:13], TAR5)
TAR5$GAS <- "CO2e (t) GTP-AR5"

WAR5 <- cbind(ch4[, 1:13], WAR5)
WAR5$GAS <- "CO2e (t) GWP-AR5"

TAR6 <- cbind(ch4[, 1:13], TAR6)
TAR6$GAS <- "CO2e (t) GTP-AR6"

WAR6 <- cbind(ch4[, 1:13], WAR6)
WAR6$GAS <- "CO2e (t) GWP-AR6"

residuos <- as.data.frame(rbind(n2o, ch4, TAR2, WAR2, TAR4, WAR4, TAR5, WAR5, TAR6, WAR6))

residuos$`1970` <- 0
residuos$`1971` <- 0
residuos$`1972` <- 0
residuos$`1973` <- 0
residuos$`1974` <- 0
residuos$`1975` <- 0
residuos$`1976` <- 0
residuos$`1977` <- 0
residuos$`1978` <- 0
residuos$`1979` <- 0
residuos$`1980` <- 0
residuos$`1981` <- 0
residuos$`1982` <- 0
residuos$`1983` <- 0
residuos$`1984` <- 0
residuos$`1985` <- 0
residuos$`1986` <- 0
residuos$`1987` <- 0
residuos$`1988` <- 0
residuos$`1989` <- 0
residuos <- residuos[, c(1:13, 45:64, 14:44)]

# Exclude information "de" and "para" from the main table

tabelao_full_mun2 <- tabelao_full_mun %>%
  group_by(SECTOR, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, TYPE, GAS, CODIBGE, CODBIOMASESTADOS, STATE, ECONOMIC_ACTIVITY, PRODUCT) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )

emiss_aggrCO2 <- tabelao_full_mun2
emiss_aggrTAR2 <- tabelao_full_mun2
emiss_aggrWAR2 <- tabelao_full_mun2
emiss_aggrTAR4 <- tabelao_full_mun2
emiss_aggrWAR4 <- tabelao_full_mun2
emiss_aggrTAR5 <- tabelao_full_mun2
emiss_aggrTAR6 <- tabelao_full_mun2
emiss_aggrWAR6 <- tabelao_full_mun2

emiss_aggrCO2$GAS <- "CO2 (t)"
emiss_aggrTAR2$GAS <- "CO2e (t) GTP-AR2"
emiss_aggrWAR2$GAS <- "CO2e (t) GWP-AR2"
emiss_aggrTAR4$GAS <- "CO2e (t) GTP-AR4"
emiss_aggrWAR4$GAS <- "CO2e (t) GWP-AR4"
emiss_aggrTAR5$GAS <- "CO2e (t) GTP-AR5"
emiss_aggrTAR6$GAS <- "CO2e (t) GTP-AR6"
emiss_aggrWAR6$GAS <- "CO2e (t) GWP-AR6"

tabelao_full_final_mun <- rbind(
  tabelao_full_mun2,
  emiss_aggrCO2,
  emiss_aggrTAR2,
  emiss_aggrWAR2,
  emiss_aggrTAR4,
  emiss_aggrWAR4,
  emiss_aggrTAR5,
  emiss_aggrTAR6,
  emiss_aggrWAR6,
  residuos
)

# Exporting intermediate file
write.csv(tabelao_full_final_mun, file = "SEEG_Tabelao_full_mun_col6.csv")

# Further organization
tabelao_full_final_mun$LEVEL_3 <- as.factor(tabelao_full_final_mun$LEVEL_3)
levels(tabelao_full_final_mun$LEVEL_3) <- c(
  "Amazonia",
  "Caatinga",
  "Cerrado",
  "Atlantic Forest",
  "Pampa",
  "Pantanal"
)


tabelao_full_final_mun$LEVEL_4 <- as.factor(tabelao_full_final_mun$LEVEL_4)
levels(tabelao_full_final_mun$LEVEL_4) <- c("Outside protected areas", "Within protected areas", "NA")

tabelao_full_final_mun$STATE <- as.factor(tabelao_full_final_mun$STATE)
levels(tabelao_full_final_mun$STATE) <- c(
  "AC",
  "AL",
  "AP",
  "AM",
  "BA",
  "CE",
  "DF",
  "ES",
  "GO",
  "MA",
  "MT",
  "MS",
  "MG",
  "PA",
  "PB",
  "PR",
  "PE",
  "PI",
  "RJ",
  "RN",
  "RS",
  "RO",
  "RR",
  "SC",
  "SP",
  "SE",
  "TO"
)

# Definition of process type (SEEG LEVEL_5)
deforestation <- c(
  "Primary forest -- Non vegetated area",
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
  "Secondary non forest vegetation -- Pasture/Agriculture"
)
regeneration <- c(
  "Planted forest -- Secondary forest",
  "Planted forest -- Secondary non forest vegetation",
  "Pasture/Agriculture -- Secondary forest",
  "Pasture/Agriculture -- Secondary non forest vegetation",
  "Non vegetated area -- Secondary forest",
  "Non vegetated area -- Secondary non forest vegetation"
)
others <- c(
  "Planted forest -- Non vegetated area",
  "Planted forest -- Pasture/Agriculture",
  "Pasture/Agriculture -- Non vegetated area",
  "Pasture/Agriculture -- Planted forest",
  "Pasture/Agriculture -- Pasture/Agriculture",
  "Non vegetated area -- Planted forest",
  "Non vegetated area -- Pasture/Agriculture"
)
stable <- c(
  "Primary forest -- Primary forest",
  "Primary non forest vegetation -- Primary non forest vegetation",
  "Secondary forest -- Secondary forest",
  "Secondary non forest vegetation -- Secondary non forest vegetation"
)

tabelao_full_final_mun$LEVEL_5[tabelao_full_final_mun$LEVEL_6 %in%
  regeneration] <- "Regeneration"
tabelao_full_final_mun$LEVEL_5[tabelao_full_final_mun$LEVEL_6 %in%
  stable] <- "Stable native vegetation"
tabelao_full_final_mun$LEVEL_5[tabelao_full_final_mun$LEVEL_6 %in%
  deforestation] <- "Deforestation"
tabelao_full_final_mun$LEVEL_5[tabelao_full_final_mun$LEVEL_6 %in%
  others] <- "Other types of land use change"
tabelao_full_final_mun$LEVEL_5[tabelao_full_final_mun$LEVEL_6 == "NA"] <- "NA"

# Tabelao estados (precisa deles para realizar a regressao antes da correcao do ultimo ano)
tabelao_full_final_estados <- tabelao_full_final_mun
tabelao_full_final_estados <- tabelao_full_final_estados %>%
  group_by(SECTOR, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, `TIPO DE VALOR`, GAS, CODBIOMASESTADOS, STATE, ECONOMIC_ACTIVITY, PRODUCT) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )

##### Correction of the last year of the series based on the deforestation rates provided by official sources (PRODES Amazonia and PRODES Cerrado)
# Rates are input as auxiliary tables
setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/Auxiliares c<U+FFFD>lculo") # !!!

# PRODES rates at the level of biome
prodesam_bi <- read.csv("prodesam_bi.csv", head = T, sep = ";")
prodesce_bi <- read.csv("prodesce_bi.csv", head = T, sep = ";")

# PRODES rates at the level of state (UF)
prodesam_uf <- read.csv("prodesam_uf.csv", head = T, sep = ";")
prodesce_uf <- read.csv("prodesce_uf.csv", head = T, sep = ";")

# Linear regression between PRODES rates and the emissions by SEEG (due to deforestation and burning of vegetation residuals only)
estados_GWPAR5 <- tabelao_full_final_estados[tabelao_full_final_estados$GAS == "CO2e (t) GWP-AR5", ]
estados_AUSRF <- estados_GWPAR5[estados_GWPAR5$LEVEL_2 == "Land use change" |
  estados_GWPAR5$LEVEL_2 == "Vegetation residuals", ]
estados_AUSRF <- estados_AUSRF[estados_AUSRF$LEVEL_5 == "Deforestation" |
  estados_AUSRF$LEVEL_5 == "NA", ]
estados_AUSRF <- estados_AUSRF %>%
  group_by(LEVEL_3, STATE) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )
biomas_AUSRF <- estados_AUSRF %>%
  group_by(LEVEL_3) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )


# Final equations per biome
# Amazonia
summary(lm(t(biomas_AUSRF[1, 22:51]) ~ prodesam_bi$PRODES[1:30])) # a=188719838, b1= 54141, R2= 0.87
# Cerrado
summary(lm(t(biomas_AUSRF[3, 33:51]) ~ prodesce_bi$PRODES[1:19])) # a=57540000, b1= 5271, R2= 0.80

# Applying the equation to predict emissions in the final year (2020)
am2020 <- 188719838 + 54141 * prodesam_bi$PRODES[31]
ce2020 <- 57540000 + 5271 * prodesce_bi$PRODES[20]

gases <- unique(tabelao_full_final_estados$GAS)
for (i in gases) {
  tabelao_full_final_estados[tabelao_full_final_estados$GAS == i & (tabelao_full_final_estados$LEVEL_3 == "Amaz<U+FFFD>nia" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Amaz<U+FFFD>nia" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] /
      sum(tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Amaz<U+FFFD>nia" &
        ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
          tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
          tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63]) * am2020
  tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Cerrado" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Cerrado" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] /
      sum(tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Cerrado" &
        ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
          tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
          tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63]) * ce2020
}

# For the other biomes, emissions in 2020 (related to deforestation and the burning of vegetation residuals onlye) are assumed to be the same as in 2019
for (i in gases) {
  tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Caatinga" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Caatinga" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 62]

  tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Mata Atl<U+FFFD>ntica" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Mata Atl<U+FFFD>ntica" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 62]

  tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Pampa" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Pampa" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 62]

  tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Pantanal" &
    ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
      tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
      tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 63] <-
    tabelao_full_final_estados[tabelao_full_final_estados$Gas == i & (tabelao_full_final_estados$LEVEL_3 == "Pantanal" &
      ((tabelao_full_final_estados$LEVEL_2 == "Land use change" &
        tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
        tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals")), 62]
}


# Proportional distribution of the emissions of the last year for the municipalities
tabelao_full_final_estados2020 <- tabelao_full_final_estados[(tabelao_full_final_estados$LEVEL_2 == "Land use change" &
  tabelao_full_final_estados$LEVEL_5 == "Deforestation") |
  tabelao_full_final_estados$LEVEL_2 == "Vegetation residuals", -c(13:62)]
estados2020corr <- tabelao_full_final_estados2020 %>%
  group_by(GAS, STATE, LEVEL_3) %>%
  summarise(`2020` = sum(`2020`))

tabelao_full_final_mun_corr <- tabelao_full_final_mun %>%
  left_join(x = tabelao_full_final_mun, y = estados2020corr, by = c("GAS", "STATE", "LEVEL_3"))
tabelao_full_final_mun_corr$`2020` <- tabelao_full_final_mun_corr$`2020.x`

tabelao_full_final_estados$STATE <- as.character(tabelao_full_final_estados$STATE)
tabelao_full_final_estados$LEVEL_3 <- as.character(tabelao_full_final_estados$LEVEL_3)

estados <- unique(tabelao_full_final_estados$STATE)
biomascorr <- c("Amaz<U+FFFD>nia", "Cerrado")

for (i in gases) {
  for (k in estados) {
    tab <- tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$STATE == k & ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
      tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
      tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), ]
    biomas <- as.character(unique(tab$LEVEL_3))
    biomas <- biomas[biomas %in% biomascorr]
    for (j in biomas) {
      tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$LEVEL_3 == j & (tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$STATE == k & ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
        tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
        tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals"))), 66] <-
        ((tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$LEVEL_3 == j & (tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$STATE == k & ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
          tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
          tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals"))), 64] /
          sum(tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$LEVEL_3 == j & (tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$STATE == k & ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
            tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
            tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals"))), 64]))) *
          tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$LEVEL_3 == j & (tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$STATE == k & ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
            tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
            tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals"))), 65]
    }
  }
}

tabelao_full_final_mun_corr <- tabelao_full_final_mun_corr[, -c(64, 65)]

# Repetition of 2019 for the other biomes
for (i in gases) {
  tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Caatinga" &
    ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
      tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
      tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 64] <-
    tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Caatinga" &
      ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
        tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
        tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 63]

  tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Mata Atl<U+FFFD>ntica" &
    ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
      tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
      tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 64] <-
    tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Mata Atl<U+FFFD>ntica" &
      ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
        tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
        tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 63]

  tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Pampa" &
    ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
      tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
      tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 64] <-
    tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Pampa" &
      ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
        tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
        tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 63]

  tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Pantanal" &
    ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
      tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
      tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 64] <-
    tabelao_full_final_mun_corr[tabelao_full_final_mun_corr$GAS == i & (tabelao_full_final_mun_corr$LEVEL_3 == "Pantanal" &
      ((tabelao_full_final_mun_corr$LEVEL_2 == "Land use change" &
        tabelao_full_final_mun_corr$LEVEL_5 == "Deforestation") |
        tabelao_full_final_mun_corr$LEVEL_2 == "Vegetation residuals")), 63]
}

# Final exporting of the table at the level of states
tabelao_full_final_estados <- tabelao_full_final_mun1
tabelao_full_final_estados <- tabelao_full_final_estados %>%
  group_by(SECTOR, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, TYPE, GAS, CODBIOMASESTADOS, STATE, ECONOMIC_ACTIVITY, PRODUCT) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )

setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/SEEG 9/SEEG 9.1") # !!!
write.csv(tabelao_full_final_estados, file = "TABELAO_MUT_ESTADOS.csv", row.names = F)

# Final exporting of the table at the level of Brazil (BR)
tabelaoBR <- tabelao_full_final_estados
tabelaoBR$STATE <- "BR"
tabelaoBR <- tabelaoBR %>%
  group_by(SECTOR, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, TYPE, GAS, STATE, ECONOMIC_ACTIVITY, PRODUCT) %>%
  summarise(
    `1970` = sum(`1970`), `1971` = sum(`1971`), `1972` = sum(`1972`), `1973` = sum(`1973`), `1974` = sum(`1974`), `1975` = sum(`1975`), `1976` = sum(`1976`),
    `1977` = sum(`1977`), `1978` = sum(`1978`), `1979` = sum(`1979`), `1980` = sum(`1980`), `1981` = sum(`1981`),
    `1982` = sum(`1982`), `1983` = sum(`1983`), `1984` = sum(`1984`), `1985` = sum(`1985`), `1986` = sum(`1986`), `1987` = sum(`1987`), `1988` = sum(`1988`), `1989` = sum(`1989`),
    `1990` = sum(`1990`), `1991` = sum(`1991`), `1992` = sum(`1992`), `1993` = sum(`1993`), `1994` = sum(`1994`), `1995` = sum(`1995`), `1996` = sum(`1996`), `1997` = sum(`1997`),
    `1998` = sum(`1998`), `1999` = sum(`1999`), `2000` = sum(`2000`), `2001` = sum(`2001`), `2002` = sum(`2002`), `2003` = sum(`2003`), `2004` = sum(`2004`), `2005` = sum(`2005`),
    `2006` = sum(`2006`), `2007` = sum(`2007`), `2008` = sum(`2008`), `2009` = sum(`2009`), `2010` = sum(`2010`), `2011` = sum(`2011`), `2012` = sum(`2012`), `2013` = sum(`2013`),
    `2014` = sum(`2014`), `2015` = sum(`2015`), `2016` = sum(`2016`), `2017` = sum(`2017`), `2018` = sum(`2018`), `2019` = sum(`2019`), `2020` = sum(`2020`)
  )


write.csv(tabelaoBR, file = "TABELAO_MUT_BR-10-01.csv", row.names = F)

# Final exporting of the table at the level of municipalities
# Municipality names
setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/Auxiliares c<U+FFFD>lculo") # !!!
nomesmun <- read.csv("nomes_mun_IBGE.csv", head = T, sep = ";")
nomesmun <- nomesmun[, 1:2]

nomesmun$GEOCODIGO2 <- as.character(nomesmun$GEOCODIGO)
tabelao_full_final_mun_corr$CODIBGE <- as.character(tabelao_full_final_mun_corr$CODIBGE)
tabelao_full_final_mun_corr$CODIBGE <- as.character(str_sub(tabelao_full_final_mun_corr$CODIBGE, 2, 8))

tabelao_full_final_mun1 <- tabelao_full_final_mun_corr %>%
  left_join(nomesmun, by = c("CODIBGE" = "GEOCODIGO2"))
tabelao_full_final_mun1 <- tabelao_full_final_mun1[, c(1:9, 66, 10:64)]


setwd("C:/Users/barbara.zimbres/Dropbox/Work/SEEG/SEEG 9/SEEG 9.1") # !!!
tabelao_full_final_mun1$STATE <- as.character(tabelao_full_final_mun1$STATE)
lista.estados <- unique(tabelao_full_final_mun1$STATE)

for (i in 1:length(lista.estados)) {
  write.csv(subset(tabelao_full_final_mun1, tabelao_full_final_mun1[, 12] == lista.estados[i]), file = paste("UF/TABELAO_MUT_MUN", "_", lista.estados[i], ".csv", sep = ""), row.names = F, fileEncoding = "UTF-8")
}
