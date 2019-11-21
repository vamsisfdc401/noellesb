/*****************************************************************************************
TriggerName: GBSLMSIPTrigger
Purpose: Trigger for GBS_LMS_IP__c Object
Version : 1.0
Date Created : May/09/2018
Created By : Harsha Vardhan P
JIRA : GBS-278
******************************************************************************************/
trigger GBSLMSIPTrigger on GBS_LMS_IP__c (after insert, after delete) {
    
    //  Create an entry into custom setting with trigger name as Name and tick the Disable checkbox to disable the trigger 
    if(GBSTriggerManager__c.getInstance('GBSLMSIPTrigger') != null && GBSTriggerManager__c.getInstance('GBSLMSIPTrigger').GBSDisable__c)
        return;
    
    if(Trigger.isAfter && Trigger.isInsert)
        GBSLMSIPTriggerHandler.setIPNamesOnLMS(Trigger.newMap);
    if(Trigger.isAfter && Trigger.isDelete)
        GBSLMSIPTriggerHandler.setIPNamesOnLMS(Trigger.oldMap);
}