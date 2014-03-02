#!/bin/bash

# This file sets up the bash shell for condor
# If you have additional custom enhancements to your shell 
# environment, you may need to add them here

export CUR_DIR=$PWD

export SCRAM_ARCH="slc5_amd64_gcc462"
export VO_CMS_SW_DIR="/cms/base/cmssoft"
export COIN_FULL_INDIRECT_RENDERING=1
#source $VO_CMS_SW_DIR/cmsset_default.sh
#source /uscmst1/prod/sw/cms/shrc prod
source /cms/base/cmssoft/cmsset_default.sh

# Change to your CMSSW software version
export MYREL="CMSSW_5_3_2_patch4"
export MYPROJECT="mySpace/Substructure/Generation/Simulation"
export MYBASE="${MYPROJECT}/${MYREL}"

# Shown for c shell
# Also change 'username' to your username
cd ~gomez/${MYBASE}/src
eval `scramv1 runtime -sh`
date

# Switch to your working directory below
cd  $CUR_DIR
