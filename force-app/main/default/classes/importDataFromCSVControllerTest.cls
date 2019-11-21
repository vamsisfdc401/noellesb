/*****************************************************************************************
Class Name: importDataFromCSVControllerTest
Purpose: Test class for apex class importDataFromCSVController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class importDataFromCSVControllerTest{

    private static Financials__c currentFinancial;  
    private static Blob importFile;
    private static String importFileName;  
    
    /************************************
    Method Name: testImport
    Purpose: Test method to test the method importCSVFile on the class importDataFromCSVController
    *************************************/ 
    static TestMethod void testImport(){
        
        Recordtype dealRecordTypes= [Select id, DeveloperName from RecordType where developerName='July_2018_Layout' limit 1];
        Test.startTest();
        
        Acquisition_Deal__c currentDeal = new Acquisition_Deal__c ();
        currentDeal.Name = 'Deal through test';
        currentDeal.recordtypeId= dealRecordTypes.id; 
        
        insert currentDeal;
        
        currentFinancial = new Financials__c ();
        currentFinancial.Acquisition_Deal__c= currentDeal.id;
        currentFinancial.This_Home_Ent_Forecast_was_received_on__c = system.today()+1;
        currentFinancial.X1st_year_ROI__c = 16;
        insert currentFinancial;
        
        importFile=Blob.valueOf('1st year Revenue - Theatrical,1st year Revenue - Video,1st year Revenue- Television and Digital,1st Year Revenue - Other,1st year Margin - Theatrical,1st year Margin - Video,1st Year Margin - Other,1st year Margin - International FTV,1st year Margin - International PTV,1st yr Margin-International TVOD/Digital,1st year Margin - International SVOD,1st year Margin - Domestic FTV,1st year Margin - Domestic PTV,1st year Margin - Domestic TVOD/Digital,1st year Margin - Domestic SVOD,1st year Margin - Recoupable Costs,1st year Margin - Non-Recoupable Costs,1st year Margin - Mechanicals,1st year MG,1st year Overages,1st year Net OCF,1st year Contribution %,1st year ROI %,1st year Cash-on-Cash,2nd year Revenue - Video,2nd year Revenue- Television and Digital,2nd year Revenue - Other,2nd year Margin - Theatrical,2nd year Margin - Video,2nd Year Margin - Other,2nd year Margin - International FTV,2nd year Margin - International PTV,2nd yr Margin-International TVOD/Digital,2nd year Margin - International SVOD,2nd year Margin - Domestic FTV,2nd year Margin - Domestic PTV,2nd year Margin - Domestic TVOD/Digital,2nd year Margin - Domestic SVOD,2nd year Margin - Recoupable Costs,2nd year Margin - Non-Recoupable Costs,2nd year Margin - Mechanicals,2nd year MG,2nd year Overages,2nd year Net OCF,2nd year Contribution %,2nd year ROI %,2nd year Cash-on-Cash,Revenue - Theatrical,Revenue - Video,Revenue - Television and Digital,Revenue - Other,Margin - Theatrical,Margin - Video,Margin - Other,Margin - International FTV,Margin - International PTV,Margin - International TVOD / Digital,Margin - International SVOD,Margin - Domestic FTV,Margin - Domestic PTV,Margin - Domestic TVOD / Digital,Margin - Domestic SVOD,Margin - Recoupable Costs,Margin - Non-Recoupable Costs,Margin - Mechanicals,MG,Overages,Net OCF,Contribution %,ROI % ,Cash-on-Cash\r\n1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71\r\n');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(currentFinancial);
        importDataFromCSVController testImport = new importDataFromCSVController(sc);
        
        PageReference pageRef = Page.ImportFinancialSummaryData;        
        pageRef.getParameters().put('id', String.ValueOf(currentFinancial.id));
        Test.setCurrentPage(pageRef);
        
        testImport.csvFileBody = importFile;
        testImport.csvFileName= 'testfile.csv';
        testImport.importCSVFile();
        Test.stopTest();
    }
}