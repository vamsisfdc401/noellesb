/*****************************************************************************************
Class Name: DGF_NewPromotionProductControllerTest
Purpose: Test class for apex class DGF_NewPromotionProductController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             14/06/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_NewPromotionProductControllerTest {
    
    /***********************************
     Method Name: scenario1
     Purpose: method to test code for DFOR-116
    ***********************************/
    static testMethod void scenario1() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();  
        Id BundleRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Id AccPromoRecTypeIdPrd = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
        
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertdgtlRels;
        
        List<Promotion__c> insertPromo = DGF_TestDataUtility.createPromotion(1,AccPromoRecTypeIdPrd);
        insert insertPromo;
        
        List<Product__c> insertFilmProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for (Product__c pr : insertFilmProd) {
            pr.RecordTypeId = FilmRecTypeIdPrd;
        }
        //inserting Film Products
        insert insertFilmProd;
        //insert Promotion Product of existing Promotion
        List<Promotion_Product__c> insertPromotionProduct = DGF_TestDataUtility.createPromoProd(5,insertFilmProd[0].Id,insertPromo[0].Id);
        insert insertPromotionProduct;
        
        List<Product__c> insertTVProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for (Product__c pr : insertTVProd) {
            pr.RecordTypeId = TVRecTypeIdPrd;
        }
        //inserting TV Products
        insert insertTVProd;
        
        List<Product__c> insertBundleProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertBundleProd){
            pr.RecordTypeId = BundleRecTypeIdPrd;
        }
        //inserting Bundle Products
        insert insertBundleProd;
        
        //creating JSON instance
        test.startTest();
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper = DGF_NewPromotionProductController.fetchProducts('Test',null);          
        string strJSON = JSON.serialize(lstWrapper);
        
        //check product/Account user
        System.AssertEquals(FALSE,DGF_NewPromotionProductController.getUser(insertPromo[0].id));
        
        //creating JSON instance
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper1 = DGF_NewPromotionProductController.fetchProducts('Test','btnSearchFilm');          
        string strJSON1 = JSON.serialize(lstWrapper1);
        
        //creating JSON instance
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper2 = DGF_NewPromotionProductController.fetchProducts('Test','btnSearchTV');          
        string strJSON2 = JSON.serialize(lstWrapper2);
        
        //creating JSON instance
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper3 = DGF_NewPromotionProductController.fetchProducts(null,'btnSearchTV');          
        string strJSON3 = JSON.serialize(lstWrapper3);
        
        //creating JSON instance
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper4 = DGF_NewPromotionProductController.fetchProducts(null,'btnSearchFilm');          
        string strJSON4 = JSON.serialize(lstWrapper4);
        
        //checking submit buttons
        System.AssertEquals(TRUE,(DGF_NewPromotionProductController.submitDetails(insertPromo[0].Id,strJSON)) != null);
        test.stopTest();
    }
    
    /***********************************
     Method Name: scenario2
     Purpose: method to test code for DFOR-116
    ***********************************/
    static testMethod void scenario2() {
        ID FreeEpisodeRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
        Id TVRelRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId(); 
        Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        //create Promotion record
        List<Promotion__c> insertPromo = DGF_TestDataUtility.createPromotion(1,FreeEpisodeRecTypeId);
        insertPromo[0].Sync_Free_First_Episode_Dates__c = true;
        insert insertPromo;
        System.AssertEquals( TRUE , insertPromo[0].id != null , 'Promotion Record not Created');
        //create TV Release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,TVRelRecTypeId);
        insert insertdgtlRels;
        System.AssertEquals( TRUE , insertdgtlRels[0].id != null , 'Digital Release Record not Created');
        
        //create TV Products
        List<Product__c> insertTVProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for (Product__c pr : insertTVProd) {
            pr.RecordTypeId = TVProdRecTypeId;
        }
        insert insertTVProd;
        System.AssertEquals( TRUE , insertTVProd[0].id != null , 'Product Record not Created');
        test.startTest();
        //creating JSON instance
        List<DGF_NewPromotionProductController.PromotionProductWrapper> lstWrapper3 = DGF_NewPromotionProductController.fetchProducts(null,'btnSearchTV');          
        string strJSON3 = JSON.serialize(lstWrapper3);
        System.assertEquals(DGF_Constants.FREE_EPISODE_SYNC_MESSAGE, DGF_NewPromotionProductController.submitDetails(insertPromo[0].id, strJSON3), 'Sync not completed');
        test.stopTest();
    }
    
}