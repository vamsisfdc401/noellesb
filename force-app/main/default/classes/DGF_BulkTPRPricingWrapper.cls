/*****************************************************************************************
Class Name: DGF_BulkTPRPricingWrapper
Purpose: Wrapper classes for Bulk TPR Pricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             04/08/2017           Prarthana                Initial Development
******************************************************************************************/
public with sharing class DGF_BulkTPRPricingWrapper {
    //wrapper class for mapping product and pricing records
    public class ProductPricingWrapper {
        @AuraEnabled public string productName {get;set;}
        @AuraEnabled public string productID {get;set;}
        @AuraEnabled public string productRecTypeID {get;set;} //DFOR-1506
        @AuraEnabled public string promoID{get;set;}
        @AuraEnabled public string id{get;set;}
	@AuraEnabled public String promoTerr{get;set;} //DFOR-1504
        @AuraEnabled public Date stDate{get;set;}
        @AuraEnabled public Date endDate{get;set;}
        @AuraEnabled public String prdUSPlatform{get;set;}
        @AuraEnabled public String prdCAPlatform{get;set;}
        @AuraEnabled public Boolean prdSD{get;set;}
        @AuraEnabled public Boolean prdHD{get;set;}
        @AuraEnabled public Boolean prdUHD{get;set;}
        @AuraEnabled public Boolean prd3D{get;set;}
        @AuraEnabled public string usESTSDWSP{get;set;}
        @AuraEnabled public string usESTHDWSP{get;set;}
        @AuraEnabled public string usESTUHDWSP{get;set;}
        @AuraEnabled public string caESTSDWSP{get;set;}
        @AuraEnabled public string caESTHDWSP{get;set;}
        @AuraEnabled public string caESTUHDWSP{get;set;}
		@AuraEnabled public string usEST3DWSP{get;set;}
        @AuraEnabled public string caEST3DWSP{get;set;}
		
		@AuraEnabled public string usESTSDSRP{get;set;}
        @AuraEnabled public string usESTHDSRP{get;set;}
        @AuraEnabled public string usESTUHDSRP{get;set;}
        @AuraEnabled public string caESTSDSRP{get;set;}
        @AuraEnabled public string caESTHDSRP{get;set;}
        @AuraEnabled public string caESTUHDSRP{get;set;}
		@AuraEnabled public string usEST3DSRP{get;set;}
        @AuraEnabled public string caEST3DSRP{get;set;}
		
		@AuraEnabled public string usVODSDWSP{get;set;}
        @AuraEnabled public string usVODHDWSP{get;set;}
        @AuraEnabled public string usVODUHDWSP{get;set;}
        @AuraEnabled public string caVODSDWSP{get;set;}
        @AuraEnabled public string caVODHDWSP{get;set;}
        @AuraEnabled public string caVODUHDWSP{get;set;}
		@AuraEnabled public string usVOD3DWSP{get;set;}
        @AuraEnabled public string caVOD3DWSP{get;set;}
		
		@AuraEnabled public string usVODSDSRP{get;set;}
        @AuraEnabled public string usVODHDSRP{get;set;}
        @AuraEnabled public string usVODUHDSRP{get;set;}
        @AuraEnabled public string caVODSDSRP{get;set;}
        @AuraEnabled public string caVODHDSRP{get;set;}
        @AuraEnabled public string caVODUHDSRP{get;set;}
		@AuraEnabled public string usVOD3DSRP{get;set;}
        @AuraEnabled public string caVOD3DSRP{get;set;}
		
        @AuraEnabled public String usESTSDID{get;set;}
        @AuraEnabled public String usESTHDID{get;set;}
        @AuraEnabled public String usESTUHDID{get;set;}
        @AuraEnabled public String usEST3DID{get;set;}
        @AuraEnabled public String caESTSDID{get;set;}
        @AuraEnabled public String caESTHDID{get;set;}
        @AuraEnabled public String caESTUHDID{get;set;}
        @AuraEnabled public String caEST3DID{get;set;}
        
        @AuraEnabled public String usVODSDID{get;set;}
        @AuraEnabled public String usVODHDID{get;set;}
        @AuraEnabled public String usVODUHDID{get;set;}
        @AuraEnabled public String usVOD3DID{get;set;}
        @AuraEnabled public String caVODSDID{get;set;}
        @AuraEnabled public String caVODHDID{get;set;}
        @AuraEnabled public String caVODUHDID{get;set;}
        @AuraEnabled public String caVOD3DID{get;set;}
        @AuraEnabled public Integer hasTPRPrices{get;set;}
        @AuraEnabled public String msg{get;set;}
        
        public ProductPricingWrapper(){
        	hasTPRPrices=0;
        }
    }
    
    //Wrapper to display the pricing TPR dropdown
    public class TPRPricingWrapper{
        @AuraEnabled public list<String> priceType = new list<String>();
        @AuraEnabled public String priceVal{get;set;}
        @AuraEnabled public String selectedPriceType{get;set;}
        
        public TPRPricingWrapper(){
            priceType.add('US EST SD WSP TPR');
            priceType.add('US EST SD SRP TPR');
            priceType.add('US EST HD WSP TPR');
            priceType.add('US EST HD SRP TPR');
            priceType.add('US EST UHD WSP TPR');
            priceType.add('US EST UHD SRP TPR');
            priceType.add('US EST 3D WSP TPR');
            priceType.add('US EST 3D SRP TPR');
            
            priceType.add('US VOD SD WSP TPR');
            priceType.add('US VOD SD SRP TPR');
            priceType.add('US VOD HD WSP TPR');
            priceType.add('US VOD HD SRP TPR');
            priceType.add('US VOD UHD WSP TPR');
            priceType.add('US VOD UHD SRP TPR');
            priceType.add('US VOD 3D WSP TPR');
            priceType.add('US VOD 3D SRP TPR');
            
            priceType.add('CA EST SD WSP TPR');
            priceType.add('CA EST SD SRP TPR');
            priceType.add('CA EST HD WSP TPR');
            priceType.add('CA EST HD SRP TPR');
            priceType.add('CA EST UHD WSP TPR');
            priceType.add('CA EST UHD SRP TPR');
            priceType.add('CA EST 3D WSP TPR');
            priceType.add('CA EST 3D SRP TPR');
            
            priceType.add('CA VOD SD WSP TPR');
            priceType.add('CA VOD SD SRP TPR');
            priceType.add('CA VOD HD WSP TPR');
            priceType.add('CA VOD HD SRP TPR');
            priceType.add('CA VOD UHD WSP TPR');
            priceType.add('CA VOD UHD SRP TPR');
            priceType.add('CA VOD 3D WSP TPR');
            priceType.add('CA VOD 3D SRP TPR');          
        }
    }
}