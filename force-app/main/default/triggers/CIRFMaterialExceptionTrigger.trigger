trigger CIRFMaterialExceptionTrigger on CIRF_Material_Exceptions__c (before insert) {
    if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFMaterialExceptionTriggerHandler().run();
    }
}