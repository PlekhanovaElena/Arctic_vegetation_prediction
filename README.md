# Arctic vegetation prediction and refugia analysis
Predicting how Actic vegetation will look in 2050 based on CAVM and CMIP6 climate data based on Pearson et. al. (2013) methodology.


### Data
Before running the code, please download the 

* CAVM rasterfile

https://data.mendeley.com/datasets/c4xj5rv6kv/1

* Substrate CAVM shapefile

https://arcticatlas.geobotany.org/catalog/dataset/circumpolar-arctic-substrate-chemistry

* 19 bioclimatic variables for the 3 climate models (EC-Earth3-Veg, IPSL-CM6A-LR, MRI-ESM2-0) and SSPs 126 and 585 scenarios from 2041 to 2060 on 30sec resolution
https://www.worldclim.org/data/cmip6/cmip6_clim30s.html#2041-2060

* Final predictions and data for the data analysis part
---link to the data repository---


### Code
The code has the following structure

1. Preparing predictors

    1.0 Cropping bioclimate variables to the Arctic extent - above 60 latitude

    1.1a Masking bioclimate variables with CAVM

    1.1b Masking bioclimate variables with CAVM leaving 100 km buffer with trees

    1.2 Stacking 19 bioclimate variables with CAVM and converting the raster to the dataframe

    1.3 Process substrate - converting to 1 and 0 for acidic and non-acidic soils and expanding to 100 km buffer, assigning random acidity there

    1.4 Preparing the vegetation file with trees - adding GLC2000 tree classes to 100km buffer of CAVM

    1.5 Combining substrate, bioclimatic variables and vegetation data in the final dataset for RF classification and prediction 

2. Classification using Random Forest

    2a Training RF on substrate and bioclimatic variables to classify CAVM vegetation 
    
    2b The same on the larger area with 100km buffer with trees

3. Prediction using Random Forest

    3a making prediction for 6 datasets (3 climate models, 2 emission scenarios)
    
    3b prediction for CAVM area only - which we use as an input in restricted scenarios
    
 4. Restricted tree dispersal scenarios
 
    4 combining predictions made in 3a and 3b for restricted tree scenarios (5 km and 20 km disperal).
    
