/***********************************************************************************
Class Name: DGF_ProductVersionTriggerHandlerTest
Purpose: Test class for apex class DGF_ProductVersionTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/04/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_ProductVersionTriggerHandlerTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-23
    ***********************************/
    static testMethod void scenario1() {
        
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        
        //getting record type for digital release
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        
        test.startTest();
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, BundleRecTypeId);
        //inserting Digital Release
        insert insertdgtlRels;
        System.assertEquals(1, insertdgtlRels.size());
       
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(5, insertdgtlRels);
        //inserting Products
        insert insertProd;
        System.assertEquals(5, insertProd.size());
        
        //getting list of Title records to be created
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        //inserting Titles
        insert insertTitle;
        
        //getting list of TM Version records to be created
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5, insertTitle);
        //inserting TMVersion
        insert insertTmVersion;
        
        //getting list of Product Version records to be created
        List<Product_Version__c> insertProdVersion = DGF_TestDataUtility.createProductVersion(5, insertProd, insertTmVersion);
        //inserting Product version
        insert insertProdVersion;
        
        Product_Version__c pr = [select Product_Release__c from Product_Version__c where Id =: insertProdVersion[3].Id];
        Digital_Release__c dg = [Select of_Titles_in_Bundle__c from Digital_Release__c where Id in : insertdgtlRels];
        System.assertEquals(5, dg.of_Titles_in_Bundle__c);
        Product_Version__c ProdVersion = insertProdVersion[0];
        
        //updating Product version
        ProdVersion.Lead_Title__c = TRUE;
        update ProdVersion;
        
        //deleting Product version
        delete ProdVersion;
        test.stopTest();
    }
       /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-263
    ***********************************/
    static testMethod void scenario2() {
    	 //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
         Id FilmProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id PreOrderRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
        
         //getting list of Title records to be created
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        //inserting Titles
        insert insertTitle;
        
        //getting list of TM Version records to be created
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5, insertTitle);
        //inserting TMVersion
         for(TM_Version__c tm : insertTmVersion) {
            tm.original_flag__c =true;
        }
        insert insertTmVersion;
        
         //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insertdgtlRels [0].US_EPO_Date__c = date.today();
        //inserting Digital Release
        insert insertdgtlRels;
        //insert a preorder Product
        Product__c prod = new Product__c (Digital_Release__c = insertdgtlRels [0].id, RecordTypeId = PreOrderRecTypeId );
        insert prod;
        List<Product__c>preOrderProd = [Select id, Version_Availability__c,  Digital_release__c , RecordTypeId from Product__c where id =:prod.id];
        List<Product__c> prodList = DGF_TestDataUtility.createCustomProduct(1, insertdgtlRels);
        prodList[0].recordTypeId = FilmProdRecTypeId;
        insert prodList;
        test.startTest();
             //getting list of Product Version records to be created
            List<Product_Version__c> insertProdVersion = DGF_TestDataUtility.createProductVersion(1, prodList, insertTmVersion);
            //inserting Product version
            insert insertProdVersion;
        	//check the vaue of version on the preorder product
            System.assertEquals('Theatrical', preOrderProd[0].Version_Availability__c);
        test.stopTest();
        
    }
}