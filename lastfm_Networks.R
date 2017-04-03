library(jsonlite)
library(networkD3)
library(igraph)
library(RCurl)

json_file4 <- "C:/Documents/R-files/Synth-2/kendrick.json"
json_fileF <- "C:/Documents/R-files/Synth-2/flying.json"
json_fileH <- "C:/Documents/R-files/Synth-2/haywyre.json"

json_datak <- fromJSON(readLines(json_file4), flatten=TRUE)
json_flying <- fromJSON(readLines(json_fileF), flatten=TRUE)
json_h <- fromJSON(readLines(json_fileH), flatten=TRUE)

klinks <- json_datak$links
knodes <- json_datak$nodes

flying_nodes <- json_flying$nodes
flying_links <- json_flying$links

h_links <- json_h$links
h_nodes <- json_h$nodes

Networkdata_k <- data.frame(klinks$source, klinks$target)
Networkdata_h <- data.frame(h_links$source, h_links$target)
Networkdata_f <- data.frame(flying_links$source, flying_links$target)


simpleNetwork(Networkdata_k, linkDistance = 75, zoom =T)
simpleNetwork(Networkdata_f, linkDistance = 75, zoom = T)
simpleNetwork(Networkdata_h, linkDistance = 75, zoom =T)


#Attempt at first force network

write.csv(knodes, file="knodes.csv") 

knodes_csv <- read.csv("knodes.csv")
knodes <- data.frame(knodes_csv)

kendrick <-forceNetwork(Links = klinks, Nodes = knodes,
               Source = "source", Target = "target",
              NodeID = "name", Group = "X.1",
               opacity = 0.9, bounded=T, zoom=T, colourScale = JS("d3.scaleOrdinal(d3.schemeCategory20);"))

htmltools::html_print(kendrick, viewer = utils::browseURL)

#Example of Force Network that works for some reason. 

URL <- "https://raw.githubusercontent.com/christophergandrud/d3Network/master/JSONdata/miserables.json"
MisJson <- getURL(URL, ssl.verifypeer = FALSE)


MisLinks <- JSONtoDF(jsonStr = MisJson, array = "links")
MisNodes <- JSONtoDF(jsonStr = MisJson, array = "nodes")

forceNetwork(Links = MisLinks, Nodes = MisNodes,
             Source = "source", Target = "target",
             NodeID = "name", Group = "group",
             opacity = 1, bounded=T, zoom=TRUE, colourScale = JS("d3.scaleOrdinal(d3.schemeCategory20);"))
