/*****************************************************************************************
Class Name: ChildLabelUpdateBatchHandler 
Purpose: Apex class for handling batch component label code update on parent material deal update.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/17/2017           Suman Kundu              Initial Development 
******************************************************************************************/
global class ChildLabelUpdateBatchHandler implements Database.Batchable<sObject>, Database.Stateful {
    List<Material__c> componentList;
    global Set<Id> processingMaterialIds = new Set<Id>();
    
    // Parameterized constructor.
    global ChildLabelUpdateBatchHandler(List<Material__c> componentList) {
        this.componentList = componentList;
    }
    
    // Interface start method to grab total context list.
    global List<SObject> start(Database.BatchableContext info) { 
        return componentList;
    }
    
    // Interface execute method to perform actual operation.
    global void execute(Database.BatchableContext info, List<Material__c> scope) {
        TriggerUtility.executeQueueable = false;
        try {
            update scope;
            for (Material__c mat : scope) {
                processingMaterialIds.add(mat.Id);
            }
        }
        catch(Exception ex) {}
    }
    
    // Method handles the after batch process activity.
    global void finish(Database.BatchableContext info) {
        // Intiate the dependent Asynchronous Defaulting Batch Jobs.
        Database.executeBatch(new AdditionalMaterialDefaultBatchHandler(processingMaterialIds), 50);
    }
}