public class CIRFCorrugateTriggerHandler extends TriggerHandler{
    public static Map<Id,List<CIRF_Corrugate_Material__c>> corIdCorMatsMap;
    public static Map<Id,CIRF_Corrugate_Material__c> oldCorMatValues;
    public static map<id,CIRF_Corrugate__c>triggerOldMap;
    public static map<id,CIRF_Corrugate__c>triggerNewMap;
    
    //used to disable validations in case of submit, revise & cancel
    public static boolean allowedCIRFActions = true;
    public static boolean UpdatedFromCorMat = true;
    
    public CIRFCorrugateTriggerHandler() {
        
        triggerOldMap=(Map<Id, CIRF_Corrugate__c>) trigger.OldMap;
        triggerNewMap=(Map<Id, CIRF_Corrugate__c>) trigger.NewMap;
        system.debug('triggernewMap==>'+triggerNewMap);
        system.debug('triggerOldMap==>'+triggerOldMap);
        
    }
    
    public override void beforeInsert() {
        populateExternalID();
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE);//added by Kalyani on 10/29/2018
            //List<PermissionSetAssignment> permlst=[SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE  AssigneeId= : userinfo.getUserId() and PermissionSet.Name IN ('CIRF_Customer_Ops')];
            //if(permlst.size() > 0)
                //CIRFCorrugateTriggerHandler.CorrugateModificationCheck();
        }
        populateDefaults();
    }
    public static void CorrugateModificationCheck() {
        system.debug('Inside CorrugateModificationCheck');
        for(Sobject  corrugateId:triggerNewMap.values()){
            system.debug('Inside for=='+corrugateId);
            if((triggerNewMap.get(corrugateId.Id).Corrugate_Request_Name__c != triggerOldMap.get(corrugateId.Id).Corrugate_Request_Name__c) 
               || (triggerNewMap.get(corrugateId.Id).Number_Of_Stores__c!=triggerOldMap.get(corrugateId.Id).Number_Of_Stores__c)
               || (triggerNewMap.get(corrugateId.Id).Corrugate_Type__c!=triggerOldMap.get(corrugateId.Id).Corrugate_Type__c)
               || (triggerNewMap.get(corrugateId.Id).Number_Of_Empties__c!=triggerOldMap.get(corrugateId.Id).Number_Of_Empties__c)
               || (triggerNewMap.get(corrugateId.Id).Fully_Built__c!=triggerOldMap.get(corrugateId.Id).Fully_Built__c)
               || (triggerNewMap.get(corrugateId.id).French_Corrugate__c!=triggerOldMap.get(corrugateId.Id).French_Corrugate__c)
               || (triggerNewMap.get(corrugateId.id).Corrugate_Status__c!=triggerOldMap.get(corrugateId.Id).Corrugate_Status__c))
            {
                corrugateId.addError(System.Label.User_Corrugate_Modification_Check_Error);
            }
            
        }
    }
    
    
    public override void beforeUpdate() {
        
        if(allowedCIRFActions){ 
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE);//added by Kalyani on 10/29/2018
            //  01/31/2019 - AL - Temporarily commented out (HEITCIRF-221)
            //List<PermissionSetAssignment> permlst=[SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE  AssigneeId= : userinfo.getUserId() and PermissionSet.Name IN ('CIRF_Customer_Ops')];
            //if(permlst.size() > 0)
            //    CIRFCorrugateTriggerHandler.CorrugateModificationCheck();
        }
        List<Id> corIds = new List<Id>();
        corIdCorMatsMap = new Map<Id,List<CIRF_Corrugate_Material__c>>();
        oldCorMatValues = new Map<Id,CIRF_Corrugate_Material__c>();
        for(CIRF_Corrugate__c cc : (List<CIRF_Corrugate__c>) Trigger.new) {
            if(cc.Number_Of_Stores__c!= ((CIRF_Corrugate__c)Trigger.oldMap.get(cc.id)).Number_Of_Stores__c){
                corIds.add(cc.id);
            }
            system.debug('cc==>'+cc);
        }
        List<CIRF_Corrugate_Material__c> corMatsToUpdate = [select id, Total_Stock__c, CIRF_Corrugate__c from CIRF_Corrugate_Material__c 
                                                            where CIRF_Corrugate__c IN :corIds];
        for(CIRF_Corrugate_Material__c ccm : corMatsToUpdate) {
            oldCorMatValues.put(ccm.id, ccm);
            if(!(corIdCorMatsMap.containsKey(ccm.CIRF_Corrugate__c))){
                corIdCorMatsMap.put(ccm.CIRF_Corrugate__c, new List<CIRF_Corrugate_Material__c>());
            }
            corIdCorMatsMap.get(ccm.CIRF_Corrugate__c).add(ccm);
        }
        if(UpdatedFromCorMat)
            updateLinkedCIRFCorrugateStatus();
        
        updateEditedCIRFCorrugateStatus(); 
    }
    
    public override void beforeDelete() {
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE);//added by Kalyani on 10/29/2018
        }
        
        //HEITCIRF-273
        //Added by SJ 11/26/2018
        deleteActions();
    }
    
    public override void afterUpdate() {
        Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
        List<Id> corIds = new List<Id>();
        for(CIRF_Corrugate__c cc : (List<CIRF_Corrugate__c>) Trigger.new) {
            if(cc.Number_Of_Stores__c!= ((CIRF_Corrugate__c)Trigger.oldMap.get(cc.id)).Number_Of_Stores__c){
                corIds.add(cc.id);
            }
        }
        if(!corIds.isEmpty()){
            List<CIRF_Corrugate_Material__c> corMatsToUpdate = [select id, Total_Stock__c, CIRF_Corrugate__c, CIRF_Material__c from CIRF_Corrugate_Material__c 
                                                                where CIRF_Corrugate__c IN :corIds];
            Map<Id, CIRF_Material__c> CIRFMatIDMap = getCIRFMaterialIDMap(corMatsToUpdate);
            for(CIRF_Corrugate_Material__c ccm : corMatsToUpdate) {
                CIRF_Material__c mat = CIRFMatIDMap.get(ccm.CIRF_Material__c);
                mat.Corrugate_Units__c -= (oldCorMatValues.get(ccm.id)).Total_Stock__c;
                mat.Corrugate_Units__c += ccm.Total_Stock__c;
                if(mat.Corrugate_Units__c > 99999){
                    ((CIRF_Corrugate__c)Trigger.newMap.get(ccm.CIRF_Corrugate__c)).addError('WOW. You deserve a medal. That is a lot of Corrugate Units for this material! Please check your input values');
                }
                else{
                    CIRFMaterialsToUpdate.put(mat.id, mat);
                }
            }
            update CIRFMaterialsToUpdate.values();
        }
        
        /*List<Database.SaveResult> updateResults = Database.update(CIRFMaterialsToUpdate.values(), false);
for(Integer i=0;i<updateResults.size();i++){
if (!(updateResults.get(i).isSuccess())){
System.debug('******' + updateResults.get(i).getId());
//((CIRF_Corrugate__c)Trigger.oldMap.get(updateResults.get(i).getId())).addError('Corrugate Units outside valid range');
}
}*/
        rollDownFullyBuilt();
        
        uponCancelled();
    }
    
    //HEITCIRF-273
    //Added by SJ 11/26/2018
    private void deleteActions() {
        Map<Id,String> corIdHeaderIdMap = new Map<Id,String>();
        List<Id> corIdsMatsToDelete = new List<Id>();
        for(CIRF_Corrugate__c corr : (List<CIRF_Corrugate__c>) Trigger.old) {
            corIdHeaderIdMap.put(corr.id,corr.CIRF_Header__c);
        }
        Map<Id,CIRF_Header__c> relatedHeaders = new Map<Id,CIRF_Header__c>([select id, CIRF_Status__c, Revision__c from CIRF_Header__c 
                                                                            where id IN :corIdHeaderIdMap.values()]);
        for(CIRF_Corrugate__c corr : (List<CIRF_Corrugate__c>) Trigger.old) {
            CIRF_Header__c head = relatedHeaders.get(corr.CIRF_Header__c);
            if(head.CIRF_Status__c == 'Draft' && head.Revision__c == 0){
                //scenario 3
                corIdsMatsToDelete.add(corr.id);
            }
            else if(head.CIRF_Status__c == 'Draft' && head.Revision__c > 0){
                //scenario 6
                corr.addError('You cannot delete this corrugate. Please set the CIRF Corrugate status to Cancelled');
            }
            else if(head.CIRF_Status__c != 'Draft'){
                corr.addError('You cannot delete this material. Please revise the whole CIRF');
            }
        }
        if(!corIdsMatsToDelete.isEmpty()){
            deleteChildCorrugateMaterials(corIdsMatsToDelete);
        }
    }
    
    //HEITCIRF-273
    //Added by SJ 11/26/2018
    //Cancelled status for scenario 6
    private void uponCancelled() {
        List<Id> corIdsMatsToDelete = new List<Id>();
        for(CIRF_Corrugate__c corr : (List<CIRF_Corrugate__c>) Trigger.new) {
            if(corr.Corrugate_Status__c == 'Cancelled' && ((CIRF_Corrugate__c) trigger.oldMap.get(corr.id)).Corrugate_Status__c != 'Cancelled'){
                if(((CIRF_Corrugate__c) trigger.oldMap.get(corr.id)).Corrugate_Status__c != 'Cancelled'){
                    corIdsMatsToDelete.add(corr.id);
                }
                else{
                    corr.addError('You can Cancel from Draft status only');
                }
            }
        }
        if(!corIdsMatsToDelete.isEmpty()){
            CIRFCorrugateMaterialTriggerHandler.byPassCorMatDelActions = true;
            deleteChildCorrugateMaterials(corIdsMatsToDelete);
        }
    }
    
    private void deleteChildCorrugateMaterials(List<Id> corrIds){
        try{
            List<CIRF_Corrugate_Material__c> corMatsToDelete = [select id, CIRF_Corrugate__c from CIRF_Corrugate_Material__c where 
                                                                CIRF_Corrugate__c IN :corrIds];
            delete corMatsToDelete;
        }catch(exception ex){ 
            system.debug('Error line :'+ex.getLineNumber()+'  Error message :'+ex.getMessage());
        }
    }
    
    private void rollDownFullyBuilt(){
        List<Id> corIdCIRFMats = new List<Id>();
        for(CIRF_Corrugate__c corr : (List<CIRF_Corrugate__c>) Trigger.new) {
            if(corr.Fully_built__c == true && ((CIRF_Corrugate__c)trigger.oldMap.get(corr.id)).Fully_built__c != corr.Fully_built__c){
                corIdCIRFMats.add(corr.id);
            }
        }
        if(!corIdCIRFMats.isEmpty()){
            List<CIRF_Corrugate_Material__c> relCorMats = [select id, Fully_Built__c, CIRF_Corrugate__c, CIRF_Material__c from 
                                                           CIRF_Corrugate_Material__c where CIRF_Corrugate__c IN :corIdCIRFMats];
            Map<Id, CIRF_Material__c> CIRFMaterialsToUpdate = getCIRFMaterialIDMap(relCorMats);
            for(CIRF_Material__c cm : CIRFMaterialsToUpdate.values()) {
                cm.Fully_Built__c = true;
            }
            update CIRFMaterialsToUpdate.values();
        }
    }
    
    private void populateExternalID(){
        for(CIRF_Corrugate__c cc: (List<CIRF_Corrugate__c>) trigger.new){
            cc.Corrugate_External_Id__c = cc.CIRF_Header__c +''+ cc.Corrugate_Request_Name__c;
        }
    }
    
    //SJ - 02/11/2019 - Redone to Save on SOQL queries
    private void populateDefaults(){
        List<Id> headerIds = new List<Id>();
        for(CIRF_Corrugate__c cc: (List<CIRF_Corrugate__c>) trigger.new){
            headerIds.add(cc.CIRF_Header__c);
        }
        if(!headerIds.isEmpty()){
            Map<Id,CIRF_Header__c> headerMap = new Map<Id,CIRF_Header__c>([select id, OwnerId, CIRF_Name__c, CIRF_Status__c,Request_Type__c from CIRF_Header__c where id IN :headerIds]);
            for(CIRF_Corrugate__c cc: (List<CIRF_Corrugate__c>) trigger.new){
                CIRF_Header__c head = headerMap.get(cc.CIRF_Header__c);
                if(head.Request_Type__c == 'Singles'){
                    if(cc.Corrugate_Type__c == null || cc.Corrugate_Type__c == ''){
                        cc.Corrugate_Type__c = 'Singles Request';    
                    }
                    if(cc.Number_Of_Stores__c < 1){
                        cc.Number_Of_Stores__c = 1;    
                    }        
                }
            }
        }
    }
    
    /*private void populateDefaults(){
        for(CIRF_Corrugate__c cc: (List<CIRF_Corrugate__c>) trigger.new){
            
            if(header.Request_Type__c == 'Singles')
            {
                if(cc.Corrugate_Type__c == null || cc.Corrugate_Type__c == '')
                {
                	cc.Corrugate_Type__c = 'Singles Request';    
                }
                if(cc.Number_Of_Stores__c < 1)
                {
                	cc.Number_Of_Stores__c = 1;    
                }        
            }
        }
    }*/
    
    private static Map<Id, CIRF_Material__c> getCIRFMaterialIDMap(List<CIRF_Corrugate_Material__c> updatedCorMat){
        List<Id> CIRFMatIds = new List<Id>();
        Map<Id, CIRF_Material__c> CIRFMatIDMap = new Map<Id, CIRF_Material__c>();
        for(CIRF_Corrugate_Material__c ccm : updatedCorMat) {
            CIRFMatIds.add(ccm.CIRF_Material__c);
        }
        List<CIRF_Material__c> cmats = [select id, Material_Name__c, CIRF_Header__c,Corrugate_Units__c from CIRF_Material__c
                                        where id in :CIRFMatIds];
        for(CIRF_Material__c cmat : cmats) {
            CIRFMatIDMap.put(cmat.id, cmat);
        }
        return CIRFMatIDMap;
    }
    
    
    //  11/18/2018 - AL - HEITCIRF-238
    public static void updateMergedCIRFCorrugateStatus(List<Id> CIRFHeaderIdList) {
        List<CIRF_Corrugate__c> CIRFCorrugateUpdateList = new List<CIRF_Corrugate__c>();
        for (CIRF_Corrugate__c cc : [select id, Name, CIRF_Header__c, Corrugate_Status__c
                                     from CIRF_Corrugate__c
                                     where CIRF_Header__c in : CIRFHeaderIdList
                                     and Corrugate_Status__c != 'Cancelled']) {
                                         cc.Corrugate_Status__c = 'Merged';
                                         CIRFCorrugateUpdateList.add(cc);
                                     }
        
        if (!CIRFCorrugateUpdateList.isEmpty())
            update CIRFCorrugateUpdateList;
    }
    
    /*public static void updateLinkedCIRFCorrugateStatus(){
        set<Id> CorrugateIds=new Set<Id>();
        set<Id> CorrugatenamenullIds=new Set<Id>();
        CIRF_Corrugate__c ccs;
        for(id  corrugateId:triggerNewMap.keyset()){
            if((triggerNewMap.get(corrugateId).Corrugate_Name__c!=null && triggernewMap.get(corrugateId).SAP_Corrugate_Changes_Made__c==true) || (triggerNewMap.get(corrugateId).Corrugate_Name__c!=null)){
                ccs=triggerNewMap.get(corrugateId);
                CorrugateIds.add(ccs.Id);
                // ccs.Corrugate_Status__c='Linked'; 
                system.debug('cc===>'+ccs);
            }
            else{
                ccs=triggerNewMap.get(corrugateId);
                CorrugatenamenullIds.add(ccs.Id);
            }
        }
        for(CIRF_Corrugate__c cc : [select CIRF_Header__r.CIRF_Status__c,Corrugate_Material_Number__c,Corrugate_Status__c,SAP_Corrugate_Changes_Made__c from CIRF_Corrugate__c where id In :CorrugateIds])
        {
            if((cc.CIRF_Header__r.CIRF_Status__c == 'Cancelled' &&  triggerNewMap.get(cc.Id).Corrugate_Name__c != null) || (triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' && triggerNewMap.get(cc.Id).Corrugate_Name__c != null))
                ccs.Corrugate_Status__c='Cancelled';
            else if(cc.CIRF_Header__r.CIRF_Status__c == 'Merged')
                ccs.Corrugate_Status__c='Merged';
            else if(cc.CIRF_Header__r.CIRF_Status__c == 'Complete')
                ccs.Corrugate_Status__c='Complete';
            else if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' &&  triggerNewMap.get(cc.Id).Corrugate_Name__c != null && triggerNewMap.get(cc.Id).Corrugate_Request_Name__c==triggerOldMap.get(cc.Id).Corrugate_Request_Name__c)
                ccs.Corrugate_Status__c='Linked';
            else if(triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' && triggerNewMap.get(cc.Id).Corrugate_Name__c == null)
            {
                if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' || cc.CIRF_Header__r.CIRF_Status__c == 'Draft')
                    ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
                else
                    ccs.Corrugate_Status__c='Draft';
            }
            else
                ccs.Corrugate_Status__c='Linked';
            if((triggerNewMap.get(cc.Id).SAP_Corrugate_Changes_Made__c == false && triggerNewMap.get(cc.Id).Corrugate_Name__c != null && triggerOldMap.get(cc.Id).SAP_Corrugate_Changes_Made__c == true) || (triggerNewMap.get(cc.Id).Corrugate_Request_Name__c!=triggerOldMap.get(cc.Id).Corrugate_Request_Name__c))
                ccs.Corrugate_Status__c='Edited';
            
             CIRFHeaderTriggerHandler.Updatedfromheader=false;
        }
        for(CIRF_Corrugate__c cc : [select CIRF_Header__r.CIRF_Status__c,Corrugate_Material_Number__c,Corrugate_Status__c,SAP_Corrugate_Changes_Made__c from CIRF_Corrugate__c where id In :CorrugatenamenullIds])
        {
            if(triggerNewMap.get(cc.Id).Corrugate_Status__c =='Edited' && triggerNewMap.get(cc.Id).Corrugate_Name__c ==null){
                ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
            }
            if((triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' || triggerNewMap.get(cc.Id).Corrugate_Status__c =='Linked') && triggerNewMap.get(cc.Id).Corrugate_Name__c == null)
            {
                if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' || cc.CIRF_Header__r.CIRF_Status__c == 'Draft')
                    ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
                else
                    ccs.Corrugate_Status__c='Draft';
            }
        }
    }*/
    
    //SJ - 02/11/2019 - Optimized SOQL version
    public static void updateLinkedCIRFCorrugateStatus(){
        set<Id> CorrugateIds=new Set<Id>();
        set<Id> CorrugatenamenullIds=new Set<Id>();
        CIRF_Corrugate__c ccs;
        for(id  corrugateId:triggerNewMap.keyset()){
            if((triggerNewMap.get(corrugateId).Corrugate_Name__c!=null && triggernewMap.get(corrugateId).SAP_Corrugate_Changes_Made__c==true) || (triggerNewMap.get(corrugateId).Corrugate_Name__c!=null)){
                ccs=triggerNewMap.get(corrugateId);
                CorrugateIds.add(ccs.Id);
                system.debug('cc===>'+ccs);
            }
            else{
                ccs=triggerNewMap.get(corrugateId);
                CorrugatenamenullIds.add(ccs.Id);
            }
        }
        if(!CorrugateIds.isEmpty()){
            List<CIRF_Corrugate__c> corList1 = [select CIRF_Header__r.CIRF_Status__c,Corrugate_Material_Number__c,Corrugate_Status__c,SAP_Corrugate_Changes_Made__c from CIRF_Corrugate__c where id In :CorrugateIds];
            for(CIRF_Corrugate__c cc : corList1){
                if((cc.CIRF_Header__r.CIRF_Status__c == 'Cancelled' &&  triggerNewMap.get(cc.Id).Corrugate_Name__c != null) || (triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' && triggerNewMap.get(cc.Id).Corrugate_Name__c != null))
                    ccs.Corrugate_Status__c='Cancelled';
                else if(cc.CIRF_Header__r.CIRF_Status__c == 'Merged')
                    ccs.Corrugate_Status__c='Merged';
                else if(cc.CIRF_Header__r.CIRF_Status__c == 'Complete')
                    ccs.Corrugate_Status__c='Complete';
                else if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' &&  triggerNewMap.get(cc.Id).Corrugate_Name__c != null && triggerNewMap.get(cc.Id).Corrugate_Request_Name__c==triggerOldMap.get(cc.Id).Corrugate_Request_Name__c)
                    ccs.Corrugate_Status__c='Linked';
                else if(triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' && triggerNewMap.get(cc.Id).Corrugate_Name__c == null){
                    if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' || cc.CIRF_Header__r.CIRF_Status__c == 'Draft')
                        ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
                    else
                        ccs.Corrugate_Status__c='Draft';
                }
                else
                    ccs.Corrugate_Status__c='Linked';
                if((triggerNewMap.get(cc.Id).SAP_Corrugate_Changes_Made__c == false && triggerNewMap.get(cc.Id).Corrugate_Name__c != null && triggerOldMap.get(cc.Id).SAP_Corrugate_Changes_Made__c == true) || (triggerNewMap.get(cc.Id).Corrugate_Request_Name__c!=triggerOldMap.get(cc.Id).Corrugate_Request_Name__c))
                    ccs.Corrugate_Status__c='Edited';
                
                CIRFHeaderTriggerHandler.Updatedfromheader=false;
            }
        }
        if(!CorrugatenamenullIds.isEmpty()){
            List<CIRF_Corrugate__c> corNameNullList = [select CIRF_Header__r.CIRF_Status__c,Corrugate_Material_Number__c,Corrugate_Status__c,SAP_Corrugate_Changes_Made__c from CIRF_Corrugate__c where id In :CorrugatenamenullIds];
            for(CIRF_Corrugate__c cc : corNameNullList){
                if(triggerNewMap.get(cc.Id).Corrugate_Status__c =='Edited' && triggerNewMap.get(cc.Id).Corrugate_Name__c ==null){
                    ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
                }
                if((triggerNewMap.get(cc.Id).Corrugate_Status__c =='Cancelled' || triggerNewMap.get(cc.Id).Corrugate_Status__c =='Linked') && triggerNewMap.get(cc.Id).Corrugate_Name__c == null){
                    if(cc.CIRF_Header__r.CIRF_Status__c == 'Loaded' || cc.CIRF_Header__r.CIRF_Status__c == 'Draft')
                        ccs.Corrugate_Status__c=cc.CIRF_Header__r.CIRF_Status__c;
                    else
                        ccs.Corrugate_Status__c='Draft';
                }
            }
        }
    }
    
    public static void updateEditedCIRFCorrugateStatus(){
        system.debug('Inside edit');
        for(id  corrugateId:triggerNewMap.keyset()){
            if(triggerNewMap.get(corrugateId).Corrugate_Status__c != 'Cancelled' && (triggerNewMap.get(corrugateId).Corrugate_Request_Name__c!=triggerOldMap.get(corrugateId).Corrugate_Request_Name__c && triggerNewMap.get(corrugateId).Corrugate_Name__c != null)
               ||(triggerNewMap.get(corrugateId).Corrugate_Type__c!=triggerOldMap.get(corrugateId).Corrugate_Type__c && triggerNewMap.get(corrugateId).Corrugate_Name__c != null)){
                   CIRF_Corrugate__c cc=triggerNewMap.get(corrugateId);
                   cc.SAP_Corrugate_Changes_Made__c=false;
                   cc.Corrugate_Status__c='Edited'; 
                   system.debug('cc===>'+cc);
               }
        }
    }
    
}