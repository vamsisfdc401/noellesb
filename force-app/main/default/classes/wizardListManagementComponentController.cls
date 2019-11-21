/*****************************************************************************************
Class Name: ListManagementComponentController
Purpose: Apex class for ListManagementComponent VF page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/08/2016           Mohit                    Initial Development
******************************************************************************************/

public with sharing class wizardListManagementComponentController {

    /****private variables****/
    public set<ID> setAlreadyAdded;
    public Set<string> setManualAdd;
    public List<string> lstManualAdd;
    public string SOQL;
    public ID materialID{get;set;}   
    public List<BOM_Item__c> lstBOMItem;
    public List<Material__c> lstAllAddedMaterials;
    public List<Title__c> lstAllAddedTitle;
    public user userDetail;
    public string territoryType;
    public string territoryType1;
    public string territoryType2;
    public List<Material__c> tmpAllSearchedMaterials = new List<Material__c>();
    public List<Title__c> tmpAllSearchedTitles = new List<Title__c>();

    /****public variables****/    
    public integer rdActivityType {get;set;}
    public string searchCriteria{get;set;}
    public string manualAddCriterial {get;set;}
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public string csvContentType{get;set;}
    public Material__c parentMaterialDetails{get;set;}
    public List<Material__c> lstSelectedMaterials{get;set;}
    public string operationTypeParam{get;set;}
    public boolean paginationAvailable{get;set;}
    public boolean selectedPaginationAvailable{get;set;}
    public boolean showPageBlock{get;set;}
    public String[] csvFileLines{get;set;}
    public boolean showAccept{get;set;}
    public ID paramMaterialID{get;set;}
    public ID paramID{get;set;}
    public boolean showMaterialSection{get;set;}
    public boolean showTitleSection{get;set;}
    public List<Material__c> lstSelectedMaterial{get;set;}
    public List<Title__c> lstSelectedTitle{get;set;}
    public integer mtRowNumber{get;set;}
    public integer selectedRowNumber{get;set;}
    public integer pageSize{get;set;} 
    public List<Material__c> lstMaterialDetails{get;set;}
    public List<Title__c> lstTitleDetails{get;set;}
    public boolean enableTitleSearch{get;set;}
    public Boolean closeWindow {get; private set;}
    
    
    private Set<ID> setMatID;
    private Set<ID> setTitleMatID;
    
    private Boolean isFromCSV;    
    
    //REL-10 Clone BOM to Versioned Materials
    private Set<ID> matIds=new Set<ID>();
    private List<Bom_Item__c> bomItemList=new List<Bom_Item__c>();
    public String isClone{get;set;}
    private List<Bom_item__c> bomItemInsertList = new List<Bom_item__c>();
    private String currMaterialId;
    private Set<ID> clonedToSet = new Set<ID>();
    private boolean isSuccess;
    private Material__c currentMat;
    private Map<Id, List<Bom_item__c>> bomExistingMap = new Map<Id,List<Bom_item__c>>();
    private Boolean componentMismatch;//REL-90
        
    //REL-18 Bom
    public Map<String,String> matQtyMap{get;set;}
    private Boolean invalidData; //REL-98 Additional logic to show error msg
    
        
    ApexPages.StandardSetController availableCon;
    ApexPages.StandardSetController selectedCon;
    
    /************************************
    Method Name: ListManagementComponentController
    Purpose: Constructor
    *************************************/   
    public wizardListManagementComponentController(){
        try{
            //Initializing variables
            rdActivityType = 1;
            paginationAvailable = FALSE;
            showPageBlock = FALSE;            
            showAccept =FALSE;            
            selectedPaginationAvailable = FALSE;
            pageSize = 20;
            showMaterialSection = FALSE;
            showTitleSection = FALSE;
            enableTitleSearch = TRUE;
            closeWindow = false;
            isFromCSV = FALSE;
            isClone='false';//REL-10
                        
            
            //Initializing collection
            lstAllAddedMaterials = new List<Material__c>();
            setAlreadyAdded = new Set<ID>();
            lstAllAddedTitle = new List<Title__c>();
            lstSelectedTitle = new List<Title__c>();            
            parentMaterialDetails = new Material__c();
            lstSelectedMaterials = new List<Material__c>();
            lstSelectedMaterial = new List<Material__c>();
            
            setTitleMatID = new Set<ID>();
            setMatID = new Set<ID>();
            
            //Initializing standard set controller
            availableCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where name =' + '\''+ '\'')); //USST-2685 
            selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where name =' + '\''+ '\''));  //USST-2685
            
            //getting material id from parameter
            territoryType = apexpages.currentpage().getparameters().get('territory');
            territoryType1 = apexpages.currentpage().getparameters().get('dualterritory');
            territoryType2 = apexpages.currentpage().getparameters().get('territory');
            
            if(apexpages.currentpage().getparameters().get('isClone')!=null && apexpages.currentpage().getparameters().get('isClone')!='')
                isClone=apexpages.currentpage().getparameters().get('isClone');
            currMaterialId=apexpages.currentpage().getparameters().get('matID');
            System.debug('currMaterialId---->'+currMaterialId);
            
            if(territoryType != null && territoryType != ''){
                string tempTerritory = territoryType;
                territoryType = ' AND Territory__c like \'%' +tempTerritory.trim()+ '%\'';
            }
            
            //getting user details
            userDetail = [Select id,label_code__c from user where id =:userinfo.getUserId()];
            
            //getting parent material details
            parentMaterialDetails = [Select id,name,Material_Type__c,Total_Item_Qty__c, Item_Type__c, Item_Code__c,Material_Number__c,Territory__c, Format_Description__c,Association_Required__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c,Label_Code__c, Sub_Label_Code_Lookup__c, BOM_Status__c, Component_Material__c, Selection_ID__c, Material_Status__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c LIMIT 1]; //USST-2685
                
                //if material type of parent material is ROH then this process cannot be used
                if(parentMaterialDetails != null){
                    showPageBlock = TRUE;                    
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'For ROH records this functionality cannot be used.'));  
                }
                
                //for(Material__c matSearch : parentMaterialDetails){
                    if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='M (Multipack)' && parentMaterialDetails.Item_Code__c == 'MT - MULTI-TITLE'){
                      enableTitleSearch = FALSE;
                    }
                    else if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='S (Single)' && parentMaterialDetails.Item_Code__c == 'CE - COMPILATIONS'){
                      enableTitleSearch = FALSE;
                    }
                    else{
                     enableTitleSearch = TRUE;
                    }
                
         }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }
    }
    
    /************************************
    Method Name: btnSearch
    Purpose: called on click of search button 
    *************************************/  
    public pageReference btnSearch(){
        try{
            //Initializing collection and variables
            SOQL = '';
            manualAddCriterial = '';
            isFromCSV = FALSE;
            lstTitleDetails = new List<Title__c>();
            lstMaterialDetails = new List<Material__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            String uRoleId = UserInfo.getUserRoleId();
            String roleName;
            if(currMaterialId!=null && currMaterialId!=''){
              fetchParentMaterialDetials();//REL-10 fetching parent material details.
            }
            if(UserInfo.getUserRoleId() != null)
                roleName=[Select Id,Name from Userrole where Id=:uRoleId].Name;
            //checking if search text not blank
            if(string.isNotBlank(searchCriteria)){
                //if user is searching on material object
                searchCriteria = String.escapeSingleQuotes(searchCriteria);
                              
                if(rdActivityType == 1){ 
                    if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && roleName == 'UPHE Brand and HQ'){
                        SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Component_Type__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                        SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                        SOQL = SOQL + ' AND (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        SOQL = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\''/*+ 'AND Item_Code__c !=' +'\''+ 'BF - BABY FERT' + '\''*/; //commenting baby fert filter for USST-2976
                        if(territoryType != null && territoryType != ''){
                            SOQL = SOQL + territoryType;
                        }
                        SOQL  = SOQL + ' Limit 1000';
                        System.Debug('SOQL Query @@ '+SOQL);
                    }
                    else if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && isClone=='false'){
                        SOQL = 'Select id,name,SGENNO__c, Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Component_Type__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                        SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                        SOQL = SOQL + ' AND (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\'';
                        if(territoryType != null && territoryType != ''){
                            SOQL = SOQL + territoryType;
                        }
                        SOQL  = SOQL + ' Limit 1000';
                       
                    }
                    else if(apexPages.currentPage().getParameters().get('matType') != 'FERT' && apexPages.currentPage().getParameters().get('from')== 'bomWizard' && isClone=='false')
                    {
                        SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Format_Description__c,Material_Status__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                        SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                        SOQL = SOQL + ' AND (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId+ '\'';
                        if(territoryType != null && territoryType != ''){
                            SOQL = SOQL + territoryType;
                        }
                        SOQL  = SOQL + ' Limit 1000';
                        
                    }
                    //Added for REL-10 
                    //REL-90 Added Selection_Version as filter 
                    else if(apexPages.currentPage().getParameters().get('matType') == 'FERT' && apexPages.currentPage().getParameters().get('from')== 'bomWizard' && isClone=='true')
                    {
                        SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Format_Description__c,Material_Status__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c,Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                        SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                        SOQL = SOQL + ' AND (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        //SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId+ '\'';
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\''+'AND Selection_ID__c!=null AND Selection_Version__c!=\'000\' AND Material_Number__c!=null';
                        if(currentMat.selection_id__c!=null && currentMat.selection_id__c!='')//REL-10 Displaying only those versioned materials whose selection Ids are matching with Base material.
                        {
                          SOQL= SOQL+' AND Selection_ID__c=\''+currentMat.selection_id__c+'\'';
                        }   
                        if(territoryType != null && territoryType != ''){
                            SOQL = SOQL + territoryType;
                        }
                        SOQL  = SOQL + ' Limit 1000';
                       
                    }
                    else{
                         
                        SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Format_Description__c,Material_Status__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                        SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                        SOQL = SOQL + ' AND (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId+ '\'';
                        if(territoryType != null && territoryType != ''){
                            SOQL = SOQL + territoryType;
                        }
                        SOQL  = SOQL + ' Limit 1000';
                    }
                } 
                //if user is searching on title object               
                else if(rdActivityType == 2){ 
                    SOQL = 'Select id,name,SGENNO__c,Title_Abbreviation__c,Initial_Release_Air_Year__c,Type_Code__c,Level_Code__c from Title__c';
                    SOQL = SOQL + ' where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\')';                   
                    SOQL  = SOQL + ' Limit 1000';
                    
                  }
                
                //calling set controller method
                availableConRecordQuery();
            }
            //if no search text entered
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Field cannot be blank.'));   
            }
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }    
        return null;    
    }
    
    /************************************
    Method Name: btnManualAdd
    Purpose: if manual add button is used
    *************************************/  
    public pageReference btnManualAdd(){
        try{
            //initializing variables and collection
            setManualAdd = new Set<String>();
            lstManualAdd = new List<String>();
            SOQL = '';
            isFromCSV = FALSE;
            searchCriteria = '';
            lstMaterialDetails = new List<Material__c>();
            lstTitleDetails = new List<Title__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            String uRoleId = UserInfo.getUserRoleId();
            String roleName;
            if(currMaterialId!=null && currMaterialId!=''){
              fetchParentMaterialDetials();//REL-10 fetching parent material details.
            }
            
            if(UserInfo.getUserRoleId() != null)
                roleName=[Select Id,Name from Userrole where Id=:uRoleId].Name;
            //if manual add field is not blank
            if(string.isNotBlank(manualAddCriterial)){
                //splitting the search criteria by comma
                List<string> lstTemp = manualAddCriterial.split(',');
                
                //creating a set of search criteria
                for(string s : lstTemp){
                    setManualAdd.add(s.trim());
                }
                
                System.Debug('Role Name@@@ '+roleName);
                System.Debug('FERT Or Not Name@@@ '+ apexPages.currentPage().getParameters().get('matType'));
                System.Debug('Manual Add Criteria !!#$ '+setManualAdd);
                System.Debug('RecordType ID %%% '+recordTypeId);
                System.Debug('Radio Button Type ##$$ '+rdActivityType);
                searchCriteria = String.escapeSingleQuotes(searchCriteria);
                //if set not empty
                if(!setManualAdd.isEmpty()){
                    //if search is performed on material object
                    if(rdActivityType == 1){
                        if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && roleName == 'UPHE Brand and HQ'){
                            SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Component_Type__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                            SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                            SOQL = SOQL + ' AND Material_Number__c in :setManualAdd ';
                            SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\''/*+ 'AND Item_Code__c !=' + '\''+ 'BF - BABY FERT' + '\''*/; //commenting baby fert filter for USST-2976
                            if(territoryType != null && territoryType != ''){
                                SOQL = SOQL + territoryType;
                            }
                            SOQL  = SOQL + ' Limit 1000';
                            System.Debug('SOQL Query @@ '+SOQL);
                        }
                        else if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && isClone=='false'){
                            SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                            SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                            SOQL = SOQL + ' AND Material_Number__c in :setManualAdd';
                            SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                            if(territoryType != null && territoryType != ''){
                                SOQL = SOQL + territoryType;
                            }
                            
                            SOQL  = SOQL + ' Limit 1000'; 
                        }
                        //Added for REL-10
                         else if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && isClone=='true' && apexPages.currentPage().getParameters().get('from')== 'bomWizard'){
                            SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c,Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                            SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                            SOQL = SOQL + ' AND Material_Number__c in :setManualAdd';
                            SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\''+'AND Selection_ID__c!=null AND Selection_Version__c!=\'000\' AND Material_Number__c!=null';
                            if(currentMat.selection_id__c!=null && currentMat.selection_id__c!='')//REL-10 Displaying only those versioned materials whose selection Ids are matching with Base material.
                          {
                            SOQL= SOQL+' AND Selection_ID__c=\''+currentMat.selection_id__c+'\'';
                          }
                            if(territoryType != null && territoryType != ''){
                                SOQL = SOQL + territoryType;
                            }
                            
                            SOQL  = SOQL + ' Limit 1000'; 
                        }
                        else if(apexPages.currentPage().getParameters().get('matType') != 'FERT' && apexPages.currentPage().getParameters().get('from')== 'bomWizard'){
                            SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                            SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                            SOQL = SOQL + ' AND Material_Number__c in :setManualAdd ';                         
                            SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                            if(territoryType != null && territoryType != ''){
                                SOQL = SOQL + territoryType;
                            }  
                            SOQL  = SOQL + ' Limit 1000'; 
                        }
                        else{
                            SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                            SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                            SOQL = SOQL + ' AND Material_Number__c in :setManualAdd ';                         
                            SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                            if(territoryType != null && territoryType != ''){
                                SOQL = SOQL + territoryType;
                            }  
                            SOQL  = SOQL + ' Limit 1000'; 
                        }   
                    }
                    //if search is performed on title object
                    else if(rdActivityType == 2 ){    
                        SOQL = 'Select id,name,SGENNO__c,Title_Abbreviation__c,Initial_Release_Air_Year__c,Type_Code__c,Level_Code__c from Title__c ';
                        SOQL = SOQL + 'Where SGENNO__c in :setManualAdd ';                                                
                        SOQL  = SOQL + ' Limit 1000';                        
                    }
                    
                    System.Debug('SOQL Query !!@@ '+SOQL);
                    
                    //calling set controller method
                    availableConRecordQuery();
                }
            }
            else{                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Field cannot be blank.'));   
            }
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }   
        return null;    
    }    
    
    /************************************
    Method Name: btnUploadCSV
    Purpose: if file upload is used
    *************************************/  
    public pageReference btnUploadCSV(){
     try{
        //Initializing variables and collections
        csvFileLines = new String[]{};
        setManualAdd = new Set<String>();
        lstManualAdd = new List<String>();
        isFromCSV = TRUE;
        SOQL = '';
        searchCriteria = '';
        manualAddCriterial = '';
        lstMaterialDetails = new List<Material__c>();
        lstTitleDetails = new List<Title__c>();
        Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        String uRoleId = UserInfo.getUserRoleId();
        String roleName;
        if(currMaterialId!=null && currMaterialId!=''){
              fetchParentMaterialDetials();//REL-10 fetching parent material details.
        }
        
        //REL-18 getting user's profile 
        String uProfileId= UserInfo.getProfileId();
        Profile profName;
        Set<String> temMatIdSet=new Set<String>();//REL-98 initializing
        invalidData=false;//REL-108 lazy initializing
        
        if(UserInfo.getUserRoleId() != null)
            roleName=[Select Id,Name from Userrole where Id=:uRoleId].Name;
            //REL-18
            profName=[SELECT Id,Name FROM Profile where id=:uProfileId];
        //reading csv file
        if(string.valueof(csvFileBody) != null && string.valueof(csvFileBody) != ''){
          csvAsString = csvFileBody.toString();
        }else{
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.')); 
          return null;  
        }  
        csvFileLines = csvAsString.split('\n');
        
        System.Debug('check csv file lines @@ '+csvFileLines );
        
        //REL-18 initializing variables
        matQtyMap=new Map<String,String>();
        
        //looping over csv file and adding criteria to a set
        for(Integer i=1;i<csvFileLines.size();i++){                
            string[] csvRecordData = csvFileLines[i].split(',');
            System.Debug('check csv file lines !! '+csvRecordData[0]);
            //setManualAdd.add((csvRecordData[0]).trim());
            System.Debug('check csv file lines---itemQty !! '+csvRecordData);
            //Added below as part of DF-01941
            temMatIdSet.add((csvRecordData[0]).trim());//Added to filter out the invalid characters
            //lstManualAdd.add((csvRecordData[0]).trim());//commenting this as part of REL-98
            //Added code for REL-18
            System.Debug('check csv file lines---itemQty !! '+csvRecordData);
            if((roleName=='UPHE Customer Service' || profName.name=='Master Data Admin'  || profName.Name=='System Administrator') && csvRecordData.size()>1 ){ 
              system.debug('====profile===');
              if(csvRecordData.size()>1 && csvRecordData[1]!=null && csvRecordData[1]!=''){
                
                  try{ //REL-98 Additional condition to check if the data is numeric
                    System.debug('Double.valueOf(csvRecordData[1].trim())----->'+Double.valueOf(csvRecordData[1].trim()));
                      Double.valueOf(csvRecordData[1].trim());
                      if(Double.valueOf(csvRecordData[1].trim())!=0){//REL-112 0 are considered to be invalid
                          matQtyMap.put(csvRecordData[0].trim(),csvRecordData[1].trim());
                      }       
                      else if(Double.valueOf(csvRecordData[1].trim())==0)
                      {
                          invalidData=true;
                        temMatIdSet.remove(csvRecordData[0].trim());
                      }
                        
                  }
                  catch(TypeException e){
                    invalidData=true;
                    temMatIdSet.remove(csvRecordData[0].trim());
                  }
              }
            }
            else if((roleName!='UPHE Customer Service' && profName.name!='Master Data Admin' && profName.Name!='System Administrator') && csvRecordData.size()>1){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'Mass upload item quantity is not available for this profile.Please click on Accept to proceed with default item quantities.')); 
            }
        }
        //System.debug('temMatIdSet----->'+temMatIdSet);
        if(!temMatIdSet.isEmpty()){//REL-98 adding only filtered materials
          lstManualAdd.addAll(temMatIdSet);
        }
        
        if(invalidData==true && !temMatIdSet.isEmpty()){//REL-98 Error Msg1. if some item qtyies are correct
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Warning,'Item Qty column contains invalid characters or 0 for few materials in the file. Please click accept to proceed without these data.'));
        }
        if(invalidData==true && temMatIdSet.isEmpty()){//REL-98 Error Msg2. if none of the values are valid
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Item Qty column contains invalid characters or 0 for all materials.Kindly upload a valid file'));
        }
        
        //if set not empty
         system.debug('lstManualAdd== '+lstManualAdd);
         if(!lstManualAdd.isEmpty() || Test.isRunningTest()){      
                
             //if search is performed on material object      
             if(rdActivityType == 1){
                 if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && roleName == 'UPHE Brand and HQ'){
                     SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Component_Type__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                     SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                     SOQL = SOQL + ' AND Material_Number__c in :lstManualAdd ';
                     SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\''/*+ 'AND Item_Code__c !=' +             '\''+ 'BF - BABY FERT' + '\''*/; //commenting baby fert filter for USST-2976
                     if(territoryType != null && territoryType != ''){
                         SOQL = SOQL + territoryType;
                     }
                     SOQL  = SOQL + ' Limit 1000';
                     System.Debug('SOQL Query @@ '+SOQL);
                 }
                 else if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && isClone=='false'){
                     SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Territory__c,Release__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                     SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                     SOQL = SOQL + ' AND Material_Number__c in :lstManualAdd';
                     SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + ' AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                     if(territoryType != null && territoryType != ''){
                         SOQL = SOQL + territoryType;
                     }
                     SOQL  = SOQL + ' Limit 1000'; 
                                        
                 }
                 //Added for REL-10
                 else if(apexPages.currentPage().getParameters().get('matType')== 'FERT' && isClone=='true' && apexPages.currentPage().getParameters().get('from')== 'bomWizard'){
                     SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Territory__c,Release__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c,Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                     SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                     SOQL = SOQL + ' AND Material_Number__c in :lstManualAdd';
                     SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + ' AND RecordTypeId !='+ '\''+ recordTypeId + '\''+'AND Selection_ID__c!=null AND Selection_Version__c!=\'000\' AND Material_Number__c!=null';
                     if(territoryType != null && territoryType != ''){
                         SOQL = SOQL + territoryType;
                     }
                     if(currentMat.selection_id__c!=null && currentMat.selection_id__c!='')//REL-10 Displaying only those versioned materials whose selection Ids are matching with Base material.
                     {
                          SOQL= SOQL+' AND Selection_ID__c=\''+currentMat.selection_id__c+'\'';
                     }
                     SOQL  = SOQL + ' Limit 1000'; 
                     System.Debug('SOQL Query @@3 '+SOQL);
                 }
                 else if(apexPages.currentPage().getParameters().get('matType') != 'FERT' && apexPages.currentPage().getParameters().get('from')== 'bomWizard'){
                     SOQL = 'Select id,name,SGENNO__c, Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                     SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                     SOQL = SOQL + ' AND Material_Number__c in :lstManualAdd ';                         
                     SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId + '\'';   
                     if(territoryType != null && territoryType != ''){
                         SOQL = SOQL + territoryType;
                     } 
                     SOQL  = SOQL + ' Limit 1000'; 
                 }
                 else{
                     SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c, Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                     SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                     SOQL = SOQL + ' AND Material_Number__c in :lstManualAdd ';                         
                     SOQL  = SOQL + ' AND (Material_Type__c =\'ROH\' OR Material_Type__c =\'Z009\' OR Material_Type__c =\'ZVSM\' OR Material_Type__c =\'ZDLT\') AND RecordTypeId !='+ '\''+ recordTypeId + '\''; 
                     if(territoryType != null && territoryType != ''){
                         SOQL = SOQL + territoryType;
                     } 
                     SOQL  = SOQL + ' Limit 1000';
                    // System.Debug('SOQL Query @@4 '+SOQL); 
                 }                
             }      
             //if search is performed on title object
             else if(rdActivityType == 2 ){      
                 SOQL = 'Select id,name,SGENNO__c,Title_Abbreviation__c,Initial_Release_Air_Year__c,Type_Code__c,Level_Code__c from Title__c ';
                 SOQL = SOQL + 'Where SGENNO__c in :lstManualAdd ';                                                
                 SOQL  = SOQL + ' Limit 1000';
                 
             }
             System.debug('-----SOQL> '+SOQL);
             //calling set controller method
             availableConRecordQuery();
             
             if(rdActivityType == 1){
                 
                 //Added below as part of DF-01941
                /*USST-2951 Map<string,Material__c> mapMatNo = new Map<string,Material__c>();
                 for(Material__c mat : Database.Query(SOQL)){
                    if(!mapMatNo.containsKey(mat.Material_Number__c)){
                        mapMatNo.put(mat.Material_Number__c,mat);
                    }
                }
                
                for(String s : lstManualAdd){
                    if(mapMatNo.containsKey(s)){
                        tmpAllSearchedMaterials.add(mapMatNo.get(s));
                    }                    
                }
                
                System.Debug('List values ## '+tmpAllSearchedMaterials);*/ //USST-2951
                 
                 if(lstMaterialDetails != null && lstMaterialDetails.size() > 0)
                 {
                     tmpAllSearchedMaterials.clear(); //USST-2951
                     tmpAllSearchedMaterials.addAll(lstMaterialDetails); //USST-2951
                     isMethodAutoCalled = true;
                     Integer i = 0;
                     for(Material__c mat : tmpAllSearchedMaterials )
                     {
                         System.Debug('Mat Val## '+mat);
                         mtRowNumber = i ++;
                         paramID = mat.Id;
                         setSelectedMaterial();
                     }
                     isMethodAutoCalled = false;
                 }
                 tmpAllSearchedMaterials.clear(); 
             }
             else if(rdActivityType == 2){
                
                //Added below as part of DF-01941
                Map<string,Title__c> mapTitleSGENNO = new Map<string,Title__c>();                
                
                for(Title__c ttl : Database.Query(SOQL)){
                    if(!mapTitleSGENNO.containsKey(ttl.SGENNO__c)){
                        mapTitleSGENNO.put(ttl.SGENNO__c,ttl);
                    }
                }
                
                for(String s : lstManualAdd){
                    if(mapTitleSGENNO.containsKey(s)){
                        tmpAllSearchedTitles.add(mapTitleSGENNO.get(s));
                    }                    
                }
                                 
                 if(lstTitleDetails != null && lstTitleDetails.size() > 0)
                 {
                     isMethodAutoCalled = true;
                     Integer i = 0;
                     for(Title__c ttl : tmpAllSearchedTitles)
                     {
                         mtRowNumber = i ++;
                         paramID = ttl.Id;
                         setSelectedTitle();
                     }
                     isMethodAutoCalled = false;
                 }
                 tmpAllSearchedTitles.clear(); 
             }
         }
         else{ 
             if(invalidData==false){   //Added condition for REL-98         
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.'));
             }   
         } 
     }catch(exception ex){            
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
     }           
        return null;    
    }
    
    /************************************
    Method Name: setSelectedMaterial
    Purpose: add selected material
    *************************************/ 
    private Boolean isMethodAutoCalled = false;   
    public pageReference setSelectedMaterial(){  
        //if record has not already been selected
        if(!setAlreadyAdded.contains(paramID)){
            //adding selected record to a list
            if(isMethodAutoCalled)
                lstAllAddedMaterials.add(tmpAllSearchedMaterials[mtRowNumber]);
            else
                lstAllAddedMaterials.add(lstMaterialDetails[mtRowNumber]);
            
            //adding selected record id to a set
            setAlreadyAdded.add(paramID);
            //displaying accept button
            showAccept = TRUE;  
            
            //Setting set controller
            selectedCon = new ApexPages.StandardSetController(lstAllAddedMaterials);  
            selectedCon.setPageSize(pageSize);
            
            //calling selected compnent set controller method
            selectedConRecordSet();          
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Record already added.'));
        }  
        return null;        
    }
    
    /************************************
    Method Name: removeSelectedMaterial
    Purpose: remove selected material
    *************************************/ 
    public pageReference removeSelectedMaterial(){
        //remove record from set  
        setAlreadyAdded.remove(paramID);   
        
        //removing record from master list
        for(integer i=0;i<lstAllAddedMaterials.size();i++){
            if(lstAllAddedMaterials[i].id == paramID){
                lstAllAddedMaterials.remove(i);
            }       
        } 

        /*for(integer j=0;j<lstSelectedMaterial.size();j++){
            if(lstSelectedMaterial[j].id == paramID){
                lstSelectedMaterial.remove(j);
            }           
        }     */      
        
        //setting values in set controller
        selectedCon = new ApexPages.StandardSetController(lstAllAddedMaterials);  
        selectedCon.setPageSize(pageSize);
        
        //calling set controller method
        selectedConRecordSet();
        
        //if list size 0 then hiding accept button
        if(lstSelectedMaterial.size() == 0){
            showAccept = FALSE;
        }
        return null;
    }
    
    /************************************
    Method Name: setSelectedTitle
    Purpose: add selected title
    *************************************/    
    public pageReference setSelectedTitle(){        
        //adding selected title to master list and set
        if(!setAlreadyAdded.contains(paramID)){
            //adding selected record to a list
            if(isMethodAutoCalled)
                lstAllAddedTitle.add(tmpAllSearchedTitles[mtRowNumber]);
            else
                lstAllAddedTitle.add(lstTitleDetails[mtRowNumber]);
            
            setAlreadyAdded.add(paramID);
            showAccept = TRUE;  
            
            //setting values in set controller
            selectedCon = new ApexPages.StandardSetController(lstAllAddedTitle);  
            selectedCon.setPageSize(pageSize);
            
            //calling set controller method
            selectedConRecordSet();          
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Record already added.'));
        }  
        return null;        
    }
    
    /************************************
    Method Name: removeSelectedTitle
    Purpose: remove selected title
    *************************************/     
    public pageReference removeSelectedTitle(){ 
        //removing title
        setAlreadyAdded.remove(paramID);   
        
        //removing title from master list
        for(integer i=0;i<lstAllAddedTitle.size();i++){
            if(lstAllAddedTitle[i].id == paramID){
                lstAllAddedTitle.remove(i);
            }            
        } 
        
        /*for(integer j=0;j<lstSelectedTitle.size();j++){
            if(lstSelectedTitle[j].id == paramID){
                lstSelectedTitle.remove(j);
            }            
        }  */     
        
        //setting values in set controller
        selectedCon = new ApexPages.StandardSetController(lstAllAddedTitle);  
        selectedCon.setPageSize(pageSize);
        
        //calling set controller method
        selectedConRecordSet();
        
        //if listsize 0 then hiding pagination and accept button
        if(lstSelectedTitle.size() == 0){
            showAccept = FALSE;
            selectedPaginationAvailable = FALSE;
        }
        return null;
    }
    
    
    /************************************
    Method Name: submit
    Purpose: saving selected records
    *************************************/ 
   public pageReference submit(){
        //Initializing variables        
        set<ID> tempIDSet = new Set<ID>();
        set<ID> tempIDBFPresent = new Set<ID>();
        List<Material__c> lstQryMaterial = new List<Material__c>();
        List<Material__c> lstInsertMaterial = new List<Material__c>();
        List<Deal__c> lstDealDetails = new List<Deal__c>();
        Map<ID,String> mapLabelCode = new Map<ID,String>();
        lstBOMItem = new List<BOM_Item__c>();
        Map<ID,String> mapBFNaming = new Map<ID,String>();
        //USST-2208 ---start
        String parentMatTerritory = apexpages.currentpage().getparameters().get('territory');
        Id updateRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<Id> lstTempMatChk = new Set<Id>();
        Set<Id> lstTempSalesChk = new Set<Id>();
        List<Sales__c> lstSales = new List<Sales__c>();
        List<Material__c> finalLstQryMaterial = new List<Material__c>();
        //USST-2208 ---end
        
                
        try{ 
            //if search on material
            if(rdActivityType == 1){
                //linking materials by creating BOM Item
                if(!lstSelectedMaterial.isEmpty()){
                    for(Material__c mt : lstAllAddedMaterials){
                        BOM_Item__c objBOM = new BOM_Item__c();
                        objBOM.Material__c= parentMaterialDetails.Id;
                        objBOM.Material_Component__c= mt.Id;
                        objBOM.Territory__c = parentMaterialDetails .Territory__c;
                        objBOM.Item_Category__c = 'N';
                        objBOM.Valid_From__c = Date.today();
                        lstBOMItem.add(objBOM); 
                    }
                    
                    if(!lstBOMItem.isEmpty()){
                        insert lstBOMItem;     
                    }
                }
            }
            //if search on title
            else if(rdActivityType == 2){ 
                //creating set of title ids
                system.debug('lstAllAddedTitle=== '+lstAllAddedTitle);             
                if(!lstAllAddedTitle.isEmpty()){
                    for (Title__c t:lstAllAddedTitle){
                        tempIDSet.add(t.id);
                        
                        if(t.Title_Abbreviation__c != null){
                            mapBFNaming.put(t.id,t.Title_Abbreviation__c );
                        }
                         
                    }            
                }
                
                System.debug('parentMaterialDetails--->'+parentMaterialDetails);
                //if set not empty
                system.debug('tempIDSet=== '+tempIDSet); 
                if(!tempIDSet.isEmpty()){
                    //getting primary deals for title
                    lstDealDetails = [Select id,name,Title__c, Primary_Deal__c, Label_Code__c from Deal__c where Primary_Deal__c = TRUE and Title__c in:tempIDSet];
                    system.debug('lstDealDetails=== '+lstDealDetails);
                    //creating a map of title and label code
                    if(!lstDealDetails.isEmpty()){
                      for(Deal__c d : lstDealDetails){
                          system.debug('mapLabelCode=== '+mapLabelCode);
                         if(!mapLabelCode.containsKey(d.Title__c)){
                           mapLabelCode.put(d.Title__c,d.Label_Code__c);
                         }                      
                      }                   
                    }
                
                    //getting exisitng baby FERT materials based on title ID
                     lstQryMaterial = [Select id,name,Total_Item_Qty__c ,Title__r.Name, Title__r.ID,Item_Code__c,Retailer_Rental__c,Label_Code__c,Material_Type__c,Format_Description__c,Item_Type__c,BOM_Quantity__c,Association_Required__c,Component_Type__c,SGENNO__c,release__c,Territory__c,Material_Number__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Count_Sales_for_D_Chain_Status__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c,Component_Material__c, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where Title__c in:tempIDSet and (Item_Code__c = 'BF - BABY FERT' OR ( (Item_Code__c = 'ME - TV MULTIPLE EPISODES' OR Item_Code__c = 'SE - TV SINGLE EPISODES') AND Territory__c =: parentMatTerritory ) ) AND RecordTypeId !=: updateRecordTypeId AND Deletion_Flag__c = FALSE]; //Modified query for USST-2208 //USST-2685
                    system.debug('lstQryMaterial === '+lstQryMaterial );
                    system.debug('parentMatTerritory === '+parentMatTerritory );
                    //creating BOM Item for existing BABY FERTs
                    if(!lstQryMaterial.isEmpty()){
                        //USST-2208 ---start
                        for (Material__c m : lstQryMaterial) {
                            lstTempMatChk.add(m.Id);
                        }
                        
                        system.debug('territoryType === '+territoryType1 );
                        system.debug('territoryType === '+territoryType2 );
                        //modofied for USST-2878
                        if(territoryType2 == 'US' && territoryType1 == null )
                          lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released' and territory__C='US'];
                        else if (territoryType2 == 'CDN')
                          lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released' and territory__C='CDN'];
                        else if (territoryType1 == 'yes')
                          lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released'];
                        //end of USST-2878
                        system.debug('lstSales === '+lstSales );
                        if (!lstSales.isEmpty()) {
                            for (Sales__c s : lstSales) {
                                lstTempSalesChk.add(s.Material__c);
                            }
                        
                            for(Id tempId : lstTempSalesChk)
                            {
                               if(lstTempMatChk.contains(tempId))
                                    lstTempMatChk.remove(tempId);
                            }
                            
                            if (!lstTempMatChk.isEmpty()) {
                                finalLstQryMaterial = [Select id,name,Total_Item_Qty__c ,Title__r.Name, Title__r.ID,Item_Code__c,Retailer_Rental__c, Label_Code__c,Material_Type__c,Format_Description__c,Item_Type__c,BOM_Quantity__c, Association_Required__c,Component_Type__c,SGENNO__c,release__c,Territory__c,Material_Number__c,Sub_Label_Code_Lookup__c, BOM_Status__c,Count_Sales_for_D_Chain_Status__c, MPM_Issue__c, Sales_Planning_Group__c,Subformat__c,Component_Material__c, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where Id IN : lstTempMatChk]; //USST-2685
                            }
                        }
                        else {
                            finalLstQryMaterial.addAll(lstQryMaterial);
                        }
                        //USST-2208 ---end
                        
                        for(Material__c mt : finalLstQryMaterial){  //USST-2208
                            if(!tempIDBFPresent.contains(mt.Title__r.ID)){
                                BOM_Item__c objBOM = new BOM_Item__c();
                                objBOM.Material__c= parentMaterialDetails.Id;
                                objBOM.Material_Component__c= mt.Id;
                                objBOM.Territory__c = parentMaterialDetails .Territory__c; 
                                lstBOMItem.add(objBOM);
                                tempIDBFPresent.add(mt.Title__r.ID);
                                tempIDSet.remove(mt.Title__r.ID);  
                            }
                        }
                    }
                }
                 system.debug('tempIDSet=== '+tempIDSet);
                if(!tempIDSet.isEmpty()){  
                    //Looping over remaining title for which new BABY FERT has to be created                  
                    for(ID setTitleID : tempIDSet){                        
                        Material__c objMaterial = new Material__c();
                        if(mapBFNaming.containsKey(setTitleID)){
                            objMaterial.Name = mapBFNaming.get(setTitleID) + ' 4MT ';
                        }
                        else{
                            objMaterial.Name = '4MT';
                        }
                        
                        objMaterial.Material_Type__c = 'FERT';
                        objMaterial.Item_Type__c = 'S (Single)';
                        objMaterial.Item_Code__c = 'BF - BABY FERT';
                        objMaterial.Territory__c = 'US & CDN';
                        objMaterial.BOM_Status__c = 'Draft';
                        objMaterial.Format_Description__c = 'DVD';
                        objMaterial.Title__c = setTitleID;
                        //objMaterial.Total_Item_Qty__c  = 1;
                        lstInsertMaterial.add(objMaterial);
                        
                    }
                    
                    //inserting material and creating BOM Item for the same
                    if(!lstInsertMaterial.isEmpty()){
                        TriggerUtility.followMaterialNamingConvension = TRUE;
                    }                    
                }
            }
            if(finalLstQryMaterial.size() > 0) { //USST-2208
                cache.session.put('selectedTitleMat',finalLstQryMaterial,300); //USST-2208
            }
            if(lstInsertMaterial.size() > 0){
                cache.session.put('selectedTitleNewMat',lstInsertMaterial,300);
            }
            System.debug('---cache.session> '+cache.session.getKeys());
            closeWindow = true;
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));
        } 
        return null;
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
    public Integer resultSize{
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
        if(rdActivityType == 1){
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        }
        else if(rdActivityType == 2){
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
        }
    }
    
    /************************************
    Method Name: last
    Purpose: returns last page of records
    *************************************/ 
    public void last() {
        availableCon.last();
        if(rdActivityType == 1){
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        }
        else if(rdActivityType == 2){
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
        }
    }
    
    /************************************
    Method Name: previous
    Purpose: returns previous page of records
    *************************************/ 
    public void previous() {
        availableCon.previous();
        if(rdActivityType == 1){
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        }
        else if(rdActivityType == 2){
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
        }
    }
    
    /************************************
    Method Name: next
    Purpose: returns next page of records
    *************************************/
    public void next() {
        availableCon.next();
        if(rdActivityType == 1){
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        }
        else if(rdActivityType == 2){
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
        }
    }
    
    /************************************
    Method Name: availableConRecordQuery
    Purpose: sets the available searched records to be displayed
    *************************************/
    private void availableConRecordQuery(){
        //setting records in set controller
        /*availableCon = new ApexPages.StandardSetController(Database.getQueryLocator(SOQL));  
        availableCon.setPageSize(pageSize);*/
        //REL-18
        Map<String,String> tempmatQtyMap = new Map<String,String>();
        //USST-2208 ---start
        List<Material__c> lstQryMaterial = new List<Material__c>();
        Set<Id> lstTempMatChk = new Set<Id>();
        Set<Id> lstTempSalesChk = new Set<Id>();
        List<Sales__c> lstSales = new List<Sales__c>();
        List<Material__c> finalLstQryMaterial = new List<Material__c>();
        //USST-2208 ---end
        
        //checking type of search activity
        if(rdActivityType == 1){
            //USST-2208 ---start
            lstQryMaterial = Database.Query(SOQL);
            
            for (Material__c mt : lstQryMaterial) {
                lstTempMatChk.add(mt.Id);
            }
            
            system.debug('territoryType === '+territoryType1 );
            system.debug('territoryType === '+territoryType2 );
            //modofied for USST-2878
            if(territoryType2 == 'US' && territoryType1 == null )
              lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released' and territory__C='US'];
            else if (territoryType2 == 'CDN')
              lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released' and territory__C='CDN'];
            else if (territoryType1 == 'yes')
              lstSales = [Select Material__c,D_Chain_Spec__c,territory__C from Sales__c WHERE Material__c IN : lstTempMatChk AND D_Chain_Spec__c = 'XX - Never Released'];
            //end of USST-2878
            system.debug('lstSales === '+lstSales );
            if (!lstSales.isEmpty()) {
                for (Sales__c s : lstSales) {
                    lstTempSalesChk.add(s.Material__c);
                }
            
                for(Id tempId : lstTempSalesChk)
                {
                   if(lstTempMatChk.contains(tempId))
                        lstTempMatChk.remove(tempId);
                }
                
                if (!lstTempMatChk.isEmpty()) {
                    finalLstQryMaterial = [Select id,name,Total_Item_Qty__c ,Title__r.Name, Title__r.ID,Item_Code__c,Retailer_Rental__c,Label_Code__c,Material_Type__c,Format_Description__c,Item_Type__c,BOM_Quantity__c,Association_Required__c,Component_Type__c,SGENNO__c,release__c,Territory__c,Material_Number__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Count_Sales_for_D_Chain_Status__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c,Component_Material__c, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where Id IN : lstTempMatChk]; //USST-2685
                }
            }
            else {
                finalLstQryMaterial.addAll(lstQryMaterial);
            }
            //USST-2208 ---end
            //Added below as part of DF-01941
            List<Material__c> lstTempMat = new List<Material__c>();
            if(isFromCSV)
            {
                Map<string,Material__c> mapMatNo = new Map<string,Material__c>();
                
                for(Material__c mat : finalLstQryMaterial){
                    if(!mapMatNo.containsKey(mat.Material_Number__c)){ 
                        mapMatNo.put(mat.Material_Number__c,mat);                           
                    }
                    //REL-18 Filtering only the relevant data
                    if(matQtyMap!=null && matQtyMap.containsKey(mat.Material_Number__c))
                    {
                      tempmatQtyMap.put(mat.Material_Number__c, matQtyMap.get(mat.Material_Number__c));
                    }
                    
                }
                 //System.debug('mapMatNo---->'+mapMatNo);
                 //REL-18
                 if(tempmatQtyMap!=null && tempmatQtyMap.size()>0){
                  matQtyMap = tempmatQtyMap;
                 }
                //System.debug('tempmatQtyMap---->'+tempmatQtyMap);
                //System.debug('mapMatNo 1111---->'+matQtyMap);
                for(String s : lstManualAdd){
                    if(mapMatNo.containsKey(s)){
                        lstTempMat.add(mapMatNo.get(s));
                    }                    
                }
            }
            else{
                lstTempMat = finalLstQryMaterial; 
            }               
            
            availableCon = new ApexPages.StandardSetController(lstTempMat);  
            availableCon.setPageSize(pageSize);
            
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        }
        else if(rdActivityType == 2){
            //Added below as part of DF-01941
            List<Title__c> lstTempTitle = new List<Title__c>();
            if(isFromCSV)
            {
                Map<string,Title__c> mapTitleSGENNO = new Map<string,Title__c>();                
                
                for(Title__c ttl : Database.Query(SOQL)){
                    if(!mapTitleSGENNO.containsKey(ttl.SGENNO__c)){
                        mapTitleSGENNO.put(ttl.SGENNO__c,ttl);
                    }
                }
                
                for(String s : lstManualAdd){
                    if(mapTitleSGENNO.containsKey(s)){
                        lstTempTitle.add(mapTitleSGENNO.get(s));
                    }                    
                }
            }
            else{
                lstTempTitle = Database.query(SOQL);
            }               
            
            availableCon = new ApexPages.StandardSetController(lstTempTitle);  
            availableCon.setPageSize(pageSize);         
            
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
            system.debug('lstTitleDetails=== '+lstTitleDetails);
        }        
        
        //based on search type setting boolean variables
        if(!lstMaterialDetails.isEmpty()){            
            paginationAvailable = TRUE;
            showMaterialSection = TRUE;
            showTitleSection = FALSE;
        }
        else if(!lstTitleDetails.isEmpty()){
            paginationAvailable = TRUE;
            showMaterialSection = FALSE;
            showTitleSection = TRUE;
        }
        else{
            paginationAvailable = FALSE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'No matching records found.'));   
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
        if(rdActivityType == 1){
            List<Material__c> tempList = new List<Material__c>();
            lstSelectedMaterial = new List<Material__c>();            
            
            tempList = (List<Material__c>)selectedCon.getRecords();
            
            /*for(Material__c mat : lstAllAddedMaterials){
                if(!setMatID.contains(mat.ID)){
                    setMatID.add(mat.ID);
                    lstSelectedMaterial.add(mat);
                }
            }*/
            lstSelectedMaterial.addall(tempList);            
        }
        //if search is on title
        else if(rdActivityType == 2){
            List<Title__c> tempList = new List<Title__c>();
            lstSelectedTitle = new List<Title__c>();
            
            tempList = (List<Title__c>)selectedCon.getRecords();
            
            /*for(Title__c  title : lstAllAddedTitle){
                if(!setTitleMatID.contains(title.ID)){
                    setTitleMatID.add(title.ID);
                    lstSelectedTitle.add(title);
                }
            }*/
            lstSelectedTitle.addall(tempList);            
        }
        
        //setting boolean variables based on search type
        if(!lstSelectedMaterial.isEmpty()){
            selectedPaginationAvailable = TRUE;            
        }
        else if(!lstTitleDetails.isEmpty()){
            selectedPaginationAvailable = TRUE;
        }
        else{
            selectedPaginationAvailable = FALSE;
        }
    }
    
    /************************************
    Method Name: removeAll
    Purpose: clearing all the lists on click of remove all button
    *************************************/
    public pageReference removeAll(){
        lstAllAddedMaterials = new List<Material__c>();
        selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id, Material_Status__c, Selection_ID__c, Old_Material_Load__c, Material_Expiration_Date__c from Material__c where name =' + '\''+ '\''));  //USST-2685
        lstSelectedMaterial = new List<Material__c>();
        setAlreadyAdded = new Set<ID>();
        selectedPaginationAvailable = FALSE;
        lstAllAddedTitle =  new List<Title__c>();
        lstSelectedTitle = new List<Title__c>();
        showAccept = FALSE;
        return null;
    }
    
    
    /************************************
    Method Name: accept
    Purpose: invoked from accept button and close's pop Up window
    *************************************/
    
    public void accept(){
        List<Material__c> lstInsertMaterial = new List<Material__c>();
        lstBOMItem = new List<BOM_Item__c>();
        
        try{ 
            system.debug('lstSelectedMaterial== '+lstSelectedMaterial);
            cache.session.put('selectedMat',lstAllAddedMaterials,300);
            //REL-18 Adding ItemQtyMap to cache to pass data to other page.
            if(matQtyMap!=null){ // Added for REL-102 Auto close popup
               cache.session.put('matQtyMap',matQtyMap);
            }
            System.debug('---cache.session> '+cache.session.getKeys());
            
            closeWindow = true;
        }catch(Exception e){
            System.debug('---exception: '+e.getMessage());
        }    
    }
    
  /*************************************************
  Method Name: cloneBOM   -  REL-10
  Purpose: Clonning BomItems for Versioned materials.
  *************************************************/
  
  public void cloneBOM(){       
    try{ 
      //System.debug('Inside cloneBOM');
      isSuccess=true;//Lazy initialising
      componentMismatch=false;//Lazy initialising
      for(Material__c mat:lstSelectedMaterial){
        matIds.add(mat.id);
      }
      fetchChildBOMs(matIds,1);
      clonning();
      //REL-90 Added one more criteria  to the logic.
      if((isSuccess==true || isSuccess==false) && componentMismatch==true){//Updated to show both error and success msg. //Updated Success msg for REL-199
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'BOM was cloned to Material Versions successfully.Please refer to the following List View to make changes: \'Version BOMs Cloned Today\''));             
      }
      //closeWindow = true;              
    }
    catch(Exception e){
      System.debug('---exception: '+e.getMessage());
    }    
  }
  
  /***********************************************************
  Method Name: fetchChildBOMs - REL-10
  Purpose: fetching entire bom structure for the existing BOM
  ************************************************************/
  
  public void fetchChildBOMs(Set<Id> processingMaterialIds, Integer depth)
  {
    //System.debug('Inside Fetch Material');
    Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
    // Fetch the child materials from BOM Items.Added Material__r.BOM_Long_Text__c for REL-183.
    for(BOM_Item__c bom : [SELECT Material__c,Material_Component__c,Item_Category__c, Material_Component__r.Material_Type__c, Material_Component__r.Item_Type__c,BOM_Status__c,BOM_Quantity__c,Component_Quantity__c,
                  BOM_Item_Text_1__c,BOM_Item_Text_2__c, Material__r.BOM_Long_Text__c FROM BOM_Item__c WHERE Material__c IN :processingMaterialIds])
    {           
      if(bom.Material__c==currMaterialId){
        bomItemList.add(bom);
      }
      else{
        if(bomExistingMap.containsKey(bom.Material__c) && bom.Item_Category__c!='T'){
          bomExistingMap.get(bom.Material__c).add(bom);
        }
        else if(!bomExistingMap.containsKey(bom.Material__c) && bom.Item_Category__c!='T'){
          bomExistingMap.put(bom.Material__c,new List<Bom_item__c>{bom});
        }
      }
    }       
  } 
  /***********************************************************
  Method Name: clonning - REL-10
  Purpose: Cloning the BOM structure to Selected Materials
  ************************************************************/
  public void clonning(){
    //system.debug('INside Clonning');
    String error_message='';
    String selectionId_errormsg='';
    String selectId='';
    String componentTypeError='';
    List<Material__c> updateMaterialList=new List<Material__c>();
    
    if(currentMat.Material_Number__c!=null){
        selectId=(currentMat.Material_Number__c).substring(2,8);//REL-90 selection Id logic
    }
    
    if(!lstSelectedMaterial.isEmpty()){
         for(Material__c mat:lstSelectedMaterial){
        //REL-90 Updated logic for Selection_ID field to include two preceeding zeros
        //System.debug('mat.selection_Id__c.substring(2,8)---->'+mat.selection_Id__c.substring(2,8));
        //REL-85 Defect Added condition to check if the component being added is of correct type
        if(!bomItemList.isEmpty() && selectId!=null && mat.selection_Id__c.substring(2,8)==(selectId) && (bomExistingMap==null || (bomExistingMap!=null && !bomExistingMap.containsKey(mat.id))) && mat.BOM_Status__c!='In Progress'){
          //System.debug('bomItemList.isEmpty()--->'+bomItemList.isEmpty());
          for(Bom_item__c bomitem:bomItemList){
              //Updated logic for REL-85
            if((mat.item_type__c=='S (Single)' && bomitem.material_component__c!=null && bomitem.material_component__r.item_type__c!='S (Single)'&& bomitem.material_component__r.item_type__c!='M (Multipack)'&& bomitem.material_component__r.item_type__c!='D (Display Vehicle)') || mat.item_type__c!='S (Single)' || bomitem.Item_Category__c=='T'){//REL-110 updated logic to clone T Boms
              Bom_item__c bom = bomitem.clone(false,false,false,false);
              bom.BOM_Status__c='In Progress';
              if(bom.Material__c==currMaterialId){
                  bom.Material__c=mat.id;
              }
              mat.Bom_status__c='In Progress';
              if (bomitem.Material__r.BOM_Long_Text__c != null) { // REL-183 Added for copying Bom Long Text value also 
                    mat.BOM_Long_Text__c =  bomitem.Material__r.BOM_Long_Text__c;
              }
              bomItemInsertList.add(bom); 
              componentMismatch=true; //REL-90
            }  
            //REL-85 Defect 
            else{
              if(!componentTypeError.contains(mat.material_Number__c))//Conditional check for REL-85
               componentTypeError+=mat.material_Number__c+',';
            }    
                
          }
        updateMaterialList.add(mat);                                      
        }  
        else if(bomItemList.isEmpty()){//REL-90 Added Error msg if there are no BomItems to be copied
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are no Bom Items to be cloned'));
        }
        else {
          error_message+=mat.material_Number__c+',';      
        }
          
      }
      //REL-85 Defect 
      if(componentTypeError!=null && componentTypeError!=''){
        componentTypeError=componentTypeError.substring(0,componentTypeError.length()-1);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'One of the Bom Items cannot be copied into the Materials '+componentTypeError+' as only components can be child of S (Single)' ));
      }
      if(error_message!=null && error_message!=''){
        error_message=error_message.substring(0,error_message.length()-1);
        isSuccess=false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Materials '+error_message+' has a BOM that already exists within the system.'));                                   
      }  
      try{
        if((isSuccess==true || isSuccess==false) && componentMismatch==true){//Updated to show both error and success msg.
          if(!updateMaterialList.isEmpty()){
             update updateMaterialList;
          }
          if(!bomItemInsertList.isEmpty()){  
            insert bomItemInsertList;
          }
        }
      
      }
      catch(Exception e){
          System.debug('---exception: '+e.getMessage());
      }               
    }
  }        
      
  /***********************************************************
  Method Name: fetchParentMaterialDetials - REL-10
  Purpose: get details of base material
  ************************************************************/ 
  public void fetchParentMaterialDetials(){
    System.debug('Inside fetchParentMaterialDetials');
      currentMat=[Select id,Material_Number__c,selection_Id__c, Material_Status__c,Old_Material_Load__c, Material_Expiration_Date__c from Material__c where Id=:currMaterialId]; //USST-2685
        matIds.add(currMaterialId);
  }
      
  /***********************************************************
  Method Name: Autopopulate - REL-10
  Purpose: Autopopulate versioned materials
  ************************************************************/ 
  public void autoPopulateVersionedMaterials(){
     //System.debug('AutoPopulate------->');
     if(isClone=='true'){
       
        try{
            //Initializing collection and variables
            SOQL = '';
            manualAddCriterial = '';
            isFromCSV = FALSE;
            lstTitleDetails = new List<Title__c>();
            lstMaterialDetails = new List<Material__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            String uRoleId = UserInfo.getUserRoleId();
            String roleName;
            if(currMaterialId!=null && currMaterialId!=''){
              fetchParentMaterialDetials();//REL-10 fetching parent material details.
            }
            if(UserInfo.getUserRoleId() != null){
                roleName=[Select Id,Name from Userrole where Id=:uRoleId].Name;
            }   
                                           
            if(rdActivityType == 1){ 
                //Added for REL-10 
                //REL-90 Added Selection_Version as filter 
                if(apexPages.currentPage().getParameters().get('matType') == 'FERT' && apexPages.currentPage().getParameters().get('from')== 'bomWizard')
                {
                    SOQL = 'Select id,name,SGENNO__c,Total_Item_Qty__c, Material_Number__c,Old_Material_No__c,Old_Material_Load__c,Material_Type__c, Component_Type__c, MPM_Issue__c,Sales_Planning_Group__c,Subformat__c, Label_Code__c,Format_Description__c,Material_Status__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c,Component_Material__c,Selection_ID__c, Material_Expiration_Date__c from Material__c '; //USST-2685
                    SOQL = SOQL + ' where Deletion_Flag__c = FALSE ';
                    SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\''+ 'AND RecordTypeId !='+'\''+ recordTypeId+ '\''+'AND Selection_ID__c!=null AND Selection_Version__c!=\'000\' AND Material_Number__c!=null';
                    if(currentMat.selection_id__c!=null && currentMat.selection_id__c!='')//REL-10 Displaying only those versioned materials whose selection Ids are matching with Base material.
                    {
                      SOQL= SOQL+' AND Selection_ID__c=\''+currentMat.selection_id__c+'\'';
                    }   
                    if(territoryType != null && territoryType != ''){
                        SOQL = SOQL + territoryType;
                    }
                    SOQL  = SOQL + ' Limit 1000';
                   System.Debug('SOQL Query @@REL-10 '+SOQL);
                } 
                
            } 
            
            //calling set controller method
            availableConRecordQuery();
           
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
       }
    
    } 
  }

}