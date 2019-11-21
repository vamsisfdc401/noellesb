/*****************************************************************************************
Class Name: DGF_BulkRepricingController
Purpose: Controller for Bulk Repricing Component
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/05/2017           Prarthana                Initial Development
1.1             06/12/2017           Vaibhav B                Adding Comments (Story DFOR-1035)
******************************************************************************************/
public with sharing class DGF_BulkRepricingController{  
    
    /***********************************
    Method Name: fetchProducts
    Purpose: method to fetch products matching name and EST Tier
    ***********************************/
    @AuraEnabled public static List<ProductWrapper> fetchProducts(String searchProdName) {
        String searchKey = '%' + searchProdName + '%';
        list<ProductWrapper>prodWrapperList = new list<ProductWrapper>();
        Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        
        //query for the products
        list<Product__c>prodList = new list<Product__c>();
        prodList=[SELECT ID, US_Platform_Offering__c, CA_Platform_Offering__c, Name, CA_EST_Tier__c, EST_Tier__c,(Select id,
                  Valid_from__c, Valid_To__c, Account__c, Category__c, Platform__c, Price_Type__c, Product__c, Resolution__c,
                  SRP__c, Territory__c, WSP__c from Pricing__r WHERE Platform__c=:DGF_Constants.PLATFORM_EST and
                  (Price_type__c=:DGF_Constants.ORIGINAL or Price_Type__c=:DGF_Constants.REPRICE) and Account__c = null
                  order By Valid_From__c ASC) from Product__c where RecordTypeId=:FilmRecTypeId AND (CA_Platform_Offering__c 
                  INCLUDES ('EST') or Us_Platform_Offering__c INCLUDES('EST')) AND (Name LIKE :searchKey OR CA_EST_Tier__c LIKE :searchKey 
                  OR  EST_Tier__c LIKE :searchKey) ];
        
        for(Product__c pr:prodList) {
            if(!pr.Pricing__r.isEmpty()) {
                //prepare the ProductWrapper
                ProductWrapper pw = new ProductWrapper();
                pw.prodId = pr.Id;
                pw.prodName = pr.name;
                if(pr.US_Platform_Offering__c != null) {
                    //stamp the US EST Tier value
                    if(pr.US_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                        pw.USESTTier = pr.EST_Tier__c;
                    }
                    else {
                        pw.USESTTier = 'N/A';
                    }
                }
                else {
                    pw.USESTTier = 'N/A';
                }
                if(pr.CA_Platform_Offering__c != null) {
                    //stamp the CA EST Tier value
                    if(pr.CA_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                        pw.CAESTTier = pr.CA_EST_Tier__c;
                    }
                    else {
                        pw.CAESTTier = 'N/A';
                    }
                }
                else {
                    pw.CAESTTier = 'N/A';
                }
                /* Ch# 1.1 
                * Any addition in pricing column or change in way they are currently displayed (suffixed with '$ ') the same has to be taken care of 
                * in Lightning bundle DGF_BulkRepricing method sortByField in DGF_BulkRepricingHelper
                */
                //iterate over the Pricing records to fetch the WSP values for different territories and resolutions
                for(Pricing__c price:pr.Pricing__r) {
                    //for US Territory
                    if( price.Territory__c == DGF_Constants.TERRITORY_US  && price.Account__c == null) {
                        //for SD
                        if( price.Resolution__c == DGF_Constants.SD ) {
                            if(price.valid_from__c != null) {
                                if(pw.US_SD_WSP == null || ((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                    if(price.WSP__c != null) {
                                        pw.US_SD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                    }
                                }
                            }
                            
                        }
                        //for HD
                        else if( price.Resolution__c == DGF_Constants.HD ) {
                            if(price.valid_from__c != null) {
                                if(pw.US_HD_WSP == null ||((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                    if(price.WSP__c != null) { 
                                        pw.US_HD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                    }
                                }
                            }
                        }
                        //for UHD
                        else if( price.Resolution__c == DGF_Constants.UHD) {
                            if(price.valid_from__c != null) {
                                if(pw.US_UHD_WSP == null ||((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                    if(price.WSP__c != null) {
                                        pw.US_UHD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                    }
                                }
                            }
                            
                        }
                    }
                    //for CA Territory
                    else if( price.Territory__c == DGF_Constants.TERRITORY_CA  && price.Account__c == null) {
                        //for SD
                        if( price.Resolution__c == DGF_Constants.SD) {
                            if(price.valid_from__c != null){
                                if(pw.CA_SD_WSP == null ||((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                   if(price.WSP__c != null) {
                                        pw.CA_SD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                   }
                               }
                            }
                        }
                        //for HD
                        else if( price.Resolution__c == DGF_Constants.HD ) {
                            if(price.valid_from__c != null) {
                                if( pw.CA_HD_WSP == null || ((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                     if(price.WSP__c != null) {
                                         pw.CA_HD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                     }
                                 }
                            }
                        }
                        //for UHD
                        else if( price.Resolution__c == DGF_Constants.UHD ) {
                            if(price.valid_from__c != null){
                                if(pw.CA_UHD_WSP == null ||((price.valid_from__c < date.today() && date.today() < price.valid_to__c) || 
                                (price.valid_from__c < date.today() && price.valid_to__c == null))) {
                                    if(price.WSP__c != null) {
                                        pw.CA_UHD_WSP = '$ ' + String.valueof((price.WSP__c).setScale(2));
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                if(pr.US_Platform_Offering__c != null) {
                    //setting the order of EST Tier for US EST Tier
                    if(pr.US_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                        if(pr.EST_Tier__c != null ) {
                            if( pr.EST_Tier__c == DGF_Constants.NEW_RELEASE_PREMIUM) {
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.usESTTierOpt.add(DGF_Constants.TIER_2);
                                pw.usESTTierOpt.add(DGF_Constants.TIER_3);
                                
                            }
                            else if( pr.EST_Tier__c == DGF_Constants.NEW_RELEASE_STANDARD) {
                                pw.usESTTierOpt.add(DGF_Constants.TIER_2);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.usESTTierOpt.add(DGF_Constants.TIER_3);
                            }
                            else if( pr.EST_Tier__c == DGF_Constants.TIER_2) {
                                pw.usESTTierOpt.add(DGF_Constants.TIER_3);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.usESTTierOpt.add(DGF_Constants.TIER_2);
                            }
                            else if( pr.EST_Tier__c ==DGF_Constants.TIER_3) {
                                pw.usESTTierOpt.add(DGF_Constants.TIER_3);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.usESTTierOpt.add(DGF_Constants.TIER_2);
                            }
                        }
                        else {
                            pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                            pw.usESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                            pw.usESTTierOpt.add(DGF_Constants.TIER_2);
                            pw.usESTTierOpt.add(DGF_Constants.TIER_3);
                        }
                    }
                    else {
                        pw.usESTTierOpt.add('N/A');
                    }
                }
                else {
                    pw.usESTTierOpt.add('N/A');
                }
                if(pr.CA_Platform_Offering__c != null) {
                    //setting the order of EST Tier for CA EST Tier
                    if(pr.CA_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                        if(pr.CA_EST_Tier__c != null ) {
                            if( pr.CA_EST_Tier__c == DGF_Constants.NEW_RELEASE_PREMIUM) {
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.caESTTierOpt.add(DGF_Constants.TIER_2);
                                pw.caESTTierOpt.add(DGF_Constants.TIER_3);
                                
                                
                            }
                            else if( pr.CA_EST_Tier__c == DGF_Constants.NEW_RELEASE_STANDARD) {
                                pw.caESTTierOpt.add(DGF_Constants.TIER_2);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.caESTTierOpt.add(DGF_Constants.TIER_3);
                            }
                            else if( pr.CA_EST_Tier__c == DGF_Constants.TIER_2) {
                                pw.caESTTierOpt.add(DGF_Constants.TIER_3);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.caESTTierOpt.add(DGF_Constants.TIER_2);
                            }
                            else if( pr.CA_EST_Tier__c == DGF_Constants.TIER_3) {
                                pw.caESTTierOpt.add(DGF_Constants.TIER_3);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                                pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                                pw.caESTTierOpt.add(DGF_Constants.TIER_2);
                            }
                        }
                        else {
                            pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_STANDARD);
                            pw.caESTTierOpt.add(DGF_Constants.NEW_RELEASE_PREMIUM);
                            pw.caESTTierOpt.add(DGF_Constants.TIER_2);
                            pw.caESTTierOpt.add(DGF_Constants.TIER_3);
                        }
                    }
                    else {
                        pw.caESTTierOpt.add('N/A');
                    }
                }
                else {
                    pw.caESTTierOpt.add('N/A');
                }
                prodWrapperList.add(pw);
            }
        }
        
        return prodWrapperList;
        
    }
    
    /***********************************
    Method Name: updateProducts
    Purpose: method to update the selected products
    ***********************************/
    @AuraEnabled public static String updateProducts(String prodWrapper,String priceEffectiveDate){
        Boolean isDMLException = false;
        String returnValue = '';
        //set the Price Effective Date Value
        if(priceEffectiveDate != '' && priceEffectiveDate != null) {
            list<String> splitDate = priceEffectiveDate.split('-');
            Date priceEffDate = date.newInstance(Integer.valueOf(splitDate[0]),Integer.valueOf(splitDate[1]),Integer.valueOf(splitDate[2]));
            DGF_TriggerUtility.priceEffectiveDate=priceEffDate;
        }   
        
        set<String>prodIdSet=new set<String>();
        list<Product__C>toBeUpdatedList = new list<Product__c>();
        List<DGF_BulkRepricingController.ProductWrapper> prodWrapperList = (List<DGF_BulkRepricingController.ProductWrapper>)System.JSON.deserialize(prodWrapper,List<DGF_BulkRepricingController.ProductWrapper>.class);
        //prepare set of product ID's
        for(ProductWrapper pw:prodWrapperList) {
            if(pw.newUSESTTier != pw.USESTTier || pw.newCAESTTier != pw.CAESTTier) {
                prodIdSet.add(pw.prodId);
            }
        }
        
        list<Product__c>prodList=[SELECT ID, Name, EST_Tier__c, CA_EST_Tier__c from Product__c where id in:prodIdSet];
        //iterate over the products and update the EST Tier Values
        for(Product__c pr:prodList) {
            for(ProductWrapper pw:prodWrapperList) {
                if(pw.prodId == pr.id){
                    if(pr.EST_Tier__c != pw.newUSESTTier && pw.newUSESTTier != 'N/A') {
                        pr.EST_Tier__c = pw.newUSESTTier;
                        
                    }
                    if(pr.CA_EST_Tier__c != pw.newCAESTTier && pw.newCAESTTier != 'N/A') {
                        pr.CA_EST_Tier__c = pw.newCAESTTier;
                        
                    }
                    toBeUpdatedList.add(pr);
                    
                }
            }
        }
        
        String prid=prodWrapperList[0].prodId;
        returnValue=prid.subString(0,3);
        
        //DML To update products
        try{            
            if(!toBeUpdatedList.isEmpty()) {
                DGF_TriggerUtility.isBulkReprice = true;
                update (toBeUpdatedList);
                if(!DGF_TriggerUtility.mapOfProductBulkReprice.isEmpty()) {
                    string errorMessage = 'The following Products are already set to be repriced after the inputted Price Effective Date : ' + '<br/><br/>';
                    
                    for(string s : DGF_TriggerUtility.mapOfProductBulkReprice.values()) {                        
                        errorMessage = errorMessage + '<li>' + s + '</li>'+ '<br/>' ;                        
                    }
                    errorMessage = errorMessage + 'To resolve issue either 1) Update the Price Effective Date or 2) Go back and remove the Products and update the product records manually';
                    
                    AuraHandledException ex = new AuraHandledException(errorMessage);
                    ex.setMessage(errorMessage);
                    throw ex;
                    
                }
            }            
        }
        catch(DMLException ex) {
            isDMLException = TRUE;      
            DGF_ExceptionLogController.createExceptionLog('After update of Product','Bulk Repricing',ex.getMessage()); 
            throw new AuraHandledException(ex.getDmlMessage(0));
            return ex.getDmlMessage(0);
        }
        catch(Exception e) {
            if(!isDMLException){
                throw new AuraHandledException(e.getMessage());
                return e.getMessage();
            }
        }
        return returnValue;
    }
    
    /***********************************
    Method Name: cancelMethod
    Purpose:cancel method
    ***********************************/
    @AuraEnabled public static String cancelMethod(){
        //fetch for a product
        list<Product__C>prdLst = [SELECT ID from Product__c LIMIT 1];
        String prdId = prdLst[0].id;
        //return the first 3 digits of product ID to navigate to product list view
        String retVal = prdId.substring(0,3);
        return retVal;
    }
    
    
    
    //wrapper class for product pricing
    public class ProductWrapper{
        /* Ch# 1.1 
        * Any change in naming will affect Lightning bundle DGF_BulkRepricing(component,helper) 
        */
        @AuraEnabled public Id prodId{get;set;}
        @AuraEnabled public String prodName {get;set;}
        @AuraEnabled public String USESTTier{get;set;}
        @AuraEnabled public String CAESTTier{get;set;}
        @AuraEnabled public String US_HD_WSP{get;set;}
        @AuraEnabled public String US_SD_WSP{get;set;}
        @AuraEnabled public String US_UHD_WSP{get;set;}
        @AuraEnabled public String CA_HD_WSP{get;set;}
        @AuraEnabled public String CA_SD_WSP{get;set;}
        @AuraEnabled public String CA_UHD_WSP{get;set;}
        @AuraEnabled public String newUSESTTier{get;set;}
        @AuraEnabled public String newCAESTTier{get;set;}
        @AuraEnabled public list<String> usESTTierOpt =new list<String>();
        @AuraEnabled public list<String> caESTTierOpt =new list<String>();
        
        
        
    }
}