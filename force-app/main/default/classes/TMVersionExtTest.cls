/*****************************************************************************************
Class Name: TMVersionExtTest
Purpose: Test class for apex class TMVersionExt Controller
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
public class TMVersionExtTest{
    
    @isTest
    static void testMethod_1()
    {
        List<Material__c> materialList=new List<Material__c>();
        List<Bom_item__c> bomItemList=new List<Bom_item__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='1231';
        title.Series_SGENNO__c='1231';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        TM_Version__c tmversion=new TM_Version__c(Series_Sys__c='1231',Name='TMVersion1');
        insert tmversion;
        
        TM_Version__c tmversion1=new TM_Version__c(Series_Sys__c='1231',Name='TMVersion2');
        insert tmversion1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.territory__c='US';
        materialList.add(material1);
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.territory__c='US';
        materialList.add(material2);
        insert material2;
        Test.startTest();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem1);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.territory__c='US';
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.territory__c='US';
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem2);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem3);
        
        insert bomItemList;
        
        // added start and stop on 16.12
        PageReference pageRef = Page.TMVersion;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        TMVersionExt tmversionext= new TMVersionExt (sc);
        tmversionext.SaveTM();
        tmversionext.cancel();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod_2()
    {
        List<Material__c> materialList=new List<Material__c>();
        List<Bom_item__c> bomItemList=new List<Bom_item__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='1231';
        title.Series_SGENNO__c='1231';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.territory__c='US';
        materialList.add(material1);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.territory__c='US';
        materialList.add(material2);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.territory__c='US';
        materialList.add(material3);
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.territory__c='US';
        materialList.add(material4);
        
        insert materialList;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem1);
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem2);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        bomItemList.add(bomItem3);
        
        
        insert bomItemList;
        
        Sales__c saleChild=new Sales__c(Material__c=material1.id,Distribution_Channel__c='12');
        insert saleChild;
        
        Test.startTest(); // added start and stop on 16.12
        PageReference pageRef = Page.ReleaseTVersion;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(release);
        TMVersionExt tmversionext= new TMVersionExt (sc);
        tmversionext.SaveTM();
        tmversionext.cancel();
        Test.StopTest();
    }
    
    @isTest
    static void testMethod_3()
    {
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='1231';
        title.Series_SGENNO__c='1231';
        insert title;
		
		Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.territory__c='US';
        material1.title__c=title.id;
		material1.deal__c = deal.id;
        materialList.add(material1);
        insert material1;
        
        
        PageReference pageRef = Page.ReleaseTVersion;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        TMVersionExt tmversionext= new TMVersionExt (sc);
        tmversionext.SaveTM();
        tmversionext.cancel();
    }
}