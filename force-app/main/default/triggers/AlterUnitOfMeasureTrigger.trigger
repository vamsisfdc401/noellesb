trigger AlterUnitOfMeasureTrigger on Alternative_Unit_of_Measure__c (before insert, before Update, after Update) 
{
    if(!TriggerUtility.hasTriggerExecuted('Alternative_Unit_of_Measure__c'))
    {
        // Handling Before events
        if(Trigger.isBefore)
        {
            // Scope for Before Insert
            if(Trigger.isInsert)
            {
                AlterUnitOfMeasureTriggerHandler.executeOnBeforeInsert();
            }
            // Scope for Before Update
            else if(Trigger.isUpdate)
            {
                AlterUnitOfMeasureTriggerHandler.executeOnBeforeUpdate();
            }
        }
        // Handling After events
        else
        {
            // Scope for After Insert
            if(Trigger.isInsert)
            {}
            // Scope for After Update
            else if(Trigger.isUpdate)
            {
                AlterUnitOfMeasureTriggerHandler.executeOnAfterUpdate(); //USST-2955
            }
            // Scope for After Delete
            else if(Trigger.isDelete)
            {}
        }
    }
}