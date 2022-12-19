library(raster)
library(tictoc)
require(sf)
require(rgeos)
library(rgdal)
dev.off()

# reading substrate
sr = raster("~/scratch/substrate/Ph_CAVM_raster.tif")

#reading CAVM with 100km tree buffer
trs = raster("~/scratch/cavm/with_trees/cavm_with_trees_v1.tif")
trs[trs > 2] = NA
trs500 = disaggregate(trs, fact=2)
me = extend(sr,trs500)
m = me
mr = resample(sr, trs500)
extent(m) == extent(trs500)
m = mr
m[!is.na(trs500)] = 0
writeRaster(m, "~/scratch/substrate/subst_with_trees_as_0.tif", overwrite= T)

library(terra)

# Prepare substrate according to Pearson et al. 2013 instructions:
# Making it random above or below certain pH threshold
sb_all = raster("~/scratch/substrate/subst_with_trees_as_0.tif")
sb_all[sb_all > 2] = 3
nv = sb_all[sb_all == 0]
random_sb = sample(c(2,3), length(nv), replace = T)
sb_all[sb_all == 0] = random_sb
writeRaster(sb_all, "~/scratch/substrate/subst_with_trees_rand_10.tif")

sb_all = rast("~/scratch/substrate/subst_with_trees_rand_10.tif")
pr =  rast("~/scratch/climate_now/bio19_60_cropped.tif")
bio1 = pr[[1]]
rm(pr)
sb_pr = project(sb_all, bio1, method = "near")
writeRaster(sb_pr, "~/scratch/substrate/subst_with_trees_10_proj_to_bio.tif")

expr = stack( list.files("~/scratch/climate_now/masked/"))
bio1 = expr[[1]]
rm(expr)

rsr = projectRaster(sr, bio1, method = "ngb") # 2min and 11GB in the process
plot(rsr)
writeRaster(rsr, "~/scratch/substrate/substrate_proj_to_bio.tif", overwrite = T)

sb = raster("~/scratch/substrate/substrate_proj_to_bio.tif")
pr = stack(list.files("~/scratch/climate_now/masked/", full.names = T))
rcavm = raster("~/scratch/cavm/cavm_proj_to_bio.tif")
# Please, make sure that teh "Bio" layers come in the right order!

# Creating a teble of predictors for current climate
s = stack(sb, pr, rcavm)
rm(pr,rcavm,sb)
tic()
dt = as.data.frame(s, xy = T) #3min
toc()
dt = dt[complete.cases(dt),]
write.csv(dt, "~/scratch/predictors_full/pred_table.csv")
