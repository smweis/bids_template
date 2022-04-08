#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=pydeface_SUB_sed
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=elianyperez@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5gb
#SBATCH --time=01:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

#This code defaces BIDS-compliant T1 data using pydeface.
#Outputs 2 files for notes -- participants who are missing T1 data, and participants whose T1 data did not successfully deface.

#MUST SET THESE
BIDS_dir=BIDS_DIR_sed
warning_dir=PYDEFACE_DIR_sed #I do not recommend this to be the same as your BIDS folder

module load pydeface
module load fsl/6.0.4

for subID in SUB_sed
do


#checking if T1 exists
if [ -f $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz ];

    fslreorient2std $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz

    #run pydeface
    then pydeface $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz

    #checking if pydeface ran successfully
    if [ -f $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w_defaced.nii.gz ];
    then
      #remove the old T1 (that is not defaced)
      #then rm sub-${subID}_T1w.nii
      #rename the defaced T1 to be BIDS compliant
      mv $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w_defaced.nii.gz $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w.nii.gz

    #if pydeface did not run successfully
    else
      if [ ! -f $BIDS_dir/sub-${subID}/anat/sub-${subID}_T1w_defaced.nii.gz ]; then
      #make a note of the participant who was not defaced
      echo "pydeface failed for sub-${SUB}" >> $warning_dir/pydeface_failed_files.txt
      fi
    fi

#if T1 does not exist
else
    if [ ! -f $BIDS_dir/sub-${SUB}/anat/sub-${SUB}_T1w.nii.gz ]; then
    #make a note. check this later to make sure missing files are supposed to be missing
    echo "T1 does not exist for sub-${SUB}" >> $warning_dir/pydeface_nonexistant_files.txt
    fi
fi


done
