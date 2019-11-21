@isTest
private class DGF_BundlePriceController_Test {
	static testmethod void methodOne(){
		 DGF_BundlePriceController.pricingWrapper priceWrap = new DGF_BundlePriceController.pricingWrapper('Test',25.00,true,'TEst Validation Notes');
		    Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
		    //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        list<Product__c> productList = DGF_TestDataUtility.createCustomProduct(1,releaseList);
        insert productList;
        Digital_Release__c dr = [select id,US_Bundle_Avail_Date__c,CA_Bundle_Avail_Date__c,Release_State__c from Digital_Release__c where id=:productList[0].Digital_Release__c];
        dr.US_Bundle_Avail_Date__c=null;
        dr.CA_Bundle_Avail_Date__c=null;
        update dr;  
        
        test.starttest();
        DGF_BundlePriceController.validateBundleRelease(productList[0].id);
        dr.Release_State__c='Inactive';
        update dr;
        DGF_BundlePriceController.validateBundleRelease(productList[0].id);
        test.stoptest();
	}
	
    static testmethod void methodTwo(){
		 DGF_BundlePriceController.pricingWrapper priceWrap = new DGF_BundlePriceController.pricingWrapper('Test',25.00,true,'TEst Validation Notes');
		    Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
		    //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        list<Product__c> productList = DGF_TestDataUtility.createCustomProduct(1,releaseList);
        insert productList;
        list<Pricing__c> pricingList = DGF_TestDataUtility.createPricing('US',true,false,false,false,'EST',productList[0].id);
        pricingList[0].Price_type__c='Reprice';
        insert pricingList;
        test.starttest();
        DGF_BundlePriceController.validateBundleRelease(productList[0].id);
        test.stoptest();
	}
	
    static testmethod void methodThree(){
		 DGF_BundlePriceController.pricingWrapper priceWrap = new DGF_BundlePriceController.pricingWrapper('Test',25.00,true,'TEst Validation Notes');
		    Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
		    //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        list<Product__c> productList = DGF_TestDataUtility.createCustomProduct(1,releaseList);
        insert productList;
        list<Pricing__c> pricingList = DGF_TestDataUtility.createPricing('US',true,false,false,false,'EST',productList[0].id);
        pricingList[0].WSP__c=0;
        insert pricingList;
        test.starttest();
        DGF_BundlePriceController.validateBundleRelease(productList[0].id);
        test.stoptest();
	}
	
    static testmethod void methodFour(){
		 DGF_BundlePriceController.pricingWrapper priceWrap = new DGF_BundlePriceController.pricingWrapper('Test',25.00,true,'TEst Validation Notes');
		    Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
		    //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        releaseList[0].Release_State__c='Inactive';
        insert releaseList;
        list<Product__c> productList = DGF_TestDataUtility.createCustomProduct(1,releaseList);
        insert productList;
        test.starttest();
        DGF_BundlePriceController.validateBundleRelease(productList[0].id);
        test.stoptest();
	}
    
    
    static testmethod void validateTitlePricingBundleUS(){
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        
       Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id prodFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
	    //create title
	   List<Title__c> titles = DGF_TestDataUtility.createTitle(1);
	    insert titles;
	    //create TM Version
	      list<TM_Version__c> tmvList = DGF_TestDataUtility.createTmVersion(1,titles);
	      insert tmvList;
        list<Digital_Release__c>releaseList1 = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList1;
        list<Product__c> productList1 = DGF_TestDataUtility.createCustomProduct(1,releaseList1);
        productList1[0].recordtypeId=prodFilmRecTypeId;
        insert productList1;system.debug('productList1 '+productList1[0].recordtypeId);
        //create product version
        List<Product_Version__c> prodVersions = DGF_TestDataUtility.createProductVersion(1,productList1,tmvList);
        insert prodVersions;
       list<Pricing__c> pricingList = DGF_TestDataUtility.createPricing('US',true,false,false,false,'EST',productList1[0].id);
        pricingList[0].Valid_To__c=date.today();
        pricingList[0].SRP__c=10;
        insert pricingList;system.debug('pricingList[0] '+pricingList);
        list<Pricing__c> pricingList1 = DGF_TestDataUtility.createPricing('US',false,true,false,false,'EST',productList1[0].id);
        pricingList1[0].Valid_To__c=date.today();
        pricingList1[0].SRP__c=10;
        insert pricingList1;
        list<Pricing__c> pricingList2 = DGF_TestDataUtility.createPricing('US',false,false,true,false,'EST',productList1[0].id);
        pricingList2[0].Valid_To__c=date.today();
        pricingList2[0].SRP__c=10;
        insert pricingList2;
        list<Pricing__c> pricingList3 = DGF_TestDataUtility.createPricing('US',false,false,false,true,'EST',productList1[0].id);
        pricingList3[0].Valid_To__c=date.today();
        pricingList3[0].SRP__c=10;
        insert pricingList3;
        test.starttest();
        //try{
       DGF_BundlePriceController.validateTitlePricingBundle(productList1[0].id);
        //}
        //catch(exception e){
            
        //}
        test.stoptest();
    }
    
    static testmethod void validateTitlePricingBundleCA(){
       Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
       Id prodFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();

    //create title
	   List<Title__c> titles = DGF_TestDataUtility.createTitle(1);
	    insert titles;
	    //create TM Version
	      list<TM_Version__c> tmvList = DGF_TestDataUtility.createTmVersion(1,titles);
	      insert tmvList;
        list<Digital_Release__c>releaseListCA = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        releaseListCA[0].CA_Bundle_Avail_Date__c = Date.Today();
        insert releaseListCA;
        list<Product__c> productListCA = DGF_TestDataUtility.createCustomProduct(1,releaseListCA);
        productListCA[0].recordtypeId=prodFilmRecTypeId;
        insert productListCA;system.debug('productListCA '+productListCA[0].Digital_Release__r.CA_Bundle_Avail_Date__c);
        //create product version
        List<Product_Version__c> prodVersions = DGF_TestDataUtility.createProductVersion(1,productListCA,tmvList);
        insert prodVersions;
       list<Pricing__c> pricingList = DGF_TestDataUtility.createPricing('CA',true,false,false,false,'EST',productListCA[0].id);
        pricingList[0].Valid_To__c=date.today();
        pricingList[0].SRP__c=10;
        insert pricingList;
        test.starttest();
        //try{
       DGF_BundlePriceController.validateTitlePricingBundle(productListCA[0].id);
       // }
        //catch(exception e){
            
       // }
        test.stoptest();
    }
    
}