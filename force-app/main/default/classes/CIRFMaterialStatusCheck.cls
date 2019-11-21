public without sharing class CIRFMaterialStatusCheck {

/**
*    @description   model class for Task object
*    @author  xxxxxxx
*    Modification Log
*    12/7/2018 - SJ - HEITCIRF-134 - Changes in HEITCIRF-386
*    11/5/2018 - AL - HEITCIRF-308
*    12/6/2018 - AL - SKU Exception Approval changes
*
*/
    public static boolean StatusCheckExecuted = false;
    public static Boolean firstTime = true;
    public static boolean cmTaskCreated = false;
    public static Map<Id,CIRF_Material_Exceptions__c> nationalExceptionMap = new Map<Id, CIRF_Material_Exceptions__c>();
    public static List<CIRF_Material_Exceptions__c> CIRFMaterialExceptionsList = new List<CIRF_Material_Exceptions__c>();
    public static List<Id> executedCmatIds = new List<Id>();
    
    public Static void CIRFMaterialStatusCheckMethod(List<CIRF_Material__c> CIRFMaterialList,Map<Id,CIRF_Material__c> CIRFMaterialOldMap){
        
        System.debug('?????CIRFMaterialStatusCheck'+StatusCheckExecuted);
        if(!StatusCheckExecuted){
            List<Id> MaterialIds = new List<Id>();
            List<Id> HeaderIds = new List<Id>();
            for(CIRF_Material__c cm : CIRFMaterialList){
                MaterialIds.add(cm.Material_Name__c);
                HeaderIds.add(cm.CIRF_Header__c);
            }

        Map<Id, Material__c> MaterialMap = getMaterialMap(MaterialIds);
        Map<Id, CIRF_Header__c> HeaderMap = getCIRFHeaderMap(HeaderIds);
        List<Id> RetailerIds = getRetailerIdList(HeaderMap);
        Map<String,CIRF_Material_Exceptions__c> materialExceptionsMap = getMaterialExceptionsMap(MaterialIds, RetailerIds,HeaderMap.values()[0]);
        
        List<CIRF_Material__c> cmatInventoryTaskList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> cmatSplitForecastTaskList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> cmatSKUExceptionList = new List<CIRF_Material__c>();
        CIRF_Header__c CIRFHeader = null;
        String materialExceptionName = null;
        Boolean exceptionExists;
        
        for(CIRF_Material__c cm : CIRFMaterialList){
            if(MaterialMap.containsKey(cm.Material_Name__c) && cm.CIRF_Material_Status__c == 'Submitted') {
                CIRFHeader = HeaderMap.get(cm.CIRF_Header__c);
                materialExceptionName = getMaterialException(cm.Material_Name__c, materialMap, CIRFHeader, materialExceptionsMap);
                //System.debug('*123 materialExceptionName ' +materialExceptionName);
                exceptionExists = materialExceptionName != null ? true : false;
                System.debug('*123 exceptionExists ' +exceptionExists);
                //Boolean exceptionFound
                /*if (SKUMaterialException(cm))
                    if (exceptionExists)  {
                        cm = exceptionUpdate(cm, materialExceptionName);
                     }
                    else
                     cmatSKUExceptionList.add(cm);*/

                if ((cm.CIRF_Material_Status__c <> CIRFMaterialOldMap.get(cm.Id).CIRF_Material_Status__c
                    && (CIRFMaterialOldMap.get(cm.Id).CIRF_Material_Status__c == 'Draft' 
                    ||  CIRFMaterialOldMap.get(cm.Id).CIRF_Material_Status__c == 'Merged'))|| cm.CIRF_Material_Status__c == 'Submitted'){               
                    Material__c Material = MaterialMap.get(cm.Material_Name__c);                                       
                    if(cm.Material_Status__c == 'AC' || cm.Material_Status__c == 'RP'){
                        System.debug('Scenario 1 *** AC RP');
                        if(cm.Material_to_Forecast__c == null)
                        {
                        	cm.Material_to_Forecast__c = cm.Material_Name__c;    
                        }                        
                        cm.Planning_Approval__c = true;
                        cm.Planning_Approval_Reason__c = 'Status = AC/RP';
                        cm.Customer_Marketing_Approval__c = true;
                        cm.Customer_Marketing_Approval_Reason__c = 'Status = AC/RP';
                    } 
                    else {
                        CIRF_Header__c head = HeaderMap.get(cm.CIRF_Header__c);
                        String key = cm.Material_Name__c+''+head.Retailer__c;
                        CIRF_Material_Exceptions__c exc = materialExceptionsMap.get(key);
                        CIRF_Material_Exceptions__c excNat = nationalExceptionMap.get(cm.Material_Name__c);
                        if(SKUMaterialException(cm) && materialExceptionsMap.containsKey(key) && (head.CIRF_End_Date__c >= exc.Start_Date__c && head.CIRF_End_Date__c <= exc.End_Date__c)){
                            System.debug('Not national');
                            exceptionUpdate(cm, exc.Name);
                          }
                        else if(SKUMaterialException(cm) && nationalExceptionMap.containsKey(cm.Material_Name__c) && (head.CIRF_End_Date__c >= excNat.Start_Date__c && head.CIRF_End_Date__c <= excNat.End_Date__c)){
                            //national exception exists
                            System.debug('national');
                             exceptionUpdate(cm, excNat.Name);
                        }
                        else if(cm.Material_Status__c == 'ID' || cm.Material_Status__c == 'IM' || cm.Material_Status__c == 'ES'){
                            System.debug('Scenario 3 Before *** ID IM ES');
                            cmatSKUExceptionList.add(cm);
                        } 
                        else if(cm.Material_Status__c == 'SD' || cm.Material_Status__c == 'DS'){
                            System.debug('Scenario 4 Before *** SD DS');
                            cmatInventoryTaskList.add(cm);
                        }
                        else if((cm.Material_Status__c == 'NR' || cm.Material_Status__c == 'FR' || cm.Material_Status__c == 'NA' || cm.Material_Status__c == 'AA') && Material.Item_Type__c == 'M (Multipack)' && (Material.Item_Code__c != 'XS - SPECIAL SINGLE' && Material.Item_Code__c != 'MS - TV MULTIPLE SERIES' && Material.Item_Code__c != 'MT - MULTI-TITLE')){
                            System.debug('Scenario 5 Before ***');
                            if(cm.Material_to_Forecast__c == null)
                            {
                                cm.Material_to_Forecast__c = cm.Material_Name__c;    
                            }
                            cm.Planning_Approval__c = true;
                            cm.Planning_Approval_Reason__c = 'NR/FR Item Type M Approval';
                            cm.Customer_Marketing_Approval__c = true;
                            cm.Customer_Marketing_Approval_Reason__c = 'NR/FR Standard Approval';
                            cmatSplitForecastTaskList.add(cm);
                        } else if((cm.Material_Status__c == 'NR' || cm.Material_Status__c == 'FR' || cm.Material_Status__c == 'NA' || cm.Material_Status__c == 'AA') && (Material.Item_Type__c != 'M (Multipack)' || (Material.Item_Type__c == 'M (Multipack)' && (Material.Item_Code__c == 'XS - SPECIAL SINGLE' || Material.Item_Code__c == 'MS - TV MULTIPLE SERIES' || Material.Item_Code__c == 'MT - MULTI-TITLE')))){
                            System.debug('Scenario 6 Before ***');
                            /*if(Material.Street_Date__c + 28 > HeaderMap.get(cm.CIRF_Header__c).CIRF_Start_Date__c){
                                //Send Email to getPlannerGroupByLabelCode
                                String PlannerGroup = MaterialLabelHelper.getPlanningGroupByLabelCode(cm.Material_Label_Code__c);
                            }*/
                            System.debug('NR FR Not multipack');
                            if(cm.Material_to_Forecast__c == null)
                            {
                                cm.Material_to_Forecast__c = cm.Material_Name__c;    
                            }
                            cm.Planning_Approval__c = true;
                            cm.Planning_Approval_Reason__c = 'NR/FR Standard Approval';
                            cm.Customer_Marketing_Approval__c = true;
                            cm.Customer_Marketing_Approval_Reason__c = 'NR/FR Standard Approval';
                        } else {
                            cm.Customer_Marketing_Approval__c = true;
                            cm.Customer_Marketing_Approval_Reason__c = 'Other Status...';
                            System.debug('other status');
                            cmatSKUExceptionList.add(cm);
                        }
                    } 

                }   

            }
        }
        //System.debug(cmatInventoryTaskList);
        //System.debug(cmatSplitForecastTaskList);
        //  Part of CIRF Material SKU Exception Approval - Before logic
        if (!cmatSKUExceptionList.isEmpty())
            processSKUMaterials(cmatSKUExceptionList);

        }
        //TaskModel.createInventoryRequestTask(cmatInventoryTaskList);
        //TaskModel.createInventoryRequestTask(cmatInventoryTaskList);
    }

    public Static void CIRFMaterialStatusCheckAfter(List<CIRF_Material__c> CIRFMaterialList,Map<Id,CIRF_Material__c> CIRFMaterialOldMap){
        system.debug('StatusCheckExecuted:  ' + StatusCheckExecuted);
        //if(!StatusCheckExecuted){
        system.debug('----CIRFMaterialStatusCheckAfter');
                
        List<Id> MaterialIds = new List<Id>();
        List<Id> HeaderIds = new List<Id>();
        system.debug('CIRFMaterialList:'+CIRFMaterialList);
        for(CIRF_Material__c cm : CIRFMaterialList){
            MaterialIds.add(cm.Material_Name__c);
            HeaderIds.add(cm.CIRF_Header__c);
        }
        system.debug('MaterialIds:'+MaterialIds);
        system.debug('HeaderIds:'+HeaderIds);
        Map<Id,Material__c> materialMap =  getMaterialMap(MaterialIds);
        system.debug('materialMap:'+materialMap);
        Map<Id,CIRF_Header__c> HeaderMap = getCIRFHeaderMap(HeaderIds);       
        system.debug('HeaderMap:'+HeaderMap);
        List<Id> RetailerIds = getRetailerIdList(HeaderMap);                                                                 
        system.debug('RetailerIds:'+RetailerIds);
        Map<String,CIRF_Material_Exceptions__c> materialExceptionsMap = getMaterialExceptionsMap(MaterialIds, RetailerIds,HeaderMap.values()[0]);
        Boolean  exceptionExists = false;
        CIRF_Header__c CIRFHeader = null; 
        String materialExceptionName = null;

        List<CIRF_Material__c> cmatInventoryTaskList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> cmatSplitForecastTaskList = new List<CIRF_Material__c>();
        Map<Id,CIRF_Material__c> SKUMaterialList = new Map<Id,CIRF_Material__c>();
        List<CIRF_Material__c> SendEmailforMaterial = new List<CIRF_Material__c>();
        
        for(CIRF_Material__c cm : CIRFMaterialList){
            if(!executedCmatIds.contains(cm.id)){
                //system.debug('debug mat after-- cm: ' + cm.name +' '+cm);
                System.debug('*** After Insert');
                CIRFHeader = HeaderMap.get(cm.CIRF_Header__c);
                String key = cm.Material_Name__c+''+CIRFHeader.Retailer__c;
                CIRF_Material_Exceptions__c exc = materialExceptionsMap.get(key);
                CIRF_Material_Exceptions__c excNational = nationalExceptionMap.get(cm.Material_Name__c);
                System.debug('exc '+exc);
                System.debug('excnat '+excNational);
                if(SKUMaterialException(cm) && cm.On_Hand_Qty__c!= null && (CIRFMaterialOldMap.get(cm.id)).On_Hand_Qty__c != null && cm.Material_Status__c == 'DS' && cm.On_Hand_Qty__c < cm.Total_Order_Qty__c){
                    if(exc==null && excNational==null){
                        System.debug('1.1sku');
                        SKUMaterialList.put(cm.id,cm);
                    }
                    else if((exc!=null && (CIRFHeader.CIRF_End_Date__c < exc.Start_Date__c || CIRFHeader.CIRF_End_Date__c > exc.End_Date__c))||
                            (excNational!=null && (CIRFHeader.CIRF_End_Date__c < excNational.Start_Date__c || CIRFHeader.CIRF_End_Date__c > excNational.End_Date__c))){
                                System.debug('1.2sku');
                                SKUMaterialList.put(cm.id,cm);
                    }
                }
                else if(SKUMaterialException(cm) && exc==null && excNational==null && cm.Material_Status__c != 'DS'){
                    System.debug('2sku');
                    SKUMaterialList.put(cm.id,cm);
                }
                else if(SKUMaterialException(cm) && cm.Material_Status__c != 'DS' && ((exc!=null && (CIRFHeader.CIRF_End_Date__c < exc.Start_Date__c || CIRFHeader.CIRF_End_Date__c > exc.End_Date__c))||
                            (excNational!=null && (CIRFHeader.CIRF_End_Date__c < excNational.Start_Date__c || CIRFHeader.CIRF_End_Date__c > excNational.End_Date__c)))){
                                System.debug('3sku');
                                SKUMaterialList.put(cm.id,cm);
                }
                //}
                else if(MaterialMap.containsKey(cm.Material_Name__c) && (cm.CIRF_Material_Status__c == 'Submitted' || cm.CIRF_Material_Status__c == 'Loaded')
                    && CIRFMaterialOldMap.get(cm.Id).CIRF_Material_Status__c == 'Draft'){             
                    Material__c Material = MaterialMap.get(cm.Material_Name__c);
                    System.debug('*** Validate BOM done');
                    //if(!exceptionExists && (cm.Material_Status__c == 'ID' || cm.Material_Status__c == 'IM')){
                    if(cm.Material_Status__c == 'SD' || cm.Material_Status__c == 'DS'){
                        System.debug('Scenario 4 *** SD DS');
                        cmatInventoryTaskList.add(cm);
                    } else if((cm.Material_Status__c == 'NR' || cm.Material_Status__c == 'FR' || cm.Material_Status__c == 'NA' || cm.Material_Status__c == 'AA') && Material.Item_Type__c == 'M (Multipack)' && (Material.Item_Code__c != 'XS - SPECIAL SINGLE' && Material.Item_Code__c != 'MS - TV MULTIPLE SERIES' && Material.Item_Code__c != 'MT - MULTI-TITLE')){
                        System.debug('NR FR Split forecast *** Scenario 5');
                        cmatSplitForecastTaskList.add(cm);
                    } else if((cm.Material_Status__c == 'NR' || cm.Material_Status__c == 'FR' || cm.Material_Status__c == 'NA' || cm.Material_Status__c == 'AA') && (Material.Item_Type__c != 'M (Multipack)' || (Material.Item_Type__c == 'M (Multipack)' && (Material.Item_Code__c == 'XS - SPECIAL SINGLE' || Material.Item_Code__c == 'MS - TV MULTIPLE SERIES' || Material.Item_Code__c == 'MT - MULTI-TITLE')))){
                        System.debug('NR FR send email *** Scenario 6');
                        /*if(Material.Street_Date__c + 28 > HeaderMap.get(cm.CIRF_Header__c).CIRF_Start_Date__c){
                            //Send Email to getPlannerGroupByLabelCode
                            String PlannerGroup = MaterialLabelHelper.getPlanningGroupByLabelCode(cm.Material_Label_Code__c);
                            //SendEmailforMaterial.add(cm);
                        }*/
                    }
                    //StatusCheckExecuted = true;
                }
            }
            executedCmatIds.add(cm.id);
        }
         if(!cmatInventoryTaskList.isEmpty())
            TaskModel.createInventoryRequestTask(cmatInventoryTaskList); 
        
        if(!cmatSplitForecastTaskList.isEmpty())
            TaskModel.createSplitForecastTask(cmatSplitForecastTaskList);
        
        if(!SKUMaterialList.values().isEmpty())
            SKUMaterialExceptionApproval(SKUMaterialList.values());
        
        /*if(!SendEmailforMaterial.isEmpty())
            SendEmailToPlannerGroup(SendEmailforMaterial);*/
        //}
    }

    private static Map<Id, Material__c> getMaterialMap(List<Id> materialIdList) {
         Map<Id,Material__c> materialMap = new Map<Id,Material__c>([Select Id,Material_Number__c,Material_Status__c,Street_Date__c,Item_Code__c,Item_type__c 
                                            from Material__c 
                                            where Id =: materialIdList]);

         return materialMap;
    }

    private static Map<Id, CIRF_Header__c> getCIRFHeaderMap(List<Id> headerIdList) {
        Map<Id,CIRF_Header__c> headerMap = new Map<Id,CIRF_Header__c>([Select Id,CIRF_Start_Date__c, CIRF_End_Date__c, Retailer__c 
                                            from CIRF_Header__c 
                                            where Id=:headerIdList ]);

        return headerMap;
    }

    private static List<Id> getRetailerIdList (Map<Id, CIRF_Header__c> CIRFHeaderMap) {
        List<Id> retailerIdList = new List<Id>();
        for(CIRF_Header__c ch : CIRFHeaderMap.values()){
            retailerIdList.add(ch.Retailer__c);
        }
        return retailerIdList;
    }

    private static Boolean SKUMaterialException(CIRF_Material__c cm) {
        switch on (cm.Material_Status__c)  {
            when 'ID', 'IM','ES','DS'{
                return true;
            }
            when 'NR','FR','NA','AA','AC','RP'{
                return false;
            }
            when else {
                return true;
            }
        }
     }

    private static Map<String, CIRF_Material_Exceptions__c> getMaterialExceptionsMap(List<Id> materialIdList, List<Id> retailerIdList, CIRF_Header__c head) {
        System.debug('headddd '+head);
        system.debug('firstTime: ' + firstTime);
        retailerIdList.add(Label.CIRF_National_Retailer_ID);
        if (firstTime) {
            CIRFMaterialExceptionsList = [Select Id,Name, Retailer__c,Material__c,End_Date__c,Start_Date__c 
                                                                    from CIRF_Material_Exceptions__c 
                                                                    where Material__c =: materialIdList 
                                                                    AND Retailer__c =: retailerIdList];
            System.debug('*123 CIRFMaterialExceptionsList '+CIRFMaterialExceptionsList);
             firstTime = false;                                                       
        }
       
        Map<String,CIRF_Material_Exceptions__c> materialExceptionsMap = new Map<String,CIRF_Material_Exceptions__c>();
        for(CIRF_Material_Exceptions__c me : CIRFMaterialExceptionsList){
            if(me.Start_Date__c != null && me.End_Date__c != null){
                System.debug(head.CIRF_End_Date__c >= me.Start_Date__c);
                System.debug(head.CIRF_End_Date__c <= me.End_Date__c);
                if(head.CIRF_End_Date__c >= me.Start_Date__c && head.CIRF_End_Date__c <= me.End_Date__c){
                    if(me.Retailer__c == Label.CIRF_National_Retailer_ID){
                    	nationalExceptionMap.put(me.Material__c, me);
                	}
                    else{
                        String key = me.Material__c + '' + me.Retailer__c;
                		materialExceptionsMap.put(key, me);
                    }
                }
            }
        }
        System.debug('matttmap '+materialExceptionsMap);
        return materialExceptionsMap;
    }

    private static CIRF_Material__c exceptionUpdate(CIRF_Material__c cm, String materialExceptionName) {
         if(cm.Material_to_Forecast__c == null )
         {
             cm.Material_to_Forecast__c = cm.Material_Name__c;    
         }
         cm.Planning_Approval__c = true;
         cm.Planning_Approval_Reason__c = 'On Exceptions Report - ' + materialExceptionName;
         cm.Customer_Marketing_Approval__c = true;
         cm.Customer_Marketing_Approval_Reason__c = 'On Exceptions Report - ' + materialExceptionName;
         return cm;
    }

    private static String GetMaterialException(Id materialId, Map<Id, Material__c> materialMap, CIRF_Header__c CIRFHeader, Map<String,CIRF_Material_Exceptions__c> materialExceptionsMap) {

        system.debug('GetMaterialException Vinay');
        String materialExceptionName = null;
        Material__c Material = MaterialMap.get(materialId);                    
        String key = materialId + '' + CIRFHeader.Retailer__c;
 
        if(MaterialExceptionsMap.containsKey(key)   
             && CIRFHeader.CIRF_Start_Date__c >= MaterialExceptionsMap.get(key).Start_Date__c 
             && CIRFHeader.CIRF_End_Date__c <= MaterialExceptionsMap.get(key).End_Date__c){
            materialExceptionName = MaterialExceptionsMap.get(key).Name;
        }
            system.debug('Key: ' + key + ' return: '+ materialExceptionName);
                   
        return materialExceptionName;
    }
    
    public Static Map<Id,List<User>> fetchGroupMembers(Id GroupIds){
        return null;
    } 
    
    public static Set<id> GetUserIdsFromGroup(Id groupId)
    {
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
        {
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
            }
        }
        return result; 
    }
    
    public static void approvalCheck(List<CIRF_Material__c> cmatList){
        system.debug('approvalCheck'+cmatList);
        
        for (CIRF_Material__c cm : cmatList) {
            //system.debug('cmat: ' + cm);
            if(cm.CIRF_Material_Status__c=='Submitted'){
                //System.debug('Submitted');
                //System.debug(cm.Customer_Marketing_Approval__c);
                //System.debug(cm.Creator_Approval__c);
                //System.debug(cm.RIM_Approval__c);
                if(cm.Customer_Marketing_Approval__c==true && cm.Creator_Approval__c==true && cm.RIM_Approval__c==true){
                    cm.CIRF_Material_Status__c = 'Loaded';
                }
            }           
        }
        
    }
    
    public static void processSKUMaterialsSubmitted(List<CIRF_Material__c> currentCIRFMatList) {        
        //  Scenario 2 Check
        system.debug('processKUMaterials');
        Map<String, Boolean> labelCustMktApprovalMap = MaterialLabelHelper.getLabelCustMktApprovalMap(currentCIRFMatList);
        List<CIRF_Material__c> CMAppCMatList = new List<CIRF_Material__c>();
        for (CIRF_Material__c cmat : currentCIRFMatList) 
        {
            system.debug('cmat.Customer_Marketing_Approval__c: ' + cmat.Customer_Marketing_Approval__c);
            if (cmat.Creator_Approval__c && cmat.Planning_Approval__c) 
            {
                //  Don't need Customer Marketing Approval -- labelCustMktApproval = false
                //System.debug(cmat.name + ' ' +cmat.material_label_code__c);
                if (cmat.material_label_code__c != null && labelCustMktApprovalMap.get(cmat.material_label_code__c)) 
                {
                    // Need Customer Marketing Approval & Customer Marketing Approval is provided (= true)
                       if (cmat.Customer_Marketing_Approval__c == true)
                       {
                           if(cmat.Material_to_Forecast__c == null)
                            {
                                cmat.Material_to_Forecast__c = cmat.Material_Name__c;    
                            }
                       }
                       else
                       {
                           CMAppCMatList.add(cmat);
                       }
                }
         	}
        }
        if(!CMAppCMatList.IsEmpty())
        {
            S2CUpdate(CMAppCMatList);
        }
        
    }
    //for before context
    public static void processSKUMaterials(List<CIRF_Material__c> currentCIRFMatList) {        
        //  Scenario 2 Check
        system.debug('processKUMaterials');
        Map<String, Boolean> labelCustMktApprovalMap = MaterialLabelHelper.getLabelCustMktApprovalMap(currentCIRFMatList);
        List<CIRF_Material__c> S2MatList = new List<CIRF_Material__c>();
        for (CIRF_Material__c cmat : currentCIRFMatList) {
            system.debug('cmat.Customer_Marketing_Approval__c: ' + cmat.Customer_Marketing_Approval__c);
            if (cmat.Creator_Approval__c && cmat.Planning_Approval__c) {
                //  Don't need Customer Marketing Approval -- labelCustMktApproval = false
                if (cmat.material_label_code__c != null && !labelCustMktApprovalMap.get(cmat.material_label_code__c)) {
                    cmat.Customer_Marketing_Approval__c = true;
                    cmat.Customer_Marketing_Approval_Reason__c = 'Non-CM Supported Label Code';
                    if(cmat.Material_to_Forecast__c == null)
                    {
                        cmat.Material_to_Forecast__c = cmat.Material_Name__c;    
                    }
                }
               else {
                    //  Need Customer Marketing Approval & Customer Marketing Approval is provided (= true)
                    if (cmat.Customer_Marketing_Approval__c == true)
                    {
                        if(cmat.Material_to_Forecast__c == null)
                        {
                            cmat.Material_to_Forecast__c = cmat.Material_Name__c;    
                        }
                        //cmat.Material_to_Forecast__c = cmat.Material_Name__c;
                    }
                        
                }
            }
         }
        
    }
    //for after context
    public static void SKUMaterialExceptionApproval(List<CIRF_Material__c> SKUMatList) {
        system.debug('---SKUMaterialExceptionApproval');
        Map<String, Boolean> labelCustMktApprovalMap = MaterialLabelHelper.getLabelCustMktApprovalMap(SKUMatList);
        List<CIRF_Material__c> matExceptionList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> plannerTaskList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> cmTaskList = new List<CIRF_Material__c>();
         for (CIRF_Material__c cm : SKUMatList) {
             //System.debug('exceptionmet '+cm.name+' CA '+cm.Creator_Approval__c+'PA '+cm.Planning_Approval__c+'CMA '+cm.Customer_Marketing_Approval__c);
            if (cm.Creator_Approval__c) {
                if (cm.Planning_Approval__c) {
                    if (cm.material_label_code__c != null && !labelCustMktApprovalMap.get(cm.material_label_code__c)) {
                        // Do nothing
                        System.debug('Do nothing sku exception labelCustMktApprovalMap');
                        //SJ - Start - HEITCIRF-616 - To create exception even if CMA is unchecked on Label Code
                        /*if (cm.Material_Status__c == 'DS' || cm.Material_Status__c == 'ID' || 
                            cm.Material_Status__c == 'IM' || cm.Material_Status__c == 'ES') {
                                //System.debug('exceptionmet '+cm.name+' '+cm.Material_Status__c);
                                matExceptionList.add(cm);
                            }*/
                        //SJ - End
                    }
                    else {
                        if(cm.Customer_Marketing_Approval__c) {
                             if (cm.Material_Status__c == 'DS' || cm.Material_Status__c == 'ID' || 
                                cm.Material_Status__c == 'IM' || cm.Material_Status__c == 'ES') {
                                    //System.debug('exceptionmet '+cm.name+' '+cm.Material_Status__c);
                                matExceptionList.add(cm);
                             }
                            else {
                                //  do nothing
                            } 
                        }
                        else
                            cmTaskList.add(cm);
                    }
                 }       
                else 
                    plannerTaskList.add(cm);
            }
        }
        
        if (!matExceptionList.isEmpty())
            S2B3Process(matExceptionList);

        if (!cmTaskList.isEmpty())
            S2CUpdate(cmTaskList);

        if (!plannerTaskList.isEmpty())
            S3Process(plannerTaskList);     
     
    }
    @TestVisible //added by Kalyani
    private static void S1DoNothing() {
        //  Do nothing
    }
    
    @TestVisible //added by Kalyani
    private static void S2AProcess(List<CIRF_Material__c> cmatList) {
        //  Do nothing here -- logic handled in BeforeInsert/BeforeUpdate
    }
    
    @TestVisible //added by Kalyani
    private static void S2B1Process(List<CIRF_Material__c> cmatList) {
        //  Exit, do nothing
    }
    
    @TestVisible //added by Kalyani
    private static void S2B3Process(List<CIRF_Material__c> cmatList) {
        system.debug('S2B3Process');
        Map<Id, CIRF_Header__c> CIRFHeaderMap = getCIRFHeaderMap (cmatList);
        
        //  Create Material Exception record
        CIRFMaterialExceptionModel.createCIRFMaterialException(cmatList, CIRFHeaderMap);
        
        //  Create CIRF General Task for Master Data
        TaskModel.createUpdateMaterialStatusTask(cmatList, CIRFHeaderMap);
        
        //  Create CIRF General Task for Customer Ops
        
        TaskModel.createUpdateMaterialExceptionTask(cmatList, CIRFHeaderMap);
    }
    
    @TestVisible
    private static void S2CUpdate(List<CIRF_Material__c> cmatList) {
        
        Map<Id, CIRF_Header__c> CIRFHeaderMap = getCIRFHeaderMap (cmatList);
        
        //  Create Approve Exception Task for Customer Marketing
        if(cmTaskCreated == false){
            TaskModel.createCMApproveExceptionTask(cmatList, CIRFHeaderMap);
            cmTaskCreated = true;
        }
    }
    
    private static void S3Process(List<CIRF_Material__c> cmatList) {
        Map<Id, CIRF_Header__c> CIRFHeaderMap = getCIRFHeaderMap(cmatList);
        system.debug('----S3Process: ' + cmatList);
        system.debug('----S3Process: ' + cmatList.size());
        TaskModel.createPlanningApproveExceptionTask(cmatList, CIRFHeaderMap);
    }
    
    public static map<Id, CIRF_Header__c> getCIRFHeaderMap (List<CIRF_Material__c> CIRFMatList) {
        map<Id, CIRF_Header__c> CIRFMatHeaderMap = new map<Id, CIRF_Header__c>();
        Set<Id> CIRFHeaderIdList = new Set<Id>();
        
        for(CIRF_Material__c cm : CIRFMatList) {
            CIRFHeaderIdList.add(cm.CIRF_Header__c);
        }
        
        map<Id, CIRF_Header__c> CIRFHeaderMap = new Map<Id, CIRF_Header__c>([select Id, CIRF_Start_Date__c, 
                                                                             CIRF_End_Date__c, Retailer__c, Retailer_Sold_To__c, 
                                                                             Retailer__r.Territory__c, Super_CIRF__c, Is_Super_CIRF__c
                                                                             from CIRF_Header__c 
                                                                             where Id in: CIRFHeaderIdList]);
        
        
        for (CIRF_Material__c cm2 : CIRFMatList) {
            CIRFMatHeaderMap.put(cm2.id, CIRFHeaderMap.get(cm2.CIRF_Header__c));
        }
        
        return CIRFMatHeaderMap;
    }
    
}