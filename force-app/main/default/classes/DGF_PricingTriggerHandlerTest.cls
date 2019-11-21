/*****************************************************************************************
Class Name: DGF_PricingTriggerHandlerTest
Purpose: Test class for apex class DGF_PricingTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/05/2017           Jata               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_PricingTriggerHandlerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario1(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        //create Dogital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        list<Title__c>titleList=DGF_TestDataUtility.createTitle(2);
        insert titleList;
        Right__c rights=DGF_TestDataUtility.createRights(titleList[0].id, 'EST', 'CA', true);
        insert rights;
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        releaseList[0].title__c=titleList[0].id;
        insert releaseList;
        System.assert(releaseList!=null);
        
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.SD__c = false;
            prd.UHD__c = false;
            prd.X3D__c = false;
        }
        insert prdList;
        
        list<TM_Version__c>tmvList=DGF_testDataUtility.createTmVersion(1, titleList);
        insert tmvList;
        
        list<Product_Version__c>pvList=DGF_TestDataUtility.createProductVersion(1, prdList, tmvList);
        insert pvList;
        
        test.startTest();
        
        System.assert(prdList!=null);
        //querying Price List
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        
        Pricing__c prc1 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25);
        //inserting Pricing record
        //insert prc1;
        
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc2 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 25,Valid_To__c = date.today() - 15);
        //inserting Pricing record
        //insert prc2;
        
        List<Pricing__c> lstPriceInsert = new List<Pricing__c>();
        lstPriceInsert.add(prc1);
        lstPriceInsert.add(prc2);
        insert lstPriceInsert;
        System.assert(lstPriceInsert!=null);
        
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc3 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 65,Valid_To__c = date.today() - 35,Account__c='iTunes',SRP__c =4.99);
        //inserting Pricing record
        insert prc3;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prc3.SRP__c = 9.99;
        //updating Pricing record
        update prc3;
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario2(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id AccPromoRecTypeIdPrd = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
        //create Dogital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        list<Title__c>titleList=DGF_TestDataUtility.createTitle(2);
        insert titleList;
        Right__c rights=DGF_TestDataUtility.createRights(titleList[0].id, 'EST', 'CA', true);
        insert rights;
        List<Promotion__c> insertPromo = DGF_TestDataUtility.createPromotion(1,AccPromoRecTypeIdPrd);
        insert insertPromo;
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        releaseList[0].title__c=titleList[0].id;
        insert releaseList;
        System.assert(releaseList!=null);
        
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.SD__c = false;
            prd.UHD__c = false;
            prd.X3D__c = false;
        }
        insert prdList;
        //insert Promotion Product of existing Promotion
        List<Promotion_Product__c> insertPromotionProduct = DGF_TestDataUtility.createPromoProd(5,prdList[0].Id,insertPromo[0].Id);
        insert insertPromotionProduct;
        
        
        list<TM_Version__c>tmvList=DGF_testDataUtility.createTmVersion(1, titleList);
        insert tmvList;
        list<Product_Version__c>pvList=DGF_TestDataUtility.createProductVersion(1, prdList, tmvList);
        insert pvList;
        System.assert(prdList!=null);
        //querying Price List
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        test.startTest();
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc3 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Reprice',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 95,Valid_To__c = date.today() - 70,SRP__c =4.99);
        //inserting Pricing record
        insert prc3;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc4 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 65,Valid_To__c = date.today() - 35,Account__c='iTunes',SRP__c =4.99);
        //inserting Pricing record
        insert prc4;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prc4.SRP__c = 9.99;
        //updating Pricing record
        update prc4;
        try{
            //Inserting Duplicate pricing record
            Pricing__c prc5 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 55,Valid_To__c = date.today() - 35,Account__c='iTunes',SRP__c =4.99);
            //inserting Pricing record
            insert prc5;  
        }
        catch(Exception ex){
            System.debug('Uniqueness Error'+ex.getMessage());
        }
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario3
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario3(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        //create Digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        insert releaseList;
        System.assert(releaseList!=null);
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.US_Platform_Offering__c = null;
            prd.SD__c = false;
            prd.UHD__c = false;
            prd.X3D__c = false;
        }
        insert prdList;
        System.assert(prdList!=null);
        test.startTest();
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc1 = new Pricing__c(Name='CA EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25);
        //inserting Pricing record
        insert prc1;
        System.assert(prc1!=null);
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc2 = new Pricing__c(Name='CA EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 25,Valid_To__c = date.today() - 15);
        //inserting Pricing record
        insert prc2;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        try{
            //Inserting Duplicate pricing record
            Pricing__c prc3 = new Pricing__c(Name='CA EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 25,Valid_To__c = date.today() - 15);
            //inserting Pricing record
            insert prc3;  
        }
        catch(Exception ex){
            System.debug('Uniqueness Error'+ex.getMessage());
        }
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario4
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario4(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id TVPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        
        //create Digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        insert releaseList;
        System.assert(releaseList!=null);
        
        //create the Film products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.US_Platform_Offering__c = null;
        }
        insert prdList;
        System.assert(prdList!=null);
        //create the TV products
        list<Product__c> prdListTv=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdListTv){
            prd.RecordTypeID = TVPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.US_Platform_Offering__c = null;
        }
        insert prdListTv;
        System.assert(prdListTv!=null);
        Pricing__c prcTv = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdListTv[0].Id,SRP__c = 9.99);
        insert prcTv;
        Pricing__c prcRecForTV = [Select Id,WSP__c,SRP__c from Pricing__c where Id =: prcTv.Id];
        System.assertEquals((prcRecForTV.SRP__c*.7).setScale(2), prcRecForTV.WSP__c);
        prcTv.SRP__c = null;
        update prcTv;
        Pricing__c prcRecForTV1 = [Select Id,WSP__c,SRP__c from Pricing__c where Id =: prcTv.Id];
        System.assertEquals((prcRecForTV.WSP__c/.7).setScale(2), prcRecForTV.SRP__c);
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        test.startTest();
        List<Pricing__c> priceList = new List<Pricing__c>();
        Pricing__c prc1 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='TPR National',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25,SRP__c = 9.99,Valid_To__c = date.today().addMonths(7));
        //inserting Pricing record of TPR price type
        priceList.add(prc1); 
        //insert prc1;
        System.assert(prc1!=null);
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        
        Pricing__c prc2 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='TPR National',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today().addMonths(10),SRP__c = 9.99,Valid_To__c = date.today().addMonths(20));
        //inserting Pricing record of TPR price type
       priceList.add(prc2);
        //insert prc2;
        insert priceList;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prc2.SRP__c = null;
        //updating Pricing record of TPR price type
        update prc2;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prc2.SRP__c = 11.99;
        //updating Pricing record of TPR price type
        update prc2;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc3 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='TPR National',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today().addMonths(7),SRP__c = 9.99,Valid_To__c = date.today().addMonths(19));
        //inserting Pricing record of TPR price type
        insert prc3;
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario5
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario5(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id TVPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        
        //create Digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        insert releaseList;
        System.assert(releaseList!=null);
        
        //create the Film products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.US_Platform_Offering__c = null;
        }
        insert prdList;
        System.assert(prdList!=null);
        test.startTest();
        //create the TV products
        list<Product__c> prdListTv=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdListTv){
            prd.RecordTypeID = TVPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.US_Platform_Offering__c = null;
        }
        insert prdListTv;
        System.assert(prdListTv!=null);
        Pricing__c prcTv = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdListTv[0].Id,SRP__c = 9.99);
        insert prcTv;
        Pricing__c prcRecForTV = [Select Id,WSP__c,SRP__c from Pricing__c where Id =: prcTv.Id];
        System.assertEquals((prcRecForTV.SRP__c*.7).setScale(2), prcRecForTV.WSP__c);
        prcTv.SRP__c = null;
        update prcTv;
        Pricing__c prcRecForTV1 = [Select Id,WSP__c,SRP__c from Pricing__c where Id =: prcTv.Id];
        System.assertEquals((prcRecForTV.WSP__c/.7).setScale(2), prcRecForTV.SRP__c);
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc4 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='CA', Price_Type__c ='TPR National',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today().addMonths(7),SRP__c = 9.99,Valid_To__c = date.today().addMonths(19));
        //inserting Pricing record of TPR price type
        insert prc4;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prc4.SRP__c = 11.99;
        //updating Pricing record of TPR price type
        update prc4;
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario6
    Purpose: method to test update chatter notification
    ***********************************/
    static testMethod void scenario6() {
        
        //getting record type id
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();   
        Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('National Promotion').getRecordTypeId(); 
        Id filmRecType = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
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
        
        Pricing__c prc1 = new Pricing__c(Name='US EST HD WSP TPR', Resolution__c='HD', Territory__c='US', Price_Type__c = DGF_Constants.TPR_National,Promotion__c = insertPromoNational[0].Id, 
                                         Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25, WSP__c = 12.00, SRP__c = 12.00);
        
        insert prc1;
        
        test.startTest();
        //updating pricing
        Pricing__c pr = new Pricing__c();
        pr.WSP__c = 43.00;
        pr.SRP__c = 49.00;
        pr.Id = prc1.Id;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        update pr;
        
        //query for the pricing of the promoproduct
        list<Pricing__c> priceList = [SELECT ID, Valid_From__c from pricing__c where promotion__c =: promoProd.promotion__c and product__c =: promoProd.product__c];
        //assert that the valid from is equal to the TPR Start Date
        System.assertEquals(TRUE, priceList != null);
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario7
    Purpose: method to test update chatter notification for Bundle Products
    ***********************************/    
    static testMethod void scenario7(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id BundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id AccountRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
        
        //create Digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        list<Title__c>titleList=DGF_TestDataUtility.createTitle(2);
        insert titleList;
        Right__c rights=DGF_TestDataUtility.createRights(titleList[0].id, 'EST', 'CA', true);
        insert rights;
        DGF_triggerUtility.isTestRunning = false;
        releaseList[0].US_Physical_Street_Date__c = date.today(); 
        releaseList[0].CA_Physical_Street_Date__c = date.today();
        releaseList[0].US_iTunes_Price_Date__c = date.today(); 
        releaseList[0].CA_iTunes_Price_Date__c = date.today();
        releaseList[0].title__c=titleList[0].id;
        insert releaseList;
        System.assert(releaseList!=null);
        
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeID = FilmPrdRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.SD__c = false;
            prd.UHD__c = false;
            prd.X3D__c = false;
        }
        insert prdList;
        List<Promotion__c> insertPromoAccount = DGF_TestDataUtility.createPromotion(1,AccountRecTypeId);
        insert insertPromoAccount;
        
        //insert promotion products
        Promotion_Product__c promoProd = new Promotion_Product__c(Promotion__c = insertPromoAccount[0].id, Product__c = prdList[0].id);
        insert promoProd;
        
        list<TM_Version__c>tmvList=DGF_testDataUtility.createTmVersion(1, titleList);
        insert tmvList;
        
        list<Product_Version__c>pvList=DGF_TestDataUtility.createProductVersion(1, prdList, tmvList);
        insert pvList;
        
        //create the Bundle products
        list<Product__c> prdListBundle=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        for(Product__c prd : prdListBundle){
            prd.RecordTypeID = BundleRecTypeId;
            prd.CA_Platform_Offering__c = null;
            prd.SD__c = false;
            prd.UHD__c = false;
            prd.X3D__c = false;
        }
        insert prdListBundle;
        
        list<Product_Version__c>pvListBundle=DGF_TestDataUtility.createProductVersion(1, prdListBundle, tmvList);
        insert pvListBundle;
        boolean hasPrice = false;
        
        test.startTest();
        
        System.assert(prdList!=null);
        //querying Price List
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        
        Pricing__c prc1 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Reprice',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25);
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc2 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Reprice',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 25,Valid_To__c = date.today() - 15);
        //inserting Pricing record
        //insert prc2;
        
        List<Pricing__c> lstPriceInsert = new List<Pricing__c>();
        lstPriceInsert.add(prc1);
        lstPriceInsert.add(prc2);
        try{
            insert lstPriceInsert;
        }
        catch(exception ex){
        }        
        System.assert(lstPriceInsert!=null);
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc3 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Reprice',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 65,Valid_To__c = date.today() - 35,SRP__c =4.99);
        //inserting Pricing record
        try{
            insert prc3;
            //Enabling trigger
            DGF_TriggerUtility.executePricingTrigger=true;
            DGF_TriggerUtility.sobjectExecutedEvents.clear();
            prc3.SRP__c = 9.99;
            //updating Pricing record
            update prc3;
        }
        catch(exception ex){
        }        
        test.stopTest();
    }    
}