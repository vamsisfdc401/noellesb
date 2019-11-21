/*****************************************************************************************
Class Name: GBSContactTriggerHandlerTest
Purpose: Test class for ContactTrigger
Version : 2.0
DateCreated : 04/26/2018
ModifiedDate: 06/28/2018
CreatedBy : Jay
ModifiedBy : Lakshmi(For GBS-407)
******************************************************************************************/
@isTest(seeAllData=FALSE)

public class GBSContactTriggerHandlerTest {

        public static Id agentContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AGENTCONTACT).getRecordTypeId();
        public static Id licenseeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
        public static Id factoryContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.FACTORYCONTACT).getRecordTypeId();
        public static Id auditFirmContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AUDITFIRMCONTACT).getRecordTypeId();
        public static Id tradeOfficeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.TRADEOFFICECONTACT).getRecordTypeId();
        public static Id dealMakerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.DEALMAKERCONTACT).getRecordTypeId();
        public static Id agentAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.AGENTACCOUNT).getRecordTypeId();
        public static Id licenseeAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
        public static Id gbsDefaultAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId();
                   
/***********************************
Method Name: scenario1
Purpose: method to test Agent code for GBS-334
***********************************/
    static testMethod void scenario1(){
   test.startTest();   

        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;        
        insert insertGBSAccnt;
        
        //insert Agent Account
        List<Account> insertAccnt = GBSTestDataUtility.createAccount(2,agentAccountRecTypeId);
        insert insertAccnt;
                
        //Insert Agent Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertAccnt[0].Id,3,agentContactRecTypeId);
        insert insertContact;  

        //Retrieve the Agent Account
        List<Account> acctList = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after trigger: ' + acctList[0].Contact_Emails__c);
 
        // Test that the trigger correctly updated the field
       // System.assertEquals('test.3@test3.com;test.1@test1.com;test.2@test2.com;' , acctList[0].Contact_Emails__c);
        
        //Update Agent Contacts
        for(Contact con : insertContact){
            con.Email = '1' + con.Email;
        }
        update insertContact;

        //Retrieve the updated Agent Account
        List<Account> acctList1 = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after update: ' + acctList1[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;' , acctList1[0].Contact_Emails__c);
         
        //Delete an Agent Contact
        delete insertContact[2];
        
        //Retrieve the update Agent Account        
        List<Account> acctList2 = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after delete: ' + acctList2[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;' , acctList2[0].Contact_Emails__c);
         
        test.stopTest();
        
    }
/***********************************
Method Name: scenario2
Purpose: method to test Factory code for GBS-334 and GBS-283
**********************************/
    static testMethod void scenario2(){
 
        test.startTest();

        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;         
        insert insertGBSAccnt;
 
        //insert Factory
        List<Factory__c> insertFactory = GBSTestDataUtility.createFactory(2);
        insert insertFactory;

        //Insert Factory Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertFactory[0].Id,3,factoryContactRecTypeId);
        insert insertContact;  

        //Retrieve the Factory
        List<Factory__c> factList = [SELECT Id, Contacts__c, Contact_Emails__c FROM
         Factory__c WHERE Id = :insertFactory[0].id];
        System.debug('Contact Emails field after trigger: ' + factList[0].Contact_Emails__c);
 
        // Test that the trigger correctly updated the field
        System.assertEquals('test.1@test1.com;test.2@test2.com;test.3@test3.com;' , factList[0].Contact_Emails__c);
                     
        //Update Factory Contacts
        for(Contact con : insertContact){
            con.Email = '1' + con.Email;
        }
        update insertContact;

        //Retrieve the updated Factory
        List<Factory__c> factList1 = [SELECT Id, Contacts__c, Contact_Emails__c FROM
         Factory__c WHERE Id = :insertFactory[0].id];
        System.debug('Contact Emails field after update: ' + factList1[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;' , factList1[0].Contact_Emails__c);
    
        //Delete a Factory Contact
       // delete insertContact[2];
        
        //Retrieve the updated Factory        
        List<Factory__c> factList2 = [SELECT Id, Contacts__c, Contact_Emails__c FROM
         Factory__c WHERE Id = :insertFactory[0].id];
        System.debug('Contact Emails field after delete: ' + factList2[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;' , factList2[0].Contact_Emails__c);
          
        test.stopTest();               
    }
    
/***********************************
Method Name: scenario3
Purpose: method to test Licensee code for GBS-334
***********************************/
    static testMethod void scenario3(){
        
        test.startTest();   
        //insert Licensee Account
        List<Account> insertAccnt = GBSTestDataUtility.createAccount(2,licenseeAccountRecTypeId);
        insert insertAccnt;               

        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;        
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT; 
        insert insertGBSAccnt;
 
        //Insert Licensee Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertAccnt[0].Id,3,licenseeContactRecTypeId);
        insert insertContact;  

        //Retrieve the Licensee Account
        List<Account> acctList = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after trigger: ' + acctList[0].Contact_Emails__c);
 
        // Test that the trigger correctly updated the field
        System.assertEquals('test.1@test1.com;test.2@test2.com;test.3@test3.com;' , acctList[0].Contact_Emails__c);
               
        //Update Licensee Contacts
        for(Contact con : insertContact){
            con.Email = '1' + con.Email;
        }
        update insertContact;
        
        //Retrieve the updated Agent Account
        List<Account> acctList1 = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after update: ' + acctList1[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;' , acctList1[0].Contact_Emails__c);
         
        //Delete an Licensee Contact
        delete insertContact[2];
        
        //Retrieve the update Agent Account        
        List<Account> acctList2 = [SELECT Id, Contact_Emails__c FROM
         Account WHERE Id = :insertAccnt[0].id];
        System.debug('Contact Emails field after delete: ' + acctList2[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;' , acctList2[0].Contact_Emails__c);
    
        test.stopTest();                
    }

/***********************************
Method Name: scenario4
Purpose: method to test Trade Office code for GBS-334
**********************************/
    static testMethod void scenario4(){
 
        test.startTest();


        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;         
        insert insertGBSAccnt;
        
        //insert Trade Office
        List<Trade_Office__c> insertTradeOffice = GBSTestDataUtility.createTradeOffice(2);
        insert insertTradeOffice;

        //Insert Trade Office Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertTradeOffice[0].Id,3,tradeOfficeContactRecTypeId);
        insert insertContact;  

        //Retrieve the Trade Office
        List<Trade_Office__c> toList = [SELECT Id, Contact_Emails__c FROM
         Trade_Office__c WHERE Id = :insertTradeOffice[0].id];
        System.debug('Contact Emails field after trigger: ' + toList[0].Contact_Emails__c);
 
        // Test that the trigger correctly updated the field
        System.assertEquals('test.1@test1.com;test.2@test2.com;test.3@test3.com;' , toList[0].Contact_Emails__c);
                 
        //Update Trade Office Contacts
        for(Contact con : insertContact){
            con.Email = '1' + con.Email;
        }
        update insertContact;

        //Retrieve the updated Trade Office
        List<Trade_Office__c> toList1 = [SELECT Id, Contact_Emails__c FROM
         Trade_Office__c WHERE Id = :insertTradeOffice[0].id];
        System.debug('Contact Emails field after update: ' + toList1[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;', toList1[0].Contact_Emails__c);
  
        //Delete a Trade Office Contact
        delete insertContact[2];
       
        //Retrieve the updated Trade Office        
        List<Trade_Office__c> toList2 = [SELECT Id, Contact_Emails__c FROM
         Trade_Office__c WHERE Id = :insertTradeOffice[0].id];
        System.debug('Contact Emails field after delete: ' + toList2[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;' , toList2[0].Contact_Emails__c);
      
        test.stopTest();               
    }      
/***********************************
Method Name: scenario5
Purpose: method to test Audit Firm code for GBS-334
**********************************/
    static testMethod void scenario5(){
 
        test.startTest();

        //insert Audit Firm
        List<Audit_Firm__c> insertAuditFirm = GBSTestDataUtility.createAuditFirm(2);
        insert insertAuditFirm;

        //Insert GBS Default Accounts
        List<Account> insertGBSAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertGBSAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertGBSAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertGBSAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        insertGBSAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;         
        insert insertGBSAccnt;
 
        //Insert Audit Firm Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertAuditFirm[0].Id,3,auditFirmContactRecTypeId);
        insert insertContact;  

        //Retrieve the Audit Firm
        List<Audit_Firm__c> auditFirmList = [SELECT Id, Contact_Emails__c FROM
         Audit_Firm__c WHERE Id = :insertAuditFirm[0].id];
        System.debug('Contact Emails field after trigger: ' + auditFirmList[0].Contact_Emails__c);
 
        // Test that the trigger correctly updated the field
        System.assertEquals('test.1@test1.com;test.2@test2.com;test.3@test3.com;' , auditFirmList[0].Contact_Emails__c);
                 
        //Update Audit Firm Contacts
        for(Contact con : insertContact){
            con.Email = '1' + con.Email;
        }
        update insertContact;

        //Retrieve the updated Audit Firm
        List<Audit_Firm__c> auditFirmList1 = [SELECT Id, Contact_Emails__c FROM
         Audit_Firm__c WHERE Id = :insertAuditFirm[0].id];
        System.debug('Contact Emails field after update: ' + auditFirmList1[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;1test.3@test3.com;', auditFirmList1[0].Contact_Emails__c);
  
        //Delete an Audit Firm Contact
        delete insertContact[2];

        //Retrieve the updated Trade Office        
        List<Audit_Firm__c> auditFirmList2 = [SELECT Id, Contact_Emails__c FROM
         Audit_Firm__c WHERE Id = :insertAuditFirm[0].id];
        System.debug('Contact Emails field after delete: ' + auditFirmList2[0].Contact_Emails__c);

        // Test that the trigger correctly updated the field
        System.assertEquals('1test.1@test1.com;1test.2@test2.com;' , auditFirmList2[0].Contact_Emails__c);
             
        test.stopTest();               
    }  

/***********************************
Method Name: scenario6
Purpose: method to test code that sets default Account for GBS-338
**********************************/

    static testMethod void scenario6(){
 
        test.startTest();

        //Insert GBS Default Accounts
        List<Account> insertAccnt = GBSTestDataUtility.createAccount(4,gbsDefaultAccountRecTypeId);
        insertAccnt[0].Name = GBSConstants.DEFAULTTRADEOFFICEACCOUNT;
        insertAccnt[1].Name = GBSConstants.DEFAULTFACTORYACCOUNT;
        insertAccnt[2].Name = GBSConstants.DEFAULTAUDITFIRMACCOUNT;
        insertAccnt[3].Name = GBSConstants.DEFAULTDEALMAKERACCOUNT;         
        insert insertAccnt;
        
        //insert Trade Office
        List<Trade_Office__c> insertTradeOffice = GBSTestDataUtility.createTradeOffice(2);
        insert insertTradeOffice;

        //Insert Trade Office Contacts
        List<Contact> insertContact = GBSTestDataUtility.createContact(insertTradeOffice[0].Id,3,tradeOfficeContactRecTypeId);
        insert insertContact;  

        //Get the default Trade Office Account
        Account defaultTOAccount = [Select Id, Name, RecordTypeId from Account WHERE 
                                             (Name = :GBSConstants.DEFAULTTRADEOFFICEACCOUNT AND RecordTypeId = :gbsDefaultAccountRecTypeId)];        

        //Retrieve the Contact
        List<Contact> TOList = [SELECT Id, AccountId FROM
         Contact WHERE Id = :insertContact[0].id];
        System.debug('AccountId field after trigger: ' + TOList[0].AccountId);

        // Test that the trigger correctly set the field
        System.assertEquals(defaultTOAccount.Id , TOList[0].AccountId);
                       
        test.stopTest();  
    }    
}