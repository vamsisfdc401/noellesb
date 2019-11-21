/***********************************************************************************
Class Name: DGF_DeleteDigitalReleaseControllerTest
Purpose: Test class for apex class DGF_DeleteDigitalReleaseController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_DeleteDigitalReleaseControllerTest { 

    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-30
    ***********************************/ 
    static testMethod void scenario1() {
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        //creating title records
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        //creating TM version
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);        
        insert insertTmVersion;

        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  

        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;

        //getting list of products to be created
        List<Product__c> insertProduct = DGF_TestDataUtility.createCustomProduct(1,insertDG);
        insert insertProduct;

        //getting list of product versions to be inserted
        List<Product_Version__c> insertProdVersion = DGF_TestDataUtility.createProductVersion(1,insertProduct,insertTmVersion);
        insert insertProdVersion;

        //getting record type for EPO&Bonus
        Id FilmEPORecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get('Film Bonus').getRecordTypeId();

        //getting list of Bonus records to be inserted
        List<EPO_Bonus__c> insertBonus = DGF_TestDataUtility.createEPOBonus(10,FilmEPORecTypeId,insertDG[0].ID);
        insert insertBonus;
        
        //getting list of accounts inserted
        List<Account> insertAcc = DGF_TestDataUtility.createAccount(1);
        insert insertAcc;
        
        //getting list of Bonus records to be inserted
        List<Product_Account__c> insertProdAcc = DGF_TestDataUtility.createProductAccount(1,insertProduct[0].ID,insertAcc[0].id);
        insert insertProdAcc;
        
        //getting list of Bonus records to be inserted
        List<Bonus_account__c> insertBonusAcc = DGF_TestDataUtility.createBonusAccount(1,insertBonus[0].ID,insertAcc[0].id);
        insert insertBonusAcc;
        
        List<Catalog_Window__c> insertCatalogWindow = new List<Catalog_Window__c>();
        insertCatalogWindow.add(new Catalog_Window__c(Digital_Release__c= insertDG[0].Id));
        insert insertCatalogWindow;

        //calling class method for testing the scenario
        test.startTest();
            System.AssertEquals(TRUE,DGF_DeleteDigitalReleaseController.deleteRelease(insertDG[0].ID) != null);
            System.AssertEquals(TRUE,DGF_DeleteDigitalReleaseController.hasDeleteAccess(insertDG[0].ID));
        test.stopTest();
    }
}