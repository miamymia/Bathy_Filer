echo ########## Multibeam processing with MBSYSTEM ###############

echo This script does cleaning and gridding of Kongsberg Multibeam data
echo using MBsystem. Naming of products, e.g. grids, is done half automatically,
echo so may need adjustment. Variables need to be defined, such as grid resolution, 
echo search radius, region etc. Once adjusted, the script should be execultable via
echo command line in the folder where .all files are located.


# in terminal, cd to folder that contains raw MBES files (.all)
# change read/write persmission for .all files

chmod -x *.all
chmod +r *.all

# determine multibeam system format identifier using mbformat; below is a list of the systems format 
# (MBIO Data Format ID) commonly used on german research vessels (Kongsberg systems):

echo	############### Kongsberg MBES system format identifiers ################
	
echo	MBIO Data Format ID:  56
echo	Format name:          MBF_EM300RAW
echo	Informal Description: Simrad current multibeam vendor format
echo	Attributes:           Simrad EM120, EM300, EM1002, EM3000, 
echo	                      bathymetry, amplitude, and sidescan,
echo	                      up to 254 beams, variable pixels, ascii + binary, Simrad.
	
echo	MBIO Data Format ID:  57
echo	Format name:          MBF_EM300MBA
echo	Informal Description: Simrad multibeam processing format
echo	Attributes:           Old and new Simrad multibeams, 
echo	                      EM12S, EM12D, EM121, EM120, EM300, 
echo	                      EM100, EM1000, EM950, EM1002, EM3000, 
echo	                      bathymetry, amplitude, and sidescan,
echo	                      up to 254 beams, variable pixels, ascii + binary, MBARI.

echo	MBIO Data Format ID:  58
echo	Format name:          MBF_EM710RAW
echo	Informal Description: Kongsberg current multibeam vendor format
echo	Attributes:           Kongsberg EM122, EM302, EM710,
echo	                      bathymetry, amplitude, and sidescan,
echo	                      up to 400 beams, variable pixels, binary, Kongsberg.

echo	MBIO Data Format ID:  59
echo	Format name:          MBF_EM710MBA
echo	Informal Description: Kongsberg current multibeam processing format
echo	Attributes:           Kongsberg EM122, EM302, EM710,
echo	                      bathymetry, amplitude, and sidescan,
echo	                      up to 400 beams, variable pixels, binary, MBARI.

echo	################### END ##################################

# create datalist - in the {}, insert the correct format identifier for the multibeam you used (58 for EM122, EM710) 
# /bin/ls -1 *.all | awk '{print $1" 56"}' > datalist_raw.mb-1
/bin/ls -1 *.all | awk '{print $1" 58"}' > datalist_raw.mb-1


# convert to mbsystem-readable format:
mbkongsbergpreprocess -I datalist_raw.mb-1 -V

# make list from preprocessed files:
/bin/ls -1 *.mb59 | grep -v "p.mb59" | awk '{print $1" 59"}' > datalist.mb-1
mbdatalist -O -Z -V

# clean and apply flags to files (http://www3.mbari.org/products/mbsystem/html/mbclean.html)
# use mbunclean to unflag 
# optional manual editing: mbedit
# mbclean -I datalist.mb-1 -A70 B70/5000 -M2 -C3.5 -D0.01/0.20 -G0.98/1.02 -Q50 -Z -S3 -V
# 							echo	# * where D = min/max distance between beams as 
# 							echo	# 	fraction of depth (beam distances/depth written in MBES manual)
# 							echo	# * where C = max slope after which soundings are rejected
# 							echo	# * where G = min/max deviation from median depth denoted as fraction of depth
# 							echo	# * where M = flags beam associated with excessive slope according to option C;
# 							echo	# * where Z = flags all beams with zero lon/lat
# 							echo	# * where A = flag sounding hat exceed local median depth
# 							echo	# * where Q = flags soundings with one or more outer beams lying
# 							echo	# more than *backup* meters inboard of a more inner beam


# Apply changes/edits
mbprocess -I datalist.mb-1 -V

#create datalist from preprocessed files ('59' is the format identifier for mbsystem processed files)
/bin/ls -1 *p.mb59 | awk '{print $1" 59"}' > datalistp.mb-1
# /bin/ls -1 *.mb121 | awk '{print $1" 121"}' > datalist_pre.mb-1

# export to xyz 
mblist -I datalistp.mb-1 -OXY-z -MA > M104_EM122_MBsysCleaned_WGS84.xyz

# get region with gmt
gmtinfo_output=$(gmt gmtinfo ../_xyz/*.xyz -C)
REGION=$(echo "$gmtinfo_output" | awk '{print $1 "/" $2 "/" $3 "/" $4}')

# Define other Variables
# resolution in degree/seconds/minutes (s/m)
RES_DEG="0.00416666666667"
SRAD="0.0082"
MBES="HS"
CRUISE="M46_3"

REG_PATH="/Volumes/Evo/Data/CV/All_Raster/Compilations/GEBCO23_Brave.nc"
echo "${REG_PATH}"

# make nice grid and smooth over data holes using gmt 
# chose region with -R option: -Rxmin/xmax/ymin/ymax ( = W//E/S/N)
gmt blockmedian M104_EM122_MBsysCleaned_WGS84.xyz -R"${REGION}" -I"${RES_DEG}" -S"${SRAD}" -bo > out_median.xyz
gmt nearneighbor out_median.xyz -R"${REGION}" -I"${RES_DEG}" -S"${SRAD}" -ENaN -N1 -bi3 -G"${CRUISE}"_"${MBES}"_"${RES_DEG}"_WGS84.nc

echo ########## Backscatter ##################

# get table with backscatter/amplitutdes (http://www3.mbari.org/products/mbsystem/html/mbbackangle.html):
#mbbackangle -A2 -G1 -Q -V -I datalistp.mb-1
mbbackangle -A2 -G1 -V -I datalist_pre.mb-1


# set parameters for backscatter/amplitude (http://www3.mbari.org/products/mbsystem/html/mbset.html):
mbset -I datalist_pre.mb-1-PAMPCORRFILE:datalist_pre.mb-1_tot.aga
mbset -I datalist_pre.mb-1 -PSSCORRFILE:datalist_pre.mb-1_tot.sga

# process the data (apply mbset, mbbackangle etc)
mbprocess -I datalist_pre.mb-1

# make datalist with processed files
/bin/ls -1 *p.mb59 | awk '{print $1" 59"}' > datalistp.mb-1
/bin/ls -1 *p.mb121 | awk '{print $1" 121"}' > datalistp.mb-1

# Filter the sidescan/esp. low-apss filters for smoothing & speckle reduction etc.  (http://www3.mbari.org/products/mbsystem/html/mbfilter.html)
mbfilter -Idatalistp.mb-1 -S2/5/3

# make mosaic from processed p.mb59 files (http://www3.mbari.org/products/mbsystem/html/mbmosaic.html):
mbmosaic -A4 -G3 -C2 -E200/200/meters -JU -O "${CRUISE}"_"${MBES}"_"${RES_DEG}"_BS_WGS84_UTM -I datalistp.mb-1

# export Backscatter to xyBs
mblist -I datalistp.mb-1 -D5 > "${CRUISE}"_"${MBES}"_Backscatter_WGS84.xyBS

rm *.out_median_bs.xyz

# make nice BS and smooth over data holes using gmt 
# chose region with -R option: -Rxmin/xmax/ymin/ymax ( = W//E/S/N)

gmt blockmedian SO286_EM122_Backscatter_WGS84.xyBS -R"${REGION}" -I"${RES_DEG}" -S"${SRAD}" -bo -V > out_median_bs.xyz
gmt nearneighbor out_median_bs.xyz -R"${REGION}" -I"${RES_DEG}" -S"${SRAD}" -ENaN -N1 -bi3 -V -G"${CRUISE}"_"${MBES}"_"${RES_DEG}"_Backscatter_WGS84.nc


echo ######## optional ###############

# create grid from raw (uncleand) files
# -A1 (z positive down) -E100/100 (resolution) -F5 (footprint with slope gridding alg.) -JU (chooses UTM Zone automatically)
# mbgrid -A1 -E100/100/metres  -F5 -JU -I datalist.mb-1 -O "${CRUISE}"_"${MBES}"_"${RES_DEG}"_WGS84.nc
