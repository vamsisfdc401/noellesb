/*****************************************************************************************
Class Name: GBSBatchLMSStatusUpdateTest
Purpose: Test class for apex class GBSBatchLMSStatusUpdate.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/07/2018           Ashok Raghavan          Initial Development
******************************************************************************************/
@isTest (SeeAllData = True)
Private class DeleteEmailFileShareLinkTest 
{
    static testmethod void testBatch_1() {
 	
         Test.startTest();
           		DeleteEmailFileShareLink c = new DeleteEmailFileShareLink();
       			Database.executeBatch(c);
               // System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM LMS__c '), 1);
      		 Test.stopTest();
    }
  
}