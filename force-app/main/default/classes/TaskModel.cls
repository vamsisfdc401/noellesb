/**
*    @description   model class for Task object
*    @author Ann Luong
*    Modification Log
*    10/15/2018 - AL - HEITCIRF-178 
*    11/5/2018 - AL - HEITCIRF-308
*
*/
global with sharing class TaskModel {
    
    public static final string RT_CIRF_GENERAL_TASK = 'CIRF General Task';
    public static final string RT_CIRF_SPLIT_MATERIAL = 'CIRF Split Material';
    public static final string RT_CIRF_EXCEPTION_APPROVAL = 'CIRF Exception Approval';
    public static final string RT_CIRF_INVENTORY_REQUEST = 'CIRF Inventory Request';
    public static final string RT_CIRF_SPLIT_FORECAST = 'CIRF Split Forecast';
    public static final string SOBJTYPE_TASK = 'Task';
    public static final string USER_NAME_API = 'API User';

    public static final string RESPONSE_STATUS_SUCCESS = 'SUCCESS'; 
    public static final string RESPONSE_STATUS_FAIL = 'FAIL';
    public static final string RESPONSE_STATUSCODE_FOUND = 'TASK_FOUND';
    public static final string RESPONSE_STATUSCODE_INVALIDPARM = 'INVALID_PARAMETER';
    public static final string RESPONSE_STATUSDESC_INVALIDPARM = 'The input parameters are invalid or missing';
    public static final string RESPONSE_STATUSCODE_CANNOTFOUND = 'TASK_NOT_FOUND';
    
    //SJ - 01/29/2019 - HEITCIRF-686
    public static Id apiUserId = Utility.getUserId(USER_NAME_API);

    /**
    * @description:  Create PIR Task
    * @param assignList 
    */
    public static void createPIRTask(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap){
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            system.debug('CIRFHeaderMap: ' + CIRFHeaderMap);
            Task PIRTask = new Task();
            PIRTask.WhatId = cmat.id;
            PIRTask.Status = 'Not Started';
            PIRTask.ActivityDate = date.TODAY() + 1;
            //PIRTask.OwnerId = Utility.getUserId(USER_NAME_API);
            PIRTask.OwnerId = apiUserId;
            PIRTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_GENERAL_TASK, SOBJTYPE_TASK);
            PIRTask.Type = 'Create PIR'; 
            PIRTask.Group__c = Utility.getMasterDataGroupName();
            PIRTask.CIRF_Header__c = cmat.CIRF_Header__c;
            system.debug('cmat.CIRF_Header__c: ' + cmat.CIRF_Header__c);
            if (CIRFHeaderMap.get(cmat.id) != null)
                PIRTask.CIRF_Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
            system.debug('Retailer Territory: ' + PIRTask.CIRF_Retailer__r.Territory__c);
            PIRTask.Subject = 'Create PIR for ' + cmat.Material_Number__c + ' - ' + cmat.Territory__c;
            PIRTask.Start_Date__c = date.TODAY();
            PIRTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            PIRTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            PIRTask.Material_Number__c = cmat.Material_Number__c;
            //SJ == HEITCIRF-593 -- 02/05/2019
            //PIRTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            taskList.add(PIRTask);           
        }
 
        insert taskList;    
    }

    public static void createFinalizeTask(List<CIRF_Material__c> cmatList, Map<Id,CIRF_Header__c> nameMap) {
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            system.debug('CIRFHeaderMap: ' + nameMap);
            Task finalizeBom = new Task();
            finalizeBom.WhatId = cmat.id;
            finalizeBom.Status = 'Not Started';
            finalizeBom.ActivityDate = date.TODAY() + 1;
            //finalizeBOM.OwnerId = Utility.getUserId(USER_NAME_API);
            finalizeBOM.OwnerId = apiUserId;
            finalizeBOM.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_GENERAL_TASK, SOBJTYPE_TASK); 
            finalizeBOM.Type = 'Finalize BOM'; 
            finalizeBOM.Group__c = Utility.getMasterDataGroupName();  // Need to define
            finalizeBOM.CIRF_Header__c = cmat.CIRF_Header__c;
            if (nameMap.get(cmat.id) != null)
                finalizeBOM.CIRF_Retailer__c = namemap.get(cmat.id).Retailer__c;
            finalizeBOM.Subject = 'Finalize BOM for ' + cmat.Material_Number__c + ' - ' + cmat.Territory__c;      
            finalizeBOM.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            finalizeBOM.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            finalizeBOM.Material_Number__c = cmat.Material_Number__c;
            //SJ == HEITCIRF-593 -- 02/05/2019
            //finalizeBOM.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            taskList.add(finalizeBom);            
        }
        insert taskList;
    }
    
    public static void createUpdateMaterialStatusTask(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap) {
        //
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            Task updateMatStatusTask = new Task();
            updateMatStatusTask.WhatId = cmat.id;
            updateMatStatusTask.Subject = 'Material Status Update for ' + cmat.Material_Number__c;
            updateMatStatusTask.Status = 'Not Started';
            updateMatStatusTask.Start_Date__c = date.TODAY();
            updateMatStatusTask.ActivityDate = date.TODAY() + 1;
            //updateMatStatusTask.OwnerId = Utility.getUserId(USER_NAME_API);
            updateMatStatusTask.OwnerId = apiUserId;
            updateMatStatusTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_GENERAL_TASK, SOBJTYPE_TASK); 
            //HEITCIRF-525 - SJ - 12/28/2018
            updateMatStatusTask.Type = 'Material Status Update'; 
            updateMatStatusTask.Group__c = Utility.getMasterDataGroupName();  
            updateMatStatusTask.Priority = 'Normal';

            system.debug('Exception Type: ' + cmat.Exception_Type__c);
            updateMatStatusTask.Activity_Description__c = 'Change Material Status...';

            if (cmat.Exception_Type__c == 'Distribution Only')
                updateMatStatusTask.Activity_Description__c = 'Change Material Status to "DS" for ' + cmat.Material_Number__c;
            else
            if (cmat.Exception_Type__c == 'Manufacturing and Distribution')
                updateMatStatusTask.Activity_Description__c = 'Change Material Status to "ES" for ' + cmat.Material_Number__c;

            updateMatStatusTask.CIRF_Header__c = cmat.CIRF_Header__c;
            system.debug('cmat.CIRFHeader: ' + cmat.CIRF_Header__c);
            updateMatStatusTask.CIRF_Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
            updateMatStatusTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            updateMatStatusTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            updateMatStatusTask.Material_Number__c = cmat.Material_Number__c;
            //SJ == HEITCIRF-593 -- 02/05/2019
            updateMatStatusTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            taskList.add(updateMatStatusTask);            
        }
        insert taskList;        
    }   

    public static void createUpdateMaterialExceptionTask(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap) {

        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            Task matExceptionTask = new Task();
            matExceptionTask.Group__c = Utility.getCustomerOperationsGroupName();
            matExceptionTask.RecordTypeId =  Utility.getRecordTypeId(RT_CIRF_GENERAL_TASK, SOBJTYPE_TASK); 
            matExceptionTask.Subject = 'Update Inclusion/Exclusion Table';
            matExceptionTask.Activity_Description__c = 'Sold To: ' + CIRFHeaderMap.get(cmat.id).Retailer_Sold_To__c;
            //  Change to Exception Start/End Date
            matExceptionTask.Activity_Description__c += ', Start Date: ' + string.valueOf(cmat.Exception_Start_Date__c);
            matExceptionTask.Activity_Description__c += ', End Date: ' + string.valueOf(cmat.Exception_End_Date__c);
            matExceptionTask.Activity_Description__c += ', Exception Type: ' + cmat.Exception_Type__c;
            matExceptionTask.Activity_Description__c += ', Material Number: ' + cmat.Material_Number__c;
            matExceptionTask.Start_Date__c = date.TODAY();
            matExceptionTask.ActivityDate = date.TODAY() + 1;
            matExceptionTask.Priority = 'Normal';
            matExceptionTask.CIRF_Header__c = cmat.CIRF_Header__c;
            matExceptionTask.Type = 'Inclusion/Exclusion Table';
            matExceptionTask.WhatId = cmat.Id;
            matExceptionTask.CIRF_Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
            matExceptionTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            matExceptionTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            matExceptionTask.Material_Number__c = cmat.Material_Number__c;
            //SJ == HEITCIRF-593 -- 02/05/2019
            matExceptionTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            taskList.add(matExceptionTask); 
        }
        insert taskList;
    }

    public static void createCMApproveExceptionTask(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap) {
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            system.debug('CIRFHeaderMap: ' + CIRFHeaderMap);
            Task approveExceptionTask = new Task();
            approveExceptionTask.WhatId = cmat.id;
            approveExceptionTask.Subject = 'Approve Exception - Customer Marketing - ' + cmat.Material_Number__c;
            approveExceptionTask.Status = 'Not Started';
            approveExceptionTask.ActivityDate = date.TODAY() + 1;
            //approveExceptionTask.OwnerId = Utility.getUserId(USER_NAME_API);
            approveExceptionTask.OwnerId = apiUserId;
            approveExceptionTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_EXCEPTION_APPROVAL, SOBJTYPE_TASK); 
            approveExceptionTask.Type = 'Customer Marketing'; 
            approveExceptionTask.Group__c = Utility.getCustomerMarketingGroupName(); 
            approveExceptionTask.Priority = 'High'; 
            approveExceptionTask.CIRF_Header__c = cmat.CIRF_Header__c;
            approveExceptionTask.CIRF_Exception_Start_Date__c = date.TODAY();       //HEITCIRF-308
            approveExceptionTask.CIRF_Exception_End_Date__c = CIRFHeaderMap.get(cmat.id).CIRF_End_Date__c;
            approveExceptionTask.CIRF_Exception_Type__c = cmat.Exception_Type__c;
            approveExceptionTask.CIRF_Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
            approveExceptionTask.Start_Date__c = date.TODAY();
            approveExceptionTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            approveExceptionTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            approveExceptionTask.Material_Number__c = cmat.Material_Number__c;
            approveExceptionTask.Activity_Description__c = 'This SKU is in a status that cannot be distributed. Please review this material and either accept this exception, remove this material from the promotion, or provide an alternate material';
            
            //SJ - HEITCIRF-593 - 01/10/2019
            approveExceptionTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            approveExceptionTask.CIRF_Replen_Units__c = cmat.Replen_Units__c;
            approveExceptionTask.CIRF_Units_to_Order__c = cmat.Units_to_Order__c;
            //SJ - HEITCIRF-640 - 01/18/2019
            approveExceptionTask.Total_Order_Qty__c = cmat.Total_Order_Qty__c;
            //SJ - HEITCIRF-717 - 02/14/2019
            approveExceptionTask.CIRF_Corrugate_Units__c = cmat.Corrugate_Units__c;
            // HEITCIRF-734 Added by Kalyani
            approveExceptionTask.Material_Status__c = cmat.Material_Status__c;
            // HEITCIRF-733 Added by Kalyani
            approveExceptionTask.Description = 'Planning Comments:' + cmat.comments__c;
            taskList.add(approveExceptionTask);            
        }
        insert taskList;        
    }

    public static void createPlanningApproveExceptionTask(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap) {
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            System.debug('taskcmat '+cmat);
            Task approveExceptionTask = new Task();
            approveExceptionTask.WhatId = cmat.id;
            approveExceptionTask.Subject = 'Approve Exception - Planning - ' + cmat.Material_Number__c;
            approveExceptionTask.Status = 'Not Started';
            approveExceptionTask.ActivityDate = date.TODAY() + 1;
            //approveExceptionTask.OwnerId = Utility.getUserId(USER_NAME_API);
            approveExceptionTask.OwnerId = apiUserId;
            approveExceptionTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_EXCEPTION_APPROVAL, SOBJTYPE_TASK); 
            approveExceptionTask.Type = 'Planning'; 
            //SJ - 01/28/2019 - HEITCIRF-624
            System.debug('Taskm '+cmat.Name +cmat.Material_Label_Code__c);
            System.debug('Taskm2 '+cmat.Name +cmat.Material_Product_Class__c);
            approveExceptionTask.Group__c = MaterialLabelHelper.getPlanningGroupByLabelCode(cmat.Material_Label_Code__c, cmat.Material_Product_Class__c);
            approveExceptionTask.Priority = 'High'; 
            approveExceptionTask.CIRF_Header__c = cmat.CIRF_Header__c;
            approveExceptionTask.CIRF_Exception_Start_Date__c = date.TODAY();       //  HEITCIRF-308
            approveExceptionTask.CIRF_Exception_End_Date__c = CIRFHeaderMap.get(cmat.Id).CIRF_End_Date__c;
            system.debug('cmat: ' + cmat + ' Exception Type: ' + cmat.Exception_Type__c);
            approveExceptionTask.CIRF_Exception_Type__c = cmat.Exception_Type__c;
            approveExceptionTask.CIRF_Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
            approveExceptionTask.Start_Date__c = date.TODAY();
            approveExceptionTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            approveExceptionTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            approveExceptionTask.Material_Number__c = cmat.Material_Number__c;
            approveExceptionTask.Activity_Description__c = 'This SKU is in a status that cannot be distributed. Please review this material and either accept this exception, remove this material from the promotion, or provide an alternate material';
            //SJ - HEITCIRF-593 - 01/10/2019
            approveExceptionTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            approveExceptionTask.CIRF_Replen_Units__c = cmat.Replen_Units__c;
            approveExceptionTask.CIRF_Units_to_Order__c = cmat.Units_to_Order__c;
            //SJ - HEITCIRF-640 - 01/18/2019
            approveExceptionTask.Total_Order_Qty__c = cmat.Total_Order_Qty__c;
            //SJ - HEITCIRF-717 - 02/14/2019
            approveExceptionTask.CIRF_Corrugate_Units__c = cmat.Corrugate_Units__c;
            // HEITCIRF-734 Added by Kalyani
            approveExceptionTask.Material_Status__c = cmat.Material_Status__c;
            taskList.add(approveExceptionTask);          

        }
        insert taskList;        

    }
    
    public static void createInventoryRequestTask(List<CIRF_Material__c> cmatList) {
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            Task approveExceptionTask = new Task();
            approveExceptionTask.WhatId = cmat.id;
            approveExceptionTask.Subject = 'Validate inventory of material : ' + cmat.Material_Number__c + ' and enter value on the task';
            approveExceptionTask.Status = 'Not Started';
            approveExceptionTask.ActivityDate = date.TODAY() + 1;
            //approveExceptionTask.OwnerId = Utility.getUserId(USER_NAME_API);
            approveExceptionTask.OwnerId = apiUserId;
            approveExceptionTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_INVENTORY_REQUEST, SOBJTYPE_TASK); 
            approveExceptionTask.Type = 'Planning'; 
            approveExceptionTask.Group__c = 'Universal_New_Release_Planning';
            approveExceptionTask.Priority = 'High'; 
            approveExceptionTask.CIRF_Header__c = cmat.CIRF_Header__c;
            approveExceptionTask.CIRF_Exception_Type__c = cmat.Exception_Type__c;
            approveExceptionTask.Start_Date__c = date.TODAY();
            approveExceptionTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            approveExceptionTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            approveExceptionTask.Material_Number__c = cmat.Material_Number__c;
            
            //HEITCIRF-648 - SJ - 1/17/2019
            approveExceptionTask.Total_Order_Qty__c = cmat.Total_Order_Qty__c;
            //SJ - HEITCIRF-717 - 02/14/2019
            approveExceptionTask.CIRF_Corrugate_Units__c = cmat.Corrugate_Units__c;
            // HEITCIRF-734 Added by Kalyani
            approveExceptionTask.Material_Status__c = cmat.Material_Status__c;
            taskList.add(approveExceptionTask);          

        }
        System.debug(taskList);
        insert taskList;        
    }
    
    public static void createSplitForecastTask(List<CIRF_Material__c> cmatList) {
        List<Task> taskList = new List<Task>();
        for (CIRF_Material__c cmat : cmatList) {
            Task approveExceptionTask = new Task();
            approveExceptionTask.WhatId = cmat.id;
            approveExceptionTask.Subject = 'Review if forecast should be split into sellable singles';
            approveExceptionTask.Status = 'Not Started';
            approveExceptionTask.ActivityDate = date.TODAY() + 1;
            //approveExceptionTask.OwnerId = Utility.getUserId(USER_NAME_API);
            approveExceptionTask.OwnerId = apiUserId;
            approveExceptionTask.RecordTypeId = Utility.getRecordTypeId(RT_CIRF_SPLIT_FORECAST, SOBJTYPE_TASK); 
            approveExceptionTask.Type = 'Planning';
            //SJ - 01/28/2019 - HEITCIRF-624
            approveExceptionTask.Group__c = MaterialLabelHelper.getPlanningGroupByLabelCode(cmat.Material_Label_Code__c, cmat.Material_Product_Class__c);
            approveExceptionTask.Priority = 'High'; 
            approveExceptionTask.CIRF_Header__c = cmat.CIRF_Header__c;
            approveExceptionTask.CIRF_Exception_Type__c = cmat.Exception_Type__c;
            approveExceptionTask.Start_Date__c = date.TODAY();
            approveExceptionTask.CIRF_Current_Material_Id__c = cmat.Material_Name__c;
            approveExceptionTask.MaterialDescription_SmartSheet__c = cmat.Material_Description__c;
            approveExceptionTask.Material_Number__c = cmat.Material_Number__c;
            //SJ == HEITCIRF-593 -- 02/05/2019
            //approveExceptionTask.CIRF_Material_On_Hand_Qty__c = cmat.On_Hand_Qty__c;
            taskList.add(approveExceptionTask);          

        }
        insert taskList;        
    }
    
    //SJ - HEITCIRF-84 - 12/10/2018
    public static void createPricingTask(List<CIRF_Header__c> headers) {
        List<Id> headerIds = new List<Id>();
        List<Task> tasksToInsert = new List<task>();
        Map<Id,List<String>> retailerUserIdMap = new Map<Id, List<String>>();
        for(CIRF_Header__c ch : headers){
            headerIds.add(ch.Retailer__c);
        }
        List<AccountTeamMember> atms = [select accountid, userid from AccountTeamMember where accountid IN : headerIds AND TeamMemberRole = 'CIRF Customer Ops'];                          
        for(AccountTeamMember atm : atms){
            if(!retailerUserIdMap.containsKey(atm.accountid)){
                retailerUserIdMap.put(atm.accountid, new List<String>());
            }
            (retailerUserIdMap.get(atm.accountid)).add(atm.userid);
        }
        System.debug('retailerUserIdMap '+retailerUserIdMap);
        Id RecordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CIRF General Task').getRecordTypeId();
        //Id apiUserId = [select id from user where name = 'API User'].Id;
        for(CIRF_Header__c head : headers){
            Task t = new Task();
            t.RecordTypeId = RecordTypeIdTask;
            t.WhatId = head.id;
            t.Group__c = 'RF_Customer_Ops';
            t.Subject =' Review Pricing for ' + head.Name;
            t.Type = 'Pricing';
            t.Start_Date__c = System.today();     
            t.ActivityDate = t.Start_Date__c+1;
            t.Priority = 'Normal';
            t.CIRF_Header__c = head.Id;
            //Only assign owner if the account team has user with role CIRF Customer Ops
            if(retailerUserIdMap.get(head.Retailer__c) != null && (!(retailerUserIdMap.get(head.Retailer__c)).isEmpty())){
                t.OwnerId = (retailerUserIdMap.get(head.Retailer__c))[0];
            }
            else{
                t.OwnerId = apiUserId;
            }
            tasksToInsert.add(t);
        }
        System.debug('*** ' + tasksToInsert);
        if(!tasksToInsert.isEmpty()){
            insert tasksToInsert;
        }
    }
}