/*****************************************************************************************
Class Name: ScheduleBatchUpdateRejectionComments
Purpose: Schedulable class for scheduling batch class BatchUpdateRejectionComments
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             18/09/2018           Dinakar K             Initial Development
******************************************************************************************/
global class ScheduleBatchUpdateRejectionComments implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      BatchUpdateRejectionComments b = new BatchUpdateRejectionComments(); 
      database.executebatch(b);
    }
}