@isTest
public class RequestDetailTriggerHandlerTest {
	public static final String TEST_PLANNING_GROUP = 'testCampaignName'; 
    public static final String CIRF_RETAILERS_RECORD_TYPE_NAME = 'CIRF_Retailers';
    public static final String CIRF_RIM_ACCOUNT_TEAM_ROLE = 'CIRF RIM Team';
    public static final String CIRF_SALES_ACCOUNT_TEAM_ROLE = 'CIRF Account Team';
    public static final String MATERIAL_ITEM_CODE_SS = 'SS - SINGLE SELECTION';
    public static final String MATERIAL_ITEM_TYPE_MULTI_PACK = 'M (Multipack)';
    public static final String MATERIAL_STATUS_PROCESSED_IN_SAP = 'Processed in SAP';
    public static final String MATERIAL_FORMAT_DVD = '02 - DVD';
    public static final String MATERIAL_FORMAT_DESCRIPTION_DVD = 'DVD';
    public static final string MATERIAL_UNIQUE = 'Unique';
    public static final String MATERIAL_NATIONAL = 'National';
	public static final String MATERIAL_LABEL_CODE_61_UNIVERSAL = '61 - Universal Pictures';


	@isTest static void TSA_PositiveTest() {
		// Implement test code
		//	Create Indirect Customer account
		Account cust = TSA_TestDataFactory.createUSIndirectCustomer('Target - US');
		//	Create TSA Request Header record
        String authorizationType = '0002';
        String authorizationName = 'Test 123';
		Request_Header__c hdr = TSA_TestDataFactory.createTSARequestHeader(cust.Id, authorizationType, authorizationName);
		//	Create TSA Request Detail record
		Request_Detail__c det = TSA_TestDataFactory.createTSARequestDetail(hdr.id, 1);
		//	Create  Material List
		List<Material__c> matList = new List<Material__c>();

        String mediaName = '';
        String mediaType = '';
        String fund = '';
		List<Request_Material__c> reqMatList = TSA_TestDataFactory.createTSARequestMatList(hdr.id, det.id, matList, mediaName, mediaType, fund); 
 
        //  Submit TSA request to SAP

        hdr.Status__c = 'Submitted';
        update hdr;

        det.Status__c = 'Submitted to SAP';
        det.TSA_SAP_Submission_Date__c = date.TODAY();
        update det;
        system.assertEquals('Submitted to SAP', det.status__c);


       Test.startTest();


        Request_Detail__c det2 = [select id, name, status__c from Request_Detail__c where id = : det.id limit 1];

        //  Change Integration Status to Processed
        det2.TSA_SAP_Integration_Status__c = 'P';
        det2.TSA_SAP_Status_Date__c = date.TODAY();
        update det2;
        det2 = [select id, name, status__c from Request_Detail__c where id = : det.id limit 1];
        system.assertEquals('Processing', det2.Status__c);
        
        //  Change Integration Status to Success (Sterling)
        det2.TSA_SAP_Integration_Status__c = 'S';
        det2.TSA_SAP_Status_Date__c = date.TODAY();
        update det2;
        //System.assertEquals('Processing', det2.status__c);

        //  Change Integration Status to SAP Authorized
        det2.TSA_SAP_Integration_Status__c = 'A';
        det2.TSA_SAP_Authorization_Number__c = 'A12345';
		det2.TSA_SAP_Status_Date__c = date.TODAY();
        update det2;

        Request_Detail__c det2A = [select id, Status__c from Request_Detail__c where id =: det2.id];
        System.assertEquals('Accepted',det2A.Status__c);

        Request_Header__c h = [select id, TSA_SAP_Authorization_Number__c
                               from Request_Header__c
                               where id = : det.Request_Header__c];
        system.debug('Auth Number: ' + h.TSA_SAP_Authorization_Number__c);
        system.assertEquals('A12345', h.TSA_SAP_Authorization_Number__c);


        Test.stopTest();

	}
	
	@isTest static void TSA_Error_Test() {
		
        Account cust = TSA_TestDataFactory.createUSIndirectCustomer('Target - US');
        //  Create TSA Request Header record
        String authorizationType = '0002';
        String authorizationName = 'Test 123';
        Request_Header__c hdr = TSA_TestDataFactory.createTSARequestHeader(cust.Id, authorizationType, authorizationName);

        //  Create TSA Request Detail record
        Request_Detail__c det = TSA_TestDataFactory.createTSARequestDetail(hdr.id, 1);
        //  Create  Material List
        List<Material__c> matList = new List<Material__c>();

        String mediaName = '';
        String mediaType = '';
        String fund = '';
        List<Request_Material__c> reqMatList = TSA_TestDataFactory.createTSARequestMatList(hdr.id, det.id, matList, mediaName, mediaType, fund); 

        //  Submit TSA request to SAP
        
        Test.startTest();

        Request_Detail__c det2 = [select id, name, status__c from Request_Detail__c where id = : det.id limit 1];
        //system.assertEquals('Submitted to SAP', det2.status__c);


        //  Change Integration Status to Processed
        det2.TSA_SAP_Integration_Status__c = 'E';
        det2.TSA_SAP_Status_Date__c = date.TODAY();
        update det2;
        //System.assertEquals('Error', det2.status__c);
        
        //  Change Integration Status to Success (Sterling)
        det2.TSA_SAP_Integration_Status__c = 'S';
        det2.TSA_SAP_Status_Date__c = date.TODAY();
        update det2;

        Request_Detail__c det2A = [select id, Status__c, Request_Header__c from Request_Detail__c where id =: det2.id];
        System.assertEquals('Processing',det2A.Status__c);

        //  Change Integration Status to SAP Authorized
        det2.TSA_SAP_Integration_Status__c = 'R';
        det2.TSA_SAP_Status_Date__c = date.TODAY();
        det2.TSA_SAP_Error_Message__c = 'Invalid Direct Customer';
        update det2;

        det2A = [select id, Status__c, Request_Header__c from Request_Detail__c where id =: det2.id];
        System.assertEquals('Rejected',det2A.Status__c);

        Test.stopTest();      
	}
	

}