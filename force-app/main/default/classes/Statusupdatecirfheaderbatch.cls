global class Statusupdatecirfheaderbatch implements Database.Batchable<sObject>{
    set<id> HeaderId=new Set<id>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, CIRF_End_Date__c,CIRF_Status__c  from CIRF_Header__c where CIRF_End_Date__c <TODAY and CIRF_Status__c in(\'Loaded\')';
        system.debug('Query result==>'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext BC, List<CIRF_Header__c> scope){
        for(CIRF_Header__c hl:scope){
            hl.CIRF_Status__c  ='Complete';
            HeaderId.add(hl.Id);
        }
        update scope;
        List<CIRF_Material__c> crfMater=[SELECT CIRF_Header_Name__c,CIRF_Header__c,CIRF_Material_Status__c FROM CIRF_Material__c where CIRF_Header__c IN : HeaderId];
        for(CIRF_Material__c crma : crfMater)
            crma.CIRF_Material_Status__c='Complete';
        update crfMater;
    }
    global void finish(Database.BatchableContext BC){
    }
}