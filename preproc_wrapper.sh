#!/bin/bash
#1=dcm2bids; 2=pydeface; 3=MRIQC; 4= fMRIprep

code_dir="/blue/stevenweisberg/share/DSP_fMRI/code"
cd $code_dir/logs

# for more than one subject:
# subjects=('12003' '11002')

subjects=('12003')

for subID in "${subjects[@]}"
do
  bash $code_dir/preprocessing_pipeline.sh $subID 4
done
