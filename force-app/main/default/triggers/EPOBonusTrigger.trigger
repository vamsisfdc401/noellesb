/*****************************************************************************************
TriggerName: EPOBonusTrigger 
Purpose: Trigger for EPO Bonus Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Prarthana                Initial Development
******************************************************************************************/
trigger EPOBonusTrigger on EPO_Bonus__c (before insert, after insert, before update,after update,before delete) {
    
    if(Trigger.isAfter && Trigger.isUpdate && DGF_TriggerUtility.sobjectExecutedEvents.containsKey('EPO_Bonus__c') && DGF_TriggerUtility.sobjectExecutedEvents.get('EPO_Bonus__c').contains('AFTER UPDATE')){       
        DGF_TriggerUtility.sobjectExecutedEvents.get('EPO_Bonus__c').remove('AFTER UPDATE');
    }   
    
    //check if a trigger event has already executed
    if(!DGF_TriggerUtility.hasTriggerExecuted('EPO_Bonus__c')) {        
        //check before context
        if(Trigger.isBefore){
            
            //check update context
            if(Trigger.isUpdate){
                //call handler method for before update
                DGF_EPOBonusTriggerHandler.executeOnBeforeUpdate();
            }

            //check insert context
            if(Trigger.isInsert){
                //call handler method for before insert
                DGF_EPOBonusTriggerHandler.executeOnBeforeInsert();
            }
            
               //check insert context
            if(Trigger.isDelete){
                //call handler method for before insert
                DGF_EPOBonusTriggerHandler.executeOnBeforeDelete();
            }
        }
        
        //check after context
        else if (trigger.isAfter){
            
            //check update context
            if(Trigger.isUpdate){
                //call handler method for after update
                DGF_EPOBonusTriggerHandler.executeOnAfterUpdate();                 
            }
            
            //check insert context
            if(Trigger.isInsert){
                //call handler method for after insert
                DGF_EPOBonusTriggerHandler.executeOnAfterInsert();
            }        
        }    
    }
}