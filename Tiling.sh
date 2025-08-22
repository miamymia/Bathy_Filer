#!/bin/bash
# export PATH="/opt/local/bin/gmt:$PATH"

# Define input point cloud file
input_file='/gxfs_work/geomar/smomw468/CV/xyz/CV_merge.xyz'

# Define tile size (in degrees or whatever units your coordinates are in)
tile_size=2

# Define output directory for tiles
output_dir='/gxfs_work/geomar/smomw468/CV/xyz/xyz_tiles_2deg'

# Make sure output directory exists, if not, create it
rm -r $output_dir
mkdir -p $output_dir

xmin='-69.904753'
ymin='-35.9214876'
xmax='5.52692314'
ymax='53.68173222'

# -R-69.9/5.5/-35.9/53.6    1st tile: -R-72/-69/-36/-33

# Get bounding box coordinates of the entire point cloud
# xmin_out=$(gmt info -C -V -o0 $input_file)
# xmin=$(echo $xmin_out)
# echo 'xmin = ' $xmin
# ymin_out=$(gmt info -C -V -o2 $input_file)
# ymin=$(echo $ymin_out)
# echo $ymin
# xmax_out=$(gmt info -C -V -o1 $input_file)
# xmax=$(echo $xmax_out)
# echo $xmax
# ymax_out=$(gmt info -C -V -o3 $input_file)
# ymax=$(echo $ymax_out)
# echo $ymax

# Calculate number of tiles in x and y directions
num_tiles_x=$(echo "($xmax - $xmin) / $tile_size" | bc)
echo 'num_tiles_x = ' $num_tiles_x
num_tiles_y=$(echo "($ymax - $ymin) / $tile_size" | bc)
echo 'num_tiles_y = ' $num_tiles_y

# Loop through each tile and extract points within it
for ((i=0; i<$num_tiles_x; i++)); do
    for ((j=0; j<$num_tiles_y; j++)); do
        # Calculate tile bounding box
        tile_xmin=$(echo "($xmin + ($i * $tile_size))" | bc)
        echo 'i = ' $i
        tile_ymin=$(echo "($ymin + ($j * $tile_size))" | bc)
        echo 'j = ' $j
        tile_xmax=$(echo "($xmin + (($i + 1) * $tile_size))" | bc)
        tile_ymax=$(echo "($ymin + (($j + 1) * $tile_size))" | bc)
        
        tile_xmin_rd=$(printf "%.1f" $tile_xmin)
        tile_xmax_rd=$(printf "%.1f" $tile_xmax)
        tile_ymin_rd=$(printf "%.1f" $tile_ymin)
        tile_ymax_rd=$(printf "%.1f" $tile_ymax)

        echo 'tile_xmin_rd = ' $tile_xmin_rd
        echo 'tile_ymin_rd = ' $tile_ymin_rd

        # Extract points within the tile bounding box
        
        gmt select $input_file -R$tile_xmin/$tile_xmax/$tile_ymin/$tile_ymax > $output_dir/tile_${tile_xmin_rd}E_${tile_xmax_rd}E-${tile_ymin_rd}N_${tile_ymax_rd}N.xyz
        echo 'Tile done'
    done
    
done
