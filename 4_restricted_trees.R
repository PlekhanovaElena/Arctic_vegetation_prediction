library(terra)
library(tictoc)

cvm = vect("~/scratch/cavm/cavm_treeline_border/")

for (dist in c(5,20)) {
  tb = vect(paste0("~/scratch/treeline/",dist,"_km/"))
  
  for (modname in c("e3v_126","e3v_585","ipsl_126", "ipsl_585")) {
    print(modname)
    tic()
    wo_trees = rast(paste0("~/scratch/output/cavm_only/rpred_",modname,".tif"))
    # p - without trees
    with_trees = rast(paste0("~/scratch/output/with_trees/rpred_",modname,"_with_trees.tif"))
    crs(tb) = crs(wo_trees)
    crs(cvm) = crs(wo_trees)
    below_t = mask(with_trees, tb)
    above_t = with_trees
    above_t[!is.na(below_t)] = NA
    above_t[above_t == 1] = wo_trees[above_t == 1]
    above_t[above_t == 2] = wo_trees[above_t == 2]
    print("middle")
    below_t[is.na(below_t)] = above_t[is.na(below_t)]
    cb = mask(below_t, cvm)
    writeRaster(cb, 
                paste0("~/scratch/output_upd/restricted/rpred_", dist, "km_",modname, ".tif"), 
                overwrite = T)
    toc()
  }
}


#,"ipsl_585","mri_126","mri_585"
modnames = c("e3v_126","e3v_585","ipsl_126","ipsl_585","mri_126","mri_585")
with_trees = rast(paste0("~/scratch/output/with_trees/rpred_",modnames,"_with_trees.tif"))


cp = mask(with_trees,cvm)
plot(cp)

for (i in c(1:6)) {
  writeRaster(cp[[i]], paste0("~/scratch/output_upd/unrestricted/rpred_",modnames[i],".tif"), 
              overwrite = T)
}

r = rast("~/scratch/output_upd/restricted/rpred_20km_ipsl_585.tif")
plot(r, col = rainbow(10))

