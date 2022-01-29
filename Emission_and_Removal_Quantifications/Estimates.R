## SCRIPT PARA CALCULO DAS EMISSÕES E REMOÇÕES DAS TRANSIÇÕES
## SEXTO E ÚLTIMO PASSO PARA O METODO DE CALCULOS DO SEEG, SETOR MUT

## Organizacao responsavel: IPAM (Instituto de Pesquisa Ambiental da Amazonia)
## Criado por: Joao Siqueira, Felipe Lenti e Barbara Zimbres (barbara.zimbres@ipam.org.br)
## Citacao: referenciar o SEEG/Observatorio do Clima e o IPAM ao usar esse script

#####PACOTES REQUERIDOS#####
##Instalar se necessario###
library(geojsonR)
library(jsonlite)
library(tidyverse)
library(googledrive)
library(openxlsx)
library(dplyr)
#install.packages("styler")
############################



gc()
memory.limit (9999999999)


###Leitura das tabelas GeoJSON exportadas pelo processo do Google Earth Engine

#Importacao dos arquivos base com os codigos dos biomas e estados
biomasestados <- read.csv("C:/Users/edriano.souza/OneDrive/d/seeg/a/R/data_seeg/biomas_estados.csv")

#Pasta onde se encontram os GeoJSON exportados do Google Earth Engine
folder <- "C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/geoJson"


#Organizacao das areas de transicao e saida em hectares
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
  select(codigo, codigobiomasestados = biomasestados, bioma = descricaobiomas, estado = descricaoestados, areaprotegida, periodo, de, para, 
         area_ha = V2) %>%
  mutate(area_ha = area_ha*100)

# Start-v3 _ 14:27 08/10/2021


#15:35 16:29
colnames(biomasestado.data)
head(biomasestado.data,10)


setwd("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/")

write.csv(biomasestado.data, file = "1_0_Dadosbrutos.csv",row.names=F,fileEncoding = "UTF-8" )


#biomasestado.data <- read.csv("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/1_0_Dadosbrutos.csv")


# Validaty class antes
unique(biomasestado.data$de)
#0    3    4    5    9   11   12   13   15   20   21   23   24   25   31   33   41   49   30   39   48
#   46   47   40   29  300  400 1200 4900 1100 1500  500 1300 2100 4600 4100  900 2500 4700 4800 2900 3300
# 2000 3900 4000

# Validaty class depois
unique(biomasestado.data$para)
#0    3   15   21  300    4    5    9   11   12   24 1200   13   23  400   20 4900   25   31   33   41
#49 1100   30   39 1500   48  500 1300   46 2100 4600   47 4100   40  900 2500 4700   29 4800 2900 3300
#2000 3900 4000


### Valid Class Mapbiomas 
#{3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,@32,33,39,40,41,46,47,48,49}

# Necessario recodificar o código para agrupar classes de Café, Citrus, Outras lavouras temporárias, Restinga 

biomasestado.data <- biomasestado.data %>% 
  mutate(de= recode(de,
                    `0` = "0",
                    `3` = "3",
                    `4` = "4",
                    `5` = "5",
                    `9` = "9",
                    `11` = "11",
                    `12` = "12",
                    `13` = "13",
                    `15` = "15",
                    `20` = "20",
                    `21` = "21",
                    `23` = "23",
                    `24` = "24",
                    `25` = "25",
                    `29` = "29",
                    `30` = "30",
                    `31` = "31",
                    `33` = "33",
                    `39` = "39",
                    `40` = "39",
                    `41` = "41",
                    `46` = "36", 
                    `47` = "36",
                    `48` = "36",
                    `49` = "5",
                    `300` = "300",
                    `400` = "400",
                    `500` = "500",
                    `900` = "9",
                    `1100` = "1100",
                    `1200` = "1200",
                    `1300` = "1300",
                    `1500` = "1500",
                    `2000` = "2000",
                    `2100` = "2100",
                    `2500` = "2500",
                    `2900` = "29",
                    `3300` = "3300",
                    `3900` = "3900",
                    `4000` = "3900",
                    `4100` = "4100",
                    `4600` = "3600",
                    `4700` = "3600",
                    `4800` = "3600",
                    `4900` = "500"
                    )) %>% 
  mutate(para= recode(para,
                      `0` = "0",
                      `3` = "3",
                      `4` = "4",
                      `5` = "5",
                      `9` = "9",
                      `11` = "11",
                      `12` = "12",
                      `13` = "13",
                      `15` = "15",
                      `20` = "20",
                      `21` = "21",
                      `23` = "23",
                      `24` = "24",
                      `25` = "25",
                      `29` = "29",
                      `30` = "30",
                      `31` = "31",
                      `33` = "33",
                      `39` = "39",
                      `40` = "39",
                      `41` = "41",
                      `46` = "36", 
                      `47` = "36",
                      `48` = "36",
                      `49` = "5",
                      `300` = "300",
                      `400` = "400",
                      `500` = "500",
                      `900` = "9",
                      `1100` = "1100",
                      `1200` = "1200",
                      `1300` = "1300",
                      `1500` = "1500",
                      `2000` = "2000",
                      `2100` = "2100",
                      `2500` = "2500",
                      `2900` = "29",
                      `3300` = "3300",
                      `3900` = "3900",
                      `4000` = "3900",
                      `4100` = "4100",
                      `4600` = "3600",
                      `4700` = "3600",
                      `4800` = "3600",
                      `4900` = "500")) 
                    
                    
#biomasestado.data <- data.frame(biomasestado.data)

#setwd("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9")


write.csv(biomasestado.data, file = "1_0_DadosbrutosRECT.csv",row.names=F,fileEncoding = "UTF-8" )


biomasestado.data <- read.csv("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/1_0_Dadosbrutos.csv")


#Exportacao da tabela para fins de armazenamento do processo
tran_mun = biomasestado.data %>%
  arrange(codigo, periodo, de, para) %>% 
  spread(key = periodo, value = area_ha, fill = 0) %>%
  filter(!is.na(bioma))#%>%
#write_csv("D:/Dropbox/Work/SEEG/SEEG 8/SEEG 8.1/transicao_biomas_estados_municipios_col5.csv")


unique(tran_mun$de)
unique(tran_mun$para)
  

tran_mun <- tran_mun %>% 
  mutate(de= recode(de,
                    `0` = "0",
                    `3` = "3",
                    `4` = "4",
                    `5` = "5",
                    `9` = "9",
                    `11` = "11",
                    `12` = "12",
                    `13` = "13",
                    `15` = "15",
                    `20` = "20",
                    `21` = "21",
                    `23` = "23",
                    `24` = "24",
                    `25` = "25",
                    `29` = "29",
                    `30` = "30",
                    `31` = "31",
                    `33` = "33",
                    `39` = "39",
                    `40` = "39",
                    `41` = "41",
                    `46` = "36", 
                    `47` = "36",
                    `48` = "36",
                    `49` = "5",
                    `300` = "300",
                    `400` = "400",
                    `500` = "500",
                    `900` = "9",
                    `1100` = "1100",
                    `1200` = "1200",
                    `1300` = "1300",
                    `1500` = "1500",
                    `2000` = "2000",
                    `2100` = "2100",
                    `2500` = "2500",
                    `2900` = "29",
                    `3300` = "3300",
                    `3900` = "3900",
                    `4000` = "3900",
                    `4100` = "4100",
                    `4600` = "3600",
                    `4700` = "3600",
                    `4800` = "3600",
                    `4900` = "500"
  )) %>% 
  mutate(para= recode(para,
                      `0` = "0",
                      `3` = "3",
                      `4` = "4",
                      `5` = "5",
                      `9` = "9",
                      `11` = "11",
                      `12` = "12",
                      `13` = "13",
                      `15` = "15",
                      `20` = "20",
                      `21` = "21",
                      `23` = "23",
                      `24` = "24",
                      `25` = "25",
                      `29` = "29",
                      `30` = "30",
                      `31` = "31",
                      `33` = "33",
                      `39` = "39",
                      `40` = "39",
                      `41` = "41",
                      `46` = "36", 
                      `47` = "36",
                      `48` = "36",
                      `49` = "5",
                      `300` = "300",
                      `400` = "400",
                      `500` = "500",
                      `900` = "9",
                      `1100` = "1100",
                      `1200` = "1200",
                      `1300` = "1300",
                      `1500` = "1500",
                      `2000` = "2000",
                      `2100` = "2100",
                      `2500` = "2500",
                      `2900` = "29",
                      `3300` = "3300",
                      `3900` = "3900",
                      `4000` = "3900",
                      `4100` = "4100",
                      `4600` = "3600",
                      `4700` = "3600",
                      `4800` = "3600",
                      `4900` = "500"))




# 13:17 
tran_mun<- read.csv("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/1_1_Dados_fill_0_Col6_Seeg_2021.csv")

unique(tran_mun$de)

####Definicao de parametros para aplicacao das equacoes de emissao/remocao 

#Lista das classes do Mapbiomas (coleção 5.0) presentes em cada bioma
#Amazonia
classesAM<-c(3, 
             4,
             5,
             9,
             #11, #Wetland aparece
             12,
             15,
             20,
             #21, # Add Include Mosaic de Agricultura e Pastagem
             23,
             24,
             25,
             30,
             39,
             36, # Add Citrus
             41,
             #47, # Add Citrus
             300,
             400,
             500,
             1200)

#Cerrado
classesCE<-c(3,
             4,
             5,
             9,
             11,
             12,
             13,
             15,
             20,
             21,
             23,
             24,
             25,
             30,
             36, # Classe not include
             39,
             #40, # Include rice -> Class 39
             41,
             #46,# Include in Colletction 6.0
             #47,# Include in Colletction 6.0
             #48,# Include in Colletction 6.0
             300,
             400,
             500,
             1100,
             1200,
             1300)

#Mata Atlantica
classesMA<-c( 3,
              4,
              5,
              9,
              11,
              12,
              13,
              15,
              20,
              21,
              23,
              24,
              25,
              29,
              30,
              31,
              #33,
              36, # Classe not include
              39,
              #40, # Include Rice
              41,
              #46,# Include in Colletction 6.0
              #47,# Include in Colletction 6.0
              #49, #Include new classes
              300,
              400,
              500,
              1100,
              1200,
              1300)

#Caatinga
classesCA<-c( 3,
              4,
              5,
              9,
              12,
              13,
              15,
              20,
              21,
              23,
              24,
              25,
              29,
              30,
              31,
              #33, # Include class lake, 
              36, # Classe not include
              39,
              41,
              #46,# Include in Colletction 6.0
              #47,# Include in Colletction 6.0
              #48,# Include in Colletction 6.0
              300,
              400,
              500,
              1200,
              1300)

#Pantanal
classesPN<-c( 3,
              4,
              9,
              11,
              12,
              15,
              20,
              #21,
              24,
              25,
              30,
              #33, #Include Lake
              39,
              41,
              300,
              400,
              1100,
              1200)

#Pampa
classesPM<-c( 3, 
              9,
              11, 
              12,
              15,
              21,
              23,
              24,
              25,
              #29, # Include 2.4. Rocky Outcrop
              30,
              31,
              #33,
              39, # Soja
              #40, # Include Rice Collection 
              41,
              300,
              1100,
              1200)


biomas <- c( "AMAZONIA", "CAATINGA","CERRADO", "MATA_ATLANTICA",
             "PAMPA","PANTANAL")

#Relacao das classes do MapBiomas com as classes contabilizadas no 4o. Inventario
FM <- c(3, 4, 5)
FNM <- c(3, 4, 5)
FSec <- c(300, 400, 500)
GSec <- c(1100, 1200, 1300)
Ref <- 9
GM <- c(11,12,13)
GNM <- c(11,12,13)
Ac <- c(20, 21,36,39,41) #Include: (40)3.2.1.3. Rice; (46)3.2.1.1. Coffee / (47) 3.2.1.2. Citrus/ (48) 3.2.1.3. Other Perennial Crops
Ap <- 15
O <- c(23, 24, 25, 29, 30, 31)

#Verificar APICUM

# 3, 4, 5, 9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 33, 39, 40,41, 46, 47, 48, 49

unique(biomasestado.data$de)
unique(biomasestado.data$para)
unique(biomasestado.data$periodo)


classes <- sort(unique(c(FM, FNM, FSec, Ref, GM, GNM, GSec, Ac, Ap, O)))
uso <- sort(unique(c(Ref, Ac, Ap, O)))
nat <- c(FM,GM, FSec, GSec)

#O estoque para o cerrado varia de acordo com o estado
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
  "RO",
  "SP",
  "TO")

estados_cer <- sort(c("BAHIA",
                      "DISTRITO FEDERAL",
                      "GOIAS",
                      "MARANHAO",
                      "MINAS GERAIS",
                      "MATO GROSSO DO SUL",
                      "MATO GROSSO",
                      "PARA",
                      "PIAUI",
                      "PARANA",
                      "RONDONIA",
                      "SAO PAULO",
                      "TOCANTINS"))


####Organizacao da tabela de transicoes por municipio

colnames(tran_mun)<-c('codigo','codigobiomasestados', 'bioma','estado','ap','de','para',
                      'X1989.a.1990','X1990.a.1991',
                      'X1991.a.1992','X1992.a.1993',
                      'X1993.a.1994','X1994.a.1995',
                      'X1995.a.1996','X1996.a.1997',
                      'X1997.a.1998','X1998.a.1999',
                      'X1999.a.2000','X2000.a.2001',
                      'X2001.a.2002','X2002.a.2003',
                      'X2003.a.2004','X2004.a.2005',
                      'X2005.a.2006','X2006.a.2007',
                      'X2007.a.2008','X2008.a.2009',
                      'X2009.a.2010','X2010.a.2011',
                      'X2011.a.2012','X2012.a.2013',
                      'X2013.a.2014','X2014.a.2015',
                      'X2015.a.2016','X2016.a.2017',
                      'X2017.a.2018','X2018.a.2019','X2019.a.2020')


colnames(tran_mun)
#Agregar a soma das areas de cada transicao por area de interesse (municipio, bioma, estado e area protegida)
tran_mun<-tran_mun%>%
  group_by(codigo,codigobiomasestados, bioma,estado,ap,de,para) %>% summarise(X1989.a.1990 = sum(X1989.a.1990),X1990.a.1991 = sum(X1990.a.1991),
                                                                              X1991.a.1992 = sum(X1991.a.1992),X1992.a.1993 = sum(X1992.a.1993),
                                                                              X1993.a.1994 = sum(X1993.a.1994),X1994.a.1995 = sum(X1994.a.1995),
                                                                              X1995.a.1996 = sum(X1995.a.1996),X1996.a.1997 = sum(X1996.a.1997),
                                                                              X1997.a.1998 = sum(X1997.a.1998),X1998.a.1999 = sum(X1998.a.1999),
                                                                              X1999.a.2000 = sum(X1999.a.2000),X2000.a.2001 = sum(X2000.a.2001),
                                                                              X2001.a.2002 = sum(X2001.a.2002),X2002.a.2003 = sum(X2002.a.2003),
                                                                              X2003.a.2004 = sum(X2003.a.2004),X2004.a.2005 = sum(X2004.a.2005),
                                                                              X2005.a.2006 = sum(X2005.a.2006),X2006.a.2007 = sum(X2006.a.2007),
                                                                              X2007.a.2008 = sum(X2007.a.2008),X2008.a.2009 = sum(X2008.a.2009),
                                                                              X2009.a.2010 = sum(X2009.a.2010),X2010.a.2011 = sum(X2010.a.2011),
                                                                              X2011.a.2012 = sum(X2011.a.2012),X2012.a.2013 = sum(X2012.a.2013),
                                                                              X2013.a.2014 = sum(X2013.a.2014),X2014.a.2015 = sum(X2014.a.2015),
                                                                              X2015.a.2016 = sum(X2015.a.2016),X2016.a.2017 = sum(X2016.a.2017),
                                                                              X2017.a.2018 = sum(X2017.a.2018),X2018.a.2019 = sum(X2018.a.2019),
                                                                              X2019.a.2020 = sum(X2019.a.2020))

tran_mun<-data.frame(tran_mun)



str(tran_mun)

#tran_mun$bioma <- as.factor(tran_mun$bioma)
#tran_mun$estado <- as.factor(tran_mun$estado)
#tran_mun$ap <- as.factor(tran_mun$ap)
#tran_mun$de <- as.factor(tran_mun$de)
#tran_mun$para <- as.factor(tran_mun$para)
#levels(tran_mun$bioma)
#levels(tran_mun$estado)
#levels(tran_mun$ap)
#levels(tran_mun$de)
#levels(tran_mun$para)


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'AMAZONIA',])

nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'CERRADO',])

nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'CAATINGA',])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'MATA ATLANTICA',])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'PAMPA',])


nrow(tran_mun[tran_mun$de == 3 &
                tran_mun$para == 3 &
                tran_mun$ap == 1&
                tran_mun$bioma == 'PANTANAL',])



#Ajustando areas de transicao
tran_mun <- tran_mun[(tran_mun$para %in% classes),]
tran_mun <- tran_mun[(tran_mun$de %in% classes),]
#unique(paste(tran_mun$de, tran_mun$para, sep = "-"))

levels(tran_mun$bioma) <- c("AMAZONIA","MATA_ATLANTICA","PANTANAL","CERRADO","CAATINGA","PAMPA")
tran_mun$bioma[tran_mun$bioma == 'MATA ATLANTICA']<-'MATA_ATLANTICA'

colnames(tran_mun)
#Organizacao dos dados de floresta para relacionar com os estados do Cerrado (UF = "outros" nos demais biomas)
tran_mun$uf <- "OUTROS"

colnames(tran_mun)
for (i in 1:length(estadosCerrado)){
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$de == 3, "uf"] <- estadosCerrado[i]
  tran_mun[tran_mun$bioma == "CERRADO" & tran_mun$estado == estados_cer[i] & tran_mun$para == 3, "uf"] <- estadosCerrado[i]
}

colnames(tran_mun)
#unique(paste(tran_mun$uf, tran_mun$bioma))
colSums(subset(tran_mun, tran_mun$bioma == "AMAZONIA")[8:38])
colSums(subset(tran_mun, tran_mun$bioma == "CERRADO")[8:38])
colSums(subset(tran_mun, tran_mun$bioma == "MATA_ATLANTICA")[8:38])
colSums(subset(tran_mun, tran_mun$bioma == "PANTANAL")[8:38])
colSums(subset(tran_mun, tran_mun$bioma == "PAMPA")[8:38])
colSums(subset(tran_mun, tran_mun$bioma == "CAATINGA")[8:38])

# rownames(tran_mun)<-seq(1:nrow(tran_mun))
names(tran_mun)
#Descartar areas muitos pequenas (< 1ha)
tran_mun <- tran_mun[!!rowSums(abs(tran_mun[(names (tran_mun) %in% c("X1989.a.1990","X1990.a.1991","X1991.a.1992",
                                                                     "X1992.a.1993","X1993.a.1994","X1994.a.1995",
                                                                     "X1995.a.1996","X1996.a.1997","X1997.a.1998",
                                                                     "X1998.a.1999","X1999.a.2000","X2000.a.2001",
                                                                     "X2001.a.2002","X2002.a.2003","X2003.a.2004",
                                                                     "X2004.a.2005","X2005.a.2006","X2006.a.2007",
                                                                     "X2007.a.2008","X2008.a.2009","X2009.a.2010",
                                                                     "X2010.a.2011","X2011.a.2012","X2012.a.2013",
                                                                     "X2013.a.2014","X2014.a.2015","X2015.a.2016",
                                                                     "X2016.a.2017","X2017.a.2018","X2018.a.2019", "X2019.a.2020"))])) > 1,]



#Importacao das tabelas de estoque e incremento
setwd('C:/Users/edriano.souza/OneDrive/d/seeg/a/R/data_seeg') #Inserir diretorio onde as tabelas estao armazenadas
stk <- read.csv(file = 'estoques_biomas_QCN.csv' , header = TRUE, sep = ";")
cer_uf <- read.table(file = "estoques-floresta-cer-uf_QCN.txt", header =T)
incr <- read.csv(file = "incremento_QCN.csv", header = TRUE, sep = ";")

#Ajustando dados de estoques
bio <- rep(stk$Bioma, each = 12)
estq <- reshape (stk, varying = list(colnames(stk[-1])),
                 times = names(stk[-1]),
                 timevar = "classe",
                 idvar = "Bioma",
                 ids = stk$Bioma,
                 direction = "long")
rownames(estq) <- NULL
colnames(estq)[3] <- "estoque"
head(estq,72)

#Ajustando dados de incrementos
inc <- reshape (incr, varying = list(colnames(incr[-1])),
                times = names(incr[-1]),
                timevar = "classe",
                idvar = "Bioma",
                ids = incr$Bioma,
                direction = "long")
rownames(inc) <- NULL
colnames(inc)[3] <- "incremento"
head(inc)


####Funcao para codificar e associar as equacoes do inventario em funcao das transicoes

seeg <- function(t1, t2, bi, uf, ap){
  ######  
  #considerando estoques estaduais para classe 3 em Cerrado  
  if (bi == "CERRADO" & t1 == 3 ||
      bi == "CERRADO" & t1 == 300 ||
      bi == "CERRADO" & t2 == 3 ||
      bi == "CERRADO" & t1 == 300){
    if (t1 %in% FM & t2 %in% FM & ap == 1) {
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.2 FM-FM"
      proc <- "Remoção em Áreas Protegidas"
      
    } else if (t1 %in% FSec & t2 %in% FSec) { 
      
      equacao <- paste("A*(",0, "-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.3 FSec-FSec"
      proc <- "Remoção por Vegetação Secundária"
      
      # } else if (t1 %in% FNM & t2 %in% FNM & ap == 0 ) { 
      #   
      #   equacao <- paste("0",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.1 FNM-FNM"
      #   proc <- "transicao nao inventariada"
    } else if (t1 %in% FNM & t2 %in% FM & ap == 1) { 
      
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
                           3],
                       "*)(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.7 FNM-FM"
      proc <- "Remoção em Áreas Protegidas"
      
      # } else if (t1 %in% FNM & t2 %in% FSec & ap == 0) { 
      #   
      #   equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
      #                    "-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
      #                        3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.8 FNM-FSec"
      #   proc <- "Alterações de Uso do Solo"
      
      # } else if (t1 %in% FM & t2 %in% FSec & ap == 1) { 
      #   
      #   equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2]
      #                    , "-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.9 FM-FSec"
      #   proc <- "Alterações de Uso do Solo"
      #   
    } else if (t1 %in% Ref & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.10 Ref-FSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ref & ap == 1) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.12 FM-Ref"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FNM & t2 %in% Ref & ap == 0) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      
      newAP <- ap
      notes <- "2.3.1.11 FNM-Ref"                                
      proc <- "Alterações de Uso do Solo"
      
    }   else if (t1 %in% FSec & t2 %in% Ref) {
      
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      if (is.na(cer_uf[cer_uf$uf == as.character(uf), 2])== FALSE){
        if(round((cer_uf[cer_uf$uf == as.character(uf), 2])*0.44) >
           inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
      newAP <- ap
      notes <- "2.3.1.13 FSec-Ref"
      
    }   else if (t1 %in% Ap & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "AP.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.2.1 Ap-FSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ac & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      
      newAP <- ap
      notes <- "2.3.2.2 Ac-FSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% O & t2 %in% FSec) {
      
      equacao <- paste("A*(", 0,
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "O.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.2.3 O-FSec"
      proc <- "Remoção por Vegetação Secundária"
      
    } else if (t1 %in% FNM & t2 %in% Ap & ap == 0) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.4 FNM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ap & ap == 1) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.5 FM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FSec & t2 %in% Ap) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],"*0.44",
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.6 FSec-Ap"
      proc <- "Alterações de Uso do Solo"
      
      
    } else if (t1 %in% FNM & t2 %in% Ac & ap == 0) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.1 FNM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ac & ap == 1) {
      
      equacao <- paste("A*(",cer_uf[cer_uf$uf == as.character(uf), 2],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.2 FM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FSec & t2 %in% Ac) {
      
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.3 FSec-Ac"
      proc <- "Alterações de Uso do Solo"
      
      # } else if (t1 %in% FM & t2 %in% Res & ap == 1) {
      #   
      #   equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.2 FM-Res"
      
      # } else if (t1 %in% FNM & t2 %in% Res & ap == 0) {
      #   
      #   equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.1 FNM-Res"
      
      # }  else if (t1 %in% FSec & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],"*0.44",
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.3 FSec-Res"
      
    } else if (t1 %in% FM & t2 %in% O & ap == 1) {
      
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.2 FM-O"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FNM & t2 %in% O & ap == 0) {
      
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.1 FNM-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% FSec & t2 %in% O) {
      
      equacao <- paste("A*(", cer_uf[cer_uf$uf == as.character(uf), 2],"*0.44",
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.3 FSec-O"
      proc <- "Alterações de Uso do Solo"
    } else {
      equacao <- NA
      newAP <- NA
      notes <- "transicao nao inventariada"
      proc <- "transicao nao inventariada"
    }
    ############demais Biomas: valores iguais para todos os estados  
  } else {
    if (t1 %in% FM & t2 %in% FM & ap == 1) {
      
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.2 FM-FM"
      proc <- "Remoção em Áreas Protegidas"
      
    } else if (t1 %in% FSec & t2 %in% FSec) { 
      
      
      equacao <- paste("A*(",0, "-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC",
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.3 FSec-FSec"
      proc <- "Remoção por Vegetação Secundária"
      
      # } else if (t1 %in% FNM & t2 %in% FNM & ap == 0) { 
      #   
      #   equacao <- paste("0",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.1 FNM-FNM"
      #   proc <- "transicao nao inventariada"
      
    } else if (t1 %in% FNM & t2 %in% FM & ap == 1) { 
      
      
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.7 FNM-FM"
      proc <- "Remoção em Áreas Protegidas"
      
      # } else if (t1 %in% Ref & t2 %in% Ref) { 
      #   
      #   equacao <- paste("A*(",
      #                    0,
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.3 Ref-Ref"
      #   proc <- "transicao nao inventariada"
      
      # } else if (t1 %in% FNM & t2 %in% FSec & ap == 0) { 
      #   
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3],
      #                    "-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.8 FNM-FSec"
      #   proc <- "Remoção por Vegetação Secundária"
      
      # } else if (t1 %in% FM & t2 %in% FSec & ap == 1) {
      #   
      # 
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3]
      #                    , "-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.1.9 FM-FSec"
      #   proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ref & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "F.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.10 Ref-FSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ref & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.1.12 FM-Ref"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FNM & t2 %in% Ref & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1), sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      
      newAP <- ap
      notes <- "2.3.1.11 FNM-Ref"
      proc <- "Alterações de Uso do Solo"
      
    }   else if (t1 %in% FSec & t2 %in% Ref) {
      
      equacao <- paste("A*(", estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                         sep =""), 3],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                           sep =""), 3])== FALSE){
        if((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                       sep =""), 3])*0.44 >
           inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
      
      newAP <- ap
      notes <- "2.3.1.13 FSec-Ref"
      
    }   else if (t1 %in% Ap & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "AP.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.2.1 Ap-FSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ac & t2 %in% FSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE){
        if((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                       sep =""), 3]) >
           inc[inc$Bioma == as.character(bi) & inc$classe == "AC.FSEC", 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
      newAP <- ap
      notes <- "2.3.2.2 Ac-FSec"
      
      
    } else if (t1 %in% O & t2 %in% FSec) {
      
      equacao <- paste("A*(", 0,
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == "O.FSEC", 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.2.3 O-FSec"
      proc <- "Remoção por Vegetação Secundária"
      
    } else if (t1 %in% GM & t2 %in% Ref & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE){
        if((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                       sep =""), 3]) >
           inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
      newAP <- ap
      notes <- "2.3.2.4 GM-Ref"
      
    } else if (t1 %in% GNM & t2 %in% Ref & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE){
        if((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                       sep =""), 3]) >
           inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
      newAP <- ap
      notes <- "2.3.2.4 GNM-Ref"
      
    } else if (t1 %in% GSec & t2 %in% Ref) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.2.5 GSec-Ref"
      if (is.na((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                            sep =""), 3])) == FALSE){ 
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                        sep =""), 3])*0.44 >
            inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"  
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% Ap & t2 %in% Ref) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")  
      newAP <- ap
      notes <- "2.3.2.6 Ap-Ref"
      proc <- "Remoção por Mudança de Uso da Terra"
      
    } else if (t1 %in% Ac & t2 %in% Ref) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")  
      newAP <- ap
      notes <- "2.3.2.7 Ac-Ref"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE) {
        
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1)),
                                                                        sep =""), 3]) >
            inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra" 
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% O & t2 %in% Ref) {
      
      equacao <- paste("A*(",0,
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")  
      newAP <- ap
      notes <- "2.3.2.8 O-Ref"
      proc <- "Remoção por Mudança de Uso da Terra" 
      
      # } else if (t1 %in% GNM & t2 %in% GNM & ap == 0) { 
      #   
      #   equacao <- paste("0",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.3.1 GNM-GNM"
      
    } else if (t1 %in% GM & t2 %in% GM & ap == 1) { 
      
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.2 GM-GM"
      proc <- "Remoção em Áreas Protegidas"
      
    } else if (t1 %in% GSec & t2 %in% GSec) { 
      
      equacao <- paste("A*(",0,"-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.3 GSec-GSec"
      proc <- "Remoção por Vegetação Secundária"
      
      # } else if (t1 %in% Ap & t2 %in% Ap) { 
      #   
      #   equacao <- paste("A*(",0,")",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.3.4 Ap-Ap"
      
    } else if (t1 %in% GNM & t2 %in% GM & ap == 1) { 
      
      equacao <- paste("A*(-",
                       inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
                           3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.5 GNM-GM"
      proc <- "Remoção em Áreas Protegidas"
      
      # } else if (t1 %in% GNM & t2 %in% GSec & ap == 0) { 
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                    sep =""), 3],"-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
      #                        3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.3.6 GNM-GSec"
      #   proc <- "Alterações de Uso do Solo"
      
      # } else if (t1 %in% GM & t2 %in% GSec & ap == 1) { 
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                    sep =""), 3],"-",
      #                    inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""),
      #                        3],
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.3.7 GM-GSec"
      #   proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ap & t2 %in% GSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.8 Ap-GSec"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE &
          is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3])== FALSE){
        
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                        sep =""), 3]) >
            inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Vegetação Secundária" 
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% GNM & t2 %in% Ap & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.9 GNM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GM & t2 %in% Ap & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.10 GM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GSec & t2 %in% Ap) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.3.11 GSec-Ap"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                           sep =""), 3])== FALSE &
          is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                           sep =""), 3])== FALSE){
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                        sep =""), 3])*0.44 >
            estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                       sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra" 
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      } 
    } else if (t1 %in% Ref & t2 %in% GSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.1 Ref-GSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ac & t2 %in% GSec) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.2 Ac-GSec"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% O & t2 %in% GSec) {
      
      equacao <- paste("A*(",0,
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2), sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.3 O-GSec"
      proc <- "Remoção por Vegetação Secundária"
      
    } else if (t1 %in% FNM & t2 %in% Ap & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.4 FNM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ap & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.5 FM-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FSec & t2 %in% Ap) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.6 FSec-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ref & t2 %in% Ap) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.7 Ref-Ap"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ac & t2 %in% Ap) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.9 Ac-Ap"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE &
          is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                           sep =""), 3])== FALSE){
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                        sep =""), 3]) >
            estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                       sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% O & t2 %in% Ap) {
      
      equacao <- paste("A*(", 0,
                       "-",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t2),
                                                                                      sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.4.10 O-Ap"
      proc <- "Remoção por Mudança de Uso da Terra"
      
      # } else if (t1 %in% Ac & t2 %in% Ac) {
      #   
      #   equacao <- paste("A*", 0, sep = "")
      #   newAP <- ap
      #   notes <- "2.3.5 Ac-Ac"
      
    } else if (t1 %in% FNM & t2 %in% Ac & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.1 FNM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FM & t2 %in% Ac & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.2 FM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FSec & t2 %in% Ac) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.3 FSec-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% Ref & t2 %in% Ac) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.4 Ref-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GM & t2 %in% Ac & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.7 GM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GNM & t2 %in% Ac & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.6 GNM-Ac"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GSec & t2 %in% Ac) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.8 GSec-Ac"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                           sep =""), 3])== FALSE &
          is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                        sep =""), 3])== FALSE){
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                        sep =""), 3]*0.44) >
            inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                    sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"
          }
      }else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% Ap & t2 %in% Ac) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.9 Ap-Ac"
      if (is.na(estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                           sep =""), 3])== FALSE &
          is.na(inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                        sep =""), 3])== FALSE){
        
        if ((estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                        sep =""), 3]) >
            inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                    sep =""), 3]){
          proc <- "Alterações de Uso do Solo"} else {
            proc <- "Remoção por Mudança de Uso da Terra"
          }
      } else {
        equacao <- paste("classe ausente no bioma",
                         sep = "")
        proc <- "transicao nao inventariada"
      }
    } else if (t1 %in% O & t2 %in% Ac) {
      
      equacao <- paste("A*(", 0,
                       "-",inc[inc$Bioma == as.character(bi) & inc$classe == paste("X", as.character(t2),
                                                                                   sep =""), 3],
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.6.10 O-Ac"
      proc <- "Remoção por Mudança de Uso da Terra"
      ######
      # } else if (t1 %in% Res & t2 %in% Res) {
      #   
      #   equacao <- paste("A*", 0, sep = "")
      #   newAP <- ap
      #   notes <- "2.3.7.2 Res-Res"
      #   
      # } else if (t1 %in% FM & t2 %in% Res & ap == 1) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.2 FM-Res"
      #   
      # } else if (t1 %in% FNM & t2 %in% Res & ap == 0) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.1 FNM-Res"
      #   
      # }  else if (t1 %in% FSec & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
      #                                                                                     sep =""), 3],"*0.44",
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.3 FSec-Res"
      #   
      # }  else if (t1 %in% Ref & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.4 Ref-Res"
      #   
      # } else if (t1 %in% GM & t2 %in% Res & ap == 1) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.7 GM-Res"
      #   
      # } else if (t1 %in% GNM & t2 %in% Res & ap == 0) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.6 GNM-Res"
      #   
      # }  else if (t1 %in% GSec & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
      #                                                                                     sep =""), 3],"*0.44",
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.8 GSec-Res"
      #   
      # }  else if (t1 %in% Ap & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.9 Ap-Res"
      #   
      # }  else if (t1 %in% Ac & t2 %in% Res) {
      #   
      #   equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
      #                                                                                     sep =""), 3],
      #                    
      #                    ")*(44/12)",
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.10 Ac-Res"
      #   
      # }  else if (t1 %in% O & t2 %in% Res) {
      #   
      #   equacao <- paste("A*", 0,
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.11 O-Res"
      # 
      # } else if (t1 %in% O & t2 %in% O) {
      #   
      #   equacao <- paste("A*", 0, sep = "")
      #   newAP <- ap
      #   notes <- "2.3.11 O-O"
      #######   
    } else if (t1 %in% FM & t2 %in% O & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.2 FM-O"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% FNM & t2 %in% O & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.1 FNM-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% FSec & t2 %in% O) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.3 FSec-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% Ref & t2 %in% O) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.4 Ref-O"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GM & t2 %in% O & ap == 1) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.7 GM-O"
      proc <- "Alterações de Uso do Solo"
      
    } else if (t1 %in% GNM & t2 %in% O & ap == 0) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.6 GNM-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% GSec & t2 %in% O) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(round(t1/100)),
                                                                                        sep =""), 3],"*0.44",
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.8 GSec-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% Ap & t2 %in% O) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.9 Ap-O"
      proc <- "Alterações de Uso do Solo"
      
    }  else if (t1 %in% Ac & t2 %in% O) {
      
      equacao <- paste("A*(",estq[estq$Bioma == as.character(bi) & estq$classe == paste("X", as.character(t1),
                                                                                        sep =""), 3],
                       
                       ")*(44/12)",
                       sep = "")
      newAP <- ap
      notes <- "2.3.12.10 Ac-O"
      proc <- "Alterações de Uso do Solo"
      
      # }  else if (t1 %in% O & t2 %in% Res) {
      #   
      #   equacao <- paste("A*", 0,
      #                    sep = "")
      #   newAP <- ap
      #   notes <- "2.3.8.11 O-Res"
      
    } else { 
      equacao <- NA
      newAP <- NA
      notes <- "transicao nao inventariada"
      proc <- "transicao nao inventariada"
    }
  }
  #{ equacao <- null }
  out <-data.frame(t1, t2, bi, uf, equacao, newAP, notes, proc, stringsAsFactors = FALSE)
  return(out)
}


####Organizando matrizes por bioma com todos os casos de transicao a serem calculados,
#com todas as combinacoes de "de", "para", "ap" e, no caso do Cerrado, "uf" para transicoes
#que envolvam floresta (3 e 300)

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


#Agrupamento das matrizes organizadas por bioma
matriz <- rbind(mCA1, mCA2,
                mPM1, mPM2,
                mAM1, mAM2,
                mMA1, mMA2,
                mCER1, mCER2, mCER3, mCER4, mCER5, mCER6,
                mPN1, mPN2)
matriz <- matriz[!duplicated(matriz), ]

#Aplicacao da funcao 'seeg' para atribuir a equacao especifica para cada caso no objeto matriz
myTab <- data.frame(t(mapply(seeg,t1=matriz$t1,t2=matriz$t2, bi=matriz$bioma, uf=matriz$uf, ap = matriz$ap)))

for (i in 1:ncol(myTab)){
  myTab[, i] <- unlist(myTab[, i]) 
}

myTab <- myTab[!duplicated(myTab), ]
colnames(myTab) <- c("t1", "t2", "bioma", "uf", "equacao", "ap", "nota", "processo")
#unique(myTab$processo)

#Filtragem dos casos nao inventariados
myTab <- myTab [myTab$nota != "transicao nao inventariada", ]
myTab [grep("NA", myTab$equacao), "equacao"] <- "classe ausente no bioma"
#myTab <- myTab [-grep("classe ausente no bioma", myTab$equacao), ]

#Criacao de matrizes para receber estimativas de emissao/remocao

tran_mun.b <- tran_mun #essa vai passar pelos mesmos processos, mas vai ficar sem a aplicacao das equacoes para fim de monitoramento das areas inventariadas e geracao do dado de atividade
emiss_mun <- tran_mun.b
tran_mun.b$eq_inv <- "NULL"
emiss_mun$eq_inv <- "NULL"
tran_mun.b$processo <- "NULL"
emiss_mun$processo <- "NULL"

# rownames(emiss_mun)<-seq(1:nrow(emiss_mun))
# nrow(emiss_mun[emiss_mun$de == 3 &
#              emiss_mun$para == 3 &
#              emiss_mun$ap == 1&
#              emiss_mun$bioma == 'MATA_ATLANTICA',])
# 
# 
# colSums(tran_mun.b[8:36])

#Aplicacao do calculo codificado nas equacoes armazenadas nas matrizes
for (i in 1:nrow(emiss_mun)){
  print(paste0(i,"of",nrow(emiss_mun)))
  thisRow <- emiss_mun[i,]
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
  
  if (length(eq) == 0 || length(processo) == 0){
    emiss_mun[i, "eq_inv"] <- "transicao nao inventariada"
    tran_mun.b[i, "eq_inv"] <- "transicao nao inventariada"
    emiss_mun[i, "processo"] <- "transicao nao inventariada"
    tran_mun.b[i, "processo"] <- "transicao nao inventariada"
  } else {
    emiss_mun[i, "eq_inv"] <- note
    tran_mun.b[i, "eq_inv"] <- note
    emiss_mun[i, "processo"] <- processo
    tran_mun.b[i, "processo"] <- processo
    eq <- sub( "A\\*", "", eq)#[2])
    emiss_mun[i, !(names(emiss_mun) %in% c("codigo",
                                           "codigobiomasestados",
                                           "bioma",
                                           "estado",
                                           "ap",
                                           "de",
                                           "para",
                                           "uf",
                                           "eq_inv",
                                           "processo"
    ))] <-  paste(emiss_mun[i, !(names(emiss_mun) %in% c("codigo",
                                                         "codigobiomasestados",
                                                         "bioma",
                                                         "estado",
                                                         "ap",
                                                         "de",
                                                         "para",
                                                         "uf",
                                                         "eq_inv",
                                                         "processo"))],"*", eq, sep ="")
    
    for (j in 1:ncol(emiss_mun[i, !(names(emiss_mun) %in% c("codigo",
                                                            "codigobiomasestados", 
                                                            "bioma", 
                                                            "estado",
                                                            "de",
                                                            "para",
                                                            "uf", 
                                                            "eq_inv", 
                                                            "processo",
                                                            "ap"))])){
      emiss_mun[i, j+7] <- as.numeric(round(eval(parse(text = emiss_mun[i, j+7]))))
    }
  }
}

#15:25 #########Isso influencia na questão do número de combinação de
# dia 7/10/2021 15:38

## dia 8/10/2021#17:47 Start----


colnames(tran_mun.b)
str(tran_mun.b)
tran_mun.b[,8:38] <- as.numeric(unlist(tran_mun.b[,8:38])) #Coluna com as estimativas anuais como numéricas
emiss_mun[,8:38] <- as.numeric(unlist(emiss_mun[,8:38])) #Coluna com as estimativas anuais como numéricas


colSums(tran_mun.b[8:38])

#colSums(desm[34:63])
#colSums(subset(desm, desm$LEVEL_3 == "AMAZONIA")[34:63])
#colSums(subset(desm, desm$LEVEL_3 == "CERRADO")[34:63])
# colSums(subset(desm, desm$LEVEL_3 == "CAATINGA")[34:63])
# colSums(subset(desm, desm$LEVEL_3 == "MATA_ATLANTICA")[34:63])
# colSums(subset(desm, desm$LEVEL_3 == "PAMPA")[34:63])
# colSums(subset(desm, desm$LEVEL_3 == "PANTANAL")[34:63])



setwd("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/")


#Exportacao para fins de armazenamento do processo e exploracao inicial dos padroes
write.csv(emiss_mun, file = "1_2_Emiss_mun_col6_municipios.csv")
write.csv(tran_mun.b, file = "1_2_areastran_col6_municipios.csv")

# setwd("D:/Dropbox/Work/SEEG")
tran_mun.b<-read.csv("areastran_col6_municipios.csv",h=T)

# head(emiss_mun)
# unique(emiss_mun$eq_inv)
# unique(emiss_mun$processo)

#### Organizacao da matriz de resultado
#Reordenacao das colunas e filtragem dos casos nao inventariados para fins de organizacao
emiss_mun_filt <- emiss_mun
emiss_mun_filt <- emiss_mun_filt[-grep("transicao nao inventariada", emiss_mun_filt$processo), ]
unique(emiss_mun_filt$processo)

#Geracao da coluna atividade, que diferencia as transicoes entre atividade economica agropecuaria e conservacao
emiss_mun_filt$atividade <- NA
emiss_mun_filt$atividade[emiss_mun_filt$processo == "Remoção em Áreas Protegidas"] <- "CONSERV"
emiss_mun_filt$atividade[emiss_mun_filt$processo != "Remoção em Áreas Protegidas"] <- "AGROPEC"

#Geracao da coluna tipo, que diferencia emissoes e remocoes
emiss_mun_filt$tipo <- NA
emiss_mun_filt [grep("Remoção", emiss_mun_filt$processo), "tipo"] <- "Remoção"
emiss_mun_filt [-grep("Remoção", emiss_mun_filt$processo), "tipo"] <- "Emissão"

#Associacao das classes do inventario a cada tipo de transicao
setwd('C:/Users/edriano.souza/OneDrive/d/seeg/a/R/data_seeg')
simp <- read.csv(file = "class_inv_simpl.csv", header = TRUE, sep = ";")
emiss_mun_filt$transic <- emiss_mun_filt$eq_inv
emiss_mun_filt$transic <- gsub('[[:digit:]]', "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub('\\.', "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub(' ', "", emiss_mun_filt$transic)
emiss_mun_filt$transic <- gsub("-", " -- ", emiss_mun_filt$transic)

for (i in 1:nrow(simp)){
  emiss_mun_filt$transic <- gsub(simp$inv[i], simp$seeg[i], emiss_mun_filt$transic)
}

unique(paste(emiss_mun_filt$transic, emiss_mun_filt$eq_inv))

levels(emiss_mun_filt$estado) <- c("AC",
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
                                   "TO")

emiss_mun_filt <- emiss_mun_filt [, c("processo", "bioma", "ap", "transic", "tipo", "estado", "atividade", 'X1989.a.1990','X1990.a.1991',
                                      'X1991.a.1992','X1992.a.1993',
                                      'X1993.a.1994','X1994.a.1995',
                                      'X1995.a.1996','X1996.a.1997',
                                      'X1997.a.1998','X1998.a.1999',
                                      'X1999.a.2000','X2000.a.2001',
                                      'X2001.a.2002','X2002.a.2003',
                                      'X2003.a.2004','X2004.a.2005',
                                      'X2005.a.2006','X2006.a.2007',
                                      'X2007.a.2008','X2008.a.2009',
                                      'X2009.a.2010','X2010.a.2011',
                                      'X2011.a.2012','X2012.a.2013',
                                      'X2013.a.2014','X2014.a.2015',
                                      'X2015.a.2016','X2016.a.2017',
                                      'X2017.a.2018','X2018.a.2019', 'X2019.a.2020',"codigo","codigobiomasestados", "de", "para", "uf", "eq_inv")]
#names(emiss_mun_filt[,8:37])
#emiss_mun_filt[,8:36] <- as.numeric(unlist(emiss_mun_filt[,8:36])) #Coluna com as estimativas anuais como numéricas

#Exportacao para fins de armazenamento do processo e exploracao resultados filtrados
#write.csv(emiss_mun_filt, file = "area_mun_filt_col5_municipios.csv")

# colSums(subset(emiss_mun_filt, emiss_mun_filt$bioma == "CAATINGA")[8:37])
# sum(subset(emiss_mun_filt, emiss_mun_filt$bioma == "CERRADO")[8:37])
# sum(subset(emiss_mun_filt, emiss_mun_filt$bioma == "AMAZONIA")[8:37])
# sum(subset(emiss_mun_filt, emiss_mun_filt$bioma == "PANTANAL")[8:37])
# sum(subset(emiss_mun_filt, emiss_mun_filt$bioma == "MATA_ATLANTICA")[8:37])
# sum(subset(emiss_mun_filt, emiss_mun_filt$bioma == "PAMPA")[8:37])
str(emiss_mun_filt)
colnames(emiss_mun_filt)
#Agrupamento dos tipos de transicao
emiss_aggr <- aggregate(emiss_mun_filt[,8:38], by = list(
  emiss_mun_filt$processo,
  emiss_mun_filt$bioma,
  emiss_mun_filt$ap,
  emiss_mun_filt$transic,
  emiss_mun_filt$tipo,
  emiss_mun_filt$codigo,
  emiss_mun_filt$codigobiomasestados,
  emiss_mun_filt$estado,
  emiss_mun_filt$atividade),
  FUN = "sum")

names(emiss_aggr$Group.2)

#Adicao e organizacao das colunas necessarias a tabela final do SEEG MUT
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
emiss_aggr$SETOR <- "Mudança de Uso da Terra e Floresta"
emiss_aggr$LEVEL_5 <- "NA"
emiss_aggr$PRODUCT <- "NA"
newNames <- c("LEVEL_2",
              "LEVEL_3",
              "LEVEL_4",
              "LEVEL_6",
              "TIPO DE VALOR",
              "CODIBGE",
              "CODBIOMASESTADOS",
              "STATE",
              "ECONOMIC_ACTIVITY",
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
              "PRODUCT")

i <- sapply(emiss_aggr, is.factor)
emiss_aggr[i] <- lapply(emiss_aggr[i], as.character)

# length(newNames)
str(emiss_aggr)
# cbind(names(emiss_aggr),newNames)

names(emiss_aggr)
names(emiss_aggr) <- newNames

colnames(emiss_aggr)
str(emiss_aggr)
emiss_aggr <- emiss_aggr [, c(62, 1:3, 63, 4, 5, 61, 6, 7, 8, 9, 64, 41:60, 10:40)]
i <- sapply(emiss_aggr, is.factor)
emiss_aggr[i] <- lapply(emiss_aggr[i], as.character)

# colnames(emiss_aggr)[9]<-"CODIBGE"
# colnames(emiss_aggr)[10]<-"CODBIOMASESTADOS"

tabelao_full_mun<-emiss_aggr

tabelao_full_mun1<-emiss_aggr

plot(tabelao_full_mun$`2018`)

head(tabelao_full_mun)


setwd("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/")
#Exportacao para fins de armazenamento do processo
write.csv(tabelao_full_mun, file = "3_Tabelao_area_full_mun_col6.csv")

colnames(tabelao_full_mun1)
head(tabelao_full_mun1)
summary(tabelao_full_mun)

####Calculo das emissoes por queima de residuos florestais, com base nas emissoes por desmatamento

#Verificacao da ordem dos processos (com base no LEVEL_6) de desmatamento para aplicar no passo a seguir
unique(tabelao_full_mun$LEVEL_6)

##Selecionar transicoes que configuram desmatamento
# [1] "Floresta primária -- Área sem vegetação"             Desm                    
# [2] "Floresta primária -- Uso agropecuário"               Desm                    
# [3] "Floresta secundária -- Uso agropecuário"             Desm                    
# [4] "Uso agropecuário -- Área sem vegetação"                                  
# [5] "Uso agropecuário -- Floresta secundária"                                 
# [6] "Uso agropecuário -- Vegetação não florestal secundária"                  
# [7] "Floresta secundária -- Floresta secundária"                              
# [8] "Vegetação não florestal secundária -- Vegetação não florestal secundária"
# [9] "Área sem vegetação -- Uso agropecuário"                                  
# [10] "Floresta secundária -- Área sem vegetação"                Desm               
# [11] "Vegetação não florestal primária -- Área sem vegetação"            Desm      
# [12] "Vegetação não florestal primária -- Uso agropecuário"             Desm       
# [13] "Vegetação não florestal secundária -- Uso agropecuário"              Desm    
# [14] "Área sem vegetação -- Floresta secundária"                               
# [15] "Uso agropecuário -- Uso agropecuário"                                    
# [16] "Silvicultura -- Uso agropecuário"                                        
# [17] "Silvicultura -- Vegetação não florestal secundária"                      
# [18] "Vegetação não florestal primária -- Silvicultura"                        
# [19] "Uso agropecuário -- Silvicultura"                                        
# [20] "Vegetação não florestal secundária -- Área sem vegetação"               Desm 
# [21] "Área sem vegetação -- Vegetação não florestal secundária"                
# [22] "Vegetação não florestal secundária -- Silvicultura"                      
# [23] "Floresta primária -- Silvicultura"                                       
# [24] "Floresta secundária -- Silvicultura"                                     
# [25] "Silvicultura -- Área sem vegetação"                                      
# [26] "Silvicultura -- Floresta secundária"                                     
# [27] "Área sem vegetação -- Silvicultura"                                      
# [28] "Floresta primária -- Floresta primária"                                  
# [29] "Vegetação não florestal primária -- Vegetação não florestal primária"



#[1] "Floresta primária -- Área sem vegetação" Desm                                       
#[2] "Floresta primária -- Uso agropecuário"     Desm                                     
#[3] "Floresta secundária -- Uso agropecuário"     Desm                            
#[4] "Uso agropecuário -- Área sem vegetação"                                  
#[5] "Uso agropecuário -- Floresta secundária"                                 
#[6] "Uso agropecuário -- Vegetação não florestal secundária"                  
#[7] "Vegetação não florestal primária -- Área sem vegetação"    Desm                 
#[8] "Vegetação não florestal primária -- Uso agropecuário"      Desm                 
#[9] "Vegetação não florestal secundária -- Uso agropecuário"    Desm                 
#[10] "Floresta secundária -- Floresta secundária"                              
#[11] "Vegetação não florestal secundária -- Vegetação não florestal secundária"
#[12] "Uso agropecuário -- Uso agropecuário"                                    
#[13] "Área sem vegetação -- Uso agropecuário"                                  
#[14] "Floresta secundária -- Área sem vegetação"   #Desm                                   
#[15] "Vegetação não florestal secundária -- Área sem vegetação"         Desm       
#[16] "Silvicultura -- Floresta secundária"                                     
#[17] "Silvicultura -- Uso agropecuário"                                        
#[18] "Uso agropecuário -- Silvicultura"                                        
#[19] "Área sem vegetação -- Floresta secundária"                               
#[20] "Área sem vegetação -- Vegetação não florestal secundária"                
#[21] "NULL"                                                                    
#[22] "Floresta primária -- Silvicultura"                                       
#[23] "Vegetação não florestal primária -- Silvicultura"                        
#[24] "Silvicultura -- Área sem vegetação"                                      
#[25] "Floresta secundária -- Silvicultura"                                     
#[26] "Silvicultura -- Vegetação não florestal secundária"                      
#[27] "Vegetação não florestal secundária -- Silvicultura"                      
#[28] "Área sem vegetação -- Silvicultura"                                      
#[29] "Floresta primária -- Floresta primária"                                  
#[30] "Vegetação não florestal primária -- Vegetação não florestal primária" 

colnames(tabelao_full_mun)

desm <- tabelao_full_mun[tabelao_full_mun$LEVEL_6 %in% c(unique(tabelao_full_mun$LEVEL_6)[c(
  1,2,3,7,8,9,14,15)])
  & tabelao_full_mun$`TIPO DE VALOR` == "Emissão",]

desm$LEVEL_4[desm$LEVEL_4 == 1 ] <- 0 #nao diferencia entre dentro e fora de areas protegidas
colnames(tabelao_full_mun)

dim(desm)

colnames(desm)

#Agrupa total de emissoes por desmatamento
desm <- aggregate(desm[, c(14:64)], by = list(
  desm$SECTOR,
  desm$LEVEL_2,
  desm$LEVEL_3,
  as.character(desm$LEVEL_4),
  desm$LEVEL_5,
  desm$`TIPO DE VALOR`,
  desm$GAS,
  as.character(desm$CODIBGE),
  as.character(desm$CODBIOMASESTADOS),
  desm$STATE,
  desm$ECONOMIC_ACTIVITY,
  desm$PRODUCT),
  FUN = "sum")

dim(desm)
str(desm)
colnames(tabelao_full_mun)
# names(tabelao_full_mun)

tabelao_full_mun$`TIPO DE VALOR`
names(desm) <- names(tabelao_full_mun)[c(1:5,7:64)]
desm$LEVEL_6 <- "NA"
names(desm)
desm <- desm[c(1:5, 64, 6:63)]
# names(desm)
colnames(desm)

#Aplicacao dos fatores de emissao de CH4 e N2O com base nas emissoes de CO2 por desmatamento
ch42002 <- round(desm[14:46]*0.00169)
ch42020 <- round(desm[47:64]*0.00205)
n2o2002 <- round(desm[14:46] *0.000067)
n202020 <- round(desm[47:64]*0.000074)

#Organizacao dos resultados
ch4 <- cbind(ch42002, ch42020)
ch4$GAS <- "CH4 (t)"
n2o <- cbind(n2o2002, n202020)
n2o$GAS <- "N2O (t)" 

ch4$SECTOR <- desm$SECTOR[1]
n2o$SECTOR <- desm$SECTOR[1]

ch4$LEVEL_2 <- "Resíduos Florestais"
n2o$LEVEL_2 <- "Resíduos Florestais"

ch4$LEVEL_3 <- desm[,"LEVEL_3"]
n2o$LEVEL_3 <- desm[,"LEVEL_3"]

ch4$LEVEL_4 <- "NA"
n2o$LEVEL_4 <- "NA"

ch4$LEVEL_5 <- "NA"
n2o$LEVEL_5 <- "NA"

ch4$LEVEL_6 <- "NA"
n2o$LEVEL_6 <- "NA"

ch4$`TIPO DE VALOR` <- "Emissão"
n2o$`TIPO DE VALOR` <- "Emissão"

ch4$CODIBGE <- desm[,"CODIBGE"]
n2o$CODIBGE <- desm[,"CODIBGE"]

ch4$CODBIOMASESTADOS <- desm[,"CODBIOMASESTADOS"]
n2o$CODBIOMASESTADOS <- desm[,"CODBIOMASESTADOS"]

ch4$STATE <- desm[,"STATE"]
n2o$STATE <- desm[,"STATE"]

ch4$ECONOMIC_ACTIVITY <- desm[,"ECONOMIC_ACTIVITY"]
n2o$ECONOMIC_ACTIVITY <- desm[,"ECONOMIC_ACTIVITY"]

ch4$PRODUCT <- "NA"
n2o$PRODUCT <- "NA"

str(ch4)
names(ch4)
ch4 <- ch4[, c(53:58, 52, 59:64, 1:51)]
names(n2o)
n2o <- n2o[, c(53:58, 52, 59:64, 1:51)]

names(ch4)
names(n2o)

colnames(ch4)
#Calculo das emissoes de residuos como CO2 equivalente de acordo com as metricas de potencial de aquecimento do IPCC
TAR2 <- round((ch4[,14:64]*5)+(n2o [,14:64]*270))
WAR2 <- round((ch4[,14:64]*21)+(n2o[,14:64]*310))
TAR4 <- round((ch4[,14:64]*5)+(n2o [,14:64]*270))
WAR4 <- round((ch4[,14:64]*25)+(n2o[,14:64]*298))
TAR5 <- round((ch4[,14:64]*4)+(n2o [,14:64]*234))
WAR5 <- round((ch4[,14:64]*28)+(n2o[,14:64]*265))

names(ch4)
names(n2o)

#Organizacao dos resultados para agrupamento com o tabelao original
TAR2 <- cbind(ch4[,1:13], TAR2)
TAR2$GAS <- "CO2e (t) GTP-AR2"

WAR2 <- cbind(ch4[,1:13], WAR2)
WAR2$GAS <- "CO2e (t) GWP-AR2"

TAR4 <- cbind(ch4[,1:13], TAR4)
TAR4$GAS <- "CO2e (t) GTP-AR4"

WAR4 <- cbind(ch4[,1:13], WAR4)
WAR4$GAS <- "CO2e (t) GWP-AR4"

TAR5 <- cbind(ch4[,1:13], TAR5)
TAR5$GAS <- "CO2e (t) GTP-AR5"

WAR5 <- cbind(ch4[,1:13], WAR5)
WAR5$GAS <- "CO2e (t) GWP-AR5"

residuos <- as.data.frame(rbind(n2o, ch4, TAR2, WAR2, TAR4, WAR4, TAR5, WAR5))
head(residuos, 1)

#Aplicacao das diferentes metricas de CO2 equivalente tambem no tabelao original
emiss_aggrCO2 <-  tabelao_full_mun
emiss_aggrTAR2 <- tabelao_full_mun
emiss_aggrWAR2 <- tabelao_full_mun
emiss_aggrTAR4 <- tabelao_full_mun
emiss_aggrWAR4 <- tabelao_full_mun
emiss_aggrTAR5 <- tabelao_full_mun

emiss_aggrCO2$GAS <- "CO2 (t)"
emiss_aggrTAR2$GAS <- "CO2e (t) GTP-AR2"
emiss_aggrWAR2$GAS <- "CO2e (t) GWP-AR2"
emiss_aggrTAR4$GAS <- "CO2e (t) GTP-AR4"
emiss_aggrWAR4$GAS <- "CO2e (t) GWP-AR4"
emiss_aggrTAR5$GAS <- "CO2e (t) GTP-AR5"

tabelao <- rbind(
  tabelao_full_mun,
  emiss_aggrCO2,
  emiss_aggrTAR2,
  emiss_aggrWAR2,
  emiss_aggrTAR4,
  emiss_aggrWAR4,
  emiss_aggrTAR5)

#Agrupamento do tabelao com os calculos de residuos 
tabelao_full_final_mun <- rbind(tabelao, residuos) 

#Organizacao final
# names(tabelao_full_final_mun)
# unique(tabelao_full_final_mun$STATE)
tabelao_full_final_mun$LEVEL_3 <- as.factor(tabelao_full_final_mun$LEVEL_3)
levels(tabelao_full_final_mun$LEVEL_3) <- c("Amazônia",
                                            "Caatinga",
                                            "Cerrado",
                                            "Mata Atlântica",
                                            "Pampa",
                                            "Pantanal")


tabelao_full_final_mun$LEVEL_4 <- as.factor(tabelao_full_final_mun$LEVEL_4) 
levels(tabelao_full_final_mun$LEVEL_4) <- c("fora de Área Protegida", "em Área Protegida", "NA")


#Definição do tipo de processo (SEEG LEVEL_5)
#Verificacao da ordem dos processos (com base no LEVEL_6) para aplicar no passo a seguir

unique(tabelao_full_final_mun$LEVEL_6)
# [1] "Floresta primária -- Área sem vegetação"           Desm                      
# [2] "Floresta primária -- Uso agropecuário"                Desm                   
# [3] "Floresta secundária -- Uso agropecuário"             Desm                    
# [4] "Uso agropecuário -- Área sem vegetação"                 Outros                 
# [5] "Uso agropecuário -- Floresta secundária"                        Regen         
# [6] "Uso agropecuário -- Vegetação não florestal secundária"                Regen  
# [7] "Floresta secundária -- Floresta secundária"                       Estavel       
# [8] "Vegetação não florestal secundária -- Vegetação não florestal secundária"     Estavel
# [9] "Área sem vegetação -- Uso agropecuário"                    Outros              
# [10] "Floresta secundária -- Área sem vegetação"                      Desm         
# [11] "Vegetação não florestal primária -- Área sem vegetação"          Desm        
# [12] "Vegetação não florestal primária -- Uso agropecuário"              Desm      
# [13] "Vegetação não florestal secundária -- Uso agropecuário"             Desm     
# [14] "Área sem vegetação -- Floresta secundária"                     Regen          
# [15] "Uso agropecuário -- Uso agropecuário"                          Outros          
# [16] "Silvicultura -- Uso agropecuário"                              Outros          
# [17] "Silvicultura -- Vegetação não florestal secundária"               Regen    
# [18] "Vegetação não florestal primária -- Silvicultura"                    Desm    
# [19] "Uso agropecuário -- Silvicultura"                                Outros        
# [20] "Vegetação não florestal secundária -- Área sem vegetação"                Desm
# [21] "Área sem vegetação -- Vegetação não florestal secundária"             Regen
# [22] "Vegetação não florestal secundária -- Silvicultura"                      Desm
# [23] "Floresta primária -- Silvicultura"                                       Desm
# [24] "Floresta secundária -- Silvicultura"                                     Desm
# [25] "Silvicultura -- Área sem vegetação"                           Outros           
# [26] "Silvicultura -- Floresta secundária"                                 Regen
# [27] "Área sem vegetação -- Silvicultura"                           Outros           
# [28] "Floresta primária -- Floresta primária"                                  Estavel
# [29] "Vegetação não florestal primária -- Vegetação não florestal primária"    Estavel
# [30] "NA"                                                                   



#Coleção 6

#[1] Floresta primária -- Área sem vegetação                                      #Desm               
#[2] Floresta primária -- Uso agropecuário                                        #Desm         
#[3] Floresta secundária -- Uso agropecuário                                      #Desm               
#[4] Uso agropecuário -- Área sem vegetação                                       #Outros               
#[5] Uso agropecuário -- Floresta secundária                                      #Regen               
#[6] Uso agropecuário -- Vegetação não florestal secundária                       #Regen         
#[7] Vegetação não florestal primária -- Área sem vegetação                       #Desm               
#[8] Vegetação não florestal primária -- Uso agropecuário                         #Desm               
#[9] Vegetação não florestal secundária -- Uso agropecuário                       #Desm
#[10] Floresta secundária -- Floresta secundária                                  #Estável
#[11] Vegetação não florestal secundária -- Vegetação não florestal secundária    #Estável
#[12] Uso agropecuário -- Uso agropecuário                                        #Outros
#[13] Área sem vegetação -- Uso agropecuário                                      #Outros
#[14] Floresta secundária -- Área sem vegetação                                   #Desm
#15]  Vegetação não florestal secundária -- Área sem vegetação                     #Desm
#[16] Silvicultura -- Floresta secundária                                         #Regen
#[17] Silvicultura -- Uso agropecuário                                            #Outros
#[18] Uso agropecuário -- Silvicultura                                            #Outros
#[19] Área sem vegetação -- Floresta secundária                                   #Regen
#[20] NULL                                                                        #NA
#[21] Floresta primária -- Silvicultura                                           #Desmatamento
#[22] Vegetação não florestal primária -- Silvicultura                            #Desmatamento
#[23] Área sem vegetação -- Vegetação não florestal secundária                    #Regen
#[24] Silvicultura -- Área sem vegetação                                          #Outros
#[25] Floresta secundária -- Silvicultura                                         #Desma
#[26] Silvicultura -- Vegetação não florestal secundária                          #Regen
#[27] Vegetação não florestal secundária -- Silvicultura                          #Desm
#[28] Área sem vegetação -- Silvicultura                                          #Outros
#[29] Floresta primária -- Floresta primária                                      #Estável
#[30] Vegetação não florestal primária -- Vegetação não florestal primária        #Estável
#[31] NA


#[1] "Floresta primária -- Área sem vegetação"                                     #Desm
#[2] "Floresta primária -- Uso agropecuário"                                       #Desm
#[3] "Floresta secundária -- Uso agropecuário"                                     #Desm
#[4] "Uso agropecuário -- Área sem vegetação"                                      #Outros
#[5] "Uso agropecuário -- Floresta secundária"                                     #Regen
#[6] "Uso agropecuário -- Vegetação não florestal secundária"                      #Regen
#[7] "Vegetação não florestal primária -- Área sem vegetação"                      #Desm
#[8] "Vegetação não florestal primária -- Uso agropecuário"                        #Desm
#[9] "Vegetação não florestal secundária -- Uso agropecuário"                      #Desm
#[10] "Floresta secundária -- Floresta secundária"                                 #Estável
#[11] "Vegetação não florestal secundária -- Vegetação não florestal secundária"   #Estável
#[12] "Uso agropecuário -- Uso agropecuário"                                       #Outros
#[13] "Área sem vegetação -- Uso agropecuário"                                     #Outros
#[14] "Floresta secundária -- Área sem vegetação"                                  #Desm
#[15] "Vegetação não florestal secundária -- Área sem vegetação"                   #Desm
#[16] "NULL"                                                                       #NA
#[17] "Floresta primária -- Silvicultura"                                          #Desm
#[18] "Vegetação não florestal primária -- Silvicultura"                           #Desmatamento
#[19] "Área sem vegetação -- Floresta secundária"                                  #Regen 
#[20] "Área sem vegetação -- Vegetação não florestal secundária"                   #Regen
#[21] "Uso agropecuário -- Silvicultura"                                           #Outros
#[22] "Silvicultura -- Área sem vegetação"                                         #Outros
#[23] "Floresta secundária -- Silvicultura"                                        #Desmatamento
#[24] "Silvicultura -- Floresta secundária"                                        #Regeneração
#[25] "Silvicultura -- Uso agropecuário"                                           #Outros
#[26] "Silvicultura -- Vegetação não florestal secundária"                         #Regeneração
#[27] "Vegetação não florestal secundária -- Silvicultura"                         #Desmatamento
#[28] "Área sem vegetação -- Silvicultura"                                         #Outros
#[29] "Floresta primária -- Floresta primária"                                     #Estável
#[30] "Vegetação não florestal primária -- Vegetação não florestal primária"       #Estável
#[31] "NA"                                                                         #NA



#[1] "Floresta primária -- Área sem vegetação"         #Desmatamento                        
#[2] "Floresta primária -- Uso agropecuário"            #Desmatamento                       
#[3] "Floresta secundária -- Uso agropecuário"               #Desmatamento                  
#[4] "Uso agropecuário -- Área sem vegetação"                       Outros           
#[5] "Uso agropecuário -- Floresta secundária"                        Regen         
#[6] "Uso agropecuário -- Vegetação não florestal secundária"              Regen    
#[7] "Vegetação não florestal primária -- Área sem vegetação"                  Desma
#[8] "Vegetação não florestal primária -- Uso agropecuário"                    Desma
#[9] "Vegetação não florestal secundária -- Uso agropecuário"                  Desm
#[10] "Floresta secundária -- Floresta secundária"                              Estável
#[11] "Vegetação não florestal secundária -- Vegetação não florestal secundária" Estáveç
#[12] "Uso agropecuário -- Uso agropecuário"                                    #Outos
#[13] "Área sem vegetação -- Uso agropecuário"                                  #Outros
#[14] "Floresta secundária -- Área sem vegetação"                               #Desm
#[15] "Vegetação não florestal secundária -- Área sem vegetação"                #Desm
#[16] "Silvicultura -- Floresta secundária"                                     #Regen
#[17] "Silvicultura -- Uso agropecuário"                                        #Outros
#[18] "Uso agropecuário -- Silvicultura"                                        #Outros
#[19] "Área sem vegetação -- Floresta secundária"                               #Regen
#[20] "Área sem vegetação -- Vegetação não florestal secundária"                #Regen
#[21] "NULL"                                                                    #NA
#[22] "Floresta primária -- Silvicultura"                                       #desma
#[23] "Vegetação não florestal primária -- Silvicultura"                        #Desma
#[24] "Silvicultura -- Área sem vegetação"                                      #Outros
#[25] "Floresta secundária -- Silvicultura"                                     #Desmatamento
#[26] "Silvicultura -- Vegetação não florestal secundária"                      #Regen
#[27] "Vegetação não florestal secundária -- Silvicultura"                      #Desmatamento
#[28] "Área sem vegetação -- Silvicultura"                                      #Outros
#[29] "Floresta primária -- Floresta primária"                                  #Estável
#[30] "Vegetação não florestal primária -- Vegetação não florestal primária"    #Estável
#[31] "NA                                                                       #NA



tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  unique(tabelao_full_final_mun$LEVEL_6)[c(5,6, 16,19,20,26)]] <- "Regeneração" #Caution Oscilation
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  unique(tabelao_full_final_mun$LEVEL_6)[c(10, 11, 29, 30)]] <- "Vegetação nativa estável" #Stable
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  unique(tabelao_full_final_mun$LEVEL_6)[c(1,2,3,7,8,9,14,15,22,23,25,27)]] <- "Desmatamento" # Caution Oscilation
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  unique(tabelao_full_final_mun$LEVEL_6)[c(21,31)]] <- "NA"
tabelao_full_final_mun$LEVEL_5 [tabelao_full_final_mun$LEVEL_6 %in%
                                  unique(tabelao_full_final_mun$LEVEL_6)[c(4,12,13,17,18,24,28)]] <- "Outras Mudanças de uso da terra"

#


#setwd("C:/Users/edriano.souza/OneDrive/data_2021/highligts/")
write.csv(tabelao_full_final_mun, file = "4_SEEG_Tabelao_full_mun_col6.csv")


colnames(tabelao_full_final_mun)

# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="RONDONIA"]<-"RO"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="ACRE"]<-"AC"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="AMAZONAS"]<-"AM"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="RORAIMA"]<-"RR"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="PARA"]<-"PA"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="AMAPA"]<-"AP"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="TOCANTINS"]<-"TO"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="MARANHAO"]<-"MA"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="MATO GROSSO"]<-"MT"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="RIO GRANDE DO NORTE"]<-"RN"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="PARAIBA"]<-"PB"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="PERNAMBUCO"]<-"PE"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="ALAGOAS"]<-"AL"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="SERGIPE"]<-"SE"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="BAHIA"]<-"BA"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="MINAS GERAIS"]<-"MG"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="ESPIRITO SANTO"]<-"ES"
#tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="ESPIRITO SANTO"]<-"ESPÍRITO SANTO"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="RIO DE JANEIRO"]<-"RJ"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="SAO PAULO"]<-"SP"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="PARANA"]<-"PR"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="SANTA CATARINA"]<-"SC"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="RIO GRANDE DO SUL"]<-"RS"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="MATO GROSSO DO SUL"]<-"MS"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="GOIAS"]<-"GO"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="PIAUI"]<-"PI"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="DISTRITO FEDERAL"]<-"DF"
# tabelao_full_final_mun$STATE[tabelao_full_final_mun$STATE=="CEARA"]<-"CE"

newNames <- c("Nivel_1_Setor",
              "Nivel_2",
              "Nivel_3",
              "Nivel_4",
              "Nivel_5",
              "Nivel_6",
              "Emissao_Remocao",
              "Gas",
              "CodIBGE",
              "CodBiomasEstados",
              "Estado",
              "Atividade_Economica",
              "Produto",
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
              "2020")

names(tabelao_full_final_mun) <- newNames



#Geracao e exportacao do tabelao para estados
tabelao_full_final_estados <- tabelao_full_final_mun
tabelao_full_final_estados <- aggregate(tabelao_full_final_estados[,14:64], by = list(
  tabelao_full_final_estados$Nivel_1_Setor,
  tabelao_full_final_estados$Nivel_2,
  tabelao_full_final_estados$Nivel_3,
  tabelao_full_final_estados$Nivel_4,
  tabelao_full_final_estados$Nivel_5,
  tabelao_full_final_estados$Nivel_6,
  tabelao_full_final_estados$Emissao_Remocao,
  tabelao_full_final_estados$Gas,
  tabelao_full_final_estados$Estado,
  tabelao_full_final_estados$Atividade_Economica,
  tabelao_full_final_estados$Produto), FUN = "sum")
names(tabelao_full_final_estados) <- names(tabelao_full_final_mun[,-c(9,10)])
#head(tabelao_full_final_estados,4)
write.csv(tabelao_full_final_estados, file = "TABELAO_MUT_ESTADOS-26-09.csv",row.names=F)
colnames(tabelao_full_final_mun)


#Geracao e exportacao do tabelao para o Brasil
tabelaoBR <- tabelao_full_final_mun
tabelaoBR$Estado <- "BR"
tabelaoBR <- aggregate(tabelaoBR[,14:64], by = list(
  tabelaoBR$Nivel_1_Setor,
  tabelaoBR$Nivel_2,
  tabelaoBR$Nivel_3,
  tabelaoBR$Nivel_4,
  tabelaoBR$Nivel_5,
  tabelaoBR$Nivel_6,
  tabelaoBR$Emissao_Remocao,
  tabelaoBR$Gas,
  tabelaoBR$Estado,
  tabelaoBR$Atividade_Economica,
  tabelaoBR$Produto), FUN = "sum")
names(tabelaoBR) <- names(tabelao_full_final_mun[,-c(9,10)])
write.csv(tabelaoBR, file = "TABELAO_MUT_BR-26-09.csv",row.names=F)


str(tabelao_full_final_mun$CodIBGE)

#Organizacao dos nomes dos municipios
setwd("C:/Users/edriano.souza/OneDrive/teste")

nomesmun<-read.csv("nomes_mun_IBGE.csv",head=T,sep=";")
colnames(nomesmun)

nomesmun<-nomesmun[,1:2]
str(nomesmun)

nomesmun$GEOCODIGO2<-as.character(nomesmun$GEOCODIGO)
nomesmun$IBGE <- as.character(nomesmun$IBGE)

tabelao_full_final_mun$CodIBGE <- as.factor(nomesmun$GEOCODIGO2)
library(dplyr)


tabelao_full_final_mun$IBGE <- as.character(tabelao_full_final_mun$CodIBGE)


nomesmun <- as.data.frame(nomesmun)
tabelao_full_final_mun <- as.data.frame(tabelao_full_final_mun)
#tabelao_full_final_mun$CodIBGE<-as.character(str_sub(tabelao_full_final_mun$CodIBGE,4,10)) No caso do 4 ao décimos
head(tabelao_full_final_mun_OK,3)
head(tabelao_full_final_mun,3)

tabelao_full_final_mun$CodIBGE<-as.character(tabelao_full_final_mun$CodIBGE)


tabelao_full_final_mun<-tabelao_full_final_mun[,-c(65,66)] #N

str(tabelao_full_final_mun)

str()

a<- left_join(y=nomesmun,x= tabelao_full_final_mun, by=c("CodIBGE"="GEOCODIGO2"))



tabelao_full_final_mun1<-tabelao_full_final_mun%>%
  left_join(nomesmun,by=c("CodIBGE"="GEOCODIGO"))
# names(tabelao_full_final_mun)



head(a,5)
# names(tabelao_full_final_mun)
tabelao_full_final_mun$Nome_Município

setwd("C:/Users/edriano.souza/OneDrive/data_2021/highligts/")

write.csv(tabelao_full_final_mun, file = "TABELAO_MUT_MUN-26-09.csv",row.names=F,fileEncoding = "UTF-8")
