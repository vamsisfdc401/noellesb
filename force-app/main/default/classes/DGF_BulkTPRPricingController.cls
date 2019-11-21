/*****************************************************************************************
Class Name: DGF_BulkTPRPricingController
Purpose: Controller for Bulk TPR Pricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/06/2017           Prarthana                Initial Development
1.1             11/09/2017           Prarthana               DFOR-1012 and DFOR-1018
******************************************************************************************/
public with sharing class DGF_BulkTPRPricingController {
    /***********************************
    Method Name: fetchRelatedRecords
    Purpose: method to fetch related records
    ***********************************/    
    @AuraEnabled public static List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper> fetchProducts(ID promoId){
        try{
            List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper> lstProductPricingDetails = new List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>();            
            set<Id>prodIDSet=new set<Id>();
            list<Product__C> productList = new List<Product__c>();
            Map<Id,Promotion_Product__c> mapPromotionProduct = new Map<Id,Promotion_Product__c>();
            Map<Id,Promotion_Product__c> mapPromoProds;
            Map<Id,Product__c> mapProds;
            //list of promotion products
            List<Promotion_Product__c> lstProductDetails = [SELECT ID, Promotion__r.RecordTypeId, Collection_End_Date__c, Collection_Start_Date__c,
                                                            Product__c, Promotion__c, Name, TPR__c, TPR_End_Date__c, TPR_Start_Date__c 
                                                            from Promotion_Product__c where Promotion__c=:promoId and TPR__c=true ORDER BY Sort_Index__c ASC];
            mapPromoProds = new Map<Id,Promotion_Product__c>(lstProductDetails);
            if(!lstProductDetails.isEmpty()){
                //creating a set of product ids
                for(Promotion_Product__c pr:lstProductDetails) {
                    prodIdSet.add(pr.Product__c);
                    
                    //map of promotion products
                    if(!mapPromotionProduct.containsKey(pr.Product__c)){
                        mapPromotionProduct.put(pr.Product__c,pr);
                    }    
                }
                //query for the products and the pricing records
                productList=[SELECT ID, Name, US_Platform_offering__c, CA_Platform_offering__c, SD__c, HD__C, UHD__c, X3D__c,RecordTypeId, 
                             (Select id, Promotion__c, Account__c, Category__c, iTunes_Tier__c, Margin__c, Platform__c, Price_Type__c, 
                              Product__c, Resolution__c, SRP__c, Territory__c, Valid_From__c, Valid_To__c, WSP__c from Pricing__r where 
                              Account__C != :DGF_Constants.iTUNES  order by Valid_from__c )from product__c where id in:prodIdSet order by name]; //DFOR-1506
                mapProds = new Map<Id,Product__c>(productList);
            }
           
            //if list not empty
            if(!productList.isEmpty()) {
              
                //looping over promotion products
                for(Promotion_Product__c promProd:lstProductDetails) {  
                  
                    DGF_BulkTPRPricingWrapper.ProductPricingWrapper pw = new DGF_BulkTPRPricingWrapper.ProductPricingWrapper();
                    Promotion_Product__c promotionProd = promProd;
                    Product__c prod = mapProds.get(promotionProd.Product__c);
                    /*if(mapPromotionProduct.containsKey(prod.Id) && mapPromotionProduct.get(prod.Id) != null){
                        promotionProd = mapPromotionProduct.get(prod.Id);
                    }*/
                    //set values of the wrapper
                    pw.promoId = promotionProd.Promotion__c;
                    pw.id = promotionProd.id;
                    pw.stDate = promotionProd.TPR_Start_Date__c;
                    pw.endDate = promotionProd.TPR_End_Date__c;
                    pw.productName = prod.name;
                    pw.productId = promotionProd.Product__c;
                    pw.productRecTypeID = prod.RecordTypeID; //DFOR-1506
                    pw.prdUSPlatform = prod.US_Platform_Offering__c;
                    pw.prdCAPlatform = prod.CA_Platform_Offering__c;
                    pw.prdSD = prod.SD__c;
                    pw.prdHD = prod.HD__c;
                    pw.prdUHD = prod.UHD__c;
                    pw.prd3D = prod.X3D__c;
                    //iterate over the pricing
                    for(Pricing__c pr:prod.pricing__r) {
                        //set the WSP Values of the Original/Reprice records to the wrapper variables
                        if((pr.price_type__c == DGF_Constants.ORIGINAL || pr.price_type__c == DGF_Constants.REPRICE) ) {
                            //for resolution SD
                            if(pr.Resolution__c == DGF_Constants.SD   &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                    
                                        pw.usESTSDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usESTSDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caESTSDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caESTSDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                    
                                        pw.usVODSDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usVODSDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caVODSDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caVODSDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                            }
                            
                            //for resolution HD
                            else if(pr.Resolution__c == DGF_Constants.HD    &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >=            promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US && pr.Account__c == null) {
                                        if(pr.WSP__c != null) {
                                            pw.usESTHDWSP = String.valueOf((pr.WSP__c).setScale(2));
                                        }
                                        pw.usESTHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caESTHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                    }
                                    pw.caESTHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                    
                                        pw.usVODHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usVODHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caVODHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caVODHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                            }
                            // for UHD
                            else if(pr.Resolution__c == DGF_Constants.UHD  &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                        pw.usESTUHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usESTUHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caESTUHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caESTUHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                    
                                        pw.usVODUHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usVODUHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caVODUHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caVODUHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                            }
                            // for 3D
                            else if(pr.Resolution__c == DGF_Constants.X3D  &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                        pw.usEST3DWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usEST3DSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caEST3DWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caEST3DSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.territory__c == DGF_Constants.TERRITORY_US  && pr.Account__c == null) {
                                    
                                        pw.usVOD3DWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.usVOD3DSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    
                                    }
                                    else if(pr.territory__c == DGF_Constants.TERRITORY_CA  && pr.Account__c == null) {
                                        pw.caVOD3DWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): NULL;
                                        pw.caVOD3DSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): NULL;
                                    }
                                }
                            }
                        }
                        //for TPR Prices, if TPR PRicing exists then populate the id of the pricing record in the wrapper
                        else if((pr.price_type__c == DGF_Constants.TPR_National || pr.price_type__c == DGF_Constants.TPR_Account) && 
                                pr.promotion__c == promotionProd.Promotion__c) {
                                pw.hasTPRPrices = 1;
                            if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.resolution__c == DGF_Constants.SD) {
                                        pw.usESTSDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.HD) {
                                        pw.usESTHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.UHD) {
                                        pw.usESTUHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.X3D) {
                                        pw.usEST3DID = pr.id;
                                    }
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.resolution__c == DGF_Constants.SD) {
                                        pw.usVODSDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.HD) {
                                        pw.usVODHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.UHD) {
                                        pw.usVODUHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.X3D) {
                                        pw.usVOD3DID = pr.id;
                                    }
                                }
                            }
                            else if(pr.territory__c == DGF_Constants.TERRITORY_CA) {
                                if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                                    if(pr.resolution__c == DGF_Constants.SD) {
                                        pw.caESTSDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.HD) {
                                        pw.caESTHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.UHD) {
                                        pw.caESTUHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.X3D) {
                                        pw.caEST3DID = pr.id;
                                    }
                                }
                                else if(pr.platform__c == DGF_Constants.PLATFORM_VOD) {
                                    if(pr.resolution__c == DGF_Constants.SD) {
                                        pw.caVODSDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.HD) {
                                        pw.caVODHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.UHD) {
                                        pw.caVODUHDID = pr.id;
                                    }
                                    else if(pr.resolution__c == DGF_Constants.X3D) {
                                        pw.caVOD3DID = pr.id;
                                    }
                                }
                            }
                        } 
                    }
                    //add the wrapper instance to a list
                    lstProductPricingDetails.add(pw);
                }
                
            }
            return lstProductPricingDetails;
        }
        catch(exception ex){ 
            throw new AuraHandledException(ex.getMessage());
            return null;        
        }        
    }
    
    /***********************************
    Method Name: createTPRWrapper
    Purpose: method to create TPRWrapper to enter the TPR Prices
    ***********************************/   
    @AuraEnabled public static DGF_BulkTPRPricingWrapper.TPRPricingWrapper createTPRWrapper(String tprWrp, String recordID) {
        if(tprWrp != null || tprWrp != '') {
            List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper> tprWrapperList = (List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>)System.JSON.deserialize(tprWrp,List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>.class);
            set<String>tprPriceSet = new set<String>();
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper tprWr = new DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
            set<String>newSet = new set<String>();            
            
            Promotion__c promo = [SELECT Id, Territory__c from Promotion__c where id=: recordID];
        
            //prepare a set of selected TPR Prices
            if(!tprWrapperList.isEmpty()) {
                for(DGF_BulkTPRPricingWrapper.TPRPricingWrapper tpr:tprWrapperList) {
                    tprPriceSet.add(tpr.selectedPriceType);
                }
            }
            //add all price type values to another set
            newSet.addAll(tprWr.priceType);  
            
            if((promo.Territory__c!=null && promo.Territory__c.length()>0)){
                List<string> territoryList = promo.Territory__c.split(';');
                if(territoryList!=null && territoryList.size()<2){
                    //filter Set                    
                    filterOptions(newSet, territoryList);
                }
            }else{
                filterOptions(newSet, null);
            }
            
            //if Price Type is already selected then remove it from the new wrapper instance being created
            if(!tprPriceSet.isEmpty()) {
                for(String s:tprPriceSet) {
                    newSet.remove(s);
                }
            }
            tprWr.priceType.clear();
            tprWr.priceType.addAll(newSet);
            return tprWr;
        }
        else {
            
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper tprWr = new DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
            return tprWr;
        }
        return null;
    }
    
    /***********************************
    Method Name: createTPRWrapper
    Purpose: method to create TPRWrapper to enter the TPR Prices
    ***********************************/   
    @AuraEnabled public static List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper> createTPRWrapperOnInit(String recordID) {
        
        List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper> tprWr = new List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>();
        DGF_BulkTPRPricingWrapper.TPRPricingWrapper tempTPR = new DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
        set<String>newSet = new set<String>();
        set<String> tprPriceSet = new set<String>();
        Promotion__c promo = [SELECT Id, Territory__c from Promotion__c where id=: recordID];
        
        newSet.addAll(tempTPR.priceType);  
        
        tprPriceSet.add('US EST SD WSP TPR');
        tprPriceSet.add('US EST SD SRP TPR'); 
        tprPriceSet.add('US EST HD WSP TPR');
        tprPriceSet.add('US EST HD SRP TPR');
        tprPriceSet.add('US EST UHD WSP TPR');
        tprPriceSet.add('US EST UHD SRP TPR');
        tprPriceSet.add('CA EST SD WSP TPR');
        tprPriceSet.add('CA EST SD SRP TPR');
        tprPriceSet.add('CA EST HD WSP TPR');
        tprPriceSet.add('CA EST HD SRP TPR');
        tprPriceSet.add('CA EST UHD WSP TPR');
        tprPriceSet.add('CA EST UHD SRP TPR');
        
        if((promo.Territory__c!=null && promo.Territory__c.length()>0)){
            List<string> territoryList = promo.Territory__c.split(';');         
            
            if(territoryList!=null && territoryList.size()<2){
                //filter Set
                filterOptions(tprPriceSet, territoryList);
                filterOptions(newSet, territoryList);
            }
        }else{
            filterOptions(tprPriceSet, null);
            filterOptions(newSet, null);
        }
        
        for(String s : tprPriceSet) {
            integer count = 0;
            newSet.remove(s);
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper obj = new DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
            obj.selectedPriceType = s;
            tprWr.add(obj); 
        }
        
        if(tprWr != null) {
            For(DGF_BulkTPRPricingWrapper.TPRPricingWrapper temp : tprWr) {
                temp.priceType.clear();
                temp.priceType.add(temp.selectedPriceType); 
                temp.priceType.addAll(newSet);      
            }
        }
        
        return tprWr;        
    }
    
    /***********************************
    Method Name: filterOptions
    Purpose: method to filter from Terriroty selection 
            on Promotion
    ***********************************/    
    public static void filterOptions(set<string> targetSet, List<string> territoryList){
        set<string> removeset = new set<string>(); 
        set<string> excludeTerritory = new set<string>{'US','CA'};  
        if(territoryList!=null)excludeTerritory.removeAll(territoryList); 
        
        for(String s : targetSet) {
            for(string territory : excludeTerritory){
                if(s.containsIgnoreCase(territory)){
                    removeset.add(s);
                }
            }
                    
        }
        if(removeset!=null && removeset.size()>0){
            targetSet.removeall(removeset);
        }
    }
    
    /***********************************
    Method Name: fetchPromoTerritories
    Purpose: method to get recordType of Promotion
    ***********************************/
    @AuraEnabled public static String fetchPromoTerritories(String recordID) {
        
        Promotion__c promo = [SELECT Id, Territory__c from Promotion__c where id=:recordID];
        return promo.Territory__c;
    }
    
    /***********************************
    Method Name: saveAndContinueTPR
    Purpose: method invoked when Save and Continue button is clicked
    ***********************************/
    @AuraEnabled public static list<DGF_BulkTPRPricingWrapper.ProductPricingWrapper> saveAndContinueTPR(String prodJson,String tprJson,String recordTypeName,Boolean defaultingFlag, String promoTerr) { //DFOR-1504
        //call the saveTPR method
        String promoId = saveTPRPricing(prodJson,tprJson,recordTypeName,defaultingFlag, promoTerr);
        list<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>prodWrapperList = new list<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>(); 
        if(!promoId.contains('The TPR Price entered is greater than the everyday Price')) {
            //fetch the products once again after the TPR Prices are saved
            prodWrapperList = fetchProducts(promoId);
        }
        else {
            DGF_BulkTPRPricingWrapper.ProductPricingWrapper pw = new DGF_BulkTPRPricingWrapper.ProductPricingWrapper ();
            pw.msg = promoId;
            prodWrapperList.add(pw);
            
        }
            return prodWrapperList;
    }
    
    /***********************************
    Method Name: saveTPRPricing
    Purpose: method to save TPR Pricing
    ***********************************/
    @AuraEnabled public static String saveTPRPricing(String prodJson,String tprJson,String recordTypeName,Boolean defaultingFlag, String promoTerr) {
        try{
            DGF_TriggerUtility.dontDefaultTPRPrices=defaultingFlag;
            ID TVRecordTypeId = Schema.Sobjecttype.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId(); //DFOR-1506
            //deserialize the Json strings
            List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper> prodWrapperList = (List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>)System.JSON.deserialize(prodJson,List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>.class);
            List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper> tprWrapperList = (List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>)System.JSON.deserialize(tprJson,List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>.class);
            Map <Id,String> productNameMap = new Map<Id,String>();
            map<String,String>tprMap=new map<String,String>();            
            
            //prepare a map of the selected TPR Price type and the value entered            
            list<Pricing__c>insertList = new list<Pricing__c>();
            list<Pricing__c>updateList = new list<Pricing__c>();
            list<Pricing__c>iTunesUpdateList = new list<Pricing__c>();
            set<String>priceIdSet = new set<String>();
            String retVal = '';
            
            boolean tprAccount = false; //DFOR - 1431
            if(recordTypeName == DGF_Constants.ACCOUNT_PROMOTION) {
                tprAccount = true;
            }
            
            for(DGF_BulkTPRPricingWrapper.TPRPricingWrapper wrp:tprWrapperList) {
                if(wrp.priceval == ''){
                    tprMap.put(wrp.selectedPriceType,null);
                }
                else {
                    tprMap.put(wrp.selectedPriceType,wrp.priceVal);
                }                
            }
            
            for(DGF_BulkTPRPricingWrapper.ProductPricingWrapper pw:prodWrapperList) {
                retVal = pw.promoId;
                priceIdSet.add(pw.usESTSDID);
                priceIdSet.add(pw.usESTHDID);
                priceIdSet.add(pw.usESTUHDID);
                priceIdSet.add(pw.usEST3DID);
                priceIdSet.add(pw.usVODSDID);
                priceIdSet.add(pw.usVODHDID);
                priceIdSet.add(pw.usVODUHDID);
                priceIdSet.add(pw.usVOD3DID);
                priceIdSet.add(pw.caESTSDID);
                priceIdSet.add(pw.caESTHDID);
                priceIdSet.add(pw.caESTUHDID);
                priceIdSet.add(pw.caEST3DID);
                priceIdSet.add(pw.caVODSDID);
                priceIdSet.add(pw.caVODHDID);
                priceIdSet.add(pw.caVODUHDID);
                priceIdSet.add(pw.caVOD3DID);
            }
            priceIdSet.remove(null);
            list<Pricing__c>pricingList = [SELECT ID, WSP__c, SRP__c from Pricing__c where id in:priceIdSet];
            map <Id,Pricing__c> priceMap = new map<Id,Pricing__c>();
            for(Pricing__c p:pricingList) {
                priceMap.put(p.id,p);
            }
            if(!tprMap.isEmpty()) {
                for(DGF_BulkTPRPricingWrapper.ProductPricingWrapper pr:prodWrapperList) {
                    pr.promoTerr = promoTerr; //DFOR-1504
                    if(pr.prdUSPlatform != null) {
                        if(((tprMap.containsKey('US EST SD WSP TPR') && tprMap.get('US EST SD WSP TPR') != null) || 
                           (tprMap.containsKey('US EST SD SRP TPR')) && tprMap.get('US EST SD SRP TPR') != null) && 
                           pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdSD) {
                            if(((tprMap.containsKey('US EST SD WSP TPR') && tprMap.get('US EST SD WSP TPR') != null && 
                            pr.usESTSDWSP !=null && Decimal.valueOf(tprMap.get('US EST SD WSP TPR')) > Decimal.valueOf(pr.usESTSDWSP)) || 
                            (tprMap.containsKey('US EST SD SRP TPR') && tprMap.get('US EST SD SRP TPR') != null && pr.usESTSDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US EST SD SRP TPR')) > Decimal.valueOf(pr.usESTSDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            //create new TPR US SD Pricing record    
                            if(pr.usESTSDID==null) {
                                Pricing__c price=new Pricing__c(Territory__c= DGF_Constants.TERRITORY_US , Platform__c = DGF_Constants.PLATFORM_EST ,Resolution__c = DGF_Constants.SD,Valid_from__c = pr.stDate,
                                                                Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US EST SD WSP TPR') && tprMap.get('US EST SD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US EST SD WSP TPR'));
                                    
                                }
                                if(tprMap.containsKey('US EST SD SRP TPR') && tprMap.get('US EST SD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US EST SD SRP TPR'));
                                    
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504 //DFOR-1506
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            //update existing TPR US SD Pricing record
                            else {
                                if(priceMap.containsKey(pr.usESTSDID)) {
                                    Pricing__c price = priceMap.get(pr.usESTSDID);
                                    if(tprMap.containsKey('US EST SD WSP TPR') && tprMap.get('US EST SD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US EST SD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US EST SD SRP TPR') && tprMap.get('US EST SD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US EST SD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                         if(((tprMap.containsKey('US EST HD WSP TPR') && tprMap.get('US EST HD WSP TPR') != null) || 
                            (tprMap.containsKey('US EST HD SRP TPR') && tprMap.get('US EST HD SRP TPR') != null)) && 
                            pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdHD) {
                                
                                if(((tprMap.containsKey('US EST HD WSP TPR') && tprMap.get('US EST HD WSP TPR') != null  &&
                            pr.usESTHDWSP !=null && Decimal.valueOf(tprMap.get('US EST HD WSP TPR')) > Decimal.valueOf(pr.usESTHDWSP)) || 
                            (tprMap.containsKey('US EST HD SRP TPR') && tprMap.get('US EST HD SRP TPR') != null  && pr.usESTHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US EST HD SRP TPR')) > Decimal.valueOf(pr.usESTHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            //create new TPR US HD Pricing record   
                            if(pr.usESTHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_EST ,Resolution__c = DGF_Constants.HD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US EST HD WSP TPR') && tprMap.get('US EST HD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US EST HD WSP TPR'));
                                }
                                if(tprMap.containsKey('US EST HD SRP TPR') && tprMap.get('US EST HD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US EST HD SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            //update existing TPR US HD Pricing record  
                            else {
                                if(priceMap.containsKey(pr.usESTHDID)) {
                                    Pricing__c price = priceMap.get(pr.usESTHDID);
                                    if(tprMap.containsKey('US EST HD WSP TPR') && tprMap.get('US EST HD WSP TPR') != null) {
                                        price.WSP__c=Decimal.valueOf(tprMap.get('US EST HD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US EST HD SRP TPR') && tprMap.get('US EST HD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US EST HD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                         if(((tprMap.containsKey('US EST UHD WSP TPR') && tprMap.get('US EST UHD WSP TPR') != null) || 
                            (tprMap.containsKey('US EST UHD SRP TPR') && tprMap.get('US EST UHD SRP TPR') != null)) && 
                            pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdUHD) {
                                if(((tprMap.containsKey('US EST UHD WSP TPR') && tprMap.get('US EST UHD WSP TPR') != null && 
                            pr.usESTUHDWSP !=null && Decimal.valueOf(tprMap.get('US EST UHD WSP TPR')) > Decimal.valueOf(pr.usESTUHDWSP)) || 
                            (tprMap.containsKey('US EST UHD SRP TPR') && tprMap.get('US EST UHD SRP TPR') != null && pr.usESTUHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US EST UHD SRP TPR')) > Decimal.valueOf(pr.usESTUHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            //create new TPR US UHD Pricing record  
                            if(pr.usESTUHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_EST ,Resolution__c = DGF_Constants.UHD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US EST UHD WSP TPR') && tprMap.get('US EST UHD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US EST UHD WSP TPR'));
                                }
                                if(tprMap.containsKey('US EST UHD SRP TPR') && tprMap.get('US EST UHD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US EST UHD SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            //update existing TPR US UHD Pricing record 
                            else {
                                if(priceMap.containsKey(pr.usESTUHDID)) {
                                    Pricing__c price = priceMap.get(pr.usESTUHDID);
                                    if(tprMap.containsKey('US EST UHD WSP TPR') && tprMap.get('US EST UHD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US EST UHD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US EST UHD SRP TPR') && tprMap.get('US EST UHD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US EST UHD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                         if(((tprMap.containsKey('US EST 3D WSP TPR') && tprMap.get('US EST 3D WSP TPR') != null) || 
                            (tprMap.containsKey('US EST 3D SRP TPR') && tprMap.get('US EST 3D SRP TPR') != null)) && 
                            pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prd3D) {
                                if(((tprMap.containsKey('US EST 3D WSP TPR') && tprMap.get('US EST 3D WSP TPR') != null && 
                            pr.usEST3DWSP !=null && Decimal.valueOf(tprMap.get('US EST 3D WSP TPR')) > Decimal.valueOf(pr.usEST3DWSP)) || 
                            (tprMap.containsKey('US EST 3D SRP TPR') && tprMap.get('US EST 3D SRP TPR') != null && pr.usEST3DSRP !=null &&
                            Decimal.valueOf(tprMap.get('US EST 3D SRP TPR')) > Decimal.valueOf(pr.usEST3DSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            //create new TPR US 3D Pricing record   
                            if(pr.usEST3DID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_EST,Resolution__c = DGF_Constants.X3D,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US EST 3D WSP TPR') && tprMap.get('US EST 3D WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US EST 3D WSP TPR'));
                                }
                                if(tprMap.containsKey('US EST 3D SRP TPR') && tprMap.get('US EST 3D SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US EST 3D SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            //update existing TPR US 3D Pricing record  
                            else {
                                if(priceMap.containsKey(pr.usEST3DID)) {
                                    Pricing__c price = priceMap.get(pr.usEST3DID);
                                    if(tprMap.containsKey('US EST 3D WSP TPR') && tprMap.get('US EST 3D WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US EST 3D WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US EST 3D SRP TPR') && tprMap.get('US EST 3D SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US EST 3D SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                    }
                    //creation/updation of CA TPR Pricing records
                    if(pr.prdCAPlatform!=null) {
                        if(((tprMap.containsKey('CA EST SD WSP TPR') && tprMap.GET('CA EST SD WSP TPR') != null) || 
                           (tprMap.containsKey('CA EST SD SRP TPR') && tprMap.get('CA EST SD SRP TPR') != null)) && 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdSD) {
                               if(((tprMap.containsKey('CA EST SD WSP TPR') && tprMap.get('CA EST SD WSP TPR') != null && 
                            pr.caESTSDWSP !=null && Decimal.valueOf(tprMap.get('CA EST SD WSP TPR')) > Decimal.valueOf(pr.caESTSDWSP)) || 
                            (tprMap.containsKey('CA EST SD SRP TPR') && tprMap.get('CA EST SD SRP TPR') != null && pr.caESTSDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA EST SD SRP TPR')) > Decimal.valueOf(pr.caESTSDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caESTSDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_EST,Resolution__c = DGF_Constants.SD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA EST SD WSP TPR') && tprMap.get('CA EST SD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA EST SD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA EST SD SRP TPR') && tprMap.get('CA EST SD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA EST SD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caESTSDID)) {
                                    Pricing__c price = priceMap.get(pr.caESTSDID);
                                    if(tprMap.containsKey('CA EST SD WSP TPR') && tprMap.get('CA EST SD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA EST SD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA EST SD SRP TPR') && tprMap.get('CA EST SD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA EST SD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        if(((tprMap.containsKey('CA EST HD WSP TPR') && tprMap.GET('CA EST HD WSP TPR') != null) || 
                           (tprMap.containsKey('CA EST HD SRP TPR') && tprMap.get('CA EST HD SRP TPR') != null)) && 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdHD) {
                                if(((tprMap.containsKey('CA EST HD WSP TPR') && tprMap.get('CA EST HD WSP TPR') != null && 
                            pr.caESTHDWSP !=null && Decimal.valueOf(tprMap.get('CA EST HD WSP TPR')) > Decimal.valueOf(pr.caESTHDWSP)) || 
                            (tprMap.containsKey('CA EST HD SRP TPR') && tprMap.get('CA EST HD SRP TPR') != null && pr.caESTHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA EST HD SRP TPR')) > Decimal.valueOf(pr.caESTHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caESTHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_EST,Resolution__c = DGF_Constants.HD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA EST HD WSP TPR') && tprMap.get('CA EST HD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA EST HD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA EST HD SRP TPR') && tprMap.get('CA EST HD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA EST HD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caESTHDID)) {
                                    Pricing__c price = priceMap.get(pr.caESTHDID);
                                    if(tprMap.containsKey('CA EST HD WSP TPR') && tprMap.get('CA EST HD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA EST HD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA EST HD SRP TPR') && tprMap.get('CA EST HD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA EST HD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                       if(((tprMap.containsKey('CA EST UHD WSP TPR') && tprMap.GET('CA EST UHD WSP TPR') != null) || 
                          (tprMap.containsKey('CA EST UHD SRP TPR') && tprMap.get('CA EST UHD SRP TPR') != null)) && 
                          pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prdUHD) {
                               if(((tprMap.containsKey('CA EST UHD WSP TPR') && tprMap.get('CA EST UHD WSP TPR') != null && 
                            pr.caESTUHDWSP !=null && Decimal.valueOf(tprMap.get('CA EST UHD WSP TPR')) > Decimal.valueOf(pr.caESTUHDWSP)) || 
                            (tprMap.containsKey('CA EST UHD SRP TPR') && tprMap.get('CA EST UHD SRP TPR') != null && pr.caESTUHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA EST UHD SRP TPR')) > Decimal.valueOf(pr.caESTUHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caESTUHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_EST ,Resolution__c = DGF_Constants.UHD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA EST UHD WSP TPR') && tprMap.get('CA EST UHD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA EST UHD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA EST UHD SRP TPR') && tprMap.get('CA EST UHD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA EST UHD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caESTUHDID)) {
                                    Pricing__c price = priceMap.get(pr.caESTUHDID);
                                    if(tprMap.containsKey('CA EST UHD WSP TPR') && tprMap.get('CA EST UHD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA EST UHD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA EST UHD SRP TPR') && tprMap.get('CA EST UHD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA EST UHD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                        if(((tprMap.containsKey('CA EST 3D WSP TPR') && tprMap.GET('CA EST 3D WSP TPR') != null) || 
                           (tprMap.containsKey('CA EST 3D SRP TPR') && tprMap.get('CA EST 3D SRP TPR') != null)) && 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_EST) && pr.prd3D) {
                               if(((tprMap.containsKey('CA EST 3D WSP TPR') && tprMap.get('CA EST 3D WSP TPR') != null && 
                            pr.caEST3DWSP !=null && Decimal.valueOf(tprMap.get('CA EST 3D WSP TPR')) > Decimal.valueOf(pr.caEST3DWSP)) || 
                            (tprMap.containsKey('CA EST 3D SRP TPR') && tprMap.get('CA EST 3D SRP TPR') != null && pr.caEST3DSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA EST 3D SRP TPR')) > Decimal.valueOf(pr.caEST3DSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caEST3DID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_EST ,Resolution__c = DGF_Constants.X3D,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA EST 3D WSP TPR') && tprMap.get('CA EST 3D WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA EST 3D WSP TPR'));
                                }
                                if(tprMap.containsKey('CA EST 3D SRP TPR') && tprMap.get('CA EST 3D SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA EST 3D SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caEST3DID)) {
                                    Pricing__c price = priceMap.get(pr.caEST3DID);
                                    if(tprMap.containsKey('CA EST 3D WSP TPR') && tprMap.get('CA EST 3D WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA EST 3D WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA EST 3D SRP TPR') && tprMap.get('CA EST 3D SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA EST 3D SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                    }
                    if(pr.prdUSPlatform!=null) {
                        //creation/updation of US VOD TPR Prices
                        if(((tprMap.containsKey('US VOD SD WSP TPR') && tprMap.get('US VOD SD WSP TPR') != null) || 
                           (tprMap.containsKey('US VOD SD SRP TPR') && tprMap.get('US VOD SD SRP TPR') != null)) && 
                           pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdSD) {
                               if(((tprMap.containsKey('US VOD SD WSP TPR') && tprMap.get('US VOD SD WSP TPR') != null && 
                            pr.usVODSDWSP !=null && Decimal.valueOf(tprMap.get('US VOD SD WSP TPR')) > Decimal.valueOf(pr.usVODSDWSP)) || 
                            (tprMap.containsKey('US VOD SD SRP TPR') && tprMap.get('US VOD SD SRP TPR') != null && pr.usVODSDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US VOD SD SRP TPR')) > Decimal.valueOf(pr.usVODSDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                               if(pr.usVODSDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.SD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US VOD SD WSP TPR') && tprMap.get('US VOD SD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US VOD SD WSP TPR'));
                                }
                                if(tprMap.containsKey('US VOD SD SRP TPR') && tprMap.get('US VOD SD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US VOD SD SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.usVODSDID)) {
                                    Pricing__c price = priceMap.get(pr.usVODSDID);
                                    if(tprMap.containsKey('US VOD SD WSP TPR') && tprMap.get('US VOD SD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US VOD SD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US VOD SD SRP TPR') && tprMap.get('US VOD SD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US VOD SD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                         if(((tprMap.containsKey('US VOD HD WSP TPR') && tprMap.get('US VOD HD WSP TPR') != null) || 
                            (tprMap.containsKey('US VOD HD SRP TPR') && tprMap.get('US VOD HD SRP TPR') != null)) && 
                            pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdHD) {
                                 if(((tprMap.containsKey('US VOD HD WSP TPR') && tprMap.get('US VOD HD WSP TPR') != null && 
                            pr.usVODHDWSP !=null && Decimal.valueOf(tprMap.get('US VOD HD WSP TPR')) > Decimal.valueOf(pr.usVODHDWSP)) || 
                            (tprMap.containsKey('US VOD HD SRP TPR') && tprMap.get('US VOD HD SRP TPR') != null && pr.usVODHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US VOD HD SRP TPR')) > Decimal.valueOf(pr.usVODHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.usVODHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_VOD ,Resolution__c = DGF_Constants.HD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US VOD HD WSP TPR') && tprMap.get('US VOD HD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US VOD HD WSP TPR'));
                                }
                                if(tprMap.containsKey('US VOD HD SRP TPR') && tprMap.get('US VOD HD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US VOD HD SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.usVODHDID)) {
                                    Pricing__c price = priceMap.get(pr.usVODHDID);
                                    if(tprMap.containsKey('US VOD HD WSP TPR') && tprMap.get('US VOD HD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US VOD HD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US VOD HD SRP TPR') && tprMap.get('US VOD HD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US VOD HD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                         if(((tprMap.containsKey('US VOD UHD WSP TPR') && tprMap.get('US VOD UHD WSP TPR') != null) || 
                            (tprMap.containsKey('US VOD UHD SRP TPR') && tprMap.get('US VOD UHD SRP TPR') != null)) && 
                            pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdUHD) {
                                 if(((tprMap.containsKey('US VOD UHD WSP TPR') && tprMap.get('US VOD UHD WSP TPR') != null && 
                            pr.usVODUHDWSP !=null && Decimal.valueOf(tprMap.get('US VOD UHD WSP TPR')) > Decimal.valueOf(pr.usVODUHDWSP)) || 
                            (tprMap.containsKey('US VOD UHD SRP TPR') && tprMap.get('US VOD UHD SRP TPR') != null && pr.usVODUHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('US VOD UHD SRP TPR')) > Decimal.valueOf(pr.usVODUHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.usVODUHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_VOD ,Resolution__c = DGF_Constants.UHD,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US VOD UHD WSP TPR') && tprMap.get('US VOD UHD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US VOD UHD WSP TPR'));
                                }
                                if(tprMap.containsKey('US VOD UHD SRP TPR') && tprMap.get('US VOD UHD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US VOD UHD SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.usVODUHDID)) {
                                    Pricing__c price = priceMap.get(pr.usVODUHDID);
                                    if(tprMap.containsKey('US VOD UHD WSP TPR') && tprMap.get('US VOD UHD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US VOD UHD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US VOD UHD SRP TPR') && tprMap.get('US VOD UHD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US VOD UHD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                        if(((tprMap.containsKey('US VOD 3D WSP TPR') && tprMap.get('US VOD 3D WSP TPR') != null) || 
                           (tprMap.containsKey('US VOD 3D SRP TPR') && tprMap.get('US VOD 3D SRP TPR') != null)) && 
                           pr.prdUSPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prd3D) {
                                if(((tprMap.containsKey('US VOD 3D WSP TPR') && tprMap.get('US VOD 3D WSP TPR') != null && 
                            pr.usVOD3DWSP !=null && Decimal.valueOf(tprMap.get('US VOD 3D WSP TPR')) > Decimal.valueOf(pr.usVOD3DWSP)) || 
                            (tprMap.containsKey('US VOD 3D SRP TPR') && tprMap.get('US VOD 3D SRP TPR') != null && pr.usVOD3DSRP !=null &&
                            Decimal.valueOf(tprMap.get('US VOD 3D SRP TPR')) > Decimal.valueOf(pr.usVOD3DSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.usVOD3DID == null){
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US ,Platform__c = DGF_Constants.PLATFORM_VOD ,Resolution__c = DGF_Constants.X3D,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('US VOD 3D WSP TPR') && tprMap.get('US VOD 3D WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('US VOD 3D WSP TPR'));
                                }
                                if(tprMap.containsKey('US VOD 3D SRP TPR') && tprMap.get('US VOD 3D SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('US VOD 3D SRP TPR'));
                                }
                                if (pr.promoTerr.split(';').size() > 1 && !tprAccount && pr.productRecTypeID == TVRecordTypeId) { //DFOR-1504
                                    Pricing__c priceCAClone = price.clone(false, false, false, false); //DFOR-1504
                                    priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1504
                                    priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                                    insertList.add(priceCAClone); //DFOR-1504
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.usVOD3DID)) {
                                    Pricing__c price = priceMap.get(pr.usVOD3DID);
                                    if(tprMap.containsKey('US VOD 3D WSP TPR') && tprMap.get('US VOD 3D WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('US VOD 3D WSP TPR'));
                                    }
                                    if(tprMap.containsKey('US VOD 3D SRP TPR') && tprMap.get('US VOD 3D SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('US VOD 3D SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                    }
                    //creation/updation of CA VOD TPR Prices
                    if(pr.prdCAPlatform!=null) {          
                        if(((tprMap.containsKey('CA VOD SD WSP TPR') && tprMap.get('CA VOD SD WSP TPR') != null) || 
                           (tprMap.containsKey('CA VOD SD SRP TPR') && tprMap.get('CA VOD SD SRP TPR') != null) )&& 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdSD) {
                               if(((tprMap.containsKey('CA VOD SD WSP TPR') && tprMap.get('CA VOD SD WSP TPR') != null && 
                            pr.caVODSDWSP !=null && Decimal.valueOf(tprMap.get('CA VOD SD WSP TPR')) > Decimal.valueOf(pr.caVODSDWSP)) || 
                            (tprMap.containsKey('CA VOD SD SRP TPR') && tprMap.get('CA VOD SD SRP TPR') != null && pr.caVODSDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA VOD SD SRP TPR')) > Decimal.valueOf(pr.caVODSDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caVODSDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.SD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA VOD SD WSP TPR') && tprMap.get('CA VOD SD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD SD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA VOD SD SRP TPR') && tprMap.get('CA VOD SD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD SD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caVODSDID)) {
                                    Pricing__c price = priceMap.get(pr.caVODSDID);
                                    if(tprMap.containsKey('CA VOD SD WSP TPR') && tprMap.get('CA VOD SD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD SD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA VOD SD SRP TPR') && tprMap.get('CA VOD SD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD SD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                       if(((tprMap.containsKey('CA VOD HD WSP TPR') && tprMap.get('CA VOD HD WSP TPR') != null) || 
                          (tprMap.containsKey('CA VOD HD SRP TPR') && tprMap.get('CA VOD HD SRP TPR') != null) )&& 
                          pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdHD) {
                               if(((tprMap.containsKey('CA VOD HD WSP TPR') && tprMap.get('CA VOD HD WSP TPR') != null && 
                            pr.caVODHDWSP !=null && Decimal.valueOf(tprMap.get('CA VOD HD WSP TPR')) > Decimal.valueOf(pr.caVODHDWSP)) || 
                            (tprMap.containsKey('CA VOD HD SRP TPR') && tprMap.get('CA VOD HD SRP TPR') != null && pr.caVODHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA VOD HD SRP TPR')) > Decimal.valueOf(pr.caVODHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caVODHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.HD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA VOD HD WSP TPR') && tprMap.get('CA VOD HD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD HD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA VOD HD SRP TPR') && tprMap.get('CA VOD HD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD HD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caVODHDID)) {
                                    Pricing__c price = priceMap.get(pr.caVODHDID);
                                    if(tprMap.containsKey('CA VOD HD WSP TPR') && tprMap.get('CA VOD HD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD HD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA VOD HD SRP TPR') && tprMap.get('CA VOD HD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD HD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                        if(((tprMap.containsKey('CA VOD UHD WSP TPR') && tprMap.get('CA VOD UHD WSP TPR') != null) || 
                           (tprMap.containsKey('CA VOD UHD SRP TPR') && tprMap.get('CA VOD UHD SRP TPR') != null)) && 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prdUHD) {
                                if(((tprMap.containsKey('CA VOD UHD WSP TPR') && tprMap.get('CA VOD UHD WSP TPR') != null && 
                            pr.caVODUHDWSP !=null && Decimal.valueOf(tprMap.get('CA VOD UHD WSP TPR')) > Decimal.valueOf(pr.caVODUHDWSP)) || 
                            (tprMap.containsKey('CA VOD UHD SRP TPR') && tprMap.get('CA VOD UHD SRP TPR') != null && pr.caVODUHDSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA VOD UHD SRP TPR')) > Decimal.valueOf(pr.caVODUHDSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caVODUHDID == null) {
                                Pricing__c price = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.UHD ,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA VOD UHD WSP TPR') && tprMap.get('CA VOD UHD WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD UHD WSP TPR'));
                                }
                                if(tprMap.containsKey('CA VOD UHD SRP TPR') && tprMap.get('CA VOD UHD SRP TPR') != null) {
                                    price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD UHD SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caVODUHDID)) {
                                    Pricing__c price = priceMap.get(pr.caVODUHDID);
                                    if(tprMap.containsKey('CA VOD UHD WSP TPR') && tprMap.get('CA VOD UHD WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD UHD WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA VOD UHD SRP TPR') && tprMap.get('CA VOD UHD SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD UHD SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                        if(((tprMap.containsKey('CA VOD 3D WSP TPR') && tprMap.get('CA VOD 3D WSP TPR') != null) || 
                           (tprMap.containsKey('CA VOD 3D SRP TPR') && tprMap.get('CA VOD 3D SRP TPR') != null)) && 
                           pr.prdCAPlatform.contains(DGF_Constants.PLATFORM_VOD) && pr.prd3D) {
                                 if(((tprMap.containsKey('CA VOD 3D WSP TPR') && tprMap.get('CA VOD 3D WSP TPR') != null && 
                            pr.caVOD3DWSP !=null && Decimal.valueOf(tprMap.get('CA VOD 3D WSP TPR')) > Decimal.valueOf(pr.caVOD3DWSP)) || 
                            (tprMap.containsKey('CA VOD 3D SRP TPR') && tprMap.get('CA VOD 3D SRP TPR') != null && pr.caVOD3DSRP !=null &&
                            Decimal.valueOf(tprMap.get('CA VOD 3D SRP TPR')) > Decimal.valueOf(pr.caVOD3DSRP))) && !tprAccount) {
                                productNameMap.put(pr.productID,pr.productName);
                            }
                            if(pr.caVOD3DID == null) {
                                Pricing__c price = new Pricing__c(Territory__c =  DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.X3D,Valid_from__c = pr.stDate,
                                                                  Valid_to__c = pr.endDate,Product__c = pr.productID,Promotion__c = pr.promoId);
                                if(tprMap.containsKey('CA VOD 3D WSP TPR') && tprMap.get('CA VOD 3D WSP TPR') != null) {
                                    price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD 3D WSP TPR'));
                                }
                                if(tprMap.containsKey('CA VOD 3D SRP TPR') && tprMap.get('CA VOD 3D SRP TPR') != null) {
                                    price.SRP__c=Decimal.valueOf(tprMap.get('CA VOD 3D SRP TPR'));
                                }
                                insertList.add(price);
                            }
                            else {
                                if(priceMap.containsKey(pr.caVOD3DID)) {
                                    Pricing__c price = priceMap.get(pr.caVOD3DID);
                                    if(tprMap.containsKey('CA VOD 3D WSP TPR') && tprMap.get('CA VOD 3D WSP TPR') != null) {
                                        price.WSP__c = Decimal.valueOf(tprMap.get('CA VOD 3D WSP TPR'));
                                    }
                                    if(tprMap.containsKey('CA VOD 3D SRP TPR') && tprMap.get('CA VOD 3D SRP TPR') != null) {
                                        price.SRP__c = Decimal.valueOf(tprMap.get('CA VOD 3D SRP TPR'));
                                    }
                                    updateList.add(price);
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            if(productNameMap.isEmpty()) {
                //update the existing TPR Records with the new WSP/SRP Values
                if(!updateList.isEmpty()) {
                    DGF_PerformDML.saveRecords(updateList,'update');
                }
                if(!insertList.isEmpty()) {
                    for(Pricing__c pr:insertList) {
                        if(recordTypeName == DGF_Constants.ACCOUNT_PROMOTION) {
                            pr.price_type__c = DGF_Constants.TPR_Account;
                        }
                        else if(recordTypeName == DGF_Constants.NATIONAL_PROMOTION) {
                            pr.price_type__c = DGF_Constants.TPR_National;
                        }
                    }
                    //INSERT the newly created TPR Prices
                    
                    //database.insert(insertList);
                    DGF_PerformDML.saveRecords(insertList,'insert');
                }
                
        }
        else { 
            retVal = 'The TPR Price entered is greater than the everyday Price for the following Products:' +'<br/>';
            for(Id prdId:productNameMap.keySet()) {
                retVal += '<li>' + productNameMap.get(prdId) + '</li>'  ;
            }
            
        }
            
            return retVal;
        }
        catch(exception ex) {
            //DFOR-1510 --- start
            if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                String formatedException = getFormattedErrorMessage(ex.getMessage());
                throw new AuraHandledException(formatedException);
                return formatedException;
            }
            else {
                throw new AuraHandledException(ex.getMessage());
                return ex.getMessage();    
            }    
            //DFOR-1510 --- end
        }        
    }
    
    /***********************************
    Method Name: fetchRecordType
    Purpose: method to get recordType of Promotion
    ***********************************/
    @AuraEnabled public static String fetchRecordType(String recordID) {
        //query for promotion record
        Promotion__c pr = [SELECT ID, RecordTypeId from Promotion__c where id=:recordID ];
        //get the recordType name
        RecordType rt = [SELECT Name, Id from RecordType where id=:pr.recordTypeId and  SObjectType='Promotion__c'];
        return rt.name;
    }
    
    /***********************************
    Method Name: getProdCount
    Purpose: method to get count of TPR Promotion Products
    ***********************************/
    @AuraEnabled public static Integer getProdCount(String recordID) {
        //get the count of TPR Products under the promotion.
        Integer cnt=[SELECT count() from Promotion_Product__c where Promotion__c=:recordID and TPR__c=true];
        return cnt;
    }
    
    /***********************************
    Method Name: getProfileDetails
    Purpose: method to get profile of logged in user
    ***********************************/
    @AuraEnabled public static boolean getProfileDetails(String recordID) {
        String rt = fetchRecordType(recordID);
        Boolean retVal;
        User u = [Select id, name, Profile.Name from User where ID=:userinfo.getUserID()];
        //get the profile details of logged in user
        if(rt == DGF_Constants.ACCOUNT_PROMOTION) {
            if(u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN || u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER)) {
                retVal = false;
            }
            else {
                retVal = true;
            }
        }
        else if(rt == DGF_Constants.NATIONAL_PROMOTION) {
            if(u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN ||   u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER )) {
                retVal = false;
            }else{
                retVal = true;
            }
        }
        return retVal;
    } 
    /*****************************************************************
     Method Name: getFormattedErrorMessage
     Purpose : Method to format validation message caused via DML operation (DFOR-1510)
     ***************************************************************/
     
    public static String getFormattedErrorMessage( String incomingMsg ) {
        String msg = incomingMsg;               
        if ( msg != null && msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
             String errorMessage = msg;
             Integer cutPoint = msg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34;
             errorMessage = msg.substring(cutPoint);
             errorMessage = String.escapeSingleQuotes(errorMessage);
             errorMessage = errorMessage.replace('&quot;','\'');
             errorMessage = errorMessage.replace('&lt;','<');
             cutPoint = errorMessage.indexOf(': [');
             if ( errorMessage.length() > cutPoint ) {
                  
                 msg = errorMessage.subString(0,cutPoint); 
                 system.debug('msg'+msg);
             }
        } 
        return msg; 
    }
  
}