/**********************************************************************************************************************
Class Name: BatchUpdateRejectionComments
Purpose: Batch class to update the last/latest rejection comment on Material at end of the day.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             18/09/2018           Dinakar K             Initial Development
***********************************************************************************************************************/
global without sharing class BatchUpdateRejectionComments implements Database.Batchable<sObject>, Database.Stateful {
   
    global List<Material__c> lstRejectedMat = new List<Material__c>();
        
    global Database.QueryLocator start(Database.BatchableContext BC) {              
        return Database.getQueryLocator('Select Id, Material_Status__c, Rejection_Comments__c, Rejection_Date__c, (Select Id, IsPending, ProcessInstanceId, TargetObjectId, StepStatus, OriginalActorId, ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp FROM ProcessSteps ORDER BY CreatedDate DESC) From Material__c'); 
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            if (scope.size() > 0) {
                for (Material__c mat: (List<Material__c>)scope) {
                    if (mat.ProcessSteps.size() > 0 && mat.ProcessSteps[0].StepStatus == 'Rejected') {
                        mat.Rejection_Comments__c = mat.ProcessSteps[0].Comments;
                        mat.Rejection_Date__c = mat.ProcessSteps[0].CreatedDate;
                        lstRejectedMat.add(mat);
                    }
                }
            }
            if (lstRejectedMat.size() > 0) {
                update lstRejectedMat;
            }
        }
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}