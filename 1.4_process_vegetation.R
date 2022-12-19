library(raster)
library(tictoc)


pr = stack("~/scratch/climate_now/bio19_60_cropped.tif")
rcavm = raster("~/scratch/cavm/cavm_to_bio_qgis.tif")
#rcavm = raster("~/scratch/cavm/with_trees/cavm_with_trees_proj_to_bio.tif")
bio1 = pr[[1]]
rm(pr)
bcavm = resample(rcavm, bio1, method = "ngb")
writeRaster(bcavm, "~/scratch/cavm/cavm_to_bio_qgis_resampled.tif")

rcavm = raster("~/scratch/cavm/with_trees/cavm_with_trees_to_bio_qgis.tif")
bcavm = resample(rcavm, bio1, method = "ngb")
writeRaster(bcavm, "~/scratch/cavm/with_trees/cavm_with_trees_bio_qgis_resampled.tif")

#rcavm = raster("~/scratch/cavm/cavm_proj_to_bio.tif")
#gm = raster("~/scratch/glc2000/Tiff/glc2000_v1_1.tif")
#plot(gm)
#crs(gm) = crs(rcavm)
#gm = crop(gm, extent(-180, 180, 60, 90))

#writeRaster(gm, "~/scratch/glc2000/glc2000_cropped_60.tif")
tr = read.csv("~/scratch/cavm/tr_codes_to_veg_types.csv")
gm = raster("~/scratch/glc2000/glc2000_cropped_60.tif")
gm[gm<7] = 2
gm[gm == 9] = 1

writeRaster(gm, "~/scratch/glc2000/glc2000_cropped_60_12.tif", overwrite=TRUE)
plot(gm)
rm(rcavm)


gm = raster("~/scratch/glc2000/glc2000_cropped_60_12.tif")
cavm = raster("~/scratch/cavm/raster_cavm_v1.tif")
cavm[cavm == 99] = NA #remove non-arctic and water
cavm[cavm == 92] = NA #remove non-arctic and water
cavm = trim(cavm) # would need to do it with 100km buffer
plot(cavm)
tic()
pgm = projectRaster(gm, cavm, method = "ngb")
toc()
writeRaster(pgm,"~/scratch/glc2000/glc2000_projected_to_cavm_orig.tif", overwrite = T)
plot(pgm)

bc = readOGR("~/scratch/cavm/cavm_buf/")

mt = mask(pgm, bc)
tmt = trim(mt)
plot(tmt)
mc = mask(cavm, bc)
plot(mc)
mc[mc < 6] = NA # exclude barrens
mc[mc == 41] = NA # exclude wetlands
mc[mc == 42] = NA # exclude wetlands
mc[mc == 43] = NA # exclude wetlands

mt[mt > 2] = NA #exclude other classes than trees
plot(mt)

mc[mc == 99] = mt[mc == 99]
plot(mc)
mc[mc > 40] = NA
plot(mc, col = rainbow(10))

tmc = trim(mc)
plot(tmc, col = rainbow(13))
writeRaster(mc, "~/scratch/cavm/with_trees/cavm_with_trees_v1.tif")
writeRaster(tmc, "~/scratch/cavm/with_trees/cavm_with_trees_trimmed_v1.tif")
pgm
cavm

