/*****************************************************************************************
Class Name: GBSBatchLMSStatusUpdate
Purpose: This class handles the business logic for updating the LMS Status to Contract Expired 
If the Product right group End date is today.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/06/2018           Ashok Raghavan          Initial Development
******************************************************************************************/

global class GBSBatchLMSStatusUpdate implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id ,Contract__r.Contract_End_Date__c from LMS__c where LMS_Status__c != \'Contract Expired\' AND   Contract__r.Contract_End_Date__c <= today';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<LMS__c> lmsjList) {
        
        If (!lmsjList.isempty()){
        	 for(LMS__c lms : lmsjList){
            
             	lms.LMS_Status__c = 'Contract Expired';
            
        	 }
         	update lmsjList;
    	}   
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}