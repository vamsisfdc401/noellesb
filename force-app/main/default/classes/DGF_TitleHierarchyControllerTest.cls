/*****************************************************************************************
Class Name: DGF_TitleHierarchyControllerTest
Purpose: Test class for apex class DGF_TitleHierarchyController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/12/2017           Nandeesh                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_TitleHierarchyControllerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose:     To create Digital TV Release Data and Link into Series Release 
    ***********************************/
    static testMethod void scenario1(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
         System.AssertEquals( TRUE , insertTitle[0].id != null , 'Title Record not Created');
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);        
        insert insertTmVersion;
        System.AssertEquals( TRUE , insertTmVersion[0].id != null , 'TM Version Record not Created');
        
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id TVRecTypeIdPro = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id SeriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDGSeries = DGF_TestDataUtility.createDigitalRelease(1,SeriesRecTypeId);
        insert insertDGSeries;
		System.AssertEquals( TRUE , insertDGSeries[0].id != null , 'Digital Release Record not Created');
        
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        
        For(Digital_Release__c  rel: insertDG){
            rel.Series_Name__c = insertDGSeries[0].id;
        }
        insert insertDG;
        System.AssertEquals( TRUE , insertDG[0].id != null , 'TV Digital Release Record not Created');
        
        //creating product
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(2,insertDG);
        
        For(Product__c prod : insertProd){
            prod.recordtypeid = TVRecTypeIdPro;
        }
        insert insertProd;
        System.AssertEquals( TRUE , insertProd[0].id != null , 'Product Record not Created');
        
        
        //create pricing
        List<Pricing__c> insertPricing = DGF_TestDataUtility.createPricing('US',true,true,false,false,'EST',insertProd[0].ID);
        
        for (Pricing__c prc : insertPricing) {
            prc.Valid_From__c = System.Today()-1 ;
            prc.Valid_To__c = System.Today()+2 ;
            prc.WSP__c = 12;
            prc.SRP__c = 15;
            prc.Price_Type__c ='ORIGINAL';
        }
        insert insertPricing;
        System.AssertEquals( TRUE , insertPricing[0].id != null , 'Pricing Record not Created');
        
        test.startTest();
        System.AssertEquals(TRUE,(DGF_TitleHierarchyController.fetchRelatedRecords(insertDG[0].Id)).size() > 0 , 'There was no Related Records');
        System.AssertEquals(TRUE,(DGF_TitleHierarchyController.fetchRelatedRecords(insertDGSeries[0].Id)).size() > 0 , 'There was no Related Records');
        test.stopTest();
    }
}