library('corrr')
library('ggcorrplot')
library('FactoMineR')

hoverfly_data <- read.csv("classification_data.csv")
# Show the data and its variables
str(hoverfly_data)

# Check for non-existant variables
colSums(is.na(hoverfly_data))

# Remove the names from the data set just to keep numericals
numerical_data <- hoverfly_data[,2:10]
# View pure numerical data
head(numerical_data)

# Scale the data to remove mean and standard deviation
data_normalized <- scale(numerical_data)
head(data_normalized)

# Compute the principle component analysis and display the results
data.pca <- princomp(data_normalized)
summary(data.pca)

# How much do all the original variables relate to the components
data.pca$loadings[, 1:2]

# Visualize importance of each component
fviz_eig(data.pca, addlabels = TRUE)

# Graph of the variables
fviz_pca_var(data.pca, col.var = "black")

# Show importance of individual features relating to components 
fviz_cos2(data.pca, choice = "var", axes = 1:2)

# Show importance of features on a 2d grids
fviz_pca_var(data.pca, col.var = "cos2",
             gradient.cols = c("black", "orange", "green"),
             repel = TRUE)



