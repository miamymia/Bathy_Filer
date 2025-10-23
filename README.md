# Bathy Blueheart
Script collection to sort and order bathymetry data on blueheart server

- With `00_Create_productLists.ipynb` users can list (missing) cruises, data products etc. that are (not) available on blueheart. This can also reveal spelling errors: 
- **Note**: If names are misspelled, these datasets will be marked as missing! Most common mistake: Cruise leg names should ALWAYS be denoted with a *dash*, not an *underscore* e.g. SO301-1, and NOT(!) SO301_1. Currently, there is no check for such spelling mistakes hence if wrong, the respective datasets will be marked as missing which has to be corrected manually.
- `01_Create_cov.sh` is a bash script that creates zero grids and from this, coverage polygons for bathymetry raster files in a given path dir. Needs [gdal](https://gdal.org/en/stable/programs/gdal_raster_mosaic.html). Recommended: Install gdal via [anaconda/miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main). Or, even better: Use the blueheart_environment.yml
- `02_Add_metadata.ipynb` dissolves features, removes empty features and adds metadata to previously created polygon coverages. Renames file-ending from '_Area.gpkg' to '_Coverage.gpkg' to avoid messing up existing files in case something goes wrong. Also copies final polygon coverages to respective cruise folder on blueheart.
- `03_Create_GPKG_Compilation.sh` is a bash script that creates a merged product from all (previously created) gpkg ending with '_Coverage.gpkg' in user defined path dir.
- `04_Create_Raster_Compilation.sh` is a bash script that creates a merged product from all bathy raster in user defined path dir.
- With `05_Batch_CreateProducts.ipynb` the user can process a bunch of data at once. Not neccessary needed.
- `Create_dirs.py` creates folder structure for any cruise folder that doesn't have this structure yet. Ignore those that do have the structure. Usage: _"python Create_dirs.py /path/to/local/dst_dir/ XX"_ (XX = vessel short name, e.g. "SO" for SONNE, so the command is: _python Create_dirs.py /path/to/local/folder/ SO_)
- `Sync_files.py` uses rsync to copy multibeam data from MDM by excluding .wcd data. It also creates the folder structure. Usage: _"python Sync_files.py path/to/src_mdm_dir path/to/local/dst_dir"_; E.g.: _python Sync_files.py /Volumes/projects/p_mdm/mdm/SO/EM122/SO294/  /Users/hiwi/DataOnDisk/Pangaea/00_from_MDM/SO294/raw/EM122/_
- `gridding.sh` converts point cloud into raster using gmt and gdal optionally to convert between data formats and projections. Needs gmt and gdal to be installed.
- `Tiling.sh` takes xyz data as input and divides it into tiles of user defined size in coordinate units. For HPC usage, use in combination with `Tiling_sbatch.slurm`

- The _mbsystem_ Workflows can be used for older data to create grids, extract backscatter, adjust SVP etc. **Caution: Don't just execute the .sh scripts, rather copy the lines you need out of it!** They are mostly redundant with slight differences:
- `Workflow_mbsystem_General_SVPAdjust.sh` can be used to manually adjust SVP for certain areas within the data (from line 212)
- `Workflow_mbsystem_Kongsberg.sh` does processing for Kongsberg data (mbsystem format 56)
- `Workflow_mbsystem_QnD_DAM.sh` can be used to create 'quick and dirty' grids for overview etc. 

- __docs_ contains manuals and log file templates for multibeam data acquisition and processing plus a QGIS manual 