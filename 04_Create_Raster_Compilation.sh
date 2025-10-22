# Merge all bathy grids in file list into one grid compilation
# Usage: bash 04_Create_Raster_Compilation platform 
# platform: one of MERIAN, METEOR, SONNE
# Note: file list needs to contains absolute paths to gpks files! Create lists with 00_Create_productLists.ipynb
# blueheart must be mounted!

%%bash
platform=$1
path="/Volumes/bathymetry/_blueheart/00_${platform}/${platform}_GEOMAR/"
echo $path
cd $path
# one band
gdalbuildvrt -input_file_list "${platform}_grid_list.txt" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.vrt" -overwrite
gdal_translate -of GTiff -co "COMPRESS=DEFLATE" -co "TILED=YES" -co "BIGTIFF=YES" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.vrt" "${platform}_GEOMAR_AllSoundings_DivRes_EPSG3395.tif"