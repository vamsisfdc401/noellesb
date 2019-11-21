/*****************************************************************************************
Class Name: GBSCurrentWorkFlowTriggerHandler
Purpose: Handler class for PCWorkflowTrigger
Version : 1.0
Created Date : 05/21/2018
Created By : Lakshmi Penamatsa
JIRA : GBS-408
******************************************************************************************/
public without sharing class GBSCurrentWorkFlowTriggerHandler {
    
    private static Id partnerExemptionworkflow = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get(GBSConstants.GBSPARTNEREXEMPTIONWORKFLOW).getRecordTypeId();

    /********************************************************
    Method Name: workFlowInsert
    Purpose: Method to Insert records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/ 
    public static void workFlowInsert(List<Workflow__c> workFlowList){
        Set<Id> factoryIds = new Set<Id>();
        List<Workflow__c> workFlowInsertList = new List<Workflow__c>();
        for(Workflow__c workflow : workFlowList){
            //check if record type of workflow record is not partner exemption and Factory is not null
            if(workFlow.RecordTypeId != partnerExemptionworkflow && workflow.Factory__c !=null){ 
                factoryIds.add(workflow.Factory__c);
            } 
        }
       
        //check if set is empty or null
        if(factoryIds != null && !factoryIds.isEmpty()){
         setCurrentWorkFlow(factoryIds);
        }
        
    }
    
    /********************************************************
    Method Name: workFlowUpdate
    Purpose: Method to Update records into Workflow__c object.
    Parameters: List<Workflow__c>,Map<Id,Workflow__c>
    Return Type: void
    *********************************************************/
    public static void workFlowUpdate(List<Workflow__c> workFlowList, Map<Id,Workflow__c> oldWorkFlowMap){
        Set<Id> factoryIds = new Set<Id>();
        for(Workflow__c workFlow : workFlowList){
            Workflow__c oldWorkFlow = oldWorkFlowMap.get(workFlow.Id);
            //check if record type is not partner exemption
            if(workFlow.RecordTypeId != partnerExemptionworkflow || oldWorkflow.RecordTypeId != partnerExemptionworkflow){
                //check if factory or current workflow fields are changed on workflow record
                if(workFlow.GBS_Current_Workflow__c != oldWorkFlow.GBS_Current_Workflow__c || workFlow.Factory__c != oldWorkFlow.Factory__c){
                    // check if factory is updated on workflow record , in order to update the current workflow of both the new and old records
                   if(workFlow.Factory__c != oldWorkFlow.Factory__c){
                        if(oldWorkFlow.Factory__c != null){
                            factoryIds.add(oldWorkFlow.Factory__c);
                        }
                        
                    }
                    //check if factory is not null for new record
                    if(workFlow.Factory__c != null){
                        factoryIds.add(workFlow.Factory__c);
                    }
                }
            }
        }
       
        //check if set is empty or null
        if(factoryIds != null && !factoryIds.isEmpty()){
            setCurrentWorkFlow(factoryIds);
        }
        
    }
    
    /********************************************************
    Method Name: workFlowDelete
    Purpose: Method to Delete records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/
    public static void workFlowDelete(List<Workflow__c> workFlowList){
        //no functionality on delete of workflow record 
    }
    
    /********************************************************
    Method Name: setCurrentWorkFlow
    Purpose: Method to Update current workflow field on WorkFlow object.
    Parameters: Set<Id>
    Return Type: void
    *********************************************************/
    public static void setCurrentWorkFlow(Set<Id> factoryIds) {
        List<Workflow__c> workFlowListUpdate = new List<Workflow__c>();
        List<Workflow__c> workflowList = [Select Id, Factory__c, LastModifiedDate, GBS_Current_Workflow__c FROM Workflow__c WHERE Factory__c IN: factoryIds AND RecordTypeId !=: partnerExemptionworkflow ORDER BY Factory__c, LastModifiedDate DESC];
        Map<Id,List<Workflow__c>> workFlowMap = new Map<Id,List<Workflow__c>>();
        for(Workflow__c workflow: workflowList){
            //if new entry - workFlowMap needs to be updated with factoryId and WorkFlow record
            if(!workFlowMap.containsKey(workflow.Factory__c)){
                workFlowMap.put(workflow.Factory__c, new List<Workflow__c>{workflow});
            }
            else
            {
                // check if current workflow is true, and add to the workFlowMap
                if(workflow.GBS_Current_Workflow__c == true){
                    workFlowMap.get(workflow.Factory__c).add(workflow); 
                }
                
            }  
        }
        //loop through the factoryIds
        for(Id factoryId : factoryIds){
            //check if workFlowMap contains factoryId
            if(workFlowMap.get(factoryId) != null){
                List<WorkFlow__c> workflowCurrentCheckBoxList = workFlowMap.get(factoryId);
                for(Integer i=0; i< workflowCurrentCheckBoxList.size(); i++){
                    WorkFlow__c workFlowCheckBoxSelected = new WorkFlow__c();
                    if(i==0){
                        //latest record based on lastmodified date needs to be updated with current workflow as true
                        workFlowCheckBoxSelected = workflowCurrentCheckBoxList[0];
                        workFlowCheckBoxSelected.GBS_Current_Workflow__c = true;  
                    }else{
                        //other records needs to be updated with current workflow as false
                        workFlowCheckBoxSelected = workflowCurrentCheckBoxList[i];
                        workFlowCheckBoxSelected.GBS_Current_Workflow__c = false;
                    }
                    workFlowListUpdate.add(workFlowCheckBoxSelected);
                }
            }            
        }
        
        //check if list is empty or null
        if(workFlowListUpdate != null && !workFlowListUpdate.isEmpty()){
            try{ 
                update workFlowListUpdate; 
            }catch(DmlException e){
                //  Log exception
                DGF_ExceptionLogController.createExceptionLog('While Updating WorkFlow Record currentworkflow field', 'GBSCurrentWorkFlowTriggerHandler.setCurrentWorkFlow', e.getMessage());
            }
        }
        
    }
}