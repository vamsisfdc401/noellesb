/*****************************************************************************************
Class Name: ScheduleBatchVProjectUpdate
Purpose: Schedulable class for scheduling batch class batchVProjectUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/10/2016           Mohit Goyal              Initial Development
******************************************************************************************/
global class ScheduleBatchVProjectUpdate implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      batchVProjectUpdate b = new batchVProjectUpdate(); //ur batch class
      database.executebatch(b);
    }
}