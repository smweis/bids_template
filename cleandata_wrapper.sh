#!/bin/bash

log_dir="/blue/stevenweisberg/share/DSP_fMRI/code/logs"
cd log_dir
# for more than one subject:
# subjects=('dspfmri12003' 'dspfmri11002')

subjects=('2101')

for subID in "${subjects[@]}"
do
  sbatch /blue/stevenweisberg/share/DSP_fMRI/code/analysis/clean_fmriprep_data.sh $subID dspfmri
done
