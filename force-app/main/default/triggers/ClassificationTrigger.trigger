/*****************************************************************************************
Trigger Name: ClassificationTrigger
Purpose: Trigger handling business logic for Classification
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/08/2016                                    Initial Development
******************************************************************************************/
trigger ClassificationTrigger on Classification__c (before insert, before update, after insert, after update) {
    // Checking for recursive trigger execution
    if(!TriggerUtility.hasTriggerExecuted('Classification__c'))
    {
        // Handling Before events
        if(Trigger.isBefore)
        {
            // Scope for Before Insert
            if(Trigger.isInsert)
            {
                ClassificationTriggerHandler.executeOnBeforeInsert();
            }
            // Scope for Before Update
            else if(Trigger.isUpdate)
            {
                ClassificationTriggerHandler.executeOnBeforeUpdate();
            }
        }
        // Handling After events
        else
        {
            // Scope for After Insert
            if(Trigger.isInsert)
            {
                ClassificationTriggerHandler.executeOnAfterInsert();
            }
            // Scope for After Update
            else if(Trigger.isUpdate)
            {
                ClassificationTriggerHandler.executeOnAfterUpdate();
            }
            // Scope for After Delete
            else if(Trigger.isDelete)
            {
                
            }
        }
    }
}