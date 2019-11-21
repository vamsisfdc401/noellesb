/*****************************************************************************************
Class Name: GBSLMSProductTriggerHandler
Purpose: Handler class for GBSLMSProductTrigger
Version : 1.0
Date Created : 05/09/2018
Created By : Harsha Vardhan P
Modified By :Lakshmi (For GBS-546)
JIRA : GBS-30
******************************************************************************************/
public class GBSLMSProductTriggerHandler {
    /********************************************************
    Method Name: setProductNamesOnLMS
    Purpose: Method to Insert records into Contract_Agent_Contact__c junction object.
    Parameters: Map<Id, GBS_LMS_Product__c>
    Return Type: void
    *********************************************************/ 
    public static void setProductNamesOnLMS(Map<Id, GBS_LMS_Product__c> LMSProducts) {
        Set<Id> LMSIds = new Set<Id>();
        Set<Id> factoryIds = new Set<Id>();
        Map<Id, String> LMSIdToProductsMap = new Map<Id, String>();
        List<LMS__c> LMSRecordsToUpdate = new List<LMS__c>();
        List<Factory__c> factoryToUpdate = new List<Factory__c>();
        
        //  Collect LMS Ids from LMS Products
        for(GBS_LMS_Product__c LMSProduct : LMSProducts.values()) {
            LMSIds.add(LMSProduct.GBS_LMS__c);            
        }
        
        //  Query and iterate all LMS Products associated to the LMS Ids collected above
        for(GBS_LMS_Product__c LMSProduct : [Select Id, GBS_Product_Type__r.Name, GBS_LMS__c, GBS_LMS__r.Factory__c From GBS_LMS_Product__c Where GBS_LMS__c IN : LMSIds]) {
            factoryIds.add(LMSProduct.GBS_LMS__r.Factory__c);
            //  Prepare a map with LMS Id as key and assoictaed Product Names with comma separated as value
            String prodNames = LMSProduct.GBS_Product_Type__r.Name;
            
            if(LMSIdToProductsMap.containsKey(LMSProduct.GBS_LMS__c)) {
                //  Proceed only if the string(which is stored into Product Details field of LMS) length is not exceeding 10000
                if(!LMSIdToProductsMap.get(LMSProduct.GBS_LMS__c).endsWith('...')) {
                    //  If string length exceeds 10000 after adding another product Name, just add ellipsis at the end
                    if((LMSIdToProductsMap.get(LMSProduct.GBS_LMS__c) + ',' + prodNames).length() >= 10000)
                        prodNames = LMSIdToProductsMap.get(LMSProduct.GBS_LMS__c) + '...';
                    else
                        prodNames = LMSIdToProductsMap.get(LMSProduct.GBS_LMS__c) + ',' + prodNames;
                }
            }
                
            LMSIdToProductsMap.put(LMSProduct.GBS_LMS__c, prodNames);
        }
        
        for(LMS__c lms : [Select Id, Factory__c from LMS__c where Id IN: LMSIds]){
            if(factoryIds.isEmpty()){                
                factoryIds.add(lms.Factory__c);
            }
        }
        
        //  Update LMS records with the concatenated Product Names
        for(Id LMSId : LMSIds) {
            LMS__c lms = new LMS__c();            
            if(LMSIdToProductsMap.containsKey(LMSId)){ 
                lms = new LMS__c(Id = LMSId, LMS_Product_Detail__c = LMSIdToProductsMap.get(LMSId));
            }
            else{
                lms = new LMS__c(Id = LMSId, LMS_Product_Detail__c = null);
            }
            LMSRecordsToUpdate.add(lms);
        }
        
        if(!LMSRecordsToUpdate.isEmpty()){
            update LMSRecordsToUpdate;
        }       
        
        
        //added for GBS-546        
        Map<Id,String> submittedProductDetailMap = new Map<Id,String>();
        Map<Id,List<LMS__c>> lmsFactoryMap = new Map<Id,List<LMS__c>>();        
        
        for(Factory__c factory : [Select Id, Submitted_Product_Details__c,(select id, LMS_Product_Detail__c from LMS__r) From Factory__c Where Id IN: factoryIds]){
            submittedProductDetailMap.put(factory.Id,factory.Submitted_Product_Details__c);
            lmsFactoryMap.put(factory.Id,factory.LMS__r);              
        }
               
        for(Id factoryId: submittedProductDetailMap.keyset()){            
            String lmsProductDetailsFactory = '';
            if(factoryId != null){
                String lmsProductDetails = '';
                for(LMS__c lms : lmsFactoryMap.get(factoryId)){
                    if(lms.LMS_Product_Detail__c != null){
                        lmsProductDetails =  lms.LMS_Product_Detail__c + ','+ lmsProductDetails;
                    }                   
                }
               
                Set<String> lmsProductDetailsSet = new Set<String>();
                Set<String> submittedProductDetailsSet = new Set<String>();
                String submittedProductDetails = submittedProductDetailMap.get(factoryId);
                
                if(String.isNotEmpty(lmsProductDetails)){                     
                    lmsProductDetailsSet = new Set<String>(lmsProductDetails.split(','));
                }                
                
                if(String.isNotEmpty(submittedProductDetails)){
                    submittedProductDetailsSet = new Set<String>(submittedProductDetails.split(',')); 
                }
                                
                for(String lmsProdDetail : lmsProductDetailsSet){                   
                    if(!submittedProductDetailsSet.contains(lmsProdDetail)){                        
                        submittedProductDetailsSet.addAll(lmsProductDetailsSet);
                    }                   
                }
                
                if(!lmsProductDetailsSet.isEmpty()){
                List<String> submittedProductDetailsList = new List<String>(lmsProductDetailsSet);
                factoryToUpdate.add(new Factory__c(Id = factoryId, 
                                                   Submitted_Product_Details__c = String.join(submittedProductDetailsList,',')));
                }
            }
        }
        
        try {
            //  Perform DML on LMS 
            if(!factoryToUpdate.isEmpty()){               
                update factoryToUpdate;
            }
        }catch(DMLException e) {
            //  Log exception
            DGF_ExceptionLogController.createExceptionLog('While creating new LMS Product', 'GBSLMSProductTriggerHandler', e.getMessage());
        }
    }
}