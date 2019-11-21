/***********************************************************************************
Class Name: DGF_PromotionTriggerHandlerTest
Purpose: Test class for apex class DGF_PromotionTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/05/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_PromotionTriggerHandlerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-37
    ***********************************/
    static testMethod void scenario1() {
        //getting record type id
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();   
        Id filmRecType = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();   
        
        //getting list of EPOBonus records to be created
        List<Promotion__c> insertPromo = DGF_TestDataUtility.createPromotion(10,AccountRecTypeId);
        
        //creating account
        Account acc = new Account(Name = 'Account');
        insert acc;
        
        //insert the promotion record
        insert insertPromo;
        
        //insert promotion account
        Promotion_Account__c pa = new Promotion_Account__c(Account__c = acc.id, start_date__c = date.today(), Promotion__c = insertPromo[0].id);
        insert pa;
        
        //insert digital release
        list<Digital_Release__c> releaseList = DGF_TestDataUtility.createDigitalRelease(1, filmRecType);
        insert releaseList;
        
        //insert products
        list<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(1, releaseList);
        insert prdList;
        
        //insert promotion products
        Promotion_Product__c promoProd = new Promotion_Product__c(Promotion__c=insertPromo[0].id, Product__c=prdList[0].id);
        insert promoProd;
        
        //query the created digital date records
        list<digital_date__c> digiDateList = [select id from digital_date__C where promotion__c =:insertPromo[0].id];
        System.assertEquals(2, digiDateList.size());
        
        test.startTest();
            //updating the dates of the promotion
            insertPromo[0].start_date__c=date.today()+1;
            insertPromo[0].end_date__c=date.today()+1;
            update insertPromo[0];
            delete insertPromo[0];
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test deletion of digital dates when start and end dates are cleard out
    ***********************************/
    static testMethod void scenario2() {
        
        //getting record type id
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();   
        
        //insert the promotion record
        List<Promotion__c> insertPromo = DGF_TestDataUtility.createPromotion(1,AccountRecTypeId);
        insert insertPromo;
        
        test.startTest();
            //clear out the start and end date values
            insertPromo[0].start_date__c = null;
            insertPromo[0].end_date__c = null;
        
            //update the promotion
            update insertPromo[0];
        
            //verify that the digital dates are deleted
            list<Digital_Date__c> digDate = [SELECT ID from Digital_Date__c where Promotion__c=:insertPromo[0].id];        
            System.assertEquals(0, digDate.size());
            
            DGF_TriggerUtility.sobjectExecutedEvents.clear();
            Promotion__c promo = new Promotion__c(Name = 'Promo1', RecordTypeid = AccountRecTypeId);
            insert promo;
            
            promo.Start_Date__c = date.today();
            update promo;    
        test.stopTest();        
    }
    
    /***********************************
    Method Name: scenario3
    Purpose: method to test chatter notifications
    ***********************************/
    static testMethod void scenario3() {
        
        //getting record type id
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();   
        Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();   
        
        //insert the promotion record
        List<Promotion__c> insertPromoNational = DGF_TestDataUtility.createPromotion(1,NationalRecTypeId);
        insert insertPromoNational;
        
        List<Promotion__c> insertPromoAccount = DGF_TestDataUtility.createPromotion(1,AccountRecTypeId);
        insertPromoAccount[0].National_Offering_TPR__c = insertPromoNational[0].Id;
        insert insertPromoAccount;
        
        test.startTest();
            //clear out the start and end date values
            insertPromoNational[0].start_date__c = Date.Today() + 10;
            insertPromoNational[0].end_date__c = Date.Today() + 20;
            update insertPromoNational;
            
            insertPromoNational[0].start_date__c = null;
            insertPromoNational[0].end_date__c = null;
            update insertPromoNational;
        
            //verify that the digital dates are deleted
            list<Digital_Date__c> digDate = [SELECT ID from Digital_Date__c where Promotion__c =: insertPromoNational[0].id];        
            System.assertEquals(2, digDate.size());
            
            delete insertPromoNational;
        test.stopTest();        
    }
    
     /***********************************
    Method Name: scenario4
    Purpose: method to test scenario for DFOR-1097
    ***********************************/
    static testMethod void scenario4() {
        Id FreeEpisodeRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
        Id TVRelrecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        //insert the promotion record
        List<Promotion__c> freeEpiPromo = DGF_TestDataUtility.createPromotion(1,FreeEpisodeRecTypeId);
        insert freeEpiPromo;
        System.AssertEquals( TRUE , freeEpiPromo[0].id != null , 'Free episode promotion Record not Created');
        
        //Create a TV Digital Release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, TVRelrecTypeId);
        insertdgtlRels[0].Free_First_Episode_Start_Date__c = date.today();
        insertdgtlRels[0].Free_First_Episode_End_Date__c = date.today() + 1;
        insert insertdgtlRels;
        System.AssertEquals( TRUE , insertdgtlRels[0].id != null , 'Digital Release Record not Created');
        
        //Create TV Product
        List<Product__c> insertProd =  DGF_TestDataUtility.createCustomProduct(1, insertdgtlRels);
        insertProd[0].recordTypeId = TVProdRecTypeId;
        insert insertProd;
        System.AssertEquals( TRUE , insertProd[0].id != null , 'TV Product Record not Created');
        
        //Create a Promotion Product Record
        Promotion_Product__c promoProd = new Promotion_Product__c (Promotion__c = freeEpiPromo[0].id, Product__c = insertProd[0].id);
        insert promoProd;
        System.AssertEquals( TRUE , promoProd.id != null , 'Promotion Product Record not Created');
        
        test.startTest();
        //update the sync flag to true
        freeEpiPromo[0].Sync_Free_First_Episode_Dates__c =true;
        update freeEpiPromo[0];
        //the promotion start date is synced with free episode start date
        System.assertEquals(date.today(), freeEpiPromo[0].start_date__c, 'Free episode dates not synced');
        test.stopTest();
    }
}