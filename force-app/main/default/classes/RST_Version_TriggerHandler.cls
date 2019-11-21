public without sharing class RST_Version_TriggerHandler extends TriggerHandler{

    public override void afterDelete(){
        //get file upload and content document and delete them
        system.debug('getting ready to delete version');
        Set<Id> uploadIds = new Set<Id>();
        for(RST_Version__c v : (List<RST_Version__c>) trigger.old){
            uploadIds.add(v.Upload__c);
        }
        delete [SELECT Id FROM RST_Forecast_Upload__c WHERE Id IN :uploadIds];
    }

}