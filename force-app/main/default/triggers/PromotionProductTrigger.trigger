/*****************************************************************************************
TriggerName: PromotionProductTrigger
Purpose: Trigger for Promotion Product Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/07/2017           Prarthana                Initial Development
******************************************************************************************/
trigger PromotionProductTrigger on Promotion_Product__c (after insert, after update, after delete) {
    
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('Promotion_Product__c')) {
        
        //check after context
        if (Trigger.isAfter) {          
            //check insert context
            if (Trigger.isInsert) {
                DGF_PromotionProductTriggerHandler.executeOnAfterInsert();
            }
            //check update context
            else if (Trigger.isUpdate) {
                DGF_PromotionProductTriggerHandler.executeOnAfterUpdate();
            }
            //check delete context
            else if (Trigger.isDelete) {
                DGF_PromotionProductTriggerHandler.executeOnAfterDelete();
            }
        }
    }
}