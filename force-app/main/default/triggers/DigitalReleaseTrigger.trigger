/*****************************************************************************************
TriggerName: DigitalReleaseTrigger 
Purpose: Trigger for Digital Release Object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/04/2017           Mohit                    Initial Development
******************************************************************************************/
trigger DigitalReleaseTrigger on Digital_Release__c (before insert, after insert, before update, after update, before delete) {
    string BundleRecordtypeId= schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.Bundle).getRecordTypeId();
    //check if a trigger event has already executed
    if (!DGF_TriggerUtility.hasTriggerExecuted('Digital_Release__c') && DGF_TriggerUtility.executeDigitalReleaseTrigger) {
        
        //check before context
        if (Trigger.isBefore) {
            //check insert and update context
            if (Trigger.isUpdate) {
                //call handler method for before update;
                DGF_DigitalReleaseTriggerHandler.executeOnBeforeUpdate();
            }
            
            //check insert context
            else if (Trigger.isInsert) {
                system.debug('=====2====');
                //call handler method for before insert
                DGF_DigitalReleaseTriggerHandler.executeOnBeforeInsert();
            }
        }
        
        //check after context
        else if (trigger.isAfter) {
            
            //check update context
            if (Trigger.isUpdate) {
                system.debug('=====3====');                
                //call handler method for after update
                DGF_DigitalReleaseTriggerHandler.executeOnAfterUpdate();
                DGF_SystemModeUtility.changeReleaseAccessLevelAndSendEmail();
            }
            
            //check insert context
            else if (Trigger.isInsert) {
                system.debug('=====4====');
                //call handler method for after insert 
                DGF_DigitalReleaseTriggerHandler.executeOnAfterInsert();
            }        
        }    
    }
    
    //For GTM server webservice
    if(Trigger.isUpdate && Trigger.IsAfter)
    {
        String message='';
        for(Digital_Release__c dig:trigger.new){
            system.debug('***** is blank '+String.isBlank(dig.Bundle_SysGen__C));
            if(String.isBlank(dig.Bundle_SysGen__C)){
                message=DGF_DigitalReleaseTriggerHandler.CallingGTMServerWebservice(Trigger.New,Trigger.Old); 
            }
        }
        
        system.debug('=====message==== +Execution One');
        for(Digital_Release__c d:Trigger.New)
        {
            if(message!='')
                d.adderror(message);  
            
            
        }
        for(Digital_Release__c d:Trigger.New){            
            for(Digital_Release__c d1:Trigger.old){
                if(d.send_to_gtm__c==true && d.send_to_gtm__c==d1.send_to_gtm__c && d.Bundle_SYSGEN__c !=null && d.Bundle_SYSGEN__c ==d1.Bundle_SYSGEN__c && ( d.Primary_Bundle_Genre__c!=d1.Primary_Bundle_Genre__c || d.Bundle_Genre__c!=d1.Bundle_Genre__c || d.US_Bundle_Avail_Date__c!=d1.US_Bundle_Avail_Date__c || d.CA_Bundle_Avail_Date__c!=d1.CA_Bundle_Avail_Date__c || d.US_Bundle_Pre_Purchase_Date__c!=d1.US_Bundle_Pre_Purchase_Date__c || d.CA_Bundle_Pre_Purchase_Date__c!=d1.CA_Bundle_Pre_Purchase_Date__c || d.Deactivation_Date__c!=d1.Deactivation_Date__c ) ){
                    DGF_DigitalReleaseTriggerHandler.CallUpdateFieldsWebservice(Trigger.New,Trigger.Old);
                }
                else if(d.send_to_gtm__c==true && d.send_to_gtm__c==d1.send_to_gtm__c && d.Bundle_SYSGEN__c ==null && d.Bundle_SYSGEN__c ==d1.Bundle_SYSGEN__c && ( d.Primary_Bundle_Genre__c!=d1.Primary_Bundle_Genre__c || d.Bundle_Genre__c!=d1.Bundle_Genre__c || d.US_Bundle_Avail_Date__c!=d1.US_Bundle_Avail_Date__c || d.CA_Bundle_Avail_Date__c!=d1.CA_Bundle_Avail_Date__c || d.US_Bundle_Pre_Purchase_Date__c!=d1.US_Bundle_Pre_Purchase_Date__c || d.CA_Bundle_Pre_Purchase_Date__c!=d1.CA_Bundle_Pre_Purchase_Date__c || d.Deactivation_Date__c!=d1.Deactivation_Date__c ) ){
                    d.adderror('Bundle Sysgen is null..!!');
                }
            }
        }
        
        for(Digital_Release__c d:Trigger.New)
        {            
            User u=[select id, profileid from User where id=:d.LastModifiedById];
            Profile p1=[select id,name from profile where name='Platform API'];
            for(Digital_Release__c d1:Trigger.old){                
                if(d.Bundle_SYSGEN__c!=null && d.Bundle_SYSGEN__c!=d1.Bundle_SYSGEN__c && u.profileId!=p1.id)
                    DGF_DigitalReleaseTriggerHandler.CallingGTMServerWebserviceAfter_Bundle_SYSGEN_Update(Trigger.New,trigger.old);
            }
        }
    }
              
    if (Trigger.isDelete) {                
        //displaying error message while deleting record other than Admin
        for(Digital_Release__c drd:trigger.old){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(profileName!='System Administrator' && drd.Send_to_GTM__c==true)
                drd.addError('Delete failed. You are not authorized to delete this record');
        }
    }
    
    
}