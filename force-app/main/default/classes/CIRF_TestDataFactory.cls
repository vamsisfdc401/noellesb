/**
* @author         Ann Luong  
* @date           11/21/2018
* @description    Utility class to generate test data for CIRF
* @group          Utility
*
*
*/
@isTest
public with sharing class CIRF_TestDataFactory
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
    public static final String CIRF_CROSS_STUDIO = 'Cross Studio';
    public static final String CIRF_UPHE_STUDIO = 'Universal';
    
    public static CIRF_Header__c testAccount;
    public static Account acctRetailer; 
    
    
    
    public static Account createRetailerAccount(string RetailerName, string Territory, string retailerGroup, string soldTo) {
        Account retailer = new Account();
        retailer.Name = RetailerName;
        retailer.RecordTypeId = Utility.getRecordTypeId(Label.CIRF_Account_RecordType,'Account');
        retailer.CIRF_Retailer_Group__c = retailerGroup;
        retailer.Territory__c = Territory;
        //retailer.CIRF_Sold_To__c = soldTo; //HEITCIRF-547
        retailer.Sold_To__c = soldTo;
        return retailer;	
    }
    
    public static AccountTeamMember createRIMAccountTeam(id retailerId, string firstName, string lastName) {
        AccountTeamMember crtm = createAccountTeamMember(retailerId,  firstName, lastName, CIRF_RIM_ACCOUNT_TEAM_ROLE);
        return crtm;
    }  
    
    public static AccountTeamMember createSalesAccountTeam(id retailerId, string firstName, string lastName) {
        AccountTeamMember cstm = createAccountTeamMember(retailerId,  firstName, lastName, CIRF_Sales_ACCOUNT_TEAM_ROLE);
        return cstm;
    }  
    
    
    public static AccountTeamMember createAccountTeamMember(Id accountId, String firstName, String lastName, String accountTeamRole) {
        AccountTeamMember at = new AccountTeamMember();
        User u = createUser(firstName, lastName);
        insert u;
        at.UserId = u.Id;
        at.AccountId = accountId;
        at.TeamMemberRole = accountTeamRole;
        at.AccountAccessLevel = 'Edit';
        at.CaseAccessLevel = 'Edit';
        at.OpportunityAccessLevel = 'Edit';
        return at;
    }
    
    
    public static User createUser(String firstName, String lastName) {
        User u = new User();
        String uName = firstname + lastname;
        uName = uName.trim().replaceAll(' ','');
        u.alias = firstName.left(1) + lastName.left(6);
        u.email= uName + '@xyz.com';
        u.username = u.email;
        u.emailencodingkey='UTF-8';
        u.lastname = lastName;
        u.firstname = firstName;
        u.languagelocalekey='en_US'; 
        u.localesidkey='en_US';
        u.profileid =  UserInfo.getProfileId();
        u.timezonesidkey='America/Los_Angeles';
        u.profileId = UserInfo.getProfileId();
        return u;
    }
    
    public static CIRF_Header__c createCIRFHeader(string CIRF_Name, string CIRF_Type, Id retailerId, date CIRF_StartDate, date CIRF_EndDate, date CIRF_InStoreDate, string CIRF_Status, boolean isSuperCIRF) {
        CIRF_Header__c ch = new CIRF_Header__c();
        ch.CIRF_Name__c = CIRF_Name;
        ch.Request_Type__c = CIRF_Type;
        ch.Retailer__c = retailerId;
        ch.CIRF_Start_Date__c = CIRF_StartDate;
        ch.CIRF_End_Date__c = CIRF_EndDate;
        ch.CIRF_In_Store__c = CIRF_InStoreDate;
        ch.CIRF_Status__c = CIRF_Status;
        ch.Is_Super_CIRF__c = isSuperCIRF;
        ch.Revision__c = 0;
        if (isSuperCIRF)
            ch.Studio__c = CIRF_CROSS_STUDIO;
        else
            ch.Studio__c = CIRF_UPHE_STUDIO;
        return ch;
    }

     public static CIRF_Header__c createCIRFHeader(string CIRF_Name, string CIRF_Type, Id retailerId, date CIRF_StartDate, date CIRF_EndDate, date CIRF_InStoreDate, string CIRF_Status, boolean isSuperCIRF, String studio) {
        CIRF_Header__c ch = new CIRF_Header__c();
        ch.CIRF_Name__c = CIRF_Name;
        ch.Request_Type__c = CIRF_Type;
        ch.Retailer__c = retailerId;
        ch.CIRF_Start_Date__c = CIRF_StartDate;
        ch.CIRF_End_Date__c = CIRF_EndDate;
        ch.CIRF_In_Store__c = CIRF_InStoreDate;
        ch.CIRF_Status__c = CIRF_Status;
        ch.Is_Super_CIRF__c = isSuperCIRF;
        ch.Revision__c = 0;
        ch.Studio__c = studio;
        return ch;
    }
    
    public static CIRF_Material_Forecast__c createCIRFMaterialForecast(Id CIRF_HeaderId,Id CIRF_MaterialId,DateTime Archive_Date,Date Calculated_Date,String Group_Calcul,string Forecast_Type,decimal Quantity,Id MaterialId,String Stage,decimal Revision)
    {
        CIRF_Material_Forecast__c frct = new CIRF_Material_Forecast__c();
        frct.CIRF_Header__c = CIRF_HeaderId;
        frct.CIRF_Material__c = CIRF_MaterialId;
        frct.Archive_Date__c = Archive_Date;
        frct.Calculated_Date__c = Calculated_Date;
        frct.Group_Calculation__c = Group_Calcul;
        frct.Forecast_Type__c =Forecast_Type;
        frct.Quantity__c = Quantity;
        frct.Material_to_Forecast_Number__c = MaterialId;
        frct.Stage__c = Stage;
        frct.Revision_Number__c = Revision;
        return frct;
    }
    public static CIRF_Material__c createCIRFMaterial(Id CIRF_HeaderId, Id materialId, String CIRF_MaterialStatus, Integer unitsToOrder, Integer replenUnits) {
        CIRF_Material__c cm = new CIRF_Material__c();
        cm.CIRF_Header__c = CIRF_HeaderId;
        cm.CIRF_Material_Status__c = CIRF_MaterialStatus;
        cm.Units_to_Order__c = unitsToOrder;
        cm.Replen_Units__c = replenUnits;
        cm.Unique_vs_National__c = MATERIAL_NATIONAL;
        cm.Material_Name__c = materialId;
        cm.External_Id__c = CIRF_HeaderId + '-' + cm.Material_Name__r.Material_Number__c;
        //cm.split_forecast__c=splitforecast;
        return cm;
    }
    public static CIRF_Material_Exceptions__c createCmatException(Id materialId, Id retailerId, Date startdate, Date enddate) {
        CIRF_Material_Exceptions__c exc = new CIRF_Material_Exceptions__c();
        exc.Material__c = materialId;
        exc.Retailer__c = retailerId;
        exc.Start_Date__c = startdate;
        exc.End_Date__c = enddate;
        return exc;
    }
    public static Bom_Item__C createBomItem(Id materialId) {
        Bom_Item__C bm =new Bom_Item__C();
        bm.Material__c=materialId;
        bm.Material_Component__c= materialId;
        return bm;
    }
    public static Sub_Label_Code__c createSublabelCode(Boolean SublabelCode,string labelcode) {
        Sub_Label_Code__c bm =new Sub_Label_Code__c();
        bm.CIRF_BOM_Required__c=SublabelCode;
        bm.Label_Code__c=labelcode;
        return bm;
    }
    public static CIRF_Corrugate__c createCIRFCorrugate(Id CIRF_HeaderId, String corrugateName, String corrugateType, Integer numberofStores) {
        CIRF_Corrugate__c cc = new CIRF_Corrugate__c();
        cc.CIRF_Header__c = CIRF_HeaderId;
        cc.Corrugate_Status__c = 'Draft';
        cc.Corrugate_Type__c = corrugateType;
        cc.Corrugate_Request_Name__c = corrugateName;
        cc.Number_Of_Stores__c = numberOfStores;
        return cc;
    }
    
    public static CIRF_Corrugate_Material__c createCIRFCorrugateMaterial(Id CIRF_MaterialId, Id CIRF_CorrugateId) {
        CIRF_Corrugate_Material__c ccm = new CIRF_Corrugate_Material__c();
        ccm.CIRF_Material__c = CIRF_MaterialId;
        ccm.CIRF_Corrugate__c = CIRF_CorrugateId;
        ccm.External_Id__c = ccm.CIRF_Material__r.CIRF_Header__c + '-' + CIRF_CorrugateId;
        return ccm;
    }
    
    public static CIRF_Corrugate_Material__c createCIRFCorrugateMaterial_New(Id MaterialId, Id CIRF_CorrugateId) {
        CIRF_Corrugate_Material__c ccm = new CIRF_Corrugate_Material__c();
        //ccm.CIRF_Material__c = CIRF_MaterialId;
        ccm.CIRF_Corrugate__c = CIRF_CorrugateId;
        ccm.Material_Name__c = MaterialId;
        ccm.Facings__c = 0;
        ccm.Units_per_Pocket__c = 0;
        //ccm.External_Id__c = ccm.CIRF_Material__r.CIRF_Header__c + '-' + CIRF_CorrugateId;
        return ccm;
    }
    
    public static Material__c createMaterial(String territory, String materialName, String materialNumber, String materialLabelCode, String dChainStatus, String oldMaterialId) {
        
        Material__c m = new Material__c();
        m.recordTypeId = Utility.getRecordTypeId('Default Value','Material__c');
        m.Territory__c = territory;
        m.Format__c = MATERIAL_FORMAT_DVD;
        m.Label_Code__c = materialLabelCode;
        m.Format_Description__c = MATERIAL_FORMAT_DESCRIPTION_DVD;
        m.Material_Status__c = MATERIAL_STATUS_PROCESSED_IN_SAP;
        m.Material_Type__c = 'FERT';
        m.name = materialName + ' ' + m.Format_Description__c; 
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
    
    
    public static Task createTask(String subject,string status,Id userId,Id relatedId,string priority,String recordTypeName){
        Task t = new Task();
        t.Subject = subject;
        t.Status = status;
        t.WhatId = relatedId;
        t.OwnerId = userId;
        t.Priority = priority;
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return t;
    }
}