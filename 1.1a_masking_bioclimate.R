library(raster)
library(tictoc)
par(mar = c(0.1, 0.1, 0.1, 0.5))

#pr = stack("~/scratch/climate_now/bio19_60_cropped.tif")


rcavm = raster("~/scratch/cavm/cavm_to_bio_qgis_resampled.tif")
rcavm_t = raster("~/scratch/cavm/with_trees/cavm_with_trees_bio_qgis_resampled.tif")
msk = rcavm/rcavm
msk[is.na(rcavm_t)] = NA
#"e3v_126","e3v_585","ipsl_126",
for (modname in c("ipsl_585","mri_126","mri_585")) {
  print(modname)
  dir.create(paste0("~/scratch/future/masked_", modname))
  pr = stack(paste0("~/scratch/future/cropped/", modname, ".tif"))
  for (i in c(1:19)) {
    bio1 = pr[[i]]
    tic()
    pr1 = mask(bio1, msk)
    writeRaster(pr1, paste0("~/scratch/future/masked_", modname,"/bio", i, ".tif"), 
                overwrite = T)
    # _with_trees
    toc() 
  }
}

num_cor = data.frame(c(1:19), names(pr))
colnames(num_cor) = c("orig", "messed")
num_cor$messed = as.numeric(num_cor$messed)
write.csv(num_cor, "~/scratch/number_correction.csv", row.names = F)

pr = rast("~/scratch/climate_now/bio19_60_cropped.tif")
for (i in c(1:19)) {
  bio1 = pr[[i]]
  tic()
  pr1 = mask(bio1, msk)
  writeRaster(pr1, paste0("~/scratch/climate_now/masked/bio", i, ".tif"), 
              overwrite = T)
  # _with_trees
  toc() 
}

plot(pr1)

toc() 