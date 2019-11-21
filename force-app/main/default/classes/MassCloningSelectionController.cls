/*****************************************************************************************
Class Name: MassCloningSelectionController
Purpose: Apex class for MassCloningSelection VF page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             04/10/2016           Suman                         Initial Development
1.0             07/20/2017           Pravin/Dinakar           Added code for USST-2260
2.0             18/9/2017            Suman/Jyothsna           made changes for REL-40
******************************************************************************************/
public without sharing class MassCloningSelectionController {   // Changed for REL-40

    /****private static variables****/

    /****private variables****/
    private set<ID> setAlreadyAdded;
    private Set<string> setManualAdd;
    private List<string> lstManualAdd; //DF-02187
    private string SOQL;
    private ID releaseID{get;set;}   
    private List<BOM_Item__c> lstBOMItem;
    private List<Material__c> lstAllAddedMaterials;
    public user userDetail {get; private set;}
    public Boolean hasError {get; set;} //REL-40

    /****public variables****/    
    public string searchCriteria {get;set;}
    public string manualAddCriterial {get;set;}
    public Blob csvFileBody {get;set;}
    public string csvAsString {get;set;}
    public string csvContentType {get;set;}
    public Release__c releaseDetails {get;set;}
    public List<Material__c> lstSelectedMaterials {get;set;}
    public string operationTypeParam{get;set;}
    public Boolean paginationAvailable{get;set;}
    public Boolean selectedPaginationAvailable{get;set;}
    public Boolean errorPaginationAvailable{get;set;}
    public Boolean errorPaginationSelection{get;set;} //REL-40
    public Boolean showPageBlock{get;set;}
    public String[] csvFileLines{get;set;}
    public Boolean showAccept{get;set;}
    public ID paramMaterialID{get;set;}
    public ID paramID{get;set;}
    public Boolean showMaterialSection{get;set;}
    public List<Material__c> lstSelectedMaterial{get;set;}
    public integer mtRowNumber{get;set;}
    public integer selectedRowNumber{get;set;}
    public integer pageSize{get;set;} 
    public Set<Material__c> lstSuccessMat{get;set;}
    public Set<Material__c> lstFailureMat{get;set;}
    public Set<Material__c> lstSuccessMat1{get;set;}
    public Set<Material__c> lstFailureMat1{get;set;}
    public List<Material__c> lstMaterialDetails{get;set;}
    public Boolean matListView {get; set;}
    public Boolean shouldStampOldMatNo {get; set;}
    private Set<String> targetTerritories;
    public Map<Id, Material__c> finalMaterials {get; set;}
    private Boolean isFromCSV;  //DF-02187
    Map<String, String> originalToCloneMap = new Map<String, String>();
    List<Material__c> tmpAllSearchedMaterials = new List<Material__c>();
    public Material__c tempMat {get; set;} {tempMat = new Material__c();}    // Added for RE-56
    public List<ErrorMessage> errorMessages {get; set;} //REL -40
    public PaginationHandlerForError errorPagination {get;set;} // REL-40    
    public List<ErrorMessage> errorMessagesSelection {get; set;} //REL -40
    public PaginationHandlerForError errorPaginationSelect {get;set;} // REL-40  
    public Set<String> errorMaterialNos {get;set;} // REL-40  
    
    public Map<Id, Set<Id>> globalMaterialChildMap  = new Map<Id, Set<Id>>();
    public Integer globalcomponentcount;
    ApexPages.StandardSetController availableCon;
    ApexPages.StandardSetController selectedCon;
    Set<String> ignoreItemCodes = new Set<String>{'X1 - OLD TV SINGLE EPISODES', 'X2 - OLD TV: MULTI LEGAL TITLES', 'X3 - OLD TV BOX SET'};
    Boolean hasItemCodeIssue = false;
    
    /************************************
    Method Name: MassCloningSelectionController
    Purpose: Constructor
    *************************************/   
    public MassCloningSelectionController() {
        try {
            //Initializing variables
            shouldStampOldMatNo = TRUE;
            paginationAvailable = FALSE;
            errorPaginationAvailable = FALSE;
            errorPaginationSelection = FALSE;  //REL-40
            showPageBlock = FALSE;            
            showAccept =FALSE;            
            selectedPaginationAvailable = FALSE;
            pageSize = 20;
            showMaterialSection = FALSE;
            matListView = FALSE;
            //Initializing collection
            lstAllAddedMaterials = new List<Material__c>();
            setAlreadyAdded = new Set<ID>();      
            releaseDetails = new Release__c();
            lstSelectedMaterials = new List<Material__c>();
            lstSelectedMaterial = new List<Material__c>();
            targetTerritories = new Set<String>();
            isFromCSV = FALSE; //DF-02187
            errorMessages = new List<ErrorMessage>(); //REL-40
            errorPagination = new PaginationHandlerForError();    //REL-40
            errorPagination.assignRecordList(errorMessages);  //REL-40
            
            errorMessagesSelection = new List<ErrorMessage>(); //REL-40
            errorPaginationSelect = new PaginationHandlerForError();    //REL-40
            errorPaginationSelect.assignRecordList(errorMessagesSelection);  //REL-40
            
            lstFailureMat = new Set<Material__c>();
            lstSuccessMat = new Set<Material__c>();
            lstFailureMat1 = new Set<Material__c>();
            lstSuccessMat1 = new Set<Material__c>();
            
            errorMaterialNos = new Set<String>(); //REL-40
            
            //Initializing standard set controller
            availableCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
            selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
            
            //getting material id from parameter
            releaseID = apexpages.currentpage().getparameters().get('releaseId');
            
            //getting user details
            userDetail = [SELECT Id, Label_Code__c, ProfileID, Profile.Name 
                          FROM User WHERE Id=:userinfo.getUserId()];
            
            //getting parent material details
            if (string.valueof(releaseID) != null && string.valueof(releaseID) != '') {
                releaseDetails = [SELECT Id, Name, Title__c, Territory__c,Number_of_Materials__c, Street_Date__c, Brand_Group__c, Project_Type__c, Promotion_Name_Abbreviation__c, Release_Status__c 
                                  FROM Release__c 
                                  WHERE Id=:releaseID LIMIT 1];
                targetTerritories.add('US & CDN');
                if (releaseDetails != null && releaseDetails.Territory__c != null && releaseDetails.Territory__c.trim() != '') {
                    targetTerritories.add(releaseDetails.Territory__c);
                }
                else {
                    targetTerritories.add('US');
                }
                
                if (releaseDetails.Release_Status__c == 'Cancelled') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'This action cannot be performed on a Cancelled Release.'));              
                } 
                else {
                  showPageBlock = true;
                }
            }
            else {
                matListView =TRUE;
            }
        } catch (exception ex) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }    
    }
    
    /************************************
    Method Name: btnSearch
    Purpose: called on click of search button 
    *************************************/  
    public pageReference btnSearch() {
        try {
            //Initializing collection and variables
            SOQL = '';
            manualAddCriterial = '';
            isFromCSV = FALSE; //DF-02187
            lstMaterialDetails = new List<Material__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            
            //checking if search text not blank
            if (String.isNotBlank(searchCriteria)) {
                searchCriteria = String.escapeSingleQuotes(searchCriteria);
                SOQL = 'SELECT Id, Name, SGENNO__c, Material_Number__c, Material_Type__c, Territory__c, Item_Code__c FROM Material__c ';
                SOQL += 'WHERE (Name LIKE ' + '\'%' + searchCriteria.trim() + '%\'';
                SOQL += ' OR SGENNO__c LIKE ' + '\'%' + searchCriteria.trim() + '%\'';
                SOQL += ' OR Material_Number__c LIKE ' + '\'%' + searchCriteria.trim() + '%\')';
                SOQL += 'AND recordTypeId !=\''+ recordTypeId+'\'';
                SOQL += ' AND Material_Type__c=\'FERT\'';    // Switched comment for REL-152 
                SOQL += ' AND Do_Not_Clone__c=false'; //USST-2687
                if (targetTerritories != null && targetTerritories.size() > 0) {
                    SOQL += ' AND Territory__c IN :targetTerritories';  //REl-40 // Uncommented due to REL-152
                }
                SOQL += ' ORDER BY Name Limit 1000';
                
                //calling set controller method
                availableConRecordQuery();
            }
            //if no search text entered
            else { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please provide Search Criteria.'));   
            }
        } 
        catch (exception ex) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact system admin. '+ex.getMessage()));              
        }    
        return null;    
    }
    
    /************************************
    Method Name: btnManualAdd
    Purpose: if manual add button is used
    *************************************/  
    public pageReference btnManualAdd() {
        try {
            //initializing variables and collection
            setManualAdd = new Set<String>();
            SOQL = '';
            searchCriteria = '';
            isFromCSV = FALSE; //DF-02187
            lstMaterialDetails = new List<Material__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            //if manual add field is not blank
            if (string.isNotBlank(manualAddCriterial)) {
                //splitting the search criteria by comma
                List<string> lstTemp = manualAddCriterial.split(',');
                
                //creating a set of search criteria
                for (string s : lstTemp) {
                    setManualAdd.add(s.trim());
                }
                
                //if set not empty
                if (!setManualAdd.isEmpty()) {
                    SOQL = 'SELECT Id, Name, SGENNO__c, Material_Number__c, Material_Type__c, Territory__c, Item_Code__c FROM Material__c ';
                    SOQL += 'WHERE Material_Number__c IN :setManualAdd ';
                    SOQL += 'AND recordTypeId !=\''+ recordTypeId+'\'';
                    SOQL += ' AND Material_Type__c=\'FERT\' AND Do_Not_Clone__c=false';    // Switched comment for REL-152 //USST-2687 
                    if (targetTerritories != null && targetTerritories.size() > 0) {
                        SOQL += ' AND Territory__c IN :targetTerritories'; //REl-40 // Uncommented due to REL-152
                    }
                    SOQL += ' ORDER BY Name LIMIT 1000';
                    
                    //calling set controller method
                    availableConRecordQuery();
                }
            } 
            else {                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please provide Unique Identifier'));   
            }
        } 
        catch (exception ex) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact system admin. '+ex.getMessage()));              
        }   
        return null;    
    }    
    
    /************************************
    Method Name: btnUploadCSV
    Purpose: if file upload is used
    *************************************/  
    public pageReference btnUploadCSV() {
        try {
            //Initializing variables and collections
            csvFileLines = new String[]{};
            setManualAdd = new Set<String>();
            lstManualAdd = new List<String>(); //DF-02187
            List<String> tempLstManualAdd = new List<String>();
            isFromCSV = TRUE; //DF-02187
            SOQL = '';
            searchCriteria = '';
            manualAddCriterial = '';
            lstMaterialDetails = new List<Material__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            //reading csv file
            if (string.valueof(csvFileBody) != null && string.valueof(csvFileBody) != '') {
                csvAsString = csvFileBody.toString();
            } 
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.')); 
                return null;  
            }    
            
            csvFileLines = csvAsString.split('\n');
            //USST-2982  start
            IF(csvFileLines.size()>56){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Number of materials in CSV had increased the limit of 55.')); 
            return null; 
            }
            //USST-2982  Stop
            //looping over csv file and adding criteria to a set
            for (Integer i = 1; i < csvFileLines.size(); i ++) {                
                string[] csvRecordData = csvFileLines[i].split(',');
                tempLstManualAdd.add((csvRecordData[0]).trim().replaceAll('"', '')); //DF-02187
            }
            for (String str: tempLstManualAdd) {
                if (!String.isBlank(str)) {
                    lstManualAdd.add(str);
                }   
            }
            
            //if set not empty
            if (!lstManualAdd.isEmpty()) {      
                SOQL = 'SELECT Id, Name, SGENNO__c, Material_Number__c, Material_Type__c, Territory__c, Item_Code__c FROM Material__c ';
                SOQL += 'WHERE Material_Number__c IN :lstManualAdd ';
                SOQL += 'AND recordTypeId !=\''+ recordTypeId+'\'';
                SOQL += ' AND (Material_Type__c=\'FERT\' OR Material_Type__c=\'ROH\' OR Material_Type__c=\'Z009\') AND Do_Not_Clone__c=false'; //REL-40 //USST-2687
                SOQL += ' ORDER BY Name LIMIT 1000';
                
                //calling set controller method
                availableConRecordQuery();
                
                //DF-02187----------------START
                Map<string,Material__c> mapMatNo = new Map<string,Material__c>();
                for (Material__c mat : MassCloningUtility.fetchMaterials(lstManualAdd)) {    // Changed for REL-40
                    if (!mapMatNo.containsKey(mat.Material_Number__c)) {
                        mapMatNo.put(mat.Material_Number__c,mat);
                    }
                }
                
                for (String s : lstManualAdd) {
                    if (mapMatNo.containsKey(s) && !errorMaterialNos.contains(s)) {  //REL-40
                        tmpAllSearchedMaterials.add(mapMatNo.get(s));
                    }                    
                }
                errorMaterialNos.clear();  //REL-40
              
                System.Debug('List values ## '+tmpAllSearchedMaterials);
                //DF-02187-----------------END
                
                if (lstMaterialDetails != null && lstMaterialDetails.size() > 0) {
                    isMethodAutoCalled = true;
                    Integer i = 0;
                    for (Material__c mat : tmpAllSearchedMaterials) {
                        mtRowNumber = i ++;
                        paramID = mat.Id;
                        setSelectedMaterial();
                    }
                    isMethodAutoCalled = false;
                }
                tmpAllSearchedMaterials.clear();     
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please upload valid file.'));   
            } 
        }
        catch (exception ex) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }         
        return null;    
    }
    
    /***********************************
    Method Name: selectAllAvailableMaterials
    Purpose: Selects all materials in the available list.
    ***********************************/
    public void selectAllAvailableMaterials() {
        if (lstMaterialDetails != null && lstMaterialDetails.size() > 0) {
            Integer i = 0;
            for (Material__c mat : lstMaterialDetails) {
                mtRowNumber = i ++;
                paramID = mat.Id;
                setSelectedMaterial();
            }
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There is no in material available list.'));
        }
    }
    
    /************************************
    Method Name: setSelectedMaterial
    Purpose: add selected material
    *************************************/    
    private Boolean isMethodAutoCalled = false;
    public pageReference setSelectedMaterial() {  
        //if record has not already been selected
        if (!setAlreadyAdded.contains(paramID)) {
            if ((isMethodAutoCalled && tmpAllSearchedMaterials[mtRowNumber].Material_Type__c != null && childMaterialTypes.contains(tmpAllSearchedMaterials[mtRowNumber].Material_Type__c)) || 
               (!isMethodAutoCalled && lstMaterialDetails[mtRowNumber].Material_Type__c != null && childMaterialTypes.contains(lstMaterialDetails[mtRowNumber].Material_Type__c))) {
                if (!isMethodAutoCalled) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Components cannot be cloned. Please unselect any components.'));
                }
                return null;
            }
            
            //adding selected record to a list
            if (isMethodAutoCalled) {
                if (ignoreItemCodes.contains(tmpAllSearchedMaterials[mtRowNumber].Item_Code__c)) {
                    return null;
                }
                lstAllAddedMaterials.add(tmpAllSearchedMaterials[mtRowNumber]);
            } 
            else {
                if (ignoreItemCodes.contains(lstMaterialDetails[mtRowNumber].Item_Code__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Material with Item Code: X1, X2, X3 cannot be cloned.'));
                    return null;
                }
                lstAllAddedMaterials.add(lstMaterialDetails[mtRowNumber]);
            }
            //adding selected record id to a set
            setAlreadyAdded.add(paramID);
            //displaying accept button
            showAccept = TRUE;  
            
            //Setting set controller
            selectedCon = new ApexPages.StandardSetController(lstAllAddedMaterials);  
            selectedCon.setPageSize(pageSize);
            
            //calling selected compnent set controller method
            selectedConRecordSet();          
        } 
        else {
            if (!isMethodAutoCalled) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Record already added.'));
            }
        }  
        return null;        
    }
    
    /************************************
    Method Name: removeSelectedMaterial
    Purpose: remove selected material
    *************************************/ 
    public pageReference removeSelectedMaterial() {
        //remove record from set  
        setAlreadyAdded.remove(paramID);   
        
        //removing record from master list
        for (integer i=0;i<lstAllAddedMaterials.size();i++) {
            if (lstAllAddedMaterials[i].id == paramID) {
                lstAllAddedMaterials.remove(i);
            }            
        }   
        
        //setting values in set controller
        selectedCon = new ApexPages.StandardSetController(lstAllAddedMaterials);  
        selectedCon.setPageSize(pageSize);
        
        //calling set controller method
        selectedConRecordSet();
        
        //if list size 0 then hiding accept button
        if (lstSelectedMaterial.size() == 0) {
            showAccept = FALSE;
        }
        return null;
    }
    
    /************************************
    Method Name: submit
    Purpose: saving selected records
    *************************************/ 
    public pageReference submit() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (rootMaterialIds != null && rootMaterialIds.size() > 0) {
                errorMessages.clear();
                hasError = false;
                TriggerUtility.checkFromCloning = TRUE;
                TriggerUtility.followMaterialNamingConvension = FALSE;
                TriggerUtility.checkFromMassCloneIn = TRUE;    // Added for REL-40

                
                Set<String> fieldsToIgnore = new Set<String>();
                fieldsToIgnore.add('Material_Number__c');
                fieldsToIgnore.add('ID');
                fieldsToIgnore.add('Id');
                fieldsToIgnore.add('Material_Status__c');
                fieldsToIgnore.add('BOM_Number__c');
                fieldsToIgnore.add('BOM_Status__c');
                fieldsToIgnore.add('UPC__c');
                fieldsToIgnore.add('Cross_Ref__c');
                fieldsToIgnore.add('Deletion_Flag__c');
                fieldsToIgnore.add('Theatrical_Release_Date__c');
                fieldsToIgnore.add('VOD_Street_Date__c');
                fieldsToIgnore.add('Windowed_Rental_Pre_Order_Close_Date__c');
                fieldsToIgnore.add('Windowed_Rental_Street_Date__c');
                fieldsToIgnore.add('Brand_Group__c');
                fieldsToIgnore.add('BOM_Integration_State__c');
                fieldsToIgnore.add('Material_Integration_State__c');
                
                fieldsToIgnore.add('material_number__c');
                fieldsToIgnore.add('material_status__c');
                fieldsToIgnore.add('bom_number__c');
                fieldsToIgnore.add('bom_status__c');
                fieldsToIgnore.add('upc__c');
                fieldsToIgnore.add('cross_ref__c');
                fieldsToIgnore.add('deletion_flag__c');
                fieldsToIgnore.add('theatrical_release_date__c');
                fieldsToIgnore.add('vod_street_date__c');
                fieldsToIgnore.add('windowed_rental_pre_order_close_date__c');
                fieldsToIgnore.add('windowed_rental_street_date__c');
                fieldsToIgnore.add('brand_group__c');
                fieldsToIgnore.add('bom_integration_state__c');
                fieldsToIgnore.add('material_integration_state__c');
                fieldsToIgnore.add('MPM_Issue__c');
                fieldsToIgnore.add('Sales_Planning_Group__c');
                fieldsToIgnore.add('Subformat__c');
                fieldsToIgnore.add('mpm_issue__c');
                fieldsToIgnore.add('subformat__c');
                fieldsToIgnore.add('sales_planning_group__c');
                fieldsToIgnore.add('total_item_qty__c');
                fieldsToIgnore.add('Total_Item_Qty__c');
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
                // Added for RE-56
                String globalRetailerRental = '';
                if (tempMat != null && tempMat.Retailer_Rental__c != null && tempMat.Retailer_Rental__c.trim() != '') {
                    fieldsToIgnore.add('retailer_rental__c');
                    fieldsToIgnore.add('Retailer_Rental__c');
                    
                    globalRetailerRental = tempMat.Retailer_Rental__c;
                }
                
                List<String> selectedMatIds = new List<String>();
                for (Id matId : rootMaterialIds) {
                    selectedMatIds.add(matId);
                }
                
                // Below cloned list will have 'clonehelperfield__c' populated and will be equal to the object id from where it is cloned
                List<SObject> clonedMatList;
                clonedMatList = Utility.cloneMaterialList(selectedMatIds, fieldsToIgnore, releaseDetails.Id);
                Id reqRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
                String bomTextRegEx = Label.SpecialCharacters_Regex;
                Pattern MyPattern = Pattern.compile(bomTextRegEx);
                Matcher MyMatcher;
                String message;
                system.debug('clonedMatList-----'+clonedMatList);
                // Iterate on cloned materials and collect deal with its title.
                Set<Id> dealIds = new Set<Id>();
                for (SObject obj : clonedMatList) {
                    if (obj.get('Deal__c') != null) {
                        dealIds.add(String.valueOf(obj.get('Deal__c')));
                    }
                }
                Map<Id, Deal__c> dealMap = new Map<Id, Deal__c>([SELECT Id, Title__c FROM Deal__c WHERE Id IN: dealIds]);
                String dealsHavingIssue = '';
                Boolean hasDealIssue = false;
                
                List<SObject> clonedMatList1 = new List<SObject>(); //REL-40
                Set<Material__c> failedClonedMatList = new Set<Material__c>();
                Boolean isObjHasError = false;
                for (SObject obj : clonedMatList) {
                    isObjHasError = false;
                    if (obj.get('clonehelperfield__c') != null && finalMaterials.containsKey(String.valueOf(obj.get('clonehelperfield__c')))) {
                        obj.put('Name', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Name);
                        
                        if (obj.get('Deal__c') != null && obj.get('Title__c') != null && dealMap.containsKey(String.valueOf(obj.get('Deal__c'))) &&
                           dealMap.get(String.valueOf(obj.get('Deal__c'))).Title__c != null && dealMap.get(String.valueOf(obj.get('Deal__c'))).Title__c != obj.get('Title__c')) {
                            isObjHasError = true;
                            hasError = true;
                            ErrorMessage msg = new ErrorMessage();
                            msg.materialDescription = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Name;
                            msg.OriginalMaterialNumber = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Material_Number__c;
                            msg.errorMessage = 'This is not a valid deal for this title, please select again for material(s):' + obj.get('Name');
                            errorMessages.add(msg);
                            failedClonedMatList.add((Material__c)obj);
                            
                        }
                        if (userDetail.Label_Code__c == '59 - Paramount' && (finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c == null || 
                           finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c == '')) {
                            
                            hasError = true;
                            isObjHasError = true;
                            ErrorMessage msg = new ErrorMessage();
                            msg.materialDescription = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Name;
                            msg.OriginalMaterialNumber = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Material_Number__c;
                            msg.errorMessage = 'MPM cannot be left blank.';
                            errorMessages.add(msg);
                                              
                            failedClonedMatList.add((Material__c)obj);
                        }
                        
                        obj.put('MPM_Issue__c', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).MPM_Issue__c);
                        obj.put('Sales_Planning_Group__c', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Sales_Planning_Group__c);                     
                        obj.put('Subformat__c', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Subformat__c);
                        obj.put('Material_Description_Unique__c', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Name);
                        
                        if (shouldStampOldMatNo) {
                            obj.put('Old_Material_No__c', obj.get('clonehelperfield__c'));
                            // Added for RE-24
                            if (finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Material_Number__c != null) {
                                obj.put('Old_Material_Load__c', finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Material_Number__c);
                            }
                        }
                        
                        // Added for RE-56
                        if (globalRetailerRental != '') {
                            obj.put('Retailer_Rental__c', globalRetailerRental);
                        }
                        
                        if (finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c != null && 
                            MyPattern.matcher(finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c).find()){
                            message=finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).BOM_Long_Text__c;
                            obj.put('BOM_Long_Text__c', message.replaceAll(bomTextRegEx, ''));
                        }
                        //added following if condition for REL-201
                        if(finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Item_Type__c == 'M (Multipack)' && 
                           finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Item_Code__c == 'MT - MULTI-TITLE' && 
                           ((materialWrapperMap.get(finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Id)).childFERTs == null ||
                            (materialWrapperMap.get(finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Id)).childFERTs.size() == 0) && 
                           finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Id == null) { //Added id == null condition for USST-2745
                                hasError = true;
                                isObjHasError = true;
                                ErrorMessage msg = new ErrorMessage();
                                msg.materialDescription = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Name;
                                msg.OriginalMaterialNumber = finalMaterials.get(String.valueOf(obj.get('clonehelperfield__c'))).Material_Number__c;
                                msg.errorMessage = 'For item type M and item code MT, baby FERT material is mandatory.';
                                errorMessages.add(msg);
                                             
                                failedClonedMatList.add((Material__c)obj);  
                            }  
                    }
                    obj.put('Material_Status__c', 'Draft');
                    obj.put('BOM_Status__c', 'Draft');
                    obj.put('Brand_Group__c',null);
                    obj.put('RecordTypeId', reqRecordTypeId);
                    obj.put('Cloned__c', True); //USST-2786
                    //USST-2980 --- start
                    if (obj.get('Item_Type__c') == 'S (Single)' || obj.get('Item_Type__c') == 'M (Multipack)') {
                        obj.put('Material_Expiration_Date__c',Date.valueOf('3333-12-31'));              
                    }
                    //USST-2980 --- end
                    if (releaseDetails.Territory__c != null) {
                        obj.put('Territory__c', releaseDetails.Territory__c);
                    }
                     
                    if (releaseDetails.Street_Date__c != null && String.valueof(releaseDetails.Street_Date__c) != '') {
                        obj.put('Street_Date__c', releaseDetails.Street_Date__c);
                    }
                    if (releaseDetails.Title__c != null && obj.get('Material_Type__c') != null && 
                       String.valueOf(obj.get('Item_Type__c')) != 'M (Multipack)' && String.valueOf(obj.get('Item_Type__c')) != 'D (Display Vehicle)') { //USST-3010
                        obj.put('Title__c', releaseDetails.Title__c);
                    }
                    //REL - 40  
                    if (!isObjHasError) {
                        clonedMatList1.add(obj);
                    }   
                }
                
                //Added for the defect # 2260    
                List<Material__c> vLstMat = new List<Material__c>();
                                              
                for (Material__c vMat: reviewMaterials) {
                    for (sObject vObj: clonedMatList1) {
                        if (vMat.Id == vObj.get('CloneHelperField__c')) {
                            vLstMat.add((Material__c)vObj);
                            system.debug('vLstMat'+vObj);
                        }
                    }
                }
                
                //REL - 40
                checkDuplicateMaterialDescription(vLstMat);
                
                if (lstSuccessMat != null && lstSuccessMat.size() > 0 ) {
                    checkDuplicateMaterialUPC(lstSuccessMat);
                }
                List<sObject> lstSuccessVmat = new List<sObject>();
                List<Material__c> lstFailedVmat = new List<Material__c>();
                List<Material__c> lstinsertMat = new List<Material__c>();
                lstinsertMat.addAll(lstSuccessMat1);
                Database.SaveResult[] srList = Database.insert(lstinsertMat, false);
                
                Integer cnt = -1;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        cnt = cnt + 1;
                        lstSuccessVmat.add(lstinsertMat.get(cnt));
                    } 
                    else {
                        cnt = cnt + 1;
                        lstFailedVmat.add(lstinsertMat.get(cnt));
                        hasError = true;
                        String msg = '';
                        Material__c tempMat = lstinsertMat.get(cnt);
                        for(Database.Error err : sr.getErrors()) {
                            msg = err.getMessage()+' ';
                        }
                        ErrorMessage msg1 = new ErrorMessage();
                        msg1.materialDescription = tempMat.Material_Description_Unique__c;
                        msg1.OriginalMaterialNumber = tempMat.Old_Material_Load__c;
                        msg1.errorMessage = msg;
                        errorMessages.add(msg1);
                        
                    }
                }   
                      
                clonedMatList.clear();
                reviewMaterials.clear();
                clonedMatList.addAll(lstSuccessVmat);
                if (lstFailedVmat != null && lstFailedVmat.size() > 0) {
                    tempReviewMaterials.addAll(lstFailedVmat);
                }
                if (lstFailureMat != null && lstFailureMat.size() > 0) {
                    tempReviewMaterials.addAll(lstFailureMat);
                }
                if (lstFailureMat1 != null && lstFailureMat1.size() > 0) {
                    tempReviewMaterials.addAll(lstFailureMat1);
                }
                if (failedClonedMatList != null && failedClonedMatList.size() > 0) {
                    tempReviewMaterials.addAll(failedClonedMatList);
                }
                
                // Repopulating remaining failure materials.
                for (Material__c eMat : tempReviewMaterials) {
                    if(eMat.clonehelperfield__c != null && finalMaterials.get(eMat.clonehelperfield__c) != null) {
                        reviewMaterials.add(finalMaterials.get(eMat.clonehelperfield__c));
                    }
                }
                
                // Updating Old Material Number again to override defaulting.
                if (shouldStampOldMatNo && clonedMatList != null && clonedMatList.size() > 0) {
                    List<Material__c> updateableMats = new List<Material__c>();
                    for (Material__c clonedObj : (List<Material__c>)clonedMatList) {
                        Material__c uMat = new Material__c();
                        uMat.Id = clonedObj.Id;
                        uMat.Old_Material_No__c = clonedObj.Old_Material_No__c;
                        uMat.Old_Material_Load__c = clonedObj.Old_Material_Load__c;    // Added for RE-24
                        updateableMats.add(uMat);
                    }
                    
                    TriggerUtility.doNotExecute = true;
                    update updateableMats;
                    TriggerUtility.doNotExecute = false;
                }
                
                //Prepare map of orginal to cloned material id
                originalToCloneMap.clear();
                if (clonedMatList != null && clonedMatList.size() > 0) {
                    for (Material__c clonedObj : (List<Material__c>)clonedMatList) {
                        if (clonedObj.CloneHelperField__c != null) {
                            originalToCloneMap.put(clonedObj.CloneHelperField__c, clonedObj.Id);
                        }
                    }
                }
                
                // Change for REL-113
                releaseMaterialIds.clear();
                getStructureMaterialIds(originalToCloneMap.keySet(), 1);
                
                // Create Release Materials for all the existing materials.
                if (releaseMaterialIds.size() > 0) {
                    List<Release_Material__c> insertableReleaseMaterials = new List<Release_Material__c>();
                    for (Id matId : releaseMaterialIds) {
                        Release_Material__c relMaterial = new Release_Material__c();
                        relMaterial.Release__c = releaseDetails.Id;
                        relMaterial.Material__c = matId;
                        insertableReleaseMaterials.add(relMaterial);
                    }
                    
                    insert insertableReleaseMaterials;
                }
                
                List<BOM_Item__c> insertableBomItems = new List<BOM_Item__c>();
                // Create BOM Items for direct childs only
                if (parentChildMaterialsMap.size() > 0) {
                    for (Id matId : parentChildMaterialsMap.keySet()) {
                        if (!originalToCloneMap.containsKey(matId)) {
                            continue;
                        }
                        
                        for (BOM_Item__c bom : parentChildMaterialsMap.get(matId)) {
                            bom.Material__c = originalToCloneMap.get(matId);
                            insertableBomItems.add(bom);
                        }
                    }
                }
                
                // Added for RE-13    
                // Preparing T-BOM Items
                if (rootMatTBomMap.size() > 0) {
                    for (Id rMatId : rootMaterialIds) {
                        if (originalToCloneMap != null && originalToCloneMap.containsKey(rMatId) && rootMatTBomMap.get(rMatId) != null) {
                            //Looping over related T BOM Item records
                            for (BOM_Item__c bom : rootMatTBomMap.get(rMatId)) {
                                if (!originalToCloneMap.containsKey(bom.material__c)) {
                                    continue;
                                }
                                BOM_Item__c bom1 = bom.clone();
                                bom1.BOM_Function__c = '009';
                                bom1.material__c = originalToCloneMap.get(bom.material__c);
                                insertableBOMItems.add(bom1);
                            }
                        }
                    }
                }
                
                if (insertableBomItems.size() > 0) {
                    insert insertableBomItems;
                    Set<Id> rootMatIds = new Set<Id>();
                    for (Id rMatId : rootMaterialIds) {
                        if(originalToCloneMap != null && originalToCloneMap.containsKey(rMatId))
                            rootMatIds.add(originalToCloneMap.get(rMatId));
                    }
                    // Added for RE-17
                    if (rootMatIds.size() > 0) {
                        RSUCalculationHandler.updateMaterialTreeAsync(rootMatIds, false);
                    }
                }
                
                System.debug('hasError:'+ hasError);
                clonedMatList.clear();
                clonedMatList1.clear();
                lstSuccessMat.clear();
                lstFailureMat.clear();
                lstSuccessMat1.clear();
                lstFailureMat1.clear();
                failedClonedMatList.clear();
                tempReviewMaterials.clear();
                
                if (hasError) {
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please find the below errors.'));
                } 
                else { // Redirect to Release detail page.
                    return new PageReference('/' + releaseDetails.Id);
                }   
            }
        } 
        catch (DMLException dEx) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact System Administrator.'+dEx.getDmlMessage(0)));
        } 
        catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please contact System Administrator.'+ex.getMessage()));
        }
        return null;
    }
    
    // Following method fetches the material Ids in a structure to be added in release. For REL-113
    Set<Id> processedMaterialIds = new Set<Id>();
    private void getStructureMaterialIds(Set<String> currentMatIds, Integer depth) {
        Set<String> nextLevelProcessingMaterialIds = new Set<String>();
        for (Id matId : currentMatIds) {
            if (materialWrapperMap.get(matId) != null) {
                if (depth > 1) {
                    releaseMaterialIds.add(matId);
                }
                MaterialFERTWrapper matIns = materialWrapperMap.get(matId);
                processedMaterialIds.add(matId);
                
                // Iterating over components.
                if (matIns.childComponents != null && matIns.childComponents.size() > 0) {
                    for (MaterialComponentWrapper comp : matIns.childComponents) {
                        releaseMaterialIds.add(comp.instance.Id);
                    }
                }
                
                // Iterating over FERTs
                if (matIns.childFERTs != null && matIns.childFERTs.size() > 0) {
                    for (MaterialFERTWrapper mat : matIns.childFERTs) {
                        if (!processedMaterialIds.contains(mat.instance.Id)) {
                            nextLevelProcessingMaterialIds.add(mat.instance.Id);
                        }
                    }
                }
            }
        }
        
        // Call itself recursively.
        if (nextLevelProcessingMaterialIds.size() > 0) {
            getStructureMaterialIds(nextLevelProcessingMaterialIds, ++ depth);
        }
    }
    
    /************************************
    Method Name: finalizeSelection
    Purpose: Following method is responsible to finalize the material selection and find the BOM Hierarchy
    ************************************/
    Set<Id> rootMaterialIds = new Set<Id>();
    Set<Id> releaseMaterialIds = new Set<Id>();
    Map<Id, List<BOM_Item__c>> parentChildMaterialsMap = new Map<Id, List<BOM_Item__c>>();
    public List<Material__c> reviewMaterials {get; set;}
    public Set<Material__c> tempReviewMaterials {get; set;}
    
    public PageReference finalizeSelection() {
    
        if (!lstSelectedMaterial.isEmpty()) {
            rootMaterialIds.clear();
            materialWrapperMap.clear();
            materialChildMap.clear();
            processedMatIds2.clear();
            releaseMaterialIds.clear();
            parentChildMaterialsMap.clear();
            rootMatTBomMap.clear();    // Added for RE-13
            finalMaterials = new Map<Id, Material__c>();
            reviewMaterials = new List<Material__c>();
            tempReviewMaterials = new Set<Material__c>();
            
            for (Material__c mat : lstAllAddedMaterials) {
                rootMaterialIds.add(mat.Id);
            }
            //USST-2982  start
            if (rootMaterialIds.size() > 0) {
                Integer counter = 0;
                fetchCompleteBOMHierarchy(rootMaterialIds, 1);
                
                counter = counter + globalMaterialChildMap.keySet().size() + globalcomponentcount;
                if((counter + releaseDetails.Number_of_Materials__c +globalcomponentcount ) > 800){
                 Integer allowedmaterials = 0;
                 allowedmaterials = 800 - integer.valueof(releaseDetails.Number_of_Materials__c);
                system.debug('globalcomponentcount'+globalcomponentcount);
                system.debug('globalMaterialChildMap.keySet().size()'+globalMaterialChildMap.keySet().size());
                system.debug('releaseDetails.Number_of_Materials__c'+releaseDetails.Number_of_Materials__c);
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Total number of materials are exceeding the 800 MAX limit. Materials already existing : '+releaseDetails.Number_of_Materials__c+ ' Allowed number of material to add : ' +allowedmaterials));
                 return null;
                }
           //USST-2982  stop    
                prepareCompleteBOMHierarchy(rootMaterialIds);
                Set<Id> ttlIds = new Set<Id>();
                for (Material__c mat : [SELECT Title__c FROM Material__c WHERE Id IN :rootMaterialIds AND Do_Not_Clone__c=false]) { //USST-2687
                    if (mat.Title__c != null) {
                        ttlIds.add(mat.Title__c);
                    }
                }
                
                // Added for RE-56
                String globalRetailerRental = '';
                if (tempMat != null && tempMat.Retailer_Rental__c != null && tempMat.Retailer_Rental__c.trim() != '') {
                    globalRetailerRental = tempMat.Retailer_Rental__c;
                }
                
                Map<Id, Title__c> ttlMap = new Map<Id, Title__c>([Select Id, Name, SGENNO__c, Street_Date__c, Title_Abbreviation__c, Sort_Name__c 
                                                                  FROM Title__c 
                                                                  WHERE Id IN :ttlIds]);
                
                Map<string,Material__c> mapMatNo = new Map<string,Material__c>();
                List<Material__c> lstTempMat = new List<Material__c>();
                
                for (Material__c mat : [SELECT Id, Name, Material_Type__c, Item_Type__c, Item_Code__c, Format_Description__c, Retailer_Rental__c,
                                       Title__c, Material_Number__c, External_Material_Number__c, Original_Material_Number__c, Territory__c, BOM_Long_Text__c  
                                       FROM Material__c 
                                       WHERE Id IN :rootMaterialIds AND Do_Not_Clone__c=false]) { //commented order by title null for DF-02187 //USST-2687
                    // Added for RE-56
                    if (globalRetailerRental != '') {
                        mat.Retailer_Rental__c = globalRetailerRental;
                    }
                    String tempName = mat.Name;
                    Title__c ttl;
                    if (ttlMap.containsKey(mat.Title__c)) {
                        ttl = ttlMap.get(mat.Title__c);
                    }

                    if(releaseDetails.Territory__c != null) {
                        mat.Territory__c = releaseDetails.Territory__c;
                    }
                    tempName = MaterialNamingConventionHandler.getFERTMaterialName(mat, releaseDetails, ttl);
                    
                    if (mat.Item_Type__c != 'M (Multipack)' || globalRetailerRental != '') {    // Changed for RE-56
                        mat.Name = tempName;
                    }
                    
                    if (!mapMatNo.containsKey(mat.Material_Number__c)) {
                        mapMatNo.put(mat.Material_Number__c,mat);
                    }
                    if (!isFromCSV) {
                        reviewMaterials.add(mat);
                    }
                    System.debug('###Asha - MassClonning BOMText Materials'+mat);     
                    finalMaterials.put(mat.Id, mat);
                }
                if (isFromCSV) {
                    for (String s : lstManualAdd) {
                        if (mapMatNo.containsKey(s)) {
                            reviewMaterials.add(mapMatNo.get(s));
                        }                    
                    }
                }
            }
            
            return Page.MassCloningReview;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select materials to clone.'));
        }
        return null;
    }
    
    /***********************************
    Method Name: redirectPreviousPage
    Purpose: This method is responsible to redirect back to previous selection page
     ***********************************/
        public PageReference redirectPreviousPage() {
            return Page.MassCloningSelection;
        }
    
    /************************************
    Method Name: hasNext 
    Purpose: indicates whether there are more records after the current page set.
    *************************************/     
    public Boolean hasNext {
        get {
            return availableCon.getHasNext();
        }
        set;
    }
    
    /************************************
    Method Name: hasPrevious 
    Purpose: // indicates whether there are more records before the current page set.
    *************************************/    
    public Boolean hasPrevious {
        get {
            return availableCon.getHasPrevious();
        }
        set;
    }
    
    /************************************
    Method Name: pageNumber 
    Purpose: // returns the page number of the current page set
    *************************************/ 
    public Integer pageNumber {
        get {
            return availableCon.getPageNumber();
        }
        set;
    }
    
    /************************************
    Method Name: resultSize
    Purpose: returns total number of records
    *************************************/ 
    public Integer resultSize {
        get {
            return availableCon.getResultSize();
        }
        set;
    }
    
    /************************************
    Method Name: first
    Purpose: returns first page of records
    *************************************/ 
    public void first() {
        availableCon.first();
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
    }
    
    /************************************
    Method Name: last
    Purpose: returns last page of records
    *************************************/ 
    public void last() {
        availableCon.last();
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
    }
    
    /************************************
    Method Name: previous
    Purpose: returns previous page of records
    *************************************/ 
    public void previous() {
        availableCon.previous();
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
    }
    
    /************************************
    Method Name: next
    Purpose: returns next page of records
    *************************************/
    public void next() {
        availableCon.next();
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
    }
    
    /************************************
    Method Name: availableConRecordQuery
    Purpose: sets the available searched records to be displayed
    *************************************/
    private void availableConRecordQuery() {
        //checking type of search activity
        //DF-02187 ------------------------START
        errorMessagesSelection.clear();  //REL - 40
        List<Material__c> lstTempMat = new List<Material__c>();
        List<Material__c> lstTempMat1 = new List<Material__c>();  //REL-40
        if (isFromCSV) {
            Map<string,Material__c> mapMatNo = new Map<string,Material__c>();
            Set<String> availbleMatIds = new Set<String>();
            // Querying as system level permission. // Added for REL-40
            for (Material__c mat : Database.Query(SOQL)) {
                availbleMatIds.add(mat.Material_Number__c);
            }
            
            // Fetching the materials user has access to.
            for (Material__c mat : MassCloningUtility.fetchMaterials(lstManualAdd)) {
                if (!mapMatNo.containsKey(mat.Material_Number__c)) {
                    mapMatNo.put(mat.Material_Number__c,mat);
                }
            }
            
            // System availablility checking. //REL-40
            for (String matNo : lstManualAdd) {
                // If material no. does not belong to the system.
                if (!availbleMatIds.contains(matNo)) {
                    ErrorMessage msg = new ErrorMessage();
                    msg.OriginalMaterialNumber = matNo;
                    msg.errorMessage = 'The material/material number is invalid.';    // Changed
                    errorMessagesSelection.add(msg);  
                } 
                // Material is in system, but not in user permission.
                else if (availbleMatIds.contains(matNo) && !mapMatNo.containsKey(matNo)) { 
                    ErrorMessage msg = new ErrorMessage();
                    msg.OriginalMaterialNumber = matNo;
                    msg.errorMessage = 'User doesnot have access to this material number.';
                    errorMessagesSelection.add(msg);  
                }
            }
            
            for (String s : lstManualAdd) {
                if (mapMatNo.containsKey(s)) {
                    lstTempMat.add(mapMatNo.get(s));
                }                    
            }
        } else {
            //added following code as part of REL - 40
            if (string.isNotBlank(manualAddCriterial)) {
                Map<string,Material__c> tempMapMatNo = new Map<string,Material__c>();
                List<string> lstTemp = new List<String>();
                lstTemp.addAll(setManualAdd);
                Set<String> tempavailbleMatIds = new Set<String>();
                
                // Querying as system level permission. // Added for REL-40
                for (Material__c mat : Database.Query(SOQL)) {
                    tempavailbleMatIds.add(mat.Material_Number__c);
                }
                
                // Fetching the materials user has access to.
                for (Material__c mat : MassCloningUtility.fetchFERTs(lstTemp, targetTerritories)) {    // Changed for REL-152
                    if (!tempMapMatNo.containsKey(mat.Material_Number__c)) {
                        tempMapMatNo.put(mat.Material_Number__c, mat);
                    }
                }
                
                // System availablility checking. //REL-40
                List<string> lstTemp2 = new List<String>();        // Added
                Boolean isErrorneousMat = false;        // Added
                for (String matNo : lstTemp) {
                    isErrorneousMat = false;    // Added
                    // If material no. does not belong to the system.
                    if (!tempavailbleMatIds.contains(matNo)) {
                        isErrorneousMat = true;    // Added
                        ErrorMessage msg = new ErrorMessage();
                        msg.OriginalMaterialNumber = matNo;
                        msg.errorMessage = 'The material number or material is invalid.';    // Changed
                        errorMessagesSelection.add(msg);  
                    } 
                    // Material is in system, but not in user permission.
                    else if (tempavailbleMatIds.contains(matNo) && !tempMapMatNo.containsKey(matNo)) {    
                        isErrorneousMat = true;    // Added
                        ErrorMessage msg = new ErrorMessage();
                        msg.OriginalMaterialNumber = matNo;
                        msg.errorMessage = 'User doesnot have access to this material number.';
                        errorMessagesSelection.add(msg);  
                    }
                    
                    if (!isErrorneousMat) {    // Added
                        lstTemp2.add(matNo);
                    }
                }
                
                lstTempMat = MassCloningUtility.fetchFERTs(lstTemp2, targetTerritories);    // Changed for REL-152
            } 
            else {
                lstTempMat = MassCloningUtility.fetchFERTsForCriteria(searchCriteria, targetTerritories);    // Changed for REL-152
                System.debug('lstTempMat:'+ lstTempMat);
                if (lstTempMat == null || lstTempMat.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'No matching records found.')); 
                }
            }   
        }   
        
        //added following code as part of REL - 40
        Boolean isErrorneousMat = false;
        for (Material__c mat : lstTempMat) {
            isErrorneousMat = false;
            if (mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
            {
                isErrorneousMat = true;
                ErrorMessage msg = new ErrorMessage();
                msg.OriginalMaterialNumber = mat.Material_Number__c;
                msg.errorMessage = 'Components cannot be directly cloned under a Release';
                errorMessagesSelection.add(msg); 
                errorMaterialNos.add(mat.Material_Number__c);
            }
            
            if (!targetTerritories.contains(mat.Territory__c)) {
                isErrorneousMat = true;
                ErrorMessage msg = new ErrorMessage();
                msg.OriginalMaterialNumber = mat.Material_Number__c;
                if(mat.Territory__c == 'US')
                    msg.errorMessage = 'US Materials cannot be cloned in a CDN Release';
                else if(mat.Territory__c == 'CDN')
                    msg.errorMessage = 'CDN Materials cannot be cloned in a US Release';
                errorMessagesSelection.add(msg);
                errorMaterialNos.add(mat.Material_Number__c);
            }
            
            if (!isErrorneousMat) {
                lstTempMat1.add(mat);
            }
        }
        
        availableCon = new ApexPages.StandardSetController(lstTempMat1);   //REL - 40
        availableCon.setPageSize(pageSize);
        
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        //DF-02187 ---------------------------END
        
        
        //based on search type setting Boolean variables
        if (!lstMaterialDetails.isEmpty()) { 
            paginationAvailable = TRUE;
            showMaterialSection = TRUE;
        }
        else {
            paginationAvailable = FALSE;
        }
    }
   
    /************************************
    Method Name: selectedHasNext 
    Purpose: indicates whether there are more records after the current page set.
    *************************************/ 
    public Boolean selectedHasNext {
        get {
            return selectedCon.getHasNext();
        }
        set;
    }
    
    /************************************
    Method Name: selectedHasPrevious 
    Purpose: indicates if there are more recods on current page set
    *************************************/
    public Boolean selectedHasPrevious {
        get {
            return selectedCon.getHasPrevious();
        }
        set;
    }
    
    /************************************
    Method Name: selectedPageNumber 
    Purpose: returns page number of current page set
    *************************************/
    public Integer selectedPageNumber {
        get {
            return selectedCon.getPageNumber();
        }
        set;
    }
    
    /************************************
    Method Name: selectedResultSize
    Purpose: returns total number of records
    *************************************/
    public Integer selectedResultSize{
        get {
            return selectedCon.getResultSize();
        }
        set;
    }
    
    /************************************
    Method Name: selectedFirst
    Purpose: returns first page of records
    *************************************/
    public void selectedFirst() {
        selectedCon.first();
        selectedConRecordSet();
    }
    
    /************************************
    Method Name: selectedLast
    Purpose: returns last page of records
    *************************************/
    public void selectedLast() {
        selectedCon.last();
        selectedConRecordSet();
    }
    
    /************************************
    Method Name: selectedPrevious
    Purpose: returns previous page of records
    *************************************/
    public void selectedPrevious() {
        selectedCon.previous();
        selectedConRecordSet();
    }
    
    /************************************
    Method Name: selectedNext
    Purpose: returns next page of records
    *************************************/
    public void selectedNext() {
        selectedCon.next();
        selectedConRecordSet();
    }
    
    /************************************
    Method Name: selectedConRecordSet
    Purpose: setting set controller for selected records
    *************************************/
    private void selectedConRecordSet(){
        //if search ison material
        List<Material__c> tempList = new List<Material__c>();
        lstSelectedMaterial = new List<Material__c>();
        
        tempList = (List<Material__c>)selectedCon.getRecords();
        lstSelectedMaterial.addall(tempList);            
        
        //setting Boolean variables based on search type
        if (!lstSelectedMaterial.isEmpty()) {
            selectedPaginationAvailable = TRUE;            
        }
        else {
            selectedPaginationAvailable = FALSE;
        }
    }
    
    /************************************
    Method Name: removeAll
    Purpose: clearing all the lists on click of remove all button
    *************************************/
    public pageReference removeAll() {
        lstAllAddedMaterials = new List<Material__c>();
        selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
        lstSelectedMaterial = new List<Material__c>();
        setAlreadyAdded = new Set<ID>();
        selectedPaginationAvailable = FALSE;
        showAccept = FALSE;
        return null;
    }
    
    /************************************
    Method Name: cancelSelection
    Purpose: redirects user to release record
    *************************************/
    
    public pageReference cancelSelection() {
        PageReference pg = new PageReference('/'+releaseDetails.id);  
        return pg;  
    }
    
    /************************************
    Method Name: cancelSelected
    Purpose: redirects user to material list view 
    *************************************/
   
    public pageReference cancelSelected() {
        PageReference pg = new PageReference('/?retURL=/a0V/o');  
        return pg;  
    }
   
    private Map<Id, MaterialFERTWrapper> materialWrapperMap = new Map<Id, MaterialFERTWrapper>();
    private Map<Id, Set<Id>> materialChildMap = new Map<Id, Set<Id>>();
    private Set<Id> processedMatIds2 = new Set<Id>();
    private static final string FERT_MATERIAL_TYPE = 'FERT';
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    
    /*****************************************************************
    Method Name: prepareCompleteBOMHierarchy
    Purpose : relating parent FERT to child FERT
    ***************************************************************/
    private void prepareCompleteBOMHierarchy(Set<Id> processingMaterialIds) {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        
        //looping over all FERT
        for (Id matId : processingMaterialIds) {
            //if material id present in child map
            if (materialChildMap.containsKey(matId) && materialChildMap.get(matId).size() > 0) {   
                //adding all key id to a set for using in recursive call
                nextLevelProcessingMaterialIds.addAll(materialChildMap.get(matId));
                
                //looping over values
                for(Id childMatId : materialChildMap.get(matId)) {   
                    //linking parent FERT to child FERT
                    if(materialWrapperMap.get(matId) != null && materialWrapperMap.get(childMatId) != null){
                        materialWrapperMap.get(matId).childFERTs.add(materialWrapperMap.get(childMatId));
                    }    
                }
            }
        }
        
        if (nextLevelProcessingMaterialIds.size() > 0) {
            prepareCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
        }    
    }
    
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : setting FERT level details
    ***************************************************************/
    // Added for RE-13
    private Map<Id, List<BOM_Item__c>> rootMatTBomMap = new Map<Id, List<BOM_Item__c>>();
    
    private void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds, Integer level) {
        Integer counter = 0;
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        Map<Id, Set<BOM_Item__c>> matBomMap = new Map<Id, Set<BOM_Item__c>>(); //USST-2763
        Map<Id, BOM_Item__c> childMatBOMMap = new Map<Id, BOM_Item__c>(); //USST-2763
        Set<Id> tempSetMatIds = new Set<Id>(); //USST-2763
        Set<Id> setNeverReleasedMats = new Set<Id>(); //USST-2763
        
        for (BOM_Item__c bom : [SELECT Material__c, Material_Component__c, Material_Component__r.Material_Type__c, Component_Number__c, BOM_Item_Text_1__c, BOM_Item_Text_2__c, Unit_of_Measure__c, 
                               Material_Component__r.Component_Type__c, Material_Component__r.Name,Material_Component__r.Release__c,Material_Component__r.Material_Number__c,
                               Material_Component__r.UPC__c, Material_Component__r.Material_Status__c, Component_Quantity__c, Item_Category__c,Material_Component__r.BOM_Long_Text__c 
                               FROM BOM_Item__c
                               WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND Material__r.Item_Code__c NOT IN: ignoreItemCodes AND
                                   Material_Component__c NOT IN :processedMatIds2 AND Material_Component__c != null AND 
                                   Material_Component__r.Deletion_Flag__c=false]) {
            if (!matBomMap.containsKey(bom.Material__c)) {
                matBomMap.put(bom.Material__c, new Set<BOM_Item__c>()); //USST-2763
            }
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
        if (level == 1) {
            for (BOM_Item__c bom : [SELECT Id, Material__c, BOM_Item_Text_1__c, Component_Quantity__c, Item_Category__c, Production_Flag__c, 
                                   Unit_of_Measure__c, BOM_Quantity__c, Usage_Rate__c 
                                   FROM BOM_Item__c WHERE Material__c IN :processingMaterialIds AND Item_Category__c='T'
                                   ORDER BY CreatedDate]) {
                if (!rootMatTBomMap.containsKey(bom.Material__c)) {
                    rootMatTBomMap.put(bom.Material__c, new List<BOM_Item__c>());
                }
                rootMatTBomMap.get(bom.Material__c).add(bom);
            }
        }
        
        // Fetch the child materials from BOM Items.
        for (Material__c mat : [SELECT Id, Name, Item_Type__c, Item_Code__c, Title__c, Title__r.SGENNO__c, Format_Description__c,
                               Material_Type__c, Retailer_Rental__c, BOM_Quantity__c, Component_Type__c, Territory__c,Release__c, Material_Number__c,UPC__c,Material_Status__c,BOM_Long_Text__c
                               FROM Material__c
                               WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes AND Item_Code__c NOT IN: ignoreItemCodes AND Do_Not_Clone__c=false]) { //USST-2687
            //adding processed materials to a set
            processedMatIds2.add(mat.Id);
            
            // Preparing Release Material List
            if (!rootMaterialIds.contains(mat.Id)) {
                releaseMaterialIds.add(mat.Id);
            }
            //adding FERT ID to map
            if (!materialChildMap.containsKey(mat.Id)) {
                materialChildMap.put(mat.Id, new Set<Id>());
            }
            //setting details for FERT instance
            MaterialFERTWrapper matIns = new MaterialFERTWrapper(null, '');
            matIns.instance = mat;
            matIns.isExisting = true;
            if (mat.Title__c != null) {
                matIns.sysgenNo = mat.Title__r.SGENNO__c;
            }
            //checking if related BOM Item records for FERT not null
            if (matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0) {   
                if (rootMaterialIds.contains(mat.Id)) {
                    parentChildMaterialsMap.put(mat.Id, new List<BOM_Item__c>());
                }
                //Looping over related BOM Item records
                for (BOM_Item__c bom : matBomMap.get(mat.Id)) {
                    if (!rootMaterialIds.contains(bom.Material_Component__c)) {
                        releaseMaterialIds.add(bom.Material_Component__c);
                    }
                    if (rootMaterialIds.contains(mat.Id) && parentChildMaterialsMap.containsKey(mat.Id)) {
                        parentChildMaterialsMap.get(mat.Id).add(bom.clone());
                    }
                    // If it is a component material.
                    if (childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c)) {
                        MaterialComponentWrapper comp = new MaterialComponentWrapper();
                        comp.instance.Id = bom.Material_Component__c;
                        comp.instance.Name = bom.Material_Component__r.Name;
                        comp.instance.Material_Type__c = bom.Material_Component__r.Material_Type__c;
                        comp.instance.Component_Type__c = bom.Material_Component__r.Component_Type__c;
                        comp.instance.Association_Required__c = false;
                        comp.instance.UPC__c = bom.Material_Component__r.UPC__c;
                        comp.instance.Material_Number__c = bom.Material_Component__r.Material_Number__c;
                        comp.instance.Material_Status__c = bom.Material_Component__r.Material_Status__c;
                        comp.isExisting = true;
                        comp.isExistingRecord = true;
                        comp.instance.Release__c = bom.Material_Component__r.Release__c;
                        comp.instance.BOM_Long_Text__c = bom.Material_Component__r.BOM_Long_Text__c;
                        matIns.childComponents.add(comp);
                        counter = matIns.childComponents.size();
                        system.debug('matIns.childComponents.size()'+matIns.childComponents.size());
                        system.debug('counter'+counter );
                    }
                    // If FERT material not previously processed. FERT to FERT mapping
                    else if (!processedMatIds2.contains(bom.Material_Component__c)) {   
                        //for recursive call adding FERT id to a set
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                        
                        //mapping parent FERT and Child FERT IDs
                        materialChildMap.get(mat.Id).add(bom.Material_Component__c);
                    }
                }
            }
            
            //map of material records
            materialWrapperMap.put(mat.Id, matIns);
        }
        
        //recursive call
        if(nextLevelProcessingMaterialIds.size() > 0) {
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds, (level + 1));
        }   
        globalMaterialChildMap = materialChildMap;
        globalcomponentcount = counter;
    }
    
    // Material Wrapper class.
    public class MaterialFERTWrapper {
        public Boolean isExistingRecord {get; private set;}
        public Boolean isSelected {get; set;}
        public Material__c instance {
            get; 
            set {
                instance = value;
                if(instance.Id != null) {
                    isExistingRecord = true;
                }
            }
        }
        public String sysgenNo {get; private set;}
        public Boolean isExisting {get; private set;}
        public List<MaterialFERTWrapper> childFERTs {get; set;}
        public List<MaterialComponentWrapper> childComponents {get; set;}
        public string componentQty {get; set;}
        
        public MaterialFERTWrapper(Id titleId, String sysgenNo) {
            instance = new Material__c();
            instance.Title__c = titleId;
            this.sysgenNo = sysgenNo;   
            instance.Material_Type__c = FERT_MATERIAL_TYPE ;
            isExisting = false;
            isExistingRecord = false;
            isSelected = true;
            
            childFERTs = new List<MaterialFERTWrapper>();
            childComponents = new List<MaterialComponentWrapper>();
        }
    }
    
    // Component wrapper class
    public class MaterialComponentWrapper {
        public Boolean isExistingRecord {get; private set;}
        public Boolean isSelected {get; set;}
        public Material__c instance {
            get; 
            set {
                instance = value;
                if (instance.Id != null) {
                    isExistingRecord = true;
                }
            }
        }
        public Boolean isExisting {get; private set;}
        public string componentQty{get;set;}
        
        public MaterialComponentWrapper() {
            instance = new Material__c();
            instance.Material_Type__c = 'ROH';
            isExisting = false;
            isExistingRecord = false;
            isSelected = true;
        }
    }
    // Following class to grab the errorneous material numbers.
    // Added for REL-40
    public class ErrorMessage {
        public String materialDescription {get; set;}
        public String OriginalMaterialNumber {get; set;}
        public String errorMessage {get; set;}
    }
    /************************************************/
    // Method Name: checkDuplicateMaterialDescription
    // Purpose:Checks for Duplicate Material
    // Added for REL-40
    /*************************************************/
    public void checkDuplicateMaterialDescription(List<Material__c> lstMaterials) {
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<string> setMatDesc = new Set<string>();
        List<Material__c> lstDuplicateMaterial = new List<Material__c>();
        Set<String> setDuplicateMat = new Set<String>();   
                
        for (Material__c mat : lstMaterials) {
            if (mat.RecordTypeID != recTypeId) {
                if (!setMatDesc.contains((string.valueof(mat.Name).trim()))) {
                    setMatDesc.add(string.valueof(mat.Name).trim());
                }
                else if (setMatDesc.contains((string.valueof(mat.Name).trim()))) {
                    setDuplicateMat.add((string.valueof(mat.Name).trim()));
                }   
            }                   
        }
        
        if (!setMatDesc.isEmpty()) {
            lstDuplicateMaterial = [SELECT Id, Name FROM Material__c WHERE name in:setMatDesc];
            
            if (!lstDuplicateMaterial.isEmpty()) {
                for (Material__c mat : lstDuplicateMaterial) {
                    if (!setDuplicateMat.contains((string.valueof(mat.Name).trim()))) {
                        setDuplicateMat.add((string.valueof(mat.Name).trim()));
                    }
                }
            }
        }
        
        if (!setDuplicateMat.isEmpty()) {
            for (Material__c mat : lstMaterials) {
                if (mat.RecordTypeID != recTypeId) {
                    if (setDuplicateMat.contains((string.valueof(mat.Name).trim()))) {
                        ErrorMessage msg = new ErrorMessage();
                        msg.materialDescription = mat.Material_Description_Unique__c;
                        msg.OriginalMaterialNumber = mat.Old_Material_Load__c;
                        msg.errorMessage = 'Duplicate material found with description';
                        errorMessages.add(msg);
                        lstFailureMat.add(mat);
                        hasError = true;

                    }
                    else {   
                        lstSuccessMat.add(mat);
                    }
                }
            } 
        }
        else {
            lstSuccessMat.addAll(lstMaterials); 
        }
    }
    /***********************************/
    // Method Name: checkDuplicateMaterialUPC
    // Purpose:Checks for Duplicate Material
    // Added for REL-40
    /***********************************/
    public void checkDuplicateMaterialUPC(Set<Material__c> lstMaterials) {
             
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<string> setMatUPC = new Set<string>();
        List<Material__c> lstDuplicateMaterial = new List<Material__c>();
        Set<String> setDuplicateUPC = new Set<String>();
        
        for (Material__c mat : lstMaterials) {
            Material__c oldMat;
                        
            if (mat.UPC__c != null && mat.UPC__c != '' && mat.RecordTypeID != recTypeId) {
                // Checking in trigger's internal change set
                if (!setMatUPC.contains(mat.UPC__c.trim())) {
                    setMatUPC.add(mat.UPC__c.trim());
                }
                else {   
                    setDuplicateUPC.add(mat.UPC__c.trim());
                }
            }
        }
        
        if (!setMatUPC.isEmpty()) {
            lstDuplicateMaterial = [SELECT ID,UPC__c 
                                    FROM Material__c 
                                    WHERE RecordType.Name <> 'Update' and UPC__c in:setMatUPC limit 1000]; //Added record type check for usst-2460

            if(!lstDuplicateMaterial.isEmpty()) {
                for(Material__c mat : lstDuplicateMaterial) {
                    if(string.valueof(mat.UPC__c) != null && string.valueof(mat.UPC__c)!= '' && !setDuplicateUPC.contains((string.valueof(mat.UPC__c).trim()))) {
                        setDuplicateUPC.add((string.valueof(mat.UPC__c).trim()));
                    }
                }
            }
        }
        
        if (!setDuplicateUPC.isEmpty()) {
             for (Material__c mat : lstMaterials) {
                if (mat.RecordTypeID != recTypeId) {
                    if (setDuplicateUPC.contains(string.valueof(mat.UPC__c))) {
                        ErrorMessage msg = new ErrorMessage();
                        msg.materialDescription = mat.Material_Description_Unique__c;
                        msg.OriginalMaterialNumber = mat.Old_Material_Load__c;
                        msg.errorMessage = 'This UPC is already in use: '+ setDuplicateUPC;
                        errorMessages.add(msg);
                        lstFailureMat1.add(mat);
                        hasError = true;

                    }
                    else {   
                        lstSuccessMat1.add(mat);
                    }
                }
            }  
        }
        else {
            lstSuccessMat1.addAll(lstMaterials);
        }
    }
}