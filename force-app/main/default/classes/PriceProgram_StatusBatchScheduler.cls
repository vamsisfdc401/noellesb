global class PriceProgram_StatusBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Bypass_TPWV__c BypassCS = Bypass_TPWV__c.getInstance();
        Boolean BypassValidations = BypassCS.Bypass_Validation_Rules__c;
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = true;
            upsert BypassCS;
        }
        List<Price_Protection_Program__c> HeaderList = [Select Id, Status__c, Effective_Date__c, Submission_Deadline__c from Price_Protection_Program__c where Status__c in('Queued','Published') AND No_of_Materials__c > 0];
        system.debug('List of records: ' + HeaderList);
        for(Price_Protection_Program__c hl: HeaderList){
            if (hl.Status__c == 'Queued' && hl.Effective_Date__c.daysBetween(System.today()) > 0){
                hl.Status__c ='Published';
                system.debug('Setting to Published for: ' + hl.Id);
            }/* TJ: Commented for HEITCM-76. The code below may be reactivated at a future date if required by business
            if (hl.Status__c == 'Published' && hl.Submission_Deadline__c.daysBetween(System.today()) > 13){
                hl.Status__c = 'Closed';
                system.debug('Setting to Closed for: ' + hl.Id);
            }*/
        }
        update HeaderList;
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = false;
            upsert BypassCS;
        }
    }
}