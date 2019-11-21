/*****************************************************************************************
Class Name: DGF_ClonePromotionComponentControlerTest
Purpose: Test class for apex class DGF_ClonePromotionComponentController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/19/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_ClonePromotionComponentControlerTest{  
    
    /***********************************
    Method Name: scenario1
    Purpose: for testing the controller
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
        
        //getting record type for digital release
        Id prodFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();  
        Id prodBundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        
        //creating film product
        List<Product__c> insertProdFilm = DGF_TestDataUtility.createCustomProduct(1,insertDGFilm);
        insertProdFilm[0].RecordTypeId= prodFilmRecTypeId;
        insert insertProdFilm;
        
        //create product version for film product
        List<Product_Version__c> insertProductVersionFilm = DGF_TestDataUtility.createProductVersion(1,insertProdFilm,insertTmVersion);
        insert insertProductVersionFilm;        
        
        //promotion record types
        Id recordTypeAccountPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
        Id recordTypeNationalPromotion = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
        
        //create prmotion
        List<Promotion__c> insertPromotion = DGF_TestDataUtility.createPromotion(1,recordTypeNationalPromotion);
        insert insertPromotion;
        
        List<Promotion__c> accPromo=DGF_TestDataUtility.createPromotion(1,recordTypeAccountPromotion);
        insert accPromo;
        
        //create pricing
        List<Pricing__c> insertPricing = DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',insertProdFilm[0].ID);
        insertPricing.addall(DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',insertProdFilm[0].ID));
        
        for(Pricing__c prc : insertPricing){
            prc.Valid_From__c = System.Today() -1;
            prc.WSP__c = 12;
            prc.Promotion__c = insertPromotion[0].Id;
        }
        
        insert insertPricing;
        
        //inserting promotion product
        List<Promotion_Product__c> insertPromotionProduct = DGF_TestDataUtility.createPromoProd(1,insertProdFilm[0].ID,insertPromotion[0].Id);
        insert insertPromotionProduct;
        
        test.startTest();
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getPromotionType(insertPromotion[0].Id,TRUE)) != null);     
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getPromotionType(insertPromotion[0].Id,FALSE)) != null);    
        
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(insertPromotion[0].Id,TRUE)) == null);     
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(insertPromotion[0].Id,FALSE)) == null);    
        
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.clonePromotionRecord(insertPromotion[0].Id,TRUE)) != null); 
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.clonePromotionRecord(insertPromotion[0].Id,FALSE)) != null);
        try{
            System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.clonePromotionRecord('test',FALSE)) == null);
        }
        catch(exception e){
        }       
        
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.saveClonedPromotionRecord(JSON.serialize((insertPromotion[0]).clone()),insertPromotion[0].Id,null,TRUE)) != null);      
        System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.saveClonedPromotionRecord(JSON.serialize((insertPromotion[0]).clone()),insertPromotion[0].Id,null,FALSE)) != null); 
        try{
            System.AssertEquals(FALSE,(DGF_ClonePromotionComponentController.saveClonedPromotionRecord(JSON.serialize((insertPromotion[0]).clone()),'test',null,FALSE)) == null);                    
        }catch(exception e){
        } 
        
        //Create an Accounts User
        User accUser=DGF_TestDataUtility.createUser(DGF_Constants.PROFILE_ACCOUNT_USER,'accUsertest123@gmail.com','acc');
        System.runAs(accUser){
            System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(accPromo[0].Id,TRUE))==null);
            System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(insertPromotion[0].Id,FALSE))==null);
        }
        //Create Product User
        User prdUser=DGF_TestDataUtility.createUser(DGF_Constants.PROFILE_PRODUCT_USER,'prdUsertest123@gmail.com','prd');
        System.runAs(prdUser){
            System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(insertPromotion[0].Id,TRUE))==null);
        }
        //Create Ops user 
         User opsUser=DGF_TestDataUtility.createUser('DD Ops User','test123opsUser@gmail.com','ops');
        System.runAs(opsUser){
             System.AssertEquals(TRUE,(DGF_ClonePromotionComponentController.getUserAccess(insertPromotion[0].Id,TRUE))=='User does not have required access to perform the operation.');
        }
        test.stopTest();
    }
    
}