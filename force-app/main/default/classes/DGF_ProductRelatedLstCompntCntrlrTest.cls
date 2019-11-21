/*****************************************************************************************
Class Name: DGF_ProductRelatedLstCompntCntrlrTest
Purpose: Test class for apex class DGF_ProductRelatedLstComponentController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/05/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_ProductRelatedLstCompntCntrlrTest{  
    
    /***********************************
    Method Name: scenario1
    Purpose: 
    ***********************************/
    static testMethod void scenario1(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);        
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10,FilmRecTypeId);
        insert insertDG;
        
        //creating product
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(10,insertDG);
        insert insertProd;
        
        //create pricing
        List<Pricing__c> insertPricing = DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',insertProd[0].ID);
        insertPricing.addall(DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',insertProd[0].ID));
        
        for(Pricing__c prc : insertPricing){
            prc.Valid_From__c = System.Today() -1;
            prc.WSP__c = 12;
        }
        
        insert insertPricing;
              
        test.startTest();
            System.AssertEquals(TRUE,(DGF_ProductRelatedLstComponentController.fetchRelatedRecords(insertDG[0].Id)).size() > 0);
            System.AssertEquals(TRUE,(DGF_ProductRelatedLstComponentController.getReleaseType(insertDG[0].Id)) != null);
        test.stopTest();
    }
}