/**
* @author         Ann Luong  
* @date           11/21/2018
* @description    Test class for SuperCIRFMerge class
* @group          CIRF Merge
*
*
*/
@isTest
public with sharing class TaskModelTest {

	public static List<CIRF_Material__c> CIRFMaterialList;
	public static final String MATERIAL_LABEL_CODE_61_UNIVERSAL = '61 - Universal Pictures';
	public static final String CIRF_REQUEST_TYPE_SINGLES = 'Singles';
	public static Map<Id, CIRF_Header__c> CIRFHeaderMap;
	public static final String CIRF_REQUEST_TYPE_CORRUGATE = 'Corrugate';
	public static final String CIRF_REQUEST_TYPE_JOINT_CORRUGATE = 'Joint Corrugate';
	public static final String STUDIO_UNIVERSAL = 'Universal';
	public static final String STUDIO_CROSS_STUDIO = 'Cross Studio';
	

	public TaskModelTest() {



	}

	static testMethod void createPIRTaskTest() {
		CIRFHeaderMap = new Map<Id, CIRF_Header__c>();
		//	Create Retailer
       String retailerName = 'Retailer - US';
       String territory = 'US';
       String retailerGroupId = 'Group 1';
       String soldTo = '0123456789';
       Boolean RIMApproval = true;
       String noRIMApproval = null;
       Account retailer = CIRF_TestDataFactory.createRetailerAccount(retailerName, territory, retailerGroupId, soldTo);
       retailer.CIRF_RIM_Approval__c = RIMApproval;
        retailer.CIRF_No_RIM_Approval__c = noRIMApproval;
        insert retailer;

		//	Create CIRF Header
		      //	Create Child CIRF #1
       String CIRF_Name = 'CIRF Header';
       String CIRF_Type = CIRF_REQUEST_TYPE_CORRUGATE;
       Date CIRF_InStoreDate = System.today() - 15;
       Date CIRF_StartDate = Date.today();
       Date CIRF_EndDate = CIRF_StartDate.addDays(30);

       String CIRF_Status = 'Draft';
       Boolean isSuperCIRF = false;
       CIRF_Header__c CIRFHeader = CIRF_TestDataFactory.createCIRFHeader(CIRF_Name, CIRF_Type, retailer.Id, CIRF_StartDate, CIRF_EndDate, CIRF_InStoreDate, CIRF_Status, isSuperCIRF);
        CIRFHeader.Studio__c = STUDIO_UNIVERSAL;
       insert CIRFHeader;
       Id CIRFHeaderId = CIRFHeader.Id;

 
 	//	Create Material

      String materialName = 'LEAVE NO TRACE (2018) DVD ' + ' ' + datetime.now().format();
      String materialNumber = '0000011111';
      String materialLabelCode = MATERIAL_LABEL_CODE_61_UNIVERSAL;
      String dChainStatus = 'AC';
      String oldMaterialId = null;
      Material__c material = CIRF_TestDataFactory.createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
      insert material;

	//	Create CIRF Material

	CIRFMaterialList = new List<CIRF_Material__c>();
	Integer unitsToOrder = 10;
      Integer replenUnits = 2;
      String CIRF_MaterialStatus = 'Draft';
      CIRF_Material__c CIRFMaterial = CIRF_TestDataFactory.createCIRFMaterial(CIRFHeader.Id, material.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
      insert CIRFMaterial;
      CIRFMaterialList.add(CIRFMaterial);

       CIRFHeader.CIRF_Status__c = 'Submitted';
       update CIRFHeader;

       CIRFHeader = [select Id, CIRF_Status__c, Retailer__c, Retailer__r.Territory__c, CIRF_Start_Date__c, CIRF_End_Date__c, Retailer_Sold_To__c
       				 from CIRF_Header__c where Id =: CIRFHeaderId limit 1];

       system.debug('CIRFHeader: ' + CIRFHeader);
       CIRFHeaderMap.put(CIRFMaterial.Id, CIRFHeader);
 	  TaskModel.createPIRTask(CIRFMaterialList, CIRFHeaderMap);
 	  TaskModel.createFinalizeTask(CIRFMaterialList, CIRFHeaderMap);
 	  TaskModel.createUpdateMaterialStatusTask(CIRFMaterialList, CIRFHeaderMap);
	  TaskModel.createUpdateMaterialExceptionTask(CIRFMaterialList, CIRFHeaderMap);
	  TaskModel.createCMApproveExceptionTask(CIRFMaterialList, CIRFHeaderMap);
	  TaskModel.createPlanningApproveExceptionTask(CIRFMaterialList, CIRFHeaderMap);
	  TaskModel.createInventoryRequestTask(CIRFMaterialList);
	  TaskModel.createSplitForecastTask(CIRFMaterialList);
	}
}