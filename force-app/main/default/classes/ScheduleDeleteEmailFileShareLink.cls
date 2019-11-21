/*****************************************************************************************
Class Name: ScheduleDeleteEmailFileShareLink
Purpose: Schedulable class for scheduling batch class batchVProjectUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/07/2018           Ashok Raghavan          Initial Development
******************************************************************************************/
global class ScheduleDeleteEmailFileShareLink implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      DeleteEmailFileShareLink b = new DeleteEmailFileShareLink(); //ur batch class
      database.executebatch(b);
    }
}