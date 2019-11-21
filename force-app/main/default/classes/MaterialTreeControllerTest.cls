/*****************************************************************************************
Class Name: MaterialTreeControllerTest
Purpose: Test class for apex class MaterialTreeControllerTest
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/09/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest
public class MaterialTreeControllerTest{
    
    static testmethod void testMethod_1()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        List<Material__C>materialList =  new List<Material__C>();  
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material1);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material2);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material3);
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material4);
        
        insert materialList;
        List<Bom_item__c>bomItemsList =  new List<Bom_item__c>();
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem1);
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem2);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem3);
        
        insert bomItemsList;
        
        Test.startTest();
        PageReference pageRef = Page.MaterialTreeOnMaterial;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        MaterialTreeController matTreeController = new MaterialTreeController(sc);
        matTreeController.redirectToWizard();
        matTreeController.redirectToBOMWizard();
        Test.stopTest();
    }
    
    
    static testmethod void testMethod_2()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        List<Material__c>materialList =  new list<Material__c>();
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'M (Multipack)','CL - COLLECTION PACK');
        material1.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material1);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material2);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material3);
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material4);
        
        insert materialList;
        
        List<Bom_item__c>bomItemsList =  new List<Bom_item__c>();
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem1);
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem2);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemsList.add(bomItem3);
        insert bomItemsList;
        
        Test.startTest();
        PageReference pageRef = Page.MaterialTreeOnRelease;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(release);
        MaterialTreeController matTreeController = new MaterialTreeController(sc);
        matTreeController.redirectToWizard();
        matTreeController.redirectToBOMWizard();
        Test.stopTest();
    }
    
    static testmethod void testMethod_3()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        List<Material__c>materialList = new list<Material__c>();
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material1);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material2);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material3);
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US'; // to over come NULL pointer error 
        materialList.add(material4);
        
        insert materialList;
        
        List<Bom_item__c>bomItemList =  new List<Bom_item__c>();
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem2);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem3);
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem1);
        
        insert bomItemList;
        
        Test.startTest();
        PageReference pageRef = Page.MaterialTreeOnMaterial;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material2);
        MaterialTreeController matTreeController = new MaterialTreeController(sc);
        matTreeController.redirectToWizard();
        matTreeController.redirectToBOMWizard();
        Test.stopTest();
        
    }
}