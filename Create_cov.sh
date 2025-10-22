# Usage: ./create_cov.sh ifi
# ifi/ofi: input file name; input: bathymetry grid (geotiff); output: coverage geopackage;
# Calculates zero grid from bathymetry and polygonises zero grid

ifi=$1
ofi_zero="${ifi%%.*}_zero.tif"
ofi_gpkg="${ifi%%.*}_Area.gpkg"
echo Reading input file: $ifi
echo Generating zero grid: $ofi_zero
gdal_calc.py -A $ifi --outfile=$ofi_zero --co="COMPRESS=DEFLATE" --co="TILED=YES" --calc="(A*0)+1"
echo Saving coverage to $ofi_gpkg
gdal_polygonize.py $ofi_zero $ofi_gpkg 
