#!/bin/bash 

####################################################
###
###  Simple bash script to copy a hadronizer and send jobs to crab.
###
###  Alejandro Gomez Espinosa
###  gomez@physics.rutgers.edu
###
###  How to run: 
###  source createJobs_CRAB.sh
###  (If it is an executable (chmod +x createJobs.sh):
###  ./createJobs_CRAB.sh 
###
###  You must change the PARAMETERS according with your needs. Initially is the only part that you should modify.
###
####################################################

######################################
### PARAMETERS
#####################################

user=${USER}
stop1=100	## You can use this parameters later to make everything simpler. Now I am not using them at all
stop2=250	## You can use this parameters later to make everything simpler. Now I am not using them at all

numJobs=400
totalNumberEvents=100000
Energy=13000

Main_Dir=/uscms_data/d3/algomez/Substructure/Simulation/CMSSW_5_3_2_patch4/src/jetSubsSimulation/ # Main Dir
Name=SbtoWSt_RPVSttojj_13TeV 
#Name=RPVSt${stop1}tojj_8TeV_HT500		 						# Example how to use the stop1 parameters
LHE_File=/uscms_data/d3/algomez/files/SbtoWSt_RPVSttojj_13TeV/lhe/unweighted_500SbtoWSt_100RPVSttojj_13TeV_100K_fixed.lhe				# lhe file, write the whole path.
hadronizer=templates/Hadronizer_TuneD6T_8TeV_madgraph_tauola_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU_2.py				# make sure that you have the hadronizer in your templates folder.

#####################################################
#### Here is where the code starts.. 
#### Initially you shouldn't modify this part
#####################################################
echo " Creating directories..."
####### Working directory
Working_Dir=${Main_Dir}/${Name}	
if [ -d $Working_Dir ]; then
	rm -rf $Working_Dir
	mkdir -p $Working_Dir
else
	mkdir -p $Working_Dir
fi

Output_Dir=/eos/uscms/store/user/algomez/${Name}/lhe/
if [ -d $Output_Dir ]; then
	rm -rf $Output_Dir
	mkdir -p $Output_Dir
else
	mkdir -p $Output_Dir
fi

echo " Copying LHE file to EOS area ..." 
cp ${LHE_File} ${Output_Dir}/${Name}.lhe

cd $Working_Dir/


##############################################
##### Create the python file for Ntuples
##############################################
echo " Creating Hadronizer file... "
namePythonFile=${Name}_Hadronizer.py
if [ -f $namePythonFile ]; then
	rm -rf $namePythonFile
fi

cp ${Main_Dir}/${hadronizer} ${namePythonFile} 

sed -i 's,file:test.lhe,root://xrootd.unl.edu//store/user/'"${user}"'/'"${Name}"'/lhe/'"${Name}"'.lhe,' ${namePythonFile}
sed -i 's/8000/'"${Energy}"'/' ${namePythonFile}

########################################################
######### Small file with the commands for condor
########################################################
echo " Creating crab file .... "
crabFile=crab_${Name}.cfg
if [ -f $crabFile ]; then
	rm -rf $crabFile
fi
echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = None
generator = lhe
pset = '${namePythonFile}'
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = '${numJobs}'
get_edm_output = 1
output_file = '${Name}.root'
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 0
storage_element = cmseos.fnal.gov 
storage_path = /srm/v2/server?SFN=/eos/uscms/store/user/'${user}'/
user_remote_dir = '${Name}'
check_user_remote_dir = 0
ui_working_dir = '${Name}'

[GRID]
max_wall_time = 4800'>> ${crabFile}

#################################
##### To make it run
#################################
echo ' To make it run: 
First load the libraries (only once per session):
source /uscmst1/prod/grid/gLite_SL5.sh
source /uscmst1/prod/grid/CRAB/crab.sh

Create and submit your jobs:
cd '${Name}'
crab -create -cfg '${crabFile}' 
crab -submit -cfg '${crabFile}' 

or just:
crab -create -submit -cfg '${crabFile}' 

To check the status:
crab -status -c '${Name}'

Have a nice day :D '

