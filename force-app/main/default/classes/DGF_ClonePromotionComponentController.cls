/*****************************************************************************************
Class Name: DGF_ClonePromotionComponentController
Purpose: Controller for cloning promotion records
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/13/2017           Mohit                    Initial Development
******************************************************************************************/
public without sharing class DGF_ClonePromotionComponentController{  
    
    /**private instance**/
    private static Id recordTypeAccountPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
    private static Id recordTypeNationalPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
    
    /***********************************
	Method Name: getPromotionType
	Purpose: get promotion record type
	***********************************/
    @AuraEnabled public static string getPromotionType(String recordId,Boolean isCloneProcess) {
        //returning record type          
        Promotion__c promotion = [Select id, recordType.name from Promotion__c where id=:recordId];    
        
        //if clone process then return as is 
        if (isCloneProcess) {
            return promotion.recordType.Name;
        }		
        //if not then it means user is trying to add account promotion
        else {
            return DGF_Constants.ACCOUNT_PROMOTION;
        }               
    }
    
    /***********************************
	Method Name: getUserAccess
	Purpose: get user access for creating clone record
	***********************************/
    @AuraEnabled public static string getUserAccess(String recordId, Boolean isCloneProcess) {
        //returning record type          
        Promotion__c promotion = [Select id, recordType.name, recordtypeId from Promotion__c where id =: recordId];    
        
        //getting user details
        User u = [Select id, Profile.Name from User where Id =: userinfo.getUserId()];
        
        //if admin profile
        if (u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN) {
            return null;
        }
        //if account user doing cloning
        else if (u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER && isCloneProcess && recordTypeAccountPromotion == promotion.recordtypeId) {
            return null;
        }
        //if product user cloning
        else if (u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER && isCloneProcess && recordTypeNationalPromotion == promotion.recordtypeId) {
            return null;
        }
        //if account user adding national promotion
        else if (u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER && !isCloneProcess && recordTypeNationalPromotion == promotion.recordtypeId) {
            return null;
        }
        //otherwise return error
        else {
            return 'User does not have required access to perform the operation.';
        }        
    }
    
    /***********************************
	Method Name: clonePromotionRecord
	Purpose: method to clone promotion record
	***********************************/
    @AuraEnabled public static Promotion__c clonePromotionRecord(String recordId, Boolean isCloneProcess) {
        try{
            //intializing variables            
            Promotion__c clonedPromotionInsance = new Promotion__c();
            String soqlPromotion;           
            Promotion__c promotionDetails = new Promotion__c();
            
            //if record id is not null
            if (recordId != null) {        
                //getting all creatable fields for promotion
                soqlPromotion = getCreatableFieldsSOQL('Promotion__c','Id =: recordId');       
                
                //querying promotion details
                promotionDetails = Database.Query(soqlPromotion);
                
                //cloning promotion instance
                clonedPromotionInsance = promotionDetails.clone(); 
                
                //if add account promotion then setting record type to account promotion id 
                if (!isCloneProcess) {
                    clonedPromotionInsance.RecordTypeId = recordTypeAccountPromotion;
                    clonedPromotionInsance.National_Offering_TPR__c = promotionDetails.Id;
                }                
            }
            
            //returning cloned promotion record
            return clonedPromotionInsance ;
        }
        catch (DMLException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
            return null;
        }
        catch (exception ex) {
            throw new AuraHandledException(ex.getMessage());
            return null;
        }        
    }
    
    /***********************************
	Method Name: saveClonedPromotionRecord
	Purpose: method to save clone promotion record
	***********************************/
    @AuraEnabled public static string saveClonedPromotionRecord(String promotionInstance, String recordId, string strNationalTPROffering, Boolean isCloneProcess) {
        try{
            //initializing variables
            List<Promotion_Product__c> lstPromotionProducts = new List<Promotion_Product__c>();
            List<Pricing__c> lstPricing = new List<Pricing__c>();
            List<Promotion_Product__c> lstClonedPromotionProducts = new List<Promotion_Product__c>();
            List<Pricing__c> lstClonedPricing = new List<Pricing__c>();
            Set<Id> setProductId = new Set<Id>();
            String soqlProdPromotion;
            String soqlPricing;
            
            //deserializing JSON
            Promotion__c insertPromotion = (Promotion__c)System.JSON.deserialize(promotionInstance,Promotion__c.class);
            
            //inserting promotion record
            DGF_TriggerUtility.isCloningProcess = TRUE;
            
            if (strNationalTPROffering != null && strNationalTPROffering != '') {
                insertPromotion.National_Offering_TPR__c = strNationalTPROffering;
            }
            
            insert insertPromotion;
            
            //if record id is not null
            if (recordId != null) {
                //getting all creatable fields for product promotion
                soqlProdPromotion = getCreatableFieldsSOQL('Promotion_Product__c','Promotion__c =: recordId'); 
                
                //querying promotion products
                lstPromotionProducts = Database.Query(soqlProdPromotion);
                
                //if list of promotion products not empty
                if (!lstPromotionProducts.isEmpty()) {
                    for (Promotion_Product__c pp : lstPromotionProducts) {
                        //cloning product promotion record
                        Promotion_Product__c clonedPP = pp.clone();
                        
                        //setting id to new promotion
                        clonedPP.Promotion__c = insertPromotion.Id;
                        clonedPP.TPR_Start_Date__c = insertPromotion.Start_Date__c;
                        clonedPP.TPR_End_Date__c = insertPromotion.End_Date__c;
                        clonedPP.Collection_Start_Date__c = insertPromotion.Start_Date__c;
                        clonedPP.Collection_End_Date__c = insertPromotion.End_Date__c;
                        
                        //creating a set of products
                        setProductId.add(pp.Product__c);
                        
                        //adding to list to be inserted
                        lstClonedPromotionProducts.add(clonedPP);
                    }                   
                }
                
                //if product set not empty
                if (!setProductId.isEmpty()) {
                    //getting all createable fields for pricing
                    soqlPricing = getCreatableFieldsSOQL('Pricing__c','Promotion__c =: recordId AND Product__c in:setProductId'); 
                    
                    //querying pricing records
                    lstPricing = Database.Query(soqlPricing);
                    
                    //if list not empty
                    if (!lstPricing.isEmpty()) {
                        for (Pricing__c prc : lstPricing) {
                            //cloning pricing record
                            Pricing__c price = prc.clone();
                            
                            //setting id to new promotion
                            price.Promotion__c = insertPromotion.Id;
                            
                            price.Valid_From__c = insertPromotion.Start_Date__c;
                            price.Valid_To__c = insertPromotion.End_Date__c;
                            
                            //if add account promotion then setting record type to account promotion id 
                            if (!isCloneProcess) {
                                price.Price_Type__c = DGF_Constants.PRICE_TPR_ACCOUNT;
                            }
                            
                            //adding to list to be inserted
                            lstClonedPricing.add(price);
                        }
                    }
                }
                
                //inserting product promotion
                if (!lstClonedPromotionProducts.isEmpty()) {
                    insert lstClonedPromotionProducts;
                }
                
                //inserting pricing
                if (!lstClonedPricing.isEmpty()) {
                    DGF_TriggerUtility.isCloningProcess = TRUE;
                    insert lstClonedPricing;
                }
            }
            
            return string.valueof(insertPromotion.Id);
        }
        catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
            return null;
        }
        catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
            return null;
        }        
    }
    
    /***********************************
	Method Name: getCreatableFieldsSOQL
	Purpose: get all createable fields
	***********************************/
    public static string getCreatableFieldsSOQL(String objectName, String whereClause) {
        String selects = '';
        
        if(whereClause == null || whereClause == ''){
            return null;
        }
        
        //get a map of field names and field tokens
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();
        
        if (fMap!=null) {
			//loop through all field tokens (ft)	
            for (Schema.SObjectField ft : fMap.values()) { 
				//describe each field (fd)
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
				//field is creatable
                if (fd.isCreateable() && fd.getName() != 'OwnerId') { 
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()) {
            for (string s: selectFields) {
                selects += s + ',';
            }
            
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }                      
        }
        
        if ((selects == null || selects == '') && objectName == 'Pricing__c') {
            selects = 'Name,CurrencyIsoCode,Product__c,Category__c,Platform__c,Price_Type__c,Resolution__c,SRP__c,Territory__c,Valid_From__c,Valid_To__c,WSP__c,Promotion__c,Account__c,iTunes_Tier__c';
        } 
        else if ((selects == null || selects == '') && objectName == 'Promotion__c') {
            selects = 'Name,CurrencyIsoCode,RecordTypeId,Comments__c,Description__c,End_Date__c,Film_TV__c,National_Offering_TPR__c,Promotion_Type__c,Start_Date__c,TPR_Approval_Status__c,Tags__c,Territory__c,US_Platform_Offering__c,CA_Platform_Offering__c';
        } 
        else if ((selects == null || selects == '') && objectName == 'Promotion_Product__c') {
            selects = 'CurrencyIsoCode,Product__c,Promotion__c,Collection_End_Date__c,Collection_Start_Date__c,Collection__c,TPR_End_Date__c,TPR_Start_Date__c,TPR__c';
        }  
        
        return 'SELECT ' + selects+ ' FROM ' + objectName + ' WHERE ' + whereClause;
    }    
}