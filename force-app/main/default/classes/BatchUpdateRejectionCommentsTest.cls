/*****************************************************************************************
Class Name: BatchUpdateRejectionCommentsTest
Purpose: Test class for apex class BatchUpdateRejectionComments
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/09/2018           Dinakar                 Initial Development
******************************************************************************************/
@isTest
private class BatchUpdateRejectionCommentsTest {
 @isTest
    static void testMethod_1()
    {
        Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal = new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Material__c objMaterial = new Material__c(Territory__c='US',Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT', Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', TM_Origin_Code__c='010 - Universal Pictures', Title__c=objTitle.Id, Deal__c=deal.Id,Label_Code__c='61 - Universal Pictures');
        insert objMaterial;
        
        Id curId = generateAndSubmitObject(objMaterial);
        
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('Rejecting request with a comment.');
        testRej.setAction('Reject');
        testRej.setWorkitemId(curId);
        
        Approval.ProcessResult testRejResult =  Approval.process(testRej);
        
        Test.startTest();
          BatchUpdateRejectionComments uca = new BatchUpdateRejectionComments();
             Database.executeBatch(uca);
        Test.stopTest();

        List<Material__c> lstMat = [Select Id, Rejection_Comments__c, (Select Id, StepStatus, Comments FROM ProcessSteps ORDER BY CreatedDate DESC) From Material__c where id =: objMaterial.id];
        System.assertEquals(lstMat[0].Rejection_Comments__c, lstMat[0].ProcessSteps[0].Comments);

    }
    
    private static Id generateAndSubmitObject(Material__c mat)
    {

        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(mat.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);

        return reqResult.getNewWorkitemIds()[0];
    }
}