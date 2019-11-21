/*trigger TitleTrigger on Title__c (before insert, before update, after update) {
    
    if(Trigger.isBefore){
       TitleTriggerHandler.setParentTitle();        
    }
    
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('Title__c')) {  //DFOR-1498
        
        //check after context
        if (Trigger.isAfter) {
            
            //check update context
            if (Trigger.isUpdate) {
                //calling handler method for after update
                TitleTriggerHandler.executeOnAfterUpdate();
            }
        }
    }
    
    
}*/
trigger TitleTrigger on Title__c (before insert, before update, after update) {
    Id currentUserProfile = userinfo.getProfileId();
    Boolean execute = true;
    if (!Test.IsRunningTest() && (currentUserProfile == Label.UPHE_CG_Approver || currentUserProfile == Label.UPHE_CG_Full_User || currentUserProfile == Label.UPHE_CG_Standard_User || currentUserProfile == Label.UPHE_LA_Approver || currentUserProfile == Label.UPHE_CG_Read_All_User || currentUserProfile == Label.UPHE_CG_System_Administrator)) {
        execute = false;
    }
    if (execute) {
        if(Trigger.isBefore){
           TitleTriggerHandler.setParentTitle();        
        }
        
        //check if a trigger event has already executed
        if (!DGF_TriggerUtility.hasTriggerExecuted('Title__c')) {  //DFOR-1498
            
            //check after context
            if (Trigger.isAfter) {
                
                //check update context
                if (Trigger.isUpdate) {
                    //calling handler method for after update
                    TitleTriggerHandler.executeOnAfterUpdate();
                }
            }
        }
    }
    
    
    
}