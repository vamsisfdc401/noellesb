/*****************************************************************************************
TriggerName: WorkflowTrigger 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             04/24/2018           Ashok                    Initial Development

No logic built on the Trigger as a best practice, and just call GBSworkflowTrigger handler.
All the logic should be written only on handler.
******************************************************************************************/
trigger WorkflowTrigger on Workflow__c (after insert, after update, after delete)
{
    if (Trigger.isafter )
    {
        If ( Trigger.isinsert)
        {
            
            GBSWorkflowTriggerHandler.executeOnAfterInsert(Trigger.New);
            // GBS-331 workflow insert
            GBSLicenseeFlagTriggerHandler.workFlowInsert(Trigger.New);
            
            //GBS-408 workflow insert                      
            RecursiveTriggerHandler.isFirstTime = false;//update the recursive trigger flag to false
            GBSCurrentWorkFlowTriggerHandler.workFlowInsert(Trigger.New);
            
            //GBS-489             
            GBSWorkFlowApprovalDateTriggerHandler.executeOnAfterInsert(Trigger.New);
            GBSFactoryCurrentWorkFlowTriggerHandler.executeOnAfterInsert(Trigger.New);
        }
        else if (Trigger.isupdate)
        {
            
            GBSWorkflowTriggerHandler.executeOnAfterUpdate(Trigger.New,trigger.oldMap);
            // GBS-331 workflow update
            GBSLicenseeFlagTriggerHandler.workFlowUpdate(Trigger.New,trigger.oldMap);            
            
            //GBS-408 workflow update
            //check for recursive trigger update
            if(RecursiveTriggerHandler.isFirstTime){               
                RecursiveTriggerHandler.isFirstTime = false;
                GBSCurrentWorkFlowTriggerHandler.workFlowUpdate(Trigger.New,trigger.oldMap);                                
            }
            
            //GBS-489 
            GBSWorkFlowApprovalDateTriggerHandler.executeOnAfterUpdate(Trigger.New,trigger.oldMap);
            GBSFactoryCurrentWorkFlowTriggerHandler.executeOnAfterUpdate(Trigger.New,trigger.oldMap);
        }
        else if (trigger.isdelete)
        {
            GBSWorkflowTriggerHandler.executeOnAfterDelete(Trigger.old);
            // GBS-331 workflow delete
            GBSLicenseeFlagTriggerHandler.workFlowDelete(Trigger.old);
        }
    }
    
}