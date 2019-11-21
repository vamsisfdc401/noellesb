/***********************************************************************************
Class Name:     DGF_DeleteExceptionLogScheduler
Purpose: Scheduler class to schedule the DGF_DeleteExceptionLogBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/05/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_DeleteExceptionLogScheduler implements Schedulable {

    /***********************************
    Method Name: execute
    Purpose: method to call the batch class
    ***********************************/
    global void execute(SchedulableContext ctx) {
        DGF_DeleteExceptionLogBatch btch= new DGF_DeleteExceptionLogBatch();
        database.executebatch(btch,100);
    }
}