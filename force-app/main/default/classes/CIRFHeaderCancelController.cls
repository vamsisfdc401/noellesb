public without sharing class CIRFHeaderCancelController {
    @AuraEnabled
    public static List<String> getCancelReasonPicklist() {
        Schema.DescribeFieldResult fieldResult = CIRF_Header__c.Cancellation_Reason__c.getDescribe();
        List<Schema.PicklistEntry> CancellationFieldResult = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for( Schema.PicklistEntry f : CancellationFieldResult) {
            options.add(f.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public Static String cancelHeader(ID recordId,String cancelReason){
        try{
        List<Id> relIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        List<Task> tasksToUpdate = new List<Task>();
        CIRF_Header__c header = [select id, Name, OwnerId, CIRF_Name__c, CIRF_Status__c, (select id from CIRF_Materials__r), Revision__c, 
                                 RIM_Approval__c, Retailer__c from CIRF_Header__c where id=:recordId];
        if(/*header.CIRF_Status__c == 'Draft' || */header.CIRF_Status__c == 'Complete'){
            return 'You can not cancel a Header in Complete Status';
        }
        else if(header.CIRF_Status__c == 'Cancelled'){
            //HEITCIRF-199
            return 'This CIRF is already Cancelled';
        }
        
        List<ProcessInstance> proInstanceList = [SELECT Id,TargetObjectId,(select id from Workitems) FROM ProcessInstance where TargetObjectId = :recordId AND Status = 'Pending'];
        if(!proInstanceList.isEmpty()){
            //User u = [select id, name from user where name like :Label.CIRF_Admin_User_Name];
            //System.runAs(u){
            CIRFHeaderTriggerHandler.reviseCancel = true;
                List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstance proInstance : proInstanceList){
                    for(ProcessInstanceWorkitem workItem : proInstance.Workitems){
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setComments('Rejecting request.');
                        req.setAction('Reject');
                        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                        req.setWorkitemId(workItem.Id);
                        reqList.add(req);
                    }
                }
                List<Approval.ProcessResult> result2 =  Approval.process(reqList);
            //}
        }
        
        //if block added by Kalyani to set CIRF Status to cancelled on locked request
        /* if(!proInstanceList.isEmpty()){
            //return 'You can not cancel when RIM Approval is pending';
            //create object to serialize and send it to email service
            CIRF_Header__c cirfHeaderObject = new CIRF_Header__c(CIRF_Status__c = 'Cancelled', Id = header.Id,Cancellation_Reason__c = cancelReason);
            //call email service to cancel the request            
            Map<String, Object> resultMap = SObjectDMLEmailService.mApprovalRecallAction(JSON.serialize(cirfHeaderObject), 'CIRF_Header__c');
            if(Boolean.valueOf(resultMap.get('bSuccess')) == true) {
                return 'Request was cancelled successfully! It may take 5-10 seconds to update, please refresh your page.';
            } else {
                return 'There was an error in processing the request.';
            }
            
        }*/
        
        header.CIRF_Status__c = 'Cancelled';
        header.Cancellation_Reason__c = cancelReason;
        for(CIRF_Material__c cm : header.CIRF_Materials__r) {
            relIds.add(cm.id);
        }
        header = CIRF_Utility.ReviseCIRF(header,true);
        
        //CIRFCreateForecastRecords2.CreateForRecords(header.id,false); // VK Moved to the CIRFHeaderTriggerHandler
        for(Task tk : [select id, Status, WhatId, isClosed from Task where whatid IN :relIds AND isClosed = false]) {
            tk.Status = 'Completed';
            tasksToUpdate.add(tk);
        }
       /* for(CIRF_Material__c cirfmat : [select id, CIRF_Header__c from CIRF_Material__c where CIRF_Header__c = :header.id] ) 
        {
            CIRFCreateForecastRecords2.CancelledCMATFrctRecords(cirfmat.id, header.revision__C);
        }
        */
        userIds.add(header.OwnerId);
        for(AccountTeamMember atm : [select accountid, userid from AccountTeamMember where 
                                     accountid=:header.Retailer__c AND TeamMemberRole = 'CIRF RIM Team']) {
                                         if(!userIds.contains(atm.userid)) {
                                             userIds.add(atm.userid);
                                         }
                                     }
        EmailTemplate et=[Select id from EmailTemplate where name = :Label.CIRF_Header_Cancel_Email_Template limit 1];
        /*
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setTargetObjectIds(userIds);
        mail.setSenderDisplayName('System Admin');
        mail.setTemplateId(et.id);
        mail.setSaveAsActivity(false);
        Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(new Messaging.MassEmailMessage[]{mail});
*/
        
        //for bypassing update restrictions based on header status
        CIRFMaterialTriggerHandler.allowedCIRFActions = false;
        CIRFCorrugateTriggerHandler.allowedCIRFActions = false;
        CIRFCorrugateMaterialTriggerHandler.allowedCIRFActions = false;
        CIRFHeaderTriggerHandler.Updatedfromheader=true;
        //try {
            update tasksToUpdate;
            update header;
            //}
        /*catch(Exception e){
            System.debug(e.getMessage());
            if(e.getMessage().contains('Your Delivery/In Store date must be prior to or the same as your CIRF Start Date')) {
                return 'Your Delivery/In Store date must be prior to or the same as your CIRF Start Date';
            }
            else if(e.getMessage().contains('Record is read-only')) {
                return 'Record is read-only';
            }
        }*/
        List<String> groupMemberEmails = Utility.getUserEmails(userIds);
        Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(et.Id, userInfo.getUserId(), header.Id);
        msg.setToAddresses(groupMemberEmails);
        msg.setSaveAsActivity(false);
        system.debug ('-----------------------'+msg);
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
        }catch(Exception e){
            System.debug(e.getMessage());
            if(e.getMessage().contains('Your Delivery/In Store date must be prior to or the same as your CIRF Start Date')) {
                return 'Your Delivery/In Store date must be prior to or the same as your CIRF Start Date';
            }
            else if(e.getMessage().contains('Record is read-only')) {
                return 'Record is read-only';
            }
            else{
               return e.getMessage(); 
            }
        }
        return 'success';
    }
}