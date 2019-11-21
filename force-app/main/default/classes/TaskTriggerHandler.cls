public class TaskTriggerHandler extends TriggerHandler {
    /*****************************************************************
    Created on:  10/10/2018
    Created by:  Ann Luong
    Ticket:  HEITCIRF-170
    ******************************************************************/  
    list<Task> newTasklist = (List<Task>) trigger.new;
    list<Task> oldTasklist = (List<Task>) trigger.old;
    map<Id, Task> newTaskmap = (Map<Id, Task>) trigger.newMap;
    map<Id, Task> oldTaskmap = (Map<Id, Task>) trigger.oldMap;
    public static Map<Id,Task> oldTaskCustomFields;
    public static Map<Id,Material__c> materialRecords;
    
    String recordTypeId;
    String recordTypeName;
    list<Task> currTaskList;
    public static final string CM_APPROVAL_REASON = 'Customer Marketing Approved Exception';
    public static final string PLANNING_APPROVAL_REASON = 'Planning Approved Exception';   
    
    public Static boolean taskTriggerExecuted = false;
    
    public TaskTriggerHandler() {
        if (trigger.isInsert || trigger.isUpdate) {
            recordTypeId = (String) newTasklist[0].RecordTypeId;
            currTaskList = newTaskList;
        }
        else {
            recordTypeId = (String) oldTasklist[0].RecordTypeId;
            currTaskList = oldTaskList;
        }
        
        recordTypeName = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }

    public override void beforeInsert() 
    {
        updateTotalQty();
    }
    
    public override void beforeUpdate() {
        validateTaskRejection();
        //oldTaskCustomFields = getTaskCustomFields((List<Task>)trigger.new);
        materialRecords = getMaterialRecords((List<Task>)trigger.new);
    }
    
    
    public override void afterInsert() {
        //  AL - 10/10/2018 - HEITCIRF-170
        switch on recordTypeName {
            when 'CIRF Exception Approval' {
                if(!taskTriggerExecuted){
                //processException(currTaskList);
                //checkIfApproved();
                }
                //updateCIRFOpenTaskCount(currTaskList);
            }
            when 'CIRF General Task','CIRF Split Material','CIRF Inventory Request','CIRF Split Forecast' {
               system.debug('RT: ' + recordTypeName);
                //updateCIRFOpenTaskCount(currTaskList);
            }
            when else {
                system.debug('RT: Other');
                //updateVProject(currTaskList);
            }
        }
    }
    
    public override void afterUpdate() 
    {
        switch on recordTypeName 
        {
            when 'CIRF Exception Approval' 
            {
                system.debug('ExceptionList: ' + currTaskList);
                if(!taskTriggerExecuted){
                processException(currTaskList);
                //checkIfApproved();
                }
                //updateCIRFOpenTaskCount(currTaskList);
            }
            when 'CIRF General Task','CIRF Split Material','CIRF Inventory Request','CIRF Split Forecast' {
                system.debug('RT: ' + recordTypeName);
                updateSplitForecastField();
                validateInventoryTask();        

                //UpdateCIRFMaterialInventory();
                //updateCIRFOpenTaskCount(currTaskList);   
                        
            }
            when else 
            {
                system.debug('RT: Other');
                //
                //updateVProject(currTaskList);
            }
        }


    } // end afterUpdate
    
    public override void afterDelete() {

         switch on oldTasklist[0].RecordType.Name {
            when 'CIRF General Task','CIRF Split Material','CIRF Exception Approval','CIRF Inventory Request','CIRF Split Forecast' {
                system.debug('RT: ' + recordTypeName);
                updateCIRFOpenTaskCount(currTaskList);
            }
            when else {
                system.debug('RT: Other');
                //updateVProject(currTaskList);
            }
        }   
    }
    @TestVisible
    private void updateCIRFOpenTaskCount(List<Task> currTaskList) {
        Set<Id> CIRFHeaderIdSet = new Set<Id>();
        for (Task t : currTaskList) {
            CIRFHeaderIdSet.add(t.CIRF_Header__c);
        }

        List<Task> openTaskList = [select id, subject, status, cirf_header__c from Task where CIRF_Header__c in: CIRFHeaderIdSet and status <> 'Completed'];

        Map<Id, CIRF_Header__c> updCIRFHeaderMap = new Map<Id, CIRF_Header__c>([select id, Open_Tasks__c from CIRF_Header__c where id in: CIRFHeaderIdSet]);

        AggregateResult[] openTasksByHeader   = [SELECT CIRF_Header__c, count(Id) taskCount
                                              FROM Task
                                              where CIRF_Header__c in : CIRFHeaderIdSet
                                              and Status <> 'Completed'
                                              and CIRF_Header__c <> null
                                              GROUP BY CIRF_Header__c];

        for (AggregateResult ar : openTasksByHeader)  {
            CIRF_Header__c ch = new CIRF_Header__c();
            ch.Id = (Id) ar.get('CIRF_Header__c');
            ch.Open_Tasks__c = (Decimal) ar.get('TaskCount');
            updCIRFHeaderMap.get(ch.Id).Open_Tasks__c = ch.Open_Tasks__c;
            system.debug('CIRF_Header__c: ' + ar.get('CIRF_Header__c'));
        }

        update updCIRFHeaderMap.values();        

    }

    private void validateTaskRejection(){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CIRF_Exception_Approval').getRecordTypeId();

        for(Task t : newTasklist){
            System.debug('before update');
            System.debug(t.Status);
            System.debug(trigger.isUpdate);
            System.debug(t.status != oldTaskmap.get(t.Id).status);
            if(t.RecordTypeId == recordTypeId && (t.Status == 'Rejected' && (Trigger.isInsert || (trigger.isUpdate && t.status != oldTaskmap.get(t.Id).status)))  && (Trigger.isInsert || (Trigger.isUpdate && t.CIRF_Alternate_Qty__c == OldTaskMap.get(t.Id).CIRF_Alternate_Qty__c && t.CIRF_Alternate_Replen_Units__c == OldTaskMap.get(t.Id).CIRF_Alternate_Replen_Units__c && t.Remove_from_Promotion__c == OldTaskMap.get(t.Id).Remove_from_Promotion__c && t.Material__c == OldTaskMap.get(t.Id).Material__c) || 
                                                                           (t.CIRF_Alternate_Qty__c == null && t.CIRF_Alternate_Replen_Units__c == null && !t.Remove_from_Promotion__c && t.Material__c == null))){
                t.addError('You actually have to change something to reject it...');
            }
        }
    }
    /*private void updateVProject(List<Task> currTaskList) {
    //Get the v-Project Ids associated to trigger.new
        Set<Id> vId = new Set<Id>();
        Schema.sObjectType vType = v_Project_Request__c.sObjectType;
        List<Task> tList = new List<Task>();                                 //moved list to here for 101 error 04/10/2018
        List<v_Project_Request__c> vList = new List<v_Project_Request__c>(); //moved list to here for 101 error 04/10/2018
          
        for (Task t : currTaskList){          
            if(t.WhatId != NULL && t.WhatId.getSObjectType() == vType) 
                vId.add(t.whatId);
        }

        //Get the Tasks related to those v-Projects
        if (vId.size() >0) { //Added for 101 error 04/10/2018
            tList = [Select Id, whatId, Status from Task WHERE (whatId IN :vId AND Status <> 'Completed')]; //changed for 101 error 04/10/2018
            //construct List to put task counts on
            vList = [Select Id, Active_Task_Count__c from v_Project_Request__c WHERE Id IN :vId]; //changed for 101 error 04/10/2018
        }
        //Iterate through the v-Projects and Tasks to add to the count on the v-Project
        if (vList.size() > 0) { //Added for 101 error 04/10/2018
            for (v_Project_Request__c v : vList){
                //Reset count to zero
                v.Active_Task_Count__c = 0;
        
                //increment count on v-Project
                if (tList.size() > 0) { //Added for 101 error 04/10/2018
                    for(Task t: tList){
                        if(t.whatId == v.Id){
                            v.Active_Task_Count__c = v.Active_Task_Count__c +1;
                        }
                    }
                }
            }
        }
        vProjectUtility.shouldExecute = FALSE;
        if (vList.size() > 0) { //Added for 101 error 04/10/2018
            update vList;
        }
    }*/
    /*private void checkIfApproved() {
        Id taskExceptionRecordtypeId = [select id, name from recordtype where name = 'CIRF Exception Approval'].id;
        List<Task> approvedTasks = new List<Task>();
        List<Task> rejectedTasks = new List<Task>();
        for(Task tk : (List<Task>)trigger.new) {
            if(tk.RecordTypeId == taskExceptionRecordtypeId) {
                if(tk.Status == 'Approved' && ((Task)trigger.oldMap.get(tk.id)).Status != 'Approved') {
                    approvedTasks.add(tk);
                }
                else if(tk.Status == 'Rejected' && ((Task)trigger.oldMap.get(tk.id)).Status != 'Rejected') {
                    rejectedTasks.add(tk);
                    System.debug('2');
                }
            }
        }
        if(!approvedTasks.isEmpty()){
            approveTask(approvedTasks);
        }
        if(!rejectedTasks.isEmpty()){
            rejectTask(rejectedTasks);
        }
    }*/
    
    public static void processException(List<Task> currTaskList) {

        system.debug('currTaskList: ' + currTaskList);

        List<Task> approvedTaskList = new List<Task>();
        List<Task> rejectedTaskList = new List<Task>();

        for (Task t : currTaskList) {
            if (t.status == 'Approved' && ((Task)trigger.oldMap.get(t.id)).Status != 'Approved'){
                approvedTaskList.add(t);
            }
            else if (t.status == 'Rejected' && ((Task)trigger.oldMap.get(t.id)).Status != 'Rejected'){
                rejectedTaskList.add(t);
                System.debug(t.Material__c);
                System.debug(((Task)trigger.oldMap.get(t.id)).Material__c);
            }
        }

        if (!approvedTaskList.isEmpty())
            approveTask(approvedTaskList);
        
        if (!rejectedTaskList.isEmpty())
            rejectTask(rejectedTaskList);
    }

    private static void approveTask(List<Task> approvedTasks) {
        Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
        Map<Id,CIRF_Material__c> taskCmatMap = getRelatedCIRFMaterialMap(approvedTasks);
        //Map<Id,Task> taskCustomFields = getTaskCustomFields(approvedTasks);
        List<Task> tasksToUpdate = new List<Task>();
        for(Task tk : approvedTasks) {
            CIRF_Material__c currentCIRFMaterial = taskCmatMap.get(tk.id);
            if(tk.Type == 'Customer Marketing') {
                currentCIRFMaterial.Customer_Marketing_Approval__c = true;
                currentCIRFMaterial.Customer_Marketing_Approval_Reason__c = 'Customer Marketing Approved Exception';
                //currentCIRFMaterial.Exception_Start_Date__c = (taskCustomFields.get(tk.id)).CIRF_Exception_Start_Date__c;
                currentCIRFMaterial.Exception_Start_Date__c = tk.CIRF_Exception_Start_Date__c;
                //currentCIRFMaterial.Exception_End_Date__c = (taskCustomFields.get(tk.id)).CIRF_Exception_End_Date__c;
                currentCIRFMaterial.Exception_End_Date__c = tk.CIRF_Exception_End_Date__c;
                currentCIRFMaterial.Exception_Type__c = tk.CIRF_Exception_Type__c;
                CIRFMaterialsToUpdate.put(currentCIRFMaterial.id, currentCIRFMaterial);
            }
            else if(tk.Type == 'Planning') {
                currentCIRFMaterial.Planning_Approval__c = true;
                currentCIRFMaterial.Planning_Approval_Reason__c = 'Planning Approved Exception';
                //currentCIRFMaterial.Exception_Start_Date__c = (taskCustomFields.get(tk.id)).CIRF_Exception_Start_Date__c;
                currentCIRFMaterial.Exception_Start_Date__c = tk.CIRF_Exception_Start_Date__c;
                //currentCIRFMaterial.Exception_End_Date__c = (taskCustomFields.get(tk.id)).CIRF_Exception_End_Date__c;
                currentCIRFMaterial.Exception_End_Date__c = tk.CIRF_Exception_End_Date__c;
                currentCIRFMaterial.Exception_Type__c = tk.CIRF_Exception_Type__c;
                CIRFMaterialsToUpdate.put(currentCIRFMaterial.id, currentCIRFMaterial);
            }
            if(tk.Description != null){  
                if(currentCIRFMaterial.Comments__c == null){
                    currentCIRFMaterial.Comments__c = tk.Description;                
                }else{
                currentCIRFMaterial.Comments__c += '\n' +tk.Description;                
                }
                CIRFMaterialsToUpdate.put(currentCIRFMaterial.id, currentCIRFMaterial);
            }
            
            Task newTask = new Task(id=tk.id);
            newTask.Status = 'Completed';
            tasksToUpdate.add(newTask);            
        }
        update tasksToUpdate;
        Update CIRFMaterialsToUpdate.values();
    }
    
    //SJ - Same as approveTask() method
    /*public static void updCIRFMaterial(List<Task> cmApprovalTaskList) {
        Map<Id, Task> cmApprovalTaskMap = new Map<Id, Task>();
        List<CIRF_Material__c> cmatUpdList = new List<CIRF_Material__c>();
        List<Id> taskIdList = new List<Id>();

        for (Task t : cmApprovalTaskList) {
            cmApprovalTaskMap.put(t.WhatId, t);
        }
        if (cmApprovalTaskMap != null)
            for (Id i : cmApprovalTaskMap.keySet() ) {
                CIRF_Material__c cmat = new CIRF_Material__c();
                cmat.id = i;
                if (cmApprovalTaskMap.get(i).Type == 'Customer Marketing') {
                    cmat.Customer_Marketing_Approval__c = true;
                    cmat.Customer_Marketing_Approval_Reason__c = CM_APPROVAL_REASON;
                }
                else {
                    cmat.Planning_Approval__c = true;
                    cmat.Planning_Approval_Reason__c = PLANNING_APPROVAL_REASON;
                }
                cmat.Exception_Type__c = cmApprovalTaskMap.get(i).CIRF_Exception_Type__c;
                cmat.Exception_Start_Date__c = cmApprovalTaskMap.get(i).CIRF_Exception_Start_Date__c;
                cmat.Exception_End_Date__c = cmApprovalTaskMap.get(i).CIRF_Exception_End_Date__c;
                cmatUpdList.add(cmat);
                taskIdList.add(cmApprovalTaskMap.get(i).Id);
            }
            if (!cmatUpdList.isEmpty() && cmatUpdList.size() > 0)  {
                update cmatUpdList;
                System.debug('++++cmatUpdList '+cmatUpdList);
                //CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(cmatUpdList);
                updTaskToCompleted(taskIdList);
            }

    }*/

    @future
    public static void updTaskToCompleted(List<Id> taskIdList) {
        system.debug('updTaskToCompleted: ' + taskIdList);
        List<Task> taskList = [select id, Status from Task where id in :taskIdList];
        for (Task t : taskList) {
            t.Status = 'Completed';
        }
        update taskList;
    }
    
    public static Boolean exc;
    private static void rejectTask(List<Task> rejectedTasks) {
        System.debug('Rejection method');
        List<Id> headerIds = new List<Id>();
        Map<Id,CIRF_Header__c> headerUpdateMap = new Map<Id,CIRF_Header__c>();
        Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
        Map<Id,CIRF_Material__c> taskCmatMap = getRelatedCIRFMaterialMap(rejectedTasks);
       //Map<Id,Task> taskCustomFields = getTaskCustomFields(rejectedTasks);
        List<Task> tasksToUpdate = new List<Task>();
        Map<Id,Task> relTasksToUpdate = new Map<Id,Task>();
        EmailTemplate et=[Select id from EmailTemplate where name = 'CIRF Material Removed from Promotion' limit 1];
        String matStatus = '';
        for(Task tk : rejectedTasks) {
            exc = false;
            system.debug('for loop');
            Task newTask = new Task(id=tk.id);
            CIRF_Material__c currentCIRFMaterial = taskCmatMap.get(tk.id);
            //Task currentTask = taskCustomFields.get(tk.id);
            //Task oldTaskFields = oldTaskCustomFields.get(tk.id);
            Material__c mat = materialRecords.get(tk.Material__c);
            System.debug(mat);
            if(mat!=null){
                if(currentCIRFMaterial.CIRF_Header__r.Territory__c == 'US'){
                    matStatus = (mat.CIRF_US_D_Chain_Spec__c).subString(0,2);
                }
                else{
                    matStatus = (mat.CIRF_CDN_D_Chain_Spec__c).subString(0,2);
                }
            }
            if(tk.Remove_from_Promotion__c == true) {
                System.debug('1');
                checkForCorrugateMaterial(tk,currentCIRFMaterial);
                newTask.CIRF_Rejection_Reason__c = 'Remove from Promotion';
                newTask.Status = 'Completed';
                List<String> groupMemberEmails = Utility.getUserEmails(new List<Id>{currentCIRFMaterial.CIRF_Header__r.OwnerID});
                Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(et.Id, userInfo.getUserId(), currentCIRFMaterial.Id);
                msg.setToAddresses(groupMemberEmails);
                msg.setSaveAsActivity(false);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
            }
            currentCIRFMaterial.CIRF_Material_Status__c = 'Cancelled';
            CIRFMaterialTriggerHandler.cancelledByTask = true;
            closeTasks(relTasksToUpdate, currentCIRFMaterial);
            List<String> matStatusValues = new List<String>{'AC','RP','NR','FR','AA','NA'};
            System.debug(tk.Material__c);
            System.debug(tk.CIRF_Current_Material_Id__c);
            System.debug(tk.Material__c == tk.CIRF_Current_Material_Id__c);
            //HEITCIRF-641
            if(tk.Material__c != null && tk.Material__c == tk.CIRF_Current_Material_Id__c){
                System.debug('inside if');
                exc = true;
                trigger.newMap.get(tk.id).addError('Old Material & Alternate Material are Same!');
            }
            if(tk.Material__c != null && tk.Material__c != tk.CIRF_Current_Material_Id__c && matStatus != null && (!matStatusValues.contains(matStatus))) {
                exc = true;
                trigger.newMap.get(tk.id).addError('You cannot select this Alternate Material due to its forbidden status! Beware!');
            }
            if(tk.Material__c != null && tk.Material__c != tk.CIRF_Current_Material_Id__c) {
                System.debug('2');
                newTask.CIRF_Rejection_Reason__c = 'Provide Alternate Material';
                currentCIRFMaterial.CIRF_Material_Status__c = 'Draft';
                closeTasks(relTasksToUpdate, currentCIRFMaterial);
                //According to HEITCIRF-641
                if(matStatus != null && matStatusValues.contains(matStatus)){
                    checkMaterialLookupFilter(mat,tk,currentCIRFMaterial);
                    checkDuplicateMaterial(mat,tk,currentCIRFMaterial);
                    System.debug('2-1');
                    newTask.Status = 'Completed';
                    //
                    //newTask.CIRF_Current_Material_Id__c = tk.Material__c;
                    //newTask.MaterialDescription_SmartSheet__c = mat.Name;
                    //newTask.Material_Number__c = mat.Material_Number__c;
                    //
                    currentCIRFMaterial.CIRF_Material_Status__c = 'Draft';
                    //HEITCIRF-182 - update in Dark Red
                    currentCIRFMaterial.Material_Name__c = tk.Material__c;
                    closeTasks(relTasksToUpdate, currentCIRFMaterial);
                    currentCIRFMaterial = routeBackToCreator(tk, currentCIRFMaterial, newTask);
                }
            }
            if(tk.CIRF_Alternate_Replen_Units__c >= 0 || tk.CIRF_Alternate_Qty__c >= 0){
                System.debug('3');
                newTask.CIRF_Rejection_Reason__c = 'Adjust Quantity';
                newTask.Status = 'Completed';
                currentCIRFMaterial.CIRF_Material_Status__c = 'Draft';
                //HEITCIRF-182 - updates in Dark Red
                if(tk.CIRF_Alternate_Replen_Units__c != null){
                    currentCIRFMaterial.Replen_Units__c = tk.CIRF_Alternate_Replen_Units__c;
                }
                if(tk.CIRF_Alternate_Qty__c != null){
                    //SJ - HEITCIRF-640 - As per Michelle Cua's comment
                    currentCIRFMaterial.Units_to_Order__c = tk.CIRF_Alternate_Qty__c;
                    //currentCIRFMaterial.On_Hand_Qty__c = tk.CIRF_Alternate_Qty__c;
                }
                
                CIRF_Header__c head = new CIRF_Header__c(Id=tk.CIRF_Header__c);
                head.RIM_Approval__c = false;
                head.RIM_Approval_Reason__c = null;
                if(exc == false){
                    headerUpdateMap.put(head.id,head);
                }
                closeTasks(relTasksToUpdate, currentCIRFMaterial);
                currentCIRFMaterial = routeBackToCreator(tk, currentCIRFMaterial, newTask);
            }
            if(exc == false){
                tasksToUpdate.add(newTask);
            }
            if(tk.Description != null){
                if(currentCIRFMaterial.Comments__c == null){
                    currentCIRFMaterial.Comments__c = '';
                    currentCIRFMaterial.Comments__c += tk.Description;
                }
                else{
                    currentCIRFMaterial.Comments__c += '.  ' +tk.Description;
                }
            }
            if(exc == false){
                CIRFMaterialsToUpdate.put(currentCIRFMaterial.id, currentCIRFMaterial);
            }
        }
        if(!tasksToUpdate.isEmpty() && exc == false){
            update tasksToUpdate;
        }
        if(!relTasksToUpdate.values().isEmpty() && exc == false){
            update relTasksToUpdate.values();
        }
        if(!CIRFMaterialsToUpdate.values().isEmpty() && exc == false){
            update CIRFMaterialsToUpdate.values();
        }
        if(!headerUpdateMap.values().isEmpty() && exc == false){
            update headerUpdateMap.values();
        }
    }
    @TestVisible
    private static void checkMaterialLookupFilter(Material__c mat, Task tk, CIRF_Material__c cmat) {
        /*System.debug(mat.Deletion_Flag__c);
        System.debug(mat.RecordType.Name);
        System.debug(mat.Material_Type__c);
        System.debug(mat.Item_Type__c);
        System.debug(mat.Territory__c.contains(cmat.CIRF_Header__r.Territory__c));
        System.debug(mat.Material_Number__c);
        System.debug(mat.Material_Status__c);*/
        if(!(mat.Deletion_Flag__c == false && mat.RecordType.Name != 'Update' && (mat.Material_Type__c != null && mat.Material_Type__c == 'FERT') && (mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)') && (mat.Territory__c != null && mat.Territory__c.contains(cmat.CIRF_Header__r.Territory__c)) && mat.Material_Number__c != '' && mat.Material_Status__c == 'Processed in SAP')){
            System.debug('inside');
            exc = true;
            trigger.newMap.get(tk.id).addError('The Alternate Material does not match the Filter Criteria');
        }
    }
    
    @TestVisible
    private static void checkDuplicateMaterial(Material__c mat, Task tk, CIRF_Material__c cmat) {
        List<CIRF_Material__c> dupList = [select id from CIRF_Material__c where Material_Name__c = :mat.id AND CIRF_Header__c = :cmat.CIRF_Header__c];
        if(dupList.size()!=0){
            System.debug('inside dup');
            exc = true;
            trigger.newMap.get(tk.id).addError('This material is already used under same header');
        }
    }
    
    @TestVisible
    private static void checkForCorrugateMaterial(Task tk, CIRF_Material__c cmat) {
        List<CIRF_Corrugate_Material__c> corMats = [select id from CIRF_Corrugate_Material__c where CIRF_Material__c = :cmat.id AND CIRF_Corrugate__r.CIRF_Header__c = :cmat.CIRF_Header__c];
        if(corMats.size()!=0){
            System.debug('inside cormat found');
            exc = true;
            trigger.newMap.get(tk.id).addError('Material cannot be rejected because it is in a corrugate. Please reach out to the requester to revise the CIRF');
        }
    }
    
    @TestVisible
    private static Map<Id,Task> getTaskCustomFields(List<Task> approvedTasks) {
        List<Id> taskIds = new List<Id>();
        for(Task tk : approvedTasks) {
            taskIds.add(tk.Id);
        }
        Map<Id,Task> customFields = new Map<Id,Task>([SELECT Id, Material__c, CIRF_Alternate_Replen_Units__c, CIRF_Alternate_Qty__c, CIRF_Exception_Type__c, CIRF_Exception_End_Date__c, 
                                                      CIRF_Exception_Start_Date__c, CIRF_Current_Material_Id__c, Material__r.Material_Status__c FROM Task where id IN :taskIds]);
        return customFields;
    }
    @TestVisible
    private static Map<Id,Material__c> getMaterialRecords(List<Task> approvedTasks){
        List<Id> matIds = new List<Id>();
        for(Task tk : approvedTasks) {
            if(tk.Material__c != null && tk.Material__c != ((Task)trigger.oldMap.get(tk.id)).Material__c){
                matIds.add(tk.Material__c);
            }
        }
        Map<Id,Material__c> matList = new Map<Id,Material__c>([select id, Name, Territory__c, Deletion_Flag__c, Item_Type__c, Material_Type__c, RecordType.Name, Material_Number__c, CIRF_US_D_Chain_Spec__c,CIRF_CDN_D_Chain_Spec__c, Material_Status__c from Material__c where id IN :matIds]);
        return matList;
    }
    
    private static void closeTasks(Map<Id,Task> tasksToUpdate, CIRF_Material__c cmat) {
        for(Task tk : [select id, Status, WhatId, isClosed from Task where whatid = :cmat.id AND isClosed = false]) {
            tk.Status = 'Completed';
            tasksToUpdate.put(tk.id,tk);
        }
    }
    
    private static CIRF_Material__c routeBackToCreator(Task tsk, CIRF_Material__c cmat, Task newTask) {
        if(tsk.Type == 'Customer Marketing') {
            cmat.Customer_Marketing_Approval__c = true;
            cmat.Customer_Marketing_Approval_Reason__c = newTask.CIRF_Rejection_Reason__c;
        }
        else if(tsk.Type == 'Planning') {
            cmat.Planning_Approval__c = true;
            cmat.Planning_Approval_Reason__c = newTask.CIRF_Rejection_Reason__c;
            cmat.Creator_Approval__c = false;
            cmat.CIRF_Material_Status__c = 'Draft';
            
            EmailTemplate et=[Select id from EmailTemplate where name = 'CIRF Material Exception Not Granted' limit 1];
            List<String> groupMemberEmails = Utility.getUserEmails(new List<Id>{cmat.CIRF_Header__r.OwnerID});
            Messaging.SingleEmailMessage msg = Messaging.renderStoredEmailTemplate(et.Id, userInfo.getUserId(), cmat.Id);
            msg.setToAddresses(groupMemberEmails);
            msg.setSaveAsActivity(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
        }
        
        /*
//email to header.CreatedBy
EmailTemplate et=[Select id from EmailTemplate where name = 'CIRF Material Exception Not Granted' limit 1];
Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
mail.setTargetObjectIds(new List<Id>{cmat.CIRF_Header__r.OwnerID});
mail.setSenderDisplayName('System Admin');
mail.setTemplateId(et.id);
mail.setSaveAsActivity(false);
Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(new Messaging.MassEmailMessage[]{mail});
*/
        
        return cmat;
    }
    
    /*public static void processReject(List<Task> rejectedTaskList) {

    }*/
    
    private static Map<Id,CIRF_Material__c> getRelatedCIRFMaterialMap(List<Task> approvedTasks) {
        List<Id> cmatIds = new List<Id>();
        for(Task tk : approvedTasks) {
            cmatIds.add(tk.WhatId);
        }
        Map<Id,CIRF_Material__c> relatedCIRFMaterialsMap = 
            new Map<Id,CIRF_Material__c>([select id,On_Hand_Qty__c,Replen_Units__c,Material_Description__c,Material_Status__c,Customer_Marketing_Approval__c,Customer_Marketing_Approval_Reason__c,
                                          Exception_Start_Date__c, Exception_End_Date__c, Exception_Type__c, Planning_Approval__c,CIRF_Header__c,
                                          Planning_Approval_Reason__c, CIRF_Header__r.OwnerID,CIRF_Header__r.Territory__c, Comments__c from CIRF_Material__c where id IN :cmatIds]);
        Map<Id,CIRF_Material__c> taskCmatMap = new Map<Id,CIRF_Material__c>();
        for(Task tk : approvedTasks) {
            taskCmatMap.put(tk.id, relatedCIRFMaterialsMap.get(tk.WhatId));
        }
        return taskCmatMap;
    }
    
    /*public Static void UpdateCIRFMaterialInventory(){
        Id CIRFInventoryRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Inventory Request').getRecordTypeId();
        List<Id> CIRFMaterialIds = new List<Id>();
        Map<Id,Task> TaskOldMap = (Map<Id,Task>)Trigger.oldMap;
        Map<Id,Task> MaterialTaskMap = new Map<Id,Task>();
        
        for(Task t : (List<Task>)Trigger.new){
            if(t.RecordTypeId == CIRFInventoryRecordType && t.CIRF_Material_On_Hand_Qty__c != 0 && t.CIRF_Material_On_Hand_Qty__c != TaskOldMap.get(t.Id).CIRF_Material_On_Hand_Qty__c && String.valueOf(t.WhatId).substring(0,3) == CIRF_Material__c.sobjecttype.getDescribe().getKeyPrefix()){
                CIRFMaterialIds.add(t.WhatId);
                MaterialTaskMap.put(t.WhatId,t);
            }
        }
        
        List<CIRF_Material__c> CIRFMaterialList = [Select Id, Name,CIRF_Header__c,Material_Description__c,Exception_Type__c,Material_Name__c,Material_Number__c,Material_Status__c, Total_Order_Qty__c,Creator_Approval__c, Planning_Approval__c,material_label_code__c from CIRF_Material__c where id =:CIRFMaterialIds];
        List<CIRF_Material__c> SKUExceptionCallList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> CIRFMaterialUpdateList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cm : CIRFMaterialList){
            if(MaterialTaskMap.containsKey(cm.Id)){
                Task RelatedTask = MaterialTaskMap.get(cm.Id);
                if(RelatedTask.CIRF_Material_On_Hand_Qty__c < cm.Total_Order_Qty__c ){
                    SKUExceptionCallList.add(cm);
                } else {
                    cm.Material_to_Forecast__c = cm.Material_Name__c;
                    cm.Planning_Approval__c = true;
                    cm.Planning_Approval_Reason__c = 'Status = SD/DS and sufficient Inventory';
                    cm.Customer_Marketing_Approval__c = true;
                    cm.Customer_Marketing_Approval_Reason__c = 'Status = SD/DS and sufficient Inventory';
                    CIRFMaterialUpdateList.add(cm);
                }
            }
        }
        Update CIRFMaterialUpdateList;
        CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(SKUExceptionCallList);
    }*/
    
     private void updateTotalQty() {
        List<Id> cmatIds = new List<Id>();
        Id CIRFInventoryRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Inventory Request').getRecordTypeId();
        for(Task tsk : (List<Task>) trigger.new) {
            if(tsk.RecordTypeId == CIRFInventoryRecordType){
                cmatIds.add(tsk.WhatId);
            }
        }
        Map<Id,CIRF_Material__c> relatedMaterials = new Map<Id,CIRF_Material__c>([select id, Material_Description__c,CIRF_Material_Status__c, Creator_Approval__c, RIM_Approval__c, Material_Name__c, On_Hand_Qty__c, Total_Order_Qty__c, Material_to_Forecast__c, Planning_Approval__c, Planning_Approval_Reason__c, Customer_Marketing_Approval__c, Customer_Marketing_Approval_Reason__c from CIRF_Material__c where id IN :cmatIds]);
        for(Task tsk : (List<Task>) trigger.new) {
            if(tsk.RecordTypeId == CIRFInventoryRecordType){
                CIRF_Material__c curMat = relatedMaterials.get(tsk.WhatId);
                tsk.Total_Order_Qty__c = curMat.Total_Order_Qty__c;
            }
        }
    } //end updateTotalQty
    
    private void updateSplitForecastField() {
        //Id taskSPFRecordtypeId = [select id, name from recordtype where name = 'CIRF Split Forecast'].id;
        System.debug('@@@split1');
        Id taskSPFRecordtypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Split Forecast').getRecordTypeId();
        Map<Id,String> tskCmatIdMap = new Map<Id,String>();
        for(Task tsk : (List<Task>) trigger.new){
            if(tsk.RecordTypeId == taskSPFRecordtypeId){
                if(tsk.Status == 'Completed' && ((Task)trigger.oldmap.get(tsk.id)).Status != 'Completed'){
                    tskCmatIdMap.put(tsk.id,tsk.WhatId);
                }
            }
        }
        if(!tskCmatIdMap.values().isEmpty()){
            System.debug('@@@split2');
            Map<Id,Task> queriedTasks = new Map<Id,Task>([select id, WhatId, CIRF_Split_Forecast__c from Task where Id IN :tskCmatIdMap.keyset()]);
            Map<Id,CIRF_Material__c> relatedMaterials = new Map<Id,CIRF_Material__c>([select id, On_Hand_Qty__c,Split_Forecast__c from CIRF_Material__c where id IN :tskCmatIdMap.values()]);
            for(Id tskId : tskCmatIdMap.keyset()){
                System.debug('@@@split3');
                //Task curTask = (Task) trigger.newMap.get(tskId);
                Task curTask = queriedTasks.get(tskId);
                CIRF_Material__c curMat = relatedMaterials.get(curTask.WhatId);
                curMat.Split_Forecast__c = curTask.CIRF_Split_Forecast__c;
            }
            //HEITCIRF-542 - SJ
            CIRFMaterialTriggerHandler.allowedCIRFActions = false;
            update relatedMaterials.values();
        }
    }
    
    private void validateInventoryTask() {
        Id CIRFInventoryRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF Inventory Request').getRecordTypeId();
        Map<Id,String> cmatIds = new Map<Id,String>();
        Map<Id,Task> tasksToUpdate = new Map<Id,Task>();
        List<CIRF_Material__c> skuExceptionMats = new List<CIRF_Material__c>();
        List<CIRF_Material__c> approvalCheckMats = new List<CIRF_Material__c>();
        for(Task tsk : (List<Task>) trigger.new) {
            System.debug('qty** ' + tsk.CIRF_Material_On_Hand_Qty__c);
            if(tsk.RecordTypeId == CIRFInventoryRecordType && tsk.CIRF_Material_On_Hand_Qty__c != null && tsk.CIRF_Material_On_Hand_Qty__c != ((Task)trigger.oldMap.get(tsk.id)).CIRF_Material_On_Hand_Qty__c){
                System.debug('Inside IF');
                cmatIds.put(tsk.id,tsk.WhatId);
            }
        }
        if(!cmatIds.values().isEmpty()){
            Map<Id,CIRF_Material__c> relatedMaterials = new Map<Id,CIRF_Material__c>([select id,Replen_Units__c,Material_Description__c,Material_Number__c,Material_Status__c,Material_Label_Code__c,CIRF_header__c, CIRF_Material_Status__c, Creator_Approval__c, RIM_Approval__c, Material_Name__c, On_Hand_Qty__c, Total_Order_Qty__c, Material_to_Forecast__c, Planning_Approval__c, Planning_Approval_Reason__c, Customer_Marketing_Approval__c, Customer_Marketing_Approval_Reason__c from CIRF_Material__c where id IN :cmatIds.values()]);
            for(Id tskId : cmatIds.keySet()){
                Task curTask = (Task) trigger.newMap.get(tskId);
                CIRF_Material__c curMat = relatedMaterials.get(cmatIds.get(tskId));
                curMat.On_Hand_Qty__c = curTask.CIRF_Material_On_Hand_Qty__c;
                //set task status to completed
                Task newTask = new Task(Id = curTask.id);
                newTask.Status = 'Completed';
                tasksToUpdate.put(newTask.id, newTask);
                if(curMat.On_Hand_Qty__c <= curMat.Total_Order_Qty__c){
                    //call sku exception
                    skuExceptionMats.add(curMat);
                }
                else {
                    curMat.Material_to_Forecast__c = curMat.Material_Name__c;
                    curMat.Planning_Approval__c = true;
                    curMat.Planning_Approval_Reason__c = 'Status = DS and sufficient inventory';
                    curMat.Customer_Marketing_Approval__c = true;
                    curMat.Customer_Marketing_Approval_Reason__c = 'Status = DS and sufficient inventory';
                    
                    //call material approval check
                    //CIRFMaterialStatusCheck.approvalCheck(new List<CIRF_Material__c>{curMat});
                    approvalCheckMats.add(curMat);
                }
            }
            if(!skuExceptionMats.isEmpty()){
                System.debug('12121212 '+skuExceptionMats);
                CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(skuExceptionMats);
            }
            if(!approvalCheckMats.isEmpty()){
                CIRFMaterialStatusCheck.approvalCheck(approvalCheckMats);
            }
            if(!tasksToUpdate.values().isEmpty()){
                update tasksToUpdate.values();
            }
            if(!relatedMaterials.values().isEmpty()){
                update relatedMaterials.values();
            }
        }
    }
} //The End