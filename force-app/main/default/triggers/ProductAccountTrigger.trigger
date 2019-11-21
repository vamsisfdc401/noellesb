/*****************************************************************************************
TriggerName: ProductTrigger 
Purpose: Trigger for Product Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/08/2017           Jata                    Initial Development
******************************************************************************************/
trigger ProductAccountTrigger on Product_Account__c (before insert,before update) {
    
    //check if a trigger event has already executed        
    if(!DGF_TriggerUtility.hasTriggerExecuted('Product_Account__c')) {
    //check before context
        if(Trigger.isBefore){
            
            //check update context
            if(Trigger.isUpdate){
                //call handler method for before update
                DGF_ProductAccountTriggerHandler.executeOnBeforeUpdate();
            }

            //check insert context
            if(Trigger.isInsert){
                //call handler method for before insert
                DGF_ProductAccountTriggerHandler.executeOnBeforeInsert();
            }
        }
    }

}