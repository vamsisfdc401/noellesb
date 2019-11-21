/*****************************************************************************************
Class Name: DGF_TMVersionTriggerHandlerTest
Purpose: Test class for apex class DGF_TMVersionTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/10/2017           Mohit                    Initial Development as partof DFOR-1092
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_TMVersionTriggerHandlerTest{  
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-119
    ***********************************/
    static testMethod void scenario1() {
        //creating title record
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        //creating TM Version
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);   
        for (TM_Version__c tm : insertTmVersion ) {
            tm.TVD_SAFE_Production_ID__c = '123';
            tm.Version_EIDR__c = '43';
        }     
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();  
        
        //creating product
        Product__c prodFilm = new Product__c();
        prodFilm.Name = 'FILM PROD';
        prodFilm.RecordTypeId = FilmRecTypeId;
        
        Product__c prodTV = new Product__c();
        prodTV.Name = 'FILM TV';
        prodTV.RecordTypeId = TVRecTypeId;
        
        List<Product__c> insertableProd = new List<Product__c>();
        insertableProd.add(prodFilm);
        insertableProd.add(prodTV);
        
        insert insertableProd;
        
        //creating product version
        List<Product_Version__c> insertProdVersion = DGF_TestDataUtility.createProductVersion(2,insertableProd,insertTmVersion);   
        insert insertProdVersion;
                
        test.startTest();           
            
            //updating TM Version
            for (TM_Version__c tm : insertTmVersion) {
                tm.TVD_SAFE_Production_ID__c = '1231';
                tm.Version_EIDR__c = '431';
            }            
            update insertTmVersion;
            
            List<Product__c> lstProd = [Select id, EIDR__c, Product_ID__c from Product__c where ID =: insertableProd[0].Id];
            System.AssertEquals(TRUE, lstProd[0].EIDR__c == insertTmVersion[0].Version_EIDR__c);
            System.AssertEquals(TRUE, lstProd[0].Product_Id__c == insertTmVersion[0].TVD_SAFE_Production_ID__c);
            
        test.stopTest();        
    }
}