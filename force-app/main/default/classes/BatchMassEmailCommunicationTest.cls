/*****************************************************************************************
Class Name: BatchMassEmailCommunicationTest
Purpose: Test class for apex class BatchMassEmailCommunication.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna             Initial Development
******************************************************************************************/
@isTest(SeeAllData = FAlSE)
private class BatchMassEmailCommunicationTest{
    
    /**************************************************************************************************
    Method Name: testBatch_1
    Purpose: To send email notification to users of public group for releases created current date
    ***************************************************************************************************/    
    static testmethod void testBatch_1() { 
    
        // The query used by the batch job.
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();       
        String query = 'SELECT Id, Name, Brand_Group__c, Online_Consumer_Solicitation_Date__c, Street_Date__c, CreatedDate, LastModifiedDate FROM Release__c where RecordTypeId != :CompRecordTypeId AND CreatedDate = TODAY'; 
        

        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns.Territory__c = 'US';
        materialIns.Material_Status__c = 'Processed in SAP';
        insert materialIns;
        Test.startTest();
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'ROH',Release__c = release.id, Item_Type__c='S (Single)',Item_Code__c='DS - DISC');
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;
       
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

       
       BatchMassEmailCommunication c = new BatchMassEmailCommunication();
       Database.executeBatch(c);
       System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Release__c '), 1);
       Test.stopTest();
    }
}