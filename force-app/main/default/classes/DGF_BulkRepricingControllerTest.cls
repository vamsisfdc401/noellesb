/*****************************************************************************************
Class Name: DGF_BulkRepricingControllerTest
Purpose: Test class for apex class DGF_BulkRepricingController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             023/05/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with Sharing class DGF_BulkRepricingControllerTest {
    /***********************************
Method Name: scenario1
Purpose: method to test code for DFOR-34
***********************************/
    static testMethod void scenario1(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        test.startTest();
        //create digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        //create products associated to release
        list<Product__c>prdList=DGF_TestDataUtility.createCustomProduct(1, releaseList);
        insert prdList;
        prdlist[0].Us_Platform_Offering__c='EST';
        prdlist[0].CA_Platform_Offering__c='EST';
        prdList[0].recordTypeId=FilmPrdRecTypeId;
        update prdlist[0];
        //create US Pricing records for the created product
        list<Pricing__c>usPriceList=DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',prdList[0].id);
        insert usPriceList;
        for(Pricing__c p: usPriceList){
            p.valid_From__c=date.today()-1;
        }
        update usPriceList;
        //create CA Pricing records for the created product
        list<Pricing__c>caPriceList=DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',prdList[0].id);
        insert caPriceList;
        for(Pricing__c p: caPriceList){
            p.valid_From__c=date.today()-1;
        }
        update caPriceList;
        //update the US and CA EST Tiers
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper = DGF_BulkRepricingController.fetchProducts('Test');          
        string strJSON = JSON.serialize(lstWrapper);
        String retVal=DGF_BulkRepricingController.updateProducts(strJSON, String.valueOf(Date.today()));
        prdList[0].est_tier__c='New Release Premium';
        prdList[0].ca_est_tier__c='New Release Premium';
        update prdList[0];
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper1 = DGF_BulkRepricingController.fetchProducts('Test'); 
        prdList[0].est_tier__c='New Release Standard';
        prdList[0].ca_est_tier__c='New Release Standard';
        update prdList[0];
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper2 = DGF_BulkRepricingController.fetchProducts('Test'); 
        prdList[0].est_tier__c='Tier 2';
        prdList[0].ca_est_tier__c='Tier 2';
        update prdList[0];
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper3 = DGF_BulkRepricingController.fetchProducts('Test');
        prdList[0].est_tier__c='Tier 3';
        prdList[0].ca_est_tier__c='Tier 3';
        update prdList[0];
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper4 = DGF_BulkRepricingController.fetchProducts('Test');
        DGF_BulkRepricingController.cancelMethod();
        System.assertEquals(1, lstWrapper4.size());
        Product__c pr=new Product__c(Digital_Release__c=releaseList[0].id,Name='negativeTest',recordTypeId=FilmPrdRecTypeId,Us_Platform_Offering__c='EST');
        insert pr;
        list<Pricing__c>usPriceList1=DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',pr.id);
        insert usPriceList1;
        List<DGF_BulkRepricingController.ProductWrapper> lstWrapper5 = DGF_BulkRepricingController.fetchProducts('negativeTest');
        test.stopTest();
    }
    
}