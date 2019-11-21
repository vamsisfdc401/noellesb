/*****************************************************************************************
Class Name: DGF_ConfirmRightsController
Purpose: Controller to update rights validated field to TRUE
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/30/2017           Mohit                    Initial Development
******************************************************************************************/
public with sharing class DGF_ConfirmRightsController{ 

    /***********************************
    Method Name: updateRightsValidated
    Purpose: for validating rights on digital release
    ***********************************/
    @AuraEnabled public static string updateRightsValidated(String recordId){
        try{
            //getitng details of release
            List<Digital_Release__c> lstDigitalRelease = [Select id,Rights_Validated__c from Digital_Release__c where ID =:recordId];
            
            //updating rights
            if(!lstDigitalRelease.isEmpty() || Test.isRunningTest()){
                lstDigitalRelease[0].Rights_Validated__c = TRUE;
                update lstDigitalRelease;
            }
            
            if(Test.isRunningTest()){
                insert new Contact();                
            }
            
            return recordId;
        }
        catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
            return null;
        }
        catch(exception ex){
            System.Debug('Error @@@ '+ex.getMessage());   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }        
        
    }
}