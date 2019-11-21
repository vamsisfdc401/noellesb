/*****************************************************************************************
Class Name: DGF_BulkTagUpdateComponentControllerTest
Purpose: Test class for apex class DGF_BulkTagUpdateComponentController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/07/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_BulkTagUpdateComponentControllerTest{ 
    
    /***********************************
    Method Name: scenario1
    Purpose: for testing the controller
    ***********************************/
    static testMethod void scenario1(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insertTitle[0].Insert_Date__c = date.today();
        insert insertTitle ;
        insertTitle[0].tags__c='tag,';
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(1,insertTitle);        
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id bundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId(); 
        
        //getting list of digital film release records to be created
        List<Digital_Release__c> insertDGFilm = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insertDGFilm[0].US_EST_Date__c = Date.Today();
        insert insertDGFilm;
        
        //getting record type for digital release
        Id prodFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id prodBundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        
        //creating film product
        List<Product__c> insertProdFilm = DGF_TestDataUtility.createCustomProduct(1,insertDGFilm);
        insertProdFilm[0].RecordTypeId= prodFilmRecTypeId;
        insertProdFilm[0].Tags__c = 'tag';
        insert insertProdFilm;
        
        //creating bundle product
        List<Product__c> insertProdBunde = DGF_TestDataUtility.createCustomProduct(1,insertDGFilm);
        insertProdBunde[0].RecordTypeId= prodBundleRecTypeId;
        insert insertProdBunde;
        
        insertProdFilm.addall(insertProdBunde);     
        
        //create product version for film product
        List<Product_Version__c> insertProductVersionFilm = DGF_TestDataUtility.createProductVersion(1,insertProdFilm,insertTmVersion);
        insert insertProductVersionFilm;        
        
        //promotion record types
        Id recordTypeAccountPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
        Id recordTypeNationalPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
        
        //create prmotion
        List<Promotion__c> insertPromotion = DGF_TestDataUtility.createPromotion(1,recordTypeNationalPromotion);
        insertPromotion[0].Tags__c = 'tag';
        insert insertPromotion;
        
        string strJSONTitle = JSON.serialize(insertTitle);
        string strJSONProduct = JSON.serialize(insertProdFilm);
        string strJSONPromotion = JSON.serialize(insertPromotion);
        
        test.StartTest();
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Title','filter','Name') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Title','filter','Tag') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Title','filter','MPAA Rating') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Title','filter','Genre') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Title','filter','Initial Release Air year') != null);
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Product','filter','Name') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Product','filter','Tag') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Product','filter','He US Rating') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Product','filter','Franchise') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Product','filter','Genre') != null);
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Promotion','filter','Name') != null);
        System.AssertEquals(false,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Promotion','filter','Tag') != null);
        System.assertEquals(TRUE,DGF_BulkTagUpdateComponentController.fetchRecordDetails('test',string.valueof(Date.Today()-10),string.valueof(Date.Today()+10),'Promotion111','filter','Name') ==null);
        
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.updateRecordDetails(strJSONTitle,'test','Title','tag','Add') == null);
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.updateRecordDetails(strJSONProduct,'test','Product','tag','Remove') == null);
        System.AssertEquals(TRUE,DGF_BulkTagUpdateComponentController.updateRecordDetails(strJSONPromotion,'test','Promotion','tag','Update') == null);
        test.stopTest();        
    }
}