@isTest
public class Test_CIRFTaskTriggerHandler {
    public static Id recordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByDeveloperName().get('Material').getRecordTypeId();
    @TestSetup
    public static void testData(){
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat.CIRF_US_D_Chain_Spec__c = 'NR - ';
        mat.CIRF_CDN_D_Chain_Spec__c = 'NR - ';
        mat.Item_Type__c = 'S (Single)';
        mat.Material_Type__c = 'FERT';
        mat.Material_Status__c = 'Processed in SAP';
        mat.Deletion_Flag__c = false;
        mat.RecordTypeId = recordTypeId;
        mat.Territory__c = 'US';
        mat.Material_Number__c = '123456789';
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);        
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Singles', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';  
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Task t = CIRF_TestDataFactory.createTask('Call','Not Started',UserInfo.getUserId(),cmat.id,'Normal','CIRF Inventory Request');  
        t.CIRF_Alternate_Qty__c = 1;
        //t.Material__c = mat.id;
        t.CIRF_Header__c = header.id;
        t.CIRF_Current_Material_Id__c = mat.id;
        insert t;
    }
    
    @isTest
    public static void validateInventoryTaskTest(){    
        Task t = [select id, subject, status, OwnerId, WhatId, Priority, RecordTypeId,CIRF_Material_On_Hand_Qty__c from task LIMIT 1];
            t.CIRF_Material_On_Hand_Qty__c = 5;
            update t;
            t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Split Forecast').getRecordTypeId();
            t.Status ='Completed';
            update t;
    }
    
    
    @isTest
    public static void checkIfApprovedTest(){
        test.startTest();
        Task t = [select id, subject, status, OwnerId, WhatId, Priority, RecordTypeId,CIRF_Material_On_Hand_Qty__c from task LIMIT 1];
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Exception Approval').getRecordTypeId();
        t.Status = 'Approved';
        t.Type = 'Customer Marketing';
        t.Description = 'test task';
        update t;
        t.Type = 'Planning';
        update t; 
        
        //th.updateCIRFOpenTaskCount(new List<Task>{t});
        TaskTriggerHandler.getTaskCustomFields(new List<Task>{t});//added by Kalyani
        TaskTriggerHandler.updTaskToCompleted(new List<Id> {t.id});//added by Kalyani
        //CIRFTaskTriggerHandler ctask = new CIRFTaskTriggerHandler();
        //ctask.checkIfApproved();
        test.stopTest();

    }
    @isTest
    public static void testreject(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material1', '12345', '61 - Universal Pictures', 'AA','');
        mat.CIRF_US_D_Chain_Spec__c = 'FR - ';
        mat.CIRF_CDN_D_Chain_Spec__c = 'FR - ';
        mat.Item_Type__c = 'S (Single)';
        mat.Material_Type__c = 'FERT';
        mat.Material_Status__c = 'Processed in SAP';
        mat.Deletion_Flag__c = false;
        mat.RecordTypeId = recordTypeId;
        mat.Territory__c = 'US';
        mat.Material_Number__c = '12345678999';
        insert mat;
        Task t = [select id, subject, status, OwnerId, WhatId, Priority, RecordTypeId,CIRF_Material_On_Hand_Qty__c,Material__c from task where WhatId != '' LIMIT 1];
        //CIRFTaskTriggerHandler.oldTaskCustomFields = new Map<Id,Task>([SELECT Id, Material__c, CIRF_Alternate_Replen_Units__c, CIRF_Alternate_Qty__c, CIRF_Exception_Type__c, CIRF_Exception_End_Date__c, 
         //                                             CIRF_Exception_Start_Date__c FROM Task where id = :t.id]);
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Exception Approval').getRecordTypeId();
        t.Description = 'reject';
        t.Subject = 'Send Letter';
        t.Status = 'Rejected';
        t.Remove_from_Promotion__c = true;
        t.CIRF_Alternate_Qty__c = 2;
        t.Type = 'Planning';
        //t.Material__c = mat.id;
        test.startTest();
        update t;
        try{
        TaskTriggerHandler.checkMaterialLookupFilter(mat, t, [Select Id, CIRF_Header__r.Territory__c from CIRF_Material__c limit 1]);
        } catch(Exception ex) {//this throws error
        }
        delete t;//added by Kalyani
        test.stopTest();
    }
    /*@isTest
    public static void testreject1(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('US', 'Test Material1', '1234', '61 - Universal Pictures', 'AA','');
        insert mat1;
        Account acc1 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer1', 'US', 'Test1', '12346');
        insert acc1;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);        
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Singles', acc1.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';  
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Task t = CIRF_TestDataFactory.createTask('Call','Not Started',UserInfo.getUserId(),cmat.id,'Normal','CIRF Inventory Request');  
        insert t;
        Test.startTest();
        t.Material__c = mat1.id;
        t.CIRF_Alternate_Qty__c = 1;
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Exception Approval').getRecordTypeId();
        t.Description = 'reject';
        t.Subject = 'Send Letter';
        t.Status = 'Rejected';
        t.Remove_from_Promotion__c = true;
        t.CIRF_Alternate_Qty__c = 2;
        t.Type = 'Planning';       
        update t;
        Test.stopTest(); 
        
    }*/
}