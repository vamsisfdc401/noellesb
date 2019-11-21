/*****************************************************************************************
Class Name: GBSFactoryCurrentWorkFlowTriggerHandler
Purpose: Handler class for WorkflowTrigger
Version : 1.0
Created Date : 08/07/2018
Created By : Lakshmi Penamatsa
JIRA : GBS-489(replacement to GBS-295 related process builder logic)
******************************************************************************************/
public without sharing class GBSFactoryCurrentWorkFlowTriggerHandler {

	/********************************************************
    Method Name: workFlowInsert
    Purpose: Method to Insert records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/     
    public static void executeOnAfterInsert(List<Workflow__c> workflowList){       
        Set<Id> factoryIds = new Set<Id>();        
        for (Workflow__c workflow: workflowList) {
            if(workFlow.GBS_Current_Workflow__c == true && workFlow.Factory__c != null){
                factoryIds.add(workflow.Factory__c);
            } 
        }
        
        //check if set is empty or null
        if(factoryIds != null && !factoryIds.isEmpty()){
           updateFactoryWithCurrentWorkFlow(factoryIds);           
        }
        
    }
    
	/********************************************************
	Method Name: executeOnAfterUpdate
	Purpose: Method to Update records into Workflow__c object.
	Parameters: List<Workflow__c>,Map<Id,Workflow__c>
	Return Type: void
	*********************************************************/
    public static void executeOnAfterUpdate(List<Workflow__c> workflowList, Map<Id,Workflow__c> oldWorkFlowMap){
        
        Set<Id> factoryIds = new Set<Id>();
        for(Workflow__c workFlow : workFlowList){                       
                if(workFlow.GBS_Current_Workflow__c == true && workFlow.Factory__c != null){
                    factoryIds.add(workFlow.Factory__c);
                }
        }       
        //check if set is empty or null
        if(factoryIds != null && !factoryIds.isEmpty()){
          updateFactoryWithCurrentWorkFlow(factoryIds); 
        }
    }
    
	/********************************************************
	Method Name: updateFactoryWithCurrentWorkFlow
	Purpose: Method to update Factory fields(Managing Business Unit,# open yellow flags,
	# open red flags,Approval expiration date) based on current WorkFlow fields.
	Parameters: Set<Id>
	Return Type: void
	*********************************************************/
    public static void updateFactoryWithCurrentWorkFlow(Set<Id> factoryIds){
        List<Factory__c> factoryUpdateList = new List<Factory__c>();
        List<Workflow__c> currentWorkFlowList = [SELECT Id, GBS_Current_Workflow__c, Managing_Business_Unit__c, of_Open_Yellow_Flags__c, of_Open_Red_Flags__c, Approval_Expiration_Date__c, Factory__c FROM Workflow__c WHERE Factory__c IN: factoryIds AND GBS_Current_Workflow__c =: true];
        
        Map<Id,Workflow__c> currentWorkFlowMap = new Map<Id,WorkFlow__c>();
        
        for(Workflow__c workFlow : currentWorkFlowList){ 
          //build the map of factoryId and its respective workflow record
          currentWorkFlowMap.put(workFlow.Factory__c, workFlow);          
        }        
        
        // added for GBS-489
        for(Id factoryId : factoryIds){
            Factory__c factory = new Factory__c(Id = factoryId);
            //check if workflow record exists for the factory id in Map
             if(currentWorkFlowMap.get(factoryId) != null){
               Workflow__c workFlowSelected = currentWorkFlowMap.get(factoryId);
               
                    //check if Managing_Business_Unit__c != null
                    if(workFlowSelected.Managing_Business_Unit__c != null){
                        factory.Managing_Business_Unit__c = workFlowSelected.Managing_Business_Unit__c;
                    } 
                    
                    //check if of_Open_Yellow_Flags__c != null
                    if(workFlowSelected.of_Open_Yellow_Flags__c != null){
                        factory.of_Open_Yellow_Flags__c = workFlowSelected.of_Open_Yellow_Flags__c;  
                    } 
                    
                    //check if of_Open_Red_Flags__c != null
                    if(workFlowSelected.of_Open_Red_Flags__c != null){
                        factory.of_Open_Red_Flags__c = workFlowSelected.of_Open_Red_Flags__c; 
                    } 
                    
                    //check if Approval_Expiration_Date__c != null
                    if(workFlowSelected.Approval_Expiration_Date__c != null){                        
                        factory.Approval_Expiration_Date__c = workFlowSelected.Approval_Expiration_Date__c;
                    }               
                factoryUpdateList.add(factory);          
        }
        }
        //check if list is empty or null
        if(factoryUpdateList.size() > 0 && factoryUpdateList !=null){
            update factoryUpdateList;            
        }
    } 
}