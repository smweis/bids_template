#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=fmriprep_SUB_sed
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=elianyperez@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

#BP 1/19/21
# SW 7/2/21

module load singularity
echo "SUB_sed"

#directories
BIDS_dir=BIDS_DIR_sed
fmriprep_derivatives_dir=FMRIPREP_DERIVATIVES_DIR_sed
freesurfer_license_dir=FREESURFER_LICENSE_sed
singularity_dir=SINGULARITY_sed
work_dir=WORK_DIR_sed
fmriprep_version=fmriprep-21.0.0rc2.simg


#running fmriprep with ICA-AROMA
# for info on inputs, see here: https://fmriprep.org/en/stable/usage.html
# --mem is ESSENTIAL for limiting the amount of memory fmriprep has access to on your compute node
singularity run --cleanenv $singularity_dir/$fmriprep_version $BIDS_dir $fmriprep_derivatives_dir participant --participant-label SUB_sed --mem 120000 --output-space T1w MNI152NLin2009cAsym --work-dir $work_dir --fs-license-file $freesurfer_license_dir/freesurfer_license.txt --use-aroma

# Change permissions to group
cd $fmriprep_derivatives_dir/sub-${SUB_sed}
chmod -R -f 00771 ./ || :

# Change permissions to group
cd $fmriprep_derivatives_dir/sourcedata/freesurfer/sub-${SUB_sed}
chmod -R -f 00771 ./ || :
