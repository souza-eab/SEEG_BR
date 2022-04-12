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

## 0_Exporting intermediate file
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
### 1_Exporting intermediate file  ------------------------------------------
```
write.csv(tran_mun, file = "Results/1_0_DadosbrutosRECT.csv", row.names = F, fileEncoding = "UTF-8") # !!!
```
