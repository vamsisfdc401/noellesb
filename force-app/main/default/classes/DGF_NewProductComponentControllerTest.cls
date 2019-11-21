/*****************************************************************************************
Class Name: DGF_NewProductComponentControllerTest
Purpose: Test class for apex class DGF_NewProductComponentController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/05/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_NewProductComponentControllerTest {  
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-119
    ***********************************/
    static testMethod void scenario1() {
         CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);   
        for (TM_Version__c tm : insertTmVersion ) {
            tm.TVD_SAFE_Production_ID__c = '123';
        }     
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();  
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10, FilmRecTypeId);
        insert insertDG;
        
        //create TV release
        List<Digital_Release__c> insertDG1 = DGF_TestDataUtility.createDigitalRelease(10, TVRecTypeId);
        insert insertDG1;
        
        //creating Bundle release
        List<Digital_Release__c> insertDG2 = DGF_TestDataUtility.createDigitalRelease(10, BundleRecTypeId);
        insert insertDG2;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'US', TRUE, 1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'US', TRUE, 1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'CA', TRUE, 1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'CA', TRUE, 1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        test.startTest();
            //checking picklist values
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.getESTTierValues()).size() > 0);
            
            //checking title versions
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.fetchTitleVersions(insertDG[0].id, 'Test')).size() > 0);
            
            //creating JSON instance
            List<DGF_NewProductComponentController.TitleVersionWrapper> lstWrapper = DGF_NewProductComponentController.fetchTitleVersions(insertDG[0].Id, 'Test');          
            string strJSON = JSON.serialize(lstWrapper);
          	DGF_NewProductComponentController.saveNoVersionProduct(insertDG[0].Id);
            //checking submit buttons
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG[0].Id,strJSON,'Tier 2','Unrated')) != null);
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG1[0].Id,strJSON,'Tier 2','Unrated')) != null);
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG2[0].Id,strJSON,'Tier 2','Unrated')) != null);  
            
            //checking release type method
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.getReleaseType(insertDG[0].ID)) != null);  
            
            //check product user
            System.AssertEquals(FALSE, DGF_NewProductComponentController.getProductUser());
        test.stopTest();        
    }
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-119
    ***********************************/
    static testMethod void scenario2() {
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(1, insertTitle);   
        for (TM_Version__c tm : insertTmVersion ) {
            tm.TVD_SAFE_Production_ID__c = '123';
        }       
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();   
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insert insertDG;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'US', TRUE, 1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'US', TRUE, 1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'CA', TRUE, 1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'CA', TRUE, 1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        test.startTest();            
            //creating JSON instance
            List<DGF_NewProductComponentController.TitleVersionWrapper> lstWrapper = DGF_NewProductComponentController.fetchTitleVersions(insertDG[0].Id, 'Test');          
            string strJSON = JSON.serialize(lstWrapper);
            
            //checking submit buttons
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG[0].Id, strJSON, 'Tier 2', 'Unrated')) != null); 
        test.stopTest();        
    }
    
    /***********************************
    Method Name: scenario3
    Purpose: method to test code for DFOR-119
    ***********************************/
    static testMethod void scenario3() {
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(1, insertTitle);        
        insert insertTmVersion;
        
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();   
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1, TVRecTypeId);
        insert insertDG;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'US', TRUE, 1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'US', TRUE, 1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'CA', TRUE, 1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'CA', TRUE, 1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        test.startTest();            
            //creating JSON instance
            List<DGF_NewProductComponentController.TitleVersionWrapper> lstWrapper = DGF_NewProductComponentController.fetchTitleVersions(insertDG[0].Id, 'Test');          
            string strJSON = JSON.serialize(lstWrapper);
            
            //checking submit buttons
            try {
                System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG[0].Id, strJSON, 'Tier 2', 'Unrated')) != null); 
            }
            catch (exception e) {
            } 
            
            DGF_NewProductComponentController.getTitleName(insertDG[0].Id);
        test.stopTest();        
    }
    
    /***********************************
    Method Name: scenario4
    Purpose: method to test code for DFOR-119
    ***********************************/
    static testMethod void scenario4(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(1, insertTitle);   
        for (TM_Version__c tm : insertTmVersion ) {
            tm.TVD_SAFE_Production_ID__c = '123';
        }     
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();  
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10, FilmRecTypeId);
        insert insertDG;
        
        //create TV release
        List<Digital_Release__c> insertDG1 = DGF_TestDataUtility.createDigitalRelease(10, TVRecTypeId);
        insert insertDG1;
        
        //creating Bundle release
        List<Digital_Release__c> insertDG2 = DGF_TestDataUtility.createDigitalRelease(10, BundleRecTypeId);
        insert insertDG2;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'US', TRUE, 1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'US', TRUE, 1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'EST', 'CA', TRUE, 1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID, 'VOD', 'CA', TRUE, 1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        test.startTest();
            //checking picklist values
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.getESTTierValues()).size() > 0);
            
            //checking title versions
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.fetchTitleVersions(insertDG1[0].id,'Test')).size() > 0);
            
            //creating JSON instance
            List<DGF_NewProductComponentController.TitleVersionWrapper> lstWrapper = DGF_NewProductComponentController.fetchTitleVersions(insertDG[0].Id, 'Test');          
            string strJSON = JSON.serialize(lstWrapper);
            
            //checking submit buttons
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG[0].Id, strJSON, 'Tier 2', 'Unrated')) != null);
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG1[0].Id, strJSON, 'Tier 2', 'Unrated')) != null);
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.submitDetails(insertDG2[0].Id, strJSON, 'Tier 2', 'Unrated')) != null);  
            
            //checking release type method
            System.AssertEquals(TRUE, (DGF_NewProductComponentController.getReleaseType(insertDG[0].ID)) != null);  
            
            //check product user
            System.AssertEquals(FALSE, DGF_NewProductComponentController.getProductUser());
        test.stopTest();        
    }
}