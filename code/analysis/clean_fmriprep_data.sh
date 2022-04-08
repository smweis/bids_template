#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=clean_data
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=stevenweisberg@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

# SW 1/20/2022

cd /blue/stevenweisberg/share/DSP_fMRI/code/logs

ml python
ml fsl/6.0.5

python /blue/stevenweisberg/share/DSP_fMRI/code/analysis/clean_fmriprep_data.py --fmriprepdir /blue/stevenweisberg/share/DSP_fMRI/derivatives --outputdir /blue/stevenweisberg/share/DSP_fMRI/derivatives/clean_data --subj $1 --task $2 -d