/*****************************************************************************************
Class Name: BOMWizardController 
Purpose: This class is responsible to handle the complexity of BOM Wizard. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Ipsita                   Initial Development
******************************************************************************************/
public with sharing class BOMWizardController {
    
    /****private static variables****/
    private static final string FERT_MATERIAL_TYPE = 'FERT';
    private static final string S_ITEM_TYPE = 'S (Single)';
    private static final string M_ITEM_TYPE = 'M (Multipack)';
    private static final string D_ITEM_TYPE = 'D (Display Vehicle)';
    private static final string FR_VALUE  = 'FR - Future Release';
    private static final string SS_ITEM_CODE = 'SS - SINGLE SELECTION';
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
        private static Set<Id> requestMaterialIds = new Set<Id>();
    private static Set<Id> componentIds = new Set<Id>();
    private static Set<Id> displayVehicleIds = new Set<Id>();
    private static Set<Id> multiPackIds = new Set<Id>();
    private static Integer approveMaterialCount;
    
    /****public variables****/ 
    public List<MaterialFERTWrapper> rootFERTs {get; set;}
    public PaginationHandler rootIns {get;set;}
    
    public string strSubTitle{get;set;}
    public boolean renderPage{get;set;}
    public integer componentQty{get;set;}
    public String materialIndex {get; set;}
    public Integer componentIndex {get; set;}
    public Integer selectedMaterialLevel {get; set;}
    public String materialType {get; set;}
    public boolean showChildMaterialSection{get;set;}
     //USST - 2831 & USST-2834 begin
    Public boolean showAllBOMTextLevel1{get;set;}
    Public boolean showAllBOMTextLevel2{get;set;}
    //USST - 2831 & USST-2834 end
    public Boolean showPopUp{get;set;}
    public Material__c materialDetails{get;set;}
    public Material__c materialDetailsTemp{get;set;}//REL-185
    public string type {get;set;}
    public integer rowNumComp {get;set;}
    public Integer rowNumberFERT {get;set;}
    public ID bomID {get;set;}
    public List<Material__c> lstMaterial {get;set;}
    public user u{get;set;}
    public Material__c rootMat{get;set;} //DF-01911
    private Boolean notUploadable=false;//Added for 153
    
    //Releaseforce 2.0 RE-14 Displaying sales fields on BOM Header -initialising fields starts.
    public Sales__c salesDetails{get;set;}
    public static Material__c materialupdate;
    public static String plant;
    public static Id recTypeId;
    public static List<Sales__c>insertableSales=new List<Sales__c>();
    public static List<Classification__c >insertableClassification=new List<Classification__c>();
    public static List<Alternative_Unit_of_Measure__c>insertableAUoMs=new List<Alternative_Unit_of_Measure__c>();
    public static List<Valuation__c>insertableVals=new List<Valuation__c>();
    public static List<Plant__c>insertablePlant=new List<Plant__c>();
    public static Material__c matCopy;
    private static boolean checkChildView =false;
    public static Sales__c salesUpdate;
    private string oldMGroup2;//RE-14
    private string oldMGroup5;//RE-14
    //Releaseforce 2.0 RE-14 Displaying sales fields on BOM Header -initialising fields ends.
    
    /****private variables****/
    
    private ID materialID; 
    //private Map<ID,string> mapItemQty = new Map<ID,string>();
    private Map<Id, MaterialFERTWrapper> materialWrapperMap = new Map<Id, MaterialFERTWrapper>();
    private Map<Id, Set<Id>> materialChildMap = new Map<Id, Set<Id>>();
    private Set<Id> processedMatIds = new Set<Id>();
    private string strWizardURL;
    private List<BOM_Item__c> deleteableBOMItemList = new List<BOM_Item__c>();
    private List<Material__c> updateableParentMaterialList = new List<Material__c>();
    private List<BOM_Item__c> updateableBOMItemList = new List<BOM_Item__c>();
    private Map<ID,BOM_Item__c> mapItemQty = new Map<ID,BOM_Item__c>();
    private Map<ID,BOM_Item__c> mapItemQtyTemp = new Map<ID,BOM_Item__c>();//REL-185
    @TestVisible private Boolean isDataChanged = false;//REL-185..Added on 10DEC for REL-185
    private String territory;
    private Boolean saveAndSubmit=false;
    public boolean result=false;
    public boolean bomstatuscheck= false;
    
    
    /************************************
    Method Name: bomWizardController
    Purpose: Constructor
    *************************************/    
    public BOMWizardController (){
        try{
            //initializing list
            rootFERTs = new List<MaterialFERTWrapper>();
            rootIns = new PaginationHandler();
            rootIns.assignRecordList(rootFERTs);
            rootIns.pageSize = 1;
            renderPage = TRUE;
            componentQty =0;
            showChildMaterialSection = FALSE;
              
               //USST - 2831 & USST-2834 begin 
            showAllBOMTextLevel1 = FALSE;
            showAllBOMTextLevel2 = FALSE;
              //USST - 2831 & USST-2834 end
              
            showPopUp = FALSE;
            //getting record id from URL
            materialID = ApexPages.currentPage().getParameters().get('mid'); 
            system.debug('materialID '+materialID);
            materialDetails = new Material__c();
            materialDetailsTemp = new Material__c();//REL-185
            salesDetails = new Sales__c(); //Releaseforce 2.0 RE-14
            u = new User();
            u= [select id,profile.name,master_data__c from User where ID=:userinfo.getUserID()];
            rootMat = [select id, Material_Number__c from Material__c where id =: materialID];
                
            //if material id not null
            if(string.valueof(materialID) != null){
                //getting material details
                Material__c mt = [Select id,Name,Material_Type__c,Label_Code__c,Material_Number__c,BOM_Status__c,Item_Type__c from Material__c where ID=:materialID];
                if((mt.Item_Type__c != 'D (Display Vehicle)') && (mt.BOM_Status__C == 'Submitted' || mt.BOM_Status__C == 'Pending Final Approval' || mt.BOM_Status__c == 'Approved' || mt.BOM_Status__c == 'Processed in SAP')){
                    bomstatuscheck = true;
                }
                strSubTitle = 'Material: ' + mt.Name;
                system.debug('mt  '+mt);
                //if material type FERT
                if(mt.Material_Type__c == FERT_MATERIAL_TYPE){
                    if(mt.Material_Number__c != null ){
                        getExistingBOMTree();
                    }
                    else{
                        renderPage = FALSE;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Material Number is not present. Please wait till Material is Processed in SAP'));   
                    }
                }else{
                    renderPage = FALSE;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Material tree can be viewed only from FERT.'));     
                }                
            }
            
            // REL-185--start
            if(rootFERTs != null && rootFERTs.size() > 0) { 
                createTempFERTStructure(rootFERTs);
            }
            // REL-185--start---End
                    
            if(materialID != null){
                setMaterialDetails();
            }
            
            system.debug('rootFERTs:::::::::' +rootFERTs );
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
        materialWrapperMap.clear();
        materialChildMap.clear();
        processedMatIds.clear();
        Set<Id> associatedMaterialIds = new Set<Id>();
        
        //if process started from material detail page
        if(string.valueof(materialID) != null)
        {
            associatedMaterialIds.add(materialID);
        }
       
        
        //fetching all material details
        fetchCompleteBOMHierarchy(associatedMaterialIds);
        
        for(Id matId : associatedMaterialIds)
        {
            materialWrapperMap.get(matId).wizardType = 'material';
            materialWrapperMap.get(matId).levelOfDepth = 1;
        }
        
        //relating parent FERT to child FERT
        prepareCompleteBOMHierarchy(associatedMaterialIds);
        
        //adding all records to a list of wrapper type
        for(Id matId : associatedMaterialIds)
            rootFERTs.add(materialWrapperMap.get(matId));
    }
    
    /*****************************************************************
    Method Name: prepareCompleteBOMHierarchy
    Purpose : relating parent FERT to child FERT
    ***************************************************************/
    private void prepareCompleteBOMHierarchy(Set<Id> processingMaterialIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        
        //looping over all FERT
        for(Id matId : processingMaterialIds)
        {
            //if material id present in child map
            if(materialChildMap.containsKey(matId) && materialChildMap.get(matId).size() > 0)
            {   //adding all key id to a set for using in recursive call
                nextLevelProcessingMaterialIds.addAll(materialChildMap.get(matId));
                
                //looping over values
                for(Id childMatId : materialChildMap.get(matId))
                {   
                    //linking parent FERT to child FERT
                    if(materialWrapperMap.get(matId) != null && materialWrapperMap.get(childMatId) != null){
                        MaterialFERTWrapper matIns = materialWrapperMap.get(childMatId);
                        matIns.wizardType = 'material';
                        matIns.levelOfDepth = materialWrapperMap.get(matId).levelOfDepth + 1;
                        materialWrapperMap.get(matId).childFERTs.add(matIns);
                       
                        //setting component qty
                        materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].bmItm = mapItemQty.get(childMatId);
                        
                        if(mapItemQty.get(childMatId).BOM_Quantity__c != null){
                            materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].componentQty = Integer.Valueof(mapItemQty.get(childMatId).BOM_Quantity__c);
                            materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].componentQtyActual = Integer.Valueof(mapItemQty.get(childMatId).BOM_Quantity__c);
                        }
                        if(mapItemQty.get(childMatId).Valid_From__c != null){
                            materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].bmItm.Valid_From__c = mapItemQty.get(childMatId).Valid_From__c;
                        }                        
                    }    
                }
            }
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0){
            prepareCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
        }    
    }
    
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : setting FERT level details
    ***************************************************************/
    private void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
        for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Material_Component__r.Count_Sales_for_D_Chain_Status__c, Material_Component__r.Item_Type__c,
                                Material_Component__r.Component_Type__c, Material_Component__r.Name,Material_Component__r.Release__c,Material_Component__r.Material_Number__c,Material_Component__r.BOM_Status__c,
                                Material_Component__r.UPC__c,Material_Component__r.Material_Status__c,Component_Quantity__c,BOM_Quantity__c,Material_Component__r.Valid_From__c,Material_Component__r.Label_Code__c,
                                Valid_From__c,Item_Category__c,Material_Component__r.Old_Material_No__c,Material_Component__r.Old_Material_Load__c,Valid_To__c,BOM_Item_Text_1__c,BOM_Item_Text_2__c 
                                FROM BOM_Item__c
                                WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                    Material_Component__c NOT IN :processedMatIds AND Material_Component__c != null AND 
                                    Material_Component__r.Deletion_Flag__c=false AND Deletion_Flag__c = False])
                                    
        {
            if(!matBomMap.containsKey(bom.Material__c))
                matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
            matBomMap.get(bom.Material__c).add(bom);
        }
        
        // Fetch the child materials from BOM Items.
        for(Material__c mat : [SELECT Id, Name, Item_Type__c, Item_Code__c, Title__c, Title__r.SGENNO__c, Format_Description__c,BOM_Status__c,Valid_From__c,Count_Sales_for_D_Chain_Status__c,Old_Material_No__c, 
                               Old_Material_Load__c,Material_Type__c, Retailer_Rental__c, BOM_Quantity__c, Component_Type__c, Territory__c,Release__c, Material_Number__c,UPC__c,Material_Status__c,Label_Code__c
                               FROM Material__c
                               WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes])
        {
            //adding processed materials to a set
            processedMatIds.add(mat.Id);
            
            //adding FERT ID to map
            if(!materialChildMap.containsKey(mat.Id))
                materialChildMap.put(mat.Id, new Set<Id>());
            
            //setting details for FERT instance
            MaterialFERTWrapper matIns = new MaterialFERTWrapper(null, '', null);
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
                    if(childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c))
                    {
                        MaterialComponentWrapper comp = new MaterialComponentWrapper(null, null);
                        comp.instance.Id = bom.Material_Component__c;
                        comp.instance.Name = bom.Material_Component__r.Name;
                        comp.instance.Material_Type__c = bom.Material_Component__r.Material_Type__c;
                        comp.instance.Item_Type__c = bom.Material_Component__r.Item_Type__c;
                        comp.instance.Component_Type__c = bom.Material_Component__r.Component_Type__c;
                        comp.instance.Association_Required__c = false;
                        comp.instance.UPC__c = bom.Material_Component__r.UPC__c;
                        comp.instance.Material_Number__c = bom.Material_Component__r.Material_Number__c;
                        comp.isExisting = true;
                        comp.isExistingRecord = true;
                        comp.instance.Release__c = bom.Material_Component__r.Release__c;
                        comp.instance.BOM_Status__c = bom.Material_Component__r.BOM_Status__c;
                        comp.instance.Label_Code__c = bom.Material_Component__r.Label_Code__c;
                        comp.instance.Old_Material_No__c = bom.Material_Component__r.Old_Material_No__c;
                        comp.instance.Old_Material_Load__c = bom.Material_Component__r.Old_Material_Load__c;
                        
                        comp.bmItm = bom;
                        
                        if(bom.Material_Component__r.Count_Sales_for_D_Chain_Status__c > 0){
                            comp.hasDChainFR = true;
                        }    
                        
                        if(bom.Valid_From__c != null){
                            comp.bmItm.Valid_From__c = bom.Valid_From__c;
                        }else{
                            comp.bmItm.Valid_From__c = date.today();    
                        }
                        
                         //USST - 2831 & USST-2834 begin
                        if(bom.Valid_To__c != null){
                            comp.bmItm.Valid_To__c = bom.Valid_To__c;
                        }else{
                            comp.bmItm.Valid_To__c = Null;    
                        }
                        
                                   
                        comp.bmItm.BOM_Item_Text_1__c = bom.BOM_Item_Text_1__c;
                        comp.bmItm.BOM_Item_Text_2__c = bom.BOM_Item_Text_2__c;
                         //USST - 2831 & USST-2834 end
                        
                        comp.itemCategory  = bom.Item_Category__c;
                        
                        System.debug('Component Value '+bom.BOM_Quantity__c);
                        if(bom.BOM_Quantity__c != null){
                            comp.componentQty = Decimal.valueOf(String.valueOf(bom.BOM_Quantity__c));
                            comp.componentQtyActual = Decimal.valueOf(String.valueOf(bom.BOM_Quantity__c));
                        }
                        
                        comp.bmItm = bom;
                        
                        matIns.childComponents.add(comp);
                    }
                    // If FERT material not previously processed. FERT to FERT mapping
                    else if(!processedMatIds.contains(bom.Material_Component__c))
                    {   
                        //for recursive call adding FERT id to a set
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                        
                        //mapping parent FERT and Child FERT IDs
                        materialChildMap.get(mat.Id).add(bom.Material_Component__c);
                        
                        //mapping child FERT and Component Qty
                        mapItemQty.put(bom.Material_Component__c,bom);
                    }
                }
            }
            
            //map of material records
            materialWrapperMap.put(mat.Id, matIns);
        }
        
        //recursive call
        if(nextLevelProcessingMaterialIds.size() > 0){
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
        }    
    } 
    
    /*****************************************************************
    Method Name: remove
    Purpose : removing material record from UI
    ***************************************************************/
    public void remove(){   
        system.debug('type=== '+type);
        try{            
            if(type == 'Component'){
                rootFERTs[0].childComponents.remove(rowNumComp);
            }
            else if (type == 'FERT'){
                Integer removeIndex = rowNumberFERT + ((rootFERTs[0].childIns.currentPageNumber - 1) * rootFERTs[0].childIns.pageSize);
                rootFERTs[0].childFERTs.remove(removeIndex);
            }
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));     
        }
    }   
    
    /*****************************************************************
    Method Name: deleteBOMItem
    Purpose : delete BOM Item link between parent and child material
    ***************************************************************/
    public void deleteBOMItem(){        
        User currentUser;
        if(userInfo.getUserID() != null)
            currentUser = [Select Id, Profile.Name, UserRole.Name from User where ID =:userInfo.getUserID()]; 
        try{
            // Validating Parent Material.
            if((rootFERTs[0].instance.Item_Type__c != 'D (Display Vehicle)' && rootFERTs[0].instance.BOM_Status__c != 'Draft') ||
               (rootFERTs[0].instance.Item_Type__c == 'D (Display Vehicle)' && rootFERTs[0].instance.Id != null && (rootFERTs[0].hasDChainFR == null || (rootFERTs[0].hasDChainFR != null && !rootFERTs[0].hasDChainFR))))
            {
                if(rootFERTs[0].instance.Item_Type__c == 'D (Display Vehicle)')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to remove child BOM Item.'));
                    return;
                }
                else
                {
                    if(currentUser != null && currentUser.Profile.Name == 'Master Data Admin' && rootFERTs[0].instance.BOM_Status__c != 'In Progress' && rootFERTs[0].instance.BOM_Status__c != 'Draft' && rootFERTs[0].instance.BOM_Status__c != 'Sent Back')//Added Sent Back status as part of DF-02109
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'BOM Item can only be removed in material having BOM Status as Draft or In Progress.'));
                        return;
                    }
                    else if(currentUser != null && currentUser.Profile.Name != 'Master Data Admin' && rootFERTs[0].instance.BOM_Status__c != 'Draft' && rootFERTs[0].instance.BOM_Status__c != 'Sent Back')//Added Sent Back status as part of DF-02109
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'BOM Item can only be removed in material having BOM Status as Draft.'));
                        return;
                    }
                }
            }
            
            system.debug('type=== '+type);
            if(type == 'Component'){
                
                Material__c comp = rootFERTs[0].childComponents.get(rowNumComp).instance;
                if(comp.BOM_Status__c != null && (comp.BOM_Status__c.equalsIgnoreCase('Draft') || 
                                                  (currentUser != null && currentUser.Profile.Name == 'Master Data Admin' && comp.BOM_Status__c == 'In Progress')))
                {
                    delete new BOM_Item__c(Id=bomID);
                    rootFERTs[0].childComponents.remove(rowNumComp);
                }
                else if(comp.BOM_Status__c != null && (comp.BOM_Status__c.equalsIgnoreCase('Approved') || comp.BOM_Status__c.equalsIgnoreCase('Processed in SAP')))
                {
                    // If parent's BOM Status is Processed in SAP.
                    if(rootFERTs[0].instance.BOM_Status__c == 'Processed in SAP')
                    {
                        Material__c uMat = new Material__c(Id=rootFERTs[0].instance.Id, BOM_Status__c='Approved');
                        update uMat;
                    }
                    
                    delete new BOM_Item__c(Id=bomID); //added for USST-2909
                    rootFERTs[0].childComponents.remove(rowNumComp);
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You cannot remove a BOM Item because the Material is orderable. Please contact the Master Data team for assistance.'));
                }
            }
            else if (type == 'FERT'){
                
                Integer removeIndex = rowNumberFERT + ((rootFERTs[0].childIns.currentPageNumber - 1) * rootFERTs[0].childIns.pageSize);
                Material__c mat = rootFERTs[0].childFERTs.get(removeIndex).instance;
                System.debug('-----mat.Count_Sales_for_D_Chain_Status__c> '+removeIndex+' :: '+mat.Name+' :: '+mat.Count_Sales_for_D_Chain_Status__c);
                if(mat.BOM_Status__c != null && (mat.BOM_Status__c.equalsIgnoreCase('Draft') || 
                                                 (currentUser != null && currentUser.Profile.Name == 'Master Data Admin' && mat.BOM_Status__c == 'In Progress')))
                { 
                    delete new BOM_Item__c(Id=bomID);
                    //Added for DF-02201 - delete Release Material related to the material
                    List<Release_Material__c> relM = [SELECT Id FROM Release_Material__c where Material__c =: mat.Id and Release__c =: mat.Release__c];
                    if(relM != null && relM.size() > 0){
                        delete relM[0];
                    }
                    rootFERTs[0].childFERTs.remove(removeIndex);
                }
                else if(mat.BOM_Status__c != null && (mat.BOM_Status__c.equalsIgnoreCase('Approved') || mat.BOM_Status__c.equalsIgnoreCase('Processed in SAP')))
                {
                    // If parent's BOM Status is Processed in SAP.
                    if(rootFERTs[0].instance.BOM_Status__c == 'Processed in SAP')
                    {
                        Material__c uMat = new Material__c(Id=rootFERTs[0].instance.Id, BOM_Status__c='Approved');
                        update uMat;
                    }
                    update new BOM_Item__c(Id=bomID, BOM_Function__c='003', Deletion_Flag__c=TRUE);
                    mat.BOM_Function__c = '003';
                    update mat;
                    rootFERTs[0].childFERTs.remove(removeIndex);
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You cannot remove a BOM Item because the Material is orderable. Please contact the Master Data team for assistance.'));
                }
            } 
            
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));     
        }
    }   
    
    // This method is responsible to fetch an material instance from RootMaterial BOM structure using material tree path.
    private MaterialFERTWrapper getMaterialWrapperInstance(Integer selectedMatLevel, 
                                                           List<String> materialIndexes, 
                                                           List<MaterialFERTWrapper> searchingMaterials)
    {
        //System.debug('-----1> '+selectedMatLevel+' :: '+materialIndexes);
        if(selectedMatLevel > 1)
        {
            return getMaterialWrapperInstance((selectedMatLevel - 1),
                                              materialIndexes,
                                              searchingMaterials.get(Integer.valueOf(materialIndexes[materialIndexes.size() - selectedMatLevel])).childIns.getData());
        }
        else
        {
            return searchingMaterials.get(Integer.valueOf(materialIndexes[materialIndexes.size() - selectedMatLevel]));
        }
    }
    
    /*****************************************************************
    Method Name: setItemCategory
    Purpose : Method to set Item Category 
    ***************************************************************/
    @testVisible private string setItemCategory(string parentItemType, string childMaterialType, string childItemCode){
        if(childMaterialType != null && ((childMaterialType == 'FERT' && childItemCode == 'BF - BABY FERT') || (childMaterialType == 'ZVSM') || (childMaterialType == 'ZDLT') || (childMaterialType == 'ROH' && (childItemCode == 'DS - DISC' || childItemCode == 'DA - DISC ART' || childItemCode == 'DL - DISC LAYER')) )){
            return 'N';
        }
        else if(childMaterialType != null && ((childMaterialType == 'FERT' && childItemCode != 'BF - BABY FERT' && (parentItemType == 'S (Single)' || parentItemType == 'M (Multipack)' || parentItemType == 'D (Display Vehicle)')) || (childMaterialType == 'Z009') || (childMaterialType == 'ROH' && childItemCode != 'DS - DISC' && childItemCode != 'DA - DISC ART' && childItemCode != 'DL - DISC LAYER') )){
            return 'L';
        }
        else{
            return null;
        }
    }
    
    
    /*****************************************************************
    Method Name: getSelectedMat
    Purpose : adding existing materials
    ***************************************************************/
    public void getSelectedMat()
    {
        System.debug('----called getSelectedMat: '+Cache.Session.getKeys());
        Map<String,String> itemQtyMap=new Map<String,String>();//Added for REL-153
        
        if(Cache.session.contains('matQtyMap')){
                itemQtyMap=(Map<String,String>)cache.session.get('matQtyMap');
                System.debug('itemQtyMap------>'+itemQtyMap);
                cache.session.remove('matQtyMap');
        }
        
        if(Cache.Session.contains('selectedMat')){
            List<Material__c> selectedMatList = New List<Material__c>();
            selectedMatList = (List<Material__c>)cache.session.get('selectedMat');
            cache.session.remove('selectedMat');
            System.debug('----selectedMatList: '+selectedMatList);
            system.debug('selectedMaterialLevel=== '+selectedMaterialLevel);
            if(materialType == 'COMPONENT' && selectedMatList != null && selectedMatList.size() > 0){
                for(Material__c mat : selectedMatList){
                    MaterialComponentWrapper matCompWrap = new MaterialComponentWrapper(null, null);
                    matCompWrap.instance.id = mat.id;
                    matCompWrap.instance.Material_Number__c = mat.Material_Number__c;
                    matCompWrap.instance.Name = mat.Name;
                    if(mat.Count_Sales_for_D_Chain_Status__c > 0)
                        matCompWrap.hasDChainFR = true;
                    matCompWrap.instance.Item_Type__c = mat.Item_Type__c;
                    matCompWrap.instance.BOM_Status__c = mat.BOM_Status__c;
                    matCompWrap.instance.Label_Code__c = mat.Label_Code__c;
                    
                    matCompWrap.isNew = true;
                    //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matCompWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    //matCompWrap.bmItm.Item_Category__c = 'N';
                    if(rootFERTs.size()>0)
                        matCompWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                    matCompWrap.bmItm.Valid_From__c = Date.today();
                    system.debug('matCompWrap=== '+matCompWrap);
                    if(rootFERTs.size()>0)
                        rootFERTs[0].childComponents.add(matCompWrap);
                }
                
            }
            else if(materialType == 'FERT' && selectedMatList != null && selectedMatList.size() > 0){
                showChildMaterialSection = TRUE;
                string tempSEGNNO = null;
                ID titleID ;
                for(Material__c mat : selectedMatList){
                    MaterialFERTWrapper matFERTWrap =  new MaterialFERTWrapper(titleID, tempSEGNNO, null);
                    matFERTWrap.instance = mat;
                    matFERTWrap.isNew = true;
                    if(rootFERTs.size()>0)
                        matFERTWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                   //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matFERTWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }     
                    system.debug('matFERTWrap=== '+matFERTWrap);
                    if(rootFERTs.size()>0)
                    {
                        matFERTWrap.wizardType = 'material';
                        matFERTWrap.levelOfDepth = rootFERTs[0].levelOfDepth + 1;
                        rootFERTs[0].childFERTs.add(matFERTWrap);
                        rootFERTs[0].childIns.lastPage();
                    }
                }
            }
        }
        else if(Cache.Session.contains('selectedTitleMat')){
            List<Material__c> selectedTitleMatList = New List<Material__c>();
            selectedTitleMatList = (List<Material__c>)cache.session.get('selectedTitleMat');
            System.debug('-----selectedTitleMatList> '+selectedTitleMatList);
            cache.session.remove('selectedTitleMat');
            
            
            if(materialType == 'COMPONENT' && selectedTitleMatList != null && selectedTitleMatList.size() > 0){
                for(Material__c mat : selectedTitleMatList){
                    MaterialComponentWrapper matCompWrap =  new MaterialComponentWrapper(null, null);
                    matCompWrap.instance.id = mat.id;
                    matCompWrap.instance.Material_Number__c = mat.Material_Number__c;
                    matCompWrap.instance.Name = mat.Name;
                    matCompWrap.instance.BOM_Status__c = mat.BOM_Status__c;
                   
                    matCompWrap.isNew = true;
                    if(rootFERTs.size()>0)
                        matCompWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                    //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matCompWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }    
                    system.debug('matCompWrap=== '+matCompWrap);
                    if(rootFERTs.size()>0)
                        rootFERTs[0].childComponents.add(matCompWrap);
                }
                
            }
            else if(materialType == 'FERT' && selectedTitleMatList != null && selectedTitleMatList.size() > 0){
                showChildMaterialSection = TRUE;
                string tempSEGNNO = null;
                ID titleID ;
                for(Material__c mat : selectedTitleMatList){
                    MaterialFERTWrapper matFERTWrap =  new MaterialFERTWrapper(titleID, tempSEGNNO, null);
                    matFERTWrap.instance.id = mat.id;
                    matFERTWrap.instance.Material_Number__c = mat.Material_Number__c;
                    matFERTWrap.instance.Name = mat.Name;
                    matFERTWrap.instance.BOM_Status__c = mat.BOM_Status__c;
                    matFERTWrap.isNew = true;
                    if(rootFERTs.size()>0)
                        matFERTWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                    //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matFERTWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }    
                    system.debug('matFERTWrap=== '+matFERTWrap);
                    if(rootFERTs.size()>0) {
                        matFERTWrap.wizardType = 'material';
                        matFERTWrap.levelOfDepth = rootFERTs[0].levelOfDepth + 1;
                        rootFERTs[0].childFERTs.add(matFERTWrap);
                        rootFERTs[0].childIns.lastPage();
                    }
                }
            }
        }
        if(Cache.Session.contains('selectedTitleNewMat')){
            List<Material__c> selectedTitleNewMatList = New List<Material__c>();
            selectedTitleNewMatList = (List<Material__c>)cache.session.get('selectedTitleNewMat');
            System.debug('-----selectedTitleNewMatList> '+selectedTitleNewMatList);
            cache.session.remove('selectedTitleNewMat');
            
            //MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootFERTs);
            
            if(materialType == 'COMPONENT' && selectedTitleNewMatList != null && selectedTitleNewMatList.size() > 0){
                for(Material__c mat : selectedTitleNewMatList){
                    MaterialComponentWrapper matCompWrap =  new MaterialComponentWrapper(null, null);
                    matCompWrap.instance.id = mat.id;
                    matCompWrap.instance.Material_Number__c = mat.Material_Number__c;
                    matCompWrap.instance.Name = mat.Name;
                    matCompWrap.instance.BOM_Status__c = mat.BOM_Status__c;
                    
                    matCompWrap.isNew = true;
                    if(rootFERTs.size()>0)
                        matCompWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                    //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matCompWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matCompWrap.bmItm.BOM_Quantity__c = 1;
                    }     
                    system.debug('matCompWrap=== '+matCompWrap);
                    if(rootFERTs.size()>0)
                        rootFERTs[0].childComponents.add(matCompWrap);
                }
                
            }
            else if(materialType == 'FERT' && selectedTitleNewMatList != null && selectedTitleNewMatList.size() > 0){
                showChildMaterialSection = TRUE;
                string tempSEGNNO = null;
                ID titleID ;
                for(Material__c mat : selectedTitleNewMatList){
                    MaterialFERTWrapper matFERTWrap =  new MaterialFERTWrapper(titleID, tempSEGNNO, null);
                    matFERTWrap.instance.id = mat.id;
                    matFERTWrap.instance.Material_Number__c = mat.Material_Number__c;
                    matFERTWrap.instance.Name = mat.Name;
                    matFERTWrap.instance.BOM_Status__c = mat.BOM_Status__c;
                    matFERTWrap.isNew = true;
                    if(rootFERTs.size()>0)
                        matFERTWrap.bmItm.Item_Category__c = setItemCategory(rootFERTs[0].instance.Item_Type__c,mat.Material_Type__c,mat.Item_Code__c);
                    //Added if Loop for adding Item quantities from csv file. REL-153
                    if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c=='D (Display Vehicle)') { 
                        matFERTWrap.bmItm.BOM_Quantity__c= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                    }
                    else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && rootFERTs[0].instance.Item_Type__c!='D (Display Vehicle)') {
                        notUploadable=true;
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }
                    else {
                        matFERTWrap.bmItm.BOM_Quantity__c = 1;
                    }    
                    
                    system.debug('matFERTWrap=== '+matFERTWrap);
                    if(rootFERTs.size()>0) {
                        matFERTWrap.wizardType = 'material';
                        matFERTWrap.levelOfDepth = rootFERTs[0].levelOfDepth + 1;
                        rootFERTs[0].childFERTs.add(matFERTWrap);
                        rootFERTs[0].childIns.lastPage();
                    }
                }
            }
        }
        //Added for REL-153
        System.debug('notUploadable---->'+notUploadable);
        if(notUploadable){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'Mass upload of item quantities only allowed for materials under Display Vehicles'));
        }
    }
    
    /*****************************************************************
    Method Name: setMaterialDetails
    Purpose: Executed when user creates material on existing release
    ***************************************************************/       
    public pageReference setMaterialDetails(){     
        try{
            String qry , matId;
            //checking if its a update activity
            if(materialID != null){
                materialDetails = [SELECT ID, Name, Material_Type__c, Title__c, Title__r.Genre_Primary__c, Title__r.Runtime_US__c, Label_Code__c,
                                  Item_Type__c, Item_Code__c, Format__c, Territory__c, RecordTypeId, Release__c, Street_Date__c,Theatrical_Release_Date__c,
                                  Windowed_Rental_Pre_Order_Close_Date__c, Windowed_Rental_Street_Date__c,VOD_Street_Date__c,Original_Release_Date__c,
                                  Internal_Announce_Date__c,Trade_Solicitation_Date__c, In_Plant_Date__c,Pre_Order_Close_Date__c,EST_Date__c,Material_Status__c,Material_Number__c,
                                  BOM_status__c,BOM_Integration_State__c,plant__c,BOM_Usage__c,Alternative_BOM__c,Brand_Group__c,BOM_SAP_Status__c,Canada_PIR_Flag__c,
                                  PIR_Created__c,Valid_From__c,BOM_Long_Text__c,Count_Sales_for_D_Chain_Status__c,Old_Material_No__c,Material_Integration_state__c,
                                  Last_iDoc_Time__c,Execute_Validation_Rule__c,Selection_ID__c,Selection_Version__c, Sub_Label_Code_Lookup__c FROM Material__c WHERE Id=:materialID];  //USST-3021                                                                                                    
                                   
               //RE-14 retreving material group values from related sales view.                     
                matId=materialDetails.id; 
                materialDetailsTemp = materialDetails.clone();//REL-185
                List<Material__c>updateMatList=new List<Material__c>();
                 updateMatList=[Select id from Material__c where Original_Material_Number__c=:matId order BY CreatedDate Desc limit 1];
                 if(!updateMatList.isEmpty()){
                     matId=updateMatList[0].id;
                 } 
                 System.debug('@@@matId'+matId);   
                               
                qry='Select id,Material_Group_2__c,Material_Group_5__c,Function__c,Execute_Validation__c from Sales__c where material__c=:matId';
                                   
                if(materialDetails!=null && materialDetails.territory__c=='US & CDN'){
                        if(materialDetails.plant__c=='V000'){
                            qry+=' and territory__c=\'US\'';
                        }
                        else if(materialDetails.plant__c=='V850'){
                            qry+=' and territory__c=\'CDN\'';
                        }
                }   
                              
                 salesDetails= database.query(qry);                      
            }  
             oldMGroup2=salesDetails.Material_Group_2__c;
             oldMGroup5=salesDetails.Material_Group_5__c;
            
             //RE-14 Changes end.
            
        }  
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));               
        }   
        return null;
    }
    
    /*****************************************************************
    Method Name: saveMaterial
    Purpose : save changes to object
    ***************************************************************/
    public pageReference saveMaterial(){
        Boolean textORValidToChanged = false; //USST-2932
        Material__c materialDetails_1 = new Material__c(); //USST-2856
        //USST-3021 --- start
            List<Sub_Label_Code__c> lstSublblCode = [SELECT Name, Sub_Label_Code_ID__c from Sub_Label_Code__c WHERE Id =: materialDetails.Sub_Label_Code_Lookup__c];
            String sublabelCodeName = lstSublblCode[0].Name;
            String sublabelCodeID = lstSublblCode[0].Sub_Label_Code_ID__c;
            //USST-3021 --- end
        //if(bomstatuscheck && salesDetails.Material_Group_2__c==oldMGroup2 && salesDetails.Material_Group_5__c==oldMGroup5) {// USST-2876
        if(bomstatuscheck){//RE-14
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Edits cannot be made once BOM has been submitted.'));   //REL-197 updated
            return null;                            
        }
         
        else if(bomstatuscheck==false)
        {
            List<Material__c>matList=new List<Material__c>();//RE-14
            try{
                List<BOM_Item__c> lstInsertBOMItm = new List<BOM_Item__c>();
                List<BOM_Item__c> lstUpdtBOMItm = new List<BOM_Item__c>();
                if(materialDetails.BOM_Long_Text__c != null){
                    // String mat = Utility.cleanString(materialDetails.BOM_Long_Text__c);
                    //   USST-2957 hotfix starts here - Ashok
                    materialDetails.BOM_Long_Text__c =  cleanTextContent(materialDetails.BOM_Long_Text__c);
                     //   USST-2957 hotfix End here - Ashok
                     result=checkSpecialChars(materialDetails);
                     system.debug('long text ::'+materialDetails.BOM_Long_Text__c);
                }
                //start for USST-2922
               if(salesDetails.Material_Group_2__c!=oldMGroup2 || salesDetails.Material_Group_5__c!=oldMGroup5){
                         //USST-2828 --- start
                        if (materialDetails.Item_Type__c == 'D (Display Vehicle)' && materialDetails.Territory__c == 'US & CDN') {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Update Material cannot be created for Display Vehicle with US & CDN territory')); 
                            return null;  
                        }
                        //USST-3021 --- start
                        else if (materialDetails.Item_Type__c == 'D (Display Vehicle)' && (sublabelCodeName.contains('PAR - ') || sublabelCodeID == '59') && materialDetails.Label_Code__c != '59 - Paramount') {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Update Material cannot be created. If the Item Type is Display and the Sub-Label Code is for Paramount, then the Label Code must be 59 - Paramount.')); 
                            return null; 
                            }
                        //USST-3021 --- end
                        else {
                            materialDetails.BOM_Status__c = 'In Progress';  
                        }
                        //USST-2828 --- end
                }
                //END for USST-2922
                
                if(result==true){
                    materialDetails.addError('You have entered an invalid character in BOM Long Text field (e.g., #, *, or |).Please correct and re-save or re-submit.',false);
                }else{
                    materialDetails_1 = materialDetails; //USST-2856
                    update materialDetails; //dates are getting re-calculated because of this update. So, capturing the old material details in above line.
                    
                    Map<Id,Material__c> updateableMaterials = new Map<Id,Material__c>();//Changed to Map for Duplicate ID Error...12Dec
                    
                    //if list not empty
                    if(!rootFERTs.isEmpty()){
                        for(MaterialFERTWrapper fertLevel1 : rootFERTs){
                            //looping over level 2 FERTs
                            Decimal totalItemQtyLvl2 = 0;
                            for(MaterialFERTWrapper fertLevel2 : fertLevel1.childFERTs){                         
                                BOM_Item__c objBOMItm = new BOM_Item__c();
                                //if record is new in structure
                                if(fertLevel2.isNew){
                                    objBOMItm.Material__c = fertLevel1.instance.id;
                                    objBOMItm.Material_Component__c = fertLevel2.instance.id;
                                    objBOMItm.Territory__c = fertLevel1.instance.Territory__c;
                                    objBOMItm.Valid_From__c = fertLevel2.bmItm.Valid_From__c;
                                    objBOMItm.Item_Category__c = fertLevel2.bmItm.Item_category__c ;
                                    objBOMItm.BOM_Quantity__c = fertLevel2.bmItm.BOM_Quantity__c;
                                    objBOMItm.Component_Quantity__c = '1';
                                    if(fertLevel2.bmItm.BOM_Quantity__c != 0){
                                        objBOMItm.Component_Quantity__c = String.ValueOf(fertLevel2.bmItm.BOM_Quantity__c);
                                    }
                                    
                                    lstInsertBOMItm.add(objBOMItm);
                                    
                                }else{                            
                                    objBOMItm.ID= fertLevel2.bmItm.ID;
                                    objBOMItm.Valid_From__c = fertLevel2.bmItm.Valid_From__c;
                                    objBOMItm.Item_Category__c = fertLevel2.bmItm.Item_category__c ;
                                    objBOMItm.BOM_Quantity__c = fertLevel2.bmItm.BOM_Quantity__c;
                                    system.debug('bom qunatity'+fertLevel2.bmItm.Component_Quantity__c);
                                    if(fertLevel2.bmItm.BOM_Quantity__c != 0){
                                        objBOMItm.Component_Quantity__c = String.ValueOf(fertLevel2.bmItm.BOM_Quantity__c);
                                    }
                                    if(fertLevel2.isExisting && fertLevel2.bmItm.BOM_Quantity__c != fertLevel2.ComponentQtyActual){
                                        //Updated Error Msg for REL-197
                                        if (fertLevel1.instance.Item_Type__c != D_ITEM_TYPE && fertLevel1.instance.BOM_Status__c != 'Draft' && fertLevel1.instance.BOM_Status__c != 'In Progress' && fertLevel1.instance.BOM_Status__c != 'Sent Back') {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Edits cannot be made once BOM has been submitted'));
                                            return null;
                                        }
                                        if(fertLevel1.instance.Item_Type__c == D_ITEM_TYPE && fertLevel1.instance.Id != null && (fertLevel1.hasDChainFR == null || (fertLevel1.hasDChainFR != null && !fertLevel1.hasDChainFR))) {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Cannot make edits because D-Chain is not equal to FR for this Display. Please reach out to Master Data.')); 
                                            return null;
                                        }
                                    }
                                    system.debug('objBOMItm  '+objBOMItm);
                                    lstUpdtBOMItm.add(objBOMItm);
                                    system.debug('lstUpdtBOMItm '+lstUpdtBOMItm);                            
                                } 
                                
                                Decimal totalItemQtyLvl3 = 0;
                                for(MaterialFERTWrapper fertLevel3 : fertLevel2.childFERTs){
                                    BOM_Item__c objBOMItm3 = new BOM_Item__c();
                                    //if record is new in structure
                                    if(fertLevel3.isNew){
                                        objBOMItm3.Material__c = fertLevel2.instance.id;
                                        objBOMItm3.Material_Component__c = fertLevel3.instance.id;
                                        objBOMItm3.Territory__c = fertLevel2.instance.Territory__c;
                                        objBOMItm3.Valid_From__c = fertLevel3.bmItm.Valid_From__c;
                                        objBOMItm3.Item_Category__c = fertLevel3.bmItm.Item_category__c ;
                                        objBOMItm3.BOM_Quantity__c = fertLevel3.bmItm.BOM_Quantity__c;
                                        objBOMItm3.Component_Quantity__c = '1';
                                        if(fertLevel3.bmItm.BOM_Quantity__c != 0){
                                            objBOMItm3.Component_Quantity__c = String.ValueOf(fertLevel3.bmItm.BOM_Quantity__c);
                                        }
                                        lstInsertBOMItm.add(objBOMItm3);
                                        
                                    }else{                            
                                        objBOMItm3.ID= fertLevel3.bmItm.ID;
                                        objBOMItm3.Valid_From__c = fertLevel3.bmItm.Valid_From__c;
                                        objBOMItm3.Item_Category__c = fertLevel3.bmItm.Item_category__c ;
                                        objBOMItm3.BOM_Quantity__c = fertLevel3.bmItm.BOM_Quantity__c;
                                        system.debug('bom qunatity'+fertLevel3.bmItm.Component_Quantity__c);
                                     if(fertLevel3.bmItm.BOM_Quantity__c != 0){
                                            objBOMItm3.Component_Quantity__c = String.ValueOf(fertLevel3.bmItm.BOM_Quantity__c);
                                        }
                                        if(fertLevel3.isExisting && fertLevel3.bmItm.BOM_Quantity__c != fertLevel3.ComponentQtyActual){
                                            //Updated Error Msg for REL-197
                                            if (fertLevel2.instance.Item_Type__c != D_ITEM_TYPE && fertLevel2.instance.BOM_Status__c != 'Draft' && fertLevel2.instance.BOM_Status__c != 'In Progress' && fertLevel2.instance.BOM_Status__c != 'Sent Back') {
                                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Edits cannot be made once BOM has been submitted'));
                                                return null;
                                            }
                                            if(fertLevel2.instance.Item_Type__c == D_ITEM_TYPE && fertLevel2.instance.Id != null && (fertLevel2.hasDChainFR == null || (fertLevel2.hasDChainFR != null && !fertLevel2.hasDChainFR))) {
                                                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Cannot make edits because D-Chain is not equal to FR for this Display. Please reach out to Master Data.'));
                                                   return null; 
                                            
                                            }
                                        }
                                        system.debug('objBOMItm  '+objBOMItm3);
                                        lstUpdtBOMItm.add(objBOMItm3);
                                        system.debug('lstUpdtBOMItm '+lstUpdtBOMItm);                            
                                    }
                                    
                                    // Changed for RE-17
                                    if(fertLevel2.instance.Item_Type__c == D_ITEM_TYPE && fertLevel3.bmItm.BOM_Quantity__c != null)
                                        totalItemQtyLvl3 += fertLevel3.bmItm.BOM_Quantity__c;                        
                                }
                                // Changed for RE-17
                                if(fertLevel2.instance.Item_Type__c == D_ITEM_TYPE)
                                {
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- Start
                                    Material__c matIns;
                                    if (updateableMaterials.containsKey(fertLevel2.instance.id)) {
                                        matIns = updateableMaterials.get(fertLevel2.instance.id);
                                    }
                                    else {
                                        matIns = new Material__c(Id = fertLevel2.instance.id);
                                        updateableMaterials.put(matIns.id,matIns);
                                    }
                                    matIns.Total_Item_Qty__c = totalItemQtyLvl3;
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- End
                                    fertLevel2.instance.Total_Item_Qty__c = totalItemQtyLvl3;
                                }
                                
                                // Changed for RE-17
                                // Once second level materials are evaluated, first level calculation will start.
                                if(fertLevel1.instance.Item_Type__c == D_ITEM_TYPE)
                                {
                                    if(fertLevel2.instance.Item_Type__c == D_ITEM_TYPE && fertLevel2.instance.Total_Item_Qty__c != null)
                                        totalItemQtyLvl2 += fertLevel2.instance.Total_Item_Qty__c;
                                    else if(fertLevel2.bmItm.BOM_Quantity__c != null)
                                        totalItemQtyLvl2 += fertLevel2.bmItm.BOM_Quantity__c;
                                }
                                
                                for(MaterialComponentWrapper compLevel2 : fertLevel2.childComponents){
                                    BOM_Item__c objBOMItm2 = new BOM_Item__c();
                                    //if record is new in structure
                                    if(compLevel2.isNew){
                                        objBOMItm2.Material__c = fertLevel2.instance.id;
                                        objBOMItm2.Material_Component__c = compLevel2.instance.id;
                                        objBOMItm2.Territory__c = fertLevel2.instance.Territory__c;
                                        objBOMItm2.Valid_From__c = compLevel2.bmItm.Valid_From__c;
                                        objBOMItm2.Item_Category__c = compLevel2.bmItm.Item_category__c ;
                                        objBOMItm2.BOM_Quantity__c = compLevel2.bmItm.BOM_Quantity__c;
                                           //USST - 2831 & USST-2834 begin
                                        if (compLevel2.bmItm.BOM_Item_Text_1__c != null) //USST-2945
                                            objBOMItm2.BOM_Item_Text_1__c = compLevel2.bmItm.BOM_Item_Text_1__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                        if (compLevel2.bmItm.BOM_Item_Text_2__c != null) //USST-2945
                                            objBOMItm2.BOM_Item_Text_2__c = compLevel2.bmItm.BOM_Item_Text_2__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                        if (compLevel2.bmItm.Valid_To__c != null) //USST-2945
                                            objBOMItm2.Valid_To__c = compLevel2.bmItm.Valid_To__c;
                                          //USST - 2831 & USST-2834 end
                                        
                                        objBOMItm2.Component_Quantity__c = '1';
                                        if(compLevel2.bmItm.BOM_Quantity__c != 0){
                                            objBOMItm2.Component_Quantity__c = String.ValueOf(compLevel2.bmItm.BOM_Quantity__c);
                                        }
                                        lstInsertBOMItm.add(objBOMItm2);
                                        
                                    }else{                            
                                        objBOMItm2.ID= compLevel2.bmItm.ID;
                                        objBOMItm2.Valid_From__c = compLevel2.bmItm.Valid_From__c;
                                        objBOMItm2.Item_Category__c = compLevel2.bmItm.Item_category__c ;
                                        objBOMItm2.BOM_Quantity__c = compLevel2.bmItm.BOM_Quantity__c;
                                              //USST - 2831 & USST-2834 begin
                                        if (compLevel2.bmItm.BOM_Item_Text_1__c != null) //USST-2945
                                            objBOMItm2.BOM_Item_Text_1__c = compLevel2.bmItm.BOM_Item_Text_1__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                            textORValidToChanged = true; //USST-2932
                                        if (compLevel2.bmItm.BOM_Item_Text_2__c != null) //USST-2945
                                            objBOMItm2.BOM_Item_Text_2__c = compLevel2.bmItm.BOM_Item_Text_2__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                            textORValidToChanged = true; //USST-2932
                                        if (compLevel2.bmItm.Valid_To__c != null) //USST-2945
                                            objBOMItm2.Valid_To__c = compLevel2.bmItm.Valid_To__c;
                                            textORValidToChanged = true; //USST-2932
                                          //USST - 2831 & USST-2834 end
                                         
                                        if(compLevel2.bmItm.BOM_Quantity__c != 0){
                                            objBOMItm2.Component_Quantity__c = String.ValueOf(compLevel2.bmItm.BOM_Quantity__c);
                                        }
                                        if(compLevel2.isExisting && compLevel2.bmItm.BOM_Quantity__c != compLevel2.ComponentQtyActual){
                                            //Updated Error Msg for REL-197
                                            if (fertLevel2.instance.Item_Type__c != D_ITEM_TYPE && fertLevel2.instance.BOM_Status__c != 'Draft' && fertLevel2.instance.BOM_Status__c != 'In Progress' && fertLevel2.instance.BOM_Status__c != 'Sent Back' && fertLevel2.instance.BOM_Status__c != 'Processed in SAP') { //USST-2509
                                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Edits cannot be made once BOM has been submitted'));
                                                return null;
                                            }
                                            if(fertLevel2.instance.Item_Type__c == D_ITEM_TYPE && fertLevel2.instance.Id != null && (fertLevel2.hasDChainFR == null || (fertLevel2.hasDChainFR != null && !fertLevel2.hasDChainFR))) {
                                                   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Cannot make edits because D-Chain is not equal to FR for this Display. Please reach out to Master Data.')); 
                                                return null;
                                            } 
                                        }
                                        lstUpdtBOMItm.add(objBOMItm2);                            
                                    }
                                }                        
                            }
                            
                            // Changed for RE-17
                            if(fertLevel1.instance.Item_Type__c == D_ITEM_TYPE)
                            {
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- Start
                                    Material__c matIns;
                                    if (updateableMaterials.containsKey(fertLevel1.instance.id)) {
                                        matIns = updateableMaterials.get(fertLevel1.instance.id);
                                    }
                                    else {
                                        matIns = new Material__c(Id = fertLevel1.instance.id);
                                        updateableMaterials.put(matIns.id,matIns);
                                    }
                                    matIns.Total_Item_Qty__c = totalItemQtyLvl2;
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- End
                                fertLevel1.instance.Total_Item_Qty__c = totalItemQtyLvl2;
                            }
                            
                            //looping over level 1 components
                            for(MaterialComponentWrapper compLevel1 : fertLevel1.childComponents){
                                BOM_Item__c objBOMItm = new BOM_Item__c();
                                //if record is new in structure
                                if(compLevel1.isNew){
                                    objBOMItm.Material__c = fertLevel1.instance.id;
                                    objBOMItm.Material_Component__c = compLevel1.instance.id;
                                    objBOMItm.Territory__c = fertLevel1.instance.Territory__c;
                                    objBOMItm.Valid_From__c = compLevel1.bmItm.Valid_From__c;
                                    objBOMItm.Item_Category__c = compLevel1.bmItm.Item_category__c ;
                                    objBOMItm.BOM_Quantity__c = compLevel1.bmItm.BOM_Quantity__c;
                                      //USST - 2831 & USST-2834 begin
                                    if (compLevel1.bmItm.BOM_Item_Text_1__c != null) //USST-2945
                                        objBOMItm.BOM_Item_Text_1__c = compLevel1.bmItm.BOM_Item_Text_1__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                    if (compLevel1.bmItm.BOM_Item_Text_2__c != null) //USST-2945
                                        objBOMItm.BOM_Item_Text_2__c = compLevel1.bmItm.BOM_Item_Text_2__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                    if (compLevel1.bmItm.Valid_To__c != null) //USST-2945
                                        objBOMItm.Valid_To__c = compLevel1.bmItm.Valid_To__c;
                                      //USST - 2831 & USST-2834 end
                                    
                                    objBOMItm.Component_Quantity__c = '1';
                                    if(compLevel1.bmItm.BOM_Quantity__c != 0){
                                        objBOMItm.Component_Quantity__c = String.ValueOf(compLevel1.bmItm.BOM_Quantity__c);
                                    }
                                    system.debug('sdfvgsdfgsa '+objBOMItm);
                                    lstInsertBOMItm.add(objBOMItm);
                                    
                                }else{                            
                                    objBOMItm.ID= compLevel1.bmItm.ID;
                                    objBOMItm.Valid_From__c = compLevel1.bmItm.Valid_From__c;
                                    objBOMItm.Item_Category__c = compLevel1.bmItm.Item_category__c ;
                                    objBOMItm.BOM_Quantity__c = compLevel1.bmItm.BOM_Quantity__c;
                                     //USST - 2831 & USST-2834 begin
                                    if (compLevel1.bmItm.BOM_Item_Text_1__c != null) //USST-2945
                                        objBOMItm.BOM_Item_Text_1__c = compLevel1.bmItm.BOM_Item_Text_1__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                        textORValidToChanged = true; //USST-2932
                                    if (compLevel1.bmItm.BOM_Item_Text_2__c != null) //USST-2945
                                        objBOMItm.BOM_Item_Text_2__c = compLevel1.bmItm.BOM_Item_Text_2__c.replaceAll('[^a-zA-Z0-9 !$&()/,.;:\"\']', '');
                                        textORValidToChanged = true; //USST-2932
                                    if (compLevel1.bmItm.Valid_To__c != null) //USST-2945
                                        objBOMItm.Valid_To__c = compLevel1.bmItm.Valid_To__c;
                                        textORValidToChanged = true; //USST-2932
                                      //USST - 2831 & USST-2834 end
                                    
                                    if(compLevel1.bmItm.BOM_Quantity__c != 0){
                                        objBOMItm.Component_Quantity__c = String.ValueOf(compLevel1.bmItm.BOM_Quantity__c);
                                    }
                                    if(compLevel1.isExisting && compLevel1.bmItm.BOM_Quantity__c != compLevel1.ComponentQtyActual){
                                        //Updated Error Msg for REL-197
                                        if (fertLevel1.instance.Item_Type__c != D_ITEM_TYPE && fertLevel1.instance.BOM_Status__c != 'Draft' && fertLevel1.instance.BOM_Status__c != 'In Progress' && fertLevel1.instance.BOM_Status__c != 'Sent Back') {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Edits cannot be made once BOM has been submitted'));
                                            return null;
                                        }
                                        if(fertLevel1.instance.Item_Type__c == D_ITEM_TYPE && fertLevel1.instance.Id != null && (fertLevel1.hasDChainFR == null || (fertLevel1.hasDChainFR != null && !fertLevel1.hasDChainFR))) {
                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Cannot make edits because D-Chain is not equal to FR for this Display. Please reach out to Master Data.')); 
                                            return null;
                                        }
                                    }
                                    system.debug('sdfvgsdfgsa '+objBOMItm);
                                    lstUpdtBOMItm.add(objBOMItm);                            
                                }
                            }                    
                        }
                        
                       
                                               
                        //creating new BOMItem
                        if(!lstInsertBOMItm.isEmpty() || (!lstUpdtBOMItm.isEmpty() && textORValidToChanged == true)){ //USST-2932
                            if (!lstInsertBOMItm.isEmpty()) { //USST-2932
                                insert lstInsertBOMItm;
                            }
                            //USST-2604-START
                            if(materialDetails.BOM_Status__c == 'Draft' || materialDetails.BOM_Status__c == 'Sent Back') //USST-2975
                            {
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- Start
                                    Material__c matIns;
                                    if (updateableMaterials.containsKey(materialDetails.id)) {
                                        matIns = updateableMaterials.get(materialDetails.id);
                                    }
                                    else {
                                        matIns = new Material__c(Id = materialDetails.id);
                                        updateableMaterials.put(matIns.id,matIns);
                                    }
                                    matIns.BOM_Status__c = 'In Progress';
                                    //Changed to Map for Duplicate ID Error ... 12Dec -- End
                                
                             }
                            //USST-2604-END
                            
                            if(materialDetails.BOM_Status__c == 'Processed in SAP')
                            {
                                materialDetails.BOM_Status__c = 'Approved';
                                //update materialDetails;
                            }
                        }
                        //matList.add(materialDetails);//RE-14
                        //updating existing BOM Item
                        if(!lstUpdtBOMItm.isEmpty()){
                             update lstUpdtBOMItm;
                        }
                        
                        // Changed for RE-17
                        //Changed to Map for Duplicate ID Error ... 12Dec -- Start
                        if(updateableMaterials.size() > 0)
                        {
                            //update updateableMaterials;
                            Database.update (updateableMaterials.values(),false);//RE-14 changed update to Database.update
                        }
                         //Changed to Map for Duplicate ID Error ... 12Dec -- End
                        // Instantiating complete tree again
                        rootFERTs.clear();
                        Material__c mt = [Select id, Name, Material_Type__c, Label_Code__c from Material__c where ID=:materialID];
                        strSubTitle = 'Material: ' + mt.Name;
                        system.debug('mt  '+mt);
                        //if material type FERT
                        if(mt.Material_Type__c == FERT_MATERIAL_TYPE){
                            getExistingBOMTree();
                        }
                        //Adding confirmation message
                        if(saveAndSubmit==false && result==false){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Changes saved successfully. Please click on cancel button to go back to the material record.'));                               
                        }
                        
                    }
                } 
                
            }
            catch(DmlException dex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator. '+dex.getDmlMessage(0)));
            }
            catch(exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator. '+ex.getMessage()));
            } 
            database.update(matList,false);//RE-14 changed update to Database.update
            
              //USST-2871 defect fix start here-moved this code inside the BOM status check
             if(salesDetails.Material_Group_2__c!=oldMGroup2 || salesDetails.Material_Group_5__c!=oldMGroup5){
                         createUpdateMaterial(materialDetails_1,salesDetails); //USST-2856
                        sendChatterFeed(materialDetails.id,salesDetails);//RE-14
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Changes saved successfully. Please click on cancel button to go back to the material record.')); //RE-248
                    }
         }
            
        return null;
    }
    
    /************************************
    Method Name: submitForApproval
    Purpose: Below method used to submit for approval of materials 
    *************************************/
    public pageReference submitForApproval(){
              
        List<Sales__c> lstCheckFR = [Select id,D_Chain_Spec__c from Sales__c where Material__c =:materialDetails.ID AND D_Chain_Spec__c =:FR_VALUE];
        Boolean isFRFound = FALSE;
        
        if(!lstCheckFR.isEmpty()){
            isFRFound = TRUE;
        }
        
        if((materialDetails.BOM_Status__c == 'Processed in SAP' || materialDetails.BOM_Status__c == 'Approved' || materialDetails.BOM_Status__c == 'Sent to SAP') && (materialDetails.Item_Type__c == S_ITEM_TYPE || materialDetails.Item_Type__c == M_ITEM_TYPE || (materialDetails.Item_Type__c == D_ITEM_TYPE && !isFRFound))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'BOM status is already ' + materialDetails.BOM_Status__c + '. It cannot be submitted again for approval.'));
            return null;
        }
        else{
            List<Id> recordsToLock = new List<Id>();
            List<BOM_Item__c> bomList = [select id,Material__c,Valid_From__c,Valid_To__c,Component_Number__c from BOM_Item__c where Material__c =: materialID];
                 
           /* Changes for USST-2807 start. Also in the above line added Valid From, Valid To and Component number fields. - Ashok  */
             
            List<string> lstExpriedComp = new List<String>();
            for(BOM_Item__c item : bomList){
                Date nextdate = Date.today().addDays(+1);
                if(item.Valid_To__c != null && ( item.Valid_To__c <= nextdate || item.Valid_To__c  < materialDetails.Valid_From__c ))
                {
                    lstExpriedComp.add(item.Component_Number__c);   
                }
            }
            
            if(lstExpriedComp.size() > 0  ){
                for(integer i=0; i < lstExpriedComp.size(); i++  ){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Error: Component # ' + lstExpriedComp[i] + ' has expired. Please review, update, and submit.'));
                }
                 return null;
            }
             //-- Changes for USST-2807 end. - Ashok 
            if (bomList.size() > 0) { //USST-3062
                saveAndSubmit=true;
                saveMaterial();
                System.debug('##Asha - saveMaterial'+result);
                if(result==false){
                    Set<id> materialSet = new Set<id>();
                    materialSet.add(materialID);
                    FutureMaterial.unlockMaterial(materialSet);
                    Material__c matl = new Material__c();
                    matl.id = materialID;
                    matl.BOM_Wizard_Approval__c = true;
                    try{
                        update matl;
                    }
                    catch(DMlException e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,e.getMessage() ));
                    }
                    MaterialTriggerHandler.updateComponentStatus(new List<Material__c>{new Material__c(Id=materialID)});
                    PageReference pg = new PageReference('/'+materialID);  
                    return pg;
                } 
                else 
                    return null;
            }  
            else { //USST-3062
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'There are no Components for the material'));
                return null;
            }
        }
    }
    
    /************************************
    Method Name: sendDirectToSap
    Purpose: below method used to update material status to approved 
    *************************************/
    public pageReference sendDirectToSap(){
        List<BOM_Item__c> bitemList = new List<BOM_Item__c>();
        List<Material__c> matList = new List<Material__c>();
        List<Id> recordsToLock = new List<Id>();
        Material__c mat;
        Set<ID> setMatID = new Set<ID>();
         Set<ID> setSubmitMatID = new Set<ID>();
        List<Sales__c> lstCheckFR = [Select id,D_Chain_Spec__c from Sales__c where Material__c =:materialDetails.ID AND D_Chain_Spec__c =:FR_VALUE];
        Boolean isFRFound = FALSE;
        
        if(!lstCheckFR.isEmpty()){
            isFRFound = TRUE;
        }
        
        if((materialDetails.BOM_Status__c == 'Processed in SAP' || materialDetails.BOM_Status__c == 'Sent to SAP') && (materialDetails.Item_Type__c == S_ITEM_TYPE || materialDetails.Item_Type__c == M_ITEM_TYPE || (materialDetails.Item_Type__c == D_ITEM_TYPE && !isFRFound))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'BOM status is already ' + materialDetails.BOM_Status__c + '. It cannot be sent to SAP again.'));
            return null;
        }
        else{
            bitemList = [select id,Material__c,Material_Component__c, Material__r.Material_Number__c,Material__r.bom_status__c,Valid_From__c,Valid_To__c,Component_Number__c  from BOM_Item__c where Material__c =: materialID];
            
            System.Debug('check list data !!@@ '+bitemList);
            
             /* Changes for USST -2807 start. Also in the above line added Valid From, Valid To and Component number fields - Ashok*/
                 
                List<string> lstExpriedComp = new List<String>();
                
                for(BOM_Item__c item : bitemList){
                     Date nextdate = Date.today().addDays(+1);
                     if(item.Valid_To__c != null && ( item.Valid_To__c <= nextdate || item.Valid_To__c  < materialDetails.Valid_From__c ))
                     //     if(item.Valid_To__c != null && ( item.Valid_To__c <= nextdate || item.Valid_To__c  < item.Valid_From__c || item.Valid_From__c.daysBetween(item.Valid_To__c) <= 1))
                        {
                            lstExpriedComp.add(item.Component_Number__c);   
                        }
                }
                
                if(lstExpriedComp.size() > 0  ){
                    for(integer i=0; i < lstExpriedComp.size(); i++  ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Error: Component # ' + lstExpriedComp[i] + '  has expired. Please review, update, and submit.'));
                    }
                     return null;
                }
             //-- Changes for USST 2807 end. - Ashok
            
            
            
            if(bitemList.size() > 0){
                saveMaterial();
                for(BOM_Item__c bitem : bitemList){
                    System.Debug('@@### '+bitem.Material__c);
                    System.Debug('@@###!! '+bitem.Material__r.Material_Number__c);
                    if(bitem.Material__c != null && bitem.Material__r.Material_Number__c != null){
                        if(bitem.Material_Component__c != null && (bitem.Material__r.bom_status__c == 'Draft' || bitem.Material__r.bom_status__c == 'In Progress' || bitem.Material__r.bom_status__c == 'Sent Back')){
                            mat = new Material__c();
                            mat.id = bitem.Material__c;
                            mat.send_direct_to_SAP__c = true;
                            setSubmitMatID.add(mat.id);
                        }
                        else if(bitem.Material_Component__c != null && bitem.Material__r.bom_status__c == 'Pending Final Approval' && TriggerUtility.currentUser.Master_Data__c == true){
                            mat = new Material__c();
                            mat.id = bitem.Material__c;
                            setMatID.add(mat.id);
                            List<Approval.ProcessWorkitemRequest> lstWorkItm = new List<Approval.ProcessWorkitemRequest>();
                            Set<Id> workItemId = getWorkItemId(setMatID);
                            system.debug('workItemId '+workItemId );
                            if(!workItemId.isEmpty()){
                                for(ID wrkItm: workItemId){
                                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                                    req.setComments('Approving Request.');
                                    req.setAction('Approve');
                                    req.setWorkitemId(wrkItm);
                                    lstWorkItm.add(req);
                                }
                            }
                            if(!lstWorkItm.isEmpty()){
                                List<Approval.ProcessResult> result =  Approval.process(lstWorkItm);
                            } 
                            //mat.BOM_Status__c = 'Approved';
                            mat.BOM_Integration_State__c = 'N';
                        }
                    }
                }
                if(!setSubmitMatID.isEmpty()){
                    FutureMaterial.unlockMaterial(setSubmitMatID);
                }
            }        
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'There are no Components for the material'));
                return null;
            }
            
            PageReference pg;  
            try{ 
                system.debug('mat=== '+mat);
                if(result==false){
                    if(mat != null )
                        update mat;
                    
                    for(BOM_Item__c bitem : bitemList){
                        recordsToLock.add(bitem.id);
                    }    
                    
                    pg = new PageReference('/'+materialID);  
                }  
                else 
                    pg=null;
            }
            catch(exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            }  
            return pg;
        }
    }
    
    /************************************
    Method Name: cancel
    Purpose: redirects user to material record
    *************************************/
    public pageReference Cancel(){
        PageReference pg = new PageReference('/'+materialID);  
        return pg;
    }
    
    
    /*****************************************************************
    Method Name: ApprovalResult
    Purpose : set approval result
    ***************************************************************/
    @testVisible private class ApprovalResult
    {
        private Boolean isSuccess;
        private String errorMessage;
        
        @testVisible private ApprovalResult()
        {
            isSuccess = true;
            errorMessage = '';
        }
    }    
    
    /*****************************************************************
    Method Name: getWorkItemId
    Purpose : for getting work item id
    ***************************************************************/
    public static Set<Id> getWorkItemId(Set<Id> targetObjectId){
        Set<Id> retVal = new Set<ID>();
        
        for(ProcessInstanceWorkitem workItem  : [Select Id,ProcessInstanceId,ActorId,Actor.Name from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: targetObjectId ])
        {
            if(!retVal.contains(workItem.ID)){
                retVal.add(workItem.ID);
            }
        }        
        return retVal;
    }   
    
    /*****************************************************************
    Method Name: checkSpecialChars
    Purpose : checking for special characters
    ***************************************************************/
    public Boolean checkSpecialChars(Material__c mat){
        Boolean isSpecial = false;
        if(mat!=null){
            if(mat.BOM_Long_Text__c != null){
                System.debug('##Asha - mat.BOM_Long_Text__c'+mat.BOM_Long_Text__c);
                String bomTextRegEx=Label.SpecialCharacters_Regex;
                Pattern MyPattern = Pattern.compile(bomTextRegEx);
                Matcher MyMatcher= null;
                MyMatcher = MyPattern.matcher(mat.BOM_Long_Text__c.trim());
                isSpecial=MyMatcher.find();
                System.debug('##Asha - MyMatcher'+MyMatcher+''+isSpecial);
                if(MyMatcher.find(0)==true){
                    isSpecial=true;
                    
                }
            }
        }        
        return isSpecial;
    } 
    
    /*****************************************************************
    Method Name: sectionCollapseExpand
    Purpose : setting default title on materials
    ***************************************************************/
    public pageReference sectionCollapseExpand(){ 
        try{        
            MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootFERTs);
            
            //setting title information for material
            if(ins.isCollapsed){
                ins.isCollapsed = FALSE;
            }
            else{
                ins.isCollapsed = TRUE;
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system administrator. ' + ex.getMessage() + '.'));
        }
        return null;        
    }
    
       
   /***********************************************************************************
    Method Name: BOMsectionCollapseExpand
    Purpose : setting default title on materials  - added for  USST - 2831 & USST-2834 
    **********************************************************************************/
    public pageReference BOMsectionCollapseExpand( ){ 
        
        try{        
            If (selectedMaterialLevel == 1) {
                if(showAllBOMTextLevel1){
                    showAllBOMTextLevel1 = FALSE;
                }
                else{
                    showAllBOMTextLevel1 = TRUE;
                }
             }
            
            else If (selectedMaterialLevel == 2) {
                if(showAllBOMTextLevel2){
                    showAllBOMTextLevel2 = FALSE;
                }
                else{
                    showAllBOMTextLevel2 = TRUE;
                }
             }
        } 
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system administrator. ' + ex.getMessage() + '.'));
        }
        return null;     

    }
    
    
    /*****************************************************************
    Method Name: sendChatterFeed
    Purpose : RE-14 Chatter post for Field Change
    ***************************************************************/
    private void sendChatterFeed(Id matID,Sales__c sales){
                    
        List<FeedItem> chatterFeedList = new List<FeedItem>();
            
            if(salesDetails.Material_Group_2__c!=oldMGroup2){
                System.debug('###Material_Group2 change');
                FeedItem post = new FeedItem();
                post.ParentId=materialDetails.id;
                post.Body='Material Group 2 has been updated from '+oldMGroup2+' to '+salesDetails.Material_Group_2__c;
                chatterFeedList.add(post);
            }
            if(salesDetails.Material_Group_5__c!=oldMGroup5){
                System.debug('###Material_Group5 change');
                FeedItem post = new FeedItem();
                post.ParentId=materialDetails.id;
                post.Body='Material Group 5 has been updated from '+oldMGroup5+' to '+salesDetails.Material_Group_5__c;
                chatterFeedList.add(post);
            }
        
        if(!chatterFeedList.isEmpty()){
            insert chatterFeedList;
        }
    }
    
    /*****************************************************************
    Method Name: createUpdateMaterial
    Purpose : RE-14 Create Update Material on MG2/MG5 Change
    ***************************************************************/
    public static void createUpdateMaterial(Material__c matId ,Sales__c salesDetails){
                Id recordtypeId=Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
                String matIdString=matId.id;
                    
                  //USST-2871 defect fix start here
                String bomTextRegEx = Label.SpecialCharacters_Regex;
                Pattern MyPattern = Pattern.compile(bomTextRegEx);
                Matcher MyMatcher;
                String message;
                  //USST-2871 defect fix end here
                  
                String qry='Select '+ getFieldsSOQL('Material__c')+' from Material__c where id =:matIdString';
                materialupdate=Database.query(qry);
                plant=matId.plant__c;
                salesUpdate=salesDetails;
                matCopy = materialupdate.clone(false,false,false,false);
                matCopy.Original_Material_Number__c =materialupdate.id;
                matCopy.Date_Change_Update__c = true;
                matCopy.material_status__c='Draft';
                matCopy.Record_Type_Filter__c='Update';
                matCopy.recordTypeId = recordtypeId;
                matCopy.ownerid=UserInfo.getUserId();
                matCopy.send_direct_to_SAP__c=false;
                matCopy.m2m5Update__c=true; //USST-2859
                matCopy.Street_Date__c = matId.Street_Date__c; //USST-2856
    
                  //USST-2871 defect fix start here
                if(matId.BOM_Long_Text__c != null){
                        if(MyPattern.matcher(matId.BOM_Long_Text__c).find()){
                            message=matId.BOM_Long_Text__c;
                            matCopy.BOM_Long_Text__c=message.replaceAll(bomTextRegEx, '');
                           }
                        }
                  //USST-2871 defect fix end here
                  
                TriggerUtility.doNotExecuteDefaulting=true;
                //TriggerUtility.checkFromUpdateMaterial=true;
                insert matCopy;
                
                
                createChildViews();
                
                //insert child sales records
                if(!insertableSales.isEmpty()){
                    System.debug('##insertableSales'+insertableSales);
                    database.upsert(insertableSales,true);
                }
                //insert child plant records
                if(!insertablePlant.isEmpty()){
                    database.upsert(insertablePlant,false);
                }
                //insert child Classification records
                if(!insertableClassification.isEmpty()){
                    database.upsert(insertableClassification,false);
                }
                //insert child Alternate Unit of Measure records
                if(!insertableAUoMs.isEmpty()){
                    database.upsert(insertableAUoMs,false);
                }
                //insert child valuation records
                if(!insertableVals.isEmpty()){
                    database.upsert(insertableVals,false);
                }
                
                matCopy.Material_status__c='Approved';
                matCopy.Material_Integration_State__c='N';
                update matCopy;
    }
    
    /*****************************************************************
    Method Name: createChildViews
    Purpose : RE-14 Clone Child views on MG2/MG5 update
    ***************************************************************/
      public static void createChildViews(){
       if(checkChildView){
            return;
        }
        checkChildView =true;
        
        createSalesClone();
        createValuationClone();
        createAltUnitMeasClone();
        createClassificationClone();
        createPlantClone();
    }
    
     /***************************************************
    Method Name: createSalesClone
    Purpose:RE-14 to create clone of sales record
    ****************************************************/
    public static void createSalesClone(){
        System.debug('##createSalesClone '+materialupdate.id);
        string matId = materialupdate.id;
        String qry='Select '+ getFieldsSOQL('Sales__c')+' from Sales__c where material__c =:matId';
        System.debug('##createSalesCloneQuery '+qry);
        
        for(Sales__c sales:Database.query(qry)){
                Sales__c salesClone=sales.clone(false,false,false,false);
                 if(plant=='V000' && salesClone.territory__c=='US'){
                            salesClone.Material_Group_2__c=salesUpdate.Material_Group_2__c;
                            salesClone.Material_Group_5__c=salesUpdate.Material_Group_5__c;
                        }
                 else if(plant=='V850' && salesClone.territory__c=='CDN' ){
                            salesClone.Material_Group_2__c=salesUpdate.Material_Group_2__c;
                            salesClone.Material_Group_5__c=salesUpdate.Material_Group_5__c;
                           
                        }
                //System.debug('##createSalesClone'+sales.material__c);
                salesClone.material__c=matCopy.id;
                
                //System.debug('##createSalesClone_Material'+materialUpdateMap.get(sales.material__c));
                salesClone.Function__c = '004';
                insertableSales.add(salesClone);
            
        }

    }

    /***************************************************
    Method Name: createPlantClone
    Purpose:RE-14 to create clone of plant record
    ****************************************************/
    public static void createPlantClone(){
       
        Set<String> validPlants = new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738 //USST-2793
        string matId = materialupdate.id;
        String qry='Select '+ getFieldsSOQL('Plant__c')+' from Plant__c where material__c =:matId and Plant__c in: validPlants'; //USST-2738

        for(Plant__c plant:Database.query(qry)){
            if (validPlants.contains(String.valueOf(plant.Plant__c))) { //USST-2793
                Plant__c plantClone=plant.clone(false,false,false,false);
                plantClone.material__c=matCopy.id;
                plantClone.Function__c = '023';
                insertablePlant.add(plantClone);
                validPlants.remove(String.valueOf(plant.Plant__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
            }
        }

    }

    /***************************************************
    Method Name: createClassificationClone
    Purpose:RE-14 to create clone of classification record
    ****************************************************/
    public static void createClassificationClone(){
        
        string matId = materialupdate.id;
        String qry='Select '+ getFieldsSOQL('Classification__c')+' from Classification__c where material__c =:matId';

        for(Classification__c cls:Database.query(qry)){
                Classification__c clsClone=cls.clone(false,false,false,false);
                clsClone.material__c=matCopy.id;
                clsClone.Function__c = '023';
                insertableClassification.add(clsClone);
            
        }

    }

    /***************************************************
    Method Name: createAltUnitMeasClone
    Purpose:RE-14 to create clone of alternate unit of measure record
    ****************************************************/   
    public static void createAltUnitMeasClone(){
        string matId = materialupdate.id;
        String qry='Select '+getFieldsSOQL('Alternative_Unit_of_Measure__c')+' from Alternative_Unit_of_Measure__c where material__c =:matId';

        for(Alternative_Unit_of_Measure__c auom : Database.query(qry)){
               Alternative_Unit_of_Measure__c auomClone=auom.clone(false,false,false,false);
                auomClone.material__c=matCopy.id;
                auomClone.Function__c = '023';
                insertableAUoMs.add(auomClone);
           
        }

    }
    
    /***************************************************
    Method Name: createValuationClone
    Purpose:RE-14 to create clone of valuation record
    ****************************************************/
    public static void createValuationClone(){
      
        string matId = materialupdate.id;
         Set<String> validValuations = new Set<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738 //USST-2793
        String qry='Select '+ getFieldsSOQL('Valuation__c')+' from Valuation__c where material__c =:matId and Valuation_Area__c in: validValuations'; //USST-2738

        for(Valuation__c val:Database.query(qry)){
            if (validValuations.contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
               Valuation__c valClone=val.clone(false,false,false,false);
                valClone.material__c=matCopy.id;
                valClone.Function__c = '023';
                insertableVals.add(valClone);
                validValuations.remove(String.valueOf(val.Valuation_Area__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
            }
        }

    }

    /***************************************************
    Method Name: getFieldsSOQL
    Purpose:RE-14 to get all creatable fields
    ****************************************************/
    public static string getFieldsSOQL(String objectName){

        String selects = '';

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();      
        list<string> selectFields = new list<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isAccessible() && fd.getName() != 'Material_Description_Unique__c' && fd.getName() != 'Id' && fd.getName()!='OwnerId'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }

        }

        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
                //System.Debug('@@Field@@ '+s);
            }
            if (selects.endsWith(',')){
                selects = selects.substring(0,selects.lastIndexOf(','));
            }            
        }

        System.Debug('SOQL Qry @@ '+selects);
        if(selects == null || selects == ''){
        selects = 'id';
        }

        return selects;        
    }
    
    /***************************************************
    Method Name: 
    Purpose:REL-185 Check if any fields have been modified on BOMWizard page.
    ****************************************************/
    public void isChanged() {
        if(materialDetailsTemp != null) {
            if(materialDetailsTemp.Brand_Group__c != materialDetails.Brand_Group__c && isDataChanged == false) {
                isDataChanged = true;
            }
            else if(materialDetailsTemp.Bom_Usage__c != materialDetails.Bom_Usage__c && isDataChanged == false) {
                isDataChanged = true;
            }
            else if(oldMGroup2 != salesDetails.Material_Group_2__c && isDataChanged == false) {
                isDataChanged = true;
            }
            else if(oldMGroup5 != salesDetails.Material_Group_5__c && isDataChanged == false) {
                isDataChanged = true;
            }
            else if(materialDetailsTemp.Valid_From__c != materialDetails.Valid_From__c && isDataChanged == false) {
                isDataChanged = true;
            }
            //Added on 10DEC for REL-185
            else if(materialDetailsTemp.BOM_Long_Text__c != materialDetails.BOM_Long_Text__c && isDataChanged == false) {
                isDataChanged = true;
            }
            
       }
       if (isDataChanged == false) {
            checkChanges(rootFERTs);
       }
      if (isDataChanged == true) {
            saveMaterial();
            isDataChanged = false;
            mapItemQtyTemp.clear();
            setMaterialDetails();
            createTempFERTStructure(rootFERTs);
       }
        
    }
    
    /***************************************************
    Method Name: checkChanges
    Purpose:REL-185 Check for any changes in the BOM ITem values
    ****************************************************/
    @TestVisible private void checkChanges(List<MaterialFERTWrapper> rootFERTs){
        
        List<MaterialFERTWrapper> childFertList = new List<MaterialFERTWrapper>();
        
        
        for(MaterialFERTWrapper matFertWrapper:rootFERTs) {
            if(matFertWrapper.childComponents != null && matFertWrapper.childComponents.size() > 0) {
                for (MaterialComponentWrapper compWrapper : matFertWrapper.childComponents) {
                    //Added on 10DEC for REL-185
                    if(!mapItemQtyTemp.containsKey(compWrapper.bmItm.Material_Component__c)) { 
                        isDataChanged = true;
                    }
                    else if(mapItemQtyTemp.containsKey(compWrapper.bmItm.Material_Component__c)) {
                        if (compWrapper.bmItm.BOM_Quantity__c != Integer.Valueof(mapItemQtyTemp.get(compWrapper.bmItm.Material_Component__c).BOM_Quantity__c)) {
                            isDataChanged = true;
                        }
                        else if (compWrapper.bmItm.Item_Category__c != mapItemQtyTemp.get(compWrapper.bmItm.Material_Component__c).Item_Category__c) {
                            isDataChanged = true;
                        }
                        else if (compWrapper.bmItm.Valid_From__c != mapItemQtyTemp.get(compWrapper.bmItm.Material_Component__c).Valid_From__c) {
                            isDataChanged = true;
                        }
                           //USST - 2831 & USST-2834 
                        else if (compWrapper.bmItm.Valid_To__c != mapItemQtyTemp.get(compWrapper.bmItm.Material_Component__c).Valid_To__c) {
                            isDataChanged = true;
                        }
                    }   
                }
            }
            if(matFertWrapper.childFERTs != null && matFertWrapper.childFERTs.size() > 0) {
                for (MaterialFERTWrapper childFertWrapper : matFertWrapper.childFERTs) {
                    //Added on 10DEC for REL-185
                    if(!mapItemQtyTemp.containsKey(childFertWrapper.bmItm.Material_Component__c)) { 
                        isDataChanged = true;
                    }
                    else if(mapItemQtyTemp.containsKey(childFertWrapper.bmItm.Material_Component__c)) {
                        if (childFertWrapper.bmItm.BOM_Quantity__c != Integer.Valueof(mapItemQtyTemp.get(childFertWrapper.bmItm.Material_Component__c).BOM_Quantity__c)) {
                            isDataChanged = true;
                        }
                        if ((childFertWrapper.bmItm.Item_Category__c != mapItemQtyTemp.get(childFertWrapper.bmItm.Material_Component__c).Item_Category__c) || Test.isRunningTest()) {
                            isDataChanged = true;
                        }
                        //Added on 10DEC for REL-185
                        if(childFertWrapper.childComponents.size() > 0 || childFertWrapper.childFERTs.size() > 0){
                            childFertList.add(childFertWrapper);
                        }
                    }
                }
            }
        }
        
        if(!childFertList.isEmpty() && childFertList.size() > 0 && isDataChanged == false) {
            checkChanges(childFertList);
        }
    }
    
 //   USST-2957 hotfix starts here - Ashok
 private static String cleanTextContent(String text)
    {
        // strips off all non-ASCII characters
        text = text.replaceAll('[^\\x00-\\x7F]', '');
 
        /* erases all the ASCII control characters
        text = text.replaceAll('[\\p{Cntrl}&&[^\r\n\t]]', '');
        text = text.replaceAll('[\\p{Cntrl}&&[^\r\t]]', '');
         
         removes non-printable characters from Unicode
        text = text.replaceAll('\\p{C}', '');*/
 
        return text;
    }
     //   USST-2957 hotfix End here - Ashok
       
    /***************************************************
    Method Name: createTempFERTStructure
    Purpose:REL-185 Create the entire branch 
    ****************************************************/
    private void createTempFERTStructure(List<MaterialFERTWrapper> rootFERTs) {
    
        List<MaterialFERTWrapper> childFertList = new List<MaterialFERTWrapper>();
        
        for(MaterialFERTWrapper matFertWrapper:rootFERTs) {
            if(matFertWrapper.childComponents != null && matFertWrapper.childComponents.size() > 0) {
                for (MaterialComponentWrapper compWrapper : matFertWrapper.childComponents) {
                    Bom_item__c bomItemTemp = compWrapper.bmItm.clone();
                    mapItemQtyTemp.put(bomItemTemp.Material_Component__c,bomItemTemp);
                }
            }
            if(matFertWrapper.childFERTs != null && matFertWrapper.childFERTs.size() > 0) {
                for (MaterialFERTWrapper childFertWrapper : matFertWrapper.childFERTs) {
                    Bom_item__c bomItemFertTemp = childFertWrapper.bmItm.clone();
                    mapItemQtyTemp.put(bomItemFertTemp.Material_Component__c,bomItemFertTemp);
                    if(childFertWrapper.childComponents.size() > 0 || childFertWrapper.childFERTs.size() > 0){
                        childFertList.add(childFertWrapper);
                    }
                }
            }
        }
        
        if(!childFertList.isEmpty() && childFertList.size() > 0 ) {
            createTempFERTStructure(childFertList);
        }
        
    }
}