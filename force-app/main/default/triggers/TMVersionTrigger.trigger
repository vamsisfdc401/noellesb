/*****************************************************************************************
TriggerName: TMVersionTrigger 
Purpose: Trigger for TM Version Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/10/2017           Mohit                    Initial Development as part of DFOR-1092
******************************************************************************************/
trigger TMVersionTrigger on TM_Version__c (after update) {
    
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('TM_Version__c')) {
        
        //check after context
        if (Trigger.isAfter) {
            
            //check update context
            if (Trigger.isUpdate) {
                //calling handler method for after update
                DGF_TMVersionTriggerHandler.executeOnAfterUpdate();
            }
        }
    }
}