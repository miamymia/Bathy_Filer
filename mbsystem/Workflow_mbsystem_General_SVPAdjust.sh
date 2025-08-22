echo ########## Multibeam processing with MBSYSTEM ###############

echo This script does cleaning and gridding of Seabeam 3100 and Atlas Multibeam data
echo and processed point files .gsf using MBsystem. Naming of products, e.g. grids, is done half automatically,
echo so may need adjustment. Variables need to be defined, such as grid resolution, 
echo search radius, region etc. Once adjusted, the script should be execultable via
echo command line in the folder where .sda/.gsf files are located. Not that some of the 
echo comands occur more than once - this is for the different file format, i.e. .sda/.gsf etc..
echo You probably only need one of the commands according to the data format you have.
echo This scirpt also contains SVP correcting commands. These should only be used if your
echo SVP are really messed up, because mblevitus reads very general SVPs from WOA13 and they may not
echo be very accurate. Carefully adjust the region and filenames within the SVP part.

echo #################### END ###################
# change directory (only when using mbsystem docker)
cd opt/MBSWorkDir/Docs_Data/Bathy/Processing/

# change read/write persmission for .all files
chmod -x *.sda
chmod +r *.sda
chmod -x *.six
chmod +r *.six

chmod -x *.0
chmod +r *.0

chmod +w *.sda
chmod +w *.six

chmod +r-x+w *.mb21

# make datalist from .xse: 
/bin/ls -1 *.xse | awk '{print $1" 94"}' > datalist_raw.mb-1
/bin/ls -1 *.gsf | awk '{print $1" 121"}' > datalist_raw.mb-1
/bin/ls -1 *.all | awk '{print $1" 56"}' > datalist_raw.mb-1
/bin/ls -1 *.sda | awk '{print $1" 181"}' > datalist_raw.mb-1


# transfer data formats if non-writable/convert to mbsys-readable format (94 for SB3050):
mbcopy -F181/71 -I m624424.sda -O m624424.mb71

# Multicopy doesn't always work properly, do for-loop instead, see below
# mbm_multicopy -I datalist_raw.mb-1 -F71 -T -X4 -V

# convert .* -> .mb* for many files: (mb57 for .all, mb71 for .sda, mb26(?) for Atlas dux/.0)
for f in *.sda; do base=${f%.sda}; mbcopy -F181/71 -I $f -O ${f%.sda}.mb71;done
#for f in *.0; do base=${f%.sda}; mbcopy -F26 -I $f -O ${f%.sda}.mb26;done
for f in *.0; do base=${f%.sda}; mbcopy -F21 -I $f -O ${f%.sda}.mb21;done
for f in *.1; do base=${f%.sda}; mbcopy -F21 -I $f -O ${f%.sda}.mb21;done
for f in *.mb32; do base=${f%.mb32}; mbcopy -F21 -I $f -O ${f%.mb32}.mb121; done

# make datalist from .mb71 files:
/bin/ls -1 *.mb71 | awk '{print $1" 71"}' > datalist_raw.mb-1
/bin/ls -1 *.mb26 | awk '{print $1" 26"}' > datalist_raw.mb-1
/bin/ls -1 *.mb21 | awk '{print $1" 21"}' > datalist_raw.mb-1
/bin/ls -1 *.mb32 | awk '{print $1" 32"}' > datalist_raw.mb-1
/bin/ls -1 *.mb33 | awk '{print $1" 33"}' > datalist_raw.mb-1


# create mbsystemfiles ((r).mbXX): 
mbpreprocess --input=datalist_raw.mb-1 --verbose

# make datalist for .mbXX or, if mbcopy used(?), for r.mbXX: 
/bin/ls -1 *.mb94 | awk '{print $1" 94"}' > datalist_pre.mb-1
/bin/ls -1 *.mb121 | awk '{print $1" 121"}' > datalist_pre.mb-1
/bin/ls -1 *.mb57 | awk '{print $1" 57"}' > datalist_pre.mb-1

/bin/ls -1 *r.mb71 | awk '{print $1" 71"}' > datalist_pre.mb-1
/bin/ls -1 *r.mb26 | awk '{print $1" 26"}' > datalist_pre.mb-1
/bin/ls -1 *r.mb21 | awk '{print $1" 21"}' > datalist_pre.mb-1
/bin/ls -1 *r.mb32 | awk '{print $1" 32"}' > datalist_pre.mb-1
/bin/ls -1 *r.mb33 | awk '{print $1" 33"}' > datalist_pre.mb-1

# set sound velocity: 
mbset -I datalist_pre.mb-1 -PSVPFILE:NB_SoundVelocity.svp

# set sonar offset: 
mbset -I datalist_pre.mb-1 -PSONAROFFSETZ:2.00		#was -2.96

# set roll bias port: 
mbset -I datalist_pre.mb-1 -PROLLBIASPORT:0.84

# set roll bias starbort: 
mbset -I datalist_pre.mb-1 -PROLLBIASSTBD:0.84

# clean data: 

# manual (3D cloud):
mbeditviz -I datalist_pre.mb-1

# manual (2D pings):
mbedit -I datalist_pre.mb-1

# auto:
mbclean -I datalist_pre.mb-1 -A100 -B100/8000 -M1 -C3.5 -D0.01/0.20 -G0.75/1.25 -Q -V
mbclean -I datalist_pre.mb-1 -G0.75/1.25 -Q -V
mbclean -I datalist_raw.mb-1 -G0.75/1.25 -Q -V
mbclean -I datalist_raw.mb-1 -A100 -M1 -C3.5 -D0.01/0.20 -G0.75/1.25 -Q -V


											echo	# * where D = min/max distance between beams as fraction of depth (beam distances/depth written in MBES manual)
											echo	# * where C = max slope after which soundings are rejected
											echo	# * where G = min/max deviation from median depth denoted as fraction of depth
											echo	# * where M = flags beam associated with excessive slope according to option C;
											echo	# * where Z = flags all beams with zero lon/lat
											echo	# * where A = flag sounding hat exceed local median depth
											echo	# * where Q = flags soundings with no valid lon lats
											echo	# * where B = low/high acceptable depth


# apply: 
mbprocess -I datalist_pre.mb-1
mbprocess -I datalist_raw.mb-1

# make datalist for p.mbXX: 
/bin/ls -1 *p.mb94 | awk '{print $1" 94"}' > datalistp.mb-1
/bin/ls -1 *p.mb121 | awk '{print $1" 121"}' > datalistp.mb-1
/bin/ls -1 *p.mb57 | awk '{print $1" 57"}' > datalistp.mb-1
/bin/ls -1 *p.mb71 | awk '{print $1" 71"}' > datalistp.mb-1

# check if data are not empty: 
mbnavlist -I datalistp.mb-1
mbnavlist -I datalist_pre.mb-1

# Set names as environment variablies

FILE="M62-5B"
SOUND="AllSoundings"
XYZ="${FILE}"_"${SOUND}"_WGS84.xyz

# export to .xyz (for all beams: MA, otherwise type number of beams): 
mblist -I datalistp.mb-1 -OXY-z -MA > ../_xyz/"${FILE}"_"${SOUND}"_WGS84.xyz
mblist -I datalist_pre.mb-1 -OXY-z -MA > _xyz/"${FILE}"_"${SOUND}"_WGS84.xyz
mblist -I datalist_raw.mb-1 -OXY-z -MA > ../"${FILE}"_"${SOUND}"_WGS84.xyz
mblist -I datalist_pre.mb-1 -OXY-z -MA > ../$XYZ

# create directories for grids & xyz
# mkdir _grd
# mkdir _xyz

cd ..
RES="100"
SRAD="200"

gmtinfo_output=$(gmt gmtinfo -I0.1 "${FILE}"_"${SOUND}"_WGS84.xyz)
REGION=$(echo $gmtinfo_output)
echo $REGION

# ------- Get region Info from grid ----------
gmtinfo_output=$(gmt grdinfo -I0.1 SO254_EM122_400m_CUBE_A_EPSG3395.tif)
REGION=$(echo $gmtinfo_output)
echo $REGION

# ------------ Quick and dirty grid ------------

gmt blockmedian "${XYZ}" "${REGION}" -I"${RES}"e -S"${SRAD}"e -bo -V > out_median.xyz
gmt nearneighbor out_median.xyz "${REGION}" -I"${RES}"e -S"${SRAD}"e -V -ENaN -N1 -bi3 -G"${FILE}"_"${RES}"m_"${SOUND}"_WGS84.nc

# Convert to Geotiff & reproject to EPSG:3395
NC=""${FILE}"_"${RES}"m_"${SOUND}"_WGS84.nc"
TIF_REPRJ=""${FILE}"_"${RES}"m_"${SOUND}"_EPSG3395.tif"
gdalwarp -overwrite -s_srs EPSG:4326 -t_srs EPSG:3395 "${NC}" "${TIF_REPRJ}"

# Convert to Geotiff #
NC=""${FILE}"_"${RES}"m_"${SOUND}"_WGS84.nc"
TIF=""${FILE}"_"${RES}"m_"${SOUND}"_WGS84.tif"
gdal_translate -ot Float32 -of Gtiff -a_srs EPSG:4326 "${NC}" "${TIF}"


gdalwarp -t_srs EPSG:XXXXX srtm_37_02.tif dem_rd.tif

# Move grids to ../_grd
mv *.tif ../_grd
mv *.nc ../_grd

# --------------------- Fix SVP for multiple files based on region and mblevitus ----------------------------------

# create xyF (lon,lat,filename) based on region to check where is which file
# with mblevitus, create one SVP per defined region (generate this from centre file of resp. region)
# make .xyF input list for mblevitus
# might have to run: gmt set GMT_CUSTOM_LIBS = /usr/local/lib/mbsystem.so

# plot trackline with filenames
mbm_plot -Idatalist_pre.mb-1 -MNA0.02/P
bash -xv datalist_pre.mb-1.cmd

# define region chunks from mbm_plot
R11="-55/-53/-36/-35"
R12="-53/-51/-36/-35"
R21="-55/-53/-38/-36"
R22="-53/-51/-38/-36"
R31="-55/-53/-36/-34"
R32="-53/-51/-36/-34"

mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R11}  > ../_xyz/M78_3A_Trackline_R11_HS_WGS84.xyF
mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R12}  > ../_xyz/M78_3A_Trackline_R12_HS_WGS84.xyF

mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R21}  > ../_xyz/M78_3A_Trackline_R21_HS_WGS84.xyF
mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R22}  > ../_xyz/M78_3A_Trackline_R22_HS_WGS84.xyF

mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R31}  > ../_xyz/M78_3A_Trackline_R31_HS_WGS84.xyF
mblist -I datalist_pre.mb-1 -O.F -M0/0 -R${R32}  > ../_xyz/M78_3A_Trackline_R32_HS_WGS84.xyF

# Remove duplicate lines (do cd ../_xyz first!)
cd ../_xyz
for f in *_WGS84.xyF; do awk '!x[$0]++' $f > "${f%%.*}_datalist.txt"; done

# add column/s to make it an mbsystem command file (add 'mbset -I' before filename and 'PSVP... after')
for f in *_datalist.txt; do awk -F, '{$1="mbset -I " FS $1;}1' OFS=' ' $f > "${f%%.*}_svp.txt"; done

# Create svp using mbvelocitytool on centre file
mbvelocitytool -I c0490raw.mb57

awk -F, '{$(NF+1)="-PSVPFILE:R11.svp";}1' M78_3A_Trackline_R11_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R11_HS_WGS84_datalist_svp.sh

awk -F, '{$(NF+1)="-PSVPFILE:R12.svp";}1' M78_3A_Trackline_R12_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R12_HS_WGS84_datalist_svp.sh

awk -F, '{$(NF+1)="-PSVPFILE:R21.svp";}1' M78_3A_Trackline_R21_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R21_HS_WGS84_datalist_svp.sh

awk -F, '{$(NF+1)="-PSVPFILE:R22.svp";}1' M78_3A_Trackline_R22_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R22_HS_WGS84_datalist_svp.sh

awk -F, '{$(NF+1)="-PSVPFILE:R31.svp";}1' M78_3A_Trackline_R31_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R31_HS_WGS84_datalist_svp.sh

awk -F, '{$(NF+1)="-PSVPFILE:R32.svp";}1' M78_3A_Trackline_R32_HS_WGS84_datalist_svp.txt > M78_3A_Trackline_R32_HS_WGS84_datalist_svp.sh

# --------------------------------- END OF SVP TUNING --------------------------------------

# check depth values in .xyz: (optional)
# python3
# import numpy as np
# lon, lat, depth = np.loadtxt('M68_2_EM120_mbsys_WGS84.xyz', unpack = True)
# print(np.max(depth))
# print(np.median(depth))
# print(np.min(depth))
# lon2 = [np.nan if lo > 180 else lo for lo in lon]
# xyz = np.stack([lon2, lat, depth], axis=1)
# quit()

FILE="_xyz/Pitcairn_EM12D_accepted_EPSG4326.txt"

# get region with gmt
gmtinfo_output=$(gmt gmtinfo -I1 $FILE)
REGION=$(echo $gmtinfo_output)
echo $REGION
# REGION=$(echo "$gmtinfo_output" | awk '{print $1 "/" $2 "/" $3 "/" $4}')

# Define other Variables
# resolution in degree/seconds/minutes (s/m)
RES="100e"
RES_BM="20e"
SRAD="400e"
SRAD_BM="40e"
MBES="EM12D"
STATUS="accepted"
CRUISE="Pitcairn"

REG_PATH="/Volumes/Evo/Data/CV/All_Raster/Compilations/GEBCO23_Brave.nc"
echo "${REG_PATH}"

# Run blockmedian to avoid aliasing first, then grid with nearneighbour; Q: Mollweide projection (-JU)
gmt blockmedian $FILE "${REGION}" -I"${RES_BM}" -bo -V > _xyz/out_median.xyz
gmt nearneighbor _xyz/out_median.xyz "${REGION}" -I"${RES}" -S"${SRAD}" -ENaN -N1 -bi3 -V -G_grd/"${CRUISE}"_"${MBES}"_"${RES}"_"${STATUS}"_BM20_WGS84.nc
gmt nearneighbor $FILE "${REGION}" -I"${RES}" -S"${SRAD}" -ENaN -N1 -V -G_grd/"${CRUISE}"_"${MBES}"_"${RES}"_"${STATUS}"-BM_WGS84.nc

# For Area calculations, reproject to Mollweide EPSG:54009
# Gdal doesn't always do what you want
gdalwarp -overwrite -s_srs EPSG:32628 -r near -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 /Volumes/Evo/Data/ICEAge3/QGIS/_grd/Final_grids/Geotif/SO273_MerMet17-6_EM122_All_transit_100m.tif /Volumes/Evo/Data/iAtlantic_Data/Bathymetry/PushToPangaea/SO276_EM122_Transit_100m_Accepted_EPSG54009.tif

#### mit QgsrasterFileWriter nach tiff exportieren: https://qgis.org/pyqgis/3.2/core/Raster/QgsRasterFileWriter.html ######
# move grid/xyz in _grd/_xyz folder

rm *.history
rm out_median.xyz
mkdir ../_grd
mkdir ../_xyz
mv *.nc ../_grd
mv *.xyz ../_xyz
rm ../_xyz/out_median.xyz

# or grid using mbsys:
# (-A1 (z positive down) -E100/100 (resolution) -F5 (footprint with slope gridding alg., for swath data only) -JU (chooses UTM Zone automatically)); default grid spacing: grid spacing equivalent to 0.02 times the maximum sonar altitude
# mbgrid -A1 -E500/500/metres  -F5 -JU -I datalist_pre.mb-1 -O "${CRUISE}"_"${MBES}"_"${RES_DEG}"_testgrid_WGS84.grd


#------------------------------ BACKSCATTER ---------------------------------- #

mbbackangle  -G1 -Q -V -Idatalist_pre.mb-1

# set parameters for backscatter/amplitude (http://www3.mbari.org/products/mbsystem/html/mbset.html):
mbset -I datalist_pre.mb-1 -PAMPCORRFILE:datalist_pre.mb-1_tot.aga
mbset -I datalist_pre.mb-1 -PSSCORRFILE:datalist_pre.mb-1_tot.sga


# process the data (apply mbset, mbbackangle etc)
mbprocess -I datalist_pre.mb-1

# make datalist with processed files
ls -1 *p.mb94 > datalistp.mb-1
/bin/ls -1 *p.mb121 | awk '{print $1" 121"}' > datalistp.mb-1

# Filter the sidescan/esp. low-apss filters for smoothing & speckle reduction etc.  (http://www3.mbari.org/products/mbsystem/html/mbfilter.html)
mbfilter -Idatalistp.mb-1 -S2/5/3

# export backscatter as xyBS
mblist -I datalistp.mb-1 -D5 > "${CRUISE}"_"${MBES}"_Backscatter_WGS84.xyBS

RES='2e'
SRAD='5e'

gmt blockmedian SB3100_test.xyAMP -R"${REGION}" -I"${RES}" -S"${SRAD}" -bo > out_median.xyz
gmt nearneighbor out_median.xyz -R"${REGION}"  -I"${RES}" -S"${SRAD}" -ENaN -N1 -bi3 -G"${CRUISE}"_"${MBES}"_"${RES_DEG}"_Backscatter_WGS84.nc


####################

Mosaic & grid

# make mosaic from processed p.mb59 files (http://www3.mbari.org/products/mbsystem/html/mbmosaic.html):
mbmosaic -A4 -C2 -E2/2/meters -O "${CRUISE}"_"${MBES}"_"${RES_DEG}"_Backscatter_WGS84.nc -I datalist_pre.mb-1




