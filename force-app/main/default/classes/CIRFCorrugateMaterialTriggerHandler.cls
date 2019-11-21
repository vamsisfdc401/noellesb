public class CIRFCorrugateMaterialTriggerHandler extends TriggerHandler {
    public static Boolean isFirstTime = true;
    public Static Boolean UpdatedFromMaterial = false;
    public static map<id,CIRF_Corrugate_Material__c>triggerOldMap;
    public static map<id,CIRF_Corrugate_Material__c>triggerNewMap;
    public static List<CIRF_Corrugate_Material__c> classUpdCIRFCorMat;
    
    //used to disable validations in case of submit, revise & cancel
    public static boolean allowedCIRFActions = true;
    
    public static Boolean byPassCorMatDelActions = false;
    
    public CIRFCorrugateMaterialTriggerHandler() {
        triggerOldMap=(Map<Id, CIRF_Corrugate_Material__c>) trigger.OldMap;
        triggerNewMap=(Map<Id, CIRF_Corrugate_Material__c>) trigger.NewMap;
        system.debug('triggernewMap==>'+triggerNewMap);
        system.debug('triggerOldMap==>'+triggerOldMap);
        
    }
    
    public override void beforeInsert() {
        populateExternalID();
        if(allowedCIRFActions){
            //CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE_MATERIALS);//added by Kalyani on 10/29/2018
        }
        
    }
    
    public override void beforeUpdate() {
        populateExternalID();
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE_MATERIALS);//added by Kalyani on 10/29/2018
        }
        //
        //updateTotalUnits();
    }
    
    
    public override void afterInsert() {
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE_MATERIALS);//added by Kalyani on 10/29/2018
        }
        //SJ - SAPCorrugateChanges must happen in After Context, once validation util is passed
        SAPCorrugateChanges();
        classUpdCIRFCorMat = linkCorMatCIRFMat();
        addTotalUnits();
    }
    public override void afterUpdate() {
        SAPCorrugateChanges ();
        if(isFirstTime) {
            if(!UpdatedFromMaterial){
                classUpdCIRFCorMat = linkCorMatCIRFMat();
                updateTotalUnits(classUpdCIRFCorMat);
            }
            
        }
    }
    
    
    public override void beforeDelete() {
        if(allowedCIRFActions){
            CIRFValidationUtil.processRecords(CIRFValidationUtil.CIRF_CORRUGATE_MATERIALS);//added by Kalyani on 10/29/2018
        }

        
        //HEITCIRF-273
        //Added by SJ 11/26/2018
        deleteActions();
        //SJ - Commented out
        //SAPCorrugateChanges ();
    }
    
    public override void afterDelete() {
        //Added by Sravanthi 12/19/2018
        SAPCorrugateChanges ();
        System.debug('In After Delete');
        subtractTotalUnits();
    }
    
    private static void populateExternalID(){
        Map<Id,CIRF_Corrugate__c> relCorrugates = getRelatedCorrugates();
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
            CIRF_Corrugate_Material__c oldCorMat;
            if(trigger.isUpdate){
                oldCorMat= (CIRF_Corrugate_Material__c)Trigger.oldMap.get(ccm.id);
            }
            if(ccm.External_Id__c == null || (Trigger.isUpdate && (ccm.Material_Name__c != oldCorMat.Material_Name__c || ccm.CIRF_Corrugate__c != oldCorMat.CIRF_Corrugate__c))){
                if(relCorrugates.containsKey(ccm.CIRF_Corrugate__c)){
                    ccm.External_Id__c = (relCorrugates.get(ccm.CIRF_Corrugate__c)).Corrugate_External_Id__c + '' + ccm.Material_Number__c; 
                }
            }
        }
    }
    
    set<id> corrgarid=new set<id>();
    List<CIRF_Corrugate__c> updatecorrgate=new List<CIRF_Corrugate__c>();
    public void SAPCorrugateChanges(){	
        system.debug('after delete');
        List<CIRF_Corrugate_Material__c> crfMatlst=new List<CIRF_Corrugate_Material__c>();
        Map<Id,CIRF_Corrugate_Material__c> crfOldMap = new Map<Id,CIRF_Corrugate_Material__c>();
        if(Trigger.isdelete)
            crfMatlst=(List<CIRF_Corrugate_Material__c>) trigger.old;
        else{            
            crfMatlst=(List<CIRF_Corrugate_Material__c>) trigger.new;
            crfOldMap =(Map<Id,CIRF_Corrugate_Material__c>)trigger.OldMap;
        }
        system.debug('after delete crfMatlst =='+crfMatlst);
        for(CIRF_Corrugate_Material__c csm : crfMatlst){
            if(Trigger.isDelete){
                corrgarid.add(csm.CIRF_Corrugate__c);
            }
            else if(Trigger.isinsert){
                corrgarid.add(csm.CIRF_Corrugate__c);
            }
            else{
                if(csm.Facings__c != crfOldMap.get(csm.id).Facings__c){
                    corrgarid.add(csm.CIRF_Corrugate__c);
                }
                else if(csm.Units_per_Pocket__c != crfOldMap.get(csm.id).Units_per_Pocket__c){
                    corrgarid.add(csm.CIRF_Corrugate__c);
                }
                else if(csm.Material_Name__c != crfOldMap.get(csm.id).Material_Name__c){
                    corrgarid.add(csm.CIRF_Corrugate__c);
                }
            }
        }
        system.debug('after delete corrgarid =='+corrgarid);
        if(!corrgarid.isEmpty()){
            List<CIRF_Corrugate__c> corList = [SELECT Corrugate_Name__c,Total_Number_of_Facings__c,Total_Number_of_Units__c,SAP_Corrugate_Changes_Made__c FROM CIRF_Corrugate__c where id IN : corrgarid];
            for(CIRF_Corrugate__c cc : corList){
                if(cc.Corrugate_Name__c != null){
                    cc.SAP_Corrugate_Changes_Made__c=false;
                    //cc.Corrugate_Status__c='Edited';
                    //cc.Corrugate_Status__c='Cancelled';//HEITCIRF-501
                    updatecorrgate.add(cc);   
                }
            }
        }
        if(updatecorrgate.size()>0){
            CIRFCorrugateTriggerHandler.UpdatedFromCorMat = false;
            CIRFHeaderTriggerHandler.Updatedfromheader=false;
            system.debug('updatecorrgate=='+updatecorrgate);
            update updatecorrgate;
        }
    }
    
    private static List<CIRF_Corrugate_Material__c> linkCorMatCIRFMat(){
        //Map of corrugate material ID to header ID
        Map<Id,Id> corMatHeadID = new Map<Id,Id>();
        //Map of corrugate material ID to corrugate id
        Map<Id,Id> corMatCorID = new Map<Id,Id>();
        //Map of corrugate ID to CIRF Header ID
        Map<Id,Id> corHeaderID = new Map<Id,Id>();
        //Map of material ID to CIRF Material
        Map<Id,CIRF_Material__c> matCIRFMat = new Map<Id,CIRF_Material__c>();
        //Map of Header ID to Material ID
        Map<Id,List<Id>> headerMaterialMap = new Map<Id,List<Id>>();
        //Map of uniqueID to CIRF Material
        Map<String ,CIRF_Material__c> IDCIRFMaterialMap = new Map<String ,CIRF_Material__c>();
        
        Map<String,CIRF_Material__c> newCIRFMaterials = new Map<String,CIRF_Material__c>();
        
        List<CIRF_Corrugate_Material__c> cormatToUpdate = new List<CIRF_Corrugate_Material__c>();
        //List<CIRF_Material__c> newCIRFMaterials = new List<CIRF_Material__c>();
        List<CIRF_Corrugate_Material__c> updCIRFCorMat = new List<CIRF_Corrugate_Material__c>();
        
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
            corMatCorID.put(ccm.id,ccm.CIRF_Corrugate__c);
        }
        List<CIRF_Corrugate__c> relCorg = [select id,CIRF_Header__c from CIRF_Corrugate__c where id IN :corMatCorID.values()];
        for(CIRF_Corrugate__c cc : relCorg) {
            corHeaderID.put(cc.id,cc.CIRF_Header__c);
        }
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
            corMatHeadID.put(ccm.id,corHeaderID.get(corMatCorID.get(ccm.id)));
        }
        List<CIRF_Material__c> cmats = [select id, Material_Name__c, CIRF_Header__c from CIRF_Material__c
                                        where CIRF_Header__c in :corMatHeadID.values()];
        
        for(CIRF_Material__c cm : cmats){
            matCIRFMat.put(cm.Material_Name__c, cm);
            if(!headerMaterialMap.containsKey(cm.CIRF_Header__c)) {
                headerMaterialMap.put(cm.CIRF_Header__c,new List<Id>());
            }
            headerMaterialMap.get(cm.CIRF_Header__c).add(cm.Material_Name__c);
        }
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
            if(headerMaterialMap.get(corMatHeadID.get(ccm.id))==null||(!(headerMaterialMap.get(corMatHeadID.get(ccm.id))).contains(ccm.Material_Name__c))) {
                CIRF_Material__c newCmat = new CIRF_Material__c();
                newCmat.CIRF_Header__c = corMatHeadID.get(ccm.id);
                System.debug(ccm.Material_Name__c);
                newCmat.Material_Name__c = ccm.Material_Name__c;
                newCmat.External_Id__c = newCmat.CIRF_Header__c + '-' + ccm.Material_Number__c;
                newCIRFMaterials.put(newCmat.External_Id__c, newCmat);
                cormatToUpdate.add(ccm);
                IDCIRFMaterialMap.put(String.valueOf(corMatHeadID.get(ccm.id))+'-'+String.valueOf(ccm.Material_Name__c),newCmat);
            }
            else {
                System.debug(matCIRFMat.get(ccm.Material_Name__c).Id);
                CIRF_Corrugate_Material__c newCorMat = new CIRF_Corrugate_Material__c(Id = ccm.Id);
                newCorMat.CIRF_Material__c = matCIRFMat.get(ccm.Material_Name__c).Id;
                updCIRFCorMat.add(newCorMat);
                //boolean for recursion
                isFirstTime = false;
            }
        }
        isFirstTime = false;
        List<Database.UpsertResult> upr = Database.upsert(newCIRFMaterials.values(),CIRF_Material__c.Fields.External_Id__c,False);
        for(CIRF_Corrugate_Material__c ccm : cormatToUpdate) {
            CIRF_Corrugate_Material__c newCorMat = new CIRF_Corrugate_Material__c(Id = ccm.Id);
            newCorMat.CIRF_Material__c = IDCIRFMaterialMap.get(String.valueOf(corHeaderID.get(ccm.CIRF_Corrugate__c))+'-'+String.valueOf(ccm.Material_Name__c)).Id;
            updCIRFCorMat.add(newCorMat);
        }
        If(!updCIRFCorMat.IsEmpty()){                  
            update updCIRFCorMat; 
        }
        return updCIRFCorMat;
    }
    
    private static void addTotalUnits(){
        Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
        List<CIRF_Corrugate_Material__c> updatedCorMat = [select id, Total_Stock__c , CIRF_Material__c from CIRF_Corrugate_Material__c where id IN :trigger.new];
        Map<Id, CIRF_Material__c> CIRFMatIDMap = getCIRFMaterialIDMap(updatedCorMat);
        Map<Id, CIRF_Material__c> CIRFMatIDMap1 = getCIRFMaterialIDMap((List<CIRF_Corrugate_Material__c>) trigger.new);
        for(CIRF_Corrugate_Material__c ccm : updatedCorMat) {
            CIRF_Material__c cm = CIRFMatIDMap.get(ccm.CIRF_Material__c);
            if(cm != null){
                if(cm.Corrugate_Units__c != null){
                    cm.Corrugate_Units__c += ccm.Total_Stock__c;
                } 
                else {
                    cm.Corrugate_Units__c = 0;
                    cm.Corrugate_Units__c += ccm.Total_Stock__c;
                }
                if(cm.Corrugate_Units__c > 99999){
                    //ccm.addError('WOW. You deserve a medal. That is a lot of Corrugate Units for this material! Please check your input values');
                    ((CIRF_Corrugate_Material__c)Trigger.newMap.get(ccm.id)).addError('WOW. You deserve a medal. That is a lot of Corrugate Units for this material! Please check your input values');
                }
                else{
                    CIRFMaterialsToUpdate.put(cm.id,cm);
                }
            }
        }
        if(!CIRFMaterialsToUpdate.isEmpty())
            update CIRFMaterialsToUpdate.values();
    }
    
    private static void updateTotalUnits(List<CIRF_Corrugate_Material__c> UpdCIRFCorMat){
        if(!UpdCIRFCorMat.IsEmpty() && UpdCIRFCorMat != null)
        {
            Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
            Map<Id,CIRF_Material__c> oldCIRFMaterialsMap = new Map<Id,CIRF_Material__c>();
            Map<Id,CIRF_Material__c> newCIRFMatMap = new Map<Id,CIRF_Material__c>();
            Map<Id,Id> oldnewCmatMap = new Map<Id,Id>();
            List<Id> oldCIRFMaterialIds = new List<Id>();
            List<Id> newCIRFMatIds = new List<Id>();
            Map<Id,Id> cormatcmatmap = new Map<Id,Id>();
            
            for(CIRF_Corrugate_Material__c newccm : UpdCIRFCorMat) {
                cormatcmatmap.put(newccm.id,newccm.CIRF_Material__c);
            }
            
            for(CIRF_Corrugate_Material__c ccm : UpdCIRFCorMat) {
                if(ccm.CIRF_Material__c!=((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).CIRF_Material__c) {
                    oldCIRFMaterialIds.add(((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).CIRF_Material__c);
                    newCIRFMatIds.add(ccm.CIRF_Material__c);
                    System.debug('old + ' + ((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).CIRF_Material__c);
                    System.debug('new '+ ccm.CIRF_Material__c);
                }
            }
            List<CIRF_Material__c> updatedCIRFMat = [select id, Material_Name__c, CIRF_Header__c,Corrugate_Units__c from CIRF_Material__c
                                                     where id in :newCIRFMatIds];
            System.debug(updatedCIRFMat);
            for(CIRF_Material__c newcm : updatedCIRFMat) {
                newCIRFMatMap.put(newcm.id,newcm);
            }
            
            List<CIRF_Material__c> oldCIRFMaterials = [select id, Material_Name__c, CIRF_Header__c,Corrugate_Units__c from CIRF_Material__c
                                                       where id in :oldCIRFMaterialIds];
            System.debug(oldCIRFMaterials);
            for(CIRF_Material__c cm : oldCIRFMaterials) {
                oldCIRFMaterialsMap.put(cm.id,cm);
            }
            
            Map<Id, CIRF_Material__c> CIRFMatIDMap = getCIRFMaterialIDMap((List<CIRF_Corrugate_Material__c>) trigger.new);
            for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
                CIRF_Material__c cm;
                System.debug(CIRFMatIDMap.get(ccm.CIRF_Material__c));
                if(ccm.Material_Name__c!=((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).Material_Name__c 
                   && ((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).Material_Name__c != null){
                       CIRF_Material__c ocm = oldCIRFMaterialsMap.get(((CIRF_Corrugate_Material__c) Trigger.oldMap.get(ccm.id)).CIRF_Material__c);
                       if(ocm!=null){
                           System.debug(ocm);
                           ocm.Corrugate_Units__c -= ((CIRF_Corrugate_Material__c)Trigger.oldMap.get(ccm.id)).Total_Stock__c;
                           CIRFMaterialsToUpdate.put(ocm.id,ocm);
                       }
                       cm = newCIRFMatMap.get(cormatcmatmap.get(ccm.id));
                   }
                else {
                    System.debug('else');
                    cm = CIRFMatIDMap.get(ccm.CIRF_Material__c);
                    if(cm!=null){
                        cm.Corrugate_Units__c -= ((CIRF_Corrugate_Material__c)Trigger.oldMap.get(ccm.id)).Total_Stock__c;
                        System.debug(cm.Corrugate_Units__c);
                        System.debug('old + '+ ((CIRF_Corrugate_Material__c)Trigger.oldMap.get(ccm.id)).Total_Stock__c);
                    }
                }
                if(cm!=null){
                    cm.Corrugate_Units__c += ccm.Total_Stock__c;
                    //System.debug(cm);
                    System.debug('cm.Corrugate_Units__c '+ cm.Corrugate_Units__c);
                    System.debug('ccm.Total_Stock__c '+ ccm.Total_Stock__c);
                    if(cm.Corrugate_Units__c > 99999){
                        ccm.addError('WOW. You deserve a medal. That is a lot of Corrugate Units for this material! Please check your input values');
                    }
                    else {
                        CIRFMaterialsToUpdate.put(cm.id,cm);
                    }
                }
            }
            update CIRFMaterialsToUpdate.values();
        }
    }
    
    private static void subtractTotalUnits(){
        Map<Id,CIRF_Material__c> CIRFMaterialsToUpdate = new Map<Id,CIRF_Material__c>();
        Map<Id, CIRF_Material__c> CIRFMatIDMap = getCIRFMaterialIDMap((List<CIRF_Corrugate_Material__c>) trigger.old);
        System.debug('CIRFMatIDMap '+CIRFMatIDMap);
        System.debug(trigger.old);
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.old) {
            CIRF_Material__c cm = CIRFMatIDMap.get(ccm.CIRF_Material__c);
            System.debug('cm****** '+cm);
            if(cm!=null){
                System.debug(cm.Corrugate_Units__c);
                System.debug(ccm.Total_Stock__c);
                cm.Corrugate_Units__c -= ccm.Total_Stock__c;
                CIRFMaterialsToUpdate.put(cm.Id,cm);
                CIRFMatIDMap.put(cm.Id,cm);
            }
        }
        update CIRFMaterialsToUpdate.values();
    }
    
    //HEITCIRF-273
    //Added by SJ 11/26/2018
    private void deleteActions() {
        Map<Id,String> corMatCorIdMap = new Map<Id,String>();
        Map<Id,String> corMatCmatIdMap = new Map<Id,String>();
        Map<Id,String> CorIdCorMatMap = new Map<Id,String>();
        Map<Id,CIRF_Material__c> CmatsToDelete = new Map<Id,CIRF_Material__c>();
        Map<Id,CIRF_Material__c> CmatsToUpdate = new Map<Id,CIRF_Material__c>();
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.old){
            CorIdCorMatMap.put(ccm.CIRF_Corrugate__c, ccm.id);
        }
        Map<Id,CIRF_Corrugate__c> relatedCorrugates = new Map<Id,CIRF_Corrugate__c>([select id, CIRF_Header__r.CIRF_Status__c, CIRF_Header__r.Revision__c from CIRF_Corrugate__c where id in :CorIdCorMatMap.keyset()]);
        for(CIRF_Corrugate__c cc : relatedCorrugates.values()){
            if(cc.CIRF_Header__r.CIRF_Status__c != 'Draft' && CIRFMaterialTriggerHandler.cancelledByTask == false && byPassCorMatDelActions == false){
                //scenario 7
                ((CIRF_Corrugate_Material__c)trigger.oldmap.get(CorIdCorMatMap.get(cc.id))).addError('You cannot delete this material. Please revise the whole CIRF');
            }
        }
    }
    
    private static Map<Id, CIRF_Material__c> getCIRFMaterialIDMap(List<CIRF_Corrugate_Material__c> updatedCorMat){
        List<Id> CIRFMatIds = new List<Id>();
        Map<Id, CIRF_Material__c> CIRFMatIDMap = new Map<Id, CIRF_Material__c>();
        for(CIRF_Corrugate_Material__c ccm : updatedCorMat) {
            CIRFMatIds.add(ccm.CIRF_Material__c);
        }
        System.debug('CIRFMatIds '+CIRFMatIds);
        List<CIRF_Material__c> cmats = [select id, Material_Name__c, CIRF_Header__c,Corrugate_Units__c from CIRF_Material__c
                                        where id in :CIRFMatIds];
        for(CIRF_Material__c cmat : cmats) {
            CIRFMatIDMap.put(cmat.id, cmat);
        }
        return CIRFMatIDMap;
    }
    
    private static Map<Id,CIRF_Corrugate__c> getRelatedCorrugates() {
        List<Id> corrugateIds = new List<Id>();
        Map<Id,CIRF_Corrugate__c> relCorrugates = new Map<Id,CIRF_Corrugate__c>();
        for(CIRF_Corrugate_Material__c ccm : (List<CIRF_Corrugate_Material__c>) trigger.new) {
            corrugateIds.add(ccm.CIRF_Corrugate__c);
        }
        List<CIRF_Corrugate__c> relatedCorrugates = [select id,CIRF_Header__c,Corrugate_External_Id__c from CIRF_Corrugate__c where id IN :corrugateIds];
        for(CIRF_Corrugate__c cc : relatedCorrugates) {
            relCorrugates.put(cc.id, cc);
        }
        return relCorrugates;
    }
}