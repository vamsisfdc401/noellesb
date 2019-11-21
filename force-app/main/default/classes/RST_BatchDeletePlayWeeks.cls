global class RST_BatchDeletePlayWeeks implements Database.Batchable<sObject> , Database.Stateful{

    private string uploadId;

    public RST_BatchDeletePlayWeeks(String use_uploadId){
        system.debug('batch delete and store uploadId: ' + use_uploadId);
        uploadId = use_uploadId;
    
        // delete versions - could be used later
        delete [SELECT Id FROM RST_Version__c];
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Source__c, Title__r.Lock_Title__c FROM RST_Play_Week__c WHERE Source__c != \'Magic\'');// OR Title__r.Lock_Title__c = false');
    }

    global void execute(Database.BatchableContext bc, List<RST_Play_Week__c> records){
        List<RST_Play_Week__c> recordsToDelete = new List<RST_Play_Week__c>();
        for(RST_Play_Week__c record : records){
            if(record.Title__r.Lock_Title__c != true){
                recordsToDelete.add(record);
            } 
        }
        if(recordsToDelete.size() > 0 ) delete recordsToDelete;
    }

    global void finish(Database.BatchableContext bc){
        system.debug('call csv parse for uploadId: ' + uploadId); 
        Id batchprocessid = Database.executeBatch(new RST_BatchProcess_RawCSV(uploadId), 50);
    }

}