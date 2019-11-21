/***********************************************************************************
Class Name: DGF_iTunesPricingUpdateBatchScheduler
Purpose: Scheduler class to schedule the DGF_iTunesPricingUpdateMarginDateBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0            09/11/2017           Nandeesh                Initial Development
******************************************************************************************/
global with sharing class DGF_iTunesPricingUpdateBatchScheduler implements Schedulable {
    /***********************************
    Method Name: execute
    Purpose: method to call the batch class
    ***********************************/
    global void execute(SchedulableContext ctx) {
        DGF_iTunesPricingUpdateMarginDateBatch  iTunesBatch = new DGF_iTunesPricingUpdateMarginDateBatch();
        database.executebatch(iTunesBatch,100);
    }

}