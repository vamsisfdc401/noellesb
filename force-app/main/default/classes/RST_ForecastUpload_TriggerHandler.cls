public without sharing class RST_ForecastUpload_TriggerHandler extends TriggerHandler{
    public override void beforeDelete(){
        // delete my file and the raw lines
        Set<Id> uploadIds = new Set<Id>();
        
        for(RST_Forecast_Upload__c fu : (List<RST_Forecast_Upload__c>) Trigger.old){
            uploadIds.add(fu.Id);
        }
        Set<Id> cdIds = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :uploadIds]){
            cdIds.add(cdl.ContentDocumentId);
        }

        //ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :docId ORDER BY CreatedDate DESC LIMIT 1];
        if(cdIds.size() > 0 ) delete [SELECT Id FROM ContentDocument WHERE Id IN :cdIds];
        
    }

}