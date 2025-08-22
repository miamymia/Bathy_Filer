#!/bin/bash
#SBATCH --job-name=Tiling
#SBATCH --partition=base 
#SBATCH --nodes=2 
#SBATCH --tasks-per-node=32 
#SBATCH --cpus-per-task=1 
#SBATCH --mem=100000 
#SBATCH --time=10:00:00 
#SBATCH --output=Tiling.out
export OMP_NUM_THREADS=1 


module load gcc12-env/12.3.0
# module load singularity/3.11.5
module load miniconda3/23.5.2

conda activate .gis
./Tiling.sh
# singularity exec -B $PWD --no-home -e gmt6_latest.sif ./Tiling.sh
