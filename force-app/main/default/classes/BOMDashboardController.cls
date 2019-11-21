/*****************************************************************************************
Class Name: BOMDashboardController
Purpose: Apex class for BOM Item Dashboard
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/07/2016           Mohit                    Initial Development
******************************************************************************************/  
public with sharing class BOMDashboardController {    
    
    /*** Public Instance Methods ***/
    public String sortField{set;get;}
    public String sortDirection{set;get;}
    public String saveRecordId {get;set;}
    public String saveBOMId    {get;set;}  
    
    private integer pageSize = 50;
    private List<Material__c> lstMaterial;
    private set<string> setMaterialID;
    
    //Set Controller for pagination
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {                
                if(sortField == null)
                    sortField = 'Material__r.Material_Number__c';                
                if(sortDirection == null)
                    sortDirection = 'ASC';                
                
                con = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id, Name,Material__r.Material_Number__c,Material__r.Name,Material__r.BOM_Status__c,Material__r.Operation_Group__c,Material__r.PIR_Created__c,lastmodifieddate,Material__r.Sales_Org__c,Material__r.D_Chain_Spec__c,Material__r.Material_Status__c,Material__r.Purchasing_Group__c,Material__r.Canada_PIR_Flag__c FROM BOM_Item__c ' + ' ORDER BY ' + sortField + ' ' + sortDirection +  ' NULLS LAST ' +' ' + 'Limit 10000'));
                // sets the number of records in each page set
                con.setPageSize(pageSize);
            }
            return con;
        }
        set;
    }
    
    //Creation of constructor with parameter StandardSetController
    public BOMDashboardController(ApexPages.StandardSetController c) {}
    
    public BOMDashboardController() {
        //readOnlyMode = TRUE;
        //editMode = FALSE;
    }
    
    
    /************************************
    Method Name: getBOMItemList
    Purpose: for populating page block table on VF
    *************************************/
    public List<BOM_Item__c> getBOMItemList() {
        return (List<BOM_Item__c>)con.getRecords();
    }    
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns the first page of records
    public void first() {
        con.first();
    }
    
    // returns the last page of records
    public void last() {
        con.last();
    }
    
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
    
    // returns the next page of records
    public void next() {
        con.next();
    }
    
    /************************************
    Method Name: toggleSort
    Purpose: for sorting
    *************************************/
    public pagereference toggleSort() {        
        sortDirection = sortDirection.equalsIgnoreCase('ASC') ? 'DESC' : 'ASC';
        con = null;
        con = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id, Name,Material__r.Canada_PIR_Flag__c ,Material__r.Material_Number__c,Material__r.Name,Material__r.BOM_Status__c,Material__r.Sales_Org__c,Material__r.Operation_Group__c,Material__r.PIR_Created__c,lastmodifieddate,material__r.id,Material__r.D_Chain_Spec__c,Material__r.Purchasing_Group__c FROM BOM_Item__c ' + ' ORDER BY ' + sortField + ' ' + sortDirection +  ' NULLS LAST ' +' ' + 'Limit 10000'));           
        con.setPageSize(pageSize); 
        
        return null;         
    }
    
    /************************************
    Method Name: saveRecords
    Purpose: for saving PIR changes
    *************************************/
    /*public pageReference saveRecords(){
        try{
            lstMaterial = new List<Material__c>();
            setMaterialID = new Set<string>();
            
            System.Debug('entry in save');
            
            for(BOM_Item__c bm : (List<BOM_Item__c>)con.getRecords()){
                if(!setMaterialID.contains(bm.Material__r.Id)){
                    Material__c objMaterial = new Material__c();
                    objMaterial.ID = bm.Material__r.Id;
                    System.Debug('entry in save@@ ===='+bm.Material__r.PIR_Created__c + '======M Id=='+ bm.Material__c);
                    objMaterial.PIR_Created__c = bm.Material__r.PIR_Created__c;
                    objMaterial.Canada_PIR_Flag__c = bm.Material__r.Canada_PIR_Flag__c;
                    lstMaterial.add(objMaterial);
                    setMaterialID.add(bm.Material__r.Id);
                }    
            }            
            update lstMaterial; 
             System.Debug('=====lstMaterial======='+lstMaterial);
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }     
        return null;        
    }*/
    
     /************************************
    Method Name: saveEachRecords
    Purpose: for saving PIR changes for Particular Record
    *************************************/
    public pageReference saveEachRecords(){
        try{
            lstMaterial = new List<Material__c>();
            setMaterialID = new Set<string>();
                        
            for(BOM_Item__c bm : (List<BOM_Item__c>)con.getRecords()){                   
                if(saveRecordId == (bm.Material__r.Id) && saveBOMId ==(bm.Id)){
                    if(bm.Material__r.Material_Status__c != 'Draft' && bm.Material__r.Material_Status__c != 'Sent Back'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                                            'Material is Locked and cannot be modified.'));                  
                        return null;
                    }
                    else{
                    System.debug('Inside the Save Block');    
                        Material__c objMaterial = new Material__c();
                        objMaterial.ID = bm.Material__r.Id;                                        
                        objMaterial.PIR_Created__c = bm.Material__r.PIR_Created__c;
                        objMaterial.Canada_PIR_Flag__c = bm.Material__r.Canada_PIR_Flag__c;
                        lstMaterial.add(objMaterial);
                        setMaterialID.add(bm.Material__r.Id);
                    }
                }    
            }     
            System.Debug('=====lstMaterial======='+lstMaterial);       
            update lstMaterial; 
            System.Debug('=====lstMaterial======='+lstMaterial);
        }catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact system admin. '+ex.getMessage()));              
        }  
                   
        PageReference pageRef = new PageReference('/apex/BOMDashboard?sfdc.tabName='+ApexPages.currentPage().getParameters().get('sfdc.tabName'));      
        pageRef.setRedirect(true);
        return pageRef;
                
    }    
}