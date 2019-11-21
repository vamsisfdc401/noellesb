/*****************************************************************************************
Class Name: legalSummaryViewsOnAcqDealTest
Purpose: Test class for apex class legalSummaryViewsOnAcqDeal
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class legalSummaryViewsOnAcqDealTest{

    private static Acquisition_Deal__c currentDeal;
    private static Title__c approvedTitle;
    private static Title__c nonApprovedTitle;
    private static Primary_Terms__c approvedPT;
    private static Primary_Terms__c nonApprovedPT;
    private static Financials__c approvedFinancials;
    private static Financials__c nonApprovedFinancials;
    private static Risk_Compliance__c approvedRisk;
    private static Risk_Compliance__c nonApprovedRisk;
    
    /************************************
    Method Name: testSummaryPage
    Purpose: Test summary page
    *************************************/ 
    static TestMethod void testSummaryPage(){
        List<Title__c> titlesToInsert = new List<Title__C>();
        List<Primary_Terms__c > ptsToInsert = new List<Primary_Terms__c >();
        List<Financials__c > finsToInsert = new List<Financials__c >();
        List<Risk_Compliance__c > risksToInsert = new List<Risk_Compliance__c >();
        
        Recordtype dealRecordTypes= [Select id, DeveloperName from RecordType where developerName='July_2018_Layout' limit 1];
        Test.startTest();
        
        currentDeal = new Acquisition_Deal__c ();
        currentDeal.Name = 'Deal through test';
        currentDeal.recordtypeId= dealRecordTypes.id; 
        
        insert currentDeal;
        
        approvedTitle = new Title__c();
        approvedTitle.Name = 'LAQ Approved Title through test';
        approvedTitle.LAQ_Acquisition_Deal__c = currentDeal.id;
        
        titlesToInsert.add(approvedTitle); 
        
        nonApprovedTitle = new Title__c();
        nonApprovedTitle.Name = 'LAQ Non Approved Title through test';
        nonApprovedTitle.LAQ_Acquisition_Deal__c = currentDeal.id;
        
        titlesToInsert.add(nonApprovedTitle); 
        
        approvedPT = new Primary_Terms__c ();
        approvedPT.Acquisition_Deal__c= currentDeal.id;
        ptsToInsert.add(approvedPT);
        
        nonApprovedPT = new Primary_Terms__c();
        nonApprovedPT.Acquisition_Deal__c= currentDeal.id;
        ptsToInsert.add(nonApprovedPT);
        
        approvedFinancials = new Financials__c ();
        approvedFinancials.Acquisition_Deal__c= currentDeal.id;
        finsToInsert.add(approvedFinancials);
        
        nonApprovedFinancials = new Financials__c ();
        nonApprovedFinancials.Acquisition_Deal__c= currentDeal.id;
        finsToInsert.add(nonApprovedFinancials);
        
        approvedRisk = new Risk_Compliance__c ();
        approvedRisk.Acquisition_Deal__c= currentDeal.id;
        risksToInsert.add(approvedRisk);
        
        nonApprovedRisk = new Risk_Compliance__c ();
        nonApprovedRisk.Acquisition_Deal__c= currentDeal.id;
        risksToInsert.add(nonApprovedRisk);
        
        insert ptsToInsert;
        insert finsToInsert;
        insert risksToInsert;
        insert titlesToInsert;
        
        currentDeal.Primary_Term__c = nonApprovedPT.id;
        currentDeal.Primary_Term_Approved__c = approvedPT.id;
        currentDeal.Financials__c = nonApprovedFinancials.id;
        currentDeal.Financials_Approved__c = approvedFinancials.id;
        currentDeal.Risk_Compliance__c = nonApprovedRisk.id;
        currentDeal.Risk_Compliance_Approved__c = approvedRisk.id;
        currentDeal.Title_Context__c = nonApprovedTitle.id;
        currentDeal.Title_Approved__c = ApprovedTitle.id;
        
        update currentDeal;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(currentDeal);
        legalSummaryViewsOnAcqDeal testLegalSummPage = new legalSummaryViewsOnAcqDeal(sc);
        
        PageReference pageRef = Page.LAQ_LegalSummaryViewsApproved;
        pageRef.getParameters().put('id', String.valueOf(currentDeal.Id));
        Test.setCurrentPage(pageRef);
        
        testLegalSummPage.queryRelatedObjects();
        Test.stopTest();
        
    }
}