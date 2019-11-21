/*****************************************************************************************
TriggerName: Pricingtrigger
Purpose: Trigger for Pricing Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             18/05/2017           Prarthana                Initial Development
******************************************************************************************/
trigger PricingTrigger on Pricing__c (before insert, after insert, before update, after update) {
    
    //if cloning process then don't execute the pricing trigger
    if (DGF_TriggerUtility.isCloningProcess) {
        return;
    }
    
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('Pricing__c') && DGF_TriggerUtility.executePricingTrigger) {
      //check before context
        if (Trigger.isBefore) {
            
            //check update context
            if (Trigger.isUpdate) {
                //call handler method for before update
                DGF_PricingTriggerHandler.executeOnBeforeUpdate();                
            }

            //check insert context
            else if (Trigger.isInsert) {
                //call handler method for before insert
                DGF_PricingTriggerHandler.executeOnBeforeInsert();
            }
        }
        
        //check after context
        else if (trigger.isAfter) {
            
            //check update context
            if (Trigger.isUpdate) {
                //call handler method for after update
                DGF_PricingTriggerHandler.executeOnAfterUpdate();
            }
            
            //check insert context
            else if (Trigger.isInsert) {
                //call handler method for after insert
                DGF_PricingTriggerHandler.executeOnAfterInsert();
            }        
        }    
    }
}