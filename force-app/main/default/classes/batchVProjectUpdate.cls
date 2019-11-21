/*****************************************************************************************
Class Name: batchVProjectUpdate
Purpose: This class handles the business logic for updating the v-Project Status if it 
crossed the Project Finish Date.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/10/2016           Ipsita Mishra              Initial Development
******************************************************************************************/

global class batchVProjectUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Project_Finish_Date__c FROM v_Project_Request__c';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<v_Project_Request__c> vprjList) {
         for(v_Project_Request__c vpr : vprjList){
             if(Date.Today() > vpr.Project_Finish_Date__c){
                 vpr.v_Project_Status__c = 'Inactive';
             }
         }
         update vprjList;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}