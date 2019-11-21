/*****************************************************************************************
Class Name: GBSLMSProductTriggerTest
Purpose: Test class for GBSLMSProductTrigger and it's handler
Version : 1.0
Date Created : 05/18/2018
Created By : Harsha Vardhan P
JIRA : GBS-278
******************************************************************************************/
@isTest
private class GBSLMSProductTriggerTest {

	private static testMethod void LMSProduct_Create() {
        GBSTriggerManager__c GBSLMSProductTrigger = new GBSTriggerManager__c();
		GBSLMSProductTrigger.Name = 'GBSLMSProductTrigger'; 
        GBSLMSProductTrigger.GBSDisable__c = true; 
		insert GBSLMSProductTrigger;
        
	    Product_Type__c product = new Product_Type__c(Name = 'Test Product Type');
	    insert product;
	    
        List<Factory__c> factoryList = GBSTestDataUtility.createFactory(1);        
        insert factoryList;
        
	    LMS__c LMS = new LMS__c();
        LMS.Factory__c = factoryList[0].Id;
	    insert LMS;
	    
        GBS_LMS_Product__c LMSProduct = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct1 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct2 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct3 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct4 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct5 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct6 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct7 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct8 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct9 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct10 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        insert new List<GBS_LMS_Product__c>{LMSProduct, LMSProduct1, LMSProduct2, LMSProduct3, LMSProduct4, LMSProduct5, LMSProduct6, LMSProduct7, LMSProduct8, LMSProduct9, LMSProduct10};
        
        delete [Select Id From GBS_LMS_Product__c];
	}

    
    private static testMethod void LMSProduct_Create1() {
               
	    Product_Type__c product = new Product_Type__c(Name = 'Test Product Type');
	    insert product;
	    
        List<Factory__c> factoryList = GBSTestDataUtility.createFactory(2);        
        insert factoryList;
        
	    LMS__c LMS = new LMS__c();
        LMS.Factory__c = factoryList[0].Id;
	    insert LMS;
	    
        GBS_LMS_Product__c LMSProduct = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct1 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct2 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct3 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct4 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct5 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct6 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct7 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct8 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct9 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        GBS_LMS_Product__c LMSProduct10 = new GBS_LMS_Product__c(GBS_LMS__c = LMS.Id, GBS_Product_Type__c = product.Id);
        insert new List<GBS_LMS_Product__c>{LMSProduct, LMSProduct1, LMSProduct2, LMSProduct3, LMSProduct4, LMSProduct5, LMSProduct6, LMSProduct7, LMSProduct8, LMSProduct9, LMSProduct10};
        
        delete [Select Id From GBS_LMS_Product__c];
	}

}