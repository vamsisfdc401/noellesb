/*****************************************************************************************
Class Name: DGF_TitleHierarchyController
Purpose: Controller for displaying related records on detail page for Series Record Type
******************************************************************************************
Version         DateModified         ModifiedBy                  Change
1.0             12/05/2017           Nandeesh                    Initial Development
******************************************************************************************/
public with sharing class DGF_TitleHierarchyController{
    
    
    /***********************************
    Method Name: fetchRelatedRecords
    Purpose: method to fetch related records
    ***********************************/    
    @AuraEnabled public static List<ProductPricingWrapper> fetchRelatedRecords(ID recordID) {
        try {
            Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
            Id seriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.SERIES).getRecordTypeId();
            Id tvRelRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
            
            //initializing variables
            Date todaysDate = System.Today();
            List<ProductPricingWrapper> lstProductPricingDetails = new List<ProductPricingWrapper>();            
            string usESTSDWSP = 'N/A';
            string usESTSDSRP = 'N/A';
            string usESTHDWSP = 'N/A';
            string usESTHDSRP = 'N/A';
            List<Product__c> lstProductDetails = new List<Product__c> ();
            List<Digital_Release__c> tvSeasonRelease = new List<Digital_Release__c>();
            Digital_Release__c currentRecord = new Digital_Release__c();
            Digital_Release__c dgDetails = new Digital_Release__c();
            List<Digital_Release__c> seriesDetails = new List<Digital_Release__c>();
            Digital_Release__c dgDetailsTV = new Digital_Release__c();
            
            List<Digital_Release__c> dgDetailsList = [Select Id, Name, RecordType.Name, RecordType.Id ,Series_Name__c from Digital_Release__c 
                                                      where Series_Name__c =: recordID or ID =: recordID];
            
            for (Digital_Release__c rel: dgDetailsList) {
                 if (rel.id == recordID && rel.RecordType.Id == seriesRecTypeId) {
                    dgDetails = rel;
                }
                else if(rel.RecordType.Id == tvRelRecTypeId ) {
                    dgDetailsTV = rel;
                }
                 
            }
            // For Series Digital Release
            if (dgDetails.RecordType.Id == seriesRecTypeId) {
                
                if (seriesDetails != null) {
                    tvSeasonRelease = seriesDetails != null ? seriesDetails : null ;
                }
                //getting product and pricing information
                if (!tvSeasonRelease.isEmpty()) {
                    lstProductDetails = [Select Id, name, Digital_Release__r.Name, Digital_Release__r.Season__c , 
                                         Digital_Release__r.of_Eps_in_Season_without_Bonus__c , 
                                         (Select Id, name, WSP__c, SRP__c, Territory__c, Resolution__c, Product__c, Platform__c, Price_Type__c,
                                          Valid_From__c, Valid_To__c FROM Pricing__r 
                                          WHERE Account__c = null 
                                          AND Platform__c=:DGF_Constants.PLATFORM_EST 
                                          AND (Price_Type__c =:DGF_Constants.ORIGINAL OR Price_Type__c =: DGF_Constants.REPRICE) 
                                           ) 
                                         FROM Product__c 
                                         WHERE RecordTypeId =: TVRecTypeId AND Digital_Release__c IN : tvSeasonRelease
                                         ORDER BY Digital_Release__r.season_Type__c ASC NULLS Last , Digital_Release__r.US_EST_Launch_Date__c DESC NULLS LAST ,
                                         Digital_Release__r.Season__c DESC NULLS Last];
                }
            }
            //For Tv Digital Release
            if (dgDetailsTV.RecordType.Id == tvRelRecTypeId ) {
                
                if (dgDetailsTV != null) {
                    currentRecord = dgDetailsTV != null && dgDetailsTV.Series_Name__c!=null ? dgDetailsTV : null; 
                }
                
                if (currentRecord != null){
                    lstProductDetails = [Select Id, Name, Digital_Release__r.Name, Digital_Release__r.Season__c ,
                                         Digital_Release__r.of_Eps_in_Season_without_Bonus__c ,
                                         (Select Id, name, WSP__c, SRP__c, Territory__c, Resolution__c, Product__c, Platform__c, Price_Type__c,
                                          Valid_From__c, Valid_To__c FROM Pricing__r WHERE Account__c = null 
                                          AND Platform__c=:DGF_Constants.PLATFORM_EST 
                                          AND (Price_Type__c =:DGF_Constants.ORIGINAL OR Price_Type__c =: DGF_Constants.REPRICE) 
                                           ) 
                                         FROM Product__c 
                                         WHERE RecordTypeId =: TVRecTypeId 
                                         AND Digital_Release__r.Series_Name__r.Id =: currentRecord.Series_Name__c
                                         ORDER BY Digital_Release__r.season_Type__c ASC  NULLS Last, Digital_Release__r.US_EST_Launch_Date__c DESC NULLS LAST ,
                                         Digital_Release__r.Season__c DESC NULLS Last];
                }
            }
            
            //if list not empty
            if (!lstProductDetails.isEmpty()) {
                //looping over product
                for (Product__c prd : lstProductDetails) {
                    
                    //setting default to N/A
                    usESTSDWSP = 'N/A';
                    usESTSDSRP = 'N/A';
                    usESTHDWSP = 'N/A';
                    usESTHDSRP = 'N/A';
                    
                    //looping over pricing records for the product
                    for (Pricing__c prc : prd.Pricing__r) {   
                        if (prc.Valid_To__c != null && prc.Valid_To__c < todaysDate) {
                            continue;
                        }
                        
                        //if territory is US
                        if (prc.Territory__c == DGF_Constants.TERRITORY_US) {
                            //for SD WSP 
                            if (prc.Resolution__c == DGF_Constants.SD && prc.WSP__c != null && 
                                (usESTSDWSP == 'N/A' || 
                                 (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTSDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for SD SRP 
                            if (prc.Resolution__c == DGF_Constants.SD && prc.SRP__c != null && 
                                (usESTSDSRP == 'N/A' || 
                                 (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))) {
                                usESTSDSRP = '$ ' + String.valueof((prc.SRP__c).setScale(2));
                            }
                            //for HD WSP 
                            if (prc.Resolution__c == DGF_Constants.HD && prc.WSP__c != null && 
                                (usESTHDWSP == 'N/A' || 
                                 (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTHDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for HD SRP 
                            if (prc.Resolution__c == DGF_Constants.HD && prc.SRP__c != null && 
                                (usESTHDSRP == 'N/A' || 
                                 (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTHDSRP = '$ ' + String.valueof((prc.SRP__c).setScale(2));
                            }
                        }  
                    }
                    //adding detials to the wrapper instance
                    lstProductPricingDetails.add(new ProductPricingWrapper(prd, usESTSDWSP, usESTSDSRP, usESTHDWSP, usESTHDSRP));
                }            
            }
            system.debug('lstProductPricingDetails'+ lstProductPricingDetails);
            return lstProductPricingDetails;
        }
        catch (exception ex) {   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }   
    }
    
    //wrapper class for mapping product and pricing records
    public class ProductPricingWrapper{
        @AuraEnabled public string releaseName{get;set;}
        @AuraEnabled public string releaseID{get;set;}
        @AuraEnabled public String seasonNumber{get;set;}
        @AuraEnabled public Decimal numberOfEpisode{get;set;}
        @AuraEnabled public string usESTSDWSP{get;set;}
        @AuraEnabled public string usESTSDSRP{get;set;}
        @AuraEnabled public string usESTHDWSP{get;set;}
        @AuraEnabled public string usESTHDSRP{get;set;}
        
        /***********************************
        Method Name: Constructor
        Purpose: constructor to wrap the Product with the Pricing
        ***********************************/
        public ProductPricingWrapper(Product__c prodDetail, string usESTSDWSPPrice, string usESTSDSRPPrice, String usESTHDWSPPrice, 
                                     String usESTHDSRPPrice){
            
            //defaulting variables based on parameter values
            releaseName = prodDetail.Digital_Release__r.Name;
            releaseID = prodDetail.Digital_Release__r.Id;
            seasonNumber = prodDetail.Digital_Release__r.Season__c;
            numberOfEpisode = prodDetail.Digital_Release__r.of_Eps_in_Season_without_Bonus__c;
            usESTSDWSP = usESTSDWSPPrice;
            usESTSDSRP = usESTSDSRPPrice;
            usESTHDWSP = usESTHDWSPPrice;
            usESTHDSRP = usESTHDSRPPrice;              
        }    
    }
}