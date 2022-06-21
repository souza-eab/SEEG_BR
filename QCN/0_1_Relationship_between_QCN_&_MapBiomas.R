
## {                                                                                                                                                                    ##
#  Script para gerar tabelas auxiliares para relacionar as fitofisionimas do IBGE como entradas da QCN para novas re-classificações conforme MapBiomas Coleção 6 (2020). #
## }                                                                                                                                                                    ##

## Bibliotecas necessárias
#install.packages('tidyverse') Instalar biblioteca
library(tidyverse)# Utilizar Bibliotecas
library(readxl)  
library(ggplot2) 
windowsFonts(fonte.tt= windowsFont("TT Times New Roman")) #Fonte de texto para plots "coloque aqui a sua fonte" selecionada



################################################################################
################################################################################
############################### Cerrado ########################################
################################################################################
################################################################################

cer <- read.csv2("C:/Users/edriano.souza/OneDrive - IPAM-Amazonia/Mapbiomas_2021/class_csv/cerrado.csv",
                 h=T, encoding = "UTF-8",sep = ";")

colnames(cer) #verificar nomes das colunas 
summary(cer)


colnames(cer) #verificar nomes das colunas 
summary(cer)
cer<-cer[,-c(5)] #Na csv tem outra categoria do IBGE, "categorig" retirar e alinhar a colunas



#Nomes das colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv") #Aqui as colunas padrão
#que todos os biomas compartilhas da mesma informação;
#Para relacionar as classes pegamos C_pretvizi e categvizi;

colnames(cer)<-newNames# Receber classes  
cer$BIOMA <- c("Cerrado")#Criar variável bioma na csv
cer <- mutate(cer, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos
str(names(cer)) #Conferência
cer$C_pretorig <- as.factor(cer$C_pretorig)#Tranformar em fatores para as Tibbles
cer$C_pretvizi <- as.factor(cer$C_pretvizi)#.....................................
cer$categvizi <- as.factor(cer$categvizi)#.....................................
cer$BIOMA <- as.factor(cer$BIOMA)#...............................................
cer$C_pretvizi_OK <- as.factor(cer$C_pretvizi_OK)#..............................#


#vericar número de classes
unique(cer$C_pretvizi_OK)

# 59 Leves
#Aa,Ab,AR,Ar,As,Ca,Cb,Cm,Cs,Da,Db,DUN,Dn,Ds,Eg,Fa,Fb,Fm,Fs,Ma,Ml,Mm,ONm,ONs,ONts,P,Pa,Pf,Pm,Rm,S,Sa,Sd,Sg,SMl,SMm,SNb,SNm,SNs,SNtm,SNts,SOs,SOts,Sp,STb,STNm,STNs,STNtm,STNts,STs,STtm,STts,T,Ta,Td,Tg,TNm,TNs,TNtm,TNts,Tp
# A planilha tem 59 levels de pretVeg = 7890, sendo, Floresta (7873)
# tem 26 Forest, 3 OFL e 4 Grassland | 1 Duna e 1 Area Rochosas como possuem semelhança com o MAPbiomas mantive
# tem 27 Classes  

## Forest (3) -> N= 43; 
## Savana (4) -> N=  5; 
## Mangue (5) -> N=  1;
## Wetlnd (11)-> N=  1;
## Grslnd (12)-> N=  6;
## Restg  (49)-> N=  1;



cer_mapb_FLO<- cer %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" |C_pretvizi_OK== "Cb" # Conforme QCN página 121
         |C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"| C_pretvizi_OK== "Da"|C_pretvizi_OK== "Db" |C_pretvizi_OK== "Ds" #pág122
         |C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"| C_pretvizi_OK== "Ma" #    123
         |C_pretvizi_OK== "Ml" |C_pretvizi_OK== "Mm"|C_pretvizi_OK== "P" |C_pretvizi_OK== "Sd"|C_pretvizi_OK== "T"
         | C_pretvizi_OK== "Td" # Classes de Contato abaixo;
         |C_pretvizi_OK== "ONm" |C_pretvizi_OK== "ONs"|C_pretvizi_OK== "ONts"|C_pretvizi_OK== "SMl"|C_pretvizi_OK== "SMm"
         |C_pretvizi_OK== "SNb" |C_pretvizi_OK== "SNm"|C_pretvizi_OK== "SNs"|C_pretvizi_OK== "SNtm"|C_pretvizi_OK== "SNts"
         |C_pretvizi_OK== "SOs"|C_pretvizi_OK== "SOts"|C_pretvizi_OK== "STb"| C_pretvizi_OK== "STNm"|C_pretvizi_OK== "STNs"
         |C_pretvizi_OK== "STNtm"|C_pretvizi_OK== "STNts"|C_pretvizi_OK== "STtm"|C_pretvizi_OK== "TNm"| C_pretvizi_OK== "TNs"
         |C_pretvizi_OK== "TNtm"| C_pretvizi_OK== "TNts") %>%
  mutate(MAPBIOMAS = 3)%>% 
  mutate(G_class = "F")



cer_mapb_S<- cer %>% 
  filter(C_pretvizi_OK== "S" | C_pretvizi_OK== "Sa" |C_pretvizi_OK== "Ta"
         |C_pretvizi_OK== "STs"|C_pretvizi_OK== "STts") %>%
  mutate(MAPBIOMAS = 4)%>%
  mutate(G_class = "S")
cer_mapb_M<- cer %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS = 5)%>%
  mutate(G_class = "M")
cer_mapb_OFL<- cer %>% 
  filter(C_pretvizi_OK== "Pa") %>%
  mutate(MAPBIOMAS = 11)%>%
  mutate(G_class = "OFL")
cer_mapb_G<- cer %>% 
  filter(C_pretvizi_OK== "Eg" | C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Sp" |C_pretvizi_OK== "Tg"|C_pretvizi_OK== "Rm"| C_pretvizi_OK== "Tp") %>%
  mutate(MAPBIOMAS = 12)%>% 
  mutate(G_class = "G")
cer_mapb_R<- cer %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS = 49)%>%
  mutate(G_class = "R")
cer_mapb_DUN<- cer %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS = 23)%>% 
  mutate(G_class = "DUN")
cer_mapb_AR<- cer %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS = 29)%>% 
  mutate(G_class = "AR")


cerrado_ <-rbind(cer_mapb_FLO,cer_mapb_S,cer_mapb_M,cer_mapb_OFL,cer_mapb_G,cer_mapb_R,cer_mapb_DUN,cer_mapb_AR)


################################################################################
################################################################################
################################Caatinga########################################
################################################################################
################################################################################

ca <- read.csv2("C:/Users/edriano.souza/OneDrive - IPAM-Amazonia/Mapbiomas_2021/class_csv/caatinga.csv",
                h=T, encoding = "UTF-8",sep = ";")

#Tratar Caatinga
colnames(ca)
summary(ca)
cbind(names(ca))


#Nomes das colunas
newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv") #Aqui as colunas padrã
#que todos os biomas compartilhas da mesma informação;
#Para relacionar as classes pegamos C_pretvizi e categvizi;



#Reclassificando as colunas dos biomas da QCN
colnames(ca)<-newNames


#Criar coluna dos Biomas 
ca$BIOMA <- c("Caatinga")


#Criar variável de classe igual para tratamentos
ca <- mutate(ca, C_pretvizi_OK =C_pretvizi) #Criar variável de classe igual para tratamentos nas tbls
ca$C_pretorig <- as.factor(ca$C_pretorig)#Tranformar em fatores para as Tibbles
ca$C_pretvizi <- as.factor(ca$C_pretvizi)#.....................................
ca$categvizi <- as.factor(ca$categvizi)#.....................................
ca$BIOMA <- as.factor(ca$BIOMA)#...............................................
ca$C_pretvizi_OK <- as.factor(ca$C_pretvizi_OK)#..............................#


a<- ca %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)

#32 Classes
#Aa,Ab,Am,Ar,As,Ca,Cb,Cm,Cs,Da,Dm,Dn,Ds,Fa,Fb,Fm,
#Fs,Pa,Pf,Pm,Rm,Sa,Sd,Sg,SN,Sp,ST,Ta,Td,Tg,TN, Tp



ca_mapb_FLO<- ca %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "Am"|C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" 
         |C_pretvizi_OK== "Cb"|C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"| C_pretvizi_OK== "Da" |C_pretvizi_OK== "Dm"
         |C_pretvizi_OK== "Ds"|C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"
         |C_pretvizi_OK== "Sd"|C_pretvizi_OK== "SN"|C_pretvizi_OK== "Td"|C_pretvizi_OK== "TN") %>%
  mutate(MAPBIOMAS = 3)%>% 
  mutate(G_class = "F")

##Classes de Florestas = 18


ca_mapb_S<- ca %>% 
  filter(C_pretvizi_OK== "Sa" | C_pretvizi_OK== "Ta"
         |C_pretvizi_OK== "ST") %>%
  mutate(MAPBIOMAS = 4)%>%
  mutate(G_class = "S")
ca_mapb_M<- ca %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS = 5)%>%
  mutate(G_class = "M")
ca_mapb_G<- ca %>% 
  filter(C_pretvizi_OK== "Pa" | C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Sp" |C_pretvizi_OK== "Tg"|C_pretvizi_OK== "Rm"| C_pretvizi_OK== "Tp") %>%
  mutate(MAPBIOMAS = 12)%>% 
  mutate(G_class = "G")
ca_mapb_R<- ca %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS = 49)%>%
  mutate(G_class = "R")
ca_mapb_DUN<- ca %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS = 23)%>% 
  mutate(G_class = "DUN")
ca_mapb_AR<- ca %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS = 29)%>% 
  mutate(G_class = "AR")


caatinga <-rbind(ca_mapb_FLO,ca_mapb_S,ca_mapb_M,ca_mapb_G,ca_mapb_R,ca_mapb_DUN,ca_mapb_AR)



################################################################################
################################################################################
################################ Mata Atlântica ################################
################################################################################
################################################################################



m_atl <- read.csv2("C:/Users/edriano.souza/OneDrive - IPAM-Amazonia/Mapbiomas_2021/class_csv/mata_atlan_.csv",
                h=T, encoding = "UTF-8",sep = ";")


colnames(m_atl)
cbind(names(m_atl))
summary(m_atl)

m_atl<-m_atl[,-c(3,6)] #há duas colunas addicionais "ObjID" e "categorig" retirar e alinhar as colunas
cbind(names(m_atl))




newNames <- c("FID", "ID", "C_pretorig","C_pretvizi", "categvizi", "c_agb", 
              "c_bgb","c_dw","c_litter","c_total4inv") #Aqui as colunas pad


#Reclassificando as colunas dos biomas da QCN
colnames(m_atl)<-newNames


#Criar coluna dos Biomas 
m_atl$BIOMA <- c("Mata_atlantica")

m_atl <- mutate(m_atl, C_pretvizi_OK =C_pretvizi)#Criar variável de classe igual para tratamentos
m_atl$C_pretorig <- as.factor(m_atl$C_pretorig)#Tranformar em fatores para as Tibbles
m_atl$C_pretvizi <- as.factor(m_atl$C_pretvizi)#.....................................
m_atl$BIOMA <- as.factor(m_atl$BIOMA)#...............................................
m_atl$C_pretvizi_OK <- as.factor(m_atl$C_pretvizi_OK)#..............................#


a<- m_atl %>%
  group_by(C_pretvizi_OK) %>%
  count(C_pretvizi_OK)


ggplot(data=a, aes(x=C_pretvizi_OK, y=n)) +
  geom_bar(stat="identity")




#59 Classes
##14 classes por linha = 56 + 3 info
#Aa, Ab, Am, Ar, As, Ca, Cb, Cm, Cs,  D, Da, Db, Dl, Dm, Dn
#Ds, E,  Eg, EM, EN, F, Fa, Fb, Fm,  Fs, L,  La, Lg, M, Ma, 
#Ml, Mm, Ms, NM, NP, OM, ON, OP, P,  Pa, Pf, Pm, Rl, Rm, S, 
#Sa, Sd  Sg, SM, SN, SO, Sp, SP, ST, T, Ta,  Td, Tg, TN


#

#Classifim_atlr MAPBIOMAS igual a planilha do paper para classe Floresta
#34 class OR + 39
m_atl_mapb_FLO<- m_atl %>% 
  filter(C_pretvizi_OK== "Aa" |C_pretvizi_OK== "Ab"|C_pretvizi_OK== "Am" | C_pretvizi_OK== "As"| C_pretvizi_OK== "Ca" 
         |C_pretvizi_OK== "Cb"|C_pretvizi_OK== "Cm"|C_pretvizi_OK== "Cs"|C_pretvizi_OK== "Da" | C_pretvizi_OK== "Db" 
         |C_pretvizi_OK== "Dl" | C_pretvizi_OK== "Dm"|C_pretvizi_OK== "Ds"|C_pretvizi_OK== "EM"| C_pretvizi_OK== "EN"
         |C_pretvizi_OK== "Fa"|C_pretvizi_OK== "Fb" |C_pretvizi_OK== "Fm"|C_pretvizi_OK== "Fs"| C_pretvizi_OK== "La"
         | C_pretvizi_OK== "Ma"|C_pretvizi_OK== "Ml" |C_pretvizi_OK== "Mm"| C_pretvizi_OK== "Ms"| C_pretvizi_OK== "NM"
         | C_pretvizi_OK== "OM"| C_pretvizi_OK== "ON"| C_pretvizi_OK== "OP"|C_pretvizi_OK== "P"| C_pretvizi_OK== "SM"
         |C_pretvizi_OK== "SN"| C_pretvizi_OK== "SO"|C_pretvizi_OK== "TN" ## Daqui em diante não tem na média;
         |C_pretvizi_OK== "D" |C_pretvizi_OK== "F"|C_pretvizi_OK== "L"|C_pretvizi_OK== "M"|C_pretvizi_OK== "NP"
         |C_pretvizi_OK== "SP"|C_pretvizi_OK== "T")%>%
  mutate(MAPBIOMAS = 3)

##Classes de Florestas = 24

#Classifim_atlr com a QCN para a Savana 4
m_atl_mapb_S<- m_atl %>% 
  filter(C_pretvizi_OK== "E" |C_pretvizi_OK== "S" | C_pretvizi_OK== "Sa" |C_pretvizi_OK== "Sd" | C_pretvizi_OK== "ST" | C_pretvizi_OK== "Ta" |C_pretvizi_OK== "Td") %>%
  mutate(MAPBIOMAS = 4)
##Classes de Florestas = 4

m_atl_mapb_M<- m_atl %>% 
  filter(C_pretvizi_OK== "Pf") %>%
  mutate(MAPBIOMAS = 5)
##Classes = 1

m_atl_mapb_OFL<- m_atl %>% 
  filter(C_pretvizi_OK== "Pa") %>%
  mutate(MAPBIOMAS = 11)

#Classifim_atlr com a QCN para a Grassland 12
m_atl_mapb_G<- m_atl %>% 
  filter(C_pretvizi_OK== "Eg" |C_pretvizi_OK== "Lg" |C_pretvizi_OK== "Sg" |C_pretvizi_OK== "Rl"
         |C_pretvizi_OK== "Rm"|C_pretvizi_OK== "Sp"|C_pretvizi_OK== "Tg") %>%
  mutate(MAPBIOMAS = 12)

##Classes de Florestas = 7
m_atl_mapb_R<- m_atl %>% 
  filter(C_pretvizi_OK== "Pm") %>%
  mutate(MAPBIOMAS = 49)

#Classifim_atlr com a QCN para a DUN
m_atl_mapb_DUN<- m_atl %>% 
  filter(C_pretvizi_OK== "Dn") %>%
  mutate(MAPBIOMAS = 23)
##Classes = 1

#Classifim_atlr com a QCN para a AR
m_atl_mapb_AR<- m_atl %>% 
  filter(C_pretvizi_OK== "Ar") %>%
  mutate(MAPBIOMAS = 29)
##Classes  = 1


m_atl_Ok <-rbind(m_atl_mapb_AR,
                 m_atl_mapb_DUN,
                 m_atl_mapb_FLO,
                 m_atl_mapb_G,
                 m_atl_mapb_M,
                 m_atl_mapb_OFL,
                 m_atl_mapb_R,
                 m_atl_mapb_S)


