/*****************************************************************************************
Class Name: AcquisitionDealTriggerTest
Purpose:Test class for AcquisitionDealTrigger Apex class
******************************************************************************************/  
@isTest(seeAllData = false)
private class AcquisitionDealTriggerTest {
    
    private static Id recordTypeId = Schema.SObjectType.Acquisition_Deal__c.getRecordTypeInfosByName().get('July 2018 Layout').getRecordTypeId();
    
    static testMethod void createNewDeal() 
    {
        Test.startTest();
        Acquisition_Deal__c acqDeal = new Acquisition_Deal__c();
        acqDeal.Name = 'TestName';
        acqDeal.Office__c = 'UK';
        acqDeal.CurrencyIsoCode = 'USD';
        acqDeal.On_Hold__c = true;
        acqDeal.Dead__c = true;
        acqDeal.Acquisition_Deal_Stage__c = 'Pending Board Approval';
        acqDeal.RecordTypeId = recordTypeId;
        insert acqDeal;
        System.assert(acqDeal.Id != null);
        
        acqDeal.Name = 'TestDealName';
        acqDeal.Acquisition_Deal_Stage__c = 'Pending Board Approval';
        acqDeal.On_Hold__c = false;
        acqDeal.Dead__c = false;
        Update acqDeal;
        System.assert(acqDeal.Name != null);
        
        acqDeal.Name = 'TestDealName';
        acqDeal.Acquisition_Deal_Stage__c = 'Pending Board Approval';
        acqDeal.Dead__c = false;
        acqDeal.On_Hold__c = true;
        Update acqDeal;
        System.assert(acqDeal.Name != null);
        
        acqDeal.Name = 'TestDealName';
        acqDeal.StageValueBeforeDeadOrOnHold__c = 'TestDeal';
        acqDeal.On_Hold__c = false;
        acqDeal.Dead__c = true;
        Update acqDeal;
        System.assert(acqDeal.Name != null);
        Test.stopTest();
    }
}