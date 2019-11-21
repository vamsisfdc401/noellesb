/*****************************************************************************************
Class Name: BatchVProjectUpdateTest
Purpose: Test class for apex class BatchVProjectUpdate.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/10/2016           Mohit Goyal              Initial Development
******************************************************************************************/
@isTest
private class BatchVProjectUpdateTest{
    
    /************************************
    Method Name: saveEachRecords
    Purpose: for saving PIR changes for Particular Record
    *************************************/    
    static testmethod void testBatch_1() {
        // The query used by the batch job.
        String query = 'SELECT Id,Project_Finish_Date__c FROM v_Project_Request__c';

        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
       
       v_Project_Request__c[] vProjList = new List<v_Project_Request__c>();
       
      // for (Integer i=0;i<10;i++) {
           v_Project_Request__c vProj = new v_Project_Request__c();
            vProj.Release__c = release.ID;
            vProj.SAP_Project_Description__c = 'Test';
            vProj.Project_Category__c = 'V006';
            vProj.Project_Studio__c = '001';
            vProj.POS_Order_End_Date__c = Date.Today();
            vProj.Project_Finish_Date__c = Date.Today().addDays(-5);
            vProj.Return_End_Date__c = Date.Today();
            
           vProjList.add(vProj);
       //}
       insert vProjList ;

       Test.startTest();
       batchVProjectUpdate c = new batchVProjectUpdate();
       Database.executeBatch(c);
       Test.stopTest();
    }
}