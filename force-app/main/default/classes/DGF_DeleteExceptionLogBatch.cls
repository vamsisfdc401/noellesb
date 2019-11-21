/***********************************************************************************
Class Name: DGF_DeleteExceptionLogBatch
Purpose: Batch class for deleting exception logs
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/05/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_DeleteExceptionLogBatch implements Database.Batchable<sObject>,Database.Stateful{
  
    /***********************************
    Method Name: start
    Purpose: method to query for Exception logs created more than a week ago
    ***********************************/
    global list<Exception_Log__c> start(Database.BatchableContext BC){
        //query for prodcuts and the associated pricing records where VOD End Date=today
        list<Exception_Log__c>excepList=[SELECT ID,CreatedDate from Exception_log__c where CreatedDate < :date.today() ];
        return excepList;
    }
    
    
      /***********************************
    Method Name: execute
    Purpose: method to delete exception logs
    ***********************************/
    global void execute(Database.BatchableContext BC, List<Exception_Log__c> excepList){
        list<Exception_Log__c>toBeDeletedList=new list<Exception_Log__c>();
        for(Exception_log__c excep:excepList){
        integer numberDays =Date.valueOf(excep.CreatedDate).daysBetween(Date.today());
            System.debug(numberDays);
            if(numberDays > 7){
                toBeDeletedList.add(excep);
            }
        }
        
        if(!toBeDeletedList.isEmpty()){
            database.delete(toBeDeletedList);
        }
    }
    
       global void finish(Database.BatchableContext BC){
     }
}