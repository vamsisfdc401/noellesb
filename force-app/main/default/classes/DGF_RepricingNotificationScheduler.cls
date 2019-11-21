/***********************************************************************************
Class Name: DGF_RepricingNotificationScheduler
Purpose: Scheduler class to schedule the DGF_RepricingNotificationBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/10/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_RepricingNotificationScheduler  implements Schedulable {

    /***********************************
    Method Name: execute
    Purpose: method to call the batch class
    ***********************************/
    global void execute(SchedulableContext ctx) {
        DGF_RepricingNotificationBatch  repBatch = new DGF_RepricingNotificationBatch ();
        database.executebatch(repBatch,100);
    }
}