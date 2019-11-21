trigger GBSLMSTrigger on LMS__c (before insert, after insert, before update, after update, before delete,after delete)  {
        //check after context
    if (trigger.isAfter && (Trigger.IsUpdate ||Trigger.IsInsert) ){
        GBSLMSTriggerHandler.UpdateContractLMSFlag();
    }
}