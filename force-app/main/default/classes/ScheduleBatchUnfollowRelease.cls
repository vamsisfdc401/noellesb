/*****************************************************************************************
Class Name: ScheduleBatchUnfollowRelease
Purpose: Schedulable class for scheduling batch class batchUnfollowRelease
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             12/10/2017           Jyothsna             Initial Development
******************************************************************************************/
global class ScheduleBatchUnfollowRelease implements schedulable
{
    //executes batchUnfollowRelease batch job to unfollow releases whose street date is current date
    global void execute(SchedulableContext sc)
    {
      batchUnfollowRelease b = new batchUnfollowRelease(); 
      database.executebatch(b);
    }
}