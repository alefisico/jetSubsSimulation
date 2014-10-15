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

stop1=200	## You can use this parameters later to make everything simpler. 
stop2=250	## You can use this parameters later to make everything simpler. Now I am not using them at all

totalNumberEvents=100000

Name=RPVSt${stop1}tojj_13TeV_pythia8
LHEFile=/store/user/algomez/RPVSttojj_13TeV/RPVSt200tojj_13TeV.lhe					#### DONT USE the entire eos path!!!!!

PU=( 'PU20bx25' 'PU40bx25' 'PUbx50' )									#### You can remove the PU scenario that you are not going to use.




#####################################################
#### Here is where the code starts.. 
#### Initially you shouldn't modify this part
#####################################################
echo " Creating directories..."
Main_Dir=$PWD 
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
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT.py  ${step1PythonFile}'PU20bx25.py'
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT.py  ${step1PythonFile}'PU40bx25.py'
cp ${Main_Dir}/step1_DIGI_LI_DIGI2RAW_HLT.py  ${step1PythonFile}'PU40bx50.py'

sed -i 's/inputFile/'"${Name}"'_RAWSIM_PU20bx25/' ${step1PythonFile}'PU20bx25.py'
sed -i 's/inputFile/'"${Name}"'_RAWSIM_PU40bx25/' ${step1PythonFile}'PU40bx25.py'
sed -i 's/process.mix.input.nbPileupEvents.averageNumber = cms.double(20.000000)/process.mix.input.nbPileupEvents.averageNumber = cms.double(40.000000)/' ${step1PythonFile}'PU40bx25.py'
sed -i 's/inputFile/'"${Name}"'_RAWSIM_PU40bx50/' ${step1PythonFile}'PU40bx50.py'
sed -i 's/process.mix.bunchspace = cms.int32(25)/process.mix.bunchspace = cms.int32(50)/' ${step1PythonFile}'PU40bx50.py'
sed -i 's/process.mix.input.nbPileupEvents.averageNumber = cms.double(20.000000)/process.mix.input.nbPileupEvents.averageNumber = cms.double(40.000000)/' ${step1PythonFile}'PU40bx50.py'
sed -i 's/POSTLS170_V7/POSTLS170_V6A/' ${step1PythonFile}'PU40bx50.py'

echo " Creating python file for AODSIM (different PU scenarios).. "
step2PythonFile="step2_${Name}_RAW2DIGI_L1Reco_RECO_"
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU20bx25.py'
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU40bx25.py'
cp ${Main_Dir}/step2_RAW2DIGI_L1Reco_RECO.py  ${step2PythonFile}'PU40bx50.py'
sed -i 's/inputFile/'"${Name}"'_AODSIM_PU20bx25/' ${step2PythonFile}'PU20bx25.py'
sed -i 's/inputFile/'"${Name}"'_AODSIM_PU40bx25/' ${step2PythonFile}'PU40bx25.py'
sed -i 's/inputFile/'"${Name}"'_AODSIM_PU40bx50/' ${step2PythonFile}'PU40bx50.py'
sed -i 's/POSTLS170_V7/POSTLS170_V6A/' ${step2PythonFile}'PU40bx50.py'

echo " Creating python file for MiniAOD (different PU scenarios).. "
step3PythonFile="step3_${Name}_MiniAOD_"
cp ${Main_Dir}/step3_MiniAOD.py  ${step3PythonFile}'PU20bx25.py'
cp ${Main_Dir}/step3_MiniAOD.py  ${step3PythonFile}'PU40bx25.py'
cp ${Main_Dir}/step3_MiniAOD.py  ${step3PythonFile}'PU40bx50.py'
sed -i 's/inputFile/'"${Name}"'_MiniAOD_PU20bx25/' ${step3PythonFile}'PU20bx25.py'
sed -i 's/inputFile/'"${Name}"'_MiniAOD_PU40bx25/' ${step3PythonFile}'PU40bx25.py'
sed -i 's/inputFile/'"${Name}"'_MiniAOD_PU40bx50/' ${step3PythonFile}'PU40bx50.py'

########################################################
######### Small file with the commands for condor
########################################################
echo " Creating crab files .... "
crabFileStep0=crab2_${Name}_GENSIM_step0.cfg
cp ${Main_Dir}/crab2.cfg  ${crabFileStep0}
sed -i 's/test/'"${step0PythonFile}"'/' ${crabFileStep0}
sed -i 's/NAME/'"${Name}"'_GENSIM_v706/' ${crabFileStep0}

crabFileStep1=crab2_${Name}_RAWSIM_step1_
crabFileStep2=crab2_${Name}_AODSIM_step2_
crabFileStep3=crab2_${Name}_MiniAOD_step3_
for i in ${PU[@]}; do
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep1}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep1}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep1}${i}'.cfg'
	sed -i 's/test/'"${step1PythonFile}${i}"'/' ${crabFileStep1}${i}'.cfg'
	sed -i 's/NAME/'"${Name}"'_RAWSIM_v706_'"${i}"'/' ${crabFileStep1}${i}'.cfg'
#	sed -i 's/remoteGlidein/condor/' ${crabFileStep1}${i}'.cfg'
	sed -i 's/^#//' ${crabFileStep1}${i}'.cfg'
	sed -i 's/None/ADD_YOUR_DATASET_HERE/' ${crabFileStep1}${i}'.cfg'
	sed -i 's/generator = lhe/dbs_url = phys03/' ${crabFileStep1}${i}'.cfg'

	cp ${Main_Dir}/crab2.cfg  ${crabFileStep2}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep2}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep2}${i}'.cfg'
	sed -i 's/test/'"${step2PythonFile}${i}"'/' ${crabFileStep2}${i}'.cfg'
	sed -i 's/NAME/'"${Name}"'_AODSIM_v706_'"${i}"'/' ${crabFileStep2}${i}'.cfg'
#	sed -i 's/remoteGlidein/condor/' ${crabFileStep2}${i}'.cfg'
	sed -i 's/^#//' ${crabFileStep2}${i}'.cfg'
	sed -i 's/None/ADD_YOUR_DATASET_HERE/' ${crabFileStep2}${i}'.cfg'
	sed -i 's/generator = lhe/dbs_url = phys03/' ${crabFileStep2}${i}'.cfg'

	cp ${Main_Dir}/crab2.cfg  ${crabFileStep3}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep3}${i}'.cfg'
	cp ${Main_Dir}/crab2.cfg  ${crabFileStep3}${i}'.cfg'
	sed -i 's/test/'"${step3PythonFile}${i}"'/' ${crabFileStep3}${i}'.cfg'
	sed -i 's/NAME/'"${Name}"'_MiniAOD_v706_'"${i}"'/' ${crabFileStep3}${i}'.cfg'
	sed -i 's/^#//' ${crabFileStep3}${i}'.cfg'
	sed -i 's/None/ADD_YOUR_DATASET_HERE/' ${crabFileStep3}${i}'.cfg'
	sed -i 's/generator = lhe/dbs_url = phys03/' ${crabFileStep3}${i}'.cfg'
done

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

Once you have the dataset from step0 or step1, for example:
sed -i "s/ADD_YOUR_DATASET_HERE/\/RPVSt100tojj_13TeV_pythia8_GENSIM\/algomez-RPVSt100tojj_13TeV_pythia8_GENSIM-62459d50bdc5c4568f334137235e3bfc\/USER/g" crab2*RAWSIM*
' >> README

echo 'Crab instructions in the README file'
echo 'Have a nice day :D '

