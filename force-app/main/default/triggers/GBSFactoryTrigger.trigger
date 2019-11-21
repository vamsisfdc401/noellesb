/*****************************************************************************************
TriggerName: GBSFactoryTrigger 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/10/2018           Ashok                    Initial Development

No logic built on the Trigger as a best practice, and just call GBSContractTriggerHandler.
All the logic should be written only on handler.
******************************************************************************************/

trigger GBSFactoryTrigger on Factory__c (after update) 
{
    if(trigger.isafter && Trigger.isUpdate){
      
       GBSFactoryTriggerHandler.UpdateContractLMSFlag();
    }
}