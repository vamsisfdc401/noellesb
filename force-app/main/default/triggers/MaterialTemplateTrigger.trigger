/*****************************************************************************************
Trigger Name: MaterialTemplateTrigger
Purpose: This is the trigger to handle Material Template operations.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/11/2017           Suman                    Initial Development
******************************************************************************************/
trigger MaterialTemplateTrigger on Material_Template__c (after insert, after Update) 
{
    // Checking for recursive trigger execution
    if(!TriggerUtility.hasTriggerExecuted('Material_Template__c'))
    {
        // Changing material template sharing
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        {
            MaterialTemplateTriggerHandler.executeOnAfterInsertUpdate();
        }
    }
}