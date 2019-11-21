/*****************************************************************************************
Class Name: GBSLMSTriggerHandlerTest
Purpose: Test Class for GBSContractTriggerHandler
******************************************************************************************
Version         DateModified            ModifiedBy                  Change
1.0             09/05/2018              Ashok                       Initial Development(GBS- 223)
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class GBSLMSTriggerHandlerTest 
{
    /********************************************************
    Method Name: testLMSonAssociateContract
    Purpose: Test method to Test Contract Association to LMS.
    Parameters: NA
    Return Type: void
    *********************************************************/ 
    private static testMethod void testLMSonAssociateContract() {
        Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId())[0];
        
        Account LicenseefactoryDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        LicenseefactoryDefaultAccount.Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        
        insert new List<Account>{LicenseefactoryDefaultAccount};
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        insert contract;
            
        Factory__c Factory = GBSTestDataUtility.createFactory(1)[0];
        Factory.Name = 'Test Factory';
        Factory.Factory_Status__c = 'NBCU Audit Required';
        insert Factory;
                
        
        Product_Rights_Group__c PRG = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
        PRG.Territories__c = 'WorldWide';
        PRG.Contract__c = contract.id;
        insert PRG;
        
        system.assertEquals(1, [Select Id From Contract__c Where Contract__c.Id =: contract.Id].size());
        
        LMS__c LMS1 = new LMS__c();
        LMS1.Contract__c = contract.id;
        LMS1.Product_Rights_Group__c = PRG.id;
        insert LMS1;
        
        system.assertEquals(1, [Select Current_Factory_Status__c From LMS__c Where ID =: LMS1.Id ].size());
        List<Contract__c> contractlist = new List<contract__c>();
        
              
              contract.LMS_Flag__c = '';
             update Contract;
        
              contract.LMS_Flag__c = 'No Approved Factories';
             update Contract;
       
        
        
    }
   
}