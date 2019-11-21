/***********************************************************************************
Class Name: DGF_PricingTriggerHandler
Purpose: Handler class for Prcing trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             18/05/2017           Jata                Initial Development
2.0             18/01/2018           Vaibhav B           DFOR-1333 Sub Query returning more than 200 records hence spliting query into 2
******************************************************************************************/
public without sharing class DGF_PricingTriggerHandler {
    
    /*****private declaration*****/
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> deleteableDataSet = new Map<String, List<SObject>>(); 
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static set<Id>pricingIdSet = new set<Id>();
    private static set<Id>productIdSet = new set<Id>();
    private static Pricing__c  prdOld;
    private static Map<Id, Pricing__c> updateExistingPricing = new Map<Id, Pricing__c>();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id BundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
    private static Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
    private static Map<Id,Boolean> prodVersionMap = new map<Id,Boolean>();
    private static list<Pricing__c>caPriceList = new list<Pricing__c>();
    private static set <Id> promoSet = new set<Id> ();
    private static map <String,Promotion_Product__c>promoProdMap = new map <String, Promotion_Product__c>();
    private static Pricing__c prOld; 
    private static Map<Id,Id> productVersionMap =  new Map<Id,Id>();
    private static Map<Id,List<String>> prodWithBundleMap = new Map<Id,List<String>>();
    private static set<id> setPromotionId = new set<ID>();
    private static map<Id, set<string>> mapPromotionProd = new Map<Id, set<string>>();
    
    /***********************************
    Method Name: resetDataSet
    Purpose: method to reset context data variable
    ***********************************/
    private static void resetDataSet() {    
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear(); 
        pricingIdSet.clear();
        productIdSet.clear();
        prodVersionMap.clear();
        caPriceList.clear();
        setPromotionId.clear();
        mapPromotionProd.clear();
        prodWithBundleMap.clear();
    }
    
    /***********************************
    Method Name: getDataSet
    Purpose: method for executing SOQL
    ***********************************/
    @testVisible private static void getDataSet() {
        
        //query pricing detials
        if (!pricingIdSet.isEmpty()) {
            //if instance not present 
            if (!fetchDataSet.containsKey('Pricing__c')) {
                fetchDataSet.put('Pricing__c', new Map<ID,sObject>());
            }
            
            //looping over pricing records
            for (Pricing__c pricing : [Select Name, Account__c, Category__c, Margin__c, iTunes_Tier__c, Platform__c,
                                       Price_Type__c, Product__c, Resolution__c, SRP__c, Territory__c,
                                       Valid_From__c, Valid_To__c, WSP__c, Promotion__c,
                                       Product__r.Digital_Release__r.CA_Physical_Street_Date__c,
                                       Product__r.Digital_Release__r.US_Physical_Street_Date__c,
                                       Product__r.Digital_Release__r.CA_iTunes_Price_Date__c,
                                       Product__r.Digital_Release__r.US_iTunes_Price_Date__c,
                                       Product__r.Digital_Release__r.US_EST_Date__c,
                                       Product__r.Digital_Release__r.CA_Bundle_Avail_Date__c,
                                       Product__r.Digital_Release__r.US_Bundle_Avail_Date__c,
                                       Product__r.Digital_Release__r.Initial_Launch_Categorization__c,                                       
                                       Product__r.RecordTypeId,                                       
                                       product__r.SD__c,
                                       product__r.HD__c,
                                       product__r.HDR__c,
                                       product__r.UHD__c,
                                       Product__r.Digital_Release__r.CA_EST_Date__c, product__r.digital_release__r.ca_est_launch_date__c FROM Pricing__c where Id in : pricingIdSet]) {
                                           fetchDataSet.get('Pricing__c').put(pricing.ID, pricing);  
                                       } 
        }
        
        //getting product details with pricing information
        if (!productIdSet.isEmpty()) {
            Map<String,String> titleMap = new Map<String,String>();
            Map<String,Boolean> rightsMap = new Map<String,Boolean>();
            Set<String> titleSet = new Set<String>();
            //if product instance not present
            if (!fetchDataSet.containsKey('Product__c')) {
                fetchDataSet.put('Product__c', new Map<ID,sObject>());
            }
            //looping over product details
            //Ch DFOR - 1333 Start
            for(Product__c prod : [Select Id, Name, RecordTypeId, 
                                   (SELECT ID, Product__c, promotion__c, TPR__c, TPR_Start_Date__c, TPR_End_Date__c, Promotion__r.OwnerId FROM Product_Promotions__r) from Product__c where ID in : productIdSet]) {
                                       fetchDataSet.get('Product__c').put(prod.ID, prod);                                        
                                   }
            Map<Id,Pricing__c> productPricingMap = new Map<Id,Pricing__c> ([Select Name, CreatedById, Account__c, Category__c, Margin__c, iTunes_Tier__c, Platform__c,
                                                                   Price_Type__c, Product__c, Resolution__c, SRP__c, Territory__c,
                                                                   Valid_From__c, Valid_To__c, WSP__c, Product__r.Name, Promotion__c, Promotion__r.Start_Date__c, Promotion__r.End_Date__c,
                                                                   Product__r.Digital_Release__r.CA_Physical_Street_Date__c,
                                                                   Product__r.Digital_Release__r.US_Physical_Street_Date__c,
                                                                   Product__r.Digital_Release__r.CA_iTunes_Price_Date__c,
                                                                   Product__r.Digital_Release__r.US_iTunes_Price_Date__c,
                                                                   Product__r.Digital_Release__r.US_EST_Date__c,
                                                                   Product__r.RecordTypeId,
                                                                   Product__r.Digital_Release__r.CA_EST_Date__c, product__r.digital_release__r.us_est_launch_date__c,Id FROM Pricing__c
                                                                   where Product__c in : fetchDataSet.get('Product__c').keySet() Order by Valid_From__c]);
            
            fetchDataSet.put('ProductPricing',productPricingMap);
            for (Product_Version__c pv : [SELECT ID, TM_Version__c, TM_Version__r.Title__c, Product__c FROM Product_Version__c where Product__c in : productIdSet]) {
                titleMap.put(pv.Product__c,pv.TM_Version__r.Title__c);
                productVersionMap.put(pv.Product__c,pv.TM_Version__c);
            }
            //Ch DFOR - 1333 End
            if (!productVersionMap.isEmpty()) {
                for (Product_Version__c pv : [SELECT ID, TM_Version__c, Product__c, Product__r.Name, Product__r.RecordTypeId 
                                              FROM Product_Version__c where TM_Version__c in : productVersionMap.values() 
                                              And Product__r.RecordTypeId =: BundleRecTypeId]) {
                                                      if (!prodWithBundleMap.containsKey(pv.TM_Version__c)) {
                                                          prodWithBundleMap.put(pv.TM_Version__c, new List<String>());
                                                          prodWithBundleMap.get(pv.TM_Version__c).add(pv.Product__r.Name);
                                                      }
                                                      else {
                                                          prodWithBundleMap.get(pv.TM_Version__c).add(pv.Product__r.Name);
                                                      }                                                  
                                              }
            }
            if (!promoSet.isEmpty() && !productIdSet.isEmpty()) {
                for(Promotion_Product__c prmPrd : [SELECT ID, Product__c, promotion__c, TPR_Start_Date__c, TPR_End_Date__c, Promotion__r.OwnerId FROM Promotion_Product__c where Product__c in : productIdSet and Promotion__c in : promoSet]) {
                    promoProdMap.put(prmPrd.Promotion__c+':'+prmPrd.Product__c, prmPrd);
                }
            }
            for (String titleId:titleMap.values()) {
                titleSet.add(titleId);
            }
            
            List<Title__c> lstOfTitles = [select id, name, Network_of_Air_Date__c, Pilot_Flag__c, (Select id, name, TVD_SAFE_Production_ID__c, Version_EIDR__c, Original_Flag__c from TM_Versions__r where TVD_SAFE_Production_ID__c != null), (Select id, name, Platform__c, Territory__c, Rights__c from Rights__r) from Title__c where ID in : titleSet];
            
            if (!lstOfTitles.isEmpty()) {
                //looping over title details
                for (Title__c title : lstOfTitles) {
                    //looping over related rights
                    for (Right__c rght : title.Rights__r) {
                        if (rght.Territory__c == 'CA') {                       
                            if (rght.Platform__c == 'EST' && rght.Rights__c == TRUE) { 
                                rightsMap.put(title.id, true);
                            }   
                            else if (rght.Platform__c == 'EST' && rght.Rights__c == FALSE) {
                                rightsMap.put(title.id, false);
                            }
                        }                        
                    }
                }
                for (String key : titleMap.keySet()) {
                    String title = titleMap.get(key);
                    if (rightsMap.containsKey(title)) {
                        prodVersionMap.put(key, rightsMap.get(title));
                    }
                }
            }
        }
        
        //getting iTunes pricing tier records
        if (!fetchDataSet.containsKey('Pricing_Tier__c')) {
            fetchDataSet.put('Pricing_Tier__c', new Map<ID,sObject>());
        }
        for (Pricing_Tier__c pt : [SELECT ID, Product_Type__c, iTunes_Tier__c, Customer_Specific__c, Category__c, WSP__c, SRP__c, Territory__c, Resolution__c, Platform__c from Pricing_Tier__c WHERE Customer_Specific__c =: 'iTunes']) {
            fetchDataSet.get('Pricing_Tier__c').put(pt.ID, pt);
        }       
        
        //if set not empty
        if (!setPromotionId.isEmpty()) {
            //adding promotion as key
            if (!fetchDataSet.containsKey('Promotion__c')) {
                fetchDataSet.put('Promotion__c',new Map<ID,sObject>());
            }
            
            //looping over promotion records
            for (Promotion__c promotion : [Select id, name, start_date__c, end_date__c, RecordTypeId, (Select id, name, start_date__c, end_date__c, RecordTypeId from Promotions__r) 
                                           from Promotion__c where Id IN : setPromotionId]) {
                                               fetchDataSet.get('Promotion__c').put(promotion.ID, promotion);  
                                           }
        }
    }
    
    /***********************************
    Method Name: commitDataSet
    Purpose: Method for performing DML operations
    ***********************************/
    @testVisible private static void commitDataSet()
    {
        //for inserting records
        if (!insertableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                List<SObject> dataSet = new List<SObject>();
                
                
                for (SObject sObj : insertableDataSet.get(sobjectApi)) {
                    if (sObj.id ==  null) {
                        dataSet.add(sObj);
                    }                    
                }
                
                //inserting records
                if (!dataSet.isEmpty()) {
                    insert dataSet;
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
    Method Name: executeOnBeforeInsert
    Purpose:Should execute only for before insert event
    ***********************************/    
    public static void executeOnBeforeInsert() {
        //first iteration over trigger.new to create collections
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            //Validation for Valid From and Valid To Dates
            System.debug('current pricing record>>>' + pr.Valid_From__c);
            if (pr.Valid_From__c != null && pr.Valid_To__c != null && Pr.Valid_To__c < pr.Valid_From__c && !DGF_TriggerUtility.isBulkReprice) {
                pr.addError(DGF_Constants.DGF_Valid_To_should_be_after_Valid_From_Date_For_Pricing_Record + ' : '+ pr.Name);
            }
            //adding product ID to a set
            if (!productIdSet.contains(pr.Product__c)) {
                productIdSet.add(pr.Product__c);
            } 
            
            if (!promoSet.contains(pr.Promotion__c)) {
                promoSet.add(pr.Promotion__c);
            }
        } 
        
        //fetching data set for processing
        getDataSet(); 
        
        //second iteration over Trigger.New for actual iteration
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            
            checkUniqueness(pr);
            //DFOR-160
            if (pr.price_type__c == 'TPR National' || pr.price_type__c == 'TPR Account' && pr.Account__c == null && pr.SRP__c != null) {
                System.debug('before insert...'+pr);
                if (!DGF_TriggerUtility.dontDefaultTPRPrices) {
                    defaultTPRPricing(pr);
                }
            }
            if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c').containsKey(pr.Product__c)) {
                Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(pr.Product__c);
                //Default WSP/SRP for TV Products
                if (pr.Product__c == prd.Id && prd.RecordTypeId == TVRecTypeId && (pr.Price_Type__c != 'TPR National' && pr.Price_Type__c != 'TPR Account')) {
                    if (pr.SRP__c != null && pr.WSP__c == null) {
                        pr.WSP__c = (pr.SRP__c * DGF_Constants.DEFAULT_WSP_SRP).setScale(2);
                    }
                    else if(pr.SRP__c == null && pr.WSP__c != null) {
                        pr.SRP__c = (pr.WSP__c / DGF_Constants.DEFAULT_WSP_SRP).setScale(2);
                    }
                }
            }
        }
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
    Method Name: defaultTPRPricing
    Purpose:Method to default TPR Prices
    ***********************************/    
    private static void defaultTPRPricing(Pricing__c pr) {
        if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c').containsKey(pr.Product__c)) {
            Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(pr.Product__c);
            List<Pricing__c> productPricingList = getProductPricingList(prd.Id);
            if (prd.id == pr.product__c && (prd.RecordTypeId == TVRecTypeId || prd.recordTypeId == FilmRecTypeId || prd.recordTypeId == BundleRecTypeId)) {
                for (Pricing__c price: productPricingList) {
                    if ((price.price_type__c == 'Original' || price.Price_type__c == 'Reprice') && price.Account__c == null && price.territory__c == pr.territory__c && price.platform__c == pr.platform__c && price.resolution__c == pr.resolution__c ) {
                        if (promoProdMap.containsKey(pr.Promotion__c+':'+pr.Product__c)) {
                            if (promoProdMap.get(pr.Promotion__c+':'+pr.Product__c).tpr_start_date__c !=null && promoProdMap.get(pr.Promotion__c+':'+pr.Product__c).tpr_end_date__c !=null) {
                                if (price.valid_from__c < promoProdMap.get(pr.Promotion__c+':'+pr.Product__c).tpr_end_date__c && (price.valid_to__c >= promoProdMap.get(pr.Promotion__c+':'+pr.Product__c).tpr_end_date__c || price.valid_to__c ==null)) {
                                    if (pr.SRP__c !=null) {
                                        pr.wsp__c = (pr.srp__c * (1 - (price.margin__c/100))).setScale(2);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose:Should execute only for before update event
    ***********************************/    
    public static void executeOnBeforeUpdate() {
        //first iteration over trigger.new to create collections
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            prOld = (Pricing__c) Trigger.OldMap.get(pr.Id);
            //Validation for Valid From and Valid To Dates
            if (pr.Valid_From__c != null && pr.Valid_To__c != null && Pr.Valid_To__c < pr.Valid_From__c && !DGF_TriggerUtility.isBulkReprice) {
                pr.addError(DGF_Constants.DGF_Valid_To_should_be_after_Valid_From_Date_For_Pricing_Record + ' : '+ pr.Name);
            }
            //adding product ID to a set
            if (!productIdSet.contains(pr.Product__c)) {
                productIdSet.add(pr.Product__c);
            }
            //adding pricing ID to a set
            if (!pricingIdSet.contains(pr.Id)) {
                pricingIdSet.add(pr.Id);
            }
            if (!promoSet.contains(pr.Promotion__c)) {
                promoSet.add(pr.Promotion__c);
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            prOld = (Pricing__c) Trigger.OldMap.get(pr.Id);
            //System.debug('before update outside if....'+pr);
            //System.debug('before update outside if old....'+prOld);
            if ((pr.price_type__c == 'TPR National' || pr.price_type__c == 'TPR Account') && pr.Account__c == null && pr.SRP__c != prOld.srp__c) {
                System.debug('before update inside if....'+pr);
                if (!DGF_TriggerUtility.dontDefaultTPRPrices) {
                    defaultTPRPricing(pr);
                }
            }
            if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c').containsKey(pr.Product__c)) {
                Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(pr.Product__c);
                //Default WSP/SRP for TV Products
                if (pr.Product__c == prd.Id && prd.RecordTypeId == TVRecTypeId && (pr.Price_Type__c != 'TPR National' && pr.Price_Type__c != 'TPR Account')) 
                {
                    if (pr.SRP__c != null && pr.WSP__c == null) {
                        pr.WSP__c = (pr.SRP__c * DGF_Constants.DEFAULT_WSP_SRP).setScale(2);
                    }
                    else if (pr.SRP__c == null && pr.WSP__c != null) {
                        pr.SRP__c = (pr.WSP__c / DGF_Constants.DEFAULT_WSP_SRP).setScale(2); 
                    }
                }
            }
            
            prdOld = (Pricing__c)Trigger.oldMap.get(pr.Id);
            if (prdOld.Valid_From__c != pr.Valid_From__c && pr.Valid_From__c == null) {
                pr.addError(DGF_Constants.DGF_Enter_Valid_From_Date);
            }
            if (prdOld.Resolution__c != pr.Resolution__c || prdOld.Territory__c != pr.Territory__c || prdOld.Platform__c != pr.Platform__c ||
                prdOld.Account__c != pr.Account__c || prdOld.Price_Type__c != pr.Price_Type__c || prdOld.Valid_From__c != pr.Valid_From__c ||
                prdOld.Valid_To__c != pr.Valid_To__c) {
                    checkUniqueness(pr); 
                }
            
            if (prdOld.SRP__c != pr.SRP__c && pr.Account__c == DGF_Constants.iTUNES) {
                Pricing__c prc = (Pricing__c)fetchDataSet.get('Pricing__c').get(pr.id);
                if (prc.Product__r.RecordTypeId != FilmRecTypeId) {
                    continue;
                }
                Integer days1;
                Integer days2;
                Integer days3;
                //Calculate Windows by no. of months
                if (prc.Territory__c == DGF_Constants.TERRITORY_US) {
                    if (prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && prc.Valid_From__c != null) {
                        days1 = prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(prc.Valid_From__c);
                        days2 = prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                        days3 = prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(prc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                    }
                }
                else if (prc.Territory__c==DGF_Constants.TERRITORY_CA) {
                    if (prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && prc.Valid_From__c != null) {
                        days1 = prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(prc.Valid_From__c);
                        days2 = prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                        days3 = prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(prc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                    }
                }
                
                CalculateWSPandiTunesTier(pr, days1, days2, days3);
            }
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
    Method Name: executeOnAfterInsert
    Purpose:Should execute only for after insert event
    ***********************************/    
    public static void executeOnAfterInsert() {
        //first iteration over trigger.new to create collections
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            if (pr.Platform__c == DGF_Constants.PLATFORM_EST ) {
                //adding pricing ID to a set
                if (!pricingIdSet.contains(pr.Id)) {
                    pricingIdSet.add(pr.Id);
                }
            }
            
            //adding product ID to a set
            if (!productIdSet.contains(pr.Product__c)) {
                productIdSet.add(pr.Product__c);
            }
                        
            //creating a set of promotion id
            if (pr.Promotion__c != null && !setPromotionId.contains(pr.Promotion__c)) {
                setPromotionId.add(pr.Promotion__c);
            }
        }   
        
        //fetching data set for processing
        getDataSet();
        
        Map<Id,List<Pricing__c>> repriceNotificationMap = new Map<Id,List<Pricing__c>>();
        List<Pricing__c> iTunesprcListToInsert = new List<Pricing__c>();
        
        //second iteration over Trigger.New for actual iteration
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            //Post Notification when non-itunes reprice record is getting created
            if (pr.Price_Type__c == DGF_Constants.REPRICE && pr.Account__c != DGF_Constants.iTUNES) {
                //reprice notification for film products
                if (!repriceNotificationMap.containsKey(pr.Product__c)) {
                    repriceNotificationMap.put(pr.Product__c, new List<Pricing__c>());
                    repriceNotificationMap.get(pr.Product__c).add(pr); 
                }
                else {
                    repriceNotificationMap.get(pr.Product__c).add(pr);
                }
            }
            
            //creating iTunes record 
            if((pr.Platform__c == DGF_Constants.PLATFORM_EST && pr.iTunes_Tier__c == null && pr.Account__c != DGF_Constants.iTUNES) && 
               ((pr.Price_Type__c == DGF_Constants.ORIGINAL || pr.Price_Type__c == DGF_Constants.REPRICE) 
                || (pr.SRP__c != null && (pr.Price_Type__c == DGF_Constants.TPR_National || pr.Price_Type__c == DGF_Constants.TPR_Account)))) {
                    
                    List<Pricing__c> tempiTunesprcListToInsert = new List<Pricing__c>();
                    tempiTunesprcListToInsert = createItunesPricing(pr);
                    
                    if (tempiTunesprcListToInsert != null) {
                        iTunesprcListToInsert.addall(tempiTunesprcListToInsert);
                    }
                    
                }
                if((pr.Platform__c == DGF_Constants.PLATFORM_EST && pr.iTunes_Tier__c == null && pr.Account__c != DGF_Constants.iTUNES)  
               		//&& (pr.Price_Type__c == DGF_Constants.ORIGINAL)
               		){
                	Pricing__c prc = (Pricing__c)fetchDataSet.get('Pricing__c').get(pr.id);
                	if(prc.product__r.recordTypeId == BundleRecTypeId){
                		System.debug('Attempted iTunes Price Rec Creation??');
                		
                		 List<Pricing__c> tempiTunesprcListToInsert = new List<Pricing__c>();
                    	tempiTunesprcListToInsert = createItunesPricingForBundles(pr);
                    	
                		if (tempiTunesprcListToInsert != null) {
                        	iTunesprcListToInsert.addall(tempiTunesprcListToInsert);
                    	}
                	}
                }
            UpdateValidToDate(pr);  
            if (fetchDataSet.containsKey('Pricing__c') && fetchDataSet.get('Pricing__c').containsKey(pr.id)) {
                Pricing__c prc = (Pricing__c)fetchDataSet.get('Pricing__c').get(pr.id);
              
                if (prc.product__r.recordTypeId == TVRecTypeId && prc.territory__c == 'US' && prc.platform__c == 'EST' && 
                    (prc.price_type__c == DGF_Constants.ORIGINAL || prc.price_type__c == DGF_Constants.REPRICE)
                    && prc.Product__r.Digital_Release__r.CA_EST_Launch_Date__c!=null) {
                        //if (prodVersionMap.containsKey(prc.product__c) && prodVersionMap.get(prc.product__c)) {                        	
                            defaultCAtvPricing(prc);
                        //}
                    }
            }   

            //for chatter notification DFOR-423
            if (pr.Promotion__c != null && pr.Price_Type__c == DGF_Constants.TPR_National && pr.Account__c == null) {
                createPromotionProductMapping(pr);
            }           
        }
        
         //for chatter notification on pricing change
        chatterPostOnChildPromotion();
        
        //inserting feed items
        if (insertableDataSet.containsKey('FeedItem')) {
            insert insertableDataSet.get('FeedItem');
        }
        
        if (!repriceNotificationMap.isEmpty()) {
            postNotification(repriceNotificationMap);
            postNotificationOnProductChatterGroup(repriceNotificationMap);
        }
        
        if (!iTunesprcListToInsert.isEmpty()) {
            try {
                insert iTunesprcListToInsert;
            }
            catch (DMLException de) {
                Trigger.New[0].addError(de.getDMLMessage(0));
            }
            catch (Exception ex) {
                Trigger.New[0].addError(ex.getMessage());
            }
        }
        
        if (!updateExistingPricing.isEmpty()) {
            DGF_TriggerUtility.executePricingTrigger = FALSE;  
            update updateExistingPricing.values();
            DGF_TriggerUtility.executePricingTrigger = TRUE;
            updateExistingPricing.clear();      
        }
        
        if (!caPriceList.isEmpty()) {
            DGF_TriggerUtility.sobjectExecutedEvents.clear();
            DGF_TriggerUtility.isTVPricing=FALSE;
            try {
                insert caPriceList;
            }
            catch (DMLException de) {
                Trigger.New[0].addError(de.getDMLMessage(0));
            }
            catch (Exception ex) {
                Trigger.New[0].addError(ex.getMessage());
            }
            DGF_TriggerUtility.isTVPricing = TRUE;
        }       
        
        //clear data set
        resetDataSet();  
    }
    
    /***********************************
    Method Name: postNotification
    Purpose:Should execute only when reprice record has been inserted
    ***********************************/ 
    public static void postNotification(Map<Id,List<Pricing__c>> repriceNotificationMap) {
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment;
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        List<Promotion__share> sharePromotionProductList = new List<Promotion__share>();
        Set<Id> promotionIdSet = new Set<Id>();
        for (Id prdId : repriceNotificationMap.keySet()) {
            Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prdId);
            for (Promotion_Product__c promPrd : prod.Product_Promotions__r) {
                if(promPrd.Promotion__r.ownerId !=userInfo.getUserId() && !promotionIdSet.contains(promPrd.Promotion__c)) {
                    Promotion__share shareRec = new Promotion__share();
                    shareRec.AccessLevel = 'Read';
                    shareRec.userOrGroupId = userInfo.getUserId();
                    shareRec.parentId = promPrd.Promotion__c;
                    sharePromotionProductList.add(shareRec);
                    promotionIdSet.add(promPrd.Promotion__c);
                }
            }
        }        
        insert sharePromotionProductList;
        for (Id prdId : repriceNotificationMap.keySet()) {
            //storing product details in instance
            Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prdId);
            List<Pricing__c> prcngList = repriceNotificationMap.get(prdId);
            //looping over all promotions related to product
            for (Promotion_Product__c promPrd : prod.Product_Promotions__r) {
                Boolean hasReprice = false;
                mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                feedItemInput = new ConnectApi.FeedItemInput();
                textSegmentInput = new ConnectApi.TextSegmentInput();
                messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                //tagging promotion owner in the post
                mentionSegmentInput.id = promPrd.Promotion__r.OwnerId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupBeginSegment);
                 //preparing post message
                textSegmentInput.text = '\n\nThe following products will be repriced during this Promotion:\n\n';
                messageBodyInput.messageSegments.add(textSegmentInput);
                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupEndSegment);
                
                markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupBeginSegment);
                markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
                messageBodyInput.messageSegments.add(markupBeginSegment);
                
                textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = prod.Name;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
                messageBodyInput.messageSegments.add(markupEndSegment);
                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupEndSegment);
                //looping over all pricing related to Product
                for (Pricing__c prcng : prcngList) {
                    System.debug('tprStart--'+promPrd.TPR_Start_Date__c+'tprend--'+promPrd.TPR_End_Date__c+'pricingProd'+prcng.Product__c+'promProd=='+promPrd.Product__c+'promprodId'+promPrd.Id);
                    if(prcng.Valid_From__c != null && promPrd.TPR_Start_Date__c != null && 
                       promPrd.TPR_End_Date__c != null && prcng.Product__c == promPrd.Product__c && promPrd.TPR__c) {
                        //if valid from is between tpr start date and tpr end date
                        if (prcng.Valid_From__c >= promPrd.TPR_Start_Date__c && prcng.Valid_From__c < promPrd.TPR_End_Date__c ) {
                            String wspToSRP;
                            hasReprice = true;
                            
                            if (prcng.WSP__c == null && prcng.SRP__c != null) {
                                wspToSRP = '$N/A'+'/$'+prcng.SRP__c;
                            }
                            else if (prcng.WSP__c != null && prcng.SRP__c == null) {
                                wspToSRP = '$'+prcng.WSP__c+'/$N/A';
                            }
                            else if(prcng.WSP__c == null && prcng.SRP__c == null) {
                                wspToSRP = '$N/A'+'/$N/A';
                            }
                            else if (prcng.WSP__c != null && prcng.SRP__c != null){
                                wspToSRP = '$'+prcng.WSP__c+'/$'+prcng.SRP__c;
                            }
                            
                            textSegmentInput = new ConnectApi.TextSegmentInput();
                            markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                            markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                            messageBodyInput.messageSegments.add(markupBeginSegment);
                            //preparing post message
                            textSegmentInput.text = '\n\n'+prcng.Territory__c+' '+prcng.Platform__c+' '+
                                prcng.Resolution__c+' '+wspToSRP;
                            messageBodyInput.messageSegments.add(textSegmentInput);
                            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                            markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                            messageBodyInput.messageSegments.add(markupEndSegment);
                        } 
                    }
                }
                //adding promotion id for chatter post
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = promPrd.Promotion__c;
                if (hasReprice) {
                    //posting feed element in promotion records                    
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput); 
                }
            }
        }
        delete sharePromotionProductList;
    }
    
    /***********************************
    Method Name: postNotificationOnProductChatterGroup
    Purpose:Should execute only when reprice record has been inserted
    ***********************************/ 
    public static void postNotificationOnProductChatterGroup(Map<Id,List<Pricing__c>> repriceNotificationMap) {
        if (!prodWithBundleMap.isEmpty() && !productVersionMap.isEmpty()) {
            String message;
            String messageToPost;
            for (Id prdId : productVersionMap.keyset()) {
                
                if(repriceNotificationMap.containsKey(prdId)) {
                    message = '';
                    messageToPost =  null;
                    Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prdId);
                    for(Id versn : prodWithBundleMap.keySet()) {
                        if(productVersionMap.get(prdId) == versn && (prod.RecordTypeId == TVRecTypeId ||prod.RecordTypeId == FilmRecTypeId )) {
                           for(String str : prodWithBundleMap.get(versn)) {                             
                                  message = message + str+'\n';
                            }
                            messageToPost =  prod.Name+' '+'is being repriced. The following Bundles are affected:\n\n'+message;
                            ConnectApi.FeedElement feedElement = 
                                ConnectApi.ChatterFeeds.postFeedElement(null,DGF_TriggerUtility.chatterGroup.ID, ConnectApi.FeedElementType.FeedItem, messageToPost);
                            
                        }
                    }
                }
            }
        }
    }
    
    public static void defaultCAtvPricing(Pricing__c newPrc) {
    	
    	boolean originalPricingExists = false;
    	//check if product instance present
        if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(newPrc.Product__c)) {
            return;
        }
        
        //storing product details in instance
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(newPrc.Product__c);
        Pricing__c updtPrice;
        DGF_TriggerUtility.checkPricingUniqueness = FALSE;
        
        List<Pricing__c> pricingList = getProductPricingList(prod.Id);
        
        if (prod != null && newPrc.price_type__c == 'Reprice') {
            for (Pricing__c exstingPrc : pricingList) {                
                if (newPrc.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
                    continue;
                }
                //(newPrc.Price_Type__c == DGF_Constants.ORIGINAL || newPrc.Price_Type__c == DGF_Constants.REPRICE)
                if ((exstingPrc.Price_Type__c == DGF_Constants.ORIGINAL) && newPrc.Account__c == exstingPrc.Account__c && 
                                       newPrc.Territory__c == exstingPrc.Territory__c && newPrc.Platform__c == exstingPrc.Platform__c && 
                                       newPrc.Resolution__c == exstingPrc.Resolution__c) {
                                       	originalPricingExists = true;
                }
            } 
        }    
        
        Pricing__c caPrice = new Pricing__c(Account__c = newPrc.Account__c, Category__c = newPrc.Category__c, 
                                            iTunes_Tier__c = newPrc.iTunes_Tier__c, Platform__c = newPrc.Platform__c, 
                                             Product__c = newPrc.Product__c, 
                                            Promotion__c = newPrc.Promotion__c, Resolution__c = newPrc.Resolution__c, 
                                            SRP__c = newPrc.SRP__c, Territory__c = 'CA', WSP__c = newPrc.WSP__c);
        if (newPrc.price_type__c == 'Reprice' ) {
        	if(originalPricingExists){
        		caPrice.valid_from__c=newPrc.valid_from__c;
            	caPrice.Price_Type__c = newPrc.Price_Type__c;
        	}else{
        		caPrice.valid_from__c= newPrc.product__r.digital_release__r.ca_est_launch_date__c;
            	caPrice.Price_Type__c = DGF_Constants.ORIGINAL;
        	}            
        }
        else if (newPrc.price_type__c == 'Original' && newPrc.product__r.digital_release__r.ca_est_launch_date__c != null){
            caPrice.valid_from__c = newPrc.product__r.digital_release__r.ca_est_launch_date__c;
            caPrice.Price_Type__c = newPrc.Price_Type__c;
        }
        createFeedItem('CA Pricing has been created to reflect current US Pricing',caPrice.Product__c);
        caPriceList.add(caPrice);
    }
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {
        
        //first iteration over trigger.new to create collections
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {         
            
            //adding product ID to a set
            if (!productIdSet.contains(pr.Product__c)) {
                productIdSet.add(pr.Product__c);
            }
            
            //adding pricing ID to a set
            if (!pricingIdSet.contains(pr.Id)) {
                pricingIdSet.add(pr.Id);
            }
            
            //creating a set of promotion id
            if (pr.Promotion__c != null && !setPromotionId.contains(pr.Promotion__c)) {
                setPromotionId.add(pr.Promotion__c);
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        List<Pricing__c> iTunesTPRprcListToInsert = new List<Pricing__c>();
        
        //second iteration over Trigger.New for actual iteration        
        for (Pricing__c pr : (List<Pricing__c>)trigger.new) {
            UpdateValidToDate(pr); 
            prdOld = (Pricing__c)Trigger.oldMap.get(pr.Id);
            //if SRP is updated from null, create iTunes TPR Pricing
            if (prdOld.SRP__c == null && prdOld.SRP__c != pr.SRP__c && pr.Platform__c == DGF_Constants.PLATFORM_EST && 
                (pr.Price_Type__c == DGF_Constants.TPR_National || pr.Price_Type__c == DGF_Constants.TPR_Account)) {
                    
                    if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(pr.Product__c)) {
                        continue;
                    }
                    
                    Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(pr.Product__c);
                    //Ch DFOR - 1333 start
                    List<Pricing__c> pricingList = getProductPricingList(prod.Id);
                    //Ch DFOR - 1333 End
                    Map<Id,Pricing__c>iTunesTPRPrcMap = new Map<Id,Pricing__c>();
                    if (prod.RecordTypeId == FilmRecTypeId) {
                        //looping over iTunes pricing for TPR type to find existing iTunes records
                        if (prod != null ) {
                            for (Pricing__c exstingTPRiTunesPrc : pricingList) {     //Ch DFOR - 1333           
                                
                                if (pr.Id == exstingTPRiTunesPrc.Id && DGF_triggerUtility.isTestRunning) {
                                    continue;
                                }
                                if (pr.Product__c == exstingTPRiTunesPrc.Product__c) {
                                    if (exstingTPRiTunesPrc.Platform__c == pr.Platform__c && exstingTPRiTunesPrc.Resolution__c == pr.Resolution__c && 
                                        exstingTPRiTunesPrc.Territory__c == pr.Territory__c && exstingTPRiTunesPrc.Account__c == DGF_Constants.iTUNES && 
                                        exstingTPRiTunesPrc.Price_Type__c == pr.Price_Type__c && exstingTPRiTunesPrc.Promotion__c == pr.Promotion__c) {
                                            iTunesTPRPrcMap.put(exstingTPRiTunesPrc.Id, exstingTPRiTunesPrc);
                                        }
                                }
                            }
                        }
                        
                        if (iTunesTPRPrcMap.isEmpty()) {
                            List<Pricing__c> tempTPRiTunesprcListToInsert = new List<Pricing__c>();
                            tempTPRiTunesprcListToInsert = createItunesPricing(pr);
                            if (tempTPRiTunesprcListToInsert != null) {
                                iTunesTPRprcListToInsert.addall(tempTPRiTunesprcListToInsert);
                            }
                        }
                    }
                }else if(
                ((pr.SRP__c != null && prdOld.SRP__c != pr.SRP__c) || (pr.wsp__c != null && prdOld.wsp__c != pr.wsp__c)|| (prdOld.valid_from__c != pr.valid_from__c) ) && pr.Platform__c == DGF_Constants.PLATFORM_EST && 
                	(pr.Price_Type__c == DGF_Constants.ORIGINAL || pr.Price_Type__c == DGF_Constants.REPRICE) && pr.territory__c == DGF_Constants.TERRITORY_US){
                 	
                 	Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(pr.Product__c);
                 	if(prod.RecordTypeId == TVRecTypeId){
	                	if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(pr.Product__c)) {
	                        continue;
	                    }
                        Integer repriceCount = 0;
	                    boolean rePricingExists = false;
	                    List<Pricing__c> pricingList = getProductPricingList(prod.Id);
	        
				        if (prod != null && pr.price_type__c == 'Reprice') {
				            for (Pricing__c exstingPrc : pricingList) {                
				                if (pr.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
				                    continue;
				                }
                                if(exstingPrc.territory__c != DGF_Constants.TERRITORY_CA){
				                	continue;
				                }
				                //(newPrc.Price_Type__c == DGF_Constants.ORIGINAL || newPrc.Price_Type__c == DGF_Constants.REPRICE)
				                if ((exstingPrc.Price_Type__c == DGF_Constants.REPRICE) && pr.Account__c == pr.Account__c && 
				                        pr.Platform__c == exstingPrc.Platform__c && pr.Resolution__c == exstingPrc.Resolution__c && exstingPrc.territory__c == DGF_Constants.TERRITORY_CA) {
				                                       if(prdOld.valid_from__c == exstingPrc.valid_from__c){
				                                       		 rePricingExists = true;
				                                       		 if((prdOld.valid_from__c != pr.valid_from__c) && (prdOld.srp__c == pr.srp__c && prdOld.wsp__c == pr.wsp__c)){
				                                       		  	exstingPrc.valid_from__c = pr.valid_from__c;
				                                       		  		createFeedItem('CA Valid From and Valid To Dates have been updated',exstingPrc.Product__c);
				                                       		 }else if((prdOld.valid_from__c != pr.valid_from__c) && (prdOld.srp__c != pr.srp__c || prdOld.wsp__c != pr.wsp__c)){
				                                       		 	if(prdOld.valid_from__c != pr.valid_from__c){
				                                       		  	exstingPrc.valid_from__c = pr.valid_from__c;
					                                       		  	exstingPrc.srp__c = pr.srp__c;
					                                       		 	exstingPrc.wsp__c = pr.wsp__c;
				                                       		  		createFeedItem('<p>CA Pricing has been updated to reflect current US Pricing </p> CA Valid From and Valid To Dates have been updated',exstingPrc.Product__c);
				                                       		 	}
				                                       		 }else if(prdOld.srp__c != pr.srp__c || prdOld.wsp__c != pr.wsp__c){
				                                       		 	exstingPrc.srp__c = pr.srp__c;
				                                       		 	exstingPrc.wsp__c = pr.wsp__c;
				                                       		 	createFeedItem('CA Pricing has been updated to reflect current US Pricing',exstingPrc.Product__c);				                                       		 
				                                       		 }
						                                      
						                                 updateExistingPricing.put(exstingPrc.id, exstingPrc);
				                                       }/*else{
				                                       	rePricingExists = true;
				                                       }*/	
                                            repriceCount++;
				                }
				            } 
				            if(!rePricingExists && repriceCount<2 && ((pr.SRP__c != null && prdOld.SRP__c != pr.SRP__c) || (pr.wsp__c != null && prdOld.wsp__c != pr.wsp__c))){ //If not more than 2 reprice Attempt at Updating Original
				            	for (Pricing__c exstingPrc : pricingList) {                
					                if (pr.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
					                    continue;
					                }
					                if ((exstingPrc.Price_Type__c == DGF_Constants.ORIGINAL) && pr.Account__c == pr.Account__c && 
					                          pr.Platform__c == exstingPrc.Platform__c && pr.Resolution__c == exstingPrc.Resolution__c && exstingPrc.territory__c == DGF_Constants.TERRITORY_CA) {
					                                       		 exstingPrc.srp__c = pr.srp__c;
					                                       		 exstingPrc.wsp__c = pr.wsp__c;
							                                     //exstingPrc.valid_from__c = pr.valid_from__c; 
							                                      updateExistingPricing.put(exstingPrc.id, exstingPrc);
							                                      createFeedItem('CA Pricing has been updated to reflect current US Pricing',exstingPrc.Product__c);
					                                       		                                       	
					                }
				            	}
				            	
				            }
				        }else if(prod != null && pr.price_type__c == DGF_Constants.ORIGINAL && ((pr.SRP__c != null && prdOld.SRP__c != pr.SRP__c) || (pr.wsp__c != null && prdOld.wsp__c != pr.wsp__c))){				        	 
				        	for (Pricing__c exstingPrc : pricingList) {                
					                if (pr.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
					                    continue;
					                }
					                if ((exstingPrc.Price_Type__c == DGF_Constants.ORIGINAL) && pr.Account__c == pr.Account__c && 
					                	pr.Platform__c == exstingPrc.Platform__c && pr.Resolution__c == exstingPrc.Resolution__c && exstingPrc.territory__c == DGF_Constants.TERRITORY_CA) {
					                                       		 exstingPrc.srp__c = pr.srp__c;
					                                       		 exstingPrc.wsp__c = pr.wsp__c;							                                    							                                       
							                                      updateExistingPricing.put(exstingPrc.id, exstingPrc);
							                                      createFeedItem('CA Pricing has been updated to reflect current US Pricing',exstingPrc.Product__c);
					                                       		                                       	
					                }
				            }
				        } 
                 		
                 	}
                 
                }
            //update SRP of existing TPR iTunes
            if (prdOld.SRP__c != pr.SRP__c && (pr.Price_Type__c == DGF_Constants.TPR_National 
                                               || pr.Price_Type__c == DGF_Constants.TPR_Account)) {
                                                   updateSrpOfExistingTPRiTunes(pr);
                                               }            
                     
            //for chatter notification DFOR-423
            if (pr.Promotion__c != null && pr.Price_Type__c == DGF_Constants.TPR_National && pr.Account__c == null && (pr.WSP__c != prdOld.WSP__c || pr.SRP__c != prdOld.SRP__c)) {
                createPromotionProductMapping(pr);
            }
        }
        
        //insert TPR iTunes record
        if (!iTunesTPRprcListToInsert.isEmpty()) {
            try {
                DGF_TriggerUtility.executePricingTrigger = FALSE;
                insert iTunesTPRprcListToInsert;
                DGF_TriggerUtility.executePricingTrigger = TRUE;
            }
            catch (DMLException de) {
                Trigger.New[0].addError(de.getDMLMessage(0));
            }
            catch (Exception ex) {
                Trigger.New[0].addError(ex.getMessage());
            }
        } 
        if (!updateExistingPricing.isEmpty()) {
            DGF_TriggerUtility.executePricingTrigger = FALSE;
            update updateExistingPricing.values();
            DGF_TriggerUtility.executePricingTrigger = TRUE;
            updateExistingPricing.clear();      
        }
        
        //for chatter notification on pricing change
        chatterPostOnChildPromotion();
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    
    /***********************************
    Method Name: createItunesPricingForBundles
    Purpose:Create iTunes Pricing record from Pricing tier for Bundles
    ***********************************/ 
    
    private static List<Pricing__c> createItunesPricingForBundles(Pricing__c prcng) { 
    	pricing__c insertPriceRec = new pricing__c();
    	boolean isCAAvail = false;
    	boolean isUSAvail = false;
    	boolean isSD = false;
    	boolean isHD = false;
    	boolean isUHD = false;
    	boolean isHDR = false;
    	boolean isValidBundle = false;
    	decimal currentSRP = 0;
    	date bundleAvailDt;
    	Pricing_Tier__c prevTier = new Pricing_Tier__c();
        Pricing_Tier__c matchedTier = new Pricing_Tier__c();
        Pricing_Tier__c currTier = new Pricing_Tier__c();
        Pricing_Tier__c currRepriceTier = new Pricing_Tier__c();
        list<pricing__c> insertPricingList = new list<pricing__c>();
    	
    	
    	
    	if (!fetchDataSet.containskey('Pricing__c') || !fetchDataSet.get('Pricing__c').containsKey(prcng.id)) {
            return null;
        }
        
        //for cloning not creating itune pricing as it is already existing
        if (DGF_TriggerUtility.isCloningProcess) {
            return null;
        }
        //storing pricing details in instance
        Pricing__c pr = (Pricing__c)fetchDataSet.get('Pricing__c').get(prcng.id);
        if (pr.Product__r.RecordTypeId != BundleRecTypeId) {
            return null;
        }
        
        if(pr.Product__r.Digital_release__r.Initial_Launch_Categorization__c == null || 
        	((pr.territory__C == DGF_Constants.TERRITORY_US && pr.Product__r.Digital_release__r.US_Bundle_Avail_Date__c == null) ||
        	 (pr.territory__C == DGF_Constants.TERRITORY_CA && pr.Product__r.Digital_release__r.CA_Bundle_Avail_Date__c == null))){
        	return null;
        }else{
        	isValidBundle = true;
        }
         if (!fetchDataSet.containsKey('Bundle_Pricing_Tier__c')) {
         	fetchDataSet.put('Bundle_Pricing_Tier__c', new Map<ID,sObject>());
         	for (Pricing_Tier__c pt : [SELECT ID, Product_Type__c, iTunes_Tier__c, Customer_Specific__c, Category__c, WSP__c, SRP__c, Territory__c, Resolution__c, Platform__c, margin__c from Pricing_Tier__c WHERE Customer_Specific__c =: 'iTunes' and Product_Type__c = 'Bundle' 
	         order by territory__C  , iTunes_Tier__c asc]) {
	         	fetchDataSet.get('Bundle_Pricing_Tier__c').put(pt.ID, pt);
	         }
         }            
          
         system.debug('Fetching Map??' + fetchDataSet.get('Bundle_Pricing_Tier__c'));
         
         if(pr.territory__C == DGF_Constants.TERRITORY_US){
         	bundleAvailDt = pr.Product__r.Digital_release__r.US_Bundle_Avail_Date__c;
         }else{
         	bundleAvailDt = pr.Product__r.Digital_release__r.CA_Bundle_Avail_Date__c;
         }
         
         map<id, Pricing_Tier__c> pricingTierMap =  new map<id, Pricing_Tier__c>() ;
         
         //find matching srp tier
         
         if(fetchDataSet.get('Bundle_Pricing_Tier__c') !=null && fetchDataSet.get('Bundle_Pricing_Tier__c').size()>0){
         	Map<Id, SObject> bundleSObjMap = new Map<Id, SObject>();
         	bundleSObjMap = fetchDataSet.get('Bundle_Pricing_Tier__c');
         	System.debug('DEBUG LOGS??' + bundleSObjMap);
         	
         	for(SObject record: bundleSObjMap.values()){
         		Pricing_Tier__c ptier = (Pricing_Tier__c) record;
         		pricingTierMap.put(ptier.id, ptier);
         	}
         	//pricingTierMap= fetchDataSet.get('Bundle_Pricing_Tier__c'); 
         	for(Pricing_Tier__c pt : pricingTierMap.values()){
         		if(pt.Territory__c != pr.Territory__c || pt.resolution__c != pr.resolution__c || pt.margin__c != DGF_Constants.BUNDLE_iTune_WSP1) continue;
         		system.debug('pr>>' + pr);
         		system.debug('pt>>' + pt);
         		
         		if(pr.srp__c == pt.srp__c ){
         			matchedTier = pt;
         			currentSRP = pt.srp__c;
         			break;
         		}else if(pr.srp__c < pt.srp__c){
         			prevTier = new Pricing_Tier__c();
         			prevTier = pt;
         			break;
         		}
         	}
         }
         
         
         if(currentSRP ==0){
          		currTier = prevTier;
          }else{
          	currTier = matchedTier;
          }
         system.debug('matched tier' + matchedTier + 'currentSRP>>' + currentSRP);
         
         if((pr.Product__r.Digital_release__r.Initial_Launch_Categorization__c.equalsIgnoreCase('New Release')
         || (pr.Product__r.Digital_release__r.Initial_Launch_Categorization__c.equalsIgnoreCase('Catalog'))) &&
          pr.product__r.HDR__c && pr.price_type__c == DGF_Constants.ORIGINAL){//mos 1-3 and reprice
          	
          	System.debug('currTier' + currTier);
          	
          	 Pricing__c itunesPricing = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                   Platform__c = pr.Platform__c,
                                                   Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                   srp__c = currTier.srp__c, wsp__c = currTier.wsp__c,Territory__c = pr.Territory__c,
                                                   Valid_From__c = bundleAvailDt,Valid_To__c = bundleAvailDt.addmonths(3),
                                                   Promotion__c = pr.Promotion__c, iTunes_Tier__c = currTier.iTunes_Tier__c);
             insertPricingList.add(itunesPricing);         
             
             for(Pricing_Tier__c pt : pricingTierMap.values()){
             	decimal currMargin = 0;
             	currMargin =  100 - (pt.wsp__c / pt.srp__c).setscale(2);
             	system.debug('PMargin' + currMargin);
         		if(pt.Territory__c != pr.Territory__c || pt.resolution__c != pr.resolution__c || currMargin == DGF_Constants.BUNDLE_iTune_WSP1) continue;
         		
         		if(currTier.srp__c  == pt.srp__c ){
         			currRepriceTier = pt;
         			System.debug('REPRICE TIER FOUND>>>' + currRepriceTier);
         			break;
         		}else{
         			System.debug('REPRICE TIER NOT FOUND>>>' + currRepriceTier);
         		}
         	}              
         	
         	Pricing__c itunesRePricing;
         	
         	if(currRepriceTier!=null){         		
         		  itunesRePricing = new Pricing__c (Price_Type__c = DGF_Constants.REPRICE, Account__c = DGF_Constants.iTUNES,
                                                   Platform__c = pr.Platform__c,
                                                   Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                   srp__c = currRepriceTier.srp__c, wsp__c = currRepriceTier.wsp__c,Territory__c = pr.Territory__c,
                                                   Valid_From__c = bundleAvailDt.addmonths(3).adddays(1),
                                                   Promotion__c = pr.Promotion__c, iTunes_Tier__c = currRepriceTier.iTunes_Tier__c);
         	}               
                                                   
            
             insertPricingList.add(itunesRePricing); 
                                                   
                                                   
         	
         }else if(((pr.Product__r.Digital_release__r.Initial_Launch_Categorization__c.equalsIgnoreCase('Catalog')) && !pr.product__r.HDR__c && pr.price_type__c == DGF_Constants.ORIGINAL) 
         				|| pr.price_type__c == DGF_Constants.REPRICE ){// at launch+ and no reprice
         	//fix 1723				
         	if(pr.Product__r.Digital_release__r.Initial_Launch_Categorization__c.equalsIgnoreCase('New Release') && !pr.product__r.HDR__c){
         		return null;
         	}				
         	
         	Pricing__c itunesPricing; 
         	
         	 for(Pricing_Tier__c pt : pricingTierMap.values()){
         	 	decimal currMargin = 0;
             	currMargin =  100 - (pt.wsp__c / pt.srp__c).setscale(2);
             	system.debug('PMargin Reprice' + currMargin);
         		if(pt.Territory__c != pr.Territory__c || pt.resolution__c != pr.resolution__c || currMargin == DGF_Constants.BUNDLE_iTune_WSP1) continue;
         		
         		if(currTier.srp__c == pt.srp__c ){
         			currRepriceTier = pt; 
         			break;
         			System.debug('Price Tier Found>>>' + pt);
         		}else{
         			System.debug('NOPrice Tier Found>>>');
         		}
         	}  
         	
         	if(currRepriceTier!=null){
         		itunesPricing = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                   Platform__c = pr.Platform__c,
                                                   Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                   srp__c = currRepriceTier.srp__c, wsp__c = currRepriceTier.wsp__c,Territory__c = pr.Territory__c,
                                                   Valid_From__c = bundleAvailDt,
                                                   Promotion__c = pr.Promotion__c, iTunes_Tier__c = currRepriceTier.iTunes_Tier__c);
             	insertPricingList.add(itunesPricing);  
         	}
         	if(pr.price_type__c == DGF_Constants.REPRICE){
         		itunesPricing.Price_Type__c = DGF_Constants.REPRICE;
         		itunesPricing.Valid_From__c = pr.Valid_From__c;
         		
         	}
         	
         }else if(pr.price_type__c == DGF_Constants.TPR_National || pr.price_type__c == DGF_Constants.TPR_Account){
         	boolean margin1 =true;
         	boolean existingRecMatch = false;
         	List<Pricing__c> pricingList = getProductPricingList(pr.Product__c);
         	
         	for(pricing__c ep : pricingList){
         		if(ep.account__c==DGF_Constants.iTUNES && ep.territory__C == pr.territory__c && ep.resolution__C == pr.resolution__c && (ep.price_type__c == DGF_Constants.ORIGINAL || ep.price_type__c == DGF_Constants.REPRICE)){
         			if(ep.valid_from__c <=pr.valid_to__c && (ep.valid_to__c ==null || ep.valid_to__c >= pr.valid_from__c) ){
         				if(ep.margin__c>DGF_Constants.BUNDLE_iTune_WSP1){ 
         					margin1 = false; 
         				}
         				existingRecMatch = true;
         				break;
         			}
         		}
         	}
         	if(existingRecMatch){
         		Pricing__c itunesPricing = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                   Category__c = pr.Category__c, Platform__c = pr.Platform__c,
                                                   Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                   SRP__c = pr.SRP__c, Territory__c = pr.Territory__c,
                                                   Valid_From__c = pr.Valid_From__c,Valid_To__c = pr.Valid_To__c,
                                                   Promotion__c = pr.Promotion__c);
                                                   
	            if(margin1){            	
	            	itunesPricing.wsp__c = (itunesPricing.srp__c * (100 - DGF_Constants.BUNDLE_iTune_WSP1)/100).setscale(2); 
	            	itunesPricing.iTunes_Tier__c = currTier.iTunes_Tier__c;
	            }else{
	            	itunesPricing.wsp__c = (itunesPricing.srp__c * (100 - DGF_Constants.BUNDLE_iTune_WSP2)/100).setscale(2);
	            	
	            	 for(Pricing_Tier__c pt : pricingTierMap.values()){
		         	 	decimal currMargin = 0;
		             	currMargin =  100 - (pt.wsp__c / pt.srp__c).setscale(2);
		             	system.debug('PMargin Reprice' + currMargin);
		         		if(pt.Territory__c != pr.Territory__c || pt.resolution__c != pr.resolution__c || currMargin == DGF_Constants.BUNDLE_iTune_WSP1) continue;
		         		
		         		if(currTier.srp__c == pt.srp__c ){
		         			currRepriceTier = pt; 
		         			break;
		         			System.debug('Price Tier Found>>>' + pt);
		         		}else{
		         			System.debug('NOPrice Tier Found>>>');
		         		}
		         	}   
		         	
		         	if(currRepriceTier!=null){
		         		itunesPricing.iTunes_Tier__c = currRepriceTier.iTunes_Tier__c;
		         	}
	            }
	            insertPricingList.add(itunesPricing);         		
         	}         	
         } 
                                                   
        return insertPricingList;
    	
    }
    
    /***********************************
    Method Name: createItunesPricing
    Purpose:Create iTunes Pricing record from Pricing tier
    ***********************************/ 
    public static List<Pricing__c> createItunesPricing(Pricing__c prcng) {
        if (!fetchDataSet.containskey('Pricing__c') || !fetchDataSet.get('Pricing__c').containsKey(prcng.id)) {
            return null;
        }
        
        //for cloning not creating itune pricing as it is already existing
        if (DGF_TriggerUtility.isCloningProcess) {
            return null;
        }
        //storing pricing details in instance
        Pricing__c pr = (Pricing__c)fetchDataSet.get('Pricing__c').get(prcng.id);
        if (pr.Product__r.RecordTypeId != FilmRecTypeId) {
            return null;
        }
        
        Pricing__c itunesPricingTPR2;
        Pricing__c updtPrice;
        Pricing__c prcToInsert;
        List<Pricing__c> iTunesPricingToBeInserted = new List<Pricing__c>();
        Map<String,Pricing_Tier__c>pTierMap = new Map<String,Pricing_Tier__c>();
        Map<Id,Pricing__c>iTunesPrcMap = new Map<Id,Pricing__c>();
        Integer days1;
        Integer days2;
        Integer days3;
        Date Change1;
        Date Change2;
        
        //Calculate Windows by no. of months
        if (pr.Territory__c == 'US' && pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null) {
            Change1 = pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6);
            Change2 = pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18);  
        }
        else if (pr.Territory__c == 'CA' && pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null) {
            Change1 = pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6);
            Change2 = pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18);
        }
        
        //storing product details in instance
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prcng.Product__c);
        
        //creating new instance of Pricing
        Pricing__c itunesPricing = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                   Category__c = pr.Category__c, Platform__c = pr.Platform__c,
                                                   Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                   SRP__c = pr.SRP__c, Territory__c = pr.Territory__c,
                                                   Valid_From__c = pr.Valid_From__c,Valid_To__c = pr.Valid_To__c,
                                                   Promotion__c = pr.Promotion__c);
        //create TPR iTunes Pricing 
        if ((pr.Price_Type__c == DGF_Constants.TPR_National || pr.Price_Type__c == DGF_Constants.TPR_Account) 
            && pr.SRP__c != null && pr.Valid_From__c < Change1 && Change1 <= pr.Valid_To__c) {
                itunesPricingTPR2 = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                    Category__c = pr.Category__c, Platform__c = pr.Platform__c,
                                                    Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                    SRP__c = pr.SRP__c, Territory__c = pr.Territory__c,
                                                    Valid_To__c = pr.Valid_To__c, Promotion__c = pr.Promotion__c);
                itunesPricingTPR2.Valid_From__c = change1;
                itunesPricing.Valid_To__c = change1 -1;
            }
        else if((pr.Price_Type__c == DGF_Constants.TPR_National || pr.Price_Type__c == DGF_Constants.TPR_Account) 
                && pr.SRP__c != null && pr.Valid_From__c < Change2 && Change2 <= pr.Valid_To__c) {
                    itunesPricingTPR2 = new Pricing__c (Price_Type__c = pr.Price_Type__c, Account__c = DGF_Constants.iTUNES,
                                                        Category__c = pr.Category__c, Platform__c = pr.Platform__c,
                                                        Product__c = pr.Product__c, Resolution__c = pr.Resolution__c,
                                                        SRP__c = pr.SRP__c, Territory__c = pr.Territory__c,
                                                        Valid_To__c = pr.Valid_To__c, Promotion__c = pr.Promotion__c);
                    itunesPricingTPR2.Valid_From__c = change2;
                    itunesPricing.Valid_To__c = change2 -1;
                }
        //Ch DFOR - 1333 start
        List<Pricing__c> pricingList = getProductPricingList(prod.Id);
        //Ch DFOR - 1333 End
        //looping over iTunes pricing for Original or Reprice type to find existing iTunes records
        if(prod != null && (pr.Price_Type__c == DGF_Constants.ORIGINAL || pr.Price_Type__c == DGF_Constants.REPRICE)){
            for(Pricing__c exstingiTunesPrc : pricingList){                
                if(pr.Id == exstingiTunesPrc.Id && DGF_triggerUtility.isTestRunning){
                    continue;
                }
                if(pr.Product__c == exstingiTunesPrc.Product__c){
                    if(exstingiTunesPrc.Platform__c == pr.Platform__c && exstingiTunesPrc.Resolution__c == pr.Resolution__c && 
                       exstingiTunesPrc.Territory__c == pr.Territory__c && exstingiTunesPrc.Account__c == DGF_Constants.iTUNES && (exstingiTunesPrc.Price_Type__c == DGF_Constants.ORIGINAL || exstingiTunesPrc.Price_Type__c == DGF_Constants.REPRICE)){
                           iTunesPrcMap.put(exstingiTunesPrc.Id, exstingiTunesPrc);
                       }
                }
            }
        }
        
        //update Windows for existing and new iTunes records
        if(!iTunesPrcMap.isEmpty()){
            for(Pricing__c existiTunes : iTunesPrcMap.values()){
                if(existiTunes.Valid_From__c < pr.Valid_From__c && (existiTunes.Valid_To__c == null || pr.Valid_From__c < existiTunes.Valid_To__c)){
                    itunesPricing.Valid_To__c = existiTunes.Valid_To__c;
                    updtPrice = existiTunes;
                    updtPrice.Valid_To__c = pr.Valid_From__c - 1;
                    if(!updateExistingPricing.containsKey(updtPrice.Id))
                        updateExistingPricing.put(updtPrice.Id,updtPrice);
                }
                else if(existiTunes.Valid_From__c >= pr.Valid_From__c){
                    updtPrice = existiTunes;
                    updtPrice.SRP__c = pr.SRP__c;
                    Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(updtPrice.Product__c);
                    
                    //looping over pricing for the product
                    if(prd != null){
                    List<Pricing__c> productPricingList = getProductPricingList(prd.Id);
                        for(Pricing__c exstingPrc : productPricingList){
                            
                            if(updtPrice.Id == exstingPrc.Id){
                                if(exstingPrc.Territory__c==DGF_Constants.TERRITORY_US){
                                    if(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && exstingPrc.Valid_From__c != null){
                                        days1=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Valid_From__c);
                                        days2=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                                        days3=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                                    }
                                }
                                else if (exstingPrc.Territory__c==DGF_Constants.TERRITORY_CA){
                                    if(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && exstingPrc.Valid_From__c != null){ 
                                        days1=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Valid_From__c);
                                        days2=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                                        days3=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                                    }
                                }
                                
                                CalculateWSPandiTunesTier(updtPrice,days1,days2,days3);
                                if(!updateExistingPricing.containsKey(updtPrice.Id))
                                    updateExistingPricing.put(updtPrice.Id,updtPrice);
                            }
                        }
                    }
                }
            }
        }
        
        
        //Calculate WSP for US based on Valid from and iTunes Price Date
        if(pr.Territory__c==DGF_Constants.TERRITORY_US){
            
            if(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && pr.Valid_From__c != null){
                days1=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pr.Valid_From__c);
                days2=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                days3=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
            }
            
            //Calculate WSP for CA based on Valid from and iTunes Price Date
        } else if (pr.Territory__c==DGF_Constants.TERRITORY_CA){
            if(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && pr.Valid_From__c != null){
                days1=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pr.Valid_From__c);
                days2=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                days3=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
            }
            
        }  
        prcToInsert = CalculateWSPandiTunesTier(itunesPricing,days1,days2,days3); 
        iTunesPricingToBeInserted.add(prcToInsert);
        if(itunesPricingTPR2 != null){
            //Calculate WSP for US based on Valid from and iTunes Price Date
            if(pr.Territory__c==DGF_Constants.TERRITORY_US){
                
                if(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && itunesPricingTPR2.Valid_From__c != null){
                    days1=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(itunesPricingTPR2.Valid_From__c);
                    days2=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                    days3=pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                }
                
                //Calculate WSP for CA based on Valid from and iTunes Price Date
            } else if (pr.Territory__c==DGF_Constants.TERRITORY_CA){
                if(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && itunesPricingTPR2.Valid_From__c != null){
                    days1=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(itunesPricingTPR2.Valid_From__c);
                    days2=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                    days3=pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                }
                
            }
            prcToInsert = CalculateWSPandiTunesTier(itunesPricingTPR2,days1,days2,days3);
            iTunesPricingToBeInserted.add(prcToInsert);
        }
        
        return iTunesPricingToBeInserted;
        
    }
    
    /***********************************
    Method Name: CalculateWSPandiTunesTier
    Purpose:calculate WSP and iTunes Tier
    ***********************************/ 
    public static Pricing__c CalculateWSPandiTunesTier(Pricing__c pr,Integer day1,Integer day2,Integer day3){
        Map<String,Pricing_Tier__c>pTierMap = new Map<String,Pricing_Tier__c>();
        
        
        if(DGF_TriggerUtility.getDataSetFromBatch){
           if (!fetchDataSet.containsKey('Pricing_Tier__c')) {
                fetchDataSet.put('Pricing_Tier__c', new Map<ID,sObject>());
            }
            for (Pricing_Tier__c pt : [SELECT ID, Product_Type__c, iTunes_Tier__c, Customer_Specific__c, Category__c, WSP__c, SRP__c, Territory__c, Resolution__c, Platform__c from Pricing_Tier__c WHERE Customer_Specific__c =: 'iTunes']) {
                fetchDataSet.get('Pricing_Tier__c').put(pt.ID, pt);
            }   
        }
        //Fetch Data from Pricing Tier Object
        if(fetchDataSet.containsKey('Pricing_Tier__c') && fetchDataSet.get('Pricing_Tier__c')!=NULL){
            
            for(pricing_Tier__c pTier : (List<Pricing_Tier__c> )fetchDataSet.get('Pricing_Tier__c').values()){
                if(pTier.Customer_Specific__c == DGF_Constants.iTUNES && pTier.Product_Type__c == DGF_Constants.FILM)
                    pTierMap.put(pTier.Resolution__c+':'+pTier.Territory__c+':'+pTier.SRP__c+':'+pTier.Platform__c,pTier);
            }
        }
        
        //Calculate WSP for based on Valid from and iTunes Price Date
        if(day1 < day2 && pr.srp__c!= null){
            pr.WSP__c=(pr.srp__c * DGF_Constants.DEFAULT_WSP1).setScale(2);
        }
        else if(day2<=day1 && day1<day3 && pr.srp__c!= null){
            pr.WSP__c=(pr.srp__c * DGF_Constants.DEFAULT_WSP2).setScale(2);
        }
        else if(day1>=day3 && pr.srp__c!= null){
            pr.WSP__c=(pr.srp__c * DGF_Constants.DEFAULT_WSP3).setScale(2);
        }
        else if(pr.SRP__c == null){
            pr.WSP__c = null;
        }
        
        //Populate iTunes Tier from Pricing Tier Object
        if(pTierMap.containsKey(pr.Resolution__c+':'+pr.Territory__c+':'+pr.SRP__c+':'+pr.Platform__c)){
            pr.iTunes_Tier__c = pTierMap.get(pr.Resolution__c+':'+pr.Territory__c+':'+pr.SRP__c+':'+pr.Platform__c).iTunes_Tier__c;
        }
        
        return pr;        
    }
    /***********************************
    Method Name: getProductPricingList
    Purpose: return list of pricing records for product
    ***********************************/ 
    public Static List<Pricing__c> getProductPricingList(Id productId) {
        List<Pricing__c> productPricingList = new List<Pricing__c>();
        List<Pricing__c> pricingList = fetchDataSet.get('ProductPricing').values();
        for(Pricing__c price: pricingList) {
            if(price.Product__c == productId ) {
                productPricingList.add(price);
            }
        }
        return productPricingList;
    }
    /***********************************
    Method Name: updateSrpOfExistingTPRiTunes
    Purpose:update SRP of TPR iTunes Pricing
    ***********************************/ 
    public static void updateSrpOfExistingTPRiTunes(Pricing__c prcng){
        //check if product instance present
        if(!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(prcng.Product__c)){
            return;
        }
        
        //storing product details in instance
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(prcng.Product__c);
        Map<Id,Pricing__c>iTunesTPRPrcMap = new Map<Id,Pricing__c>();
        Pricing__c updtPrice;
        //Ch DFOR - 1333 start
        List<Pricing__c> pricingList = getProductPricingList(prod.Id);
        //Ch DFOR - 1333 End
        if(prod.RecordTypeId == FilmRecTypeId){
            //looping over iTunes pricing for TPR type to find existing iTunes records
            if(prod != null ){
                for(Pricing__c exstingTPRiTunesPrc : pricingList){    //Ch DFOR -1333
                    if(prcng.Id == exstingTPRiTunesPrc.Id && DGF_triggerUtility.isTestRunning){
                        continue;
                    }
                    if(prcng.Product__c == exstingTPRiTunesPrc.Product__c){
                        if(exstingTPRiTunesPrc.Platform__c == prcng.Platform__c && exstingTPRiTunesPrc.Resolution__c == prcng.Resolution__c && 
                           exstingTPRiTunesPrc.Territory__c == prcng.Territory__c && exstingTPRiTunesPrc.Account__c == DGF_Constants.iTUNES && 
                           exstingTPRiTunesPrc.Price_Type__c == prcng.Price_Type__c && exstingTPRiTunesPrc.Promotion__c == prcng.Promotion__c){
                               iTunesTPRPrcMap.put(exstingTPRiTunesPrc.Id, exstingTPRiTunesPrc);
                           }
                    }
                }
            }
            
            //update Windows for existing and new iTunes records
            if(!iTunesTPRPrcMap.isEmpty()){
                for(Pricing__c existTPRiTunes : iTunesTPRPrcMap.values()){
                    updtPrice = existTPRiTunes;
                    updtPrice.SRP__c = prcng.SRP__c;
                    Product__c prd = (Product__c)fetchDataSet.get('Product__c').get(updtPrice.Product__c);
                    Integer days1;
                    Integer days2;
                    Integer days3;
                    
                    //looping over pricing for the product
                    if(prd != null){
                        List<Pricing__c> productPricingList = getProductPricingList(prd.id);
                        for(Pricing__c exstingPrc : productPricingList){
                            
                            if(updtPrice.Id == exstingPrc.Id){
                                if(exstingPrc.Territory__c==DGF_Constants.TERRITORY_US){
                                    if(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && exstingPrc.Valid_From__c != null){
                                        days1=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Valid_From__c);
                                        days2=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                                        days3=exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                                    }
                                }
                                else if (exstingPrc.Territory__c==DGF_Constants.TERRITORY_CA){
                                    if(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && exstingPrc.Valid_From__c != null){ 
                                        days1=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Valid_From__c);
                                        days2=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                                        days3=exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(exstingPrc.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                                    }
                                }
                                
                                CalculateWSPandiTunesTier(updtPrice,days1,days2,days3); 
                                updateExistingPricing.put(updtPrice.Id,updtPrice);
                            }
                        }
                    }
                }
            } 
        }
    }
    
    /***********************************
    Method Name: checkUniqueness
    Purpose:Create unique Pricing record
    ***********************************/ 
    public static void checkUniqueness(Pricing__c newPrc) {
        
        //check if product instance present
        if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(newPrc.Product__c)) {
            return;
        }
        
        //storing product details in instance
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(newPrc.Product__c);
        //Ch DFOR - 1333 start
        List<Pricing__c> pricingList = getProductPricingList(prod.Id);
        //Ch DFOR - 1333 End
        //looping over pricing for the product
        if (prod != null) {
            for (Pricing__c exstingPrc : pricingList) {                
                if (newPrc.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
                    continue;
                }
                
                if (exstingPrc.Price_Type__c == DGF_Constants.TPR_National || exstingPrc.Price_Type__c == DGF_Constants.TPR_Account) {
                    continue; 
                }
                    
                if (newPrc.Product__c == exstingPrc.Product__c) {
                    //if below fiels match then record is unique
                    if ((newPrc.Price_Type__c == DGF_Constants.ORIGINAL || newPrc.Price_Type__c == DGF_Constants.REPRICE) && newPrc.Account__c == exstingPrc.Account__c && 
                                       newPrc.Territory__c == exstingPrc.Territory__c && newPrc.Platform__c == exstingPrc.Platform__c && 
                                       newPrc.Resolution__c == exstingPrc.Resolution__c) {
                           
                           //if valid from is null
                           if (newPrc.Valid_From__c == null && !DGF_TriggerUtility.isBulkReprice && DGF_TriggerUtility.isTVPricing) {
                               newPrc.addError(DGF_Constants.DGF_Enter_Valid_From_Date);
                           }
                           //if valid from are same for current and existing records
                           else if (exstingPrc.Valid_From__c == newPrc.Valid_From__c && !DGF_TriggerUtility.isBulkReprice) {
                               newPrc.addError(DGF_Constants.DGF_Update_Valid_From_Date +' : '+ exstingPrc.Product__r.Name +' ( '+ DGF_Constants.DGF_RecordID +' : ['+exstingPrc.Id+']) '+ DGF_Constants.DGF_Valid_From +' : ['+ exstingPrc.Valid_From__c+'] '+ DGF_Constants.DGF_Valid_To +' : ['+exstingPrc.Valid_To__c+']).');
                           }
                           //if valid from is greater than existing Valid from
                           else if (exstingPrc.Valid_From__c < newPrc.Valid_From__c && newPrc.Valid_From__c <= exstingPrc.Valid_To__c) {
                               if (!DGF_TriggerUtility.isBulkReprice) {
                                   newPrc.addError(DGF_Constants.DGF_Update_Valid_From_Date +' : '+ exstingPrc.Product__r.Name +' ( '+ DGF_Constants.DGF_RecordID + ' : ['+exstingPrc.Id+']) '+ DGF_Constants.DGF_Valid_From +' : ['+exstingPrc.Valid_From__c+'] '+ DGF_Constants.DGF_Valid_To +' : ['+exstingPrc.Valid_To__c+']).');
                               }                                   
                               else if (DGF_TriggerUtility.isBulkReprice && !DGF_TriggerUtility.mapOfProductBulkReprice.containsKey(exstingPrc.Product__c)) {
                                   DGF_TriggerUtility.mapOfProductBulkReprice.put(exstingPrc.Product__c,exstingPrc.Product__r.Name+' - '+exstingPrc.Valid_To__c.format()+' For '+exstingPrc.Territory__c);
                               }                               
                           }                                           
                           //if valid from is lesser than existing Valid from
                           else if ((newPrc.Valid_From__c < exstingPrc.Valid_From__c) && (newPrc.Valid_To__c == null || exstingPrc.Valid_From__c <= newPrc.Valid_To__c) && !DGF_TriggerUtility.isBulkReprice) {
                               newPrc.addError(DGF_Constants.DGF_Update_Valid_To_Date +' : '+ exstingPrc.Product__r.Name +' ( '+ DGF_Constants.DGF_RecordID +' : ['+exstingPrc.Id+']) '+ DGF_Constants.DGF_Valid_From +' : ['+exstingPrc.Valid_From__c+'] '+ DGF_Constants.DGF_Valid_To + ' : ['+exstingPrc.Valid_To__c+']).');
                           }
                           else if (DGF_TriggerUtility.isBulkReprice && newPrc.Valid_From__c <= exstingPrc.Valid_From__c) {
                               DGF_TriggerUtility.mapOfProductBulkReprice.put(exstingPrc.Product__c,exstingPrc.Product__r.Name+' - '+exstingPrc.Valid_From__c.format()+' For '+exstingPrc.Territory__c);
                           }
                       } 
                }
            } 
        }
    }
    
    /***********************************
    Method Name: UpdateValidToDate
    Purpose:Update Valid to Date of Pricing record
    ***********************************/ 
    public static void UpdateValidToDate(Pricing__c newPrc) {
        //check if product instance present
        if (!fetchDataSet.containskey('Product__c') || !fetchDataSet.get('Product__c').containsKey(newPrc.Product__c)) {
            return;
        }
        
        //storing product details in instance
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(newPrc.Product__c);
        Pricing__c updtPrice;
        DGF_TriggerUtility.checkPricingUniqueness = FALSE;
        //Ch DFOR - 1333 start
        List<Pricing__c> pricingList = getProductPricingList(prod.Id);
        //Ch DFOR - 1333 End
        //looping over pricing for the product
        if (prod != null ) {
            for (Pricing__c exstingPrc : pricingList) {                
                if (newPrc.Id == exstingPrc.Id && DGF_triggerUtility.isTestRunning) {
                    continue;
                }
                
                if ((newPrc.Price_Type__c == DGF_Constants.ORIGINAL || newPrc.Price_Type__c == DGF_Constants.REPRICE) && newPrc.Account__c == exstingPrc.Account__c && 
                                       newPrc.Territory__c == exstingPrc.Territory__c && newPrc.Platform__c == exstingPrc.Platform__c && 
                                       newPrc.Resolution__c == exstingPrc.Resolution__c) {
                       if (exstingPrc.Valid_From__c < newPrc.Valid_From__c && exstingPrc.Valid_To__c == null) {  
                           updtPrice = exstingPrc;                    
                           updtPrice.Valid_to__c = newPrc.Valid_From__c - 1;
                           updateExistingPricing.put(updtPrice.Id,updtPrice);                    
                       } 
                }
            } 
        }
    }
    
    /*****************************************
    Method Name: createPromotionProductMapping
    Purpose: DFOR-423 for creating promotion product mapping
    *****************************************/   
    private static void createPromotionProductMapping(Pricing__c pp) {
        
        //if product instance is not present
        if (!fetchDataSet.containsKey('Product__c') || !fetchDataSet.get('Product__c').containsKey(pp.Product__c)) {
            return;
        }
        
        //if promotion instance is not present
        if (!fetchDataSet.containsKey('Promotion__c') || !fetchDataSet.get('Promotion__c').containsKey(pp.Promotion__c)) {
            return;
        }
        
        //getting promotion details
        Promotion__c promotionDetails = (Promotion__c)fetchDataSet.get('Promotion__c').get(pp.Promotion__c);
        
        //if not national promotion return
        if (promotionDetails.RecordTypeId != NationalRecTypeId) {
            return;
        }
        
        //getting product details 
        Product__c prod = (Product__c)fetchDataSet.get('Product__c').get(pp.Product__c);
        
        //if map does not contain key for promotion
        if (!mapPromotionProd.containsKey(pp.Promotion__c)) {
            mapPromotionProd.put(pp.Promotion__c, new Set<String>());
        }
        
        string WSP;
        string SRP;
        
        if (pp.WSP__c == null) {
            WSP = 'NA';
        }
        else {
            WSP = '$'+ pp.WSP__c;
        }
        
        if (pp.SRP__c == null) {
            SRP = 'NA';
        }
        else {
            SRP = '$'+ pp.SRP__c;
        }
        
        //creating a map of all national promotion with productname      
        mapPromotionProd.get(pp.Promotion__c).add(prod.Name + ': ' + pp.Territory__c + ' ' + pp.Platform__c + ' ' + pp.Resolution__c + ' - ' + WSP + '/' + SRP);           
    }
    
    public static void createFeedItem(string message, id prodId){    	
    	 if (!insertableDataSet.containsKey('FeedItem')) {
                insertableDataSet.put('FeedItem', new List<sObject>());
            }
    	//creating an instance of feed item
        FeedItem post = new FeedItem();
        post.ParentId = prodId; 
        post.IsRichText = TRUE;
        post.Body = message;
        insertableDataSet.get('FeedItem').add(post);
    }
    
    /*****************************************
    Method Name: chatterPostOnChildPromotion
    Purpose: DFOR-423 for posting a chatter on child promotion if start/end date is updated on nation promotion
    *****************************************/   
    private static void chatterPostOnChildPromotion() {     
        
        //if map not empty
        if (!mapPromotionProd.isEmpty()) {
            
            //adding feeditem key to insertable data set
            if (!insertableDataSet.containsKey('FeedItem')) {
                insertableDataSet.put('FeedItem', new List<sObject>());
            }
            
            //looping over map
            for (Id promoId : mapPromotionProd.keySet()) {
                
                //getting promotion details
                Promotion__c promotionDetails = (Promotion__c)fetchDataSet.get('Promotion__c').get(promoId);
                
                //if child records are present
                if (!promotionDetails.Promotions__r.isEmpty()) {
                    //looping over child promotion records
                    for (Promotion__c promotionChild : promotionDetails.Promotions__r) {
                        
                        //if child promotion is of type account
                        if (promotionChild.RecordTypeId == AccRecTypeId) {
                            
                            //creating an instance of feed item
                            FeedItem post = new FeedItem();
                            post.ParentId = promotionChild.Id; 
                            post.IsRichText = TRUE;
                            post.Body = '<p>National Offering has updated the Product Pricing: &nbsp;</p>'; 
                            
                            //looping over products to be posted
                            for(string s : mapPromotionProd.get(promoId)){
                                post.Body = post.Body + '<p><li>' + s + '&nbsp;</li></p>' ;
                            }
                            
                            //adding details to insertable data set
                            insertableDataSet.get('FeedItem').add(post);  
                        }
                    }
                }
            }
        }
    }
}