library(tidyverse)
library(readxl)
library(ggplot2)


setwd('C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_2_Col9_QCN/plot/4/')



#Importacao dos arquivos base com os codigos dos biomas e estados
cer_x <- read.csv("C:/Users/edriano.souza/Onedrive - INSTITUTO DE PESQUISA AMBIENTAL DA AMAZÔNIA/SEEG_2021_2_Col9_QCN/4_Rect_stats_x.csv",encoding = "UTF-8")

unique(cer_x$NM_ESTADO)

cer_x <- cer_x %>% 
  mutate(NM_STATE= recode(NM_ESTADO,
                         `MINAS GERAIS`= "MG", 
                         `SÃO PAULO`= "SP",
                         `BAHIA` = "BA",
                         `PIAUÍ` = "PI",
                         `MARANHÃO` = "MA",
                         `PARÁ` = "PA",
                         `RONDÔNIA` = "RO",
                         `MATO GROSSO` = "MT",
                         `TOCANTINS` = "TO",
                         `GOIÁS` = "GO",
                         `DISTRITO FEDERAL` = "DF",
                         `MATO GROSSO DO SUL` = "MS",
                         `PARANÁ` = "PR"))



colnames(cer_x)
str(cer_x)


######

geom.text.size = 7
theme.size = (14/5) * geom.text.size


plot11<- ggplot(cer_x, aes(
  color =NM_STATE , x= year, y = c_agreement)) +
  geom_point() +
  geom_smooth(method = "lm")+
  geom_text(size=4, data = cer_x[which(cer_x$year == "2010"),],
            aes(label = NM_STATE),position = position_dodge(width=0.5),size=12,
            vjust = -0.5)+
  #geom_label(size=15)+
  #geom_label(aes(fill = factor(NM_STATE)), colour = "white", fontface = "bold")
  #theme(axis.text = element_text(size = theme.size, colour="black"))+ 
  ylab("C_agreement (tC/ha)") +
  xlab(" ")+
  #scale_y_continuous(limits=c(0,175), breaks = c( 0, 25,50,75,100,125,150,175))+
  #scale_x_discrete(breaks=seq(1985,2020,5))+
  #scale_x_discrete(breaks=seq(1985,2020,5))+
  #scale_x_continuous() +
  scale_x_continuous(limits=c(1985, 2020), breaks = c(1990,2000,2010,2020)) +
  #scale_fill_manual(values=c("#92d050","#f68b32"))+
  labs(fill = " ")+
  #guides(fill=guide_legend(nrow = 1, byrow = T))+        
  theme_bw()+
  #theme_classic()+
  #theme(legend.position=c(.5,.1), legend.box = "horizontal",legend.justification = "center")+
  theme(legend.key = element_blank())+
  #theme(legend.key.height = unit(0.1, "mm"))+
  theme(legend.background = element_blank())+
  theme(legend.title = element_text(color = "black", family = "fonte.tt", size=9))+
  theme(axis.title = element_text(color = "black",family = "fonte.tt", size=9))+
  theme(legend.text =  element_text(color = "black",family = "fonte.tt", size=12,face = "bold"))+ # Aqui e a letra da legenda
  theme(axis.title.x = element_text(color = "black",family = "fonte.tt", size=9, face = "bold"))+
  theme(axis.title.y = element_text(color = "black",family = "fonte.tt", size=12, face = "bold"))+ #Aqui é a legenda do eixo y 
  theme(axis.text.x = element_text(color = "black",family = "fonte.tt",size=9, angle = 0))+ #Aqui é a legenda do eixo x
  theme(axis.text.y = element_text(color = "black",family = "fonte.tt",size=9))#Aqui é a legenda do eixo y
plot(plot11)


plot112 <- plot11 + facet_wrap( ~ class, nrow=1) 
plot(plot112)

plot(plot112)
ggsave("4_C_agreement.png", plot = plot112,dpi = 300 )


cer_x%>% filter (`class` == "12") %>% group_by(NM_STATE)%>%
  summarise(mean= mean(c_agreement), sd= sd(c_agreement), max = max(c_agreement),min = min(c_agreement))
