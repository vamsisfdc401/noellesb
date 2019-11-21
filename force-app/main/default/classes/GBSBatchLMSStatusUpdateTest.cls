/*****************************************************************************************
Class Name: GBSBatchLMSStatusUpdateTest
Purpose: Test class for apex class GBSBatchLMSStatusUpdate.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/09/2018           Ashok Raghavan          Initial Development
******************************************************************************************/
@isTest (SeeAllData = FAlSE)
Private class GBSBatchLMSStatusUpdateTest 
{
    static testmethod void testBatch_1() {
      
        
        String query = 'Select Id ,Product_Rights_Group__r.Rights_Group_End_Date__c  from LMS__c' +  ' where Product_Rights_Group__r.Rights_Group_End_Date__c <= today';
        
          Contract__c contracts = new Contract__c();
            contracts.Name = 'Test Contract';
            contracts.Contract_End_Date__c = Date.Today();
            
            Insert contracts;
        
            Product_Rights_Group__c productRightsGroup = new Product_Rights_Group__c();
          
            productRightsGroup.Name = 'Test Product Rights Group';
            //productRightsGroup.Rights_Group_End_Date__c = Date.Today();
            productRightsGroup.Contract__c = contracts.id;
            insert productRightsGroup;
          
            LMS__c LMS = new LMS__c();
            LMS.Contract__c = contracts.id;
            LMS.Product_Rights_Group__c = productRightsGroup.id;
            insert LMS;
        
             Test.startTest();
           		GBSBatchLMSStatusUpdate c = new GBSBatchLMSStatusUpdate();
       			Database.executeBatch(c);
                System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM LMS__c '), 1);
      		 Test.stopTest();
    }
}