@isTest
public class Test_CIRFReviseBtnController {
	@isTest
    public static void testgetRevisionReasonPicklist(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';
        header.Revision_Reason__c = 'Promotion Date has changed';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        insert atm;
		Task t = CIRF_TestDataFactory.createTask('Call', 'Not Started', UserInfo.getUserId(), cmat.id, 'Normal','CIRF General Task');
        insert t;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(header.id);
        req1.setSubmitterId(UserInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('RIM_Approval');
        req1.setSkipEntryCriteria(true);
        req1.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
        Approval.process(req1);
        
        CIRFReviseBtnController.getRevisionReasonPicklist();
        CIRFReviseBtnController.checkRevision(header.Id, header.Revision_Reason__c);
        header.CIRF_Status__c = 'Submitted';
        update header;
        CIRFReviseBtnController.checkRevision(header.Id, header.Revision_Reason__c);
    }
}