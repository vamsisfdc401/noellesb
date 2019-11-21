trigger CIRFHeaderTrigger on CIRF_Header__c (before update, after update) {
    if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFHeaderTriggerHandler().run();
    }
}