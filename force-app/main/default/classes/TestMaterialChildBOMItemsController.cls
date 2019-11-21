/*****************************************************************************************
Class Name: TestMaterialChildBOMItemsController
Purpose: Apex class to To test MaterialChildBOMItemsController.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             14/02/2018           Ashok                    Initial Development
******************************************************************************************/  

@isTest
private class TestMaterialChildBOMItemsController 
{
  static testMethod void TestMaterialChildBOMItemsController()
    {
      Material__c m = new Material__c(Name = 'Test Material');
      insert m;
    
      ApexPages.StandardController sc = new ApexPages.StandardController(m);
      MaterialChildBOMItemsController cls = new MaterialChildBOMItemsController(sc);
         
    }
}