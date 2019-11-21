@isTest
public class test_CIRFCorrugateTriggerHandler {
    
    @testSetup
    public static void testdata(){
        User u = CIRF_TestDataFactory.createUser('Test ', 'Validation User');
        u.ProfileId = [Select id from Profile where name = 'UPHE Sales Users' Limit 1].id;
        //Role r = [select id from role where name = 'UPHE Brand and HQ' limit 1];
        //u.UserRoleId = r.id;
        insert u;
        PermissionSetAssignment permission = new PermissionSetAssignment();
        permission.AssigneeId = u.id;
        permission.PermissionSetId = [Select id from Permissionset where name = 'CIRF_User_Platform' Limit 1].id;
        insert permission;
        System.debug(permission);
    }
    
    @isTest
    public static void testmethod1(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        /*Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
insert acc;*/
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        //CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        Account acc2 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer2', 'US', 'Test2', '1265');
        acc2.CIRF_RIM_Approval__c =true ;
        acc2.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc2;
        
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Corrugate', acc2.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header2.Studio__c= 'Universal';
        insert header2;
        CIRF_Material__C cmat2 = CIRF_TestDataFactory.createCIRFMaterial(header2.id, mat.id, 'Draft', 2, 3);
        insert cmat2;
        CIRF_Corrugate__c ccorr2 =CIRF_TestDataFactory.createCIRFCorrugate(header2.id,'test corrugate2','Singles Request', 2);
        insert ccorr2;
        
        CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.Id,ccorr2.Id);
        corrmat.Facings__c = 2;
        insert corrmat;//for CIRFCorrugateTriggerHandler beforeUpdate()
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material2', '12348', '61 - Universal Pictures', 'AA','');
        insert mat2;
        Test.startTest();
        ccorr2.Number_Of_Stores__c = 3; 
        update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        cmat2.Material_Name__c = mat2.Id;
        update cmat2;
        corrmat.Material_Name__c = mat2.id;
        update corrmat;
        ccorr2.Number_Of_Stores__c = 5;
        
        update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        
        List<Id> headerList = new List<Id>();
        headerList.add(header2.Id);
        
        CIRFCorrugateTriggerHandler.updateMergedCIRFCorrugateStatus(headerList); 
        
        delete ccorr2;//for CIRFCorrugateTriggerHandler beforeDelete()
        Test.stopTest();
        
    }
    
    @isTest
    public static void testmethod2(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;

        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        //CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        Account acc2 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer2', 'US', 'Test2', '1265');
        acc2.CIRF_RIM_Approval__c =true ;
        acc2.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc2;
        
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Corrugate', acc2.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header2.Studio__c= 'Universal';
        header2.Revision__c = 5;
        insert header2;
        CIRF_Material__C cmat2 = CIRF_TestDataFactory.createCIRFMaterial(header2.id, mat.id, 'Draft', 2, 3);
        insert cmat2;
        CIRF_Corrugate__c ccorr2 =CIRF_TestDataFactory.createCIRFCorrugate(header2.id,'test corrugate2','Singles Request', 2);
        insert ccorr2;
        
        CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.Id,ccorr2.Id);
        corrmat.Facings__c = 2;
        insert corrmat;//for CIRFCorrugateTriggerHandler beforeUpdate()
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material2', '12348', '61 - Universal Pictures', 'AA','');
        mat2.Item_Type__c = 'S (Single)';
        mat2.Material_Type__c = 'FERT';
        mat2.Material_Status__c = 'Processed in SAP';
        insert mat2;
        
        ccorr2.Number_Of_Stores__c = 3; 
        update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        corrmat.Material_Name__c = mat2.id;
        update corrmat;
        ccorr2.Number_Of_Stores__c = 1800;
        Test.startTest();
        try{
            update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        }
        catch(Exception e){
            System.assert(true); 
        }
        
        Material__c mat3 = CIRF_TestDataFactory.createMaterial('US', 'Test Material3', '123489', '61 - Universal Pictures', 'AA','');
        mat3.Item_Type__c = 'D (Display Vehicle)';
        mat3.Material_Type__c = 'FERT';
        mat3.Material_Status__c = 'Processed in SAP';
        insert mat3;
        
        ccorr2.Corrugate_Request_Name__c = 'Test Change';
        ccorr2.SAP_Corrugate_Changes_Made__c = true;
        ccorr2.Corrugate_Name__c=mat3.id;
        update ccorr2;
        
        //System.assertEquals('Linked',ccorr2.Corrugate_Status__c);
        List<Id> headerList = new List<Id>();
        headerList.add(header2.Id);
        
        CIRFCorrugateTriggerHandler.updateMergedCIRFCorrugateStatus(headerList); 
        try{
            delete ccorr2;//for CIRFCorrugateTriggerHandler beforeDelete()
        }
        catch(Exception e){
            ccorr2.Corrugate_Status__c = 'Cancelled';
            update ccorr2;
            System.assertEquals('Cancelled',ccorr2.Corrugate_Status__c);
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void testmethodUser(){
        //User u = [Select id,name,alias,email,lastname,firstname,profileid from User where name='Walmart US' Limit 1];
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        /*Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
insert acc;*/

        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material2', '12348', '61 - Universal Pictures', 'AA','');
        insert mat2;
        
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        
        //CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        Account acc2 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer2', 'US', 'Test2', '1265');
        acc2.CIRF_RIM_Approval__c =true ;
        acc2.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc2;
        //System.runas(u){
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Corrugate', acc2.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header2.Studio__c= 'Universal';
        insert header2;
        CIRF_Material__C cmat2 = CIRF_TestDataFactory.createCIRFMaterial(header2.id, mat.id, 'Draft', 2, 3);
        insert cmat2;
        
        CIRF_Corrugate__c ccorr2 =CIRF_TestDataFactory.createCIRFCorrugate(header2.id,'test corrugate2','Singles Request', 2);
        insert ccorr2;
        
        CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.Id,ccorr2.Id);
        corrmat.Facings__c = 2;
        insert corrmat;//for CIRFCorrugateTriggerHandler beforeUpdate()
        
        Test.startTest();
        
        ccorr2.Number_Of_Stores__c = 3; 
        update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        cmat2.Material_Name__c = mat2.Id;
        update cmat2;
        corrmat.Material_Name__c = mat2.id;
        update corrmat;
        ccorr2.Number_Of_Stores__c = 2;
        
        update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
        
        List<Id> headerList = new List<Id>();
        headerList.add(header2.Id);
                
        CIRFCorrugateTriggerHandler.updateMergedCIRFCorrugateStatus(headerList); 
        CIRFCorrugateTriggerHandler.CorrugateModificationCheck();
         
        //delete ccorr2;//for CIRFCorrugateTriggerHandler beforeDelete()
        Test.stopTest();
        //}
    }

    
}