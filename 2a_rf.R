library(randomForest)
library(tictoc)
library(ranger)

tic()
#dt = read.csv("~/scratch/predictors_full/pred_table_with_trees.csv")
dt = read.csv("~/scratch/predictors_full/pred_table.csv")
toc()
dt = dt[,-1]
dt$cavm_to_bio_qgis_resampled = as.factor(dt$cavm_to_bio_qgis_resampled)


tic()
rf <- ranger(x = dt[,3:(ncol(dt) - 1)], 
             y = dt$cavm_to_bio_qgis_resampled, max.depth = 25, 
             ntree=1000)
toc() #41 min

save(rf,file = "~/scratch/rf_1000_ph10_d25_full.RData")



