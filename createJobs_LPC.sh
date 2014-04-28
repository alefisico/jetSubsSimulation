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
###  (If it is an executable (chmod +x createJobs.sh):
###  ./createJobs.sh 
###
###  You must change the PARAMETERS according with your needs. Initially is the only part that you should modify.
###  For different masses, like 250St2toSt1Z_100RPVSttojj, you may want to include the stop2 variable
###  and then the variable Name is like: ${stop2}St2toSt1Z_${stop1}RPVSttojj
###  Run is very specific of what I was doing. You can leave it with 0
###
####################################################

######################################
### PARAMETERS
#####################################

user=$USER
stop1=100
stop2=250											# Mass of the stop2
numJobs=400
run=6
#foreach Process ("jj") # "bj")									# Here I have two different final states (Maybe you dont need it)

Base_Dir=/uscms_data/d3/${user}/Substructure/Simulation/CMSSW_5_3_2_patch4/src/			# Dir from where we have to load the enviroment
Main_Dir=${Base_Dir}jetSubsSimulation/								# Main Dir
#Name=${stop2}St2toSt1Z_${stop1}RPVSttojj_8TeV_8TeVPU						# Name of the process
Name=RPVSt${stop1}tojj_8TeV_HT500		 						# Name of the process
Output_Dir=/eos/uscms/store/user/${user}/${Name}/						# Output directory
LHE_File_Dir=/eos/uscms/store/user/algomez/RPVSt100tojj_8TeV_HT500/lhe/				# Directory of the lhe file.
LHE_Name=${Name}_${run}.lhe
emailForNotifications=gomez@physics.rutgers.edu
#hadronizer=Hadronizer_MgmMatchTune4C_7TeV_madgraph_pythia8_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU.py
hadronizer=templates/Hadronizer_TuneD6T_8TeV_madgraph_tauola_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU_1.py

#####################################################
#### Here is where the code starts.. 
#### Initially you shouldn't modify this part
#####################################################

echo " Creating directories..."
####### Working directory
Working_Dir=${Main_Dir}/${Name}	
if [ -d $Working_Dir ]; then
	rm -rf $Working_Dir/${Name}_${run}
	mkdir -p $Working_Dir/${Name}_${run}
else
	mkdir -p $Working_Dir/${Name}_${run} 
fi
cd $Working_Dir/${Name}_${run}

####### EOS directory for root files
if [ -d $Output_Dir ]; then
	#rm -rf $Output_Dir
	mkdir -p $Output_Dir/${Name}_${run}/lhe/
	mkdir -p $Output_Dir/${Name}_${run}/aodsim/
else
	mkdir -p $Output_Dir/${Name}_${run}/lhe/
	mkdir -p $Output_Dir/${Name}_${run}/aodsim/
fi

######## Create a symbolic link to the lhe file
#ln -s ${LHE_File_Dir}/${LHE_Name} ${Output_Dir}/${Name}_${run}/lhe/${Name}_${run}.lhe

##############################################
##### Create the python file for Ntuples
##############################################
echo " Creating python file... "
namePythonFile=${Name}_Hadronizer.py
if [ -f $namePythonFile ]; then
	rm -rf $namePythonFile
fi

cp ${Main_Dir}/${hadronizer} ${namePythonFile} 

sed -i 's/INFILENAME = /#INFILENAME =/' ${namePythonFile}
sed -i 's,print INFILENAME,INFILENAME = '"\'file:${LHE_File_Dir}""${LHE_Name}\'"',' ${namePythonFile}

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
export COIN_FULL_INDIRECT_RENDERING=1
source /uscmst1/prod/sw/cms/setup/shrc prod

#---------------------------------------------------------------

cd '${Base_Dir}'
eval `scramv1 runtime -sh`

# Switch to your working directory below
cd ${_CONDOR_SCRATCH_DIR}


cmsRun '${Working_Dir}'/'${Name}'_'${run}'/'${namePythonFile}' $1 $2 $3 $4 $5 '>> ${nameRunFile}

#chmod +x ${nameRunFile}

########################################################
######### Here, I am creating the condor script.
########################################################
echo " Creating condor file..... "
nameCondorFile=condor_${name}_AOD.jdl
if [ -f $nameCondorFile ]; then
	rm -rf $nameCondorFile
fi
echo "universe = vanilla
Requirements = Memory >= 199 &&OpSys == \"LINUX\"&& (Arch != \"DUMMY\" )&& Disk > 1000000
Should_Transfer_Files = YES
WhenToTransferOutput = ON_EXIT
Executable = ${Working_Dir}/${Name}_${run}/${nameRunFile}
Notify_User = ${emailForNotifications}" >> ${nameCondorFile}

for ((version=1;version<${numJobs}+1;version++))
do
	events=$(echo "1+(${version}-1)*250" | bc)
	echo "
Output = ${Working_Dir}/${Name}_${run}/${Name}_${version}.stdout
Error = ${Working_Dir}/${Name}_${run}/${Name}_${version}.stderr
Log = ${Working_Dir}/${Name}_${run}/${Name}_${version}.condorlog
Arguments = ${Name}_${run} 1 ${version} ${events} ${Output_Dir}
Queue ">> ${nameCondorFile}
done


#################################
##### Make it run
#################################
echo " Running script in condor... "
condor_submit ${nameCondorFile}

echo " Have a nice day :D "

