/*****************************************************************************************
/*****************************************************************************************
Class Name: MaterialCreationWizardController
Purpose: Apex page for material creation wizard
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016           Suman/Mohit/Ipsita       Initial Development
2.0             19/09/2016           Mohit                    Changes done as part of STY-00555
3.0             08/09/2017           Jyothsna                 Changes done as part of REL-17 and REL-20
******************************************************************************************/
public with sharing class MaterialCreationWizardController
{
     /****private static variables****/
     private static final string FERT_MATERIAL_TYPE = 'FERT'; 
     private static final string ROH_MATERIAL_TYPE = 'ROH';
     private static final string Z009_MATERIAL_TYPE = 'Z009';
     private static final string COMP_ITEM_TYPE = 'C - Components';
     private static final string S_ITEM_TYPE = 'S (Single)';
     private static final string SS_ITEM_CODE = 'SS - SINGLE SELECTION';
     private static final string COMBO_PACK = 'COMBO PACK';
     private static final string COMPONENT_ITEM_TYPE = 'Components';
     private static final string DS_ITEM_CODE = 'DS - DISC';
     private static final string PG_ITEM_CODE = 'PG - PACKAGING';
     private static final string M_ITEM_TYPE = 'M (Multipack)';
     private static final string D_ITEM_TYPE = 'D (Display Vehicle)';
     private static final string CL_ITEM_CODE = 'CL - COLLECTION PACK';
     private static final string MT_ITEM_CODE = 'MT - MULTI-TITLE';
     private static final string BF_ITEM_CODE = 'BF - BABY FERT';
     private static final string FT_ITEM_CODE = 'FT - PHANTOM TRAY';
     private static final string ME_ITEM_CODE = 'ME - TV MULTIPLE EPISODES';
     private static final string SE_ITEM_CODE = 'SE - TV SINGLE EPISODES';
     private static final string LABEL_CODE_59_PARAMOUNT = '59 - Paramount';
     private static final string LABEL_CODE_87_JC = '87 - JOINT CORR/MULTI-STUDIO';
     private static final string DVD_WIZARD_FORMAT = 'DVD';
     private static final string BRAND_USER_PROFILE = 'Brand User';
     private static final string US_TERRITORY = 'US';
     private static final string CDN_TERRITORY = 'CDN';
     private static final string US_CDN_TERRITORY = 'US & CDN';
     private static final string CE_ITEM_CODE = 'CE - COMPILATIONS';
     private static final string TITLE_TYPE_CODE = 'U/A - Unallocated (Standalone)';
     private static final string PHE_BRAND_GROUP = 'PHE Nickelodeon';  //REL-20 (Creation of Multi-Territory Discs) //REL-93
     
     private static Set<String> setHardDelete = new Set<String>{'Submitted', 'Draft'};   
     private static Set<String> setRemoveLink = new Set<String>{'Approved', 'Sent to SAP', 'SAP Error', 'Processed in SAP'};
     
     /****private variables****/
     private ID releaseID; //to get release id from URL
     private ID titleID; //to get title id from URL
     private ID materialID; //to get material id from URL
     @testVisible private List<Material__c> lstMaterialRecords; //for inserting FERT material
     @testVisible private List<Material__c> lstChildMaterial; // For inserting ROH material
     @testVisible private List<Material__c> lstMaterialRecordsChild; //for inserting child FERT material
     @testVisible private List<Material__c> lstChildMaterialComponent; //for inserting child ROH material
     private List<BOM_Item__c> lstBOMItem; //for inserting BOM Item 
     private List<Material__c> updateableParentMats;
     private boolean checkAssociationSelected; //to identify if user wants to associate a FERT to a existing DISC
     private List<Release_Material__c> lstReleaseMaterial; //List for inserting release  material records which is a link betwen material and release
     private List<Material__c> lstAllInsertedMaterials; //List contains all material inserted 
     private ID defaultRecordTypeId; //to store record type id for default records
     private ID masterRecordTypeId; //to store record type id    
     private List<Material_Template__c> lstMaterialTemplate; //to store material template data
     @testVisible private Map<ID,Title__c> mapTitleDetails; //map to store title details
     @testVisible private boolean checkLinkComponents;  //to check if link component page has to be opened
     public Boolean hasError{get; private set;}  //to check if error is present
     public Boolean hasError2{get; private set;}  //to check if error is present
     private String territory; //to store territory
     @testVisible private Set<Id> matFERTIds; //set of FERT ID
     @testVisible private Set<Id> matROHIds;  //set of ROH ID
     private Map<String, String> pageParameters {get; private set;} //map of page URL parameters    
     private List<Release_Material__c> insertableReleaseMaterials; // for inserting Release Materials.
     private set<string> setDuplicateName;
     private set<string> setUniqueName;
     private set<string> setLengthyName; //USST-2765
     private set<ID> setBMID;
     private set<ID> setMatID;
     private set<ID> setMatIDRM;
     private set<ID> setMatIDException;
     private string releaseType;
     private List<Material__c> lstTempMaterial;
     private boolean isInsertedMT;
     private boolean isInsertedRM;
     private boolean isInsertedBI;
     private Map<ID,String> mapBOMQty = new Map<ID,String>();
     private set<ID> setMultitleID;
     private Map<ID,Boolean> mapBFPresent;
     private String wizardType;
     
     /****public variables****/   
     public List<Material__c> lstReleaseFormats; //Used in template for FERT records
     public List<Material__c> lstChildFormatForParent; //Used for storing default records for ROH material type    
     public boolean showTitleInputField {get;set;} // Input field will be shown if user is not starting the functionality from Title detail page
     public boolean showTitleOutputField {get;set;} //Output field will be shown if user is starting the functionality from Title detail page
     public boolean showRelInputField {get;set;}// Input field will be shown if user is not starting from release detail page
     public boolean showRelOutputField {get;set;}//Output field will be shown if user is starting from release detail page
     public string strTempRelName{get;set;} // to store release name temporarily
     public boolean useTemplate{get;set;}// to identify if user wants to use template functionality
     public Integer formatRowToRemove {get;set;} //to set row number of parent material in wizard    
     public boolean showAddFormat{get;set;} //to show wizrd after activity type has been selected
     public Integer compRowNumber{get;set;} //to store component row number for parent material in wizard
     public boolean showChildMaterialSection{get;set;} //to show child material section within a wizard
     public Integer compChildRowNumber{get;set;} //to store component row number for child material in wizard
     public Integer formatChildRowToRemove {get;set;} //to set child row number of material in wizard
     public Release__c releaseDetails {get;set;}  //for setting release details on VF page
     public Material__c materialDetails {get;set;}
     public String selectedTemplateId {get; set;} // Added for REL-45
     public List<SelectOption> availableTemplates { // Added for REL-45
         get {
             List<SelectOption> tmplates = new List<SelectOption>();
             if(releaseDetails.Brand_Group__c != null && releaseDetails.Brand_Group__c.trim() != '')
             {
                 tmplates.add(new SelectOption('', '-- None --'));
                 for(Material_Template__c ins : [SELECT Id, Template_Name__c FROM Material_Template__c 
                                                 WHERE Brand_Group__c=:releaseDetails.Brand_Group__c AND Is_Active__c=true
                                                 ORDER BY Template_Name__c])
                 {
                     tmplates.add(new SelectOption(ins.Id, ins.Template_Name__c));
                 }
             }
             return tmplates;
         }
         set;
     }
     public Boolean showPopUp{get;set;}
     public Boolean showMultiDiscPopUp {get;set;}    // Added for RE-20
     public Boolean showChildPopUp{get;set;}
     public integer qtyCount{get;set;}
     public integer multiDiscQty{get;set;}    // Added for RE-20
     public String selectedDiscType {get; set;}    // Added for RE-20
     public List<SelectOption> discTypes {    // Added for RE-20
         get {
             List<SelectOption> tmpDiscTypes = new List<SelectOption>();
             tmpDiscTypes.add(new SelectOption('DISC CD', 'DISC CD'));
             tmpDiscTypes.add(new SelectOption('DISC DVD', 'DISC DVD'));
             tmpDiscTypes.add(new SelectOption('DISC BD', 'DISC BD'));
             tmpDiscTypes.add(new SelectOption('DISC UHD', 'DISC UHD'));
             
             return tmpDiscTypes;
         }
         private set;
     }
     public boolean showMaterialDesc{get;set;}
     public Integer addComponentsToIndex {get;set;}
     public Integer addMaterialsToIndex {get;set;}
     public Integer addChildComponentsToIndex{get;set;}
     public Integer frmtRowNumChild{get;set;}
     public Integer frmtRowNumParent{get;set;}
     public Boolean showReleaseNew {get; private set;}
     public Boolean showReleaseView {get; private set;}
     public Boolean showMaterialNew {get; private set;}
     public Boolean showMaterialView {get; private set;}    
     public List<MaterialFERTWrapper> rootFERTs {get; set;}
     public String materialIndex {get; set;}
     public Integer componentIndex {get; set;}
     public Integer selectedMaterialLevel {get; set;}
     public String materialType {get; set;}
     public String operatingObject {get; private set;}
     private List<Material__c> updateableParentMaterialList = new List<Material__c>();
     private List<Alternative_Unit_of_Measure__c> updateableAUoMList = new List<Alternative_Unit_of_Measure__c>();
     private List<BOM_Item__c> updateableBOMItemList = new List<BOM_Item__c>();
     private List<BOM_Item__c> deleteableBOMItemList = new List<BOM_Item__c>();
     private Map<ID,string> mapItemQty = new Map<ID,string>();
     public boolean showMPM{get;set;}
     @testvisible private boolean hasException;
     private string exceptionMessage;
     public string addToTop {get;set;}    
     public user u{get;set;} //to store user logged in user details
     public string sourceType {get;set;}
     public boolean negativeScearioTesting {get;set;}
     public PaginationHandler rootIns {get;set;}
     
     //REL-18
     public Boolean notUploadable{get;set;}
     
     //REL-198
    public String previousBrandGroup {get; set;}
    public Boolean isWizardHasDiscComponent {get; set;}
         
     /************************************
     Method Name: MaterialCreationWizardController
     Purpose: Constructor
     *************************************/    
     public MaterialCreationWizardController()
     {   
         //Initializing root FERT list
         rootFERTs = new List<MaterialFERTWrapper>();
         rootIns = new PaginationHandler();
         rootIns.assignRecordList(rootFERTs);
         
         //getting page parameters
         pageParameters = ApexPages.currentPage().getParameters();
         
         //Setting boolean varialbles  
         addToTop = 'FALSE';
         useTemplate = FALSE;
         showAddFormat = FALSE;
         showChildMaterialSection = FALSE;
         showPopUp = FALSE;
         showMultiDiscPopUp = FALSE;    // Added for RE-20
         showChildPopUp = FALSE;
         qtyCount = 0;
         showMaterialDesc = FALSE;
         checkLinkComponents = FALSE;
         showReleaseNew = false;
         showReleaseView = false;
         showMaterialNew = false;
         showMaterialView = false;
         showMPM = FALSE;
         hasError = FALSE;
         negativeScearioTesting = FALSE;
         hasError2 = FALSE;
         operatingObject = 'Release';
         //Initializing List
         releaseDetails = new Release__c(); 
         materialDetails = new Material__c();
         mapTitleDetails = new Map<ID,Title__c>();
         hasException = FALSE;
         exceptionMessage = '';
         setBMID = new Set<ID>();
         setMatID = new Set<ID>();
         setMatIDRM = new Set<ID>();
         setMatIDException = new Set<ID>();
         lstTempMaterial = new List<Material__c>();
         isInsertedMT = FALSE;
         isInsertedRM = FALSE;
         isInsertedBI = FALSE;
         setMultitleID = new Set<ID>();
         //REL-18
         notUploadable=false;
         isWizardHasDiscComponent = false; //REL-198
             
         mapBFPresent = new Map<ID,Boolean>();        
         //getting logged in user details
         u = new User();
         u = [Select id,brand_Group__c,Label_Code__c,profile.name from User where id=:userinfo.getuserid()];
         
         if(u.Label_Code__c  == LABEL_CODE_59_PARAMOUNT){
             showMPM = TRUE;
         }
        
         
         //checking source from which page has been opened
         if(pageParameters.containsKey('source'))
         {   
             //storing page source so that remove button can be rendered accordingly for Level 1 FERT
             sourceType = pageParameters.get('source');
             
             //if page opened from title detail
             if(pageParameters.get('source').equalsIgnoreCase('TitleDetail'))
             {
                 showReleaseNew = true;
                 wizardType = 'release';
                 if(pageParameters.containsKey('id'))
                     titleID = pageParameters.get('id');
                     
                     releaseDetails.Brand_Group__c = u.Brand_Group__c;
                     releaseDetails.Label_Code__c = u.Label_Code__c;
                     releaseType = 'New';
                     
                     if(u.Brand_Group__c == 'Catalog'){
                         releaseDetails.Project_type__c = 'Catalog';
                     }
                     else if(u.Brand_Group__c != null && u.Brand_Group__c != 'Catalog') {
                         releaseDetails.Project_type__c = 'New Release';
                     }
             }
             //if page opened from release list view
             else if(pageParameters.get('source').equalsIgnoreCase('ReleaseListView'))
             {
                 showReleaseNew = true;
                 wizardType = 'release';
                 releaseDetails.Brand_Group__c = u.Brand_Group__c;               
                 releaseDetails.Label_Code__c = u.Label_Code__c;
                 releaseType = 'New';
                 if(pageParameters.containsKey('titleId') && pageParameters.get('titleId') != null && pageParameters.get('titleId') != ''){
                     releaseDetails.Title__c = pageParameters.get('titleId');
                 }
                 
                 if(u.Brand_Group__c == 'Catalog'){
                     releaseDetails.Project_type__c = 'Catalog';
                 }
                 else if(u.Brand_Group__c != null && u.Brand_Group__c != 'Catalog') {
                     releaseDetails.Project_type__c = 'New Release';
                 }
             }
             //if page opened from release detail page
             else if(pageParameters.get('source').equalsIgnoreCase('ReleaseDetail'))
             {
                 showReleaseView = true;
                 wizardType = 'release';
                 if(pageParameters.containsKey('id'))
                 {
                     releaseID = pageParameters.get('id');
                     getExistingBOMTree();
                 }
                 
                 releaseType = 'Existing';
             }
             //if page opened from material list view page
             else if(pageParameters.get('source').equalsIgnoreCase('MaterialListView'))
             {
                 showMaterialNew = true;
                 wizardType = 'material';
                 operatingObject = 'Material';
                 releaseDetails = null;
                 releaseType = 'None';
             }
             //if page opened from material detail
             else if(pageParameters.get('source').equalsIgnoreCase('MaterialDetail'))
             {
                 showMaterialView = true;
                 wizardType = 'material';
                 operatingObject = 'Material';
                 if(pageParameters.containsKey('id'))
                 {
                     materialID = pageParameters.get('id');
                     getExistingBOMTree();
                 }
                 
                 releaseType = 'None';
             }
         }
         
         if(wizardType == 'material')
             rootIns.pageSize = 1;
         else
             rootIns.pageSize = 4; //USST-2946
         
         //Getting record type id for default records
         defaultRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Default Value').getRecordTypeId();
         masterRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId(); 
         
         
         
         //If process is started from release detail page
         if(releaseID != null){
             List<Release__c> relRecord =  [select id,recordtypeid from release__c where recordtype.name = 'Competitive' and id  = : releaseID];
             if(!relRecord.isEmpty()){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Materials can not be requested for this release.'));     
             }
             else{
                 showRelInputField = FALSE;
                 showRelOutputField = TRUE;
                 
                 releaseDetails.Release__c = releaseID;
                 setReleaseDetails();
             }
         }
         //if process started from title detail page
         else if(titleID != null){            
             showRelInputField = FALSE;
             showRelOutputField = FALSE;
             showTitleInputField = FALSE;
             showTitleOutputField = TRUE;
             
             
             List<Title__c> lstTitleDetails = [Select street_Date__c from Title__c where id=:titleID];
             releaseDetails.Brand_Group__c = u.Brand_Group__c;
             releaseDetails.Title__c = titleID;
             releaseDetails.Street_Date__c = lstTitleDetails[0].Street_Date__c;
         }
         else if(materialID != null)
         {
             materialDetails.Id = materialID;
             prepareMaterialDetails();
             
             if(materialDetails.Material_Type__c == 'ROH')
            {
                 hasError2 = true;
             }
         }
         else{
             showRelInputField = TRUE;
             showRelOutputField = FALSE;
             showTitleInputField = TRUE;
             showTitleOutputField = FALSE;
              
         } 
         if(releaseDetails != null) {
            previousBrandGroup = releaseDetails.Brand_Group__c; //REL-198
         }
         
         if(rootFERTs.size() == 0)
             addFormats(); 
             
         if(hasError2)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'This functionality is not applicable for Component(ROH/Z009) materials.'));  
         }
     }
     
     private Integer localCompId = 0;
     
     /*****************************************************************
     Method Name: prepareMaterialDetails
     Purpose: getting material level details
     ***************************************************************/       
     public pageReference prepareMaterialDetails(){ 
         set<Id> materialId = new Set<Id>();
         try{
             //getting material details
             if(materialDetails != null){
                 Material__c matDetail = [Select id,name,Total_Item_Qty__c,Release__c,Item_Type__c,Item_Code__c ,Material_Type__c,Sub_Label_Code_Lookup__c,Material_Expiration_Date__c from Material__c where id=:materialDetails.id]; //USST-2960
                 
                 //setting material details
                 if (matDetail != null){                    
                     materialDetails.id = matDetail.id;
                     materialDetails.name = matDetail.name;
                     materialDetails.Release__c = matDetail.Release__c;
                     materialDetails.Item_Type__c = matDetail.Item_Type__c;
                     materialDetails.Item_Code__c = matDetail.Item_Code__c;
                     materialDetails.Material_Type__c = matDetail.Material_Type__c;
                     materialDetails.Sub_Label_Code_Lookup__c = matDetail.Sub_Label_Code_Lookup__c;
                 }
                 materialId.add(materialDetails.id);
                 if(matDetail.Release__c != null)
                 {
                     List<Release__c> relDetail = [Select id,name,Street_Date__c,Title__r.id,Brand_Group__c,Project_Type__c,Territory__c,Promotion_Name_Abbreviation__c from Release__c where id=:matDetail.Release__c];
                 
                     //setting release details
                     if (!relDetail.isEmpty()){                    
                         releaseDetails.id = relDetail[0].id;
                         releaseDetails.name = relDetail[0].name;
                         releaseDetails.Street_Date__c = relDetail[0].Street_Date__c;
                         releaseDetails.Title__c = relDetail[0].Title__r.id;
                         releaseDetails.Brand_Group__c = relDetail[0].Brand_Group__c;
                         releaseDetails.Project_Type__c = relDetail[0].Project_Type__c;
                         releaseDetails.Territory__c = relDetail[0].Territory__c;
                         releaseDetails.Promotion_Name_Abbreviation__c = relDetail[0].Promotion_Name_Abbreviation__c ; 
                     }
                 }
                 else
                 {
                     releaseDetails = null;
                 }
             } 
              
         }  
         catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));               
         }   
         return null;
     }
     
     
     /************************************
     Method Name: addComponent
     Purpose: add ROH under a FERT 
     *************************************/     
     public void addComponent()
     {
         System.debug('---->>'+materialIndex+' :: '+selectedMaterialLevel);
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
         if((ins.instance.Item_Type__c != D_ITEM_TYPE && ins.instance.BOM_Status__c != 'Draft') ||
            (ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.Id != null && (ins.hasDChainFR == null || (ins.hasDChainFR != null && !ins.hasDChainFR))))
         {
             if(ins.instance.Item_Type__c == D_ITEM_TYPE)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to add child component.'));
             else
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material/Component cannot be added due to BOM Status no longer being in Draft. Please reach out to Planning to make any further updates.'));//USST-2944
             return;
         }
         
         ins.childComponents.add(new MaterialComponentWrapper(localCompId ++,u.Profile.Name));
         
         //setting default territory based on material
         ins.childComponents[ins.childComponents.size()-1].instance.Territory__c = ins.instance.Territory__c;
             
    }
     
     /************************************
     Method Name: addMaterial
     Purpose: add a new FERT 
     *************************************/ 
     public void addMaterial()
     {
         string tempSEGNNO = null;
         ID titleID ;
         
         //setting default title
         if(releaseDetails != null && string.valueof(releaseDetails.Title__c)!='' && string.valueof(releaseDetails.Title__c)!= null){
             Title__c titleDetails = [Select id,name,SGENNO__c from Title__c where id=:releaseDetails.Title__c];
             tempSEGNNO = titleDetails.SGENNO__c;
             titleID = titleDetails.ID;
         }
         
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
         if((ins.instance.Item_Type__c != D_ITEM_TYPE && ins.instance.BOM_Status__c != 'Draft') ||
            (ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.Id != null && (ins.hasDChainFR == null || (ins.hasDChainFR != null && !ins.hasDChainFR))))
         {
             if(ins.instance.Item_Type__c == D_ITEM_TYPE)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to add child FERT material.'));
             else
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material/Component cannot be added due to BOM Status no longer being in Draft. Please reach out to Planning to make any further updates.'));//USST-2944
             return;
         }
         
         MaterialFERTWrapper childFERT = new MaterialFERTWrapper(titleID, tempSEGNNO,u.Profile.Name);
         childFERT.instance.Item_Type__c = S_ITEM_TYPE;
         childFERT.instance.Item_Code__c = SS_ITEM_CODE;
         childFERT.instance.Territory__c = ins.instance.Territory__c;
         // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
         if(ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
         {
             ins.instance.BOM_Status__c = 'Approved';
         }
         
         childFERT.wizardType = wizardType;
         childFERT.levelOfDepth = ins.levelOfDepth + 1;
         ins.childFERTs.add(childFERT);
         ins.childIns.lastPage();
     }
     
     /************************************
     Method Name: openPopUp
     Purpose: open copy material tree popup
     *************************************/ 
     public void openPopUp()
     {
         showPopUp = TRUE;
         qtyCount = 1;
     }
     
     /************************************
     Method Name: openMultiDiscPopUp (Added for RE-20)
     Purpose: open multi disc popup
     *************************************/ 
     public void openMultiDiscPopUp()
     {
         showMultiDiscPopUp = TRUE;
         multiDiscQty = 1;
     }
     
     /************************************
     Method Name: closePopUp
     Purpose: close material tree popuup
     *************************************/ 
     public void closePopUp()
     {
         showPopUp = FALSE;
         showMultiDiscPopUp = FALSE;    //Added for RE-20
     }
     
     /************************************
     Method Name: copyMaterialTree
     Purpose: This method is responsible to fetch cloned copy of current material BOM tree and push that in sibling level.
     *************************************/    
     public void copyMaterialTree()
     {
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
         
         // Calling method to get deep clone on current instance's BOM structure.
         List<MaterialFERTWrapper> clonedInstances = getClonedTree(ins, null);
         
         for(Integer i = 0; i < qtyCount; i ++)
         {
             if(materialIndex.contains(';'))
             {
                 List<String> matIndices = materialIndex.subString(0, materialIndex.lastIndexOf(';')).split(';');
                 MaterialFERTWrapper parentInstance = getMaterialWrapperInstance((selectedMaterialLevel - 1), matIndices, rootIns.getData());
                 parentInstance.childFERTs.add(clonedInstances[i]);
             }
             else
             {
                 rootFERTs.add(clonedInstances[i]);
             }
         }
         
         showPopUp = FALSE; 
     }
     
     /************************************
     Method Name: createMultipleDisc (Added for RE-20)
     Purpose: This method is responsible to create multiple Disc components.
     *************************************/    
     public void createMultipleDisc()
     {
         if(multiDiscQty == null || multiDiscQty <= 0)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please provide valid quantity.'));
             return;
         }
         else if(multiDiscQty > 70)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Quantity must be less than or equal to 70.'));
             return;
         }
         
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
         
         if((ins.instance.Item_Type__c != D_ITEM_TYPE && ins.instance.BOM_Status__c != 'Draft') ||
            (ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.Id != null && (ins.hasDChainFR == null || (ins.hasDChainFR != null && !ins.hasDChainFR))))
         {
             if(ins.instance.Item_Type__c == D_ITEM_TYPE)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to add child component.'));
             else
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material/Component cannot be added due to BOM Status no longer being in Draft. Please reach out to Planning to make any further updates.')); //USST-2944
             return;
         }
         
         System.debug('releaseDetails %%%%:'+ releaseDetails);
         for(Integer i = 0; i < multiDiscQty; i ++)
         {
             MaterialComponentWrapper compIns = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
             
             // REL-20 - made code changes to default territory of all Disc components to US & CDN
             if((selectedDiscType == 'DISC DVD' || selectedDiscType == 'DISC BD' || selectedDiscType == 'DISC UHD' || selectedDiscType == 'DISC CD'))
             {
                     
                 if(releaseDetails != null && releaseDetails.Brand_Group__c == PHE_BRAND_GROUP)
                 {
                     compIns.instance.Territory__c = ins.instance.Territory__c;
                 }
                 else
                 {       
                     compIns.instance.Territory__c = US_CDN_TERRITORY;
                 }   
             }
             else
             {   
                 //setting default territory based on material
                 compIns.instance.Territory__c = ins.instance.Territory__c;
             }
             compIns.instance.Component_Type__c = selectedDiscType;
             
             ins.childComponents.add(compIns);
         }
         showMultiDiscPopUp = FALSE; 
     }
     
     /*****************************************************************
     Method Name: removeFERTs
     Purpose: removing a FERT record
     ***************************************************************/
     public void removeFERTs()
     {
         Savepoint sp = Database.setSavepoint();
         try
         {
         TriggerUtility.checkFromTemplate = TRUE;
         // Checks if material index is deeper than first level
         if(materialIndex.contains(';'))
         {
             System.debug('materialIndex::: '+materialIndex);
             List<String> matIndices = materialIndex.subString(0, materialIndex.lastIndexOf(';')).split(';');
             MaterialFERTWrapper ins = getMaterialWrapperInstance((selectedMaterialLevel - 1), matIndices, rootIns.getData());
             Integer removingIndex = Integer.valueOf(materialIndex.split(';')[(selectedMaterialLevel - 1)]);
             removingIndex += ((ins.childIns.currentPageNumber - 1) * ins.childIns.pageSize);
             //Added Sent Back status as part of DF-02109
             if((ins.instance.Item_Type__c != D_ITEM_TYPE && ins.instance.BOM_Status__c != 'Draft' && ins.instance.BOM_Status__c != 'Sent Back') ||
                (ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.Id != null && (ins.hasDChainFR == null || (ins.hasDChainFR != null && !ins.hasDChainFR))))
             {
                 if(ins.instance.Item_Type__c == D_ITEM_TYPE)
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to remove child FERT material.'));
                 else
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material can only be removed in parent material having BOM Status as Draft.'));
                 return;
             }
             
             if(ins.childFERTs.get(removingIndex).isExisting)
             {   
                 System.debug('Enter 1');
                 if(releaseDetails != null)
                 {
                     System.debug('Enter 2');
                     Material__c mat = ins.childFERTs.get(removingIndex).instance;
                     //for DF-02120, added condition of Sent Back Materials
                     if(setHardDelete.contains(mat.Material_Status__c) || mat.Material_Status__c == 'Sent Back'){ //this is for draft
                         if(string.valueof(mat.Release__c) != null && string.valueof(mat.Release__c) != ''){ // if release not null on material
                             system.debug(' &&&&&&& '+mat.Release__c);
                             if(releaseDetails.ID == mat.Release__c){ // release id and material release id same
                                 Set<ID> setID = new Set<ID>();
                                 setID.add(mat.id);
                                 
                                 fetchBOMHierarchyToDelete(setID);
                                 
                                 
                                 System.Debug('setMatID @@@ '+setMatID);
                                 System.Debug('setMatIDException  @@@ '+setMatIDException );
                                 //getting all release material for that material
                                 List<Release_Material__c> lstRM = new List<Release_Material__c>();
                                 
                                 if(setMatIDException.size() > 0)
                                     lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                                 
                                 for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                     lstRM.add(new Release_Material__c(ID=rel.id));
                                 }
                                                   
                                 //finding all the BOM item where this material has been used as a child
                                 List<BOM_Item__c> lstBMItm = [Select id from BOM_Item__c where (Material_Component__c in: setMatID OR Material__c in: setMatID) AND ID not in: setBMID];
                                 
                                 for(ID mID : setBMID){
                                     lstBMItm.add(new BOM_Item__c(ID = mID));
                                 }
                                 system.debug(' &&&&&&& '+lstRM);
                                 system.debug(' &&&&&&& '+lstBMItm);
                                 List<Material__c> lstMat = [Select id  from Material__c where ID in:setMatID];
                                 system.debug(' ********* '+lstMat+ '###' +lstRM);
                                 if(lstRM.size() > 0){
                                     delete lstRM;
                                 }
                                 
                                 if(lstBMItm.size() > 0){
                                     delete lstBMItm;
                                 }
                                 List<v_Material__c> deleteVMaterial=[Select id from v_Material__c where Material__c in: setMatID];
                                 if(deleteVMaterial.size()>0){
                                     DeleteMaterial.deleteVMaterial(deleteVMaterial);
                                 }
                                 if(lstMat.size() > 0){
                                     delete lstMat;
                                 }
                                 
                                 // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                                 if(ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                                 {
                                     ins.instance.BOM_Status__c = 'Approved';
                                     ins.instance.BOM_Function__c = '004';
                                     ins.instance.BOM_Integration_State__c = 'N';
                                     update ins.instance;
                                 }
                                 
                                 ins.childFERTs.remove(removingIndex);
                                 
                             }else{
                                 Set<ID> setID = new Set<ID>();
                                 setID.add(mat.id);
                                 
                                 setMatIDException.add(mat.id);
                                 
                                 fetchBOMHierarchyToDelete(setID);
                                 
                                 //getting all release material for that material
                                 List<Release_Material__c> lstRM = new List<Release_Material__c>();
                                 
                                 if(releaseDetails != null && releaseDetails.ID != null){
                                     if(setMatIDException.size() > 0)
                                         lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                                     
                                     for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                         lstRM.add(new Release_Material__c(ID=rel.id));
                                     }
                                 }
                                 
                                 if(lstRM.size() > 0){
                                     delete lstRM;
                                 }
                                 
                                 delete new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId); 
                                 
                                 // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                                 if(ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                                 {
                                     ins.instance.BOM_Status__c = 'Approved';
                                     ins.instance.BOM_Function__c = '004';
                                     ins.instance.BOM_Integration_State__c = 'N';
                                     update ins.instance;
                                 }
                                 
                                 ins.childFERTs.remove(removingIndex);                           
                             }
                             
                         }else{
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material cannot be removed as there is no release populated on the material.'));
                         }
                         
                     }
                     else if(setRemoveLink.contains(mat.Material_Status__c)){  //this is for processed in SAP
                         //if user is trying to remove level 1 FERT from release wizard
                         if(ins.childFERTs.get(removingIndex).bomItemId == null && releaseDetails != null && releaseDetails.id != null){
                             Set<ID> setID = new Set<ID>();
                             setID.add(mat.id);
                             
                             setMatIDException.add(mat.id);
                             
                             fetchBOMHierarchyToDelete(setID);                       
                             
                             //getting all release material for that material
                             List<Release_Material__c> lstRM = new List<Release_Material__c>();
                             
                             if(releaseDetails != null && releaseDetails.ID != null){
                                 if(setMatIDException.size() > 0)
                                     lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                                 
                                 for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                     lstRM.add(new Release_Material__c(ID=rel.id));
                                 }
                             }
                             
                             if(lstRM.size() > 0){
                                 delete lstRM;
                             }
                             
                             // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                             if(ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                             {
                                 ins.instance.BOM_Status__c = 'Approved';
                                 ins.instance.BOM_Function__c = '004';
                                 ins.instance.BOM_Integration_State__c = 'N';
                                 update ins.instance;
                             }
                             mat.Release__c = null; //USST-2646
                             update mat; //USST-2646
                             ins.childFERTs.remove(removingIndex);                       
                         }
                         //if user is trying to remove level 1 from material wizard
                         else if(ins.childFERTs.get(removingIndex).bomItemId == null && releaseDetails == null && releaseDetails.id == null){
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Level 1 material cannot be removed if material status is Processed in SAP.'));
                         }
                         //if user is trying to remove FERT from level 2 onwards
                         else if(ins.childFERTs.get(removingIndex).bomItemId != null){
                             //if user is doing the process from release wizard
                             if(releaseDetails != null && releaseDetails.id != null){
                                 Set<ID> setID = new Set<ID>();
                                 Set<ID> tempMatIDs = new Set<ID>(); //USST-2747
                                 List<Material__c> lstMats= new List<Material__c>(); //USST-2747
                                 setID.add(mat.id);
                                 
                                 setMatIDException.add(mat.id);
                                 
                                 fetchBOMHierarchyToDelete(setID);
                                 
                                 //getting all release material for that material
                                 List<Release_Material__c> lstRM = new List<Release_Material__c>();
                                 
                                 if(releaseDetails != null && releaseDetails.ID != null){
                                     if(setMatIDException.size() > 0)
                                         lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                                     
                                     for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                         lstRM.add(new Release_Material__c(ID=rel.id));
                                     }
                                     //USST-2747----start
                                     for (Bom_Item__c bom : [Select Id, Material_Component__c from Bom_Item__c where Material__c IN : setMatIDException]) {
                                         tempMatIDs.add(bom.Material_Component__c);
                                     }

                                     if (!tempMatIDs.isEmpty()) {
                                         for (Material__c mt : [Select Release__c  from Material__c where Id IN : tempMatIDs]) {
                                             if (mt.Release__c == releaseDetails.ID) {
                                                 mt.Release__c = null;
                                                 lstMats.add(mt);
                                             }
                                         }
                                     }
                                     //USST-2747----end
                                     
                                 }
                                 
                                 if(lstRM.size() > 0){
                                     delete lstRM;
                                 }
                                 
                                 if(mat.BOM_Status__c != null &&  (mat.BOM_Status__c.equalsIgnoreCase('Approved') || mat.BOM_Status__c.equalsIgnoreCase('Processed in SAP')))
                                 {
                                     TriggerUtility.doNotExecute = TRUE;
                                     update new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId, BOM_Function__c='003', Deletion_Flag__c=TRUE);
                                     RSUCalculationHandler.updateMaterialTree(new Set<Id>{ins.instance.Id}, true);    // Added for REL-104
                                     TriggerUtility.doNotExecute = FALSE;
                                 }
                                 else
                                     delete new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId);  //USST-2851
                                 
                                 // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                                 if(ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                                 {
                                     TriggerUtility.checkFromTemplate = TRUE;
                                     ins.instance.BOM_Status__c = 'Approved';
                                     ins.instance.BOM_Function__c = '004';
                                     ins.instance.BOM_Integration_State__c = 'N';
                                     update ins.instance;
                                 }
                                 mat.Release__c = null; //USST-2646
                                 lstMats.add(mat);//USST-2747
                                 update lstMats; //USST-2646 //USST-2747
                                 ins.childFERTs.remove(removingIndex);
                             }
                             //if user is doing the process from material wizard
                             else if(releaseDetails == null && releaseDetails.id == null){
                                 if(mat.BOM_Status__c != null &&  (mat.BOM_Status__c.equalsIgnoreCase('Approved') || mat.BOM_Status__c.equalsIgnoreCase('Processed in SAP')))
                                 {
                                     TriggerUtility.doNotExecute = TRUE;
                                     update new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId, BOM_Function__c='003', Deletion_Flag__c=TRUE);
                                     RSUCalculationHandler.updateMaterialTree(new Set<Id>{ins.instance.Id}, true);    // Added for REL-104
                                     TriggerUtility.doNotExecute = FALSE;
                                 }
                                 /*else
                                     delete new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId);*/ // commented for USST-2622
                                 // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                                 if(ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                                 {
                                     TriggerUtility.checkFromTemplate = TRUE;
                                     ins.instance.BOM_Status__c = 'Approved';
                                     ins.instance.BOM_Function__c = '004';
                                     ins.instance.BOM_Integration_State__c = 'N';
                                     update ins.instance;
                                 }
                                 
                                 ins.childFERTs.remove(removingIndex);
                             }
                         }
                     }
                 }   
                 else {
                     System.debug('Enter 3');
                     Material__c mat = ins.childFERTs.get(removingIndex).instance;
                     //for DF-02120, added condition of Sent Back Materials
                     if((setHardDelete.contains(mat.Material_Status__c) || mat.Material_Status__c == 'Sent Back') && mat.Component_Material__c != null && mat.Component_Material__c == ins.instance.Id){
                         Set<ID> setID = new Set<ID>();
                         setID.add(mat.id);
                         
                         fetchBOMHierarchyToDelete(setID);
                         
                         System.Debug('setMatID @@@ '+setMatID);
                         System.Debug('setMatIDException  @@@ '+setMatIDException );
                         //getting all release material for that material
                         List<Release_Material__c> lstRM = new List<Release_Material__c>();
                         
                         if(setMatIDException.size() > 0)
                             lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                         
                         for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                             lstRM.add(new Release_Material__c(ID=rel.id));
                         }
                                            
                         //finding all the BOM item where this material has been used as a child
                         List<BOM_Item__c> lstBMItm = [Select id from BOM_Item__c where (Material_Component__c in: setMatID OR Material__c in: setMatID) AND ID not in: setBMID];
                         
                         for(ID mID : setBMID){
                             lstBMItm.add(new BOM_Item__c(ID = mID));
                         }
                         
                         List<Material__c> lstMat = [Select id  from Material__c where ID in:setMatID];
                         
                         if(lstRM.size() > 0){
                             delete lstRM;
                         }
                         
                         if(lstBMItm.size() > 0){
                             delete lstBMItm;
                         }
                         List<v_Material__c> deleteVMaterial=[Select id from v_Material__c where Material__c in: setMatID];
                         if(deleteVMaterial.size()>0){
                             DeleteMaterial.deleteVMaterial(deleteVMaterial);
                         }
                         if(lstMat.size() > 0){
                             delete lstMat;
                         }
                         
                         // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                         if(ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                         {
                             ins.instance.BOM_Status__c = 'Approved';
                             ins.instance.BOM_Function__c = '004';
                             ins.instance.BOM_Integration_State__c = 'N';
                             update ins.instance;
                         }
                         
                         ins.childFERTs.remove(removingIndex);
                         
                     }
                     // This is for processed in SAP
                     else if(setRemoveLink.contains(mat.Material_Status__c))
                     {
                         System.debug('Enter 4');
                         if(ins.childFERTs.get(removingIndex).bomItemId != null)
                             delete new BOM_Item__c(Id=ins.childFERTs.get(removingIndex).bomItemId); 
                         
                         // For Existing Display Vehicle, if any child material is removed should change the BOM Status. 
                         if(ins.instance.BOM_Status__c == 'Processed in SAP' && ins.instance.Id != null)
                         {
                             System.debug('USST-2708 :: '+ins.instance.BOM_Status__c + ins.instance.Id);
                             TriggerUtility.checkFromTemplate = TRUE;
                             ins.instance.BOM_Status__c = 'Approved';
                             ins.instance.BOM_Function__c = '004';
                             ins.instance.BOM_Integration_State__c = 'N';
                             update ins.instance;
                         }
                         
                         ins.childFERTs.remove(removingIndex);
                     }
                     else
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'This material cannot be removed from material wizard.'));
                 }
             }
             else
                 ins.childFERTs.remove(removingIndex);
             
             // Setting previous page if there is no child left in this page after deletion
             List<MaterialFERTWrapper> pageData = ins.childIns.getData();
             if(pageData == null || pageData.size() == 0)
             {
                 ins.childIns.previousPage();
                 Integer noOfPages = ins.childIns.numberOfPages;
             }
         }
         else
         {
             System.debug('Enter 5');
             Integer removingIndex = Integer.valueOf(materialIndex) + ((rootIns.currentPageNumber - 1) * rootIns.pageSize);
             
             //if release details not null
             if(releaseDetails != null){
                 System.debug('Enter 6');
                 //storing material instance
                 Material__c mat = rootFERTs[Integer.valueOf(removingIndex)].instance;
                 //checking if exsiting material
                 if(rootFERTs[Integer.valueOf(removingIndex)].isExisting)
                 {
                     System.debug('Enter 7');
                     //for DF-02120, added condition of Sent Back Materials
                     if(setHardDelete.contains(mat.Material_Status__c) || mat.Material_Status__c == 'Sent Back'){ //this is for draft
                         if(string.valueof(mat.Release__c) != null && string.valueof(mat.Release__c) != ''){ // if release not null on material
                             
                             if(releaseDetails.ID == mat.Release__c){ // release id and material release id same
                                 Set<ID> setID = new Set<ID>();
                                 setID.add(mat.id);
                                 
                                 fetchBOMHierarchyToDelete(setID);
                                 
                                 
                                 System.Debug('setMatID @@@ '+setMatID);
                                 System.Debug('setMatIDException  @@@ '+setMatIDException );
                                 //getting all release material for that material
                                 Map<Id, Release_Material__c> lstRM = new Map<Id, Release_Material__c>();
                                 
                                 if(setMatIDException.size() > 0)
                                     lstRM = new Map<Id, Release_Material__c>([Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID]);
                                 
                                 for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                     lstRM.put(rel.id, new Release_Material__c(ID=rel.id));
                                 }
                                 
                                 //finding all the BOM item where this material has been used as a child
                                 List<BOM_Item__c> lstBMItm = [Select id from BOM_Item__c where (Material_Component__c in: setMatID OR Material__c in: setMatID) AND ID not in: setBMID];
                                 
                                 for(ID mID : setBMID){
                                     lstBMItm.add(new BOM_Item__c(ID = mID));
                                 }
                                 system.debug(' &&&&&&& '+lstRM);
                                 system.debug(' &&&&&&& '+lstBMItm);
                                 List<Material__c> lstMat = [Select id  from Material__c where ID in:setMatID];
                                 
                                 if(lstRM.size() > 0){
                                     delete lstRM.values();
                                }
                                 
                                 if(lstBMItm.size() > 0){
                                     delete lstBMItm;
                                 }
                                 List<v_Material__c>deleteVMaterial=[Select id from v_Material__c where Material__c in:setMatID] ;
                                 if(deleteVMaterial.size() > 0){
                                     DeleteMaterial.deleteVMaterial(deleteVMaterial);
                                 }
                                 
                                 if(lstMat.size() > 0){
                                     delete lstMat;
                                 }
                                 
                                 rootFERTs.remove(Integer.valueOf(removingIndex));           
                             }else{
                                 Set<ID> setID = new Set<ID>();
                                 setID.add(mat.id);
                                 
                                 setMatIDException.add(mat.id);
                                 
                                 fetchBOMHierarchyToDelete(setID);
                                 
                                 //getting all release material for that material
                                 List<Release_Material__c> lstRM = new List<Release_Material__c>();
                                 
                                 if(releaseDetails != null && releaseDetails.ID != null){
                                     if(setMatIDException.size() > 0)
                                         lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                                     
                                     for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                         lstRM.add(new Release_Material__c(ID=rel.id));
                                     }
                                 }
                                 
                                 if(lstRM.size() > 0){
                                     delete lstRM;
                                 }
                                 
                                 rootFERTs.remove(Integer.valueOf(removingIndex));                           
                             }       
                         }else{
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material cannot be removed as there is no release populated on the material.'));
                         }   
                     }
                     else if(setRemoveLink.contains(mat.Material_Status__c)){  //this is for processed in SAP 
                        System.debug('Enter 8');
                         Set<ID> setID = new Set<ID>();
                         Set<ID> tempMatIDs = new Set<ID>(); //USST-2665
                         List<Material__c> lstMats= new List<Material__c>(); //USST-2665
                         List<Material__c> updtMatLst= new List<Material__c>(); //USST-2665
                         List<ID> updMatIDLst= new List<ID>(); //USST-2938
                         setID.add(mat.id);
                         
                         setMatIDException.add(mat.id);
                         
                         fetchBOMHierarchyToDelete(setID);                       
                         
                         //getting all release material for that material
                         List<Release_Material__c> lstRM = new List<Release_Material__c>();
                         
                         if(releaseDetails != null && releaseDetails.ID != null){
                             if(setMatIDException.size() > 0)
                                 lstRM = [Select id from Release_Material__c where Material__c in: setMatIDException AND Release__c =: releaseDetails.ID];
                             
                             for(Release_Material__c rel : [Select id from Release_Material__c where Material__c in: setMatID]){
                                 lstRM.add(new Release_Material__c(ID=rel.id));
                             }
                             //USST-2665----start
                             for (Bom_Item__c bom : [Select Id, Material_Component__c from Bom_Item__c where Material__c IN : setMatIDException]) {
                                tempMatIDs.add(bom.Material_Component__c);
                             }

                             if (!tempMatIDs.isEmpty()) {
                                 for (Material__c mt : [Select Release__c  from Material__c where Id IN : tempMatIDs]) {
                                     if (mt.Release__c == releaseDetails.ID) {
                                         mt.Release__c = null;
                                         lstMats.add(mt);
                                     }
                                 }
                             }
                             //USST-2665----end
                         }
                         
                         if(lstRM.size() > 0){
                             delete lstRM;
                         }
                         mat.Release__c = null; //USST-2646
                         //USST-2665---start
                         lstMats.add(mat); 
                         //check if the removed mat or its child ferts have update requests.
                         for (Material__c updMat : [Select Release__c  from Material__c where Original_Material_Number__c IN : tempMatIDs OR Original_Material_Number__c =: mat.ID]) {
                             updMat.Release__c = null;
                             updtMatLst.add(updMat);
                             updMatIDLst.add(updMat.Id);//USST-2938
                         }
                         update lstMats; //USST-2646
                         if (!updtMatLst.isEmpty()) {
                            ApprovalUnlockMaterials.materialUnlock(updMatIDLst); //USST-2938
                            update updtMatLst;  
                         }
                         //USST-2665---end
                         rootFERTs.remove(Integer.valueOf(removingIndex));
                     }
                 }
                 else{
                     rootFERTs.remove(Integer.valueOf(removingIndex));
                 }
             }
             else{
                 rootFERTs.remove(Integer.valueOf(removingIndex));
             }
             
             // Setting previous page if there is no child left in this page after deletion
             List<MaterialFERTWrapper> pageData = rootIns.getData();
             if(pageData == null || pageData.size() == 0)
             {
                 rootIns.previousPage();
                 Integer noOfPages = rootIns.numberOfPages;
             }            
         }
         }
         catch(DmlException dex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error: '+dex.getDmlMessage(0)));
             Database.rollback(sp);
         }
         catch(Exception ex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error: '+ex.getMessage()));
             Database.rollback(sp);
         }
     }
     
     /*****************************************************************
     Method Name: fetchBOMHierarchyToDelete
     Purpose: getting list of records to be deleted
     ***************************************************************/
     @testvisible private void fetchBOMHierarchyToDelete(Set<Id> processingMaterialIds)
     {
         Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
         Set<String> setChildMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
         Set<Id> setProcessedMatIds = new Set<Id>();
         Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
         for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Material_Component__r.Material_Status__c
                                FROM BOM_Item__c
                                WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: setChildMaterialTypes AND 
                                    Material_Component__c NOT IN :setProcessedMatIds AND Material_Component__c != null AND 
                                    Material_Component__r.Deletion_Flag__c=false AND (BOM_Function__c != '003' AND Deletion_Flag__c=false)])
         {
             if(!matBomMap.containsKey(bom.Material__c))
                 matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
             matBomMap.get(bom.Material__c).add(bom);
         }
         
         // Fetch the child materials from BOM Items.
         for(Material__c mat : [SELECT Id, 
                                Material_Type__c,Total_Item_Qty__c, Material_Status__c,Release__c, Sub_Label_Code_Lookup__c 
                                FROM Material__c
                                WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: setChildMaterialTypes])
         {
             setProcessedMatIds.add(mat.Id); 
             //for DF-02120, added condition of Sent Back Materials
             if((setHardDelete.contains(mat.Material_Status__c)  || mat.Material_Status__c == 'Sent Back')  && !setMatIDException.contains(mat.Id)){
                 if(!setMatID.contains(mat.ID)){
                     setMatID.add(mat.ID);
                 }
             }
             
             if(!setMatIDRM.contains(mat.ID)){
                  setMatIDRM.add(mat.ID);
             }       
             //for DF-02120, added condition of Sent Back Materials
             if((!setHardDelete.contains(mat.Material_Status__c) && mat.Material_Status__c != 'Sent Back') || (releaseDetails != null && releaseDetails.ID != mat.Release__c)){
                 if(!setMatIDException.contains(mat.id)){
                     setMatIDException.add(mat.id);
                 }
             }
             
             if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
             {   
                 //Looping over related BOM Item records
                 for(BOM_Item__c bom : matBomMap.get(mat.Id))
                 {
                     // If it is a component material.
                     if(setChildMaterialTypes.contains(bom.Material_Component__r.Material_Type__c))
                     {
                         if(setRemoveLink.contains(bom.Material_Component__r.Material_Status__c) && !setMatIDException.contains(bom.Material__c)){
                              if(!setBMID.contains(bom.ID)){
                                 setBMID.add(bom.ID);
                              }                           
                         }   
                         
                         if(!setMatID.contains(bom.Material_Component__r.ID) && (setHardDelete.contains(bom.Material_Component__r.Material_Status__c) || (bom.Material_Component__r.Material_Status__c == 'Sent Back')) && 
                            !setMatIDException.contains(bom.Material__c)){
                             setMatID.add(bom.Material_Component__r.ID);
                         }
                         
                         if(!setMatIDRM.contains(bom.Material_Component__r.ID)){
                             setMatIDRM.add(bom.Material_Component__r.ID);
                         }
                         
                         if(setMatIDException.contains(bom.Material__c))
                         {
                             setMatIDException.add(bom.Material_Component__c);
                         }
                     }
                     // If FERT material not previously processed.
                     else if(!setProcessedMatIds.contains(bom.Material_Component__c)) 
                     {               
                         nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                         if(setMatIDException.contains(bom.Material__c))
                         {
                             setMatIDException.add(bom.Material_Component__c);
                         }
                     }
                 }
             }           
             
         }
         
         if(nextLevelProcessingMaterialIds.size() > 0)
             fetchBOMHierarchyToDelete(nextLevelProcessingMaterialIds);
     }
     
     /*****************************************************************
     Method Name: removeComponent
     Purpose: removing a component record
     ***************************************************************/
     public void removeComponent()
     {
         Savepoint sp = Database.setSavepoint();
         try
         {
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
         if((ins.instance.Item_Type__c != D_ITEM_TYPE && ins.instance.BOM_Status__c != 'Draft') ||
            (ins.instance.Item_Type__c == D_ITEM_TYPE && ins.instance.Id != null && (ins.hasDChainFR == null || (ins.hasDChainFR != null && !ins.hasDChainFR))))
         {
             if(ins.instance.Item_Type__c == D_ITEM_TYPE)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Display Vehicle should have D-Chain Spec \'FR\' to remove child Component.'));
             else
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Component can only be removed in parent material having BOM Status as Draft.'));
             return;
         }
         
         Integer actualCompIndex = 0;
         for(MaterialComponentWrapper comp : ins.childComponents)
         {
             System.debug('Local component ID '+ comp.localComponentId);
             System.debug('Component Index '+componentIndex);
             
             if(comp.localComponentId == componentIndex)
             {
                 break;
             }
             actualCompIndex ++;
         }
         
         System.Debug('Actual Component Index '+actualCompIndex);
         // If component is existing in the BOM Hierarchy.
         if(ins.childComponents.get(actualCompIndex).isExisting)
         {
             if(releaseDetails != null){ //checking if user is coming from release wizard or material wizard
                 List<Release_material__c> lstRM = new List<Release_material__c>();
                 List<BOM_Item__c> lstBMItm = new List<BOM_Item__c>();
                 
                 Material__c comp = ins.childComponents.get(actualCompIndex).instance;
                 
                 System.Debug('Material Status @@ '+comp.Material_Status__c);
                 //for DF-02120, added condition of Sent Back Components
                 if(setHardDelete.contains(comp.Material_Status__c) || comp.Material_Status__c == 'Sent Back'){ //if material is in draft status
                     if(string.valueof(comp.Release__c) != null && string.valueof(comp.Release__c) != ''){
                         if(releaseDetails.ID == comp.Release__c){
                             lstRM = [Select ID from Release_Material__c where Material__c =: comp.id];  
                             lstBMItm = [Select id from BOM_Item__c where Material_Component__c =: comp.id];
                             system.debug(' &&&&&&& '+lstRM);
                             system.debug(' &&&&&&& '+lstBMItm);
                             if(lstRM.size() > 0){
                                 delete lstRM;
                             }
                             
                             if(lstBMItm.size() > 0){
                                 delete lstBMItm;
                             }
                             List<v_Material__c>deleteVMaterial=[Select id from v_Material__c where Material__c=:comp.id] ;
                             if(deleteVMaterial.size() > 0){
                                 DeleteMaterial.deleteVMaterial(deleteVMaterial);
                             }
                             removeROHFromList(rootFERTs,comp.id);
                             delete comp;                            
                             
                         }else{
                             lstRM = [Select ID from Release_Material__c where Material__c =: comp.id AND Release__c =: releaseDetails.ID];
                             lstBMItm = [Select id from BOM_Item__c where ID =: ins.childComponents.get(actualCompIndex).bomItemId];
                             
                             if(lstRM.size() > 0){
                                 delete lstRM;
                             }
                             
                             if(lstBMItm.size() > 0){
                                 delete lstBMItm;
                             }
                             
                             ins.childComponents.remove(actualCompIndex);
                         }
                                                 
                         
                     }
                     else{
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material cannot be removed as there is no release populated on the material.'));
                     }                   
                 }
                 else if(setRemoveLink.contains(comp.Material_Status__c)){ //if material is in processed in SAP status
                     if(releaseDetails != null && releaseDetails.ID != null){
                         lstRM = [Select ID from Release_Material__c where Material__c =: comp.id AND Release__c =:releaseDetails.ID];
                     }
                     
                     lstBMItm = [Select id from BOM_Item__c where ID =: ins.childComponents.get(actualCompIndex).bomItemId];
                     
                     if(lstRM.size() > 0){
                         delete lstRM;
                     }
                     
                     if(lstBMItm.size() > 0){
                         delete lstBMItm;
                     }
                     ins.childComponents.remove(actualCompIndex);
                 }
             }
             // If coming from material wizard.
             else{
                 Material__c comp = ins.childComponents.get(actualCompIndex).instance;
                 
                 if(setHardDelete.contains(comp.Material_Status__c) && comp.Component_Material__c != null && comp.Component_Material__c == ins.instance.Id)
                 {
                     List<Release_Material__c> lstRM = [Select ID from Release_Material__c where Material__c =: comp.id];  
                     List<BOM_Item__c> lstBMItm = [Select id from BOM_Item__c where Material_Component__c =: comp.id];
                     
                     if(lstRM.size() > 0){
                         delete lstRM;
                     }
                     
                     if(lstBMItm.size() > 0){
                         delete lstBMItm;
                     }
                     List<v_Material__c>deleteVMaterial=[Select id from v_Material__c where Material__c=:comp.id] ;
                     if(deleteVMaterial.size() > 0){
                         DeleteMaterial.deleteVMaterial(deleteVMaterial);
                     }
                     removeROHFromList(rootFERTs,comp.id);
                     delete comp;
                 }
                 //if material is in processed in SAP status
                 else if(setRemoveLink.contains(comp.Material_Status__c)){ 
                     List<BOM_Item__c> lstBMItm = [Select id from BOM_Item__c where ID =: ins.childComponents.get(actualCompIndex).bomItemId];
                     
                     if(lstBMItm != null && lstBMItm.size() > 0){
                         delete lstBMItm;
                     }
                     ins.childComponents.remove(actualCompIndex);
                 }
                 else
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'This component cannot be removed from material wizard.'));
             }

         }
         else{
             ins.childComponents.remove(actualCompIndex);
         }
         }
         catch(DmlException dex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error: '+dex.getDmlMessage(0)));
             Database.rollback(sp);
         }
         catch(Exception ex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Error: '+ex.getMessage()));
             Database.rollback(sp);
         }
     }
     
     /*****************************************************************
     Method Name: removeROHFromList
     Purpose : remove ROH from list
     ***************************************************************/
     private void removeROHFromList(List<MaterialFERTWrapper> operatingMaterials,ID compID)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         for(MaterialFERTWrapper matWrapper : operatingMaterials)
         {            
             if(matWrapper.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
             
             if(matWrapper.childComponents.size() > 0)
             {   integer i=0;
                 List<MaterialComponentWrapper> lstTempComp = new List<MaterialComponentWrapper>();
                 lstTempComp.addall(matWrapper.childComponents);
                 
                 for(MaterialComponentWrapper childComp : lstTempComp)
                 {
                     if(compID == childComp.instance.ID){
                         matWrapper.childComponents.remove(i);                       
                     }
                     
                     i++;
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             removeROHFromList(nextLevelMaterials,compID);
     }
     
     
     
     // This method is responsible to fetch an material instance from RootMaterial BOM structure using material tree path.
     private MaterialFERTWrapper getMaterialWrapperInstance(Integer selectedMatLevel, 
                                                           List<String> materialIndexes, 
                                                           List<MaterialFERTWrapper> searchingMaterials)
     {
         System.debug('-----1> '+selectedMatLevel+' :: '+materialIndexes);
         if(searchingMaterials != null && searchingMaterials.size() > 0)
         {
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
         return null;
     }
     
     /*****************************************************************
     Method Name: getClonedTree
     Purpose: Recursive method to get complete cloned BOM tree for a material instance. 
     ***************************************************************/
     private List<MaterialFERTWrapper> getClonedTree(MaterialFERTWrapper sourceMaterial, List<MaterialFERTWrapper> parentMaterials)
     {
         List<MaterialFERTWrapper> cloneMaterialInstances = new List<MaterialFERTWrapper>();
         for(Integer i = 0; i < qtyCount; i ++)
         {
             // Creating new copied instance.
             MaterialFERTWrapper clonedIns = new MaterialFERTWrapper(null, '',u.Profile.Name);
             
             // Copying material values to new instance.
             if(sourceMaterial.instance != null)
                 clonedIns.instance = sourceMaterial.instance.clone(false, false, false, false);
             clonedIns.discQuantity = sourceMaterial.discQuantity;
             clonedIns.discQuantityDVD = sourceMaterial.discQuantityDVD;
             clonedIns.quantity = sourceMaterial.quantity;
             clonedIns.sysgenNo = sourceMaterial.sysgenNo;
             clonedIns.qtyBOM = 0;
             clonedIns.instance.Title__c = sourceMaterial.instance.Title__c;
             clonedIns.componentQty = sourceMaterial.componentQty;
             clonedIns.wizardType = wizardType;
             clonedIns.levelOfDepth = sourceMaterial.levelOfDepth;
             clonedIns.instance.Material_Status__c = 'Draft';
             clonedIns.instance.Material_Number__c  = '';
             
             // Copying components in new instance.
             if(sourceMaterial.childComponents != null && sourceMaterial.childComponents.size() > 0)
             {
                 for(MaterialComponentWrapper sourceCompWrapper : sourceMaterial.childComponents)
                 {
                     MaterialComponentWrapper clonedComponentInstance = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
                     
                     // Copying component values to new instance.
                     if(sourceCompWrapper.instance != null)
                         clonedComponentInstance.instance = sourceCompWrapper.instance.clone(false, false, false, false);
                     clonedComponentInstance.quantity = sourceCompWrapper.quantity;
                     clonedComponentInstance.componentQty = sourceCompWrapper.componentQty;
                     clonedComponentInstance.hasDChainFR = sourceCompWrapper.hasDChainFR;
                     clonedComponentInstance.instance.Material_Status__c = 'Draft';
                     clonedComponentInstance.instance.Material_Number__c  = '';
                     clonedComponentInstance.instance.Selection_Reference_Number__c  = '';
                     
                     // Adding new component instance in cloned material instance.
                     clonedIns.childComponents.add(clonedComponentInstance);
                 }
             }
             
             cloneMaterialInstances.add(clonedIns);
         }
         
         // Recursive call to add child FERTs in new instance.
         if(sourceMaterial.childFERTs != null && sourceMaterial.childFERTs.size() > 0)
         {
             for(MaterialFERTWrapper sourceMatWrapper : sourceMaterial.childFERTs)
             {
                 getClonedTree(sourceMatWrapper, cloneMaterialInstances);
             }
         }
             
         if(parentMaterials != null && parentMaterials.size() > 0)
         {
             for(Integer i = 0; i < qtyCount; i ++)
             {
                 // Adding new instance parent instance.
                 parentMaterials[i].childFERTs.add(cloneMaterialInstances[i]);
             }
         }
         
         if(parentMaterials == null)
             return cloneMaterialInstances;
         else
             return null;
     }
     
     /************************************
     Method Name: setTemplateMaterials
     Purpose: Getting all materials based on Brand group and its template selection. // Changed for REL-45
     *************************************/     
     public pageReference setTemplateMaterials()
     {        
         try
         {
             //Initializing list
             //lstMaterialTemplate = new List<Material_Template__c>();            
             string territory;
             
             if(releaseDetails.Territory__c != null){
                 territory = releaseDetails.Territory__c;
             }else{
                 territory = 'US';
             }
             
             //if use template checkbox is selected
             if(selectedTemplateId != null && selectedTemplateId.trim() != '')
             { 
                 rootFERTs = new List<MaterialFERTWrapper>();  
                 if(pageParameters.get('source').equalsIgnoreCase('ReleaseDetail'))
                 {
                     getExistingBOMTree();
                 }
                      
                // Fetching material and components associated to the selected template and Creating wrapper structure to be populated on VF. // Changed for REL-127
                 for(Material_Detail__c mtDetail : [SELECT Id, Format__c, Item_Code__c, Item_Type__c, Quantity__c, Retailer_Rental__c, Subformat__c, Sales_Planning_Group__c, 
                                                    (SELECT Id, Component_Type__c, Existing_Component__c, Is_Existing__c, Existing_Component__r.Component_Type__c,
                                                     Existing_Component__r.Material_Type__c, Existing_Component__r.Item_Type__c,Existing_Component__r.SGENNO__c,
                                                     Existing_Component__r.Name, Existing_Component__r.Release__c, Existing_Component__r.Material_Number__c, 
                                                     Existing_Component__r.Total_Item_Qty__c, Existing_Component__r.Count_Sales_for_D_Chain_Status__c, Existing_Component__r.BOM_Status__c, 
                                                     Existing_Component__r.MPM_Issue__c, Existing_Component__r.Sales_Planning_Group__c, Existing_Component__r.Subformat__c,
                                                     Existing_Component__r.Material_Status__c, Existing_Component__r.Territory__c, Existing_Component__r.Label_Code__c,
                                                     Existing_Component__r.Sub_Label_Code_Lookup__c, Existing_Component__r.Component_Material__c 
                                                    FROM Component_Details__r ORDER BY Sequence__c)
                                                    FROM Material_Detail__c
                                                   WHERE Material_Template__c=:selectedTemplateId 
                                                   ORDER BY Sequence__c
                                                   ]) // Added subformat and sales planning group for USST-2783
                 {
                     Integer qty = (mtDetail.Quantity__c != null && mtDetail.Quantity__c > 0) ? Integer.valueOf(mtDetail.Quantity__c) : 1;
                     for(Integer i = 0; i < qty; i ++)
                     {
                         //create parent FERT level details
                         MaterialFERTWrapper mat;
                         
                         if(releaseDetails != null)
                             mat = new MaterialFERTWrapper(releaseDetails.Title__c, releaseDetails.SGENNO__c, u.Profile.Name);
                         else
                             mat = new MaterialFERTWrapper(null, '',u.Profile.Name);
                         rootFERTs.add(mat);
                             
                         mat.instance.Item_Type__c = mtDetail.Item_Type__c;
                         mat.instance.Item_Code__c = mtDetail.Item_Code__c;
                         mat.instance.Format_Description__c = mtDetail.Format__c;
                         mat.instance.Retailer_Rental__c = mtDetail.Retailer_Rental__c;
                         mat.instance.Subformat__c = mtDetail.Subformat__c; //USST-27783
                         mat.instance.Sales_Planning_Group__c = mtDetail.Sales_Planning_Group__c; //USST-2783
                         mat.instance.Territory__c  = territory;
                         if(mat.instance.Item_Code__c == 'BF - BABY FERT')
                             mat.instance.Territory__c  = 'US & CDN';
                         mat.wizardType = wizardType;
                         mat.levelOfDepth = 1;
                         
                         //if list not null
                         if(mtDetail.Component_Details__r != null && mtDetail.Component_Details__r.size() > 0)
                         {
                             for(Component_Detail__c compDet : mtDetail.Component_Details__r)
                             {  
                                 //adding components to wrapper
                                 MaterialComponentWrapper comp = new MaterialComponentWrapper(localCompId ++, u.Profile.Name);
                                 
                                 // Adding new component
                                 if(!compDet.Is_Existing__c)
                                 {
                                     String s = compDet.Component_Type__c;
                                     comp.instance.Component_Type__c = s;
                                     comp.instance.Territory__c  = mat.instance.Territory__c;
                                    if((s.contains('UV INSERT') || s.contains('STICKER') || s.contains('DC INSERT')) && releaseDetails.Project_Type__c ==  'New Release' && releaseDetails.Brand_Group__c == 'Family' && mtDetail.Format__c == '3D BD'){ //USST-3078
                                         comp.instance.Association_Required__c = TRUE;                        
                                     }
                                 }
                                 // Adding existing component.
                                 else
                                 {
                                     Material__c existingComponent = new Material__c(Id=compDet.Existing_Component__c);
                                     comp.instance = existingComponent;
                                     comp.instance.Name = compDet.Existing_Component__r.Name;
                                     comp.instance.Material_Type__c = compDet.Existing_Component__r.Material_Type__c;
                                     comp.instance.Component_Type__c = compDet.Existing_Component__r.Component_Type__c;
                                     comp.instance.Association_Required__c = false;
                                     comp.instance.Release__c = compDet.Existing_Component__r.Release__c;
                                     comp.instance.BOM_Status__c = compDet.Existing_Component__r.BOM_Status__c;
                                     comp.instance.Item_Type__c = compDet.Existing_Component__r.Item_Type__c;
                                     comp.instance.Label_Code__c = compDet.Existing_Component__r.Label_Code__c;
                                     comp.instance.Material_Number__c = compDet.Existing_Component__r.Material_Number__c;
                                     comp.instance.Sub_Label_Code_Lookup__c = compDet.Existing_Component__r.Sub_Label_Code_Lookup__c;
                                     comp.instance.Component_Material__c = compDet.Existing_Component__r.Component_Material__c;
                                     if(compDet.Existing_Component__r.Count_Sales_for_D_Chain_Status__c > 0)
                                         comp.hasDChainFR = true;
                                     comp.isExisting = false;
                                     comp.isExistingRecord = true;
                                     
                                     if(showMPM){
                                       comp.instance.MPM_Issue__c = compDet.Existing_Component__r.MPM_Issue__c;
                                       comp.instance.Sales_Planning_Group__c = compDet.Existing_Component__r.Sales_Planning_Group__c;
                                       comp.instance.Subformat__c = compDet.Existing_Component__r.Subformat__c;
                                     }
                                     
                                     comp.instance.Material_Status__c = compDet.Existing_Component__r.Material_Status__c;
                                     comp.instance.Territory__c = compDet.Existing_Component__r.Territory__c;
                                 }
                                 
                                 // Adding component under parent material.
                                 mat.childComponents.add(comp);
                             }
                         }
                     }
                 }
                 
                 //If list empty then showing error message
                 if (rootFERTs.isEmpty()){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'No material found for the selected template.'));
                 }
                 else{
                     rootIns.assignRecordList(rootFERTs);
                 }
             }
             // If template changed back to empty.
             else
             {
                 rootFERTs = new List<MaterialFERTWrapper>();  
                 if(pageParameters.get('source').equalsIgnoreCase('ReleaseDetail'))
                 {
                     getExistingBOMTree();
                 }
                 rootIns.assignRecordList(rootFERTs);
             }
             populateTerritoryForDisc(rootFERTs);  //REL-20
         }catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));               
         }          
         return null;        
     }
     
     /*****************************************************************
     Method Name: setReleaseDetails
     Purpose: Executed when user creates material on existing release
     ***************************************************************/       
     public pageReference setReleaseDetails(){     
         try{
             //checking if its a update activity
             if(releaseDetails != null && releaseDetails.Release__c != null){
                 Release__c relDetail = [Select id,name,Label_Code__c,Street_Date__c,Title__r.id,Brand_Group__c,Project_Type__c,Territory__c,Promotion_Name_Abbreviation__c from Release__c where id=:releaseDetails.Release__c];
                 
                 //setting release details
                 if (relDetail != null){                    
                     releaseDetails.id = relDetail.id;
                     releaseDetails.name = relDetail.name;
                     releaseDetails.Street_Date__c = relDetail.Street_Date__c;
                     releaseDetails.Title__c = relDetail.Title__r.id;
                     releaseDetails.Brand_Group__c = relDetail.Brand_Group__c;
                     releaseDetails.Project_Type__c = relDetail.Project_Type__c;
                     releaseDetails.Territory__c = relDetail.Territory__c;
                     releaseDetails.Promotion_Name_Abbreviation__c = relDetail.Promotion_Name_Abbreviation__c ; 
                     releaseDetails.Label_Code__c = relDetail.Label_Code__c;
                 }
             }  
         }  
         catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));               
         }   
         return null;
     }  
     
       
     /*****************************************************************
     Method Name: addFormats
     Purpose : for adding parent material row
     ***************************************************************/
     public pagereference addFormats(){
         string tempSEGNNO = null;
         ID titleID ;
         Title__c titleDetails;
         
         //setting default title
         if(releaseDetails != null && string.valueof(releaseDetails.Title__c)!='' && string.valueof(releaseDetails.Title__c)!= null){
             titleDetails = [Select id,name,SGENNO__c,street_Date__c,Title_Abbreviation__c,Sort_Name__c,Type_Code__c from Title__c where id=:releaseDetails.Title__c];
             tempSEGNNO = titleDetails.SGENNO__c;
             titleID = titleDetails.ID;
         }
         
         if(titleDetails != null && !mapTitleDetails.containsKey(titleDetails.id)){
             mapTitleDetails.put(titleDetails.id,titleDetails);
         }   
         
         if(titleID == null && pageParameters.containsKey('titleId') && pageParameters.get('titleId') != null && pageParameters.get('titleId') != ''){
             titleID = pageParameters.get('titleId');
         }
         
         //Adding a format row for wizard section
         rootFERTs.add(new MaterialFERTWrapper(titleID, tempSEGNNO,u.Profile.Name));
         rootFERTs[rootFERTs.size()-1].instance.Item_Type__c = S_ITEM_TYPE;
         rootFERTs[rootFERTs.size()-1].instance.Item_Code__c = SS_ITEM_CODE;
         rootFERTs[rootFERTs.size()-1].wizardType = wizardType;
         rootFERTs[rootFERTs.size()-1].levelOfDepth = 1;
         
         if(releaseDetails !=null && releaseDetails.Territory__c != null){
             rootFERTs[rootFERTs.size()-1].instance.Territory__c = releaseDetails.Territory__c;
         }else{        
             rootFERTs[rootFERTs.size()-1].instance.Territory__c = 'US';
         }
         
         rootIns.lastPage();
         
         return null;
     } 
     
     /*****************************************************************
     Method Name: setStreetDateOnTitleChange
     Purpose: Set street Date from title
     ***************************************************************/ 
     public pageReference setStreetDateOnTitleChange(){ 
         if(releaseDetails != null && string.valueof(releaseDetails.Title__c) != null && string.valueof(releaseDetails.Title__c) != ''){
             List<Title__c> lstTitleDetails = [Select id,name,SGENNO__c,street_Date__c,Title_Abbreviation__c,Sort_Name__c,Type_Code__c from Title__c where id=:releaseDetails.Title__c];
             releaseDetails.SGENNO__c = lstTitleDetails[0].SGENNO__c;
             if(!mapTitleDetails.containsKey(lstTitleDetails[0].id)){
                 mapTitleDetails.put(lstTitleDetails[0].id,lstTitleDetails[0]);
             }   
             
             //Setting default title for wizard
             if(!rootFERTs.isEmpty()){               
                 for(MaterialFERTWrapper wAF : rootFERTs){                    
                     if(string.valueof(wAF.instance.Title__c)=='' || string.valueof(wAF.instance.Title__c)==null){
                         wAF.instance.Title__c = releaseDetails.Title__c;
                         wAF.sysgenNo = lstTitleDetails[0].SGENNO__c ;
                     }
                 }
             }
         }
         
         if(releaseDetails != null && strTempRelName != null && strTempRelName.trim() != '')
             releaseDetails.Name= strTempRelName;
         return null;        
     }
     
     
     /*****************************************************************
     Method Name: setReleaseName
     Purpose: add new rows to material lookup table
     ***************************************************************/
     public pageReference setReleaseName(){      
         if(releaseDetails != null)
             strTempRelName = releaseDetails.Name;
         return null;
     }
     
     /*****************************************************************
     Method Name: setTitleDetails
     Purpose : setting default title on materials
     ***************************************************************/
     public pageReference setTitleDetails(){ 
         try{        
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
             
             //setting title information for material
             if(!rootFERTs.isEmpty() && ins.instance.Title__c != null){
                 Title__c titleDetails = [Select id,name,SGENNO__c,Title_Abbreviation__c,Sort_Name__c,Type_Code__c from Title__c where id=:ins.instance.Title__c];
                 if(!mapTitleDetails.containsKey(titleDetails.id)){
                     mapTitleDetails.put(titleDetails.id, titleDetails);
                 } 
                 ins.sysgenNo = titleDetails.SGENNO__c ;
             } 
             else if(ins != null && ins.instance.Title__c == null) 
             {
                 ins.sysgenNo = '';
             }  
         }
         catch(Exception ex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system administrator. ' + ex.getMessage() + '.'));
         }
         return null;        
     }
     
     /*****************************************************************
     Method Name: setTitleDetailsG1200
     Purpose : setting default title on materials
     ***************************************************************/
     public pageReference setTitleDetailsG1200(){ 
         try{        
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootFERTs);
             String uRole = UserInfo.getUserRoleID();
             UserRole u = [select Id, Name from UserRole where Id =: uRole];
             system.debug('u============= '+u);
             Title__c titleDetails = [Select id,name,SGENNO__c,Title_Abbreviation__c,Sort_Name__c,Type_Code__c from Title__c where SGENNO__c =: Label.G1200_SGENNO];
             
             if(u.Name == 'G1200' && ins.instance.Item_Type__c == 'S (Single)'){
                 mapTitleDetails.put(titleDetails.id, titleDetails);
                 system.debug('mapTitleDetails=== '+mapTitleDetails);
             }
             
             if(u.Name == 'G1200' && ins.instance.Item_Type__c == 'S (Single)'){
                 ins.instance.Title__c = mapTitleDetails.get(titleDetails.id).Id;   
                 ins.sysgenNo = titleDetails.SGENNO__c ;
             }
         }
         catch(Exception ex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system administrator. ' + ex.getMessage() + '.'));
         }
         return null;        
     }
     
     @testVisible Map<Id, Deal__c> titleDealMap = new Map<Id, Deal__c>();
     @testVisible Map<String, String> changedLblCodeMap = new Map<String, String>();
     @testVisible Map<String, Id> subLblCodeMap = new Map<String, Id>();
     @testVisible Map<String, Origin_Code__c> originCodeMap = new Map<String, Origin_Code__c>();
     /*****************************************************************
     Method Name: setMaterialDetails
     Purpose : for setting material description and other fields for a material record
     ***************************************************************/
     public pageReference setMaterialDetails(){
                                List<Alternative_Unit_of_Measure__c> tempAUoMList = new List<Alternative_Unit_of_Measure__c>(); //USST-2982
                                Map<ID, Alternative_Unit_of_Measure__c> AuomMatMap = new Map<ID, Alternative_Unit_of_Measure__c>(); //USST-2982
                                Set<Id> tempMatIdSet = new Set<Id>(); //USST-2982
         try
         {
             //Initializing variables and colection 
             string tempName;
             
             //Setting territory
             if(releaseDetails != null && releaseDetails.Territory__c != null && releaseDetails.Territory__c !=''){
                 territory = releaseDetails.Territory__c;
             }else{
                 territory = 'US';
             }            
             
             //Error if project type or brand group is null
             if(releaseDetails != null && (releaseDetails.Project_Type__c == null || releaseDetails.Project_Type__c == '' || releaseDetails.Brand_Group__c == null || releaseDetails.Brand_Group__c == '') && (pageParameters.get('source').equalsIgnoreCase('ReleaseListView') || pageParameters.get('source').equalsIgnoreCase('ReleaseListNew') || pageParameters.get('source').equalsIgnoreCase('TitleDetail'))){    
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select Brand Group and Project Type before clicking on submit.'));   
                 return null; 
             }
             
             //Error if label code is null
             if(releaseDetails != null && (releaseDetails.Label_Code__c == null || releaseDetails.Label_Code__c == '' ) && (pageParameters.get('source').equalsIgnoreCase('ReleaseListView') || pageParameters.get('source').equalsIgnoreCase('ReleaseListNew') || pageParameters.get('source').equalsIgnoreCase('TitleDetail'))){    
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select Label Code before clicking on submit.'));   
                 return null; 
             }
             
             lstMaterialRecords = new List<Material__c>();
             if(!rootFERTs.isEmpty())
             {
                 hasError = false;
                 titleDealMap = new Map<Id, Deal__c>();
                 getAllTitles(rootFERTs);
                 changedLblCodeMap.clear();
                 subLblCodeMap.clear();
                 
                 if(u.Label_Code__c != null && LabelCode_SubLabelCode_Map__c.getInstance(u.Label_Code__c) != null && 
                    LabelCode_SubLabelCode_Map__c.getInstance(u.Label_Code__c).Sub_Label_Code_Id__c != null)
                     changedLblCodeMap.put(u.Label_Code__c, LabelCode_SubLabelCode_Map__c.getInstance(u.Label_Code__c).Sub_Label_Code_Id__c);
                 // Fetches the default deal associated with title.
                 if(titleDealMap.size() > 0)
                 {
                     for(Deal__c deal : [SELECT Id, Name, Deal_ID__c, Label_Code__c, Title__c, Origin_Code__c, Title__r.Name     // Changed for Deal
                                         FROM Deal__c 
                                         WHERE Title__c IN :titleDealMap.keySet() AND Finance_Default_Deal__c=TRUE /*AND Label_Code__c =: u.Label_Code__c*/])
                     {
                         // Changed for Deal
                         if (deal.Origin_Code__c == null) {
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'The Origin Code of Deal: '+deal.Name+'(under Title: '+
                                                                    deal.Title__r.Name+') is not valid in the system. Please reach out to IT to resolve.'));   
                             return null;
                         }
                        
                         titleDealMap.put(deal.Title__c, deal);
                         if(deal.Label_Code__c != null && !changedLblCodeMap.containsKey(deal.Label_Code__c) && LabelCode_SubLabelCode_Map__c.getInstance(deal.Label_Code__c) != null && 
                            LabelCode_SubLabelCode_Map__c.getInstance(deal.Label_Code__c).Sub_Label_Code_Id__c != null)
                             changedLblCodeMap.put(deal.Label_Code__c, LabelCode_SubLabelCode_Map__c.getInstance(deal.Label_Code__c).Sub_Label_Code_Id__c);
                         if(deal.Origin_Code__c != null)
                             originCodeMap.put(deal.Origin_Code__c, null);
                     }
                 }
                 
                 if(releaseDetails != null && releaseDetails.Label_Code__c != null && !changedLblCodeMap.containsKey(releaseDetails.Label_Code__c) &&
                    LabelCode_SubLabelCode_Map__c.getInstance(releaseDetails.Label_Code__c) != null && LabelCode_SubLabelCode_Map__c.getInstance(releaseDetails.Label_Code__c).Sub_Label_Code_Id__c != null)
                     changedLblCodeMap.put(releaseDetails.Label_Code__c, LabelCode_SubLabelCode_Map__c.getInstance(releaseDetails.Label_Code__c).Sub_Label_Code_Id__c);
                 
                 if(originCodeMap.size() > 0)
                 {
                     for(Origin_Code__c oc : [SELECT Id, Label_Code__c, Sub_Label_Code__c, Origin_Code__c, Label_Code_2__c, Sub_Label_Code_2__c, Default_Deal_ID__c FROM Origin_Code__c WHERE Origin_Code__c IN: originCodeMap.keySet()]) //USST-2728 & USST-2669
                     {
                         originCodeMap.put(oc.Origin_Code__c, oc);
                         if(oc.Label_Code__c != null && !changedLblCodeMap.containsKey(oc.Label_Code__c) && LabelCode_SubLabelCode_Map__c.getInstance(oc.Label_Code__c) != null && 
                            LabelCode_SubLabelCode_Map__c.getInstance(oc.Label_Code__c).Sub_Label_Code_Id__c != null)
                             changedLblCodeMap.put(oc.Label_Code__c, LabelCode_SubLabelCode_Map__c.getInstance(oc.Label_Code__c).Sub_Label_Code_Id__c);
                     }
                 }
                 
                 if(changedLblCodeMap.size() > 0)
                 {
                     for(Sub_Label_Code__c sLblCode : [SELECT Id, Sub_Label_Code_ID__c FROM Sub_Label_Code__c 
                                                       WHERE Sub_Label_Code_ID__c IN: changedLblCodeMap.values()])
                     {
                         subLblCodeMap.put(sLblCode.Sub_Label_Code_ID__c, sLblCode.Id);
                     }
                 }
                System.Debug('check map values !! '+titleDealMap);
                 
                 if(!setMultitleID.isEmpty()){
                     for(Material__c mat : [Select id,Total_Item_Qty__c,Material_Expiration_Date__c , (Select id from BOM_Items__r where Material_Component__r.Item_Code__c=:BF_ITEM_CODE LIMIT 200) from Material__c where id in:setMultitleID]){ //USST-2960
                         if(!mapBFPresent.containsKey(mat.ID) && mat.BOM_Items__r.size() > 0){
                             mapBFPresent.put(mat.ID,TRUE);
                         }
                     }
                 }
                 
                 prepareCompleteBOMHierarchy(rootFERTs);
                 
                 if(hasError)
                     return null;
                 
                 // Changed for RE-17
                                                                //USST-2982 --- start
                                                                for (MaterialFERTWrapper mat : rootFERTs) {
                                                                                tempMatIdSet.add(mat.instance.id);
                                                                }
                                                                
                                                                 tempAUoMList = [SELECT Id, Alternative_Unit_of_Measure__c,Material__c, Denominator_Conversion__c        
                                                                                                                                                                                 FROM Alternative_Unit_of_Measure__c WHERE Material__c IN: tempMatIdSet    
                                             AND (Alternative_Unit_of_Measure__c='RSU - Retail unit' OR Alternative_Unit_of_Measure__c='RSU - Retail Sellable Unit')];
                                                                for (Alternative_Unit_of_Measure__c auom : tempAUoMList) {
                                                                                AuomMatMap.put(auom.Material__c, auom);
                                                                } 
                                                                 //USST-2982 --- end
                 // Reiterate again on the first level to handle Joint Corrugate calculation on FT.
                 for(MaterialFERTWrapper mat : rootFERTs)
                 {
                     if(mat.instance.Item_Type__c == D_ITEM_TYPE && mat.childFERTs.size() > 0)
                     {
                         Decimal totalItemQty = 0;
                         for(MaterialFERTWrapper childMat : mat.childFERTs)
                         {
                             if(childMat.instance.Item_Type__c == D_ITEM_TYPE && childMat.instance.Total_Item_Qty__c != null)
                             
                                 totalItemQty += childMat.instance.Total_Item_Qty__c;
                             else
                                 totalItemQty += childMat.ComponentQty;
                             System.debug('totalItemQty :: '+totalItemQty);
                         }
                         mat.instance.Total_Item_Qty__c = totalItemQty;
                         System.debug('-----JCCount> '+mat.instance.Total_Item_Qty__c);
                     }
                     //Update for 2458 starts
                     updateableParentMaterialList.add(mat.instance);     
                     if (AuomMatMap != null && AuomMatMap.get(mat.instance.id)!= null ) {  // Added for USST-3009
                     
                                    Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c(Id = AuomMatMap.get(mat.instance.id).id, Denominator_Conversion__c = String.valueOf(Integer.valueOf(mat.instance.Total_Item_Qty__c)), Execute_Validation__c = false); //USST-2982  
                                     updateableAUoMList.add(auom);     
                             
                     System.debug('updateableAUoMList:: '+updateableAUoMList);
                                                                                }
                                                                                
                     
                     
                     //Update for 2458 ENDS                  
                 }
                 
                 rootIns.currentPageNumber = 1;
                 setPageNumberForBOMHierarchy(rootFERTs);
                 
                 showMaterialDesc = TRUE;
                 rootIns.firstPage();
                 pagereference pg = new pagereference('/apex/ReviewMaterialDescription');
                 pg.setRedirect(false);
                 return pg;
             }
             else
             {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please add some material(s) to proceed.'));   
                 return null;
             }
         }
         catch(Exception ex)
         {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage() + '.'));   
             return null;
         }
         
         return null;
     }
     
     //Set Page number to 1 on click of next
     @TestVisible private void setPageNumberForBOMHierarchy(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {
             //set page number to 1
             mat.childIns.CurrentPageNumber = 1;
             
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             getAllTitles(nextLevelMaterials);
     }
     
     // Following method fetches the selected titles from materials
     private void getAllTitles(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {
             // Collect titles
             if(mat.instance.Title__c != null)
                 titleDealMap.put(mat.instance.Title__c, null);
             
             if(mat.instance.id != null && mat.instance.Item_Code__c == MT_ITEM_CODE && !setMultitleID.contains(mat.instance.ID)){
                 setMultitleID.add(mat.instance.ID);
             }
                 
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             getAllTitles(nextLevelMaterials);
     }
     
     /*****************************************************************
     Method Name: prepareCompleteBOMHierarchy
     Purpose : prepare default data for all the records on click of next button
     ***************************************************************/
     public void prepareCompleteBOMHierarchy(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         String tempName;
         
         //DF-00974 start
         Set <id> titleIds=new Set<Id>();
         
         System.debug('####Asha - mapTitleDetails'+mapTitleDetails);
         if(mapTitleDetails==null || mapTitleDetails.isEmpty()){
            for(MaterialFERTWrapper matWrap:processingMaterials){
                     titleIds.add(matWrap.instance.Title__c);
                 }
                 if(!titleIds.isEmpty()){
                     for(Title__c titleDetails :[Select id,name,SGENNO__c,Title_Abbreviation__c,Sort_Name__c,Type_Code__c from Title__c where id in:titleIds])
                     
                         if(!mapTitleDetails.containsKey(titleDetails.id)){
                             mapTitleDetails.put(titleDetails.id, titleDetails);
                         } 
                 }
         }
         //DF-00974 end
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {   
             String lblCode = u.Label_Code__c;
             System.debug('----lblCode1> '+lblCode);
             
             if(mat.instance.Id == null)
             {          
                 //checking if format description is not null
                 if(mat.instance.Format_Description__c == null){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select format description.')); 
                     hasError = true;
                     return;
                 } 
                 
                 //validation if material type is not FERT
                 if(mat.instance.Material_Type__c != FERT_MATERIAL_TYPE ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Material Type should be FERT.')); 
                     hasError = true;
                     return;                
                 }
                 
                 //validation if Item type is not selected USST-2910
                 if(mat.instance.Item_Type__c == null ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item type field is a required field.  It can not be blank or none.')); 
                     hasError = true;
                     return;                
                 }
                 
                 //validation if Item code is not selected USST-2910
                 if(mat.instance.Item_Code__c == null ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item code field is a required field.  It can not be blank or none.')); 
                     hasError = true;
                     return;                
                 }
                 
                 //Wizard format should be DVD for creating a Baby FERT
                 if(mat.instance.Format_Description__c != DVD_WIZARD_FORMAT && mat.instance.Item_Type__c == S_ITEM_TYPE && mat.instance.Item_Code__c == BF_ITEM_CODE){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Wizard format should be set to DVD when creating a Baby FERT.')); 
                     hasError = true;
                     return;                
                 }
                 
                 // Validation for Multi Title and Collection Pack.
                 if((mat.instance.Item_Type__c == M_ITEM_TYPE || mat.instance.Item_Type__c == D_ITEM_TYPE) && (mat.instance.Title__c != null || (releaseDetails != null && releaseDetails.Title__c != null)))
                 {
                     mat.instance.Title__c = null; //USST-2977
                     mat.instance.SGENNO__c = null; //USST-2977
                 }
                 
                 // Validation for Item Type S and Item Code SS.
                 if(mat.instance.Item_Type__c == S_ITEM_TYPE && (mat.instance.Item_Code__c == SS_ITEM_CODE || mat.instance.Item_Code__c == BF_ITEM_CODE || mat.instance.Item_Code__c == ME_ITEM_CODE || mat.instance.Item_Code__c == SE_ITEM_CODE) && mat.instance.Title__c == null) //Added SE,ME,BF for USST-2644
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Title should not be blank if item type is S and item code is SS/SE/ME/BF.')); //Modified error message for USST-2644
                     hasError = true;
                     return;
                 }
                 
                 if(mat.instance.Item_Type__c == S_ITEM_TYPE && mat.instance.Item_Code__c == CE_ITEM_CODE && mat.instance.Title__c != null && mapTitleDetails != null && mapTitleDetails.containsKey(mat.instance.Title__c) && mapTitleDetails.get(mat.instance.Title__c).Type_Code__c != TITLE_TYPE_CODE)
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Title type code should be ' + TITLE_TYPE_CODE + ' if item type is S and item code is CE. ' )); 
                     hasError = true;
                     return;
                 }
                 
                 // Validating for BF should allow only territory US & CDN
                 if(mat.instance.Item_Type__c == S_ITEM_TYPE && mat.instance.Item_Code__c == BF_ITEM_CODE && mat.instance.territory__c != 'US & CDN')
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select territory US & CDN for Baby FERT.')); 
                     hasError = true;
                     return;
                 }
                 
                 //Validating territory type
                 if(releaseDetails != null && releaseDetails.Territory__c != null && ((releaseDetails.Territory__c == 'US' && mat.instance.territory__c == 'CDN') || (releaseDetails.Territory__c == 'CDN' && mat.instance.territory__c == 'US') )){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If release territory is '+releaseDetails.Territory__c + ' then material territory cannot be '+mat.instance.territory__c+'.')); 
                     hasError = true;
                     return;                
                 }
                 
                 //Validating territory type
                 if(mat.instance.territory__c == null){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Territory cannot be left blank.')); 
                     hasError = true;
                     return;                
                 } 
                 
                 /*** Prepare material details. ***/
                 mat.instance.Created_from_Wizard__c = true;
                 
                 system.debug('material description-->'+mat.instance.Format_Description__c);
                 MaterialNamingConventionHandler.parentformatDescription = mat.instance.Format_Description__c; // passing parent format description   
                 //generating name for parent material 
                 System.debug('check map values '+ mapTitleDetails);
                 tempName = MaterialNamingConventionHandler.getFERTMaterialName(mat.instance, releaseDetails, mapTitleDetails.get(mat.instance.Title__c));                      
                 mat.instance.Name = tempName;
                 
                 if(releaseDetails != null && releaseDetails.Project_Type__c != null && releaseDetails.Project_Type__c != '')
                 {
                     mat.instance.Project_Type__c = releaseDetails.Project_Type__c;
                 }
                 if(releaseDetails != null && releaseDetails.Street_Date__c != null && mat.instance.Item_Code__c != 'BF - BABY FERT' && mat.instance.Material_Type__c != 'ROH' && mat.instance.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false)
                 {
                     mat.instance.Street_Date__c = releaseDetails.Street_Date__c;
                     mat.instance.Original_Release_Date__c = releaseDetails.Street_Date__c;
                 }
                 
                 //assigning SGENNO based on title
                 if(mapTitleDetails.containskey(mat.instance.Title__c)){
                     mat.instance.SGENNO__c = mapTitleDetails.get(mat.instance.Title__c).SGENNO__c;
                 }
                  
                 System.Debug('material instance details '+ mat);
                 Id subLabelCodeId;
                 if(mat.instance.Title__c != null && titleDealMap.containsKey(mat.instance.Title__c) && titleDealMap.get(mat.instance.Title__c) != null)
                 {
                     mat.instance.Deal__c = titleDealMap.get(mat.instance.Title__c).Id; //USST-2728
                     mat.instance.Deal_ID__c = titleDealMap.get(mat.instance.Title__c).Deal_ID__c; //USST-2728
                     
                     if(titleDealMap.get(mat.instance.Title__c).Origin_Code__c != null && originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c) != null &&
                        originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Label_Code__c != null)
                     {
                         //USST-2728 & USST-2669 ---- start 
                         if (originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c != null
                            && originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c != ''
                            && originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c == mat.instance.Deal_ID__c) {
                             system.debug('Enter 2728');
                             lblCode = originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Label_Code_2__c;
                         }
                         else {
                              system.debug('Enter 2728');
                             lblCode = originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Label_Code__c;
                         }
                         //USST-2728 & USST-2669 ---- end
                         
                         if(originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Sub_Label_Code__c != null) {
                            //USST-2728 & USST-2669 ---- start 
                            if (originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c != null
                                && originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c != ''
                                && originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Default_Deal_ID__c == mat.instance.Deal_ID__c) {
                                system.debug('Enter 2728');
                                subLabelCodeId = originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Sub_Label_Code_2__c; 
                            }
                            else {
                                system.debug('Enter 2728');
                               subLabelCodeId = originCodeMap.get(titleDealMap.get(mat.instance.Title__c).Origin_Code__c).Sub_Label_Code__c; 
                            }
                            //USST-2728 & USST-2669 ---- end
                         }
                     }
                     else if(titleDealMap.get(mat.instance.Title__c).Label_Code__c != null)
                     {
                         lblCode = titleDealMap.get(mat.instance.Title__c).Label_Code__c;
                         if(changedLblCodeMap.containsKey(lblCode) && subLblCodeMap.containsKey(changedLblCodeMap.get(lblCode)))
                             subLabelCodeId = subLblCodeMap.get(changedLblCodeMap.get(lblCode));
                     }
                 }
                 else if(mat.instance.Title__c != null && titleDealMap.containsKey(mat.instance.Title__c) && titleDealMap.get(mat.instance.Title__c) == null)
                 {
                     if(releaseDetails != null && releaseDetails.Label_Code__c !=null){
                         lblCode = releaseDetails.Label_Code__c;
                     }    
                 }  
                 else if(mat.instance.Title__c == null && releaseDetails != null && releaseDetails.Label_Code__c !=null){
                     lblCode = releaseDetails.Label_Code__c;
                 }               
                 System.debug('check deal 1 '+mat.instance.Deal__c);
                 System.debug('----lblCodeMat> '+lblCode);
                 //setting default values for material record
                 Material__c mtParent = setKeyFields(mat.instance, mat.instance.name, mat.instance.Format_Description__c, lblCode, FERT_MATERIAL_TYPE , mat.instance.Item_Type__c, mat.instance.Item_Code__c, mat.instance.Territory__c, mat.instance.Retailer_Rental__c,mat.instance.Title__c, '', FALSE, 0, null);
                 System.debug('*****subLblCodeMap> '+subLblCodeMap+' :: '+changedLblCodeMap+' :: '+mtParent.Label_Code__c);
                 if(subLabelCodeId != null)
                     mtParent.Sub_Label_Code_Lookup__c = subLabelCodeId;
                 else if(mtParent != null && mtParent.Material_Type__c == 'FERT' && 
                     mtParent.Label_Code__c != null && changedLblCodeMap.containsKey(mtParent.Label_Code__c) && subLblCodeMap.containsKey(changedLblCodeMap.get(mtParent.Label_Code__c)))
                 {
                     mtParent.Sub_Label_Code_Lookup__c = subLblCodeMap.get(changedLblCodeMap.get(mtParent.Label_Code__c));
                 }
                 if(mtParent != null){
                     lstMaterialRecords.add(mtParent);
                 }

                 System.debug('check deal 2 '+mat.instance.Deal__c);
             }
             // Following scope is to handle the Existing material section.
             else
             {
                 if(mat.instance.Title__c != null && titleDealMap.containsKey(mat.instance.Title__c) && titleDealMap.get(mat.instance.Title__c) != null &&
                    titleDealMap.get(mat.instance.Title__c).Label_Code__c != null)
                     lblCode = titleDealMap.get(mat.instance.Title__c).Label_Code__c;
             }
             
             Map<String, Integer> discCounterMap = new Map<String, Integer>();
             Map<String, Integer> discCounterMap1 = new Map<String, Integer>();
             
             for(MaterialComponentWrapper comp : mat.childComponents)
             {
                 if(comp.instance.Id != null)
                     continue;
                 if(!String.isEmpty(comp.instance.Component_Type__c) && (string.valueof(comp.instance.Component_Type__c).contains('DISC'))){
                     if(discCounterMap.containsKey(comp.instance.Component_Type__c))
                         discCounterMap.put(comp.instance.Component_Type__c, (discCounterMap.get(comp.instance.Component_Type__c) + 1));
                     else
                         discCounterMap.put(comp.instance.Component_Type__c, 1);
                 }
             }
             
             // Iterate over child components
             for(MaterialComponentWrapper comp : mat.childComponents)
             {
                 if(comp.isExisting && comp.ComponentQty != comp.ComponentQtyActual){
                     //Updated Error Msg for REL-197
                    if (mat.instance.Item_Type__c != D_ITEM_TYPE && mat.instance.BOM_Status__c != 'Draft' && mat.instance.BOM_Status__c != 'In Progress') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item Quantity can no longer be edited once the BOM has been submitted')); 
                        hasError = true;
                        return;
                    }
                    else if (mat.instance.Item_Type__c == D_ITEM_TYPE && mat.instance.Id != null && (mat.hasDChainFR == null || 
                       (mat.hasDChainFR != null && !mat.hasDChainFR))) {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item Quantity cannot be edited because DChain is not equal to FR for this Display')); 
                        hasError = true;
                        return;
                    }
                 }
                 
                 
                 //Validating territory type
                 if(releaseDetails != null && releaseDetails.Territory__c != null && ((releaseDetails.Territory__c == 'US' && comp.instance.territory__c == 'CDN') || (releaseDetails.Territory__c == 'CDN' && comp.instance.territory__c == 'US') )){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If release territory is '+releaseDetails.Territory__c + ' then material territory cannot be '+comp.instance.territory__c+'.')); 
                     hasError = true;
                     return;                
                 }       
                 
                 //Validating territory type
                 if(comp.instance.territory__c == null){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Territory cannot be left blank.')); 
                     hasError = true;
                     return;                
                 }  
                 
                 //Validating territory type
                 if((mat.instance.Territory__c == 'US' && comp.instance.territory__c == 'CDN') || (mat.instance.Territory__c == 'CDN' && comp.instance.territory__c == 'US') ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If FERT territory is '+ mat.instance.Territory__c + ' then component territory cannot be '+ comp.instance.territory__c+'.')); 
                     hasError = true;
                     return;                
                 }    
                 
                 //Validating territory type
                 if(mat.instance.Territory__c == 'US & CDN' && comp.instance.territory__c != 'US & CDN'){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If FERT territory is '+ mat.instance.Territory__c + ' then component territory should be '+ mat.instance.Territory__c +'.')); 
                     hasError = true;
                     return;                
                 }
                 
                 // Re-Locate due to REL-45
                 if(comp.instance.Id != null)
                     continue;
                
                //relocated the below if condition for USST-2619
                //checking if component type is selected
                 if(comp.instance.Component_Type__c == null){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please select component type.')); 
                     hasError = true;
                     return;
                 }  
                
                 // Change for REL-78 & REL-20
                 // For Non-Disc components.
                 if(comp.instance.Component_Type__c !=  'DISC DVD' && comp.instance.Component_Type__c != 'DISC BD' && 
                    comp.instance.Component_Type__c != 'DISC UHD' && comp.instance.Component_Type__c != 'DISC CD')
                 {
                     // Brand user must choose territory as US only or CDN only
                     if(u.Profile.Name == 'Brand User' && comp.instance.territory__c == 'US & CDN')
                     {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Brand user must not choose the territory of NON-DISC component as US & CDN.')); 
                         hasError = true;
                         return;
                     }
                 }
                 
                 //Setting naming convention for ROH records
                 comp.instance.Created_from_Wizard__c = true;
                 
                 System.debug('####Asha - Component Naming convention'+mat.instance.Title__c);
                 System.debug('####Asha - mat.instance.Retailer_Rental__c'+mapTitleDetails.get(mat.instance.Title__c));
                 comp.instance.Name = comp.instance.Component_Type__c;
                 String discFormat;
                 if(!String.valueOf(comp.instance.Component_Type__c).contains('DISC'))
                 {
                     comp.instance.Format_Description__c     = mat.instance.Format_Description__c;
                 }
                 else
                 {
                     if(comp.instance.Component_Type__c == 'DISC CD')
                     {
                         comp.instance.Format_Description__c = mat.instance.Format_Description__c;
                     } //USST-2424
                     else
                      {
                          if(comp.instance.Component_Type__c == 'DISC DVD' || comp.instance.Component_Type__c== 'DISC UHD' ||
                            comp.instance.Component_Type__c == 'DISC BD' )
                         {
                           if(mat.instance.Format_Description__c=='BD-R' || 
                             mat.instance.Format_Description__c=='BD-R COMBO PACK' ||
                             mat.instance.Format_Description__c=='DVDR' )
                       {
                         
                         List<String> splitedVals = comp.instance.Component_Type__c.split(' ');
                         if(splitedVals != null && splitedVals.size() == 2)
                         {
                             String format = splitedVals[1];
                             comp.instance.Format_Description__c = mat.instance.Format_Description__c + ' '+format;
                         }
                       }else
                         {
                         List<String> splitedVals = comp.instance.Component_Type__c.split(' ');
                         if(splitedVals != null && splitedVals.size() == 2)
                             {
                                 String format = splitedVals[1];
                                 comp.instance.Format_Description__c = format;
                             }
                         }
                          }else
                            {
                             List<String> splitedVals = comp.instance.Component_Type__c.split(' ');
                             if(splitedVals != null && splitedVals.size() == 2)
                             {
                                 String format = splitedVals[1];
                                 comp.instance.Format_Description__c = format;
                             }
                             
                            }
                            
                          }
                         
                 }
                 comp.instance.Retailer_Rental__c = mat.instance.Retailer_Rental__c;                     
                 tempName = MaterialNamingConventionHandler.getComponentName(comp.instance,releaseDetails,mapTitleDetails.get(mat.instance.Title__c));                      
                 if(comp.instance.Format_Description__c !=null)
                 {
                     if(comp.instance.Format_Description__c=='BD-R DVD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R DVD','BD-R');
                     }
                     if(comp.instance.Format_Description__c=='BD-R UHD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R UHD','BD-R');
                     } 
                     if(comp.instance.Format_Description__c=='BD-R BD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R BD','BD-R');
                     } 
                     if(comp.instance.Format_Description__c=='BD-R COMBO PACK DVD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R COMBO PACK DVD','BD-R COMBO PACK');
                     } 
                     if(comp.instance.Format_Description__c=='BD-R COMBO PACK UHD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R COMBO PACK UHD','BD-R COMBO PACK');
                     } 
                     if(comp.instance.Format_Description__c=='BD-R COMBO PACK BD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('BD-R COMBO PACK BD','BD-R COMBO PACK');
                     }
                     if(comp.instance.Format_Description__c=='DVDR DVD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('DVDR DVD','DVDR');
                     } 
                     if(comp.instance.Format_Description__c=='DVDR UHD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('DVDR UHD','DVDR');
                     } 
                     if(comp.instance.Format_Description__c=='DVDR BD')
                     {
                       comp.instance.Format_Description__c = comp.instance.Format_Description__c.replaceAll('DVDR BD','DVDR');
                     } 
                 }
                 discFormat = comp.instance.Format_Description__c;
                 comp.instance.Name = tempName;
                 if(releaseDetails != null && releaseDetails.Project_Type__c != null && releaseDetails.Project_Type__c != '')
                 {
                     comp.instance.Project_Type__c = releaseDetails.Project_Type__c;
                 }
                 
                 System.debug('----lblCodeComp> '+lblCode);
                 String materialType = ROH_MATERIAL_TYPE;
                 if(Component_MaterialType_Mapping__c.getInstance(comp.instance.Component_Type__c) != null && 
                    Component_MaterialType_Mapping__c.getInstance(comp.instance.Component_Type__c).Material_Type__c == Z009_MATERIAL_TYPE)
                 {
                     materialType = Z009_MATERIAL_TYPE;
                 }
                 
                 System.Debug('Wizard Format Val '+mat.instance.Format_Description__c);
                 
                 if(mat.instance.Material_Number__c != null && mat.instance.Material_Number__c != '' && comp.instance.ID == null){
                    comp.instance.Selection_Reference_Number__c = mat.instance.Material_Number__c;
                 }
                 
                 //setting other default values for field
                 if(string.valueof(comp.instance.Component_Type__c).contains('DISC')){
                     if (discCounterMap.containsKey(comp.instance.Component_Type__c) && Integer.ValueOf(discCounterMap.get(comp.instance.Component_Type__c)) > 1){
                         if(discCounterMap1.containsKey(comp.instance.Component_Type__c)){
                             discCounterMap1.put(comp.instance.Component_Type__c, (discCounterMap1.get(comp.instance.Component_Type__c) + 1));
                             comp.instance.Name = comp.instance.Name + ' D' + string.valueof(discCounterMap1.get(comp.instance.Component_Type__c));
                         }    
                         else{
                             discCounterMap1.put(comp.instance.Component_Type__c, 1);
                             comp.instance.Name = comp.instance.Name + ' D' + string.valueof(discCounterMap1.get(comp.instance.Component_Type__c));
                         }    
                     }
                     
                     
                     lstMaterialRecords.add(setKeyFields(comp.instance, comp.instance.Name,/*mat.instance.Format_Description__c*/discFormat,lblCode, materialType,COMP_ITEM_TYPE,DS_ITEM_CODE,comp.instance.Territory__c,mat.instance.Retailer_Rental__c,null,'',comp.instance.Association_Required__c, 0, comp.instance.Component_Type__c));
                 }else{
                     lstMaterialRecords.add(setKeyFields(comp.instance, comp.instance.Name,null,lblCode, materialType,COMP_ITEM_TYPE,PG_ITEM_CODE,comp.instance.Territory__c,mat.instance.Retailer_Rental__c,null,'',comp.instance.Association_Required__c, 0, comp.instance.Component_Type__c));
                 }
                 
                 
             }
             
             // Iterate over child materials
             if(mat.childFERTs.size() > 0)
             {
                 Decimal totalItemQty = 0;
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     if(childMat.isExisting && childMat.ComponentQty != childMat.ComponentQtyActual){
                         //Updated Error Msg for REL-197
                        if (mat.instance.Item_Type__c != D_ITEM_TYPE && mat.instance.BOM_Status__c != 'Draft' && mat.instance.BOM_Status__c != 'In Progress') { 
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item Quantity can no longer be edited once the BOM has been submitted'));
                            hasError = true;
                            return;
                        }
                        if (mat.instance.Item_Type__c == D_ITEM_TYPE && mat.instance.Id != null && (mat.hasDChainFR == null || (mat.hasDChainFR != null && !mat.hasDChainFR))) {
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Item Quantity cannot be edited because DChain is not equal to FR for this Display'));
                           hasError = true;
                           return;
                        }
                     }
                     // Validation for Multi Title and Collection Pack. // Changed for RE-16
                     if(((mat.parentItemType != D_ITEM_TYPE && mat.instance.Item_Type__c == M_ITEM_TYPE && mat.instance.Item_Code__c == CL_ITEM_CODE) || (mat.instance.Item_Type__c == D_ITEM_TYPE)) && childMat.instance.Item_Code__c ==BF_ITEM_CODE)                       
                     {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Baby FERT cannot be a direct child of item type M and item code CL or item type D.')); 
                         hasError = true;
                         return;
                     }
                     
                      // Validation for Multi Title and Baby FERT // Changed for RE-16
                     if(mat.parentItemType != D_ITEM_TYPE && mat.instance.id == null && mat.instance.Item_Type__c == M_ITEM_TYPE && mat.instance.Item_Code__c == MT_ITEM_CODE && childMat.instance.Item_Code__c !=BF_ITEM_CODE && childMat.instance.Item_Code__c !=ME_ITEM_CODE && childMat.instance.Item_Code__c !=SE_ITEM_CODE)   /* Added id == null condition for USST-2745 */                    
                     {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'For item type M and item code MT, only baby FERT material or S/SE material or S/ME material can be added.')); 
                         hasError = true;
                         return;
                     }
                     
                     //Validating territory type
                     if((mat.instance.Territory__c == 'US' && childMat.instance.territory__c == 'CDN') || (mat.instance.Territory__c == 'CDN' && childMat.instance.territory__c == 'US') ){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If FERT territory is '+ mat.instance.Territory__c + ' then child FERT territory cannot be '+ childMat.instance.territory__c+'.')); 
                         hasError = true;
                         return;                
                     }    
                     
                     //Validating territory type
                     if(mat.instance.Territory__c == 'US & CDN' && childMat.instance.territory__c != 'US & CDN'){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'If FERT territory is '+ mat.instance.Territory__c + ' then child FERT territory should be '+ mat.instance.Territory__c +'.')); 
                         hasError = true;
                         return;                
                     }   
                     
                     // Added for RE-17
                     // If parent is Display vehicle, calculate the total item qty of child FERTs.
                     if(mat.instance.Item_Type__c == D_ITEM_TYPE)
                     {
                         totalItemQty += childMat.ComponentQty;
                     }
                     
                     // Added for RE-16
                     childMat.parentItemType = mat.instance.Item_Type__c;
                     
                     nextLevelMaterials.add(childMat);
                     System.debug('totalItemQty :: '+totalItemQty);
                 }
                 
                 // Changed for RE-17
                 // If parent is Display vehicle, populate the total item count.
                 if(mat.instance.Item_Type__c == D_ITEM_TYPE)
                 {
                     mat.instance.Total_Item_Qty__c = totalItemQty;
                 }
                 System.debug('Total_Item_Qty__c :: '+mat.instance.Total_Item_Qty__c);
             }
             else{
                 // Changed for RE-16
                 if(mat.parentItemType != D_ITEM_TYPE && mat.instance.id == null && mat.instance.Item_Type__c == M_ITEM_TYPE && mat.instance.Item_Code__c == MT_ITEM_CODE)                       
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'For item type M and item code MT, baby FERT material is mandatory.')); 
                     hasError = true;
                     return;
                 }
                 // Changed for RE-16
                 else if(mat.parentItemType != D_ITEM_TYPE && mat.instance.id == null && mat.instance.Item_Type__c == M_ITEM_TYPE && mat.instance.Item_Code__c == MT_ITEM_CODE && !mapBFPresent.containsKey(mat.instance.id))  /* changed id != null condition to id == null for USST-2745 */                 
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'For item type M and item code MT, baby FERT material is mandatory.')); 
                     hasError = true;
                     return;
                 }
                 //USST-2745 --- start
                 else if(mat.parentItemType != D_ITEM_TYPE && mat.instance.Id == null && mat.instance.Item_Type__c == M_ITEM_TYPE && (mat.instance.Item_Code__c == CL_ITEM_CODE || mat.instance.Item_Code__c == 'MS - TV MULTIPLE SERIES' || mat.instance.Item_Code__c == 'XS - SPECIAL SINGLE')) // Added Id == null condition for USST-2773              
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'At least one Child FERT must be added before submitting request')); 
                     hasError = true;
                     return;
                 }
                 //USST-2745 --- end
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             prepareCompleteBOMHierarchy(nextLevelMaterials);
     }
     
     /*****************************************************************
     Method Name: setKeyFields
     Purpose : For setting default values of material records
     ***************************************************************/ 
     @testvisible private Material__c setKeyFields(Material__c objMaterial, string recordType, String recordFormat, String labelCode, string materialType, string itemType, string itemCode,string territory, string retailerRental, ID titleID, string specialScenario, boolean associationReq,integer qtyBOM,string componentType){
         
         objMaterial.Format_Description__c = recordFormat;
         objMaterial.Material_Type__c = materialType;
         objMaterial.Item_Type__c = itemtype;
         objMaterial.Item_Code__c = itemCode;
         
         if(itemcode == FT_ITEM_CODE && labelCode == LABEL_CODE_87_JC){
             objMaterial.Label_Code__c = null;
         }
         else{
             objMaterial.Label_Code__c = labelCode;
         }
             
         objMaterial.Territory__c = territory;
         objMaterial.OwnerId = userinfo.getUserId();
         objMaterial.Deletion_Flag__c = FALSE;
         objMaterial.Retailer_Rental__c = retailerRental;
         objMaterial.Valid_From__c = Date.today();
         objMaterial.RecordTypeId = masterRecordTypeId;
         objMaterial.Association_Required__c = associationReq;
         objMaterial.BOM_Quantity__c = qtyBOM;        
         
         if(itemType != M_ITEM_TYPE && itemType != D_ITEM_TYPE && itemType != COMP_ITEM_TYPE){
             objMaterial.Title__c = titleID;         
         }
         
         objMaterial.Base_Quantity__c = '0';
         objMaterial.Name = recordType;        
         objMaterial.Component_Type__c = componentType;
         
         
         return objMaterial;
     }
     
     /*****************************************************************
     Method Name: cancel
     Purpose : called on click of cancel button
     ***************************************************************/
     public PageReference cancel()
     {
         if(pageParameters != null && pageParameters.containsKey('retURL'))
         {
             String url2 = URL.getSalesforceBaseUrl().toExternalForm() + pageParameters.get('retURL');
             PageReference pg = new Pagereference(url2);
             System.debug('*****URL> '+url2 + ' :: ' + pg.getUrl());
             return pg;        
             }
         else
             return new pagereference('/home/home.jsp');
     }
     
     /*****************************************************************
     Method Name: backMaterialDescription
     Purpose : called on click of back button
     ***************************************************************/
     public pageReference backMaterialDescription(){
         showMaterialDesc = FALSE;
         
         System.Debug('check root value '+ rootFERTs);
         rootIns.firstPage();
         pagereference pg = new pagereference('/apex/MaterialCreationWizard');
         updateableParentMaterialList.clear(); //USST-2594
         updateableAUoMList.clear(); //USST-2594
         pg.setRedirect(false);
         return pg;
     }
     
     /*****************************************************************
     Method Name: submit
     Purpose : create material records
     ***************************************************************/
     public void submit()
     {
         Savepoint sp = Database.setSavepoint();
         try{
             //Initializing variables
             pageReference pg;            
             lstBOMItem = new List<BOM_Item__c>();
             updateableParentMats = new List<Material__c>();
             insertableReleaseMaterials = new List<Release_Material__c>();     
             setDuplicateName = new Set<string>();
             setUniqueName = new Set<string>();
             setLengthyName = new Set<string>();
                 
             if(lstMaterialRecords != null && lstMaterialRecords.size() > 0)
             {
                 populateLabelCodesInComponents(rootFERTs);
                 //REL-17
                 if(showMPM)
                 {
                     populateMPMInComponents(rootFERTs);
                 }               
                 //setting release id for all the records
                 for(Material__c mt : lstMaterialRecords){
                     System.Debug('check execution times ');
                     //USST-2765 --- start
                     if (mt.name.length() > 40) {
                         setLengthyName.add(mt.Name);
                     }
                     //USST-2765 --- end
                     if(releaseDetails != null)
                     {
                         mt.Release__c = releaseDetails.id;
                     }  
                     
                     if(showMPM && mt.MPM_Issue__c == null){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'MPM field is mandatory for label code '+LABEL_CODE_59_PARAMOUNT +'.'));   
                         hasException = TRUE;
                         exceptionMessage = 'MPM field is mandatory for label code '+LABEL_CODE_59_PARAMOUNT +'.';
                         lstTempMaterial.add(mt.clone());
                         break;
                     }
                     
                     if(mt.Label_Code__c == null || mt.Label_Code__c.trim() == '')
                     {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please provide Label Code for all materials.'));
                         hasException = TRUE;
                         exceptionMessage = 'Please provide Label Code for all materials.';
                         lstTempMaterial.add(mt.clone());
                         break;
                     }
                     
                     if(!setUniqueName.contains(mt.Name)){
                       setUniqueName.add(mt.name);
                     }
                     else{
                       setDuplicateName.add(mt.name);
                     }
                     
                     System.Debug('m@@terial name check '+mt.name);
                     
                     lstTempMaterial.add(mt.clone());
                 } 
                 
                 System.Debug('entry check 1');
                 
                 if(!hasException)
                 {
                     System.Debug('entry check 2');
                     //USST-2765 --- start
                     if (!setLengthyName.isEmpty()) {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Material Description cannot be more than 40 characters '+setLengthyName));
                         hasException = TRUE;
                         exceptionMessage = 'Material Description cannot be more than 40 characters '+setLengthyName; 
                         setLengthyName = new Set<string>();
                     }
                     //USST-2765 --- end
                     else { //USST-2765
                         if(!setUniqueName.isEmpty()){
                             List<Material__c> lstCheckMTDesc = [Select id,name,Total_Item_Qty__c  from Material__c where name in:setUniqueName and Material_Status__c != 'Sent Back']; //added sent back status for usst-2386
                             
                             System.Debug('check list values '+lstCheckMTDesc );
                             
                             if(!lstCheckMTDesc.isEmpty()){
                                 for(Material__c mt : lstCheckMTDesc){
                                     if(!setDuplicateName.contains(mt.name)){
                                         setDuplicateName.add(mt.name);
                                     }
                                 }
                             }
                         }  
                         System.Debug('check unique name @@@ '+setUniqueName);
                        System.Debug('check duplicate name @@@ '+setDuplicateName); 

                        if(setDuplicateName.isEmpty()){
                             TriggerUtility.checkFromTemplate = TRUE;
                             system.debug('lstMaterialRecords :: '+lstMaterialRecords );
                             insert lstMaterialRecords;   
                             isInsertedMT = TRUE;
                             System.Debug('entry here 3');
                         }
                         else{
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Records with duplicate material description found: '+setDuplicateName));
                             hasException = TRUE;
                             exceptionMessage = 'Records with duplicate material description found: '+setDuplicateName; 
                             setDuplicateName = new Set<string>();
                             setUniqueName = new Set<string>();     
                             System.debug('entry here 4');                 
                         }
                     }
                 }
                                
             }
             
         }catch(exception ex){
             clearMaterialDetails();
             lstMaterialRecords = new List<Material__c>();
             lstBOMItem = new List<BOM_Item__c>();
             updateableParentMats = new List<Material__c>();
             insertableReleaseMaterials = new List<Release_Material__c>();
             System.debug('entry in catch');
             Database.rollback(sp);
             
             ApexPages.addmessages(ex);
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         } 
     }
     
     // Following method is responsible to populate Label Code in Components based on its parent FERT. 
     private void populateLabelCodesInComponents(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {
             if(mat.instance.Label_Code__c != null)
             {
                 // populate label code.
                 if(mat.childComponents.size() > 0)
                 {
                     for(MaterialComponentWrapper comp : mat.childComponents)
                     {
                         comp.instance.Label_Code__c = mat.instance.Label_Code__c;
                     }
                 }
             }
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             populateLabelCodesInComponents(nextLevelMaterials);
     }
     
     /**********************************************************************************************************
     REL-17
     Method Name: populateMPMInComponents
     Purpose : method is responsible to populate MPM in Components based on its parent FERT if requester is PHE.
     ************************************************************************************************************/
     private void populateMPMInComponents(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
                 
         for(MaterialFERTWrapper mat : processingMaterials)
         {
             if(mat.instance.MPM_Issue__c != null && mat.instance.Item_Type__c != D_ITEM_TYPE)
             {
                 // populate MPM.
                 if(mat.childComponents.size() > 0)
                 {
                     for(MaterialComponentWrapper comp : mat.childComponents)
                     {
                         if(String.isBlank(comp.instance.MPM_Issue__c))
                         {
                             comp.instance.MPM_Issue__c = mat.instance.MPM_Issue__c;
                         }
                     }
                 }
             }
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             populateMPMInComponents(nextLevelMaterials);
     }
     
     /*****************************************************************
     Method Name: prepareBOMItems
     Purpose : prepare BOM Item
     ***************************************************************/
     @testVisible private void prepareBOMItems(List<MaterialFERTWrapper> operatingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         for(MaterialFERTWrapper matWrapper : operatingMaterials)
         {
             matFERTIds.add(matWrapper.instance.Id);
             
             if(!matWrapper.isExisting && matWrapper.isExistingRecord && releaseDetails != null && releaseDetails.Id != null)/* DF-02183 - commenting this condition to allow addition of same material to the release again after removing it.*/
             {
                Release_Material__c relMat = new Release_Material__c();
                relMat.Material__c = matWrapper.instance.Id;
                relMat.Release__c = releaseDetails.Id;
                
                insertableReleaseMaterials.add(relMat);
             }
             
             if(matWrapper.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                 {
                     System.debug('*****childMat> '+childMat);
                     if(!childMat.isExisting)
                     {
                         BOM_Item__c objBOM = new BOM_Item__c();
                         objBOM.Material__c= matWrapper.instance.Id;
                         objBOM.Material_Component__c= childMat.instance.Id;
                         objBOM.Territory__c = matWrapper.instance.Territory__c; 
                         objBOM.Component_Quantity__c = string.valueof(childMat.componentQty.setScale(3));
                         objBOM.BOM_Quantity__c= childMat.componentQty;
                         
                         lstBOMItem.add(objBOM);
                     }else{
                         if(childMat.componentQty != childMat.componentQtyActual){
                             updateableBOMItemList.add(new Bom_Item__c(ID=childMat.bomItemId,Component_Quantity__c= string.valueof(childMat.componentQty.setScale(3)),BOM_Quantity__c= childMat.componentQty));
                         }
                     }
                     // If current child material is a new record, update its primary parent as current parent record.
                     if(!childMat.isExistingRecord)
                     {
                         Material__c cMat = new Material__c(Id=childMat.instance.Id, Component_Material__c=matWrapper.instance.Id);
                         updateableParentMats.add(cMat);
                     }
                     
                     nextLevelMaterials.add(childMat);
                 }
             }
             
             if(matWrapper.childComponents.size() > 0)
             {
                 for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                 {
                     System.debug('*****childComp> '+childComp);
                     if(!childComp.isExisting)
                     {
                         BOM_Item__c objBOM = new BOM_Item__c();
                         objBOM.Material__c= matWrapper.instance.Id;
                         objBOM.Material_Component__c= childComp.instance.Id;
                         objBOM.Territory__c = matWrapper.instance.Territory__c; 
                         objBOM.Component_Quantity__c = string.valueof(childComp.componentQty.setScale(3));
                         objBOM.BOM_Quantity__c= childComp.componentQty;
                         lstBOMItem.add(objBOM);
                     }else{
                         if(childComp.componentQty != childComp.componentQtyActual){
                             updateableBOMItemList.add(new Bom_Item__c(ID=childComp.bomItemId,Component_Quantity__c= string.valueof(childComp.componentQty.setScale(3)),BOM_Quantity__c= childComp.componentQty));
                         }
                     }
                    // If current child material is a new record, update its primary parent as current parent record.
                     if(!childComp.isExistingRecord)
                     {
                         Material__c cMat = new Material__c(Id=childComp.instance.Id, Component_Material__c=matWrapper.instance.Id);
                         updateableParentMats.add(cMat);
                     }                   
                                        
                     //storing ROH ID and BOM Qty in a map for use in link component
                     if(!mapBOMQty.containsKey(childComp.instance.Id)){
                         mapBOMQty.put(childComp.instance.Id,string.valueof(childComp.componentQty.setScale(3)));
                     }
                     
                     // If material is existing record and has separate Release.
                     if(!childComp.isExisting && childComp.isExistingRecord && releaseDetails != null && releaseDetails.Id != null)/* DF-02183 - commenting this condition to allow addition of same material to the release again after removing it.*/
                     {
                         Release_Material__c relMat = new Release_Material__c();
                         relMat.Material__c = childComp.instance.Id;
                         relMat.Release__c = releaseDetails.Id;
                         
                         insertableReleaseMaterials.add(relMat);
                     }
                     
                     if(childComp.instance.Association_Required__c){
                         matROHIds.add(childComp.instance.Id);
                         checkLinkComponents = TRUE;
                     }    
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             prepareBOMItems(nextLevelMaterials);
     }
     
     /*****************************************************************
     Method Name: getSelectedMat
     Purpose : Calling apex method to get selected Material
     ***************************************************************/
     public void getSelectedMat()
     {
          Map<String,String> itemQtyMap=new Map<String,String>();
         if(Cache.Session.contains('selectedMat')){
             List<Material__c> selectedMatList = New List<Material__c>();
             selectedMatList = (List<Material__c>)cache.session.get('selectedMat');
             cache.session.remove('selectedMat');
             
              //REL-18 Mass upload of quantity. 
             if(Cache.session.contains('matQtyMap')){
                 itemQtyMap=(Map<String,String>)cache.session.get('matQtyMap');
                 cache.session.remove('matQtyMap');
             }
         
             
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
             
             if(materialType == 'COMPONENT' && selectedMatList != null && selectedMatList.size() > 0){
                 if(ins != null)
                 {
                     for(Material__c mat : selectedMatList){
                         MaterialComponentWrapper comp = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
                         comp.instance = mat;
                         
                          //REL-18 Mass upload of quantity.
                         if(itemQtyMap!=null &&  itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){ 
                             comp.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                        }
                         else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                             notUploadable=true;
                         }
                         
                         ins.childComponents.add(comp);
                     }
                 }
                 else
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Error: Component(s) cannot be added in root level.'));
                 }
             }
             else if(materialType == 'FERT' && selectedMatList != null && selectedMatList.size() > 0){
                 showChildMaterialSection = TRUE;
                 string tempSEGNNO = null;
                 ID titleID ;
                 
                 //setting default title
                 if(releaseDetails != null && string.valueof(releaseDetails.Title__c)!='' && string.valueof(releaseDetails.Title__c)!= null){
                     Title__c titleDetails = [Select id,name,SGENNO__c from Title__c where id=:releaseDetails.Title__c];
                     tempSEGNNO = titleDetails.SGENNO__c;
                     titleID = titleDetails.ID;
                 }
                 for(Material__c mat : selectedMatList){
                     MaterialFERTWrapper existingMat = new MaterialFERTWrapper(titleID, tempSEGNNO,u.Profile.Name);
                     existingMat.instance = mat;
                     
                     //REL-18 Mass upload of quantity.
                      if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){
                         existingMat.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                      }
                      else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                          notUploadable=true;
                      }
                     
                     if(addToTop == 'TRUE' || ins == null){
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = 1;
                         rootFERTs.add(existingMat);
                         rootIns.lastPage();
                     }else{
                         //adding child material row for a parent material
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = ins.levelOfDepth + 1;
                         ins.childFERTs.add(existingMat);  
                         ins.childIns.lastPage();
                    }
                 }
             }
         }
         else if(Cache.Session.contains('selectedTitleMat')){
             List<Material__c> selectedTitleMatList = New List<Material__c>();
             selectedTitleMatList = (List<Material__c>)cache.session.get('selectedTitleMat');
             System.debug('-----selectedTitleMatList> '+selectedTitleMatList);
             cache.session.remove('selectedTitleMat');
             
             
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
             
             if(materialType == 'COMPONENT' && selectedTitleMatList != null && selectedTitleMatList.size() > 0){
                 if(ins != null)
                 {
                     for(Material__c mat : selectedTitleMatList){
                         MaterialComponentWrapper comp = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
                         comp.instance = mat;
                         
                         //REL-18 Mass upload of quantity.
                         if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){
                             comp.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                         }
                         else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                          notUploadable=true;
                         }
                         ins.childComponents.add(comp);
                     }
                 }
                 else
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Error: Component(s) cannot be added in root level.'));
                 }
             }
             else if(materialType == 'FERT' && selectedTitleMatList != null && selectedTitleMatList.size() > 0){
                 showChildMaterialSection = TRUE;
                 string tempSEGNNO = null;
                 ID titleID ;
                 
                 //setting default title
                 if(releaseDetails != null && string.valueof(releaseDetails.Title__c)!='' && string.valueof(releaseDetails.Title__c)!= null){
                     Title__c titleDetails = [Select id,name,SGENNO__c from Title__c where id=:releaseDetails.Title__c];
                     tempSEGNNO = titleDetails.SGENNO__c;
                     titleID = titleDetails.ID;
                 }
                 for(Material__c mat : selectedTitleMatList){
                     MaterialFERTWrapper existingMat = new MaterialFERTWrapper(titleID, tempSEGNNO,u.Profile.Name);
                     existingMat.instance = mat;
                     
                     
                     //REL-18 Mass upload of quantity.
                     if(itemQtyMap!=null  && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){
                         existingMat.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                     }
                     else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                          notUploadable=true;
                     }
                     if(ins != null)
                     {
                         //adding child material row for a parent material
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = ins.levelOfDepth + 1;
                         ins.childFERTs.add(existingMat);
                         ins.childIns.lastPage();
                     }
                     else
                     {
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = 1;
                         rootFERTs.add(existingMat);
                         rootIns.lastPage();
                     }
                 }
             }
         }
         if(Cache.Session.contains('selectedTitleNewMat')){
             List<Material__c> selectedTitleNewMatList = New List<Material__c>();
             selectedTitleNewMatList = (List<Material__c>)cache.session.get('selectedTitleNewMat');
             System.debug('-----selectedTitleNewMatList> '+selectedTitleNewMatList);
             cache.session.remove('selectedTitleNewMat');
             
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
             
             if(materialType == 'COMPONENT' && selectedTitleNewMatList != null && selectedTitleNewMatList.size() > 0){
                 if(ins != null)
                 {
                     for(Material__c mat : selectedTitleNewMatList){
                         MaterialComponentWrapper comp = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
                         comp.instance = mat;
                         
                         //REL-18 Mass upload of quantity.
                         if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){
                             comp.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                         }
                         else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                           notUploadable=true;
                         }
                         ins.childComponents.add(comp);
                     }
                 }
                 else
                 {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Error: Component(s) cannot be added in root level.'));
                 }
             }
             else if(materialType == 'FERT' && selectedTitleNewMatList != null && selectedTitleNewMatList.size() > 0){
                 showChildMaterialSection = TRUE;
                 string tempSEGNNO = null;
                 ID titleID ;
                 
                 //setting default title
                 if(releaseDetails != null && string.valueof(releaseDetails.Title__c)!='' && string.valueof(releaseDetails.Title__c)!= null){
                     Title__c titleDetails = [Select id,name,SGENNO__c from Title__c where id=:releaseDetails.Title__c];
                     tempSEGNNO = titleDetails.SGENNO__c;
                     titleID = titleDetails.ID;
                 }
                 for(Material__c mat : selectedTitleNewMatList){
                     MaterialFERTWrapper existingMat = new MaterialFERTWrapper(titleID, tempSEGNNO,u.Profile.Name);
                     existingMat.instance = mat;
                     
                     //REL-18 Mass upload of quantity.
                     if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c=='D (Display Vehicle)'){
                         existingMat.componentQty= Double.valueOf(itemQtyMap.get(mat.material_number__c));
                     }
                     else if(itemQtyMap!=null && itemQtyMap.containskey(mat.material_number__c) && ins.instance.item_type__c!='D (Display Vehicle)'){
                          notUploadable=true;
                     }
                     
                     if(ins != null)
                     {
                         //adding child material row for a parent material
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = ins.levelOfDepth + 1;
                         ins.childFERTs.add(existingMat);
                         ins.childIns.lastPage();
                     }
                     else
                     {
                         existingMat.wizardType = wizardType;
                         existingMat.levelOfDepth = 1;
                         rootFERTs.add(existingMat);
                         rootIns.lastPage();
                     }
                 }
             }
         }
         addToTop = 'FALSE';
        
         //REL-18 show error  if the material is different type
         System.debug('notUploadable---->'+notUploadable);
         if(notUploadable){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'Mass upload of item quantities only allowed for materials under Display Vehicles'));
         }
         
     }
     
     private Map<Id, MaterialFERTWrapper> materialWrapperMap = new Map<Id, MaterialFERTWrapper>();
     private Map<Id, Set<Id>> materialChildMap = new Map<Id, Set<Id>>();
     private Set<Id> processedMatIds = new Set<Id>();
     private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
     
     /*****************************************************************
     Method Name: getExistingBOMTree
     Purpose : get the material tree structure
     ***************************************************************/
     private void getExistingBOMTree()
     {
         Set<Id> associatedMaterialIds = new Set<Id>();
         Set<Id> releaseMaterialsIds = new Set<Id>();
         if(pageParameters.get('source').equalsIgnoreCase('ReleaseDetail'))
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
             
             for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c
                                    FROM BOM_Item__c 
                                    WHERE Material__c IN :relMatIds.keySet() AND Material_Component__c IN :relMatIds.keySet()])
             {
                 if(relMatIds.containsKey(bom.Material_Component__c))
                     relMatIds.put(bom.Material_Component__c, false);
             }
             
             for(Id matId : relMatIds.keySet())
             {
                 if(relMatIds.get(matId))
                     associatedMaterialIds.add(matId);
             }
         }
         else if(pageParameters.get('source').equalsIgnoreCase('MaterialDetail'))
         {
             associatedMaterialIds.add(materialID);
         }
         System.debug('----associatedMaterialIds> '+associatedMaterialIds);
         
         fetchCompleteBOMHierarchy(associatedMaterialIds,releaseMaterialsIds);
         for(Id matId : associatedMaterialIds)
         {
             if(materialWrapperMap.containsKey(matId))
             {
                 materialWrapperMap.get(matId).wizardType = wizardType;
                 materialWrapperMap.get(matId).levelOfDepth = 1;
             }
         }
         prepareCompleteBOMHierarchy(associatedMaterialIds,releaseMaterialsIds);
         
         for(Id matId : associatedMaterialIds)
             rootFERTs.add(materialWrapperMap.get(matId));
     }
     
     /*****************************************************************
     Method Name: prepareCompleteBOMHierarchy
     Purpose : Calling apex method to prepare BOM Hierarchy
     ***************************************************************/
     private void prepareCompleteBOMHierarchy(Set<Id> processingMaterialIds,Set<Id> releaseMaterialsIds)
     {
         Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
         for(Id matId : processingMaterialIds)
         {
             if(materialChildMap.containsKey(matId) && materialChildMap.get(matId).size() > 0)
             {
                  //adding all key id to a set for using in recursive call
                 if(releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || releaseMaterialsIds.contains(matId)){
                     nextLevelProcessingMaterialIds.addAll(materialChildMap.get(matId));
                 }
                 
                 for(Id childMatId : materialChildMap.get(matId))
                 {
                      if(materialWrapperMap.get(matId) != null && materialWrapperMap.get(childMatId) != null && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                        releaseMaterialsIds.contains(childMatId))){
                         MaterialFERTWrapper matIns = materialWrapperMap.get(childMatId);
                         matIns.parentMaterialId = matId;
                         if(parentChildBOMMap.containsKey(matId) && parentChildBOMMap.get(matId).containsKey(childMatId)){
                             matIns.bomItemId = parentChildBOMMap.get(matId).get(childMatId);
                             
                         }    
                         matIns.wizardType = wizardType;
                         matIns.levelOfDepth = materialWrapperMap.get(matId).levelOfDepth + 1;    
                         materialWrapperMap.get(matId).childFERTs.add(matIns);
                         //setting component qty
                         if(mapItemQty.get(childMatId) != null){
                             materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].componentQty = Decimal.valueof(mapItemQty.get(childMatId));
                             materialWrapperMap.get(matId).childFERTs[materialWrapperMap.get(matId).childFERTs.size()-1].componentQtyActual = Decimal.valueof(mapItemQty.get(childMatId));
                             
                             
                         }
                     }
                 }
             }
         }
         
         if(nextLevelProcessingMaterialIds.size() > 0)
             prepareCompleteBOMHierarchy(nextLevelProcessingMaterialIds,releaseMaterialsIds);
     }
     
     Map<Id, Map<Id, Id>> parentChildBOMMap = new Map<Id, Map<Id, Id>>();
     /*****************************************************************
     Method Name: fetchCompleteBOMHierarchy
     Purpose : Calling apex method to fetch BOM Hierarchy
     ***************************************************************/
     private void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds,Set<Id> releaseMaterialsIds)
     {
         Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
         Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
         // Changed for RE-17
         for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Material_Component__r.Item_Type__c,Material_Component__r.SGENNO__c,Valid_to__c,
                                 Material_Component__r.Component_Type__c, Material_Component__r.Name, Material_Component__r.Release__c, Material_Component__r.Material_Number__c, Material_Component__r.Total_Item_Qty__c,
                                 Material_Component__r.Count_Sales_for_D_Chain_Status__c, Material_Component__r.BOM_Status__c, Component_Quantity__c, Material_Component__r.MPM_Issue__c,Material_Component__r.Sales_Planning_Group__c,Material_Component__r.Subformat__c,Material_Component__r.Material_Status__c,
                                 Material_Component__r.Territory__c, Material_Component__r.Label_Code__c, Material_Component__r.Sub_Label_Code_Lookup__c, Material_Component__r.Component_Material__c  
                                 FROM BOM_Item__c
                                 WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                     Material_Component__c NOT IN :processedMatIds AND Material_Component__c != null AND 
                                     Material_Component__r.Deletion_Flag__c=false AND (BOM_Function__c != '003' AND Deletion_Flag__c=false)])//2636 
         {
             if(!matBomMap.containsKey(bom.Material__c))
                 matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
             matBomMap.get(bom.Material__c).add(bom);
         }
         
         // Fetch the child materials from BOM Items. // Changed for RE-17
         for(Material__c mat : [SELECT Id, Name, Item_Type__c, Item_Code__c, Title__c, Title__r.SGENNO__c, Format_Description__c, Sub_Label_Code_Lookup__c, Total_Item_Qty__c,
                                Material_Type__c, Retailer_Rental__c, BOM_Quantity__c, Component_Type__c, Territory__c,Release__c, Material_Number__c, Component_Material__c,
                                Count_Sales_for_D_Chain_Status__c, BOM_Status__c,MPM_Issue__c,Sales_Planning_Group__c,Subformat__c,Label_Code__c, Material_Status__c, SGENNO__c, Material_Expiration_Date__c  
                                FROM Material__c
                                WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes]) //USST-2960
         {
             processedMatIds.add(mat.Id);
             
             if(!materialChildMap.containsKey(mat.Id))
                 materialChildMap.put(mat.Id, new Set<Id>());
             if(!parentChildBOMMap.containsKey(mat.Id))
                 parentChildBOMMap.put(mat.Id, new Map<Id, Id>());
             
             MaterialFERTWrapper matIns = new MaterialFERTWrapper(null, '',u.Profile.Name);
             matIns.instance = mat;
             matIns.isExisting = true;
             if(mat.Title__c != null)
                 matIns.sysgenNo = mat.Title__r.SGENNO__c;
             
             if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
             {   
                 //Looping over related BOM Item records
                 for(BOM_Item__c bom : matBomMap.get(mat.Id))
                 {
                     // If it is a component material.
                     if(childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c) && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                     releaseMaterialsIds.contains(bom.Material_Component__c)))
                     {
                         MaterialComponentWrapper comp = new MaterialComponentWrapper(localCompId ++,u.Profile.Name);
                         comp.instance.Id = bom.Material_Component__c;
                         comp.instance.Name = bom.Material_Component__r.Name;
                         comp.instance.Material_Type__c = bom.Material_Component__r.Material_Type__c;
                         comp.instance.Component_Type__c = bom.Material_Component__r.Component_Type__c;
                         comp.instance.Association_Required__c = false;
                         comp.instance.Release__c = bom.Material_Component__r.Release__c;
                         comp.instance.BOM_Status__c = bom.Material_Component__r.BOM_Status__c;
                         comp.instance.Item_Type__c = bom.Material_Component__r.Item_Type__c;
                         comp.instance.Label_Code__c = bom.Material_Component__r.Label_Code__c;
                         comp.instance.Material_Number__c = bom.Material_Component__r.Material_Number__c;
                         comp.instance.Sub_Label_Code_Lookup__c = bom.Material_Component__r.Sub_Label_Code_Lookup__c;
                         comp.instance.Component_Material__c = bom.Material_Component__r.Component_Material__c;
                         if(bom.Material_Component__r.Count_Sales_for_D_Chain_Status__c > 0)
                             comp.hasDChainFR = true;
                         comp.isExisting = true;
                         comp.isExistingRecord = true;
                         comp.bomItemId = bom.Id;
                         comp.parentMaterialId = bom.Material__c;
                         if(bom.Component_Quantity__c != null){
                             comp.componentQty = Decimal.valueof(bom.Component_Quantity__c);
                             comp.componentQtyActual = Decimal.valueof(bom.Component_Quantity__c);
                         }
                        
                         if(showMPM){
                           comp.instance.MPM_Issue__c = bom.Material_Component__r.MPM_Issue__c;
                           comp.instance.Sales_Planning_Group__c = bom.Material_Component__r.Sales_Planning_Group__c;
                           comp.instance.Subformat__c = bom.Material_Component__r.Subformat__c;
                         }
                         
                         comp.instance.Material_Status__c = bom.Material_Component__r.Material_Status__c;
                         comp.instance.Territory__c = bom.Material_Component__r.Territory__c;
                         matIns.childComponents.add(comp);
                     }
                     // If FERT material not previously processed.
                     else if(!processedMatIds.contains(bom.Material_Component__c) && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                             releaseMaterialsIds.contains(bom.Material_Component__c)))
                     {
                         nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                         materialChildMap.get(mat.Id).add(bom.Material_Component__c);
                         parentChildBOMMap.get(mat.Id).put(bom.Material_Component__c, bom.Id);
                          //mapping child FERT and Component Qty
                         mapItemQty.put(bom.Material_Component__c,bom.Component_Quantity__c);
                        
                     }
                 }
             }
             
             materialWrapperMap.put(mat.Id, matIns);
         }
         
         if(nextLevelProcessingMaterialIds.size() > 0)
             fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds,releaseMaterialsIds);
     }
     
     /*****************************************************************
     Method Name: setMaterialDefault
     Purpose : Calling apex method to default values for material record
     ***************************************************************/
     public void setMaterialDefault(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             TriggerUtility.checkFromTemplate = TRUE;
             //Inserting release record only for new scenario
             if(showReleaseNew && releaseDetails != null && releaseDetails.id==null){
                 insert releaseDetails;  
             }
             
             for(Material__c mt : lstMaterialRecords){
                 system.debug('lstMaterialRecords : '+lstMaterialRecords);
                 if(releaseDetails != null)
                 {
                     mt.Release__c = releaseDetails.id;
                 }
             }
             
             TriggerUtility.CheckFromTemplate = TRUE;
             DefaultingHandler.processingMaterials = lstMaterialRecords;
             DefaultingHandler.fetchCompleteDefaultData();
             DefaultingHandler.populateMaterialDefaultValues();
         }
         catch(exception ex){
             Database.rollback(sp);  
             System.debug('entry in catch');          
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }
     }
     
     /*****************************************************************
     Method Name: createBOMItem
     Purpose : calling apex method for creating BOM Item record
     ***************************************************************/
     public void createBOMItem(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
            if(!hasException){
                 lstBOMItem = new List<BOM_Item__c>();
                 insertableReleaseMaterials = new List<Release_Material__c>(); 
                 matFERTIds = new Set<Id>();
                 matROHIds = new Set<Id>();
                 
                 prepareBOMItems(rootFERTs);
                 TriggerUtility.checkFromTemplate = TRUE;
                 

                 if(lstBOMItem.size() > 0){
                     insert lstBOMItem;
                     isInsertedBI = TRUE;
                 }    
                 
                 // Added for REL-104
                 Set<Id> rootMatIds = new Set<Id>();
                 for(MaterialFERTWrapper mat : rootFERTs)
                 {
                     if(mat.instance.Id != null && mat.instance.Item_Type__c == D_ITEM_TYPE && mat.childFERTs.size() > 0)
                     {
                         rootMatIds.add(mat.instance.Id);
                     }
                 }
                 // recalculate the RSU asynchronously.
                 if(rootMatIds.size() > 0)
                 {
                     RSUCalculationHandler.updateMaterialTreeAsync(rootMatIds, false);
                 }
                 
                 if(insertableReleaseMaterials.size() > 0){
                     insert insertableReleaseMaterials;
                     isInsertedRM = TRUE;
                 }
             }           
         }
         catch(exception ex){
             lstMaterialRecords = new List<Material__c>();
             lstBOMItem = new List<BOM_Item__c>();
             insertableReleaseMaterials = new List<Release_Material__c>();
             System.debug('entry in catch');
             
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }   
     }
     
     /*****************************************************************
     Method Name: createSalesRecord
     Purpose : calling apex method for creating sales record
     ***************************************************************/
     public void createSalesRecord(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             if(!hasException){
                 TriggerUtility.checkFromTemplate = TRUE;
                 TriggerUtility.checkNotFromChild = FALSE;
                 DefaultingHandler.processingMaterials = lstMaterialRecords;
                 DefaultingHandler.fetchCompleteDefaultData();
                 DefaultingHandler.populateSalesDefaultValues(); 
             }           
         }
         catch(exception ex){
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }   
     }
     
     /*****************************************************************
     Method Name: createPlantRecord
     Purpose : calling apex method for creating plant record
     ***************************************************************/
     public void createPlantRecord(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             if(!hasException){
                 TriggerUtility.checkFromTemplate = TRUE;
                 TriggerUtility.checkNotFromChild = FALSE;
                 DefaultingHandler.processingMaterials = lstMaterialRecords;
                 DefaultingHandler.fetchCompleteDefaultData();
                 DefaultingHandler.populatePlantDefaultValues(); 
             }
         }
         catch(exception ex){
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }           
     }
     
     /*****************************************************************
     Method Name: createClassificationRecord
     Purpose : Calling apex method for creating classification record
     ***************************************************************/
     public void createClassificationRecord(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             if(!hasException){
                 TriggerUtility.checkFromTemplate = TRUE;
                 TriggerUtility.checkNotFromChild = FALSE;
                 DefaultingHandler.processingMaterials = lstMaterialRecords;
                 DefaultingHandler.fetchCompleteDefaultData();
                 DefaultingHandler.populateClassificationDefaultValues();
             }
         }
         catch(exception ex){
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }
     }
     
     /*****************************************************************
     Method Name: createAUoMRecord
     Purpose : Calling apex method to create alternative unit if measure record
     ***************************************************************/
     public void createAUoMRecord(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             if(!hasException){
                 TriggerUtility.checkFromTemplate = TRUE;
                 TriggerUtility.checkNotFromChild = FALSE;
                 DefaultingHandler.processingMaterials = lstMaterialRecords;
                 DefaultingHandler.fetchCompleteDefaultData();
                 DefaultingHandler.populateAUoMDefaultValues();
             }
         }
         catch(exception ex){
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }
     }
     
     /*****************************************************************
     Method Name: createValuationRecord
     Purpose : Calling apex method to create valuation record
     ***************************************************************/
     public void createValuationRecord(){
         Savepoint sp = Database.setSavepoint();
         try{
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }
             
             if(!hasException){
                 TriggerUtility.checkFromTemplate = TRUE;
                 TriggerUtility.checkNotFromChild = FALSE;
                 DefaultingHandler.processingMaterials = lstMaterialRecords;
                 DefaultingHandler.fetchCompleteDefaultData();
                 DefaultingHandler.populateValuationDefaultValues(); 
             }
         }
         catch(exception ex){
             Database.rollback(sp);
             System.debug('entry in catch');
             hasException = TRUE;
             exceptionMessage = ex.getMessage();
         }
     }
     
     /*****************************************************************
     Method Name: redirectUserAndSetQueue
     Purpose : Calling apex method to default values for material record
     ***************************************************************/
     public pageReference redirectUserAndSetQueue(){
         Savepoint sp = Database.setSavepoint();
         try{      
             
             if(Test.isRunningTest() && negativeScearioTesting){
                 integer i =1/0;
             }      
             
             if(!hasException){
                     
                     // Deleting Existing removed BOM Items
                     if(deleteableBOMItemList.size() > 0)
                     {
                         Database.delete(deleteableBOMItemList, false);
                     }
                     
                     // Updating Existing Materials
                     if(updateableParentMaterialList.size() > 0)
                     {
                         Database.update(updateableParentMaterialList, false);
                          Database.update(updateableAUoMList, false);
                     }
                     
                     // Updating Existing BOM items
                     if(updateableBOMItemList.size() > 0)
                     {
                         Database.update(updateableBOMItemList, false);
                     }
                         
                     if(updateableParentMats != null && !updateableParentMats.isEmpty())
                     {
                         TriggerUtility.doNotExecute = TRUE;
                         update updateableParentMats;
                         TriggerUtility.doNotExecute = FALSE;
                     }
                 
                     Set<ID> setMatID = new Set<ID>();
                     For(Material__c matID : lstMaterialRecords){
                         setMatID.add(matID.ID);
                     }
                     
                     SetAdditionaMateriallDefaults instanceDefaults1 = new SetAdditionaMateriallDefaults();
                     instanceDefaults1.materialID = setMatID;
                     // Added for RE-190
                     instanceDefaults1.initiatedFromWizard = TRUE;
                     System.enqueueJob(instanceDefaults1);
                     
                     SetAdditionalSalesDefaults instanceDefaults2 = new SetAdditionalSalesDefaults();
                     instanceDefaults2.materialID = setMatID;
                     System.enqueueJob(instanceDefaults2);
                     
                     SetAdditionalPlantDefaults instanceDefaults3 = new SetAdditionalPlantDefaults();
                     instanceDefaults3.materialID = setMatID;
                     System.enqueueJob(instanceDefaults3);
                     
                     SetAdditionalOtherDefaults instanceDefaults4 = new SetAdditionalOtherDefaults();
                     instanceDefaults4.materialID = setMatID;
                     System.enqueueJob(instanceDefaults4);
             
                     pagereference pg;
                     //if link component required
                     if(checkLinkComponents == TRUE){
                         Cache.Session.put('fertID', matFERTIds);
                         Cache.Session.put('rohID', matROHIds);
                         Cache.Session.put('bomQty', mapBOMQty);
                         
                         if(releaseDetails != null && releaseDetails.id != null){
                             pg = new pageReference('/apex/LinkComponents?rid='+releaseDetails.id+'&retURL='+pageParameters.get('retURL'));
                         }
                         else{
                             pg = new pageReference('/apex/LinkComponents?mid='+rootFERTs[0].instance.id+'&retURL='+pageParameters.get('retURL'));
                         }
                     }
                     else{
                         System.Debug('Check entry in else');
                         if(pageParameters.get('source').equalsIgnoreCase('TitleDetail') || pageParameters.get('source').equalsIgnoreCase('ReleaseDetail') || pageParameters.get('source').equalsIgnoreCase('releaselistview'))
                             pg = new pageReference('/'+releaseDetails.id);
                         else if(pageParameters.get('source').equalsIgnoreCase('MaterialDetail'))
                             pg = new pageReference('/'+materialDetails.id);
                         else if(pageParameters.get('source').equalsIgnoreCase('materiallistview'))
                             pg = new pageReference('/'+rootFERTs[0].instance.id);
                         else if(pageParameters.containsKey('retURL'))
                             pg = new pageReference(pageParameters.get('retURL'));
                         else
                             pg = new pageReference('/home/home.jsp');
                     }
                     
                     //redirecting user to release record created            
                     pg.setRedirect(true);
                     return pg;
             }else{
                 
                 if(insertableReleaseMaterials != null && !insertableReleaseMaterials.isEmpty() && isInsertedRM){
                     delete insertableReleaseMaterials;
                     isInsertedRM = FALSE;
                 }
                 
                 if(releaseDetails != null && releaseDetails.ID != null){
                     List<Release_Material__c> lstRMDelete = [Select id from Release_Material__c where Material__c in:lstMaterialRecords and Release__c =: releaseDetails.ID];
                     
                     if(!lstRMDelete.isEmpty()){
                         delete lstRMDelete;
                         isInsertedRM = FALSE;
                     }
                 }               
                 
                 if(lstBOMItem != null && !lstBOMItem.isEmpty() && isInsertedBI){
                     delete lstBOMItem;
                     isInsertedBI = FALSE;
                 }                
                 
                 if(lstMaterialRecords != null && !lstMaterialRecords.isEmpty() && isInsertedMT){
                     System.Debug('list records '+lstMaterialRecords);
                     delete lstMaterialRecords;
                     isInsertedMT = FALSE;
                 }
                 
                 if(releaseDetails != null && releaseDetails.ID != null && releaseType == 'New'){
                     delete releaseDetails;
                     releaseDetails.id=null;
                 }                   
                 
                 lstMaterialRecords = new List<Material__c>();
                 lstBOMItem = new List<BOM_Item__c>();
                 updateableParentMats = new List<Material__c>();
                 
                 if(lstTempMaterial!= null && !lstTempMaterial.isEmpty()){
                     lstMaterialRecords.clear();
                     resetMaterialList(rootFERTs);
                 }
                 
                 setDuplicateName = new Set<string>();
                 setUniqueName = new Set<string>();
                                 
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Error: ' +getFormattedErrorMessage( exceptionMessage))); //USST-2675
                 hasException = FALSE;
                 exceptionMessage = '';
                 return null;            
             }
         }
         catch(exception ex){
             if(releaseDetails != null)
                 releaseDetails.id=null;
             lstMaterialRecords = new List<Material__c>();
             lstBOMItem = new List<BOM_Item__c>();
             updateableParentMats = new List<Material__c>();
             insertableReleaseMaterials = new List<Release_Material__c>();
             Database.rollback(sp);
             
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system administrator. ' + ex.getMessage()));  
             hasException = FALSE;  
             exceptionMessage = ''; 
             return null; 
         }   
         
     }
     /*****************************************************************
     Method Name: getFormattedErrorMessage
     Purpose : Method to format validation message caused via DML operation (USST-2675)
     ***************************************************************/
     
    public static String getFormattedErrorMessage( String incomingMsg ) {
        String msg = incomingMsg;               
        if ( msg != null && msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
             String errorMessage = msg;
             Integer cutPoint = msg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34;
             errorMessage = msg.substring(cutPoint);
             errorMessage = String.escapeSingleQuotes(errorMessage);
             errorMessage = errorMessage.replace('&quot;','\'');
             errorMessage = errorMessage.replace('&lt;','<');
             cutPoint = errorMessage.indexOf(': [');
             if ( errorMessage.length() > cutPoint ) {
                  
                 msg = errorMessage.subString(0,cutPoint); 
                 system.debug('msg'+msg);
             }
        } 
        return msg; 
    }
     /*****************************************************************
     Method Name: setTerritoryDetails
     Purpose : set territory on materials
     ***************************************************************/
     public void setTerritoryDetails()
     {
         if(!rootFERTs.isEmpty()){
             getHierarchy(rootFERTs);
         }
         
     }
     
     
     /*****************************************************************
     Method Name: setTerritoryDetails
     Purpose : set territory on materials
     ***************************************************************/
     public void getHierarchy(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         String tempName;
         Integer intCounter = 1;
         
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {   
             //initializing counter to 1
             intCounter = 1;
             
             if(mat.instance.Id == null)
             {
                 if(releaseDetails != null){
                     mat.instance.Territory__c = releaseDetails.Territory__c;
                 }                
             }
             else{
                 if(releaseDetails != null && releaseDetails.Territory__c != mat.instance.Territory__c){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please remove the existing record with a different territory.'));
                 }               
             }
             
             // Iterate over child components
             for(MaterialComponentWrapper comp : mat.childComponents)
             {
                 if(releaseDetails != null && comp.instance.Id == null){
                     comp.instance.Territory__c = releaseDetails.Territory__c;
                 }  
                 else{
                     if(releaseDetails != null && releaseDetails.Territory__c != comp.instance.Territory__c){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please remove the existing record with a different territory.'));
                     }               
                 }
             }
             
             // Iterate over child materials
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }           
         
         if(nextLevelMaterials.size() > 0)
             getHierarchy(nextLevelMaterials);
     }
     
     /*****************************************************************
     Method Name: clearMaterialDetails
     Purpose : to clear material details
     ***************************************************************/
     private void clearMaterialDetails(){
         if(!lstMaterialRecords.isEmpty()){
             For(Material__c mat : lstMaterialRecords){
                 if(mat.ID != null){
                     mat.ID = null;
                 }
             }
         }
     }
     
     /*****************************************************************
     Method Name: setSubLabelCode
     Purpose : to set sub label code based on label code of material 
     ***************************************************************/
     public void setSubLabelCode(){
         //getting material instance
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootFERTs);
             
         //setting title information for material
         if(!rootFERTs.isEmpty() && ins.instance.Label_Code__c != null && LabelCode_SubLabelCode_Map__c.getInstance(ins.instance.Label_Code__c) != null){
             //Get Sublabel code id from custom setting
             String subLblCode = LabelCode_SubLabelCode_Map__c.getInstance(ins.instance.Label_Code__c).Sub_Label_Code_Id__c;
             
             //check sublabelcode id not null
             if(subLblCode != null && subLblCode != ''){
                 //query for sub label code details
                 List<Sub_Label_Code__c> sLblCode = [SELECT Id, Sub_Label_Code_ID__c FROM Sub_Label_Code__c WHERE Sub_Label_Code_ID__c =: subLblCode limit 1];
                 
                 //populating material instance with sub label code id
                 if(!sLblCode.isEmpty()){
                     ins.instance.Sub_Label_Code_Lookup__c = sLblCode[0].ID;
                 }
                 else{
                     ins.instance.Sub_Label_Code_Lookup__c = null;
                 }
             }
         }
         //if no sub label code found in custom setting
         else if(!rootFERTs.isEmpty() && LabelCode_SubLabelCode_Map__c.getInstance(ins.instance.Label_Code__c) == null){
             ins.instance.Sub_Label_Code_Lookup__c = null;
         }
     }
     
     /*****************************************************************
     Method Name: sectionCollapseExpand
     Purpose : setting default title on materials
     ***************************************************************/
     public pageReference sectionCollapseExpand(){ 
         try{        
             MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
             
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
     
     // Following method fetches the selected titles from materials
     @testVisible private void resetMaterialList(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
         
         for(MaterialFERTWrapper mat : processingMaterials)
         {           
             // Collect titles
             if(mat.instance != null && !mat.isExistingRecord && !mat.isExisting){
                 mat.instance.id = null;
                 lstMaterialRecords.add(mat.instance);
             } 
             
             if(mat.childComponents.size() > 0)
             {
                 for(MaterialComponentWrapper childComp : mat.childComponents)
                 {
                     if(childComp.instance != null && !childComp.isExistingRecord && !childComp.isExisting){
                         childComp.instance.id = null;
                         lstMaterialRecords.add(childComp.instance);
                     }
                         
                 }
             }
                 
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             resetMaterialList(nextLevelMaterials);
     }
     /**********************************************************************************************************
     REL-20
     Method Name: updateTerritoryOfDisc
     Purpose : method to update territory of component to 'US & CDN' if component is of type 'DISC'
     ************************************************************************************************************/
     public pageReference updateTerritoryOfDisc(){ 
         
         MaterialFERTWrapper ins = getMaterialWrapperInstance(selectedMaterialLevel, materialIndex.split(';'), rootIns.getData());
            
         Integer actualCompIndex = 0;
         for(MaterialComponentWrapper comp : ins.childComponents)
         {
             System.debug('Local component ID '+ comp.localComponentId);
             System.debug('Component Index '+componentIndex);
             
             if(comp.localComponentId == componentIndex)
             {
                 break;
             }
             actualCompIndex ++;
         }
         
         System.debug('releaseDetails &&&:'+ releaseDetails);
         System.Debug('Actual Component Index '+actualCompIndex);
         
         List<Release_material__c> lstRM = new List<Release_material__c>();
         List<BOM_Item__c> lstBMItm = new List<BOM_Item__c>();
         Material__c comp = ins.childComponents.get(actualCompIndex).instance;
                 
         System.Debug('Material Status @@ '+comp.Material_Status__c);
                 
         if(comp.Component_Type__c != null && (comp.Component_Type__c == 'DISC DVD' || comp.Component_Type__c == 'DISC BD' || comp.Component_Type__c == 'DISC UHD' || comp.Component_Type__c == 'DISC CD'))
         {
             if(releaseDetails != null && releaseDetails.Brand_Group__c == PHE_BRAND_GROUP)
                 {
                     comp.Territory__c = ins.instance.Territory__c;
                 }
                 else
                 {       
                     comp.Territory__c = US_CDN_TERRITORY;
                 }
         }
         else
         {
             comp.Territory__c = ins.instance.Territory__c;
         }
         
         return null;        
             
     }
     /**********************************************************************************************************
     REL-20
     Method Name: populateTerritoryForDisc
     Purpose : method to update territory of component to 'US & CDN' if component is of type 'DISC'. 
               When 'Brand Group' of Release changes in Release Wizard             
     ************************************************************************************************************/
     private void populateTerritoryForDisc(List<MaterialFERTWrapper> processingMaterials)
     {
         List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
                 
         for(MaterialFERTWrapper mat : processingMaterials)
         {
             if(mat.childComponents.size() > 0)
                 {
                     for(MaterialComponentWrapper comp : mat.childComponents)
                     {
                         if(comp.instance != null && !comp.isExistingRecord && !comp.isExisting)
                         {
                              if(comp.instance.Component_Type__c != null && (comp.instance.Component_Type__c == 'DISC DVD' || comp.instance.Component_Type__c == 'DISC BD' || comp.instance.Component_Type__c == 'DISC UHD' || comp.instance.Component_Type__c == 'DISC CD'))
                                 {
                                     if(releaseDetails != null && releaseDetails.Brand_Group__c == PHE_BRAND_GROUP)
                                         {
                                             comp.instance.Territory__c = mat.instance.Territory__c;
                                         }
                                     else
                                         {       
                                             comp.instance.Territory__c = US_CDN_TERRITORY;
                                         }
                                 }
                             else
                                 {
                                     comp.instance.Territory__c = mat.instance.Territory__c;
                                 }
                         }       
                     }
                 }
             // Prepare for next level.
             if(mat.childFERTs.size() > 0)
             {
                 for(MaterialFERTWrapper childMat : mat.childFERTs)
                 {
                     nextLevelMaterials.add(childMat);
                 }
             }
         }
         
         if(nextLevelMaterials.size() > 0)
             populateTerritoryForDisc(nextLevelMaterials);
     }
    
    /**********************************************************************************************************
    REL-198
    Method Name: addWarningMsgOnBrandGroupChange
    Purpose : method to add warning message to VF page when brand group changed from PHE Nickelodeon             
    ************************************************************************************************************/
    public void addWarningMsgOnBrandGroupChange() {
        isWizardHasDiscComponent = false;
        checkWizardHasDiscComponent(rootFERTs);
        if((previousBrandGroup != null && previousBrandGroup == PHE_BRAND_GROUP) && (releaseDetails.Brand_Group__c != null && releaseDetails.Brand_Group__c != PHE_BRAND_GROUP) && isWizardHasDiscComponent) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning, 
                                                                   'Please check that Discs have the correct territory.'));
        }
        previousBrandGroup = releaseDetails.Brand_Group__c; 
        System.debug('previousBrandGroup:**'+ previousBrandGroup);
        
    }
    /**********************************************************************************************************
    REL-198
    Method Name: checkWizardHasDiscComponent
    Purpose : method to check release wizard contains any DISC component        
    ************************************************************************************************************/
    private void checkWizardHasDiscComponent(List<MaterialFERTWrapper> processingMaterials) {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
                
        for (MaterialFERTWrapper mat : processingMaterials) {
            if (mat.childComponents.size() > 0) {
                for (MaterialComponentWrapper comp : mat.childComponents) {
                    if (comp.instance != null) {
                        if (comp.instance.Component_Type__c != null && (comp.instance.Component_Type__c == 'DISC DVD' || 
                            comp.instance.Component_Type__c == 'DISC BD' || comp.instance.Component_Type__c == 'DISC UHD' || 
                            comp.instance.Component_Type__c == 'DISC CD')) {
                            isWizardHasDiscComponent = true;
                        }
                    }       
                }
            }
            
            // Prepare for next level.
            if (mat.childFERTs.size() > 0) {
                for (MaterialFERTWrapper childMat : mat.childFERTs) {
                    nextLevelMaterials.add(childMat);
                }
            }
        }
        
        if (nextLevelMaterials.size() > 0) {
            checkWizardHasDiscComponent(nextLevelMaterials);
        }
    }
}