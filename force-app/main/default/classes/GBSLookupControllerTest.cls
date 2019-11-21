/*****************************************************************************************
Class Name: GBSLookupControllerTest
Purpose: Test class for GBSLookupController - Lightning Component
Version : 1.0
DateCreated : 08/22/2018
CreatedBy : Lakshmi
JIRA : GBS-564
******************************************************************************************/
@isTest
public class GBSLookupControllerTest {
    
/****************************************************************
Method Name: testSearchDB
Purpose: method to test - search for prg record matching the searchtext given in the component GBS-564
******************************************************************/     
    private static testMethod void testSearchDB() {
        Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId();
        
        //insert Licensee - Account
        Account licensee = GBSTestDataUtility.createAccount(1,licenseeRecTypeId)[0];
        insert licensee;
        
        //insert Contract
        Contract__c contract = GBSTestDataUtility.createContract(licensee.Id, 1)[0];
        insert contract;     
        
        //insert ProductRightsGroup
        Product_Rights_Group__c productRightsGroup = GBSTestDataUtility.createProductRightsGroup(contract.Id, 1)[0];
        productRightsGroup.Name = 'TestPRG';
        productRightsGroup.Product_Details__c = 'TestProductDetails';
        productRightsGroup.IP_Details__c = 'IPDetails';
        insert productRightsGroup;             
        
        String objectName = 'Product_Rights_Group__c';
        String fld_API_Text = 'Name';
        String fld_API_Text1 = 'Product_Details__c';
        String fld_API_Text2 = 'IP_Details__c';
        String fld_API_Val = 'Id';
        Integer lim = 4;
        String fld_API_Search = 'Name';
        String searchText = 'test';
        String contractId = String.valueOf(contract.Id);
        
        Test.startTest();    
        GBSLookupController.searchDB(objectName,fld_API_Text,fld_API_Text1,fld_API_Text2,fld_API_Val,lim, fld_API_Search,searchText,contractId);
        
        searchText = '';
        GBSLookupController.searchDB(objectName,fld_API_Text,fld_API_Text1,fld_API_Text2,fld_API_Val,lim, fld_API_Search,searchText,contractId);
        
        searchText = 'product';
        GBSLookupController.searchDB(objectName,fld_API_Text,fld_API_Text1,fld_API_Text2,fld_API_Val,lim, fld_API_Search,searchText,contractId);
        
        searchText = 'ip';
        GBSLookupController.searchDB(objectName,fld_API_Text,fld_API_Text1,fld_API_Text2,fld_API_Val,lim, fld_API_Search,searchText,contractId);
                
        Test.stopTest();
        
        system.assertEquals('TestPRG', [Select Name From Product_Rights_Group__c].Name);
    }
    
}