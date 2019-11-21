/*****************************************************************************************
Class Name: ReleaseCloningController
Purpose: Apex class for ReleaseCloning VF page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             12/09/2016           Suman                    Initial Development
1.1             02/06/2017           Mohit                    Added digitalforce logic for DFOR-78
                07/07/2017           Dinakar                  Modified logic for USST-2410 
******************************************************************************************/
public with sharing class ReleaseCloningController {

    public boolean disableSave {get;set;}
    public String showReleasePanel { get; set; }
    public String useExistingReleaseFlag {get; set;}
    public Release__c newRelease {get;set;}
    public boolean createNew {get;set;}
    public List<MaterialFERTWrapper> rootFERTs {get; set;}
    public List<MaterialFERTWrapper> tmpRootFERTs {get; set;}
    public PaginationHandler rootIns {get;set;}
    public Boolean checkNegativeTesting = false;
    // added for RE-60
    public Boolean orgWideSyncSupport {
        get {
            return (Test.isRunningTest() ? true : SyncRelease__c.getInstance('Release_Sync').Sync_Release__c);
        } 
        private set;
    }
    
    // Local variables.
    public Boolean shouldSyncDates {get; set;} {shouldSyncDates = TRUE;} // Added for RE-60
    public Integer itemIndex {get; set;}
    public Material__c materialObj {get;set;} 
    public Material__c materialObjNewRelease {get;set;}
    public List<Material__c> childMaterialList {get;set;}
    public List<Release_Date__c> childReleaseDateList {get;set;}
    public Map<String, List<Bom_Item__c>> matVsBomItemMap {get;set;}
    String returnPath;
    private List<String> selectedMatIdList;
    private Set<String> selectedMatIdSet;
    private String releseIdToAssociateChild;
    public Integer isCalled { get; set; }
    private List<Bom_Item__c> bomList;
    private Map<String,List<String>> materialToComponentMap;
    public String errorMessage;
    public String rootMatIds {get; private set;}
    public Boolean showMaterialTreePanel {get; private set;}
    public Boolean createStandAloneMaterial {get; set;}
    public Boolean shouldCopyHierarchyForTerritoryChange {get; set;}
    public Boolean shouldShowPage {get; private set;}
    public Boolean isSeparateTerritory {get; private set;}
    public Id recordId {get; private set;}
    public String sobjectType {get; private set;}
    public String objectName {get; private set;}
    public set<ID> setTitleID;
    public boolean showPHEFields {get;set;}
    public Material__c matTempIns {get;set;}
    public String territoryInScreen {get;set;} //USST-2911
    public Boolean stampOldMatNoChecked {get;set;} //USST-2911
    public Boolean hideChildren = false; //USST-2911
    public boolean stampOldMatNo {get;set;}
    private Boolean callFromConstructor;
    public Integer selectedMaterialLevel {get; set;}
    public String materialIndex {get; set;}
    private Release__c relDetail; //added as part of DFOR-78
    private Release__c releaseDetails;//RE-50
    
    
    //USST-2546 ---start
    public Set<Id> lstCreateUpdateMatIds = new Set<Id>();
    @testVisible private static boolean checkChildView =false; 
    public static Map<String,Id>materialUpdateMap=new Map<String,Id>(); 
    public static List<Sales__c>insertableSales=new List<Sales__c>();
    public static List<Classification__c>insertableClassification=new List<Classification__c>();
    public static List<Alternative_Unit_of_Measure__c>insertableAUoMs=new List<Alternative_Unit_of_Measure__c>();
    public static List<Valuation__c>insertableVals=new List<Valuation__c>();
    public static List<Plant__c>insertablePlant=new List<Plant__c>();
    public static Boolean checkFromComponentExtension = false;
    //USST-2546 ---end

    // Constructor.
    public ReleaseCloningController(){
        disableSave = true;
        createNew = false;
        callFromConstructor = false;
        TriggerUtility.checkFromCloning = TRUE;
        TriggerUtility.followMaterialNamingConvension = FALSE;
        childMaterialList = new List<Material__c>();
        childReleaseDateList  = new List<Release_Date__c>();
        NewRelease = new Release__c(street_date__c = system.today());
        isCalled  = 0;
        materialObj = new Material__c(); 
        materialObjNewRelease = new Material__c();
        showMaterialTreePanel = false;
        createStandAloneMaterial = false;
        shouldCopyHierarchyForTerritoryChange = false;
        isSeparateTerritory = false;
        shouldShowPage = true;
        rootFERTs = new List<MaterialFERTWrapper>();
        tmpRootFERTs = new List<MaterialFERTWrapper>();
        rootIns = new PaginationHandler();
        rootIns.assignRecordList(rootFERTs);
        rootIns.pageSize = 8;
        setTitleID = new Set<ID>();
        showPHEFields = FALSE;
        matTempIns = new Material__c();
        stampOldMatNo = FALSE;
        
        itemIndex = -1;
        returnPath = '';
        rootMatIds = '';
        objectName = 'Release';
        
        // Grabing values from page URL.
        if(apexpages.currentpage().getparameters().containsKey('retURL'))
            returnPath = apexpages.currentpage().getparameters().get('retURL');
        if(apexpages.currentpage().getparameters().containsKey('recordId') && apexpages.currentpage().getparameters().get('recordId') != null && apexpages.currentpage().getparameters().get('recordId') != '')
        {
            recordId = apexpages.currentpage().getparameters().get('recordId');
            sobjectType = String.valueOf(recordId.getSobjectType());
            
            if(sobjectType != null && sobjectType.equalsIgnoreCase('Material__c'))
            {
                createStandAloneMaterial = TRUE;
                stampOldMatNo = TRUE;
                rootMatIds = recordId;
                showMaterialTreePanel = true;
                objectName = 'Material';
                List<Material__c> curMat = [SELECT Id, Material_Type__c, Item_Type__c, Territory__c FROM Material__c WHERE Id=:recordId]; //USST-2911
                
                // If page is redirected from Components, throws error message. 
                if(curMat != null && curMat.size() > 0 && (curMat[0].Material_Type__c == 'ROH' || curMat[0].Material_Type__c == 'Z009' || curMat[0].Material_Type__c == 'ZVSM' || curMat[0].Material_Type__c == 'ZDLT'))
                {
                    shouldShowPage = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Deep clone does not apply for components.'));
                }
                else if(curMat != null && curMat.size() > 0)
                {
                    //USST-2911 --- start
                    if (curMat[0].Item_Type__c != 'D (Display Vehicle)' && curMat[0].Territory__c == 'US & CDN') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'You are cloning from a US & CDN territory to a single territory. After cloning please review the BOM to make sure the components are appropriate to the new material\'s territory.'));
                    }
                    //USST-2911 --- end
                    matTempIns.Territory__c = ((curMat[0].Territory__c != null && curMat[0].Territory__c == 'CDN') ? 'CDN' : 'US');
                    callFromConstructor = true;
                    hasDifferentTerritory();
                    callFromConstructor = false;
                }
            }
            // If page is coming from Release, it fetches the BOM Hierarchy.
            else if(sobjectType != null && sobjectType.equalsIgnoreCase('Release__c'))
            {
                materialObj.Release__c = recordId;
                callFromConstructor = true;
                 //RE-50 Added below line to query contact fields from existing release.
                // Added for RE-60 and commented above query.
                String qry = 'SELECT Id,Creative_Contact__c,Manufacturing_Contact__c,Marketing_Contact__c,Master_Data_Contact__c,Tech_Ops_Contact__c,Publicity_Contact__c'; //USST-3239
                if(orgWideSyncSupport)
                {
                    for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                    {
                        if(dateFld.Sync_On_Insert__c)
                            qry += ',' + dateFld.Field_Api__c;
                    }
                }
                qry += ' FROM Release__c WHERE Id=:recordId';
                releaseDetails = Database.query(qry);
                
                //added as part of DFOR-78
                relDetail = [SELECT Id, Territory__c, Digital__c, Digital_Release__c FROM Release__c WHERE Id=:recordId];
                
                fetchChildItems();
            }
        }
        
        if(recordId != null && sobjectType.equalsIgnoreCase('Material__c') && shouldShowPage)
            getExistingBOMTree();
        
        useExistingReleaseFlag = 'CreateNewRelease';
        showReleasePanel();

    }
    
    //USST-2911 --- start
    public void reloadMaterialTreeForTerritoryChange() {
        territoryInScreen = matTempIns.Territory__c;
        stampOldMatNoChecked = stampOldMatNo;
        Material__c tempMat;
        hasDifferentTerritory();
        if (sobjectType != null && sobjectType.equalsIgnoreCase('Material__c') && recordId != null) {
            tempMat = [Select Id, Territory__c, Item_Type__c from Material__c where Id =: recordId];
            if (tempMat.Territory__c != 'US & CDN' && tempMat.Territory__c != territoryInScreen && stampOldMatNoChecked == true && (tempMat.Item_Type__c == 'S (Single)' || tempMat.Item_Type__c == 'M (Multipack)')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'If the Stamp Down Old Material box is checked then cloning across territories is not allowed - uncheck to proceed.'));
            }
            else if (tempMat.Territory__c != 'US & CDN' &&  tempMat.Territory__c != territoryInScreen && stampOldMatNoChecked == false && tempMat.Item_Type__c != 'D (Display Vehicle)') {
                hideChildren = true;
                getExistingBOMTree();
            }
            else if (tempMat.Territory__c == territoryInScreen){
                hideChildren = false;
                getExistingBOMTree();
            }
            else if (tempMat.Territory__c == 'US & CDN' && tempMat.Item_Type__c != 'D (Display Vehicle)') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'You are cloning from a US & CDN territory to a single territory. After cloning please review the BOM to make sure the components are appropriate to the new material\'s territory.'));
            }
        }
    }
    
    public void reloadMaterialTreeForStampOldMatNoChange() {
        territoryInScreen = matTempIns.Territory__c;
        stampOldMatNoChecked = stampOldMatNo;
        Material__c tempMat;
        if (sobjectType != null && sobjectType.equalsIgnoreCase('Material__c') && recordId != null) {
            tempMat = [Select Id, Territory__c, Item_Type__c from Material__c where Id =: recordId];
            if (tempMat.Territory__c != 'US & CDN' && tempMat.Territory__c != territoryInScreen && stampOldMatNoChecked == true && (tempMat.Item_Type__c == 'S (Single)' || tempMat.Item_Type__c == 'M (Multipack)')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'If the Stamp Down Old Material box is checked then cloning across territories is not allowed - uncheck to proceed.'));
            }
            else if (tempMat.Territory__c != 'US & CDN' && tempMat.Territory__c != territoryInScreen && stampOldMatNoChecked == false && tempMat.Item_Type__c != 'D (Display Vehicle)') {
                hideChildren = true;
                getExistingBOMTree();
            }
            else if (tempMat.Territory__c == territoryInScreen){
                hideChildren = false;
                getExistingBOMTree();
            }
            else if (tempMat.Territory__c == 'US & CDN' && tempMat.Item_Type__c != 'D (Display Vehicle)') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'You are cloning from a US & CDN territory to a single territory. After cloning please review the BOM to make sure the components are appropriate to the new material\'s territory.'));
            }
        }
    }
    //USST-2911 --- end
    
    public void switchView()
    {
        callFromConstructor = true;
        hasDifferentTerritory();
        callFromConstructor = false;
        if(!createStandAloneMaterial)
            stampOldMatNo = FALSE;
    }
    
    // This method is called from save method to handle target Release.
    private String getNewReleaseId(){
        if(createNew)
        {
            //insert the release object and get the id
            newRelease.Id = null;
            newRelease.Master_Schedule_Indicator__c = 'Exclude';
            newRelease.Pretty_Indicator__c = 'Exclude';
            
            //RE-50 Added below code to copy existing release's contact section. - Started
            if(releaseDetails!=null){
                newRelease.Creative_Contact__c=releaseDetails.Creative_Contact__c;
                newRelease.Manufacturing_Contact__c=releaseDetails.Manufacturing_Contact__c;
                newRelease.Marketing_Contact__c=releaseDetails.Marketing_Contact__c;
                newRelease.Master_Data_Contact__c=releaseDetails.Master_Data_Contact__c;
                newRelease.Tech_Ops_Contact__c= releaseDetails.Tech_Ops_Contact__c;
                newRelease.Publicity_Contact__c= releaseDetails.Publicity_Contact__c; //USST-3239
            }
            //RE-50 Added above code to copy existing release's contact section. - end            
            
            // Added for RE-60
            if(orgWideSyncSupport && newRelease.Sync_Dates__c && releaseDetails != null)
            {
                newRelease.Release_Sync__c = releaseDetails.Id;
                for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                {
                    if(dateFld.Sync_On_Insert__c)
                        newRelease.put(dateFld.Field_Api__c, releaseDetails.get(dateFld.Field_Api__c));
                }
            }
            
            //added as part of DFOR-78
            newRelease.Digital_Release__c = relDetail.Digital_Release__c;
            newRelease.Digital__c = relDetail.Digital__c;
            
            upsert newRelease;
            
            // modified RE-60
            if(orgWideSyncSupport && newRelease.Sync_Dates__c && releaseDetails != null)
            {
                TriggerUtility.doNotExecute = TRUE;
                update new Release__c(Id=releaseDetails.Id, Release_Sync__c=newRelease.Id, Sync_Dates__c=TRUE);
                TriggerUtility.doNotExecute = FALSE;
            }
            
            releseIdToAssociateChild = newRelease.Id;
        }
        else
        {
            // get the id of selected release materialObj.Release__c
            releseIdToAssociateChild = materialObjNewRelease.Release__c;
            
            // Added for RE-60 //added as part of DFOR-78 (Merged)
            Release__c curRel = new Release__c(Id=releseIdToAssociateChild);
            if(orgWideSyncSupport && shouldSyncDates && releaseDetails != null)
            {
                curRel.Sync_Dates__c = TRUE;
                curRel.Release_Sync__c = releaseDetails.Id;
                for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                {
                    if(dateFld.Sync_On_Insert__c)
                        curRel.put(dateFld.Field_Api__c, releaseDetails.get(dateFld.Field_Api__c));
                }
            }
            curRel.Digital_Release__c = relDetail.Digital_Release__c;
            curRel.Digital__c = relDetail.Digital__c;
            update curRel;
            
            if(orgWideSyncSupport && shouldSyncDates && releaseDetails != null)
            {
                // Modified RE-60
                TriggerUtility.doNotExecute = TRUE;
                update new Release__c(Id=releaseDetails.Id, Release_Sync__c=curRel.Id, Sync_Dates__c=TRUE);
                TriggerUtility.doNotExecute = FALSE;
            }
        }
        return  releseIdToAssociateChild;        
    }
    
    private Boolean hasError;
    // This method validates the complete chain selection. If parent is not selected and child is selected, it gives error.
    private void validateChain(List<MaterialFERTWrapper> operatingMaterials)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            if(!matWrapper.isSelected)
            {
                if(matWrapper.childFERTs.size() > 0)
                {
                    for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                    {
                        if(childMat.isSelected)
                        {
                            hasError = true;
                            return;
                        }
                    }
                }
                
                if(matWrapper.childComponents.size() > 0)
                {
                    for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                    {
                        if(childComp.isSelected)
                        {
                            hasError = true;
                            return;
                        }
                    }
                }
            }
            else
            {
                if(matWrapper.childFERTs.size() > 0)
                {
                    for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                    {
                        nextLevelMaterials.add(childMat);
                    }
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            validateChain(nextLevelMaterials);
    }
    
    private Set<String> selectedMaterialIdSet =new Set<String>();
    // This method fetches the selected materials.
    private void getSelectedData(List<MaterialFERTWrapper> operatingMaterials)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            if(matWrapper.isSelected)
                selectedMaterialIdSet.add(matWrapper.instance.Id);
            
            if(matWrapper.childFERTs.size() > 0)
            {
                for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                {
                    nextLevelMaterials.add(childMat);
                }
            }
            
            if(matWrapper.childComponents.size() > 0)
            {
                for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                {
                    if(childComp.isSelected)
                        selectedMaterialIdSet.add(childComp.instance.Id);
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            getSelectedData(nextLevelMaterials);
    }
    
    Boolean hasUncheckedComponents = false;
    // Following method is responsible to uncheck selection for components having territory CDN only.
    private void uncheckCDNOnlyComponents(List<MaterialFERTWrapper> operatingMaterials)
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
            {
                for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                {
                    //USST-2410 START
                    if(childComp.instance.Territory__c == 'CDN')
                    {
                        if(childComp.isSelected)
                        {
                            childComp.isSelected = false;
                        }
                        childComp.isDisabled = true;
                        hasUncheckedComponents = true;
                    }
                    //USST-2410 END
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            uncheckCDNOnlyComponents(nextLevelMaterials);
    }
    
    // Following method is responsible to check all components' selection across territory.
    private void checkAllComponents(List<MaterialFERTWrapper> operatingMaterials)
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
            
            if(matWrapper.childComponents.size() > 0 && !chainBreakingFERTs.contains(matWrapper.instance.Id))
            {
                for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                {
                    childComp.isSelected = true;
                    childComp.isDisabled = false;
                    // Added for RE-21
                    if(deselectCompItemCodes.contains(childComp.instance.Item_Code__c))
                    {
                        childComp.isSelected = false;
                    }
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            checkAllComponents(nextLevelMaterials);
    }
    
    // Following method is responsible to check all FERTs' selection across territory considering ignoring Item Codes.
    private void checkAllFERTsWithItemCodeChecking(List<MaterialFERTWrapper> operatingMaterials)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            matWrapper.isDisabled = false;
            matWrapper.isSelected = true;
            
            if(matWrapper.instance.Item_Code__c != null && ignoreItemCodes.contains(matWrapper.instance.Item_Code__c))
            {
                chainBreakingFERTs.add(matWrapper.instance.Id);
                matWrapper.isDisabled = true;
                matWrapper.isSelected = false;
            }
            // Checking if parent FERT has already broken the chain.
            if(chainBreakingFERTs.contains(matWrapper.instance.Id))
            {
                matWrapper.isDisabled = true;
                matWrapper.isSelected = false;
            }
            
            if(matWrapper.childFERTs.size() > 0)
            {
                for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                {
                    if(chainBreakingFERTs.contains(matWrapper.instance.Id))
                        chainBreakingFERTs.add(childMat.instance.Id);
                    
                    nextLevelMaterials.add(childMat);
                }
            }
            
            if(matWrapper.childComponents.size() > 0 && !chainBreakingFERTs.contains(matWrapper.instance.Id))
            {
                for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                {
                    childComp.isSelected = true;
                    childComp.isDisabled = false;
                    
                    if(chainBreakingFERTs.contains(matWrapper.instance.Id))
                    {
                        childComp.isSelected = false;
                        childComp.isDisabled = true;
                    }
                    // Added for RE-21
                    else if(deselectCompItemCodes.contains(childComp.instance.Item_Code__c))
                    {
                        childComp.isSelected = false;
                    }
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            checkAllFERTsWithItemCodeChecking(nextLevelMaterials);
    }
    
    // Following method is responsible to check all FERTs' selection across territory considering ignoring Item Codes.
    private void uncheckAllFERTsBasedOnTerritory(List<MaterialFERTWrapper> operatingMaterials, Integer level)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            if(matWrapper.instance.Item_Code__c != null && ignoreItemCodes.contains(matWrapper.instance.Item_Code__c))
            {
                chainBreakingFERTs.add(matWrapper.instance.Id);
                matWrapper.isDisabled = true;
                matWrapper.isSelected = false;
                hasItemCodeIssue = true;
            }
            
            // Checking if parent FERT has already broken the chain.
            if(chainBreakingFERTs.contains(matWrapper.instance.Id))
            {
                matWrapper.isDisabled = true;
                matWrapper.isSelected = false;
                hasUncheckedFERTs = true;
            }
            // If chain not yet broken and current material does not support both territory, break the chain.
            else if(level > 1 && (matWrapper.instance.Territory__c == null || matWrapper.instance.Territory__c != 'US & CDN') && sobjectType != null && 
                    (sobjectType.equalsIgnoreCase('Release__c') || (sobjectType.equalsIgnoreCase('Material__c') && 
                     ((createStandAloneMaterial && matWrapper.instance.Territory__c != matTempIns.Territory__c) || 
                      (!createStandAloneMaterial && matWrapper.instance.Territory__c != newRelease.Territory__c)))))
            {
                chainBreakingFERTs.add(matWrapper.instance.Id);
                matWrapper.isDisabled = true;
                matWrapper.isSelected = false;
                hasUncheckedFERTs = true;
            }
            
            if(matWrapper.childFERTs.size() > 0)
            {
                for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                {
                    if(chainBreakingFERTs.contains(matWrapper.instance.Id))
                        chainBreakingFERTs.add(childMat.instance.Id);
                    
                    nextLevelMaterials.add(childMat);
                }
            }
            
            if(matWrapper.childComponents.size() > 0)
            {
                for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                {
                    if(!childComp.isSelected)
                        continue;
                    
                    if(chainBreakingFERTs.contains(matWrapper.instance.Id))
                    {
                        childComp.isSelected = false;
                        childComp.isDisabled = true;
                    }
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            uncheckAllFERTsBasedOnTerritory(nextLevelMaterials, (level + 1));
    }
    
    Boolean isReleaseCancelled = false;
    Boolean hasUncheckedFERTs = false;
    public String sourceTerritory {get; private set;} {sourceTerritory = '';}    // Changed for RE-60
    public String destinationTerritory {get; private set;} {destinationTerritory = '';}    // Changed for RE-60
    // This method decides whether source and destination belong to separate territory.
    public void hasDifferentTerritory()
    {
        
        isSeparateTerritory = false;
        isReleaseCancelled = false;
        
        // Refresh all components selection.
        checkAllComponents(rootFERTs);
        
        // Refresh all FERTs if it is going through stand alone material creation process.
        if(sobjectType == 'Material__c')
        {
            chainBreakingFERTs.clear();
            checkAllFERTsWithItemCodeChecking(rootFERTs);
        }
        
        sourceTerritory = '';
        destinationTerritory = '';
        
        if(!createStandAloneMaterial)
        {
            if(createNew && newRelease.Territory__c != null)
            {
                destinationTerritory = newRelease.Territory__c;
            }
            else if(!createNew && materialObjNewRelease.Release__c != null)
            {
                Release__c rel1 = [SELECT Id, Territory__c, Release_Status__c FROM Release__c WHERE Id=:materialObjNewRelease.Release__c];
                if(rel1.Release_Status__c == 'Cancelled')
                {
                    isReleaseCancelled = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'This action cannot be performed on a Cancelled Release'));
                    return;
                }
                
                if(rel1.Territory__c != null)
                    destinationTerritory = rel1.Territory__c;
            }
        }
        else if(createStandAloneMaterial && sobjectType == 'Material__c' && matTempIns != null)
        {
            destinationTerritory = matTempIns.Territory__c;
        }
        
        if(sobjectType != null)
        {
            if(sobjectType.equalsIgnoreCase('Release__c'))
            {
                Release__c rel1 = [SELECT Id, Territory__c FROM Release__c WHERE Id=:recordId];
                if(rel1.Territory__c != null)
                    sourceTerritory = rel1.Territory__c;
            }
            else if(sobjectType.equalsIgnoreCase('Material__c'))
            {
                Material__c mat1 = [SELECT Id, Territory__c FROM Material__c WHERE Id=:recordId];
                if(mat1.Territory__c != null)
                    sourceTerritory = mat1.Territory__c;
            }
        }
        else if(materialObj.Release__c != null)
        {
            Release__c rel1 = [SELECT Id, Territory__c FROM Release__c WHERE Id=:materialObj.Release__c];
            if(rel1.Territory__c != null)
                sourceTerritory = rel1.Territory__c;
        }
        System.debug('***** territory> '+sourceTerritory+' :: '+destinationTerritory);
        if(sourceTerritory != '' && destinationTerritory != '' && !sourceTerritory.containsIgnoreCase(destinationTerritory))
        {
            isSeparateTerritory = true;
            
            if(sobjectType == 'Material__c')
            {
                hasUncheckedFERTs = false;
                chainBreakingFERTs.clear();
                uncheckAllFERTsBasedOnTerritory(rootFERTs, 1);
                if(hasUncheckedFERTs)
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Cannot extend territory for child FERTs.'));
            }
            
            // If cloning from a CDN Release to a US Release, uncheck Canada only components from material tree.
            if(sourceTerritory == 'CDN' && destinationTerritory == 'US')
            {
                hasUncheckedComponents = false;
                uncheckCDNOnlyComponents(rootFERTs);
                if(hasUncheckedComponents)
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Cannot extend Canada only components to US.'));
            }
        }
        
        if(sobjectType != null && !sobjectType.equalsIgnoreCase('Material__c') && !isSeparateTerritory)
        {
            if(!callFromConstructor)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Source and Target territory must be different.'));
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Source and Target territory must be different.'));
        }
    }
    
    // Following method is responsible to populate selected materials and components into rootFERTs list.
    private Map<Id, Set<Id>> materialChildFERTMap = new Map<Id, Set<Id>>();
    private Map<Id, MaterialFERTWrapper> materialFERTWrapperMap = new Map<Id, MaterialFERTWrapper>();
    private void populateSelectedOnes()
    {
        fetchSelectedOnes(tmpRootFERTs);
        
        for(MaterialFERTWrapper rMat : tmpRootFERTs)
        {
            if(rMat.isSelected)
            {
                materialFERTWrapperMap.get(rMat.instance.Id).wizardType = 'release';
                materialFERTWrapperMap.get(rMat.instance.Id).levelOfDepth = 1;
            }
        }
        
        prepareHierarchySelectedOnes(tmpRootFERTs);
        
        for(MaterialFERTWrapper rMat : tmpRootFERTs)
        {
            if(rMat.isSelected)
            {
                rootFERTs.add(materialFERTWrapperMap.get(rMat.instance.Id));
            }
        }
    }
    
    private void prepareHierarchySelectedOnes(List<MaterialFERTWrapper> operatingMaterials)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            if(matWrapper.isSelected)
            {
                //if material id present in child map
                if(materialChildFERTMap.containsKey(matWrapper.instance.Id) && materialChildFERTMap.get(matWrapper.instance.Id).size() > 0)
                {
                    for(Id childMatId : materialChildFERTMap.get(matWrapper.instance.Id))
                    {
                        if(materialFERTWrapperMap.containsKey(childMatId))
                        {
                            MaterialFERTWrapper cMatIns = materialFERTWrapperMap.get(childMatId);
                            cMatIns.wizardType = 'release';
                            cMatIns.levelOfDepth = materialWrapperMap.get(matWrapper.instance.Id).levelOfDepth + 1;
                            materialFERTWrapperMap.get(matWrapper.instance.Id).childFERTs.add(cMatIns);
                            
                            nextLevelMaterials.add(cMatIns);
                        }
                    }
                }
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            prepareHierarchySelectedOnes(nextLevelMaterials);
    }
    
    private void fetchSelectedOnes(List<MaterialFERTWrapper> operatingMaterials)
    {
        List<MaterialFERTWrapper> nextLevelMaterials = new List<MaterialFERTWrapper>();
        for(MaterialFERTWrapper matWrapper : operatingMaterials)
        {
            if(matWrapper.isSelected)
            {
                //adding FERT ID to map
                if(!materialChildFERTMap.containsKey(matWrapper.instance.Id))
                    materialChildFERTMap.put(matWrapper.instance.Id, new Set<Id>());
                
                MaterialFERTWrapper matIns = matWrapper.clone();
                matIns.childComponents = new List<MaterialComponentWrapper>();
                matIns.childFERTs = new List<MaterialFERTWrapper>();
                matIns.childIns = new PaginationHandler();
                matIns.childIns.assignRecordList(matIns.childFERTs);
                
                if(matWrapper.childFERTs.size() > 0)
                {
                    for(MaterialFERTWrapper childMat : matWrapper.childFERTs)
                    {
                        if(childMat.isSelected)
                        {
                            materialChildFERTMap.get(matWrapper.instance.Id).add(childMat.instance.Id);
                            nextLevelMaterials.add(childMat);
                        }
                    }
                }
                
                if(matWrapper.childComponents.size() > 0)
                {
                    for(MaterialComponentWrapper childComp : matWrapper.childComponents)
                    {
                        if(childComp.isSelected)
                        {
                            matIns.childComponents.add(childComp.clone());
                        }
                    }
                }
                
                //map of material records
                materialFERTWrapperMap.put(matWrapper.instance.Id, matIns);
            }
        }
        
        if(nextLevelMaterials.size() > 0)
            fetchSelectedOnes(nextLevelMaterials);
    }
    
    public pageReference redirectToReviewPage(){
        
        /*
        check if duplicate material description or more than 40 characters or Paramount user or display vehicle then redirect to second page 
        
        Else direct return save method
        
        */
        
        System.Debug('check here '+stampOldMatNo);
        
        if(sobjectType != null && !sobjectType.equalsIgnoreCase('Material__c') && !isSeparateTerritory)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Source and Target territory must be different.'));
            return null;
        }
        
        //USST-2911 --- start
        if (sobjectType != null && sobjectType.equalsIgnoreCase('Material__c') && isSeparateTerritory && stampOldMatNo) {
            Material__c tempMat = [Select Id, Item_Type__c from Material__c where Id =: recordId];
            if (tempMat.Item_Type__c != 'D (Display Vehicle)') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'If the Stamp Down Old Material box is checked then cloning across territories is not allowed - uncheck to proceed.'));
                return null;
            }
        }
        //USST-2911 --- end
        
        string tempName;
        Map<ID,Title__c> mapTitleDetails = new Map<ID,Title__c>();
        Boolean redirectToSecondPage = FALSE;
        Set<string> setNewMatName = new Set<String>();
        Integer nameLength = 0;
        List<Release__c> lstExistingRelease = new List<Release__c>();
        hasError = false;
        //USST-3021 --- start
        List<ID> paramountSubLabelCodeIDs = new List<ID>();
        List<Sub_Label_Code__c> paramountSublabelCodes = [Select Id from Sub_Label_Code__c where Name LIKE '%PAR - %' OR Sub_Label_Code_ID__c = '59'];
        for (Sub_Label_Code__c sc : paramountSublabelCodes) {
            paramountSubLabelCodeIDs.add(sc.Id);
        }
        //USST-3021 --- end
        validateChain(rootFERTs);
        if(hasError)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'BOM Hierarchy is not well structured. Child material/component must have material selected.'));
            return null;
        }
        
        
        //Check if PHE user then recirect to second page
        User u = new User();
        u = TriggerUtility.currentUser;
        
        if(u.Label_Code__c  == '59 - Paramount'){
            redirectToSecondPage = TRUE;
            showPHEFields = TRUE;
        }
        
        //creating of map of title details
        if(!setTitleID.isEmpty()){
            for(Title__c title : [SELECT Id, Title_Abbreviation__c, Sort_Name__c, Short_Name__c
                                                  FROM Title__c
                                                  WHERE Id IN :setTitleID]){
                if(!mapTitleDetails.containsKey(title.ID)){
                    mapTitleDetails.put(title.ID,title);
                }               
            }
        }
        
        if(!createNew && !createStandAloneMaterial){
            lstExistingRelease = [Select id, Name, Territory__c, Promotion_Name_Abbreviation__c from Release__c where ID=:materialObjNewRelease.Release__c];
        }
        
        //looping over root FERTs
        if(!rootFERTs.isEmpty()){
            for(MaterialFERTWrapper matWrapper : rootFERTs)
            {
                if(matWrapper.isSelected){
                     matWrapper.instance.Territory__c =  destinationTerritory;           
                     //if user creating a standalone material then populating new street date and territory
                     if(createStandAloneMaterial){
                         if(matTempIns.Territory__c != null){
                             matWrapper.instance.Territory__c = matTempIns.Territory__c;
                         }else{
                             matWrapper.instance.Territory__c = 'US';
                         }
                         
                         if(matTempIns.Street_Date__c != null){
                             matWrapper.instance.Street_Date__c = matTempIns.Street_Date__c;
                         }
                     }
                     tempName = MaterialNamingConventionHandler.getFERTMaterialName(matWrapper.instance, !lstExistingRelease.isEmpty() ? lstExistingRelease[0] : newRelease.Name != null ? newRelease : null  , (mapTitleDetails.containsKey(matWrapper.instance.Title__c) ? mapTitleDetails.get(matWrapper.instance.Title__c) : null));                     
                     System.Debug('check new Name !! '+tempName);
                     
                     //removing any blank space and getting length
                     if(tempName != null && tempName != ''){
                         tempName = tempName.trim();
                         nameLength = tempName.length();
                     }
                     
                     matWrapper.instance.Name = tempName;
                     
                     if(showPHEFields){
                         matWrapper.instance.MPM_Issue__c = null;
                         matWrapper.instance.Subformat__c = null;
                         matWrapper.instance.Sales_Planning_Group__c = null;
                     }
                     
                     //if name more than 40 characters then redierct to second page
                     if(nameLength > 40){
                        redirectToSecondPage = TRUE;
                        nameLength = 0;
                     }
                     
                     //If display vehicle material found then redirect to second page
                     //USST-3021 --- start
                     if(matWrapper.instance.Item_Type__c == 'D (Display Vehicle)' && paramountSubLabelCodeIDs.size() > 0 && paramountSubLabelCodeIDs.contains(matWrapper.instance.Sub_Label_Code_Lookup__c) && matWrapper.instance.Label_Code__c != '59 - Paramount'){
                        redirectToSecondPage = FALSE;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'If the Item Type is Display and the Sub-Label Code is for Paramount, then the Label Code must be 59 - Paramount.'));
                        return null;
                     }
                     else if(matWrapper.instance.Item_Type__c == 'D (Display Vehicle)'){
                        redirectToSecondPage = TRUE;
                     }
                     //USST-3021 --- end                    
                     //adding new material name to set. If it is repeated then means duplicate in structure
                     if(!setNewMatName.contains(tempName)){
                         setNewMatName.add(tempName);
                     }
                     else{
                         redirectToSecondPage = TRUE;
                     }
                }
            }
            
            //if duplicate record present in the system 
            if(!setNewMatName.isEmpty()){
                List<Material__c> lstCheckDuplicate = MaterialUtility.getAllMats(setNewMatName);    //[Select id from Material__c where Name in:setNewMatName];
                
                System.Debug('List Values '+lstCheckDuplicate );
                 System.Debug('set Values '+setNewMatName);
                
                if(!lstCheckDuplicate.isEmpty()){
                    redirectToSecondPage = TRUE;
                }               
            }           
        }
        
        if(redirectToSecondPage || (Test.isRunningTest() && checkNegativeTesting)){
            tmpRootFERTs = rootFERTs;
            rootFERTs = new List<MaterialFERTWrapper>();
            System.debug('******tmpRootFERTs> '+tmpRootFERTs);
            System.debug('******rootFERTs1> '+rootFERTs);
            populateSelectedOnes();
            rootIns = new PaginationHandler();
            rootIns.assignRecordList(rootFERTs);
            rootIns.pageSize = 8;
            System.debug('******rootFERTs2> '+rootFERTs);
            
            pagereference pg = new pagereference('/apex/ReleaseCloningReviewMaterialDesc');
            return pg;
        }
        else{
            return save();
        }        
    }
    
    public pageReference backToReleaseCloning(){
        rootFERTs = tmpRootFERTs;
        rootIns = new PaginationHandler();
        rootIns.assignRecordList(rootFERTs);
        rootIns.pageSize = 8;
        
        pagereference pg = new pagereference('/apex/ReleaseCloning');
        pg.setRedirect(false);
        return pg;
    }
    
    private Map<Id, Material__c> matNameMap = new Map<Id, Material__c>();
    public String selectedMaterialIds {get; set;}
    private Map<String,String> originalToCloneMap;
    private Boolean isUStoCDN = false;
    private Boolean isCDNtoUS = false;
    List<Material__c> clonedMaterialList;
    List<Material__c> updateMatTerritory;
    public Boolean isSaveCalled {get; private set;} {isSaveCalled = false;}
    public Boolean foundException {get; private set;} {foundException = false;}
    String exceptionMessage = '';
    
    // Following method is responsible to handle the final save logic.
    public PageReference save()
    {
        PlantTriggerEventHandler.vBoolIsClone = true;
        isSaveCalled = false;
        hasError = false;
        foundException = false;
        exceptionMessage = '';
        validateChain(rootFERTs);
        if(hasError)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'BOM Hierarchy is not well structured. Child material/component must have material selected.'));
            return null;
        }
        
        selectedMaterialIdSet.clear();
        getSelectedData(rootFERTs);
        selectedMaterialIds = '';
        Integer f = 0;
        for(String selMatId : selectedMaterialIdSet)
        {
            if(f ++ > 0)
                selectedMaterialIds += ';';
            selectedMaterialIds += selMatId;
        }
        
        // Validates basic data is provided or not.
        System.debug('----materialObj.Release__c> '+materialObj.Release__c+' :: '+selectedMaterialIds);
        if(!createStandAloneMaterial && createNew && (newRelease.name == null || newRelease.name.trim() == ''))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Please provide Release Name to create new Release.'));
            foundException = true;
            return null;
        }
        //USST-3081 --- start
        /*else if(!createStandAloneMaterial && createNew && newRelease.name.length() > 40 )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Release Name cannot be more than 40 characters.'));
            foundException = true;
            return null;
        }*/
        //USST-3081 --- end
        else if(!createStandAloneMaterial && objectName == 'Release' && materialObj.Release__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Please choose the existing source Release.'));
            foundException = true;
            return null;
        }
        else if(!createStandAloneMaterial && !createNew && materialObjNewRelease.Release__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Please choose the existing target Release.'));
            foundException = true;
            return null;
        }
        else if(!createStandAloneMaterial && !createNew && materialObjNewRelease.Release__c != null && isReleaseCancelled)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'This action cannot be performed on a Cancelled Release'));
            foundException = true;
            return null;
        }
        else if(selectedMaterialIds == null || selectedMaterialIds.trim() == '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Please select material(s) to clone.'));
            foundException = true;
            return null;
        }
        
        TriggerUtility.checkFromCloning = TRUE;
        
        //looping over root FERTs.
        matNameMap.clear();
        if(!rootFERTs.isEmpty())
        {
            for(MaterialFERTWrapper matWrapper : rootFERTs)
            {
                if(matWrapper.isSelected)
                {
                    matNameMap.put(matWrapper.instance.Id, matWrapper.instance);
                }
            }
        }
        
        // Setting Savepoint
        Savepoint sp1 = Database.setSavepoint();
        
        PageReference pRef;
        try{
            isSaveCalled = true;
            // get the id of release to which hierarchy will be associated
            if(!createStandAloneMaterial)
                releseIdToAssociateChild = getNewReleaseId();
            
            if(!Utility.isEMpty(releseIdToAssociateChild) || createStandAloneMaterial)
            {
                Set<String> matIds = new Set<String>(selectedMaterialIds.split(';'));
                Map<Id, Release__c> releaseMap;
                Material__c rootMatDet;
                if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Release__c'))
                    releaseMap = new Map<Id, Release__c>([SELECT Id, Territory__c, Project_Type__c, Street_Date__c FROM Release__c WHERE Id=:releseIdToAssociateChild OR Id=:materialObj.release__c]);
                else if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Material__c'))
                {
                    releaseMap = new Map<Id, Release__c>([SELECT Id, Territory__c, Project_Type__c, Street_Date__c FROM Release__c WHERE Id=:releseIdToAssociateChild OR Id=:materialObj.release__c]);
                    rootMatDet = [SELECT Id, Territory__c FROM MAterial__c WHERE Id=:rootMatIds];
                }
                else if(rootMatIds != null && rootMatIds.trim() != '')
                    rootMatDet = [SELECT Id, Territory__c FROM MAterial__c WHERE Id=:rootMatIds];
                    
                isUStoCDN = false;
                isCDNtoUS = false;
                // Checking for separate territory in source and target for all combinations.
                if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Release__c') && releaseMap.get(materialObj.release__c) != null && releaseMap.get(materialObj.release__c).Territory__c != null && releaseMap.get(materialObj.release__c).Territory__c.equalsIgnoreCase('US') && 
                   releaseMap.get(releseIdToAssociateChild) != null && releaseMap.get(releseIdToAssociateChild).Territory__c != null && releaseMap.get(releseIdToAssociateChild).Territory__c.equalsIgnoreCase('CDN'))
                    isUStoCDN = true;
                else if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Material__c') && rootMatDet != null && rootMatDet.Territory__c != null && rootMatDet.Territory__c.equalsIgnoreCase('US') &&
                    releaseMap.get(releseIdToAssociateChild) != null && releaseMap.get(releseIdToAssociateChild).Territory__c != null && releaseMap.get(releseIdToAssociateChild).Territory__c.equalsIgnoreCase('CDN'))
                    isUStoCDN = true;
                else if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Release__c') && releaseMap.get(materialObj.release__c) != null && releaseMap.get(materialObj.release__c).Territory__c != null && releaseMap.get(materialObj.release__c).Territory__c.equalsIgnoreCase('CDN') && 
                   releaseMap.get(releseIdToAssociateChild) != null && releaseMap.get(releseIdToAssociateChild).Territory__c != null && releaseMap.get(releseIdToAssociateChild).Territory__c.equalsIgnoreCase('US'))
                    isCDNtoUS = true;
                else if(!createStandAloneMaterial && sobjectType.equalsIgnoreCase('Material__c') && rootMatDet != null && rootMatDet.Territory__c != null && rootMatDet.Territory__c.equalsIgnoreCase('CDN') &&
                    releaseMap.get(releseIdToAssociateChild) != null && releaseMap.get(releseIdToAssociateChild).Territory__c != null && releaseMap.get(releseIdToAssociateChild).Territory__c.equalsIgnoreCase('US'))
                    isCDNtoUS = true;
                else if(createStandAloneMaterial && sourceTerritory.equalsIgnoreCase('US') && destinationTerritory.equalsIgnoreCase('CDN'))
                    isUStoCDN = true;
                else if(createStandAloneMaterial && sourceTerritory.equalsIgnoreCase('CDN') && destinationTerritory.equalsIgnoreCase('US'))
                    isCDNtoUS = true;
                
                if(clonedMaterialList != null)
                    clonedMaterialList.clear();
                if(updateMatTerritory != null)
                    updateMatTerritory.clear();
                
                Date streetDate;
                if(!Utility.isEMpty(releseIdToAssociateChild) && releaseMap.get(releseIdToAssociateChild) != null && 
                   releaseMap.get(releseIdToAssociateChild).Street_Date__c != null)
                    streetDate = releaseMap.get(releseIdToAssociateChild).Street_Date__c;
                
                Set<String> selMatIds = new Set<String>(selectedMaterialIds.split(';'));
                Map<Id, Material__c> selMatMap = new Map<Id, Material__c>([SELECT Id, Material_Status__c, Material_Type__c, Territory__c FROM Material__c WHERE Id IN: selMatIds]); // Added territory__c for usst-2534 //Added Material_Status__c for USST-2546
                
                try{
                    //prepare id list of child materials and clone it
                    if(isUStoCDN || isCDNtoUS)
                    {
                        // If copying materials from one territory to other.
                        if(shouldCopyHierarchyForTerritoryChange)
                        {
                            updateMatTerritory = new List<Material__c>();
                            for(String selectedMatId : new Set<String>(selectedMaterialIds.split(';')))
                            {
                                Material__c mat = new Material__c();
                                mat.Id = selectedMatId;
                                mat.Territory__c = 'US & CDN';
                                if(selMatMap.containsKey(mat.Id) && selMatMap.get(mat.Id).Material_Status__c == 'Processed in SAP')
                                {
                                    mat.Material_Integration_State__c = 'N';
                                    mat.Function__c = '004';
                                }
                                if(!Utility.isEMpty(releseIdToAssociateChild) && releaseMap.get(releseIdToAssociateChild) != null && 
                                   releaseMap.get(releseIdToAssociateChild).Project_Type__c != null)
                                {
                                    mat.Project_Type__c = releaseMap.get(releseIdToAssociateChild).Project_Type__c;
                                }
                                updateMatTerritory.add(mat);
                            }
                        }
                        // For normal cloning between different territories.
                        else
                        {
                            Set<String> selectedMatIds = new Set<String>(selectedMaterialIds.split(';'));
                            List<String> rootMaterialIds = new List<String>();
                            
                            for(String matId : rootMatIds.split(';'))
                            {
                                if(selectedMatIds.contains(matId))
                                    rootMaterialIds.add(matId);
                            }
                            
                            // Logic for converting material from US to CDN.
                            if(isUStoCDN)
                            {
                                clonedMaterialList = cloneMaterials(rootMaterialIds, 'CDN', streetDate);
                            }
                            // Logic for converting material from CDN to US.
                            else
                            {
                                clonedMaterialList = cloneMaterials(rootMaterialIds, 'US', streetDate);
                            }
                            System.debug('*****Limits1> '+Limits.getQueries());
                            if(((createStandAloneMaterial && stampOldMatNo) || !createStandAloneMaterial) && clonedMaterialList != null && clonedMaterialList.size() > 0)
                            {
                                List<Material__c> updateableMats = new List<Material__c>();
                                for(Material__c clonedObj : clonedMaterialList) 
                                {
                                    Material__c uMat = new Material__c();
                                    uMat.Id = clonedObj.Id;
                                    uMat.Old_Material_No__c = clonedObj.Old_Material_No__c;
                                    uMat.Old_Material_Load__c = clonedObj.Old_Material_Load__c;     // Added by RE-24
                                    updateableMats.add(uMat);
                                }
                                
                                TriggerUtility.doNotExecute = true;
                                update updateableMats;
                                TriggerUtility.doNotExecute = false;
                            }
                            System.debug('*****Limits2> '+Limits.getQueries());
                            
                            // Update non-root materials' territory to US & CDN
                            Set<String> rootMatIdsSet = new Set<String>(rootMatIds.split(';'));
                            updateMatTerritory = new List<Material__c>();
                            for(String selMatId : selectedMatIds)
                            {
                                if(!rootMatIdsSet.contains(selMatId))
                                {
                                    Material__c childMat = new Material__c();
                                    childMat.Id = selMatId;
                                    /////usst-2534 -- start
                                    if(selMatMap.containsKey(childMat.Id) && selMatMap.get(childMat.Id).Territory__c != 'US & CDN')
                                    {
                                        //USST-2546 ----start
                                        if((selMatMap.get(childMat.Id).Material_Status__c == 'Processed in SAP' || selMatMap.get(childMat.Id).Material_Status__c == 'Sent to SAP' || selMatMap.get(childMat.Id).Material_Status__c == 'Approved') && (selMatMap.get(childMat.Id).Material_Type__c == 'ROH'|| selMatMap.get(childMat.Id).Material_Type__c == 'Z009')) {
                                            system.debug('I am checking in this statement---'+selMatMap.get(childMat.Id).Material_Status__c);
                                            lstCreateUpdateMatIds.add(childMat.Id);
                                        }
                                        else {
                                        system.debug('I am checking in else statement---');
                                            childMat.Territory__c = 'US & CDN';
                                            childMat.Execute_Validation_Rule__c = false; //USST-2821
                                            updateMatTerritory.add(childMat);
                                        }
                                        //USST-2546 ----end
                                    }
                                    /////usst-2534 -- end
                                }
                            }
                            system.debug('I am checking here----'+lstCreateUpdateMatIds.size());
                            if (!lstCreateUpdateMatIds.isEmpty()) {
                                createUpdateMaterial(lstCreateUpdateMatIds); //USST-2546
                            }
                        }
                    }
                    else
                    {
                        // Changes
                        Set<String> selectedMatIds = new Set<String>(selectedMaterialIds.split(';'));
                        List<String> rootMaterialIds = new List<String>();
                        
                        for(String matId : rootMatIds.split(';'))
                        {
                            if(selectedMatIds.contains(matId))
                                rootMaterialIds.add(matId);
                        }
                        clonedMaterialList = cloneMaterials(rootMaterialIds, null, streetDate);
                        System.debug('*****Limits1> '+Limits.getQueries());
                        
                        if(((createStandAloneMaterial && stampOldMatNo) || !createStandAloneMaterial) && clonedMaterialList != null && clonedMaterialList.size() > 0)
                        {
                            List<Material__c> updateableMats = new List<Material__c>();
                            for(Material__c clonedObj : clonedMaterialList) 
                            {
                                system.debug('cloned records id :: '+clonedObj.id);
                                Material__c uMat = new Material__c();
                                uMat.Id = clonedObj.Id;
                                uMat.Old_Material_No__c = clonedObj.Old_Material_No__c;
                                uMat.Old_Material_Load__c = clonedObj.Old_Material_Load__c;     // Added by RE-24
                                updateableMats.add(uMat);
                            }
                            
                            TriggerUtility.doNotExecute = true;
                            update updateableMats;
                            TriggerUtility.doNotExecute = false;
                        }
                    }
                    system.debug('clonedMaterialList  >> '+clonedMaterialList);
                }
                catch(DmlException dex)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, dex.getDmlMessage(0)));
                    Database.rollback( sp1 );
                    foundException = true;
                    return null;    
                }
                catch(Exception e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, e.getMessage()));
                    Database.rollback( sp1 );
                    foundException = true;
                    
                    return null;
                }
                System.debug('*****Limits12> '+Limits.getQueries());
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Please Select or Create a Release to associate components.'));
                foundException = true;
            }
        }
        // Exception Handling.
        catch(DmlException dex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+dex.getDmlMessage(0)+'.');
            ApexPages.addMessage(myMsg);
            foundException = true;
            Database.rollback( sp1 );
        }
        catch(Exception ex){
        
            system.debug('Exception occurred in save '+ex.getStacktraceString());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+ex.getMessage()+'.');
            ApexPages.addMessage(myMsg);
            foundException = true;
            Database.rollback( sp1 );
        }
        
        return pRef ;
    }
    
    public PageReference save2()
    {
        TriggerUtility.checkFromCloning = true;
        
        // Setting Savepoint
        Savepoint sp1 = Database.setSavepoint();
        
        PageReference pRef;
        
        try
        {
            if(Test.isRunningTest() && checkNegativeTesting)
                Integer i = 1/0;
            
            if(updateMatTerritory != null && updateMatTerritory.size() > 0)
            {
                TriggerUtility.allowAfterUpdateTriggerExecution = true;
                TriggerUtility.checkFromCloning = FALSE;
                TriggerUtility.doNotExecuteOnMaterialCloningUpdate = TRUE;
                System.debug('******** Updating territory in Existing Comps.');
                update updateMatTerritory;
                TriggerUtility.allowAfterUpdateTriggerExecution = false;
                TriggerUtility.checkFromCloning = TRUE;
                TriggerUtility.doNotExecuteOnMaterialCloningUpdate = FALSE;
            }
            
            /******************* common changes *******************/
            //Prepare map of orginal to cloned material id
            originalToCloneMap = new Map<String, String>();
            if(clonedMaterialList != null && clonedMaterialList.size() > 0)
            {
                for(Material__c clonedObj : clonedMaterialList) 
                {
                    if(clonedObj.CloneHelperField__c != null)
                        originalToCloneMap.put(clonedObj.CloneHelperField__c, clonedObj.Id);
                }
            }
            system.debug('originalToCloneMap >>> '+originalToCloneMap);
            
            // ** Currently it works for both same territory as well as separate territory
            if(releseIdToAssociateChild != null && releseIdToAssociateChild.trim() != '')
            {
                List<Release_Material__c> insertableRelMaterials = new List<Release_Material__c>();
                for(String matId : selectedMaterialIds.split(';'))
                {
                    if(!originalToCloneMap.containsKey(matId))
                    {
                        Release_Material__c relMaterial = new Release_Material__c();
                        relMaterial.Release__c = releseIdToAssociateChild;
                        relMaterial.Material__c = matId;
                        insertableRelMaterials.add(relMaterial);
                    }
                }
                
                if(insertableRelMaterials.size() > 0)
                {
                    TriggerUtility.doNotExecute = true;
                    insert insertableRelMaterials;
                    TriggerUtility.doNotExecute = false;
                }
            }
            System.debug('*****Limits3> '+Limits.getQueries());
            
            prepareNewBOMItems();
            if(insertableBOMItems != null && insertableBOMItems.size() > 0)
            {
                TriggerUtility.doNotExecute = true;
                insert insertableBOMItems;
                TriggerUtility.doNotExecute = false;
                
                Set<String> selectedMatIds = new Set<String>(selectedMaterialIds.split(';'));
                Set<Id> rootMaterialIds = new Set<Id>();
                
                for(String matId : rootMatIds.split(';'))
                {
                    if(selectedMatIds.contains(matId) && originalToCloneMap.containsKey(matId))
                        rootMaterialIds.add(originalToCloneMap.get(matId));
                }
                // Added for RE-17
                if(rootMaterialIds.size() > 0)
                    RSUCalculationHandler.updateMaterialTreeAsync(rootMaterialIds, false);
            }
            System.debug('*****Limits4> '+Limits.getQueries());
            
            // Redirection process.
            String redirectUrl;
            if(releseIdToAssociateChild != null)
                redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/'+releseIdToAssociateChild;
            else if(createStandAloneMaterial && originalToCloneMap.get(rootMatIds) != null)
                redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/'+originalToCloneMap.get(rootMatIds);
            else
                redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/home/home.jsp';
            pRef = new Pagereference(redirectUrl);
        
        }
        // Exception Handling.
        catch(DmlException dex)
        {
            String msg = dex.getDmlMessage(0);
            if(dex.getDmlType(0) == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY)
                msg = 'User does not have required access to update record(s)';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+ msg +'.');
            ApexPages.addMessage(myMsg);
            foundException = true;
            Database.rollback( sp1 );
            
            // Removing previous transaction created records.
            if(clonedMaterialList != null && clonedMaterialList.size() > 0)
            {
                TriggerUtility.doNotExecute = true;
                // Removing release materials if created.
                if(!createStandAloneMaterial && releseIdToAssociateChild != null)
                {
                    List<Release_Material__c> relMatList = [SELECT Id FROM Release_Material__c 
                                                            WHERE Release__c=:releseIdToAssociateChild AND Material__c IN: clonedMaterialList];
                    if(relMatList != null && relMatList.size() > 0)
                    {
                        delete relMatList;
                    }
                    
                    if(createNew)
                        delete new Release__c(Id=releseIdToAssociateChild);
                }
                Database.delete(clonedMaterialList,FALSE); // usst-2534
                TriggerUtility.doNotExecute = false;
            }
        }
        catch(Exception ex){
        
            system.debug('Exception occurred in save '+ex.getStacktraceString());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+ex.getMessage()+'.');
            ApexPages.addMessage(myMsg);
            foundException = true;
            Database.rollback( sp1 );
            
            // Removing previous transaction created records.
            if(clonedMaterialList != null && clonedMaterialList.size() > 0)
            {
                TriggerUtility.doNotExecute = true;
                // Removing release materials if created.
                if(!createStandAloneMaterial && releseIdToAssociateChild != null)
                {
                    List<Release_Material__c> relMatList = [SELECT Id FROM Release_Material__c 
                                                            WHERE Release__c=:releseIdToAssociateChild AND Material__c IN: clonedMaterialList];
                    if(relMatList != null && relMatList.size() > 0)
                    {
                        delete relMatList;
                    }
                    
                    if(createNew)
                        delete new Release__c(Id=releseIdToAssociateChild);
                }
                Database.delete(clonedMaterialList,FALSE); // usst-2534
                TriggerUtility.doNotExecute = false;
            }
        }
        
        return pRef ;
    }
    
    // This method clones materials in the selected list.
    private List<SObject> cloneMaterials(List<String> selectedMatIdList, String territory, Date streetDate)
    {
        System.debug('###cloneMaterials');
        if(selectedMatIdList == null || selectedMatIdList.size() == 0)
            return null;
        
        TriggerUtility.checkFromCloning = TRUE;
        
        // Setting the list of fields from material object not to be copied.
        Set<String> fieldsToIgnore = new Set<String>();
        fieldsToIgnore.add('BOM_Number__c');
        fieldsToIgnore.add('Material_Status__c');
        fieldsToIgnore.add('BOM_Status__c');
        fieldsToIgnore.add('UPC__c');
        fieldsToIgnore.add('Cross_Ref__c');
        fieldsToIgnore.add('Deletion_Flag__c');
        fieldsToIgnore.add('bom_number__c');
        fieldsToIgnore.add('material_status__c');
        fieldsToIgnore.add('bom_status__c');
        fieldsToIgnore.add('upc__c');
        fieldsToIgnore.add('cross_ref__c');
        fieldsToIgnore.add('deletion_flag__c');
        fieldsToIgnore.add('Brand_Group__c');
        fieldsToIgnore.add('brand_group__c');
        fieldsToIgnore.add('BOM_Integration_State__c');
        fieldsToIgnore.add('bom_integration_state__c');
        fieldsToIgnore.add('Material_Integration_State__c');
        fieldsToIgnore.add('material_integration_state__c');
        fieldsToIgnore.add('Alternative_BOM__c');
        fieldsToIgnore.add('alternative_bom__c');
        fieldsToIgnore.add('BOM_Wizard_Approval__c');
        fieldsToIgnore.add('bom_wizard_approval__c');
        fieldsToIgnore.add('Call_Approval_Process__c');
        fieldsToIgnore.add('call_approval_process__c');
        fieldsToIgnore.add('send_direct_to_SAP__c');
        fieldsToIgnore.add('send_direct_to_sap__c');
        fieldsToIgnore.add('MPM_Issue__c');
        fieldsToIgnore.add('Sales_Planning_Group__c');
        fieldsToIgnore.add('Subformat__c');
        fieldsToIgnore.add('mpm_issue__c');
        fieldsToIgnore.add('subformat__c');
        fieldsToIgnore.add('sales_planning_group__c');
        fieldsToIgnore.add('Total_Item_Qty__c'); // USST-2751
        fieldsToIgnore.add('total_item_qty__c'); // USST-2751
        //USST-2778 --- start
        fieldsToIgnore.add('Deal__c');
        fieldsToIgnore.add('deal__c');
        fieldsToIgnore.add('Deal_ID__c');
        fieldsToIgnore.add('deal_id__c');
        fieldsToIgnore.add('Legal_Owner__c');
        fieldsToIgnore.add('legal_owner__c');
        fieldsToIgnore.add('Financial_Owner__c');
        fieldsToIgnore.add('financial_owner__c');
        fieldsToIgnore.add('TM_Origin_Code__c');
        fieldsToIgnore.add('tm_origin_code__c');
        //USST-2778 --- end   
        fieldsToIgnore.add('Material_Expiration_Date__c'); //USST-2980
        fieldsToIgnore.add('material_expiration_date__c'); //USST-2980
        
        //below cloned list will have 'clonehelperfield__c' populated and will be equal to the object id from where it is cloned
        List<SObject> clonedMatList;
        clonedMatList = Utility.cloneMaterialList(selectedMatIdList, fieldsToIgnore, releseIdToAssociateChild);
        Id reqRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        String bomTextRegEx = Label.SpecialCharacters_Regex;
        Pattern MyPattern = Pattern.compile(bomTextRegEx);
         Matcher MyMatcher;
         String message;
         
        for(SObject obj : clonedMatList)
        {
            obj.put('Material_Status__c', 'Draft');
            obj.put('Brand_Group__c',null);
            obj.put('BOM_Status__c', 'Draft');
            obj.put('Function__c', '009');
            obj.put('BOM_Function__c', null);
            obj.put('RecordTypeId', reqRecordTypeId);
            obj.put('Cloned__c', True); //USST-2786
            //USST-2989 start
            if(obj.get('Territory__c')!=matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).Territory__c){
                obj.put('Old_Material_No__c',null);
                obj.put('Old_Material_Load__c','');
                 
            }
            //USST-2989 stop
            //USST-2980 --- start
            if (obj.get('Item_Type__c') == 'S (Single)' || obj.get('Item_Type__c') == 'M (Multipack)') {
                obj.put('Material_Expiration_Date__c',Date.valueOf('3333-12-31'));              
            }
            //USST-2980 --- end
            if(territory != null && territory.trim() != ''){
                obj.put('Territory__c', territory);
            }   
            if(!Utility.isEMpty(releseIdToAssociateChild) && streetDate != null){
                obj.put('Street_date__c', streetDate);
            }   
            obj.put('Name', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).name);
            
            if(createStandAloneMaterial){
                obj.put('Territory__c', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).Territory__c);
                obj.put('Street_Date__c', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).Street_Date__c);            
            }
            
           
            if(showPHEFields){
                if(matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c == null || matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c == ''){
                    throw new ApplicationException('MPM cannot be left blank.');
                }
                
                obj.put('MPM_Issue__c', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c);
                obj.put('Sales_Planning_Group__c', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).Sales_Planning_Group__c);  
                obj.put('Subformat__c', matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).Subformat__c);                
            }
            
            System.debug('***** BOM Long Txt> '+matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c);
            if(matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c != null && 
               MyPattern.matcher(matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c).find()){
                message=matNameMap.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c;
                obj.put('BOM_Long_Text__c', message.replaceAll(bomTextRegEx, ''));

            }
            System.debug('@@entered '+stampOldMatNo);
            if(stampOldMatNo){
                System.debug('entered');
                obj.put('Old_Material_No__c', ID.ValueOF(string.valueof(obj.get('clonehelperfield__c'))));
                obj.put('Old_Material_Load__c', obj.get('Material_Number__c'));    // Added by RE-24
            }
            obj.put('Material_Number__c', null);    // Added by RE-24
            
            if(!createStandAloneMaterial && destinationTerritory != null && destinationTerritory != '')
                obj.put('Territory__c', destinationTerritory);
            //RE-209 Defaulting Product class to null when cloned.    
            System.debug('@@@Item_type'+obj.get('Item_Type__c'));
            if(string.valueof(obj.get('Item_Type__c'))=='D (Display Vehicle)') {
                obj.put('Product_Class__c',null);
            }    
        }
        TriggerUtility.followMaterialNamingConvension = FALSE;
        TriggerUtility.doNotExecuteOnMaterialUpdate = true;
        try {
            insert clonedMatList; 
            TriggerUtility.doNotExecuteOnMaterialUpdate = false;
            return clonedMatList;           
        }
        catch (DmlException dex) {
            //USST-2765 --- start
            if (dex.getDmlMessage(0).contains('Material Name cannot be more than 40 characters.')) {
                Set<string> setLengthyName = new Set<string>();
                for (Material__c mat : (List<Material__c>)clonedMatList) {
                    if (mat.Name.length() > 40) {
                        setLengthyName.add(mat.Name);
                    }
                }
                if (!setLengthyName.isEmpty()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, 'Material Name cannot be more than 40 characters '+setLengthyName));
                    foundException = true;
                    return null;
                }
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.eRROR, dex.getDmlMessage(0)));//USST-3346
                foundException = true;
                    return null;
            }
            //USST-2765 --- end
        }
        return null;
    }

    // This method redirect controls to other location on cancel.
    public PageReference cancel(){
        if(returnPath != '')
            return new PageReference(returnPath);
        else
            return new PageReference('/home/home.jsp');
    }
    
    // It auto fills the new release.
    public void autoPopulateNewRelease()
    {
        Map<String, String> brandDefaultProjectTypeMap = new Map<String, String>{'Universal Pictures' => 'New Release',
                                                                                 'Partners' => 'New Release',
                                                                                 '1440' => 'New Release',
                                                                                 'Family' => 'New Release Illumination',
                                                                                 'TV' => 'New Release',
                                                                                 'Catalog' => 'Catalog'
                                                                                };
        User currentUser = [SELECT Id, Brand_Group__c, Label_Code__c from User where id=:userinfo.getuserid()];
        if(createNew && materialObj.release__c != null)
        {
            Release__c curRelease = [SELECT Name, Territory__c, Street_Date__c, Title__c,Brand_Group__c
                                     FROM Release__c
                                     WHERE Id=:materialObj.release__c];
            if(newRelease.Name == null || newRelease.Name.trim() == '')
                newRelease.Name = curRelease.Name;
            if(newRelease.Territory__c == null && curRelease.Territory__c != null)
                newRelease.Territory__c = curRelease.Territory__c;
            if(curRelease.Street_Date__c != null) 
                newRelease.Street_Date__c = curRelease.Street_Date__c;
            if(newRelease.Title__c == null && curRelease.Title__c != null)
               newRelease.Title__c = curRelease.Title__c;
            if(newRelease.Brand_Group__c == null && curRelease.Brand_Group__c != null)
               newRelease.Brand_Group__c = curRelease.Brand_Group__c;
            // Modified RE-60
            if(curRelease.Territory__c == 'US')
                newRelease.Sync_Dates__c = TRUE;    // Added for RE-60
        }
        else if(createNew && recordId != null && sobjectType.equalsIgnoreCase('Material__c'))
        {
            Material__c curMaterial = [SELECT Name, Territory__c
                                       FROM Material__c
                                       WHERE Id=:recordId];
            if(newRelease.Territory__c == null && curMaterial.Territory__c != null)
            {
                if(curMaterial.Territory__c == 'US & CDN')
                    newRelease.Territory__c = 'US';
                else
                    newRelease.Territory__c = curMaterial.Territory__c;
            }
        }
        if(createNew)
        {
            
            if(newRelease.Brand_Group__c == null && currentUser.Brand_Group__c != null)
            {
                newRelease.Brand_Group__c = currentUser.Brand_Group__c;
                if(brandDefaultProjectTypeMap.containsKey(newRelease.Brand_Group__c))
                    newRelease.Project_Type__c = brandDefaultProjectTypeMap.get(newRelease.Brand_Group__c);
            }
            
        }
    }
    
    // This method fetches the child items for a chain.
    public void fetchChildItems()
    {
        showMaterialTreePanel = false;
        rootMatIds = '';
        hasDifferentTerritory();
        if(callFromConstructor)
            callFromConstructor = false;
        
        if(!Utility.isEmpty(materialObj.release__c)){
            disableSave = false;
            showMaterialTreePanel = true;
            autoPopulateNewRelease();
            rootFERTs = new List<MaterialFERTWrapper>();
            rootIns = new PaginationHandler();
            rootIns.assignRecordList(rootFERTs);
            rootIns.pageSize = 8;
        }
        else
        {
            return;
        }
        
         
        isCalled += 1;
        rootMatIds = '';
        
        Map<Id, Boolean> relMatIds = new Map<Id, Boolean>();
        for(Release_Material__c relMat : [SELECT Material__c, Release__r.Territory__c FROM Release_Material__c 
                                          WHERE Release__c=:materialObj.release__c AND Material__r.Material_Type__c='FERT' and Material__r.Do_Not_Clone__c = false]) //USST-2687
        {
            relMatIds.put(relMat.Material__c, true);
        }
        
        for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c
                               FROM BOM_Item__c 
                               WHERE Material__c IN :relMatIds.keySet() AND Material_Component__c IN :relMatIds.keySet() and Material__r.Do_Not_Clone__c = false and Material_Component__r.Do_Not_Clone__c = false]) //USST-2687
        {
            if(relMatIds.containsKey(bom.Material_Component__c))
                relMatIds.put(bom.Material_Component__c, false);
        }
        
        for(Id matId : relMatIds.keySet())
        {
            if(relMatIds.get(matId))
            {
                if(rootMatIds.trim() != '')
                    rootMatIds += ';';
                rootMatIds += matId;
            }
        }
        System.debug('----rootMatIds> '+rootMatIds);
        sobjectType = 'Release__c';
        recordID = materialObj.release__c;
        getExistingBOMTree();
    }
    
    // This method returns the availble actions to the page.
    public List<SelectOption> getAction() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('CreateNewRelease','Create New Release')); 
        options.add(new SelectOption('SelectExistingRelease','Select Existing Release')); 
        return options; 
    }
    
    // This method decides whether to show Release section in page or not.
    public void showReleasePanel(){

        if(useExistingReleaseFlag.equalsIgnoreCase('CreateNewRelease')){
            //prepare a release object
            Release__c newRelease = new Release__c(Promotion_Name_Abbreviation__c=null);
            createNew = true;
            autoPopulateNewRelease();
          }else{
              createNew =false;
          }
    }
    
    // It prepares the BOM Items.
    private void prepareNewBOMItems()
    {
        System.debug('----rootMatIds> '+rootMatIds);
        Set<String> selectedMatIds = new Set<String>(selectedMaterialIds.split(';'));
        Set<String> associatedMaterialIds = new Set<String>();
        for(String matId : rootMatIds.split(';'))
        {
            if(selectedMatIds.contains(matId))
                associatedMaterialIds.add(matId);
        }
        fetchCompleteBOMHierarchy(associatedMaterialIds, selectedMatIds, 1);
    }
    
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : This method fetches complete BOM Hierarchy according to selction of source.
    ***************************************************************/
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    private Set<String> processedMatIds = new Set<String>();
    private List<BOM_Item__c> insertableBOMItems = new List<BOM_Item__c>();
    
    private void fetchCompleteBOMHierarchy(Set<String> processingMaterialIds, Set<String> selectedMatIds, Integer level)
    {
        Set<String> nextLevelProcessingMaterialIds = new Set<String>();
        Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
        for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Component_Quantity__c, Costing_Flag__c, Production_Flag__c, 
                               Component_Number__c, BOM_Item_Text_1__c, BOM_Item_Text_2__c, Unit_of_Measure__c, Item_Category__c, Sales_Flag__c, BOM_Integration_State__c,BOM_Quantity__c
                               FROM BOM_Item__c
                               WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                   Material_Component__c NOT IN :processedMatIds AND Material_Component__c IN :selectedMatIds])
        {
            if(!matBomMap.containsKey(bom.Material__c))
                matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
            matBomMap.get(bom.Material__c).add(bom);
        }
        
        // Fetch the child materials from BOM Items.
        for(Material__c mat : [SELECT Id
                               FROM Material__c
                               WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes])
        {
            processedMatIds.add(mat.Id);
            
            // Preparing T BOM Items for first level. // Added for RE-13
            if(level == 1 && rootMatTBomMap.get(mat.Id) != null && rootMatTBomMap.get(mat.Id).size() > 0)
            {
                //Looping over related T BOM Item records
                for(BOM_Item__c bom : rootMatTBomMap.get(mat.Id))
                {
                    if(!originalToCloneMap.containsKey(bom.material__c))
                        continue;
                    BOM_Item__c bom1 = bom.clone();
                    bom1.BOM_Function__c = '009';
                    bom1.material__c = originalToCloneMap.get(bom.material__c);
                    bom1.Component_Quantity__c = bom.Component_Quantity__c ;
                    insertableBOMItems.add(bom1);
                }
            }
            
            if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
            {   
                //Looping over related BOM Item records
                for(BOM_Item__c bom : matBomMap.get(mat.Id))
                {
                    if(!childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c) && !processedMatIds.contains(bom.Material_Component__c))
                    {
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                    }
                    
                    if(!originalToCloneMap.containsKey(bom.material__c) && !originalToCloneMap.containsKey(bom.Material_Component__c))
                        continue;
                    
                    BOM_Item__c bom1 = new BOM_Item__c();
                    bom1.material__c = (originalToCloneMap.containsKey(bom.material__c) ? originalToCloneMap.get(bom.material__c) : bom.material__c);
                    bom1.Material_Component__c = (originalToCloneMap.containsKey(bom.Material_Component__c) ? originalToCloneMap.get(bom.Material_Component__c) : bom.Material_Component__c); 
                    bom1.Component_Quantity__c = bom.Component_Quantity__c;
                    bom1.Component_Number__c = bom.Component_Number__c;
                    bom1.BOM_Item_Text_1__c = bom.BOM_Item_Text_1__c;
                    bom1.BOM_Item_Text_2__c = bom.BOM_Item_Text_2__c;
                    bom1.Unit_of_Measure__c = bom.Unit_of_Measure__c;
                    bom1.Item_Category__c = bom.Item_Category__c;
                    bom1.Costing_Flag__c = bom.Costing_Flag__c;
                    bom1.Production_Flag__c = bom.Production_Flag__c;
                    bom1.Sales_Flag__c = bom.Sales_Flag__c;
                    bom1.BOM_Integration_State__c = bom.BOM_Integration_State__c;
                    bom1.BOM_Quantity__c = bom.BOM_Quantity__c;
                        
                    insertableBOMItems.add(bom1);
                }
            }
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0)
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds, selectedMatIds, (level + 1));
    }
    
    private Map<Id, MaterialFERTWrapper> materialWrapperMap = new Map<Id, MaterialFERTWrapper>();
    private Map<Id, Set<Id>> materialChildMap = new Map<Id, Set<Id>>();
    private Set<Id> processedMatIds2 = new Set<Id>();
    private static final string FERT_MATERIAL_TYPE = 'FERT';
    
    /*****************************************************************
    Method Name: getExistingBOMTree
    Purpose : getting entire Material tree
    ***************************************************************/
    private void getExistingBOMTree()
    {
        Set<Id> associatedMaterialIds = new Set<Id>();
        Set<Id> releaseMaterialsIds = new Set<Id>();
        processedMatIds2.clear();
        rootFERTs = new List<MaterialFERTWrapper>();
        rootIns = new PaginationHandler();
        rootIns.assignRecordList(rootFERTs);
        rootIns.pageSize = 8;
            
        if(sobjectType.equalsIgnoreCase('Release__c') && string.valueof(recordID) != null)
        {
            Map<Id, Boolean> relMatIds = new Map<Id, Boolean>();
                        System.Debug('Check entry in release');
            
            //getting all FERT for the release
            for(Release_Material__c relMat : [SELECT Material__c, Material__r.Material_Type__c FROM Release_Material__c 
                                              WHERE Release__c=:recordID and Material__r.Do_Not_Clone__c = false]) //USST-2687
            {
                if(relMat.Material__r.Material_Type__c == 'FERT')
                    relMatIds.put(relMat.Material__c, true);
                releaseMaterialsIds.add(relMat.Material__c);
            }
            
            //identifying top level FERT
            for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c
                                   FROM BOM_Item__c 
                                   WHERE Material__c IN :relMatIds.keySet() AND Material_Component__c IN :relMatIds.keySet() and Material__r.Do_Not_Clone__c = false and Material_Component__r.Do_Not_Clone__c = false]) //USST-2687
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
        else if(sobjectType.equalsIgnoreCase('Material__c') && string.valueof(recordID) != null)
        {
            System.Debug('Check entry in material');
            associatedMaterialIds.add(recordID);
        }
        System.debug('----associatedMaterialIds> '+associatedMaterialIds);
        hasItemCodeIssue = false;
        hasTerritoryIssue = false;
        chainBreakingFERTs.clear();    // Added for RE-13
        rootMatTBomMap.clear();
        //fetching all material details
        fetchCompleteBOMHierarchy(associatedMaterialIds, releaseMaterialsIds, 1);
        
        if(chainBreakingFERTs.size() > 0)
        {
            if(hasTerritoryIssue)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Child FERTs must support both territory to be cloned.'));
            if(hasItemCodeIssue)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Material with Item Code: X1, X2, X3 cannot be cloned.'));
        }
        
        for(Id matId : associatedMaterialIds)
        {
            materialWrapperMap.get(matId).wizardType = 'release';
            materialWrapperMap.get(matId).levelOfDepth = 1;
        }
        
        //relating parent FERT to child FERT
        prepareCompleteBOMHierarchy(associatedMaterialIds, releaseMaterialsIds);
        
        //adding all records to a list of wrapper type
        for(Id matId : associatedMaterialIds)
            rootFERTs.add(materialWrapperMap.get(matId));
        System.debug('*******rootIns> '+rootIns.getData());
        System.debug('*******rootFERTs> '+rootFERTs);
    }
    
    /*****************************************************************
    Method Name: prepareCompleteBOMHierarchy
    Purpose : relating parent FERT to child FERT
    ***************************************************************/
    private void prepareCompleteBOMHierarchy(Set<Id> processingMaterialIds, Set<Id> releaseMaterialsIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        
        //looping over all FERT
        for(Id matId : processingMaterialIds)
        {
            //if material id present in child map
            if(materialChildMap.containsKey(matId) && materialChildMap.get(matId).size() > 0)
            {   
                //adding all key id to a set for using in recursive call
                if(releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || releaseMaterialsIds.contains(matId))
                    nextLevelProcessingMaterialIds.addAll(materialChildMap.get(matId));
                
                //looping over values
                for(Id childMatId : materialChildMap.get(matId))
                {   
                    //linking parent FERT to child FERT
                    if(materialWrapperMap.get(matId) != null && materialWrapperMap.get(childMatId) != null && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                       releaseMaterialsIds.contains(childMatId))){
                        MaterialFERTWrapper matIns = materialWrapperMap.get(childMatId);
                        matIns.wizardType = 'release';
                        matIns.levelOfDepth = materialWrapperMap.get(matId).levelOfDepth + 1;
                        materialWrapperMap.get(matId).childFERTs.add(matIns);
                    }    
                }
            }
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0){
            prepareCompleteBOMHierarchy(nextLevelProcessingMaterialIds, releaseMaterialsIds);
        }    
    }
    
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : setting FERT level details
    ***************************************************************/
    Set<String> ignoreItemCodes = new Set<String>{'X1 - OLD TV SINGLE EPISODES', 'X2 - OLD TV: MULTI LEGAL TITLES', 'X3 - OLD TV BOX SET'};
    Set<String> deselectCompItemCodes = new Set<String>{'PG - PACKAGING'};
    Boolean hasItemCodeIssue = false;
    Boolean hasTerritoryIssue = false;
    Set<Id> chainBreakingFERTs = new Set<Id>();
    // Added for RE-13
    public Map<Id, List<BOM_Item__c>> rootMatTBomMap {get; private set;} {rootMatTBomMap = new Map<Id, List<BOM_Item__c>>();}
    
    private void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds, Set<Id> releaseMaterialsIds, Integer level)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        Map<Id, Set<BOM_Item__c>> matBomMap = new Map<Id, Set<BOM_Item__c>>(); //USST-2763
        Map<Id, BOM_Item__c> childMatBOMMap = new Map<Id, BOM_Item__c>(); //USST-2763
        Set<Id> tempSetMatIds = new Set<Id>(); //USST-2763
        Set<Id> setNeverReleasedMats = new Set<Id>(); //USST-2763
        for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Material_Component__r.Territory__c, Material_Component__r.Item_type__c,
                                Material_Component__r.Component_Type__c, Material_Component__r.Name,Material_Component__r.Release__c,Material_Component__r.Material_Number__c, Material_Component__r.Item_Code__c, 
                                Material_Component__r.UPC__c,Material_Component__r.Material_Status__c,Component_Quantity__c,Material_Component__r.MPM_Issue__c,Material_Component__r.Sales_Planning_Group__c,
                                Material_Component__r.Subformat__c, Material_Component__r.BOM_Long_Text__c,Material_Component__r.Count_Sales_for_D_Chain_Status__c 
                                FROM BOM_Item__c
                                WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND
                                    Material_Component__c NOT IN :processedMatIds2 AND Material_Component__c != null AND 
                                    Material_Component__r.Deletion_Flag__c=false 
                                    ]) // Added ORDER BY for RE-21
                                    //USST-2357 Order Issue
        {
            if(!matBomMap.containsKey(bom.Material__c))
                matBomMap.put(bom.Material__c, new Set<BOM_Item__c>()); //USST-2763
            matBomMap.get(bom.Material__c).add(bom);
            childMatBOMMap.put(bom.Material_Component__c, bom); //USST-2763
        }
        //USST-2763 --- start
        for (ID tempId : matBomMap.keySet()) {
            for (BOM_Item__c tempBom: matBomMap.get(tempId)) {
                tempSetMatIds.add(tempBom.Material_Component__c);
            }
        }
        if (!tempSetMatIds.isEmpty()) {
            for (Sales__c sales : [Select id,Material__c,D_Chain_Spec__c from Sales__c where material__c in: tempSetMatIds]) {
                if (sales.D_Chain_Spec__c == 'XX - Never Released') {
                    setNeverReleasedMats.add(sales.Material__c);
                }
            }   
        }
        if (!setNeverReleasedMats.isEmpty()) {
            for (ID tempchildId : setNeverReleasedMats) {
                for (Id ParentId : matBomMap.keySet()) {
                    matBomMap.get(ParentId).remove(childMatBOMMap.get(tempchildId));
                }
            }
            
        }
        //USST-2763 --- end
        // Fetching T-BOM Items for the first level only. Added for RE-13
        if(level == 1)
        {
            for(BOM_Item__c bom : [SELECT Id, Material__c, BOM_Item_Text_1__c, Component_Quantity__c, Item_Category__c, Production_Flag__c, 
                                   Unit_of_Measure__c, BOM_Quantity__c, Usage_Rate__c  
                                   FROM BOM_Item__c WHERE Material__c IN :processingMaterialIds AND Item_Category__c='T'
                                   ORDER BY CreatedDate])
            {
                if(!rootMatTBomMap.containsKey(bom.Material__c))
                    rootMatTBomMap.put(bom.Material__c, new List<BOM_Item__c>());
                rootMatTBomMap.get(bom.Material__c).add(bom);
            }
        }
        
        // Fetch the child materials from BOM Items.
        for(Material__c mat : [SELECT Id, Name, Item_Type__c, Item_Code__c, Title__c, Title__r.SGENNO__c, Format_Description__c,
                               Material_Type__c, Retailer_Rental__c, BOM_Quantity__c, Component_Type__c, Territory__c,Release__c, Material_Number__c,UPC__c,Material_Status__c,
                               MPM_Issue__c,Sales_Planning_Group__c,Subformat__c,BOM_Long_Text__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, Label_Code__c, Product_Class__c    
                                FROM Material__c
                               WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes]) //USST-3021
        {
            //adding processed materials to a set
            processedMatIds2.add(mat.Id);
            
            //adding FERT ID to map
            if(!materialChildMap.containsKey(mat.Id))
                materialChildMap.put(mat.Id, new Set<Id>());
            
            //setting details for FERT instance
            MaterialFERTWrapper matIns = new MaterialFERTWrapper(null, '', null);
            matIns.instance = mat;
            matIns.isExisting = true;
            if(mat.Title__c != null){
                matIns.sysgenNo = mat.Title__r.SGENNO__c;
                
                if(!setTitleID.contains(mat.Title__c)){
                    setTitleID.add(mat.Title__c);
                }                   
            }
            
            if(mat.Item_Code__c != null && ignoreItemCodes.contains(mat.Item_Code__c))
            {
                chainBreakingFERTs.add(mat.Id);
                matIns.isDisabled = true;
                matIns.isSelected = false;
                hasItemCodeIssue = true;
            }
            
            // Checking if parent FERT has already broken the chain.
            if(chainBreakingFERTs.contains(mat.Id))
            {
                matIns.isDisabled = true;
                matIns.isSelected = false;
            }
            // If chain not yet broken and current material does not support both territory, break the chain.
            else if(level > 1 && (mat.Territory__c == null || mat.Territory__c != 'US & CDN') && sobjectType != null && 
                    (sobjectType.equalsIgnoreCase('Release__c') || (sobjectType.equalsIgnoreCase('Material__c') && 
                     ((createStandAloneMaterial && mat.Territory__c != matTempIns.Territory__c) || 
                      (!createStandAloneMaterial && mat.Territory__c != newRelease.Territory__c)))))
            {
                chainBreakingFERTs.add(mat.Id);
                matIns.isDisabled = true;
                matIns.isSelected = false;
                hasTerritoryIssue = true;
            }
            
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
                        MaterialComponentWrapper comp = new MaterialComponentWrapper(null, null);
                        comp.instance.Id = bom.Material_Component__c;
                        comp.instance.Name = bom.Material_Component__r.Name;
                        comp.instance.Material_Type__c = bom.Material_Component__r.Material_Type__c;
                        comp.instance.Component_Type__c = bom.Material_Component__r.Component_Type__c;
                        comp.instance.Association_Required__c = false;
                        comp.instance.UPC__c = bom.Material_Component__r.UPC__c;
                        comp.instance.Material_Number__c = bom.Material_Component__r.Material_Number__c;
                        comp.instance.Material_Status__c = bom.Material_Component__r.Material_Status__c;
                        comp.instance.Territory__c = bom.Material_Component__r.Territory__c;
                        comp.instance.Subformat__c = bom.Material_Component__r.Subformat__c;
                        comp.instance.Sales_Planning_Group__c = bom.Material_Component__r.Sales_Planning_Group__c;
                        comp.instance.BOM_Long_Text__c = bom.Material_Component__r.BOM_Long_Text__c;
                        comp.instance.MPM_Issue__c = bom.Material_Component__r.MPM_Issue__c;
                        comp.instance.Item_type__c = bom.Material_Component__r.Item_type__c;
                        comp.instance.Item_Code__c = bom.Material_Component__r.Item_Code__c;
                        comp.isExisting = true;
                        comp.isExistingRecord = true;
                        comp.instance.Release__c = bom.Material_Component__r.Release__c;
                        if(chainBreakingFERTs.contains(mat.Id))
                        {
                            comp.isDisabled = true;
                            comp.isSelected = false;
                        }
                        // Added for RE-21
                        else if(deselectCompItemCodes.contains(comp.instance.Item_Code__c))
                        {
                            comp.isSelected = false;
                        }
                        if (hideChildren == false) //USST-2911
                            matIns.childComponents.add(comp);
                    }
                    // If FERT material not previously processed. FERT to FERT mapping
                    else if(!processedMatIds2.contains(bom.Material_Component__c) && (releaseMaterialsIds == null || releaseMaterialsIds.size() == 0 || 
                            releaseMaterialsIds.contains(bom.Material_Component__c)))
                    {   
                        //for recursive call adding FERT id to a set
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                        
                        //mapping parent FERT and Child FERT IDs
                        materialChildMap.get(mat.Id).add(bom.Material_Component__c);
                        
                        if(chainBreakingFERTs.contains(mat.Id))
                            chainBreakingFERTs.add(bom.Material_Component__c);
                    }
                }
            }
            
            //map of material records
            materialWrapperMap.put(mat.Id, matIns);
        }
        
        //recursive call
        if(nextLevelProcessingMaterialIds.size() > 0){
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds, releaseMaterialsIds, (level + 1));
        }    
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
    
    
    /************************************************************************************************************
    Method Name: createUpdateMaterial
    Purpose : USST-2546 Create Update Material for ROH and Z009 components and extend territory when cloned.
    **************************************************************************************************************/
    public static void createUpdateMaterial(Set<Id> lstCreateUpdateMatIds){
    system.debug('I am in createUpdateMaterial--' +lstCreateUpdateMatIds.size() );
        Material__c matCopy;
        List<Material__c> lstInsertMat = new List<Material__c>();
        List<Id> lstUpdateMatIDs = new List<Id>();
        
        Id recordtypeId=Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        String qry = 'Select '+ getFieldsSOQL('Material__c') +' from Material__c where id IN : lstCreateUpdateMatIds';
        List<Material__c> lstUpdateMats = Database.query(qry);
        
        for (Material__c oldMat : lstUpdateMats) {
            matCopy = oldMat.clone(false,false,false,false);
            matCopy.Name = oldMat.Name;
            matCopy.Material_status__c='Draft';
            matCopy.Brand_Group__c = '';
            matCopy.RecordTypeId = recordtypeId;
            matCopy.Original_Material_Number__c = oldMat.id;
            matCopy.Material_Number__c = oldMat.Material_Number__c;
            system.debug('I am coming here---'+oldMat.Material_Number__c + '----'+ oldMat.id);
            matCopy.BOM_Integration_State__c = '';
            matCopy.BOM_Function__c = '';
            matCopy.Function__c = '004';
            matCopy.Material_Integration_State__c='';
            matCopy.OwnerId =userinfo.getUserId();
            matCopy.Material_Description_Unique__c = '';
            matCopy.Record_Type_Filter__c = 'Update';
            System.debug('##insertableSales'+matcopy);
            lstInsertMat.add(matCopy);
            
        }
            
        if (!lstInsertMat.isEmpty()) {
            insert lstInsertMat;
            for (Material__c matCopy1 : lstInsertMat) {
                materialUpdateMap.put(matCopy1.Original_Material_Number__c,matCopy1.id);  
                lstUpdateMatIDs.add(matCopy1.Id);
            }
        }

        createChildViews(lstUpdateMats);
        
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
        
        if (!lstUpdateMatIDs.isEmpty()) {       
            updateComponentsTerritory(lstUpdateMatIDs);
        }
        

    }
    
    /***************************************************
    Method Name: getFieldsSOQL
    Purpose:USST-2546 to get all creatable fields
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
    Method Name: createChildViews
    Purpose: USST-2546 code to create child views for udpate material
    ****************************************************/
    public static void createChildViews(List<Material__c> lstUpdateMats){
        if(checkChildView){
            return;
        }
        checkChildView =true;
        createSalesClone(lstUpdateMats);
        createValuationClone(lstUpdateMats);
        createAltUnitMeasClone(lstUpdateMats);
        createClassificationClone(lstUpdateMats);
        createPlantClone(lstUpdateMats);
    }
    
    
     /***************************************************
    Method Name: createSalesClone
    Purpose: USST-2546 to create clone of sales record
    ****************************************************/
    public static void createSalesClone(List<Material__c> lstUpdateMats){
        String qry='Select '+ getFieldsSOQL('Sales__c')+' from Sales__c where material__c in:lstUpdateMats';
        System.debug('qry'+qry);
        for(Sales__c sales:Database.query(qry)){
            if((materialUpdateMap.containsKey(sales.material__c)) || test.isRunningTest()){
                Sales__c salesClone=sales.clone(false,false,false,false);
                System.debug('##createSalesClone'+sales.material__c);
                salesClone.material__c=materialUpdateMap.get(sales.material__c);
                System.debug('##createSalesClone_Material'+materialUpdateMap.get(sales.material__c));
                salesClone.Function__c = '004';
                insertableSales.add(salesClone);
            }
        }

    }

    /***************************************************
    Method Name: createPlantClone
    Purpose: USST-2546 to create clone of plant record
    ****************************************************/
    public static void createPlantClone(List<Material__c> lstUpdateMats){
        List<String> validPlants = new List<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738
        Map<ID, Set<String>> mapMatValidPlants = new Map<ID, Set<String>> (); //USST-2793
        String qry='Select '+ getFieldsSOQL('Plant__c')+' from Plant__c where material__c in:lstUpdateMats and Plant__c in:validPlants'; //USST-2738
        //USST-2793 --- start
        for (Material__c mat : lstUpdateMats) {
            mapMatValidPlants.put(mat.Id, new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'});
        }
        //USST-2793 --- end
        for(Plant__c plant:Database.query(qry)){
            if (mapMatValidPlants.get(plant.material__c) != null && mapMatValidPlants.get(plant.material__c).contains(String.valueOf(plant.Plant__c))) { //USST-2793
                if((materialUpdateMap.containsKey(plant.material__c)) || test.isRunningTest()){
                    Plant__c plantClone=plant.clone(false,false,false,false);
                    plantClone.material__c=materialUpdateMap.get(plant.material__c);
                    plantClone.Function__c = '004';
                    insertablePlant.add(plantClone);
                }
                mapMatValidPlants.get(plant.material__c).remove(String.valueOf(plant.Plant__c)); //USST-2793
            }
        }

    }

    /***************************************************
    Method Name: createClassificationClone
    Purpose: USST-2546 to create clone of classification record
    ****************************************************/
    public static void createClassificationClone(List<Material__c> lstUpdateMats){
        String qry='Select '+ getFieldsSOQL('Classification__c')+' from Classification__c where material__c in:lstUpdateMats';

        for(Classification__c cls:Database.query(qry)){
            if((materialUpdateMap.containsKey(cls.material__c)) || test.isRunningTest()){
                Classification__c clsClone=cls.clone(false,false,false,false);
                clsClone.material__c=materialUpdateMap.get(cls.material__c);
                clsClone.Function__c = '004';
                insertableClassification.add(clsClone);
            }
        }

    }

    /***************************************************
    Method Name: createAltUnitMeasClone
    Purpose: USST-2546 to create clone of alternate unit of measure record
    ****************************************************/   
    public static void createAltUnitMeasClone(List<Material__c> lstUpdateMats){
        String qry='Select '+getFieldsSOQL('Alternative_Unit_of_Measure__c')+' from Alternative_Unit_of_Measure__c where material__c in:lstUpdateMats';

        for(Alternative_Unit_of_Measure__c auom : Database.query(qry)){
            if((materialUpdateMap.containsKey(auom.material__c)) || test.isRunningTest()){
                Alternative_Unit_of_Measure__c auomClone=auom.clone(false,false,false,false);
                auomClone.material__c=materialUpdateMap.get(auom.material__c);
                auomClone.Function__c = '004';
                insertableAUoMs.add(auomClone);
            }
        }

    }
    
    /***************************************************
    Method Name: createValuationClone
    Purpose: USST-2546 to create clone of valuation record
    ****************************************************/
    public static void createValuationClone(List<Material__c> lstUpdateMats){
        List<String> validValuations = new List<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738
        Map<ID, Set<String>> mapMatValidValuations = new Map<ID, Set<String>> (); //USST-2793
        String qry='Select '+ getFieldsSOQL('Valuation__c')+' from Valuation__c where material__c in:lstUpdateMats and Valuation_Area__c in:validValuations'; //USST-2738
        //USST-2793 --- start
        for (Material__c mat : lstUpdateMats) {
            mapMatValidValuations.put(mat.Id, new Set<String>{'V000', 'V300', 'V400', 'V500', 'V750', 'V850'});
        }
        //USST-2793 --- end
        for(Valuation__c val:Database.query(qry)){
            if (mapMatValidValuations.get(val.material__c) != null && mapMatValidValuations.get(val.material__c).contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
                if((materialUpdateMap.containsKey(val.material__c)) || test.isRunningTest()){
                    Valuation__c valClone=val.clone(false,false,false,false);
                    valClone.material__c=materialUpdateMap.get(val.material__c);
                    valClone.Function__c = '004';
                    insertableVals.add(valClone);
                }
                mapMatValidValuations.get(val.material__c).remove(String.valueOf(val.Valuation_Area__c)); //USST-2793
            }
        }

    }
    
    /***************************************************************
    Method Name: updateComponentsTerritory
    Purpose: USST-2546 to update the territory of update component
    ***************************************************************/
    @future
    public static void updateComponentsTerritory(List<Id> componentIdList) {
        List<Material__c> componentList = [SELECT Id, Territory__c, Material_status__c, Material_Integration_State__c FROM Material__c where Id IN : componentIdList];
        List<ComponentExtensionOnClone__c> compSettings= [Select checkFromComponentExtension__c from ComponentExtensionOnClone__c where Name = 'ExecutingComponentClone'];
        if(!componentList.isEmpty()) {
             for (Material__c mt : componentList) {
                 mt.Territory__c = 'US & CDN';
                 mt.Material_status__c = 'Approved';
                 mt.Material_Integration_State__c = 'N';
             }
             for (ComponentExtensionOnClone__c comp : compSettings) {
                comp.checkFromComponentExtension__c = TRUE;
             } 
             update compSettings;
             
             update componentList; 
             
             
             TriggerUtility.checkFromCloning = true;
             DefaultingHandler.fromCloning  = true;  
             DefaultingHandler.processingMaterials = componentList;
             DefaultingHandler.isExecutingAdditionalDefaulting = true;
             DefaultingHandler.fetchCompleteDefaultData();
            
             //populating default for sales record
             DefaultingHandler.populateSalesAdditionalDefaultValues(); 
             
            
             //populating default for plant record
             DefaultingHandler.populatePlantAdditionalDefaultValues();   
            
             //populating default for classification
             DefaultingHandler.populateClassificationAdditionalDefaultValues();
            
             //populating default for alternative unit of measure
             DefaultingHandler.populateAUoMAdditionalDefaultValues();
            
             //populating default for valuation
             DefaultingHandler.populateValuationAdditionalDefaultValues(); 
            
             TriggerUtility.checkFromCloning = true;
             
             for (ComponentExtensionOnClone__c comp : compSettings) {
                comp.checkFromComponentExtension__c = FALSE;
             } 
             update compSettings;
         }
    }
}