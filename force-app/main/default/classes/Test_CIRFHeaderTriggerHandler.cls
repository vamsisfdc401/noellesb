@isTest
public class Test_CIRFHeaderTriggerHandler {
    @isTest
    public static void testperformRejectAction(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;       
        Account acc3 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc3.CIRF_RIM_Approval__c = true;
        acc3.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc3;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        CIRF_Header__c header3 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc3.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header3.Studio__c = 'Universal';
        header3.isRejected__c = false;
        insert header3;
        CIRF_Material__C cmat3 = CIRF_TestDataFactory.createCIRFMaterial(header3.id, mat.id, 'Draft', 2, 2);
        insert cmat3;
        Task t = CIRF_TestDataFactory.createTask('Call', 'Not Started', UserInfo.getUserId(), cmat3.id, 'Normal','CIRF General Task');       
        insert t; 
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc3.id,'Shweta','Meshram');
        insert atm;
        Test.startTest();
        CIRFHeaderTriggerHandler.HeaderRejected=false;
        header3.isRejected__c = true;
        update header3;
        Test.stopTest();
    }
    @isTest(SeeAllData = true)
    public static void testperformManualApprovalAction(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material1211', '12345', '61 - Universal Pictures', 'AA','');
        mat.Format_Description__c = 'BD';
        insert mat;       
        Account acc4 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc4.CIRF_RIM_Approval__c = true;
        acc4.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc4;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header4 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc4.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header4.Studio__c = 'Universal';
        insert header4;
        CIRF_Material__C cmat4 = CIRF_TestDataFactory.createCIRFMaterial(header4.id, mat.id, 'Draft', 2, 2);
        insert cmat4;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc4.id,'Shweta','Meshram');
        insert atm;
        Test.startTest();
        System.debug('***** '+CIRFHeaderApprovalController.checkValidations(header4.id));
        /*header4.CIRF_Status__c = 'Draft';
        update header4;
        //Test.startTest();
        System.debug('***** '+CIRFHeaderApprovalController.checkValidations(header4.id));
        header4.RIM_Approval__c = true;
        header4.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header4;*/
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData = true)
    public static void testperformManualApprovalAction1(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material1211', '12345', '61 - Universal Pictures', 'AA','');
        mat.Format_Description__c = 'BD';
        insert mat;       
        Account acc4 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc4.CIRF_RIM_Approval__c = true;
        acc4.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc4;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header4 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc4.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header4.Studio__c = 'Universal';
        insert header4;
        CIRF_Material__C cmat4 = CIRF_TestDataFactory.createCIRFMaterial(header4.id, mat.id, 'Draft', 2, 2);
        insert cmat4;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc4.id,'Shweta','Meshram');
        insert atm;
        Test.startTest();
        System.debug('***** '+CIRFHeaderApprovalController.checkValidations(header4.id));
        /*header4.RIM_Approval__c = true;
        header4.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header4;*/
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData = true)
    public static void testperformManualApprovalAction2(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material1211', '12345', '61 - Universal Pictures', 'AA','');
        mat.Format_Description__c = 'BD';
        insert mat;       
        Account acc4 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc4.CIRF_RIM_Approval__c = true;
        acc4.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc4;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header4 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc4.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header4.Studio__c = 'Universal';
        insert header4;
        CIRF_Material__C cmat4 = CIRF_TestDataFactory.createCIRFMaterial(header4.id, mat.id, 'Draft', 2, 2);
        insert cmat4;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc4.id,'Shweta','Meshram');
        insert atm;
        Test.startTest();
        //System.debug('***** '+CIRFHeaderApprovalController.checkValidations(header4.id));
        header4.RIM_Approval__c = true;
        header4.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header4;
        
        Test.stopTest();
    }
    
    @isTest
    public static void testforecastRecords(){
       Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;       
        Account acc4 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc4.CIRF_RIM_Approval__c = true;
        acc4.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc4;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header4 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc4.id, startDate, endDate, insStoreDate, 'Submitted' , false);
        header4.Studio__c = 'Universal';
        insert header4;
        CIRF_Material__C cmat4 = CIRF_TestDataFactory.createCIRFMaterial(header4.id, mat.id, 'Draft', 2, 2);
        insert cmat4;
        header4.CIRF_Status__c = 'Loaded';
 		update header4;
    }
    
}