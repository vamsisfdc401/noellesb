trigger RST_Version_Trigger on RST_Version__c (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    system.debug('running rst version trigger');
    new RST_Version_TriggerHandler().run();

}