# This script creates missing folder according to our folder structure
# Usage: python Create_dirs.py path startwith
# Example: python Create_dirs.py /Volumes/Bathy/Data/01_EEZ_checked/ SO

import os
import subprocess
import sys
import argparse


def create_dirs(cruise_name):

    """
    Define paths and creates destination dir;
    Also creates product folders: {cruise_name}_products 
    and a metadata text file: {cruise_name}_fileinfo.txt
    """

    # get cruise name & which mbes (e.g. EM122)
    product = str(cruise_name.name + '_products')
    fileinfo = str(cruise_name.name + '_fileinfo.txt')

    cruise_dst = os.path.join(args.path, cruise_name)

    raw_dst = os.path.join(cruise_dst, 'raw')
    meta_dst = os.path.join(cruise_dst, '_metadata')
    protocol_dst = os.path.join(cruise_dst, '_protocols')
    svp_dst = os.path.join(cruise_dst, '_svp')
    misc_dst = os.path.join(cruise_dst, '_misc')

    product_path = os.path.join(cruise_dst, product)
    grd_path = os.path.join(product_path, '_grd')
    xyz_path = os.path.join(product_path, '_xyz')
    gsf_path = os.path.join(product_path, '_gsf')
    fileinfo_path = os.path.join(cruise_dst, fileinfo)

    if not os.path.exists(raw_dst):
        os.mkdir(raw_dst)
    else:
        print(raw_dst, ' already exists.')

    
    if not os.path.exists(meta_dst):
        os.mkdir(meta_dst)
    else:
        print(meta_dst, ' already exists.')
    
    if not os.path.exists(protocol_dst):
        os.mkdir(protocol_dst)
    else:
        print(protocol_dst, ' already exists.')

    if not os.path.exists(misc_dst):
        os.mkdir(misc_dst)
    else:
        print(misc_dst, ' already exists.')
    
    if not os.path.exists(svp_dst):
        os.mkdir(svp_dst)
    else:
        print(svp_dst, ' already exists.')

    if not os.path.exists(product_path):
        os.mkdir(product_path)
    else:
        print(product_path, ' already exists.')

    if not os.path.exists(grd_path):
        os.mkdir(grd_path)

    if not os.path.exists(xyz_path):
        os.mkdir(xyz_path)

    if not os.path.exists(gsf_path):
        os.mkdir(gsf_path)

    if not os.path.exists(fileinfo_path):
        with open(fileinfo_path, 'w') as file:
            text = [ 'MBES', 'MDM paths: ', '\n', 'corrupted files:', '\n', 'EEZ/s:']
            file.write('\n' .join(text))
    else:
        print(fileinfo_path, ' already exists.')
        


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description= 'Create directory structure for bathy data')
    parser.add_argument("path", metavar="DIRECTORY", help="Enter parent directory that contains cruise folders")
    parser.add_argument("startswith", metavar="CHARACTER", help="Enter vessel letter (e.g. 'SO' for SONNE) to filter directories")
    args = parser.parse_args()
    [print(cruise_dir.name) for cruise_dir in os.scandir(args.path) if cruise_dir.is_dir() and cruise_dir.name.startswith(args.startswith)]
    [create_dirs(cruise_dir) for cruise_dir in os.scandir(args.path) if cruise_dir.is_dir() and cruise_dir.name.startswith(args.startswith)]
