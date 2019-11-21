trigger CIRFCorrugateTrigger on CIRF_Corrugate__c (before insert, after insert, before update , after update, before delete) {
    if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFCorrugateTriggerHandler().run();
    }
}