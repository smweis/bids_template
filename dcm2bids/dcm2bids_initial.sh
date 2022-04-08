#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=dcm2bids_SUB_sed
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=elianyperez@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=5gb
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

# script for running dcm2bids
# You will need one config file for each subject and each session. You can use one config file if all the runs are the same between participants, but that is unlikely.
# EP 6/27/21

#directories
#singularity_dir=SINGULARITY_DIR_sed
#singularity_version=reproin.sif
BIDS_dir=BIDS_DIR_sed
sourcedata_dir=SOURCEDATA_DIR_sed
dcm2bids_dir=DCM2B_DIR_sed
subID=SUB_sed
#config_dir=CONFIG_DIR_sed

#loading modules
module load mricrogl/20210327
module load python


# loops through sessions. Get rid of this loop entirely if there is only one session. Also get rid of '-s 0${ses}' in step 2
#for ses in 1
#do


# selects the correct subject and session config file. these MUST be created before running this script. Change the .json name as needed.
config_json=$dcm2bids_dir/config_dir/dcm2bids_DSP_config_${subID}.json #for multiple sessions

cd $BIDS_dir
# Step 1: converts the dicoms into nifti files and puts them in a temporary folder
#dcm2bids_helper -d $sourcedata_dir/$SUB/ses-0${ses} #for multiple sessions
mkdir -p tmp_dcm2bids/sub-${subID}
echo $BIDS_dir/tmp_dcm2bids/sub-${subID}
echo $sourcedata_dir/$subID
# Info here - https://www.nitrc.org/plugins/mwiki/index.php/dcm2nii:MainPage#General_Usage
dcm2niix -b y -ba y -z y -f '%3s_%f_%p' -i y -o $BIDS_dir/tmp_dcm2bids/sub-${subID} $sourcedata_dir/$subID

# Step 2: moves the niftis from the temporary folder into BIDS named folder
#dcm2bids -d $sourcedata_dir/$SUB/ses-0${ses} -p $SUB -s 0${ses} -c $code_dir/$config_json #for multiple sessions
dcm2bids -d $sourcedata_dir/$subID -p $subID -c $config_json

#removes the temporary folder
rm -R $BIDS_dir/tmp_dcm2bids/sub-${subID}


# Some of the anat processing moves over the T1 files in separate runs. This cleans that up.
# Grab the largest T1 file and rename it to omit the 'run' (if it exists)
largestT1=($(du -a $BIDS_dir/sub-${subID}/anat/*T1* | sort -n -r | head -n 1))
mv ${largestT1[1]} $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz
# Same thing for the sidecar
largestJson=${largestT1[1]::-7}.json
mv ${largestJson} $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.json
# Remove the rest of the files in the anat directory with run in them
rm $BIDS_dir/sub-${subID}/anat/*run*

# Change permissions to group
cd $BIDS_dir/sub-${subID}
chmod -R -f 00771 ./ || :
