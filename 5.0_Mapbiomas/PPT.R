# SEEG - Script for the plots of emissions and removals GHG_BR-----------------
-------------------------------------------------------
  Title:"Script for the plots of emissions and removals GHR_BR"

# Created by: 'Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza'
# For clarification or an issue/bug report, please write to barbara.zimbres@ipam.org.br and/or edriano.souza@ipam.org.br
# Key activities in sections
-------------------------------------------------------

##
##Start
gc()
memory.limit(9999999999) # or your memory

## Setting your project.R  -------------
# !!! Eg. ~/3._Plots
# //! Create Folder: 'data'; 'R/script'; 'Results'


### Required packages  -------------------------------------------------------
# e.g.
#install.packages("pacman") #// or
## install.packages("usethis")
#install.packages(c("usethis", "geojsonR", "jsonlite", "googledrive", "openxlsx", "ggplot2", "tidyverse", "tidyr", "dplyr", "rlang"))
library(pacman)
pacman::p_load(usethis, googledrive,readxl,openxlsx, 
               ggplot2, tidyverse, tidyr, dplyr, geobr,
               sf,magrittr,gghighlight,ggpubr, ggspatial)


## Set your directory with data uf_csv--------------------------------------------
setwd('data/')
files_mut<-dir(pattern = '\\.csv$')
for(i in files_mut) {assign(unlist(strsplit(i, "[.]"))[1], read.csv2(i,  sep = ",", h=T, encoding = "UTF-8")) }


### Join tables UF n= 27 states------------------------------------------
mut<-rbind(`TABELAO_MUT_MUN-08-04_AC`, `TABELAO_MUT_MUN-08-04_AL`, `TABELAO_MUT_MUN-08-04_AM`,
           `TABELAO_MUT_MUN-08-04_AP`, `TABELAO_MUT_MUN-08-04_BA`, `TABELAO_MUT_MUN-08-04_CE`,
           `TABELAO_MUT_MUN-08-04_DF`, `TABELAO_MUT_MUN-08-04_ES`, `TABELAO_MUT_MUN-08-04_GO`,
           `TABELAO_MUT_MUN-08-04_MA`, `TABELAO_MUT_MUN-08-04_MG`, `TABELAO_MUT_MUN-08-04_MS`,
           `TABELAO_MUT_MUN-08-04_MT`, `TABELAO_MUT_MUN-08-04_PB`, `TABELAO_MUT_MUN-08-04_PA`,
           `TABELAO_MUT_MUN-08-04_PE`, `TABELAO_MUT_MUN-08-04_PI`, `TABELAO_MUT_MUN-08-04_PR`,
           `TABELAO_MUT_MUN-08-04_RJ`, `TABELAO_MUT_MUN-08-04_RN`, `TABELAO_MUT_MUN-08-04_RO`,
           `TABELAO_MUT_MUN-08-04_RR`, `TABELAO_MUT_MUN-08-04_RS`, `TABELAO_MUT_MUN-08-04_SC`,
           `TABELAO_MUT_MUN-08-04_SE`, `TABELAO_MUT_MUN-08-04_SP`, `TABELAO_MUT_MUN-08-04_TO` 
)



### Duplicate ---------------------------------------------------------------
mut9 <- mut


## Head (colnames)
colnames(mut9)
mut9[,15:65] <- as.numeric(unlist(mut9[,15:65])) #column with a estimates yearly in the type: numeric 


### Return your directory eg.--------------------------------------------
setwd('C:/Users/edriano.souza/GitHub/3._Plots')


### Recode ---------------------------------------------------------------
newNames9 <- c("NIVEL 1",
               "NIVEL 2",
               "NIVEL 3",
               "NIVEL 4",
               "NIVEL 5",
               "NIVEL 6",
               "TIPO DE EMISSÃO",
               "GÁS",
               "CODIBGE",
               "Nome_Município",
               "CODBIOMASESTADOS",
               "ESTADOS",
               "ATIVIDADE ECONÔMICA",
               "PRODUTO",
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

colnames(mut9)<-newNames9


# Select gas between ------------------------------------------------------


mut_OK9<- mut9[mut9$GÁS=="CO2e (t) GWP-AR5",]

head(mut_OK9,5)


mut_OK9[,15:65] <- as.numeric(unlist(mut_OK9[,15:65])) #column with a estimates yearly in the type: numeric 



## Join table Emission and removals -------------------------------------------------
ebt9<- mut_OK9 %>%
  #filter(`NIVEL 2` == "Alterações de Uso do Solo"|`NIVEL 2` == "Resíduos Florestais")%>% 
  filter (`NIVEL 2` == "Remoção em Áreas Protegidas"|`NIVEL 2` == "Remoção por Mudança de Uso da Terra"|`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  group_by(`NIVEL 2` , `Nome_Município`, CODIBGE) %>% #P2
  #group_by(`Nome_Município`, CODIBGE) %>% #P2
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`),
            '2020'=sum(`2020`))
dff9 <- as.data.frame(ebt9)



dff9$`1990` <- as.numeric(dff9$`1990`/1000000) 
dff9$`1991` <- as.numeric(dff9$`1991`/1000000) 
dff9$`1992` <- as.numeric(dff9$`1992`/1000000) 
dff9$`1993` <- as.numeric(dff9$`1993`/1000000) 
dff9$`1994` <- as.numeric(dff9$`1994`/1000000) 
dff9$`1995` <- as.numeric(dff9$`1995`/1000000) 
dff9$`1996` <- as.numeric(dff9$`1996`/1000000) 
dff9$`1997` <- as.numeric(dff9$`1997`/1000000) 
dff9$`1998` <- as.numeric(dff9$`1998`/1000000) 
dff9$`1999` <- as.numeric(dff9$`1999`/1000000) 
dff9$`2000` <- as.numeric(dff9$`2000`/1000000)   
dff9$`2001` <- as.numeric(dff9$`2001`/1000000)
dff9$`2002` <- as.numeric(dff9$`2002`/1000000)
dff9$`2003` <- as.numeric(dff9$`2003`/1000000)
dff9$`2004` <- as.numeric(dff9$`2004`/1000000)
dff9$`2005` <- as.numeric(dff9$`2005`/1000000)
dff9$`2006` <- as.numeric(dff9$`2006`/1000000)
dff9$`2007` <- as.numeric(dff9$`2007`/1000000)
dff9$`2008` <- as.numeric(dff9$`2008`/1000000)
dff9$`2009` <- as.numeric(dff9$`2009`/1000000)
dff9$`2010` <- as.numeric(dff9$`2010`/1000000)
dff9$`2011` <- as.numeric(dff9$`2011`/1000000)
dff9$`2012` <- as.numeric(dff9$`2012`/1000000)
dff9$`2013` <- as.numeric(dff9$`2013`/1000000)
dff9$`2014` <- as.numeric(dff9$`2014`/1000000)
dff9$`2015` <- as.numeric(dff9$`2015`/1000000)
dff9$`2016` <- as.numeric(dff9$`2016`/1000000)
dff9$`2017` <- as.numeric(dff9$`2017`/1000000)
dff9$`2018` <- as.numeric(dff9$`2018`/1000000)
dff9$`2019` <- as.numeric(dff9$`2019`/1000000)
dff9$`2020` <- as.numeric(dff9$`2020`/1000000)

colnames(dff9)

df <- reshape (dff9, varying = list(colnames(dff9[4:34])),#i+1
               times = names(dff9[4:34]), #i+1
               timevar = "ANO",
               direction = "long")

colnames(df)

colnames(df)[5]<-c("VALOR")#i+1

colnames(df)

df<-df[,-c(6)]#i+1


#2

df <- reshape (dff9, varying = list(colnames(dff9[3:33])),#i+1
               times = names(dff9[3:33]), #i+1
               timevar = "ANO",
               direction = "long")

colnames(df)

colnames(df)[4]<-c("VALOR")#i+1

colnames(df)

df<-df[,-c(5)]#i+1


#Joint GEOBR -------------------------------------------------------------


##############################
all_mun <- read_municipality(year=2020)

all_reg <- read_region(year=2020)
apendice_c_geo <- read_biomes(year = 2019) %>%
  filter(name_biome == "Amazônia"| name_biome == "Cerrado"|name_biome == "Caatinga"|
           name_biome == "Mata Atlântica"| name_biome == "Pampa"| name_biome == "Pantanal")

ti <- read_indigenous_land(date=202103)

df1 <- df %>%
  filter(ANO == "2019")

## Create subsets ----------------------------------------------------------

## Master
dataset_final1 = left_join(all_mun, df1, by=c("code_muni"="CODIBGE"))
dataset_final2 = left_join(ti, df1, by=c("name_muni"="Nome_Município"))

## Region
dataset_finalN = dataset_final1 %>%
  filter(name_region == "Norte")
  
dataset_finalNE = dataset_final1 %>%
  filter(name_region == "Nordeste")

dataset_finalCO = dataset_final1 %>%
  filter(name_region == "Centro Oeste")

dataset_finalSUD = dataset_final1 %>%
  filter(name_region == "Sudeste")

dataset_finalSUL = dataset_final1 %>%
  filter(name_region == "Sul")



# Road --------------------------------------------------------------------


library(rgdal)
library(sp)

roadbr<- read.csv(file= "c:/Users/edriano.souza/GitHub/3._Plots/vw_snv_rod.csv", header = T, sep= ",")

coord_pontos <- dataset_finalSUD %>% 
  mutate(VALOR2 = VALOR) %>% 
  #tidyr::drop_na(VALOR) %>% 
  st_centroid() 



#A############################################
top10R2 <- dataset_final1 %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ## Emissões 
  #filter (name_muni == "Açailândia"|name_muni == "Amarante Do Maranhão"|
            #name_muni == "Arame"|name_muni == "Bom Jardim"|
            #name_muni == "Bom Jesus Das Selvas"|name_muni == "Buriticupu"|
            #name_muni == "Centro Novo Do Maranhão"|name_muni == "Entre Rios"|
            #name_muni == "Itinga Do Maranhão"|name_muni == "Uruçuí")%>% 
  ##### Municipios maiores removedores
  filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  name_muni == "Altamira"|name_muni == "Itaituba"|
  name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)


#A############################################
top10NE1 <- dataset_finalNE %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ## Remoções brutas
  filter(name_muni == "Açailândia"|name_muni == "Amarante Do Maranhão"|
  name_muni == "Bom Jardim"|name_muni == "Bom Jesus Das Selvas"|
  name_muni == "Centro Novo Do Maranhão"|name_muni == "Fernando Falcão"|
  name_muni == "Itinga Do Maranhão"|name_muni == "Santa Luzia"|
  name_muni == "Formosa Do Rio Preto"|name_muni == "Alto Alegre Do Pindaré")%>%
  #filter(name_state == "Maranhão"| name_state == "Bahia") %>% 
  ##### Municipios maiores removedores
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)


#A############################################
top10CO2 <- dataset_finalCO %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ## Remoções brutas
  filter(name_muni == "Juína"|name_muni == "Apiacás"|
           name_muni == "Colniza"|name_muni == "Gaúcha Do Norte"|
           name_muni == "Comodoro"|name_muni == "Aripuanã"|
           name_muni == "Querência"|name_muni == "Corumbá"|
           name_muni == "Rondolândia"|name_muni == "Paranatinga")%>%
  #filter(name_state == "Maranhão"| name_state == "Bahia") %>% 
  ##### Municipios maiores removedores
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-11, VALOR)


#A############################################
top10SUL1 <- dataset_finalSUL %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ## Remoções brutas
  filter(name_muni == "Alegrete"|name_muni == "Uruguaiana"|name_muni =="Rosário do Sul"|name_muni =="Bagé"|
           name_muni == "São Gabriel"|name_muni == "Dom Pedrito"|
           name_muni == "Sant'ana Do Livramento"|name_muni == "Santa Vitória Do Palmar"|
           name_muni == "Canguçu"|
           name_muni == "Cacequi"|name_muni == "São Borja")%>%
  #filter(name_state == "Maranhão"| name_state == "Bahia") %>% 
  ##### Municipios maiores removedores
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)


#####################################################
top10SUD <- dataset_finalSUD %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ## Emissões 
  #filter (name_muni == "Açailândia"|name_muni == "Amarante Do Maranhão"|
  #name_muni == "Arame"|name_muni == "Bom Jardim"|
  #name_muni == "Bom Jesus Das Selvas"|name_muni == "Buriticupu"|
  #name_muni == "Centro Novo Do Maranhão"|name_muni == "Entre Rios"|
  #name_muni == "Itinga Do Maranhão"|name_muni == "Uruçuí")%>% 
  ##### Municipios maiores removedores
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
            #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
            #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
            #name_muni == "Altamira"|name_muni == "Itaituba"|
            #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)


#####################################################
top10SUD1 <- dataset_finalSUD %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  ##### Municipios maiores removedore
  filter (name_muni == "João Pinheiro"|name_muni == "Buritizeiro"|
  name_muni == "Januária"|name_muni == "Paracatu"|
  name_muni == "Bonito De Minas"|name_muni == "Jequitinhonha"|
  name_muni == "Unaí"|name_muni == "Araçuaí"|
  name_muni == "Arinos"|name_muni == "Almenara")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>%
  #filter (name_muni == "Atalaia Do Norte"|name_muni == "Barcelos"|
  #name_muni == "Lábrea"|name_muni == "Santa Isabel Do Rio Negro"|
  #name_muni == "São Gabriel Da Cachoeira"|name_muni == "Almeirim"|
  #name_muni == "Altamira"|name_muni == "Itaituba"|
  #name_muni == "Oriximiná"|name_muni == "São Félix Do Xingu")%>% 
  #filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)


top10SUD_OK <- rbind(top10SUD1,top10SUD2,top10SUD3) 
ranksSUD = top10SUD_OK %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

##########

ranksSUD = top10SUD %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

#################
top10SUL_OK <- rbind(top10SUL1,top10SUL2, top10SUL3)

top10CO_OK <- rbind(top10CO1,top10CO2, top10CO3)

top10NE_OK <- rbind(top10NE1,top10NE2, top10NE3)

top10N <- rbind(top10N_1,top10N_2, top10N_3)

top10N <- rbind(top10N_R1,top10N_R2, top10N_R3)

top10NR <- rbind(top10N_R1,top10N_R2, top10N_R3)



top10A <- rbind(top10R1,top10R2, top10R3)

ranks10A = top10A %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


ranksNE = top10NEEE %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


ranksN = top10N %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))

ranksN = top10N %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))

ranksSUL = top10SUL_OK %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


##############################################################################

###############################################
top10N <- dataset_finalN2 %>% 
  filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  # selecionar o top 10
  top_n(10, VALOR)

ranksN = top10N %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))
#############################################

top10NE <- dataset_finalNE %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  # selecionar o top 10
  top_n(-10, VALOR)

ranksNE = top10NE %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))

###########################################

top10CO_2 <- dataset_finalCO %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  #filter(`NIVEL 2` == "Resíduos Florestais")%>%
  # selecionar o top 10
  top_n(-10, VALOR)

top10COk <- rbind(top10CO_1,top10CO_2)


ranksCO = top10CO_2 %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

 

ranks = top10 %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

###################

top10SUD_2 <- dataset_finalSUD %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  filter(`NIVEL 2` == "Resíduos Florestais")%>%
  filter (name_muni == "Águas Vermelhas"|name_muni == "Almenara"|
            name_muni == "Buritizeiro"|name_muni == "Itamarandiba"|
            name_muni == "Jequitinhonha"|name_muni == "João Pinheiro"|
            name_muni == "Minas Novas"|name_muni == "Paracatu"|
            name_muni == "Unaí"|name_muni == "Linhares")%>%
  # selecionar o top 10
  top_n(10, VALOR)


top10SUDok <- rbind(top10SUD_1,top10SUD_2)

ranksSUD  = top10SUDok  %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))



top10SUL <- dataset_finalSUL %>% 
  top_n(-10, VALOR) %>%
  slice_max(order_by = name_muni, n = -10)

ranksSUL  = top10SUL  %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

########################################################

top10SUL_2 <- dataset_finalSUL %>% 
  #filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  filter(`NIVEL 2` == "Resíduos Florestais")%>%
  filter (name_muni == "Coronel Domingos Soares"|name_muni == "Guarapuava"|
            name_muni == "Nova Laranjeiras"|name_muni == "Prudentópolis"|
            name_muni == "Alegrete"|name_muni == "Dom Pedrito"|
            name_muni == "Rosário Do Sul"|name_muni == "Sant'ana Do Livramento"|
            name_muni == "São Francisco De Assis"|name_muni == "São Gabriel")%>%
  # selecionar o top 10
  top_n(10, VALOR)


top10SULok <- rbind(top10SUL_1,top10SUL_2)

ranksSUL  = top10SUL  %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))












top10E1 <- dataset_final1 %>% 
  filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  # selecionar o top 10
  top_n(10, VALOR)

top10W1 <- dataset_final1 %>%
  filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  # selecionar o top 10
  top_n(10, VALOR)    

a<- rbind(top10E1,top10W1)
ranks = top10 %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


top10R1 <- dataset_final1 %>% 
  filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  # selecionar o top 10
  top_n(10, VALOR)

top10R2 <- dataset_final1 %>%
  filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  # selecionar o top 10
  top_n(10, VALOR)    

top10R3 <- dataset_final1 %>%
  filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  # selecionar o top 10
  top_n(10, VALOR) 


### Concatenate two string columns

a$mun_and_state = paste(a$name_muni,", ",a$abbrev_state,sep = "")

top10NEEE$mun_and_state = paste(top10NEEE$name_muni,", ",top10NEEE$abbrev_state,sep = "")

windowsFonts(fonte.tt= windowsFont("TT Arial"))


### Plot 2

top10E$mun_and_state = paste(top10E$name_muni,", ",top10E$abbrev_state,sep = "")


p1<- top10 %>% 
  mutate(mun_and_state = fct_reorder(mun_and_state, VALOR)) %>%
  ggplot(aes(x =mun_and_state, y = VALOR, fill = factor(`NIVEL 2`,levels = c('Emissions by the burning of vegetation residuals',
                                                                             'Emissions by land use change'))))+
  #geom_col(aes(fill = `NIVEL 2`)) +
  geom_bar(position="stack", stat="identity",  na.rm = T, width = 0.5)+
  scale_fill_manual(values=c("#fcd5b5","#c0504d"))+
  scale_color_manual(labels = c('Emissions by the burning of vegetation residuals','Emissions by land use change'))+
  scale_y_continuous(limits=c(0, 55), breaks = c(0, 5, 10,15,20,25,30,35,40,45,50,55))+
  # inverter eixos
  coord_flip()+
  #scale_y_comma(position = "right") +
  #theme(legend.position="none")+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 2, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  ylab("Millions of tonnes of CO2e (GWP-AR6)") +
  xlab(" ")+
  theme(legend.position=c(.65,.2), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(p1)

a<- ggplot() +
  geom_sf(data=dataset_finalSUD, aes(fill=VALOR), size=.125, color=alpha("gray",0.1))+
  scale_fill_distiller(palette = "Oranges",type="seq",trans = "reverse", name="Mt Co2eq")+
  theme_minimal()+
  theme(legend.position="right")+
  #theme(legend.position=c(1,.85), legend.box = "horizontal",legend.justification = "center", legend.direction = "horizontal")+
  theme(legend.key = element_blank())+
  ylab("") + xlab(" ")+
  theme(legend.direction = "vertical")+
  geom_sf_text(data=ranksSUD, aes(label=ranks))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))
 



####################

ggsave("Fig1SUL_.png", plot = a,dpi = 330)

plot(a)

windowsFonts(fonte.tt= windowsFont("TT Arial"))



top10N$mun_and_state = paste(top10N$name_muni,", ",top10N$abbrev_state,sep = "")


top10 <- top10 %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Mudança de Uso da Terra` = "Removals by other type of land use change",
                            `Remoção por Vegetação Secundária`= "Removals by secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "Removals in protected areas",
                            `Alterações de Uso do Solo` = "Emissions by land use change",
                            `Resíduos Florestais` = "Emissions by the burning of vegetation residuals"))


p1<-top10N %>% 
  mutate(mun_and_state = fct_reorder(mun_and_state, VALOR)) %>%
  ggplot(aes(x =mun_and_state, y = VALOR, fill = factor(`NIVEL 2`,levels = c('Alterações de Uso do Solo','Resíduos Florestais'))))+
  #geom_col(aes(fill = `NIVEL 2`)) +
  geom_bar(position="stack", stat="identity",  na.rm = T, width = 0.75)+
  scale_fill_manual(values=c("#c0504d","#fcd5b5"))+
  scale_color_manual(labels = c('Alterações de Uso do Solo','Resíduos Florestais'))+
  scale_y_continuous(limits=c(0, .75), breaks = c(0, .1,.2,.3,.4,.5,.6,.7,.8))+
  # inverter eixos
  coord_flip()+
  #scale_y_comma(position = "right") +
  #theme(legend.position="none")+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 2, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  ylab("Emissão Bruta em Milhões de Toneladas de CO2e (Mt Co2e - GWP_AR5)") +
  xlab(" ")+
  theme(legend.position=c(.78,.2), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=11 ))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(p1)



ggsave("Fig2_Sul_.png", plot = p1,dpi = 330)




# Change data rownames as a real column called 'carName'
data <- top10 %>%
  rownames_to_column(code_muni)




a<- ggplot() +
  #scale_fill_distiller(palette = "Greens",type="seq", trans = "reverse", name="Mt Co2eq")+
  #scale_size_continuous(name="Mt Co2eq",breaks=seq(-25,0,5))+
  #theme(legend.direction = "vertical")+
  geom_sf(data=dataset_finalSUD, aes(fill=VALOR), size=.125, color=alpha("gray",0.1))+
  scale_fill_distiller(palette = "Greens",type="seq", name="Mt Co2eq")+
  theme_minimal()+
  #geom_sf(data = all_reg, color=alpha("black",01), fill = NA)+
  theme(legend.position=c(.69,.80), legend.box = "vertical",legend.justification = "center", legend.direction = "vertical")+
  theme(legend.key = element_blank())+
  ylab("") + xlab(" ")+
  #geom_sf(data = coord_pontos, aes(size = VALOR2)) + 
  #scale_fill_distiller(palette = "Greens",type="seq", name="Mt Co2eq")+
  #geom_sf(data = coord_pontos, aes(size = VALOR2), color=alpha("green",0.5),type="seq") + 
  #scale_size_continuous(name="Mt Co2eq",breaks=seq(-25,0,5))+
  #scale_size(trans = "reverse", name="Mt Co2eq",breaks=seq(-25,0,5))+
  #scale_fill_distiller(palette = "Greens",type="seq", name="Mt Co2eq")+
  geom_sf_text(data=ranksSUD, aes(label=ranks))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))+
  # Adiciona o Norte Geográfico
  annotation_north_arrow(
    location = "br",
    which_north = "true",
    height = unit(1, "cm"),
    width = unit(1, "cm"),
    pad_x = unit(0.1, "in"),
    pad_y = unit(0.1, "in"),
    style = north_arrow_fancy_orienteering) +
  ggspatial::annotation_scale()
plot(a)

ggsave("P22_RemoSUD_.png", plot = a,dpi = 330)

max(as.numeric(coord_pontos$VALOR))
plot(a)

p<- ggpubr::ggarrange(a, p1,
                      ncol=1,
                      widths= c(1,1),
                      heights = c(2,1),# list of plots
                      #labels = "AUTO", # labels
                      #common.legend = T,# COMMON LEGEND
                      #legend = "top", # legend position
                      align = "v",
                      #align = "hv",# Align them both, horizontal and vertical
                      nrow = 2)  # number of rows


















###################################################################



top10NE_OK$mun_and_state = paste(top10NE_OK$name_muni,", ",top10NE_OK$abbrev_state,sep = "")

top10CO_OK$mun_and_state = paste(top10CO_OK$name_muni,", ",top10CO_OK$abbrev_state,sep = "")

top10SUL_OK$mun_and_state = paste(top10SUL_OK$name_muni,", ",top10SUL_OK$abbrev_state,sep = "")

top10$mun_and_state = paste(top10$name_muni,", ",top10$abbrev_state,sep = "")


top10A$mun_and_state = paste(top10A$name_muni,", ",top10A$abbrev_state,sep = "")

top10SUD_OK$mun_and_state = paste(top10SUD_OK$name_muni,", ",top10SUD_OK$abbrev_state,sep = "")
top10SUD_OK


top10 <- top10N %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Mudança de Uso da Terra` = "Removals by other type of land use change",
                            `Remoção por Vegetação Secundária`= "Removals by secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "Removals in protected areas",
                            `Alterações de Uso do Solo` = "Emissions by land use change",
                            `Resíduos Florestais` = "Emissions by the burning of vegetation residuals"))

top10NE_OK1 <- top10NE_OK[-mun_and_state == "Barra,BA", ]
p1<- 
  top10SUD_OK%>% 
  #ungroup() %>% 
  #filter(mun_and_state != "Santa Luzia, PB")%>%
  #filter(mun_and_state != "Santa Luzia, BA")%>%
  #filter(mun_and_state != "Bom Jardim, PE")%>%
  mutate(mun_and_state = fct_reorder(mun_and_state, VALOR)) %>%
  ggplot(aes(x=reorder(mun_and_state,VALOR), y = VALOR, fill = factor(`NIVEL 2`,levels = c('Remoção em Áreas Protegidas', 'Remoção por Mudança de Uso da Terra','Remoção por Vegetação Secundária'))))+
  geom_col(aes(fill = `NIVEL 2`,x=reorder(mun_and_state,VALOR))) +
  #geom_bar(position="stack", stat="identity",  na.rm = T, width = 0.75)+
  scale_fill_manual(values=c("#4f6228","#d7e4bd","#9bbb59"))+
  scale_color_manual(labels = c('Remoção por Mudança de Uso da Terra','Remoção em Áreas Protegidas','Remoção por Vegetação Secundária'))+
  #scale_y_continuous(limits=c(-30, 0), breaks = c(-30,-20,-10,0))+
  #guides(fill=guide_legend(nrow = 3, byrow = T))+      
  # inverter eixos
  coord_flip()+
  #scale_y_comma(position = "right") +
  #theme(legend.position="none")+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow =1))+        
  #theme_bw()+
  theme_classic()+
  ylab("Remoção Bruta em Milhões de Toneladas de CO2e (Mt Co2e - GWP_AR5)") +
  xlab(" ")+
  theme(legend.position=c(.33,.95), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=11 ))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(p1)


ggsave("P1_RemoSUD _.png", plot = p1,dpi = 330)
