public class CIRFHeaderTriggerHandler extends TriggerHandler {
    public Static Boolean HeaderRejected = false;
    public static Map<Id, CIRF_Header__c> triggerNewMap;
    public static Map<Id, CIRF_Header__c> triggerOldMap;
    public static List<CIRF_Header__c> triggerNew;
    public static List<CIRF_Header__c> triggerOld;
    
    public static boolean firstTime = true;
    public static boolean Updatedfromheader = true;
    public static boolean reviseCancel = false;
    
    public CIRFHeaderTriggerHandler() {
        triggerNewMap = (Map<Id, CIRF_Header__c>) trigger.newMap;
        triggerOldMap = (Map<Id, CIRF_Header__c>) trigger.OldMap;       
        triggerNew = (List<CIRF_Header__c>) trigger.new;
        triggerOld = (List<CIRF_Header__c>) trigger.old;
    }
    
    public override void beforeUpdate() {
        //HEITCIRF-195
        //performManualApprovalAction();
        incrementRevision();
        performRejectAction();
        
        for (CIRF_Header__c ch : triggerNew) {
            string oldCIRFStatus = triggerOldMap.get(ch.id).CIRF_Status__c;
            //  Scenario 2 - When child CIRF is cancelled, remove reference to Super CIRF
            if (oldCIRFStatus <> ch.CIRF_Status__c && ch.Super_CIRF__c != null && ch.CIRF_Status__c == 'Cancelled') {
                ch.Super_CIRF__c = null;
            }
        }
    }
    public override void afterUpdate() {
        if(Updatedfromheader)
            CIRF_DraftStatus();
        if(firstTime){
            sendDraftEmail();
        }
        
        List<CIRF_Header__c> currentHdr;
        List<CIRF_Header__c> oldHdr;
        List<Id> headerId = new List<Id>();
        List<Id> mergedCIRFHeaderIdList = new List<Id>();
        List<Id> superCIRFHeaderIdList = new List<Id>();
        List<Id> childrenCIRFHeaderIdList = new List<Id>();
        List<Id> cancelCIRFHeaderIdList = new List<Id>();
        List<Id> updChildCIRFHeaderList = new List<Id>();
        Boolean reSubmission = false;
        
        currentHdr = triggerNew;
        oldHdr = triggerOld;
        if(!reviseCancel){
            performManualApprovalAction();
        }
        
        
        checkRIMApproval(); 
        
        //HEITCIRF-84
        generatePricingTasks();
        
        //  Create Material Forecast records
        for(CIRF_Header__c ch : currentHdr)
        {
            String oldCIRFStatus = triggerOldMap.get(ch.Id).CIRF_Status__c;
            String superCIRFId = triggerOldMap.get(ch.Id).Super_CIRF__c;
            system.debug('???ch:  ' + ch);
            //system.debug('oldCIRFStatus: ' + oldCIRFStatus + ' current Status: ' + ch.CIRF_Status__c);
            
            if (oldCIRFStatus == 'Submitted' && ch.cirf_status__c == 'Loaded') {
                boolean split = false;
                CIRFCreateForecastRecords2.CreateForRecords(ch.id, split);
            }
            if (oldCIRFStatus == 'Loaded' && ch.cirf_status__c == 'Cancelled') {
                boolean split = false;
                CIRFCreateForecastRecords2.CreateForRecords(ch.id, split);
            }
            if ((oldCIRFStatus == 'Submitted' || oldCIRFStatus == 'Loaded') && ch.cirf_status__c == 'Merged') {
                boolean split = false;
                CIRFCreateForecastRecords2.CreateForRecords(ch.id, split);
            }
            //  Scenario 1- When a child CIRF is changed and re-submitted
            if (ch.Super_CIRF__c != null && ch.CIRF_Status__c == 'Merged') {
                mergedCIRFHeaderIdList.add(ch.id);
                superCIRFHeaderIdList.add(ch.Super_CIRF__c);
                if (oldCIRFStatus == 'Draft') 
                    reSubmission = true;
                else
                    reSubmission = false;
            }
            //  Scenario 2- When a child CIRF is cancelled
            if (oldCIRFStatus <> ch.CIRF_Status__c && superCIRFId != null && ch.CIRF_Status__c == 'Cancelled') {
                cancelCIRFHeaderIdList.add(ch.id);
                superCIRFHeaderIdList.add(superCIRFId);
            }
            //  Scenario 3 - When a Super CIRF is cancelled
            if (ch.Is_Super_CIRF__c && ch.CIRF_Status__c == 'Cancelled' && oldCIRFStatus <> ch.CIRF_Status__c) {
                updChildCIRFHeaderList.add(ch.Id);
            }
        } 
        
        //  11/18/2018 - AL - HEITCIRF-238 - Update CIRF Material Status and re-perform Merge process
        //  Scenario 1
        if (!mergedCIRFHeaderIdList.isEmpty()) {
            system.debug('Resubmit child CIRF');        
            updateSuperCIRFHeaderStatus(superCIRFHeaderIdList);                                         //  Update Super CIRF Header Status to Draft
            CIRFMaterialTriggerHandler.updateMergedCIRFMaterialStatus(mergedCIRFHeaderIdList);          //  Update Child CIRF Material Status to Merged
            CIRFCorrugateTriggerHandler.updateMergedCIRFCorrugateStatus(mergedCIRFHeaderIdList);        //  Update Child CIRF Corrugate Status to Merged
            //  02/07/2019 - AL - HEITCIRF-715            
            cancelPendingTasks(mergedCIRFHeaderIdList);                                                 //  Cancel Child pending tasks

            if (reSubmission) {
                childrenCIRFHeaderIdList = getchildrenCIRFHeaderIds(superCIRFHeaderIdList);
                CIRFMaterialTriggerHandler.cancelledByTask = true;
                SuperCIRFMergeHelper.remergeCIRFs(superCIRFHeaderIdList, childrenCIRFHeaderIdList);               
            }
        }
        
        //  12/12/2018 - AL -HEITCRF-349
        //  When a child CIRF is cancelled, remove Super CIRF linkage from child, update CIRF Status to Cancelled, and re-perform Merge
        //  Scenario 2
        if (!cancelCIRFHeaderIdList.isEmpty()) {
            childrenCIRFHeaderIdList = getchildrenCIRFHeaderIds(superCIRFHeaderIdList);
            system.debug('Super CIRF: ' + superCIRFHeaderIdList);
            system.debug('Children CIRFs: ' + childrenCIRFHeaderIdList);
            CIRFMaterialTriggerHandler.cancelledByTask = true;
            SuperCIRFMergeHelper.remergeCIRFs(superCIRFHeaderIdList, childrenCIRFHeaderIdList);                      
            updateSuperCIRFHeaderStatus(superCIRFHeaderIdList);
        }
        
        if (!updChildCIRFHeaderList.isEmpty()) {
            removeSuperCIRFRef(updChildCIRFHeaderList);
        }
        
    }
    
    private void sendDraftEmail(){
        firstTime = false;
        EmailTemplate rimET = [Select id from EmailTemplate where name = :Label.CIRF_Header_Revise_Email_Template limit 1];
        for(Id headId : headerDraftIds){
            CIRF_Header__c ch = (CIRF_Header__c) Trigger.newMap.get(headId);
            Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(rimET.Id, userInfo.getUserId(), ch.Id);
            msg.setToAddresses(groupMemberEmails);
            msg.setSaveAsActivity(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
        }
    }
    
    private void incrementRevision(){
        for(CIRF_Header__c ch : (List<CIRF_Header__c>)trigger.new) {
            system.debug('Revision Value:'+ch.Revision__c);
            if(ch.CIRF_Status__c == 'Draft' && ((CIRF_Header__c)trigger.oldMap.get(ch.id)).CIRF_Status__c != 'Draft'){
                ch.Revision__c = ch.Revision__c + 1;
            }
            if(ch.CIRF_Status__c == 'Cancelled' && ((CIRF_Header__c)trigger.oldMap.get(ch.id)).CIRF_Status__c != 'Cancelled'){
                ch.Revision__c = ch.Revision__c + 1;
            }
            else if(ch.CIRF_Status__c != 'Draft'){
                //HEITCIRF-118 -- SJ -- 11/30/2018
                if(ch.Request_Type__c != ((CIRF_Header__c)trigger.oldMap.get(ch.id)).Request_Type__c && UserInfo.getProfileId() != Label.Profile_System_Admins){
                    ch.addError('You can change the Request Type in Draft only');
                }
            } system.debug('Revision Value After:'+ch.Revision__c);
        }
    }
    
    public static List<String> groupMemberEmails;
    public static List<Id> headerDraftIds = new List<Id>();
    
    private void performRejectAction(){
        if(HeaderRejected==false){
            List<Id> chIds = new List<Id>();
            List<Task> tasksToUpdate = new List<Task>();
            List<Id> userIds = new List<Id>();
            for(CIRF_Header__c ch : (List<CIRF_Header__c>)trigger.new) {
                chIds.add(ch.id);
            }
            Map<Id,CIRF_Header__c> cirfoldMap = (Map<Id,CIRF_Header__c>)trigger.oldMap;
            Map<Id,CIRF_Header__c> cirfnewMap = (Map<Id,CIRF_Header__c>)trigger.newMap;
            /*List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
Map<Id,ProcessInstance> proInstance = new Map<Id,ProcessInstance>([SELECT Id,TargetObjectId,(select id from Workitems) FROM ProcessInstance where TargetObjectId in : chIds]);
Map<Id,ProcessInstance> TargetProInstanceMap = new Map<Id,ProcessInstance>();
for(ProcessInstance pi : proInstance.values()){
TargetProInstanceMap.put(pi.TargetObjectId,pi);
}
for(CIRF_Header__c ch : (List<CIRF_Header__c>)trigger.new){


}
System.debug('***'+reqList);
if(reqList!=NULL){
List<Approval.ProcessResult> result2 =  Approval.process(reqList); 
}*/
            Map<Id,CIRF_Header__c> headersMap = new Map<Id,CIRF_Header__c>([select id, Name, OwnerId, CIRF_Name__c, Retailer__c, CIRF_Status__c,Revision__c,(select id from CIRF_Materials__r),RIM_Approval__c from CIRF_Header__c where id IN :chIds]);
            for(CIRF_Header__c ch : (List<CIRF_Header__c>) trigger.new){
                if((ch.isRejected__c == true && ch.isRejected__c != ((CIRF_Header__c)trigger.oldMap.get(ch.id)).isRejected__c)) {
                    System.debug('inside rejected');
                    ch = CIRF_Utility.ReviseCIRF(ch,false);
                    ch.isRejected__c = false;
                    CIRF_Header__c currentHeader = headersMap.get(ch.id);
                    headerDraftIds.add(currentHeader.id);
                    List<Id> relMatIds = new List<Id>();
                    for(CIRF_Material__c cm : currentHeader.CIRF_Materials__r) {
                        relMatIds.add(cm.id);
                    }
                    for(Task tk : [select id, Status, WhatId, isClosed from Task where whatid IN :relMatIds AND isClosed = false]) {
                        tk.Status = 'Completed';
                        tasksToUpdate.add(tk);
                    }
                    userIds.add(currentHeader.OwnerId);
                    for(AccountTeamMember atm : [select accountid, userid from AccountTeamMember where 
                                                 accountid=:currentHeader.Retailer__c AND TeamMemberRole = 'CIRF RIM Team']) {
                                                     if(!userIds.contains(atm.userid)) {
                                                         userIds.add(atm.userid);
                                                     }
                                                 }
                    System.debug('userIds' + userIds);
                    groupMemberEmails = Utility.getUserEmails(userIds);
                    System.debug('groupMemberEmails' + groupMemberEmails);
                    /*Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(rimET.Id, userInfo.getUserId(), currentHeader.Id);
msg.setToAddresses(groupMemberEmails);
msg.setSaveAsActivity(false);
Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});*/
                }
            }
            update tasksToUpdate;
        }
        HeaderRejected = true;
    }
    
    public Static Boolean HeaderExecuted = false;
    //HEITCIRF-195 - Added by SJ 11/02/2018
    private void performManualApprovalAction(){
        List<Id> chIds = new List<Id>();
        Map<Id,CIRF_Header__c> cirfoldMap = (Map<Id,CIRF_Header__c>)trigger.oldMap;
        Map<Id,CIRF_Header__c> cirfnewMap = (Map<Id,CIRF_Header__c>)trigger.newMap;
        for(CIRF_Header__c ch : (List<CIRF_Header__c>)trigger.new) {
            if((ch.RIM_Approval__c==true && ch.RIM_Approval__c != cirfoldMap.get(ch.id).RIM_Approval__c)
               ||(ch.CIRF_Status__c == 'Draft' && cirfoldMap.get(ch.id).CIRF_Status__c== 'Submitted')){
                   chIds.add(ch.id);
               }            
        }
        if(!chIds.isEmpty()){
            List<Id> headerIds = new List<Id>();
            List<CIRF_Material__c> CIRFMaterialsToUpdate = new List<CIRF_Material__c>();
            List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstance> proInstanceList = [SELECT Id,TargetObjectId,(select id from Workitems) FROM ProcessInstance where TargetObjectId in : chIds AND Status = 'Pending'];
            Map<Id,List<ProcessInstance>> TargetProInstanceMap = new Map<Id,List<ProcessInstance>>();
            System.debug(proInstanceList);
            for(ProcessInstance pi : proInstanceList){
                if(!TargetProInstanceMap.containsKey(pi.TargetObjectId)){
                    TargetProInstanceMap.put(pi.TargetObjectId,new List<ProcessInstance>());
                }
                TargetProInstanceMap.get(pi.TargetObjectId).add(pi);
            }
            System.debug('***'+TargetProInstanceMap);
            for(CIRF_Header__c ch : (List<CIRF_Header__c>)trigger.new){
                System.debug(ch.RIM_Approval__c);
                System.debug(ch.RIM_Approval_Reason__c);
                System.debug(TargetProInstanceMap.containsKey(ch.id));
                if(ch.RIM_Approval__c==true && (ch.RIM_Approval_Reason__c != cirfoldMap.get(ch.id).RIM_Approval_Reason__c) && TargetProInstanceMap.containsKey(ch.id)){
                    //for bypassing update restrictions based on header status
                    CIRFMaterialTriggerHandler.allowedCIRFActions = false;
                    CIRFCorrugateTriggerHandler.allowedCIRFActions = false;
                    CIRFCorrugateMaterialTriggerHandler.allowedCIRFActions = false;
                    for(ProcessInstance proInstance : TargetProInstanceMap.get(ch.id)){
                        for(ProcessInstanceWorkitem workItem : proInstance.Workitems){
                            System.debug('for loop');
                            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                            req.setComments('Approving request.');
                            req.setAction('Approve');
                            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                            req.setWorkitemId(workItem.Id);
                            reqList.add(req);
                        }                                 
                    }
                } else if(cirfnewMap.get(ch.id).CIRF_Status__c=='Draft' && cirfoldMap.get(ch.id).CIRF_Status__c== 'Submitted' && TargetProInstanceMap.containsKey(ch.id)){
                    //for bypassing update restrictions based on header status
                    CIRFMaterialTriggerHandler.allowedCIRFActions = false;
                    CIRFCorrugateTriggerHandler.allowedCIRFActions = false;
                    CIRFCorrugateMaterialTriggerHandler.allowedCIRFActions = false;
                    for(ProcessInstance proInstance : TargetProInstanceMap.get(ch.id)){
                        for(ProcessInstanceWorkitem workItem : proInstance.Workitems){
                            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                            req.setComments('Rejecting request.');
                            req.setAction('Reject');
                            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                            req.setWorkitemId(workItem.Id);
                            reqList.add(req);
                        } 
                    }
                }
            }
            System.debug(reqList);
            List<Approval.ProcessResult> result2 =  Approval.process(reqList); 
            
            for(CIRF_Header__c ch : (List<CIRF_Header__c>) trigger.new){
                //scenario 5
                if((ch.RIM_Approval__c == true && ((CIRF_Header__c) trigger.oldMap.get(ch.id)).RIM_Approval__c == false) &&
                   (ch.RIM_Approval_Reason__c == 'RIM Approved CIRF' && 
                    ch.RIM_Approval_Reason__c != ((CIRF_Header__c)trigger.oldMap.get(ch.id)).RIM_Approval_Reason__c)) {
                        headerIds.add(ch.id);
                    }
            }
            List<CIRF_Material__c> relatedCIRFMaterials = [select id, name, CIRF_Header__c, CIRF_Material_Status__c, RIM_Approval__c,
                                                           RIM_Approval_Reason__c from CIRF_Material__c where CIRF_Header__c IN :headerIds
                                                           AND CIRF_Material_Status__c != 'Cancelled'];
            for(CIRF_Material__c cm : relatedCIRFMaterials){
                onRIMApproval(CIRFMaterialsToUpdate, cm);
            }
            update CIRFMaterialsToUpdate;
        }
    }
    
    private void checkRIMApproval(){
        List<Id> headerIds = new List<Id>();
        List<CIRF_Material__c> CIRFMaterialsToUpdate = new List<CIRF_Material__c>();
        for(CIRF_Header__c header : (List<CIRF_Header__c>) trigger.new){
            if((header.RIM_Approval__c == true) &&
               (header.RIM_Approval_Reason__c != '' && header.RIM_Approval_Reason__c != 
                ((CIRF_Header__c)trigger.oldMap.get(header.id)).RIM_Approval_Reason__c)){
                    headerIds.add(header.id);
                }
        }
        List<CIRF_Material__c> relatedCIRFMaterials = [select id, name, CIRF_Header__c, CIRF_Material_Status__c, RIM_Approval__c,
                                                       RIM_Approval_Reason__c from CIRF_Material__c where CIRF_Header__c IN :headerIds
                                                       AND CIRF_Material_Status__c != 'Cancelled'];
        for(CIRF_Material__c cm : relatedCIRFMaterials){
            onRIMApproval(CIRFMaterialsToUpdate, cm);
        }
        update CIRFMaterialsToUpdate;
    }
    private void onRIMApproval(List<CIRF_Material__c> CIRFMaterialsToUpdate, CIRF_Material__c cm){
        cm.RIM_Approval__c = true;
        cm.RIM_Approval_Reason__c = ((CIRF_Header__c) trigger.newMap.get(cm.CIRF_Header__c)).RIM_Approval_Reason__c;
        CIRFMaterialsToUpdate.add(cm);
    }
    
    public static void updateMergedCIRFHeaderStatus(Id SuperCIRFHeaderId, List<Id> ChildrenCIRFHeaderIdList) {
        
        List<CIRF_Header__c> ChildrenCIRFHeaderList = [select id, name, CIRF_Status__c 
                                                       from CIRF_Header__c
                                                       where id in : ChildrenCIRFHeaderIdList];
        
        for (CIRF_Header__c ch : ChildrenCIRFHeaderList) {
            ch.Super_CIRF__c = SuperCIRFHeaderId;
            ch.CIRF_Status__c = 'Merged';
        }
        
        if (!ChildrenCIRFHeaderList.isEmpty()) {
            update ChildrenCIRFHeaderList;
        }
    }
    //HEITCIRF-84
    public  static void generatePricingTasks(){
        Map<Id, CIRF_Header__c> headersforTask = new Map<Id, CIRF_Header__c>();
        Map<Id,CIRF_Header__c> headerIds = new Map<Id,CIRF_Header__c>();
        for(CIRF_Header__c head : (List<CIRF_Header__c>)trigger.new){
            if(head.CIRF_Status__c == 'Loaded' && head.CIRF_Status__c != ((CIRF_Header__c)trigger.oldMap.get(head.id)).CIRF_Status__c){
                headerIds.put(head.id,head);
            }
        }
        if(!headerIds.values().isEmpty()){
            Map<Id, CIRF_Header__c> queriedHeads = new Map<Id, CIRF_Header__c>([select id, Name, Retailer__c, (select id, Promo_Cost__c, Direct_Retail_Price__c from CIRF_Materials__r where Promo_Cost__c != 0 AND Promo_Cost__c != null) from CIRF_Header__c where id in :headerIds.keyset()]);
            for(Id hid : queriedHeads.keyset()){
                CIRF_Header__c curHead = queriedHeads.get(hid);
                for(CIRF_Material__c cmat : curHead.CIRF_Materials__r){
                    if(cmat.Promo_Cost__c != cmat.Direct_Retail_Price__c){
                        headersforTask.put(curHead.id, curHead);
                    }
                }
            }
            System.debug('*** '+headersforTask);
            if(!headersforTask.values().isEmpty()){
                TaskModel.createPricingTask(headersforTask.values());
            }
        }
    }
    
    //  HEITCIRF-335 - AL - 12/9/2018 
    private List<Id> getchildrenCIRFHeaderIds(List<Id> superCIRFHeaderIdList) {
        Map<Id, CIRF_Header__c> childrenCIRFHeaderMap = new Map<Id, CIRF_Header__c>([
            select Id, CIRF_Status__c 
            from CIRF_Header__c       
            where Super_CIRF__c in : superCIRFHeaderIdList]);
        List<Id> childrenCIRFHeaderList = new List<Id>();
        childrenCIRFHeaderList.addAll(childrenCIRFHeaderMap.keySet());
        return childrenCIRFHeaderList;
        
    }
    
    @future
    public static void removeSuperCIRFRef(List<Id> cancelCIRFHeaderIdList) {
        //  HEITCIRF-439 - AL = 12/10/2018
        //  Update Child CIRF Header Status to Submitted when a Super CIRF is cancelled
        Map<Id, CIRF_Header__c> cancelChildCIRFHeaderMap = new Map<Id, CIRF_Header__c>([select id, name, Super_CIRF__c 
                                                                                        from CIRF_Header__c
                                                                                        where Super_CIRF__c in : cancelCIRFHeaderIdList
                                                                                        and CIRF_Status__c != 'Cancelled']);
        for (CIRF_Header__c cch : cancelChildCIRFHeaderMap.values()) {
            cch.Super_CIRF__c = null;
            cch.CIRF_Status__c = 'Submitted';
        }
        
        if (!cancelChildCIRFHeaderMap.isEmpty()) {
            update cancelChildCIRFHeaderMap.values();
            updateChildCIRFMatStatus(cancelChildCIRFHeaderMap.keySet());
        }
    }
    
    private static void updateSuperCIRFHeaderStatus(List<Id> superCIRFHeaderIdList) {
        //  HEITCIRF-335 - AL - 12/11/2018
        //  Bring Super CIRF Header Status back to Draft when a child CIRF is re-submitted
        List<CIRF_Header__c> updCIRFHeaderList = [select id, CIRF_Status__c, Revision__c from CIRF_Header__c 
                                                  where Id in : superCIRFHeaderIdList
                                                  and CIRF_Status__c <> 'Draft' ];
        for (CIRF_Header__c ch : updCIRFHeaderList) {
            ch.CIRF_Status__c = 'Draft';
            //ch.Revision__c++;
        }  
        
        update updCIRFHeaderList;                                         
    }
    
    public static void updateChildCIRFMatStatus (Set<Id> childCIRFHeaderIdSet) {
        //  HEITCIRF-439 - AL - 12/11/2018
        //  Update children CIRF Material Status to "Submitted" when Super CIRF header is "Cancelled"
        List<Id> ChildCIRFHeaderIdList = new List<Id>();
        ChildCIRFHeaderIdList.addAll(childCIRFHeaderIdSet);
        List<CIRF_Material__c> childCIRFMatList = SuperCIRFMergeHelper.getCIRFMaterials(childCIRFHeaderIdList);
        for (CIRF_Material__c cm : childCIRFMatList) {
            cm.CIRF_Material_Status__c = 'Submitted';
        }
        if (!childCIRFMatList.isEmpty()) 
            update childCIRFMatList;
    }
    
    public void CIRF_DraftStatus(){
        //  HEITCIRF-344 - Sravanthi - 12/20/2018
        System.debug('****DraftStatusMethod');
        try{
           List<CIRF_Corrugate__c> corglst=new List<CIRF_Corrugate__c>();
            for(CIRF_Corrugate__c corg : [SELECT CIRF_Header__c,Corrugate_Name__c,Corrugate_Status__c,SAP_Corrugate_Changes_Made__c FROM CIRF_Corrugate__c WHERE CIRF_Header__c IN : triggerNewMap.keyset()])
            {
                system.debug('corg'+corg);
                system.debug('corg header status'+triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c);
                if(triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Cancelled') //added by Kalyani - to set all corrugate status to cancelled irrespective of corg
                    corg.Corrugate_Status__c='Cancelled';
                else if((triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Draft' && corg.Corrugate_Name__c== null || (triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Cancelled' && corg.Corrugate_Name__c== null)))
                    corg.Corrugate_Status__c='Draft';
                else if((triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Draft' || triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Loaded') && corg.Corrugate_Name__c != null)
                            corg.Corrugate_Status__c='Linked';
                else if(triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Loaded' && corg.Corrugate_Name__c == null)
                            corg.Corrugate_Status__c='Loaded';
                 else if(triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Merged' || triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Complete')
                            corg.Corrugate_Status__c=triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c;
                else if(triggerNewMap.get(corg.CIRF_Header__c).CIRF_Status__c =='Cancelled' && corg.Corrugate_Name__c != null)
                            corg.Corrugate_Status__c='Cancelled';
                corglst.add(corg);
            }
           
            if(corglst.size() >0)
                CIRFCorrugateTriggerHandler.UpdatedFromCorMat = false;
            system.debug('corglst=='+corglst);
                update corglst; 
        }catch(exception ex){
            system.debug('Error line :: '+ex.getLineNumber()+'==Error Message=='+ex.getMessage());
        }
    }

    //  HEITCIRF-715
    public static void cancelPendingTasks(List<Id> CIRFHeaderIdList) {
        Map<Id, CIRF_Material__c> CIRFMatMap = new Map<Id, CIRF_Material__c>([select id, name 
                                                                            from CIRF_Material__c 
                                                                            where CIRF_Header__c in : CIRFHeaderIdList]);

        List<Task> pendingTaskList = [select id, status from Task 
                                        where (whatId in : CIRFMatMap.values()
                                        or whatId in : CIRFHeaderIdList)
                                        and status not in ('Completed','Cancelled')];

        for (Task t : pendingTaskList) {
            t.Status = 'Cancelled';
        }

        if (!pendingTaskList.isEmpty())
            update pendingTaskList;                                
    }
    
}