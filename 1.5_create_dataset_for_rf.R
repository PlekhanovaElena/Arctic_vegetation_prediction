library(terra)
library(tictoc)

#
sb_pr = rast("~/scratch/substrate/subst_with_trees_10_proj_to_bio_resampled.tif")
sb_pr[sb_pr > 3] = 3
#
for (modname in c("e3v_126", "e3v_585","ipsl_126","ipsl_585", "mri_126","mri_585")) {
  print(modname)
  #pr = rast(list.files("~/scratch/climate_now/masked/", full.names = T))
  tic()
  pr = rast(list.files(paste0("~/scratch/future/masked_trees_",modname,"/"), full.names = T))
  s = c(sb_pr, pr) # stack substrate variable with cliamte variables
  rm(pr)
  dt = as.data.frame(s, xy = T) #3min
  dt = dt[complete.cases(dt),]
  nrow(dt)
  write.csv(dt, paste0("~/scratch/predictors_climate/",modname,"_with_trees.csv"))
  rm(dt,s)
  toc()
  gc()
}