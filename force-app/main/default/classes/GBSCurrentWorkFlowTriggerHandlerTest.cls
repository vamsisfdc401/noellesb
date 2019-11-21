/*****************************************************************************************
Class Name: GBSCurrentWorkFlowTriggerHandlerTest
Purpose: Test class for PCWorkflowTrigger
Version : 1.0
DateCreated : 05/24/2018
CreatedBy : Lakshmi
JIRA : GBS-408
******************************************************************************************/
@isTest
public class GBSCurrentWorkFlowTriggerHandlerTest {

/****************************************************************
Method Name: scenario1
Purpose: method to test currentworkflow when new workflow (except PartnerExemption recordtype) is created for factory GBS-408
******************************************************************/    
 private static testMethod void testWorkFlowInsert() {
     Id workflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
     
     //insert Factory
     Factory__c factory = GBSTestDataUtility.createFactory(1)[0];
     insert factory;
     
     
     //insert workflow of Audit RecordType
     List<Workflow__c> workFlowList = new List<Workflow__c>();
     Workflow__c workflow = new Workflow__c();
     workflow.Factory__c = factory.Id;
     workflow.RecordTypeId = workflowRecTypeId;
     workflow.GBS_Current_Workflow__c = true;
     workFlowList.add(workflow);
     
     Workflow__c workflow1 = new Workflow__c();
     workflow1.Factory__c = factory.Id;
     workflow1.RecordTypeId = workflowRecTypeId;
     workflow1.GBS_Current_Workflow__c = false;
     workFlowList.add(workflow1);
     insert workFlowList;
     
     //system.assertEquals(false, [Select GBS_Current_Workflow__c From Workflow__c Where Id =: workFlowList[1].Id].GBS_Current_Workflow__c);
     
    
     RecursiveTriggerHandler.isFirstTime = true;
     
     //update workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[1].Id];     
     workflow.GBS_Current_Workflow__c = true;
     update workflow;
     
     
     //system.assertEquals(true, [Select GBS_Current_Workflow__c From Workflow__c Where Id =: workFlowList[1].Id].GBS_Current_Workflow__c);  
     
     //delete workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[1].Id];
     delete workflow;

    }
    
}