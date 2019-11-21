/***********************************************************************************
Class Name: DGF_PromotionProductTriggerHandler
Purpose: Handler class for Promotion Product trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/07/2017           Prarthana                Initial Development
1.1             07/11/2017           Mohit                    DFOR-423: National Promotion Update Notification
******************************************************************************************/
public class DGF_PromotionProductTriggerHandler {
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static set<id> promoIDSet = new set<ID>();
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Promotion_Product__c prOld ;
    private static Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
    private static Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
    private static set<id> setPromotionId = new set<ID>();
    private static set<id> setProductId = new set<ID>();
    private static map<Id, set<string>> mapPromotionProd = new Map<Id, set<string>>();
    
    /***********************************
    Method Name: resetDataSet
    Purpose: method to reset context data variable
    ***********************************/
    private static void resetDataSet() {    
        updateableDataSet.clear();
        insertableDataSet.clear();
        promoIDSet.clear();
        fetchDataSet.clear();
        setPromotionId.clear();
        mapPromotionProd.clear();
        setProductId.clear();
    }
    
    /***********************************
    Method Name: getDataSet
    Purpose: method for executing SOQL
    ***********************************/
    @testVisible private static void getDataSet() {
        if (!promoIDSet.isEmpty()) {
            if (!fetchDataSet.containsKey('Pricing__c')) {
                fetchDataSet.put('Pricing__c',new Map<ID,sObject>());
            }
            
            //query for the Pricing records
            for (Pricing__c p : [SELECT ID, Valid_from__c, valid_to__c, promotion__c, product__c from pricing__c where promotion__c in : promoIDSet]) {
                fetchDataSet.get('Pricing__c').put(p.id,p);
            }
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
        
        //if set not empty
        if (!setProductId.isEmpty()) {          
            //adding Product as key 
            if (!fetchDataSet.containsKey('Product__c')) {
                fetchDataSet.put('Product__c',new Map<ID,sObject>());
            }
            
            //looping over product records
            for (Product__c prod : [Select id, name from Product__c where Id IN : setProductId]) {
                fetchDataSet.get('Product__c').put(prod.ID, prod);  
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
            for (String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                List<SObject> dataSet = insertableDataSet.get(sobjectApi);
                
                //inserting records
                if (!dataSet.isEmpty()) {
                    try {
                        insert dataSet;
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
    Method Name: executeOnAfterInsert
    Purpose:Should execute only for after insert event
    ***********************************/    
    public static void executeOnAfterInsert() {
        //first iteration over trigger.new to create collections
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.new) {
            //prepare a set of Promotion ID's
            if (!setPromotionId.contains(pr.promotion__c)) {
                setPromotionId.add(pr.promotion__c);
            }      

            //creating a set of product ids
            if (!setProductId.contains(pr.Product__c)) {
                setProductId.add(pr.Product__c);
            }
        }
        
        getDataSet();       
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.new) {
            //creating mapping of promotion and product
            createPromotionProductMapping(pr);
        }
        
        //chatter notification 
        chatterPostOnChildPromotion();
        
        //method to commit the data
        commitDataSet();
        
        //method to reset the data
        resetDataSet();
    }
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {
        
        //first iteration over trigger.new to create collections
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.new) {
            //prepare a set of Promotion ID's
            promoIDSet.add(pr.promotion__c);
            
            //prepare a set of Promotion ID's
            if (!setPromotionId.contains(pr.promotion__c)) {
                setPromotionId.add(pr.promotion__c);
            }      

            //creating a set of product ids
            if (!setProductId.contains(pr.Product__c)) {
                setProductId.add(pr.Product__c);
            }
        }
        
        getDataSet();
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.new) {
            
            prOld = (Promotion_Product__c) Trigger.OldMap.get(pr.Id);
            
            //check if either TPR Start or end date is modified
            if (pr.TPR_Start_date__c != prOld.TPR_Start_date__c || pr.TPR_End_date__c != prOld.TPR_End_date__c) {
                if (fetchDataSet != null && fetchDataSet.get('Pricing__c') != null) {
                    for (sobject price : fetchDataSet.get('Pricing__c').values()) {
                        Pricing__c p = (Pricing__c)price;
                        //invoke the updateDates method
                        if (p.promotion__c == pr.promotion__c && p.product__c == pr.product__c && pr.TPR_Start_date__c != prOld.TPR_Start_date__c) {
                            updateDates('validFrom', p, pr.TPR_Start_Date__c);
                        }
                        if (p.promotion__c == pr.promotion__c && p.product__c == pr.product__c && pr.TPR_End_date__c != prOld.TPR_End_date__c) {
                            updateDates('validTo', p, pr.TPR_End_Date__c);
                        }
                    }
                }
            }
            
            //creating mapping of promotion and product
            if (pr.TPR_End_Date__c != prOld.TPR_End_Date__c || pr.TPR_Start_Date__c != prOld.TPR_Start_Date__c) {
                createPromotionProductMapping(pr);
            }            
        }
        
        //chatter notification 
        chatterPostOnChildPromotion();
        
        //method to commit the data
        commitDataSet();
        
        //method to reset the data
        resetDataSet();
    }
    
    /***********************************
    Method Name: executeOnAfterDelete
    Purpose:Should execute only for after delete event
    ***********************************/    
    public static void executeOnAfterDelete() {
        //first iteration over trigger.new to create collections
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.old) {
            //prepare a set of Promotion ID's
            if (!setPromotionId.contains(pr.promotion__c)) {
                setPromotionId.add(pr.promotion__c);
            }      

            //creating a set of product ids
            if (!setProductId.contains(pr.Product__c)) {
                setProductId.add(pr.Product__c);
            }
        }
        
        getDataSet();       
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion_Product__c pr : (List<Promotion_Product__c>)trigger.old) {
            //creating mapping of promotion and product
            createPromotionProductMapping(pr);
        }
        
        //chatter notification 
        chatterPostOnChildPromotion();
        
        //method to commit the data
        commitDataSet();
        
        //method to reset the data
        resetDataSet();
    }
    
    /***********************************
    Method Name: updateDates
    Purpose:update dates of TPR Pricing Records 
    ***********************************/    
    public static void updateDates(String fieldToUpdate, Pricing__c price, Date dt) {
        
        Map<Id,Pricing__c> pricingUpdateMap = new Map<Id,Pricing__c>();
        
        //to update the Valid from Date
        if (fieldToUpdate == 'validFrom') {
            price.Valid_From__c = dt;
            pricingUpdateMap.put(price.id,price);
        }
        //to update the Valid toDate
        else if (fieldToUpdate == 'validTo') {
            price.Valid_To__c = dt;
            pricingUpdateMap.put(price.id,price);
        }
        
        //put the pricing record to the updateableDataSet
        if (updateableDataSet.containsKey('Pricing__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Pricing__c');
            for (Sobject pricing : pricingUpdateMap.values()) {
                updateMap.put(pricing.id,pricing);
            }
        }
        else {
            updateableDataSet.put('Pricing__c',pricingUpdateMap);
        }
    }
    
    /*****************************************
    Method Name: createPromotionProductMapping
    Purpose: DFOR-423 for creating promotion product mapping
    *****************************************/   
    private static void createPromotionProductMapping(Promotion_Product__c pp) {
        
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
        
        //creating a map of all national promotion with productname
        if (Trigger.isUpdate) {
            mapPromotionProd.get(pp.Promotion__c).add(prod.Name + ': ' + (pp.TPR_Start_Date__c == null ? 'NA' : pp.TPR_Start_Date__c.format())  + 
                                                                                   ' - ' + (pp.TPR_End_Date__c == null ? 'NA' : pp.TPR_End_Date__c.format())); 
        }
        else {
            mapPromotionProd.get(pp.Promotion__c).add(prod.Name);           
        }        
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
                            
                            //based on trigger event building trigger body
                            if (Trigger.isInsert) {
                                post.Body = '<p>National Offering has updated the titles:</p>' + '<p><b>Added: &nbsp;</b></p>';
                            }
                            else if (Trigger.isDelete) {
                                post.Body = '<p>National Offering has updated the titles:</p>' + '<p><b>Removed: &nbsp;</b></p>';
                            }    
                            else if (Trigger.isUpdate) {
                                post.Body = '<p>National Offering has updated the Product Dates: &nbsp;</p>'; 
                            }
                            
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