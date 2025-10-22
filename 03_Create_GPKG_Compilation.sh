# Merge all coverage.gpkg in dst dir into one coverage gpkg compilation
# Usage: bash Create_GPKG_Compilation platform dst_path
# platform: one of MERIAN, METEOR, SONNE; dst_path: directory containing all coverage geopackages

platform=$1
dst=$2
cd $dst
echo $dst
for zf in *; do
    ogrmerge -f GPKG -o "${platform}_GEOMAR_TID_EPSG3395.gpkg" "*_Coverage.gpkg" -src_geom_type MULTIPOLYGON -overwrite_ds
done