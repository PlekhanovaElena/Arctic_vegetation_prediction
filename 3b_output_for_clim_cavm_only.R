library(tictoc)
library(ranger)
library(terra)
load("~/scratch/rf_1000_ph10_d25_full.RData")

for (modname in c("e3v_585", "ipsl_126","ipsl_585"))
{
  print(modname)
  tic()
  #make a table of x,y and predictions
  clp = read.csv(paste0("~/scratch/predictors_climate/",modname,".csv"))
  clp = clp[,-1] #?
  colnames(clp)[4:22] = paste0("bio", c(1:19))
  print("start_pred")
  y_pred = predict(rf, clp[,3:ncol(clp)])
  print("finish_pred")
  rast_pred = as.data.frame(cbind(clp[,c("x", "y")], y_pred))
  #Remove rf, dt
  rm(clp, y_pred)
  # takes 10 min
  write.csv(rast_pred, paste0("~/scratch/output/cavm_only/",modname,"_rast_pred.csv"), row.names = F)
  toc()
  gc()
}

#"ipsl_126","ipsl_585"

rcavm = rast("~/scratch/cavm/cavm_to_bio_qgis_resampled.tif")
rcavm[rcavm > 35] = NA
rcavm[rcavm < 6] = NA
cavm = rast("~/scratch/cavm/raster_cavm_trimmed.tif")
dc = as.data.frame(rcavm, xy = T)

for (modname in c("e3v_126", "e3v_585", "ipsl_126","ipsl_585"))
{
  print(modname)
  tic()
  rast_pred = read.csv(paste0("~/scratch/output/cavm_only/",modname,"_rast_pred.csv"))
  rast_pred$prediction = as.numeric(as.character(rast_pred$prediction))
  print("made prediction")
  #make regular raster from the predicted data
  rast_pred_full = merge(dc, rast_pred, by = c('x', 'y'), all.x = T)
  rast_pred_full = rast_pred_full[,-3]
  colnames(rast_pred_full)[3] = "z"
  #Make raster from it
  rpred = rast(rast_pred_full, type="xyz")
  crs(rpred) = crs(rcavm)
  writeRaster(rpred, paste0("~/scratch/output/cavm_only/rpred_proj_bio_",modname,".tif"), overwrite = T)
  print("made raster")
  
  #Project it to cavm 
  pred = project(rpred, cavm, method = "near")
  #Save it
  writeRaster(pred, paste0("~/scratch/output/cavm_only/rpred_",modname,".tif"), overwrite = T)
  print("projected raster")
  toc()
  gc()
}




o_pred = rf$predictions
o_pred = as.numeric(as.character(o_pred))
hist(o_pred)
for (i in unique(o_pred)) {
  print(i)
  rc = sum(o_pred == i)/sum(dc$cavm_with_trees_bio_qgis_resampled == i)
  print(rc)
}