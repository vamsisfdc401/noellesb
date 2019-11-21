/*****************************************************************************************
Class Name: TestMaterialTrigger
Purpose: This is the Test Class of Material Trigger.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/07/2016           Suman Kundu              Initial Development
******************************************************************************************/
@isTest
private class TestMaterialTrigger
{
    // This method is responsible to cover all the DML operations handled in Material trigger.
    @isTest
    static void testMethod1()
    {
        // Setting up the test data.
        // Creating Release data.
        Release__c rel1 = new Release__c();
        rel1.Name = 'Test Release1';
        rel1.Street_Date__c = Date.today().addMonths(1);
        rel1.Territory__c = 'US';
        rel1.Release_Status__c = 'Materials Not Requested';
        rel1.Format__c = 'DVD';
        rel1.Brand_Group__c = 'Universal Pictures';
        rel1.Project_Type__c = 'New Release';
        
        insert rel1;
        
        Release__c rel2 = new Release__c();
        rel2.Name = 'Test Release2';
        rel2.Street_Date__c = Date.today().addMonths(1);
        rel2.Territory__c = 'US';
        rel2.Release_Status__c = 'Materials Not Requested';
        rel2.Format__c = 'DVD';
        rel2.Brand_Group__c = 'Universal Pictures';
        rel2.Project_Type__c = 'New Release';
        
        insert rel2;
        
        Test.startTest();
        
        // This is seeting up the special case for the trigger to get executed multiple times during a Transaction. 
        TriggerUtility.isSpecialCase = true;
        
        // Inserting Material record.
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US & CDN';
        
        insert mat1;
        
        // Deleting material record.
        Release_Material__c toDel = [Select Id,Material__c from Release_Material__c where Material__c =: mat1.Id and Release__c =: rel1.Id];
        delete toDel;
        delete mat1;
        
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2()
    {
        // Setting up the test data.
        // Creating Release data.
        Release__c rel1 = new Release__c();
        rel1.Name = 'Test Release1';
        rel1.Street_Date__c = Date.today().addMonths(1);
        rel1.Territory__c = 'US';
        rel1.Release_Status__c = 'Materials Not Requested';
        rel1.Format__c = 'DVD';
        rel1.Brand_Group__c = 'Universal Pictures';
        rel1.Project_Type__c = 'New Release';
        
        insert rel1;
        
        Release__c rel2 = new Release__c();
        rel2.Name = 'Test Release2';
        rel2.Street_Date__c = Date.today().addMonths(1);
        rel2.Territory__c = 'US';
        rel2.Release_Status__c = 'Materials Not Requested';
        rel2.Format__c = 'DVD';
        rel2.Brand_Group__c = 'Universal Pictures';
        rel2.Project_Type__c = 'New Release';
        
        insert rel2;
        
        Test.startTest();
        
        // This is seeting up the special case for the trigger to get executed multiple times during a Transaction. 
        TriggerUtility.isSpecialCase = true;
        
        Id matRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        
        Material__c mat2 = new Material__c();
        mat2.Name = 'Test Material';
        mat2.Material_Status__c = 'SAP Error';    
        mat2.Material_Type__c = 'FERT';
        mat2.Format_Description__c = 'Combo Pack';
        mat2.Release__c = rel1.Id;
        mat2.Territory__c = 'US & CDN';
        mat2.RecordTypeId = matRecordTypeId;
        
        insert mat2;
        
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3()
    {
        // Setting up the test data.
        // Creating Release data.
        Release__c rel1 = new Release__c();
        rel1.Name = 'Test Release1';
        rel1.Street_Date__c = Date.today().addMonths(1);
        rel1.Territory__c = 'US';
        rel1.Release_Status__c = 'Materials Not Requested';
        rel1.Format__c = 'DVD';
        rel1.Brand_Group__c = 'Universal Pictures';
        rel1.Project_Type__c = 'New Release';
        
        insert rel1;
        
        Release__c rel2 = new Release__c();
        rel2.Name = 'Test Release2';
        rel2.Street_Date__c = Date.today().addMonths(1);
        rel2.Territory__c = 'US';
        rel2.Release_Status__c = 'Materials Not Requested';
        rel2.Format__c = 'DVD';
        rel2.Brand_Group__c = 'Universal Pictures';
        rel2.Project_Type__c = 'New Release';
        
        insert rel2;
        
        Test.startTest();
        
        // This is seeting up the special case for the trigger to get executed multiple times during a Transaction. 
        TriggerUtility.isSpecialCase = true;
        
        // Inserting Material record.
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US & CDN';
        
        insert mat1;
        
        Id matRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        mat1.Release__c = rel2.Id;
        mat1.Material_Status__c = 'Sent to SAP';
        mat1.RecordTypeId = matRecordTypeId;
        update mat1;
        
        Test.stopTest();
    }
}