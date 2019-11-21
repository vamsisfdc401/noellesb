/***********************************************************************************
Class Name: DGF_ProductTriggerHandler
Purpose: handler for product trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/05/2017           Jata                    Initial Development
1.1             12/04/2017           Prarthana               DFOR-153
******************************************************************************************/
public without sharing class  DGF_ProductTriggerHandler {
    public static boolean flag1=false;
    /*****private declaration*****/
    private static Product__c  prdOld;
    public  static Boolean flag=false;
    private static Set<ID> setProductID = new Set<ID>();
    private static Set<ID> setProductPriceCreationID = new Set<ID>();
    private static Set<ID> setProductESTID = new Set<ID>();
    private static Set<ID> setPrdctIDToDelete = new Set<ID>(); 
    private static Map<ID,Map<String,Set<String>>> mapProdAndPlatform = new Map<ID,Map<String,Set<String>>>();
    private static Set<String> setTerritory = new Set<String>();
    private static Map<ID,Map<String,Set<String>>> mapTerrAndResolution = new Map<ID,Map<String,Set<String>>>();
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, List<pricing__c>> fetchProductPricingDataSet = new Map<String, List<pricing__c>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, Map<Id, SObject>> deleteableDataSet = new Map<String, Map<Id, SObject>>(); 
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id FilmRecTypeIdOfRelease = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeIdOfRelease = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static List<Pricing__c> pricingListToIns = new List<Pricing__c>();
    private static List<Pricing__c> pricingListToDelete = new List<Pricing__c>();
    private static List<Pricing__c> pricingListToUpdate = new List<Pricing__c>();
    private static Set<String> usOldPlatformValues = new Set<String>();
    private static Set<String> usNewPlatformValues = new Set<String>();
    private static Set<String> caOldPlatformValues = new Set<String>();
    private static Set<String> caNewPlatformValues = new Set<String>();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id PreOrderRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
    private static Id BundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id TVEpisodeRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.EPISODE_PRICING).getRecordTypeId();
    private static set<id>setReleaseId = new set<ID>();
    private static map<Id,Digital_Release__c>releaseMap = new map<Id,Digital_Release__c>();
    private static Map<Id,Boolean> prodVersionMap = new map<Id,Boolean>();
    private static Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
    private static Id TvProductAccRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id PreOrderAccRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
    private static map<Id,Product__c> preOrderMap = new map<Id,Product__c> ();
    
    /***********************************
Method Name: resetDataSet
Purpose: method to reset context data variable
***********************************/
    private static void resetDataSet() { 
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear();
        pricingListToIns.Clear();
        pricingListToDelete.clear();
        usOldPlatformValues.clear();
        usNewPlatformValues.clear();
        caOldPlatformValues.clear();
        caNewPlatformValues.clear(); 
        setProductPriceCreationID.clear();     
        prodVersionMap.clear(); 
        preOrderMap.clear();
    }
    
    /***********************************
Method Name: getDataSet
Purpose: method for executing SOQL
***********************************/
    @testVisible private static void getDataSet() {
        //getting list of products
        if (!setProductID.isEmpty()) {
            if (!fetchDataSet.containsKey('Product__c')) {
                fetchDataSet.put('Product__c',new Map<ID,sObject>());
            }
            
            for (Product__c prod : [Select Id, Version_Availability__c, RecordType.Name, Digital_Release__c, X3D__c, HD__c, SD__c, UHD__c, US_Platform_Offering__c, US_VOD_Tier__c, CA_VOD_Tier__c,
                                    CA_Platform_Offering__c, Digital_Release__r.US_Launch_VOD_Categorization__c, Digital_Release__r.Categorization__c, Digital_Release__r.Scripted_Reality__c,
                                    //Digital_Release__r.Network_Categorization__c DFOR-1578
                                    Digital_Release__r.US_Network_Categorization__c, Digital_Release__r.TV_Studio__c, 
                                    Digital_Release__r.US_EST_Launch_Date__c, Digital_Release__r.CA_EST_Launch_Date__c, Digital_Release__r.CA_Launch_VOD_Categorization__c, Digital_Release__r.US_EPO_Date__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c, Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,
                                    Digital_Release__r.CA_EPO_Date__c, Digital_Release__r.US_EST_Date__c, EST_Tier__c, CA_EST_Tier__c,
                                    Digital_Release__r.CA_EST_Date__c, Digital_Release__r.US_VOD_Start_Date__c,
                                    Digital_Release__r.CA_VOD_Start_Date__c, Digital_Release__r.US_VOD_End_Date__c, Digital_Release__r.CA_EST_Rights__c,
                                    Digital_Release__r.CA_VOD_End_Date__c, Digital_Release__r.Name, Digital_Release__r.RecordTypeId, RecordTypeId, (Select Id, iTunes_Tier__c, Platform__c, Account__c , 
                                                                                                                                                    Price_Type__c, Territory__c, Resolution__c, Valid_From__c, Valid_To__c, Category__c, Product__c, Product__r.Id, Product__r.Name from Pricing__r), (Select id, Product__c, Account__c , Account__r.Pre_Order_Best_Version__c, Version__c From Product_Account__r)from Product__c where ID in : setProductID]) {                          
                                                                                                                                                        
                                                                                                                                                        fetchDataSet.get('Product__c').put(prod.ID, prod);
                                                                                                                                                        //DFOR-1434
                                                                                                                                                        list<pricing__c> pricingRecList = new list<pricing__c>();
                                                                                                                                                        for(pricing__c pr: prod.Pricing__r){
                                                                                                                                                            pricingRecList.add(pr); 
                                                                                                                                                        }
                                                                                                                                                        fetchProductPricingDataSet.put(prod.id,pricingRecList);                                 
                                                                                                                                                    }
            
            
            
            
        } 
        
        //get release details
        if (!setReleaseId.isEmpty()) {
            for (Digital_Release__c dig : [select id, US_Launch_VOD_Categorization__c, CA_Launch_VOD_Categorization__c, US_EST_Date__c, CA_EST_Date__c, US_VOD_Start_Date__c,
                                           CA_VOD_Start_Date__c, US_EPO_Date__c, CA_EPO_Date__c, X3D__c, UHD__c, SD__c, HD__c FROM Digital_Release__c where id in : setReleaseId]){
                                               releaseMap.put(dig.id,dig);
                                               
                                           }
        }
        
        //getting pricing tier records
        if (!fetchDataSet.containsKey('Pricing_Tier__c')) {
            fetchDataSet.put('Pricing_Tier__c',new Map<ID,sObject>());
        }
        for(Pricing_Tier__c pt : [SELECT ID, Product_Type__c, Category__c, WSP__c, SRP__c, Territory__c, Resolution__c, Platform__c from Pricing_Tier__c WHERE Product_Type__c in  ('TV','film')]) {
            fetchDataSet.get('Pricing_Tier__c').put(pt.ID, pt);
        }
        if (!fetchDataSet.containsKey('Account')) {
            fetchDataSet.put('Account',new Map<ID,sObject>());
        }
        //query for all accounts with Digital Partner RecordType
        for(Account acc : [SELECT ID, RecordTypeId, Pre_order__c, Territory__c, RecordType.Name, Categorization__c, Scripted_Reality__c, Network_Categorization__c, Bonus__c FROM Account where 
                           RecordTypeId =:AccRecTypeId ]) {
                               fetchDataSet.get('Account').put(acc.ID, acc);
                           }
        
        
    }
    
    /***********************************
Method Name: commitDataSet
Purpose: Method for performing DML operations
***********************************/
    @testVisible private static void commitDataSet() {
        //for inserting records
        if (!insertableDataSet.isEmpty()) {
            /* if(insertableDataSet.containsKey('Product_Account__c')){
database.insert(insertableDataSet.get('Product_Account__c'));
}*/
            //looping over collection
            for (String sobjectApi : insertableDataSet.keySet()) {
                
                if (sobjectApi == null) {
                    continue;
                }
                
                //get list to be inserted
                List<SObject> dataSet = new list<Sobject>();
                if (insertableDataSet.containskey(sobjectApi)) {
                    for(String key : insertableDataSet.keySet()) {
                        dataSet = insertableDataSet.get(sobjectApi);
                        
                    }
                    
                    //inserting records
                    if (!dataSet.isEmpty()) {
                        try {
                            system.debug('sobjectApi is '+ sobjectApi+' dataSet is '+dataSet);
                            insert dataset;
                        }
                        catch (DMLException de) {
                            system.debug('stack trace is '+de.getStackTraceString());
                            Trigger.New[0].addError(de.getDMLMessage(0));
                        }
                        catch (Exception ex) {
                            Trigger.New[0].addError(ex.getMessage());
                        }
                    }
                }
            }
        }
        
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
        
        //for deleting records
        if (!deleteableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : deleteableDataSet.keySet()) {
                
                //getting list to delete
                Map<Id, SObject> dataSet = deleteableDataSet.get(sobjectApi);
                
                //deleting records
                if (!dataSet.isEmpty()) {
                    delete dataSet.values();
                }
            }
        }
    }
    
    /***********************************
Method Name: executeOnBeforeInsert
Purpose:Should execute only for before insert event
***********************************/    
    public static void executeOnBeforeInsert() {
        //first iteration over trigger.new to create collections
        for (Product__c pr : (List<Product__c>)trigger.new) {
            if (!setProductID.contains(pr.Id)) {
                setProductID.add(pr.Id);
                setReleaseId.add(pr.Digital_Release__c);
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Product__c prod : (List<Product__c>)trigger.new) {
            if (prod.RecordTypeId == FilmRecTypeId) {
                
                if (prod.Digital_Release__c != null) {
                    if (releaseMap.containsKey(prod.Digital_Release__c)) {
                        if (releaseMap.get(prod.Digital_Release__c).US_Launch_VOD_Categorization__c != null) {
                            prod.US_VOD_tier__c = releaseMap.get(prod.Digital_Release__c).US_Launch_VOD_Categorization__c;
                        }
                        if (releaseMap.get(prod.Digital_Release__c).CA_Launch_VOD_Categorization__c != null) {
                            prod.CA_VOD_tier__c = releaseMap.get(prod.Digital_Release__c).CA_Launch_VOD_Categorization__c;
                        } 
                    }
                }
            }
            
            if (prod.Digital_Release__c != null && releaseMap.containsKey(prod.Digital_Release__c)) {
                if (releaseMap.get(prod.Digital_Release__c).X3D__c == TRUE) {
                    prod.X3D__c = releaseMap.get(prod.Digital_Release__c).X3D__c;
                } 
                if (releaseMap.get(prod.Digital_Release__c).UHD__c == TRUE) {
                    prod.UHD__c = releaseMap.get(prod.Digital_Release__c).UHD__c;
                } 
                if (releaseMap.get(prod.Digital_Release__c).HD__c == TRUE) {
                    prod.HD__c = releaseMap.get(prod.Digital_Release__c).HD__c;
                } 
                if (releaseMap.get(prod.Digital_Release__c).SD__c == TRUE) {
                    prod.SD__c = releaseMap.get(prod.Digital_Release__c).SD__c;
                }
            }
            if (prod.RecordTypeId == FilmRecTypeId || prod.RecordTypeId == BundleRecTypeId) {
                prod.HDR__c = prod.UHD__c;
            }
        }
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
Method Name: executeOnBeforeUpdate
Purpose:Should execute only for before update event
***********************************/    
    public static void executeOnBeforeUpdate(){
        //first iteration over trigger.new to create collections
        for (Product__c pr : (List<Product__c>)trigger.new) {
            if (!setProductID.contains(pr.Id)) {
                setProductID.add(pr.Id);
                setReleaseId.add(pr.Digital_Release__c);
            }
            //get old instance of product
            prdOld = (Product__c)Trigger.oldMap.get(pr.Id);
            if (pr.RecordTypeId == FilmRecTypeId || pr.RecordTypeId == BundleRecTypeId) {
                if (prdOld.UHD__c != pr.UHD__c) {
                    pr.HDR__c = pr.UHD__c;
                }
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for(Product__c prod : (List<Product__c>)trigger.new){
            
        }
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
Method Name: executeOnAfterInsert
Purpose:Should execute only for after insert event
***********************************/    
    public static void executeOnAfterInsert() {       
        List<Pricing__c> pricingListToIns = new List<Pricing__c>();
        List<Product__c> productList = new List<Product__c>();
        
        //fetching data set for processing
        for (Product__c prd : (List<Product__c>)trigger.new) {
            if (!setProductID.contains(prd.Id)) {
                setProductID.add(prd.Id);
            }
            
            if(!setReleaseId.contains(prd.Digital_Release__c)) {
                setReleaseId.add(prd.Digital_Release__c);
            }
        } 
        
        //fetching data set for processing
        getDataSet();
        for (Product__c prd : (List<Product__c>)trigger.new) {      
            //for TV Record type create call method to create TV Episode Products
            if (prd.RecordTypeID == TVRecTypeId) {
                createProductAccounts(prd);
                createTVEpisodeProducts(prd);
                
            }
            
            //for TV Episode RecordType call method to create Pricing records
            if (prd.RecordTypeId==TVEpisodeRecTypeId) {
                createTVEpisodePricing(prd);
            }
            
            //for the Pre Order Products create the Product Accounts    
            if(prd.RecordTypeID == PreOrderRecTypeId) {
                createProductAccounts(prd);
            }
        }
        //checking of product records are present and then creating pricing records
        if (fetchDataSet.containsKey('Product__c')) {
            for (sobject obj:fetchDataSet.get('Product__c').values()) {
                Product__C prd = (Product__c)obj;
                if (prd.recordTypeId == FilmRecTypeId) {
                    productList.add(prd);
                }
            }
            if (!productList.isEmpty()) {
                pricingListToIns = createPricingrecords(productList, false);
                
                //creating an insertable data set for pricing records
                if (!insertableDataSet.containsKey('Pricing__c')) {
                    insertableDataSet.put('Pricing__c', pricingListToIns);
                }
            }
        }       
        //performing DML
        commitDataSet();
        if(DGF_TriggerUtility.producTriggerExecuted) {
            DGF_TriggerUtility.producTriggerExecuted = FALSE;
        }
        
        //clear data set
        resetDataSet();
    }
    
    
    
    /***********************************
Method Name: createProductAccounts
Purpose: Method to create Product Accounts for TV Product
***********************************/    
    public static void createProductAccounts (Product__c prd) {
        list<sobject> prodAccList = new list<sobject> ();
        if(fetchDataSet.containsKey('Product__c')) {
            sobject obj = fetchDataset.get('Product__c').get(prd.id);
            prd=(Product__c)obj;
        }
        
        if(fetchDataSet.containsKey('Account')) {
            //iterate over all the accounts
            for(sobject obj : fetchDataSet.get('Account').values()) { 
                Account acc = (Account)obj;
                if(prd.RecordTypeID == TVRecTypeId) {
                    //compare the fields to check the Product accounts to be created
                    if(acc.Categorization__c != null && prd.Digital_Release__r.Categorization__c != null && acc.Categorization__c.contains(prd.Digital_Release__r.Categorization__c) &&
                       acc.Scripted_Reality__c != null && prd.Digital_Release__r.Scripted_Reality__c != null && acc.Scripted_Reality__c.contains(prd.Digital_Release__r.Scripted_Reality__c) &&
                       //acc.Network_Categorization__c != null && prd.Digital_Release__r.US_Network_Categorization__c != null && acc.Network_Categorization__c.contains(prd.Digital_Release__r.Network_Categorization__c) ) { DFOR-1578
                       acc.Network_Categorization__c != null && prd.Digital_Release__r.US_Network_Categorization__c != null && acc.Network_Categorization__c.contains(prd.Digital_Release__r.US_Network_Categorization__c) ) {
                           //create a Product Account record
                           Product_Account__c prdAcc = new Product_Account__c (Product__c = prd.Id , Account__c = acc.Id, RecordTypeId = TvProductAccRecTypeId);
                           if(acc.Territory__c == DGF_Constants.TERRITORY_US && prd.Digital_Release__r.US_EST_Launch_Date__c != null) {
                               prdAcc.launch_date__c = prd.Digital_Release__r.US_EST_Launch_Date__c;
                           }
                           else if(acc.Territory__c == DGF_Constants.TERRITORY_CA && prd.Digital_Release__r.CA_EST_Launch_Date__c != null) {
                               prdAcc.launch_date__c = prd.Digital_Release__r.CA_EST_Launch_Date__c;
                           }
                           prodAccList.add(prdAcc);
                           
                       }
                }
                //create product account for pre-order product
                else if(prd.RecordTypeID == PreOrderRecTypeId) {
                    if(acc.Pre_Order__c) {
                        Product_Account__c prdAcc = new Product_Account__c (Product__c = prd.Id , Account__c = acc.Id, RecordTypeId = PreOrderAccRecTypeId);
                        prodAccList.add(prdAcc);
                    }
                }
            }
        }
        if (insertableDataSet.containsKey('Product_Account__c')) {
            List<SObject> insertList = insertableDataSet.get('Product_Account__c');
            insertList.addAll(prodAccList);
        }
        else {
            insertableDataSet.put('Product_Account__c',prodAccList);
        }
    }
    
    /***********************************
Method Name: executeOnAfterUpdate
Purpose:Should execute only for after update event
***********************************/    
    public static void executeOnAfterUpdate() {     
        map<Id,Product_Account__c> prdAccMap = new map<Id,Product_Account__c>();
        for (Product__c prd : (List<Product__c>)trigger.new) {
            if (!setProductID.contains(prd.Id)) {
                setProductID.add(prd.Id);
            }
        }
        
        //fetching data set for processing
        for (Product__c prd : (List<Product__c>)trigger.new) {
            //get old instance of product
            prdOld = (Product__c)Trigger.oldMap.get(prd.Id);
            
            //check for Film record Type
            if (prd.RecordTypeID != FilmRecTypeId) {
                continue;
            }
            
            
            
            //get US platform offering for old instance
            if (prdOld.US_Platform_Offering__c != null) {
                usOldPlatformValues.addAll(prdOld.US_Platform_Offering__c.split(';'));
            }
            
            //get US platform offering for new instance
            if (prd.US_Platform_Offering__c != null) {
                usNewPlatformValues.addAll(prd.US_Platform_Offering__c.split(';'));
            }
            
            //get CA platform offering for old instance
            if (prdOld.CA_Platform_Offering__c != null) {
                caOldPlatformValues.addAll(prdOld.CA_Platform_Offering__c.split(';'));
            }
            
            //get CA platform offering for new instance
            if (prd.CA_Platform_Offering__c != null) {
                caNewPlatformValues.addAll(prd.CA_Platform_Offering__c.split(';'));
            }
            
            //set of product ID
            if (!setProductID.contains(prd.Id) ) {
                setProductID.add(prd.Id);
            }
            
            //creating a set of products where platform offering has been added or any of the resolution has been change to TRUE from FALSE for US/CA
            if (!setProductPriceCreationID.contains(prd.Id) && prd.RecordTypeID == FilmRecTypeId && (!usOldPlatformValues.contains(DGF_Constants.PLATFORM_EST) && usNewPlatformValues.contains(DGF_Constants.PLATFORM_EST)) || 
                (!caOldPlatformValues.contains(DGF_Constants.PLATFORM_EST) && caNewPlatformValues.contains(DGF_Constants.PLATFORM_EST)) || 
                (!usOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && usNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) || 
                (!caOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && caNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) || 
                (!usOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && usNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)) || 
                (!caOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && caNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)) || 
                (prdOld.HD__c != prd.HD__c && prd.HD__c == true)|| (prdOld.SD__c != prd.SD__c && prd.SD__c == true) ||
                (prdOld.UHD__c != prd.UHD__c && prd.UHD__c == true) || (prdOld.X3D__c != prd.X3D__c && prd.X3D__c == true)) {
                    
                    setProductPriceCreationID.add(prd.Id);
                    
                }
            
            
            //Initiating maps for territory and Resolution
            if (!mapTerrAndResolution.containsKey(prd.Id)) {
                mapTerrAndResolution.put(prd.Id, new Map<String,Set<String>>());
            }
            
            //Initiating maps for Product and Platform
            if (!mapProdAndPlatform.containsKey(prd.Id)) {
                mapProdAndPlatform.put(prd.Id, new Map<String,Set<String>>());
            }
            
            //creating a map of products and platform when US offering has been removed
            if ((usOldPlatformValues.contains(DGF_Constants.PLATFORM_EST) && 
                 !usNewPlatformValues.contains(DGF_Constants.PLATFORM_EST))) {
                     
                     mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.PLATFORM_EST});
                     
                 }
            //creating a map of products and platform when US offering has been removed
            if (((usOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && !usNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) &&
                 (usOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && !usNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)))) {
                     
                     mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.PLATFORM_VOD});
                     
                 }
            else if (usOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && 
                     !usOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) &&
                     !usNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) &&
                     !usNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)) {
                         
                         mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.PLATFORM_VOD});
                         
                     }
            else if (usOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && 
                     !usOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && 
                     !usNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) &&
                     !usNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) {
                         
                         mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.PLATFORM_VOD});
                     }
            //creating a map of products and platform when CA offering has been removed
            if ((caOldPlatformValues.contains(DGF_Constants.PLATFORM_EST) && !caNewPlatformValues.contains(DGF_Constants.PLATFORM_EST))) {
                
                mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.PLATFORM_EST});
                
            }
            //creating a map of products and platform when CA offering has been removed
            if (((caOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && !caNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) && 
                 (caOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && !caNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)))) {
                     
                     mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.PLATFORM_VOD});
                     
                 }
            else if (caOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && 
                     !caOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) &&
                     !caNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) &&
                     !caNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD)) {
                         
                         mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.PLATFORM_VOD});
                         
                     }
            else if (caOldPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) && 
                     !caOldPlatformValues.contains(DGF_Constants.PLATFORM_IVOD) && 
                     !caNewPlatformValues.contains(DGF_Constants.PLATFORM_CVOD) &&
                     !caNewPlatformValues.contains(DGF_Constants.PLATFORM_IVOD)) {
                         
                         mapProdAndPlatform.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.PLATFORM_VOD});
                         
                     }
            //creating a map of Territory and Resolution when HD resolution has been removed
            if (prdOld.HD__c != prd.HD__c && prd.HD__c == false) {
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_US)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.HD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_US).add(DGF_Constants.HD); 
                }
                
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_CA)){
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.HD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_CA).add(DGF_Constants.HD);
                }
            }
            //creating a map of Territory and Resolution when SD resolution has been removed
            if (prdOld.SD__c != prd.SD__c && prd.SD__c == false) {
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_US)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.SD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_US).add(DGF_Constants.SD); 
                }
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_CA)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.SD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_CA).add(DGF_Constants.SD); 
                }
            }
            //creating a map of Territory and Resolution when UHD resolution has been removed
            if (prdOld.UHD__c != prd.UHD__c && prd.UHD__c == false) {
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_US)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.UHD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_US).add(DGF_Constants.UHD); 
                }
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_CA)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.UHD});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_CA).add(DGF_Constants.UHD); 
                }
            }
            //creating a map of Territory and Resolution when 3D resolution has been removed
            if (prdOld.X3D__c != prd.X3D__c && prd.X3D__c == false) {
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_US)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_US, new Set<String>{DGF_Constants.X3D});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_US).add(DGF_Constants.X3D); 
                }
                if (!mapTerrAndResolution.get(prd.Id).containsKey(DGF_Constants.TERRITORY_CA)) {
                    mapTerrAndResolution.get(prd.Id).put(DGF_Constants.TERRITORY_CA, new Set<String>{DGF_Constants.X3D});
                }
                else {
                    mapTerrAndResolution.get(prd.Id).get(DGF_Constants.TERRITORY_CA).add(DGF_Constants.X3D); 
                }
            }
        }
        
        //fetching data set for processing
        getDataSet();      
        
        //looping over product record for which pricing needs to be created
        if (fetchDataSet.containsKey('Product__c')) {
            pricingListToIns = createPricingrecords(((List<Product__c> )fetchDataSet.get('Product__c').values()),false);
            
            //creating an insertable data set for pricing records
            if (!insertableDataSet.containsKey('Pricing__c') && pricingListToIns != null) {
                insertableDataSet.put('Pricing__c', pricingListToIns);
            }
            else if (pricingListToIns != null) {
                for (Pricing__c prc : pricingListToIns) {
                    insertableDataSet.get('Pricing__c').add(prc);
                }
            }                
        }
        
        //Logic to delete pricing records 
        if (!mapTerrAndResolution.isEmpty() && !mapProdAndPlatform.isEmpty()) {   
            //getting list map of record to be deleted or updated
            Map<String, List<sObject>> mapPricingDMList = DGF_DefaultProductPricing.deleteUpdateProductPricing(mapTerrAndResolution,mapProdAndPlatform);
            
            //if map not empty
            if (!mapPricingDMList.isEmpty()) { 
                //checking if updateable data set contains pricing
                if (!updateableDataSet.containsKey('Pricing__c') && mapPricingDMList.containsKey('UPDATE')) {
                    updateableDataSet.put('Pricing__c', new Map<Id, SObject>());   
                    
                    //looping over list to be updated 
                    for (sObject s : mapPricingDMList.get('UPDATE')) {
                        updateableDataSet.get('Pricing__c').put(s.ID,s);
                    }                   
                }
                else if (mapPricingDMList.containsKey('UPDATE')) {
                    
                    for (sObject s : mapPricingDMList.get('UPDATE')) {
                        updateableDataSet.get('Pricing__c').put(s.ID,s);
                    }    
                }
                
                //creating instance for delete
                if (!deleteableDataSet.containsKey('Pricing__c')&& mapPricingDMList.containsKey('DELETE')) {
                    deleteableDataSet.put('Pricing__c', new Map<Id, SObject>());
                    
                    //looping over list to be updated 
                    for (sObject s : mapPricingDMList.get('DELETE')) {
                        deleteableDataSet.get('Pricing__c').put(s.ID,s);
                    }     
                }           
            }
        }
        
        //actual processing of records
        for (Product__c prd : (List<Product__c>)trigger.new) {
            //check for Film record Type
            if (prd.RecordTypeID != FilmRecTypeId) {
                continue;
            }
            //get old instance of product
            prdOld = (Product__c)Trigger.oldMap.get(prd.Id);
            
            //for creating repricing records for US
            if(prdOld.EST_Tier__c != prd.EST_Tier__c){
                createAndUpdatePricingRecords(prd, DGF_Constants.TERRITORY_US);               
            }
            
            //for creating repricing records for CA
            if(prdOld.CA_EST_Tier__c != prd.CA_EST_Tier__c){
                createAndUpdatePricingRecords(prd, DGF_Constants.TERRITORY_CA);            
            }
            
            
        }
        //actual processing of records
        //after update of preorder product
        
        for (Product__c prd : (List<Product__c>)trigger.new) {
            System.debug('#####11111'+prdOld.Version_Availability__c);
            System.debug('#####2222'+prd.Version_Availability__c);
            System.debug('#####333'+prd);
            if(prd.RecordTypeID == PreOrderRecTypeId) {
                if(fetchDataSet.containsKey('Product__c')) {
                    Sobject obj = fetchDataSet.get('Product__c').get(prd.id);
                    Product__c prod = (Product__c)obj;
                    for(Product_Account__c pa : prod.Product_Account__r) {
                        //chek if alternate is also selected
                        if(prdOld.Version_Availability__c != null && prdOld.Version_Availability__c.contains('Theatrical') && !prdOld.Version_Availability__c.contains('Alternate') && prd.Version_Availability__c != null && prd.Version_Availability__c.contains('Theatrical') && 
                           prd.Version_Availability__c.contains('Alternate')) {
                               //if account's flag is checked
                               if(pa.account__r.Pre_Order_Best_Version__c ) {
                                   //set version on Product Account
                                   pa.Version__c = 'Alternate';
                                   prdAccMap.put(pa.id,pa);
                               }
                           }
                        
                    }
                }
            }
        }
        
        if (updateableDataSet.containsKey('Product_Account__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Product_Account__c');
            for (Sobject pa:prdAccMap.values()) {
                updateMap.put(pa.id,pa);
            }
        }
        else{
            updateableDataSet.put('Product_Account__c',prdAccMap);
        }
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();
    }
    
    /***********************************
Method Name: createTVEpisodeProducts
Purpose:Method to create TV Episode products
***********************************/    
    public static void createTVEpisodeProducts(Product__C prod1) {
        
        Product__c prod = new Product__c();
        
        if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c').containsKey(prod1.ID)) {
            prod = ((Product__c)fetchDataSet.get('Product__c').get(prod1.ID));
        }
        else {
            return;
        }
        
        if (!insertableDataSet.containsKey('Product__c')) {
            insertableDataSet.put('Product__c', new List<SObject>());
        }
        
        //creating an instance of Product
        Product__c tvEpisodeProd = new Product__c(Name = prod.Digital_Release__r.Name+'(per Episode)', Digital_Release__c = prod.Digital_Release__c, RecordTypeId=TVEpisodeRecTypeId);
        //adding instance to insertable list
        insertableDataSet.get('Product__c').add(tvEpisodeProd);  
        
        DGF_TriggerUtility.producTriggerExecuted = true;
    }   
    
    /***********************************
Method Name: createTVEpisodePricing
Purpose:Method to create TV Episode pricing
***********************************/    
    public static void createTVEpisodePricing(Product__c prd) {
        if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c').containsKey(prd.id)) {
            Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prd.id);
            list<Pricing_Tier__c>pricingTierList=new list<Pricing_Tier__c>();
            
            if (insertableDataSet.containsKey('Product__c')) {
                insertableDataSet.remove('Product__c');
            }
            //get the corresponding pricing tiers
            if (fetchDataSet.containsKey('Pricing_Tier__c') && fetchDataSet.get('Pricing_Tier__c')!=NULL) {
                pricingTierList=(List<Pricing_Tier__c> )fetchDataSet.get('Pricing_Tier__c').values();
            }
            //create a new pricing record
            if (!insertableDataSet.containsKey('Pricing__c')) {
                insertableDataSet.put('Pricing__c', new List<SObject>());
            }
            
            Pricing__c priceUSHD = new Pricing__c(Product__c = prod.id, Category__c = DGF_Constants.TV_EPISODE, Platform__c = DGF_Constants.PLATFORM_EST, Price_Type__c = 'Original', Territory__c = 'US', Resolution__c = 'HD');
            Pricing__c priceUSSD = new Pricing__c(Product__c = prod.id, Category__c = DGF_Constants.TV_EPISODE, Platform__c = DGF_Constants.PLATFORM_EST, Price_Type__c = 'Original', Territory__c = 'US', Resolution__c = 'SD');
            Pricing__c priceCAHD = null;
            Pricing__c priceCASD = null;
            
            priceCAHD = new Pricing__c(Product__c = prod.id, Category__c = DGF_Constants.TV_EPISODE, Platform__c = DGF_Constants.PLATFORM_EST, Price_Type__c = 'Original', Territory__c = 'CA', Resolution__c = 'HD');
            priceCASD = new Pricing__c(Product__c = prod.id, Category__c = DGF_Constants.TV_EPISODE, Platform__c = DGF_Constants.PLATFORM_EST, Price_Type__c = 'Original', Territory__c = 'CA', Resolution__c = 'SD');
            
            if (!pricingTierList.isEmpty()) {
                for (Pricing_Tier__c pt : pricingTierList) {
                    
                    if (pt.Territory__c == 'US' && pt.Resolution__c == 'HD' &&  pt.Product_Type__c == DGF_Constants.TV && pt.Category__c == DGF_Constants.TV_EPISODE) {
                        priceUSHD.SRP__c = pt.SRP__c;
                        priceUSHD.WSP__c = pt.WSP__c;
                    }
                    if (pt.Territory__c == 'US' && pt.Resolution__c == 'SD'  &&  pt.Product_Type__c == DGF_Constants.TV && pt.Category__c == DGF_Constants.TV_EPISODE) {
                        priceUSSD.SRP__c = pt.SRP__c;
                        priceUSSD.WSP__c = pt.WSP__c;
                    }
                    if (pt.Territory__c == 'CA' && pt.Resolution__c == 'HD'  &&  pt.Product_Type__c == DGF_Constants.TV && pt.Category__c == DGF_Constants.TV_EPISODE) {
                        priceCAHD.SRP__c = pt.SRP__c;
                        priceCAHD.WSP__c = pt.WSP__c;
                    }
                    if (pt.Territory__c == 'CA' && pt.Resolution__c == 'SD'  &&  pt.Product_Type__c == DGF_Constants.TV && pt.Category__c == DGF_Constants.TV_EPISODE) {
                        priceCASD.SRP__c = pt.SRP__c;
                        priceCASD.WSP__c = pt.WSP__c;
                    }
                }
            }
            insertableDataSet.get('Pricing__c').add(priceUSHD);  
            insertableDataSet.get('Pricing__c').add(priceUSSD); 
            if (priceCAHD != null) {
                insertableDataSet.get('Pricing__c').add(priceCAHD); 
            }
            if (priceCASD != null) {
                insertableDataSet.get('Pricing__c').add(priceCASD); 
            }
        }
    }
    
    /***********************************
Method Name: createPricingrecords
Purpose: for creating pricing records
***********************************/   
    public static List<Pricing__c> createPricingrecords(List<Product__c> prdList,Boolean isRelease) {
        //Variable declaration
        List<Pricing__c> pricingList = new List<Pricing__c>();
        List<Pricing__c> PricingListToInsert = new List<Pricing__c>();      
        String resolution;
        
        //looping over product list
        for (Product__c prd : prdList) {
            
            //if none of the resolution is checked then return
            if (prd.HD__c == false && prd.SD__c == false && prd.UHD__c == false && prd.X3D__c == false) {
                continue;
            }                
            
            //if none of the offering is populated then return 
            if (prd.US_Platform_Offering__c == null && prd.CA_Platform_Offering__c == null) {
                continue;
            }
            
            if (!setProductPriceCreationID.contains(prd.id) && Trigger.isUpdate && !isRelease) {
                continue;
            }
            
            //if resolution is HD
            if (prd.HD__c == true) {
                resolution = 'HD';
                pricingList = DGF_DefaultProductPricing.defaultProductPricing(prd, resolution);
                
                if (pricingList != null && !pricingList.isEmpty()) {
                    PricingListToInsert.addall(pricingList);
                }
            }
            
            //if resolution is SD
            if (prd.SD__c == true) {
                resolution = 'SD';
                pricingList = DGF_DefaultProductPricing.defaultProductPricing(prd, resolution);
                
                if (pricingList != null && !pricingList.isEmpty()) {
                    PricingListToInsert.addall(pricingList);
                }
            }
            
            //if reolution is UHD
            if (prd.UHD__c == true) {
                resolution = 'UHD';
                pricingList = DGF_DefaultProductPricing.defaultProductPricing(prd, resolution);
                
                if (pricingList != null && !pricingList.isEmpty()) {
                    PricingListToInsert.addall(pricingList);
                }
            }
            
            //if resolution is 3D
            if (prd.X3D__c == true) {
                resolution = '3D';
                pricingList = DGF_DefaultProductPricing.defaultProductPricing(prd, resolution);
                
                if (pricingList != null && !pricingList.isEmpty()) {
                    PricingListToInsert.addall(pricingList);
                }
            }
            
        }
        
        //if size of list to insert is greater than 0
        if (PricingListToInsert.size()>0) {
            Map<String,Pricing_Tier__c> pTierMap = new Map<String,Pricing_Tier__c>();
            //fetching data set for processing when called from DigitalTriggerHandler
            if (DGF_TriggerUtility.isCalledFromDigitalTriggerHandler) {
                getDataSet();
            }
            
            if (fetchDataSet.containsKey('Pricing_Tier__c') && fetchDataSet.get('Pricing_Tier__c')!=NULL) {
                for (pricing_Tier__c pTier : (List<Pricing_Tier__c> )fetchDataSet.get('Pricing_Tier__c').values()) {
                    if (pTier.Product_Type__c == DGF_Constants.FILM && pTier.Territory__c != null && pTier.Resolution__c != null && pTier.Platform__c != null && pTier.Category__c != null) {
                        pTierMap.put(pTier.Territory__c+':'+pTier.Resolution__c+':'+pTier.Platform__c+':'+pTier.Category__c,pTier);
                    }
                }
            }
            
            //looping over records to insert
            for (Pricing__c prc : PricingListToInsert) {
                //setting pricing value
                if (pTierMap.containsKey(prc.Territory__c+':'+prc.Resolution__c+':'+prc.Platform__c+':'+prc.Category__c)) {
                    prc.WSP__c = pTierMap.get(prc.Territory__c+':'+prc.Resolution__c+':'+prc.Platform__c+':'+prc.Category__c).WSP__c;
                    prc.SRP__c = pTierMap.get(prc.Territory__c+':'+prc.Resolution__c+':'+prc.Platform__c+':'+prc.Category__c).SRP__c;
                }
            }
        }
        return PricingListToInsert;
        
    }
    
    /***********************************
Method Name: createAndUpdatePricingRecords
Purpose: for creating and updating repricing records
***********************************/    
    public static void createAndUpdatePricingRecords(Product__c prod, string territory) {
        Pricing__c prcRecord;
        List<Pricing__c> pricingESTLstOfCurrType = new List<Pricing__c>();   
        list<Pricing_Tier__c> pricingTierList=new list<Pricing_Tier__c>();
        Map<String,Pricing_Tier__c> pTierMap = new Map<String,Pricing_Tier__c>();
        if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(prod.id)) {
            return;
        }
        if (fetchDataSet.containsKey('Pricing_Tier__c') && fetchDataSet.get('Pricing_Tier__c')!=NULL) {
            
            pricingTierList = (List<Pricing_Tier__c> )fetchDataSet.get('Pricing_Tier__c').values();
            for (pricing_Tier__c pTier : pricingTierList) {
                if (pTier.Platform__c == DGF_Constants.PLATFORM_EST && pTier.Product_Type__c == DGF_Constants.FILM && pTier.Territory__c != null && pTier.Resolution__c != null && pTier.Category__c != null) {
                    pTierMap.put(pTier.Territory__c+':'+pTier.Resolution__c+':'+pTier.Category__c,pTier);
                }
            }
        }
        Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(prod.id); 
        
        if (prd.Digital_Release__r.RecordTypeId == FilmRecTypeIdOfRelease) { 
            
            //identifying currently active pricing records for the product
            //for (Pricing__c prc : prd.Pricing__r) { //DFOR-1434
            if(fetchProductPricingDataSet.containsKey(prd.id) &&  fetchProductPricingDataSet.get(prd.id).size()>0){
                for (Pricing__c prc : fetchProductPricingDataSet.get(prd.id)){                
                    if ((prc.Valid_From__c < System.today() &&  (prc.Valid_To__c == null || prc.Valid_To__c > System.today())) &&  
                        prc.Territory__c == territory && prc.Platform__c == DGF_Constants.PLATFORM_EST && 
                        (prc.Price_Type__c == DGF_Constants.ORIGINAL || prc.Price_Type__c == DGF_Constants.REPRICE)) {
                            
                            pricingESTLstOfCurrType.add(prc);
                        }
                }
                
            }
            
            
            //for applicable pricing records
            if (pricingESTLstOfCurrType.size()>0) {
                
                for (Pricing__c prc : pricingESTLstOfCurrType) {
                    if (prc.iTunes_Tier__c == null && prc.Account__c == null) {
                        prcRecord =  new Pricing__c(Valid_From__c = DGF_TriggerUtility.priceEffectiveDate,
                                                    Price_Type__c = DGF_Constants.REPRICE, Name = DGF_Constants.TERRITORY_US, Product__c = prd.Id,
                                                    Platform__c = prc.Platform__c,
                                                    Territory__c = prc.Territory__c, Resolution__c = prc.Resolution__c, Account__c = prc.Account__c,
                                                    iTunes_Tier__c = prc.iTunes_Tier__c);
                        if (territory == DGF_Constants.TERRITORY_US) {
                            prcRecord.Category__c = prd.EST_Tier__c;
                        }
                        else if (territory == DGF_Constants.TERRITORY_CA) {
                            prcRecord.Category__c = prd.CA_EST_Tier__c;
                        }
                        if (pTierMap.containsKey(prc.Territory__c+':'+prc.Resolution__c+':'+prcRecord.Category__c)) {
                            //creating instance for repricing record
                            prcRecord.WSP__c = pTierMap.get(prc.Territory__c+':'+prc.Resolution__c+':'+ prcRecord.Category__c).WSP__c;
                            prcRecord.SRP__c =pTierMap.get(prc.Territory__c+':'+prc.Resolution__c+':'+prcRecord.Category__c).SRP__c;
                        }
                        //adding to insertable data set
                        if (prcRecord != null) {
                            if (insertableDataSet.containsKey('Pricing__c')) {
                                insertableDataSet.get('Pricing__c').add(prcRecord);
                            }
                            else {
                                insertableDataSet.put('Pricing__c',new List<sObject>());
                                insertableDataSet.get('Pricing__c').add(prcRecord);
                            } 
                        }
                    }
                }                
            } 
        }
    }
    
    // Sending flag if products are there
    public static Boolean getFlagForProducts(list<Product__c> proList)
    {
        
        Id devRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        List<Product__c> prList = [select id from Product__c where Digital_Release__c=:proList[0].Digital_Release__c and Bundle_ID__c = null and  recordtypeid=:devRecordTypeId  and Digital_Release__r.Bundle_SYSGEN__c !=null];
        //List<Product__c> prList = [select id from product__c  where Short_Name__c != '' and Bundle_ID__c == '' ];
        System.debug('product List'+prList);
        if(prList.size()>0)
        {
            flag=true;
        }
        return flag;
    }
    
    public static String CallGTNServiceForNewProducts(list<Product__c> newProList)
    {
        string message='';
        list<String> idList=new List<string>();
        for(Product__c pp:newProList){
            idList.add(pp.id);
        }
        system.debug(' **id '+idList);
        list<Product_Version__c> prVesion=[select id,Product__r.Short_Name__c from Product_Version__c where Product__r.Digital_Release__c =:newProList[0].Digital_Release__c and Product__r.Digital_Release__r.Bundle_SYSGEN__c!=null and TM_Version__r.TVD_SAFE_Production_ID__c!='' and Product__r.Digital_Release__r.Send_to_GTM__c=true and Product__c in:idList];      
        System.debug('prVesion.size()'+prVesion.size());
        if(prVesion.size()>=2 && prVesion[0].Product__r.Short_Name__c!=null)
        {
            System.debug('In side the product trigger');
            SendJsonString.ExistingDigitalReleaseWithNewProduct(newProList[0].Digital_Release__c, idList);         
        }
        else
            message='Product does not have short name or Product having less than two Product Versions.!';
        return message;  
    }
    public static void UpdateFieldsProducts(list<Product__c> newProList, list<Product__c> oldProList)
    {
        Boolean pdName=false;
        Boolean shtName=false;
        Boolean bndlSynopsis=false;
        //String bundlSysgen='';
        string dgId='';
        List<string> pdIds=new List<String>();
        
        for(Product__c pd: newProList)
        {
            for(Product__c pd1: oldProList)
            {
                pdIds.add(pd.id);
                dgId=pd.Digital_Release__c;
                //bundlSysgen=pd.Digital_Release__r.Bundle_SYSGEN__c;
                if(pd.name!=pd1.name)
                    pdname=true;
                
                if(pd.Short_Name__c!=pd1.Short_Name__c)
                    shtName=true;
                
                if(pd.Bundle_Synopsis__c!=pd1.Bundle_Synopsis__c)
                    bndlSynopsis=true;
            }
        }
        SendJsonString.ProductUpdateonExistingDigitalRelease(pdIds,dgId,pdname,shtName,bndlSynopsis);
    }
    
    /*private static boolean run = true;
public static boolean runOnce(){
if(run){
run=false;
return true;
}else{
return run;
}

}*/
}