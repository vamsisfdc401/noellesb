@isTest 
public class CIRFTestClass {
  static testMethod void testMethod1() 
    {
        Id accRecordTypeName = Schema.SObjectType.account.getRecordTypeInfosByName().get(Label.CIRF_Account_RecordType).getRecordTypeId();
        account cirfAccount=new account();
        cirfAccount.Name='sravanthi3';
        cirfAccount.Territory__c='US';
        cirfAccount.CIRF_RIM_Approval__c=true;
        cirfAccount.CIRF_Retailer_Group__c='Group 4';
        cirfAccount.CIRF_No_RIM_Approval__c='Universal';
        //cirfAccount.CIRF_Sold_To__c='2522111'; //HEITCIRF-547
        cirfAccount.Sold_To__c='2522111';
        cirfAccount.RecordTypeId=accRecordTypeName;
        
        insert cirfAccount;
        CIRF_Header__c obj=new CIRF_Header__c();
        obj.CIRF_Name__c='CIRFTest';
        obj.Request_Type__c='Corrugate';
        obj.CIRF_Start_Date__c=system.today()-99;
        obj.CIRF_End_Date__c=system.today()-1;
        obj.CIRF_In_Store__c=system.today()-100;
        //obj.Retailer__c='001M0000010ggYFI';
        obj.Retailer__c=cirfAccount.id;
        obj.CIRF_Status__c='Loaded';
        obj.Studio__c = 'Universal';
        insert obj;
        
        Test.startTest();

            
       Statusupdatecirfheaderbatch j= new Statusupdatecirfheaderbatch();
          DataBase.executeBatch(j);
        
        Test.stopTest();
    }
}