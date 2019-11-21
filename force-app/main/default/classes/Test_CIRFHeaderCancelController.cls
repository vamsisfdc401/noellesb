@isTest
public class Test_CIRFHeaderCancelController {
	@isTest
    public static void testgetCancelReasonPicklist(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailercancel', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Headercancel', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Cancelled' , false);
        header.Cancellation_Reason__c = 'Customer decided to not move forward with promotion';
        header.Studio__c = 'Universal';
        insert header;
        CIRFHeaderCancelController.getCancelReasonPicklist();
    }
    @isTest
    public static void testcancelHeader(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailercancel', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Headercancel', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Loaded' , false);
        header.Studio__c = 'Universal';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Task t = CIRF_TestDataFactory.createTask('Call', 'Not Started', UserInfo.getUserId(), cmat.id, 'Normal','CIRF General Task');
        insert t;
        
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        insert atm;        
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(header.id);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('RIM_Approval');
        req1.setSkipEntryCriteria(true);
        req1.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
        Approval.process(req1);
        Test.startTest();
        CIRFHeaderCancelController.cancelHeader(header.Id,'Customer decided to not move forward with promotion');
        test.stopTest();
        //header.CIRF_Status__c ='Draft';
        //update header;
        //CIRFHeaderCancelController.cancelHeader(header.Id,'Customer decided to not move forward with promotion');
    }
    
}