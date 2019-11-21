public class CIRFMaterialTriggerHandler extends TriggerHandler {
    public List<Task> taskList;
    
    public  List<CIRF_Material__c> currentCIRFMatList;
    public List<CIRF_Material__c> subMatList;
    public Map<Id, CIRF_Material__c> triggerOldMap;
    public Map<Id, CIRF_Material__c> triggerNewMap;
    public List<CIRF_Material__c> triggerOld;
    
    //used to disable validations in case of submit, revise & cancel
    public static boolean allowedCIRFActions = true;
    
    //HEITCIRF-458
    public static boolean cancelledByTask = false;
    
    public CIRFMaterialTriggerHandler() {
        
        triggerOldMap = (Map<Id, CIRF_Material__c>) trigger.OldMap;
        triggerNewMap = (Map<Id, CIRF_Material__c>) trigger.NewMap;
        triggerOld = (List<CIRF_Material__c>) trigger.Old;
        if (trigger.isInsert || trigger.isUpdate)
            currentCIRFMatList = (List<CIRF_Material__c>) trigger.new;
        else
            currentCIRFMatList = (List<CIRF_Material__c>) trigger.old; 
    }
    
    public override void beforeInsert() {
        subMatList = new List<CIRF_Material__c>();
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_MATERIALS);//added by Kalyani on 10/29/2018
        }
        
        for(CIRF_Material__c cm : currentCIRFMatList) 
        {
            CIRF_Material__c oldCM = new CIRF_Material__c();
            if(Trigger.isUpdate){
                oldCM = triggerOldMap.get(cm.id);
            }
            if((cm.Material_Number__c!='' || cm.Material_Number__c != null) || (Trigger.isUpdate && cm.Material_Name__c != oldCM.Material_Name__c)) {
                cm.External_Id__c = cm.CIRF_Header__c + '-' + cm.Material_Number__c;
            }
            if (cm.CIRF_Material_Status__c == 'Submitted')
                subMatList.add(cm);
        }
        
        updateUniqueCatalog(currentCIRFMatList);
        needsRegieStickerUpdate();
         //if (!subMatList.isEmpty() && subMatList.size() > 0)
        //CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(currentCIRFMatList, triggerOldMap);
        //CIRFMaterialStatusCheck.approvalCheck(currentCIRFMatList);
        
        
    }
    
    public override void beforeUpdate() {
        //HEITCIRF-266
        checkIfLocked();
        uponCancelledBefore();
        needsRegieStickerUpdate();
        subMatList = new List<CIRF_Material__c>();
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_MATERIALS);//added by Kalyani on 10/29/2018
        }
        System.debug('Before Update running');       
        resetCIRFMaterialApproval();
        
        System.debug('currsize '+currentCIRFMatList.size()); 
        //currentCIRFMatList.size();
        
        for (CIRF_Material__c cmat : currentCIRFMatList) {
            if (cmat.CIRF_Material_Status__c == 'Submitted')
                subMatList.add(cmat); 
                 
            //HEITCIRF-675
            system.debug('****triggeroldMap.get(cm.Id).Material_Name__c'+triggeroldMap.get(cmat.Id).Material_Name__c);
            system.debug('*****cm.Material_Name__c'+cmat.Material_Name__c);
            
            if(triggernewMap.get(cmat.Id).Material_Name__c != triggeroldMap.get(cmat.Id).Material_Name__c && cmat.CIRF_Material_Status__c == 'Draft')
            {
                system.debug('****inside if');
                cmat.Needs_Regie_Sticker__c = false;
                cmat.Height__c = null;
                cmat.Width__c = null;
                cmat.Length__c = null;
                cmat.Split_Forecast__c = false;
                cmat.Retail_Price_Sticker__c = false;
                cmat.On_Hand_Qty__c = null;
                cmat.Version_Material_Names__c = null;
                cmat.Base_Material_Name__c = null;
                cmat.Material_to_Forecast__c = null;
            } 
        }
        CIRFMaterialValidation.CIRFMaterialValidationBefore(triggernewMap,triggerOldMap);
        CIRFMaterialStatusCheck.approvalCheck(currentCIRFMatList);
        //  AL - 12/7/2018 -  Move Approoval Check to after MaterialValidation
        system.debug('subMatList before: ' + subMatList);
        if (!subMatList.isEmpty() && subMatList.size() > 0) {     
            system.debug('CIRFMaterialTriggerHandler - before method');
            //CIRFMaterialValidation.CIRFMaterialValidationBefore(triggernewMap,triggerOldMap);
            //CIRFMaterialStatusCheck.approvalCheck(currentCIRFMatList);
        
       }
                       
    }
    
    public override void beforeDelete() {
        //  Perform CIRF Validation
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_MATERIALS);//added by Kalyani on 10/29/2018
        }
        //HEITCIRF-273
        deleteActions();
        System.debug('Delete Complete');
    }
    
    public override void afterDelete() {
        
    }
        
    public override void afterInsert() {
        
        
        List<Id> chIds = new List<Id>();
        for(CIRF_Material__c cm : currentCIRFMatList)
        { 
            chIds.add(cm.CIRF_Header__c);
        }
        
        //resetRIMApproval();
        Map<id,CIRF_Header__c> CIRFHeaders = new Map<id,CIRF_Header__c>([select id,CIRF_Status__c,Retailer__c,RIM_Approval__c,RIM_Approval_Reason__c,Request_Type__c,Studio__c from CIRF_Header__c where id IN : chIds]);
        
        subMatList = getSubmittedCIRFMat(currentCIRFMatList, triggerOldMap);
        
        if (subMatList != null && subMatList.isEmpty() == true) {
            validateBOM(subMatList, triggerOldMap);
            //
            //CIRFMaterialStatusCheck.CIRFMaterialStatusCheckAfter(subMatList, triggerOldMap);
        }
    }
    
    public override void afterUpdate() {
        triggerNewMap = (Map<Id, CIRF_Material__c>) trigger.NewMap;
        triggeroldMap = (Map<Id, CIRF_Material__c>) trigger.oldMap;
        List<id> keys = new List<id>(triggerNewMap.keySet());
        //CIRFMaterialValidation.CIRFMaterialValidationAfter(triggernewMap,triggeroldMap);
        CIRFMaterialValidation.CIRFMaterialValidationAfter(triggernewMap,triggerOldMap);
         map<id,CIRF_Header__c>canadaTerritoryMap=new map<id,CIRF_Header__c>();
      
        List<CIRF_Material__c> mergedMatList = new List<CIRF_Material__c>();
        subMatList = new List<CIRF_Material__c>();
               
        List<Id> chIds = new List<Id>();
        for(CIRF_Material__c cm : currentCIRFMatList){ 
            system.debug('---afterUpdate - CIRF Material: ' + cm);
            //system.debug('------Super CIRF Id: ' + cm.Super_CIRF__c);
            //system.debug('------New CIRF Material Status: ' + cm.CIRF_Material_Status__c);
            //system.debug('------Old CIRF Material Status: ' + TriggerOldMap.get(cm.Id).CIRF_Material_Status__c);
            //system.debug('------Material Status: ' + cm.Material_Status__c);
            //system.debug('canadaTerritoryMap.keyset().contains(cm.CIRF_Header__c) ' + canadaTerritoryMap.keyset().contains(cm.CIRF_Header__c));
            //system.debug('m.Material_Name__r.recordType.Name'+cm.Material_Name__r.recordType.Name);
            //system.debug('cm.Needs_Regie_Sticker__c'+cm.Needs_Regie_Sticker__c);
            
            
           //************************************************************************************** 
            
            
            if(cm.CIRF_Material_Status__c == 'Submitted') {
                //  && TriggerOldMap.get(cm.Id).CIRF_Material_Status__c == 'Draft') {
                chIds.add(cm.CIRF_Header__c);
                subMatList.add(cm);
            }
            else
            //  11/16/2013 - AL - HEITCIRF-335
            if (cm.CIRF_Material_Status__c == 'Cancelled'
                && TriggerOldMap.get(cm.Id).CIRF_Material_Status__c != cm.CIRF_Material_Status__c
                && cm.Super_CIRF_Status__c != 'Draft') {
                mergedMatList.add(cm);
            }
              
             //HEITCIRF-387
            if((triggeroldMap.get(cm.Id).split_forecast__c == false && triggernewMap.get(cm.Id).split_forecast__c == true) && cm.CIRF_Material_Status__c == 'Loaded')
            {
                boolean split = true;
                //CIRFCreateForecastRecords.CreateForecastRecords(cm.CIRF_Header__c, cm.id,split);
                CIRFCreateForecastRecords2.CreateForRecords(cm.CIRF_Header__c, split);
            }
           /* if((triggeroldMap.get(cm.Id).CIRF_Material_Status__c == 'Submitted' || triggeroldMap.get(cm.Id).CIRF_Material_Status__c == 'Loaded') && triggernewMap.get(cm.Id).CIRF_Material_Status__c == 'Merged') 
            {
                boolean split = false;
                CIRFCreateForecastRecords2.CreateForRecords(cm.CIRF_Header__c,split);
            }
            *///Moved to CIRFHeaderTriggerHandler
        } 
        // 11/20/2018 - SM - HEITCIRF-272 
        updateCorrugate((Map<Id,CIRF_Material__c>) trigger.newMap , (Map<Id,CIRF_Material__c>) trigger.oldMap);
        
        system.debug('---subMatList: ' + subMatList);
                       
        if (!subMatList.isEmpty()) {
            validateBOM(subMatList, triggerOldMap);
            //CIRFMaterialStatusCheck.CIRFMaterialStatusCheckAfter(subMatList, triggerOldMap);
        }
       //CIRFMaterialStatusCheck.CIRFMaterialStatusCheckAfter(currentCIRFMatList, triggerOldMap);
        //  11/16/2013 - AL - HEITCIRF-335
        if (!mergedMatList.isEmpty()) {
            cancelSuperCIRFMaterials(mergedMatList);
        }
        system.debug('@@@@@afterUpdate');
        statusToLoaded((Map<Id,CIRF_Material__c>) trigger.newMap);
        uponCancelled();
    }
    
    // 11/20/2018 - SM - HEITCIRF-272
    // 02/15/2019 - SJ - Optimised     
    private void updateCorrugate(Map<Id,CIRF_Material__c> cmatNew ,Map<Id,CIRF_Material__c> cmatOld) {
        List<Id> cmatIds = new List<Id>();
        Map<Id,List<CIRF_Corrugate_Material__c>> corrMatMap = new Map<Id,List<CIRF_Corrugate_Material__c>>();
        List<CIRF_Corrugate_Material__c> toUpdateCorr = new List<CIRF_Corrugate_Material__c>();
        //Map<Id,CIRF_Corrugate_Material__c> toDeleteCorMatMap = new Map<Id,CIRF_Corrugate_Material__c>();
        for(CIRF_Material__c cm : cmatNew.values()){
            if(cm.Material_Name__c!=cmatOld.get(cm.Id).Material_Name__c){
                cmatIds.add(cm.id);
            }
        }
        if(!cmatIds.isEmpty()){
            List <CIRF_Corrugate_Material__c>  ccorr= [select id,Material_Name__c,CIRF_Material__c from CIRF_Corrugate_Material__c where CIRF_Material__c in :cmatIds];
            for(CIRF_Corrugate_Material__c cc : ccorr){
                if(!corrMatMap.containsKey(cc.CIRF_Material__c)){
                    corrMatMap.put(cc.CIRF_Material__c,new List<CIRF_Corrugate_Material__c>());
                }
                corrMatMap.get(cc.CIRF_Material__c).add(cc);
            }
            for(CIRF_Material__c cm : cmatNew.values()){
                if(cm.Material_Name__c!=cmatOld.get(cm.Id).Material_Name__c && corrMatMap.containsKey(cm.id)){
                    for(CIRF_Corrugate_Material__c corrMat : corrMatMap.get(cm.id)){
                        corrMat.Material_Name__c = cm.Material_Name__c;
                        //CIRF_Utility.allowTriggerUpdate.put(corrMat.id,true);
                        toUpdateCorr.add(corrMat);
                    }                
                }
                /*else if(cm.CIRF_Material_Status__c=='Cancelled' && cm.CIRF_Material_Status__c!=cmatOld.get(cm.id).CIRF_Material_Status__c && corrMatMap.containsKey(cm.id)){
//toDeleteCorr.addAll(corrMatMap.get(cm.id));
for(CIRF_Corrugate_Material__c corrMat : corrMatMap.get(cm.id)){
toDeleteCorMatMap.put(corrMat.Id,corrMat);
}
}*/
            }
            if(!toUpdateCorr.isEmpty()){
                CIRFCorrugateMaterialTriggerHandler.UpdatedFromMaterial = true;
                update toUpdateCorr;
            }
            //if(!toDeleteCorMatMap.values().isEmpty())
            //delete toDeleteCorMatMap.values();
        }
    }
    
    private List<CIRF_Material__c> getSubmittedCIRFMat(List<CIRF_Material__c> currCIRFMatList, Map<Id, CIRF_Material__c> triggerOldMap) {
        
        system.debug('@@@@getSubmittedCIRFMat');
        List<CIRF_Material__c> subMatList = new List<CIRF_Material__c>();
        for (CIRF_Material__c cmat : currCIRFMatList) {
            if (cmat.CIRF_Material_Status__c == 'Submitted')
                subMatList.add(cmat);
        }
        return subMatList;
    }
    
    public static void validateBOM (List<CIRF_Material__c> currCIRFMatList, Map<Id, CIRF_Material__c> triggerOldMap) {
        system.debug('validateBOM');
        List<CIRF_Material__c> BOMRequiredList = new List<CIRF_Material__c>();
        List<CIRF_Material__c> PIRRequiredList = new List<CIRF_Material__c>();
        Map<Id, CIRF_Header__c> CIRFHeaderMap = CIRFMaterialStatusCheck.getCIRFHeaderMap (currCIRFMatList);
        
        for (CIRF_Material__c cm : currCIRFMatList) {
            
            if (cm.CIRF_Material_Status__c == 'Submitted' && (cm.CIRF_Material_Status__c <> triggerOldMap.get(cm.Id).CIRF_Material_Status__c))
            {     
                if(cm.BOM_Required__c == true) {
                    if(cm.BOM_Exists__c == false) {
                        BOMRequiredList.add(cm);
                    }
                    if(cm.PIR_Flag__c == false) {
                        PIRRequiredList.add(cm);
                    }
                }            
            }                
        }
        
        if (!PIRRequiredList.IsEmpty() && PIRRequiredList.size() > 0)  
            TaskModel.createPIRTask(PIRRequiredList, CIRFHeaderMap);
        
        if (!BOMRequiredList.isEmpty() && BOMRequiredList.size() > 0)  
            TaskModel.createFinalizeTask(BOMRequiredList, CIRFHeaderMap);
    }
    
       
    public static void updateUniqueCatalog(List<CIRF_Material__c> currentCIRFMatList) {
        for (CIRF_Material__c cmat : currentCIRFMatList) {
            if (!String.isEmpty(cmat.Old_Material_Number__c)) {
                cmat.Catalog_vs_VAS__c = 'VAS';
                cmat.Unique_vs_National__c = 'Unique';
            }
            else {
                cmat.Catalog_vs_VAS__c = 'Catalog';
                cmat.Unique_vs_National__c = 'National';
            }
        }
        
    }
    
    
    private void resetCIRFMaterialApproval() {
        List<Id> cmatIdsforDelCorrMats = new List<Id>();
        for(CIRF_Material__c cmat : currentCIRFMatList) {
            if(cmat.CIRF_Material_Status__c == 'Draft' && /*SJ - 01/29/2019 - HEITCIRF-642*/cancelledByTask == false) {
                if((cmat.Units_to_Order__c!=(triggerOldMap.get(cmat.id)).Units_to_Order__c)||
                   (cmat.Replen_Units__c!=(triggerOldMap.get(cmat.id)).Replen_Units__c)||
                   (cmat.Material_Name__c!=(triggerOldMap.get(cmat.id)).Material_Name__c)) {
                       cmat.Planning_Approval__c = false;
                       cmat.Customer_Marketing_Approval__c = false;
                       cmat.Planning_Forecast_Approval__c = false;
                   }
            }
        }
    }
    
    //SJ - 02/15/2019 - Optimised
    //If all materials are loaded, change the header status to loaded
    public static void statusToLoaded(Map<id,CIRF_Material__c> CIRFMaterial){
        List<Id> headerIds= new List<Id>();
        Map<Id,CIRF_Header__c> headersToUpdate = new Map<Id,CIRF_Header__c>();
        for(CIRF_Material__c cm: CIRFMaterial.values()){
            if(cm.CIRF_Material_Status__c=='Loaded' && ((CIRF_Material__c)Trigger.oldMap.get(cm.id)).CIRF_Material_Status__c != 'Loaded'){
                headerIds.add(cm.CIRF_Header__c);
            }
        }
        if(!headerIds.isEmpty()){
            Map<id,CIRF_Header__c> relHeader= new Map<id,CIRF_Header__c>([select id,(select id, name, CIRF_Header__c, CIRF_Material_Status__c  
                                                                                     from CIRF_Materials__r where CIRF_Material_Status__c NOT IN ('Loaded','Cancelled','Merged'))  
                                                                          from CIRF_Header__c where id IN :headerIds]);
            for(CIRF_Material__c cm: CIRFMaterial.values()){
                if(cm.CIRF_Material_Status__c=='Loaded' && ((CIRF_Material__c)Trigger.oldMap.get(cm.id)).CIRF_Material_Status__c != 'Loaded'){
                    CIRF_Header__c head = relHeader.get(cm.CIRF_Header__c);
                    System.debug(head.CIRF_Materials__r);
                    if((head.CIRF_Materials__r).isEmpty()) {
                        head.CIRF_Status__c = 'Loaded';
                        headersToUpdate.put(head.id,head);
                    }
                }
            }
            if(!headersToUpdate.values().isEmpty()){
                update headersToUpdate.values();
            }
        }
    }
    
    //for HEITCIRF-195 Scenario 1
   /* public static void OnRIMApproval(Map<id,CIRF_Header__c> CIRFHeaders){
        System.debug(CIRFHeaders.values());        
        Map<Id,CIRF_Header__c> relCIRFMaterials = new Map<Id,CIRF_Header__c>([select id,(select id, name, CIRF_Header__c, CIRF_Material_Status__c, RIM_Approval__c,RIM_Approval_Reason__c
                                                                                         from CIRF_Materials__r where  CIRF_Material_Status__c != 'Cancelled')
                                                                              from CIRF_Header__c where id IN :CIRFHeaders.keyset()]);
        
        List<CIRF_Material__c> newcm = new List<CIRF_Material__c>();
        
        for(CIRF_Header__c ch : (List<CIRF_Header__c>)CIRFHeaders.values()){
            if(ch.CIRF_Status__c =='Submitted' && ch.RIM_Approval__c==true && ch.RIM_Approval_Reason__c!=NULL && relCIRFMaterials.get(ch.id) != null && relCIRFMaterials.get(ch.id).CIRF_Materials__r != null){
                for(CIRF_Material__c cmat : relCIRFMaterials.get(ch.id).CIRF_Materials__r){
                    cmat.RIM_Approval__c = true;
                    cmat.RIM_Approval_Reason__c = ch.RIM_Approval_Reason__c;
                    newcm.add(cmat);
                }
            }
        }
        update newcm;
    }*/
    
    /*public void resetRIMApproval(){
        List<Id> headerIds = new List<Id>();
        for(CIRF_Material__c cm : (List<CIRF_Material__c>) trigger.new){
            headerIds.add(cm.CIRF_Header__c);
        }
        List<CIRF_Header__c> relatedHeaders = [select id, RIM_Approval__c, RIM_Approval_Reason__c, CIRF_Status__c from CIRF_Header__c 
                                               where (CIRF_Status__c = 'Draft' OR CIRF_Status__c = 'Submitted') AND id IN :headerIds];
        for(CIRF_Header__c header : relatedHeaders){
            header.RIM_Approval__c = false;
            header.RIM_Approval_Reason__c = '';
        }
        update relatedHeaders;
    }*/


    //  11/16/2018 - AL - HEITCIRF-335
    public static void updateSuperCIRFMaterials(List<CIRF_Material__c> mergedCIRFMatList) {
        Map<Id, CIRF_Material__c> triggerOldMap = (Map<Id, CIRF_Material__c>) trigger.oldMap;
        List<CIRF_Material__c>  superCIRFMatList = new List<CIRF_Material__c>();
        List<String> parmIdList = new List<String>();
        List<List<String>> mergeParmList = new List<List<String>>();
        List<String> SuperCIRFHeaderList = new List<String>();
        List<String> ChildrenCIRFHeaderList = new List<String>();

        for (CIRF_Material__c cm : mergedCIRFMatList) {
            SuperCIRFHeaderList.add(cm.Super_CIRF__c);
            ChildrenCIRFHeaderList.add(cm.CIRF_Header__c);
       }

       SuperCIRFMergeHelper.remergeCIRFs(SuperCIRFHeaderList, ChildrenCIRFHeaderList);

        //parmIdList.addAll(SuperCIRFHeaderList);
        //parmIdList.addAll(ChildrenCIRFHeaderList);
        //mergeParmList.add(parmIdList);
        //system.debug('mergeParmList: ' + mergeParmList);
        //List<String> returnMsg = SuperCIRFMergeHelper.mergeCIRFs(mergeParmList);
 
    }

    public static void cancelSuperCIRFMaterials(List<CIRF_Material__c> cancelCIRFMatList) {

        List<Id> SuperCIRFHeaderList = new List<Id>();
        List<String> cancelMatList = new List<String>();

        for (CIRF_Material__c cm : cancelCIRFMatList) {
            SuperCIRFHeaderList.add(cm.Super_CIRF__c);
            cancelMatList.add(cm.Material_Name__c);
         }

        SuperCIRFMergeHelper.cancelSuperCIRFMaterials(SuperCIRFHeaderList, cancelMatList);

    }

    //  11/18/2018 - AL - HEITCIRF-238
    public static void updateMergedCIRFMaterialStatus(List<Id> CIRFHeaderIdList) {
        List<CIRF_Material__c> CIRFMaterialList = [select id, name, CIRF_Header__c, Material_Number__c
                                                   from CIRF_Material__c
                                                   where CIRF_Header__c in : CIRFHeaderIdList
                                                   and CIRF_Material_Status__c != 'Cancelled'];
        for (CIRF_Material__c cm : CIRFMaterialList) {
            cm.CIRF_Material_Status__c = 'Merged';
        }
        allowedCIRFActions = false; ///RB2 Fixing update errors
        update CIRFMaterialList;
    }
    
    //HEITCIRF-273
    //Added by SJ 11/26/2018
    private void deleteActions() {
        Boolean corMatPresent = false;
        Map<Id,String> cmatIdHeadIdMap = new Map<Id,String>();
        List<Id> cmatIdsforDelCorrMats = new List<Id>();
        for(CIRF_Material__c cm : (List<CIRF_Material__c>) trigger.old){
            cmatIdHeadIdMap.put(cm.id,cm.CIRF_Header__c);
        }
        Map<Id,CIRF_Header__c> relatedHeaders = new Map<Id,CIRF_Header__c>([select id, CIRF_Status__c, Revision__c, Is_Super_CIRF__c from CIRF_Header__c 
                                                                            where id IN :cmatIdHeadIdMap.values()]);
        for(CIRF_Material__c cm : (List<CIRF_Material__c>) trigger.old){
            CIRF_Header__c head = relatedHeaders.get(cm.CIRF_Header__c);
            if(head.CIRF_Status__c == 'Draft' && head.Revision__c == 0){
                //scenario 1
                cmatIdsforDelCorrMats.add(cm.id);
                corMatPresent = true;
            }
            else if(head.CIRF_Status__c == 'Draft' && head.Revision__c > 0 && !head.Is_Super_CIRF__c){
                //scenario 4
                cm.addError('You cannot delete this material. Please set the CIRF Material status to Cancelled');
            }
            else if(head.CIRF_Status__c != 'Draft' && !head.Is_Super_CIRF__c) {
                //Scenario 7
                cm.addError('You cannot delete this material. Please revise the whole CIRF.');
            }
        }
        if(corMatPresent == true){
            //Delete associated Corrugate Materials (Scenario 1)
            deleteRelatedCorrugateMaterials(cmatIdsforDelCorrMats);
        }
    }
    
    //HEITCIRF-273
    //Added by SJ 11/26/2018
    //cancelled status for scenario 4
    private void uponCancelled() {
        List<Id> cmatIdsforDelCorrMats = new List<Id>();
        //Map<Id, CIRF_Header__c> cirfHeaderMap = CIRFMaterialStatusCheck.getCIRFHeaderMap(currentCIRFMatList);
        for(CIRF_Material__c cmat : currentCIRFMatList) {
            system.debug('Super CIRF: ' + cmat.CIRF_Header__r + ' ' + cmat.CIRF_Header__r.Is_Super_CIRF__c);

            if(cmat.CIRF_Material_Status__c == 'Cancelled' && (triggerOldMap.get(cmat.id)).CIRF_Material_Status__c != 'Cancelled'){
                if((triggerOldMap.get(cmat.id)).CIRF_Material_Status__c == 'Draft' || cancelledByTask == true){
                    cmatIdsforDelCorrMats.add(cmat.id);
                }
                else {
                    //if (cirfHeaderMap.get(cmat.id).Is_Super_CIRF__c != true) 
                        cmat.addError('You can Cancel from Draft status only');
                }
            }
        }
        if(!cmatIdsforDelCorrMats.isEmpty()){
            deleteRelatedCorrugateMaterials(cmatIdsforDelCorrMats);
        }
    }
    
    private void deleteRelatedCorrugateMaterials(List<Id> cmatIds){
        List<CIRF_Corrugate_Material__c> corMatsToDelete = [select id, CIRF_Material__c from CIRF_Corrugate_Material__c where 
                                                          CIRF_Material__c IN :cmatIds];
            delete corMatsToDelete;
    }
    
    private void checkIfLocked() {
        Map<Id,String> headerIds = new Map<Id,String>();
        for(CIRF_Material__c cm: (List<CIRF_Material__c>) trigger.old){
            if(cm.CIRF_Material_Status__c == 'Cancelled')
                headerIds.put(cm.id, cm.CIRF_Header__c);
        }
        if(!headerIds.values().isEmpty()){
            Map<id,CIRF_Header__c> relatedCIRFHeader= new Map<id,CIRF_Header__c>([select id,CIRF_Status__c from CIRF_Header__c where id IN :headerIds.values()]);
            for(Id matId : headerIds.keyset()){
                CIRF_Material__c curMat = (CIRF_Material__c)trigger.newMap.get(matId);
                CIRF_Header__c curHead = relatedCIRFHeader.get(curMat.CIRF_Header__c);
                if(curHead.CIRF_Status__c != 'Draft' && UserInfo.getProfileId() != Label.Profile_System_Admins){
                    curMat.addError('This CIRF Material is locked for all users except System Admins');
                }
                else if(curHead.CIRF_Status__c == 'Draft'){
                    if(curMat.CIRF_Material_Status__c != 'Draft' && curMat.CIRF_Material_Status__c != ((CIRF_Material__c)trigger.oldMap.get(curMat.id)).CIRF_Material_Status__c){
                        curMat.addError('The user can only set the CIRF Material status to Draft from Cancelled');
                    }
                }
            }
        }
    }
    
    //upon cancellation set corrugate units to 0
    private void uponCancelledBefore() {
        for(CIRF_Material__c cmat : (List<CIRF_Material__c>)trigger.new){
            if(cmat.CIRF_Material_Status__c == 'Cancelled' && cmat.CIRF_Material_Status__c != ((CIRF_Material__c)trigger.oldMap.get(cmat.id)).CIRF_Material_Status__c){
                cmat.Corrugate_Units__c = 0;
            }
        }
    }
    
    //HEITCIRF-254
    //SJ - 02/15/2019 - Optimised
    private void needsRegieStickerUpdate(){
        list<id>materiallistId=new list<id>(); 
        list<id>HeaderId=new list<id>(); 
        for(CIRF_Material__c cm : currentCIRFMatList){
            if(Trigger.oldMap==null || cm.Material_Name__c != ((CIRF_Material__c)Trigger.oldMap.get(cm.id)).Material_Name__c){
                materiallistId.add(cm.Material_Name__c);
                HeaderId.add(cm.CIRF_Header__c);
            }
        }
        if(!materiallistId.isEmpty()){
            map<id,CIRF_Header__c>canadaTerritoryMap=new map<id,CIRF_Header__c>([select id from CIRF_Header__c where Territory__c in ('CDN') AND Id in:HeaderId]);
            list<Material__c> materialWithClassificationList=[select id,(select id,recordtype.name,Regie_Sticker_for_Canada__c from Classifications__r where material__c in:materiallistId order by RecordType.Name DESC) from Material__c where id in:materiallistId];   
            list<Classification__c>classificationList=new list<Classification__c>();
            //system.debug('currentCIRFMatList=='+currentCIRFMatList);
            for(CIRF_Material__c cm : currentCIRFMatList){     
                if(canadaTerritoryMap.keyset().contains(cm.CIRF_Header__c)){
                    //system.debug(materialWithClassificationList+'materialWithClassificationList');  
                    for(Material__c mwc: materialWithClassificationList){
                        if(mwc.id==cm.material_name__c){
                            if(mwc.Classifications__r.size()>0){
                                for(Classification__c c:mwc.Classifications__r){
                                    if(c.recordType.Name=='General' && c.Regie_Sticker_for_Canada__c=='Y - Yes'){
                                        cm.Needs_Regie_Sticker__c=true;
                                    }else{
                                        cm.Needs_Regie_Sticker__c=false;
                                    }
                                }
                            }else{
                                cm.Needs_Regie_Sticker__c=false;
                            }   
                        }
                    }
                }
            }
        }
    }
}