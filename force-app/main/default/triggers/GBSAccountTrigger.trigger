trigger GBSAccountTrigger on Account (before insert, after insert, before update, after update, before delete,after delete) 
{
    
    //check after context
    if (trigger.isAfter)
    {        
        If (Trigger.IsInsert) {
        GBSAccountTriggerHandler.UpdateContractLMSFlag();
        GBSAccountTriggerHandler.createTask(Trigger.new);
            }
        else if (Trigger.IsUpdate)
        {
          GBSAccountTriggerHandler.UpdateContractLMSFlag();  
        }
    }
     
}