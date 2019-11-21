/*****************************************************************************************
TriggerName: GBSLMSProductTrigger
Purpose: Trigger for GBS_LMS_IP__c Object
Version : 1.0
Date Created : May/09/2018
Created By : Harsha Vardhan P
JIRA : GBS-278
******************************************************************************************/
trigger GBSLMSProductTrigger on GBS_LMS_Product__c (after insert, after delete) {
    
    //  Create an entry into custom setting with trigger name as Name and tick the Disable checkbox to disable the trigger
    if(GBSTriggerManager__c.getInstance('GBSLMSProductTrigger') != null && GBSTriggerManager__c.getInstance('GBSLMSProductTrigger').GBSDisable__c)
        return;
    
    if(Trigger.isAfter && Trigger.isInsert)
        GBSLMSProductTriggerHandler.setProductNamesOnLMS(Trigger.newMap);
    if(Trigger.isAfter && Trigger.isDelete)
        GBSLMSProductTriggerHandler.setProductNamesOnLMS(Trigger.oldMap);
}