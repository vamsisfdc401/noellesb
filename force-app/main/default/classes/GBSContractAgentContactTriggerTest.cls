/*****************************************************************************************
Class Name: GBSContractAgentContactTriggerTest
Purpose: Test class for GBSContractAgentContactTrigger
Version : 1.0
DateCreated : 06/14/2018
CreatedBy : Lakshmi (For GBS-467)
******************************************************************************************/
@isTest
public class GBSContractAgentContactTriggerTest {
    
    public static Id licenseeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
    public static Id factoryContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.FACTORYCONTACT).getRecordTypeId();
    public static Id licenseeAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
    public static Id gbsDefaultAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId();
             
    /****************************************************************
    Method Name: testContractAgentContactInsert
    Purpose: method to test insertion of contractAgentContact record
    ******************************************************************/
    private static testMethod void testContractAgentContactInsert() {
        GBSTriggerManager__c tgrManager = new GBSTriggerManager__c(Name = 'GBSContractAgentContactTrigger', GBSDisable__c = true);
        insert tgrManager;
        
        Test.startTest();
        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
		insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
		insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
		insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT; 
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;
        insert insertGBSAccnt;
        
        //insert Licensee Account
        List<Account> licensee = GBSTestDataUtility.createAccount(2,licenseeAccountRecTypeId);
        insert licensee; 
        
        //insert licensee Contract
        List<Contract__c> contract = GBSTestDataUtility.createContract(licensee[0].Id, 1);  
        insert contract;
        
		//insert Factory
        List<Factory__c> insertFactory = GBSTestDataUtility.createFactory(2);
        insert insertFactory;

        //Insert Factory Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertFactory[0].Id,3,factoryContactRecTypeId);
        insert insertContact;
        
        //Update Agent Contacts
        for(Contact con : insertContact){
            con.Email = 'test.1@test1.com';
            con.HasOptedOutOfEmail = false;
        }
        update insertContact;
        
        //insert ContractAgentContact
        List<Contract_Agent_Contact__c> contractAgentContact = GBSTestDataUtility.createContractAgentContact(1, contract[0].Id , insertContact[0].Id);
        insert contractAgentContact;
        
        
        // Test that the trigger correctly updated the field        
      	List<Contract__c> contractList = [SELECT Id, Agent_Contact_Emails__c FROM
        Contract__c WHERE Id = :contract[0].id];
        Test.stopTest();
       	System.assertNotEquals('test.1@test1.com' , contractList[0].Agent_Contact_Emails__c);
    }
    
    /****************************************************************
    Method Name: testContractAgentContactInsert1
    Purpose: method to test insertion of contractAgentContact record
    ******************************************************************/
    private static testMethod void testContractAgentContactInsert1() {
        
        Test.startTest();
        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
		insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
		insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
		insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT; 
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;
        insert insertGBSAccnt;
        
        //insert Licensee Account
        List<Account> licensee = GBSTestDataUtility.createAccount(2,licenseeAccountRecTypeId);
        insert licensee; 
        
        //insert licensee Contract
        List<Contract__c> contract = GBSTestDataUtility.createContract(licensee[0].Id, 1);  
        insert contract;
        
		//insert Factory
        List<Factory__c> insertFactory = GBSTestDataUtility.createFactory(2);
        insert insertFactory;
        Test.stopTest();

        //Insert Factory Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertFactory[0].Id,3,factoryContactRecTypeId);
        insert insertContact;
        
        //Update Agent Contacts
        for(Contact con : insertContact){
            con.Email = 'test.1@test1.com';
            con.HasOptedOutOfEmail = false;
        }
        update insertContact;
        
        //insert ContractAgentContact
        List<Contract_Agent_Contact__c> contractAgentContact = GBSTestDataUtility.createContractAgentContact(1, contract[0].Id , insertContact[0].Id);
        insert contractAgentContact;
        
        delete contractAgentContact;
    }

}