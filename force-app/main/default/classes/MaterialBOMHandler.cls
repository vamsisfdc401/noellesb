/*****************************************************************************************
Class Name: MaterialBOMHandler
Purpose: This class is the controller of CreateBOMItemPage. It handles all the business 
         logic of the page.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/07/2016           Suman Kundu              Initial Development
******************************************************************************************/
public with sharing class MaterialBOMHandler
{
    // Local variables.
    public List<BOM_Item__c> bomItemList {get; set;}
    public Integer itemIndex {get; set;}
    String returnPath;
    Id childMaterialId;
    
    // used for csv parsing  
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public string csvContentType{get;set;}
    public string parentId{get;set;} 
    
    // available standardset controller 
    ApexPages.StandardSetController availableCon;
    // selected standard set controller 
    ApexPages.StandardSetController selectedCon;
    
    // holds list of materials to display available materials
    public List<Material__c> lstMaterialDetails{get;set;}
    // indicates whether to show paginations
    public boolean paginationAvailable{get;set;}
    public boolean selectedPaginationAvailable{get;set;}
    
    // holds available material row number in list  
    public integer mtRowNumber{get;set;}
    // holds available material id in list
    public ID paramID{get;set;}
    
    // holds selected material row number in list  
    public integer selectedRowNumber{get;set;}
    
    // holds added materials in selected list
    private set<ID> setAlreadyAdded;
    // added to selected list material
    private List<Material__c> lstAllAddedMaterials;
    
    // holds selected materials list 
    public List<Material__c>lstSelectedMaterial{get;set;}
    
    // indicate whether to show accept button 
    public boolean showAccept{get;set;}
    
    // indicate default records size
    public integer pageSize{get;set;} 
    
    // holds material number set 
    private Set<string> MaterialNumbers; 
    // indicates whether to close popup window
    public Boolean closeWindow {get; private set;}
    // indicate whether to show material section
    public boolean showMaterialSection{get;set;}
    // This is extension constructor which handles initialization of variables.
    public MaterialBOMHandler(ApexPages.StandardController con)
    {
        childMaterialId = con.getId();
        bomItemList = new List<BOM_Item__c>();
        bomItemList.add(new BOM_Item__c());
        
        itemIndex = -1;
        returnPath = '';
        // It stores the return path from the page parameters.
        if(apexpages.currentpage().getparameters().containsKey('retURL'))
            returnPath = apexpages.currentpage().getparameters().get('retURL');
         
       parentId  = ApexPages.currentPage().getParameters().get('id');
         
       pageSize = 20;
       showAccept = false;
       showMaterialSection = false;
        closeWindow = false;
        
     //Initializing standard set controller
        availableCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
        selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
        
        //Initializing collection
        lstAllAddedMaterials = new List<Material__c>();
        setAlreadyAdded = new Set<ID>();
        
        lstSelectedMaterial = new List<Material__c>();
    }
    
    // This method handles the Add BOM Item action.
    public void addBOMItem()
    {
        bomItemList.add(new BOM_Item__c());
    }
    
    // This method handles the Remove BOM Item action.
    public void removeBOMItem()
    {
        if(itemIndex >= 0)
            bomItemList.remove(itemIndex);
    }
    
    // Following method is responsible to evaluate the requested BOM Item and insert the same if there is no issue.
    // And finally it redirects to retURL path.
    public PageReference save()
    {
        Set<Id> selectedMaterialIds = new Set<Id>();
        List<BOM_Item__c> insertableBomItemList = new List<BOM_Item__c>();
        List<BOM_Item__c> finalinsertableBomItemList = new List<BOM_Item__c>();
        
        if(bomItemList != null && bomItemList.size() > 0)
        {
            // Iterating to get all the unique Material ids.
            for(BOM_Item__c bi : bomItemList)
            {
                if(bi.Material__c != null)
                    selectedMaterialIds.add(bi.Material__c);
            }
            // Fetching out selected material data.
            Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, Name, Format_Description__c 
                                                                         FROM Material__c
                                                                         WHERE Id IN :selectedMaterialIds]);
            // Preparing BOM Item list to be inserted.
            for(BOM_Item__c bi : bomItemList)
            {
                if(bi.Material__c != null && materialMap.containsKey(bi.Material__c))
                {
                    if(childMaterialId != null)
                        bi.Material_Component__c = childMaterialId;
                    else
                        bi.Material_Component__c = bi.Material__c;
                    bi.Component_Quantity__c = '1';
                    
                    insertableBomItemList.add(bi);
                }
            }
            
            for(BOM_Item__c boi : insertableBomItemList){
                if(boi.Id == null){
                    finalinsertableBomItemList.add(boi);
                }
            }
            
            // Checking if there are BOM Items ready to be created.
            if(insertableBomItemList.size() > 0)
            {
                try
                {
                
                    // Inserts BOM Items.
                    insert finalinsertableBomItemList;
                    
                    if(returnPath != '')
                        return new PageReference(returnPath);
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'BOM Items are created successfully.'));
                }
                catch(DmlException dex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: '+dex.getDmlMessage(0)));
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: '+ex.getMessage()));
                }
            }
            else
            {
                // Add Message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'BOM Items could not be created.'));
            }
            
        }
        // Checks if there is BOM Item provided in the page.
        else
        {
            // Add Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add BOM Item(s) to be inserted.'));
        }
        
        return null;
    }
    
    // This method is responsible to handle Cancel scenario.
    public PageReference cancel()
    {
        if(returnPath != '')
            return new PageReference(returnPath);
        else
            return new PageReference('/home/home.jsp');
    }
    

    // converts the csv into records
    public pageReference btnUploadCSV(){
        // holds csv string 
        String[] filelines = new String[]{};
        lstMaterialDetails = new List<Material__c>();
        // show panel 
        showMaterialSection = true;
        
        try{
            if(string.valueof(csvFileBody) != '' && string.valueof(csvFileBody) != null){
                string csvAsString = csvFileBody.toString();
                //Now seperate every row of the excel file
                filelines = csvAsString.split('\n');
                
                //Iterate through every line and create a material record for each row
                MaterialNumbers =  new set<string>();
                
                for (Integer i=1;i<filelines.size();i++){
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    system.debug('inputvalues from csv-->'+inputvalues);
                    
                    if(!inputvalues.isEmpty()){
                        system.debug('material number-->'+inputvalues[0]);
                        // need to check later to have static value in custom label to compare the csv file because we concentrate on material Number column
                        if(!String.isEmpty(inputvalues[0]))MaterialNumbers.add(inputvalues[0].trim());
                    }
                    
                }
                
                string fetchQueryStr = '';
                if(!MaterialNumbers.isEmpty()){
                  system.debug('materials number-->'+MaterialNumbers);
                  //build query string for material object 
                  fetchQueryStr = queryString(fetchQueryStr);
                  system.debug('query string -->'+fetchQueryStr);
                  //calling set controller method
                  availableConRecordQuery(fetchQueryStr);
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.'));
                return null; 
            }
         }
        catch(exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));
        }
        return null;
    }
    
    // fetch query string 
    private string queryString(string queryStr){
      system.debug('material numbers to fetch material-->'+MaterialNumbers);
      
        queryStr = 'Select id,name,SGENNO__c, Material_Number__c,Material_Type__c, Component_Type__c, MPM_Issue__c, Label_Code__c,Material_Status__c,Format_Description__c,Item_Type__c,Item_Code__c,Title__c,Retailer_Rental__c,BOM_Quantity__c,Association_Required__c,Release__c,Territory__c,Count_Sales_for_D_Chain_Status__c, Sub_Label_Code_Lookup__c, BOM_Status__c from Material__c ';
        queryStr += ' where Deletion_Flag__c = FALSE ';
        queryStr += ' AND Material_Number__c in : MaterialNumbers ';                         
        queryStr  = queryStr + ' Limit 1000'; 
        return  queryStr;
    }
    
    /************************************
    Method Name: availableConRecordQuery
    Purpose: sets the available searched records to be displayed
    *************************************/
    private void availableConRecordQuery(string SOQL){
        //setting records in set controller
        availableCon = new ApexPages.StandardSetController(Database.getQueryLocator(SOQL));  
        availableCon.setPageSize(pageSize);
        lstMaterialDetails = (List<Material__c>)availableCon.getRecords();
        
        //based on search type setting boolean variables
        if(!lstMaterialDetails.isEmpty()){            
            paginationAvailable = TRUE;
        }
        else{
            paginationAvailable = FALSE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'No matching records found.'));   
        }
        system.debug('materials list-->'+lstMaterialDetails);
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
    Method Name: setSelectedMaterial
    Purpose: add selected material
    *************************************/    
    public pageReference setSelectedMaterial(){  
        //if record has not already been selected
        if(!setAlreadyAdded.contains(paramID)){
            //adding selected record to a list
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
    Method Name: selectedConRecordSet
    Purpose: setting set controller for selected records
    *************************************/
    private void selectedConRecordSet(){
        //if search ison material
        List<Material__c> tempList = new List<Material__c>();
        lstSelectedMaterial = new List<Material__c>();
        
        tempList = (List<Material__c>)selectedCon.getRecords();
        lstSelectedMaterial.addall(tempList);            
        
        //setting boolean variables based on search type
        if(!lstSelectedMaterial.isEmpty()){
            selectedPaginationAvailable = TRUE;            
        }
        else{
            selectedPaginationAvailable = FALSE;
        }
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
    Method Name: removeAll
    Purpose: clearing all the lists on click of remove all button
    *************************************/
    public pageReference removeAll(){
        lstAllAddedMaterials = new List<Material__c>();
        selectedCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select id from Material__c where name =' + '\''+ '\''));  
        lstSelectedMaterial = new List<Material__c>();
        setAlreadyAdded = new Set<ID>();
        selectedPaginationAvailable = FALSE;
        showAccept = FALSE;
        return null;
    }
    
    /************************************
    Method Name: accept
    Purpose: inserts the BOM Items on click of accept button
    *************************************/
    
     public void accept(){
      // holds list of bom itmes to insert 
      List<BOM_Item__c> lstBOMItem = new List<BOM_Item__c>();
        
        try{
          for(Material__c selMaterial: lstSelectedMaterial){
           BOM_Item__c bomItem = new BOM_Item__c ();
                bomItem.Material__c = selMaterial.Id;
                bomItem.Material_Component__c = parentId;
                system.debug('bomItem-->'+bomItem);
                lstBOMItem.add(bomItem);
          
          }
          
          if(!lstBOMItem.isEmpty()){
            insert lstBOMItem;
          }
            system.debug('lstSelectedMaterial== '+lstSelectedMaterial);
            cache.session.put('selectedMat',lstSelectedMaterial,300);
            closeWindow = true;
        }catch(Exception e){
            System.debug('---exception: '+e.getMessage());
        }    
    }

}