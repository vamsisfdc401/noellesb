trigger PlantTrigger on Plant__c (before insert, before update) 
{                                                                      
    if(!TriggerUtility.hasTriggerExecuted('Plant__c')){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                PlantTriggerEventHandler.executeOnBeforeInsert();               
            }
            else if(Trigger.isUpdate){
                PlantTriggerEventHandler.executeOnBeforeUpdate();
            }
            else if(Trigger.isDelete){
                
            }
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert){
                
            }
            else if(Trigger.isUpdate){
                
            }
            else if(Trigger.isDelete){
                
            }   
        }       
    }
}