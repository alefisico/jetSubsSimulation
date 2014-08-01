#!/bin/bash 

###########################################################################
###
###  Simple bash script to create python files for simulation.
###
###  Alejandro Gomez Espinosa
###  gomez@physics.rutgers.edu
###
###  How to run: 
###  source createJobs_CRAB.sh
###  (If it is an executable (chmod +x createJobs.sh):
###  ./createJobs_CRAB.sh 
###
###  You must change the PARAMETERS according with your needs. 
###  Initially is the only part that you should modify.
###
###########################################################################

######################################
### PARAMETERS
#####################################

user=${USER}
stop1=200	## You can use this parameters later to make everything simpler. 
stop2=250	## You can use this parameters later to make everything simpler. Now I am not using them at all

totalNumberEvents=100000

Main_Dir=/uscms_data/d3/algomez/Substructure/Simulation/CMSSW_6_2_5/src/mySIM13TeV/jetSubsSimulation/test/ 
Name=RPVSt${stop1}tojj_13TeV_pythia8
LHEFile=/store/user/algomez/RPVSttojj_13TeV/RPVSt200tojj_13TeV.lhe					#### DONT USE the entire eos path!!!!!




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

echo " Creating python file for RAWSIM (different PU scenarios).. "
step1PythonFile="step1_${Name}_DIGI_LI_DIGI2RAW_HLT_"
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT_PU20bx25.py  ${step1PythonFile}'PU20bx25.py'
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT_PU20bx25.py  ${step1PythonFile}'PU40bx25.py'
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT_PU20bx25.py  ${step1PythonFile}'PU40bx50.py'

sed -i 's/RPVSt100tojj_13TeV_PU20bx25_step1/'"${Name}"'_RAWSIM_PU20bx25/' ${step1PythonFile}'PU20bx25.py'
sed -i 's/RPVSt100tojj_13TeV_PU20bx25_step1/'"${Name}"'_RAWSIM_PU40bx25/' ${step1PythonFile}'PU40bx25.py'
sed -i 's/process.mix.input.nbPileupEvents.averageNumber = cms.double(20.000000)/process.mix.input.nbPileupEvents.averageNumber = cms.double(40.000000)/' ${step1PythonFile}'PU40bx25.py'
sed -i 's/RPVSt100tojj_13TeV_PU20bx25_step1/'"${Name}"'_RAWSIM_PU40bx50/' ${step1PythonFile}'PU40bx50.py'
sed -i 's/process.mix.bunchspace = cms.int32(25)/process.mix.bunchspace = cms.int32(50)/' ${step1PythonFile}'PU40bx50.py'
sed -i 's/process.mix.input.nbPileupEvents.averageNumber = cms.double(20.000000)/process.mix.input.nbPileupEvents.averageNumber = cms.double(40.000000)/' ${step1PythonFile}'PU40bx50.py'

echo " Creating python file for AODSIM (different PU scenarios).. "
step2PythonFile="step2_${Name}_RAW2DIGI_L1Reco_RECO_"
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU20bx25.py'
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU40bx25.py'
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU40bx50.py'
sed -i 's/RPVSt200tojj_13TeV_AODSIM_test/'"${Name}"'_AODSIM_PU20bx25/' ${step2PythonFile}'PU20bx25.py'
sed -i 's/RPVSt200tojj_13TeV_AODSIM_test/'"${Name}"'_AODSIM_PU40bx25/' ${step2PythonFile}'PU40bx25.py'
sed -i 's/RPVSt200tojj_13TeV_AODSIM_test/'"${Name}"'_AODSIM_PU40bx50/' ${step2PythonFile}'PU40bx50.py'

########################################################
######### Small file with the commands for condor
########################################################
echo " Creating crab files .... "
crabFileStep0=crab_${Name}_GENSIM_step0.cfg
if [ -f $crabFileStep0 ]; then
	rm -rf $crabFileStep0
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
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_GENSIM
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_GENSIM
check_user_remote_dir = 0
ui_working_dir = '${Name}'_GENSIM
'>> ${crabFileStep0}

crabFileStep1=crab_${Name}_RAWSIM_step1_
echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step1PythonFile}'PU20bx25.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_RAWSIM_625_PU20bx25
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU20bx25
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU20bx25

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep1}'PU20bx25.cfg'

echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step1PythonFile}'PU40bx25.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
publish_data_name = '${Name}'_RAWSIM_625_PU40bx25
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU40bx25
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU40bx25

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep1}'PU40bx25.cfg'

echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step1PythonFile}'PU40bx50.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_RAWSIM_625_PU40bx50
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU40bx50
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU40bx50

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep1}'PU40bx50.cfg'


crabFileStep2=crab_${Name}_AODSIM_step2_
echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step2PythonFile}'PU20bx25.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_RAWSIM_625_PU20bx25
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU20bx25
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU20bx25

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep2}'PU20bx25.cfg'

echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step2PythonFile}'PU40bx25.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
publish_data_name = '${Name}'_RAWSIM_625_PU40bx25
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU40bx25
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU40bx25

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep2}'PU40bx25.cfg'

echo '[CRAB]
jobtype = cmssw
scheduler = remoteGlidein
use_server = 0

[CMSSW]
datasetpath = ADD_YOUR_DATASET_HERE
dbs_url=phys03
pset = '${step2PythonFile}'PU40bx50.py
total_number_of_events = '${totalNumberEvents}'
number_of_jobs = 1000
get_edm_output = 1
allow_NonProductionCMSSW = 1

[USER]
return_data = 0
copy_data = 1
publish_data = 1
publish_data_name = '${Name}'_RAWSIM_625_PU40bx50
dbs_url_for_publication =https://cmsdbsprod.cern.ch:8443/cms_dbs_ph_analysis_01_writer/servlet/DBSServlet
storage_element = T3_US_FNALLPC
user_remote_dir = '${Name}'_RAWSIM_625_PU40bx50
check_user_remote_dir = 0
ui_working_dir = '${Name}'_RAWSIM_625_PU40bx50

[GRID]
data_location_override=T1_US_FNAL_Disk
'>> ${crabFileStep2}'PU40bx50.cfg'




#################################
##### To make it run
#################################
echo ' To make it run: 
First load the libraries (only once per session):
source /uscmst1/prod/grid/gLite_SL5.sh
source /uscmst1/prod/grid/CRAB/crab.sh

Create and submit your jobs (Example for step0):
cd '${Name}'
crab -create -cfg '${crabFileStep0}' 
crab -submit NUMBER_JOBS -cfg '${crabFileStep0}' 

To check the status:
crab -status -c '${Name}'_GENSIM

To resubmit failed jobs:
crab -resubmit LIST_OF_FAILED_JOBS  -c '${Name}'_GENSIM 

When your jobs are done:
crab -report -c '${Name}'_GENSIM

To publish:
crab -publish -c '${Name}'_GENSIM

Have a nice day :D '

