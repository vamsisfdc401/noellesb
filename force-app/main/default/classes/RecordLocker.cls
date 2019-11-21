/*****************************************************************************************
Class Name: RecordLocker
Purpose: This class is used for locking a record.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/08/2016           Suman Kundu              Initial Development
******************************************************************************************/
global class RecordLocker
{
    // This method is used from Material's custom Submit for Approval button to lock record.
    webservice static void lock(Id recordId)
    {
        if(recordId != null)
            Approval.lock(recordId);
    }
    
    public static void lock(List<Id> recordIds)
    {
        if(recordIds != null && recordIds.size() > 0)
            Approval.lock(recordIds);
    }
    
    // This method is used from Material's custom button to unlock record.
    webservice static void unlock(Id recordId)
    {
        if(recordId != null)
            Approval.unlock(recordId);
    }
    
    public static void unlock(List<Id> recordIds)
    {
        if(recordIds != null && recordIds.size() > 0)
            Approval.unlock(recordIds);
    }
    
    // This method is used from Material's custom button to unlock record.
    webservice static Boolean isLocked(Id recordId)
    {
        if(recordId != null)
            return Approval.isLocked(recordId);
        return false;
    }
}