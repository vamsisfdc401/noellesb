/*****************************************************************************************
Class Name: GBSIPRightTriggerHandlerTest
Purpose: Test class for apex class GBSIPRightTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy          	Change
1.0             04/27/2018           Jay                  	Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class GBSIPRightTriggerHandlerTest{

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
             
        //Insert Intellectual Properties
        List<Intellectual_Property__c> insertIP = GBSTestDataUtility.createIP(3);
		insert insertIP;       

        // Insert Intellectual Properties Rights
        List<Intellectual_Property_Right__c> insertIPRights = GBSTestDataUtility.createIPRight(insertProductRightsGroup, insertIP);
		insert insertIPRights;

        //Update IP Rights Record
        //Delete IP Rights Record
        delete insertIPRights;

       	// Asserts
       
        test.stopTest();               
    }        
}