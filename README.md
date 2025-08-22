# Bathy Blueheart
Script collection to sort and order bathymetry data on local server

- With `Check_Blueheart.ipynb` users can list e.g. cruises, bathymetry data etc. that area available on blueheart
- `Check_Blueheart.ipynb` also creates grid compilations and coverage polygons for each vessel. Needs [gdal](https://gdal.org/en/stable/programs/gdal_raster_mosaic.html). Recommended: Install gdal via [anaconda/miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main)
- `Sync_files.py` uses rsync to copy multibeam data from MDM by excluding .wcd data. It also creates the folder structure
- `Create_dirs.py` creates folder structure for any cruise folder that doesn't have this structure yet. Ignore those that do have the structure. 
- `Tliing.sh` takes xyz data as input and divides it into given tiles. For HPC, use in combination with `Tiling_sbatch.slurm`

#TODO: Argparse for filepaths, startletters etc.  