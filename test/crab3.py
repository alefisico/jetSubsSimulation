from WMCore.Configuration import Configuration
config = Configuration()

config.section_("General")
config.General.requestName = 'RPVSt100tojj_13TeV_pythia8
config.General.workArea = 'crab_projects'

config.section_("JobType")
config.JobType.pluginName = 'Analysis'
config.JobType.psetName = 'pset_tutorial_analysis.py'

config.section_("Data")
config.Data.inputDataset = '/GenericTTbar/HC-CMSSW_5_3_1_START53_V5-v1/GEN-SIM-RECO'
config.Data.dbsUrl = 'global'
config.Data.splitting = 'FileBased'
config.Data.unitsPerJob = 10
config.Data.publication = True
config.Data.publishDbsUrl = 'phys03'
config.Data.publishDataName = 'CRAB3_tutorial_MC_analysis_test1'

config.section_("Site")
config.Site.storageSite = <site where the user has permission to write>
