# This script synchronises bathy files from MDM to local disk
# Usage: python3 Sync_files.py src dst
# Example: python Sync_files.py SO/EM122/SO294/  SO294/raw/EM122/

import os
import subprocess
import sys

# Global paths
src_path=os.path.abspath("/Volumes/projects/p_mdm/mdm")
dst_path=os.path.abspath("/Users/hiwi/DataOnDisk/Pangaea/00_from_MDM")
suffix_src = sys.argv[1]
suffix_dst = sys.argv[2]
src = os.path.join(src_path, suffix_src)
dst = os.path.join(dst_path, suffix_dst)
# print('dst: ', dst)

def create_dirs():

    """
    Define paths and creates destination dir;
    Also creates product folders: {cruise_name}_products 
    and a metadata text file: {cruise_name}_fileinfo.txt
    """

    # get cruise name & which mbes (e.g. EM122)
    cruise=suffix_dst.split('/')[0]
    raw=suffix_dst.split('/')[1]
    mbes=suffix_dst.split('/')[2]
    print('mbes: ', mbes)
    print('raw: ', raw)


    # Create Cruise Folder, raw folder inside and EMXXX inside raw
    cruise_dst = os.path.join(dst_path, cruise)
    raw_dst = os.path.join(cruise_dst, raw)
    mbes_dst = os.path.join(raw_dst, mbes)
    print('mbes_dst: ', mbes_dst)
    print('raw_dst: ', raw_dst)

    meta_dst = os.path.join(cruise_dst, '_metadata')
    protocol_dst = os.path.join(cruise_dst, '_protocols')
    svp_dst = os.path.join(cruise_dst, '_svp')
    misc_dst = os.path.join(cruise_dst, '_misc')

     # Create product folders
    product = str(cruise + '_products')
    fileinfo = str(cruise + '_fileinfo.txt')
    product_path = os.path.join(cruise_dst, product)
    grd_path = os.path.join(product_path, '_grd')
    xyz_path = os.path.join(product_path, '_xyz')
    gsf_path = os.path.join(product_path, '_gsf')
    fileinfo_path = os.path.join(cruise_dst, fileinfo)

    if not os.path.exists(cruise_dst):
        os.mkdir(cruise_dst)
    else:
        print(cruise_dst, ' already exists.')
    

    if not os.path.exists(raw_dst):
        os.mkdir(raw_dst)
    else:
        print(raw_dst, ' already exists.')

    if not os.path.exists(mbes_dst):
        os.mkdir(mbes_dst)
    else:
        print(mbes_dst, ' already exists.')

    
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
            text = [ mbes, 'MDM paths: ', '-> Append folders in cruise folder!', src, '\n', 'corrupted files:', '\n', 'EEZ/s:']
            file.write('\n' .join(text))
            
    else:
        with open(fileinfo_path, 'a') as file:
            text = [ '\n', mbes, 'MDM paths: ', '-> Append folders in cruise folder!', src, '\n', 'corrupted files:', '\n', 'EEZ/s:' ]
            file.write('\n' .join(text))
            print(fileinfo_path, ' already exists. Appended Info for ', mbes)


if True:
    def copy_mbes():
        """
        runs rsync on source & destination dirs
        Parameters:
            - exclude: .wcd data
            - ignore-existing: skip updating files that already exist on receiver
            - progress: show copying progress
            - src: MDM folder
            - dst: local drive (see create_dirs())
        """
        print('copying from ', src, ' to ', dst)

        #find_cmd = [ 'find', src, '-type', 'f' ]
        #count_cmd = [ 'wc', '-l' ]
        #sync_cmd = ['time', 'rsync', '-avh', '-r', '--exclude', '*.wcd', '--ignore-existing', '--progress', src, dst ]

        sync_cmd = ['time', 'rsync', '-avh', '-r', '-m', '--include', '*/', '--include', '*.*all', '--exclude', '*.*wcd', '--ignore-existing', '--progress', src, dst ]
        pv_cmd = ['pv', '-lep', '-s', '2000']
        sync = subprocess.Popen(sync_cmd, stdout=subprocess.PIPE)
        subprocess.run(pv_cmd, stdin=sync.stdout, check=True)



if __name__ == '__main__':
    if os.path.exists(src):
        create_dirs() 
        copy_mbes()