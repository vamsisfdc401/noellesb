trigger GBSContractTrigger on Contract__c (before insert, after insert, before update, after update, before delete,after delete) 
{
    //check before context
    if (trigger.isafter && Trigger.IsInsert){
        GBSContractTriggerHandler.UpdateContractLMSFlag();
         // GBS-331 gbscontract insert
         GBSLicenseeFlagTriggerHandler.gbsContractInsert(Trigger.New);
    }
    if(trigger.isafter && Trigger.isUpdate){
        // GBS-331 gbscontract update
        GBSLicenseeFlagTriggerHandler.gbsContractUpdate(Trigger.New,trigger.oldMap);
    }
     if(trigger.isafter && Trigger.isDelete){
        // GBS-331 gbscontract update
        GBSLicenseeFlagTriggerHandler.gbsContractDelete(Trigger.old);
    }
}