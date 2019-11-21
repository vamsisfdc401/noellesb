/*****************************************************************************************
Class Name: GBSBatchFactoryStatusUpdateTest
Purpose: Test class for apex class GBSBatchLMSStatusUpdate.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/25/2018           Ashok Raghavan          Initial Development
******************************************************************************************/
@isTest (SeeAllData = FAlSE)
Private class GBSBatchFactoryStatusUpdateTest 
{
 static testmethod void testBatch_1() {
     
        String query = 'Select Factory__c, Action_Status__c from Workflow__c where Factory__c IN :FactoryIds and Action_Status__c != null and GBS_Last_Action_Status_Date__c !=null order by GBS_Last_Action_Status_Date__c desc';

        Factory__c Factory = new Factory__c();
        Factory.Name = 'Test Factory';
        Factory.Approval_Expiration_Date__c =  System.today();
        Insert Factory;
        
        Workflow__c workflow = new Workflow__c();
        workflow.Factory__c = factory.Id;
        workflow.RecordTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
        workflow.GBS_Current_Workflow__c = true;
        workflow.Action_Status__c = 'Waiver Expired';
        workflow.GBS_Last_Action_Status_Date__c = Date.Today();
        insert workflow;
        
        System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Factory__c '), 1);
       
       	Factory.Factory_Status__c = 'NBCU Audit - Conditionally Approved';
        update Factory;
     
        List<FactoryActiontoStatus__c> customRules = FactoryActiontoStatus__c.getAll().values();
        List<Factory__c> Facttoupdate =[Select id,Factory_Status__c from Factory__c where ID = :Factory.id];
             
        Test.startTest();
        IF(Factory.Factory_Status__c == 'NBCU Audit - Conditionally Approved' ||  Factory.Factory_Status__c == 'NBCU Audit - Officially Approved' ||
            Factory.Factory_Status__c == 'Waiver Review - Approved' ||  Factory.Factory_Status__c == 'Waiver Review - Approved (Spot Check Passed)')
        {
        	Factory.Factory_Status__c = 'Waiver Review - Approved' ;
            update Factory;
        }
                
        GBSBatchFactoryStatusUpdate c = new GBSBatchFactoryStatusUpdate();
   		Database.executeBatch(c);
        System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Factory__c '), 1);
        Test.stopTest();
    }
}