/*****************************************************************************************
Class Name: MassNotifyTriggerHelper
Purpose: This class handles to mass follow releases by users belongs to public groups
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna             Initial Development
******************************************************************************************/
public without sharing class MassNotifyTriggerHelper{

    //running following DML operation in system mode to make USER1 follow the Release who has access and Release created by another user USER2 where USER2 doesnot have access to USER1.
    public static void massFollowRelease(List<EntitySubscription> lstRecordsToFollow){
        insert lstRecordsToFollow;
    }

}