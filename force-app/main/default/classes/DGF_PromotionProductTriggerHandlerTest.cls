/***********************************************************************************
Class Name: DGF_PromotionProductTriggerHandlerTest
Purpose: Test class for apex class DGF_PromotionProductTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/07/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)

public class DGF_PromotionProductTriggerHandlerTest {
    static list<Promotion__c> promoList {get;set;}
    static list<Promotion_Product__c> promoPrd {get;set;}
    
    /***********************************
     Method Name: scenario1
     Purpose: method to test update of Pricing records on update of TPR Dates
    ***********************************/
    static testMethod void scenario1() {
        //method to create Data
        createData();
        
        test.startTest();
            //update the TPR Start and end dates of promotion product
            promoPrd[0].tpr_start_date__c = date.today()-1;
            promoPrd[0].tpr_end_date__c = date.today();
            update promoPrd[0];
            
            //query for the pricing of the promoproduct
            list<Pricing__c> priceList = [SELECT ID, Valid_From__c from pricing__c where promotion__c =: promoPrd[0].promotion__c and product__c =: promoPrd[0].product__c];
            //assert that the valid from is equal to the TPR Start Date
            System.assertEquals(date.today()-1, priceList[0].valid_from__c);
        test.stopTest();
    }
    
    /***********************************
     Method Name: scenario2
     Purpose: method to test update chatter notification
    ***********************************/
    static testMethod void scenario2() {
        
        //getting record type id
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();   
        Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId(); 
        Id filmRecType = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        
        //create national promotion
        List<Promotion__c> insertPromoNational = DGF_TestDataUtility.createPromotion(1,NationalRecTypeId);
        insert insertPromoNational;
        
        //create account promotion
        List<Promotion__c> insertPromoAccount = DGF_TestDataUtility.createPromotion(1,AccountRecTypeId);
        insertPromoAccount[0].National_Offering_TPR__c = insertPromoNational[0].Id;
        insert insertPromoAccount;
        
        //insert digital release
        list<Digital_Release__c> releaseList = DGF_TestDataUtility.createDigitalRelease(1, filmRecType);
        insert releaseList;
        
        //insert products
        list<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(1, releaseList);
        insert prdList;
        
        //insert promotion products
        Promotion_Product__c promoProd = new Promotion_Product__c(Promotion__c = insertPromoNational[0].id, Product__c = prdList[0].id);
        insert promoProd;
        
        test.startTest();
            //update the TPR Start and end dates of promotion product
            promoProd.tpr_start_date__c = date.today()-1;
            promoProd.tpr_end_date__c = date.today() + 100;
            update promoProd;       
            
            //query for the pricing of the promoproduct
            list<Pricing__c> priceList = [SELECT ID, Valid_From__c from pricing__c where promotion__c =: promoProd.promotion__c and product__c =: promoProd.product__c];
            //assert that the valid from is equal to the TPR Start Date
            System.assertEquals(TRUE, priceList != null);
            
            //delete promotion product
            delete promoProd;
        test.stopTest();
    }
    
    /***********************************
     Method Name: createData
     Purpose: method to create Data
    ***********************************/
    static void createData() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        
        //create digital release
        list<Digital_Release__c> releaseList = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insert releaseList;
        //create products associated to release
        list<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(1, releaseList);
        insert prdList;
        
        prdlist[0].Us_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
        prdlist[0].CA_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
        prdList[0].recordTypeId = FilmPrdRecTypeId;
        prdList[0].est_tier__c = DGF_Constants.NEW_RELEASE_STANDARD;
        prdList[0].ca_est_tier__c = DGF_Constants.NEW_RELEASE_STANDARD;
        update prdlist[0];
        
        Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId(); 
        promoList = DGF_TestDataUtility.createPromotion(1, AccRecTypeId);
        insert promoList;
        
        Pricing__c price = new Pricing__c(Product__c = prdList[0].id, Promotion__c = promoList[0].id, Price_Type__c = DGF_Constants.TPR_Account, Territory__c = 'US', Platform__c = 'EST', Resolution__c = 'SD', WSP__c = 20);
        insert price;
        
        promoPrd = DGF_TestDataUtility.createPromoProd(1, prdlist[0].id, promoList[0].id);
        insert promoPrd;
    }
}