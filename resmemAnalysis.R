#package install
if(!require(devtools)) install.packages("devtools")
devtools::install_github("kassambara/ggpubr")
library(tidyverse)
library(ggpubr)
library(devtools)
install_github("vqv/ggbiplot")
library(plyr)
library(dplyr)
library(ggbiplot)
library(ggplot2)

#merging two dataset
colnames(ImageRatings)
names(ImageRatings)[names(ImageRatings) == "originalName"] <- "image_name"
colnames(ImageRatings)
imageData <- merge(ImageRatings, resmem, by = "image_name")
summary(imageData)
summary(imageData$Natural)
natureSet <- imageData[imageData$Natural > median(imageData$Natural),]
urbanSet <- imageData[imageData$Natural < median(imageData$Natural),]

#correlation between naturalness and memorability
reg <- cor.test(imageData$resmem_pred, imageData$Natural, method = "pearson")
reg
ggscatter(imageData, x = "Natural", y = "resmem_pred", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Naturalness Rating", ylab = "Memorability Score",
          xlim = c(1,7), ylim = c(0.4, 1.0),
          color = "blue", cex = 0.5)
mean(natureSet$resmem_pred)
mean(urbanSet$resmem_pred)

#PCA of low-level features
str(imageData)
#PCA of nature images
llf_natural <- prcomp(natureSet[, -c(1, 14:18)], center = TRUE, scale. = TRUE)
ggbiplot(llf_natural, varname.adjust = 4,varname.size = 4)
nature.var <- llf_natural$sdev^2
nature.var.per <- round(nature.var/sum(nature.var)*100,1)
barplot(nature.var.per, main = "PCA Nature Scree plot", xlab = "Principal component",
        ylab = "Percentage variation")
nature.ls <-llf_natural$rotation[,1]
nature_score <- abs(nature.ls)
nature_score_ranked <- sort(nature_score, decreasing = TRUE)
nature_score_ranked
llf_natural$rotation[,2]

#PCA of urban images
llf_urban <- prcomp(urbanSet[, -c(1, 14:18)], center = TRUE, scale. = TRUE)
ggbiplot(llf_urban, varname.adjust = 4,varname.size = 4)
urban.var <- llf_urban$sdev^2
urban.var.per <- round(urban.var/sum(urban.var)*100,1)
barplot(urban.var.per, main = "PCA Urban Scree plot", xlab = "Principal component",
        ylab = "Percentage variation")
urban.ls <-llf_urban$rotation[,1]
urban_score <- abs(urban.ls)
urban_score_ranked <- sort(urban_score, decreasing = TRUE)
urban_score_ranked
llf_urban$rotation[,2]

#PCA of all
llf_all <- prcomp(imageData[, -c(1, 14:18)], center = TRUE, scale. = TRUE)
ggbiplot(llf_all, ellipse = TRUE, var.scale = 1, varname.adjust = 4, varname.size = 4, 
         groups = ifelse(imageData$Natural >4.805, "nature", "urban"))
ggbiplot(llf_all, ellipse = TRUE, var.scale = 1, varname.adjust = 4, varname.size = 4, 
         groups = ifelse(imageData$resmem_pred >0.59, "memorable", "not"))
all.var <- llf_all$sdev^2
all.var.per <- round(all.var/sum(all.var)*100,1)
barplot(all.var.per, main = "PCA All Scree plot", xlab = "Principal component",
        ylab = "Percentage variation")
all.ls <-llf_all$rotation[,1]
all_score <- abs(all.ls)
all_score_ranked <- sort(all_score, decreasing = TRUE)
all_score_ranked
llf_all$rotation[,1]

# 1/18
# Euclidean Distance Matrix
llf.data <- imageData[, c(1:13)]
llf.data <- na.omit(llf.data)
summary(llf.data)
ed.matrix <- dist(llf.data[, c(2:13)], method = "euclidean", diag = FALSE, upper = FALSE)         
head(ed.matrix)
summary(ed.matrix)
ed.matrix[1029]
test.set <- imageData[c(1,2,3), c(2:13)]
View(test.set)
dist(test.set)
dim(test.set)
hist(ed.matrix)
#Nature set
llf.nature <- natureSet[, c(2:13)]
llf.urban <- urbanSet[, c(2:13)]
nature.matrix <- dist(llf.nature, method = "euclidean", diag = FALSE, upper = FALSE)
head(nature.matrix)
summary(nature.matrix)

#Plotting histogram
hist(nature.matrix, col=rgb(0,0,1,1/4), xlim=c(0,1.5), ylim = c(0, 30000), 
     main = "ED Distribution of nature vs urban images")
urban.matrix <- dist(llf.urban, method = "euclidean", diag = FALSE, upper = FALSE)
summary(urban.matrix)
hist(urban.matrix, col=rgb(1,0,0,1/4), xlim=c(0,1.5),ylim = c(0, 30000), add=T)
par(xpd = F)
abline(v = mean(nature.matrix), col = "red", lwd = 3)
abline(v = mean(urban.matrix), col = "orange", lwd = 3)
text(x = 1.25, y = 25000,
     paste("Nature mean =", mean(nature.matrix)),
     col = "red",
     cex = 1)
text(x = 0.65, y = 27000,
     paste("Urban mean =", mean(urban.matrix)),
     col = "orange",
     cex = 1)


length(urban.matrix)
t.test(nature.matrix, urban.matrix)

#Scaled Set
scaled_llf_nature <- scale(llf.nature)
scaled_llf_urban <- scale(llf.urban)
scaled.nature.matrix <- dist(scaled_llf_nature, method = "euclidean", diag = FALSE, upper = FALSE)
scaled.urban.matrix <- dist(scaled_llf_urban, method = "euclidean", diag = FALSE, upper = FALSE)
hist(scaled.nature.matrix, col=rgb(0,0,1,1/4), 
     main = "histogram of Scaled nature vs urban matrix")
hist(scaled.urban.matrix, col=rgb(1,0,0,1/4), add=T)


#1/1
reg <- lm(imageData$resmem_pred ~ scale(imageData$Natural)+scale(imageData$NSED))
summary(reg)
library(lme4)
reg2 <- lmer(imageData$resmem_pred ~ scale(imageData$Natural)+scale(imageData$NSED) + 1|(imageData$image_name))
summary(reg)
