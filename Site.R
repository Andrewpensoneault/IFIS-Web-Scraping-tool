############ LOADS REQUIRED LIBRARIES
library('rvest')
library('stringr')
setwd("C:/Users/drumm/Dropbox/Graduate Classes/UIOWA - 2018 Spring/TDA/Project")     #SETS WD TO sites.csv LOCATION



############ LOADS THE SITE NAMES FROME FILE
sites <- read.table("sites.csv", quote="\"", comment.char="", stringsAsFactors=FALSE) #LOADS DATA AS TABLE
sites <- sites[,1]                  #CONVERTS TO VECTOR



############ GENERATES THE TIMES FOR THE DATA
url <- paste('http://ifis.iowafloodcenter.org/ifis/ws/elev_sites.php?site=',sites[1],'&period=72&format=tab'
             ,sep="")               #CREATES URL
webpage <- read_html(url)           #SCRAPES DATA
text <- html_text(webpage)          #CONVERTS TO TEXT
temptab=read.table(text=text)       #CONVERTS TO TABLE
tabdepth=temptab[2]                 #TAKES ONLY THE TIME
tabheight=temptab[2]                #TAKES ONLY THE TIME



############ GENERATES THE FULL DATA SET
for (i in sites){
## DEPTH
  url <- paste('http://ifis.iowafloodcenter.org/ifis/ws/sites.php?site=',i,'&period=72&format=tab',sep="")
  webpage <- read_html(url)               #SCRAPES DATA
  text <- html_text(webpage)              #CONVERTS TO TEXT
  temptab=read.table(text=text)           #CONVERTS TO TABLE
  tabdepth=cbind(tabdepth,temptab[3])     #MERGES THE TABLE WITH THE NEW DEPTH
  Sys.sleep(.3)                           #PAUSES FOR 1/10 OF A SECOND

## ELEVATION  
  url <- paste('http://ifis.iowafloodcenter.org/ifis/ws/elev_sites.php?site=',i,'&period=72&format=tab',sep="")
  webpage <- read_html(url)               #SCRAPES DATA
  text <- html_text(webpage)              #CONVERTS TO TEXT
  temptab=read.table(text=text)           #CONVERTS TO TABLE
  tabheight=cbind(tabheight,temptab[3])   #MERGES THE TABLE WITH THE NEW ELEVATION
  Sys.sleep(.3)                           #PAUSES FOR 1/10 OF A SECOND
  }


############ SAVES AS CSV 
filename=paste('DEPTH',format(Sys.time(), "%b_%d_%H_%M_%S_%Y"),'.csv',sep="")
write.csv(tabdepth, file = filename)

filename=paste('ELEVATION',format(Sys.time(), "%b_%d_%H_%M_%S_%Y"),'.csv',sep="")
write.csv(tabheight, file = filename)
