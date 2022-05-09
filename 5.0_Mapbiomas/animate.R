
##
##Start
gc()
memory.limit(9999999999) # or your memory

setwd('data_babi_area/')


d1f <- read.table(file= "c:/Users/edriano.souza/GitHub/3._Plots/data_babi_area/MUT_MUN_02-05_porarea.csv",header = TRUE, sep = ",",
                  strip.white = T, blank.lines.skip = TRUE,
                  quote = "\"", encoding = "UTF-8",dec = ".", fill = TRUE, comment.char = "")


library(tidyverse)
library(gganimate)
library(gapminder)
library(gifski)
library(av)
library(readr)
library(scales) 
library(ggspatial) 
library(ggplot2) 
library(geobr)
theme_set(theme_classic())



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
setwd('C:/Users/edriano.souza/GitHub/3._Plots/Apresentacao/')


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
ebt9 <- mut_OK9 %>%
  filter(`NIVEL 2` == "Alterações de Uso do Solo"|`NIVEL 2` == "Resíduos Florestais")%>% 
  filter(`NIVEL 3` == "Caatinga")%>% 
  #filter (`NIVEL 2` == "Remoção em Áreas Protegidas"|`NIVEL 2` == "Remoção por Mudança de Uso da Terra"|`NIVEL 2` == "Remoção por Vegetação Secundária")%>% 
  group_by(`Nome_Município`, CODIBGE) %>% #P2
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

colnames(df)
####################################################

#Joint GEOBR -------------------------------------------------------------


##############################
all_mun <- read_municipality(year=2020, code_muni = "all")

all_reg <- read_region(year=2020)%>%
  filter ()
apendice_c_geo <-  read_biomes(year = 2019) %>%
  filter(name_biome == "Caatinga")

  filter(name_biome == "Amazônia"| name_biome == "Cerrado"|name_biome == "Caatinga"|
           name_biome == "Mata Atlântica"| name_biome == "Pampa"| name_biome == "Pantanal")

ti <- read_indigenous_land(date=202103)

df4 <- df %>%
  filter(ANO != "2020")%>% 
  #filter(`NIVEL 3` == "Caatinga")%>% 
  tidyr::drop_na(VALOR) 
dffff <- dataset_final1A %>%
  
df1 <-  dataset_final1 %>%  
  filter(VALOR > 0) %>% 
  tidyr::drop_na(VALOR) 
#tidyr::drop_na(VALOR) 

## Create subsets ----------------------------------------------------------

## Master
dataset_final3 = left_join(all_mun, df4, by=c("code_muni"="CODIBGE"))

dataset_final2 = left_join(apendice_c_geo, df3, by=c("name_biome"="Bioma"))

dataset_final2 = left_join(ti, df1, by=c("name_muni"="Nome_Município"))

## Region
dataset_finalN = dataset_final1 %>%
  filter(name_region == "Norte")

dataset_finalNE = dataset_final3 %>%
  filter(name_region == "Nordeste")

dataset_finalCO = dataset_final3 %>%
  filter(name_region == "Centro Oeste")

dataset_finalSUD = dataset_final3 %>%
  filter(name_region == "Sudeste")

dataset_finalSUL = dataset_final3 %>%
  filter(name_region == "Sul")




#Joint GEOBR -------------------------------------------------------------

top10 <- 
  dataset_finalNE  %>%  
  group_by(ANO)%>%
  #filter(name_region == "Norte")%>% 
  # selecionar o top 10
  top_n(10, VALOR)  


rankTT <- top10  %>%
  group_by(ANO)%>%
  mutate(rank = min_rank(-VALOR) * 1) %>%
  ungroup()

Wata1 <- 
  rankTT %>% 
  filter(rank == "1")
Wata2 <- rankTT %>% 
  filter(rank == "2")
Wata3 <- rankTT %>% 
  filter(rank == "3")
Wata4 <- rankTT %>% 
  filter(rank == "4")
Wata5 <- rankTT %>% 
  filter(rank == "5")
Wata6 <- rankTT %>% 
  filter(rank == "6")
Wata7 <- rankTT %>% 
  filter(rank == "7")
Wata8 <- rankTT %>% 
  filter(rank == "8")
Wata9 <- rankTT %>% 
  filter(rank == "9")
Wata10 <- rankTT %>% 
  filter(rank == "10")

W100 <- rbind(Wata1,Wata2,Wata3,Wata4,Wata5,Wata6,Wata7,Wata8,Wata9,Wata10)
  
  
d1$VALOR=as.numeric(levels(d1$VALOR))[d1$VALOR]


W100$mun_and_state = paste(W100$name_muni,", ",W100$abbrev_state,sep = "")

#W10$VALOR=as.numeric(levels(W10$VALOR))[df1000$VALOR]


p <- ggplot(W100, aes(rank, 
                         fill = VALOR, color = as.factor(`mun_and_state`)))+
  #scale__discrete()+
  #scale_fill_distiller(palette = "Oranges",type="seq", name=expression('CO'[2]), labels = comma)+
  #scale_color_identity(palette = "Oranges",type="seq", name="Mt Co2eq")+
  #scale_color_paletteer_c("jcolors::pal12")+
  #scale_color_brewer(palette = "Oranges")+
  geom_tile(aes(y = VALOR/2,
                height = VALOR,
                width = 0.9), alpha = 1) +
  #scale_fill_distiller(palette = "Oranges",type="seq", name="Mt Co2eq")+
  scale_fill_distiller(palette = "Oranges", type="seq", name="Mt Co2eq",
                       limits = c(min(W100$VALOR, max(W100$VALOR))))+
  #scale_colour_distiller(palette = "Oranges",type="seq")+
  #scale_color_brewer()+
  scale_colour_manual(values = c("#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                                 "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000"))+
  #theme_classic()+
  #theme_clean()+
  # text in x-axis (requires clip = "off" in coord_*)
  # paste(country, " ")  is a hack to make pretty spacing, since hjust > 1 
  #   leads to weird artifacts in text spacing.
  geom_text(aes(y = 0, label = paste(`mun_and_state`, " ")), vjust = 0.2, hjust = 1) +
  #geom_text(aes(y = 0 label = paste(`VALOR`, " ")), vjust = 0.4 hjust=1) + # value label
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_reverse() +
  guides(color = FALSE, fill = FALSE) +
  labs(title = 'Emissões brutas - {as.integer(current_frame)}', x = "", y = "Emissão Bruta  de CO2e (GWP_AR5)") +
  #labs(title='{closest_state}', x = "", y = "Remoção Bruta em Milhões de Toneladas de CO2e (Mt Co2e - GWP_AR5)") +
  theme(plot.title = element_text(hjust = 0, size = 22),
        axis.ticks.y = element_blank(),  # These relate to the axes post-flip
        axis.text.y  = element_blank(),  # These relate to the axes post-flip
        plot.margin = margin(1,1,1,5.2, "cm")) +
  #theme(legend.position=c(.33,.95), legend.box = "horizontal",legend.justification = "center")+
  #theme(legend.key = element_blank())+
  #theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=11 ))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+
  #theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=12))+ #Aqui é a legenda do eixo x
  #theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))+
  #transition_states(ANO, transition_length = 1, ??state_length = 1) +
  transition_manual(ANO) +
  #enter_grow() +
  #exit_shrink() +
  enter_fade() +
  exit_fade()+
  ease_aes('cubic-in-out')

P<- p + scale_fill_brewer(palette="YlOrRd")
# Scatter plot
PP <- P + scale_color_brewer(palette="YlOrRd")
animate(p, duration = 39, width = 800, height = 600)


W10$
  
  
p <- ggplot(W10, aes(rank, group = `Nome_Município`, 
                     fill = VALOR)) +
  geom_tile(aes(y = VALOR/2,
                height = VALOR,
                width = 0.9), alpha = 0.8, color = NA) +
  # text in x-axis (requires clip = "off" in coord_*)
  # paste(country, " ")  is a hack to make pretty spacing, since hjust > 1 
  #   leads to weird artifacts in text spacing.
  #geom_text(aes(y = 0, label = paste(`Nome_Município`, " ")), vjust = 0.2, hjust = 1) +
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_reverse() +
  #guides(color = FALSE, fill = FALSE) +
  labs(title='{closest_state}', x = "", y = "GFP per capita") +
  theme(plot.title = element_text(hjust = 0, size = 22),
        axis.ticks.y = element_blank(),  # These relate to the axes post-flip
        axis.text.y  = element_blank(),  # These relate to the axes post-flip
        plot.margin = margin(1,1,1,4, "cm")) +
  transition_states(ANO, transition_length = 4, state_length = 1) +
  ease_aes('cubic-in-out')

animate(p,  duration = 39, width = 800, height = 600)






ggplot(w, aes(ANO, VALOR, group = `Nome_Município`)) +
  geom_line() +
  geom_segment(aes(xend = 2020, yend = VALOR), linetype =2, colour = "grey") +
  geom_point(size = 2) + 
  geom_text(aes(x = 2020, label = `Nome_Município`), hjust = 0) + 
  transition_reveal(ANO) + 
  coord_cartesian(clip = 'off') + 
  labs(title = 'Emissão de CO2 no Setor Elétrico', y = 'CO2 (Mt)') +
  scale_x_continuous("Ano", labels = df10$ANO, breaks = df10$ANO) +
  theme(plot.margin = margin(5.5, 40, 5.5, 5.5), 
        axis.text.x = element_text(face = "plain", size = 8))


a<- ggplot() +
  #scale_fill_distiller(palette = "Greens",type="seq", trans = "reverse", name="Mt Co2eq")+
  #scale_size_continuous(name="Mt Co2eq",breaks=seq(-25,0,5))+
  #theme(legend.direction = "vertical")+
  #scale_fill_distiller(palette = "Oranges",type="seq",trans = "reverse", name=expression('CO'[2]), labels = comma)+
  #scale_fill_distiller()+
  geom_sf(data=dataset_finalNE, aes(fill=VALOR), size=.125, color=alpha("orange",0.09))+
  scale_fill_distiller(palette = "Oranges",type="seq",trans = "reverse", name=expression('CO'[2]), labels = comma)+
  #geom_sf(data=W100, aes(fill=VALOR), size=.125, color=alpha("black",0.05))+
  #scale_fill_distiller()+
  theme_minimal()+
  #transition_states(ANO, transition_length = 1, state_length =1) +
  #transition_time(ANO) +
  transition_manual(ANO)+ 
  theme(axis.title=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank()) +
  labs(title = 'Emissões brutas - {as.integer(current_frame)}') +
  #theme(plot.title = element_text(hjust = 0, size = 22),
  #axis.ticks.y = element_blank(),  # These relate to the axes post-flip
  #axis.text.y  = element_blank(),  # These relate to the axes post-flip
  #plot.margin = margin(1,1,1,4, "cm")) +
  theme(legend.background = element_blank())+
  theme(plot.title = element_text(hjust = 0, size = 18))+
  theme(legend.title = element_text(colour = "black", family = "fonte.tt", size=12, face = "bold"))+
  theme(axis.title = element_text(colour = "black",family = "fonte.tt", size=12))+
  theme(legend.text =  element_text(colour = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(colour = "black",family = "fonte.tt", size=12, face = "bold"))+
  theme(axis.title.y = element_text(colour = "black",family = "fonte.tt", size=14, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(colour = "black",family = "fonte.tt",size=12))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(colour = "black",family = "fonte.tt",size=12))+
  # Adiciona o Norte Geográfico
  annotation_north_arrow(
    location = "br",
    which_north = "true",
    height = unit(2, "cm"),
    width = unit(2, "cm"),
    pad_x = unit(0.2, "in"),
    pad_y = unit(0.2, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  theme(legend.position=c(.95,.95), legend.box = "horizontal",legend.justification = "center")+
  ggspatial::annotation_scale()+
  #transition_states(ANO, transition_length = 1, state_length =1) +
  #coord_cartesian(clip = 'off') + 
  ease_aes('linear')
animate(a, width = 800, height = 600, duration = 39)
anim_save("TS_Map_Emission_SEEG_v9_1_01.gif", dpi = 330) 
anim_save("TS_Map_Emission_SEEG_v9_1_0.mp4")
#ease_aes('circular-in-out')+
animate(a)


ggsave("P1_Col9_.png", plot = plot1,dpi = 300 )

ggplot() +
  geom_sf(data=merged, aes(fill=Valor), color= NA) +
  labs(subtitle="Participação da agricultura no PIB", size=8) +
  scale_fill_continuous(trans = "reverse") +
  theme_minimal() +
  theme(axis.title=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank()) +
  labs(title = 'Year: {frame_time}') +
  transition_time(Ano) +
  ease_aes('linear')


p <- ggplot() + 
  geom_sf(data=dataset_final1, aes(fill = VALOR, frame = ANO, text = `Nome_Município`)) + 
  ggtitle("Obesity rates in the US over time") +
  ggthemes::theme_map()
plotly_json(p)
