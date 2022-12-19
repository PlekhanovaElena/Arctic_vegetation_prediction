library(raster)
library(tictoc)
par(mar = c(0.1, 0.1, 0.1, 0.5))

#pr = stack("~/scratch/climate_now/bio19_60_cropped.tif")



#rcavm = raster("~/scratch/cavm/cavm_to_bio_qgis_resampled.tif")
rcavm = raster("~/scratch/cavm/with_trees/cavm_with_trees_bio_qgis_resampled.tif")
msk = rcavm/rcavm

for (modname in c("e3v_585")) {
  print(modname)
  #dir.create(paste0("~/scratch/future/masked_trees_", modname))
  pr = stack(paste0("~/scratch/future/cropped/", modname, ".tif"))
  for (i in c(1:19)) {
    bio1 = pr[[i]]
    tic()
    pr1 = mask(bio1, msk)
    writeRaster(pr1, paste0("~/scratch/future/masked_trees_", modname,"/bio", i, ".tif"), 
                overwrite = T)
    # _with_trees
    toc() 
  }
}



plot(pr1)

toc() 