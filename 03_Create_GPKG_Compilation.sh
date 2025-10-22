# Merge all coverage.gpkg in dst dir into one coverage gpkg compilation
# Copies single gpkg to local disk first
# Usage: bash 03_Create_GPKG_Compilation platform file_list local
# platform: one of MERIAN, METEOR, SONNE; file_list: path/to/platform_gpkg_list; local: path/to/local_folder
# Note: file list needs to contains absolute paths to gpks files (usually located in _cov dirs on blueheart)! Create lists with 00_Create_productLists.ipynb

platform=$1
ifi=$2
local=$3
cd $local

IFS=$'\n'       
set -f    
for zf in $(cat < "$ifi"); do
  mv "$zf" "$local"
done

ogrmerge -f GPKG -o "${platform}_GEOMAR_TID_EPSG3395.gpkg" *_Coverage.gpkg -src_geom_type MULTIPOLYGON -overwrite_ds
