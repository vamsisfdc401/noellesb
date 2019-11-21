trigger PCEcontractctrigger on contract__c (after update, after insert){
 string operation = Trigger.isUpdate ? 'Update' : 'Insert';FSTR.ProcessComposerInitiatorUtils.EvaluateInitiators(Trigger.oldMap, Trigger.newMap, operation); 
}