/*****************************************************************************************
TriggerName: PromotionTrigger
Purpose: Trigger for Promotion Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/05/2017           Prarthana                Initial Development
******************************************************************************************/
trigger PromotionTrigger on Promotion__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('Promotion__c')) {
        
        //check before context
        if (Trigger.isBefore) {
            
            //check update context
            if (Trigger.isUpdate) {
                //call handler method for before update
                DGF_PromotionTriggerHandler.executeOnBeforeUpdate();
            }

            //check insert context
            else if (Trigger.isInsert) {
                //call handler method for before insert
                DGF_PromotionTriggerHandler.executeOnBeforeInsert();
            }
            
            //check delete context
            else if (Trigger.isDelete) {
                //call handler method for before delete
                DGF_PromotionTriggerHandler.executeOnBeforeDelete();
            }
        }
        
        //check after context
        else if (trigger.isAfter) {
            
            //check update context
            if (Trigger.isUpdate) {
                //call handler method for after update
                DGF_PromotionTriggerHandler.executeOnAfterUpdate();
            }
            
            //check insert context
            else if (Trigger.isInsert) {
                //call handler method for after insert
                DGF_PromotionTriggerHandler.executeOnAfterInsert();
            }    

            //check delete context
            else if (Trigger.isDelete) {
                //call handler method for after delete
                DGF_PromotionTriggerHandler.executeOnAfterDelete();
            }               
        }    
    }
}