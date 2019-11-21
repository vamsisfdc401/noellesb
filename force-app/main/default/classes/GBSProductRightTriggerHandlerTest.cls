/*****************************************************************************************
Class Name: GBSProductRightTriggerHandlerTestt
Purpose: Test class for apex class GBSProductRightTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy          	Change
1.0             04/27/2018           Jay                  	Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class GBSProductRightTriggerHandlerTest {

    public static Id licenseeAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
  
/********************************************************
Method Name: scenario1
Purpose: method to test IP rollup code to PRG for GBS-218
*********************************************************/    
    static testMethod void scenario1(){
         
        test.startTest();   

        //May need to insert Agent Account and Agent Contact, because of trigger work related to Agent Contacts
        //Current getting an error when the Product Rights Group is inserted. Also need to add a referece to the Agent
        //on the Contract record--modify the GBSTestDataUtility method to accept a value for the Agent lookup field
  
        //insert Licensee Account
        List<Account> insertAccnt = GBSTestDataUtility.createAccount(2,licenseeAccountRecTypeId);
        insert insertAccnt;               
        
        //Insert Contract
        List<Contract__c> insertContract = GBSTestDataUtility.createContract(insertAccnt[0].Id,1);
        insert insertContract;
        
        //insert Product Rights Groups
        List<Product_Rights_Group__c> insertProductRightsGroup = GBSTestDataUtility.createProductRightsGroup(insertContract[0].Id,2);
        insert insertProductRightsGroup;
        
        //Insert Product Types
        List<Product_Type__c> insertProductType = GBSTestDataUtility.createProductType(3);
		insert insertProductType;
   
        // Insert Product Rights
        List<Product_Right__c> insertProductRights = GBSTestDataUtility.createProductRight(insertProductRightsGroup, insertProductType);
		insert insertProductRights;

        //Update Product Rights Record
           insertProductRights[0].LMS_Flag__c = 'LMS Submitted';
           update insertProductRights;
        //Delete Product Rights Record
              delete insertProductRights;

       	// Asserts
       
        test.stopTest();               
    }        
    
     
/****************************************************************
Method Name: scenario2
Purpose: method to test LMSFlag rollup code to Contract for GBS-223
Author : Ashok
******************************************************************/    
    static testMethod void scenario2(){
         
        test.startTest();   

        Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId())[0];
        insert account;
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Licensee__c = account.Id;
        contract.LMS_Flag__c = null;
        insert contract;

        system.assertEquals(1, [Select Id,LMS_Flag__c From Contract__c Where Contract__c.Id =: contract.Id].size());
        
        
        //insert Product Rights Groups
        List<Product_Rights_Group__c> insertProductRightsGroup = GBSTestDataUtility.createProductRightsGroup(contract.Id,2);
        insert insertProductRightsGroup;
        
        //Insert Product Types
        List<Product_Type__c> insertProductType = GBSTestDataUtility.createProductType(3);
        insertProductType[0].LMS_Flag__c = 'Flag to Review';
        insertProductType[1].LMS_Flag__c = ' ';
        insertProductType[2].LMS_Flag__c = 'No LMS/s Required';
		insert insertProductType;
   
        // Insert Product Rights
        List<Product_Right__c> insertProductRights = GBSTestDataUtility.createProductRight(insertProductRightsGroup, insertProductType);
		insert insertProductRights;
        
        
        //Update Product Rights Record
          
           insertProductRights[0].LMS_Flag__c = 'No LMS Required';
           update insertProductRights;
     
        contract.LMS_Flag__c = 'No LMS Required';
        update contract;
          
        system.assertEquals(1, [Select Id,LMS_Flag__c,Licensee__r.Licensee_Flag__c From Contract__c Where Contract__c.Id =: contract.Id].size());
        
        //Delete Product Rights Record
              delete insertProductRights;
       	// Asserts
       
        test.stopTest();               
    }        
}