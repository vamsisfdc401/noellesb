/*****************************************************************************************
Class Name: FlowCloneRecordTest
Purpose: Test class for apex class FlowCloneRecord
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class flowCloneRecordTest{

   private static Acquisition_Deal__c currentDeal;
   
   /************************************
    Method Name: testcloneObjectRecord
    Purpose: Test the method cloneObjectRecord on the class FlowCloneRecord 
    *************************************/ 
   static TestMethod void testcloneObjectRecord(){
   
        Recordtype dealRecordTypes= [Select id, DeveloperName from RecordType where developerName='July_2018_Layout' limit 1];
        Test.startTest();
        
        currentDeal = new Acquisition_Deal__c ();
        currentDeal.Name = 'Deal through test';
        currentDeal.recordtypeId= dealRecordTypes.id; 
        
        insert currentDeal;
        List<Id> allDealsIds = new List<Id>();
        allDealsIds.add(currentDeal.id);
        
        FlowCloneRecord.cloneObjectRecord(allDealsIds);

   }
}