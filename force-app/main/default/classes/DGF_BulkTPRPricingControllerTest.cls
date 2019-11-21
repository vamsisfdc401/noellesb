/*****************************************************************************************
Class Name: DGF_BulkTPRPricingControllerTest
Purpose: Test class for apex class DGF_BulkTPRPricingController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/06/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with Sharing class DGF_BulkTPRPricingControllerTest {
    static list<Promotion__c>promoList{get;set;}
    static list<Promotion_Product__c>promoPrd1{get;set;}
    static list<Promotion_Product__c>promoPrd2{get;set;}
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test creation of TPR Prices
    ***********************************/
    static testMethod void scenario1() {
        //method to create the data
        createData();
        test.startTest();
            //fetch the Promotion products by passing the promotion ID
            List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>wrpList = DGF_BulkTPRPricingController.fetchProducts(promoList[0].id);
            string strJSON = JSON.serialize(wrpList);
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper tprPrice = new  DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
            tprPrice.priceVal = '10.5';
            tprPrice.selectedPriceType = 'US EST SD WSP TPR';
            list<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>tprList = new list<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>();
            tprList.add(tprPrice);
            for(String s: tprPrice.priceType) {
                DGF_BulkTPRPricingWrapper.TPRPricingWrapper tp = new  DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
                tp.priceVal = '20';
                tp.selectedPriceType = s;
                tprList.add(tp);
            }
            //create the wrapper with the Price Type and values
            string tprJSON = JSON.serialize(tprList);
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper tpr = DGF_BulkTPRPricingController.createTPRWrapper(tprJSON, promoList[0].id);
            DGF_BulkTPRPricingController.saveAndContinueTPR(strJSON, tprJSON,'Account Promotion',false,promoList[0].Territory__c );
            DGF_BulkTPRPricingController.fetchRecordType(promoList[0].id);
            DGF_BulkTPRPricingController.getProdCount(promoList[0].id);
            DGF_BulkTPRPricingController.getProfileDetails(promoList[0].id);
            list<Pricing__c>priceList = [SELECT ID, WSP__c,Promotion__c from Pricing__c where Price_type__c='TPR Account'];
            System.assertEquals(10.00, priceList[0].wsp__c);
            List<DGF_BulkTPRPricingWrapper.TPRPricingWrapper> tpr1 = DGF_BulkTPRPricingController.createTPRWrapperOnInit(promoList[0].id);
        test.stopTest();
    }
    /***********************************
    Method Name: scenario2
    Purpose: method to test updation of TPR Prices
    ***********************************/
    static testMethod void scenario2() {
        //method to create the data
        createData();
        test.startTest();
        //fetch the Promotion products by passing the promotion ID
        List<DGF_BulkTPRPricingWrapper.ProductPricingWrapper>wrpList = DGF_BulkTPRPricingController.fetchProducts(promoList[1].id);
        string strJSON = JSON.serialize(wrpList);
        DGF_BulkTPRPricingWrapper.TPRPricingWrapper tprPrice = new  DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
        tprPrice.priceVal = '10.5';
        tprPrice.selectedPriceType = 'US EST SD WSP TPR';
        list<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>tprList = new list<DGF_BulkTPRPricingWrapper.TPRPricingWrapper>();
        tprList.add(tprPrice);
        for(String s: tprPrice.priceType) {
            DGF_BulkTPRPricingWrapper.TPRPricingWrapper tp = new  DGF_BulkTPRPricingWrapper.TPRPricingWrapper();
            tp.priceVal = '20';
            tp.selectedPriceType = s;
            tprList.add(tp);
        }
        string tprJSON = JSON.serialize(tprList);
        DGF_BulkTPRPricingWrapper.TPRPricingWrapper tpr = DGF_BulkTPRPricingController.createTPRWrapper(tprJSON, promoList[1].id);
        //save and continue TPR Prices for a Product that already has TPR prices created
        DGF_BulkTPRPricingController.saveAndContinueTPR(strJSON, tprJSON,'Account Promotion',false,promoList[0].Territory__c );
         System.assertEquals('10.5', tprPrice.priceVal);
    }
    /***********************************
    Method Name: createData
    Purpose: method to create Data
    ***********************************/
    static void createData() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        //create products associated to release
        list<Product__c>prdList = DGF_TestDataUtility.createCustomProduct(2, releaseList);
        insert prdList;
        for(Product__c p : prdList) {
            p.Us_Platform_Offering__c = 'EST;iVOD';
            p.CA_Platform_Offering__c = 'EST;iVOD';
            p.recordTypeId = FilmPrdRecTypeId;
            p.est_tier__c = 'New Release Standard';
            p.ca_est_tier__c = 'New Release Standard';
        }
        
        update prdlist;
        
        list<Pricing__c>usPriceList = DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',prdList[0].id);
        insert usPriceList;
        
        //create CA Pricing records for the created product
        list<Pricing__c>caPriceList = DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',prdList[0].id);
        insert caPriceList;
        Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId(); 
        promoList = DGF_TestDataUtility.createPromotion(2, AccRecTypeId);
        insert promoList;
        //create Promotion Products
        promoPrd1 = DGF_TestDataUtility.createPromoProd(1, prdlist[0].id,promoList[0].id);
        insert promoPrd1;
        promoPrd2 = DGF_TestDataUtility.createPromoProd(1, prdlist[1].id,promoList[1].id);
        insert promoPrd2;
        //create TPR Pricing records
        list<Pricing__c>usEST = DGF_TestDataUtility.createTPRPricing(prdlist[1].ID, promoList[1].ID, 'US', 'EST');
        insert usEST;
        list<Pricing__c>caEST = DGF_TestDataUtility.createTPRPricing(prdlist[1].ID, promoList[1].ID, 'CA', 'EST');
        insert caEST;
        list<Pricing__c>usVOD = DGF_TestDataUtility.createTPRPricing(prdlist[1].ID, promoList[1].ID, 'US', 'VOD');
        insert usVOD;
        list<Pricing__c>caVOD = DGF_TestDataUtility.createTPRPricing(prdlist[1].ID, promoList[1].ID, 'CA', 'VOD');
        insert caVOD;
        
    }
}