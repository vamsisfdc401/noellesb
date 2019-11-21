public without sharing class CIRFReviseBtnController {
    @AuraEnabled
    public static List<String> getRevisionReasonPicklist() {
        Schema.DescribeFieldResult fieldResult = CIRF_Header__c.Revision_Reason__c.getDescribe();
        List<Schema.PicklistEntry> RevisionResult = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for( Schema.PicklistEntry f : RevisionResult) {
            options.add(f.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public Static String checkRevision(ID recordId,String revisionReason){
        try{
        //for bypassing update restrictions based on header status
        CIRFMaterialTriggerHandler.allowedCIRFActions = false;
        CIRFCorrugateTriggerHandler.allowedCIRFActions = false;
        CIRFCorrugateMaterialTriggerHandler.allowedCIRFActions = false;
        
        List<Id> relIds = new List<Id>();
        List<Task> tasksToUpdate = new List<Task>();
        CIRF_Header__c header = [select id, Name, OwnerId, CIRF_Name__c, Retailer__c, CIRF_Status__c,(select id from CIRF_Materials__r),RIM_Approval__c from CIRF_Header__c where id= :recordId];//Kalyani - removing Revision__c from query as it is not referenced in code
        if(header.CIRF_Status__c == 'Draft' || header.CIRF_Status__c == 'Complete'){
            return 'You can not revise this header.';
        }
        
         List<ProcessInstance> proInstanceList = [SELECT Id,TargetObjectId,(select id from Workitems) FROM ProcessInstance where TargetObjectId = :recordId AND Status = 'Pending'];
        //if block added by Kalyani to set CIRF Status to Draft on locked request
        /*if(!proInstanceList.isEmpty()){
            //create object to serialize and send it to email service
            CIRF_Header__c cirfHeaderObject = new CIRF_Header__c(CIRF_Status__c = 'Draft', Id = header.Id,Revision_Reason__c = revisionReason);
            //call email service to cancel the request            
            Map<String, Object> resultMap = SObjectDMLEmailService.mApprovalRecallAction(JSON.serialize(cirfHeaderObject), 'CIRF_Header__c');
            if(Boolean.valueOf(resultMap.get('bSuccess')) == true) {
                return 'Request was revised successfully! It may take 5-10 seconds to update, please refresh your page.';
            } else {
                return 'There was an error in processing the request.';
            }
            
        } */
        
        /*if(!proInstanceList.isEmpty()){
            return 'You can not revise when RIM Approval is pending';
        }*/
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
        
        header.CIRF_Status__c='Draft';
        for(CIRF_Material__c cm : header.CIRF_Materials__r) {
            relIds.add(cm.id);
        }
        
        for(Task tk : [select id, Status, WhatId, isClosed from Task where whatid IN :relIds AND isClosed = false]) {
            //tk.Status = 'Completed';
            //HEITCIRF-742
            tk.Status = 'Cancelled';
            tasksToUpdate.add(tk);
        }
        header = CIRF_Utility.ReviseCIRF(header,false);
        header.Revision_Reason__c = revisionReason;
        List<Id> userIds = new List<Id>();
        userIds.add(header.OwnerId);
        for(AccountTeamMember atm : [select accountid, userid from AccountTeamMember where 
                                     accountid=:header.Retailer__c AND TeamMemberRole = 'CIRF RIM Team']) {
                                         if(!userIds.contains(atm.userid)) {
                                             userIds.add(atm.userid);
                                         }
                                     }
        EmailTemplate et=[Select id from EmailTemplate where name = :Label.CIRF_Header_Revise_Email_Template limit 1];
        /*
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        //mail.setSubject('CIRF Header Approval');
        mail.setTargetObjectIds(userIds);
        system.debug('Id--'+userIds);
        mail.setSenderDisplayName('System Admin');
        mail.setTemplateId(et.id); 
        mail.setSaveAsActivity(false);
        Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(new Messaging.MassEmailMessage[]{mail});
        */
        
        
         CIRFHeaderTriggerHandler.Updatedfromheader = true;
        //try {
            update tasksToUpdate;
            update header;
        //}
        /*catch(Exception e) {
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
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
        }catch(Exception e) {
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