/*****************************************************************************************
Class Name: GBSLicenseeFlagTriggerHandlerTest
Purpose: Test class for PCWorkflowTrigger and GBSContractTrigger
Version : 1.0
DateCreated : 05/16/2018
CreatedBy : Lakshmi
JIRA : GBS-331
******************************************************************************************/
@isTest
public class GBSLicenseeFlagTriggerHandlerTest {
    
/****************************************************************
Method Name: scenario1
Purpose: method to test LicenseeFlag as No Approved Factories for Active Contracts- GBS-331
******************************************************************/   
    private static testMethod void testLicenseeFlagForActiveContracts() {
        Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
        
        //insert Account of GBS Licensee record type
        List<Account> accountList = new List<Account>();
        Account account = GBSTestDataUtility.createAccount(1, licenseeRecTypeId)[0];
        Account account1 = GBSTestDataUtility.createAccount(1, licenseeRecTypeId)[0];
        accountList.add(account1);
        accountList.add(account);
        insert accountList;
        
        //insert Contracts
        List<Contract__c> gbsContractList = new List<Contract__c>();
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Agent__c = accountList[0].Id;
        contract.Contract_Status__c = GBSCONSTANTS.GBSCONTRACTSTATUSPENDING;
        contract.LMS_Flag__c =  GBSCONSTANTS.GBSLMSNOAPPROVEDFACTORIES;   
        gbsContractList.add(contract);
        insert gbsContractList;
        
        system.assertEquals('No Approved Factories', [Select Licensee_Flag__c From Account][0].Licensee_Flag__c); 
        
        //update contract
        contract =  [SELECT Id,Agent__c, Contract_Status__c, LMS_Flag__c FROM Contract__c WHERE Id =: contract.Id];
        contract.Agent__c = accountList[1].Id;
        update contract; 
        
        system.assertEquals('No Approved Factories', [Select Licensee_Flag__c From Account][1].Licensee_Flag__c);  
        
        //delete contract
        contract =  [SELECT Id,Agent__c, Contract_Status__c, LMS_Flag__c FROM Contract__c WHERE Id =: contract.Id];
        delete contract;  
        
        system.assertEquals('No Approved Factories', [Select Licensee_Flag__c From Account][0].Licensee_Flag__c);      
    }
        
    /****************************************************************
    Method Name: scenario2
    Purpose: method to test LicenseeFlag as No Active Contracts- GBS-331
    ******************************************************************/    
    private static testMethod void testLicenseeFlagForInActiveContracts() {
        Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
        
        //insert Account of GBS Licensee record type
        Account account = GBSTestDataUtility.createAccount(1, licenseeRecTypeId)[0];
        insert account;
        
        //insert contracts
        List<Contract__c> gbsContractList = new List<Contract__c>();
        Contract__c contract = GBSTestDataUtility.createContract(account.Id, 1)[0];
        contract.Agent__c = account.Id;
        contract.Contract_Status__c = 'On Hold';
        contract.LMS_Flag__c = GBSCONSTANTS.GBSLMSNOAPPROVEDFACTORIES;   
        gbsContractList.add(contract);
        insert gbsContractList;
         
        
        //update contract
        contract =  [SELECT Id,Agent__c, Contract_Status__c, LMS_Flag__c FROM Contract__c WHERE Id =: contract.Id];
        contract.Contract_Status__c = GBSCONSTANTS.GBSCONTRACTSTATUSPENDING;
        update contract; 
        
        system.assertEquals('No Approved Factories', [Select Licensee_Flag__c From Account].Licensee_Flag__c);  
        
        //delete contract
        contract =  [SELECT Id,Agent__c, Contract_Status__c, LMS_Flag__c FROM Contract__c WHERE Id =: contract.Id];
        delete contract;  
        
        system.assertEquals(null, [Select Licensee_Flag__c From Account].Licensee_Flag__c);  
        
    }
 
    /****************************************************************
    Method Name: scenario3
    Purpose: method to test LicenseeFlag as Exempt Partner for PartnerExemptionWorkFlow- GBS-331
    ******************************************************************/    
    private static testMethod void testLicenseeFlagPartnerExemptWorkflow() {
        Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();
        Id workflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get(GBSConstants.GBSPARTNEREXEMPTIONWORKFLOW).getRecordTypeId();
        Id auditWorkflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
        
        //insert Account of GBS Licensee record type
        Account account = GBSTestDataUtility.createAccount(1, licenseeRecTypeId)[0];
        insert account;
        
        //insert LMS as PrimaryLMS field for the PartnerExecptionWorkflow record
        
        List<LMS__c> lmsList = GBSTestDataUtility.createLMS(1);
        insert lmsList;
        
        //insert workflow of partner exemption record type
        List<Workflow__c> workFlowList = new List<Workflow__c>();
        Workflow__c workflow = new Workflow__c();
        workflow.Licensee__c = account.Id;
        workflow.RecordTypeId = workflowRecTypeId;
        workflow.Action_Status__c = GBSCONSTANTS.GBSPARTNEREXEMPTIONAPPROVEDCONDITIONALLY;
        workflow.Primary_LMS__c = lmsList[0].Id;
        workFlowList.add(workflow);
        
        Workflow__c workflow1 = new Workflow__c();     
        workflow1.RecordTypeId = auditWorkflowRecTypeId;
        workflow1.Action_Status__c = 'Pending Official Approval';     
        workFlowList.add(workflow1);     
        insert workFlowList;
        
        system.assertEquals('Partner Exemption - Conditionally Approved', [Select Licensee_Flag__c From Account].Licensee_Flag__c);
        
        //update workflow record
        workflow =  [SELECT Id,Licensee__c, Action_Status__c FROM Workflow__c WHERE Id =: workflow.Id];
        workflow.Action_Status__c = GBSCONSTANTS.GBSPARTNEREXEMPTIONAPPROVED;
        update workflow; 
        
        system.assertEquals('Exempt Partner', [Select Licensee_Flag__c From Account].Licensee_Flag__c);
        
       
        //update workflow record
        workflow =  [SELECT Id,Licensee__c, Action_Status__c FROM Workflow__c WHERE Id =: workflow.Id];
        workflow.Action_Status__c = 'Under Review';
        update workflow; 
        
        system.assertEquals('Partner Exemption - Under Review', [Select Licensee_Flag__c From Account].Licensee_Flag__c);
        
        //delete workflow record
        workflow =  [SELECT Id,Licensee__c, Action_Status__c FROM Workflow__c WHERE Id =: workflow.Id]; 
        delete workflow;
        
        system.assertEquals(null, [Select Licensee_Flag__c From Account].Licensee_Flag__c); 
     
    }
}