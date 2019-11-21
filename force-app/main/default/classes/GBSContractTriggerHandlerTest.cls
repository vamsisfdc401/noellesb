/*****************************************************************************************
Class Name: GBSContractTriggerHandlerTest
Purpose: Test class for apex class GBSContractTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy          	Change
1.0             05/17/2018           Ashok                 	Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class GBSContractTriggerHandlerTest    
{
      public static Id licenseeAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
            
/****************************************************************
Method Name: scenario1
Purpose: method to test LMSFlag update for Contract for GBS-223
Author : Ashok
******************************************************************/    
    static testMethod void scenario1(){
         
        test.startTest();   

        Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId())[0];
        account.Licensee_Flag__c ='Exempt Partner';
        insert account;
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Licensee__c = account.Id;
        contract.LMS_Flag__c = null;
        insert contract;

        system.assertEquals(1, [Select Id,LMS_Flag__c From Contract__c Where Contract__c.Id =: contract.Id].size());
        
        contract.LMS_Flag__c = 'No LMS Submitted';
        update contract;
        
        test.stopTest();               
    }        
}