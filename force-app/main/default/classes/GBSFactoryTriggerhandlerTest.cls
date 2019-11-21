/*****************************************************************************************
Class Name: GBSFactoryTriggerhandlerTest
Purpose: Apex class to To test GBSFactoryTriggerhandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/16/2018           Ashok                    Initial Development
******************************************************************************************/  
@isTest
public class GBSFactoryTriggerhandlerTest 
{
    Private static testMethod void TestGBSFactoryTrigger()
    {
        Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId();
        
        //insert Factory
        Factory__c factory1 = GBSTestDataUtility.createFactory(1)[0];    
        insert factory1;
        
        Factory__c factory2 = GBSTestDataUtility.createFactory(1)[0];    
        insert factory2;
        
        //insert Licensee - Account
        Account licensee = GBSTestDataUtility.createAccount(1,licenseeRecTypeId)[0];
        insert licensee;
        
        //insert Contract
        Contract__c contract = GBSTestDataUtility.createContract(licensee.Id, 1)[0];
        contract.LMS_Flag__c='No Approved Factories';
        insert contract; 
        
        //insert LMS  
        List<LMS__c> lmsList = GBSTestDataUtility.createLMS(1);
        LMS__c lms = new LMS__c();
        lms.Contract__c = contract.Id;
        lms.Factory__c = factory1.Id;
        lmsList.add(lms);       
        insert lmsList;  
        
        Test.startTest();
        factory1.Factory_Status__c = 'Waiver Review - Approved' ;
        update factory1;
        system.assertEquals('Waiver Review - Approved', factory1.Factory_Status__c);
        
        factory2.Factory_Status__c = 'NBCU Audit - Officially Approved';
        update factory2;
        system.assertEquals('NBCU Audit - Officially Approved', factory2.Factory_Status__c);
        
        List<LMS__c> LMSContractList = [Select Contract__r.id,Contract__r.LMS_Flag__C  from LMS__c WHERE  LMS__c.Factory__c = :factory1.Id];
               
        Test.stopTest();
        
    }
    
}