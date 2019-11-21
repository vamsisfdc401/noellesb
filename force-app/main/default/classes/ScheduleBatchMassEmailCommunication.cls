/*****************************************************************************************
Class Name: ScheduleBatchMassEmailCommunication
Purpose: Schedulable class for scheduling batch class BatchMassEmailCommunication
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             12/10/2017           Jyothsna             Initial Development
******************************************************************************************/
global class ScheduleBatchMassEmailCommunication implements schedulable
{
    //executes BatchMassEmailCommunication batch job to send email communication on release create.
    global void execute(SchedulableContext sc)
    {
      BatchMassEmailCommunication b = new BatchMassEmailCommunication(); 
      database.executebatch(b);
    }
}