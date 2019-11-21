/***********************************************************************************
Class Name: DGF_RepricingNotificationBatchTest
Purpose: DFOR-417 - Test Class for DGF_RepricingNotificationBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/11/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData=TRUE)

public class DGF_RepricingNotificationBatchTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-417
    ***********************************/
    static testMethod void scenario1() {
        
        User usr = DGF_TestDataUtility.createUser('System Administrator','TestConnectedBatchPromotionProduct@product.com','Test');
        system.runAs(usr){
            Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
            Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
            Id AccPromoId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
            //create Dogital release
            list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
            insert releaseList;
            System.assert(releaseList[0] != null);
            //create the products
            list<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(10, releaseList);
            for(Product__c prd : prdList){
                prd.RecordTypeId = FilmPrdRecTypeId;
            }
            insert prdList;
            System.assertEquals(10, prdList.size());
            //create a Promotion
            list<Promotion__c>promoList = DGF_TestDataUtility.createPromotion(1, AccPromoId);
            insert promoList;
            //creating a pricing record
            Pricing__c reprice = new Pricing__c(Territory__c='US',Platform__c = 'EST', Resolution__c = 'SD' , valid_from__c = date.today()+1 , 
                                              Product__c = prdList[0].id , Promotion__c = PromoList[0].id , Price_Type__c = 'Reprice');
            insert reprice;
            list<Promotion_Product__c>promoPrdList = DGF_TestDataUtility.createPromoProd(1,prdList[0].id,promoList[0].id);
            insert promoPrdList;
        
        test.startTest();
            //run the batch
            DGF_RepricingNotificationBatch btch = new DGF_RepricingNotificationBatch();
            database.executebatch(btch,200);
             //Scheduling
            DGF_RepricingNotificationScheduler sched = new DGF_RepricingNotificationScheduler();
            String sch = '0 0 23 * * ?';
            system.schedule('Test Job', sch, sched);
        test.stopTest();    
    }
    }
}