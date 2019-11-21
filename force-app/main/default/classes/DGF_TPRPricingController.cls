/*****************************************************************************************
Class Name: DGF_TPRPricingController
Purpose: Controller for TPR Products along with the Pricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/06/2017           Prarthana                Initial Development
1.1             11/09/2017           Prarthana                DFOR-1018
******************************************************************************************/
public with sharing class DGF_TPRPricingController{
    
    /***********************************
    Method Name: fetchRelatedRecords
    Purpose: method to fetch related records
    ***********************************/    
    @AuraEnabled public static List<DGF_TPRPricingWrapper.ProductPricingWrapper> fetchRelatedRecords(ID recordID,String accountId) {
        try{
            map<String,Promotion_Product__c> PromotionEndDateMap=new map<String,Promotion_Product__c>();
            map<String,list<Promotion_Product__c>> PromotionAccountMap=new map<String,list<Promotion_Product__c>>();
            Map<Id,Promotion_Product__c> mapPromotionProduct = new Map<Id,Promotion_Product__c>();
            map<String,set<String>> promotionAccount=new map<String,set<String>>();
            Id NationalPromotionId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('National Promotion').getRecordTypeId();
            Id AccountPromotionId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
            set<String> ProAccountIds=new set<String>();
            list<Product__C> productList = new List<Product__c>();
            //initializing variables
            Date todaysDate = System.Today();
            List<DGF_TPRPricingWrapper.ProductPricingWrapper> lstProductPricingDetails = new List<DGF_TPRPricingWrapper.ProductPricingWrapper>();            
            set<Id>prodIDSet = new set<Id>();
            Map<Id,Product__c> mapProdsForPricing = new Map<Id,Product__c>();
            
            //getting product and pricing information
            List<Promotion_Product__c> lstProductDetails = [SELECT ID, Promotion__r.RecordTypeId, Collection_End_Date__c,
                                                            Collection_Start_Date__c, Product__c, Promotion__c, Name, TPR__c, TPR_End_Date__c, TPR_Start_Date__c,
                                                            Product__r.Name,Product__r.RecordTypeId from 
                                                            Promotion_Product__c where Promotion__c=:recordID and TPR__c = true ORDER BY Sort_Index__c ASC];
            
            if( !lstProductDetails.isEmpty() ) {
                //creating a set of product ids
                for(Promotion_Product__c pr:lstProductDetails) {
                    prodIdSet.add(pr.Product__c);
                    
                    //map of promotion products
                    if( !mapPromotionProduct.containsKey(pr.Product__c) ) {
                        mapPromotionProduct.put(pr.Product__c,pr);
                    }               
                }
				// Start NN
                Date promotionStartDate=[select id,Start_Date__c from Promotion__c where id=:recordID].Start_Date__c;
                if(accountId==null || accountId==''){
					for(Promotion_Account__c accPro:[select id,Account__c,Account__r.Territory__c,Promotion__c from Promotion_Account__c where Promotion__c=:recordID]){

						ProAccountIds.add(accPro.Account__c);
					}    
                }
                else ProAccountIds.add(accountId);
                system.debug('AccountID===='+accountId);
                set<String> promotionIds=new set<String>();
                for(Promotion_Product__c pProduct:[SELECT ID,Product__c,Promotion__c,Promotion__r.recordtypeid,TPR_End_Date__c from Promotion_Product__c where Product__c=:prodIdSet and TPR__c = true and Promotion__r.Visibility__c='Visible' and 
                    (Promotion__r.recordtypeid=:AccountPromotionId OR Promotion__r.recordtypeid=:NationalPromotionId) and Promotion__c!=:recordID and Promotion__r.Start_Date__c<=:promotionStartDate and TPR_Start_Date__c!=null and TPR_End_Date__c!=null order by TPR_End_Date__c desc]){
                        if(NationalPromotionId==pProduct.Promotion__r.recordtypeid){
                        	if(PromotionEndDateMap.get(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid)==null){
							PromotionEndDateMap.put(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid,pProduct);
							}
                        }
                     else if(AccountPromotionId==pProduct.Promotion__r.recordtypeid){
                        if(PromotionAccountMap.get(pProduct.Product__c)==null){
                            list<Promotion_Product__c> prolist=new list<Promotion_Product__c>();
                            prolist.add(pProduct);
                            PromotionAccountMap.put(pProduct.Product__c,prolist);
                        }else if(PromotionAccountMap.get(pProduct.Product__c)!=null){
                            list<Promotion_Product__c> prolist=PromotionAccountMap.get(pProduct.Product__c);
                            prolist.add(pProduct);
                        }
                    }
                        /*if(AccountPromotionId==pProduct.Promotion__r.recordtypeid){
                            system.debug('Promotion $$$$$'+pProduct);
                            if(PromotionAccountMap.get(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid)==null){
                            	list<Promotion_Product__c> proProductlist=new list<Promotion_Product__c>();
                                proProductlist.add(pProduct);
                            	PromotionAccountMap.put(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid,proProductlist);
                            }
                            else if(PromotionAccountMap.get(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid)!=null){
                            list<Promotion_Product__c> proProductlist=PromotionAccountMap.get(pProduct.Product__c+''+pProduct.Promotion__r.recordtypeid);
                                proProductlist.add(pProduct);
                            }
                        	promotionIds.add(pProduct.Promotion__c);
                        }*/
                    promotionIds.add(pProduct.Promotion__c);	
				}
                //promotionIds.add(recordID);
                for(Promotion_Account__c accPro:[select id,Account__c,Account__r.Territory__c,Promotion__c from Promotion_Account__c where Promotion__c=:promotionIds]){
                    if(promotionAccount.get(accPro.Promotion__c)==null){
                    	set<String> accList=new set<String>();
                        accList.add(accPro.Account__c);
                        promotionAccount.put(accPro.Promotion__c,accList);
                    }
                    else if(promotionAccount.get(accPro.Promotion__c)!=null){
                    	set<String> accList=promotionAccount.get(accPro.Promotion__c);
                        accList.add(accPro.Account__c);
                    }
                }
                system.debug('Promotion Accounts='+promotionAccount);
				// End NN
                //getting prod and price info
                productList =   [SELECT ID, Name, US_Platform_offering__c, CA_Platform_offering__c, SD__c, HD__C, UHD__c, X3D__c, RecordTypeId,
                                (Select id, Promotion__c, Account__c, Category__c, iTunes_Tier__c, Margin__c, Platform__c, Price_Type__c, 
                                Product__c, Resolution__c, SRP__c, Territory__c, Valid_From__c, Valid_To__c, WSP__c from Pricing__r 
                                order by Valid_from__c )from product__c  where id in:prodIdSet order by name]; //DFOR-1506
                mapProdsForPricing = new Map<Id,Product__c>(productList);
            }
           // Integer ind = Integer.valueOf(indx);
            
            //if list not empty
            if( !productList.isEmpty() ) {
                
              /*  Integer pageSize;
                
                if( productList.size() <  25 && ind == 0) {
                    pageSize = productList.size();
                }
                else if( ind > 0 && (productList.size() - ind) < 25) {
                    pageSize = productList.size() - ind;
                }
                else {
                    pageSize  = 25;
                }
                
                integer counter = ind;*/
                
                for(Promotion_Product__c promProd : lstProductDetails) {                             
                   // Product__c prod = productlist[i];
                    
                    DGF_TPRPricingWrapper.ProductPricingWrapper pw = new DGF_TPRPricingWrapper.ProductPricingWrapper();
                    Promotion_Product__c promotionProd = new Promotion_Product__c();
                    promotionProd = promProd;
                    //if( mapPromotionProduct.containsKey(prod.Id) && mapPromotionProduct.get(prod.Id) != null) {
                        //promotionProd = mapPromotionProduct.get(prod.Id)
                    //}
                    
                    if(promotionProd.TPR_Start_Date__c != null) {
                        pw.startDate = String.valueOf(promotionProd.TPR_Start_Date__c);
                        pw.tprStart = promotionProd.TPR_Start_Date__c ;
                        if(PromotionEndDateMap.get(promotionProd.Product__c+''+promotionProd.Promotion__r.recordtypeid)!=null){
                            date startDate=PromotionEndDateMap.get(promotionProd.Product__c+''+promotionProd.Promotion__r.recordtypeid).TPR_End_Date__c;
                            pw.startEndDiff=''+startDate.daysBetween(promotionProd.TPR_Start_Date__c);
                        }
                        else if(PromotionAccountMap.get(promotionProd.Product__c)!=null){
                        system.debug(PromotionEndDateMap);
                            boolean exitloop=false;
                            for(Promotion_Product__c proProd:PromotionAccountMap.get(promotionProd.Product__c)){
                                if(promotionAccount.get(proProd.Promotion__c) !=null) 
								for(String accId:promotionAccount.get(proProd.Promotion__c))
								{   System.debug(accID);
                                 	system.debug(ProAccountIds);
                                     if(ProAccountIds.contains(accId)){
                                         date startDate=proProd.TPR_End_Date__c;
                                         pw.startEndDiff=''+startDate.daysBetween(promotionProd.TPR_Start_Date__c);
                                         exitloop=true;
                                         break;
                                     }
										
								}
                                if(exitloop)break;
							} 
                        
                        }
                    }
                    
                    if(promotionProd.TPR_End_Date__c != null) {
                        pw.endDate = String.valueOf(promotionProd.TPR_End_Date__c);
                        pw.tprEnd = promotionProd.TPR_End_Date__c;
                    }
                    
                    pw.promoId = promotionProd.Promotion__c;
                    pw.id = promotionProd.id;
                    pw.pp = promotionProd;
                    
                    //check if the product ID matches the Product ID of the Promotion-Product record
                    
                    pw.productName = promotionProd.Product__r.name;
                    pw.productId = promotionProd.Product__c;
                    pw.productRecTypeID = promotionProd.Product__r.RecordTypeID; //DFOR-1506
                    DGF_TPRPricingWrapper.setDefaultWrapperValues(promotionProd,pw, mapProdsForPricing.get(promotionProd.Product__c));
                    for(Pricing__c pr:mapProdsForPricing.get(promotionProd.Product__c).Pricing__r) {
                        DGF_TPRPricingWrapper.stampWrapperValues(pw,pr,promotionProd);
                    }   
                    
                   // counter += 1;
                    lstProductPricingDetails.add(pw);
                }            
            }
            system.debug('lstProductPricingDetails====='+lstProductPricingDetails);
            return lstProductPricingDetails;
        }
        catch(exception ex) { 
            throw new AuraHandledException(ex.getMessage());
            return null;        
        }        
    }
    
    
    
    
    /***********************************
    Method Name: deletePromoProduct
    Purpose: method to delete Promotion Product
    ***********************************/  
    @AuraEnabled public static String deletePromoProduct(String recId,String type) {
        String promoId = '';
        //query for the promotion product record
        Promotion_Product__c pr = [SELECT ID, TPR__c, Product__c, Promotion__c from Promotion_Product__c where id=:recId];
        
        try {
            list<Promotion_Product__c> prList = new list<Promotion_Product__c>();
            prList.add(pr);
            DGF_PerformDML.saveRecords(prList, 'delete');
        }
        catch(Exception ex ) {  
            throw new AuraHandledException(ex.getMessage());
            return ex.getMessage();        
        }
            
        //query for the pricing associated to the Promotion Product
        list<Pricing__c>priceList = [SELECT ID from Pricing__c where Product__c=:pr.product__c and Promotion__c=:pr.promotion__c];
        //delete the pricing records
        try {
            DGF_PerformDML.saveRecords(priceList, 'delete');
        }
        catch(Exception ex ) {
            throw new AuraHandledException(ex.getMessage());
            return ex.getMessage();        
        }
        //return the promotion ID
        promoId=pr.Promotion__c;
        
        return promoId;
    }
    
    
    
    
    /***********************************
    Method Name: fetchCollections
    Purpose: method to fetch collections
    ***********************************/    
    @AuraEnabled public static List<DGF_TPRPricingWrapper.ProductPricingWrapper> fetchCollections(ID recordID) {
        try{ 
            List<DGF_TPRPricingWrapper.ProductPricingWrapper> lstProductPricingDetails = new List<DGF_TPRPricingWrapper.ProductPricingWrapper>();            
            set<Id>prodIDSet = new set<Id>();
            
            //query for the Promotion Product records associated with the promotion
            List<Promotion_Product__c> lstProductDetails = [SELECT ID, Product__r.Name, Product__r.RecordTypeId, Collection_End_Date__c, Collection_Start_Date__c, Product__c, Promotion__c, Name, TPR__c, TPR_End_Date__c, TPR_Start_Date__c from Promotion_Product__c where Promotion__c=:recordID ]; //DFOR-1506
            if( !lstProductDetails.isEmpty() ) {    
                for(Promotion_Product__c pr:lstProductDetails) {
                    //create a wrapper instance and set the wrapper variables
                    DGF_TPRPricingWrapper.ProductPricingWrapper pw = new DGF_TPRPricingWrapper.ProductPricingWrapper();
                    pw.productId = pr.product__c;
                    pw.id = pr.id;
                    pw.productName = pr.Product__r.name;
                    pw.productRecTypeID = pr.Product__r.RecordTypeId; //DFOR-1506
                    if( pr.Collection_Start_Date__c != null ) {
                        pw.collStartDate = pr.Collection_Start_Date__c.month()+'/'+pr.Collection_Start_Date__c.day()+'/'+pr.Collection_Start_Date__c.year();
                    }
                    if(pr.Collection_End_Date__c!=null) {
                        pw.collEndDate = pr.Collection_End_Date__c.month()+'/'+pr.Collection_End_Date__c.day()+'/'+pr.Collection_End_Date__c.year();
                    }
                    lstProductPricingDetails.add(pw);
                }
            }
            return lstProductPricingDetails;
        }
        catch(exception ex) {  
            throw new AuraHandledException(ex.getMessage());
            return null;        
        }        
    }
    
    /***********************************
    Method Name: editPromoPrd
    Purpose: method to edit a promotion product
    ***********************************/   
    @AuraEnabled public static string editPromoPrd(String wrpList, Integer ind) {
        List<DGF_TPRPricingWrapper.ProductPricingWrapper> prodWrapperList = (List<DGF_TPRPricingWrapper.ProductPricingWrapper>)System.JSON.deserialize(wrpList,List<DGF_TPRPricingWrapper.ProductPricingWrapper>.class);
        //get the ID of the promotion product record
        DGF_TPRPricingWrapper.ProductPricingWrapper pw = prodWrapperList[ind];  
        return pw.id;
        
    }
    
    /***********************************
    Method Name: fetchRecordType
    Purpose: method to get recordType of Promotion
    ***********************************/
    @AuraEnabled public static String fetchRecordType(String recordID) {
        //query for promotion record
        Promotion__c pr=[SELECT ID, RecordTypeId from Promotion__c where id=:recordID ];
        //get the recordType name
        RecordType rt = [SELECT Name, Id from RecordType where id=:pr.recordTypeId and  SObjectType='Promotion__c'];
        return rt.name;
    }
    
    /***********************************
    Method Name: fetchPromotionType
    Purpose: method to get Promotion type of Promotion
    ***********************************/
    @AuraEnabled public static String fetchPromotionType(String recordID) {
        String returnVal = '';
        //query for promotion record
        Promotion__c pr = [SELECT ID, Promotion_Type__c from Promotion__c where id=:recordID ];
        //if Collection is selected then return the value
        if(pr.promotion_Type__c != null) {
            if(pr.promotion_Type__c.contains(DGF_Constants.COLLECTION)) {
                returnVal = DGF_Constants.COLLECTION;
            }
        }
        return returnVal;
    }
    
    /***********************************
    Method Name: getProdCount
    Purpose: method to fetch total number of TPR Promotion Products
    ***********************************/
    @AuraEnabled public static Integer getProdCount(String recordID) {
        Integer cnt=[SELECT count() from Promotion_Product__c where Promotion__c=:recordID and TPR__c = true];
        return cnt;
    }
    
    /***********************************
    Method Name: getProfileDetails
    Purpose: method to get the Profile of logged in user
    ***********************************/
    @AuraEnabled public static boolean getProfileDetails(String recordID) {
        Boolean retval;
        String rt = fetchRecordType(recordID);
        User u = [Select id, name, Profile.Name from User where ID=:userinfo.getUserID()];
        if(rt == DGF_Constants.ACCOUNT_PROMOTION) {
            if(u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN || u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER)) {
                retval = false;
            }
            else {
                retval = true;
            }
        }
        else if(rt == DGF_Constants.NATIONAL_PROMOTION) {
            
            if(u != null && ( u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN || u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER )) {
                retval = false;
            }else{
                retval = true;
            }
        }
        return retval;
        
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
    Method Name: saveTPRPrices
    Purpose: method to save TPR Prices
    ***********************************/
   @AuraEnabled public static list<DGF_TPRPricingWrapper.ProductPricingWrapper> saveTPRPrices(String wrapperList,String recType,String promoId, String promoTerr) {
       DGF_TriggerUtility.dontDefaultTPRPrices  =  FALSE; 
       ID TVRecordTypeId = Schema.Sobjecttype.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId(); //DFOR-1506
       List<DGF_TPRPricingWrapper.ProductPricingWrapper> prodWrapperList = (List<DGF_TPRPricingWrapper.ProductPricingWrapper>)System.JSON.deserialize(wrapperList,List<DGF_TPRPricingWrapper.ProductPricingWrapper>.class);
        list<Pricing__c>insertList = new list<Pricing__c>();
        list<Pricing__c>updateList = new list<Pricing__c>();
        set<String> duplicatePriceIds=new set<String>();
        list<Promotion_Product__c>promoPrdList = new list<Promotion_Product__c>();
        boolean tprAccount = false; //DFOR - 1431
        boolean tprGreater = false;
        set<Id>prodSet = NEW SET<ID>();
        for(DGF_TPRPricingWrapper.ProductPricingWrapper wr:prodWrapperList) {
            if( wr.edited != null || wr.edited != '' ) {
                prodSet.add(wr.productID);
            }
        }
        list<Pricing__c>priceList = new list<Pricing__c>();
        
        map<String,Pricing__c>pricingMap = new map<String,Pricing__c>();
        String priceType = '';
        if(recType == DGF_Constants.ACCOUNT_PROMOTION) {
            priceType='TPR Account';
            tprAccount = true;
        }
        else if(recType == DGF_Constants.NATIONAL_PROMOTION) {
            priceType = 'TPR National';
        }
        priceList=[SELECT ID, WSP__C,SRP__c, Territory__c, Platform__c, Resolution__c, Account__c, Promotion__c, Product__c from Pricing__c where Product__c in:prodSet and Price_Type__c=:priceType and Account__c = null];
        
        for(Pricing__c p:priceList) {
            if(p.Account__c == null) {
                pricingMap.put(p.promotion__c+':'+p.product__c+':'+p.territory__c+':'+p.platform__c+':'+p.resolution__c,p);
            }
            
        }

        
        for(DGF_TPRPricingWrapper.ProductPricingWrapper wr:prodWrapperList) {
            wr.promoTerr = promoTerr; //DFOR-1379
            if(wr.dateChanged) {
                if(wr.startDate != String.valueOf(wr.pp.tpr_start_date__c) || wr.endDate != String.valueOf(wr.pp.tpr_end_date__c)) {
                    if(wr.startDate != String.valueOf(wr.pp.tpr_start_date__c)) {
                        list<String>dateList = new list<String>();
                        if(wr.startDate!=null) {  
                            dateList = wr.startDate.split('-');
                            
                            wr.pp.tpr_start_date__c = date.newInstance(integer.valueOf(dateList[0]),integer.valueOf(dateList[1]),integer.valueOf(dateList[2]));
                        }
                        
                    }
                    if(wr.endDate != String.valueOf(wr.pp.tpr_end_date__c)) {
                        list<String>dateList = new list<String>();
                        if(wr.startDate != null) {  
                            dateList = wr.endDate.split('-');
                            wr.pp.tpr_end_date__c = date.newInstance(integer.valueOf(dateList[0]),integer.valueOf(dateList[1]),integer.valueOf(dateList[2]));
                        }
                    }
                    promoPrdList.add(wr.pp);
                }
            }
            
            if(wr.edited != null && wr.edited != '') {
                list<String>dateList = new list<String>();
                Date stDate;
                Date endDate;
                if(wr.startDate != null) {  
                    dateList = wr.startDate.split('-');
                    stDate = date.newInstance(integer.valueOf(dateList[0]),integer.valueOf(dateList[1]),integer.valueOf(dateList[2]));
                }
                if(wr.endDate != null) {  
                    dateList.clear();
                    dateList = wr.endDate.split('-');
                    endDate = date.newInstance(integer.valueOf(dateList[0]),integer.valueOf(dateList[1]),integer.valueOf(dateList[2]));
                }           
                //DFOR - 1431 -start
                if(wr.edited.contains('US-EST-SD-WSP-TPR') || wr.edited.contains('US-EST-SD-SRP-TPR')) {
                    if( (((wr.usESTSDWSPTPR != null && wr.usESTSDWSPTPR != 'N/A')  && ( wr.usESTSDWSP != null && wr.usESTSDWSP != 'N/A') && 
                    Decimal.valueOf(wr.usESTSDWSPTPR) > Decimal.valueOf(wr.usESTSDWSP.replace('$',''))) || ((wr.usESTSDSRPTPR != null &&
                    wr.usESTSDSRPTPR != 'N/A') && (wr.usESTSDSRP != null && wr.usESTSDSRP!='N/A') && Decimal.valueOf(wr.usESTSDSRPTPR) > Decimal.valueOf(wr.usESTSDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:EST:SD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US,Platform__c = DGF_Constants.PLATFORM_EST, Resolution__c = DGF_Constants.SD ,Valid_From__c = stDate,
                                                       Valid_tO__C = endDate,Product__c = wr.productID,Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usESTSDWSPTPR != null ?Decimal.valueOf(wr.usESTSDWSPTPR):null;
                        pr.srp__c = wr.usESTSDSRPTPR!=null ?Decimal.valueOf(wr.usESTSDSRPTPR):null;
                        system.debug('product record type :: '+wr.productRecTypeID );
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:EST:SD');
                        p.wsp__c = wr.usESTSDWSPTPR != null ?Decimal.valueOf(wr.usESTSDWSPTPR):null;
                        p.srp__c = wr.usESTSDSRPTPR != null ?Decimal.valueOf(wr.usESTSDSRPTPR):null;
                        if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }
                        
                    }
                }
                
                //US EST HD
                if(wr.edited.contains('US-EST-HD-WSP-TPR') || wr.edited.contains('US-EST-HD-SRP-TPR')) {
                    if( (((wr.usESTHDWSPTPR != null && wr.usESTHDWSPTPR != 'N/A')  && ( wr.usESTHDWSP != null && wr.usESTHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.usESTHDWSPTPR) > Decimal.valueOf(wr.usESTHDWSP.replace('$',''))) || ((wr.usESTHDSRPTPR != null && wr.usESTHDSRPTPR != 'N/A') && 
                    (wr.usESTHDSRP != null && wr.usESTHDSRP!='N/A') && Decimal.valueOf(wr.usESTHDSRPTPR) > Decimal.valueOf(wr.usESTHDSRP.replace('$','')))) && !tprAccount ) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:EST:HD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US,Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.HD , Valid_From__c = stDate, Valid_tO__C = endDate, 
                                                       Product__c=wr.productID, Promotion__c=wr.promoID);
                        pr.wsp__c = wr.usESTHDWSPTPR != null ?Decimal.valueOf(wr.usESTHDWSPTPR):null;
                        pr.srp__c = wr.usESTHDSRPTPR != null ?Decimal.valueOf(wr.usESTHDSRPTPR):null;
                       
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:EST:HD');
                        p.wsp__c = wr.usESTHDWSPTPR != null ?Decimal.valueOf(wr.usESTHDWSPTPR):null;
                        p.srp__c = wr.usESTHDSRPTPR != null ?Decimal.valueOf(wr.usESTHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                        
                    }
                }
                
                //US EST UHD
                if(wr.edited.contains('US-EST-UHD-WSP-TPR') || wr.edited.contains('US-EST-UHD-SRP-TPR')) {
                    if( (((wr.usESTUHDWSPTPR != null && wr.usESTUHDWSPTPR != 'N/A')  && ( wr.usESTUHDWSP != null && wr.usESTUHDWSP != 'N/A') && 
                     Decimal.valueOf(wr.usESTUHDWSPTPR) > Decimal.valueOf(wr.usESTUHDWSP.replace('$',''))) || ((wr.usESTUHDSRPTPR != null && wr.usESTUHDSRPTPR != 'N/A') && 
                     (wr.usESTUHDSRP != null && wr.usESTUHDSRP!='N/A') && Decimal.valueOf(wr.usESTUHDSRPTPR) > Decimal.valueOf(wr.usESTUHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:EST:UHD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US, Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.UHD ,Valid_From__c = stDate,Valid_tO__C = endDate, 
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usESTUHDWSPTPR != null ?Decimal.valueOf(wr.usESTUHDWSPTPR):null;
                        pr.srp__c = wr.usESTUHDSRPTPR != null ?Decimal.valueOf(wr.usESTUHDSRPTPR):null;
                        
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:EST:UHD');
                        p.wsp__c = wr.usESTUHDWSPTPR != null ?Decimal.valueOf(wr.usESTUHDWSPTPR):null;
                        p.srp__c = wr.usESTUHDSRPTPR != null ?Decimal.valueOf(wr.usESTUHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id); 
                        }
                    }
                }
                
                //US EST 3D
                if(wr.edited.contains('US-EST-3D-WSP-TPR') || wr.edited.contains('US-EST-3D-SRP-TPR')) {
                    if( (((wr.usEST3DWSPTPR != null && wr.usEST3DWSPTPR != 'N/A')  && ( wr.usEST3DWSP != null && wr.usEST3DWSP != 'N/A') && 
                    Decimal.valueOf(wr.usEST3DWSPTPR) > Decimal.valueOf(wr.usEST3DWSP.replace('$',''))) || ((wr.usEST3DSRPTPR != null && wr.usEST3DSRPTPR != 'N/A') && 
                    (wr.usEST3DSRP != null && wr.usEST3DSRP!='N/A') && Decimal.valueOf(wr.usEST3DSRPTPR) > Decimal.valueOf(wr.usEST3DSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:EST:3D') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US, Platform__c = DGF_Constants.PLATFORM_EST, Resolution__c = DGF_Constants.X3D , Valid_From__c = stDate,Valid_tO__C = endDate, 
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usEST3DWSPTPR != null ?Decimal.valueOf(wr.usEST3DWSPTPR):null;
                        pr.srp__c = wr.usEST3DSRPTPR != null ?Decimal.valueOf(wr.usEST3DSRPTPR):null;
                       
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:EST:3D');
                        p.wsp__c = wr.usESTUHDWSPTPR != null ?Decimal.valueOf(wr.usEST3DWSPTPR):null;
                        p.srp__c = wr.usESTUHDSRPTPR != null ?Decimal.valueOf(wr.usEST3DSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id); 
                        }
                    }
                }
                
                //CA EST SD
                if(wr.edited.contains('CA-EST-SD-WSP-TPR') || wr.edited.contains('CA-EST-SD-SRP-TPR')) {
                    if( (((wr.caESTSDWSPTPR != null && wr.caESTSDWSPTPR != 'N/A')  && ( wr.caESTSDWSP != null && wr.caESTSDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caESTSDWSPTPR) > Decimal.valueOf(wr.caESTSDWSP.replace('$',''))) || ((wr.caESTSDSRPTPR != null && wr.caESTSDSRPTPR != 'N/A') &&
                    (wr.caESTSDSRP != null && wr.caESTSDSRP!='N/A') && Decimal.valueOf(wr.caESTSDSRPTPR) > Decimal.valueOf(wr.caESTSDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:EST:SD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA, Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.SD, Valid_From__c = stDate, Valid_tO__C = endDate, 
                                                       Product__c = wr.productID,Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caESTSDWSPTPR != null ?Decimal.valueOf(wr.caESTSDWSPTPR):null;
                        pr.srp__c = wr.caESTSDSRPTPR != null ?Decimal.valueOf(wr.caESTSDSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:EST:SD');
                        p.wsp__c = wr.caESTSDWSPTPR!=null ?Decimal.valueOf(wr.caESTSDWSPTPR):null;
                        p.srp__c = wr.caESTSDSRPTPR!=null ?Decimal.valueOf(wr.caESTSDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id); 
                        }
                    }
                }
                
                //CA EST HD
                if(wr.edited.contains('CA-EST-HD-WSP-TPR') || wr.edited.contains('CA-EST-HD-SRP-TPR')) {
                    if( (((wr.caESTHDWSPTPR != null && wr.caESTHDWSPTPR != 'N/A')  && ( wr.caESTHDWSP != null && wr.caESTHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caESTHDWSPTPR) > Decimal.valueOf(wr.caESTHDWSP.replace('$',''))) || ((wr.caESTHDSRPTPR != null && wr.caESTHDSRPTPR != 'N/A') && 
                    (wr.caESTHDSRP != null && wr.caESTHDSRP!='N/A') && Decimal.valueOf(wr.caESTHDSRPTPR) > Decimal.valueOf(wr.caESTHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:EST:HD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.HD , Valid_From__c = stDate, Valid_tO__C = endDate, 
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caESTHDWSPTPR != null ?Decimal.valueOf(wr.caESTHDWSPTPR):null;
                        pr.srp__c = wr.caESTHDSRPTPR != null ?Decimal.valueOf(wr.caESTHDSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:EST:HD');
                        p.wsp__c = wr.caESTHDWSPTPR != null ?Decimal.valueOf(wr.caESTHDWSPTPR):null;
                        p.srp__c = wr.caESTHDSRPTPR != null ?Decimal.valueOf(wr.caESTHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }
                    }
                }
                
                //CA EST UHD
                if(wr.edited.contains('CA-EST-UHD-WSP-TPR') || wr.edited.contains('CA-EST-UHD-SRP-TPR')) {
                    if( (((wr.caESTUHDWSPTPR != null && wr.caESTUHDWSPTPR != 'N/A')  && ( wr.caESTUHDWSP != null && wr.caESTUHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caESTUHDWSPTPR) > Decimal.valueOf(wr.caESTUHDWSP.replace('$',''))) || ((wr.caESTUHDSRPTPR != null && wr.caESTUHDSRPTPR != 'N/A') && 
                    (wr.caESTUHDSRP != null && wr.caESTUHDSRP!='N/A') && Decimal.valueOf(wr.caESTUHDSRPTPR) > Decimal.valueOf(wr.caESTUHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:EST:UHD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.UHD , Valid_From__c = stDate, Valid_tO__C = endDate,
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caESTUHDWSPTPR != null ?Decimal.valueOf(wr.caESTUHDWSPTPR):null;
                        pr.srp__c = wr.caESTUHDSRPTPR != null ?Decimal.valueOf(wr.caESTUHDSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:EST:UHD');
                        p.wsp__c = wr.caESTUHDWSPTPR != null ?Decimal.valueOf(wr.caESTUHDWSPTPR):null;
                        p.srp__c = wr.caESTUHDSRPTPR != null ?Decimal.valueOf(wr.caESTUHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //CA EST 3D
                if(wr.edited.contains('CA-EST-3D-WSP-TPR') || wr.edited.contains('CA-EST-3D-SRP-TPR')) {
                    if( (((wr.caEST3DWSPTPR != null && wr.caEST3DWSPTPR != 'N/A')  && ( wr.caEST3DWSP != null && wr.caEST3DWSP != 'N/A') && 
                    Decimal.valueOf(wr.caEST3DWSPTPR) > Decimal.valueOf(wr.caEST3DWSP.replace('$',''))) || ((wr.caEST3DSRPTPR != null && wr.caEST3DSRPTPR != 'N/A') && 
                    (wr.caEST3DSRP != null && wr.caEST3DSRP!='N/A') && Decimal.valueOf(wr.caEST3DSRPTPR) > Decimal.valueOf(wr.caEST3DSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:EST:3D') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_EST , Resolution__c = DGF_Constants.X3D , Valid_From__c = stDate, Valid_tO__C = endDate,
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caEST3DWSPTPR != null ?Decimal.valueOf(wr.caEST3DWSPTPR):null;
                        pr.srp__c = wr.caEST3DSRPTPR != null ?Decimal.valueOf(wr.caEST3DSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:EST:3D');
                        p.wsp__c = wr.caESTUHDWSPTPR != null ?Decimal.valueOf(wr.caEST3DWSPTPR):null;
                        p.srp__c = wr.caESTUHDSRPTPR != null ?Decimal.valueOf(wr.caEST3DSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                //US VOD SD
                if(wr.edited.contains('US-VOD-SD-WSP-TPR') || wr.edited.contains('US-VOD-SD-SRP-TPR')) {
                    if( (((wr.usVODSDWSPTPR != null && wr.usVODSDWSPTPR != 'N/A')  && ( wr.usVODSDWSP != null && wr.usVODSDWSP != 'N/A') && Decimal.valueOf(wr.usVODSDWSPTPR) > Decimal.valueOf(wr.usVODSDWSP.replace('$',''))) || ((wr.usVODSDSRPTPR != null && wr.usVODSDSRPTPR != 'N/A') && (wr.usVODSDSRP != null && wr.usVODSDSRP!='N/A') && Decimal.valueOf(wr.usVODSDSRPTPR) > Decimal.valueOf(wr.usVODSDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:VOD:SD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US,Platform__c = DGF_Constants.PLATFORM_VOD ,Resolution__c = DGF_Constants.SD , Valid_From__c = stDate,Valid_tO__C = endDate,
                                                       Product__c = wr.productID,Promotion__c=wr.promoID);
                        pr.wsp__c = wr.usVODSDWSPTPR != null ?Decimal.valueOf(wr.usVODSDWSPTPR):null;
                        pr.srp__c = wr.usVODSDSRPTPR != null ?Decimal.valueOf(wr.usVODSDSRPTPR):null;
                       
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:VOD:SD');
                        p.wsp__c = wr.usVODSDWSPTPR != null ?Decimal.valueOf(wr.usVODSDWSPTPR):null;
                        p.srp__c=wr.usVODSDSRPTPR != null ?Decimal.valueOf(wr.usVODSDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //US VOD HD
                if(wr.edited.contains('US-VOD-HD-WSP-TPR') || wr.edited.contains('US-VOD-HD-SRP-TPR')) {
                    if( (((wr.usVODHDWSPTPR != null && wr.usVODHDWSPTPR != 'N/A')  && ( wr.usVODHDWSP != null && wr.usVODHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.usVODHDWSPTPR) > Decimal.valueOf(wr.usVODHDWSP.replace('$',''))) || ((wr.usVODHDSRPTPR != null && wr.usVODHDSRPTPR != 'N/A') && 
                    (wr.usVODHDSRP != null && wr.usVODHDSRP!='N/A') && Decimal.valueOf(wr.usVODHDSRPTPR) > Decimal.valueOf(wr.usVODHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:VOD:HD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US, Platform__c = DGF_Constants.PLATFORM_VOD, Resolution__c = DGF_Constants.HD , Valid_From__c = stDate, Valid_tO__C = endDate,
                        Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usVODHDWSPTPR != null ?Decimal.valueOf(wr.usVODHDWSPTPR):null;
                        pr.srp__c = wr.usVODHDSRPTPR != null ?Decimal.valueOf(wr.usVODHDSRPTPR):null;
                       
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:VOD:HD');
                        p.wsp__c = wr.usVODHDWSPTPR != null ?Decimal.valueOf(wr.usVODHDWSPTPR):null;
                        p.srp__c = wr.usVODHDSRPTPR != null ?Decimal.valueOf(wr.usVODHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //US VOD UHD
                if(wr.edited.contains('US-VOD-UHD-WSP-TPR') || wr.edited.contains('US-VOD-UHD-SRP-TPR')) {
                    if( (((wr.usVODUHDWSPTPR != null && wr.usVODUHDWSPTPR != 'N/A')  && ( wr.usVODUHDWSP != null && wr.usVODUHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.usVODUHDWSPTPR) > Decimal.valueOf(wr.usVODUHDWSP.replace('$',''))) || ((wr.usVODUHDSRPTPR != null && wr.usVODUHDSRPTPR != 'N/A') && 
                    (wr.usVODUHDSRP != null && wr.usVODUHDSRP!='N/A') && Decimal.valueOf(wr.usVODUHDSRPTPR) > Decimal.valueOf(wr.usVODUHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:VOD:UHD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US, Platform__c = DGF_Constants.PLATFORM_VOD, Resolution__c = DGF_Constants.UHD , Valid_From__c = stDate, Valid_tO__C = endDate,
                        Product__c = wr.productID,Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usVODUHDWSPTPR != null ?Decimal.valueOf(wr.usVODUHDWSPTPR):null;
                        pr.srp__c = wr.usVODUHDSRPTPR != null ?Decimal.valueOf(wr.usVODUHDSRPTPR):null;
                        
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p=pricingMap.get(wr.promoId+':'+wr.productId+':US:VOD:UHD');
                        p.wsp__c = wr.usVODUHDWSPTPR != null ?Decimal.valueOf(wr.usVODUHDWSPTPR):null;
                        p.srp__c = wr.usVODUHDSRPTPR != null ?Decimal.valueOf(wr.usVODUHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //US VOD 3D
                if(wr.edited.contains('US-VOD-3D-WSP-TPR') || wr.edited.contains('US-VOD-3D-SRP-TPR')) {
                    if( (((wr.usVOD3DWSPTPR != null && wr.usVOD3DWSPTPR != 'N/A')  && ( wr.usVOD3DWSP != null && wr.usVOD3DWSP != 'N/A') && 
                    Decimal.valueOf(wr.usVOD3DWSPTPR) > Decimal.valueOf(wr.usVOD3DWSP.replace('$',''))) || ((wr.usVOD3DSRPTPR != null && wr.usVOD3DSRPTPR != 'N/A') && 
                    (wr.usVOD3DSRP != null && wr.usVOD3DSRP!='N/A') && Decimal.valueOf(wr.usVOD3DSRPTPR) > Decimal.valueOf(wr.usVOD3DSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':US:VOD:3D') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_US,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.X3D ,Valid_From__c = stDate,Valid_tO__C = endDate,
                        Product__c = wr.productID,Promotion__c = wr.promoID);
                        pr.wsp__c = wr.usVOD3DWSPTPR != null ?Decimal.valueOf(wr.usVOD3DWSPTPR):null;
                        pr.srp__c = wr.usVOD3DSRPTPR != null ?Decimal.valueOf(wr.usVOD3DSRPTPR):null;
                        
                        if (wr.promoTerr.split(';').size() > 1 && !tprAccount && wr.productRecTypeID == TVRecordTypeId) { //DFOR-1505 //DFOR-1506
                            Pricing__c priceCAClone = pr.clone(false, false, false, false); //DFOR-1379
                            priceCAClone.Territory__c = DGF_Constants.TERRITORY_CA; //DFOR-1379
                            priceCAClone.Cloned_From_US_TPR__c = true; //DFOR-1503
                            insertList.add(priceCAClone); //DFOR-1379
                        }
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':US:VOD:3D');
                        p.wsp__c = wr.usVODUHDWSPTPR != null ?Decimal.valueOf(wr.usVOD3DWSPTPR):null;
                        p.srp__c = wr.usVODUHDSRPTPR != null ?Decimal.valueOf(wr.usVOD3DSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //CA VOD SD
                if(wr.edited.contains('CA-VOD-SD-WSP-TPR') || wr.edited.contains('CA-VOD-SD-SRP-TPR')) {
                    if( (((wr.caVODSDWSPTPR != null && wr.caVODSDWSPTPR != 'N/A')  && ( wr.caVODSDWSP != null && wr.caVODSDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caVODSDWSPTPR) > Decimal.valueOf(wr.caVODSDWSP.replace('$',''))) || ((wr.caVODSDSRPTPR != null && wr.caVODSDSRPTPR != 'N/A') && 
                    (wr.caVODSDSRP != null && wr.caVODSDSRP!='N/A') && Decimal.valueOf(wr.caVODSDSRPTPR) > Decimal.valueOf(wr.caVODSDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:VOD:SD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA ,Platform__c = DGF_Constants.PLATFORM_VOD,Resolution__c = DGF_Constants.SD , Valid_From__c = stDate,Valid_tO__C = endDate,
                                                       Product__c = wr.productID,Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caVODSDWSPTPR != null ?Decimal.valueOf(wr.caVODSDWSPTPR):null;
                        pr.srp__c = wr.caVODSDSRPTPR != null ?Decimal.valueOf(wr.caVODSDSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:VOD:SD');
                        p.wsp__c = wr.caVODSDWSPTPR != null ?Decimal.valueOf(wr.caVODSDWSPTPR):null;
                        p.srp__c = wr.caVODSDSRPTPR != null ?Decimal.valueOf(wr.caVODSDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                          
                    }
                }
                
                //CA VOD HD
                if(wr.edited.contains('CA-VOD-HD-WSP-TPR') || wr.edited.contains('CA-VOD-HD-SRP-TPR')) {
                    if( (((wr.caVODHDWSPTPR != null && wr.caVODHDWSPTPR != 'N/A')  && ( wr.caVODHDWSP != null && wr.caVODHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caVODHDWSPTPR) > Decimal.valueOf(wr.caVODHDWSP.replace('$',''))) || ((wr.caVODHDSRPTPR != null && wr.caVODHDSRPTPR != 'N/A') && 
                    (wr.caVODHDSRP != null && wr.caVODHDSRP!='N/A') && Decimal.valueOf(wr.caVODHDSRPTPR) > Decimal.valueOf(wr.caVODHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:VOD:HD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_VOD, Resolution__c = DGF_Constants.HD , Valid_From__c = stDate, Valid_tO__C = endDate,
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caVODHDWSPTPR != null ?Decimal.valueOf(wr.caVODHDWSPTPR):null;
                        pr.srp__c = wr.caVODHDSRPTPR != null ?Decimal.valueOf(wr.caVODHDSRPTPR):null;
                        insertList.add(pr);
                    }
                    else {
                       Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:VOD:HD');
                        p.wsp__c = wr.caVODHDWSPTPR != null ?Decimal.valueOf(wr.caVODHDWSPTPR):null;
                        p.srp__c = wr.caVODHDSRPTPR != null ?Decimal.valueOf(wr.caVODHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }                      }
                }
                
                //CA VOD UHD
                if(wr.edited.contains('CA-VOD-UHD-WSP-TPR') || wr.edited.contains('CA-VOD-UHD-SRP-TPR')) {
                    if( (((wr.caVODUHDWSPTPR != null && wr.caVODUHDWSPTPR != 'N/A')  && ( wr.caVODUHDWSP != null && wr.caVODUHDWSP != 'N/A') && 
                    Decimal.valueOf(wr.caVODUHDWSPTPR) > Decimal.valueOf(wr.caVODUHDWSP.replace('$',''))) || ((wr.caVODUHDSRPTPR != null && wr.caVODUHDSRPTPR != 'N/A') && 
                    (wr.caVODUHDSRP != null && wr.caVODUHDSRP!='N/A') && Decimal.valueOf(wr.caVODUHDSRPTPR) > Decimal.valueOf(wr.caVODUHDSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:VOD:UHD') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_VOD , Resolution__c = DGF_Constants.UHD , Valid_From__c = stDate, Valid_tO__C = endDate,
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caVODUHDWSPTPR != null ?Decimal.valueOf(wr.caVODUHDWSPTPR):null;
                        pr.srp__c = wr.caVODUHDSRPTPR != null ?Decimal.valueOf(wr.caVODUHDSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:VOD:UHD');
                        p.wsp__c = wr.caVODUHDWSPTPR != null ?Decimal.valueOf(wr.caVODUHDWSPTPR):null;
                        p.srp__c = wr.caVODUHDSRPTPR != null ?Decimal.valueOf(wr.caVODUHDSRPTPR):null;
						if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }  
                    }
                }
                //CA VOD 3D
                if(wr.edited.contains('CA-VOD-3D-WSP-TPR') || wr.edited.contains('CA-VOD-3D-SRP-TPR')) {
                    if( (((wr.caVOD3DWSPTPR != null && wr.caVOD3DWSPTPR != 'N/A')  && ( wr.caVOD3DWSP != null && wr.caVOD3DWSP != 'N/A') && 
                    Decimal.valueOf(wr.caVOD3DWSPTPR) > Decimal.valueOf(wr.caVOD3DWSP.replace('$',''))) || ((wr.caVOD3DSRPTPR != null && wr.caVOD3DSRPTPR != 'N/A') && 
                    (wr.caVOD3DSRP != null && wr.caVOD3DSRP!='N/A') && Decimal.valueOf(wr.caVOD3DSRPTPR) > Decimal.valueOf(wr.caVOD3DSRP.replace('$','')))) && !tprAccount) { 
                        tprGreater = true;
                        break;
                    }
                    if(!pricingMap.containsKey(wr.promoId+':'+wr.productId+':CA:VOD:3D') ) {
                        Pricing__c pr = new Pricing__c(Territory__c = DGF_Constants.TERRITORY_CA , Platform__c = DGF_Constants.PLATFORM_VOD , Resolution__c = DGF_Constants.X3D , Valid_From__c = stDate,Valid_tO__C = endDate,
                                                       Product__c = wr.productID, Promotion__c = wr.promoID);
                        pr.wsp__c = wr.caVOD3DWSPTPR != null ?Decimal.valueOf(wr.caVOD3DWSPTPR):null;
                        pr.srp__c = wr.caVOD3DSRPTPR != null ?Decimal.valueOf(wr.caVOD3DSRPTPR):null;
                       
                        insertList.add(pr);
                    }
                    else {
                        
                        Pricing__c p = pricingMap.get(wr.promoId+':'+wr.productId+':CA:VOD:3D');
                        p.wsp__c = wr.caVODUHDWSPTPR != null ?Decimal.valueOf(wr.caVOD3DWSPTPR):null;
                        p.srp__c = wr.caVODUHDSRPTPR != null ?Decimal.valueOf(wr.caVOD3DSRPTPR):null;
                        if(!duplicatePriceIds.contains(p.id)){
                        updateList.add(p);
                            duplicatePriceIds.add(p.id);
                        }  
                         
                    }
                }
            } //DFOR - 1431 -END
        }
        if( !tprGreater ) {
            if(!updateList.isEmpty()) {
                try {
                    System.debug('updateList...'+updateList);
                    DGF_PerformDML.saveRecords(updateList , 'update');
                }
                catch(Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }       

            if(!insertList.isEmpty()) {
                for (Pricing__c pr: insertList ) {
                    pr.price_type__c = priceType;
                }
                try {
                    System.debug('insertList...'+insertList);
                    DGF_PerformDML.saveRecords(insertList , 'insert');
                }
                catch(Exception e) {
                    //DFOR-1510 --- start
                    if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        throw new AuraHandledException(getFormattedErrorMessage(e.getMessage()));
                    }
                    else {
                        throw new AuraHandledException(e.getMessage());
                    }
                    //DFOR-1510 --- end
                }  
            }
            
            if(!promoPrdList.isEmpty()) {
                DGF_PerformDML.saveRecords(promoPrdList , 'update');
            }
             
            
        }
        //for iTunes
        set<Id> priceSet = new set<Id>();
        list<Pricing__c>iTunesPricing=[SELECT ID, Territory__c, platform__c, promotion__c, product__c, resolution__c, wsp__c, srp__c, account__c from pricing__c 
                                      where account__c =: DGF_Constants.iTUNES and Product__c in:prodSet and Price_Type__c=:priceType];
        list<Pricing__c>iTunesUpdateList = new list<Pricing__C>();
        map<String,Pricing__c>iTunesMap = new map<String,pricing__c>();
        for(Pricing__c p:iTunesPricing) {
            iTunesMap.put(p.promotion__c+':'+p.product__c+':'+p.territory__c+':'+p.platform__c+':'+p.resolution__c+':'+p.Account__c,p);
            priceSet.add(p.id);
        }
        for(DGF_TPRPricingWrapper.ProductPricingWrapper wr:prodWrapperList) {
            if(wr.edited != null && wr.edited != '') {
                // US EST SD iTunes
                if(wr.edited.contains('US-SD-SRP-TPR_iTunes') ) {
                    
                    if( (wr.usESTSDSRP_iTunes != null &&  wr.usESTSDSRP_iTunes !='N/A') && (wr.usESTSDSRPTPR_iTunes != null && wr.usESTSDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.usESTSDSRPTPR_iTunes) > Decimal.valueOf(wr.usESTSDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'US:EST:SD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'US:EST:SD:iTunes');
                        p.srp__c = wr.usESTSDSRPTPR_iTunes != null ?Decimal.valueOf(wr.usESTSDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // US EST HD iTunes
                if(wr.edited.contains('US-HD-SRP-TPR_iTunes') ) {
                    
                    if( (wr.usESTHDSRP_iTunes != null &&  wr.usESTHDSRP_iTunes !='N/A') && (wr.usESTHDSRPTPR_iTunes != null && wr.usESTHDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.usESTHDSRPTPR_iTunes) > Decimal.valueOf(wr.usESTHDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'US:EST:HD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'US:EST:HD:iTunes');
                        p.srp__c = wr.usESTHDSRPTPR_iTunes != null ?Decimal.valueOf(wr.usESTHDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // US EST UHD iTunes
                if(wr.edited.contains('US-UHD-SRP-TPR_iTunes') ) {
                    if( (wr.usESTUHDSRP_iTunes != null &&  wr.usESTUHDSRP_iTunes !='N/A') && (wr.usESTUHDSRPTPR_iTunes != null && wr.usESTUHDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.usESTUHDSRPTPR_iTunes) > Decimal.valueOf(wr.usESTUHDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'US:EST:UHD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'US:EST:UHD:iTunes');
                        p.srp__c = wr.usESTUHDSRPTPR_iTunes != null ?Decimal.valueOf(wr.usESTUHDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // US EST 3D iTunes
                if(wr.edited.contains('US-3D-SRP-TPR_iTunes') ) {
                    if( (wr.usEST3DSRP_iTunes != null &&  wr.usEST3DSRP_iTunes !='N/A') && (wr.usEST3DSRPTPR_iTunes != null && wr.usEST3DSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.usEST3DSRPTPR_iTunes) > Decimal.valueOf(wr.usEST3DSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'US:EST:3D:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'US:EST:3D:iTunes');
                        p.srp__c = wr.usEST3DSRPTPR_iTunes!=null ?Decimal.valueOf(wr.usEST3DSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                
                // CA EST SD iTunes
                if(wr.edited.contains('CA-SD-SRP-TPR_iTunes') ) {
                    if( (wr.caESTSDSRP_iTunes != null &&  wr.caESTSDSRP_iTunes !='N/A') && (wr.caESTSDSRPTPR_iTunes != null && wr.caESTSDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.caESTSDSRPTPR_iTunes) > Decimal.valueOf(wr.caESTSDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'CA:EST:SD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'CA:EST:SD:iTunes');
                        p.srp__c = wr.caESTSDSRPTPR_iTunes != null ?Decimal.valueOf(wr.caESTSDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // CA EST HD iTunes
                if(wr.edited.contains('CA-HD-SRP-TPR_iTunes') ) {
                    if( (wr.caESTHDSRP_iTunes != null &&  wr.caESTHDSRP_iTunes !='N/A') && (wr.caESTHDSRPTPR_iTunes != null && wr.caESTHDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.caESTHDSRPTPR_iTunes) > Decimal.valueOf(wr.caESTHDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'CA:EST:HD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'CA:EST:HD:iTunes');
                        p.srp__c = wr.caESTHDSRPTPR_iTunes != null ?Decimal.valueOf(wr.caESTHDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // CA EST UHD iTunes
                if(wr.edited.contains('CA-UHD-SRP-TPR_iTunes') ) {
                    if( (wr.caESTUHDSRP_iTunes != null &&  wr.caESTUHDSRP_iTunes !='N/A') && (wr.caESTUHDSRPTPR_iTunes != null && wr.caESTUHDSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.caESTUHDSRPTPR_iTunes) > Decimal.valueOf(wr.caESTUHDSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'CA:EST:UHD:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'CA:EST:UHD:iTunes');
                        p.srp__c = wr.caESTUHDSRPTPR_iTunes != null ?Decimal.valueOf(wr.caESTUHDSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
                // CA EST 3D iTunes
                if(wr.edited.contains('CA-3D-SRP-TPR_iTunes') ) {
                    if( (wr.caEST3DSRP_iTunes != null &&  wr.caEST3DSRP_iTunes !='N/A') && (wr.caEST3DSRPTPR_iTunes != null && wr.caEST3DSRPTPR_iTunes != 'N/A' )&& 
                    Decimal.valueOf(wr.caEST3DSRPTPR_iTunes) > Decimal.valueOf(wr.caEST3DSRP_iTunes) ) { 
                        tprGreater = true;
                        break;
                    }
                    if(itunesmap.containsKey(wr.promoId+':'+wr.productId+':'+'CA:EST:3D:iTunes')) {
                        Pricing__c p = itunesmap.get(wr.promoId+':'+wr.productId+':'+'CA:EST:3D:iTunes');
                        p.srp__c = wr.caEST3DSRPTPR_iTunes != null ?Decimal.valueOf(wr.caEST3DSRPTPR_iTunes):null;
                        iTunesUpdateList.add(p);
                    }
                }
            }
        }
        if(!tprGreater) {
            if(!iTunesUpdateList.isEmpty()) {
                DGF_PerformDML.saveRecords(iTunesUpdateList , 'update');
            }
            
        }
        if(!tprGreater) {
            prodWrapperList=fetchRelatedRecords(promoId,null);
        }
        else {
            prodWrapperList.clear();
        }
        return prodWrapperList;
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
    /* DFOR-1445  */
     @AuraEnabled
    public static list<Promotion_Account__c> getAccountPromotions(id promotionId){
        return [select id,name,Account__r.Name,Account__c from Promotion_Account__c where Promotion__c=:promotionId];
    }
     
    
}