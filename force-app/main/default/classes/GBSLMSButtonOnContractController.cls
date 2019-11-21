/*****************************************************************************************
Class Name: GBSLMSButtonOnContractController
Purpose: Apex class for GBSLMSButtonOnContractComponent
Version : 1.0
Created Date : 05/21/2018
Created By : Lakshmi Penamatsa
Modified For : GBS-641 - Scenario #1 - removed prg related code
JIRA : GBS-411
******************************************************************************************/
public without sharing class GBSLMSButtonOnContractController {
    private static Id lmsPrimaryFactoryRecTypeId = Schema.SObjectType.LMS__c.getRecordTypeInfosByName().get(GBSConstants.GBSLMSPRIMARYFACTORY).getRecordTypeId();
    private static Id lmsSubContractedFactoryRecTypeId = Schema.SObjectType.LMS__c.getRecordTypeInfosByName().get(GBSConstants.GBSLMSSUBCONTRACTEDFACTORY).getRecordTypeId();
    private static Id lmsDistributionOnlyRecTypeId = Schema.SObjectType.LMS__c.getRecordTypeInfosByName().get(GBSConstants.GBSLMSDISTRIBUTIONONLY).getRecordTypeId();
   
    /********************************************************
    Method Name: saveLMS
    Purpose: Method to save LMS record with the provided input(JSON string)
    Parameters: String
    Return Type: LMS__c
    *********************************************************/ 
    @AuraEnabled
    public static LMS__c saveLMS(String newLMSJSON ) { 
        
        List<Object> newLMSList = (List<Object>) JSON.deserializeUntyped( newLMSJSON );
        Map<String, Object> results = (Map<String, Object>) newLMSList[0];
              
        LMS__c lms = new LMS__c();
        lms.Factory__c = (Id) results.get('Factory__c');
        lms.Trade_Office__c =  (Id) results.get('Trade_Office__c');
        lms.Notes__c = (String) results.get('Notes__c');
        lms.Contract__c = (Id) results.get('Contract__c');
        
        if(results.get('Primary_Factory__c') != null){  //if Primary_Factory__c is provided in the input ,then the LMS record type will be subcontracted factory          
            lms.RecordTypeId = lmsSubContractedFactoryRecTypeId;
            lms.Primary_Factory__c = (Id) results.get('Primary_Factory__c');
        }        
        else if(results.get('Distributing_Company__c') != null){ //if Distributing_Company__c is provided in the input ,then the LMS record type will be distribution only
            lms.RecordTypeId = lmsDistributionOnlyRecTypeId;
            lms.Distributing_Company__c = (Id) results.get('Distributing_Company__c');
        }        
        else{ //else the LMS record type will be primary factory
            lms.RecordTypeId = lmsPrimaryFactoryRecTypeId; 
        }
        
        
        try{
            //insert LMS record 
            insert lms;
        }catch(DmlException e){
            //  Log exception
            DGF_ExceptionLogController.createExceptionLog('While inserting LMS Record', 'GBSLMSButtonOnContractController.saveLMS', e.getMessage());
        }
        
        return lms;        
    }    
}