trigger CIRFCorrugateMaterialTrigger on CIRF_Corrugate_Material__c (after insert,after update, before update, before insert, before delete, after delete) {
	if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFCorrugateMaterialTriggerHandler().run();
    }
}