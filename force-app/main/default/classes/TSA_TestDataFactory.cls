/**
* @author         Ann Luong  
* @date           01/02/2019
* @description    Utility class to generate test data for TSA
* @group          Utility
*
*
*/
@isTest
public with sharing class TSA_TestDataFactory
{
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
	public static final List<String> MEDIA_NAME_LIST = new  List<String>{'0010 - 0001 - RTL MKTG-AGENCY FEES'};
	public static final List<String> MEDIA_TYPE_LIST = new List<String>{'1 - ACCOUNT PROMOTIONS - VIDEO'};
	public static final List<String> FUND_LIST = new List<String>{'0001 - RMF'};
	public static final String TERRITORY_US = 'US';
	public static final String ACCOUNT_TYPE_INDIRECT_CUSTOMER = 'Indirect Customer';


	public static Account createRetailerAccount(String name, String custType, String territory) {
        Account retailer = new Account();
        retailer.Name = name;
        retailer.RecordTypeId = Utility.getRecordTypeId('UPHE Retailer','Account');
        //retailer.CIRF_Retailer_Group__c = 'Group A';
        retailer.Territory__c = territory;
        //retailer.CIRF_Sold_To__c = '12345';
        retailer.Type = custType;
        return retailer;	
    }

    public static Account createUSIndirectCustomer(String name ) {
    	Account ic = createRetailerAccount(name, ACCOUNT_TYPE_INDIRECT_CUSTOMER, TERRITORY_US);
    	return ic;
    }

    public static Request_Header__c createTSARequestHeader(Id custId, String authorizationType, String authorizationName) {
    	Request_Header__c hdr = new Request_Header__c();
    	hdr.recordtypeid = Utility.getRecordTypeId('Trade Spend Authorization', 'Request_Header__c');
    	hdr.TSA_Authorization_Comment__c = 'Test 123';
    	hdr.TSA_Authorization_Name__c = authorizationName;
    	hdr.Status__c = 'Draft';
    	hdr.TSA_Material_Effective_Date__c = date.TODAY();
    	hdr.TSA_Authorization_Type__c = authorizationType;
    	hdr.TSA_Direct_Customer_Lookup__c = custId;
    	insert hdr;
    	return hdr;
    }

    public static Request_Detail__c createTSARequestDetail(Id hdrId, Integer batchNumber) {
    	Request_Detail__c det = new Request_Detail__c();
    	det.recordtypeid = Utility.getRecordTypeId('Trade Spend Authorization','Request_Detail__c');
    	det.Request_Header__c = hdrId;
    	det.Status__c = 'Draft';
    	det.TSA_SAP_Integration_Status__c = 'N';
    	det.TA_Batch_Number__c = batchNumber;
    	insert det;
    	return det;
    }

    public static List<Material__c> createMaterialList() {

    	List<Material__c> matList = new List<Material__c>();
       String materialName = 'LEAVE NO TRACE (2018) DVD';
       String materialNumber = '0000011111';
       String materialLabelCode = MATERIAL_LABEL_CODE_61_UNIVERSAL;
       String dChainStatus = 'AC';
       String oldMaterialId = null;
       String territory = 'US';
       Material__c mat = createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
       matList.add(mat);

       materialName = 'LEAVE NO TRACE (2019) DVD';
       materialNumber = '0000011112';
       mat = createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
       matList.add(mat);

       insert matList;
       return matList;

    }

    public static Map<String, Material__c> createMaterialMap() {
    	Map<String, Material__c> matMap = new Map<String, Material__c>();
    	List<Material__c> matList = createMaterialList();
    	for (Material__c m : matList) {
    		matMap.put(m.Material_Number__c, m);
    	}

    	return matMap;
    }

    public static Material__c createMaterial(String territory, String materialName, String materialNumber, String materialLabelCode, String dChainStatus, String oldMaterialId) {
        
        Material__c m = new Material__c();
        m.recordTypeId = Utility.getRecordTypeId('Default Value','Material__c');
        m.Territory__c = territory;
        m.Format__c = MATERIAL_FORMAT_DVD;
        m.Label_Code__c = MATERIAL_LABEL_CODE_61_UNIVERSAL;
        m.Format_Description__c = MATERIAL_FORMAT_DESCRIPTION_DVD;
        m.Material_Status__c = MATERIAL_STATUS_PROCESSED_IN_SAP;
        m.Material_Type__c = 'FERT';
        m.name = materialName;
        m.Material_Description_Unique__c = materialName + ' ' +  m.Format_Description__c;
        m.Association_Required__c=TRUE;
        m.Item_Type__c = MATERIAL_ITEM_TYPE_MULTI_PACK;
        m.Item_Code__c = MATERIAL_ITEM_CODE_SS;
        m.Deletion_Flag__c = False;
        m.Material_Number__c = materialNumber;
        m.D_Chain_Spec__c=dChainStatus;
        //m.Old_Material_No__c = oldMaterialId;
        return m;


    }

    public static List<Request_Material__c> createTSARequestMatList(Id hdrId, Id detId, List<Material__c> matList, String mediaName, String mediaType, String fund) {
    	List<Request_Material__c> reqMatList = new List<Request_Material__c>();
    	Request_Material__c reqMat;
    	Id reqMatRecordTypeId = Utility.getRecordTypeId('TSA_Material','Request_Material__c');
    	
    	for (Material__c mat : matList) {
    		reqMat = new Request_Material__c();
    		reqMat.recordtypeid = reqMatRecordTypeId;
    		reqMat.Request_Detail__c = detId;
    		reqMat.Request_Header__c = hdrId;
    		reqMat.Material__c = mat.Id;
    		reqMat.TSA_Media_Name__c = mediaName != ''? mediaName :  MEDIA_NAME_LIST[0];
    		reqMat.TSA_Media_Type__c = mediaType != '' ? mediaType :  MEDIA_TYPE_LIST[0];
    		reqMat.TSA_Cost__c = 1500;
    		reqMat.TSA_Ad_Start_Date__c = date.TODAY() - 30;
    		reqMat.TSA_Ad_End_Date__c = date.TODAY();
    		reqMat.TSA_Fund__c = fund != '' ? fund : FUND_LIST[0];
    		reqMatList.add(reqMat);
    	}

    	insert reqMatList;
    	return reqMatList;

    }

}