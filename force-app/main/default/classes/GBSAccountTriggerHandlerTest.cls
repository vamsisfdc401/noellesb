/*****************************************************************************************
Class Name: GBSAccountTriggerHandler
Purpose: Test Class for GBSAccountTriggerHandler
******************************************************************************************
Version        	DateModified         	ModifiedBy               	Change
1.0             09/05/2018           	Ashok                    	Initial Development(GBS- 223)
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class GBSAccountTriggerHandlerTest 
{
  /********************************************************
	Method Name: testLMSonAssociateContract
	Purpose: Test method to Test Contract Association to LMS.
	Parameters: NA
	Return Type: void
	*********************************************************/ 
    private static testMethod void testAccountLicenseeFlagStatus() {
         test.startTest();  
         Account account = GBSTestDataUtility.createAccount(1, Schema.SobjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId())[0];
         insert account;
        
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Licensee__c = account.Id;
        contract.LMS_Flag__c = null;
        insert contract;
        system.assertEquals(1, [Select Id,LMS_Flag__c From Contract__c Where Contract__c.Id =: contract.Id].size());
        
        account.Licensee_Flag__c ='Exempt Partner';
        update account;
     
        
        test.stopTest();
       
	}
}