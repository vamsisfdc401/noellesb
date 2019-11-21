trigger CIRFMaterialTrigger on CIRF_Material__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFMaterialTriggerHandler().run();
    }
}