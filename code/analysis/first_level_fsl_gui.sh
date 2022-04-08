#!/bin/bash
#SBATCH --account=stevenweisberg
#SBATCH --qos=stevenweisberg
#SBATCH --job-name=first_level_fsl
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=stevenweisberg@ufl.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#pwd; hostname; date

# SW 2/10/2022

ml fsl/6.0.5

feat /blue/stevenweisberg/share/DSP_fMRI/code/fsl_gui/design.fsf
