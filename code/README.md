## Step 1. Make sure raw data are ready to analyze and backed up.
- Verify that subject data is complete.
  - Does each scan have data?
  - Are all expected scans there?
  - Did you make a note if any scans that should be there are not there?
- Verify that subject data is on `/orange/stevenweisberg/[project folder]`

## Step 2. Create your template BIDS directory.
  We'll refer to your top level BIDS directory as BIDS_dir. Each subject needs a BIDS formatted ID. BIDS IDs don't contain any spaces, special characters, hyphens (-), or underscores (_). `sub-[projName][IDnumber]` is a good practice.
  - Project name should be the top level directory.
  - Transfer the raw data (DICOMs) from `/orange/` to `BIDS_dir/sourcedata/subID`

## Step 3. Convert raw subject data into BIDS formatted data.
  Note, if this is your **first** subject, or you have made modifications to the protocol, you'll need to modify the config file (a `.json` file you will find in `BIDS_dir/code/dcm2bids/config_dir`.

  
