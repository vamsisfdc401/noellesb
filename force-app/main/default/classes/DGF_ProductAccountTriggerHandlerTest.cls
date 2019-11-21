/*****************************************************************************************
Class Name: DGF_ProductAccountTriggerHandlerTest
Purpose: Test class for apex class DGF_ProductAccountTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/08/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_ProductAccountTriggerHandlerTest {
    
    /***********************************
Method Name: scenario1
Purpose: method to test code for DFOR-711
***********************************/
    static testMethod void scenario1(){
        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        
        //insert Film release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertdgtlRels;
        test.startTest();
        //insert Account
        List<Account> insertAccnt = DGF_TestDataUtility.createAccount(2);
        insert insertAccnt;
        
        List<Product__c> insertFilmProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertFilmProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
            
        }
        //inserting Film Products
        insert insertFilmProd;
        
        List<Product_Account__c> insertProdAccnt = DGF_TestDataUtility.createProductAccount(5,insertFilmProd[0].Id,insertAccnt[0].Id);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.VOD_Start_Date__c = Date.today();
            prdAcc.VOD_End_Date__c = Date.today() - 10;
        }
        try{
            //inserting Product Account 
            insert insertProdAccnt;
            
        } Catch(Exception Ex){
            
        }
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.VOD_Start_Date__c = Date.today();
            prdAcc.VOD_End_Date__c = Date.today() + 10;
        }
        
        insert insertProdAccnt;
        System.assert(insertProdAccnt!=null);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.VOD_Start_Date__c = Date.today();
            prdAcc.VOD_End_Date__c = Date.today() - 10;
        }
        //Enabling trigger
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        try{
            update insertProdAccnt;
        }Catch(Exception Ex1){
            
        }
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario2
Purpose: method to test code for DFOR-711
***********************************/
    static testMethod void scenario2(){
        System.debug('Scenario2');
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        
        //insert Film release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertdgtlRels;
        test.startTest();
        //insert Account
        List<Account> insertAccnt = DGF_TestDataUtility.createAccount(2);
        insert insertAccnt;
        
        List<Product__c> insertFilmProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertFilmProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
            
        }
        //inserting Film Products
        insert insertFilmProd;
        
        
        List<Product_Account__c> insertProdAccnt = DGF_TestDataUtility.createProductAccount(5,insertFilmProd[0].Id,insertAccnt[0].Id);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.Push_VOD_Start_Date__c = Date.today();
            prdAcc.Push_VOD_End_Date__c = Date.today() - 10;
        }
        try{
            //inserting Product Account 
            insert insertProdAccnt;
        } Catch(Exception Ex){
            
        }
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.Push_VOD_Start_Date__c = Date.today();
            prdAcc.Push_VOD_End_Date__c = Date.today() + 10;
        }
        
        insert insertProdAccnt;
        System.assert(insertProdAccnt!=null);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.Push_VOD_Start_Date__c = Date.today();
            prdAcc.Push_VOD_End_Date__c = Date.today() - 10;
        }
        //Enabling trigger
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        try{
            update insertProdAccnt;
        }Catch(Exception Ex1){
            
        }
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario3
Purpose: method to test code for DFOR-711
***********************************/
    static testMethod void scenario3(){
        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        
        //insert Film release
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertdgtlRels;
        test.startTest();
        //insert Account
        List<Account> insertAccnt = DGF_TestDataUtility.createAccount(2);
        insert insertAccnt;
        
        List<Product__c> insertFilmProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertFilmProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
            
        }
        //inserting Film Products
        insert insertFilmProd;
        
        
        List<Product_Account__c> insertProdAccnt = DGF_TestDataUtility.createProductAccount(5,insertFilmProd[0].Id,insertAccnt[0].Id);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.PPV_Start_Date__c = Date.today();
            prdAcc.PPV_End_Date__c = Date.today() - 10;
        }
        try{
            //inserting Product Account 
            insert insertProdAccnt;
        } Catch(Exception Ex){
            
        }
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.PPV_Start_Date__c = Date.today();
            prdAcc.PPV_End_Date__c = Date.today() + 10;
        }
        
        insert insertProdAccnt;
        System.assert(insertProdAccnt!=null);
        
        for(Product_Account__c prdAcc : insertProdAccnt){
            prdAcc.PPV_Start_Date__c = Date.today();
            prdAcc.PPV_End_Date__c = Date.today() - 10;
        }
        //Enabling trigger
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        try{
            update insertProdAccnt;
        }Catch(Exception Ex1){
            
        }
        test.stopTest();
    }
    
}