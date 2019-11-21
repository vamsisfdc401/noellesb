/*****************************************************************************************
Class Name: GBSWorkFlowApprovalDateHandlerTest
Purpose: Test class for WorkflowTrigger
Version : 1.0
DateCreated : 06/29/2018
CreatedBy : Lakshmi
JIRA : GBS-489
******************************************************************************************/
@isTest
public class GBSWorkFlowApprovalDateHandlerTest {

/****************************************************************
Method Name: scenario1
Purpose: method to test Approval Expiration Date on WorkFlow record- GBS-489
******************************************************************/   
    private static testMethod void testApprovalExpirationDate() {
        
     Id workflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
      
     //insert Factory
     Factory__c factory = GBSTestDataUtility.createFactory(1)[0];
     factory.Factory_Country__c = 'Bangladesh';
     factory.Factory_Status__c = 'NBCU Audit - Correction Required';
     //insert factory;
        
     Factory__c factory1 = GBSTestDataUtility.createFactory(1)[0];
     factory1.Factory_Country__c = 'India';
     factory.Factory_Status__c = 'NBCU Audit - Correction Required';
     //insert factory1;
     insert new List<Factory__c>{factory, factory1};
     
     
     //insert workflow of Audit RecordType
     List<Workflow__c> workFlowList = new List<Workflow__c>();
     Workflow__c workflow = new Workflow__c();
     workflow.Factory__c = factory.Id;
     workflow.RecordTypeId = workflowRecTypeId;
     workflow.GBS_Current_Workflow__c = true;
     workflow.Action_Status__c = 'Pending Official Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 9);
     workflow.Audit_Score__c = 84;
     workFlowList.add(workflow);
     
     Workflow__c workflow1 = new Workflow__c();
     workflow1.Factory__c = factory1.Id;
     workflow1.RecordTypeId = workflowRecTypeId;
     workflow1.GBS_Current_Workflow__c = false;
     workFlowList.add(workflow1);
     
     Workflow__c workflow2 = new Workflow__c();
     workflow2.Factory__c = factory.Id;
     workflow2.RecordTypeId = workflowRecTypeId;
     workflow2.GBS_Current_Workflow__c = true;
     workflow2.Action_Status__c = 'Pending Conditional Approval';
     workflow2.Audit_Date__c = Date.newInstance(2018, 12, 9);
     workflow2.Audit_Score__c = 84;
     workFlowList.add(workflow2);   
        
     insert workFlowList;
     
     Test.startTest();
     //system.assertEquals(Date.newInstance(2019, 12, 9), [Select Approval_Expiration_Date__c From Workflow__c][0].Approval_Expiration_Date__c);
     
     //RecursiveTriggerHandler.isFirstTime = true;
     
     //update workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[1].Id];     
     workflow.GBS_Current_Workflow__c = true;
     workflow.Action_Status__c = 'Pending Official Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 20);
     workflow.Audit_Score__c = 99;   
     update workflow;
     
     //system.assertEquals(Date.newInstance(2020, 12, 20), [Select Approval_Expiration_Date__c From Workflow__c][1].Approval_Expiration_Date__c);  
     
     //update workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[1].Id];     
     workflow.GBS_Current_Workflow__c = true;
     workflow.Action_Status__c = 'Pending Official Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 20);
     workflow.Audit_Score__c = 86;   
     update workflow;
     
     //system.assertEquals(Date.newInstance(2020, 12, 20), [Select Approval_Expiration_Date__c From Workflow__c][1].Approval_Expiration_Date__c);  
     
     Test.stopTest();
        
          
    }   


    /****************************************************************
Method Name: scenario1
Purpose: method to test Approval Expiration Date on WorkFlow record- GBS-489
******************************************************************/   
    private static testMethod void testApprovalExpirationDate1() {
        
     Id workflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
      
     //insert Factory
     Factory__c factory = GBSTestDataUtility.createFactory(1)[0];
     factory.Factory_Country__c = 'Bangladesh';
     factory.Factory_Status__c = 'NBCU Audit - Correction Required';
     //insert factory;
        
     Factory__c factory1 = GBSTestDataUtility.createFactory(1)[0];
     factory1.Factory_Country__c = 'India';
     factory.Factory_Status__c = 'NBCU Audit - Correction Required';
     //insert factory1;
     insert new List<Factory__c>{factory, factory1};
     
     
     //insert workflow of Audit RecordType
     List<Workflow__c> workFlowList = new List<Workflow__c>();
     Workflow__c workflow = new Workflow__c();
     workflow.Factory__c = factory.Id;
     workflow.RecordTypeId = workflowRecTypeId;
     workflow.GBS_Current_Workflow__c = true;
     workflow.Action_Status__c = 'Pending Official Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 9);
     workflow.Audit_Score__c = 84;
     workFlowList.add(workflow);
     
     Workflow__c workflow1 = new Workflow__c();
     workflow1.Factory__c = factory1.Id;
     workflow1.RecordTypeId = workflowRecTypeId;
     workflow1.GBS_Current_Workflow__c = false;
     workFlowList.add(workflow1);
     
     Workflow__c workflow2 = new Workflow__c();
     workflow2.Factory__c = factory.Id;
     workflow2.RecordTypeId = workflowRecTypeId;
     workflow2.GBS_Current_Workflow__c = true;
     workflow2.Action_Status__c = 'Pending Conditional Approval';
     workflow2.Audit_Date__c = Date.newInstance(2018, 12, 9);
     workflow2.Audit_Score__c = 84;
     workFlowList.add(workflow2);   
        
     insert workFlowList;
     
     Test.startTest();
     
     //update workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[1].Id];     
     workflow.GBS_Current_Workflow__c = true;
     workflow.Action_Status__c = 'Pending Official Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 20);
     workflow.Audit_Score__c = 0;   
     update workflow;
     
     //system.assertEquals(Date.newInstance(2020, 12, 20), [Select Approval_Expiration_Date__c From Workflow__c][1].Approval_Expiration_Date__c);  
        
      //update workflow record
     workflow =  [SELECT Id,GBS_Current_Workflow__c FROM Workflow__c WHERE Id =: workFlowList[2].Id];     
     workflow.GBS_Current_Workflow__c = true;
     //workflow.Action_Status__c = 'Pending Conditional Approval';
     workflow.Audit_Date__c = Date.newInstance(2018, 12, 20);
     update workflow;
     
     //system.assertEquals(Date.newInstance(2019, 12, 9), [Select Approval_Expiration_Date__c From Workflow__c][2].Approval_Expiration_Date__c);  
     
     Test.stopTest();
        
      
     
    }     
    
}