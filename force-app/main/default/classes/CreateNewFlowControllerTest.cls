/******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             22/2/2018           Elavarasan                Initial Development
******************************************************************************************/

@isTest
private class CreateNewFlowControllerTest{
    
    private static Acquisition_Deal__c currentDealTest;
    private static Title__c nonApprovedTitle;
    private static Primary_Terms__c nonApprovedPT;
    private static Financials__c nonApprovedFinancials;
    private static Comps__c nonApprovedComps;
    private static Risk_Compliance__c nonApprovedRisk;     
    
    static TestMethod void clonespeculativetest(){
        
        List<Title__c> titlesToInsert = new List<Title__C>();
        List<Primary_Terms__c > ptsToInsert = new List<Primary_Terms__c >();
        List<Financials__c > finsToInsert = new List<Financials__c >();
        List<Risk_Compliance__c > risksToInsert = new List<Risk_Compliance__c >();
        List<Comps__c> compsToInsert= new List<Comps__c>();
                
        Schema.DescribeSObjectResult AcquisitionDeal = Schema.SObjectType.Acquisition_Deal__c; 
        Map<String,Schema.RecordTypeInfo> AcquisitionDealRecordTypeInfo = AcquisitionDeal.getRecordTypeInfosByName(); 
        Id SpeculativeRecTypeID = AcquisitionDealRecordTypeInfo.get('July 2018 Layout').getRecordTypeId();         
        
        Test.startTest();
        
        CurrentDealTest = new Acquisition_Deal__c ();
        CurrentDealTest.Name = 'Dealspeculativetest';
        CurrentDealTest.recordtypeId= SpeculativeRecTypeID;
        CurrentDealTest.Acquisition_Deal_Stage__c='Speculative';
        CurrentDealTest.Office__c ='France';
        insert currentDealTest;
                
        nonApprovedTitle = new Title__c();
        nonApprovedTitle.Name = 'LAQ Non Approved Title through test';        
        nonApprovedTitle.LAQ_Acquisition_Deal__c = CurrentDealTest.id;
        nonApprovedTitle.LAQ_Estimated_Delivery_Date__c = System.today();
        nonApprovedTitle.LAQ_Production_Budget__c =30.4;
        nonApprovedTitle.LAQ_Genre__c = 'Feature Film';
        nonApprovedTitle.LAQ_Sub_Genre__c = 'Action';    
        titlesToInsert.add(nonApprovedTitle); 
                
        nonApprovedPT = new Primary_Terms__c();
        nonApprovedPT.Acquisition_Deal__c= CurrentDealTest.id;
        nonApprovedPT.Date_Approved__c =system.today();
        nonApprovedPT.Commencement_of_Post_Prod_pt__c = 40;
        nonApprovedPT.MG_Checkbox__c =true;  
        ptsToInsert.add(nonApprovedPT);
        
        nonApprovedFinancials = new Financials__c ();
        nonApprovedFinancials.Acquisition_Deal__c= CurrentDealTest.id;
        nonApprovedFinancials.This_Home_Ent_Forecast_was_received_on__c = system.today();
        nonApprovedFinancials.X1st_year_ROI__c = 60;
        nonApprovedFinancials.MG__c= 60000;   
        finsToInsert.add(nonApprovedFinancials);        
        
        nonApprovedRisk = new Risk_Compliance__c ();
        nonApprovedRisk.Acquisition_Deal__c= CurrentDealTest.id;
        nonApprovedRisk.Date_Approved__c = system.today()+5;
        nonApprovedRisk.Percent_of_Unsecure_Payment__c =10;
        risksToInsert.add(nonApprovedRisk);
                
        nonapprovedComps= new Comps__c();
        nonapprovedComps.Acquisition_Deal__c= CurrentDealTest.id;
        nonapprovedComps.Date_Approved__c = system.today()+5;
        nonapprovedComps.Board_Pack_Version__c=3;
        compsToInsert.add(nonapprovedComps);
                
        insert ptsToInsert;
        insert finsToInsert;
        insert risksToInsert;
        insert titlesToInsert;
        insert compsToInsert;
                
        CurrentDealTest.Primary_Term__c = nonApprovedPT.id;
        CurrentDealTest.Financials__c = nonApprovedFinancials.id;
        CurrentDealTest.Risk_Compliance__c  = nonApprovedRisk.id;
        CurrentDealTest.Comps__c = nonapprovedComps.id;
        CurrentDealTest.Acquisition_Deal_Stage__c='Pending Board Approval';        
        update CurrentDealTest;
        
        ApexPages.StandardController sctest = new ApexPages.StandardController(CurrentDealTest);
        AcquisitionDealCreateNewFlowController testCompare = new  AcquisitionDealCreateNewFlowController(sctest);
        
        PageReference pageRef = Page.acquisition_deal_create_new_deal_flow;
        pageRef.getParameters().put('id',CurrentDealTest.id);
        Test.setcurrentpage(pageRef);
        TestCompare.getpRefFinishLocation();
        Test.stoptest();        
    }
}