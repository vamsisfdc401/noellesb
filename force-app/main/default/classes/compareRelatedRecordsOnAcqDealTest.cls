/*****************************************************************************************
Class Name: compareRelatedRecordsOnAcquisitionDealTest
Purpose: Test class for apex class compareRelatedRecordsOnAcquisitionDeal
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class compareRelatedRecordsOnAcqDealTest{

    private static Acquisition_Deal__c currentDeal;
    private static Title__c approvedTitle;
    private static Title__c nonApprovedTitle;
    private static Primary_Terms__c approvedPT;
    private static Primary_Terms__c nonApprovedPT;
    private static Financials__c approvedFinancials;
    private static Financials__c nonApprovedFinancials;
    private static Risk_Compliance__c approvedRisk;
    private static Risk_Compliance__c nonApprovedRisk;
    private static Comps__c approvedComps;
    private static Comps__c nonApprovedComps;
    
    /************************************
    Method Name: testSummaryPage
    Purpose: Test the summary page
    *************************************/
    static TestMethod void testSummaryPage(){
        List<Title__c> titlesToInsert = new List<Title__C>();
        List<Primary_Terms__c > ptsToInsert = new List<Primary_Terms__c >();
        List<Financials__c > finsToInsert = new List<Financials__c >();
        List<Risk_Compliance__c > risksToInsert = new List<Risk_Compliance__c >();
        List<Comps__c> compsToInsert= new List<Comps__c>();
        
        
        Recordtype dealRecordTypes= [Select id, DeveloperName from RecordType where developerName='July_2018_Layout' limit 1];
        Test.startTest();
        
        currentDeal = new Acquisition_Deal__c ();
        currentDeal.Name = 'Deal through test';
        currentDeal.recordtypeId= dealRecordTypes.id; 
        
        insert currentDeal;
        
        approvedTitle = new Title__c();
        approvedTitle.Name = 'LAQ Approved Title through test';
        approvedTitle.LAQ_Acquisition_Deal__c = currentDeal.id;
        approvedTitle.LAQ_Estimated_Delivery_Date__c = System.today();
        approvedTitle.LAQ_Production_Budget__c =30.4;
        
        titlesToInsert.add(approvedTitle); 
        
        nonApprovedTitle = new Title__c();
        nonApprovedTitle.Name = 'LAQ Non Approved Title through test';        
        nonApprovedTitle.LAQ_Acquisition_Deal__c = currentDeal.id;
        nonApprovedTitle.LAQ_Estimated_Delivery_Date__c = System.today();
        nonApprovedTitle.LAQ_Production_Budget__c =30.4;
        
        titlesToInsert.add(nonApprovedTitle); 
        
        approvedPT = new Primary_Terms__c ();
        approvedPT.Acquisition_Deal__c= currentDeal.id;
        approvedPT.Date_Approved__c =system.today();
        approvedPT.Commencement_of_Post_Prod_pt__c = 34;
        ptsToInsert.add(approvedPT);
        
        nonApprovedPT = new Primary_Terms__c();
        nonApprovedPT.Acquisition_Deal__c= currentDeal.id;
        nonApprovedPT.Date_Approved__c =system.today();
        nonApprovedPT.Commencement_of_Post_Prod_pt__c = 40;
        ptsToInsert.add(nonApprovedPT);
        
        approvedFinancials = new Financials__c ();
        approvedFinancials.Acquisition_Deal__c= currentDeal.id;
        approvedFinancials.This_Home_Ent_Forecast_was_received_on__c = system.today()+1;
        approvedFinancials.X1st_year_ROI__c = 16;
        finsToInsert.add(approvedFinancials);
        
        nonApprovedFinancials = new Financials__c ();
        nonApprovedFinancials.Acquisition_Deal__c= currentDeal.id;
        nonApprovedFinancials.This_Home_Ent_Forecast_was_received_on__c = system.today();
        nonApprovedFinancials.X1st_year_ROI__c = 60;
        finsToInsert.add(nonApprovedFinancials);
        
        approvedRisk = new Risk_Compliance__c ();
        approvedRisk.Acquisition_Deal__c= currentDeal.id;
        approvedRisk.Date_Approved__c = system.today()+3;
        approvedRisk.Percent_of_Unsecure_Payment__c =11;
        risksToInsert.add(approvedRisk);
        
        nonApprovedRisk = new Risk_Compliance__c ();
        nonApprovedRisk.Acquisition_Deal__c= currentDeal.id;
        nonApprovedRisk.Date_Approved__c = system.today()+5;
        nonApprovedRisk.Percent_of_Unsecure_Payment__c =10;
        risksToInsert.add(nonApprovedRisk);
        
        approvedComps = new Comps__c();
        approvedComps.Acquisition_Deal__c= currentDeal.id;
        approvedComps.Date_Approved__c = system.today()+3;
        approvedComps.Board_Pack_Version__c=2;
        compsToInsert.add(approvedComps);
        
        nonapprovedComps= new Comps__c();
        nonapprovedComps.Acquisition_Deal__c= currentDeal.id;
        nonapprovedComps.Date_Approved__c = system.today()+5;
        nonapprovedComps.Board_Pack_Version__c=3;
        compsToInsert.add(nonapprovedComps);
        
        insert ptsToInsert;
        insert finsToInsert;
        insert risksToInsert;
        insert titlesToInsert;
        insert compsToInsert;
        
        currentDeal.Primary_Term__c = nonApprovedPT.id;
        currentDeal.Primary_Term_Approved__c = approvedPT.id;
        currentDeal.Financials__c = nonApprovedFinancials.id;
        currentDeal.Financials_Approved__c = approvedFinancials.id;
        currentDeal.Risk_Compliance__c = nonApprovedRisk.id;
        currentDeal.Risk_Compliance_Approved__c = approvedRisk.id;
        currentDeal.Title_Context__c = nonApprovedTitle.id;
        currentDeal.Title_Approved__c = ApprovedTitle.id;
        currentDeal.Comps__c= nonapprovedComps.id;
        currentDeal.Comps_Approved__c= approvedComps.id;
        
        update currentDeal;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(currentDeal);
        compareRelatedRecordsOnAcquisitionDeal testCompare = new compareRelatedRecordsOnAcquisitionDeal(sc);
        
        PageReference pageRef = Page.compareNonApprvdNApprvdOnAcqDeal;
        pageRef.getParameters().put('id', String.valueOf(currentDeal.Id));
        Test.setCurrentPage(pageRef);
        
        testCompare.compareRelatedObjects();
        Test.stopTest();
        
    }
}