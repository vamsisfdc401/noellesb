/*****************************************************************************************
Class Name: MaterialTreeController 
Purpose: Apex class for MaterialTree VF page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Mohit                    Initial Development
******************************************************************************************/
public with sharing class MaterialTreeController {
    
    /****private static variables****/
    private static final string FERT_MATERIAL_TYPE = 'FERT';
    
    /****public variables****/ 
    public List<MaterialFERTWrapper> rootFERTs {get; set;}
    public string strSubTitle{get;set;}
    public boolean renderPage{get;set;}
    public boolean isUpdateRecord{get;set;}
    public Release__c releaseDetails {get; set;}
    public Material__c materialDetails {get; set;}
    public String objectType {get; set;}
    
    /****private variables****/
    private ID releaseID;
    private ID materialID; 
    private Map<string,string> mapItemQty = new Map<string,string>();//REL-203
    private Map<String, MaterialFERTWrapper> materialWrapperMap = new Map<String, MaterialFERTWrapper>();//REL-203
    private Map<Id, Set<Id>> materialChildMap = new Map<Id, Set<Id>>();
    private Set<Id> processedMatIds = new Set<Id>();
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    private string strWizardURL;
    private ApexPages.StandardController controller {get; set;}
    
    /*****************************************************************
    Method Name: MaterialTreeController
    Purpose : constructor of class
    ***************************************************************/
    public MaterialTreeController (ApexPages.StandardController controller){
        try{
            //initializing list
            rootFERTs = new List<MaterialFERTWrapper>();  
            renderPage = TRUE;
            isUpdateRecord = FALSE;
            this.controller = controller;
            
            //getting object name
            objectType = controller.getRecord().getSObjectType().getDescribe().getName();
            
            //if object is release
            if(objectType == 'Release__c'){
                this.releaseDetails = (Release__c)controller.getRecord();
                releaseID = releaseDetails.ID;
                this.releaseDetails = [SELECT Id, Name, Release_Status__c FROM Release__c WHERE Id=:releaseID];
                strWizardURL = '/apex/MaterialCreationWizard?id=' + releaseID + '&source=releasedetail&retURL=/' + releaseID;
                getExistingBOMTree();
            }
            else if(objectType == 'Material__c'){
                this.controller = controller;
                this.materialDetails = (Material__c)controller.getRecord();
                
                materialID = materialDetails.ID;
                Material__c mt = [Select id,Name,Material_Type__c,RecordTypeID from Material__c where ID=:materialID];
                
                ID updateRecordID = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); 
                
                if(updateRecordID == mt.RecordTypeID){
                    isUpdateRecord = TRUE;
                }
                
                //if material type FERT
                if(mt.Material_Type__c == FERT_MATERIAL_TYPE){
                    strWizardURL = '/apex/MaterialCreationWizard?id=' + materialID + '&source=materialdetail&retURL=/' + materialID;
                    
                    getExistingBOMTree();
                }else{
                    renderPage = FALSE;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Material tree can be viewed only on a FERT.'));     
                }
            }
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));             
        }
    }
    
    /*****************************************************************
    Method Name: getExistingBOMTree
    Purpose : getting entire Material tree
    ***************************************************************/
    private void getExistingBOMTree()
    {
        Set<Id> associatedMaterialIds = new Set<Id>();
        Set<Id> releaseMaterialsIds = new Set<Id>();
        if(string.valueof(releaseID) != null)
        {
            Map<Id, Boolean> relMatIds = new Map<Id, Boolean>();
            
            //getting all FERT for the release
            for(Release_Material__c relMat : [SELECT Material__c, Material__r.Material_Type__c FROM Release_Material__c 
                                              WHERE Release__c=:releaseID])
            {
                if(relMat.Material__r.Material_Type__c == 'FERT')
                    relMatIds.put(relMat.Material__c, true);
                releaseMaterialsIds.add(relMat.Material__c);
            }
            
            //identifying top level FERT
            for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c
                                   FROM BOM_Item__c 
                                   WHERE Material__c IN :relMatIds.keySet() AND Material_Component__c IN :relMatIds.keySet()])
            {
                if(relMatIds.containsKey(bom.Material_Component__c))
                    relMatIds.put(bom.Material_Component__c, false);
            }
            
            //adding record id to set 
            for(Id matId : relMatIds.keySet())
            {
                if(relMatIds.get(matId)){
                    associatedMaterialIds.add(matId);
                }    
            }
        }
        //if process started from material detail page
        else if(string.valueof(materialID) != null)
        {
            associatedMaterialIds.add(materialID);
        }
        System.debug('----associatedMaterialIds> '+associatedMaterialIds);
        
        //fetching all material details
        fetchCompleteBOMHierarchy(associatedMaterialIds,releaseMaterialsIds);
        
        //relating parent FERT to child FERT
        prepareCompleteBOMHierarchy(associatedMaterialIds,releaseMaterialsIds);
        
        //adding all records to a list of wrapper type
        for(Id matId : associatedMaterialIds)
            rootFERTs.add(materialWrapperMap.get(matId));
    }
    
    /*****************************************************************
    Method Name: prepareCompleteBOMHierarchy
    Purpose : relating parent FERT to child FERT
    ***************************************************************/
    Set<Id> processedParMatIds = new Set<Id>();//REL-203
    private void prepareCompleteBOMHierarchy(Set<Id> processingMaterialIds,Set<Id> releaseMaterialsIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        
        //looping over all FERT
        for(Id matId : processingMaterialIds)
        {
            //if material id present in child map
            if(materialChildMap.containsKey(matId) && materialChildMap.get(matId).size() > 0)
            {   //adding all key id to a set for using in recursive call
                if(releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || releaseMaterialsIds.contains(matId)){
                    nextLevelProcessingMaterialIds.addAll(materialChildMap.get(matId));
                }
                
                //looping over values
                //REL-203 --- start
                for(Id childMatId : materialChildMap.get(matId))
                {   
                    if (childParentMap.containsKey(matId) && childParentMap.get(matId).size() > 0) {
                        for (Id parId2 : childParentMap.get(matId)) {
                            
                            String parId = String.valueOf(parId2);
                            if (parId == null || !processedParMatIds.contains(parId)) {
                                continue;
                            }
                            String materialId = '' + matId + childMatId;
                            
                            System.debug('$$parId+(string)matId'+parId+(string)matId);
                            System.debug('$$(string)matId+(string)childMatId'+(string)matId+(string)childMatId);
                            
                            //linking parent FERT to child FERT
                             if (materialWrapperMap.get(parId+(string)matId) != null && materialWrapperMap.get((string)matId+(string)childMatId) != null && 
                                (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || releaseMaterialsIds.contains(childMatId))) {
                                materialWrapperMap.get(parId+(string)matId).childFERTs.add(materialWrapperMap.get((string)matId+(string)childMatId));
                                
                                System.debug('$$$$$mapitemqtyKey'+materialId);
                                //setting component qty
                                materialWrapperMap.get(parId+(string)matId).childFERTs[materialWrapperMap.get(parId+(string)matId).childFERTs.size()-1].componentQty = mapItemQty.get(materialId);
                            }
                        }
                    }
                    else {
                        String materialId = '' + matId + childMatId;
                            
                        System.debug('$$(string)matId'+(string)matId);
                        System.debug('$$(string)matId+(string)childMatId'+(string)matId+(string)childMatId);
                        
                        //linking parent FERT to child FERT
                         if (materialWrapperMap.get((string)matId) != null && materialWrapperMap.get((string)matId+(string)childMatId) != null && 
                            (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || releaseMaterialsIds.contains(childMatId))) {
                            materialWrapperMap.get((string)matId).childFERTs.add(materialWrapperMap.get((string)matId+(string)childMatId));
                            
                            System.debug('$$$$$mapitemqtyKey'+materialId);
                            //setting component qty
                            materialWrapperMap.get((string)matId).childFERTs[materialWrapperMap.get((string)matId).childFERTs.size()-1].componentQty = mapItemQty.get(materialId);
                        }
                    }
                }
            }
            processedParMatIds.add(matId);
            
            //REL-203 --- End
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0){
            prepareCompleteBOMHierarchy(nextLevelProcessingMaterialIds,releaseMaterialsIds);
        }    
    }
    
    Map<Id, Set<Id>> childParentMap = new Map<Id, Set<Id>>();//REL-203
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : setting FERT level details
    ***************************************************************/
    private void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds,Set<Id> releaseMaterialsIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
        for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c, Material_Component__r.Material_Type__c, 
                               Material_Component__r.Component_Type__c, Material_Component__r.Name,Material_Component__r.Release__c,Material_Component__r.Material_Number__c,Material_Component__r.Label_Code__c,Material_Component__r.Territory__c,
                               Material_Component__r.UPC__c,Material_Component__r.Material_Status__c, Component_Quantity__c  
                               FROM BOM_Item__c
                               WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                   Material_Component__c NOT IN :processedMatIds AND Material_Component__c != null AND 
                                   Material_Component__r.Deletion_Flag__c=false AND (BOM_Function__c != '003' AND Deletion_Flag__c=false)
                                /*ORDER BY Material_Component__r.Item_Code__c*/]) // commented for DF-02187
        {
            if(!matBomMap.containsKey(bom.Material__c))
                matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
            matBomMap.get(bom.Material__c).add(bom);
        }
        
        // Fetch the child materials from BOM Items.
        for(Material__c mat : [SELECT Id, Name, Item_Type__c, Item_Code__c, Title__c, Title__r.SGENNO__c, Format_Description__c,
                               Material_Type__c, Retailer_Rental__c, BOM_Quantity__c, Component_Type__c, Territory__c,Release__c, Material_Number__c,UPC__c,Material_Status__c,Label_Code__c,Street_Date__c  
                               FROM Material__c
                               WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes]) //Added Street Date field for USST-2682
        {
            //adding processed materials to a set
            processedMatIds.add(mat.Id);
            
            //adding FERT ID to map
            if(!materialChildMap.containsKey(mat.Id))
                materialChildMap.put(mat.Id, new Set<Id>());
            
            //setting details for FERT instance
            MaterialFERTWrapper matIns = new MaterialFERTWrapper(null, '');
            matIns.instance = mat;
            matIns.isExisting = true;
            if(mat.Title__c != null)
                matIns.sysgenNo = mat.Title__r.SGENNO__c;
            
            //checking if related BOM Item records for FERT not null
            if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
            {   
                //Looping over related BOM Item records
                for(BOM_Item__c bom : matBomMap.get(mat.Id))
                {
                    // If it is a component material.
                    if(childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c) && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                    releaseMaterialsIds.contains(bom.Material_Component__c)))
                    {
                        MaterialComponentWrapper comp = new MaterialComponentWrapper();
                        comp.instance.Id = bom.Material_Component__c;
                        comp.instance.Name = bom.Material_Component__r.Name;
                        comp.instance.Material_Type__c = bom.Material_Component__r.Material_Type__c;
                        comp.instance.Component_Type__c = bom.Material_Component__r.Component_Type__c;
                        comp.instance.Association_Required__c = false;
                        comp.instance.UPC__c = bom.Material_Component__r.UPC__c;
                        comp.instance.Material_Number__c = bom.Material_Component__r.Material_Number__c;
                        comp.instance.Material_Status__c = bom.Material_Component__r.Material_Status__c;
                        comp.componentQty = bom.Component_Quantity__c ;
                        comp.isExisting = true;
                        comp.isExistingRecord = true;
                        comp.instance.Release__c = bom.Material_Component__r.Release__c;
                        comp.instance.Label_Code__c = bom.Material_Component__r.Label_Code__c;
                        comp.instance.Territory__c = bom.Material_Component__r.Territory__c;
                        
                        matIns.childComponents.add(comp);
                    }
                    // If FERT material not previously processed. FERT to FERT mapping
                    else if(!processedMatIds.contains(bom.Material_Component__c) && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                            releaseMaterialsIds.contains(bom.Material_Component__c)))
                    { 
                        //for recursive call adding FERT id to a set
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                        
                        //mapping parent FERT and Child FERT IDs
                        materialChildMap.get(mat.Id).add(bom.Material_Component__c);
                        
                        //REL-203 change ---start
                        if (!childParentMap.containsKey(bom.Material_Component__c)) {
                            childParentMap.put(bom.Material_Component__c, new Set<Id>());
                        }
                        childParentMap.get(bom.Material_Component__c).add(mat.Id);
                        //mapping child FERT and Component Qty
                        mapItemQty.put((String)mat.Id + (String)bom.Material_Component__c,bom.Component_Quantity__c);
                        //REL-203 --- End
                    }
                }
            }
            
            //map of material records
            //String parId = '';
             //REL-203 change ---start
            if(childParentMap.containsKey(mat.Id))
            {
                for (Id parId2 : childParentMap.get(mat.Id)) {
                    String parId = String.valueOf(parId2);
                    if (!materialWrapperMap.containsKey(parId + mat.Id)) {
                        materialWrapperMap.put((parId + mat.Id), matIns.clone());
                    }
                }
            }
            else {
                if (!materialWrapperMap.containsKey(mat.Id)) {
                    materialWrapperMap.put(mat.Id, matIns.clone());
                }
            }
             //REL-203 change ---End
            //System.debug('@@@materialWrapperMap Inside Loop'+materialWrapperMap);
        }
        
        //recursive call
        if(nextLevelProcessingMaterialIds.size() > 0){
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds,releaseMaterialsIds);
        }    
    }    
    
    /*****************************************************************
    Method Name: redirectToWizard
    Purpose : called on click of request wizard button
    ***************************************************************/
    public pageReference redirectToWizard(){
        try{
            if(objectType == 'Release__c' && releaseDetails.Release_Status__c == 'Cancelled')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'This action cannot be performed on a Cancelled Release.')); 
                return null;
            }
            pageReference pg = new pageReference(strWizardURL);
            pg.setRedirect(true);
            return pg;
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage())); 
            return null;    
        }
    }
    
    /*****************************************************************
    Method Name: redirectToBOMWizard
    Purpose : called on click of BOM wizard button
    ***************************************************************/
    public pageReference redirectToBOMWizard(){
        try{
            pageReference pg = new pageReference('/apex/BOMWizard?mid='+materialID);
            pg.setRedirect(true);
            return pg;
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage())); 
            return null;    
        }
    }
    
    /*****************************************************************
    Method Name: redirectToMassClone
    Purpose : called on click of clone button
    ***************************************************************/
    public pageReference redirectToMassClone(){
        try{
            if(objectType == 'Release__c' && releaseDetails.Release_Status__c == 'Cancelled')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'This action cannot be performed on a Cancelled Release.')); 
                return null;
            }
            pageReference pg = new pageReference('/apex/MassCloningSelection?releaseId='+releaseID+'&retURL=/'+releaseID);
            pg.setRedirect(true);
            return pg;
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage())); 
            return null;    
        }
    }
    
    // Material Wrapper class.
    public class MaterialFERTWrapper
    {
        public Boolean isExistingRecord {get; private set;}
        public Material__c instance {
            get; 
            set
            {
                instance = value;
                if(instance.Id != null)
                    isExistingRecord = true;
            }
        }
        public String sysgenNo {get; private set;}
        public Boolean isExisting {get; private set;}
        public List<MaterialFERTWrapper> childFERTs {get; set;}
        public List<MaterialComponentWrapper> childComponents {get; set;}
        public string componentQty{get;set;}
        
        public MaterialFERTWrapper(Id titleId, String sysgenNo)
        {
            instance = new Material__c();
            instance.Title__c = titleId;
            instance.Material_Type__c = FERT_MATERIAL_TYPE ;
            this.sysgenNo = sysgenNo;
            isExisting = false;
            isExistingRecord = false;
            
            childFERTs = new List<MaterialFERTWrapper>();
            childComponents = new List<MaterialComponentWrapper>();
        }
    }
    
    // Component wrapper class
    public class MaterialComponentWrapper
    {
        public Boolean isExistingRecord {get; private set;}
        public Material__c instance {
            get; 
            set
            {
                instance = value;
                if(instance.Id != null)
                    isExistingRecord = true;
            }
        }
        public Boolean isExisting {get; private set;}
        public string componentQty{get;set;}
        
        public MaterialComponentWrapper()
        {
            instance = new Material__c();
            instance.Material_Type__c = 'ROH';
            isExisting = false;
            isExistingRecord = false;
        }
    }
}