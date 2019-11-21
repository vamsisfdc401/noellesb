/*****************************************************************************************
Class Name: RecordLockerTest
Purpose: This is the test class for RecordLocker class.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/09/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest
private class RecordLockerTest{
    // This method covers all the material locking and unlocking scenarios.
    @isTest
    static void testMethod_1()
    {
       Test.startTest();
         List<Id>recordids=new List<Id>();
         
         Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Territory__c = 'US';
        insert objMaterial;
        
        recordids.add(objMaterial.id);
        
        RecordLocker.lock(objMaterial.Id);
        RecordLocker.unlock(objMaterial.Id); 
        RecordLocker.isLocked(objMaterial.Id);   
        RecordLocker.lock(recordids);
        RecordLocker.unlock(recordids);
            
       Test.stopTest();  
    }
  
}