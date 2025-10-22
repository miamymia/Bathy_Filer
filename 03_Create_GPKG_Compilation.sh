# Merge all coverage.gpkg in dst dir into one coverage gpkg compilation
# Usage: bash 03_Create_GPKG_Compilation platform file_list
# platform: one of MERIAN, METEOR, SONNE; file_list: path/to/platform_gpkg_list
# Note: file list needs to contains absolute paths to gpks files! Create lists with 00_Create_productLists.ipynb

platform=$1
ifi=$2
IFS=$'\n'       
set -f    
for f in $(cat < "$ifi"); do
    ogrmerge -f GPKG -o "${platform}_GEOMAR_TID_EPSG3395.gpkg" "$f" -src_geom_type MULTIPOLYGON -overwrite_ds
done
