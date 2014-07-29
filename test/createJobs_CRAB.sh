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

Main_Dir=/uscms_data/d3/algomez/Substructure/Simulation/CMSSW_6_2_5/src/mySIM13TeV/jetSubsSimulation/test/ # Main Dir
Name=RPVSt${stop1}tojj_13TeV_PU20bx25		
LHEFile=/store/user/algomez/RPVSttojj_13TeV/RPVSt200tojj_13TeV.lhe					# lhe file

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

cd $Working_Dir/


##############################################
##### Create the python file for Ntuples
##############################################
echo " Creating python file for GEN-SIM .. "

step0PythonFile="step0_${Name}_LHE_GEN_SIM.py"
cp ${Main_Dir}/step0_LHE_GEN_SIM.py  ${step0PythonFile}

sed -i 's,/store/user/algomez/RPVSttojj_13TeV/RPVSt200tojj_13TeV.lhe,'"${LHEFile}"',' ${step0PythonFile}
sed -i 's/RPVSt200tojj_13TeV_PU20bx25_GEN.root/'"${Name}"'_GEN.root/' ${step0PythonFile}

########################################################
######### Small file with the commands for condor
########################################################
echo " Creating crab file .... "
crabFile=crab_${Name}__GENSIM.cfg
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
pset = '${step0PythonFile}'
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = '${numJobs}'
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_GENSIM
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_GENSIM
check_user_remote_dir = 0
ui_working_dir = '${Name}'_GENSIM
'>> ${crabFile}

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

When your jobs are done:
crab -report -c '${Name}'

To publish:

Have a nice day :D '

