trigger PCGBSContractTrigger on Contract__c (after update, after insert, before delete, after delete, before insert, before update) 
{ 
  
       //after triggers 
    if (Trigger.isAfter) { 

        /* 
            This part creates first group tasks when new object is created 
        */ 
        if(Trigger.isInsert) 
            FSTR.ProcessComposerExecution.CreateSteps(Trigger.new);     
        if(Trigger.isUpdate){ 
            FSTR.RBPExecution.AfterObjectUpdate(Trigger.old, Trigger.new);        
            FSTR.ProcessComposerExecution.CreateStepsOnUpdate(Trigger.old, Trigger.newMap); 
        
        } 
    } 


    /* 
    The trigger is fired before creation of new object 
    */ 
    if (Trigger.isBefore) { 
        if (Trigger.isInsert || Trigger.isUpdate){ 
             if(Trigger.isInsert){ 
                FSTR.ProcessComposerExecution.DetermineBusiness(Trigger.new); 
                for(Contract__c newRec : Trigger.new) { 
                    //set status to open 
                    newRec.Status__c = 'Open'; 
                } 
            } 
            FSTR.ProcessComposerExecution.DetermineDefinition(Trigger.new); 
        } 
        else if(Trigger.isDelete){ 
            for(Contract__c delRec : Trigger.Old) { 
                if(delRec.Recurring_Business_Process__c != null) 
                    delRec.addError('You cannot delete a Contract that was generated by a Recurring Business Process.'); 
            } 
        }   
    } 
}