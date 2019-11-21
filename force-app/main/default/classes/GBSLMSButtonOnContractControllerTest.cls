/*****************************************************************************************
Class Name: GBSLMSButtonOnContractControllerTest
Purpose: Test class for GBSLMSButtonOnContractController - Lightning Component
Version : 1.0
DateCreated : 05/25/2018
CreatedBy : Lakshmi
JIRA : GBS-411
******************************************************************************************/
@isTest
public class GBSLMSButtonOnContractControllerTest {
    
/****************************************************************
Method Name: scenario1
Purpose: method to test - creating a new LMS record GBS-411
******************************************************************/    
 private static testMethod void testsaveLMS() {
     Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId();
         
     //insert Factory
     Factory__c factory = GBSTestDataUtility.createFactory(1)[0];    
     insert factory;
     
     //insert Licensee - Account
     Account licensee = GBSTestDataUtility.createAccount(1,licenseeRecTypeId)[0];
     insert licensee;
         
     //insert Contract
     Contract__c contract = GBSTestDataUtility.createContract(licensee.Id, 1)[0];
     insert contract;     
     
     //insert ProductRightsGroup
     Product_Rights_Group__c productRightsGroup = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
     insert productRightsGroup;
     
     //insert Trade Office
     Trade_Office__c tradeOffice = GBSTestDataUtility.createTradeOffice(1)[0];
     insert tradeOffice;
          
     //insert LMS__c
     LMS__c lms = GBSTestDataUtility.createLMS(1)[0];
     lms.Contract__c = contract.Id;
     lms.Product_Rights_Group__c = productRightsGroup.Id;
     lms.Factory__c = factory.Id;
     lms.Licensee__c = licensee.Id;
     lms.Notes__c = 'New LMS record';
     lms.Primary_Factory__c = factory.Id;
     lms.Trade_Office__c = tradeOffice.Id;
     insert lms;
          
     Test.startTest();
          
     String jsonName =' [{"Product_Rights_Group__c":"a2G2F000000JUrWUAW","Factory__c":"a2I2F000000qaK4UAI","Notes__c":"New LMS record","Trade_Office__c":null,"Primary_Factory__c":"a2I2F000000qaK4UAI","Licensee__c":"0012F00000HSZIDQA5"}]';
     
     GBSLMSButtonOnContractController.saveLMS(jsonName);
     
     String jsonNew =' [{"Product_Rights_Group__c":"a2G2F000000JUrWUAW","Factory__c":"a2I2F000000qaK4UAI","Notes__c":"New LMS record","Trade_Office__c":null,"Primary_Factory__c":null,"Licensee__c":"0012F00000HSZIDQA5"}]';
     
     GBSLMSButtonOnContractController.saveLMS(jsonNew); 
     
     String jsonDistributingCompany =' [{"Product_Rights_Group__c":"a2G2F000000JUrWUAW","Factory__c":"a2I2F000000qaK4UAI","Notes__c":"New LMS record","Trade_Office__c":null,"Primary_Factory__c":null,"Distributing_Company__c":"a2O2F0000002D8NUAU", "Licensee__c":"0012F00000HSZIDQA5"}]';
     
     GBSLMSButtonOnContractController.saveLMS(jsonDistributingCompany);
     Test.stopTest();
     system.assertEquals('New LMS record', [Select Notes__c From LMS__c][0].Notes__c);
     
 }

}