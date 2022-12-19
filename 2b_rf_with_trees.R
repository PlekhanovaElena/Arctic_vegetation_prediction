library(randomForest)
library(tictoc)
library(ranger)


tic()
dt = read.csv("~/scratch/predictors_full/pred_table_with_trees.csv")
toc()

dt = dt[,-1]
dt$cavm_with_trees_bio_qgis_resampled = as.factor(dt$cavm_with_trees_bio_qgis_resampled)


tic()
rf <- ranger(x = dt[,3:(ncol(dt) - 1)], 
             y = dt$cavm_with_trees_bio_qgis_resampled, max.depth = 25, 
             ntree=1000)
toc() #41 min

save(rf,file = "~/scratch/rf_1000_with_trees_ph10_d25_full.RData")

