#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=mriqc_SUB_sed
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=elianyperez@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

#EP 7/1/21

module load singularity
echo "SUB_sed"

#directories
BIDS_dir=BIDS_DIR_sed
singularity_dir=SINGULARITY_DIR_sed
mriqc_derivatives_dir=MRIQC_DERIVATIVES_DIR_sed
work_dir=WORK_DIR_sed
mriqc_version=mriqc-0.16.1.simg #might need to update
#fd_thres=3 #set this to voxel size maybe


#running mriqc
singularity run --cleanenv $singularity_dir/$mriqc_version $BIDS_dir $mriqc_derivatives_dir participant --participant-label SUB_sed --fd_thres 3 --mem 120000 --work-dir $work_dir --float32
