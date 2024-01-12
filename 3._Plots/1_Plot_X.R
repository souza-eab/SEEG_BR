library(pacman)
pacman::p_load(usethis, googledrive,readxl,openxlsx, 
               ggplot2, tidyverse, tidyr, dplyr, geobr,
               sf,magrittr,gghighlight,ggpubr, ggspatial)
# Net Emisson 

## Set your directory with data uf_csv--------------------------------------------
setwd('C:/Users/edriano.souza/GitHub/2023_Paper_BABI/data/')
files_mut<-dir(pattern = '\\.csv$')
for(i in files_mut) {assign(unlist(strsplit(i, "[.]"))[1], read.csv2(i,  sep = ",", h=T, encoding = "UTF-8")) }


### Join tables UF n= 27 states------------------------------------------
mut<-rm(`TABELAO_MUT_MUN-10-05_AC`, `TABELAO_MUT_MUN-10-05_AL`, `TABELAO_MUT_MUN-10-05_AM`,
        `TABELAO_MUT_MUN-10-05_AP`, `TABELAO_MUT_MUN-10-05_BA`, `TABELAO_MUT_MUN-10-05_CE`,
        `TABELAO_MUT_MUN-10-05_DF`, `TABELAO_MUT_MUN-10-05_ES`, `TABELAO_MUT_MUN-10-05_GO`,
        `TABELAO_MUT_MUN-10-05_MA`, `TABELAO_MUT_MUN-10-05_MG`, `TABELAO_MUT_MUN-10-05_MS`,
        `TABELAO_MUT_MUN-10-05_MT`, `TABELAO_MUT_MUN-10-05_PB`, `TABELAO_MUT_MUN-10-05_PA`,
        `TABELAO_MUT_MUN-10-05_PE`, `TABELAO_MUT_MUN-10-05_PI`, `TABELAO_MUT_MUN-10-05_PR`,
        `TABELAO_MUT_MUN-10-05_RJ`, `TABELAO_MUT_MUN-10-05_RN`, `TABELAO_MUT_MUN-10-05_RO`,
        `TABELAO_MUT_MUN-10-05_RR`, `TABELAO_MUT_MUN-10-05_RS`, `TABELAO_MUT_MUN-10-05_SC`,
        `TABELAO_MUT_MUN-10-05_SE`, `TABELAO_MUT_MUN-10-05_SP`, `TABELAO_MUT_MUN-10-05_TO` 
)


### Duplicate ---------------------------------------------------------------
mut9 <- mut

colnames(mut)

### Recode ---------------------------------------------------------------
newNames9 <- c("NIVEL 1",
               "NIVEL 2",
               "NIVEL 3",
               "NIVEL 4",
               "NIVEL 5",
               "NIVEL 6",
               "TIPO DE EMISSÃO",
               "GÁS",
               "TERRITÓRIO",
               "BIOMA",
               "CODIBGE",
               "Nome_Município",
               #"CODBIOMASESTADOS",
               #"ESTADOS",
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
               "2019")

colnames(mut9) <-newNames9


head(mut9)
# Select gas between ------------------------------------------------------


mut_OK9<- mut9[mut9$GÁS=="CO2e (t) GWP-AR5",]

head(mut_OK9,5)


mut_OK9[,15:64] <- as.numeric(unlist(mut_OK9[,15:64])) #column with a estimates yearly in the type: numeric 
str(mut_OK9)


# Plot Nivel_2 ----------------------------------------------------------
# Plot 4 ----------------------------------------------------------
ebt9<- mut_OK9 %>%
  filter(`NIVEL 2` != "Remoção por Mudança de Uso da Terra")%>% 
  group_by(`NIVEL 2`) %>% 
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


colnames(dff9)

df <- reshape (dff9, varying = list(colnames(dff9[2:31])),#i+1
               times = names(dff9[2:31]), #i+1
               timevar = "ANO",
               direction = "long")

colnames(df)

colnames(df)[3]<-c("VALOR")#i+1

colnames(df)

df<-df[,-c(4)]#i+1


summary(as.factor(df$`NIVEL 2`))

df <- df %>% 
  mutate(`NIVEL 2` = recode(`NIVEL 2`,
                            `Remoção por Vegetação Secundária`= "Removals by secondary vegetation", 
                            `Remoção em Áreas Protegidas`= "Removals in protected areas",
                            `Alterações de Uso do Solo` = "Net emissions by land use change",
                            `Resíduos Florestais` = "Emissions from the burning of vegetation residues"))


#############################

windowsFonts(fonte.tt= windowsFont("TT Times New Roman"))


plot1 <- df %>%
  #filter (`NIVEL 2` == "Remoção por Mudança de Uso da Terra" |
  #`NIVEL 2` =="Remoção por Vegetação Secundária" | 
  #`NIVEL 2` == "Remoção em Áreas Protegidas"|
  #`NIVEL 2` == "Alterações de Uso da Terra" |
  #`NIVEL 2` == "Resíduos Florestais ") %>%
  #filter (`TIPO DE EMISSÃO` == "Remoção" ) %>%
  #filter (MUNICÍPIO == "Salvador") %>%
  ggplot(aes(x=ANO, y=VALOR, fill= factor(`NIVEL 2`, levels = c('Emissions from the burning of vegetation residues',
                                                                'Net emissions by land use change',
                                                                'Removals by secondary vegetation',
                                                                'Removals in protected areas'))))+
  geom_bar(position="stack", stat="identity", na.rm = T, width = 0.6)+
  geom_hline(yintercept = 0, show.legend =F, colour = "black")+
  ylab("Millions of tonnes of CO2e (GWP-AR5)") +
  xlab(" ")+
  scale_y_continuous(limits=c(-1000, 2500), breaks = c(-1000, -500, 0, 500, 1000,1500, 2000,2500))+
  scale_fill_manual(values=c("#fcd5b5","#c0504d","#9bbb59","#4f6228"))+
  scale_color_manual(labels = c('Emissions from the burning of vegetation residues',
                                'Emissions by land use change',
                                'Removals in protected areas',
                                'Removals by secondary vegetation'))+
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
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=8))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=10, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9, angle = 90,vjust = 0.5, hjust=1))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9)) #Aqui é a legenda do eixo y
plot(plot1)


plot2<- plot1+ theme(legend.position="bottom")



ggsave("Figure4_OK.jpeg", plot = plot2, 
       width = 15,
       height = 12,
       units = c("cm"),
       dpi = 330)


