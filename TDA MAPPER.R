library(TDAmapper)
library(igraph)
## Import Data

#Dat  <- read.csv("D:/Dropbox/Graduate Classes/UIOWA - 2018 Spring/TDA/Project/Data/ELEVATIONApr_08_20_16_34_2018_Scaled.csv")
#Dat  <- read.csv("D:/Dropbox/Graduate Classes/UIOWA - 2018 Spring/TDA/Project/Data/STREAMFLOWApr_08_20_16_34_2018_Scaled.csv")
#Dat  <- read.csv("D:/Dropbox/Graduate Classes/UIOWA - 2018 Spring/TDA/Project/Data/ELEVATIONApr_12_10_35_16_2018_Scaled.csv")
#Dat  <- read.csv("D:/Dropbox/Graduate Classes/UIOWA - 2018 Spring/TDA/Project/Data/STREAMFLOWApr_12_10_35_16_2018_Scaled.csv")

#nums <- sapply(Dat, is.numeric)
fdata<- Dat[,-1]#Dat[ , nums]



## Functions
Find_Max_CCF<- function(a,b)
{
  d <- ccf(a, b, plot = FALSE)
  cor = d$acf[,,1]
  lag = d$lag[,,1]
  res = data.frame(cor,lag)
  res_max = res[which.max(res$cor),]
  return(res_max)
} 

cluster_cutoff_at_first_empty_binNEW <-
  function(heights, diam, num_bins_when_clustering) {
    # if there are only two points (one height value), then we have a single cluster
    if (length(heights) == 1) {
      if (heights == diam) {
        cutoff <- Inf
        return(cutoff)
      }
    }
    
    bin_breaks <- seq(
      from = min(heights),
      to = diam,
      by = (diam - min(heights)) / num_bins_when_clustering
    )
    if (length(bin_breaks) == 1) {
      bin_breaks <- 1
    }
    
    myhist <-
      hist(c(heights, diam), breaks = bin_breaks, plot = FALSE)
    z <- (myhist$counts == 0)
    if (sum(z) == 0) {
      cutoff <- Inf
      return(cutoff)
    } else {
      #  which returns the indices of the logical vector (z == TRUE), min gives the smallest index
      cutoff <- myhist$mids[min(which(z == TRUE))]
      return(cutoff)
    }
  }

mapper1Dnew3 <- function(distance_matrix = dist(data.frame(x = 2 * cos(0.5 * (1:100)), y = sin(1:100))),
                         filter_values = 2 * cos(0.5 * (1:100)),
                         num_intervals = 10,
                         percent_overlap = 50,
                         hclustering = "single",
                         num_bins_when_clustering = 10) {
  # initialize variables
  vertex_index <- 0
  
  # indexed from 1 to the number of vertices
  level_of_vertex <- c()
  points_in_vertex <- list()
  # filter_values_in_vertex <- list() # just use filter_values[points_in_vertex[[i]]]
  
  # indexed from 1 to the number of levels
  points_in_level <- list()
  vertices_in_level <- list()
  # filter_values_in_level <- list() # just use filter_values[points_in_level[[i]]]
  
  filter_min <- min(filter_values)
  filter_max <- max(filter_values)
  interval_length <-
    (filter_max - filter_min) / (num_intervals - (num_intervals - 1) * percent_overlap /
                                   100)
  step_size <- interval_length * (1 - percent_overlap / 100)
  level <- 1
  # begin mapper main loop
  for (level in 1:num_intervals) {
    min_value_in_level <- filter_min + (level - 1) * step_size
    max_value_in_level <- min_value_in_level + interval_length
    # use & (not &&) for elementwise comparison
    # create a logical vector of indices
    points_in_level_logical <-
      (min_value_in_level <= filter_values) &
      (filter_values <= max_value_in_level)
    num_points_in_level <- sum(points_in_level_logical)
    points_in_level[[level]] <- which(points_in_level_logical == TRUE)
    
    if (num_points_in_level == 0) {
      print('Level set is empty')
      next
    }
    
    if (num_points_in_level == 1) {
      print('Level set has only one point')
      num_vertices_in_level <- 1
      cluster_indices_within_level <- c(1)
    }
    
    if (num_points_in_level > 1) {
      # use as.matrix() to put the distance matrix in square form,
      # and as.dist() to put it in vector form
      # This could probably use some optimization...
      level_distance_matrix <-
        as.dist(as.matrix(distance_matrix)[points_in_level_logical, points_in_level_logical])
      level_max_distance <- max(level_distance_matrix)
      # use R's hclust (provided by stats or fastcluster)
      # in place of Matlab's linkage function.
      level_hcluster_ouput <-
        hclust(level_distance_matrix, method = hclustering)
      heights <- level_hcluster_ouput$height
      cutoff <-
        cluster_cutoff_at_first_empty_binNEW(heights, level_max_distance, num_bins_when_clustering)
      
      # use as.vector() to get rid fo the names for the vector entries
      cluster_indices_within_level <-
        as.vector(cutree(level_hcluster_ouput, h = cutoff))
      num_vertices_in_level <- max(cluster_indices_within_level)
      
      # points_in_level[[level]] and cluster_indices_within_level have the same length.
      # heights has length 1 less than points_in_level[[level]] and cluster_indices_within_level
      # print(heights)
      # print(points_in_level[[level]])
      # print(cluster_indices_within_level)
    }
    
    vertices_in_level[[level]] <-
      vertex_index + (1:num_vertices_in_level)
    
    for (j in 1:num_vertices_in_level) {
      vertex_index <- vertex_index + 1
      
      # points_in_level_logical is a logical vector, so use which(points_in_level_logical==TRUE) to convert it to a numerical vector of indices
      #nodeset <- which(points_in_level_logical==TRUE)[cluster_indices_within_level == j]
      
      level_of_vertex[vertex_index] <- level
      points_in_vertex[[vertex_index]] <-
        which(points_in_level_logical == TRUE)[cluster_indices_within_level == j]
      #points_in_vertex[[vertex_index]] <- nodeset
      #filter_values_in_vertex[[vertex_index]] <- filter_values[nodeset]
      
    }
    
  } # end mapper main loop
  
  
  # Note: num_vertices = vertex index.
  # Create the adjacency matrix for the graph, starting with a matrix of zeros
  adja <- mat.or.vec(vertex_index, vertex_index)
  
  #  for (j in 2:length(vertices_in_level)) {
  for (j in 2:num_intervals) {
    # check that both level sets are nonemtpy
    if ((length(vertices_in_level[[j - 1]]) > 0) &
        (length(vertices_in_level[[j]]) > 0)) {
      for (v1 in vertices_in_level[[j - 1]]) {
        for (v2 in vertices_in_level[[j]]) {
          # return 1 if the intersection is nonempty
          adja[v1, v2] <- (length(intersect(
            points_in_vertex[[v1]],
            points_in_vertex[[v2]]
          )) > 0)
          adja[v2, v1] <- adja[v1, v2]
        }
      }
      
    }
  } # end constructing adjacency matrix
  
  
  mapperoutput <- list(
    adjacency = adja,
    num_vertices = vertex_index,
    level_of_vertex = level_of_vertex,
    points_in_vertex = points_in_vertex,
    #filter_values_in_vertex = filter_values_in_vertex,
    points_in_level = points_in_level,
    vertices_in_level = vertices_in_level
  )
  
  class(mapperoutput) <- "TDAmapper"
  
  
  return(mapperoutput)
}



## Create Distance and Filter
distmat=matrix(nrow=length(fdata[,1]), ncol=length(fdata[,1]))
for (i in 1:length(fdata[,1])){
  for (j in 1:length(fdata[,1])){
    a=Find_Max_CCF(fdata[,i],fdata[,j])
    distmat[i,j]=a[,1]
  }
}
distmat=1-distmat

k=20
sorta=t(apply(distmat,1,sort))
KNN=sorta[,k]

## Create the output

m2 <- mapper1Dnew3(
  distance_matrix = distmat,
  filter_values = KNN,
  num_intervals = 9,
  percent_overlap = 50,
  num_bins_when_clustering = 10)


vertexLabel <- sapply(m2$points_in_vertex,length)
vertexSize <- floor(50*(log(vertexLabel,4)+1))


colnames(m2$adjacency)<-vertexLabel

g <- graph_from_adjacency_matrix(m2$adjacency,
                                 add.colnames='label', 
                                 mode="undirected",
                                 weighted = TRUE)

plot(g,vertex.size=as.matrix(vertexSize),rescale = FALSE, ylim=c(-2,14),xlim=c(4,8),aps=0)


