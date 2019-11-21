/*****************************************************************************************
Class Name: GBSProduct_IPSelectionController
Purpose: Controller class for GBSProduct_IPSelection Lightning Component
Version : 1.0
Created Date : 05/66/2018
Created By : Harsha Polepalli
JIRA : GBS-55
******************************************************************************************/
public without sharing class GBSProduct_IPSelectionController {
    private static LMS__c lms;
    
    public class ProductWrapper {
        @AuraEnabled public String prodName;
        @AuraEnabled public String prodId;
        @AuraEnabled public String prodHierarchy;
        @AuraEnabled public Boolean isSelected;
    }
    
    public class IPWrapper {
        @AuraEnabled public String IPName;
        @AuraEnabled public String IPId;
        @AuraEnabled public Boolean isSelected;
    }
    /********************************************************
Method Name: loadLMSDetails
Purpose: Method to load LMS details on load of the lightning component
Parameters: Id
Return Type: LMS__c
*********************************************************/ 
    @AuraEnabled 
    public static LMS__c loadLMSDetails(Id LMSId) {
        lms = [Select Id, Contract__c, Contract__r.Name, Product_Rights_Group__c, Product_Rights_Group__r.Name, 
               Licensee__c, Licensee__r.Name From LMS__c Where Id =: LMSId];
        return lms;
    }
    /********************************************************
Method Name: loadRelatedProductRights
Purpose: Method to fetch Available Product Rights on page load
Parameters: List<Product_Right__c>
Return Type: List<Product_Right__c>
*********************************************************/ 
    @AuraEnabled 
    public static List<ProductWrapper> loadRelatedProductRights(String alreadySelectedProducts,Id ContractId) {
        
        Set<Id> productTypeIds = new Set<Id>();       
        List<ProductWrapper> productsList = new List<ProductWrapper>();
        
        List<ProductWrapper> alreadySelectedProductsData = (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(alreadySelectedProducts),
                                                                                                         List<GBSProduct_IPSelectionController.ProductWrapper>.class);
        
        for(ProductWrapper PW : alreadySelectedProductsData) {
            productTypeIds.add(PW.prodId);
        }
        
        List<Product_Right__c> productRightsList = [Select Id, Product_Type__c, Product_Type__r.Name, 
                                                    Product_Type__r.Parent_Category__r.Name, 
                                                    Product_Type__r.Level_1_Parent_Category__r.Name, 
                                                    Product_Type__r.Product_Hierarchy__c From Product_Right__c 
                                                    Where Product_Rights_Group__r.Contract__c =: ContractId AND 
                                                    Product_Type__c NOT IN : productTypeIds];
        
        Set<Id> productIds = new Set<Id>();
        for(Product_Right__c productRight : productRightsList) {          
            if(!productIds.contains(productRight.Product_Type__c)) {                                
                ProductWrapper PW = new ProductWrapper();
                PW.prodName = productRight.Product_Type__r.Name;
                PW.prodId = productRight.Product_Type__c;
                PW.prodHierarchy = productRight.Product_Type__r.Product_Hierarchy__c ;
                PW.isSelected = false;
                productsList.add(PW);
            }            
            productIds.add(productRight.Product_Type__c);
        }
         return productsList;
        
    }
    /********************************************************
Method Name: loadRelatedIPRights
Purpose: Method to fetch Available IP Rights on page load
Parameters: List<Intellectual_Property_Right__c>
Return Type: List<Intellectual_Property_Right__c>
*********************************************************/
    @AuraEnabled 
    public static List<IPWrapper> loadRelatedIPRights(String alreadySelectedProducts, 
                                                      String PRGId, 
                                                      LMS__c LMS) {
                                                          
                                                          Set<Id> selectedProductIds = new Set<Id>();
                                                          List<IPWrapper> IPList = new List<IPWrapper>();
                                                          
                                                          
                                                          List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(alreadySelectedProducts),
                                                                                                                                                   List<GBSProduct_IPSelectionController.ProductWrapper>.class);
                                                          
                                                          //  Collect all Product Ids which are already associated to LMS
                                                          for(ProductWrapper PW : productWrapperData ) {
                                                              
                                                              selectedProductIds.add(PW.prodId);
                                                          }
                                                          
                                                          
                                                          //  Fetches all the IP Rights associated to the PRGs of Contract of LMS, if no product is selected on screen1
                                                          String query = 'Select Id, Intellectual_Property__c, Intellectual_Property__r.Name ' + 
                                                              'From Intellectual_Property_Right__c ' + 
                                                              'Where Product_Rights_Group__r.Contract__c = \'' + LMS.Contract__c + '\'';
                                                          
                                                          //  Applies product filter, if any of Products selected in Screen1                
                                                          if(!selectedProductIds.isEmpty()) {
                                                              query += ' AND Product_Rights_Group__c IN ( Select Product_Rights_Group__c ' +
                                                                  'From Product_Right__c ' + 
                                                                  'Where Product_Type__c IN : selectedProductIds' + 
                                                                  ')';
                                                          }
                                                          
                                                          
                                                          Set<Id> IntellectualPropertyIds = new Set<Id>();
                                                          //  Get all Product Right Groups which has above products associated
                                                          
                                                          
                                                          for(Intellectual_Property_Right__c IPRight : (List<Intellectual_Property_Right__c>)database.query(query)) {
                                                              
                                                              if(!IntellectualPropertyIds.contains(IPRight.Intellectual_Property__c)) {
                                                                  IPWrapper IPW = new IPWrapper();
                                                                  IPW.IPName = IPRight.Intellectual_Property__r.Name;
                                                                  IPW.IPId = IPRight.Intellectual_Property__c;
                                                                  IPW.isSelected = false;
                                                                  IPList.add(IPW);
                                                              }
                                                              
                                                              IntellectualPropertyIds.add(IPRight.Intellectual_Property__c);
                                                          }
                                                          
                                                          return IPList;
                                                      }
    
    
    /********************************************************
Method Name: loadRelatedIPRights
Purpose: Method to fetch Available IP Rights on page load
Parameters: List<Intellectual_Property_Right__c>
Return Type: List<Intellectual_Property_Right__c>
*********************************************************/
    @AuraEnabled 
    public static List<IPWrapper> loadRelatedIPRightsUpdated(String alreadySelectedProducts, 
                                                             String PRGId, LMS__c LMS,String alreadySelectedIP) 
    {
        
        List<IPWrapper> IPList = new List<IPWrapper>();
        
        
        Set<Id> selectedProductIds = new Set<Id>();
        Set<Id> selectedIPIdSet = new Set<Id>();
        
        List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(alreadySelectedProducts),
                                                                                                 List<GBSProduct_IPSelectionController.ProductWrapper>.class);
        
        List<IPWrapper> ipWrapperData =  (List<IPWrapper>)System.JSON.deserialize(String.valueOf(alreadySelectedIP),
                                                                                  List<GBSProduct_IPSelectionController.IPWrapper>.class);                                             
        
        //  Collect all Product Ids which are already associated to LMS
        for(ProductWrapper PW : productWrapperData ) {          
            selectedProductIds.add(PW.prodId);
        }
        
        for(IPWrapper ipWrapperObj : ipWrapperData ) {          
            selectedIPIdSet.add(ipWrapperObj.IPId);
        }
        
        
        //  Fetches all the IP Rights associated to the PRGs of Contract of LMS, if no product is selected on screen1
        String query = 'Select Id, Intellectual_Property__c, Intellectual_Property__r.Name ' + 
            'From Intellectual_Property_Right__c ' + 
            'Where Product_Rights_Group__r.Contract__c = \'' + LMS.Contract__c + '\'';
        
        //  Applies product filter, if any of Products selected in Screen1                
        if(!selectedProductIds.isEmpty()) {
            query += ' AND Product_Rights_Group__c IN ( Select Product_Rights_Group__c ' +
                'From Product_Right__c ' + 
                'Where Product_Type__c IN : selectedProductIds' + 
                ')';
        }
        
        if(selectedIPIdSet != null && selectedIPIdSet.size() > 0)
        {
            query += ' AND Intellectual_Property__c NOT IN : selectedIPIdSet ';
        }
        
        
        Set<Id> IntellectualPropertyIds = new Set<Id>();
        //  Get all Product Right Groups which has above products associated
        
        for(Intellectual_Property_Right__c IPRight : (List<Intellectual_Property_Right__c>)database.query(query)) {
            
            if(!IntellectualPropertyIds.contains(IPRight.Intellectual_Property__c)) {
                IPWrapper IPW = new IPWrapper();
                IPW.IPName = IPRight.Intellectual_Property__r.Name;
                IPW.IPId = IPRight.Intellectual_Property__c;
                IPW.isSelected = false;
                IPList.add(IPW);
            }
            
            IntellectualPropertyIds.add(IPRight.Intellectual_Property__c);
        }
        
        return IPList;
    }
    
    /********************************************************
Method Name: loadSelectedProductRights
Purpose: Method to fetch already added Product Rights to LMS on page load
Parameters: List<Product_Right__c>
Return Type: List<Product_Right__c>
*********************************************************/
    @AuraEnabled
    public static List<ProductWrapper> loadSelectedProductRights(Id PRGId, LMS__c LMS) { 
        
        Set<Id> selectedProductIds = new Set<Id>(); 
        List<ProductWrapper> productsList = new List<ProductWrapper>();
        
        
        
        Set<Id> productTypeIdSet = new Set<Id>();
        for(GBS_LMS_Product__c LMSProd : [Select Id, GBS_Product_Type__c, GBS_Product_Type__r.Name,
                                          GBS_Product_Type__r.Product_Hierarchy__c
                                          From GBS_LMS_Product__c Where GBS_LMS__c =: LMS.Id]) 
        {
            //  Collect Product Ids
            if(!productTypeIdSet.contains(LMSProd.GBS_Product_Type__c))  
            {   
                ProductWrapper PW = new ProductWrapper();
                PW.prodName = LMSProd.GBS_Product_Type__r.Name;
                PW.prodId = LMSProd.GBS_Product_Type__c;
                PW.prodHierarchy = LMSProd.GBS_Product_Type__r.Product_Hierarchy__c ;
                PW.isSelected = true;
                productsList.add(PW);
            }
            productTypeIdSet.add(LMSProd.GBS_Product_Type__c) ;
        }
        
        return productsList;
    }
    /********************************************************
Method Name: loadSelectedIPRights
Purpose: Method to fetch already added IP Rights to LMS on page load
Parameters: List<Intellectual_Property_Right__c>
Return Type: List<Intellectual_Property_Right__c>
*********************************************************/
    @AuraEnabled
    public static List<IPWrapper> loadSelectedIPRights(Id PRGId, Id LMSId) {
        Set<Id> selectedIPIds = new Set<Id>();
        List<IPWrapper> IPList = new List<IPWrapper>();
        //  Iterate through IPs associated to LMS
        
        Set<Id> iPIdSet = new Set<Id>();
        for(GBS_LMS_IP__c LMSIP : [Select Id, GBS_Intellectual_Property__c, GBS_Intellectual_Property__r.Name 
                                   From GBS_LMS_IP__c Where GBS_LMS__c =: LMSId]) 
        {
            if(!iPIdSet.contains(LMSIP.GBS_Intellectual_Property__c))
            {
                
                //  Collect Product Ids
                iPIdSet.add(LMSIP.GBS_Intellectual_Property__c);
                IPWrapper IPW = new IPWrapper();
                IPW.IPName = LMSIP.GBS_Intellectual_Property__r.Name;
                IPW.IPId = LMSIP.GBS_Intellectual_Property__c;
                IPW.isSelected = true;
                IPList.add(IPW);
            }
        }
        
        return IPList;
    }
    /********************************************************
Method Name: getProductRights
Purpose: Method to search Product Rights
Parameters: List<Product_Right__c>
Return Type: List<Product_Right__c>
*********************************************************/
    @AuraEnabled 
    public static List<ProductWrapper> getProductRights(String selectedProducts,
                                                        String searchKey, 
                                                        String PRGId,
                                                        String contractId) 
    {
        
        
        
        
        List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(selectedProducts),
                                                                                                 List<GBSProduct_IPSelectionController.ProductWrapper>.class);
        
        Set<Id> productTypeSet = new Set<Id>();
        for(ProductWrapper productWrapperObj  : productWrapperData ) 
        {
            productTypeSet.add(productWrapperObj.prodId);
        } 
        
        Set<Id> productRightIdSet = new  Set<Id> ();
        for(Product_Right__c productRightObject : [select Id,Product_Type__c from Product_Right__c  where Product_Type__c IN : productTypeSet
                                                   AND Product_Rights_Group__r.Contract__c  =: contractId ])
        {
            productRightIdSet.add(productRightObject.Id);
        }                                         
        
        List<ProductWrapper> productsList = new List<ProductWrapper>();
        //Map<Id, Product_Right__c> selectedProductsMap = new map<Id, Product_Right__c>(selectedProducts);
        searchKey = '%' + searchKey + '%';
        
        //added by Lakshmi to display unique values while searching through product types
        Set<Id> productIds = new Set<Id>();
        
        for(Product_Right__c productRight :  [Select Id , Product_Type__r.Name, 
                                              Product_Type__r.Parent_Category__r.Name, 
                                              Product_Type__r.Level_1_Parent_Category__r.Name, 
                                              Product_Type__r.Product_Hierarchy__c From Product_Right__c 
                                              Where Product_Rights_Group__r.Contract__c =: contractId AND 
                                              (Product_Type__r.Product_Hierarchy__c LIKE : searchKey OR 
                                               Product_Type__r.Name LIKE : searchKey) AND 
                                              Id NOT IN : productRightIdSet])
        {
            if(!productIds.contains(productRight.Product_Type__c)) {
                ProductWrapper productWrapper= new ProductWrapper();
                productWrapper.prodName = productRight.Product_Type__r.Name;
                productWrapper.prodId = productRight.Product_Type__c;
                productWrapper.prodHierarchy = productRight.Product_Type__r.Product_Hierarchy__c ;
                productWrapper.isSelected = false;
                productsList.add(productWrapper);
            }
            productIds.add(productRight.Product_Type__c);
        }
        
        return productsList  ;   
    }
    /********************************************************
Method Name: getIPRights
Purpose: Method to search IP Rights
Parameters: List<Intellectual_Property_Right__c>
Return Type: List<Intellectual_Property_Right__c>
*********************************************************/
    @AuraEnabled 
    public static List<IPWrapper> getIPRights(String selectedIPRights, 
                                              String searchKey, 
                                              String PRGId,
                                              String contractId,
                                              String selectedProductGroup)
    {
        
        
        
        List<IPWrapper> ipWrapperData =  (List<IPWrapper>)System.JSON.deserialize(String.valueOf(selectedIPRights),
                                                                                  List<GBSProduct_IPSelectionController.IPWrapper>.class); 
        
        List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(selectedProductGroup),
                                                                                                 List<GBSProduct_IPSelectionController.ProductWrapper>.class); 
        
        //Map<Id, Intellectual_Property_Right__c> selectedIPRightsMap = new map<Id, Intellectual_Property_Right__c>(selectedIPRights);
        searchKey = '%' + searchKey + '%';
        
        
        Set<Id> productTypeIdSet = new Set<Id>();
        for(ProductWrapper ipRightObject : productWrapperData )
        {
            productTypeIdSet.add(ipRightObject.prodId);            
        }
        
        
        
        Set<Id> productGroupIdSet = new Set<Id>();
        for(Product_Right__c productRightObject : [select Id,Product_Type__c,Product_Rights_Group__c from Product_Right__c 
                                                   where Product_Type__c IN : productTypeIdSet ])
        {
            productGroupIdSet .add(productRightObject.Product_Rights_Group__c);
        } 
        
        Set<Id> intellectualPropertyIdSet = new Set<Id>();
        for(IPWrapper intPropertyWrapper : ipWrapperData )
        {
            intellectualPropertyIdSet.add(intPropertyWrapper.IPId);
        }
        
        Set<Id> ipRightIdSet = new Set<Id> ();
        for(Intellectual_Property_Right__c ipRightObj : [Select Id,Intellectual_Property__c,Product_Rights_Group__c
                                                         from Intellectual_Property_Right__c  where Intellectual_Property__c IN : intellectualPropertyIdSet
                                                         AND Product_Rights_Group__c IN : productGroupIdSet AND Product_Rights_Group__r.Contract__c  =: contractId])
        {
            ipRightIdSet.add(ipRightObj.ID);
        }
        
        
        List<IPWrapper> ipWrapperList = new List<IPWrapper>();
        
        
        List<Intellectual_Property_Right__c> ipRightList =  new List<Intellectual_Property_Right__c>();
        if(productGroupIdSet.size() > 0 )
        {
            ipRightList  = [Select Id , Intellectual_Property__r.Name 
                            From Intellectual_Property_Right__c Where 
                            Product_Rights_Group__r.Contract__c  =: contractId AND 
                            Product_Rights_Group__c IN : productGroupIdSet AND
                            Intellectual_Property__r.Name LIKE : searchKey AND 
                            Id NOT IN : ipRightIdSet] ;
        }else{
            ipRightList  = [Select Id , Intellectual_Property__r.Name 
                            From Intellectual_Property_Right__c Where 
                            Product_Rights_Group__r.Contract__c  =: contractId AND 
                            Intellectual_Property__r.Name LIKE : searchKey AND 
                            Id NOT IN : ipRightIdSet] ;
            
            
        }
        
        Set<Id> iPIdSet = new Set<Id>();
        for(Intellectual_Property_Right__c ipRightObject : ipRightList){           
            if(!iPIdSet.contains(ipRightObject.Intellectual_Property__c)) {                
                IPWrapper ipWrapperObject = new IPWrapper();
                ipWrapperObject.IPName     = ipRightObject.Intellectual_Property__r.Name ;
                ipWrapperObject.IPId       = ipRightObject.Intellectual_Property__c;//modified for GBS-783
                ipWrapperObject.isSelected =  false ;
                ipWrapperList.add(ipWrapperObject);
            }
             iPIdSet.add(ipRightObject.Intellectual_Property__c);           
        }
        
        return ipWrapperList  ;
    } 
    
    /********************************************************
Method Name: setLMSStatus
Purpose: Method to update LMS status once Products and IPs are associated to LMS
Parameters: Id
Return Type: void
*********************************************************/
    @AuraEnabled
    public static void setLMSStatus(String LMSId) {
        
        lms = [Select Id, LMS_Product_Detail__c, LMS_Status__c, LMS_IP__c, Contract__c, Product_Rights_Group__c 
               From LMS__c
               Where Id =: LMSId];
        //modified for GBS-774 
        if(LMS.LMS_IP__c != null && LMS.LMS_Product_Detail__c != null && LMS.LMS_Status__c != 'Active') {
            try {
                LMS.LMS_Status__c = 'Active';
                update LMS;                
            }catch(DmlException e) {
                //  Log exception                
                DGF_ExceptionLogController.createExceptionLog('While updating LMS Status picklist', 'GBSProduct_IPSelectionController.setLMSStatus', e.getMessage());
            }
            
        }
    }
    
    
    
    /**
Method Name: setLMSFlagonPRGUpdated
Purpose: Set the falg satus
Parameters: PRGId, selectedProducts, selectedIPs
Return Type: String
**/
    @AuraEnabled
    public static void setLMSFlagonPRGUpdated(String PRGId, List<ProductWrapper> selectedProducts, 
                                              List<IPWrapper> selectedIPs)
    {
        Set<Id> selectedProductTypeIds = new Set<Id>();
        Set<Id> selectedIPIds = new Set<Id>();
        
        //  Collect Product Type Ids from selectedProducts list
        for(ProductWrapper PR : selectedProducts) {
            selectedProductTypeIds.add(PR.prodId);
        }
        
        //  Collect IP Ids from selectedIPs list
        for(IPWrapper IPR : selectedIPs) {
            selectedIPIds.add(IPR.IPId);
        }
        
        //  Query Product Rights connected to the PRG's Contract and Product Type in selcted products
        List<Product_Right__c> productRights = [Select Id, Product_Rights_Group__c 
                                                From Product_right__c 
                                                Where Product_Rights_Group__r.Contract__c =: lms.Contract__c AND 
                                                Product_Rights_Group__c !=: PRGId AND 
                                                Product_Type__c IN : selectedProductTypeIds];
        
        Set<Id> flaggedPRGIds = new Set<Id>();
        //  Set LMS Flag on Product Rights with same Product Type but on differnet PRG related to the LMS's Contract 
        for(Product_Right__c PR : productRights) {
            PR.LMS_Flag__c = 'LMS Submitted';
            flaggedPRGIds.add(PR.Product_Rights_Group__c);
        }
        
        
        update productRights;
        
        
        //  Query IP Rights connected to the PRG's Contract and IP in selcted IPRights
        List<Intellectual_Property_Right__c> IPRights = [Select Id, Product_Rights_Group__c 
                                                         From Intellectual_Property_Right__c 
                                                         Where Product_Rights_Group__r.Contract__c =: lms.Contract__c AND 
                                                         Product_Rights_Group__c !=: PRGId AND 
                                                         Product_Rights_Group__c IN : flaggedPRGIds AND 
                                                         Intellectual_Property__c IN : selectedIPIds];
        
        //  Set LMS Flag on Product Rights with same Product Type but on differnet PRG related to the LMS's Contract 
        for(Intellectual_Property_Right__c IPR : IPRights) {
            IPR.LMS_Flag__c = 'LMS Submitted';
        }
        
        update IPRights;
    }
    
    /**
Method Name: saveSelectedProductsUpdated
Purpose: Method to save Product/IP selections made in component
Parameters: selectedProducts, selectedIPs, LMSId, PRGId
Return Type: String
**/
    @AuraEnabled
    public static String saveSelectedProductsUpdated(String selectedProducts, Id LMSId, Id PRGId) 
    {
        
        
        List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(selectedProducts),
                                                                                                 List<GBSProduct_IPSelectionController.ProductWrapper>.class);
        
        List<GBS_LMS_Product__c> LMSProductsToCreate = new List<GBS_LMS_Product__c>();
        Set<Id> existingProductIds = new Set<Id>();
        Set<Id> finalSetOfSelectedProducts = new Set<Id>();
        List<Product_Right__c> productRightsToUpdate = new List<Product_Right__c>();
        
        //  Iterate through Products associated to LMS
        for(GBS_LMS_Product__c LMSProd : [Select Id, GBS_Product_Type__c From GBS_LMS_Product__c Where GBS_LMS__c =: LMSId]) {
            //  Collect Product Ids
            existingProductIds.add(LMSProd.GBS_Product_Type__c); 
        }
        
        Set<Id> productTypeIdSet = new Set<Id>();
        for(ProductWrapper prodRight : productWrapperData) {
            productTypeIdSet.add(prodRight.prodId);
        }
        
        
        Set<Id> prodTypeIdSet = new Set<Id>();
        for(Product_Right__c prodRight : [select Id,LMS_Flag__c,Product_Type__c from Product_Right__c where 
                                          Product_Type__c IN : productTypeIdSet AND Product_Rights_Group__r.Contract__c =: loadLMSDetails(LMSId).Contract__c])
        {
            if(!prodTypeIdSet.contains(prodRight.Product_Type__c))
            {
                prodTypeIdSet.add(prodRight.Product_Type__c);
                if(!existingProductIds.contains(prodRight.Product_Type__c)) {
                    prodRight.LMS_Flag__c = 'LMS Submitted';
                    productRightsToUpdate.add(prodRight);
                    LMSProductsToCreate.add(new GBS_LMS_Product__c(GBS_LMS__c = LMSId, GBS_Product_Type__c = prodRight.Product_Type__c));
                }
                finalSetOfSelectedProducts.add(prodRight.Product_Type__c);
            }
        }
        //  Below statement gets all the existing products which are not part of the final set of selected products
        //  Means, some of the already selected products are removed and we have to delete their corresponding LMS Products 
        existingProductIds.removeAll(finalSetOfSelectedProducts);
        
        Set<Id> removedProductIds = new Set<Id>(existingProductIds);
        try {
            //  Deletes the associated LMS Products, if they are removed in UI
            try {
                
                
                delete [Select Id From GBS_LMS_Product__c Where GBS_Product_Type__c IN : removedProductIds AND GBS_LMS__c =: LMSId];
            }catch(Exception e){}
            
            
            //  Checks if removed products are present on any other LMS record, associated to the current LMS's Contract
            //Map<Id, Product_Type__c> LMSProducts = new Map<Id, GBS_LMS_Product__c>([Select Id, GBS_LMS__c From GBS_LMS_Product__c Where GBS_Product_Type__c IN : removedProductIds AND GBS_LMS__r.Contract__c =: loadLMSDetails(LMSId).Contract__c]);
            Map<Id, Product_Type__c> LMSProducts = new Map<Id, Product_Type__c>([Select Id From Product_Type__c Where Id IN (Select GBS_Product_Type__c From GBS_LMS_Product__c Where GBS_Product_Type__c IN : removedProductIds AND GBS_LMS__r.Contract__c =: loadLMSDetails(LMSId).Contract__c)]);
            
            
            for(Product_Right__c removedProduct : [Select Id, LMS_Flag__c, Product_Type__c From Product_Right__c Where Product_Type__c IN :  removedProductIds AND Product_Rights_Group__r.Contract__c =: loadLMSDetails(LMSId).Contract__c]) {
                
                
                if(!LMSProducts.containsKey(removedProduct.Product_Type__c)) {  //Make sure that the product is not associated to any other LMS
                    removedProduct.LMS_Flag__c = 'No LMS Submitted';
                    productRightsToUpdate.add(removedProduct);
                }
                else {
                    
                }
            }
            
            //  Associates new Products selected in UI to LMS
            
            insert LMSProductsToCreate;
            
            //  Update LMS Flag on the selected Product Rights
            
            
            update productRightsToUpdate;
            
            setLMSStatus(LMSId);
            
            setLMSFlagonPRGUpdated(PRGId, productWrapperData, new List<IPWrapper>());
            
            return 'Success';
        }catch(DmlException e) {
            return e.getDmlMessage(0); 
        }
    } 
    
    /**
Method Name: saveSelectedIPsUpdated
Purpose: Set the falg satus
Parameters: selectedIPs, LMSId,  PRGId
Return Type: String
**/
    @AuraEnabled
    public static String saveSelectedIPsUpdated(String selectedIPs, Id LMSId, Id PRGId) {
        
        
        List<IPWrapper> ipWrapperData =  (List<IPWrapper>)System.JSON.deserialize(String.valueOf(selectedIPs),
                                                                                  List<GBSProduct_IPSelectionController.IPWrapper>.class); 
        
        List<GBS_LMS_IP__c> LMSIPsToCreate = new List<GBS_LMS_IP__c>();
        Set<Id> existingIPIds = new Set<Id>();
        Set<Id> finalSetOfSelectedIPs = new Set<Id>();
        List<Intellectual_Property_Right__c> IPRightsToUpdate = new List<Intellectual_Property_Right__c>();
        
        //  Converting selectedIPs lits to map to comapare it easily makeout new IPs and already existing IPs
        //Map<Id, Intellectual_Property_Right__c> selectedIPsMap = new Map<Id, Intellectual_Property_Right__c>(selectedIPs);
        
        //  Iterate through IPs associated to LMS
        for(GBS_LMS_IP__c LMSIP : [Select Id, GBS_Intellectual_Property__c From GBS_LMS_IP__c Where GBS_LMS__c =: LMSId]) {
            //  Collect IP Ids
            existingIPIds.add(LMSIP.GBS_Intellectual_Property__c); 
        }
        
        Set<Id> intellectualPropertyIdSet = new Set<Id>();
        for(IPWrapper ipWrapperObj : ipWrapperData){
            intellectualPropertyIdSet.add(ipWrapperObj.IPId);
        }
        
        
        Set<Id> ipIdSet = new Set<Id>();
        for(Intellectual_Property_Right__c IPRight : [Select Id,Intellectual_Property__c,LMS_Flag__c from Intellectual_Property_Right__c where 
                                                      Intellectual_Property__c IN : intellectualPropertyIdSet AND 
                                                      Product_Rights_Group__r.Contract__c =:loadLMSDetails(LMSId).Contract__c])
        {
            if(!ipIdSet.contains(IPRight.Intellectual_Property__c))
            {
                ipIdSet.add(IPRight.Intellectual_Property__c);
                
                if(!existingIPIds.contains(IPRight.Intellectual_Property__c)) {
                    IPRight.LMS_Flag__c = 'LMS Submitted';
                    IPRightsToUpdate.add(IPRight);
                    LMSIPsToCreate.add(new GBS_LMS_IP__c(GBS_LMS__c = LMSId, GBS_Intellectual_Property__c = IPRight.Intellectual_Property__c));
                }
                
                finalSetOfSelectedIPs.add(IPRight.Intellectual_Property__c);
            }   
        }
        //  Below statement gets all the existing IPs which are not part of the final set of selected IPs
        //  Means, some of the already selected IPs are removed and we have to delete their corresponding LMS IPs 
        existingIPIds.removeAll(finalSetOfSelectedIPs);
        
        Set<Id> removedIPIds = new Set<Id>(existingIPIds);
        try {
            //  Deletes the associated LMS Products, if they are removed in UI
            try {
                delete [Select Id From GBS_LMS_IP__c Where GBS_Intellectual_Property__c IN : removedIPIds AND GBS_LMS__c =: LMSId];
            }catch(Exception e) {}
            
            //  Checks if removed products are present on any other LMS record, associated to the current LMS's Contract
            //Map<Id, GBS_LMS_IP__c> LMSIPs = new Map<Id, GBS_LMS_IP__c>([Select Id, GBS_LMS__c From GBS_LMS_IP__c Where GBS_Intellectual_Property__c IN : removedIPIds AND GBS_LMS__r.Contract__c =: loadLMSDetails(LMSId).Contract__c]);
            Map<Id, Intellectual_Property__c> LMSIPs = new Map<Id, Intellectual_Property__c>([Select Id From Intellectual_Property__c Where Id IN (Select GBS_Intellectual_Property__c From GBS_LMS_IP__c Where GBS_Intellectual_Property__c IN : removedIPIds AND GBS_LMS__r.Contract__c =: loadLMSDetails(LMSId).Contract__c)]);
            
            for(Intellectual_Property_Right__c removedIP : [Select Id, LMS_Flag__c, Intellectual_Property__c From Intellectual_Property_Right__c Where Intellectual_Property__c IN :  removedIPIds AND Product_Rights_Group__r.Contract__c =: loadLMSDetails(LMSId).Contract__c]) {
                if(!LMSIPs.containsKey(removedIP.Intellectual_Property__c)) {   //Checks whether the removed IP is associated to any other LMS corresponding to current LMS's Contract 
                    removedIP.LMS_Flag__c = 'No LMS Submitted';
                    IPRightsToUpdate.add(removedIP);
                }
            }
            
            
            //  Associates new Products selected in UI to LMS
            insert LMSIPsToCreate;
            
            
            //  Update LMS Flag on selected IP Rights
            update IPRightsToUpdate;
            
            return 'Success';
        }catch(DmlException e) {
            return e.getDmlMessage(0); 
        }
    }
    
    
    /**
Method Name: saveUpdated
Purpose: Set the falg satus
Parameters: selectedProducts, selectedIPs, LMSId, PRGId
Return Type: String
**/
    @AuraEnabled
    public static String saveUpdated(String selectedProducts, String selectedIPs, 
                                     String LMSId, String PRGId,String contactId)
    {
   
        List<ProductWrapper> productWrapperData =  (List<ProductWrapper>)System.JSON.deserialize(String.valueOf(selectedProducts),
                                                                                                 List<GBSProduct_IPSelectionController.ProductWrapper>.class);
        
        List<IPWrapper> ipWrapperData =  (List<IPWrapper>)System.JSON.deserialize(String.valueOf(selectedIPs),
                                                                                  List<GBSProduct_IPSelectionController.IPWrapper>.class); 
        
        String resp_IPSave = saveSelectedIPsUpdated(selectedIPs, LMSId, PRGId);
        String resp_ProdSave = saveSelectedProductsUpdated(selectedProducts, LMSId, PRGId);
        
        setLMSFlagonPRGUpdated(PRGId, productWrapperData, ipWrapperData);
        
        if(productWrapperData != null && productWrapperData.size() > 0 && LMSId != null && LMSId != '' && contactId != null && contactId != '')
        {
           updateConflictCheckOnPRAndIpMismatch(productWrapperData,ipWrapperData,LMSId,contactId);
        }   
        
        return resp_ProdSave == 'Success' && resp_IPSave == 'Success' ? 'Success' : resp_ProdSave + ' - ' + resp_IPSave;
    }
    
    
    @TestVisible
    private static void updateConflictCheckOnPRAndIpMismatch(List<ProductWrapper> productWrapperData, 
                                                             List<IPWrapper> ipWrapperData,
                                                             String LMSId,String contactId){
               
        Set<Id> productTypeIdSet = new Set<Id>();
        Set<Id> ipIdSet = new Set<Id>();
        Set<Id> productRightGroupIdSet = new  Set<Id> ();
        Map<ID,Map<Id,List<Intellectual_Property_Right__c>>> prgIdToPTIdToIPListMap = 
            new Map<ID,Map<Id,List<Intellectual_Property_Right__c>>> ();
        Map<Id,String> productTypeIdToProductTypeNameMAp = new Map<Id,String> ();
        
        for(ProductWrapper productWrapperObj :  productWrapperData){
            productTypeIdSet.add(productWrapperObj.prodId);
        }  
        
        for(IPWrapper ipWrapperObj :  ipWrapperData){
            ipIdSet.add(ipWrapperObj.IPId);
        }    
                
        Map<Id,String> ipIdToNameMap = getIPNameByIdMap(ipIdSet) ;
        
        for(Product_Right__c productRightObject : [Select Id,Product_Rights_Group__c,Product_Type__c,
                                                   Product_Type__r.name from Product_Right__c 
                                                   where Product_Type__c IN : productTypeIdSet AND 
                                                   Product_Rights_Group__r.Contract__c =:contactId ]){
                                                       
            productRightGroupIdSet.add(productRightObject.Product_Rights_Group__c);
            productTypeIdToProductTypeNameMAp.put(productRightObject.Product_Type__c , 
                                                  productRightObject.Product_Type__r.name);
        }  
        
        
        Map<Id,DateConflict> prgIdToDateMap =  new Map<Id,DateConflict>();
        Map<Id,List<Intellectual_Property_Right__c>> ptIdToIPObjListMap = new Map<Id,List<Intellectual_Property_Right__c>>();
        
        List<Product_Rights_Group__c>   productRightGroupObjectList = [select id,Name,Rights_Group_End_Date__c,
                                                                       Contract__r.Contract_End_Date__c,
                                                                       (select Id,Product_Type__c,Product_Type__r.Name 
                                                                        from Product_Rights__r where Product_Type__c IN : productTypeIdSet),
                                                                       (Select Id,Intellectual_Property__c,
                                                                        Intellectual_Property__r.name from 
                                                                        Intellectual_Property_Rights__r where Intellectual_Property__c IN : ipIdSet) from 
                                                                       Product_Rights_Group__c where 
                                                                       Contract__c =: contactId AND 
                                                                       Id IN : productRightGroupIdSet ] ;
        
        
        Map<Id,Set<Id>> productTypeIdToIpSetMap = new  Map<Id,Set<Id>>();
        
        for(Product_Rights_Group__c productRightGroupObject : productRightGroupObjectList){
            
            List<Product_Right__c> productRightList          = new List<Product_Right__c>();
            List<Intellectual_Property_Right__c> ipRightList = new List<Intellectual_Property_Right__c> () ;
            Set<Id> ipIdsSet = new Set<Id>(); 
            
            for(Product_Right__c prObj : productRightGroupObject.Product_Rights__r){
                productRightList.add(prObj);
            }
            for(Intellectual_Property_Right__c ipOject : productRightGroupObject.Intellectual_Property_Rights__r){
                ipRightList.add(ipOject);
                ipIdsSet.add(ipOject.Intellectual_Property__c);
            }
            
            
            if(productRightGroupObject.Rights_Group_End_Date__c <> null && 
               productRightGroupObject.Contract__r.Contract_End_Date__c <> null){
                   
                DateConflict dateConflictObject             =  new DateConflict ();
                dateConflictObject.productRightGroupEndDate =  productRightGroupObject.Rights_Group_End_Date__c ;
                dateConflictObject.contractEndDate          =  productRightGroupObject.Contract__r.Contract_End_Date__c ;
                dateConflictObject.productRightGroupName    =  productRightGroupObject.Name ;
                prgIdToDateMap.put(productRightGroupObject.Id , dateConflictObject );
            }   
            
            for(Product_Right__c prObj : productRightList){                
                if(ptIdToIPObjListMap.get(prObj.Product_Type__c) == null){
                    ptIdToIPObjListMap.put(prObj.Product_Type__c,ipRightList);
                    productTypeIdToIpSetMap.put(prObj.Product_Type__c,ipIdsSet);
                    
                }else{
                    List<Intellectual_Property_Right__c> ipRightObjList = ptIdToIPObjListMap.get(prObj.Product_Type__c) ;
                    ipRightObjList.addAll(ipRightList);
                    ptIdToIPObjListMap.put(prObj.Product_Type__c,ipRightObjList);
                    
                    productTypeIdToIpSetMap.get(prObj.Product_Type__c).addAll(ipIdsSet);
                }
                
            }
            
        }
                
        String conflictCheckField = '';
        
        for(ID ipId : ipIdSet){            
            Set<String> productNameSet = new Set<String> ();
            
            for(Id productTypeId : productTypeIdSet){                                                                                               
                if(ptIdToIPObjListMap.get(productTypeId) != null){
                    Set<Id> ipIdProductTypeSet = productTypeIdToIpSetMap.get(productTypeId);//new Set<Id>();
                    
                    if(!ipIdProductTypeSet.contains(ipId)){                        
                        productNameSet.add(productTypeIdToProductTypeNameMAp.get(productTypeId));
                    }                   
                }                       
            }
            
            if(productNameSet.size() > 0 ){              
                List<String> productNameList = new List<String> (productNameSet);
                conflictCheckField = conflictCheckField + ipIdToNameMap.get(ipId) +' - Not allowed to Produce: '+
                    String.join(productNameList,',') +'<br/>';
            }                   
        }
        
        for(Id prgId : productRightGroupIdSet){
            if(prgIdToDateMap.get(prgId) != null){
                DateConflict dateConflictObj =  prgIdToDateMap.get(prgId);
                
                if(dateConflictObj.productRightGroupEndDate != dateConflictObj.contractEndDate){
                    conflictCheckField  = conflictCheckField  + ' Different IP End Date: '+
                        dateConflictObj.productRightGroupName +' - '+
                        String.valueOf(dateConflictObj.productRightGroupEndDate.year() +'-'+
                                       dateConflictObj.productRightGroupEndDate.month() +'-'+
                                       dateConflictObj.productRightGroupEndDate.day())  +' , ';
                }
            }
        }
        if(ipIdSet.isEmpty()){
            conflictCheckField = '';
        }
        
        if(LMSId != null && LMSId != ''){
            createConflictTaskAndUpdateLMS(conflictCheckField ,LMSId);   
        }                                                                   
        
    }
    
    @TestVisible
    private static Map<Id,String> getIPNameByIdMap(Set<Id> ipIdSet)
    {
        
        Map<Id,String> ipIdToNameMap = new  Map<Id,String> ();
        for(Intellectual_Property__c ipRightObject : [Select Id,Name from Intellectual_Property__c where Id IN :ipIdSet ]){              
            ipIdToNameMap.put(ipRightObject.Id,ipRightObject.Name);
        }
        return ipIdToNameMap ;
    }
    
    @TestVisible
    private static void createConflictTaskAndUpdateLMS(String conflictCheckField ,String lmsId)
    {        
        LMS__c lmsObj = new LMS__C(Id= lmsId ,GBS_Conflict_Check_field__c=conflictCheckField  ) ; 
        lmsObj.GBS_Conflict_Check_field__c= conflictCheckField ;
        
        if(lmsObj <> null){
            if(conflictCheckField <> ''){
                Task taskObject    = new Task();
                taskObject.Subject = 'LMS Conflict';
                taskObject.ActivityDate = System.today();
                taskObject.Type         = 'New LMS'; 
                taskObject.WhatId       = lmsId ;
                
                insert taskObject ;
            }
            update lmsObj  ;            
        }        
    }
    
    public class DateConflict
    {
        @AuraEnabled public Date productRightGroupEndDate;
        @AuraEnabled public Date contractEndDate;
        @AuraEnabled public String productRightGroupName;
    }
    
}