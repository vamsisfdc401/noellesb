/*****************************************************************************************
TriggerName: ProductVersionTrigger 
Purpose: Trigger for Product Version Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Jata                    Initial Development
******************************************************************************************/
trigger ProductVersionTrigger on Product_Version__c (after insert,after delete,after update,before update) {
    
     //check if a trigger event has already executed
    if(!DGF_TriggerUtility.hasTriggerExecuted('Product_Version__c')) {
        
        //check after context
        if(Trigger.isAfter){            
            //check insert context
            if(Trigger.isInsert){
                DGF_ProductVersionTriggerHandler.executeOnAfterInsert();
            }
            //check delete context
            if(Trigger.isDelete){
                DGF_ProductVersionTriggerHandler.executeOnAfterDelete();
            }
            //check update context
            if(Trigger.isUpdate){
                DGF_ProductVersionTriggerHandler.executeOnAfterUpdate();
            }
        }
        
        //check before context
        if(Trigger.isBefore){ 
            //check update contect
            if(Trigger.isUpdate){
                DGF_ProductVersionTriggerHandler.executeOnBeforeUpdate();
            }
        }        
    }
}