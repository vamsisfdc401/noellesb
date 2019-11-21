/*****************************************************************************************
Class Name: ScheduleGBSBatchFactoryStatusUpdate
Purpose: Schedulable class for scheduling batch class batchVProjectUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/27/2018           Ashok Raghavan          Initial Development (GBS 276)
******************************************************************************************/
global class ScheduleGBSBatchFactoryStatusUpdate implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      GBSBatchFactoryStatusUpdate b = new GBSBatchFactoryStatusUpdate(); //ur batch class
      database.executebatch(b);
    }
}