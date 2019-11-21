/*****************************************************************************************
Class Name: GBSWorkFlowApprovalDateTriggerHandler
Purpose: Handler class for WorkflowTrigger
Version : 1.0
Created Date : 06/29/2018
Created By : Lakshmi Penamatsa
JIRA : GBS-489
******************************************************************************************/
public without sharing class GBSWorkFlowApprovalDateTriggerHandler {
    
    /********************************************************
    Method Name: executeOnAfterInsert
    Purpose: Method to Insert records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/ 
    public static void executeOnAfterInsert(List<Workflow__c> workflowList){       
        Set<Id> workFlowIds = new Set<Id>();
        for (Workflow__c objworkflow: workflowList) {
            workFlowIds.add(objworkflow.Id);
        }
        
        //check if set is empty or null
        if(workFlowIds != null && !workFlowIds.isEmpty()){
            system.debug('workFlowIds'+workFlowIds);
            updateApprovalExpirationDate(workFlowIds);           
        }
     
    }
    
    /********************************************************
    Method Name: executeOnAfterUpdate
    Purpose: Method to Update records into Workflow__c object.
    Parameters: List<Workflow__c>,Map<Id,Workflow__c>
    Return Type: void
    *********************************************************/
    public static void executeOnAfterUpdate(List<Workflow__c> workflowList, Map<Id,Workflow__c> oldWorkFlowMap){
    
        Set<Id> workflowIDSUpdate = new Set<Id>();
        for(Workflow__c workFlow : workFlowList){
            Workflow__c oldWorkflow = oldWorkFlowMap.get(workFlow.Id);
             system.debug('oldWorkflow'+oldWorkflow);
             system.debug('newworkFlow'+workFlow);
            if(oldWorkflow.Action_Status__c != workFlow.Action_Status__c || 
               oldWorkflow.Audit_Date__c != workFlow.Audit_Date__c || 
               oldWorkflow.Audit_Score__c != workFlow.Audit_Score__c){
                   if(workFlow.Audit_Date__c != null){
                       workflowIDSUpdate.add(workFlow.Id); 
                   }
               }
        }
        
        system.debug('workflowIDSUpdate'+workflowIDSUpdate);
        //check if set is empty or null
        if(workflowIDSUpdate != null && !workflowIDSUpdate.isEmpty()){            
            updateApprovalExpirationDate(workflowIDSUpdate);
        }
    }
    
    /********************************************************
    Method Name: updateApprovalExpirationDate
    Purpose: Method to update ApprovalExpirationDate field on WorkFlow object.
    Parameters: Set<Id>
    Return Type: void
    *********************************************************/
    public static void updateApprovalExpirationDate(Set<Id> workflowIDS){
        List<Workflow__c> workFlowUpdateList = new List<Workflow__c>();
        List<Workflow__c> workFlowList = [SELECT Id, Action_Status__c, Factory_Country__c, Audit_Date__c, Approval_Expiration_Date__c, Audit_Score__c FROM Workflow__c WHERE Id IN: workflowIDS];
         
        // added for GBS-489
         for(Workflow__c workFlowSelected : workFlowList){
             //check if Action_Status__c is Pending Official Approval
            if(workFlowSelected.Action_Status__c == 'Pending Official Approval'){
                //check if Factory_Country__c is Bangladesh
                if(workFlowSelected.Factory_Country__c == 'Bangladesh'){
                   //check if Audit_Date__c is not null 
                    if(workFlowSelected.Audit_Date__c != null){
                        workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(12);
                    }
                }
                
                //check if Factory_Country__c is not Bangladesh
                else if(workFlowSelected.Factory_Country__c != 'Bangladesh'){
                    //check if Audit_Date__c is not null 
                    if(workFlowSelected.Audit_Date__c != null){
                        //check if Audit_Score__c is < 85 
                        if(workFlowSelected.Audit_Score__c < 85){
                            workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(12); 
                        } 
                        //check if Audit_Score__c is >= 85 and <93
                        else if(workFlowSelected.Audit_Score__c >= 85 && workFlowSelected.Audit_Score__c < 93){
                            workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(18); 
                        }
                        //check if Audit_Score__c is >= 93
                        else if(workFlowSelected.Audit_Score__c >= 93){
                            workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(24); 
                        } 
                        //check if Audit_Score__c is null
                        else if(workFlowSelected.Audit_Score__c == null){
                            workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(12); 
                        }
                    }
                }
            }
             
             //check if Action_Status__c is Pending Conditional Approval
            else if(workFlowSelected.Action_Status__c == 'Pending Conditional Approval'){
                //check if Audit_Date__c != null
                if(workFlowSelected.Audit_Date__c != null){
                    workFlowSelected.Approval_Expiration_Date__c =  workFlowSelected.Audit_Date__c.addMonths(12);
                }
            }
             system.debug('workFlowSelected'+workFlowSelected.Approval_Expiration_Date__c);
            workFlowUpdateList.add(workFlowSelected);
        }
        
         //check if list is empty or null
        if(workFlowUpdateList.size() > 0 && workFlowUpdateList !=null){
            update workFlowUpdateList;            
        }
    }
    
}