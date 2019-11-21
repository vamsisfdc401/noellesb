/*****************************************************************************************
Class Name: GBSProductRightsGroupTriggerTest
Purpose: Test class for GBSProductRightsGroupTrigger
Version : 1.0
DateModified : 05/07/2018
ModifiedBy : Harsha Vardhan P
JIRA : GBS-14
******************************************************************************************/
@isTest
private class GBSProductRightsGroupTriggerTest {

    /********************************************************
    Method Name: testProductRightsGroupCreate
    Purpose: Test method to Insert records into Contract_Agent_Contact__c junction object.
    Parameters: NA
    Return Type: void
    *********************************************************/ 
    private static testMethod void testProductRightsGroupCreate() {
        Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.AGENTACCOUNT).getRecordTypeId())[0];
        
        Account factoryDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        factoryDefaultAccount.Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        
        Account auditFirmDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        auditFirmDefaultAccount.Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        
        Account tradeOfficeDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        tradeOfficeDefaultAccount.Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        
        Account dealMakerDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        dealMakerDefaultAccount.Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;
        
        insert new List<Account>{account, factoryDefaultAccount, auditFirmDefaultAccount, tradeOfficeDefaultAccount, dealMakerDefaultAccount};
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Agent__c = account.Id;
        insert contract;
        
        Product_Rights_Group__c PRG = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
        PRG.Territories__c = 'WorldWide';
        insert PRG;
        
        system.assertEquals(0, [Select Id From Contract_Agent_Contact__c Where Contract__c =: contract.Id].size());
        
        Contact cont = GBSTestDataUtility.createContact(account.Id, 1, Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AGENTCONTACT).getRecordTypeId())[0];
        cont.Territory__c = 'WorldWide';
        cont.AccountId = account.Id;
        insert cont;
        
        system.assertEquals([Select Id, Agent__c From Contract__c limit 1].Agent__c, [Select Id, AccountId From Contact limit 1].AccountId);
        
        Product_Rights_Group__c PRG1 = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
        PRG1.Territories__c = 'WorldWide';
        insert PRG1;
        
        system.assertEquals(1, [Select Id From Contract_Agent_Contact__c Where Contract__c =: contract.Id AND Contact__c =: cont.Id].size());
    }

    /********************************************************
    Method Name: testProductRightsGroupUpdate
    Purpose: Test method to Update records into Contract_Agent_Contact__c junction object.
    Parameters: NA
    Return Type: void
    *********************************************************/    
    private static testMethod void testProductRightsGroupUpdate() {
        Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.AGENTACCOUNT).getRecordTypeId())[0];
        
        Account factoryDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        factoryDefaultAccount.Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        
        Account auditFirmDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        auditFirmDefaultAccount.Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        
        Account tradeOfficeDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        tradeOfficeDefaultAccount.Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        
        Account dealMakerDefaultAccount = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId())[0];
        dealMakerDefaultAccount.Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;
        
        insert new List<Account>{account, factoryDefaultAccount, auditFirmDefaultAccount, tradeOfficeDefaultAccount, dealMakerDefaultAccount};
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Agent__c = account.Id;
        insert contract;
        
        Contact cont = GBSTestDataUtility.createContact(account.Id, 1, Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AGENTCONTACT).getRecordTypeId())[0];
        cont.Territory__c = 'WorldWide';
        cont.AccountId = account.Id;
        insert cont;
        
        Product_Rights_Group__c PRG = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
        PRG.Territories__c = 'Afghanisthan'; 
        insert PRG;
        
        system.assertEquals(1, [Select Id From Contract_Agent_Contact__c Where Contract__c =: contract.Id AND Contact__c =: cont.Id].size());
        
        PRG = new Product_Rights_Group__c(Id = PRG.Id, Territories__c = 'Andorra');
        update PRG;
        
        system.assertEquals(1, [Select Id From Contract_Agent_Contact__c Where Contract__c =: contract.Id AND Contact__c =: cont.Id].size());
    }

}