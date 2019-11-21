/*****************************************************************************************
Class Name: BatchUnfollowReleaseTest
Purpose: Test class for apex class BatchUnfollowRelease.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna             Initial Development
******************************************************************************************/
@isTest(SeeAllData = FAlSE)
private class BatchUnfollowReleaseTest{
    
    /**************************************************************************************************
    Method Name: testBatch_1
    Purpose: To unfollow user who is following release when street date of release is today
    ***************************************************************************************************/    
    static testmethod void testBatch_1() { 
    
        // The query used by the batch job.
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();       
        String query = 'SELECT Id, Name, Brand_Group__c, Online_Consumer_Solicitation_Date__c, Street_Date__c, CreatedDate, LastModifiedDate FROM Release__c where RecordTypeId != :CompRecordTypeId AND CreatedDate = TODAY'; 
        

        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        release.Street_Date__c = System.today();
        insert release;
        
        /*EntitySubscription entity = new EntitySubscription();
        entity.SubscriberId = Userinfo.getUserId();
        entity.ParentId = release.Id;
        insert entity;*/
        
        v_Project_Request__c[] vProjList = new List<v_Project_Request__c>();
       
        v_Project_Request__c vProj = new v_Project_Request__c();
        vProj.Release__c = release.ID;
        vProj.SAP_Project_Description__c = 'Test';
        vProj.Project_Category__c = 'V006';
        vProj.Project_Studio__c = '001';
        vProj.POS_Order_End_Date__c = Date.Today();
        vProj.Project_Finish_Date__c = Date.Today().addDays(-5);
        vProj.Return_End_Date__c = Date.Today();
            
        vProjList.add(vProj);
       
       insert vProjList ;

       Test.startTest();
       BatchUnfollowRelease c = new BatchUnfollowRelease();
       Database.executeBatch(c);
       System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Release__c '), 1);
       Test.stopTest();
    }
}