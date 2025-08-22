echo ########## Multibeam processing with MBSYSTEM ###############

echo This script does cleaning and gridding of Kongsberg Multibeam data
echo using MBsystem. Naming of products, e.g. grids, is done half automatically,
echo so may need adjustment. Variables need to be defined, such as grid resolution, 
echo search radius, region etc. Once adjusted, the script should be execultable via
echo command line in the folder where .all files are located.
echo Usage: cd to folder with .all and execute: Workflow_mbsystem_QnD_DAM.sh {Cruise} {MBES}


# in terminal, cd to folder that contains raw MBES files (.all)
# change read/write persmission for .all files

chmod -x *.all
chmod +r *.all

# cretae datalist from raw .all
/bin/ls -1 *.all | awk '{print $1" 58"}' > datalist_raw.mb-1

# create mbsystemfiles ((r).mbXX): 
mbpreprocess --input=datalist_raw.mb-1 --verbose

# make list from preprocessed files:
/bin/ls -1 *.mb59 | grep -v "p.mb59" | awk '{print $1" 59"}' > datalist.mb-1
mbdatalist -O -Z -V

# export to .xyz
mblist -I datalist.mb-1 -OXY-z -MA > ../_xyz/M46_3_HS_TestSoundings_WGS84.xyz

# Define Variables
# resolution in degree/seconds/minutes (s/m)
CRUISE=$1
MBES=$2


CRUISE="M83-3"
MBES="EM122"
RES="1e"
RES_str="200m"
SRAD="2e"
STATUS="AllSoundings"
FILE="${CRUISE}_${MBES}_${RES_str}_${STATUS}_WGS84"


# create grid from raw (uncleand) files
# -A1 (z positive down) -E100/100 (resolution) -F5 (footprint with slope gridding alg.) -JU (chooses UTM Zone automatically)
mbgrid -A1 -E$RES  -F5 -I datalist.mb-1 -O $FILE

FILE="_xyz/$CRUISE_$MBES_$STATUS_WGS84.xyz"

# get region with gmt
gmtinfo_output=$(gmt gmtinfo -I1 $FILE)
REGION=$(echo $gmtinfo_output)
echo $REGION

# Run blockmedian to avoid aliasing first, then grid with nearneighbour; Q: Mollweide projection (-JU)
gmt blockmedian $FILE "${REGION}" -I"${RES_BM}" -bo -V > _xyz/out_median.xyz
gmt nearneighbor _xyz/out_median.xyz "${REGION}" -I"${RES}" -S"${SRAD}" -ENaN -N1 -bi3 -V -G_grd/"${CRUISE}"_"${MBES}"_"${RES}"_"${STATUS}"_WGS84.nc
gmt nearneighbor $FILE "${REGION}" -I"${RES}" -S"${SRAD}" -ENaN -N1 -V -G"${CRUISE}"_"${MBES}"_"${RES}"_"${STATUS}"_WGS84.nc
