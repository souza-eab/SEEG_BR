# About [Estimates.R](https://github.com/souza-eab/SEEG_BR/blob/main/2._Estimates/Estimates_v0.R)

Script for the calculations of emissions and removals by applying stocks and increment values to the transitions areas obtained in the previous steps of the land-use sector method.

Created by: Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza .div</>
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
