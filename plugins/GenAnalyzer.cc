// -*- C++ -*-
//
// Package:    GenAnalyzer
// Class:      GenAnalyzer
// 
/**\class GenAnalyzer GenAnalyzer.cc UserCode/GenAnalyzer/src/GenAnalyzer.cc

 Description: [one line class summary]

 Implementation:
     [Notes on implementation]
*/
//
// Original Author:  Alejandro Gomez
//         Created:  Mon May 20 14:38:03 CDT 2013
// $Id: GenAnalyzer.cc,v 1.2 2013/06/19 02:42:01 algomez Exp $
//
//


// system include files
#include <memory>
#include <vector>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "DataFormats/FWLite/interface/Handle.h"

#include "DataFormats/HepMCCandidate/interface/GenParticleFwd.h"
#include "DataFormats/HepMCCandidate/interface/GenParticle.h"

#include "DataFormats/Candidate/interface/Candidate.h"
#include "DataFormats/Candidate/interface/CandidateFwd.h"
#include "DataFormats/Common/interface/Ref.h"

#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"

#include "FWCore/Utilities/interface/InputTag.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/Math/interface/LorentzVector.h"
#include "DataFormats/Math/interface/Vector3D.h"

#include "TLorentzVector.h"
#include "TVector3.h"
#include "TH1D.h"
//
// class declaration
//

class GenAnalyzer : public edm::EDAnalyzer {
	public:
		explicit GenAnalyzer(const edm::ParameterSet&);
		~GenAnalyzer();

		
	private:
		virtual void beginJob() ;
		virtual void analyze(const edm::Event&, const edm::EventSetup&);
		virtual void endJob() ;

	// ----------member data ---------------------------
	edm::InputTag src_;
	double stop1Mass_;
	double stop2Mass_;
	double st1decay_;

	TH1D * histo; 
	TH1D * h_uq_num;
	TH1D * h_dq_num;
	TH1D * h_cq_num;
	TH1D * h_sq_num;

	// Higgs
	TH1D * h_higgs_mass;
	TH1D * h_higgsTrue_mass;
	TH1D * h_higgs_pt;
	TH1D * h_higgsBB_deltaR;
	TH1D * h_higgs_num;

	// Stop1
	TH1D * h_stop1_mass;
	TH1D * h_stop1True_mass;
	TH1D * h_stop1_pt;
	TH1D * h_stop1Bj_deltaR;
	
	// Stop2
	TH1D * h_stop2_mass;
	TH1D * h_stop2True_mass;
	TH1D * h_stop2jetsB_num;
	TH1D * h_stop2jets_num;
	
	// Jets + B
	TH1D * h_jetsB_ht;
	TH1D * h_jetsB_pt;
	TH1D * h_jetsB1_pt;
	TH1D * h_jetsB2_pt;
	TH1D * h_jetsB3_pt;
	TH1D * h_jetsB4_pt;
	TH1D * h_jetsB_num;
	TH1D * h_jetsB1_eta;
	TH1D * h_jetsB2_eta;
	TH1D * h_jetsB3_eta;
	TH1D * h_jetsB4_eta;
	TH1D * h_jetsB1_phi;
	TH1D * h_jetsB2_phi;
	TH1D * h_jetsB3_phi;
	TH1D * h_jetsB4_phi;
	TH1D * h_jetsB1jetsB2_deltaR;
	TH1D * h_jetsB1jetsB3_deltaR;

	// Bjets
	TH1D * h_Bjet1_pt;
	TH1D * h_Bjet2_pt;
	TH1D * h_Bjet_num;
	TH1D * h_Bjet1Bjet2_deltaEta;
	TH1D * h_Bjet1Bjet2_deltaPhi;
	TH1D * h_Bjet1Bjet2_cosDeltaPhi;
	TH1D * h_Bjet1Bjet2_deltaR;

	// Jets (without b)
	TH1D * h_jet_pt;
	TH1D * h_jet1_pt;
	TH1D * h_jet2_pt;
	TH1D * h_jet_num;

	// Fancy stuff
	/*TH1D * h_jet1Bjet1_eta;
	TH1D * h_jetfromStop1;
	TH1D * h_BjetfromStop1;
	TH1D * h_Bjet1fromStop1;
	TH1D * h_Bjet2fromStop1;
	TH1D * h_jetsBfromStop1;
	TH1D * h_jetsB1fromStop1;
	TH1D * h_jetsB2fromStop1;
	TH1D * h_jetsB3fromStop1;
	TH1D * h_jetsB4fromStop1;*/

};

//
// constants, enums and typedefs
//

//
// static data member definitions
//

//
// constructors and destructor
//
GenAnalyzer::GenAnalyzer(const edm::ParameterSet& iConfig) :
	src_( iConfig.getParameter<edm::InputTag>( "src" ) ),  			// Obtain inputs
	stop1Mass_( iConfig.getParameter<double>( "stop1Mass" ) ),
	stop2Mass_( iConfig.getParameter<double>( "stop2Mass" ) ),
	st1decay_( iConfig.getParameter<double>( "st1decay" ) )
{
	//now do what ever initialization is needed
	edm::Service<TFileService> fs;						// Output File 

	// Initialize Histograms
	histo = fs->make<TH1D>("jetpt" , "Jet p_{T}" , 30 ,0., 300. );		// test histo
	h_uq_num = fs->make<TH1D>("uq_num" , "Number of Up" , 10 , -0.5, 9.5 );
	h_dq_num = fs->make<TH1D>("dq_num" , "Number of Down" , 10 , -0.5, 9.5 );
	h_cq_num = fs->make<TH1D>("cq_num" , "Number of Charm" , 10 , -0.5, 9.5 );
	h_sq_num = fs->make<TH1D>("sq_num" , "Number of Strange" , 10 , -0.5, 9.5 );

	// Higgs
	h_higgs_mass = fs->make<TH1D>("higgs_mass" , "Higgs Mass" , 12.5 , 99.0, 150. );
	h_higgsTrue_mass = fs->make<TH1D>("higgsTrue_mass" , "True Higgs Mass" , 12.5, 99., 150. );
	h_higgs_pt = fs->make<TH1D>("higgs_pt" , "Higgs p_{T}" , 98 , 0., 500. );
	//h_higgsBB_deltaR = fs->make<TH1D>("higgs_deltaR" , "#Delta R (b,b) [from H]" , 50 , 0., 5. );
	h_higgs_num = fs->make<TH1D>("higgs_num" , "Number of Higgs" , 10 , -0.5, 9.5 );

	// Stop1
	h_stop1_mass = fs->make<TH1D>("stop1_mass" , "Stop1 Mass" , 41 , 70., 530. );
	h_stop1True_mass = fs->make<TH1D>("stop1True_mass" , "True Stop1 Mass" , 41 , 70, 530. );
	h_stop1_pt = fs->make<TH1D>("stop1_pt" , "Stop1 p_{T}" , 98 , 0., 500. );
	//h_stop1Bj_deltaR = fs->make<TH1D>("stop1Bj_deltaR" , "#Delta R (b,j) [from Stop1]" , 50 , 0., 5. );
	
	// Stop2
	h_stop2_mass = fs->make<TH1D>("stop2_mass" , "Stop2 Mass" , 31 , 220., 780. );
	h_stop2True_mass = fs->make<TH1D>("stop2True_mass" , "True Stop2 Mass" , 31 , 220., 780. );
	h_stop2jetsB_num = fs->make<TH1D>("stop2jetsB_num" , "Number of Jets + B" , 10 , -0.5, 9.5 );
	h_stop2jets_num = fs->make<TH1D>("stop2jets_num" , "Number of Jets" , 10 , -0.5, 9.5 );
	
	// Jets + B
	h_jetsB_ht = fs->make<TH1D>("jetsB_ht" , "H_{T} (Jets + B)" , 40 , 200., 1000. );
	h_jetsB_pt = fs->make<TH1D>("jetsB_pt" , "Jets + B  p_{T}" , 98 , 0., 500. );
	h_jetsB1_pt = fs->make<TH1D>("jetsB1_pt" , "Leading Jets + B p_{T}" , 98 , 0., 500. );
	h_jetsB2_pt = fs->make<TH1D>("jetsB2_pt" , "2nd Leading Jets + B p_{T}" , 98 , 0., 500. );
	h_jetsB3_pt = fs->make<TH1D>("jetsB3_pt" , "3rd Leading Jets + B p_{T}" , 98 , 0., 500. );
	h_jetsB4_pt = fs->make<TH1D>("jetsB4_pt" , "4th Leading Jets + B p_{T}" , 98 , 0., 500. );
	h_jetsB_num = fs->make<TH1D>("jetsB_num" , "Number of Jets + B" , 16 , -0.5, 15.5 );
	h_jetsB1_eta = fs->make<TH1D>("jetsB1_eta" , "Leading Jets + B #eta" , 28 , -3.1, 3.1 );
	h_jetsB2_eta = fs->make<TH1D>("jetsB2_eta" , "2nd Leading Jets + B #eta" , 28 , -3.1, 3.1 );
	h_jetsB3_eta = fs->make<TH1D>("jetsB3_eta" , "3rd Leading Jets + B #eta" , 28 , -3.1, 3.1 );
	h_jetsB4_eta = fs->make<TH1D>("jetsB4_eta" , "4th Leading Jets + B #eta" , 28 , -3.1, 3.1 );
	h_jetsB1_phi = fs->make<TH1D>("jetsB1_phi" , "Leading Jets + B #phi" , 58 , -5.1, 5.1 );
	h_jetsB2_phi = fs->make<TH1D>("jetsB2_phi" , "2nd Leading Jets + B #phi" , 58 , -5.1, 5.1 );
	h_jetsB3_phi = fs->make<TH1D>("jetsB3_phi" , "3rd Leading Jets + B #phi" , 58 , -5.1, 5.1 );
	h_jetsB4_phi = fs->make<TH1D>("jetsB4_phi" , "4th Leading Jets + B #phi" , 58 , -5.1, 5.1 );
	h_jetsB1jetsB2_deltaR = fs->make<TH1D>("jetsB1jetsB2_deltaR" , "#Delta R (jb_{1},jb_{2})" , 50 , 0., 5. );
	h_jetsB1jetsB3_deltaR = fs->make<TH1D>("jetsB1jetsB3_deltaR" , "#Delta R (jb_{1},jb_{3})" , 50 , 0., 5. );

	// Bjets
	h_Bjet1_pt = fs->make<TH1D>("Bjet1_pt" , "Leading B-Jet p_{T}" , 98 , 0., 500. );
	h_Bjet2_pt = fs->make<TH1D>("Bjet2_pt" , "2nd Leading B-Jet p_{T}" , 98 , 0., 500. );
	h_Bjet_num = fs->make<TH1D>("Bjet_num" , "Number of B-Jets" , 10 , -0.5, 9.5 );
	//h_Bjet1Bjet2_deltaEta = fs->make<TH1D>("jet1Bjet1_deltaEta" , "#Delta #eta (bj_{1},bj_{2})" , 28 , -3.1, 3.1 );
	h_Bjet1Bjet2_deltaPhi = fs->make<TH1D>("Bjet1Bjet2_deltaPhi" , "#Delta #phi (bj_{1}, bj_{2})" , 50 , 0., 5. );
	h_Bjet1Bjet2_cosDeltaPhi = fs->make<TH1D>("Bjet1Bjet2_cosDeltaPhi" , "cos [#Delta #phi (bj_{1}, bj_{2})]" , 26 , -1.2, 1.2 );
	h_Bjet1Bjet2_deltaR = fs->make<TH1D>("Bjet1Bjet2_deltaR" , "#Delta R (b_{1},b_{2})" , 50 , 0., 5. );

	// Jets (without b)
	h_jet_pt = fs->make<TH1D>("jet_pt" , "Jets p_{T}" , 98 , 0., 500. );
	h_jet1_pt = fs->make<TH1D>("jet1_pt" , "Leading Jet p_{T}" , 98 , 0., 500. );
	h_jet2_pt = fs->make<TH1D>("jet2_pt" , "2nd Leading Jet p_{T}" , 98 , 0., 500. );
	h_jet_num = fs->make<TH1D>("jet_num" , "Number of Jets" , 10 , -0.5, 9.5 );

	/*/ Fancy stuff
	h_jet1Bjet1_eta = fs->make<TH1D>("jet1Bjet1_eta" , "#eta (j_{1},bj_{1})" , 28 , -3.1, 3.1 );
	h_jetfromStop1 = fs->make<TH1D>("jetfromStop1" , "Position of Jets (w/o b) from Stop1" , 16, -0.5, 15.5 );
	h_BjetfromStop1 = fs->make<TH1D>("BjetfromStop1" , "Position of B-Jets from Stop1" , 16, -0.5, 15.5 );
	h_Bjet1fromStop1 = fs->make<TH1D>("Bjet1fromStop1" , "Position of Leading B-Jet from Stop1" , 16, -0.5, 15.5 );
	h_Bjet2fromStop1 = fs->make<TH1D>("Bjet2fromStop1" , "Position of 2nd Leading B-Jet from Stop1" , 16, -0.5, 15.5 );
	h_jetsBfromStop1 = fs->make<TH1D>("jetsBfromStop1" , "Position of Jets from Stop1" , 16, -0.5, 15.5 );
	h_jetsB1fromStop1 = fs->make<TH1D>("jetsB1fromStop1" , "Position of Leading Jet from Stop1" , 16, -0.5, 15.5 );
	h_jetsB2fromStop1 = fs->make<TH1D>("jetsB2fromStop1" , "Position of 2nd Leading Jet from Stop1" , 16, -0.5, 15.5 );
	h_jetsB3fromStop1 = fs->make<TH1D>("jetsB3fromStop1" , "Position of 3rd Leading Jet from Stop1" , 16, -0.5, 15.5 );
	h_jetsB4fromStop1 = fs->make<TH1D>("jetsB4fromStop1" , "Position of 4th Leading Jet from Stop1" , 16, -0.5, 15.5 ); */

}

// Bool to Sort by Pt
bool ComparePt(TLorentzVector a, TLorentzVector b) { return a.Pt() > b.Pt(); }

GenAnalyzer::~GenAnalyzer()
{
 
   // do anything here that needs to be done at desctruction time
   // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called to for each event  ------------
void GenAnalyzer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup){

	using namespace std;
	using namespace edm;
	using namespace reco;

	// Way to call GenParticle from root
	edm::Handle<std::vector<reco::GenParticle>> particles;
	iEvent.getByLabel( src_ , particles );
	const std::vector<reco::GenParticle> & p = *particles; 

	// Inizialize
	size_t higgs_num = 0;
	size_t uq = 0;
	size_t dq = 0;
	size_t sq = 0;
	size_t cq = 0;

	vector< TLorentzVector > p4jet;
	vector< TLorentzVector > p4Bjet;
	vector< TLorentzVector > p4jetsB;
	vector< TLorentzVector > p4HiggsB;
	vector< TLorentzVector > p4Higgs;
	vector< TLorentzVector > p4Stop1B;
	vector< TLorentzVector > p4Stop1jet;
	vector< TLorentzVector > p4Stop1jetsB;
	vector< TLorentzVector > p4Stop1;
	vector< TLorentzVector > p4Stop2jetsB;

	// Begin Loop for GenParticles
	for(unsigned int i = 0; i < particles->size(); ++ i) {

		if( p[i].status()!= 3 ) continue;				// Make sure only "final" particles are present
		
		const Candidate * mom = p[i].mother();				// call mother particle
		if( abs( p[i].pdgId() ) == 5 ) histo->Fill( p[i].pt() ); 			// test


		//////////// True Mass plots
		if( abs( p[i].pdgId() ) == 25 ){
			higgs_num++;						// Check number of Higgs
			h_higgsTrue_mass->Fill(p[i].mass());			// Higgs true mass
		}
		if( abs( p[i].pdgId() ) == 1000002 ) h_stop1True_mass->Fill(p[i].mass());	// Stop1 true mass
		if( abs( p[i].pdgId() ) == 1000004 ) h_stop2True_mass->Fill(p[i].mass());	// Stop2 true mass
		////////////
		

		//////////// Storing TLorentz Vectors
		TLorentzVector tmpjet, tmpBjet, tmpjetsB, tmpHiggs, tmpStop1B, tmpStop1jet;	// tmp TLorentzVectors
		if( mom ){
			if( abs( p[i].pdgId() ) == 1 ) uq++; 
			if( abs( p[i].pdgId() ) == 2 ) dq++; 
			if( abs( p[i].pdgId() ) == 3 ) cq++; 
			if( abs( p[i].pdgId() ) == 4 ) sq++; 
			// Jets without b
			if( ( abs( p[i].pdgId() ) == 1 ) || ( abs( p[i].pdgId() ) == 2 ) || ( abs( p[i].pdgId() ) == 3 ) || ( abs( p[i].pdgId() ) == 4) ){
				tmpjet.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
				p4jet.push_back( tmpjet );
			}
			std::sort(p4jet.begin(), p4jet.end(), ComparePt);
			// Bjets
			if( abs( p[i].pdgId() ) == 5 ){
				tmpBjet.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
				p4Bjet.push_back( tmpBjet );
			}
			std::sort(p4Bjet.begin(), p4Bjet.end(), ComparePt);
	 		// Jets with b
			if( ( abs( p[i].pdgId() ) == 1 ) || ( abs( p[i].pdgId() ) == 2 ) || ( abs( p[i].pdgId() ) == 3 ) || ( abs( p[i].pdgId() ) == 4) || ( abs( p[i].pdgId() ) == 5 )){
				tmpBjet.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
				p4jetsB.push_back( tmpBjet );
			}
			std::sort(p4jetsB.begin(), p4jetsB.end(), ComparePt);

			// Higgs
			if( ( abs( p[i].pdgId() ) == 5 ) & ( p[i].mother()->pdgId() == 25 ) ){
				tmpHiggs.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
				p4HiggsB.push_back( tmpHiggs );
				p4Stop2jetsB.push_back( tmpHiggs );
			}
			std::sort(p4HiggsB.begin(), p4HiggsB.end(), ComparePt);
		 	// Stop1
			if( abs( p[i].mother()->pdgId() ) == 1000002 ){
				if( ( abs( p[i].pdgId() ) == 1 ) || ( abs( p[i].pdgId() ) == 2 ) || ( abs( p[i].pdgId() ) == 3 ) || ( abs( p[i].pdgId() ) == 4) ){
					tmpStop1jet.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
					p4Stop1jet.push_back( tmpStop1jet );
					p4Stop1jetsB.push_back( tmpStop1jet );
					p4Stop2jetsB.push_back( tmpStop1jet );
				}
				else {
					tmpStop1B.SetPxPyPzE(p[i].px(),p[i].py(),p[i].pz(),p[i].energy());
					p4Stop1B.push_back( tmpStop1B );
					p4Stop1jetsB.push_back( tmpStop1B );
					p4Stop2jetsB.push_back( tmpStop1B );
				}
			}
			std::sort(p4Stop1B.begin(), p4Stop1B.end(), ComparePt);
			std::sort(p4Stop1jet.begin(), p4Stop1jet.end(), ComparePt);
			std::sort(p4Stop1jetsB.begin(), p4Stop1jetsB.end(), ComparePt);
			std::sort(p4Stop2jetsB.begin(), p4Stop2jetsB.end(), ComparePt);
		}
	}  // end GenParticles loop 


	// Test number of true Higgs
	h_higgs_num->Fill( higgs_num );
	h_uq_num->Fill(uq);
	h_dq_num->Fill(dq);
	h_cq_num->Fill(cq);
	h_sq_num->Fill(sq);

	//cout << "run:lumi:event = " << iEvent.id().run() << ":" << iEvent.id().luminosityBlock() << ":" << iEvent.id().event() <<endl;

	///// Higgs reconstructed mass
	for(unsigned int j = 0; j < p4HiggsB.size()-1; ++j) {
		for(unsigned int k=j+1; k < p4HiggsB.size(); ++k) {
			if(j==k) continue;							// avoid repetition
			TLorentzVector p4CandidateHiggs = p4HiggsB[j] + p4HiggsB[k];		// Higgs TLorentzVector
			//cout << p4HiggsB[j].E() << " " << p4HiggsB[k].E() << " " << p4CandidateHiggs.M() << endl;
			Double_t massHiggs = 125.0;						// nominal mass value
			Double_t diffmassHiggs = p4CandidateHiggs.M() - massHiggs;		// mass difference
			//cout << diffmassHiggs << endl;
			if( abs(diffmassHiggs) < 0.5 ){						// diffmass presicion
			       	h_higgs_mass->Fill( p4CandidateHiggs.M() );			// Higgs mass
			       	h_higgs_pt->Fill( p4CandidateHiggs.Pt() );			// Higgs pT
				p4Higgs.push_back( p4CandidateHiggs );				// store final TLorentzVector
				//cout << p4CandidateHiggs.M() << endl;
			}
		}
	}
	///////////////////////////// /


	/////// Stop1 reconstructed mass
	if( st1decay_==1){
		for(unsigned int j = 0; j < p4Stop1B.size(); ++j) {
			for(unsigned int k= 0; k < p4Stop1jet.size(); ++k) {
				TLorentzVector p4CandidateStop1 = p4Stop1B[j] + p4Stop1jet[k];		// higgs tlorentzvector
				Double_t massStop1 = stop1Mass_ ;						// nominal mass value
				Double_t diffmassStop1 = p4CandidateStop1.M() - massStop1;		// mass difference
				if( abs(diffmassStop1) < 1.0 ){						// diffmass presicion
				       	h_stop1_mass->Fill( p4CandidateStop1.M() );			// stop1 mass
				       	h_stop1_pt->Fill( p4CandidateStop1.Pt() );			// stop1 pt
					p4Stop1.push_back( p4CandidateStop1 );
				}
			}
		}
	} else {
		for(unsigned int j = 0; j < p4Stop1jet.size(); ++j) {
			for(unsigned int k= 0; k < p4Stop1jet.size(); ++k) {
				if( j==k ) continue;
				TLorentzVector p4CandidateStop1 = p4Stop1jet[j] + p4Stop1jet[k];		// higgs tlorentzvector 
				Double_t massStop1 = stop1Mass_ ;						// nominal mass value
				Double_t diffmassStop1 = p4CandidateStop1.M() - massStop1;		// mass difference
				if( abs(diffmassStop1) < 1.0 ){						// diffmass presicion
				       	h_stop1_mass->Fill( p4CandidateStop1.M() );			// stop1 mass
				       	h_stop1_pt->Fill( p4CandidateStop1.Pt() );			// stop1 pt
					p4Stop1.push_back( p4CandidateStop1 );
				}
			}
		}
	}
	///////////////////////////////// /
	
	// Stop2 reconstructed mass
	for(unsigned int j = 0; j < p4Higgs.size(); ++j) {
		for(unsigned int k= 0; k < p4Stop1.size(); ++k) {
			TLorentzVector p4CandidateStop2 = p4Higgs[j] + p4Stop1[k];		// Higgs TLorentzVector
			Double_t massStop2 = stop2Mass_;					// nominal mass value
			Double_t diffmassStop2 = p4CandidateStop2.M() - massStop2;		// mass difference
			if( abs(diffmassStop2) < 1.0 ){						// diffmass presicion
			       	h_stop2_mass->Fill( p4CandidateStop2.M() );			// Stop1 mass
			}
		}
	}//

	// Jets + B
	Double_t Ht = 0;
	for(unsigned int j = 0; j < p4jetsB.size(); ++j) {

		Ht += p4jetsB[j].Pt();
		if(p4jetsB[j].Pt() > 1 ) h_jetsB_pt->Fill( p4jetsB[j].Pt() );

		/*
		for(unsigned int k= 0; k < p4Stop1jet.size(); ++k) {
			if( p4Stop1jet[k].Pt() == p4jetsB[j].Pt() ) h_jetfromStop1->Fill( j+1 );
				//cout << k << " "<< j << " " <<p4Stop1jet[k].Pt() << " " << p4jetsB[j].Pt() << endl;
		}
		if( p4Stop1B[0].Pt() == p4jetsB[j].Pt() ) h_Bjet1fromStop1->Fill( j+1 );
		if( p4Stop1B[1].Pt() == p4jetsB[j].Pt() ) h_Bjet2fromStop1->Fill( j+1 );
		for(unsigned int kk= 0; kk < p4Stop1B.size(); ++kk) {
			if( p4Stop1B[kk].Pt() == p4jetsB[j].Pt() ) h_BjetfromStop1->Fill( j+1 );
				//cout << kk << " "<< j << " " <<p4Stop1B[kk].Pt() << " " << p4jetsB[j].Pt() << endl;
		}
		if( p4Stop1jetsB[0].Pt() == p4jetsB[j].Pt() ) h_jetsB1fromStop1->Fill( j+1 );
		if( p4Stop1jetsB[1].Pt() == p4jetsB[j].Pt() ) h_jetsB2fromStop1->Fill( j+1 );
		if( p4Stop1jetsB[2].Pt() == p4jetsB[j].Pt() ) h_jetsB3fromStop1->Fill( j+1 );
		if( p4Stop1jetsB[3].Pt() == p4jetsB[j].Pt() ) h_jetsB4fromStop1->Fill( j+1 );
		for(unsigned int kkk= 0; kkk < p4Stop1jetsB.size(); ++kkk) {
			if( p4Stop1jetsB[kkk].Pt() == p4jetsB[j].Pt() ) h_jetsBfromStop1->Fill( j+1 );
				//cout << kkk << " "<< j << " " <<p4Stop1jetsB[kkk].Pt() << " " << p4jetsB[j].Pt() << endl;
		}*/
	}
	h_jetsB1_pt->Fill( p4jetsB[0].Pt() );
	h_jetsB2_pt->Fill( p4jetsB[1].Pt() );
	h_jetsB3_pt->Fill( p4jetsB[2].Pt() );
	h_jetsB4_pt->Fill( p4jetsB[3].Pt() );
	h_jetsB1_eta->Fill( p4jetsB[0].Eta() );
	h_jetsB2_eta->Fill( p4jetsB[1].Eta() );
	h_jetsB3_eta->Fill( p4jetsB[2].Eta() );
	h_jetsB4_eta->Fill( p4jetsB[3].Eta() );
	h_jetsB1_phi->Fill( p4jetsB[0].Phi() );
	h_jetsB2_phi->Fill( p4jetsB[1].Phi() );
	h_jetsB3_phi->Fill( p4jetsB[2].Phi() );
	h_jetsB4_phi->Fill( p4jetsB[3].Phi() );
	h_jetsB1jetsB2_deltaR->Fill( p4jetsB[0].DeltaR( p4jetsB[1] ) );
	h_jetsB1jetsB3_deltaR->Fill( p4jetsB[0].DeltaR( p4jetsB[2] ) );
	h_jetsB_ht->Fill( Ht );
	h_jetsB_num->Fill( p4jetsB.size() );
	h_stop2jetsB_num->Fill( p4Stop2jetsB.size() );
	//////////////////////////// 

	// Bjets 
	h_Bjet2_pt->Fill( p4Bjet[1].Pt() );
	h_Bjet1Bjet2_deltaPhi->Fill( p4Bjet[0].DeltaPhi( p4Bjet[1] ) );
	h_Bjet1Bjet2_cosDeltaPhi->Fill( cos( p4Bjet[0].DeltaPhi( p4Bjet[1] ) ) );
	h_Bjet1Bjet2_deltaR->Fill( p4Bjet[0].DeltaR( p4Bjet[1] ) );
	h_Bjet1_pt->Fill( p4Bjet[0].Pt() );
	h_Bjet_num->Fill( p4Bjet.size() );
	//////////////////////////// /

	// Jets 
	for(unsigned int j = 0; j < p4jet.size(); ++j) {
		if(p4jet[j].Pt() > 1 ) h_jet_pt->Fill( p4jet[j].Pt() );
	}
	h_jet1_pt->Fill( p4jet[0].Pt() );
	h_jet2_pt->Fill( p4jet[1].Pt() );
	h_jet_num->Fill( p4jet.size() );
	h_stop2jets_num->Fill( p4Stop1jet.size() );
	/////////////////////////////

}

// ------------ method called once each job just after ending the event loop  ------------
void 
GenAnalyzer::beginJob() {
}
void 
GenAnalyzer::endJob() {
}

//define this as a plug-in
DEFINE_FWK_MODULE(GenAnalyzer);
