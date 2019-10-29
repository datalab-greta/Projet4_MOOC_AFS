# Projet 4 - MOOC

## Projet : Objectif

#__Des statistiques qualitatives concernant les forums de MOOC__

***
# Visualiser pour un cours :
# 
# *- *Les contributeurs les plus actifs (pareto)
# *- *Répartition des messages dans le temps
# *- *Répartition par groupes (topics)
# *- *Comparer des cours entre eux
# *- *Les plus actifs, les plus longs ...
***
  
## Data disponible
  
# __   DATA CONTENT   __

***
  
#   1. Introduction to Project Management 6 weeks (Anglais)
# * course-v1:AdelaideX+Project101x+2T2016 date du 15-07-2016 au 17-03-2017
# * Adelaide University en parternaire avec EdX
# 
# 2. Du manager agile au leader designer / From an agile manager to a designer leader - 5 semaine session 5 (Français et Anglais)
# * CNAM/01002/Trimestre_1_2014 date du 03-02-2014 au 15-05-2014
# * Le CNAM
# 
# 3. S'initier à la fabrication numérique - 4 semaine -session5 
# * course-v1:MinesTelecom+04026+session05 du 17 sep 2019 au 05 nov 2019
# * L'Institut Mines-Télécom
# 
# 4. Introduction à la statistique avec R -Session 12
# * course-v1:UPSUD+42001+session12 du 09 sep 2019 au 20 oct 2019 
# * L'Université Paris-Sud
# 
# 5. Python 3 : des fondamentaux aux concepts avancés du langage 
# * course = "course-v1:UCA+107001+session02" 17 sep 2018 au 06 sep 2020
# * L'Université Côte d'Azur

***


### LIBRAIRIES

#---------------------------------RMARKDOWN---------------------------------
library(rmarkdown)
library(rmd) 
library(knitr) 
library(md) 
#library(pandoc)

#--------------------------CONNECTION TO DATABASES-----------------------------
library(RPostgres)
library(RPostgreSQL)
library(DBI)
library(dbplyr)

#---------------------------------GRAPHICS-------------------------------------
library(ggplot2)
library(dplyr)
library(tidyverse)
library(tidytext)
library(stringr)
library(tidyr)
#-------------------------libraires de base ----------------------
library(devtools)
library(usethis)





## Connection à base des données



#--------------------Connect to a postgres database----
con <- dbConnect(RPostgres::Postgres(),dbname = 'BDD_Franck', 
                 host = '127.0.0.1', # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                 port = 5432, # or any other port specified by your DBA
                 user = 'perrot',
                 password = '38d3a8276b39e9da87be27e148a4e2f12a695441118da269fa7b8d3c183e18e2')
print(con)
dbListTables(con)


## Importation dans une Dataframe


#--------------------------Create a dataframe from ReadTable---------------------------
dbListFields(con, "Fun_Mooc1")
data <- dbReadTable(con, "Fun_Mooc1")
df <- data
```



#------------------------------Write dataframe to csv---------------------------------
write.csv(data,"/home/perrot/Documents/Projet4/working/datatest.csv", row.names = FALSE)




#---------------------------------Trim whitespaces-----------------------------------

df[] <- lapply(df, trimws)


## DATAFRAMES pour graphs et calcule


#------------------Dataframe with reduced dates--------------------

dfg1 <- df
dfg1$date <- as.Date(dfg1$date)

#--------------------Dataframe counts par user-----------------------

ucount <- dfg1
  ucount <- dplyr::count(df, username, sort= TRUE)

#--------------------Dataframe counts graph par course-----------------------  

dcount <- dfg1 %>% dplyr::count(date, course_id, username)
  
#------------------------------
dcountA <- dcount[order(dcount$n),]
dcountC <- dcount[order(dcount$n),]
dcountM <- dcount[order(dcount$n),]
dcountU <- dcount[order(dcount$n),]
dcountS <- dcount[order(dcount$n),]
dcountUC <- dcount[order(dcount$n),]


#----------------Subsetting Data-----------------------------------------------

dfex1 <- dfg1[c("username", "course_id")]
dfex2 <- subset(dfg1, select = c(user_id, course_id))
dfex3 <- subset(dfg1, select = c(thread_type, parent_id, thread_id, endorsed, resp_total))
dfex4 <- subset(dfg1, select = c(user_id, date))
dfex5 <- subset(dfg1, select = c(mtype, course_id, date))
dfex6 <- subset(dfg1, select = c(blen, course_id, date, mtype, user_id,thread_type, parent_id, thread_id, endorsed, resp_total))

#----------------Dataframe MType graph-----------------------------------------------

dcountAS <- dfex5[order(dfex5$mtype),]
dmtype <- dcountAS %>% tidyr::separate(mtype, c("semaine", "stitre"), sep = " / ")

#---------------------Dataframe for Pareto--------------------------------------

dfguc <- dfg1[c("username", "course_id", "date")]
ducn <- dfguc %>% group_by(course_id) %>% add_count(username)


#--------------------------Count data-------------------------------

ccdt <- dplyr::count(dfg1, date)

ccid <- dplyr::count(df, id)
ccus <- dplyr::count(df, username)
cci <- dplyr::count(df, course_id)
cct <- dplyr::count(df, courseware_title)
ccui <- dplyr::count(df, user_id)
ccpi <- dplyr::count(df, parent_id)
ccti <- dplyr::count(df, thread_id)
cctt <- dplyr::count(df, thread_type)
ccmt <- dplyr::count(df, mtype)
cctt <- dplyr::count(df, title)
cced <- dplyr::count(df, endorsed)

#----------------------------END OF DATAFRAMES-----------------------------------------




## Graphs et Plots


* Les contributeurs les plus actifs (pareto)
* Répartition des messages dans le temps
* Répartition par groupes (topics)
* Comparer des cours entre eux
* Les plus actifs, les plus longs ...


## Description graphique (histogramme, barplot, pieplot, etc.)

- Ajouter la taille cumulée et moyenne :
    – = longueur du body du message
    – + longueur des body des childs
- Identifier les messages / fils de discussion les plus ‘verbeux’
- Faire une description graphique (histogramme, barplot, pieplot, etc.)
- Les votes : les plus populaires ?




#----------------------------------------


### Les contributeurs les plus actifs (pareto)


dfp <- ucount
dfp <- dfp %>%
  filter(n >= 40L & n <= 415L)
dfp <- arrange(dfp, desc(n)) %>%
  mutate(
    cumsum = cumsum(n),
    freq = round(n / sum(n), 3),
    cum_freq = cumsum(freq)
  )
dfp

## Saving Parameters 
def_par <- par

# New margins
par(mar=c(5,5,4,5)) 

## plot bars, pc will hold x values for bars
pc = barplot(dfp$n,
             width = 1, space = 0.2, border = NA, axes = F,
             ylim = c(0, 1.05 * max(dfp$n, na.rm = T)), 
             ylab = "Counts" , cex.names = 0.7,
             las=2,
             names.arg = dfp$username,
             main = "Pareto Chart - Les contributeurs les plus actifs")
## anotate left axis
axis(side = 2, at = c(0, dfp$n), las = 1, col.axis = "grey62", col = "grey62", tick = T, cex.axis = 0.8)

## frame plot
box( col = "grey62")

## Cumulative Frequency Lines 
px <- dfp$cum_freq * max(dfp$n, na.rm = T)
lines(pc, px, type = "b", cex = 0.7, pch = 19, col="cyan4")

## Annotate Right Axis
axis(side = 4, at = c(0, px), labels = paste(c(0, round(dfp$cum_freq * 100)) ,"%",sep=""), 
     las = 1, col.axis = "grey62", col = "cyan4", cex.axis = 0.8, col.axis = "cyan4")

## restoring default paramenter
pareto <- par(def_par)


#----------------------------------------
### Les plus actifs, les plus longs ...



gucount <- dplyr::count(df, username, sort = TRUE)
gucount <- gucount %>%
  filter(n >= 40L & n <= 700L)
gucount$username <- factor(gucount$username, levels = gucount$username[order(-gucount$n)])
ggplot(gucount) +
  aes(x = gucount$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "tous les course") +
  geom_bar(fill = "#26828e") +
  coord_flip()+
  scale_fill_hue() +
  theme(
  axis.text.x = element_text(angle = 45))
  theme_minimal()


gucountA <- dcountU
gucountA <- dplyr::count(gucountA, username, course_id, sort = TRUE)
gucountA <- gucountA %>%
  filter(n >= 8L & n <= 100L) %>%
  filter(course_id %in% "course-v1:AdelaideX+Project101x+2T2016")
gucountA$username <- factor(gucountA$username, levels = gucountA$username[order(-gucountA$n)])
ggplot(gucountA) +
  aes(x = gucountA$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "AdelaideX - Introduction to Project Management (6 semaines - Anglais)", caption = "") +
  geom_bar(fill = "#6dcd59") +
  coord_flip()+
  scale_fill_hue() +
  theme_minimal()+
  theme(
  axis.text.x = element_text(angle = 45))
  theme_minimal()

  
gucountC <- dcountU
gucountC <- dplyr::count(gucountC, username, course_id, sort= TRUE)
gucountC <- gucountC %>%
  filter(n >= 13L & n <= 26L) %>%
  filter(course_id %in% "CNAM/01002/Trimestre_1_2014")
gucountC$username <- factor(gucountC$username, levels = gucountC$username[order(-gucountC$n)])
ggplot(gucountC) +
  aes(x = gucountC$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "CNAM - Du manager agile au leader designer (4 mois)", caption = "") +
  geom_bar(fill = "#b06c74") +
  coord_flip()+
  scale_fill_hue() +
  theme_minimal() + theme(
  axis.text.x = element_text(angle = 45))
p3 <- ggplot +  theme_minimal()



gucountM <- dcountM
gucountM <- dplyr::count(gucountM, username, course_id, sort= TRUE)
gucountM <- gucountM %>%
  filter(n >= 1L & n <= 26L) %>%
  filter(course_id %in% "course-v1:MinesTelecom+04026+session05")
gucountM$username <- factor(gucountM$username, levels = gucountM$username[order(-gucountM$n)])
ggplot(gucountM) +
  aes(x = gucountM$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "Mines Telecom - S'initier à la fabrication numérique - 5 semaine", caption = "") +
  geom_bar(fill = "#660000") +
coord_flip()+
  scale_fill_hue() +
  theme_minimal() + theme(
    axis.text.x = element_text(angle = 45))
p3 <- ggplot +  theme_minimal()



gucountS <- dcountU
gucountS <- dplyr::count(gucountS, username, course_id, sort= TRUE)
gucountS <- gucountS %>%
  filter(n >= 2L & n <= 26L) %>%
  filter(course_id %in% "course-v1:UPSUD+42001+session12")
gucountS$username <- factor(gucountS$username, levels = gucountS$username[order(-gucountS$n)])
ggplot(gucountS) +
  aes(x = gucountS$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "UPSUD - Introduction à la statistique avec R (8 semaine)", caption = "") +
  geom_bar(fill = "#006633") +
  coord_flip()+
  scale_fill_hue() +
  theme_minimal() + theme(
    axis.text.x = element_text(angle = 45))
p3 <- ggplot +  theme_minimal()


gucountUC <- dcountUC
gucountUC <- dplyr::count(gucountUC, username, course_id, sort= TRUE)
gucountUC <- gucountUC %>%
  filter(n >= 2L & n <= 26L) %>%
  filter(course_id %in% "course-v1:UCA+107001+session02")
gucountUC$username <- factor(gucountUC$username, levels = gucountUC$username[order(-gucountUC$n)])
ggplot(gucountUC) +
  aes(x = gucountUC$username, weight = n) +
  labs(x = "username", y = "number", title = "Les utilisateurs le plus fréquent", subtitle = "UCA -Python 3 : des fondamentaux aux concepts avancés du langage (8 semaine)", caption = "") +
  geom_bar(fill = "#d133ff") +
  coord_flip()+
  scale_fill_hue() +
  theme_minimal() + theme(
    axis.text.x = element_text(angle = 45))
p3 <- ggplot +  theme_minimal()


#----------------------------------------

### Nombre des messages par period et course

```{r}
dcountA <- dcountA %>%
  filter(course_id %in% "course-v1:AdelaideX+Project101x+2T2016")
ggplot(dcountA) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_hue() +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et course") +
  labs(subtitle = "AdelaideX Introduction to Project Management - du 15-07-2016 au 17-03-2017")
p4 <- ggplot + theme_minimal()



dcountC <- dcountC %>%
  filter(course_id %in% "CNAM/01002/Trimestre_1_2014")
ggplot(dcountC) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_hue() +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et course") +
  labs(subtitle = "CNAM - Du manager agile au leader designer du 03-02-2014 au 15-05-2014") +
  theme_minimal()



dcountM <- dcountM %>%
  filter(course_id %in% "course-v1:MinesTelecom+04026+session05")
ggplot(dcountM) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_hue() +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et course") +
  labs(subtitle = "Mines Telecom - S'initier à la fabrication numérique - session 5 du 17 sep 2019 au 05 nov 2019") +
  theme_minimal()



dcountS<- dcountS %>%
  filter(course_id %in% "course-v1:UPSUD+42001+session12")
ggplot(dcountS) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_hue() +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et course 
") +
  labs(subtitle = "UPSUD - Introduction à la statistique avec R du 09 sep 2019 au 20 oct 2019") +
  theme_minimal()



dcountUC<- dcountUC %>%
  filter(course_id %in% "course-v1:UCA+107001+session02")
ggplot(dcountUC) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_hue() +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et course") +
  labs(subtitle = "UCA - Python 3 : des fondamentaux aux concepts avancés du langage du 17 sep 2018 au 06 sep 2020") +
  theme_minimal()


#----------------------------------------


### Comparer des cours entre eux

#__Plot de course par nombre de message__


ggplot(dcount) +
  aes(x = date, y = n, colour = course_id) +
  geom_line(size = 1L) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "Period des messages", y = "Nombre de message", title = "Nombre des messages par period et tous les cours") +
  theme_minimal()



### Répartition par groupes (topics)


#__Introduction to Project Management 6 weeks (English)  - du 15-07-2016 au 17-03-2017 - par semaine__



dmtypeA <- dmtype %>%
  filter(course_id %in% "course-v1:AdelaideX+Project101x+2T2016") %>%
  
  filter(date >= "2016-07-13" & date <= "2017-03-17")

ggplot(dmtypeA) +
  aes(x = date, fill = semaine) +
  geom_histogram(bins = 30L) +
  scale_fill_hue() +
  labs(x = "temp", y = "nombre des messages", title = "Introduction to Project Management par AdelaideX", subtitle = "message par semaine et sujet", 
       caption = "", fill = "Sujet") +
  theme_minimal()



#__Du manager agile au leader designer par semaine - du 03-02-2014 au 15-05-2014__



dmtypeC <- dmtype %>%
  filter(course_id %in% "CNAM/01002/Trimestre_1_2014") %>%
  filter(date >= "2014-02-03" & date <= "2014-05-17")
ggplot(dmtypeC) +
  aes(x = date, fill = semaine) +
  geom_histogram(bins = 30L) +
  scale_fill_hue() +
  labs(x = "temp", y = "nombre des messages", title = "Agile Management par CNAM", subtitle = "message par semaine et sujet", 
       caption = "", fill = "Sujet") +
  theme_minimal()



#__S'initier à la fabrication numérique par semaine - 17 sep 2019 au 05 nov 2019__



dmtypeM <- dmtype %>%
  filter(course_id %in% "course-v1:MinesTelecom+04026+session05") %>%
  filter(date >= "2019-09-17" & date <= "2019-11-05")
ggplot(dmtypeM) +
  aes(x = date, fill = semaine) +
  geom_histogram(bins = 30L) +
  scale_fill_hue() +
  labs(x = "temp", y = "nombre des messages", title = "S'initier à la fabrication numérique par Mines Telecom", subtitle = "message par semaine et sujet", 
       caption = "", fill = "Sujet") +
  theme_minimal()




#__Introduction à la statistique avec R par semaine - 09 sep 2019 au 20 oct 2019__



dmtypeS <- dmtype %>%
  filter(course_id %in% "course-v1:UPSUD+42001+session12") %>%
  filter(date >= "2019-09-09" & date <= "2019-10-20")
ggplot(dmtypeS) +
  aes(x = date, fill = semaine) +
  geom_histogram(bins = 30L) +
  scale_fill_hue() +
  labs(x = "temp", y = "nombre des messages", title = "Introduction à la statistique avec R par UPSUD", subtitle = "du 09 sep 2019 au 20 oct 2019    messages par semaine", 
       caption = "", fill = "Sujet") +
  theme_minimal()




#__Python 3 : des fondamentaux aux concepts avancés du langage - 09 sep 2019 au 20 oct 2019__



dmtypeS <- dmtype %>%
  filter(course_id %in% "course-v1:UCA+107001+session02") %>%
  filter(date >= "2018-09-17" & date <= "2019-09-06")
ggplot(dmtypeS) +
  aes(x = date, fill = semaine) +
  geom_histogram(bins = 30L) +
  scale_fill_hue() +
  labs(x = "temp", y = "nombre des messages", title = "Python 3 : des fondamentaux aux concepts avancés du langage", subtitle = "du 17 sep 2018 au 06 sep 2019      message par semaine", 
       caption = "", fill = "Sujet") +
  theme_minimal()



### Longueur du body du message + child


#----------------------------------------
dfex7 <- subset(dfg1, select = c(course_id, blen))
dfex7$blen <- as.numeric(dfex7$blen)
dfex7 <- dfex7 %>%
  filter(blen >= 1L & blen <= 2000L)

ggplot(dfex7) +
  aes(x = blen, fill = course_id) +
  geom_density(adjust = 1L, alpha=.5) +
 scale_fill_viridis_d(option = "plasma") +
  labs(x = "longueur du 'body' du message", y = "density", title = "Longueur du 'body' du message - 1 à 2000", subtitle = "", fill = "Cours id") +
  theme_minimal()



#----------------------------------------
dfex7 <- subset(dfg1, select = c(course_id, blen))
dfex7$blen <- as.numeric(dfex7$blen)
dfex7 <- dfex7 %>%
  filter(blen >= 2001L & blen <= 6000L)

ggplot(dfex7) +
  aes(x = blen, fill = fct_rev(course_id)) +
  geom_density(adjust = 1L, alpha=.5) +
 scale_fill_viridis_d(option = "plasma") +
  labs(x = "longueur du 'body' du message", y = "density", title = "Longueur du 'body' du message - 2001 à 6000", subtitle = "", fill = "Cours id") +
  theme_minimal()





#----------------------------------------

dfex7 <- subset(dfg1, select = c(course_id, blen))
dfex7$blen <- as.numeric(dfex7$blen)
dfex7 <- dfex7 %>%
  filter(blen >= 1L & blen <= 6000L)

dentous <- ggplot(dfex7) +
  aes(x = blen, fill = fct_rev(course_id)) +
  geom_density(adjust = 1L,, alpha=.5) +
 scale_fill_viridis_d(option = "plasma") +
  labs(x = "longueur du body du message + child", y = "density", title = "Longueur du 'body' du message - 1 à 6000", subtitle = "", fill = "Cours id") +
  theme_minimal()




#----------------------------------------

dfthread <- dfg1 %>%
  filter(!(thread_type %in% ""))
thtous <- ggplot(dfthread) +
  aes(x = thread_type) +  
  geom_bar(fill = "#0c4c8a") +
labs(x = "type de thread", y = "nombre", title = "Nombre des messages par type de thread", subtitle = "") +
  theme_minimal()






### Répartition des messages dans le temps


library(plyr)
library(lubridate)
library(ggplot2)
library(dplyr)

messages <- df[c("date", "user_id", "course_id", "thread_id","thread_type","resp_total")]

#Assign color variables
col1 = "#d8e1cf" 
col2 = "#438484"

#Peek at the data set and attach the column names
head(messages)
attach(messages)
str(messages)

messages$ymd <- ymd_hms(date)
messages$month <- month(messages$ymd, label = TRUE)
messages$year <- year(messages$ymd)
messages$wday <- wday(messages$ymd, label = TRUE)
messages$hour <- hour(messages$ymd)
attach(messages)
head(messages)

#------------------------------------


yearMonth <- ddply(messages, c("year", "month"), summarize, N = length(ymd))

#reverse order of months for easier graphing
yearMonth$month <- factor(yearMonth$month, levels=rev(levels(yearMonth$month)))
attach(yearMonth)

#overall summary
ggplot(yearMonth, aes(year, month)) + geom_tile(aes(fill = N),colour = "white") +
  scale_fill_gradient(low = col1, high = col2) +  
  guides(fill=guide_legend(title="Total Messages")) +
  labs(title = "Messages par mois et année",
       x = "Année", y = "Mois") +
  theme_bw() + theme_minimal() 



dayHour <- ddply(messages, c( "hour", "wday"), summarise, N    = length(ymd))

dayHour$wday <- factor(dayHour$wday, levels=rev(levels(dayHour$wday)))
attach(dayHour)

ggplot(dayHour, aes(hour, wday)) + geom_tile(aes(fill = N),colour = "white", na.rm = TRUE) +
  scale_fill_gradient(low = col1, high = col2) +  
  guides(fill=guide_legend(title="Total Messages")) +
  theme_bw() + theme_minimal() + 
  labs(title = "Messages par heure jour et heure",
       x = "par heure", y = "par jour") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
