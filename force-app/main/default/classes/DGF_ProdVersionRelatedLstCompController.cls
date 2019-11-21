/*****************************************************************************************
Class Name: DGF_ProdVersionRelatedLstCompController
Purpose: Controller for displaying related records on detail page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/06/2017           Mohit                    Initial Development
******************************************************************************************/
public with sharing class DGF_ProdVersionRelatedLstCompController{
    
    /***********************************
    Method Name: fetchRelatedRecords
    Purpose: method to fetch related records
    ***********************************/    
    @AuraEnabled public static List<ProductPricingWrapper> fetchRelatedRecords(ID recordID){
        try{
            //initializing variables
            Date todaysDate = System.Today();
            List<ProductPricingWrapper> lstProductPricingDetails = new List<ProductPricingWrapper>();            
            string usESTHDWSP = 'N/A';
            string usESTSDWSP = 'N/A';
            string usESTUHDWSP = 'N/A';
            string usEST3DWSP = 'N/A';
            string caESTHDWSP = 'N/A';
            string caESTSDWSP = 'N/A';
            string caESTUHDWSP = 'N/A';
            string caEST3DWSP = 'N/A';
            boolean isLeadTitle = FALSE;
            Set<ID> setVersionID = new Set<ID>();
            Set<ID> setProdID = new Set<ID>();
            Map<Id,Product_Version__c> mapProductDetails = new Map<Id,Product_Version__c>();
            List<Product__c> lstProductDetails = new List<Product__c>();
            Map<Id,Boolean> mapLeadTitle = new Map<Id,Boolean>();
            
            //getting product versions for the bundle product
            List<Product_Version__c> lstProdVersion = [Select id,Product__c,TM_Version__c,Lead_Title__c from Product_Version__c where Product__c =:recordID];
            
            //if list not empty
            if(!lstProdVersion.isEmpty()){
                //creating a set of all version id for the product
                for(Product_Version__c pv : lstProdVersion){
                    if(!setVersionID.contains(pv.TM_Version__c)){
                        setVersionID.add(pv.TM_Version__c);
                        mapLeadTitle.put(pv.TM_Version__c,pv.Lead_Title__c);
                    }
                }
            }
            
            //if version id set not empty
            if(!setVersionID.isEmpty()){
                //getting all product version related to version with FILM product
                List<Product_Version__c> lstPrdVersion = [Select id,Product__c,Product__r.Name,TM_Version__c,Lead_Title__c,createdDate from Product_Version__c where TM_Version__c in:setVersionID AND Product__r.RecordType.Name =: DGF_Constants.FILM order by createdDate ASC];
                
                //if list not empty
                if(!lstPrdVersion.isEmpty()){
                    Set<ID> tempVersionId = new Set<Id>();
                    
                    //looping over product versions
                    for(Product_Version__c pv : lstPrdVersion){                     
                        //only latest instance will be added for a version
                        if(!tempVersionId.contains(pv.TM_Version__c)){
                            tempVersionId.add(pv.TM_Version__c);
                            
                            //adding details to map with product Id as key and instance of product version as value
                            mapProductDetails.put(pv.Product__c,pv);                            
                        }                       
                    }                   
                }
            }
            
            //getting pricing details for all the film products
            if(!mapProductDetails.isEmpty()){
                //getting product and pricing information
                lstProductDetails = [Select id,name,(Select id,name,WSP__c,Territory__c,Resolution__c,Product__c,Platform__c,Price_Type__c,Valid_From__c, Valid_To__c from Pricing__r where Account__c = null AND Platform__c=:DGF_Constants.PLATFORM_EST AND (Price_Type__c =:DGF_Constants.ORIGINAL OR Price_Type__c =: DGF_Constants.REPRICE) Order by Valid_From__c ASC) from product__c where Id in :mapProductDetails.keySet()];
            }
            
            //if list not empty
            if(!lstProductDetails.isEmpty()){
                                
                //looping over product
                for(Product__c prd : lstProductDetails){
                    
                    //setting default to N/A
                    usESTHDWSP = 'N/A';
                    usESTSDWSP = 'N/A';
                    usESTUHDWSP = 'N/A';
                    usEST3DWSP = 'N/A';
                    caESTHDWSP = 'N/A';
                    caESTSDWSP = 'N/A';
                    caESTUHDWSP = 'N/A';
                    caEST3DWSP = 'N/A';
                    isLeadTitle = FALSE;
                    
                    //looping over pricing records for the product
                    for(Pricing__c prc : prd.Pricing__r){
                        
                        //if valid to date of price is less than todays date then it is a expired record so continue
                        if(prc.Valid_To__c != null && prc.Valid_To__c < todaysDate){
                            continue;
                        }
                        
                        //if territory is US
                        if(prc.Territory__c == DGF_Constants.TERRITORY_US){
                            //for SD resolution
                            if(prc.Resolution__c == DGF_Constants.SD && prc.WSP__c != null && (usESTSDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTSDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for HD resolution
                            else if(prc.Resolution__c == DGF_Constants.HD && prc.WSP__c != null && (usESTHDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTHDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for UHD resolution
                            else if(prc.Resolution__c == DGF_Constants.UHD && prc.WSP__c != null && (usESTUHDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usESTUHDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for 3D resolution
                            else if(prc.Resolution__c == DGF_Constants.X3D && prc.WSP__c != null && (usEST3DWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                usEST3DWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                        }  
                        //if territory is CA
                        else if(prc.Territory__c == DGF_Constants.TERRITORY_CA){
                            //for SD resolution
                            if(prc.Resolution__c == DGF_Constants.SD && prc.WSP__c != null && (caESTSDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                caESTSDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for HD resolution
                            else if(prc.Resolution__c == DGF_Constants.HD && prc.WSP__c != null && (caESTHDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                caESTHDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for UHD resolution
                            else if(prc.Resolution__c == DGF_Constants.UHD && prc.WSP__c != null && (caESTUHDWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                caESTUHDWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                            //for 3D resolution
                            else if(prc.Resolution__c == DGF_Constants.X3D && prc.WSP__c != null && (caEST3DWSP == 'N/A' || (prc.Valid_From__c <= todaysDate && (prc.Valid_To__c == null || prc.Valid_To__c >=todaysDate)))){
                                caEST3DWSP = '$ ' + String.valueof((prc.WSP__c).setScale(2));
                            }
                        }                       
                    } 
                    
                    
                    //adding detials to the wrapper instance
                    lstProductPricingDetails.add(new ProductPricingWrapper(prd,usESTHDWSP,usESTSDWSP,usESTUHDWSP,usEST3DWSP,caESTHDWSP,caESTSDWSP,caESTUHDWSP,caEST3DWSP,mapLeadTitle.get(mapProductDetails.get(prd.Id).TM_Version__c)));
                }               
            }
            
            return lstProductPricingDetails;
        }
        catch(exception ex){
            System.Debug('Error @@@ '+ex.getMessage());   
            throw new AuraHandledException(ex.getMessage());
            return null;        
        }        
    }
    
    //wrapper class for mapping product and pricing records
    public class ProductPricingWrapper{
        @AuraEnabled public string productName {get;set;}
        @AuraEnabled public string productID {get;set;}
        @AuraEnabled public string usESTHDWSP{get;set;}
        @AuraEnabled public string usESTSDWSP{get;set;}
        @AuraEnabled public string usESTUHDWSP{get;set;}
        @AuraEnabled public string usEST3DWSP{get;set;}
        @AuraEnabled public string caESTHDWSP{get;set;}
        @AuraEnabled public string caESTSDWSP{get;set;}
        @AuraEnabled public string caESTUHDWSP{get;set;}
        @AuraEnabled public string caEST3DWSP{get;set;}
        @AuraEnabled public boolean isLeadTitle{get;set;}
                
        public ProductPricingWrapper(Product__c prodDetail, string usESTHDPrice, string usESTSDPrice, String usESTUHDPrice, String usEST3DPrice, string caESTHDPrice, string caESTSDPrice, String caESTUHDPrice, String caEST3DPrice,boolean leadTitle){
            isLeadTitle = FALSE;
            
            //defaulting variables based on parameter values
            productName = prodDetail.Name;
            productID = prodDetail.ID;
            usESTHDWSP = usESTHDPrice;
            usESTSDWSP = usESTSDPrice;
            usESTUHDWSP = usESTUHDPrice;
            usEST3DWSP = usEST3DPrice;
            caESTHDWSP = caESTHDPrice;
            caESTSDWSP = caESTSDPrice;
            caESTUHDWSP = caESTUHDPrice;
            caEST3DWSP = caEST3DPrice;    
            isLeadTitle = leadTitle;
        }    
    }
}