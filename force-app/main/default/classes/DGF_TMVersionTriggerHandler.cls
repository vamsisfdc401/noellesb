/***********************************************************************************
Class Name: DGF_TMVersionTriggerHandler
Purpose: Handler class for TM Version trigger
******************************************************************************************
Version         DateModified         ModifiedBy            Change
1.0             26/10/2017           Mohit                 Initial Development - DFOR-1092
******************************************************************************************/
public with sharing class DGF_TMVersionTriggerHandler {
    
    /*****private declaration*****/
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Set<ID> setTMVersionId = new Set<ID>();    
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id PreOrderTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PRE_ORDER).getRecordTypeId();
    
    /***********************************
    Method Name: resetDataSet
    Purpose: method to reset context data variable
    ***********************************/
    private static void resetDataSet() {    
        fetchDataSet.clear();
        updateableDataSet.clear();
        setTMVersionId.clear(); 
    }
    
    /***********************************
    Method Name: getDataSet
    Purpose: method for executing SOQL
    ***********************************/
    @testVisible private static void getDataSet() {      
        //if TM Version set not empty
        if (!setTMVersionId.isEmpty()) {
            //adding a instance of digital release in the map
            if (!fetchDataSet.containsKey('Product_Version__c')) {
                fetchDataSet.put('Product_Version__c',new Map<ID,sObject>());
            }                
            
            //looping over digital release
            for (Product_Version__c pv : [Select Id, Product__c, Product__r.RecordTypeId, TM_Version__c, TM_Version__r.TVD_SAFE_Production_ID__c, 
                                              TM_Version__r.Version_EIDR__c from Product_Version__c where TM_Version__c in: setTMVersionId]) {
                fetchDataSet.get('Product_Version__c').put(pv.ID, pv);  
            } 
        }
    }
    
    /***********************************
    Method Name: commitDataSet
    Purpose: Method for performing DML operations
    ***********************************/
    @testVisible private static void commitDataSet() {    
        //for updating records
        if (!updateableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : updateableDataSet.keySet()) {    
                
                // getting list to update            
                Map<Id, SObject> dataSet = updateableDataSet.get(sobjectApi);
                
                //updating records
                if (!dataSet.isEmpty()) {
                    try {
                        update dataSet.values();
                    }
                    catch (DMLException de) {
                        Trigger.New[0].addError(de.getDMLMessage(0));
                    }
                    catch (Exception ex) {
                        Trigger.New[0].addError(ex.getMessage());
                    }                   
                }
            }
        }
    }
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {
        //first iteration over trigger.new to create collections
        for (TM_Version__c tm : (List<TM_Version__c>)trigger.new) {
            //adding version id to set
            if (!setTMVersionId.contains(tm.id)) {
                setTMVersionId.add(tm.id);
            }
        }
        
        //fetching data set for processing
        getDataSet(); 
        
        //method to create product instance to be updated
        updateProductAndEIDR();
        
        //commit records
        commitDataSet();
        
        //reset data set
        resetDataSet();
    }
    
    /***********************************
    Method Name: updateProductAndEIDR
    Purpose: Method to create instance for updating Product ID and EIDR from TM Version
    ***********************************/
    public static void updateProductAndEIDR() {
        //if map does not contain key then return
        System.debug('TRIGGER FIRED?????');
        if (!fetchDataSet.containsKey('Product_Version__c') || fetchDataSet.get('Product_Version__c') == null) {
            return;
        }
        
        //boolean to check if record has to be added for update
        Boolean isUpdateRequired = FALSE;
        
        //looping over product versions
        for (Id pvId : fetchDataSet.get('Product_Version__c').KeySet()) {
            //getting product version instance
            Product_Version__c pv = (Product_Version__c)fetchDataSet.get('Product_Version__c').get(pvId);
            
            //setting default to false
            isUpdateRequired = FALSE;
            
            //if product is of type FILM or TV  //1498 - PreOrder Inclusion
            if (pv.Product__r.RecordTypeId == FilmRecTypeId || pv.Product__r.RecordTypeId == TVRecTypeId || 
            		pv.Product__r.RecordTypeId == PreOrderTypeId) {
                
                //creating an instance for Product
                Product__c updtProd = new Product__c();
                updtProd.id = pv.Product__c;
                
                //getting new instance of TM Version
                TM_Version__c tmNew = (TM_Version__c)Trigger.NewMap.get(pv.TM_Version__c);
                //getting old instance of TM Version
                TM_Version__c tmOld = (TM_Version__c)Trigger.oldMap.get(pv.TM_Version__c);
                
                //if new TVD Safe Production id has been changed
                if (tmNew.TVD_SAFE_Production_ID__c != tmOld.TVD_SAFE_Production_ID__c) {
                    isUpdateRequired = TRUE;
                    updtProd.Product_ID__c = tmNew.TVD_SAFE_Production_ID__c;
                }
                
                //if new Version EIDR has been changed
                if (tmNew.Version_EIDR__c != tmOld.Version_EIDR__c) {
                    isUpdateRequired = TRUE;
                    updtProd.EIDR__c = tmNew.Version_EIDR__c;
                }
                
                //if true add to map
                if (isUpdateRequired) {
                    if (!updateableDataSet.containsKey('Product__c')) {
                        updateableDataSet.put('Product__c', new Map<Id, SObject>()); 
                    }                        
                    
                    updateableDataSet.get('Product__c').put(pv.Product__c, updtProd);                   
                }                               
            }
        }
    }
}