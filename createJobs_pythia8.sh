#!/bin/bash 

####################################################
###
###  Simple tcsh script to create Pattuples
###  and send jobs to condor.
###
###  Alejandro Gomez Espinosa
###  gomez@physics.rutgers.edu
###
###  How to run: 
###  source createJobs.sh
###  100 is the mass of the daugher particle and 250 of the mother
###  (If it is an executable (chmod +x run_pattuplozer_job.sh):
###  ./run_pattuplozer_job.sh 100 250
###
###  For different masses, like 250St2toSt1Z_100RPVSttojj, you may want to include the stop2 variable
###  and then the variable Name is like: ${stop2}St2toSt1Z_${stop1}RPVSttojj
###
####################################################

######################################
### PARAMETERS
#####################################

stop1=100
stop2=250											# Mass of the stop2
#foreach Process ("jj") # "bj")									# Here I have two different final states (Maybe you dont need it)

numJobs=400	
totalNumberEvents=100000
Base_Dir=/cms/gomez/Substructure/Generation/Simulation/CMSSW_5_3_2_patch4/src/			# Dir from where we have to load the enviroment
Main_Dir=${Base_Dir}tmp/							# Main Dir
Name=${stop1}RPVSttojj_8TeV_8TeVPU						# Name of the process
Working_Dir=${Main_Dir}/${Name}									# Working directory
Output_Dir=/home/gomez/mySpace/Stops/st_jj/AOD/${Name}/						# Output directory
emailForNotifications=gomez@physics.rutgers.edu
hadronizer=Hadronizer_MgmMatchTune4C_7TeV_madgraph_pythia8_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU.py

#####################################################
#### Here is where the code starts.. Do NOT change
#####################################################
eventsPerJob=$((${totalNumberEvents}/${numJobs}))

echo " Creating directories..."
####### Working directory
if [ -d $Working_Dir ]; then
	rm -rf $Working_Dir
	mkdir -p $Working_Dir 
else
	mkdir -p $Working_Dir 
fi
cd $Working_Dir

####### EOS directory for root files
if [ -d $Output_Dir ]; then
	rm -rf $Output_Dir
	mkdir -p $Output_Dir 
else
	mkdir -p $Output_Dir 
fi

##############################################
##### Create the python file for Ntuples
##############################################
echo " Creating python file... "
namePythonFile=${Name}_Hadronizer.py
if [ -f $namePythonFile ]; then
	rm -rf $namePythonFile
fi

cp ${Main_Dir}/${hadronizer} ${namePythonFile} 

sed -i 's,input = cms.untracked.int32(10),input = cms.untracked.int32('"${eventsPerJob}"'),' ${namePythonFile}
sed -i 's,test.root,file:'"${Output_Dir}"'/'"${Name}\'_"'+NUMBER+'"\'"'_AOD.root,' ${namePythonFile}


########################################################
######### Small file with the commands for condor
########################################################
echo " Creating Bash file to run in condor.... "
nameRunFile=runCondorPATtuple.sh
if [ -f $nameRunFile ]; then
	rm -rf $nameRunFile
fi
echo '#!/bin/bash

export CUR_DIR=$PWD

export LC_ALL="en_US.UTF-8"
export SCRAM_ARCH="slc5_amd64_gcc462"
export VO_CMS_SW_DIR="/cms/base/cmssoft"
export COIN_FULL_INDIRECT_RENDERING=1
source $VO_CMS_SW_DIR/cmsset_default.sh

#---------------------------------------------------------------

cd '${Base_Dir}'
eval `scramv1 runtime -sh`

cd $CUR_DIR

cmsRun '${namePythonFile}' $1 $2 '>> ${nameRunFile}

chmod +x ${nameRunFile}

########################################################
######### Here, I am creating the condor script.
########################################################
echo " Creating condor file..... "
nameCondorFile=condor_${name}_AOD.jdl
if [ -f $nameCondorFile ]; then
	rm -rf $nameCondorFile
fi
echo "universe = vanilla
Executable = ${Working_Dir}/${nameRunFile}
Notify_User = ${emailForNotifications}" >> ${nameCondorFile}

for ((version=0;version<${numJobs};version++))
do
	events=$(echo "1+(${version})*${eventsPerJob}" | bc)
	echo "
Output = ${Working_Dir}/${Name}_${version}.stdout
Error = ${Working_Dir}/${Name}_${version}.stderr
Log = ${Working_Dir}/${Name}_${version}.condorlog
Arguments = ${version} ${events} 
Queue ">> ${nameCondorFile}
done


#################################
##### Make it run
#################################
echo " Running script in condor... "
#condor_submit ${nameCondorFile}

echo " Have a nice day :D "

