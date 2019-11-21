/*****************************************************************************************
Class Name : AcquisitionDealApprovalHandlerTest
Purpose : Test Class for AcquisitionDealApprovalHandler
******************************************************************************************

Version         DateModified        ModifiedBy              Change
1.0             28/2/2018           Elavarasan               Initial Development
******************************************************************************************/ 

@isTest(seeAllData = false)
private class AcquisitionDealApprovalHandlerTest{
    
    private static Acquisition_Deal__c currentDeal;
    private static Acquisition_Deal__c currentDealTest;
    private static Acquisition_Deal__c currentDealtesting; 
    private static Acq_Deal_Level__c   acquisitiondeallevel;
    private static Title__c title;
    private static Primary_Terms__c primaryterms;
    private static Financials__c  financials;
    private static Risk_Compliance__c  risk;
    private static Comps__c comps;
    
    static testMethod void testApprovalCont(){
        
        Test.startTest();
        
        Schema.DescribeSObjectResult acquisitionDeal = Schema.SObjectType.Acquisition_Deal__c; 
        Map<String,Schema.RecordTypeInfo> acquisitionDealRecordTypeInfo = acquisitionDeal.getRecordTypeInfosByName(); 
        Id goldRecTypeID = AcquisitionDealRecordTypeInfo.get('Gold New').getRecordTypeId();  
        
        acquisitiondeallevel = new Acq_Deal_Level__c();
        acquisitiondeallevel.Name = 'Gold';
        acquisitiondeallevel.Acq_Deal_Record_Type_Id__c = GoldRecTypeID; 
        insert acquisitiondeallevel;
        System.assert(acquisitiondeallevel.Name != Null);
        
        currentDealTest = new Acquisition_Deal__c ();
        currentDealTest.Name = 'Deal through testsample';
        currentDealTest.recordtypeId = GoldRecTypeID;
        currentDealTest.Acquisition_Deal_Stage__c = 'Speculative';
        currentDealTest.Office__c = 'France';
        insert currentDealTest;
        System.assert(currentDealTest.Name != Null);
        
        title = new Title__c();
        title.Name = 'Deal through testsample';        
        title.LAQ_Acquisition_Deal__c = currentDealTest.Id;
        title.LAQ_Genre__c = 'Feature Film';
        title.LAQ_Sub_Genre__c = 'Action';
        insert title;
        System.assert(title.Name != Null);
        
        primaryterms = new Primary_Terms__c();
        primaryterms.Acquisition_Deal__c = currentDealTest.Id;
        primaryterms.Date_Approved__c = system.today();
        primaryterms.Commencement_of_Post_Prod_pt__c = 40;
        primaryterms.MG_Checkbox__c = true; 
        insert  primaryterms;
        System.assert(primaryterms.Id != Null);
        
        financials = new Financials__c ();
        financials.Acquisition_Deal__c = CurrentDealTest.Id;
        financials.This_Home_Ent_Forecast_was_received_on__c = system.today();
        financials.X1st_year_ROI__c = 60;
        financials.MG__c = 60000;   
        insert  financials;
        System.assert(acquisitiondeallevel.Id != Null);
        
        risk = new Risk_Compliance__c ();
        risk.Acquisition_Deal__c = CurrentDealTest.Id;
        risk.Date_Approved__c = system.today() + 5;
        risk.Percent_of_Unsecure_Payment__c = 10;
        insert risk;
        System.assert(acquisitiondeallevel.Id != Null);
        
        comps = new Comps__c();
        comps.Acquisition_Deal__c = currentDealTest.Id;
        comps.Date_Approved__c = system.today() + 5;
        comps.Board_Pack_Version__c = 3;
        insert Comps;
        System.assert(acquisitiondeallevel.Id!= Null);
        
        currentDealTest.Primary_Term__c = primaryterms.Id;
        currentDealTest.Financials__c = Financials.Id;
        currentDealTest.Risk_Compliance__c = Risk.Id;
        currentDealTest.Comps__c = comps.Id;
        currentDealTest.Acquisition_Deal_Stage__c = 'Board Pack Preparation';
        currentDealTest.Acq_Deal_Level__c = Acquisitiondeallevel.Id;
        currentDealTest.Title_Context__c = title.Id;
        currentDealTest.Financials__c = financials.id;
        update currentDealTest;
        System.assert(acquisitiondeallevel.Id!= Null);
        
        ApexPages.StandardController sctest = new ApexPages.StandardController(currentDealTest);
        AcquisitionDealApprovalHandler contrtest = new AcquisitionDealApprovalHandler(sctest);
        contrtest.submitAndProcessApprovalRequest();
        Pagereference pagetest = contrtest.returnToDeal();
        
        currentDealTest.On_Hold__c = true;
        update currentDealTest;
        contrtest.submitAndProcessApprovalRequest();        
        
        currentDeal = new Acquisition_Deal__c ();
        currentDeal.Name = 'Deal through test';
        insert currentDeal;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(currentDeal);
        AcquisitionDealApprovalHandler contr = new AcquisitionDealApprovalHandler(sc);
        contr.submitAndProcessApprovalRequest();
        Pagereference page = contr.returnToDeal();
        
        currentDeal.Dead__c = true;
        update currentDeal;
        contr.submitAndProcessApprovalRequest();
        
        Test.stopTest();
    }
}