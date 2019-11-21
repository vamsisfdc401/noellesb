/*****************************************************************************************
Class Name: GBSRegisteredFactoriesControllerTest
Purpose: Apex class to To test GBSRegisteredFactoriesServerController.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/16/2018           Ashok                    Initial Development
******************************************************************************************/  
@isTest
public class GBSRegisteredFactoriesControllerTest 
{
    Private static testMethod void GBSRegisteredFactories()
    {
         Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId();
         List<Factory__c> ActiveFactory = new List<Factory__c>();
         List<Factory__c> InActiveFactory = new List<Factory__c>();
     
     //insert Factory
     Factory__c factory = GBSTestDataUtility.createFactory(1)[0];    
     insert factory;
     
     //insert Licensee - Account
     Account licensee = GBSTestDataUtility.createAccount(1,licenseeRecTypeId)[0];
     insert licensee;
         
     //insert Contract
     Contract__c contract = GBSTestDataUtility.createContract(licensee.Id, 1)[0];
     insert contract;     
     
     //insert ProductRightsGroup
     Product_Rights_Group__c productRightsGroup = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
     insert productRightsGroup;
    
     //insert Trade Office
     Trade_Office__c tradeOffice = GBSTestDataUtility.createTradeOffice(1)[0];
     insert tradeOffice;
         
     //insert LMS__c
     LMS__c lms = GBSTestDataUtility.createLMS(1)[0];
     lms.Contract__c = contract.Id;
    lms.Product_Rights_Group__c = productRightsGroup.Id;
     lms.Factory__c = factory.Id;
     lms.Licensee__c = licensee.Id;
     lms.Notes__c = 'New LMS record';
     lms.Primary_Factory__c = factory.Id;
     lms.Trade_Office__c = tradeOffice.Id;
     lms.LMS_Status__c = 'Accepted';
     insert lms;
        
     Test.startTest();
     	ActiveFactory = GBSRegisteredFactoriesServerController.GetActiveFactories(licensee.Id);
        system.assertEquals(1, ActiveFactory.size()) ;   
        
        lms.LMS_Status__c = 'Contract Expired';
        update lms;

        InActiveFactory = GBSRegisteredFactoriesServerController.GetInActiveFactories(licensee.Id);
        system.assertEquals(1, InActiveFactory.size()) ;  
        
     Test.stopTest();
    
    }
}