/***********************************************************************************
Class Name: DGF_ProductVersionTriggerHandler
Purpose: Handler class for Product Version trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Jata                    Initial Development
******************************************************************************************/
public with Sharing class DGF_ProductVersionTriggerHandler {
    
    /*****private declaration*****/
    private static Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
    private static Set<ID> setReleaseID = new Set<ID>();
    private static set<ID> setProductAlreadyProcessed = new Set<ID>();
    private static Product_Version__c  pvOld;
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> deleteableDataSet = new Map<String, List<SObject>>();     
    private static Set<ID> setProductID = new Set<ID>();
    private static Set<ID> setTitleID = new Set<ID>();
    private static Map<Id,Set<Id>> productVersionMap =  new Map<Id,Set<Id>>();
    private static Map<Id,Set<Id>> VersionProductMap =  new Map<Id,Set<Id>>();
    private static Map<Id,List<Pricing__c>> prodWithFilmOrTvMap =  new Map<Id,List<Pricing__c>>();
    private static Id BundleRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id PreOrderRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static map<Id,Product__c>preOrderMap = new map<Id,Product__c>();
     private static Set<ID> setProdVersionId = new Set<ID>();
    
    /***********************************
    Method Name: resetDataSet
    Purpose: method to reset context data variable
    ***********************************/
    private static void resetDataSet(){ 
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear();
        setReleaseID.clear();
        setProductID.clear();
        setTitleID.clear();
        productVersionMap.clear();
        VersionProductMap.clear();
        prodWithFilmOrTvMap.clear();
        preOrderMap.clear();
    }
    
    /***********************************
    Method Name: getDataSet
    Purpose: method for executing SOQL
    ***********************************/
    @testVisible private static void getDataSet(){
        if(!setProdVersionId.isEmpty()) {
            if (!fetchDataSet.containsKey('Product_Version__c')) {
                fetchDataSet.put('Product_Version__c', new Map<ID,sObject>());
            }
            for(Product_Version__c pv : [SELECT ID, Product__c, Product__r.Digital_Release__c, Product__r.RecordTypeId from Product_Version__c where id in:setProdVersionId]) {
                 fetchDataSet.get('Product_Version__c').put(pv.ID, pv);
            }
        }
        //getting list of products based on release
        if (!setReleaseID.isEmpty()) {
            if (!fetchDataSet.containsKey('Product__c')) {
                fetchDataSet.put('Product__c', new Map<ID,sObject>());
            }
            for (Product__c prod : [Select Id, RecordTypeId, Digital_Release__c, Digital_Release__r.RecordTypeId, (Select product__c, TM_Version__r.Original_Flag__c , Product__r.RecordTypeId,  product_title__c, Product_Release__c from Product_Versions__r) from Product__c where Digital_Release__c in : setReleaseID]) {
                fetchDataSet.get('Product__c').put(prod.ID, prod);  
            }
            
            System.debug('1...'+setReleaseId);
            
            for(Product__c prod : [Select ID, Digital_Release__c, Version_Availability__c, RecordTypeId, (Select Id, Account__c, Version__c, Account__r.Pre_Order_Best_Version__c FROM Product_Account__r where Account__r.Pre_Order_Best_Version__c = true) FROM Product__c where RecordTypeId=:PreOrderRecTypeId And Digital_Release__c IN:setReleaseID]) {
                preOrderMap.put(prod.Digital_Release__c,prod);
            }
            
        }
        
        //getting list of products based on product ID
        if (!setProductID.isEmpty()) {
            if (!fetchDataSet.containsKey('Product1__c')) {
                fetchDataSet.put('Product1__c', new Map<ID,sObject>());
            }
            for (Product__c prod : [Select Id, OwnerID, RecordTypeID, Digital_Release__c, Digital_Release__r.RecordType.Name, RecordType.Name, 
                                    Digital_Release__r.CA_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Pre_Purchase_Date__c,
                                    Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.US_Bundle_Pre_Purchase_Date__c,
                                    (Select Id, TM_Version__c, Lead_Title__c, Product__c, Product__r.recordTypeId from Product_Versions__r ) 
                                    from Product__c where ID in : setProductID]) {
                                        fetchDataSet.get('Product1__c').put(prod.ID, prod);
                                        for (Product_Version__c pVer : prod.Product_Versions__r) {
                                            if (pVer.Product__r.recordTypeId == BundleRecTypeIdPrd) {
                                                if (!productVersionMap.containsKey(prod.Id)) {
                                                    productVersionMap.put(prod.Id, new Set<Id>());
                                                    productVersionMap.get(prod.Id).add(pVer.TM_Version__c);
                                                }
                                                else {
                                                    productVersionMap.get(prod.Id).add(pVer.TM_Version__c);
                                                }
                                                
                                            }
                                        }
                                    }
            
            if (!productVersionMap.isEmpty()) {
                Set<Id> versionIds = new Set<Id>();
                Set<ID> productIds = new Set<Id>();
                for (Id prodId : productVersionMap.keyset()) {
                    versionIds.addAll(productVersionMap.get(prodId)); 
                }
                for (Product_Version__c pv : [SELECT ID, TM_Version__c, Product__c, Product__r.RecordTypeId 
                                              FROM Product_Version__c where TM_Version__c in : versionIds 
                                              And Product__r.RecordTypeId !=: BundleRecTypeId]) {
                                                  if (!VersionProductMap.containsKey(pv.TM_Version__c)) {
                                                      VersionProductMap.put(pv.TM_Version__c, new Set<Id>());
                                                      VersionProductMap.get(pv.TM_Version__c).add(pv.Product__c);
                                                  }
                                                  else {
                                                      VersionProductMap.get(pv.TM_Version__c).add(pv.Product__c);
                                                  }
                                              }
                for (Id versionId : VersionProductMap.keyset()) {
                    productIds.addAll(VersionProductMap.get(versionId)); 
                }
                
                for(Product__c prdct : [SELECT Id,Name, (Select Id, Account__c, Price_Type__c, Valid_From__c, Territory__c, Product__r.Name from Pricing__r 
                                                        where Price_Type__c =: 'Reprice' And Account__c !=: 'iTunes') from Product__c where Id in : productIds]) {
                                                            if(prdct.Pricing__r != null) {
                                                                if(prodWithFilmOrTvMap.containsKey(prdct.Id)) {
                                                                    prodWithFilmOrTvMap.put(prdct.Id, new List<Pricing__c>());
                                                                    prodWithFilmOrTvMap.put(prdct.Id, prdct.Pricing__r);
                                                                }
                                                                else {
                                                                    prodWithFilmOrTvMap.put(prdct.Id, prdct.Pricing__r);         
                                                                }
                                                                
                                                            }
                                                        }
                
            }
        }
        
        //getting title details 
        if (!setTitleID.isEmpty()) {
            if (!fetchDataSet.containsKey('Title__c')) {
                fetchDataSet.put('Title__c', new Map<ID,sObject>());
            }
            for (Title__c ttl : [Select id, name, Genre_Primary__c, Primary_GTM_Genre__c, (Select id, name, US_EST_Date__c, CA_EST_Date__c, US_EPO_Date__c, CA_EPO_Date__c, Theatrical_Genre__c from Digital_Releases__r where RecordType.Name =: DGF_Constants.FILM  order by createddate desc limit 1) from Title__c where ID in : setTitleID]) {
                fetchDataSet.get('Title__c').put(ttl.ID, ttl);  
            }
        }
    }
    
    /***********************************
    Method Name: commitDataSet
    Purpose: Method for performing DML operations
    ***********************************/
    @testVisible private static void commitDataSet() {
        
        //for inserting records
        if (!insertableDataSet.isEmpty()) {
            //looping over collection
            for(String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                List<SObject> dataSet = insertableDataSet.get(sobjectApi);
                
                //inserting records
                if (!dataSet.isEmpty()) {
                    //insert dataSet;
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
                    update dataSet.values();
                }
            }
        }
        
       //for deleting records
        if (!deleteableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : deleteableDataSet.keySet()) {
                
                //getting list to delete
                List<SObject> dataSet = deleteableDataSet.get(sobjectApi);
                
                //deleting records
                if (!dataSet.isEmpty()) {
                    delete dataSet;
                }
            }
        }
    }
    
    /***********************************
    Method Name: executeOnAfterInsert
    Purpose:Should execute only for after insert event
    ***********************************/    
    public static void executeOnAfterInsert() {
        
        //first iteration over trigger.new to create collections
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            if(!setProdVersionId.contains(pv.id)) {
                setProdVersionId.add(pv.id);
            }
            //create a set of release ID
            if (!setReleaseID.contains(pv.Product_Release__c) && pv.Product_Release__c != null) {
                setReleaseID.add(pv.Product_Release__c);
            } 
            //create a set of product ID
            if (!setProductID.contains(pv.Product__c)) {
                setProductID.add(pv.Product__c);
            }
        }
        
        //fetching data set for processing
        getDataSet();
        
        DGF_TriggerUtility.runOnce = TRUE;
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            
            //method to update unique number of titles on release
            updateNumberOfTitles(pv);
            
            //method to post Chatter notification for STORY DFOR-392  
            if (DGF_TriggerUtility.runOnce ) {
                 postChatterNotification(pv);
                DGF_TriggerUtility.runOnce = FALSE;
            }         
            if(fetchDataSet.containsKey('Product_Version__c')) {
                sobject obj = fetchDataSet.get('Product_Version__c').get(pv.id) ;
                pv = (Product_Version__c)obj;
            }
            //for Film Recordtype
            if(pv.Product__r.RecordTypeId == FilmRecTypeId) {
                //check if preorder product exists
                if(preOrderMap.containsKey(pv.Product__r.Digital_Release__c)) {
                    Product__c preOrderProd = preOrderMap.get(pv.Product__r.Digital_Release__c);
                    if(fetchDataSet.containsKey('Product__c')) {
                        for(sobject obj : fetchDataSet.get('Product__c').values()) {
                            Product__c prod = (Product__c)obj;
                            if(prod.recordTypeId == FilmRecTypeId && prod.id == pv.Product__c) {
                                //iterate over related Product Version
                                for(Product_Version__c prodVer : prod.Product_Versions__r) {
                                    if(prodVer.id == pv.id) {
                                        //if Original Flag is checked then set the Version Availabality as Theatrical
                                        if(prodVer.TM_Version__r.Original_Flag__c) {
                                            if(preOrderProd.Version_Availability__c == null || preOrderProd.Version_Availability__c == '') {
                                                preOrderProd.Version_Availability__c = 'Theatrical';
                                            }
                                            else if(!preOrderProd.Version_Availability__c.contains('Theatrical')){
                                                preOrderProd.Version_Availability__c += ';Theatrical';
                                            }
                                             if (!updateableDataSet.containsKey('Product__c')) {
                                                updateableDataSet.put('Product__c',new map<Id,sObject>());
                                            }
                                            
                                            //adding details to updateableDataSet 
                                            updateableDataSet.get('Product__c').put(preOrderProd.id,preOrderProd);  
                                            
                                            
                                                
                                    }
                                    //else set the Version as Alternate
                                    else {
                                        if(preOrderProd.Version_Availability__c == null || preOrderProd.Version_Availability__c == '') {
                                            preOrderProd.Version_Availability__c = 'Alternate';
                                        }
                                        else if(!preOrderProd.Version_Availability__c.contains('Alternate')){
                                            preOrderProd.Version_Availability__c += ';Alternate';
                                            for(Product_Account__c pa : preOrderProd.Product_Account__r) {
                                            
                                            if(pa.account__r.Pre_Order_Best_Version__c ) {
                                                //set version on Product Account
                                                pa.Version__c = 'Alternate';
                                                if (!updateableDataSet.containsKey('Product_Account__c')) {
                                        updateableDataSet.put('Product_Account__c',new map<Id,sObject>());
                                    }
                                    
                                    //adding details to updateableDataSet 
                                    updateableDataSet.get('Product_Account__c').put(pa.id,pa);  
                                            }
                                        }
                                         
                                    if (!updateableDataSet.containsKey('Product__c')) {
                                        updateableDataSet.put('Product__c',new map<Id,sObject>());
                                    }
                                    
                                    //adding details to updateableDataSet 
                                    updateableDataSet.get('Product__c').put(preOrderProd.id,preOrderProd);  
                                    }
                                }
                        }
                    }
                }
            }
        } 
            }  
        }
        }
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();
    }
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose:Should execute only for before update
    ***********************************/    
    public static void executeOnBeforeUpdate() {
        ///first iteration over trigger.new to create collections
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            //getting old instance
            pvOld = (Product_Version__c)Trigger.oldMap.get(pv.Id);
            
            //creating a set of product IDs
            if(!setProductID.contains(pv.Product__c)){
                setProductID.add(pv.Product__c);                
            }
        }
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration for actual processing
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            //getting old instance
            pvOld = (Product_Version__c)Trigger.oldMap.get(pv.Id);
            
            //validate lead title only if user has set it to true
            if (pv.Lead_Title__c == TRUE && pv.Lead_Title__c != pvOld.Lead_Title__c) {
                integer count = validateLeadTitle(pv);
                
                //throw error if there is more than 1 lead title for a product
                if (count > 1) {
                    pv.addError('There can only be one lead title for a product. Please remove existing lead title before adding a new one.');
                }
            }           
        }       
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();  
    }   
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {
        
        ///first iteration over trigger.new to create collections
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            pvOld = (Product_Version__c)Trigger.oldMap.get(pv.Id);
            //create a set of release ID
            if (!setReleaseID.contains(pv.Product_Release__c) && pv.Product_Release__c != pvOld.Product_Release__c || pvOld.Product_Title__c != pv.Product_Title__c) {
                setReleaseID.add(pv.Product_Release__c);
                setReleaseID.add(pvOld.Product_Release__c);
            }   

            //creating a set of product IDs
            if (!setProductID.contains(pv.Product__c)) {
                setProductID.add(pv.Product__c);                
            }           

            //creating a set of title ID
            if (!setTitleID.contains(pv.Product_Title__c)) {
                setTitleID.add(pv.Product_Title__c);
            }
        }
        
        //fetching data set for processing
        getDataSet();  
        
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.new) {
            
            //old instance of product version 
            pvOld = (Product_Version__c)Trigger.oldMap.get(pv.Id);
            
            if (pvOld.Product__c != pv.Product__c || pvOld.TM_Version__c != pv.TM_Version__c) {
                //method to update unique number of titles on release
                updateNumberOfTitles(pv);
                updateNumberOfTitles(pvOld);
            } 
            
            //updating fields on release if lead title is changed
            if (pv.Lead_Title__c == TRUE && pv.Lead_Title__c != pvOld.Lead_Title__c && ((Product__c)fetchDataSet.get('Product1__c').get(pv.Product__c)).Digital_Release__r.RecordType.Name == DGF_Constants.Bundle) {
                updateBundleDatesOnRelease(pv);
            }
        }  
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
    Method Name: executeOnAfterDelete
    Purpose:Should execute only for after delete event
    ***********************************/    
    public static void executeOnAfterDelete() {
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.old) {            
            //create a set of release ID
            if (!setReleaseID.contains(pv.Product_Release__c) && pv.Product_Release__c != null) {
                setReleaseID.add(pv.Product_Release__c);
            }               
        }      
        
        //fetching data set for processing
        getDataSet();       
        
        for (Product_Version__c pv : (List<Product_Version__c>)trigger.old) {
            //method to update unique number of titles on release
            updateNumberOfTitles(pv);
        }   
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();
    }
    
    /***********************************
    Method Name: updateNumberOfTitles
    Purpose: for updating number of titles on release
    ***********************************/   
    private static void updateNumberOfTitles(Product_Version__c pv) {
        //return control if key not present or product already processed
        if (!fetchDataSet.containsKey('Product__c') || !fetchDataSet.get('Product__c').containsKey(pv.Product__c) || setProductAlreadyProcessed.contains(pv.Product__c)) {
            return; 
        }
            
        //create instance of digital release and set of title ID
        Digital_Release__c updtDg;
        Set<ID> setTitleID = new Set<ID>();
        
        //creating an instance of digital release if not already present
        if (!updateableDataSet.containsKey('Digital_Release__c')) {
            updateableDataSet.put('Digital_Release__c', new Map<Id, SObject>());
        }
                
        //looping over all product versions
        for (Product_Version__c pv1 : ((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Product_Versions__r) {
            if (!setTitleID.contains(pv1.Product_Title__c) && pv1.Product_Title__c != null) {
                setTitleID.add(pv1.Product_Title__c);
            }   
            
            //if product already processed then adding it to a set
            setProductAlreadyProcessed.add(pv.Product__c);
        } 
        
        //if key not present then create a new instance                 
        if (!updateableDataSet.get('Digital_Release__c').containsKey(((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__c)) {
            updtDg = new Digital_Release__c();
            updtDg.of_Titles_in_Bundle__c = setTitleID.size();
            updtDg.ID = ((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__c;
        }
        //else add to existing
        else {
            updtDg = (Digital_Release__c) updateableDataSet.get('Digital_Release__c').get(((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__c);
            updtDg.of_Titles_in_Bundle__c = updtDg.of_Titles_in_Bundle__c + setTitleID.size();
            updtDg.ID = ((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__c;
        }
        
        //adding instance to the set
        if (((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__r.RecordTypeId == BundleRecTypeId) {
            updateableDataSet.get('Digital_Release__c').put(((Product__c)fetchDataSet.get('Product__c').get(pv.Product__c)).Digital_Release__c,updtDg);
        }   
    }
    
    /***********************************
    Method Name: postChatterNotification
    Purpose: for posting chatter on bundle Products
    ***********************************/   
    private static void postChatterNotification(Product_Version__c pv) {
        if (productVersionMap.containsKey(pv.Product__c)) {
            for (ID bundleProd : productVersionMap.keySet()) {
                Map<Id,String> prodWithNameMap = new Map<Id,String>();
                Boolean hasReprice = false;
                //storing product details in instance
                Product__c prod = (Product__c)fetchDataSet.get('Product1__c').get(bundleProd);
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                mentionSegmentInput.id = DGF_TriggerUtility.chatterGroup.Id;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                //preparing post message
                textSegmentInput.text = '\n\nThe following individual titles will be repriced between now and the Bundle Avail Date:\n\n';
                messageBodyInput.messageSegments.add(textSegmentInput);
                for (Id versnId : productVersionMap.get(bundleProd)) {
                    if (VersionProductMap.containsKey(versnId)) {
                        for (ID prodId : VersionProductMap.get(versnId)) {
                            if (prodWithFilmOrTvMap.containsKey(prodId)) {
                                for (Pricing__c prc : prodWithFilmOrTvMap.get(prodId)) {
                                    //for US pricing checking Valid from between today and Bundle Avail Date/Bundle Pre-Purchase Date
                                    if (prc.territory__c == 'US' && prc.Valid_from__c != null && 
                                        (prod.Digital_Release__r.US_Bundle_Avail_Date__c!= null || prod.Digital_Release__r.US_Bundle_Pre_Purchase_Date__c != null)) {
                                            if (prc.Valid_from__c >= System.today() && 
                                                (prc.Valid_From__c <= prod.Digital_Release__r.US_Bundle_Avail_Date__c 
                                                 || prc.Valid_From__c <= prod.Digital_Release__r.US_Bundle_Pre_Purchase_Date__c)) {
                                                     
                                                     prodWithNameMap.put(prodId, prc.Product__r.Name);
                                                 }
                                        }
                                    //for CA pricing checking Valid from between today and Bundle Avail Date/Bundle Pre-Purchase Date
                                    else if(prc.territory__c == 'CA' && prc.Valid_from__c != null && 
                                            (prod.Digital_Release__r.CA_Bundle_Avail_Date__c!= null || prod.Digital_Release__r.CA_Bundle_Pre_Purchase_Date__c != null)) {
                                                if (prc.Valid_from__c >= System.today() && 
                                                    (prc.Valid_From__c <= prod.Digital_Release__r.CA_Bundle_Avail_Date__c 
                                                     || prc.Valid_From__c <= prod.Digital_Release__r.CA_Bundle_Pre_Purchase_Date__c)) {
                                                         
                                                         prodWithNameMap.put(prodId, prc.Product__r.Name);
                                                     }
                                            }
                                }
                                
                                if(prodWithNameMap.containsKey(prodId)) {
                                    hasReprice = true;
                                    textSegmentInput = new ConnectApi.TextSegmentInput();
                                    textSegmentInput.text = prodWithNameMap.get(prodId)+'\n';
                                    messageBodyInput.messageSegments.add(textSegmentInput);
                                }
                                
                            }
                        }
                    }
                }
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = bundleProd;
                if (hasReprice) {
                     //posting feed element in bundle product records
                     ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
                }
            }
        }
    }
    
    /***********************************
    Method Name: validateLeadTitle
    Purpose: method to validate there is only one lead title on product
    ***********************************/   
    private static integer validateLeadTitle(Product_Version__c pv) {
        
        //checking if fetch data set contains product details
        if (!fetchDataSet.containsKey('Product1__c') || !fetchDataSet.get('Product1__c').containsKey(pv.Product__c)) {
            return 0;
        }
        
        //storing product instance 
        Product__c prodDetails = (Product__c)fetchDataSet.get('Product1__c').get(pv.Product__c);
        
        //setting default to 1 for product version record in context
        Integer count = 1;
        
        //looping over product versions
        for (Product_Version__c prdVer : prodDetails.Product_Versions__r) {
            //increasing count for record not in context if lead title is TURE
            if (prdVer.Lead_Title__c == TRUE && pv.ID != prdVer.ID) {
                count = count + 1;
            }
        }
        
        //returning total count
        return count;       
    }    
    
    /***********************************
    Method Name: updateBundleDatesOnRelease
    Purpose: method to update bundle dates on release if lead title is changed
    ***********************************/   
    private static void updateBundleDatesOnRelease(Product_Version__c pv) {
        //checking if fetch data set contains product details
        if (!fetchDataSet.containsKey('Title__c') || !fetchDataSet.get('Title__c').containsKey(pv.Product_Title__c)) {
            return ;
        }
        
        ID digitalRelID = ((Product__c)fetchDataSet.get('Product1__c').get(pv.Product__c)).Digital_Release__c;
        
        //storing title details 
        Title__c ttl = (Title__c)fetchDataSet.get('Title__c').get(pv.Product_Title__c);
        
        //adding instance of digital release if not present 
        if (!updateableDataSet.containsKey('Digital_Release__c')) {
           updateableDataSet.put('Digital_Release__c', new Map<Id, SObject>());  
        }
        
        //new instance of digital release
        Digital_Release__c dgRel = new Digital_Release__c();                       

        //checking if digital release instance already present
        if (!updateableDataSet.get('Digital_Release__c').containsKey(digitalRelID)) {
            dgRel.ID = digitalRelID;
        }
        else {
            dgRel = (Digital_Release__c) updateableDataSet.get('Digital_Release__c').get(digitalRelID);
        }   
        
        //looping over FILM release to set remaining Bundle fields on Release
        for (Digital_Release__c dg : ttl.Digital_Releases__r) {
            dgRel.Bundle_Genre__c = dg.Theatrical_Genre__c;
            dgRel.US_Bundle_Avail_Date__c = dg.US_EST_Date__c ;
            dgRel.CA_Bundle_Avail_Date__c =  dg.CA_EST_Date__c ;
            dgRel.CA_Bundle_Pre_Purchase_Date__c =  dg.CA_EPO_Date__c ;
            dgRel.US_Bundle_Pre_Purchase_Date__c =  dg.US_EPO_Date__c ;         
        }

        //adding records to updateable data set
        updateableDataSet.get('Digital_Release__c').put(digitalRelID, dgRel);       
    }
    
}