/***********************************************************************************
Class Name: DGF_iTunesRepricingBatchScheduler
Purpose: Scheduler class to schedule the DGF_iTunesRepricingBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             23/05/2017           Jata                Initial Development
******************************************************************************************/
global with sharing class DGF_iTunesRepricingBatchScheduler implements Schedulable{
    /***********************************
    Method Name: execute
    Purpose: method to call the batch class
    ***********************************/
    global void execute(SchedulableContext ctx) {
        DGF_iTunesRepricingBatch  iTunesBatch = new DGF_iTunesRepricingBatch ();
        database.executebatch(iTunesBatch,100);
    }

}