/*****************************************************************************************
Class Name: DGF_ProdVersionReltdLstCompControlerTest
Purpose: Test class for apex class DGF_ProdVersionRelatedLstCompController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             5/06/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_ProdVersionReltdLstCompControlerTest{  

    /***********************************
    Method Name: scenario1
    Purpose: 
    ***********************************/
    static testMethod void scenario1(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(1,insertTitle);        
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id bundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId(); 
        
        //getting list of digital film release records to be created
        List<Digital_Release__c> insertDGFilm = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDGFilm;
        
        //getting list of digital bundle release records to be created
        List<Digital_Release__c> insertDGBundle = DGF_TestDataUtility.createDigitalRelease(1,bundleRecTypeId);
        insert insertDGBundle;
        
        //getting record type for digital release
        Id prodFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id prodBundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        
        //creating film product
        List<Product__c> insertProdFilm = DGF_TestDataUtility.createCustomProduct(1,insertDGFilm);
        insertProdFilm[0].RecordTypeId= prodFilmRecTypeId;
        insert insertProdFilm;
        
        //creating bundle product
        List<Product__c> insertProdBundle = DGF_TestDataUtility.createCustomProduct(1,insertDGBundle);
        insertProdBundle[0].recordTypeId = prodBundleRecTypeId;
        insert insertProdBundle;
        
        //create product version for film product
        List<Product_Version__c> insertProductVersionFilm = DGF_TestDataUtility.createProductVersion(1,insertProdFilm,insertTmVersion);
        insert insertProductVersionFilm;
        
        //create product version for bundle product
        List<Product_Version__c> insertProductVersionBundle = DGF_TestDataUtility.createProductVersion(1,insertProdBundle,insertTmVersion);
        insert insertProductVersionBundle;
        
        //create pricing
        List<Pricing__c> insertPricing = DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',insertProdFilm[0].ID);
        insertPricing.addall(DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',insertProdFilm[0].ID));
        
        for(Pricing__c prc : insertPricing){
            prc.Valid_From__c = System.Today() -1;
            prc.WSP__c = 12;
        }
        
        insert insertPricing;
              
        test.startTest();
            System.AssertEquals(TRUE,(DGF_ProdVersionRelatedLstCompController.fetchRelatedRecords(insertProdBundle[0].Id)).size() > 0);
        test.stopTest();
    }
}