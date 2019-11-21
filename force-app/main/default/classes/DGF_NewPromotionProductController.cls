/*****************************************************************************************
Class Name: DGF_NewPromotionProductController
Purpose: Controller for new promotion product component
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/06/2017           Jata                    Initial Development
******************************************************************************************/
public without sharing class DGF_NewPromotionProductController {
    
    /**private instance**/
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id EpsdpricngRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.EPISODE_PRICING).getRecordTypeId();
    private static Id PreOrderRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Pre-Order').getRecordTypeId();
    private static Map<Id,Promotion_Product__c> mapOfExistingPromoProd;
    
    /***********************************
    Method Name: fetchProducts
    Purpose: method to fetch Products
    ***********************************/
    @AuraEnabled public static List<PromotionProductWrapper> fetchProducts(String searchKeyWord, String buttonID) {
        try {
            
            //storing search key word in a variable
            String searchKey = '%' + searchKeyWord + '%';
            String SOQL;
            Boolean isTPR = TRUE;
            
            //list of type wrapper to be returned
            List<PromotionProductWrapper> returnPromotionProduct = new List<PromotionProductWrapper>();
            //Creating string query
            SOQL = 'Select Id,Name,RecordTypeID from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey OR Franchise__c LIKE :searchKey) And RecordTypeId !=: EpsdpricngRecTypeId And RecordTypeId !=:PreOrderRecTypeId order by Name';
            
            if (buttonID == 'btnSearchFilm') {
                if (searchKeyWord == null) {
                    SOQL = 'Select Id,Name,RecordTypeID from Product__c where RecordTypeId =: FilmRecTypeId order by Name';
                }
                else {
                    SOQL = 'Select Id,Name,RecordTypeID from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey OR Franchise__c LIKE :searchKey) And RecordTypeId =: FilmRecTypeId order by Name';
                }
            }
            else if (buttonID == 'btnSearchTV') {
                if (searchKeyWord == null) {
                    SOQL = 'Select Id,Name,RecordTypeID from Product__c where RecordTypeId =: TVRecTypeId order by Name'; 
                }
                else {
                    SOQl = 'Select Id,Name,RecordTypeID from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey OR Franchise__c LIKE :searchKey) And RecordTypeId =: TVRecTypeId order by Name';
                }
            }
            
            //querying all matching Products
            List<Product__c> lstOfProducts = Database.query(SOQL);
            
            if (!lstOfProducts.isEmpty()) {
                for (Product__c prd : lstOfProducts) {
                    //adding a instance in the list
                    returnPromotionProduct.add(new PromotionProductWrapper(prd,null,isTPR));
                }
            }
            return returnPromotionProduct;
        }
        catch (exception ex) {
            throw new AuraHandledException(ex.getMessage());
            return null;
        }        
    }
    
    /***********************************
    Method Name: getUser
    Purpose: method to get product/Account user
    ***********************************/
    @AuraEnabled public static boolean getUser(String recordID) {
        //query for promotion record
        Promotion__c pr = [SELECT ID, RecordTypeId from Promotion__c where id =: recordID ];
        //get the recordType name
        RecordType rt = [SELECT Name, Id from RecordType where id =: pr.recordTypeId and SObjectType = 'Promotion__c'];
        Boolean retVal;
        User u = [Select id, Name, Profile.Name from User where ID =: userinfo.getUserID()];
        if (rt.name == 'Account Promotion') {
            if (u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN) || u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER) {
                retVal= false;
            } else {
                retVal= true;
            }
        }
        else if (rt.name=='National Promotion') {
           if (u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN) || u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER ) {
                retVal= false;
            }
            else {
                retVal= true;
            }
        }
        else if (rt.name=='Free Episode') {
            if (u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN) || u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER || u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER) {
                retVal= false;
            }
            else {
                retVal= true;
            }
        }
        return retVal;
    }
    
    /***********************************
    Method Name: getPromotionProduct
    Purpose: method to get existing Promotion Product
    ***********************************/
    @AuraEnabled public static List<PromotionProductWrapper> getPromotionProduct(String recordID) {
        
        //list of type wrapper to be returned
        List<PromotionProductWrapper> returnPromotionProduct = new List<PromotionProductWrapper>();
        //query for promotion Product record
        List<Promotion_Product__c> lstOfprmPrd = [SELECT Id, Product__c, TPR__c, Product__r.Name, Product__r.RecordTypeId, Promotion__c,Sort_Index__c from Promotion_Product__c where Promotion__c =: recordID ORDER BY Sort_Index__c ASC];
        if (!lstOfprmPrd.isEmpty()) {
            for (Promotion_Product__c prmPrd : lstOfprmPrd) {
                //adding a instance in the list
                returnPromotionProduct.add(new PromotionProductWrapper(null,prmPrd,true));
            }  
        }
        
        return returnPromotionProduct;
    }
    
    /***********************************
    Method Name: submitDetails
    Purpose: save records
    ***********************************/
    @AuraEnabled public static String submitDetails(ID promotionID, String strPromotionProduct) {
        try {
            set<Id>promoProdIdSet = new set<Id>();
            List<Promotion_Product__c> insertablePromotionProduct = new List<Promotion_Product__c>();
            List<Promotion_Product__c> deletablePromotionproduct = new List<Promotion_Product__c>();
            Map<Id,Promotion_Product__c> mapOfExistingPromoProd = new Map<Id,Promotion_Product__c>();
            Promotion__c promoDetails = [Select Id, RecordTypeId, Sync_Free_First_Episode_Dates__c, Start_Date__c, End_Date__c from Promotion__c where Id =: promotionID];
            List<DGF_NewPromotionProductController.PromotionProductWrapper> lstPromotionProduct = (List<DGF_NewPromotionProductController.PromotionProductWrapper>)System.JSON.deserialize(strPromotionProduct,List<DGF_NewPromotionProductController.PromotionProductWrapper>.class);
            ID FreeEpisodeRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
            Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
            Id TVRelRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
            List<PromotionProductWrapper> promotionProdList = new List<PromotionProductWrapper>();
            set<Id> prodIdSet = new set<Id>();
            set<Id> promotionSetId = new set<Id>();
            set<Id> productSetId = new set<Id>();
            List<Pricing__c> toDeletePricing = new List<Pricing__c>();
            
            promotionProdList=getPromotionProduct(promotionID);
            
            if (!promotionProdList.isEmpty()) {
                for (PromotionProductWrapper  promProd : promotionProdList) {
                    mapOfExistingPromoProd.put(promProd.prmProd.Id, promProd.prmProd);
                    prodIdSet.add(promProd.productID);
                }
            }
            
            //checking if product Promotion list is not empty
            if (!lstPromotionProduct.isEmpty()) {
                for (PromotionProductWrapper  promProd : lstPromotionProduct) {
                    
                    //creating an instance of Promotion Product
                    if (promProd.prmProd == null) {
                        promProd.prmProd = new Promotion_Product__c();
                        promProd.prmProd.Product__c = promProd.productID;
                        promProd.prmProd.Promotion__c = promotionID; 
                        promProd.prmProd.Collection__c = true;
                        promProd.prmProd.Collection_Start_Date__c = promoDetails.Start_Date__c;
                        promProd.prmProd.Collection_End_Date__c = promoDetails.End_Date__c;
                        promProd.prmProd.TPR_Start_Date__c = promoDetails.Start_Date__c;
                        promProd.prmProd.TPR_End_Date__c = promoDetails.End_Date__c;
                    }
                    promProd.prmProd.Sort_Index__c = promProd.sortIndex;
                    system.debug('### promProd.sortIndex: '+promProd.sortIndex);
                    promProd.prmProd.TPR__c = promProd.isTPR == null ? FALSE : promProd.isTPR;
                    //adding instance to the list
                    insertablePromotionProduct.add(promProd.prmProd);
                    promoProdIdSet.add(promProd.prmProd.Id);
                }
            }
            for (Id key : mapOfExistingPromoProd.keySet()) {
                if (!promoProdIdSet.contains(key)) {
                    deletablePromotionproduct.add(mapOfExistingPromoProd.get(key));
                }
            }
            //inserting Promotion Product
            if (!insertablePromotionProduct.isEmpty()) {
                System.Debug('list size ## '+insertablePromotionProduct.size());
                if (promoDetails.RecordTypeId != FreeEpisodeRecTypeId) {
                    upsert insertablePromotionProduct;
                }
                //for Free Episode Promotion
                else {
                    if(promoDetails.Sync_Free_First_Episode_Dates__c) {
                        // if more than 1 product is selected, error is thrown
                        if(insertablePromotionProduct.size() > 1) {
                            return DGF_Constants.FREE_EPISODE_SYNC_MESSAGE;
                        }
                        else {
                            if (insertablePromotionProduct.size() == 1) {
                                upsert insertablePromotionProduct;
                                //query the fields from the inserted Promotion Product
                                Promotion_Product__c promoProd = [SELECT id, Product__r.RecordTypeId, Product__r.Digital_Release__r.RecordTypeId, Product__r.Digital_Release__r.Free_First_Episode_End_Date__c,
                                                                  Product__r.Digital_Release__r.Free_First_Episode_Start_Date__c FROM Promotion_Product__c where id=:insertablePromotionProduct[0].id];
                                //sync the Promotion Start and End Dates
                                if (promoProd.product__r.RecordTypeId == TVProdRecTypeId && promoProd.Product__r.Digital_Release__r.RecordTypeId == TVRelRecTypeId) {
                                    promoDetails.Start_Date__c = promoProd.Product__r.Digital_Release__r.Free_First_Episode_Start_Date__c;
                                    promoDetails.End_Date__c = promoProd.Product__r.Digital_Release__r.Free_First_Episode_End_Date__c;
                                    update promoDetails;
                                    
                                }
                                
                            }
                        }
                    }
                    else {
                        upsert insertablePromotionProduct;
                    }
                }
            }
            //deleting Promotion Product
            if(!deletablePromotionproduct.isEmpty()) {
                for (Promotion_Product__c pro : deletablePromotionproduct ) {
                    promotionSetId.add(pro.Promotion__c != null ? pro.Promotion__c : '');
                    productSetId.add(pro.Product__c != null ? pro.Product__c : '');
                }
                 toDeletePricing = [SELECT Id , Name, Product__c, Promotion__c From Pricing__c WHERE Product__c IN : productSetId 
                                       AND Promotion__c IN : promotionSetId ];
                // deleting the Pricing Record when Promotion Product is Deleted. 
                if (!toDeletePricing.isEmpty()) {
                    delete toDeletePricing;
                }
                
                delete deletablePromotionproduct;
            }
            
            //returning ID
            return promotionID;
        }
        catch (exception ex) {
            throw new AuraHandledException(ex.getMessage());
            return null;
        }
    }
    
    //wrapper class for Promotion Product mapping 
    public static Integer idx = 0;
    public class PromotionProductWrapper {
        
        @AuraEnabled public boolean isTPR {get;set;}
        @AuraEnabled public ID productID {get;set;}
        @AuraEnabled public string productName {get;set;}
        @AuraEnabled public ID recordtypeID {get;set;}
        @AuraEnabled public Promotion_Product__c prmProd {get; set;}
        @AuraEnabled public Integer sortIndex{get;set;}
        
        public PromotionProductWrapper(Product__c prd, Promotion_Product__c promProd, Boolean tpr) {
            idx = promProd == null? ++idx : (Integer)promProd.Sort_Index__c;
            system.debug('### idx: '+idx);
            system.debug('### promProd: '+promProd);
            if (prd !=null && promProd == null) {
                this.prmProd = null;
                isTPR = tpr;
                productID = prd.ID;
                productName = prd.Name;
                recordtypeID = prd.RecordTypeId;
                sortIndex = idx;
            } else if (prd == null && promProd != null) {
                this.prmProd = promProd;
                isTPR = promProd.Tpr__c;
                productID = promProd.Product__c;
                productName = promProd.Product__r.Name;
                recordtypeID = promProd.Product__r.RecordTypeId;
                sortIndex = (Integer)promProd.Sort_Index__c;
            }
        } 
    }    
}