/*==========================================================================
TestClass Name: AcqDealRelatedCustomLinkTest
Created By: Krishna Kumar 
Created Date: 04/03/2018 
Description: This test class used to code coverage for AcqDealRelatedCustomLink Class.
====================================================================================================================*/
@isTest(seeAllData = false)
public class AcqDealRelatedCustomLinkTest {
    
    static testMethod void acquuisitionDealCreate()
    {
        Schema.DescribeSObjectResult acquisitionDeal = Schema.SObjectType.Acquisition_Deal__c; 
        Map<String,Schema.RecordTypeInfo> acqRecordTypeInfo = acquisitionDeal.getRecordTypeInfosByName(); 
        Id recordTypeID = acqRecordTypeInfo.get('Gold New').getRecordTypeId(); 
        
        Test.startTest();
        Acq_Deal_Level__c acqLevel = new Acq_Deal_Level__c();
        acqLevel.Name = 'Gold';
        acqLevel.Acq_Deal_Record_Type_Id__c = recordTypeID; 
        insert acqLevel;
        System.assert(acqLevel.Name != Null);
        
        Acquisition_Deal__c acqDeal = new Acquisition_Deal__c ();
        acqDeal.Name = 'Deal through testsample';
        acqDeal.recordtypeId = recordTypeID;
        acqDeal.Acquisition_Deal_Stage__c = 'Speculative';
        acqDeal.Office__c = 'France';
        insert acqDeal;
        System.assert(acqDeal.Name != Null);
        
        Title__c title = new Title__c();
        title.Name = 'Deal through testsample';        
        title.LAQ_Acquisition_Deal__c = acqDeal.Id;
        title.LAQ_Genre__c = 'Feature Film';
        title.LAQ_Sub_Genre__c = 'Action';
        title.LAQ_Board_Pack_Version__c = 1;
        insert title;
        System.assert(title.Name != Null);
        
        Primary_Terms__c priTerms = new Primary_Terms__c();
        priTerms.Acquisition_Deal__c = acqDeal.Id;
        priTerms.Date_Approved__c = system.today();
        priTerms.Commencement_of_Post_Prod_pt__c = 40;
        priTerms.Board_Pack_Version__c = 1 ;
        priTerms.MG_Checkbox__c = true; 
        insert  priTerms;
        System.assert(priTerms.Id != Null);
        
        Financials__c finan = new Financials__c ();
        finan.Acquisition_Deal__c = acqDeal.Id;
        finan.This_Home_Ent_Forecast_was_received_on__c = system.today();
        finan.X1st_year_ROI__c = 60;
        finan.MG__c = 60000;
        finan.Board_Pack_Version__c = 1;
        insert  finan;
        System.assert(finan.Id != Null);
        
        Risk_Compliance__c risk = new Risk_Compliance__c ();
        risk.Acquisition_Deal__c = acqDeal.Id;
        risk.Date_Approved__c = system.today() + 5;
        risk.Percent_of_Unsecure_Payment__c = 10;
        risk.Board_Pack_Version__c = 1;
        insert risk;
        System.assert(risk.Id != Null);
        
        Comps__c comps = new Comps__c();
        comps.Acquisition_Deal__c = acqDeal.Id;
        comps.Date_Approved__c = system.today() + 5;
        comps.Board_Pack_Version__c = 1;
        insert Comps;
        System.assert(Comps__c.Id!= Null);
        
        Test.stopTest();
        
        AcqDealRelatedCustomLink.getdealid(priTerms.Id);
        AcqDealRelatedCustomLink.getFinancialsid(priTerms.Id);
        AcqDealRelatedCustomLink.getTitleid(priTerms.Id);
        AcqDealRelatedCustomLink.getcompsid(priTerms.Id);
        AcqDealRelatedCustomLink.getRiskid(priTerms.Id);
        
        AcqDealRelatedCustomLink.getdealidtitle(title.Id);
        AcqDealRelatedCustomLink.getFinancialsidtitle(title.Id);
        AcqDealRelatedCustomLink.getprimaryidtitle(title.Id);
        AcqDealRelatedCustomLink.getcompsidtitle(title.Id);
        AcqDealRelatedCustomLink.getRiskidtitle(title.Id);
        
        AcqDealRelatedCustomLink.getdealidfinancial(finan.Id);
        AcqDealRelatedCustomLink.gettitleidfinancial(finan.Id);
        AcqDealRelatedCustomLink.getprimaryidfinancial(finan.Id);
        AcqDealRelatedCustomLink.getcompsidfinancial(finan.Id);
        AcqDealRelatedCustomLink.getRiskidfinancial(finan.Id);
        
        AcqDealRelatedCustomLink.getdealidcomps(comps.Id);
        AcqDealRelatedCustomLink.gettitleidcomps(comps.Id);
        AcqDealRelatedCustomLink.getprimaryidcomps(comps.Id);
        AcqDealRelatedCustomLink.getFinancialsidcomps(comps.Id);
        AcqDealRelatedCustomLink.getRiskidcomps(comps.Id);
        
        AcqDealRelatedCustomLink.getdealidrisk(risk.Id);
        AcqDealRelatedCustomLink.gettitleidrisk(risk.Id);
        AcqDealRelatedCustomLink.getprimaryidrisk(risk.Id);
        AcqDealRelatedCustomLink.getFinancialsidrisk(risk.Id);
        AcqDealRelatedCustomLink.getcompsidrisk(risk.Id);
    }
}