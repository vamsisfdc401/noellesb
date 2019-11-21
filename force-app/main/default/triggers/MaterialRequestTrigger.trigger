/*****************************************************************************************
Trigger Name: MaterialRequestTrigger
Purpose: This trigger is for handling Material Update Request's DML operation logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/16/2017           Suman                    Initial Development
******************************************************************************************/
trigger MaterialRequestTrigger on Material_Update_Request__c (before update) 
{
    // Handling on before update.
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        MaterialRequestTriggerHandler.executeOnBeforeUpdate();
    }
}