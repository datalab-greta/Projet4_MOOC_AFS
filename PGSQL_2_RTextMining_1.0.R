zemouche
###########
library(RPostgres)
library(RPostgreSQL)
library(DBI)
library(dbplyr)
#library(RODBCDBI)
# Connect to a specific postgres database i.e. Heroku
con <- dbConnect(RPostgres::Postgres(),dbname = 'BDD_Franck', 
                 host = '127.0.0.1', # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                 port = 5432, # or any other port specified by your DBA
                 user = 'perrot',
                 password = '38d3a8276b39e9da87be27e148a4e2f12a695441118da269fa7b8d3c183e18e2')
print(con)
dbListTables(con)

dbListFields(con, "Fun_Mooc1")
dftm <- dbReadTable(con, "Fun_Mooc1")

dbDisconnect(con)

#----------------------écrire la Dataframe en le CSV------------------------------------------
write.csv2(dftm,"/home/perrot/Documents/Projet4/working/data-mooc.csv", row.names = FALSE)
#write.csv2(dftm,"/home/oem/Desktop/projet_mooc/data-mooc.csv", row.names = FALSE)

#---------------------------------------TEXT MINING--------------------------------------------
library(dplyr)
library(corpus)
library(tm)

#---ETAPE 1----
#-----------------------------Importation de la base de données--------------------------------

df_mooc <-read.csv2("/home/perrot/Documents/Projet4/working/data-mooc.csv", header=TRUE, encoding="utf8")

head(df_mooc, 10)

#--------------------------mettre la colonne date en format Date-----------------------------------
df_mooc$date <- as.Date(df_mooc$date)

#----------text mining pour l'année 2014 ( ségmentation car les fichier est très volumineux)----

library(lubridate)
mooc_filtre<-df_mooc%>%
  select(date, body)%>%
  filter(date <= "2014-12-31" & date >= "2014-01-01")
head_filtre <- head(mooc_filtre, 10)


#--Opération importante: transformation de la variable base_body en corpus pour la suite du traitement

monCorpus <- tm::Corpus((VectorSource(as.character(mooc_filtre$body))))

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
monCorpus <- tm_map(monCorpus, toSpace, "/")
monCorpus<- tm_map(monCorpus, toSpace, "@")
monCorpus<- tm_map(monCorpus, toSpace, "–")
monCorpus<- tm_map(monCorpus, toSpace, "…")
monCorpus<- tm_map(monCorpus, toSpace,  "’")
#monCorpus <- tm_map(monCorpus, toSpace, "  \|")

# Inspection du corpus:
inspect(monCorpus)

# Visualisation d'un contenu
monCorpus[[3]]$content

# On transforme en matrice de mot (tokenisation)
myTDM <- TermDocumentMatrix(monCorpus)


#---ETAPE 2----

# On recherche les mots les plus fréquents (au moins 100 occurences)
mots_fréquents <- findFreqTerms(myTDM, lowfreq = 2)

# Nettoyage simple : ponctuation
monCorpusClean <- tm_map(monCorpus, removePunctuation)

# Nettoyage simple : lettre minuscule
monCorpusClean <- tm_map(monCorpusClean, content_transformer(tolower))

# Suppression des nombres du corpus, si presence eventuelle
monCorpusClean <- tm_map(monCorpusClean, removeNumbers)

# Suppression des stopwords (mots-outils, usage fonctionnel)
#monCorpusClean <- tm_map(monCorpusClean, removeWords, stopwords('english'))
monCorpusClean <- tm_map(monCorpusClean, removeWords, stopwords('french'))
# Supprimer votre propre liste de mots non désirés
monCorpusClean <- tm_map(monCorpusClean , removeWords, c("bonjour", "tout", "plus", "tous", "doit", "bien", "être", "fair", "aussi", "peut","quil","ça","là","où",
                                                         "comm", "personn", "donc", "bon", "nouvel", "fait", "autr", "sen très", "nouvell", "fait","faire", "dune",
                                                         "car", "the", "avoir", "and", "format", "les", "que", "des", "pour", "est", "dun", "une","quon","dit","alors",
                                                         "cest","qui", "sui","jai","mai", "par", "avec", "sur", "pas","fair", "question", "nest","toutes", "entre",
                                                         "très", "merci", "faut", "temp", "savoir", "bonn", "sen","ã","pens","dis", "–","’", "…","idem","manager", "•",
                                                         "comme", "toujours","déja","etre","voir","assez","veut","estce","sil","etc","cas","celle","peutetre","quun",
))
# Supprimer les espaces vides supplémentaires
monCorpusClean <- tm_map(monCorpusClean, stripWhitespace)


#---ETAPE 3----
#-------------------------------------- Text stemming--------------------------------

#---------------------------générer un nuage de mots clés----------------------------
#install.packages("wordcloud")
library(wordcloud)
wordcloud(monCorpusClean, min.freq = 10,colors=brewer.pal(8, "Dark2"),random.color = TRUE,max.words = 100)

#---------------------------barplot de mots clés----------------------------
# Partie 1 : on transforme en matrice de mot (tokenisation)
myTDMClean <- TermDocumentMatrix(monCorpusClean)

# Partie 2 : on recherche les mots les plus fréquents (au moins 100 occurences)
findFreqTerms(myTDMClean, lowfreq = 10)

# Partie 3 : Calcul de la somme des occurences
sumOccurClean <- rowSums(as.matrix(myTDMClean))[order(rowSums(as.matrix(myTDMClean)), decreasing = TRUE)]

barplot(sumOccurClean[1:20], main="20 plus fortes occurences", ylab="Nb occurence", las=2, space = 1.3,  horiz = FALSE)
#xlab="Mot"


#---ETAPE 4----
#----------------SENTIMENT ANALYSIS--------------------------------------

#--------getting emotions using in-built function--------------------
library(tidytext)
library(RColorBrewer)
library(syuzhet)
mysentiment_mooc <- get_nrc_sentiment(as.character(monCorpusClean), language = "french", cl = NULL)
#head(mysentiment_mooc)

#---- renomer les colonnes ( traduction)
names(mysentiment_mooc) <- c("colère", "anticipation", "dégoûter", "peur", "joie", "tristesse", "surprise", "confiance", "négative", "positive")

#suppression des deux sentiments : positive et négative
mysentiment_mooc <- mysentiment_mooc[,-10:-9] 

Sentimentscores_mooc<-data.frame(colSums(mysentiment_mooc[,]))

#calculationg total score for each sentiment
names(Sentimentscores_mooc)<-"Score"
Sentimentscores_mooc<-cbind("sentiment"=rownames(Sentimentscores_mooc),Sentimentscores_mooc)
rownames(Sentimentscores_mooc)<-NULL

library(ggplot2)
p<- ggplot(data=Sentimentscores_mooc, aes(x= reorder(sentiment, Score),y=Score))+
  geom_bar(aes(fill=sentiment, width = .4), stat = "identity", horiz=T )+
  theme(legend.position="none")+
  xlab("Sentiments")+ylab("scores")+ggtitle("Analyse de sentiments mooc")
print(p) 

# mise en forme de plot---------------------------------------------
  p + theme(
    panel.background = element_rect(fill = "firebrick4",
                                    colour = "lightblue",
                                    size = 0.5, linetype = "solid"),
    panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                    colour = "white"), 
    panel.grid.minor = element_line(size = 0.5, linetype = 'solid',
                                    colour = "white")
  )+ coord_flip()

