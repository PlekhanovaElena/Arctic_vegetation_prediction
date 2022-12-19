# Arctic vegetation prediction and refugia analysis
Predicting how Actic vegetation will look in 2050 based on CAVM and CMIP6 climate data based on Pearson et. al. (2013) methodology.

The code has the following structure

1. Preparing predictors

    1.0 Cropping bioclimate variables to the Arctic extent - above 60 latitude

  1.1a Masking bioclimate variables with CAVM

  1.1b Masking bioclimate variables with CAVM leaving 100 km buffer with trees

  1.2 Stacking 19 bioclimate variables with CAVM and converting the raster to the dataframe

  1.3 Process substrate - converting to 1 and 0 for acidic and non-acidic soils and expanding to 100 km buffer, assigning random acidity there

  1.4 Prepare the vegetation file with trees - 

2. Classification using Random Forest

3.
