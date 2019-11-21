/*****************************************************************************************
TriggerName: GBSContractAgentContactTrigger 
******************************************************************************************
Version         DateCreated         CreatedBy               Change
1.0             06/13/2018           Lakshmi                Initial Development

No logic built on the Trigger as a best practice, and just call GBSContractAgentContactTriggerHandler.
All the logic should be written only on handler.
******************************************************************************************/
trigger GBSContractAgentContactTrigger on Contract_Agent_Contact__c (after insert, after update, after delete) {

    //  Create an entry into custom setting with trigger name as Name and tick the Disable checkbox to disable the trigger
    if(GBSTriggerManager__c.getInstance('GBSContractAgentContactTrigger') != null && GBSTriggerManager__c.getInstance('GBSContractAgentContactTrigger').GBSDisable__c)
        return;
    
    if (trigger.isAfter){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            //GBS-467 buildContactEmails() to concatenate the contact emails
            GBSContractAgentContactTriggerHandler.buildContactEmails(Trigger.New);  
        }
        else if(trigger.isdelete){
            //GBS-467 buildContactEmails() to concatenate the contact emails
            GBSContractAgentContactTriggerHandler.buildContactEmails(Trigger.old);  
        }
    }
       
}