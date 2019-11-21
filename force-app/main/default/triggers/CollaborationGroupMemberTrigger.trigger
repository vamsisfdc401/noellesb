/*****************************************************************************************
TriggerName: CollaborationGroupMemberTrigger 
Purpose: Trigger for CollaborationGroupMember Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/06/2017           Mohit                    Initial Development
******************************************************************************************/
trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (after insert,after delete) {
    
    //check if a trigger event has already executed
    if(!DGF_TriggerUtility.hasTriggerExecuted('CollaborationGroupMember ')) {
        
        //if after context
        if(Trigger.isAfter){
            
            //for insert
            if(Trigger.isInsert){
                DGF_SystemModeUtility.addSharingForGroupMember();
            }
            
            //for delete
            if(Trigger.isDelete){
                DGF_SystemModeUtility.removeSharingForGroupMember();
            }
        }
    }
}