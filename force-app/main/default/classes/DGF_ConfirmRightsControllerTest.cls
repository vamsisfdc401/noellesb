/*****************************************************************************************
Class Name: DGF_ConfirmRightsControllerTest
Purpose: Test class for apex class DGF_ConfirmRightsController  
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/05/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_ConfirmRightsControllerTest{ 
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-398
    ***********************************/
    static testMethod void scenario1(){
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10,FilmRecTypeId);
        insert insertDG;
        
        test.StartTest();
            try{
                System.AssertEquals(TRUE,DGF_ConfirmRightsController.updateRightsValidated(insertDG[0].Id) == null);                
            }
            catch(exception ex){
                System.Debug(ex.getMessage());
            }  
            try{
                System.AssertEquals(TRUE,DGF_ConfirmRightsController.updateRightsValidated('test') == null);  
            }
            catch(exception ex){
                System.Debug(ex.getMessage());
            }                  
        test.StopTest();
    }

}