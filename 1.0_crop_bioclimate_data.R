library(terra)
library(tictoc)


fls = list.files("~/scratch/future/", full.names = T)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_EC-Earth3-Veg_ssp126_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/e3v_126.tif")

rm(prunc, pr)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_EC-Earth3-Veg_ssp585_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/e3v_585.tif", overwrite = T)

rm(prunc, pr)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_IPSL-CM6A-LR_ssp126_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/ipsl_126.tif")

rm(prunc, pr)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_IPSL-CM6A-LR_ssp585_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/ipsl_585.tif")


rm(prunc, pr)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_MRI-ESM2-0_ssp126_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/mri_126.tif")

rm(prunc, pr)
prunc = rast("~/scratch/future/wc2.1_30s_bioc_MRI-ESM2-0_ssp585_2041-2060.tif")
pr = crop(prunc, ext(-180, 180, 60, 90))
writeRaster(pr, "~/scratch/future/cropped/mri_585.tif")