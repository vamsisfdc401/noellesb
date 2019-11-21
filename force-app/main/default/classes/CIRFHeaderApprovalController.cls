public class CIRFHeaderApprovalController {
    @AuraEnabled
    public Static String checkValidations(ID recordId){
        try {//added by Kalyani
            List<Id> corrugateIds = new List<Id>();
            boolean scenario4 = false;
            CIRF_Header__c header = [select id, Name, RIM_Approval__c, Studio__c, Request_Type__c, RIM_Approval_Reason__c, OwnerId, CIRF_Name__c, 
                                     CIRF_Status__c, Retailer__c, Retailer__r.CIRF_RIM_Approval__c, Retailer__r.CIRF_No_RIM_Approval__c,
                                     Super_CIRF__c, Is_Super_CIRF__c,Territory__c
                                     from CIRF_Header__c where id= :recordId];
            
            //HEITCIRF-199
            List<String> invalidStatus = new List<String>{'Loaded','Cancelled','Merged'};
                if(invalidStatus.contains(header.CIRF_Status__c)){
                    return 'You cannot submit this Header for approval. Select Revise if you need to make any changes';
                }
            if(header.CIRF_Status__c == 'Complete'){
                return 'You cannot submit this Header for approval';
            }
            if(header.CIRF_Status__c != 'Draft' && header.CIRF_Status__c != 'Submitted'){
                return 'Header Status is not Draft or Submitted';
            }
            
            List<CIRF_Material__c> relCIRFMaterials = [select id, name, Material_Status__c,Total_Order_Qty__c, Corrugate_Units__c,Replen_Units__c, CIRF_Header__c, CIRF_Material_Status__c, Creator_Approval__c, Units_to_Order__c,
                                                       Exception_Type__c,Material_Name__r.CIRF_US_D_Chain_Spec__c,Material_Name__r.CIRF_CDN_D_Chain_Spec__c from CIRF_Material__c where CIRF_Header__c= :recordId AND CIRF_Material_Status__c != 'Cancelled'];
            System.debug(relCIRFMaterials);
            if(relCIRFMaterials.isEmpty()) {
                return 'You dont have any materials to submit...please try again.';
            }
            List<String> statusValues = new List<String>{'IL','XX','ZW'};
                Set<String> validExceptionTypes = new Set<String> {'Distribution Only', 'Manufacturing and Distribution','Temporary Status Exception'};
                    for(CIRF_Material__c cm : relCIRFMaterials) {
                        if(cm.Total_Order_Qty__c <= 0) {
                            return 'Please make sure all your quantities are >0';
                        }
                        if(cm.CIRF_Material_Status__c == 'Draft' && statusValues.contains(cm.Material_Status__c)){
                            return 'Umm, you have a chosen at least 1 forbidden material. Check yourself before you wreck yourself and remove them from your CIRF';
                        }

                        //SJ - 02/20/2019 - HEITCIRF-739
                        if(header.Territory__c == 'US'){
                            if(cm.Material_Name__r.CIRF_US_D_Chain_Spec__c == null){
                                return 'There is a material with a blank material status. Please contact the support team to proceed';
                            }
                        }
                        if(header.Territory__c == 'CDN'){
                            if(cm.Material_Name__r.CIRF_CDN_D_Chain_Spec__c == null){
                                return 'There is a material with a blank material status. Please contact the support team to proceed';
                            }
                        }                        
                        /*added by kalyani to satify this validation rule- Valid_Exception_Types , on CIRF Material
if(String.isBlank(cm.Exception_Type__c) || (String.isNotBlank(cm.Exception_Type__c) &&  !validExceptionTypes.contains(cm.Exception_Type__c))) {
return System.Label.Valid_Exception_Types ;
}*/
                    }
            List<CIRF_Corrugate__c> relCorrugates = [select id, CIRF_Header__c, Total_Number_of_Facings__c from CIRF_Corrugate__c where CIRF_Header__c= :recordId];
            System.debug(relCorrugates);
            for(CIRF_Corrugate__c cc : relCorrugates) {
                //corrugateIds.add(cc.id);
                if(cc.Total_Number_of_Facings__c < 1){
                    return 'You have submitted a corrugate where the facings are not a whole number. Please revise.';
                }
            }
            
            /*List<CIRF_Corrugate_Material__c> relCorMaterials = [select id, CIRF_Material__c, CIRF_Corrugate__c, Facings__c 
from CIRF_Corrugate_Material__c where CIRF_Corrugate__c IN :corrugateIds];
System.debug(relCorMaterials);
for(CIRF_Corrugate_Material__c ccm : relCorMaterials) {
System.debug(ccm.Facings__c);    
if(ccm.Facings__c != null && ccm.Facings__c.round() != ccm.Facings__c) {
return 'You have submitted a corrugate where the facings are not a whole number. Please revise.';
}
}
*/
            List<Id> userIds = new List<Id>();
            ID userId = UserInfo.getUserId();
            System.debug(userId);
            List<AccountTeamMember> teamMembers = [select accountid, userid, TeamMemberRole, User.Email from AccountTeamMember 
                        where accountid=:header.Retailer__c AND (TeamMemberRole='CIRF RIM Team' OR TeamMemberRole='CIRF Customer Ops' OR TeamMemberRole='Sales Rep')];
            System.debug(teamMembers);
            List<Id> memberIds = new List<Id>();
            for(AccountTeamMember atm : teamMembers) {
                if(atm.TeamMemberRole == 'CIRF RIM Team'){
                    memberIds.add(atm.userid);
                    System.debug(atm.userid);
                }
                else{
                    userIds.add(atm.userid);
                }
            }
            System.debug(memberIds);
            System.debug(header.OwnerId != userId);
            System.debug(!(memberIds.contains(userId)));
            if(header.OwnerId != userId && (!(memberIds.contains(userId)))) { 
                return 'You are not a designated submitter for this account. What are you doing? Who are you? What is going on? Big Brother is watching.';
            }
            //validations satisfied
            
            header.RIM_Approval__c = false;
            header.RIM_Approval_Reason__c = '';
            
            /*try {
update header;
}
catch(Exception e){
System.debug(e.getMessage());
if(e.getMessage().contains('Your Delivery/In Store date must be prior to or the same as your CIRF Start Date')) {
return 'Your Delivery/In Store date must be prior to or the same as your CIRF Start Date';
}
else if(e.getMessage().contains('Record is read-only')) {
return 'Record is read-only';
}
}
*/
            //  HEITCIRF-335 - AL - 12/7/2018
            if (header.Super_CIRF__c == null)
                header.CIRF_Status__c = 'Submitted';
            else
                header.CIRF_Status__c = 'Merged';
            system.debug('Header: ' + header);
            
            List<Approval.ProcessSubmitRequest> reqList = new List<Approval.ProcessSubmitRequest>();
            List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();
            //List<FeedItem> chatterList = new List<FeedItem>();
            List<Id> atmUserIds = new List<Id>();
            //teamMembers = [select accountid, userid, TeamMemberRole, User.Email from AccountTeamMember where accountid=:header.Retailer__c AND TeamMemberRole='CIRF RIM Team'];
            //HEITCIRF 195 Scenario 2
            System.debug('before scenario');
            EmailTemplate rimET=[Select id from EmailTemplate where name = :Label.CIRF_Header_RIM_Approval_ET limit 1];
            //
            System.debug('header.Retailer__r.CIRF_RIM_Approval__c '+header.Retailer__r.CIRF_RIM_Approval__c);
            System.debug('header.Request_Type__c '+header.Request_Type__c);
            System.debug('header.Retailer__r.CIRF_No_RIM_Approval__c '+header.Retailer__r.CIRF_No_RIM_Approval__c);
            System.debug('header.Studio__c '+header.Studio__c);
            //
            
            //
            Map<Id,User> userMap = new Map<Id,User>([select id, isActive from User where id IN :memberIds AND isActive = True]);
            
            if(header.Retailer__r.CIRF_RIM_Approval__c == false){
                System.debug('scenario 2');
                header.RIM_Approval__c = true;
                header.RIM_Approval_Reason__c = 'RIM Review Not Required for this Retailer';
            }
            //HEITCIRF 195 Scenario 3
            else if(header.Retailer__r.CIRF_RIM_Approval__c == true && header.Request_Type__c == 'Singles' && (header.Retailer__r.CIRF_No_RIM_Approval__c != null && header.Studio__c != null && (header.Retailer__r.CIRF_No_RIM_Approval__c).contains(header.Studio__c))){
                System.debug('scenario 3');
                header.RIM_Approval__c = true;
                header.RIM_Approval_Reason__c = 'RIM Review Not Required for Singles for this Studio/Retailer combination';
            }
            //HEITCIRF 195 Scenario 4
            else 
            {
                if(header.Retailer__r.CIRF_RIM_Approval__c == true)
                {
                    System.debug('scenario 4');
                    header.isRejected__c = false;
                    header.RIM_Approval__c = false;
                    header.RIM_Approval_Reason__c = '';
                    //header.studio__c = '';
                    if(!Approval.isLocked(header.id)){
                        for(AccountTeamMember atm : teamMembers) {
                            if(userMap.containsKey(atm.UserId)){
                                //approval process
                                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                req1.setComments('Submitting request for approval.');
                                req1.setObjectId(recordId);
                                req1.setSubmitterId(UserInfo.getUserId()); 
                                req1.setProcessDefinitionNameOrId('RIM_Approval');
                                req1.setSkipEntryCriteria(true);
                                req1.setNextApproverIds(new List<Id>{atm.UserId});
                                //req1.setNextApproverIds(idList);
                                reqList.add(req1);
                                
                                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(rimET.id, atm.UserId, header.Id);
                                mail.setToAddresses(new List<String>{atm.User.Email});    
                                mail.setReplyTo('noreply@nbcuni.com');
                                mail.setSaveAsActivity(false);      
                                lstEmailMessages.add(mail);
                                
                                //SJ - HEITCIRF-731 - 02/14/2019
                                /*FeedItem post = new FeedItem();
post.ParentId = atm.UserId;
post.Body = 'Greetings! CIRF Material requires RIM Approval. Click to navigate to the corresponding CIRF.';
post.LinkUrl = Label.CIRF_Environment_URL + 'CIRF_Header__c/' + header.id + '/view?0.source=alohaHeader';
chatterList.add(post);*/
                                
                                scenario4 = true;
                            }
                        }
                    }
                }
            }
            system.debug(header);
            
            //for bypassing update restrictions based on header status
            CIRFMaterialTriggerHandler.allowedCIRFActions = false;
            CIRFCorrugateTriggerHandler.allowedCIRFActions = false;
            CIRFCorrugateMaterialTriggerHandler.allowedCIRFActions = false;
            
            //try {
            update header;
            //}
            /*
catch(DMLException e){//Kalyani - moved to outer try
System.debug(e.getMessage());
if(e.getMessage().contains('Your Delivery/In Store date must be prior to or the same as your CIRF Start Date')) {
return 'Your Delivery/In Store date must be prior to or the same as your CIRF Start Date';
}
else if(e.getMessage().contains('Record is read-only')) {
return 'Record is read-only';
}
}
*/
            List<CIRF_Material__c> CIRFMaterialstoUpdate = new List<CIRF_Material__c>();
            List<CIRF_Corrugate__c> CIRFCorrugatestoUpdate = new List<CIRF_Corrugate__c>();
            
            relCIRFMaterials = [select id, name, CIRF_Header__c, Corrugate_Units__c, CIRF_Material_Status__c, Creator_Approval__c, Units_to_Order__c 
                                from CIRF_Material__c where CIRF_Header__c = :recordId AND CIRF_Material_Status__c = 'Draft'];
            for(CIRF_Material__c cm : relCIRFMaterials) {
                cm.Creator_Approval__c = true;
                cm.CIRF_Material_Status__c = 'Submitted';
                CIRFMaterialstoUpdate.add(cm);
            }
            relCorrugates = [select id, CIRF_Header__c, Corrugate_Status__c, Total_Number_of_Facings__c from CIRF_Corrugate__c 
                             where CIRF_Header__c = :recordId AND Corrugate_Status__c = 'Draft'];
            for(CIRF_Corrugate__c cc : relCorrugates) {
                cc.Corrugate_Status__c = 'Submitted';
                CIRFCorrugatestoUpdate.add(cc);
            }
            relCIRFMaterials = [select id,Corrugate_Units__c,CIRF_Header__r.Name,CIRF_Header__r.Studio__c ,Material_Name__r.Name,Material_Name__r.Product_Class__c  
                                from CIRF_Material__c where CIRF_Header__c = :recordId];
            system.debug('relCIRFMaterials new test email=='+relCIRFMaterials);
            List<string> GroupNames=new List<String>();
            for(CIRF_Material__c cm : relCIRFMaterials) {
                string PBGroup=CIRFHeaderApprovalController.getPublicGroup(cm.CIRF_Header__r.Studio__c,cm.Material_Name__r.Product_Class__c);
                GroupNames.add(PBGroup);
            }
            system.debug('GroupNames=='+GroupNames);
            Set<String> uniqueEmails = new Set<String>();
            
            List<GroupMember> gmList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN : GroupNames]; //:Label.CIRF_Approval_Queue
            for(GroupMember gm : gmList) {
                if(!userIds.contains(gm.UserOrGroupId)){
                    userIds.add(gm.UserOrGroupId);
                }
            }
            System.debug(userIds);
            EmailTemplate et=[Select id from EmailTemplate where name = :Label.CIRF_Header_Submitted_Email_Template limit 1];
            System.debug('submit userIds' + userIds);
            
            List<String> groupMemberEmails = Utility.getUserEmails(userIds);
            System.debug('submit groupMemberEmails' + groupMemberEmails);
            
            Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(et.Id, userInfo.getUserId(), header.Id);
            msg.setToAddresses(groupMemberEmails);
            msg.setSaveAsActivity(false);
            lstEmailMessages.add(msg);
            if(!lstEmailMessages.isEmpty()) {
                System.debug('lstEmailMessages ' + lstEmailMessages);
                Messaging.sendEmail(lstEmailMessages);
            }
            
            
            update CIRFMaterialstoUpdate;
            //update CIRFCorrugatestoUpdate;
            //
            if(scenario4 == true)
            {
                //insert chatterList;
                if(!reqList.isEmpty()) 
                {
                    List<Approval.ProcessResult> resultList = Approval.process(reqList);
                }
            }
            
            return 'success';
        } catch(DMLException e){//Kalyani - moved to outer try
            System.debug(e.getMessage());
            if(e.getMessage().contains('Your Delivery/In Store date must be prior to or the same as your CIRF Start Date')) {
                return 'Your Delivery/In Store date must be prior to or the same as your CIRF Start Date';
            }
            else if(e.getMessage().contains('Record is read-only')) {
                return 'Record is read-only';
            } else {//Else added by Kalyani - return exception message
                return e.getMessage();
            }
        } catch(Exception ex) {//Kalyani - container try - try - catch - catch added to identify any error thrown
            return ex.getMessage();
        }
        
    }
    private static String getPublicGroup(String studio, String productClass){
        String defaultPlanningGroupName = System.Label.CIRF_Default_Public_Group;
        String key = studio + '-' + productClass;
        System.debug(key);
        List<CIRF_Public_Groups_Mapping__mdt> listPublicGroupMapping = [SELECT Key__c,
                                                                  Value__c
                                                                  FROM CIRF_Public_Groups_Mapping__mdt 
                                                                  WHERE Data_Group__c = 'PublicGroupMapping' AND
                                                                  Key__c LIKE: key AND
                                                                  Active__c = TRUE];
        System.debug(listPublicGroupMapping);
        if(! listPublicGroupMapping.isEmpty()) {
            return listPublicGroupMapping.get(0).Value__c;
        } else {
            return defaultPlanningGroupName;
        }/*
        if(studio == 'Universal' && productClass == '02 - HIT'){
            return 'RF_NR_Planning_UNI';
        }
        else if(studio == 'Universal' && productClass == '01 - Catalog'){
            return 'Catalog Planning-UNI';
        }
        else if(studio == 'Partners' && productClass == '02 - HIT'){
            return 'RF_NR_Planning_Partners';
        }
        else if(studio == 'Partners' && productClass == '01 - Catalog'){
            return 'Catalog Planning-Partners';
        }
        else if(studio == 'PHE' && productClass == '02 - HIT'){
            return 'RF_NR_Planning_PHE';
        }
        else if(studio == 'PHE' && productClass == '01 - Catalog'){
            return 'Catalog Planning-PHE';
        }
        else if(studio == 'G1200' && productClass == '01 - Catalog'){
            return 'G1200_Planning';
        }
        else if(studio == 'G1200' && productClass == '02- HIT'){
            return 'G1200_Planning';
        }
        else if(studio == 'Cinedigm' && productClass == '02- HIT'){
            return 'Cinedigm_Planning';
        }
        else if(studio == 'Cinedigm' & productClass == '01 - Catalog'){
            return 'Cinedigm_Planning';
        }
        return defaultPlanningGroupName;
        */
    }
}