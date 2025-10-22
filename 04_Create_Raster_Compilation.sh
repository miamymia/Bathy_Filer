# Merge all bathy grids in file list into one grid compilation
# file list created with Create_productLists.ipynb
# Usage: bash Create_GPKG_Compilation platform 
# platform: one of MERIAN, METEOR, SONNE
# blueheart must be mounted!

%%bash
platform=$1
path="/Volumes/bathymetry/_blueheart/00_${platform}/${platform}_GEOMAR/"
echo $path
cd $path
# one band
gdalbuildvrt -input_file_list "${platform}_grid_list.txt" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.vrt" -overwrite
gdal_translate -of GTiff -co "COMPRESS=DEFLATE" -co "TILED=YES" -co "BIGTIFF=YES" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.vrt" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.tif"