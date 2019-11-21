/*****************************************************************************************
Class Name: DGF_AddCarriageControllerTest
Purpose: Test class for apex class DGF_AddCarriageController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/07/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_AddCarriageControllerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-120
    ***********************************/
    static testMethod void scenario1(){
        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();  
        Id BundleRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        //insert Film release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertdgtlRels;
        //insert TV release
        List<Digital_Release__c> insertTVdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        insertTVdgtlRels[0].US_EST_Launch_Date__c = Date.today() + 10;
        insertTVdgtlRels[0].CA_EST_Launch_Date__c = Date.today() + 10;
        insert insertTVdgtlRels;
        //insert Bundle release
        List<Digital_Release__c> insertBundledgtlRels = DGF_TestDataUtility.createDigitalRelease(1,BundleRecTypeId);
        insertBundledgtlRels[0].US_Bundle_Avail_Date__c = Date.today() + 10;
        insertBundledgtlRels[0].CA_Bundle_Avail_Date__c = Date.today() + 10;
        insert insertBundledgtlRels;
        //insert Account
        List<Account> insertAccnt = DGF_TestDataUtility.createAccount(2);
        insert insertAccnt;
        
        //updating Account with Territory as CA
        insertAccnt[1].territory__c = 'CA';
        update insertAccnt[1];
        
        List<Product__c> insertFilmProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertFilmProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
            
        }
        //inserting Film Products
        insert insertFilmProd;
        
        List<Product__c> insertTVProd = DGF_TestDataUtility.createCustomProduct(1,insertTVdgtlRels);
        for(Product__c pr : insertTVProd){
            pr.RecordTypeId = TVRecTypeIdPrd;
        }
        //inserting TV Products
        insert insertTVProd;
        
        List<Product__c> insertBundleProd = DGF_TestDataUtility.createCustomProduct(5,insertBundledgtlRels);
        for(Product__c pr : insertBundleProd){
            pr.RecordTypeId = BundleRecTypeIdPrd;
        }
        //inserting Bundle Products
        insert insertBundleProd;
        
        List<Product_Account__c> insertProdAccntUS = DGF_TestDataUtility.createProductAccount(5,insertFilmProd[0].Id,insertAccnt[0].Id);
        //inserting Product Account 
        insert insertProdAccntUS;
        
        List<Product_Account__c> insertProdAccntCA = DGF_TestDataUtility.createProductAccount(5,insertFilmProd[0].Id,insertAccnt[1].Id);
        //inserting Product Account 
        insert insertProdAccntCA;
        
        List<Product_Account__c> insertProdAccntTV = DGF_TestDataUtility.createProductAccount(5,insertTVProd[0].Id,insertAccnt[0].Id);
        //inserting Product Account 
        insert insertProdAccntTV;
        
        List<Product_Account__c> insertProdAccntBundle = DGF_TestDataUtility.createProductAccount(5,insertBundleProd[0].Id,insertAccnt[0].Id);
        //inserting Product Account 
        insert insertProdAccntBundle;
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper = DGF_AddCarriageController.fetchProducts('Test','btnSearch','All',string.valueof(Date.Today()+10),string.valueof(Date.Today()+20),insertAccnt[0].Id);          
        string strJSON = JSON.serialize(lstWrapper);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapperca = DGF_AddCarriageController.fetchProducts('Test','btnSearch','All',null,null,insertAccnt[1].Id);          
        string strJSONCA = JSON.serialize(lstWrapperca);
        
        //check Account name
         System.AssertEquals(TRUE,(DGF_AddCarriageController.getAccountName(insertAccnt[0].Id) != null));
        
        //check Account user
         System.AssertEquals(FALSE,DGF_AddCarriageController.getUser());
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper1 = DGF_AddCarriageController.fetchProducts(null,'btnSearchAll','Bundle',null,null,insertAccnt[0].Id);          
        string strJSON1 = JSON.serialize(lstWrapper1);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper2 = DGF_AddCarriageController.fetchProducts(null,'btnSearchAll','TV',string.valueof(Date.Today()+10),null,insertAccnt[0].Id);          
        string strJSON2 = JSON.serialize(lstWrapper2);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper3 = DGF_AddCarriageController.fetchProducts('ame','btnSearch','Bundle',null,string.valueof(Date.Today()+12),insertAccnt[0].Id);          
        string strJSON3 = JSON.serialize(lstWrapper3);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper4 = DGF_AddCarriageController.fetchProducts(null,'btnSearchAll','All',null,string.valueof(Date.Today()+20),insertAccnt[1].Id);          
        string strJSON4 = JSON.serialize(lstWrapper4);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper5 = DGF_AddCarriageController.fetchProducts('ame','btnSearch','Film',null,string.valueof(Date.Today()),insertAccnt[1].Id);          
        string strJSON5 = JSON.serialize(lstWrapper5);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper6 = DGF_AddCarriageController.fetchProducts('ame',null,'TV',null,string.valueof(Date.Today()+15),insertAccnt[1].Id);          
        string strJSON6 = JSON.serialize(lstWrapper6);
        
        //creating JSON instance
        List<DGF_AddCarriageController.ProductAccountWrapper> lstWrapper7 = DGF_AddCarriageController.fetchProducts(null,'btnSearchAll','All',null,null,insertAccnt[0].Id);          
        string strJSON7 = JSON.serialize(lstWrapper7);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[0].Id,strJSON)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[0].Id,strJSONCA)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[0].Id,strJSON1)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[0].Id,strJSON2)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[0].Id,strJSON3)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[1].Id,strJSON5)) != null);
        
        //checking save buttons
        System.AssertEquals(TRUE,(DGF_AddCarriageController.submitDetails(insertAccnt[1].Id,strJSON6)) != null);
    }

}