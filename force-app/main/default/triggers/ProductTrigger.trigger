/*****************************************************************************************
TriggerName: ProductTrigger 
Purpose: Trigger for Product Object

******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/05/2017           Jata                    Initial Development
******************************************************************************************/
trigger ProductTrigger on Product__c (after insert,after update,before insert,before update , before delete) {
    public static Boolean flag=false; 
    
    System.debug('DGF_TriggerUtility.producTriggerExecuted........'+DGF_TriggerUtility.producTriggerExecuted);
    System.debug(DGF_TriggerUtility.sobjectExecutedEvents); 
    //check if a trigger event has already executed        
    if(!DGF_TriggerUtility.hasTriggerExecuted('Product__c') || DGF_TriggerUtility.producTriggerExecuted ) {
        System.debug('trigger............');
        //check after context
        if (trigger.isAfter){
            
            //check update context
            if(Trigger.isUpdate){
                //call handler method for after update
                DGF_ProductTriggerHandler.executeOnAfterUpdate();
            }
            
            //check insert context
            if(Trigger.isInsert){
                //call handler method for after insert
                DGF_ProductTriggerHandler.executeOnAfterInsert();
            }        
        }
        
        //check before context
        else if(Trigger.isBefore){
            
            //check update context
            if(Trigger.isUpdate){
                //call handler method for before update
                DGF_ProductTriggerHandler.executeOnBeforeUpdate();
            }
            
            //check insert context
            if(Trigger.isInsert){
                //call handler method for before insert
                DGF_ProductTriggerHandler.executeOnBeforeInsert();
            }
        }
    }
    
    // =========== Webservice call to send products added after Digital relase send=========== 
    
    if(Trigger.isUpdate && Trigger.isAfter){
        
        String message='';
        for(Product__c pp: trigger.new){
            for(Product__c pp1: trigger.old){
                if(pp.short_name__c != null  && pp.JSON_Send__c==false){
                    // if(DGF_ProductTriggerHandler.runOnce())
                    // {
                    flag=DGF_ProductTriggerHandler.getFlagForProducts(trigger.new);
                    system.debug('****flag1 '+flag);
                    // }
                }
            }
            
        }
        if(flag){
            message=DGF_ProductTriggerHandler.CallGTNServiceForNewProducts(Trigger.new);
        }
        
        
        for(Product__c d:Trigger.New)
        {
            if(message!='')
                d.adderror(message);
            
        }
        
        //======================= Product Update =================
        //
        
        for(Product__c pp: trigger.new){ 
            
            for(Product__c pd1: trigger.old){
                System.debug('***** pp.Bundle_id__c '+pp.Bundle_id__c);
                if((pp.Bundle_id__c != null && pp.JSON_Send__c==true) && (pp.Short_Name__c!=pd1.Short_Name__c || pp.Bundle_Synopsis__c!=pd1.Bundle_Synopsis__c || pp.name!=pd1.name) ){ 
                    
                    //                         if(DGF_ProductTriggerHandler.runOnce())
                    // {
                    System.debug('***** 2   before update product method call'+ pd1.JSON_Send__c);
                    DGF_ProductTriggerHandler.UpdateFieldsProducts(trigger.new,trigger.old);
                    //}
                }
                else if((pp.Bundle_id__c == null && pp.JSON_Send__c==true && pp.JSON_Send__c == pd1.JSON_Send__c) && (pp.Short_Name__c!=pd1.Short_Name__c || pp.Bundle_Synopsis__c !=pd1.Bundle_Synopsis__c || pp.name !=pd1.name) ){
                    System.debug('Befroe bundle id null');
                    pp.adderror('Bundle Id is null..!!');
                }
            }
        }
               
    }
                
    if (Trigger.isDelete) {                
        //displaying error message while deleting record other than Admin
        for(Product__c prod:trigger.old){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName!='System Administrator' && prod.JSON_Send__c==true)
                prod.addError('Delete failed. You are not authorized to delete this record');
        }
            
    }
     
}