/*****************************************************************************************
Class Name: ListManagementComponentController 
Purpose: Apex class for ListManagementComponent VF page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/08/2016                                    Initial Development
******************************************************************************************/

public class ListManagementComponentController {

    /****private static variables****/

    /****private variables****/
    private set<ID> setAlreadyAdded;
    private Set<string> setManualAdd;
    private string SOQL;
    private ID materialID{get;set;}   
    private List<BOM_Item__c> lstBOMItem;
    private List<Material__c> lstAllAddedMaterials;
    private List<Title__c> lstAllAddedTitle;
    private user userDetail;
    private List<Material__c> lstAllAddedEpisode;
    private List<Material__c> tmpAllSearchedMaterials = new List<Material__c>();
    private List<Title__c> tmpAllSearchedTitles = new List<Title__c>();

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
    public List<Material__c> lstEpisodeDetails{get;set;}
    public List<Material__c> lstSelectedEpisodes{get;set;}
    public boolean showEpisodeSection{get;set;}
    public boolean enableEpisodeSearch{get;set;}
    public boolean matListView{get;set;}
    public Boolean closeWindow {get; private set;}
    
    ApexPages.StandardSetController availableCon;
    ApexPages.StandardSetController selectedCon;
    
    /************************************
    Method Name: ListManagementComponentController
    Purpose: Constructor
    *************************************/   
    public ListManagementComponentController(){
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
            showEpisodeSection = FALSE;
            enableEpisodeSearch = FALSE;
            matListView = FALSE;
            //Initializing collection
            lstAllAddedMaterials = new List<Material__c>();
            setAlreadyAdded = new Set<ID>();
            lstAllAddedTitle = new List<Title__c>();
            lstSelectedTitle = new List<Title__c>();            
            parentMaterialDetails = new Material__c();
            lstSelectedMaterials = new List<Material__c>();
            lstSelectedMaterial = new List<Material__c>();
            lstAllAddedEpisode = new List<Material__c>();
            lstSelectedEpisodes = new List<Material__c>();
            
            //Initializing standard set controller
            availableCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
            selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
            
            //getting material id from parameter
            materialID = apexpages.currentpage().getparameters().get('mid');
            
            //getting user details
            userDetail = [Select id,label_code__c,Master_Data__c from user where id =:userinfo.getUserId()];
            
            //getting parent material details
            if(string.valueof(materialID) != null && string.valueof(materialID) != ''){
                parentMaterialDetails = [Select id,name,Material_Type__c, Item_Type__c, Item_Code__c,Material_Number__c,Territory__c, Format_Description__c from Material__c where ID=:materialID limit 1];
                
                //if material type of parent material is ROH then this process cannot be used
                if(parentMaterialDetails.Material_Type__c != 'ROH'){
                    showPageBlock = TRUE;                    
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'For ROH records this functionality cannot be used.'));  
                }
                
                if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='M (Multipack)' && parentMaterialDetails.Item_Code__c == 'MT - MULTI-TITLE'){
                  enableTitleSearch = FALSE;
                }
                else if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='S (Single)' && parentMaterialDetails.Item_Code__c == 'CE - COMPILATIONS'){
                  enableTitleSearch = FALSE;
                }
                else{
                 enableTitleSearch = TRUE;
                }
                
                if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='S (Single)' && parentMaterialDetails.Item_Code__c == 'SE - TV SINGLE EPISODES'){
                  enableEpisodeSearch = TRUE;
                }
                else if(parentMaterialDetails.Material_Type__c == 'FERT' && parentMaterialDetails.Item_Type__c =='S (Single)' && parentMaterialDetails.Item_Code__c == 'ME - TV MULTIPLE EPISODES'){
                  enableEpisodeSearch = TRUE;
                }
                else{
                  enableEpisodeSearch = FALSE;
                }
                
                
            }
            else{
                matListView =TRUE;
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
            lstTitleDetails = new List<Title__c>();
            lstMaterialDetails = new List<Material__c>();
            lstEpisodeDetails = new List<Material__c>();
            
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            //checking if search text not blank
            if(string.isNotBlank(searchCriteria)){
                searchCriteria = String.escapeSingleQuotes(searchCriteria);
                //if user is searching on material object
                System.debug('##Asha- Search Criteria'+searchCriteria+' '+rdActivityType);
                if(rdActivityType == 1 ){   
                    
                    if(materialID != null && apexpages.currentpage().getparameters().get('source') != 'materiallistview'){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                        SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                        SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        
                        //If parent material is item type single then only ROH records should be displayed
                        if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                        
                            SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'ROH' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                        }                    
                        SOQL  = SOQL + ' Limit 1000';
                        System.Debug('SOQL Query @@ '+SOQL);
                    } 
                    else if(apexpages.currentpage().getparameters().get('source') == 'materiallistview'){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                        SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                        SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        
                        //if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                        
                            SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + 'AND RecordTypeid !='+ '\''+ recordTypeId + '\'' + ' AND BOM_Status__c !=' + '\''+ 'Approved' + '\'' + ' AND BOM_Status__c !=' +'\''+ 'Processed in SAP' + '\'';
                        //}                    
                        SOQL  = SOQL + ' Limit 1000';
                        System.Debug('SOQL Query @@ List View '+SOQL);
                    } 
                } 
                //if user is searching on title object               
                else if(rdActivityType == 2){ 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                    SOQL = 'Select id,name,SGENNO__c from Title__c';
                    SOQL = SOQL + ' where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\')';                   
                    SOQL  = SOQL + ' Limit 1000';
                    System.Debug('SOQL Query @@ '+SOQL);   
                }
                else if(rdActivityType == 3){ 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                    SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c, Component_Type__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c from Material__c ';
                    SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                    SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'Episode (HEEP)' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                    SOQL  = SOQL + ' AND Deletion_Flag__c =' + FALSE ;
                    SOQL  = SOQL + ' Limit 1000';
                    System.Debug('SOQL Query @@ '+SOQL);
                }
                
                //calling set controller method
                System.Debug('SOQL Query @@ '+SOQL);
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
            SOQL = '';
            searchCriteria = '';
            lstMaterialDetails = new List<Material__c>();
            lstTitleDetails = new List<Title__c>();
            Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            //if manual add field is not blank
            if(string.isNotBlank(manualAddCriterial)){
                //splitting the search criteria by comma
                List<string> lstTemp = manualAddCriterial.split(',');
                
                //creating a set of search criteria
                for(string s : lstTemp){
                    setManualAdd.add(s.trim());
                }
                
                //if set not empty
                if(!setManualAdd.isEmpty()){
                    //if search is performed on material object
                    if(rdActivityType == 1){
                        if(materialID != null){
                            SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                            SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                            
                            //if parent material item type is single then only ROH records will be searched
                            if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                            
                                SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'ROH' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                            }                        
                            SOQL  = SOQL + ' Limit 1000';   
                        }
                        else if(apexpages.currentpage().getparameters().get('source') == 'materiallistview'){
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                            /*SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                            SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                            SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                            SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';*/
                            
                            SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                            SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                            
                            //if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                        
                                SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'' + ' AND BOM_Status__c !=' + '\''+ 'Approved' + '\'' + ' AND BOM_Status__c !=' +'\''+ 'Processed in SAP' + '\'';
                            //}                    
                            SOQL  = SOQL + ' Limit 1000';
                            System.Debug('SOQL Query @@ List View '+SOQL);
                        }   
                    }
                    //if search is performed on title object
                    else if(rdActivityType == 2){                        
                        SOQL = 'Select id,name,SGENNO__c from Title__c ';
                        SOQL = SOQL + 'Where SGENNO__c in :setManualAdd ';                                                
                        SOQL  = SOQL + ' Limit 1000';                        
                    }
                    else if(rdActivityType == 3){ 
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                        /*SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c, Component_Type__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c from Material__c ';
                        SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                        SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'Episode (HEEP)' + '\'';
                        SOQL  = SOQL + ' AND Deletion_Flag__c =' + FALSE;*/
                        SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                        SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'Episode (HEEP)' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                        SOQL  = SOQL + ' Limit 1000';
                        System.Debug('SOQL Query @@ '+SOQL);
                    }
                    
                    //calling set controller method
                    availableConRecordQuery();
                }
            }
            else{                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Field cannot be blank.'));   
            }
        }catch(exception ex){                
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'No matching records found.'));    //USST-2761                         
          // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));           
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
        SOQL = '';
        searchCriteria = '';
        manualAddCriterial = '';
        lstMaterialDetails = new List<Material__c>();
        lstTitleDetails = new List<Title__c>();
        lstEpisodeDetails = new List<Material__c>();
        Id recordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        //reading csv file
        if(string.valueof(csvFileBody) != null && string.valueof(csvFileBody) != ''){
          csvAsString = csvFileBody.toString();
        }else{
          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.')); 
          return null;  
        }    
        
        csvFileLines = csvAsString.split('\n');
        
        System.Debug('check csv file lines @@ '+csvFileLines );
        
        //looping over csv file and adding criteria to a set
        for(Integer i=1;i<csvFileLines.size();i++){                
            string[] csvRecordData = csvFileLines[i].split(',');
            System.Debug('check csv file lines !! '+csvRecordData[0]);
            setManualAdd.add((csvRecordData[0]).trim());
        }
        
        System.Debug('Check set details '+ setManualAdd);
        
        
        //if set not empty
        if(!setManualAdd.isEmpty()){      
            //if search is performed on material object      
            if(rdActivityType == 1){
                if(materialID != null){
                    System.Debug('check set data @@ '+setManualAdd);
                    SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                    SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                    
                    //for parent material if item type is single then only ROH records will be searched
                    if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                    
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'ROH' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                    }                
                    SOQL  = SOQL + ' Limit 1000';   
                }
                else if(apexpages.currentpage().getparameters().get('source') == 'materiallistview'){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                    /*SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                    SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                    SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';*/
                    
                    
                    SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                    SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                    
                    //if(parentMaterialDetails.Item_Type__c == 'S (Single)'){                        
                        SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'FERT' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'' + ' AND BOM_Status__c !=' + '\''+ 'Approved' + '\'' + ' AND BOM_Status__c !=' +'\''+ 'Processed in SAP' + '\'';
                    //}                    
                    SOQL  = SOQL + ' Limit 1000';
                    System.Debug('SOQL Query @@ List View '+SOQL);
                }       
            }      
            //if search is performed on title object
            else if(rdActivityType == 2){                
                SOQL = 'Select id,name,SGENNO__c from Title__c ';
                SOQL = SOQL + 'Where SGENNO__c in :setManualAdd ';                                                
                SOQL  = SOQL + ' Limit 1000';
                
            }
            else if(rdActivityType == 3){ 
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Search Entry 1'));   
                /*SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c, Component_Type__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c from Material__c ';
                SOQL = SOQL + 'where (name like ' + '\'%' + searchCriteria.trim() + '%\'';
                SOQL = SOQL + ' OR SGENNO__c like ' + '\'%' + searchCriteria.trim() + '%\'';
                SOQL = SOQL + ' OR Material_Number__c like ' + '\'%' + searchCriteria.trim() + '%\')';
                SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'Episode (HEEP)' + '\'';
                SOQL  = SOQL + ' AND Deletion_Flag__c =' + FALSE;*/
                SOQL = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c  from Material__c ';
                SOQL = SOQL + 'Where Material_Number__c in :setManualAdd ';
                SOQL  = SOQL + ' AND Material_Type__c =' + '\''+ 'Episode (HEEP)' + '\'' + 'AND RecordTypeId !='+ '\''+ recordTypeId + '\'';
                SOQL  = SOQL + ' Limit 1000';
                System.Debug('SOQL Query @@ '+SOQL);
            }
            
            //calling set controller method
            availableConRecordQuery();
            
            if(rdActivityType == 1 || rdActivityType == 3){
                tmpAllSearchedMaterials = Database.query(SOQL);
                
                if(lstMaterialDetails != null && lstMaterialDetails.size() > 0)
                {
                    isMethodAutoCalled = true;
                    Integer i = 0;
                    for(Material__c mat : /*lstMaterialDetails*/tmpAllSearchedMaterials)
                    {
                        mtRowNumber = i ++;
                        paramID = mat.Id;
                        setSelectedMaterial();
                    }
                    isMethodAutoCalled = false;
                }
                tmpAllSearchedMaterials.clear(); 
            }
            else if(rdActivityType == 2){
                tmpAllSearchedTitles = Database.query(SOQL);
                
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.'));   
        } 
       }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
       }         
        return null;    
    }
    
    private Boolean isMethodAutoCalled = false;
    /************************************
    Method Name: setSelectedMaterial
    Purpose: add selected material
    *************************************/    
    public pageReference setSelectedMaterial(){  
        //if record has not already been selected
        if(!setAlreadyAdded.contains(paramID) && lstMaterialDetails != null && lstMaterialDetails.size() > 0){
            //adding selected record to a list
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
            System.debug('##Asha - SetMaterial'+lstAllAddedMaterials);
            
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
        System.debug('##Asha - RemoveMaterial'+paramID);  
        System.debug('##Asha - RemoveMaterial'+lstAllAddedMaterials);
        
        //removing record from master list
        for(integer i=0;i<lstAllAddedMaterials.size();i++){
            if(lstAllAddedMaterials[i].id == paramID){
                lstAllAddedMaterials.remove(i);
            }            
        }   
        
        //setting values in set controller
        System.debug('##Asha - lstAllAddedMaterials'+lstAllAddedMaterials);
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
    Method Name: setSelectedEpisode
    Purpose: add selected episode
    *************************************/    
    public pageReference setSelectedEpisode(){        
        //adding selected episode to master list and set
        if(!setAlreadyAdded.contains(paramID)){
            lstAllAddedEpisode.add(lstEpisodeDetails[mtRowNumber]);
            setAlreadyAdded.add(paramID);
            showAccept = TRUE;  
            
            //setting values in set controller
            selectedCon = new ApexPages.StandardSetController(lstAllAddedEpisode);  
            selectedCon.setPageSize(pageSize);
            
            //calling set controller method
            selectedConRecordSet();          
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Record already added.'));
        }  
        return null;        
    }
    
    /************************************
    Method Name: removeSelectedEpisode
    Purpose: remove selected episode
    *************************************/     
    public pageReference removeSelectedEpisode(){ 
        //removing episode
        setAlreadyAdded.remove(paramID);   
        
        //removing episode from master list
        for(integer i=0;i<lstAllAddedEpisode.size();i++){
            if(lstAllAddedEpisode[i].id == paramID){
                lstAllAddedEpisode.remove(i);
            }            
        }   
        
        //setting values in set controller
        selectedCon = new ApexPages.StandardSetController(lstAllAddedEpisode);  
        selectedCon.setPageSize(pageSize);
        
        //calling set controller method
        selectedConRecordSet();
        
        //if listsize 0 then hiding pagination and accept button
        if(lstSelectedEpisodes.size() == 0){
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
                        objBOM.Component_Quantity__c = '1';
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
                if(!lstAllAddedTitle.isEmpty()){
                    for (Title__c t:lstAllAddedTitle){
                        tempIDSet.add(t.id);
                    }            
                }
                
                //if set not empty
                if(!tempIDSet.isEmpty()){
                    //getting primary deals for title
                    lstDealDetails = [Select id,name,Title__c, Primary_Deal__c, Label_Code__c from Deal__c where Primary_Deal__c = TRUE and Title__c in:tempIDSet];
                    
                    //creating a map of title and label code
                    if(!lstDealDetails.isEmpty()){
                      for(Deal__c d : lstDealDetails){
                         if(!mapLabelCode.containsKey(d.Title__c)){
                           mapLabelCode.put(d.Title__c,d.Label_Code__c);
                         }                      
                      }                   
                    }
                
                    //getting exisitng baby FERT materials based on title ID
                    lstQryMaterial = [Select id,name,Title__r.Name, Title__r.ID,Item_Code__c from Material__c where Title__c in:tempIDSet and Item_Code__c = 'BF - BABY FERT'];
                    
                    //creating BOM Item for existing BABY FERTs
                    if(!lstQryMaterial.isEmpty()){
                        for(Material__c mt : lstQryMaterial){                            
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
                
                if(!tempIDSet.isEmpty()){  
                    //Looping over remaining title for which new BABY FERT has to be created                  
                    for(ID setTitleID : tempIDSet){                        
                        Material__c objMaterial = new Material__c();
                        objMaterial.Name = 'From ListViewManager';
                        objMaterial.Material_Type__c = 'FERT';
                        objMaterial.Item_Type__c = 'S (Single)';
                        objMaterial.Item_Code__c = 'BF - BABY FERT';
                        //objMaterial.Territory__c = parentMaterialDetails.Territory__c;
                        objMaterial.Territory__c = 'US & CDN'; 
                        objMaterial.Label_Code__c = mapLabelCode.get(setTitleID);
                        objMaterial.Format_Description__c = 'DVD';
                        objMaterial.Title__c = setTitleID;
                        
                        lstInsertMaterial.add(objMaterial);
                    }
                    
                    //inserting material and creating BOM Item for the same
                    if(!lstInsertMaterial.isEmpty()){
                        insert lstInsertMaterial;
                        
                        for(Material__c mt : lstInsertMaterial){
                            BOM_Item__c objBOM = new BOM_Item__c();
                            objBOM.Material__c= parentMaterialDetails.Id;
                            objBOM.Material_Component__c= mt.Id;
                            objBOM.Territory__c = parentMaterialDetails .Territory__c; 
                            lstBOMItem.add(objBOM);                            
                        }
                    }                    
                }
                
                if(!lstBOMItem.isEmpty()){
                    insert lstBOMItem;
                }
            }
            else if(rdActivityType == 3){
                List<Material__c> materialLst = new List<Material__c>();
                try{ 
                    system.debug('lstSelectedMaterial== '+lstSelectedEpisodes);
                    for(Material__c selectedMat : lstSelectedEpisodes){
                        Material__c clonedMaterial = selectedMat.clone(false,true);
                        clonedMaterial.Selection_Reference_Number__c = parentMaterialDetails.Material_Number__c;
                        clonedMaterial.Episode__c = parentMaterialDetails.id;
                        clonedMaterial.Item_Type__c = '';
                        clonedMaterial.Item_Code__c = '';
                        clonedMaterial.Base_Unit_of_Measure__c = 'ZEP';
                        clonedMaterial.Cross_Ref_Type__c = 'HEEP';
                        system.debug('clonedMaterial '+clonedMaterial);
                        materialLst.add(clonedMaterial);
                    }
                    if(materialLst.size()>0){
                        system.debug('materialLst=== '+materialLst);
                        insert materialLst; 
                    }
                }catch(Exception e){
                    System.debug('---exception: '+e.getMessage());
                }
            }
            //redirecting the user to parent material detail page
            pageReference pg = new pageReference('/'+parentMaterialDetails.id);
            pg.setRedirect(true);
            return pg;
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
        else if(rdActivityType == 3){
            lstEpisodeDetails= (List<Material__c>)availableCon.getRecords();
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
        else if(rdActivityType == 3){
            lstEpisodeDetails= (List<Material__c>)availableCon.getRecords();
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
        else if(rdActivityType == 3){
            lstEpisodeDetails= (List<Material__c>)availableCon.getRecords();
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
        else if(rdActivityType == 3){
            lstEpisodeDetails= (List<Material__c>)availableCon.getRecords();
        }
    }
    
    /************************************
    Method Name: availableConRecordQuery
    Purpose: sets the available searched records to be displayed
    *************************************/
    private void availableConRecordQuery(){
        //setting records in set controller
        System.debug('##Asha - availableConRecordQuery'+SOQL);
        availableCon = new ApexPages.StandardSetController(Database.getQueryLocator(SOQL));  
        availableCon.setPageSize(pageSize);
        
        //checking type of search activity
        if(rdActivityType == 1){
            lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
            //system.debug('lstMaterialDetails '+lstMaterialDetails );
        }
        else if(rdActivityType == 2){
            lstTitleDetails= (List<Title__c>)availableCon.getRecords();
        } 
        else if(rdActivityType == 3){
            lstEpisodeDetails= (List<Material__c>)availableCon.getRecords();
        }       
        
        //based on search type setting boolean variables
        if(!lstMaterialDetails.isEmpty()){ 
            system.debug('lstMaterialDetails==== '+lstMaterialDetails);
            paginationAvailable = TRUE;
            showMaterialSection = TRUE;
            showTitleSection = FALSE;
        }
        else if(!lstTitleDetails.isEmpty()){
            paginationAvailable = TRUE;
            showMaterialSection = FALSE;
            showTitleSection = TRUE;
        }
        else if(!lstEpisodeDetails.isEmpty()){
            paginationAvailable = TRUE;
            showMaterialSection = FALSE;
            showTitleSection = FALSE;
            showEpisodeSection = TRUE;
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
            if(!tempList.isEmpty())
            lstSelectedMaterial.addall(tempList);            
        }
        //if search is on title
        else if(rdActivityType == 2){
            List<Title__c> tempList = new List<Title__c>();
            lstSelectedTitle = new List<Title__c>();
            
            tempList = (List<Title__c>)selectedCon.getRecords();
            lstSelectedTitle.addall(tempList);            
        }
        else if(rdActivityType == 3){
            List<Material__c> tempEpisodeList = new List<Material__c>();
            lstSelectedEpisodes = new List<Material__c>();
            
            tempEpisodeList = (List<Material__c>)selectedCon.getRecords();
            lstSelectedEpisodes.addall(tempEpisodeList);            
        }
        
        //setting boolean variables based on search type
        if(lstSelectedMaterial!=null && !lstSelectedMaterial.isEmpty()){
            selectedPaginationAvailable = TRUE;            
        }
        else if(lstTitleDetails!=null && !lstTitleDetails.isEmpty()){
            selectedPaginationAvailable = TRUE;
        }
        else if(lstEpisodeDetails!=null && !lstEpisodeDetails.isEmpty()){
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
        selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
        lstSelectedMaterial = new List<Material__c>();
        setAlreadyAdded = new Set<ID>();
        selectedPaginationAvailable = FALSE;
        lstAllAddedTitle =  new List<Title__c>();
        lstSelectedTitle = new List<Title__c>();
        lstAllAddedEpisode = new List<Material__c>();
        lstSelectedEpisodes = new List<Material__c>();
        showAccept = FALSE;
        return null;
    }
    
    /************************************
    Method Name: cancelSelection
    Purpose: redirects user to material record
    *************************************/
    
    public pageReference cancelSelection(){
        PageReference pg = new PageReference('/'+parentMaterialDetails.id);  
        return pg;  
   }
   /************************************
    Method Name: cancelSelection
    Purpose: redirects user to material list view 
    *************************************/
   
   public pageReference cancelSelected(){
        PageReference pg = new PageReference('/?retURL=/a0V/o');  
        return pg;  
   }
   
   /************************************
    Method Name: sendDirecttoSAP
    Purpose: below method update material status and lock bom item records 
    *************************************/
   public pageReference sendDirecttoSAP(){
   try{
        List<BOM_Item__c> bitemList = new List<BOM_Item__c>();
        List<Material__c> matList = new List<Material__c>();
        List<Id> recordsToLock = new List<Id>();
        Map<id,List<id>> bomMatMap=new Map<id,List<id>>();
        Map<id,String>matIDNameMap=new Map<id,String>();
        Set<id>matRejected=new Set<id>();
        
        bitemList = [select id,Material__c,Material_Component__c,Material__r.Name,Material__r.Material_Number__c,Material__r.Valid_From__c,Valid_To__c from BOM_Item__c where Material__c IN : lstSelectedMaterial];
        system.debug('bitemList == '+bitemList );
       
        /* Changes for USST -2807 start. Also in the above line added Material Number, Valid From and Valid To field - Ashok*/
       
         List<string> lstExpriedComp = new List<String>();

       
       
                for(BOM_Item__c item : bitemList){
       
                      Date nextdate = Date.today().addDays(+1);
                     if(item.Valid_To__c != null && ( item.Valid_To__c <= nextdate || item.Valid_To__c  < item.Valid_From__c ))
                        {
                            lstExpriedComp.add(item.Material__r.Material_Number__c);     
                        }
                 
                }
                
                if(lstExpriedComp.size() > 0  ){
                    for(integer i=0; i < lstExpriedComp.size(); i++  ){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Error: Material # ' + lstExpriedComp[i] + '  has an expired component. Please remove BOMs from selected list and submit.'));
                    }
                     return null;
                }
        //-- Changes for USST 2807 end. - Ashok
       
       
        
        //Code for checking if BOMItems are present for the selected Material - STY-900
        for(BOM_Item__c bitem:bitemList){
            if(!matIDNameMap.containsKey(bitem.Material__c)){
                matIDNameMap.put(bitem.Material__c,bitem.Material__r.Name);
            }
            if(bomMatMap.containsKey(bitem.Material__c)){
                bomMatMap.get(bitem.Material__c).add(bitem.id);
            }
            else{
                bomMatMap.put(bitem.Material__c,new List<id>{bitem.id});
            }
            
        }
        
        /*for(BOM_Item__c bitem : bitemList){
            if(bitem.Material__c != null){
                Material__c mat = new Material__c();
                mat.id = bitem.Material__c;
                mat.BOM_Status__c = 'Approved';
                system.debug('mat=== '+mat);
                matList.add(mat);
            }
        }*/
        
        for(Material__c mt : lstSelectedMaterial){
            //if(bitem.Material__c != null){
                //Material__c mat = new Material__c();
                if(bomMatMap.containskey(mt.id) && bomMatMap.get(mt.id).size()>0){
                    //mt.send_direct_to_SAP__c = true;
                    mt.BOM_Status__c = 'Approved';
                    mt.BOM_Integration_State__c = 'N';
                    //system.debug('mat=== '+mat);
                    matList.add(mt);
                }
                else {
                        //matRejected=matRejected +';'+ mt.Name;
                        matRejected.add(mt.id);
                }
           // }
        }
        
        System.debug('check BOM Status '+matList);
        if(!matList.isEmpty()){
            update matList;
        }
        
        for(BOM_Item__c bitem : bitemList){
            recordsToLock.add(bitem.id);
        }   
        if(recordsToLock.size() > 0){
            RecordLocker.lock(recordsToLock);
        }
        //Validation message for Materials with no Bom items
        if(!matRejected.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,'No components associated with the following Materials,'));
            for(Material__c mat:[Select Name,id from Material__c where id in :matRejected]){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,mat.Name));
            }
        }
        else if(bitemList.size() > 0 && matRejected.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,'BOM Status has been updated to appoved successfully.'));
        }
        /*else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,'No BOM exists for the material'));
        }*/
       }
       catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please contact system admin. '+ex.getMessage()));
       }
        return null;  
   }
   /************************************
    Method Name: accept
    Purpose: below method will close pop up window 
    *************************************/
   
    public void accept(){
        List<Material__c> lstInsertMaterial = new List<Material__c>();
        lstBOMItem = new List<BOM_Item__c>();
        
        try{ 
            system.debug('lstSelectedMaterial== '+lstSelectedMaterial);
            cache.session.put('selectedMat',lstSelectedMaterial,300);
            System.debug('---cache.session> '+cache.session.getKeys());
            closeWindow = true;
        }catch(Exception e){
            System.debug('---exception: '+e.getMessage());
        }    
    }
}