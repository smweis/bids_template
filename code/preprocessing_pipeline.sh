#!/bin/bash
#Original code by Rebecca Polk
#EP 6/22/2021
#SMW 4/8/2022
#
#This script is a preprocessing pipeline for the a BIDS template directory
#Once new data is placed in the /sourcedata, this script can be run
#This script converts /sourcedata files to BIDS, defaces the BIDS data, performs quality checks with MRIQC, and preprocesses using fMRIprep
#Cannot do all at once -- run in steps: 1=BIDS; 2=deface; 3=MRIQC; 4= fMRIprep
#
#

# TO RUN:

#bash preprocessing_pipeline subid taskid

subID=$1

#process in steps
#1=BIDS; 2=deface; 3=MRIQC; 4= fMRIprep
step=$2

#setting up directories:

### EDIT THESE THREE
# Top level bids directory
BIDS_dir=/blue/stevenweisberg/share/DSP_fMRI
freesurfer_license_dir=/blue/stevenweisberg/elianyperez/code/fmriprep
work_dir=/blue/stevenweisberg/share/tmp

# The rest of the directories
sourcedata_dir=$BIDS_dir/sourcedata
singularity_dir=$BIDS_dir/code/singularities
dcm2bids_dir=$BIDS_dir/code/dcm2bids
pydeface_code_dir=$BIDS_dir/code/pydeface
mriqc_code_dir=$BIDS_dir/code/mriqc
fmriprep_code_dir=$BIDS_dir/code/fmriprep
mriqc_derivatives_dir=$BIDS_dir/derivatives/mriqc/
fmriprep_derivatives_dir=$BIDS_dir/derivatives

#participants to run
#for subID in dspfmri12001

#all subs: dspfmri12001
#need BIDS:
#need defacing:
#need MRIQC:
#need fMRIprep:
#do


#BIDS conversion using dcm2bids
if [[ $step == "1" ]]; then

 # Check if we have a dcm2bids script file for that subject already.
  if ! [ -f $dcm2bids_dir/dcm2bids_${subID}.sh ]; then
    cp $dcm2bids_dir/dcm2bids_initial.sh $dcm2bids_dir/dcm2bids_${subID}.sh
  fi

  # Check if we have a config file for that subject already.
  if ! [ -f $dcm2bids_dir/config_dir/dcm2bids_config_${subID}.json ]; then
    cp $dcm2bids_dir/config_dir/dcm2bids_config.json $dcm2bids_dir/config_dir/dcm2bids_config_${subID}.json
  fi

  #sub file inside sourcedata. where the actual subject level data is located
  #sub_file=ARROWS_${subID}

  #renames variables
  sed -i -e "s|SUB_sed|${subID}|g" $dcm2bids_dir/dcm2bids_${subID}.sh
  sed -i -e "s|BIDS_DIR_sed|${BIDS_dir}|g" $dcm2bids_dir/dcm2bids_${subID}.sh
  sed -i -e "s|DCM2B_DIR_sed|${dcm2bids_dir}|g" $dcm2bids_dir/dcm2bids_${subID}.sh
  sed -i -e "s|SOURCEDATA_DIR_sed|${sourcedata_dir}|g" $dcm2bids_dir/dcm2bids_${subID}.sh


   #runs subject-level preprocessing scripts via sbatch on the hipergator
   sbatch $dcm2bids_dir/dcm2bids_${subID}.sh

fi


#defacing BIDS data
if [[ $step == "2" ]]; then

  cp $pydeface_code_dir/pydeface_initial.sh $pydeface_code_dir/pydeface_${subID}.sh

  sed -i -e "s|SUB_sed|${subID}|g" $pydeface_code_dir/pydeface_${subID}.sh
  sed -i -e "s|BIDS_DIR_sed|${BIDS_dir}|g" $pydeface_code_dir/pydeface_${subID}.sh
  sed -i -e "s|PYDEFACE_DIR_sed|${pydeface_code_dir}|g" $pydeface_code_dir/pydeface_${subID}.sh

  #runs subject-level preprocessing scripts via sbatch on the hipergator
  sbatch $pydeface_code_dir/pydeface_${subID}.sh

fi


#running MRIQC
if [[ $step == "3" ]]; then

  cp $mriqc_code_dir/mriqc_initial.sh $mriqc_code_dir/mriqc_${subID}.sh

  sed -i -e "s|SUB_sed|${subID}|g" $mriqc_code_dir/mriqc_${subID}.sh
  sed -i -e "s|BIDS_DIR_sed|${BIDS_dir}|g" $mriqc_code_dir/mriqc_${subID}.sh
  sed -i -e "s|SINGULARITY_DIR_sed|${singularity_dir}|g" $mriqc_code_dir/mriqc_${subID}.sh
  sed -i -e "s|MRIQC_DERIVATIVES_DIR_sed|${mriqc_derivatives_dir}|g" $mriqc_code_dir/mriqc_${subID}.sh
  sed -i -e "s|WORK_DIR_sed|${work_dir}|g" $mriqc_code_dir/mriqc_${subID}.sh

  #runs subject-level preprocessing scripts via sbatch on the hipergator
  sbatch $mriqc_code_dir/mriqc_${subID}.sh

fi


#running fMRIprep
if [[ $step == "4" ]]; then

 # Check if we have a dcm2bids script file for that subject already.
  if ! [ -f $fmriprep_code_dir/fmriprep_${subID}.sh ]; then
    cp $fmriprep_code_dir/fmriprep_initial.sh $fmriprep_code_dir/fmriprep_${subID}.sh
  fi



  sed -i -e "s|SUB_sed|${subID}|g" $fmriprep_code_dir/fmriprep_${subID}.sh
  sed -i -e "s|BIDS_DIR_sed|${BIDS_dir}|g" $fmriprep_code_dir/fmriprep_${subID}.sh
  sed -i -e "s|FMRIPREP_DERIVATIVES_DIR_sed|${fmriprep_derivatives_dir}|g" $fmriprep_code_dir/fmriprep_${subID}.sh
  sed -i -e "s|FREESURFER_LICENSE_sed|${freesurfer_license_dir}|g" $fmriprep_code_dir/fmriprep_${subID}.sh
  sed -i -e "s|SINGULARITY_sed|${singularity_dir}|g" $fmriprep_code_dir/fmriprep_${subID}.sh
  sed -i -e "s|WORK_DIR_sed|${work_dir}|g" $fmriprep_code_dir/fmriprep_${subID}.sh

  #runs subject-level preprocessing scripts via sbatch on the hipergator
  sbatch $fmriprep_code_dir/fmriprep_${subID}.sh

fi

#final done for participants
#done
