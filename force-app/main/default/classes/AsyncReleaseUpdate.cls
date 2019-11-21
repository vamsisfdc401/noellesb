/*****************************************************************************************
Class Name: AsyncReleaseUpdate
Purpose: Apex class to update release list asynchronusly.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/06/2017           Suman                    Initial Development
******************************************************************************************/
public class AsyncReleaseUpdate implements Queueable {
    
    public List<Release__c> updateableReleaseList;
    
    /************************************
    Method Name: execute
    Purpose: this method invoked to unlock material record   
    *************************************/
    public void execute(QueueableContext context) {
        if (updateableReleaseList == null || updateableReleaseList.size() == 0) {
            return;
        }
        TriggerUtility.checkFromQueueable = TRUE;
        update updateableReleaseList;        
    }
}