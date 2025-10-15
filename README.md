# Bathy Blueheart
Script collection to sort and order bathymetry data on local server

- With `Check_Blueheart.ipynb` users can list (missing) cruises, data products etc. that are (not) available on blueheart
- **Note**: If names are misspelled, these datasets will be marked as missing! Most common mistake: Cruise leg names should ALWAYS be written like with a *dash*, not an *underscore* e.g. SO301-1, and NOT(!) SO301_1. Currently, there is no check for such spelling mistakes hence if wrong, the respective datasets will be marked as missing which has to be corrected manually.
- `Check_Blueheart.ipynb` also creates grid compilations and coverage polygons for each vessel. Needs [gdal](https://gdal.org/en/stable/programs/gdal_raster_mosaic.html). Recommended: Install gdal via [anaconda/miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main). Or, even better: Use the blueheart_environment.yml
- `Create_dirs.py` creates folder structure for any cruise folder that doesn't have this structure yet. Ignore those that do have the structure. Usage: _"python Create_dirs.py /path/to/local/dst_dir/ XX" (XX = vessel abbr., e.g. "SO" for SONNE, then do: python Create_dirs.py /path/to/local/folder/ SO)_
- `Sync_files.py` uses rsync to copy multibeam data from MDM by excluding .wcd data. It also creates the folder structure. Usage: _"python Sync_files.py path/to/src_mdm_dir path/to/local/dst_dir"_; E.g.: _python Sync_files.py /Volumes/projects/p_mdm/mdm/SO/EM122/SO294/  /Users/hiwi/DataOnDisk/Pangaea/00_from_MDM/SO294/raw/EM122/_
- `Tiling.sh` takes xyz data as input and divides it into tiles of user defined size in coordinate units. For HPC usage, use in combination with `Tiling_sbatch.slurm`

- The _mbsystem_ Workflows can be used for older data to create grids, extract backscatter, adjust SVP etc. They are mostly redundant with slight differences:
- `Workflow_mbsystem_General_SVPAdjust.sh` can be used to manually adjust SVP for certain areas within the data (from line 212)
- `Workflow_mbsystem_Kongsberg.sh` does processing for Kongsberg data (mbsystem format 56)
- `Workflow_mbsystem_QnD_DAM.sh` can be used to create 'quick and dirty' grids for overview etc. 

- __docs_ contains manuals and log file templates for multibeam data acquisition and processing plus a QGIS manual 