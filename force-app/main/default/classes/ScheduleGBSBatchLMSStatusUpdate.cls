/*****************************************************************************************
Class Name: ScheduleGBSBatchLMSStatusUpdate
Purpose: Schedulable class for scheduling batch class batchVProjectUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/06/2018           Ashok Raghavan          Initial Development
******************************************************************************************/
global class ScheduleGBSBatchLMSStatusUpdate implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      GBSBatchLMSStatusUpdate b = new GBSBatchLMSStatusUpdate(); //ur batch class
      database.executebatch(b);
    }
}