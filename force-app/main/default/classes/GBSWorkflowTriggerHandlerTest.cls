@isTest(SeeAllData = FAlSE)
public class GBSWorkflowTriggerHandlerTest {
  private static  Id AuditRecordTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
  private static Id WaiverRecordTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Waiver').getRecordTypeId();
  
    @isTest
    public static void Scenario1()
    {  //Scenerio1 to test After insert trigger
          List<Workflow__c> workflowlist = new List<workflow__c>();   
        
        //Create a Test Factory Record
        Factory__c Factory= new Factory__c (Name = 'Test Factory');
        insert Factory;
        
        //Create a test Audit Workflow Record
        
        Workflow__c workflow1 = new workflow__c ( Workflow_CustomName__c = 'Test Workflow', RecordTypeID = AuditRecordTypeId,Action_Status__c = 'Correction Required', Factory__r = Factory );
        workflowlist.add( workflow1);
        
        update Factory;
        //Create a test Audit Workflow Record
        Workflow__c workflow2 = new workflow__c ( Workflow_CustomName__c = 'Test Workflow', RecordTypeID = WaiverRecordTypeId,Factory__r = Factory   );
        workflowlist.add( workflow2);
        
        Test.startTest();
        insert workflowlist;
    	Factory.of_Audit_Workflows__c = (Factory.of_Audit_Workflows__c == null ? 0 : Factory.of_Audit_Workflows__c) + 1;      
        Factory.of_Waiver_Workflows__c = (Factory.of_Waiver_Workflows__c == null ? 0 : Factory.of_Waiver_Workflows__c) + 1;  
        update Factory;
        Map<id,workflow__c> oldMapworkflow = new Map<id,workflow__c>();
       
        workflow1.RecordTypeId =WaiverRecordTypeId;
        workflow2.RecordTypeId =AuditRecordTypeId;
        update workflow1;
        update workflow2;
        oldMapworkflow.put(workflow1.id,workflow1);
        oldMapworkflow.put(workflow2.id,workflow2);
       
        GBSWorkflowTriggerHandler.executeOnAfterUpdate(workflowlist,oldMapworkflow);
        GBSWorkflowTriggerHandler.executeOnAfterDelete(workflowlist);
        Test.stopTest();
      
    }
}