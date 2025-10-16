## Prepare .csv
# Remove first line
CSV="accepted_selected.csv"
YXZ="accepted_selected.yxz"
XYZ="accepted_selected.xyz"
XYZ="/Users/mschumacher/Docs_Data/VS/GNB/sidescantools/georef_out/Navigation_StarfishLog_20240822_132111_ch0"


# remove first line
sed '1d' "${CSV}" > "${YXZ}"

# Switch 1st & 2nd column
# awk -F "," '{print $2, $1, $3}' "${YXZ}" > "${XYZ}"
awk 'BEGIN {FS=","; OFS=","} {print $2, $1, $3}' "${YXZ}" > "${XYZ}"

# If no header:
awk 'BEGIN {FS=","; OFS=","} {print $2, $1, $3}' "${CSV}" > "${XYZ}"

rm "${CSV}".yxz

XYZ="xyz"

gmtinfo_output=$(gmt gmtinfo -I0.1 ${XYZ}.xyz)
REGION=$(echo $gmtinfo_output)
echo $REGION

RES="0.2e"
OUT_NC=""${XYZ}".nc"

SRAD="0.3e"

#gmt xyz2grd  "${XYZ}".xyz "${REGION}" -I"${RES}"  -G"${OUT_NC}" -V
gmt nearneighbor "${XYZ}".xyz "${REGION}" -I"${RES}" -S"${SRAD}" -V -ENaN -N1 -G${OUT_NC}

TIF_REPRJ=""${XYZ}"_"${RES}"m_EPSG3395.tif"
gdalwarp -overwrite -s_srs EPSG:4326 -t_srs EPSG:3395 "${OUT_NC}" "${TIF_REPRJ}"

TIF=""${XYZ}"_"${RES}"m_UTM32N.tif"
gdal_translate -ot Float32 -of Gtiff -a_srs EPSG:32632 "${OUT_NC}" "${TIF}"
gdal_translate -ot Float32 -of Gtiff "${OUT_NC}" "${TIF}"

ls -1 *.tif > tiff_list.txt
gdal_merge.py -o Baltic_1m_nodata_UTM32N.tif -n 0 -a_nodata nan --optfile tiff_list.txt 

FILE_P="Predicted"
RES="1"
SRAD="2"
SOUND_P="PredictedSoundings"

XYZ_M="SO276_subset_10000000_no_header.xyz"
FILE_M="Manual"
SOUND_M="ManualSoundings"

XYZ_A="5730006018000.xyz"
FILE_A="All"
SOUND_A="AllSoundings"

XYZ_A="M119_EM122_AcceptedSoundings_WGS84.xyz"
FILE_A="M119_EM122"
SOUND_A="AcceptedSoundings"

echo "gridding predicted..."
gmt xyz2grd  "${XYZ}" "${REGION}" -I"${RES}"e  -G"${FILE_P}"_"${RES}"m_"${SOUND_P}"_WGS84.nc

echo "gridding manual..."
gmt xyz2grd "${XYZ_M}" "${REGION}" -I"${RES}"e  -G"${FILE_M}"_"${RES}"m_"${SOUND_M}"_WGS84.nc

echo "gridding all..."
gmt xyz2grd "${XYZ_A}" "${REGION}" -I"${RES}"e  -G"${FILE_A}"_"${RES}"m_"${SOUND_A}"_WGS84.nc

echo "gridding accepted xyz..."
gmt xyz2grd "${XYZ}" "${REGION}" -I"${RES}"e -V -G"${FILE_A}"_"${RES}"m_"${SOUND_A}"_WGS84.nc


docker run -it -p 8080:80 -v ${PWD}:/data docker.io/tobiasziolkowski/my-docker-image:latest
docker run -it -p 8080:80 -v ${PWD}:/data tobiasziolkowski/unet-for-outlier-detection:6


# ------ Interpolation doesn't work well ----------- #

gmt blockmedian "${XYZ}" "${REGION}" -I"${RES}"e -S"${SRAD}"e -bo -V > out_median.xyz
gmt nearneighbor out_median.xyz "${REGION}" -I"${RES}"e -S"${SRAD}"e -V -ENaN -N1 -bi3 -G"${FILE_A}"_"${RES}"m_"${SOUND_A}"_WGS84.nc

#gmt blockmedian manual_clean_lolalde.xyz -R"${REGION}" -I"${RES}"e -S"${SRAD}"e -bo > out_median_man.xyz
#gmt nearneighbor out_median_man.xyz -R"${REGION}" -I"${RES}"e -S"${SRAD}"e -ENaN -N1 -bi3 -G"${FILE}"_"${RES}"m_"${SOUND}"_WGS84.nc


#gmt blockmedian Rohdaten_allSoundings.xyz -R"${REGION}" -I"${RES}"e -S"${SRAD}"e -bo > out_median_all.xyz
#gmt nearneighbor out_median_all.xyz -R"${REGION}" -I"${RES}"e -S"${SRAD}"e -ENaN -N1 -bi3 -G"${FILE}"_"${RES}"m_"${SOUND}"_WGS84.nc

# Convert to Geotiff #

NC=""${FILE_A}"_"${RES}"m_"${SOUND_A}"_WGS84.nc"
TIF=""${FILE_A}"_"${RES}"m_"${SOUND_A}"_WGS84.tif"
gdal_translate -ot Float32 -of Gtiff -a_srs EPSG:4326 "${NC}" "${TIF}"