trigger RequestDetailTrigger on Request_Detail__c (before insert, before update, after insert, after update) {
    new RequestDetailTriggerHandler().run();
   
}