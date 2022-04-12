library(geojsonR)
library(jsonlite)
library(tidyverse)
library(googledrive)
library(openxlsx)
library(dplyr)


#########################################################
##########################################################


#########################################################################################
#########################################################################################
#######################################Coleçãao 9 #######################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################


setwd("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/")


mut9<- read.csv("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_Col9/Results/02_Edriano_Col9/dadosBrutos_Seeg_1990_2019.csv", encoding = "UTF-8",sep = ",")

colnames(mut9)

newNames9 <- c("NIVEL 1",
               "NIVEL 2",
               "NIVEL 3",
               "NIVEL 4",
               "NIVEL 5",
               "NIVEL 6",
               "TIPO DE EMISSÃO",
               "GÁS",
               "CODIBGE",
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


mut_OK9<- mut9[mut9$GÁS=="CO2e (t) GWP-AR5",]

head(mut_OK9,5)


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
head(dfff9,5)


#Emissões e Remoções
head(df9,5)

colnames(df9)

df <- reshape (df9, varying = list(colnames(df9[2:31])),
               times = names(df9[2:31]),
               timevar = "ANO",
               direction = "long")



colnames(df)

colnames(df)[3]<-c("VALOR")

colnames(df)

df<-df[,-c(4)]


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

plot(plot1a)
ggsave("P131_Col9_.png", plot = plot1a,dpi = 300 )

dev.off()

#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
#########################################################################################
