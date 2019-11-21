/**
* @author         Ann Luong  
* @date           11/21/2018
* @description    Test class for SuperCIRFMerge class
* @group          CIRF Merge
*
*
*/
@isTest
public with sharing class SuperCIRFMergeTestClass {

	public static final String CIRF_REQUEST_TYPE_SINGLES = 'Singles';
	public static final String CIRF_REQUEST_TYPE_CORRUGATE = 'Corrugate';
	public static final String CIRF_REQUEST_TYPE_JOINT_CORRUGATE = 'Joint Corrugate';
	public static final String CIRF_REQUEST_TYPE_COMINGLED_VIRTUAL_CORRUGATE = 'Comingled Virtual Corrugate';
	public static final String CIRF_REQUEST_TYPE_RESET_TRANSITION = 'Reset/Transition';
	public static final String CIRF_CORRUGATE_TYPE_PALLET = 'Pallet';
	public static final String CIRF_CORRUGATE_TYPE_CARTON = 'Carton';
	public static final String MATERIAL_LABEL_CODE_61_UNIVERSAL = '61 - Universal Pictures';
	public static final String STUDIO_UNIVERSAL = 'Universal';
	public static final String STUDIO_CROSS_STUDIO = 'Cross Studio';

	public static List<CIRF_Header__c> CIRFHeaderList;
	public static List<CIRF_Corrugate__c> CIRFCorrugateList;
	public static List<CIRF_Material__c> CIRFMaterialList;
	public static List<AccountTeamMember> teamMemberList;
	public static Id CIRF1HeaderId;
	public static Id CIRF2HeaderId;
	public static Id superCIRFId;
	public static Id CIRF1Corrugate1Id;
	public static Id CIRF1Corrugate2Id;
	public static Id CIRF2Corrugate1Id;
	public static Id superCIRFHeaderId;

	public SuperCIRFMergeTestClass() {

	}

	static testMethod void mergeCIRFTest() {

	CIRFHeaderList = new List<CIRF_Header__c>();
	CIRFCorrugateList = new List<CIRF_Corrugate__c>();
	CIRFMaterialList = new List<CIRF_Material__c>();
	teamMemberList = new List<AccountTeamMember>();
	CIRF1HeaderId = null;
	CIRF2HeaderId = null;
	superCIRFHeaderId = null;
	CIRF1Corrugate1Id = null;
	CIRF1Corrugate2Id = null;
	CIRF2Corrugate1Id = null;

      //TriggerHandler.bypass('CIRFMaterialTriggerHandler');
      //TriggerHandler.bypass('CIRFHeaderTriggerHandler');


       //	Create Retailer account
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
       //	Create Sales team
       String firstName = 'Sales';
       String lastName = 'Team1';
       AccountTeamMember salesTeamMember = CIRF_TestDataFactory.createSalesAccountTeam(retailer.Id, firstName, lastName);
       teamMemberList.add(salesTeamMember);
       //insert salesTeamMember;
       //	Create RIM team
       firstName = 'RIM';
       lastName = 'Team1';
       AccountTeamMember RIMTeamMember = CIRF_TestDataFactory.createRIMAccountTeam(retailer.Id, firstName, lastName);
       teamMemberList.add(RIMTeamMember);
       //insert RIMTeamMember;
       insert teamMemberList;

       //	Create Child CIRF #1
       String CIRF_Name = 'Child CIRF #1';
       String CIRF_Type = CIRF_REQUEST_TYPE_CORRUGATE;
       Date CIRF_InStoreDate = System.today() - 15;
       Date CIRF_StartDate = Date.today();
       Date CIRF_EndDate = CIRF_StartDate.addDays(30);

       String CIRF_Status = 'Draft';
       Boolean isSuperCIRF = false;
       String Studio = STUDIO_UNIVERSAL;
       CIRF_Header__c childCIRF1Header = CIRF_TestDataFactory.createCIRFHeader(CIRF_Name, CIRF_Type, retailer.Id, CIRF_StartDate, CIRF_EndDate, CIRF_InStoreDate, CIRF_Status, isSuperCIRF);
       childCIRF1Header.Studio__c = Studio;
       childCIRF1Header.RIM_Approval__c = true;
       childCIRF1Header.RIM_Approval_Reason__c = 'RIM Approved CIRF';
       //insert childCIRF1Header;
       CIRFHeaderList.add(childCIRF1Header);


       //	Create Child CIRF #2
       CIRF_Name = 'Child CIRF #2';
       CIRF_Type = CIRF_REQUEST_TYPE_CORRUGATE;
       CIRF_StartDate = System.Today();
       CIRF_EndDate = CIRF_StartDate.addDays(30);
       CIRF_InStoreDate = System.Today() - 15;
       CIRF_Status = 'Draft';
       Studio = STUDIO_UNIVERSAL;
       CIRF_Header__c childCIRF2Header = CIRF_TestDataFactory.createCIRFHeader(CIRF_Name, CIRF_Type, retailer.Id, CIRF_StartDate, CIRF_EndDate, CIRF_InStoreDate, CIRF_Status, isSuperCIRF);
        childCIRF2Header.Studio__c = Studio;
       //insert childCIRF2Header;
       CIRFHeaderList.add(childCIRF2Header);


       //	Create Super CIRF

	   CIRF_Name = 'Super CIRF 1';
       CIRF_Type = CIRF_REQUEST_TYPE_JOINT_CORRUGATE;
       CIRF_StartDate = Date.today();
       CIRF_EndDate = CIRF_StartDate.addDays(30);
       CIRF_InStoreDate = System.Today() - 15;
       CIRF_Status = 'Draft';
       isSuperCIRF = true;
       Studio = STUDIO_CROSS_STUDIO;
       CIRF_Header__c superCIRFHeader = CIRF_TestDataFactory.createCIRFHeader(CIRF_Name, CIRF_Type, retailer.Id, CIRF_StartDate, CIRF_EndDate, CIRF_InStoreDate, CIRF_Status, isSuperCIRF);
        superCIRFHeader.Studio__c = Studio;
       CIRFHeaderList.add(superCIRFHeader);

       insert CIRFHeaderList;

       CIRF1HeaderId = CIRFHeaderList[0].Id;
       CIRF2HeaderId = CIRFHeaderList[1].Id;
       superCIRFId = CIRFHeaderList[2].Id;
       CIRFHeaderList[0].Super_CIRF__c = superCIRFId;
       CIRFHeaderList[1].Super_CIRF__c = superCIRFId;
       system.debug('Test Class - Super CIRF Id: ' + superCIRFId);


       //	Create 2 corrugates for Child CIRF #1
       String corrugateName = 'Corrugate #1';
       String corrugateType = CIRF_CORRUGATE_TYPE_PALLET;
       Integer numberOfStores = 10;
       CIRF_Corrugate__c childCIRF1Corrugate1 = CIRF_TestDataFactory.createCIRFCorrugate(CIRF1HeaderId, corrugateName, corrugateType, numberOfStores);
       //insert childCIRF1Corrugate1;
       CIRFCorrugateList.add(childCIRF1Corrugate1);

       corrugateName = 'Corrugate #2';
       corrugateType = CIRF_CORRUGATE_TYPE_CARTON;
       numberOfStores = 5;
       CIRF_Corrugate__c childCIRF1Corrugate2 = CIRF_TestDataFactory.createCIRFCorrugate(CIRF1HeaderId, corrugateName, corrugateType, numberOfStores);
       //insert childCIRF1Corrugate2;
       CIRFCorrugateList.add(childCIRF1Corrugate2);

        //	Create 1 corrugates for Child CIRF #2
       corrugateName = 'Corrugate #1';
       corrugateType = CIRF_CORRUGATE_TYPE_PALLET;
       numberOfStores = 5;
       CIRF_Corrugate__c childCIRF2Corrugate1 = CIRF_TestDataFactory.createCIRFCorrugate(CIRF2HeaderId, corrugateName, corrugateType, numberOfStores);
       //insert childCIRF2Corrugate1;
       CIRFCorrugateList.add(childCIRF2Corrugate1);

       //insert CIRFCorrugateList;

       //CIRF1Corrugate1Id = CIRFCorrugateList[0].Id;
       //CIRF1Corrugate2Id = CIRFCorrugateList[1].Id;
       //CIRF2Corrugate1Id = CIRFCorrugateList[2].Id;

       //	Create materials
       List<Material__c> materialList = new List<Material__c>();
      
       //	Create 2 CIRF Materials for Child CIRF #1
       String materialName = 'TEST ITEM1 (2018) DVD1212';
       String materialNumber = '0000011111';
       String materialLabelCode = MATERIAL_LABEL_CODE_61_UNIVERSAL;
       String dChainStatus = 'AC';
       String oldMaterialId = null;
       Material__c material1 = CIRF_TestDataFactory.createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
       materialList.add(material1);

       materialName = 'TEST ITEM2 (2019) DVD222333' ;
       materialNumber = '0000022222';
       materialLabelCode = MATERIAL_LABEL_CODE_61_UNIVERSAL;
       dChainStatus = 'RP';
       oldMaterialId = null;
       Material__c material2 = CIRF_TestDataFactory.createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
       materialList.add(material2);


       materialName = 'TEST ITEM3 (2020) DVD43435';
       materialNumber = '00000333333';
       materialLabelCode = MATERIAL_LABEL_CODE_61_UNIVERSAL;
       dChainStatus = 'AC';
       oldMaterialId = null;
       Material__c material3 = CIRF_TestDataFactory.createMaterial(territory, materialName, materialNumber, materialLabelCode, dChainStatus, oldMaterialId);
       materialList.add(material3);
       insert materialList;

       //	Add CIRF materials

       List<CIRF_Material__c> childCIRFMaterialList = new List<CIRF_Material__c>();

       Integer unitsToOrder = 10;
       Integer replenUnits = 2;
       String CIRF_MaterialStatus = 'Draft';
       CIRF_Material__c childCIRF1Material1 = CIRF_TestDataFactory.createCIRFMaterial(CIRF1HeaderId, material1.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
       childCIRFMaterialList.add(childCIRF1Material1);
 
       CIRF_Material__c childCIRF1Material2 = CIRF_TestDataFactory.createCIRFMaterial(CIRF1HeaderId, material2.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
       childCIRFMaterialList.add(childCIRF1Material2);     

       childCIRFMaterialList = new List<CIRF_Material__c>();
       unitsToOrder = 5;
       replenUnits = 1;
       CIRF_MaterialStatus = 'Draft';
       CIRF_Material__c childCIRF2Material1 = CIRF_TestDataFactory.createCIRFMaterial(CIRF2HeaderId, material1.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
       childCIRFMaterialList.add(childCIRF2Material1);

       CIRF_Material__c childCIRF2Material2 = CIRF_TestDataFactory.createCIRFMaterial(CIRF2HeaderId, material3.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
       childCIRFMaterialList.add(childCIRF2Material2);

       CIRF_Material__c superCIRFMaterial1 = CIRF_TestDataFactory.createCIRFMaterial(superCIRFId, material1.Id,CIRF_MaterialStatus,unitsToOrder, replenUnits);
       childCIRFMaterialList.add(superCIRFMaterial1);       

       insert childCIRFMaterialList;

       //TriggerHandler.clearbypass('CIRFMaterialTriggerHandler');
       //TriggerHandler.clearbypass('CIRFHeaderTriggerHandler');


       //	Submit Child CIRF for approval
       //CIRFHeaderApprovalController.CheckValidations(CIRF1HeaderId);

       system.debug('Test Class 2- Super CIRF Id: ' + superCIRFId);

       //	Perform CIRF Merge
	Test.startTest();
       List<String> mergeResult = new List<String>();
       List<List<String>> mergeParmList = new List<List<String>>();
       List<String> parmList = new List<String>();
       parmList.add(superCIRFId);
       parmList.add(CIRF1HeaderId);
       parmList.add(CIRF2HeaderId);
       system.debug('Test class - Parm List: ' + parmList);
       mergeParmList.add(parmList);
       mergeResult = SuperCIRFMergeHelper.mergeCIRFs(mergeParmList);

       Integer DMLLimit = Limits.getLimitDMLStatements();
       system.debug('@@@@@DML Limit after Merge ' + DMLLimit);

       
       //   Revise child CIRF and resubmit
       List<String> reviseReasonList = CIRFReviseBtnController.getRevisionReasonPicklist();

       if (!reviseReasonList.isEmpty()) {
            CIRFReviseBtnController.checkRevision(CIRF1HeaderId, reviseReasonList[0] );
            CIRFHeaderApprovalController.checkValidations(CIRF1HeaderId);
       }

       DMLLimit = Limits.getLimitDMLStatements();
       system.debug('@@@@@DML Limit after revision ' + DMLLimit);

       /*   Bypass tests below to avoid SOQL exceeding limit issue
      
       //   Cancel child CIRF and resubmit
       List<String> cancelReasonList = CIRFHeaderCancelController.getCancelReasonPicklist();
       if (!cancelReasonList.isEmpty()) {
            CIRFHeaderCancelController.cancelHeader(CIRF1HeaderId, cancelReasonList[0]);
       }

       DMLLimit = Limits.getLimitDMLStatements();
       system.debug('@@@@@DML Limit after cancel CIRF_Header__c ' + DMLLimit);


       TriggerHandler.bypass('CIRFHeaderTriggerHandler');
       TriggerHandler.bypass('CIRFHMaterialTriggerHandler');

       List<Id> cancelHeaderIdList = new List<Id>();
       cancelHeaderIdList.add(superCIRFId);
       CIRFMaterialTriggerHandler.updateSuperCIRFMaterials(childCIRFMaterialList);
       DMLLimit = Limits.getDMLStatements();
       system.debug('@@@@@DML Limit after update CIRF Materials ' + DMLLimit);


       Set<Id> childMatSet = new Set<Id>();
       childMatSet.add(CIRF1HeaderId);
       CIRFHeaderTriggerHandler.updateChildCIRFMatStatus(childMatSet);
     
      
      TriggerHandler.clearbypass('CIRFHeaderTriggerHandler');
      TriggerHandler.clearbypass('CIRFMaterialTriggerHandler');
      */

       Test.stopTest();
 
       
    }


}