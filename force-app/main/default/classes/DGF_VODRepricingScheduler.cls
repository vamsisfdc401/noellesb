/***********************************************************************************
Class Name: DGF_VODRepricingScheduler
Purpose: Scheduler class to schedule the DGF_VODRepricingBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             17/05/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_VODRepricingScheduler implements Schedulable {

    /***********************************
    Method Name: execute
    Purpose: method to call the batch class
    ***********************************/
    global void execute(SchedulableContext ctx) {
        DGF_VODRePricingBatch  vodBatch = new DGF_VODRePricingBatch ();
        database.executebatch(vodBatch,100);
    }
}