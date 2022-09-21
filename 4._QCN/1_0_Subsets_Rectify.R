###########------------------------------------------------------------------)
# GOALS -------------------------------------------------------------------
## {                                                                                                                                                                    ##
# */  Script para gerar tabelas auxiliares para relacionar as fitofisionimas do IBGE como entradas da QCN 
# */ para retificar e classificar conforme MapBiomas - Coleção 7.
## }                                                                                                                                                                    ##
###########------------------------------------------------------------------)

## Bibliotecas 
#install.packages('tidyverse') Instalar biblioteca
library(tidyverse)# Utilizar Bibliotecas
library(readxl)  
library(ggplot2) 
#windowsFonts(fonte.tt= windowsFont("TT Times New Roman")) #Fonte de texto para plots "coloque aqui a sua fonte" selecionada

## Liberar memória para processamento no R
gc()
memory.limit (9999999999999)

###########------------------------------------------------------------------/
## Biome Amazon -------------------------------------------------------------
###########------------------------------------------------------------------/

### Input-------------------------------------------------------------------------
#getwd('patch_your_project')

amz2 <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/amazon.csv",
                h=T, encoding = "UTF-8")

str(amz)
colnames(amz) #verificar nomes das colunas 
amz<-amz[,-c(11,12)] #Na csv tem outra categoria do IBGE, "categorig" retirar e alinhar a colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi","tipo", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv") #Colunas TRUE
# All biomas compartilha da mesma informação;
#Para relacionar as classes pegamos C_pretvizi e categvizi;
colnames(amz)<-newNames# Receber classes  
amz$BIOMA <- c("Amz")#Criar variável bioma na csv
amz <- mutate(amz, C_pretvizi_OK = C_pretvizi) #Criar variável de classe igual para tratar e manter a original
str(names(amz)) #Conferência


### Resume class_fito -------------------------------------------------------

#### Classes de Floresta -------------------------------------------------------
amz_class_F <- amz %>% # Inspect and plot the number of QCN Class
  group_by(tipo,C_pretvizi_OK) %>%
  count(tipo,C_pretvizi_OK)
ggplot(data=amz_class_F, aes(x=C_pretvizi_OK, y=n)) +
  geom_bar(stat="identity")
ggplot(data=amz_class_F, aes(x=C_pretvizi_OK, y=n, fill = tipo)) + #BarPlot Class
  geom_bar(position = "stack", width = 0.5, stat = "identity") 


##### Classes de Floresta Antropizada -------------------------------------------------------
amz_class_FA <- amz %>% 
  filter(tipo == "ANTROPIZADA")%>% #
  group_by(tipo,C_pretvizi_OK) %>%
  count(tipo,C_pretvizi_OK)
ggplot(data=amz_class_FA, aes(x=C_pretvizi_OK, y=n, fill = tipo)) + #BarPlot Class
  geom_bar(position = "stack", width = 0.5, stat = "identity")+
  scale_fill_manual(values=c("#fd8d3c"))


##### Classes de Floresta Natural -------------------------------------------------------
amz_class_NAT <- amz %>% 
  filter(tipo == "NATURAL")%>% 
  group_by(tipo ,C_pretvizi_OK)%>%
  count(tipo,C_pretvizi_OK)
ggplot(data=amz_class_NAT, aes(x=C_pretvizi_OK, y=n, fill = tipo)) + #BarPlot Class
  geom_bar(position = "stack", width = 0.5, stat = "identity") +
  scale_fill_manual(values=c("#00441b"))


##### Join Classes congruence FA e NAT -------------------------------------------------------
joinF<- amz_class_NAT %>%
  left_join(amz_class_FA,by=c("C_pretvizi_OK"="C_pretvizi_OK"))
view(joinF)

#rm('amz_class_F','amz_class_NAT','amz_class_FA')
#rm('joinF','p_class','p_class_A','p_class_N')
dev.off()  


### Filtrar e Rectify -------------------------------------------------------
#     Filtrar classes da QCN                   #
#     Criar col MAPBIOMAS_C7 e G_class_C7      #
#               Number       e Name_class      #


##### Classes de Floresta Antropizada -------------------------------------------------------
amz_mapb_FA<- amz %>% 
  filter(tipo== "ANTROPIZADA") %>%
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab" |C_pretvizi_OK== "As" | C_pretvizi_OK== "Am"
         |C_pretvizi_OK== "Ca"|C_pretvizi_OK== "Cb" |C_pretvizi_OK== "Cs" | C_pretvizi_OK== "Da"  # Conforme QCN pÃ¡gina 121
         |C_pretvizi_OK== "Db"|C_pretvizi_OK== "Dm" | C_pretvizi_OK== "Ds"| C_pretvizi_OK== "Fa" #pÃ¡g122
         |C_pretvizi_OK== "Fb"|C_pretvizi_OK== "Fm" |C_pretvizi_OK== "Fs" 
         |C_pretvizi_OK== "L" # Include C7
         |C_pretvizi_OK== "La"
         |C_pretvizi_OK== "Ld"
         |C_pretvizi_OK== "LO" # Include C7
         |C_pretvizi_OK== "ON" # Include C7
         |C_pretvizi_OK== "P" # Include C7
         |C_pretvizi_OK== "SN" # Include C7
         |C_pretvizi_OK== "SO" # Include C7
         |C_pretvizi_OK== "SP" # Include C7
         |C_pretvizi_OK== "Td" # Include C7
         |C_pretvizi_OK== "TN" # Include C7
         #|C_pretvizi_OK== "Pa" #v1 
         |C_pretvizi_OK== "Sd"|C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 3)%>% 
  mutate(G_class_C7 = "FA")
##### Classes de Floresta Natural -------------------------------------------------------
amz_mapb_F<- amz %>% 
  filter(tipo== "NATURAL") %>%
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab" |C_pretvizi_OK== "As" | C_pretvizi_OK== "Am"
         |C_pretvizi_OK== "Ca"|C_pretvizi_OK== "Cb" |C_pretvizi_OK== "Cs" | C_pretvizi_OK== "Da"  
         |C_pretvizi_OK== "Db"|C_pretvizi_OK== "Dm" | C_pretvizi_OK== "Ds"| C_pretvizi_OK== "Fa" 
         |C_pretvizi_OK== "Fb"|C_pretvizi_OK== "Fm" |C_pretvizi_OK== "Fs" 
         |C_pretvizi_OK== "L" # Include C7
         |C_pretvizi_OK== "La"
         |C_pretvizi_OK== "Ld"
         |C_pretvizi_OK== "LO" # Include C7
         |C_pretvizi_OK== "ON" # Include C7
         |C_pretvizi_OK== "P" # Include C7
         |C_pretvizi_OK== "SN" # Include C7
         |C_pretvizi_OK== "SO" # Include C7
         |C_pretvizi_OK== "SP" # Include C7
         |C_pretvizi_OK== "Td" # Include C7
         |C_pretvizi_OK== "TN" # Include C7
         #|C_pretvizi_OK== "Pa" #v1 
         |C_pretvizi_OK== "Sd"|C_pretvizi_OK== "Pm"
         ############################### Acontece só aqui
         |C_pretvizi_OK== "Rl"
         |C_pretvizi_OK== "Rs"
         |C_pretvizi_OK== "Ta") %>%
  #|C_pretvizi_OK== "Tg") %>%
  mutate(MAPBIOMAS_C7 = 0)%>% 
  mutate(G_class_C7 = "F")

##### Classes de Savana Antropizada -------------------------------------------------------
amz_mapb_SA<- amz %>% 
  filter(tipo== "ANTROPIZADA")%>%
  filter(C_pretvizi_OK== "Sa"
         |C_pretvizi_OK== "ST" #Include C7
         |C_pretvizi_OK== "S") %>% #Include C7
  #Class Ta > Not Include
  mutate(MAPBIOMAS_C7 = 4)%>%
  mutate(G_class_C7 = "SA")
##### Classes de Savana Natural -------------------------------------------------------
amz_mapb_S<- amz %>% 
  filter(tipo== "NATURAL")%>%
  filter(C_pretvizi_OK== "Sa"
         |C_pretvizi_OK== "ST" #Include C7
         |C_pretvizi_OK== "S") %>% #Include C7
  #Class Ta > Not Include
  mutate(MAPBIOMAS_C7 = 0)%>%
  mutate(G_class_C7 = "S")


##### Classes de Mangue Antropizada -------------------------------------------------------
amz_mapb_MA<- amz %>% 
  filter(tipo== "ANTROPIZADA")%>%
  filter(C_pretvizi_OK== "Pf")%>%
  mutate(MAPBIOMAS_C7 = 5)%>%
  mutate(G_class_C7 = "MA")
##### Classes de Mangue Natural -------------------------------------------------------
amz_mapb_M<- amz %>% 
  filter(tipo== "NATURAL")%>%
  filter(C_pretvizi_OK== "Pf")%>%
  mutate(MAPBIOMAS_C7 = 0)%>%
  mutate(G_class_C7 = "M")

##### Classes de Campo Alagado e Área Pantanosa -------------------------------------------------------
amz_mapb_WA<- amz %>% 
  filter(tipo== "ANTROPIZADA")%>%
  filter(C_pretvizi_OK== "Pa")%>%
  mutate(MAPBIOMAS_C7 = 11)%>%
  mutate(G_class_C7 = "WA")
##### Classes de Campo Alagado e Área Pantanosa -------------------------------------------------------
amz_mapb_W<- amz %>% 
  filter(tipo== "NATURAL")%>%
  filter(C_pretvizi_OK== "Pa")%>%
  mutate(MAPBIOMAS_C7 = 0)%>%
  mutate(G_class_C7 = "W")

#####  Classes de Formação Campestre Antropizada-------------------------------------------------------
amz_mapb_GA<- amz %>% 
  filter(tipo== "ANTROPIZADA")%>%
  filter(C_pretvizi_OK== "Lg"|C_pretvizi_OK== "Rm"|C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Tg"
         |C_pretvizi_OK== "T" #Include c7
         |C_pretvizi_OK== "Lb"|C_pretvizi_OK== "Sp"|C_pretvizi_OK== "Tp") %>%
  mutate(MAPBIOMAS_C7 = 12)%>%
  mutate(G_class_C7 = "GA")
#####  Classes de Formação Campestre Natural-------------------------------------------------------
amz_mapb_G<- amz %>% 
  filter(tipo== "NATURAL")%>%
  filter(C_pretvizi_OK== "Lg"|C_pretvizi_OK== "Rm"|C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Tg"
         |C_pretvizi_OK== "T" #Include c7
         |C_pretvizi_OK== "Lb"|C_pretvizi_OK== "Sp"|C_pretvizi_OK== "Tp") %>%
  mutate(MAPBIOMAS_C7 = 0)%>%
  mutate(G_class_C7 = "G")

##### Classes NA's  -------------------------------------------------------
amz_mapb_NAs <- amz %>% 
  filter(tipo == "")%>% 
  mutate(MAPBIOMAS_C7 = "0")%>%
  mutate(G_class_C7 = "0")


### Rbind subsets -------------------------------------------------------
amz_c7_segg_c10_v1 <- rbind(
  amz_mapb_FA, 
  amz_mapb_F,
  amz_mapb_GA,
  amz_mapb_G, 
  amz_mapb_MA,
  amz_mapb_M,
  amz_mapb_SA,
  amz_mapb_S, 
  amz_mapb_WA,
  amz_mapb_W,
  amz_mapb_NAs)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-amz_c7_segg_c10_v1[,c(1,2,13,14)]
newNames <- c("FID", "ID", "MB_C7","G_class_C7") #Colunas TRUE
colnames(rectify_class_8bit)<-newNames# Receber classes

str(rectify_class_8bit)
rectify_class_8bit$MB_C7 <- as.numeric(rectify_class_8bit$MB_C7)

str(rectify_class_8bit)

write.csv(rectify_class_8bit,file = "data/AMZ_data_reclass8bit_v2.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-amz_c7_segg_c10 [,c(1,2,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-amz_c7_segg_c10 [,c(1,2,11,12,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())






###########------------------------------------------------------------------)
## Biome Cerrado ------------------------------------------------------------------
###########------------------------------------------------------------------)


### Input-------------------------------------------------------------------------
#getwd('patch_your_project')
cer <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/cerrado.csv",
                h=T, encoding = "UTF-8")

colnames(cer) #verificar nomes das colunas 
summary(cer)
cer<-cer[,-c(5)] #Na csv tem outra categoria do IBGE, "categorig" retirar para deixar todas com as 
#mesmas variáveis e alinhar a colunas
colnames(cer) 
#Nomes das colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv", "mb_c6", "MAPBIOMAS_C6") #Aqui as colunas padrão

#que todos os biomas compartilhas da mesma informação;
#Para relacionar as classes pegamos C_pretvizi e categvizi;

colnames(cer)<-newNames# Receber classes  
cer$BIOMA <- c("Cerrado")#Criar variável bioma na csv
cer <- mutate(cer, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos
str(names(cer)) #Conferência


### Resume class_fito -------------------------------------------------------
#colnames(df)
cer_class<- cer %>%
  group_by(categvizi,C_pretvizi_OK) %>%
  count(categvizi,C_pretvizi_OK)

cpret<- cer %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)

#A planilha tem 59 levels de pretVeg

### Filtrar e Rectify -------------------------------------------------------
#     Filtrar classes da QCN                   #
#     Criar col MAPBIOMAS_C7 e G_class_C7      #
#               Number       e Name_class      #

##### Classes de Floresta -------------------------------------------------------
cer_mapb_FLO<- cer %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" |C_pretvizi_OK== "Cb" # Conforme QCN pÃ¡gina 121
         |C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"| C_pretvizi_OK== "Da" |C_pretvizi_OK== "Db" |C_pretvizi_OK== "Ds" #pÃ¡g122
         |C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"| C_pretvizi_OK== "Ma" #    123
         |C_pretvizi_OK== "Ml" |C_pretvizi_OK== "Mm"
         #C_pretvizi_OK== "P"| C_pretvizi_OK== "Pm" C6Oz
         #|C_pretvizi_OK== "S" | C6
         #Add Col7
         |(C_pretvizi_OK== "ONm" |C_pretvizi_OK== "ONs"|C_pretvizi_OK== "ONts"|C_pretvizi_OK== "SMl"|C_pretvizi_OK== "SMm"
           |C_pretvizi_OK== "P"
           |C_pretvizi_OK== "SNb"|C_pretvizi_OK== "SNm"|C_pretvizi_OK== "SNs"|C_pretvizi_OK== "SNtm"|C_pretvizi_OK== "SNts"
           |C_pretvizi_OK== "SOs"|C_pretvizi_OK== "SOts"
           |C_pretvizi_OK== "TNm"| C_pretvizi_OK== "TNs"| C_pretvizi_OK== "TNtm"| C_pretvizi_OK== "TNts"
           #
           |C_pretvizi_OK== "Sd"
           |C_pretvizi_OK== "Td")) %>% 
  #|C_pretvizi_OK== "Pa")%>% 
  #C_pretvizi_OK== "Pa"|
  #C_pretvizi_OK== "T"|) %>%
  mutate(MAPBIOMAS_C7 = 3)%>% 
  mutate(G_class_C7 = "F")

##### Classes de Savana -------------------------------------------------------
#Class Savana 4CN && ID_Mapbiomas = 4
cer_mapb_S<- cer %>% 
  filter(C_pretvizi_OK== "Sa" |C_pretvizi_OK== "Ta"|
           C_pretvizi_OK== "S" 
         #Add Col7
         | C_pretvizi_OK== "STNm"|C_pretvizi_OK== "STNs"
         |C_pretvizi_OK== "STNtm"|C_pretvizi_OK== "STNts"|C_pretvizi_OK== "STs"|C_pretvizi_OK== "STtm" |C_pretvizi_OK== "STts"
         |C_pretvizi_OK== "STb" )%>%#Include C7 class 'S' and 
  #C_pretvizi_OK== "ST" |) %>% 
  mutate(MAPBIOMAS_C7 = 4)%>%
  mutate(G_class_C7 = "Sav")

##### Classes de Mangrove -------------------------------------------------------
#Class Mangrove 4CN && ID_Mapbiomas = 5
cer_mapb_M<- cer %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS_C7 = 5)%>%
  mutate(G_class_C7 = "Man")

##### Classes de Wetland -------------------------------------------------------
#Class Wetland 4CN && ID_Mapbiomas = 11
cer_mapb_W <- cer %>% 
  filter(C_pretvizi_OK== "Pa")%>%
  mutate(MAPBIOMAS_C7 = 11)%>%
  mutate(G_class_C7 = "Wet")

##### Classes de Grassland -------------------------------------------------------
cer_mapb_G<- cer %>% 
  filter(C_pretvizi_OK== "Eg" | C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Sp" |
           C_pretvizi_OK== "Tg"|C_pretvizi_OK== "Rm"| C_pretvizi_OK== "Tp"
         | C_pretvizi_OK== "T") %>%
  mutate(MAPBIOMAS_C7 = 12)%>% 
  mutate(G_class_C7 = "GrassL")

##### Classes de Dune -------------------------------------------------------
cer_mapb_DUN<- cer %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS_C7 = 23)%>% 
  mutate(G_class_C7 = "DUN")

##### Classes de Rocky Outcrop -------------------------------------------------------
cer_mapb_AR<- cer %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS_C7 = 29)%>% 
  mutate(G_class_C7 = "AR")

##### Classes de Wooded Restinga -------------------------------------------------------
cer_mapb_Res <- cer %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 49)%>% 
  mutate(G_class_C7 = "Res")


### Rbind subsets -------------------------------------------------------
cer_c7_segg_c10<-rbind(cer_mapb_FLO,cer_mapb_S,cer_mapb_G,cer_mapb_DUN,cer_mapb_AR,cer_mapb_W,cer_mapb_Res, cer_mapb_M)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-cer_c7_segg_c10[,c(1,2,15)]
write.csv(rectify_class_8bit,file = "data/CER_data_reclass8.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-cer_c7_segg_c10 [,c(1,2,13,14,15)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-cer_c7_segg_c10 [,c(1,2,11,12,13,14,15)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())



###########------------------------------------------------------------------)
## Biome Caatinga ------------------------------------------------------------------
###########------------------------------------------------------------------)


### Input-------------------------------------------------------------------------
#getwd('patch_your_project')

ca <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/caatinga.csv",
               h=T, encoding = "UTF-8")

#Tratar Caatinga
colnames(ca)
summary(ca)
cbind(names(ca))
#Nomes das colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv","Cagrpret","MAPBIOMAS_C6")
colnames(ca)
#Reclassificando as colunas dos biomas da QCN
colnames(ca)<-newNames
#Criar coluna dos Biomas 
ca$BIOMA <- c("Caatinga")
ca <- mutate(ca, C_pretvizi_OK =C_pretvizi) #Criar variável de classe igual para tratamentos nas tbls


### Resume class_fito -------------------------------------------------------
ca_class <- ca %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)

#32 Classes
#Aa,Ab,Am,Ar,As,Ca,Cb,Cm,Cs,Da,Dm,Dn,Ds,Fa,Fb,Fm,
#Fs,Pa,Pf,Pm,Rm,Sa,Sd,Sg,SN,Sp,ST,Ta,Td,Tg,TN, Tp

### Filtrar e Rectify -------------------------------------------------------
#     Filtrar classes da QCN                   #
#     Criar col MAPBIOMAS_C7 e G_class_C7      #
#               Number       e Name_class      #


##### Classes de Floresta -------------------------------------------------------
ca_mapb_FLO<- ca %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "Am"|C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" 
         |C_pretvizi_OK== "Cb"|C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"| C_pretvizi_OK== "Da" |C_pretvizi_OK== "Dm"
         |C_pretvizi_OK== "Ds"|C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"
         |C_pretvizi_OK== "Sd"|C_pretvizi_OK== "SN"| C_pretvizi_OK== "Td"| C_pretvizi_OK== "TN") %>%
  mutate(MAPBIOMAS_C7 = 3)%>%
  mutate(G_class_C7 = "F")

##### Classes de Savana -------------------------------------------------------
ca_mapb_S<- ca %>% 
  filter(C_pretvizi_OK== "ST"| C_pretvizi_OK== "Sa" |C_pretvizi_OK== "Ta") %>%
  mutate(MAPBIOMAS_C7 = 4)%>%
  mutate(G_class_C7 = "Sav")

##### Classes de Grassland -------------------------------------------------------
ca_mapb_G<- ca %>% 
  filter(C_pretvizi_OK== "Sg" | C_pretvizi_OK== "Tg" |C_pretvizi_OK== "Tp"|C_pretvizi_OK== "Pa" |
           C_pretvizi_OK== "Rm" | C_pretvizi_OK== "Sp") %>%
  #mutate(MAPBIOMAS = 12)
  mutate(MAPBIOMAS_C7 = 12)%>%
  mutate(G_class_C7 = "GrassL")

##### Classes de Mangrove -------------------------------------------------------
ca_mapb_M<- ca %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS_C7 = 5)%>%
  mutate(G_class_C7 = "Man")

##### Classes de Dune -------------------------------------------------------
ca_mapb_DUN<- ca %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS_C7 = 23)%>%
  mutate(G_class_C7 = "DUN")

##### Classes de Rocky Outcrop -------------------------------------------------------
ca_mapb_AR<- ca %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS_C7 = 29)%>%
  mutate(G_class_C7 = "AR")

#Class Wooded Restinga 4CN && ID_Mapbiomas = 49
ca_mapb_Res <- ca %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 49)%>% 
  mutate(G_class_C7 = "Res")

### Rbind subsets -------------------------------------------------------
ca_c7_segg_c10 <-rbind(ca_mapb_FLO,ca_mapb_S, ca_mapb_G,ca_mapb_M,ca_mapb_DUN,ca_mapb_AR,ca_mapb_Res)
str(ca_c7_segg_c10)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-ca_c7_segg_c10[,c(1,2,14)]
write.csv(rectify_class_8bit,file = "data/CAA_data_reclass8.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-ca_c7_segg_c10[,c(1,2,14,15)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-ca_c7_segg_c10[,c(1,2,11,12,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())



###########------------------------------------------------------------------)
## Biome Mata Atlântica ------------------------------------------------------------------
###########------------------------------------------------------------------)

### Input-------------------------------------------------------------------------
#getwd('patch_your_project')
m_atl <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/mata_atlantica.csv",
                  h=T, encoding = "UTF-8")

#Tratar Mata Atlantica 
colnames(m_atl)
summary(m_atl)
m_atl<-m_atl[,-c(3,6)] #hÃ¡ duas colunas addicionais "ObjID" e "categorig" retirar e alinhar as colunas
cbind(names(m_atl))
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv","MAPBIOMAS_C6") #Aqui as colunas pad
#Reclassificando as colunas dos biomas da QCN
colnames(m_atl)<-newNames
m_atl <- mutate(m_atl, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos

### Resume class_fito -------------------------------------------------------
a<- m_atl %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)
ggplot(data=a, aes(x=C_pretvizi_OK, y=n)) +
  geom_bar(stat="identity")

#59 Classes

##### Classes de Floresta -------------------------------------------------------
m_atl_mapb_FLO<- m_atl %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "Am"| C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" |C_pretvizi_OK== "Cb" 
         |C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"|C_pretvizi_OK== "Da" | C_pretvizi_OK== "Db" |C_pretvizi_OK== "Dl" | C_pretvizi_OK== "Dm" 
         |C_pretvizi_OK== "Ds"
         |C_pretvizi_OK== "EM"|C_pretvizi_OK== "EN" # Add Coleção 7
         |C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"
         #| C_pretvizi_OK== "La"
         |C_pretvizi_OK== "Ma"|C_pretvizi_OK== "Ml" |C_pretvizi_OK== "Mm"| C_pretvizi_OK== "Ms"
         #
         |C_pretvizi_OK== "NM"|C_pretvizi_OK== "OM"|C_pretvizi_OK== "ON"|C_pretvizi_OK== "OP"|C_pretvizi_OK== "P" #Add Coleção 7
         |C_pretvizi_OK== "SM"|C_pretvizi_OK== "SN"|C_pretvizi_OK== "SO"|C_pretvizi_OK== "TN"
         |C_pretvizi_OK== "D"|C_pretvizi_OK== "F" |C_pretvizi_OK== "M" |C_pretvizi_OK== "NP"  |C_pretvizi_OK== "SP" ) %>% #Add Coleção 7
  #
  #|C_pretvizi_OK== "Pa"|C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 3)%>% 
  mutate(G_class_C7 = "F")

##### Classes de Savana -------------------------------------------------------
m_atl_mapb_S<- m_atl %>% 
  filter(C_pretvizi_OK== "E" |C_pretvizi_OK== "S" |C_pretvizi_OK== "ST" | #Add Col7
           C_pretvizi_OK== "Sa" |C_pretvizi_OK== "Sd" | C_pretvizi_OK== "Ta" |C_pretvizi_OK== "Td") %>%
  mutate(MAPBIOMAS_C7 = 4)%>%
  mutate(G_class_C7 = "Sav")

##### Classes de Mangrove -------------------------------------------------------
m_atl_mapb_M<- m_atl %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS_C7 = 5)%>%
  mutate(G_class_C7 = "Man")

##### Classes de Wetland-------------------------------------------------------
m_atl_mapb_W <- m_atl %>% 
  filter(C_pretvizi_OK== "Pa")%>%
  mutate(MAPBIOMAS_C7 = 11)%>%
  mutate(G_class_C7 = "Wet")

##### Classes de Grassland-------------------------------------------------------
m_atl_mapb_G<- m_atl %>% 
  filter(C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Sp" |C_pretvizi_OK== "Rl"
         |C_pretvizi_OK== "Rm"|C_pretvizi_OK== "Lg"|C_pretvizi_OK== "Eg"
         |C_pretvizi_OK== "L"|C_pretvizi_OK== "La" # Add Col7
         |C_pretvizi_OK== "T"|C_pretvizi_OK== "Tg") %>%
  #|C_pretvizi_OK== "Tg")%>%
  mutate(MAPBIOMAS_C7 = 12)%>% 
  mutate(G_class_C7 = "GrassL")

##### Classes de Dune-------------------------------------------------------
m_atl_mapb_DUN<- m_atl %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS_C7 = 23)%>% 
  mutate(G_class_C7 = "DUN")

##### Classes de Rocky Outcrop-------------------------------------------------------
m_atl_mapb_AR<- m_atl %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS_C7 = 29)%>% 
  mutate(G_class_C7 = "AR")

##### Classes de Wooded Restinga-------------------------------------------------------
m_atl_mapb_Res <- m_atl %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 49)%>% 
  mutate(G_class_C7 = "Res")

### Rbind subsets -------------------------------------------------------
m_atl_c7_segg_c10<-rbind(m_atl_mapb_FLO,m_atl_mapb_S, m_atl_mapb_G,m_atl_mapb_M,m_atl_mapb_W,m_atl_mapb_DUN,m_atl_mapb_AR,m_atl_mapb_Res)
str(m_atl_c7_segg_c10)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-m_atl_c7_segg_c10[,c(1,2,13)]
write.csv(rectify_class_8bit,file = "data/m_atl_data_reclass8.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-m_atl_c7_segg_c10[,c(1,2,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-m_atl_c7_segg_c10[,c(1,2,11,12,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())



###########------------------------------------------------------------------)
## Biome Pantanal  ------------------------------------------------------------------
###########------------------------------------------------------------------)

### Input-------------------------------------------------------------------------
#getwd('patch_your_project')
pan <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/pantanal.csv",
                h=T, encoding = "UTF-8")
colnames(pan)# Verificar nomes das colunas Pantanal
summary(pan) 
pan<-pan[,-c(5)]#Na csv tem outra categoria do IBGE, "categorig" retirar e alinhar a colunas
cbind(names(pan))
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv","MAPBIOMAS_C6") #Aqui as colunas pad
colnames(pan)<-newNames #Reclassificando as colunas dos biomas da QCN
pan <- mutate(pan, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos


### Resume class_fito -------------------------------------------------------
a<- pan %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)
ggplot(data=a, aes(x=C_pretvizi_OK, y=n)) +
  geom_bar(stat="identity")
dev.off()
#19 Classes
##### Classes de Floresta-------------------------------------------------------
pan_mapb_FLO<- pan %>% 
  filter(C_pretvizi_OK== "Ca" |C_pretvizi_OK== "Cb"|C_pretvizi_OK== "Cs"
         | C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb"|C_pretvizi_OK== "Fs"
         |C_pretvizi_OK== "Sd" |C_pretvizi_OK== "Td"
         |C_pretvizi_OK== "SN"|C_pretvizi_OK== "TN")%>%  #Add Col7
  #|C_pretvizi_OK== "Tg") %>%
  mutate(MAPBIOMAS_C7 = 3)%>% 
  mutate(G_class_C7 = "F")

##### Classes de Savana-------------------------------------------------------
pan_mapb_S<- pan %>% 
  filter(C_pretvizi_OK== "Ta" |C_pretvizi_OK== "ST" |C_pretvizi_OK== "T" |C_pretvizi_OK== "Sa" #Add Col7
         |C_pretvizi_OK== "S" ) %>%
  mutate(MAPBIOMAS_C7 = 4)%>%
  mutate(G_class_C7 = "Sav")

##### Classes de Wetland-------------------------------------------------------
pan_mapb_W <- pan %>% 
  filter(C_pretvizi_OK== "Tg"|C_pretvizi_OK== "Tp" )%>%
  mutate(MAPBIOMAS_C7 = 11)%>%
  mutate(G_class_C7 = "Wet")

##### Classes de Grassland-------------------------------------------------------
pan_mapb_G<- pan %>% 
  filter(C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Sp") %>%
  mutate(MAPBIOMAS_C7 = 12)%>% 
  mutate(G_class_C7 = "GrassL")

### Rbind subsets -------------------------------------------------------
pan_c7_segg_c10<-rbind(pan_mapb_FLO,pan_mapb_S,pan_mapb_G,pan_mapb_W)
str(pan_c7_segg_c10)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-pan_c7_segg_c10[,c(1,2,13)]
write.csv(rectify_class_8bit,file = "data/pan_data_reclass8.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-pan_c7_segg_c10[,c(1,2,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-pan_c7_segg_c10[,c(1,2,11,12,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())


###########------------------------------------------------------------------)
## Biome Pampa ------------------------------------------------------------------
###########------------------------------------------------------------------)

### Input-------------------------------------------------------------------------
#getwd('patch_your_project')
pam <- read.csv("C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/pampa.csv",
                h=T, encoding = "UTF-8")
# Tratar Pampa
colnames(pam)
summary(pam) #
pam<-pam[,-c(5,12)] #hÃ¡ duas colunas addicionais "categorig" e uma "area_ha" a Ãºnica a ter Ã¡rea
#retirar e alinhar as colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv","MAPBIOMAS_C6") #Aqui as colunas pad
#Reclassificando as colunas dos biomas da QCN
colnames(pam)<-newNames
pam <- mutate(pam, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos

### Resume class_fito -------------------------------------------------------
a<- pam %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)

ggplot(data=a, aes(x=C_pretvizi_OK, y=n)) +
  geom_bar(stat="identity")

#33 Classes
##### Classes de Floresta-------------------------------------------------------
pam_mapb_FLO<- pam %>% 
  filter(C_pretvizi_OK== "Ca" |C_pretvizi_OK== "Cb" |C_pretvizi_OK== "Cm"
         |C_pretvizi_OK== "Cs"|C_pretvizi_OK== "Da" | C_pretvizi_OK== "Db" 
         |C_pretvizi_OK== "Dm"|C_pretvizi_OK== "Ds"
         |C_pretvizi_OK== "EN"|C_pretvizi_OK== "EM"|C_pretvizi_OK== "EP" #Add Col7
         #|C_pretvizi_OK== "Ea"
         #|C_pretvizi_OK== "Ep"
         | C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb"
         |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"
         | C_pretvizi_OK== "Ma"|C_pretvizi_OK== "Ms"
         |C_pretvizi_OK== "NM"| C_pretvizi_OK== "NP"|C_pretvizi_OK== "OM"|C_pretvizi_OK== "OP"|C_pretvizi_OK== "T") %>% #Add Col7
  mutate(MAPBIOMAS_C7 = 3)%>% 
  mutate(G_class_C7 = "F")

##### Classes de Wetland-------------------------------------------------------
pam_mapb_W<- pam %>% 
  filter(C_pretvizi_OK== "P"| C_pretvizi_OK== "Pf"| C_pretvizi_OK== "Pa"|C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS_C7 = 11)%>%
  mutate(G_class_C7 = "Wet")

##### Classes de Grassland-------------------------------------------------------
pam_mapb_G<- pam %>% 
  filter(C_pretvizi_OK== "Eg" 
         | C_pretvizi_OK== "Ep" #Add Col7
         #| C_pretvizi_OK== "Pm" 
         |C_pretvizi_OK== "Tg"
         |C_pretvizi_OK== "E" #Add Col7
         |C_pretvizi_OK== "Ea" #Add Col7
         |C_pretvizi_OK== "Tp") %>%
  mutate(MAPBIOMAS_C7 = 12)%>% 
  mutate(G_class_C7 = "GrassL")

##### Classes de Dune-------------------------------------------------------
pam_mapb_DUN<- pam %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS_C7 = 23)%>% 
  mutate(G_class_C7 = "DUN")

### Rbind subsets -------------------------------------------------------
pam_c7_segg_c10<-rbind(pam_mapb_FLO,pam_mapb_W,pam_mapb_G,pam_mapb_DUN)
str(pam_c7_segg_c10)

### Write subsets -------------------------------------------------------
rectify_class_8bit <-pam_c7_segg_c10[,c(1,2,13)]
write.csv(rectify_class_8bit,file = "data/pam_data_reclass8.csv",row.names=F,fileEncoding = "UTF-8")
rm(rectify_class_8bit)
#rectify_class_16bit <-pam_c7_segg_c10[,c(1,2,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass16.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_8bit)
#rectify_class_32bit <-pam_c7_segg_c10[,c(1,2,11,12,13,14)]
#write.csv(rectify_class_16bit,file = "data/AMZ_data_reclass32.csv",row.names=F,fileEncoding = "UTF-8")
#rm(rectify_class_32bit)
rm(list=ls())

#/End
