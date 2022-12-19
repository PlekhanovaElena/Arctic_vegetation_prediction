library(raster)
library(tictoc)
par(mar = c(0.1, 0.1, 0.1, 0.5))

# Run crop bioclimate script

trs = raster("~/scratch/cavm/with_trees/cavm_with_trees_v1.tif")
pr =  stack("~/scratch/climate_now/bio19_60_cropped.tif")
bio1 = pr[[1]]
rm(pr)
trs_pr = projectRaster(trs, bio1, method = "ngb")
writeRaster(trs_pr, "~/scratch/cavm/with_trees/cavm_with_trees_proj_to_bio.tif")
plot(trs_pr)

cavm = raster("~/scratch/cavm/raster_cavm_v1.tif")
cavm[cavm > 44] = NA
cavm = trim(cavm, padding = 100) # would need to do it with 100km buffer
plot(cavm)

fls = list.files("~/scratch/climate_now/raw/", full.names = T)
prunc = rast(fls)
names(prunc) = substr(names(prunc), 15, 17)
pr = crop(prunc, ext(-180, 180, 60, 90))
names(pr) = names(prunc)
writeRaster(pr, "~/scratch/climate_now/bio19_60_cropped.tif", overwrite = T)

# Reproject CAVM to predictors space
#bio1 = pr[[1]]
#rcavm = projectRaster(cavm, bio1, method = "ngb") # 2min and 11GB in the process
#tr = read.csv("~/scratch/cavm/tr_codes_to_veg_types.csv")
#rcavm[rcavm <= 5] = NA
#rcavm[rcavm >= 41] = NA
#writeRaster(rcavm, "~/scratch/cavm/cavm_proj_to_bio.tif", overwrite = T)

# run Masking bioclimate script - with trees and without trees

pr = stack(list.files("~/scratch/climate_now/masked/", full.names = T))
rcavm = raster("~/scratch/cavm/cavm_proj_to_bio.tif")

s = stack(pr, rcavm)
tic()
dt = as.data.frame(s, xy = T) #3min
toc()
dt = dt[complete.cases(dt),]
write.csv(dt, "~/scratch/climate_now/clpred_table.csv", 
              quote = F, row.names = F)




