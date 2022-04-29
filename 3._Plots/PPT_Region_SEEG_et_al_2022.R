# SEEG - Script for the plots of emissions and removals GHG_BR-----------------
-------------------------------------------------------
  Title:"Script for the plots of emissions and removals GHG_BR"

# Created by: 'Felipe Lenti, Barbara Zimbres (barbara.zimbres@ipam.org.br), Joao Siqueira e Edriano Souza'
# For clarification or an issue/bug report, please write to barbara.zimbres@ipam.org.br and/or edriano.souza@ipam.org.br
# Key activities in sections
-------------------------------------------------------
#
##Start
gc()
memory.limit(9999999999) # or your memory

## Setting your project.R  -------------
# !!! Eg. ~/3._Plots
# //! Create Folder: 'data'; 'R/script'; 'Results'


### Required packages  -------------------------------------------------------
# e.g.
install.packages("pacman") #// or
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
  filter(`NIVEL 2` == "Alterações de Uso do Solo"|`NIVEL 2` == "Resíduos Florestais")%>% 
  #group_by(`NIVEL 2`,`Nome_Município`, CODIBGE) %>% #P2
  group_by(`NIVEL 6`,`Nome_Município`, CODIBGE) %>% #P2
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


#Joint GEOBR -------------------------------------------------------------


##############################
all_mun <- read_municipality(year=2020)

apendice_c_geo <- read_biomes(year = 2019) %>%
  filter(name_biome == "Amazônia"| name_biome == "Cerrado"|name_biome == "Caatinga"|
         name_biome == "Mata Atlântica"| name_biome == "Pampa"| name_biome == "Pantanal")


df1 <- df %>%
  filter(ANO == "2019")

dataset_final1 = left_join(all_mun, df1, by=c("code_muni"="CODIBGE"))

#dataset_final1 = dataset_final %>% #tidyr::drop_na(VALOR) %>%
  #filter (ANO == "2020")


coord_pontos <- dataset_final1 %>% 
  mutate(VALOR2 = VALOR) %>% 
  st_centroid()






#A############################################
top10E <- dataset_final1 %>% 
  filter(`NIVEL 2` == "Alterações de Uso do Solo")%>% 
  # selecionar o top 10
  top_n(10, VALOR)

top10W <- dataset_final1 %>%
 filter(`NIVEL 2` == "Resíduos Florestais")%>% 
  # selecionar o top 10
  top_n(10, VALOR)    

ranks = top10E %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


### Concatenate two string columns

top10$mun_and_state = paste(top10$name_muni,", ",top10$abbrev_state,sep = "")


windowsFonts(fonte.tt= windowsFont("TT Arial"))
top10 <- top10 %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Mudança de Uso da Terra` = "Removals by other type of land use change",
                            `Remoção por Vegetação Secundária`= "Removals by secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "Removals in protected areas",
                            `Alterações de Uso do Solo` = "Emissions by land use change",
                            `Resíduos Florestais` = "Emissions by the burning of vegetation residuals"))


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







# Change data rownames as a real column called 'carName'
data <- top10 %>%
  rownames_to_column(code_muni)

a<- ggplot() +
  geom_sf(data=dataset_final1, aes(fill=VALOR), size=.125, color=alpha("orange",0.01))+
  scale_fill_distiller(palette = "Oranges",type="seq",trans = "reverse", name="Mt Co2eq")+
  theme_minimal()+
  theme(legend.position=c(.88,.85), legend.box = "horizontal",legend.justification = "center", legend.direction = "horizontal")+
  theme(legend.key = element_blank())+
  ylab("") + xlab(" ")+
  geom_sf(data = apendice_c_geo, fill = NA, color=alpha("black",1))+
  #geom_sf(data = coord_pontos, aes(size = VALOR2), color=alpha("orange",0.5)) + 
  #scale_fill_distiller(palette = "Oranges",type="seq",trans = "reverse", name="Mt Co2eq")+
  #scale_size_continuous(name="Mt Co2eq",breaks=seq(0,40,5))+
  theme(legend.direction = "vertical")+
  geom_sf(data = coord_pontos, aes(size = VALOR2, color=`NIVEL 6`)) + 
  #geom_sf_text(data=ranks, aes(label=ranks))+
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
    style = north_arrow_fancy_orienteering
  ) +
  ggspatial::annotation_scale()+
  theme(legend.position = "right")

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




# Gross removals ----------------------------------------------------------

ebt9<- mut_OK9 %>%
  filter(`NIVEL 2`=="Remoção por Mudança de Uso da Terra"|`NIVEL 2`=="Remoção por Vegetação Secundária"|
           `NIVEL 2`=="Remoção em Áreas Protegidas") %>%
  group_by(`NIVEL 2`, `Nome_Município`, CODIBGE) %>% #P1
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


dataset_final = left_join(all_mun, df, by=c("code_muni"="CODIBGE"))
dataset_final1 = dataset_final %>% #tidyr::drop_na(VALOR) %>%
  filter (ANO == "2019")

### Rank maps municipally
ranks = dataset_final1 %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))%>%
  top_n(10)
ranks = ranks %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

top10E <- dataset_final1 %>% 
  filter(`NIVEL 2` == "Remoção por Mudança de Uso da Terra")%>% 
  # selecionar o top 10
  top_n(10, VALOR)

top10W <- dataset_final1 %>%
  filter(`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  # selecionar o top 10
  top_n(10, VALOR)    

top10Z <- dataset_final1 %>%
  filter(`NIVEL 2` == "Remoção em Áreas Protegidas")%>% 
  # selecionar o top 10
  top_n(10, VALOR)    


ranks = top10E %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))


top10a <- dataset_final1 %>% 
  filter(`Nome_Município` == "Atalaia do Norte"|`Nome_Município` == "Lábrea"|
           `Nome_Município` == "Barcelos"|`Nome_Município` == "Santa Isabel do Rio Negro"|
           `Nome_Município` == "São Gabriel da Cachoeira"|`Nome_Município` == "Almeirim"|
           `Nome_Município` == "Altamira"|`Nome_Município` == "Itaituba"|
           `Nome_Município` == "Oriximiná"|`Nome_Município` == "São Félix do Xingu")


top10a$mun_and_state = paste(top10a$name_muni,", ",top10a$abbrev_state,sep = "")


### Concatenate two string columns

top10$mun_and_state = paste(top10$name_muni,", ",top10$abbrev_state,sep = "")

top10a <- top10a %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Mudança de Uso da Terra` = "By other kinds of land use change",
                            `Remoção por Vegetação Secundária`= "By secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "By primary vegetation in protected areas"))
#`Alterações de Uso do Solo` = "Emissions by land use change",
#`Resíduos Florestais` = "Emissions by the burning of vegetation residuals"))

### Plot1

top10a$VALOR=as.numeric(levels(top10a$VALOR))[top10a$VALOR]
p1<- top10a %>% 
  mutate(mun_and_state = fct_reorder(mun_and_state, VALOR)) %>%
  ggplot(aes(x=reorder(mun_and_state,+VALOR), y = VALOR, fill = factor(`NIVEL 2`,levels = c('By primary vegetation in protected areas',
                                                                                            'By other kinds of land use change',
                                                                                            'By secondary vegetation',+VALOR))))+
  #geom_col(aes(fill = `NIVEL 2`)) +
  geom_bar(position = position_stack(reverse = TRUE), stat="identity",  na.rm = T, width = 0.5)+
  scale_fill_manual(values=c("#4f6228" ,"#d7e4bd","#9bbb59"))+
  scale_color_manual(labels = c('By primary vegetation in protected areas', 'By other kinds of land use change',
                                'By secondary vegetation'))+
  ylim(-26, 0)+
  # inverter eixos
  coord_flip()+
  #scale_y_comma(position = "right") +
  #theme(legend.position="none")+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  ylab("Millions of tonnes of CO2e (GWP-AR6)") +
  xlab(" ")+
  theme(legend.position=c(.3,.9), legend.box = "horizontal",legend.justification = "center")+
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


# Plot 2
a<- ggplot() +
  geom_sf(data=dataset_final1$, aes(fill=VALOR), size=.125, color=alpha("gray",0.1))+
  scale_fill_distiller(palette = "Greens",type="seq", name="Mt Co2eq")+
  theme_minimal()+
  theme(legend.position=c(.88,.85), legend.box = "horizontal",legend.justification = "center", legend.direction = "horizontal")+
  theme(legend.key = element_blank())+
  ylab("") + xlab(" ")+
  theme(legend.direction = "vertical")+
  #geom_sf_text(data=ranks, aes(label=ranks))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))

plot(a)

windowsFonts(fonte.tt= windowsFont("TT Arial"))





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





# Plot Net Emisions/Removals Gross removals ----------------------------------------------------------

ebt9<- mut_OK9 %>%
  group_by(`Nome_Município`, CODIBGE) %>% #P1
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

df <- reshape (dff9, varying = list(colnames(dff9[3:33])),#i+1
               times = names(dff9[3:33]), #i+1
               timevar = "ANO",
               direction = "long")

colnames(df)

colnames(df)[4]<-c("VALOR")#i+1

colnames(df)

df<-df[,-c(5)]#i+1


dataset_final = left_join(all_mun, df, by=c("code_muni"="CODIBGE"))
dataset_final1 = dataset_final %>% #tidyr::drop_na(VALOR) %>%
  filter (ANO == "2020")

### Rank maps municipally
ranks = dataset_final1 %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))%>%
  top_n(10)
ranks = ranks %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))

ranks1 = dataset_final1 %>%
  mutate(ranks = order(order(VALOR, decreasing = T)))%>%
  top_n(-10)
ranks1 = ranks1 %>%
  mutate(ranks = order(order(VALOR, decreasing = F)))


ranksF<- rbind(ranks, ranks1)


top10a <- dataset_final1 %>% 
  filter(`Nome_Município` == "Atalaia do Norte"|`Nome_Município` == "Lábrea"|
           `Nome_Município` == "Barcelos"|`Nome_Município` == "Santa Isabel do Rio Negro"|
           `Nome_Município` == "São Gabriel da Cachoeira"|`Nome_Município` == "Almeirim"|
           `Nome_Município` == "Altamira"|`Nome_Município` == "Itaituba"|
           `Nome_Município` == "Oriximiná"|`Nome_Município` == "São Félix do Xingu")


### Concatenate two string columns
ranksF$mun_and_state = paste(ranksF$name_muni,", ",ranksF$abbrev_state,sep = "")

ranksFF = ranksF %>%
  mutate(ranksF = order(order(VALOR, decreasing = T)))%>%
  top_n(20)


###Plot
p1<- ranksF %>% 
  #mutate(mun_and_state = fct_reorder(mun_and_state, VALOR)) %>%
  ggplot(aes(x=reorder(mun_and_state,+VALOR), y = VALOR, fill = VALOR))+
  scale_y_continuous(limits=c(-30, 30), breaks = c(-25,-20,-15,-10,5,0,5,10,15,20,25))+
  #geom_col(aes(fill = `NIVEL 2`)) +
  #scale_color_gradient2(low="blue",high="red",midpoint=0,limits=c(-30,30))+
  geom_bar(position = position_stack(reverse = TRUE), stat="identity",  na.rm = T, width = 0.5)+
  scale_fill_distiller(palette = "RdYlGn",name="Mt Co2eq")+
  #scale_fill_gradientn(colours = terrain.colors(7))+
  #ylim(-30, 30)+
  # inverter eixos
  coord_flip()+
  #scale_y_comma(position = "right") +
  labs(fill = " ")+
  #guides(fill=guide_legend(nrow = 3, byrow = T))+        
  theme_bw()+
  theme_classic()+
  ylab("Millions of tonnes of CO2e (GWP-AR6)") +
  xlab(" ")+
  theme(legend.position=c(.2,.6), legend.box = "horizontal",legend.justification = "center")+
  #theme(legend.key = element_blank())+
  #theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(p1)


# Plot 2
a<- ggplot() +
  geom_sf(data=dataset_final1, aes(fill=VALOR), size=.125, color=alpha("gray",0.1))+
  scale_fill_distiller(palette = "RdYlGn", name="Mt Co2eq")+
  theme_minimal()+
  theme(legend.position=c(.88,.85), legend.box = "horizontal",legend.justification = "center", legend.direction = "horizontal")+
  theme(legend.key = element_blank())+
  ylab("") + xlab(" ")+
  theme(legend.direction = "vertical")+
  geom_sf_text(data=ranksFF, aes(label=ranksF))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))

plot(a)

windowsFonts(fonte.tt= windowsFont("TT Arial"))





p<- ggpubr::ggarrange(a, p1,
                      ncol=1,
                      widths= c(1,1),
                      heights = c(2,1),# list of plots
                      #labels = "AUTO", # labels
                      common.legend = T,# COMMON LEGEND
                      legend = "right", # legend position
                      align = "v",
                      #align = "hv",# Align them both, horizontal and vertical
                      nrow = 2)  # number of rows




# Plot Nivel_2 ----------------------------------------------------------

ebt9<- mut_OK9 %>%
  group_by(`NIVEL 2`, `NIVEL 3`) %>% 
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

df <- reshape (dff9, varying = list(colnames(dff9[3:33])),#i+1
               times = names(dff9[3:33]), #i+1
               timevar = "ANO",
               direction = "long")

colnames(df)

colnames(df)[4]<-c("VALOR")#i+1

colnames(df)

df<-df[,-c(5)]#i+1


df <- df %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Mudança de Uso da Terra` = "Removals by other type of land use change",
                            `Remoção por Vegetação Secundária`= "Removals by secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "Removals in protected areas",
                            `Alterações de Uso do Solo` = "Emissions by land use change",
                            `Resíduos Florestais` = "Emissions by the burning of vegetation residuals"))

df <- df %>% 
  mutate(BIOMA= recode(`NIVEL 3`,
                       `Amazônia` = "Amazon",
                       `Caatinga` = "Caatinga",
                       `Cerrado`= "Cerrado", 
                       `Mata Atlântica`= "Atlantic Forest",
                       `Pampa` = "Pampa",
                       `Pantanal` = "Pantanal"))

#############################

plot2 <- df %>%
  filter (ANO == "2020") %>%
  filter (BIOMA == "Caatinga" |
            BIOMA == "Cerrado" |
            BIOMA =="Atlantic Forest"| 
            BIOMA == "Pampa"|
            BIOMA == "Pantanal")%>%
  ggplot(aes(x=factor(BIOMA, levels = c('Caatinga','Cerrado','Atlantic Forest', 'Pampa', 'Pantanal')), y=VALOR, fill= factor(`NIVEL 2`, levels = c('Emissions by the burning of vegetation residuals',
                                                                                                                                                   'Emissions by land use change',
                                                                                                                                                   'Removals by secondary vegetation',
                                                                                                                                                   'Removals in protected areas',
                                                                                                                                                   'Removals by other type of land use change'))))+
  geom_bar(position="stack", stat="identity", width = 0.35, na.rm = T)+
  geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab(" ") +
  xlab(" ")+
  scale_y_continuous(limits=c(-120, 120), breaks = c(-120,-100,-80,-60,-40,-20,0,20,40,60,80,100,120))+
  scale_fill_manual(values=c("#fcd5b5","#c0504d","#9bbb59","#4f6228", "#d7e4bd"))+
  scale_color_manual(labels = c('Emissions by the burning of vegetation residuals',
                                'Emissions by land use change',
                                'Removals in protected areas',
                                'Removals by secondary vegetation',
                                'Removals by other type of land use change'))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(plot2)
#########################################################

plot11 <- df %>%
  filter (ANO == "2020") %>%
  filter (BIOMA == "Amazon")%>%
  ggplot(aes(x=BIOMA, y=VALOR, fill= factor(`NIVEL 2`, levels = c('Emissions by the burning of vegetation residuals',
                                                                  'Emissions by land use change',
                                                                  'Removals by secondary vegetation',
                                                                  'Removals in protected areas',
                                                                  'Removals by other type of land use change'))))+
  geom_bar(position="stack", stat="identity", width = 0.75, na.rm = T)+
  geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab("Millions of tonnes of CO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(-1200, 1200), breaks = c(-1200, -1000, -800,-600,-400,-200,0,200,400,600,800,1000,1200))+
  scale_fill_manual(values=c("#fcd5b5","#c0504d","#9bbb59","#4f6228", "#d7e4bd"))+
  scale_color_manual(labels = c('Emissions by the burning of vegetation residuals',
                                'Emissions by land use change',
                                'Removals in protected areas',
                                'Removals by secondary vegetation',
                                'Removals by other type of land use change'))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(plot11)




p<- ggpubr::ggarrange(plot11, plot2,
                      ncol=2,
                      widths= c(.2,1),
                      heights = c(1,.2),# list of plots
                      labels = "AUTO", # labels
                      common.legend = T,# COMMON LEGEND
                      legend = "bottom", # legend position
                      #align = "hv",
                      #align = "hv",# Align them both, horizontal and vertical
                      nrow = 1)  # number of rows

plot(p)


plot(p)
# Top 10 ------------------------------------------------------------------
dataset_final1 %>%
  ggplot(dataset_final1, aes(y = name_muni)) +
  filter(name_muni == "Altamira")+
  geom_bar(aes(fill = `NIVEL 2`), position = position_stack(reverse = TRUE)) +
  theme(legend.position = "top")+
  #scale_x_discrete(expand = c(0, 0.5)) +
  coord_flip(ylim = c(length(unique(dataset_final1$NI))-9,
                      length(unique(dataset_final1$VALOR)))) 


stack <- ggplot(data_melt, 
                aes(x = reorder(name, value, FUN = sum), y = value, 
                    fill= variable)) + 
  geom_bar(stat = "identity", width = 0.8) + 
  
  # zoom in to last 10 bars on the axis
  scale_x_discrete(expand = c(0, 0.5)) +
  coord_flip(xlim = c(length(unique(data_melt$name))-9,
                      length(unique(data_melt$name)))) 


dataset_final1 %>% 
  mutate(VALOR = cut(VALOR, c(0,47000, 470000,4700000,47000000))) %>% 
  ggplot() +
  geom_sf(aes(fill = VALOR), 
          # ajusta tamanho das linhas
          colour = "black", size = 0.1) +
  # geom_sf(
  #   data = get_brmap("State"),
  #   fill = "transparent",
  #   colour = "black",
  #   size = 0.5
  # ) +
  # muda escala de cores
  scale_fill_viridis_d(option = 2, begin = 0.2, end = 0.8) +
  # tira sistema cartesiano
  theme(panel.grid = element_line(colour = "transparent"),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())



dataset_final$
  #########################################################
##########################################################


#########################################################################################
#########################################################################################
#######################################Coleçãao 9 #######################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################

a9<- mut_OK9 %>%
  group_by(`NIVEL 2`) %>%
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`))
df9 <- as.data.frame(a9)


df9$`1990` <- as.numeric(df9$`1990`/1000000) 
df9$`1991` <- as.numeric(df9$`1991`/1000000) 
df9$`1992` <- as.numeric(df9$`1992`/1000000) 
df9$`1993` <- as.numeric(df9$`1993`/1000000) 
df9$`1994` <- as.numeric(df9$`1994`/1000000) 
df9$`1995` <- as.numeric(df9$`1995`/1000000) 
df9$`1996` <- as.numeric(df9$`1996`/1000000) 
df9$`1997` <- as.numeric(df9$`1997`/1000000) 
df9$`1998` <- as.numeric(df9$`1998`/1000000) 
df9$`1999` <- as.numeric(df9$`1999`/1000000) 
df9$`2000` <- as.numeric(df9$`2000`/1000000)   
df9$`2001` <- as.numeric(df9$`2001`/1000000)
df9$`2002` <- as.numeric(df9$`2002`/1000000)
df9$`2003` <- as.numeric(df9$`2003`/1000000)
df9$`2004` <- as.numeric(df9$`2004`/1000000)
df9$`2005` <- as.numeric(df9$`2005`/1000000)
df9$`2006` <- as.numeric(df9$`2006`/1000000)
df9$`2007` <- as.numeric(df9$`2007`/1000000)
df9$`2008` <- as.numeric(df9$`2008`/1000000)
df9$`2009` <- as.numeric(df9$`2009`/1000000)
df9$`2010` <- as.numeric(df9$`2010`/1000000)
df9$`2011` <- as.numeric(df9$`2011`/1000000)
df9$`2012` <- as.numeric(df9$`2012`/1000000)
df9$`2013` <- as.numeric(df9$`2013`/1000000)
df9$`2014` <- as.numeric(df9$`2014`/1000000)
df9$`2015` <- as.numeric(df9$`2015`/1000000)
df9$`2016` <- as.numeric(df9$`2016`/1000000)
df9$`2017` <- as.numeric(df9$`2017`/1000000)
df9$`2018` <- as.numeric(df9$`2018`/1000000)
df9$`2019` <- as.numeric(df9$`2019`/1000000)

#Emissões e Remoções Totais
head(df9,5)

ebt9<- mut_OK9 %>%
  filter(`NIVEL 2`=="Alterações de Uso do Solo"|`NIVEL 2`=="Resíduos Florestais") %>%
  group_by(`NIVEL 2`,`Nome_Município`, CODIBGE) %>%
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

#Emissões Totais   brutas
head(dff9,5)
colnames(dff9)


dff9$Col <- c("Co9")#Criar variável bioma na csv





el9<- mut_OK9 %>%
  #filter(`NIVEL 2`=="Alterações de Uso do Solo"|`NIVEL 2`=="Resíduos Florestais") %>%
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`))
dfff9 <- as.data.frame(el9)




dfff9$`1990` <- as.numeric(dfff9$`1990`/1000000) 
dfff9$`1991` <- as.numeric(dfff9$`1991`/1000000) 
dfff9$`1992` <- as.numeric(dfff9$`1992`/1000000) 
dfff9$`1993` <- as.numeric(dfff9$`1993`/1000000) 
dfff9$`1994` <- as.numeric(dfff9$`1994`/1000000) 
dfff9$`1995` <- as.numeric(dfff9$`1995`/1000000) 
dfff9$`1996` <- as.numeric(dfff9$`1996`/1000000) 
dfff9$`1997` <- as.numeric(dfff9$`1997`/1000000) 
dfff9$`1998` <- as.numeric(dfff9$`1998`/1000000) 
dfff9$`1999` <- as.numeric(dfff9$`1999`/1000000) 
dfff9$`2000` <- as.numeric(dfff9$`2000`/1000000)   
dfff9$`2001` <- as.numeric(dfff9$`2001`/1000000)
dfff9$`2002` <- as.numeric(dfff9$`2002`/1000000)
dfff9$`2003` <- as.numeric(dfff9$`2003`/1000000)
dfff9$`2004` <- as.numeric(dfff9$`2004`/1000000)
dfff9$`2005` <- as.numeric(dfff9$`2005`/1000000)
dfff9$`2006` <- as.numeric(dfff9$`2006`/1000000)
dfff9$`2007` <- as.numeric(dfff9$`2007`/1000000)
dfff9$`2008` <- as.numeric(dfff9$`2008`/1000000)
dfff9$`2009` <- as.numeric(dfff9$`2009`/1000000)
dfff9$`2010` <- as.numeric(dfff9$`2010`/1000000)
dfff9$`2011` <- as.numeric(dfff9$`2011`/1000000)
dfff9$`2012` <- as.numeric(dfff9$`2012`/1000000)
dfff9$`2013` <- as.numeric(dfff9$`2013`/1000000)
dfff9$`2014` <- as.numeric(dfff9$`2014`/1000000)
dfff9$`2015` <- as.numeric(dfff9$`2015`/1000000)
dfff9$`2016` <- as.numeric(dfff9$`2016`/1000000)
dfff9$`2017` <- as.numeric(dfff9$`2017`/1000000)
dfff9$`2018` <- as.numeric(dfff9$`2018`/1000000)
dfff9$`2019` <- as.numeric(dfff9$`2019`/1000000)

#Emissões Liquídas
head(dff9,5)


#Emissões e Remoções
head(df9,5)

colnames(dff9)

df <- reshape (dff9, varying = list(colnames(dff9[4:34])),
               times = names(dff9[4:34]),
               timevar = "ANO",
               direction = "long")



colnames(df)

colnames(df)[5]<-c("VALOR")

colnames(df)

df<-df[,-c(6)]


library("tidyverse")

library("ggplot2")

unique(df$`NIVEL 2`)
windowsFonts(fonte.tt= windowsFont("TT Times New Roman"))
df$ANO <- as.character(df$ANO)

df$ANO=as.numeric(levels(df$ANO))[df$ANO]

str(df)

plot1 <- df %>%
  #filter (`NIVEL 2` == "Remoção por Mudança de Uso da Terra" |
  #`NIVEL 2` =="Remoção por Vegetação Secundária" | 
  #`NIVEL 2` == "Remoção em Áreas Protegidas"|
  #`NIVEL 2` == "Alterações de Uso da Terra" |
  #`NIVEL 2` == "Resíduos Florestais ") %>%
  #filter (`TIPO DE EMISSÃO` == "Remoção" ) %>%
  #filter (MUNICÍPIO == "Salvador") %>%
  ggplot(aes(x=ANO, y=VALOR, fill= factor(`NIVEL 2`, levels = c('Resíduos Florestais',
                                                                'Alterações de Uso do Solo',
                                                                'Remoção por Vegetação Secundária',
                                                                'Remoção por Mudança de Uso da Terra',
                                                                'Remoção em Áreas Protegidas'))))+
  geom_bar(position="stack", stat="identity", na.rm = T, width = 0.4)+
  geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab("Milhões de tCO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(-750, 2250), breaks = c(-750,  0, 750, 1500, 2250))+
  scale_x_discrete(breaks=seq(1990,2020,2))+
  #scale_x_continuous(limits=c(1990, 2020), breaks = c(1990,2000,2010,2020)) +
  scale_fill_manual(values=c("#ffc000","#f68b32","#d7e4bd","#92d050","#4f6228"))+
  scale_color_manual(labels = c('Resíduos Florestais',
                                'Alterações de Uso do Solo',
                                'Remoção em Áreas Protegidas',
                                'Remoção por Mudança de Uso da Terra',
                                'Remoção por Vegetação Secundária'))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=10, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=10))#Aqui é a legenda do eixo y
plot(plot1)

plot1<- plot1+ theme(legend.position="bottom")

plot(plot1)
ggsave("P1_Col9_.png", plot = plot1,dpi = 300 )

dev.off()





eb9_biom<- mut_OK9 %>%
  filter(`NIVEL 2`=="Alterações de Uso do Solo"|`NIVEL 2`=="Resíduos Florestais") %>%
  group_by(`NIVEL 3`) %>%
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`))
dfffb9 <- as.data.frame(eb9_biom)
colnames(dfffb9)


dfffb9$`1990` <- as.numeric(dfffb9$`1990`/1000000) 
dfffb9$`1991` <- as.numeric(dfffb9$`1991`/1000000) 
dfffb9$`1992` <- as.numeric(dfffb9$`1992`/1000000) 
dfffb9$`1993` <- as.numeric(dfffb9$`1993`/1000000) 
dfffb9$`1994` <- as.numeric(dfffb9$`1994`/1000000) 
dfffb9$`1995` <- as.numeric(dfffb9$`1995`/1000000) 
dfffb9$`1996` <- as.numeric(dfffb9$`1996`/1000000) 
dfffb9$`1997` <- as.numeric(dfffb9$`1997`/1000000) 
dfffb9$`1998` <- as.numeric(dfffb9$`1998`/1000000) 
dfffb9$`1999` <- as.numeric(dfffb9$`1999`/1000000) 
dfffb9$`2000` <- as.numeric(dfffb9$`2000`/1000000)   
dfffb9$`2001` <- as.numeric(dfffb9$`2001`/1000000)
dfffb9$`2002` <- as.numeric(dfffb9$`2002`/1000000)
dfffb9$`2003` <- as.numeric(dfffb9$`2003`/1000000)
dfffb9$`2004` <- as.numeric(dfffb9$`2004`/1000000)
dfffb9$`2005` <- as.numeric(dfffb9$`2005`/1000000)
dfffb9$`2006` <- as.numeric(dfffb9$`2006`/1000000)
dfffb9$`2007` <- as.numeric(dfffb9$`2007`/1000000)
dfffb9$`2008` <- as.numeric(dfffb9$`2008`/1000000)
dfffb9$`2009` <- as.numeric(dfffb9$`2009`/1000000)
dfffb9$`2010` <- as.numeric(dfffb9$`2010`/1000000)
dfffb9$`2011` <- as.numeric(dfffb9$`2011`/1000000)
dfffb9$`2012` <- as.numeric(dfffb9$`2012`/1000000)
dfffb9$`2013` <- as.numeric(dfffb9$`2013`/1000000)
dfffb9$`2014` <- as.numeric(dfffb9$`2014`/1000000)
dfffb9$`2015` <- as.numeric(dfffb9$`2015`/1000000)
dfffb9$`2016` <- as.numeric(dfffb9$`2016`/1000000)
dfffb9$`2017` <- as.numeric(dfffb9$`2017`/1000000)
dfffb9$`2018` <- as.numeric(dfffb9$`2018`/1000000)
dfffb9$`2019` <- as.numeric(dfffb9$`2019`/1000000)

colnames(dfffb9)

colnames(dfffb9)


dfffb8_nivel<- dfffb8


dfffb9 <- reshape (dfffb9, varying = list(colnames(dfffb9[2:31])),
                   times = names(dfffb9[2:31]),
                   timevar = "ANO",
                   direction = "long")

colnames(dfffb9)

colnames(dfffb9)[3]<-c("VALOR")

colnames(dfffb9)
dfffb9<-dfffb9[,-c(4)]


colnames(dfffb9)

str(dfffb9)

plot3 <- dfffb9 %>%
  #group_by(BIOMA) %>%
  #filter (`TIPO DE EMISSÃO` == "Emissão" ) %>%
  ggplot(aes(x = ANO, y = VALOR,group= `NIVEL 3`,color= `NIVEL 3`)) + 
  geom_line(size=1.2)+
  geom_point(size=1.3)+
  #geom_line(aes(y = "Amazônia", colour = "green"))+
  #geom_line(aes(y = "Caatinga", colour = "orange"))+
  #geom_line(aes(y = "Cerrado", colour = "brown"))+
  #geom_line(aes(y = "Mata Atlântica", colour = "gray"))+
  #geom_line(aes(y = "Pampa", colour = "gold"))+
  #geom_line(aes(y = "Pantanal", colour = "magenta"))+
  #geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab("Milhões de tCO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(0, 1800), breaks = c( 0, 450, 900, 1350,1800))+
  scale_x_discrete(breaks=seq(1990,2019,3))+
  #scale_fill_manual(values=c("#fcd5b5","#c0504d","#9bbb59","#4f6228", "#d7e4bd"))+
  #scale_color_manual(labels = c('Emissions by the burning of vegetation residuals',
  #'Emissions by land use change',
  #'Removals in protected areas',
  #'Removals by secondary vegetation',
  #'Removals by other type of land use change'))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 3, byrow = T))+        
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=10, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=10))#Aqui é a legenda do eixo y
plot(plot3)



plot3<- plot3+scale_colour_manual(values=c("#f69240","#c0504d","#00b050","#00b0f0","#ffc000","#7f7f7f"))
plot3<- plot3+ theme(legend.position="bottom")
plot(plot3)

plot3<- plot3+theme(legend.title = element_blank())
plot(plot3) 


ggsave("P3_Col9_.png", plot = plot3,dpi = 300 )

dev.off()


perct <- data.frame(
  group = c("Amazônia", "Caatinga", "Cerrado", "Mata Atlântica", "Pampa", "Pantanal"),
  value = c(80,1.195,7.29,10.31,0.68,.39))
library(scales)


# install.packages("ggplot2")
library(ggplot2)

pie <- ggplot(perct, aes(x = "", y = value, fill = group)) +
  geom_col(width = 1) +
  #geom_label_repel(aes(label = value,fill = group),size=3)+
  #geom_label_repel(aes(label = paste0(value, "%")), size=2, show.legend = F) +
  #geom_text(aes(label = value),
  #position = position_stack(vjust = 0.5)) +
  coord_polar(theta = "y", start = 0 ) +
  #geom_text(aes(label = paste0(round(value), "%")), position = position_stack(vjust = .7))+
  #geom_text(aes(y = value/6 + c(0, cumsum(value)[-length(value)]), 
  #label = percent(value/100)), size=5)+
  geom_text(aes(x = 1.6, label = paste0(round(value), "%")), position = position_stack(vjust = .5)) +
  ylab("") +
  xlab("")+
  scale_fill_manual(values=c("#f69240","#c0504d","#00b050","#00b0f0","#ffc000","#7f7f7f"))+
  guides(fill=guide_legend(nrow = 6, byrow = T))+        
  theme_void()+
  theme(legend.key = element_blank())+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=10, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=10))+
  theme(legend.position="right")+
  theme(legend.title = element_blank())+
  theme(axis.text.x=element_blank())


pie


ggsave("P3_1_Col9_.png", plot = pie,dpi = 300 )


#####################################################################

colnames(mut_OK9)




mut_OK9 <- mut_OK9 %>% 
  mutate(ESTADOS= recode(ESTADOS,
                         `AMAZONAS`= "AM",
                         `PARA`="PA", 
                         `MARANHAO`="MA",
                         `PIAUI`="PI",
                         `CEARA`="CE",
                         `RIO GRANDE DO NORTE`="RN",
                         `PARAIBA`="PB",
                         `PERNAMBUCO`="PE",
                         `BAHIA`="BA",
                         `MINAS GERAIS`="MG",
                         `ESPIRITO SANTO`="ES",
                         `RIO DE JANEIRO`="RJ",
                         `SAO PAULO`="SP",
                         `PARANA`="PR",
                         `SANTA CATARINA`="SC",
                         `RIO GRANDE DO SUL`="RS",
                         `MATO GROSSO DO SUL`="MS",
                         `MATO GROSSO`="MT",
                         `GOIAS`="GO",
                         `ALAGOAS`="AL",
                         `AMAPA`="AP",
                         `DISTRITO FEDERAL`="DF",
                         `NAO OBSERVADO`="NA",
                         `RONDONIA`="RO",
                         `SERGIPE`="SE",
                         `TOCANTINS`="TO",
                         `ACRE`="AC",
                         `RORAIMA`="RR"))


str(mut_OK9)
eb9_UF<- mut_OK9 %>%
  filter(`NIVEL 2`=="Alterações de Uso do Solo"|`NIVEL 2`=="Resíduos Florestais") %>%
  group_by(ESTADOS) %>%
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`))
dfffUF9 <- as.data.frame(eb9_UF)
colnames(dfffUF9)


dfffUF9$`1990` <- as.numeric(dfffUF9$`1990`/1000000) 
dfffUF9$`1991` <- as.numeric(dfffUF9$`1991`/1000000) 
dfffUF9$`1992` <- as.numeric(dfffUF9$`1992`/1000000) 
dfffUF9$`1993` <- as.numeric(dfffUF9$`1993`/1000000) 
dfffUF9$`1994` <- as.numeric(dfffUF9$`1994`/1000000) 
dfffUF9$`1995` <- as.numeric(dfffUF9$`1995`/1000000) 
dfffUF9$`1996` <- as.numeric(dfffUF9$`1996`/1000000) 
dfffUF9$`1997` <- as.numeric(dfffUF9$`1997`/1000000) 
dfffUF9$`1998` <- as.numeric(dfffUF9$`1998`/1000000) 
dfffUF9$`1999` <- as.numeric(dfffUF9$`1999`/1000000) 
dfffUF9$`2000` <- as.numeric(dfffUF9$`2000`/1000000)   
dfffUF9$`2001` <- as.numeric(dfffUF9$`2001`/1000000)
dfffUF9$`2002` <- as.numeric(dfffUF9$`2002`/1000000)
dfffUF9$`2003` <- as.numeric(dfffUF9$`2003`/1000000)
dfffUF9$`2004` <- as.numeric(dfffUF9$`2004`/1000000)
dfffUF9$`2005` <- as.numeric(dfffUF9$`2005`/1000000)
dfffUF9$`2006` <- as.numeric(dfffUF9$`2006`/1000000)
dfffUF9$`2007` <- as.numeric(dfffUF9$`2007`/1000000)
dfffUF9$`2008` <- as.numeric(dfffUF9$`2008`/1000000)
dfffUF9$`2009` <- as.numeric(dfffUF9$`2009`/1000000)
dfffUF9$`2010` <- as.numeric(dfffUF9$`2010`/1000000)
dfffUF9$`2011` <- as.numeric(dfffUF9$`2011`/1000000)
dfffUF9$`2012` <- as.numeric(dfffUF9$`2012`/1000000)
dfffUF9$`2013` <- as.numeric(dfffUF9$`2013`/1000000)
dfffUF9$`2014` <- as.numeric(dfffUF9$`2014`/1000000)
dfffUF9$`2015` <- as.numeric(dfffUF9$`2015`/1000000)
dfffUF9$`2016` <- as.numeric(dfffUF9$`2016`/1000000)
dfffUF9$`2017` <- as.numeric(dfffUF9$`2017`/1000000)
dfffUF9$`2018` <- as.numeric(dfffUF9$`2018`/1000000)
dfffUF9$`2019` <- as.numeric(dfffUF9$`2019`/1000000)



dfffUF9_uf<- dfffUF9
colnames(dfffUF9)

dfffUF9 <- reshape (dfffUF9, varying = list(colnames(dfffUF9[2:31])),
                    times = names(dfffUF9[2:31]),
                    timevar = "ANO",
                    direction = "long")

colnames(dfffUF9)

colnames(dfffUF9)[3]<-c("VALOR")

colnames(dfffUF9)
dfffUF9<-dfffUF9[,-c(4)]


colnames(dfffUF9)



library("tidyverse")

library("ggplot2")

windowsFonts(fonte.tt= windowsFont("TT Times New Roman"))

plot11 <- dfffUF9 %>%
  filter(ANO =="2018"| ANO =="2019") %>%
  #filter (`NIVEL 2` == "Remoção por Mudança de Uso da Terra" 
  #`NIVEL 2` =="Remoção por Vegetação Secundária" | 
  #`NIVEL 2` == "Remoção em Áreas Protegidas"|
  #`NIVEL 2` == "Alterações de Uso da Terra" |
  #`NIVEL 2` == "Resíduos Florestais ") %>%
  #filter (`TIPO DE EMISSÃO` == "Remoção" ) %>%
  #filter (MUNICÍPIO == "Salvador") %>%
  ggplot(aes(fill=ANO, x= reorder(ESTADOS,-VALOR),VALOR))+
  geom_bar(stat="identity",width = .6, position=position_dodge())+
  geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab("Milhões de tCO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(0,400), breaks = c( 0, 50,100,150,200,250,300,350,400))+
  #scale_x_discrete(breaks=seq(1990,2020,2))+
  #scale_x_continuous(limits=c(1990, 2020), breaks = c(1990,2000,2010,2020)) +
  scale_fill_manual(values=c("#92d050","#f68b32"))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 1, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=10, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=10))#Aqui é a legenda do eixo y
plot(plot11)

plot11<- plot11+ theme(legend.position="top")

plot(plot11)
ggsave("P13_Col9_.png", plot = plot11,dpi = 300 )

dev.off()

###################################################################################
###################### UFFFFFFFFFFFF 


el9_UF<- mut_OK9 %>%
  group_by(ESTADOS) %>%
  summarise('1990'=sum(`1990`),'1991'=sum(`1991`),'1992'=sum(`1992`),
            '1993'=sum(`1993`),'1994'=sum(`1994`),'1995'=sum(`1995`),
            '1996'=sum(`1996`),'1997'=sum(`1997`),'1998'=sum(`1998`),
            '1999'=sum(`1999`),'2000'=sum(`2000`),'2001'=sum(`2001`),
            '2002'=sum(`2002`),'2003'=sum(`2003`),'2004'=sum(`2004`),
            '2005'=sum(`2005`),'2006'=sum(`2006`),'2007'=sum(`2007`),
            '2008'=sum(`2008`),'2009'=sum(`2009`),'2010'=sum(`2010`),
            '2011'=sum(`2011`),'2012'=sum(`2012`),'2013'=sum(`2013`),
            '2014'=sum(`2014`),'2015'=sum(`2015`),'2016'=sum(`2016`),
            '2017'=sum(`2017`),'2018'=sum(`2018`),'2019'=sum(`2019`))
dfffUFl9 <- as.data.frame(el9_UF)
colnames(dfffUFl9)
str(dfffUFl9)

dfffUFl9$`1990` <- as.numeric(dfffUFl9$`1990`/1000000) 
dfffUFl9$`1991` <- as.numeric(dfffUFl9$`1991`/1000000) 
dfffUFl9$`1992` <- as.numeric(dfffUFl9$`1992`/1000000) 
dfffUFl9$`1993` <- as.numeric(dfffUFl9$`1993`/1000000) 
dfffUFl9$`1994` <- as.numeric(dfffUFl9$`1994`/1000000) 
dfffUFl9$`1995` <- as.numeric(dfffUFl9$`1995`/1000000) 
dfffUFl9$`1996` <- as.numeric(dfffUFl9$`1996`/1000000) 
dfffUFl9$`1997` <- as.numeric(dfffUFl9$`1997`/1000000) 
dfffUFl9$`1998` <- as.numeric(dfffUFl9$`1998`/1000000) 
dfffUFl9$`1999` <- as.numeric(dfffUFl9$`1999`/1000000) 
dfffUFl9$`2000` <- as.numeric(dfffUFl9$`2000`/1000000)   
dfffUFl9$`2001` <- as.numeric(dfffUFl9$`2001`/1000000)
dfffUFl9$`2002` <- as.numeric(dfffUFl9$`2002`/1000000)
dfffUFl9$`2003` <- as.numeric(dfffUFl9$`2003`/1000000)
dfffUFl9$`2004` <- as.numeric(dfffUFl9$`2004`/1000000)
dfffUFl9$`2005` <- as.numeric(dfffUFl9$`2005`/1000000)
dfffUFl9$`2006` <- as.numeric(dfffUFl9$`2006`/1000000)
dfffUFl9$`2007` <- as.numeric(dfffUFl9$`2007`/1000000)
dfffUFl9$`2008` <- as.numeric(dfffUFl9$`2008`/1000000)
dfffUFl9$`2009` <- as.numeric(dfffUFl9$`2009`/1000000)
dfffUFl9$`2010` <- as.numeric(dfffUFl9$`2010`/1000000)
dfffUFl9$`2011` <- as.numeric(dfffUFl9$`2011`/1000000)
dfffUFl9$`2012` <- as.numeric(dfffUFl9$`2012`/1000000)
dfffUFl9$`2013` <- as.numeric(dfffUFl9$`2013`/1000000)
dfffUFl9$`2014` <- as.numeric(dfffUFl9$`2014`/1000000)
dfffUFl9$`2015` <- as.numeric(dfffUFl9$`2015`/1000000)
dfffUFl9$`2016` <- as.numeric(dfffUFl9$`2016`/1000000)
dfffUFl9$`2017` <- as.numeric(dfffUFl9$`2017`/1000000)
dfffUFl9$`2018` <- as.numeric(dfffUFl9$`2018`/1000000)
dfffUFl9$`2019` <- as.numeric(dfffUFl9$`2019`/1000000)



dfffUF8_uf<- dfffUF8
colnames(dfffUF9_uf)

dfffUFl9<- reshape (dfffUFl9, varying = list(colnames(dfffUFl9[2:31])),
                    times = names(dfffUFl9[2:31]),
                    timevar = "ANO",
                    direction = "long")

colnames(dfffUF9_uf)

colnames(dfffUFl9)[3]<-c("VALOR")

colnames(dfffUFl9)
dfffUF9<-dfffUFl9[,-c(4)]


colnames(dfffUFl9)



library("tidyverse")

library("ggplot2")

windowsFonts(fonte.tt= windowsFont("TT Times New Roman"))

plot1a <-dfffUFl9 %>%
  filter(ANO =="2018"| ANO =="2019") %>%
  #filter (`NIVEL 2` == "Remoção por Mudança de Uso da Terra" 
  #`NIVEL 2` =="Remoção por Vegetação Secundária" | 
  #`NIVEL 2` == "Remoção em Áreas Protegidas"|
  #`NIVEL 2` == "Alterações de Uso da Terra" |
  #`NIVEL 2` == "Resíduos Florestais ") %>%
  #filter (`TIPO DE EMISSÃO` == "Remoção" ) %>%
  #filter (MUNICÍPIO == "Salvador") %>%
  ggplot(aes(fill=ANO, x= reorder(ESTADOS,-VALOR),VALOR))+
  geom_bar(stat="identity",width = .6, position=position_dodge())+
  geom_hline(yintercept = 0, show.legend =F, colour = "black",type = "l")+ #,lty=1, lwd=1)+
  #guides(fill=guide_legend(title="Transições de Remoções", color = "black", family = "fonte.tt", face = "bold"))+
  ylab("Milhões de tCO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(-110,250), breaks = c(  -100,-50,0,50, 100,150,200,250))+
  #scale_x_discrete(breaks=seq(1990,2020,2))+
  #scale_x_continuous(limits=c(1990, 2020), breaks = c(1990,2000,2010,2020)) +
  scale_fill_manual(values=c("#92d050","#f68b32"))+
  labs(fill = " ")+
  guides(fill=guide_legend(nrow = 1, byrow = T))+        
  #theme_bw()+
  theme_classic()+
  theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=10, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=10))#Aqui é a legenda do eixo y
plot(plot1a)

plot1a<- plot1a+ theme(legend.position="top")

windowsFonts(fonte.tt= windowsFont("TT Arial"))
plot(plot1a)
ggsave("P131_Col9_.png", plot = plot1a,dpi = 300 )

dev.off()

#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
