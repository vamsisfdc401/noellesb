/*****************************************************************************************
Class Name: LinkComponentsControllerTest
Purpose: Test class for apex class LinkComponentsController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Mohit                    Initial Development
******************************************************************************************/
@istest
public class LinkComponentsControllerTest{

    static testmethod void testMethod_1()
    {
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //materialIns.Label_Code__c ='12 - Nelvana';
        materialIns.Label_Code__c ='24 - PURE FLIX';
        materialIns.Territory__c ='US';  // ADDED TO OVERCOME NULL POINTER ERROR 
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy1',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Territory__c ='US'; // ADDED TO OVERCOME NULL POINTER ERROR
        insert objMaterial1;
        
        Material__c objMaterial2 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial2.Territory__c ='US'; // ADDED TO OVERCOME NULL POINTER ERROR
        insert objMaterial2;
        
        //BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        //insert bomItem; 
        
        Material__c materialIns1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns1.Territory__c = 'US';// ADDED TO OVERCOME NULL POINTER ERROR
        insert materialIns1;
        
        /*List<BOM_Item__c> lstBOMItem = new List<BOM_Item__c>();
        
        BOM_Item__c objBOM= new BOM_Item__c();
        objBOM.Material__c = materialIns1.id;
        objBOM.Material_Component__c = materialIns1.id;
        objBOM.Territory__c = materialIns1.territory__c ;
        lstBOMItem.add(objBOM); */
        //insert lstBOMItem;
        
        Set<id>fertIdSet=new Set<id>{materialIns.id};
        Set<id>rohIdSet=new Set<id>{objMaterial1.id};
        test.startTest();
        Cache.Session.put('fertID', fertIdSet);
        Cache.Session.put('rohID', rohIdSet);
        
        PageReference pageRef = Page.LinkComponents;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retURL', '/apex/MaterialCreationWizard');
        ApexPages.currentPage().getParameters().put('rid',release.id);
        
        LinkComponentsController linkComponent=new LinkComponentsController();
        linkComponent.setMaterialDetails();
        linkComponent.lstParentWrapper[0].lstChildWrapper[0].selected = TRUE;
        linkComponent.submit();
        linkComponent.cancel();
        //system.assertEquals(!lstBOMItem.isEmpty(), true);
        linkComponent.rowNum = 0;
        linkComponent.setSelection();
        linkComponent.setSelectALL();
        linkComponent.openRequestWizard();
        Test.stopTest();
    }
    
    static testmethod void testMethod_2()
    {
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //materialIns.Label_Code__c ='12 - Nelvana';
        materialIns.Label_Code__c ='24 - PURE FLIX';
        materialIns.Territory__c = 'US';// ADDED TO OVERCOME NULL POINTER ERROR
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Territory__c = 'US';// ADDED TO OVERCOME NULL POINTER ERROR
        insert objMaterial1;
        
        Material__c objMaterial2 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy3',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial2.Territory__c = 'US';// ADDED TO OVERCOME NULL POINTER ERROR
        insert objMaterial2;
        
        //BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        //insert bomItem; 
        
        Material__c materialIns1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        insert materialIns1;
        
        test.startTest();
        /*List<BOM_Item__c> lstBOMItem = new List<BOM_Item__c>();
        
        BOM_Item__c objBOM= new BOM_Item__c();
        objBOM.Material__c = materialIns1.id;
        objBOM.Material_Component__c = materialIns1.id;
        objBOM.Territory__c = materialIns1.territory__c ;
        lstBOMItem.add(objBOM);*/ 
        //insert lstBOMItem;
        
        Set<id>fertIdSet=new Set<id>{materialIns.id};
        Set<id>rohIdSet=new Set<id>{objMaterial1.id};
        
        Cache.Session.put('fertID', fertIdSet);
        Cache.Session.put('rohID', rohIdSet);
        
        PageReference pageRef = Page.LinkComponents;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retURL', '/apex/MaterialCreationWizard');
        ApexPages.currentPage().getParameters().put('mid',materialIns.id);
        
        LinkComponentsController linkComponent=new LinkComponentsController();
        linkComponent.setMaterialDetails();
        linkComponent.lstParentWrapper[0].lstChildWrapper[0].selected = TRUE;
        linkComponent.submit();
        linkComponent.cancel();
        //system.assertEquals(!lstBOMItem.isEmpty(), true);
        linkComponent.rowNum = 0;
        linkComponent.setSelection();
        linkComponent.setSelectALL();
        linkComponent.openRequestWizard();
        test.stopTest();
    }
}