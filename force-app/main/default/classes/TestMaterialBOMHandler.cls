/*****************************************************************************************
Class Name: TestMaterialBOMHandler
Purpose: This is the Test Class of MaterialBOMHandler.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/07/2016           Suman Kundu              Initial Development
******************************************************************************************/
@isTest
private class TestMaterialBOMHandler
{
    // This test method covers scenario to add parent material to a child material.
    @isTest
    static void testMethod1()
    {
        // Preparing test setup data.
        // Creating Release.
        Release__c rel = new Release__c();
        rel.Name = 'Test Release';
        rel.Street_Date__c = Date.today().addMonths(1);
        rel.Territory__c = 'US';
        rel.Release_Status__c = 'Materials Not Requested';
        rel.Format__c = 'DVD';
        rel.Brand_Group__c = 'Universal Pictures';
        rel.Project_Type__c = 'New Release';
        
        insert rel;
        
        // Creating Material.
        Material__c mat = new Material__c();
        mat.Name = 'Test Material';
        mat.Material_Status__c = 'Draft';
        mat.Material_Type__c = 'FERT';
        mat.Format_Description__c = 'DVD';
        mat.Release__c = rel.Id;
        mat.Territory__c = 'US & CDN';
        
        insert mat;
        
        Test.startTest();
        
        // Test Context is setup with CreateBOMItemPage.
        PageReference pageRef = Page.CreateBOMItemPage;
        Test.setCurrentPage(pageRef);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('retURL', '/001');
        
        MaterialBOMHandler con = new MaterialBOMHandler(new ApexPages.StandardController(new BOM_Item__c()));
        con.BOMItemList[0].Material__c = mat.Id;
        
        // Adding a BOM Item.
        con.addBOMItem();
        System.assert(con.BOMItemList.size() == 2);
        con.BOMItemList[1].Material__c = mat.Id;
        
        con.itemIndex = 1;
        con.removeBOMItem();
        
        // Commiting the change.
        con.save();
        System.assert([SELECT Id FROM BOM_Item__c WHERE Material__c = :mat.Id].size() == 1);
        
        con.cancel();
        
        Test.stopTest();
    }
    
    // This method is to test negative test scenarios.
    @isTest
    static void testMethod2()
    {
        // Creating Release data.
        Release__c rel = new Release__c();
        rel.Name = 'Test Release';
        rel.Street_Date__c = Date.today().addMonths(1);
        rel.Territory__c = 'US';
        rel.Release_Status__c = 'Materials Not Requested';
        rel.Format__c = 'DVD';
        rel.Brand_Group__c = 'Universal Pictures';
        rel.Project_Type__c = 'New Release';
        
        insert rel;
        
        Material__c mat = new Material__c();
        mat.Name = 'Test Material';
        mat.Material_Status__c = 'Draft';
        mat.Material_Type__c = 'FERT';
        mat.Format_Description__c = 'DVD';
        mat.Release__c = rel.Id;
        mat.Territory__c = 'US & CDN';
        
        insert mat;
        
        Test.startTest();
        
        // Setting up Test Context with page CreateBOMItemPage.
        PageReference pageRef = Page.CreateBOMItemPage;
        Test.setCurrentPage(pageRef);

        MaterialBOMHandler con = new MaterialBOMHandler(new ApexPages.StandardController(new BOM_Item__c()));
        con.BOMItemList[0].Material__c = mat.Id;
        
        // Removing BOM Item from lines.
        con.itemIndex = 0;
        con.removeBOMItem();
        
        // Commiting changes to test error.
        con.save();
        
        // Adding BOM Item.
        con.addBOMItem();
        System.assert(con.BOMItemList.size() == 1);
        con.BOMItemList[0].Material__c = mat.Id;
        
        // Committing changes.
        con.save();
        
        con.cancel();
        
        Test.stopTest();
    }
}