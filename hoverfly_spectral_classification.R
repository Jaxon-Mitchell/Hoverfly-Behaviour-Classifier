library("tidyverse")
library("gridExtra")
library("ggplot2")

dorsalData <- read_csv('/home/birkwin/documents/data/dorsalNoFly.csv',show_col_types = FALSE)
head(dorsalData, 5)


# Kmeans Application
set.seed(1748)

## Run Kmeans algorithm with 3 clusters
km <- kmeans(data, 3) 


## Retrieve and store cluster assignments
kmeans_clusters <- km$cluster
kmeans_results <- cbind(data, cluster = as.factor(kmeans_clusters))
head(kmeans_results)

# Spectral Clustering

## Create Similarity matrix of Euclidean distance between points
S <- as.matrix(dist(data))


## Create Degree matrix
D <- matrix(0, nrow=nrow(data), ncol = nrow(data)) # empty nxn matrix

for (i in 1:nrow(data)) {
  
  # Find top 10 nearest neighbors using Euclidean distance
  index <- order(S[i,])[2:11]
  
  # Assign value to neighbors
  D[i,][index] <- 1 
}

# find mutual neighbors
D = D + t(D) 
D[ D == 2 ] = 1

# find degrees of vertices
degrees = colSums(D) 
n = nrow(D)


## Compute Laplacian matrix
# Since k > 2 clusters (3), we normalize the Laplacian matrix:
laplacian = ( diag(n) - diag(degrees^(-1/2)) %*% D %*% diag(degrees^(-1/2)) )


## Compute eigenvectors
eigenvectors = eigen(laplacian, symmetric = TRUE)
n = nrow(laplacian)
eigenvectors = eigenvectors$vectors[,(n - 2):(n - 1)]


set.seed(1748)
## Run Kmeans on eigenvectors
sc = kmeans(eigenvectors, 3)


## Pull clustering results
sc_results = cbind(data, cluster = as.factor(sc$cluster))
head(sc_results)

# Kmeans plot
kmeans_plot = ggplot(data = kmeans_results, aes(x=x, y=y, color = cluster)) + 
  geom_point() + 
  scale_color_manual(values = c('1' = "violetred2",
                                '2' ="darkorchid2",
                                '3' ="darkolivegreen2")) +
  ggtitle("K-Means Clustering") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        plot.title = element_text(hjust = 0.5), legend.position="bottom")

# Spectral Clustering plot
sc_plot = ggplot(data = sc_results, aes(x=x, y=y, color = cluster)) + 
  geom_point() + 
  scale_color_manual(values = c('1' = "violetred2",
                                '2' ="darkorchid2",
                                '3' ="darkolivegreen2")) +
  ggtitle("Spectral Clustering") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        plot.title = element_text(hjust = 0.5), legend.position="bottom")

# Arrange plots
grid.arrange(kmeans_plot, sc_plot, nrow=1)