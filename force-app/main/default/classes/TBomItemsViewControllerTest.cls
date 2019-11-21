/*****************************************************************************************
Class Name: TBomItemsViewControllerTest
Purpose: Test class for apex class  TBomItemsViewController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/20/2017           Suman                    Initial Development
******************************************************************************************/
@isTest
private class TBomItemsViewControllerTest{
    @isTest
    static void testMethod_1()
    {
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id, Material_Component__c=null, Component_Number__c='1', Component_Quantity__c='1', Item_Category__c='T');
        insert bomItem1;
        
        Test.setCurrentPage(Page.materialView);
        ApexPages.currentPage().getParameters().put('Id', material1.Id);
        
        Test.startTest();
        
        TBomItemsViewController con = new TBomItemsViewController();
        con.columnsToShow = 'Item_Category__c, BOM_Function__c, Id, BOM_Item_Text_1__c, RecordTypeId';
        con.parentRecordId = material1.Id;
        ApexPages.currentPage().getParameters().put('editBomId', bomItem1.Id);
        
        con.openEditPanel();
        TBomItemsViewController.saveBomItem(bomItem1.Id, '', '1', true, 1, null);
        TBomItemsViewController.saveBomItem(bomItem1.Id, 'Bom Text', '1', true, 1, null);
        TBomItemsViewController.saveBomItem(bomItem1.Id, 'Bom Text', '1', true, 1, material1.Id);
        TBomItemsViewController.saveBomItem(null, 'Bom Text', '1', true, 1, material1.Id);
        
        ApexPages.currentPage().getParameters().put('result', 'error');
        ApexPages.currentPage().getParameters().put('fromEvent', 'save');
        con.handleAfterRemoteAction();
        
        ApexPages.currentPage().getParameters().put('result', 'success');
        ApexPages.currentPage().getParameters().put('fromEvent', 'save');
        con.handleAfterRemoteAction();
        
        ApexPages.currentPage().getParameters().put('result', 'success');
        ApexPages.currentPage().getParameters().put('fromEvent', 'saveNew');
        con.handleAfterRemoteAction();
        
        TBomItemsViewController.removeBomItem(null);
        TBomItemsViewController.removeBomItem(bomItem1.Id);
        
        Test.stopTest();
    }
}