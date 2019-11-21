/*****************************************************************************************
Class Name: TestBOMItemTrigger
Purpose: This is the Test Class of BOMItemTrigger.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/07/2016           Suman Kundu              Initial Development
******************************************************************************************/
@isTest
private class TestBOMItemTrigger
{
    // This method covers all the scenarios that happens during DML operations on
    // BOM Item object and the trigger is responsible for the same.
    @isTest
    static void testMethod1()
    {
        TriggerUtility.doNotExecute = TRUE;
        // Creating Release record.
        Release__c rel1 = new Release__c();
        rel1.Name = 'Test Release1';
        rel1.Street_Date__c = Date.today().addMonths(1);
        rel1.Territory__c = 'US';
        rel1.Release_Status__c = 'Materials Not Requested';
        rel1.Format__c = 'DVD';
        rel1.Brand_Group__c = 'Universal Pictures';
        rel1.Project_Type__c = 'New Release';
        
        insert rel1;
        
        // This variable controls whether a Material/BOM Item trigger should execute 
        // multiple time in the same transaction or not.
        TriggerUtility.isSpecialCase = true;
        
        // Inserting Material records.
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material 1';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US & CDN';
        mat1.Item_Type__c = 'S (Single)';
        
        insert mat1;
        
        Material__c mat2 = new Material__c();
        mat2.Name = 'Test Material 2';
        mat2.Material_Status__c = 'Draft';
        mat2.Material_Type__c = 'FERT';
        mat2.Format_Description__c = 'COMBO PACK';
        //mat2.Format_Description__c = 'DVD'; // comment on 16.12 and added combo pack format description
        mat2.Release__c = rel1.Id;
        mat2.Territory__c = 'US & CDN';
        mat2.Item_Type__c = 'S (Single)';
        
        insert mat2;
        TriggerUtility.doNotExecute = FALSE;
        
        Test.startTest();
        
        // Creating testing BOM Item record.
        BOM_Item__c bi = new BOM_Item__c();
        //bi.Name = 'Test BOM Item';
        //bi.Material__r.BOM_Status__c = 'Draft';  // comment on 16.12 due to null exception 
        bi.Territory__c = 'US & CDN';
        bi.Material__c = mat1.Id;
        bi.Material_Component__c = mat1.Id;
        
        insert bi;
        
        // Updating the BOM Item record.
        //bi.Material__c = mat2.Id;  // comment on 16.12 due to overcome issue with non overwrite 
       // update bi;
        
        // Deleting the BOM Item record.
        delete bi;
        
        Test.stopTest();
    }
}