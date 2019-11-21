/************************************************************************************************
Class Name: GBSRegisteredFactoriesServerController
Purpose: Controller Class for GBSRegisteredFactories Component
*************************************************************************************************
Version        	DateModified         	ModifiedBy               	Change
1.0             15/05/2018           	Ashok                    	Initial Development(GBS-332)
*************************************************************************************************/
public with sharing class GBSRegisteredFactoriesServerController 
{

  @AuraEnabled
    Public static List<Factory__c> GetActiveFactories (id LicenseeId)
    {
        /* GBS 597 
         List <LMS__c> LMSActive = [Select  ID,LMS_Status__c,Factory__r.Id FROM LMS__c where LMS__c.Licensee__c = :LicenseeId AND (LMS_Status__c != 'Contract Expired' or LMS_Status__c != 'No Longer Using') ];
			*/
         List <LMS__c> LMSActive = [Select  ID,LMS_Status__c,Factory__r.Id FROM LMS__c where LMS__c.Licensee__c = :LicenseeId AND (LMS_Status__c = 'Active' or LMS_Status__c = 'Accepted') ];
         List <Factory__c> ListActiveFactory = new List<Factory__c>();
         Set<ID> ActiveFactoryIDs = new set<ID>();
        
         If(!LMSActive.isempty())
         {
             for(LMS__c ALM:LMSActive){
                 ActiveFactoryIDs.add(ALM.Factory__r.id);
             }
         }
        /* Remove the inactive factories from it  - GBS 597
         List <LMS__c> LMSInActive = [Select  ID,LMS_Status__c,Factory__r.Id FROM LMS__c where LMS__c.Licensee__c = :LicenseeId AND (LMS_Status__c = 'Contract Expired' or LMS_Status__c = 'No Longer Using') ];
         List <Factory__c> ListInActiveFactory = new List<Factory__c>();
         Set<ID> InActiveFactoryIDs = new set<ID>();
        
         If(!LMSInActive.isempty())
         {
             for(LMS__c ALM:LMSInActive){
                 InActiveFactoryIDs.add(ALM.Factory__r.id);
             }
         }
        
        for(Id objId: ActiveFactoryIDs){
            if(InActiveFactoryIDs.contains(objId)) 
            {
					//Remove them from Active list
				ActiveFactoryIDs.remove(objId);
        			   }
     			 }
        */
        
        If(!ActiveFactoryIDs.Isempty()){
            ListActiveFactory = [Select ID,Name,Factory_Code__c,Factory_Status__c,Approval_Expiration_Date__c from Factory__c where Id in :ActiveFactoryIDs];
        }
        return ListActiveFactory;
        
    }
    
    @AuraEnabled
     Public static List<Factory__c> GetInActiveFactories (id LicenseeId)
    {
         List <LMS__c> LMSInActive = [Select  ID,LMS_Status__c,Factory__r.Id FROM LMS__c where LMS__c.Licensee__c = :LicenseeId AND (LMS_Status__c != 'Active' or LMS_Status__c != 'Accepted') ];
         List <Factory__c> ListInActiveFactory = new List<Factory__c>();
         Set<ID> InActiveFactoryIDs = new set<ID>();
        
         If(!LMSInActive.isempty())
         {
             for(LMS__c ALM:LMSInActive){
                 InActiveFactoryIDs.add(ALM.Factory__r.id);
             }
         }
        
        // Remove the active factories from it  - GBS 597
         List <LMS__c> LMSActive = [Select  ID,LMS_Status__c,Factory__r.Id FROM LMS__c where LMS__c.Licensee__c = :LicenseeId AND (LMS_Status__c = 'Active' or LMS_Status__c = 'Accepted') ];
         //List <Factory__c> ListActiveFactory = new List<Factory__c>();
         Set<ID> ActiveFactoryIDs = new set<ID>();
        
         If(!LMSActive.isempty())
         {
             for(LMS__c ALM:LMSActive){
                 ActiveFactoryIDs.add(ALM.Factory__r.id);
             }
         }
        
        for(Id objId: InActiveFactoryIDs){
            if(ActiveFactoryIDs.contains(objId)) 
            {
					//Remove them from InActive list
				InActiveFactoryIDs.remove(objId);
        			   }
     			 }
        
        
        
         If(!InActiveFactoryIDs.Isempty()){
            ListInActiveFactory = [Select ID,Name,Factory_Code__c,Factory_Status__c,Approval_Expiration_Date__c from Factory__c where Id in :InActiveFactoryIDs];
        }
        return ListInActiveFactory;
        
    }
    
 }