/*****************************************************************************************
Class Name: BOMWizardControllerTest 
Purpose: This class is responsible to create a Update material record from existing processed material and also it creates associated child views. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/09/2016           Ipsita                   Initial Development
******************************************************************************************/
@isTest(SeeAllData = FAlSE)
public class BOMWizardControllerTest{
    
    @isTest
    static void testMethod_1()
    {
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;

        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //materialList.add(material1);
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        //insert material2;
        
        
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material3);
        //insert material3;
        test.startTest();
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material4);
        //insert material4;
        
        insert materialList;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= materialList[0].id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= materialList[1].id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c= materialList[2].id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        // Actual test process starts here.
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='FERT';
        bomWizardCtlr.materialIndex='0';
        bomWizardCtlr.selectedMaterialLevel=0;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.sectionCollapseExpand(); // added on 2.03
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        //bomWizardCtlr.type = 'Component';
        bomWizardCtlr.deleteBOMItem();
        bomWizardCtlr.remove();
        test.stopTest();
    }
    
    @isTest
    static void testMethod_2()
    {
        // Preparing the complete Data Setup.
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy5','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //materialList.add(material1);
        material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy6','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
         test.startTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy7','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy8','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
       
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='Component';
        bomWizardCtlr.materialIndex='1';
        bomWizardCtlr.selectedMaterialLevel=1;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        test.stopTest();
    }
    
    @isTest
    static void testMethod_3()
    {
        // Preparing data setup.
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;

        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dumm7','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //materialList.add(material1);
        
material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy10','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.startTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy21','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy22','ROH',release.id,TRUE,'C - Components','DS - DISC');
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedTitleNewMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='Component';
        bomWizardCtlr.materialIndex='1';
        bomWizardCtlr.selectedMaterialLevel=2;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        test.stopTest();
    }
    
    @isTest
    static void testMethod_6()
    {
    
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy33','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //materialList.add(material1);
        material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy222','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.startTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2232','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy224','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedTitleNewMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='FERT';
        bomWizardCtlr.materialIndex='1';
        bomWizardCtlr.selectedMaterialLevel=2;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        test.stopTest();
    }
    
    @isTest
    static void testMethod_4()
    {
    
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy343','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //materialList.add(material1);
        material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy255','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.startTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy351f2','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2gt6','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedTitleMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='FERT';
        bomWizardCtlr.materialIndex='0';
        bomWizardCtlr.selectedMaterialLevel=1;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        
        test.stopTest();
    }
    
    @isTest
    static void testMethod_5()
    {
    
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //materialList.add(material1);
        material1.Sub_Label_Code_Lookup__c=sg.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy234i','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material2);
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.startTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy34202','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material3);
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dum343my2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material4);
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedTitleMat', materialList);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        bomWizardCtlr.materialType='Component';
        bomWizardCtlr.materialIndex='1';
        bomWizardCtlr.selectedMaterialLevel=1;
        bomWizardCtlr.rowNumComp=2;
        //bomWizardCtlr.rowNumFERT=1;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.saveMaterial();
        bomWizardCtlr.submitForApproval();
        bomWizardCtlr.sendDirectToSap();
        bomWizardCtlr.cancel();
        
        test.stopTest();
    }
    
    @isTest
    static void testMethod_7()
    {
    
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        //Deal details
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Sub_Label_Code__c sub_Label_Code = getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1 = getMaterialDetails(material1,title,sub_Label_Code,alternativeLegalTitle);
        material1.deal__C = deal.id;
        materialList.add(material1);
        insert materialList;

        
        Valuation__c valuation = getValuations(material1);
        insert valuation;
        
        Plant__c plant = getPlants(material1);
        insert plant ;
        
        Operations_Group__c operationGroup = getOperation();
        insert operationGroup;
        
        Sales__c sales = getSales(material1,operationGroup);
        insert sales;
        
        
        //Material__c material5=testClassUtility.createMaterial('02 - DVD','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //insert material5;
        
        test.startTest();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Component_Number__c='1',BOM_Quantity__c=2,Component_Quantity__c='2',Production_Flag__c=true,Valid_From__c=Date.newInstance(2000, 12, 12),Item_Category__c='L');
        insert bomItem1;
        //Material_Component__c
        //system.debug('bomItem1-->'+bomItem1);
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',material1.id );
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            bomWizardCtlr.lstMaterial = materialList;
            bomWizardCtlr.bomID = bomItem1.id;
            bomWizardCtlr.materialType='Component';
            bomWizardCtlr.materialIndex='1';
            bomWizardCtlr.selectedMaterialLevel=1;
            bomWizardCtlr.rowNumComp=2;
            //bomWizardCtlr.rowNumFERT=1;
            bomWizardCtlr.getSelectedMat();
            bomWizardCtlr.saveMaterial();
            bomWizardCtlr.submitForApproval();
            bomWizardCtlr.sendDirectToSap();
            bomWizardCtlr.setMaterialDetails();
            bomWizardCtlr.cancel();
        
        test.stopTest();
    }
    
    
    
    @isTest
    static void testMethod_8(){
        
        List<Material__c>materialList =  new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy98','FERT',release.id,TRUE,'D (Display Vehicle)','SS (Single Selection)');
        //material1.Label_Code__c ='';
        //material1.Material_Type__c = '';
        material1.BOM_Status__c = 'Draft';
        
        insert material1;
        materialList.add(material1);
        Test.startTest();
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',material1.id);
            Cache.Session.put('selectedMat', materialList);
             
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            //bomWizardCtlr.renderPage = false;
            bomWizardCtlr.rowNumberFERT = 1;
            bomWizardCtlr.type ='FERT';
            bomWizardCtlr.materialType='FERT';
            bomWizardCtlr.getSelectedMat();
        
            bomWizardCtlr.deleteBOMItem();
        
            bomWizardCtlr.remove();
            bomWizardCtlr.rowNumComp = 1;
            bomWizardCtlr.type ='Component';
            bomWizardCtlr.materialType='Component';
            bomWizardCtlr.remove();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethod_9(){
        
        List<Material__c>materialList =  new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //material1.Label_Code__c ='';
        //material1.Material_Type__c = '';
        material1.BOM_Status__c = 'Draft';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        insert material1;
        
        materialList.add(material1);
        
        Test.startTest();
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',material1.id);
            Cache.Session.put('selectedTitleMat', materialList);
             
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            //bomWizardCtlr.renderPage = false;
            bomWizardCtlr.rowNumberFERT = 1;
            bomWizardCtlr.type ='FERT';
            bomWizardCtlr.materialType='FERT';
            bomWizardCtlr.deleteBOMItem();
            bomWizardCtlr.remove();
            
            
        Test.stopTest();
        
    }
    
    public static testMethod void testDeleteFunction(){
        
        List<Material__c>materialList = new list<Material__c>();
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // material data
        Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','TESTMaterial','FERT',release.id,TRUE,'M (Multipack)','MT - MULTI-TITLE');
        material.Deletion_Flag__c = false;
        material.Selection_Reference_Number__c = '12311230000';
        //material.BOM_Quantity__c = 11;
        //material.Prior_BOM_Quantity__c = '0';
        material.Material_Status__c  = 'Processed in SAP';
        material.Material_Number__c = '11224488000';
        material.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        // child FERT MATERIAL 
        Material__c materialChildFert =  testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','BD','CHILD FERTMATERIAL','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialChildFert.Deletion_Flag__c = false;
        materialChildFert.Material_Status__c  = 'Draft';
        materialChildFert.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        Material__c materialChildFert2 =  testClassUtility.createMaterial('02 - DVD','DVD','CHILD FERTMATERIAL2','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialChildFert2.Deletion_Flag__c = false;
        materialChildFert2.Material_Status__c  = 'Processed in SAP';
        materialChildFert2.Material_Number__c = '19821198000';
        materialChildFert2.BOM_Status__c = 'Processed in SAP';
        materialChildFert2.Retailer_Rental__c='KMT (KMART)';
        materialChildFert2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        // roh material 
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.BOM_Quantity__c = 1;
        materialComponent.Prior_BOM_Quantity__c = '011';
        materialComponent.Material_Status__c  = 'Draft';
        materialComponent.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        Material__c materialComponent2 =  testClassUtility.createMaterial('11 - ULTRA HD 4K','UHD','TESTcomponent2','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent2.Deletion_Flag__c = false;
        materialComponent2.Selection_Reference_Number__c = '12410100000';
        materialComponent2.BOM_Quantity__c = 1;
        materialComponent2.Prior_BOM_Quantity__c = '011';
        materialComponent2.Material_Status__c = 'Processed in SAP';
        materialComponent2.BOM_Status__c = 'Processed in SAP';
        materialComponent2.Material_Number__c = '19821198000';
        materialComponent2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        materialList.add(material);
        materialList.add(materialChildFert);
        materialList.add(materialComponent);
        materialList.add(materialChildFert2);
        materialList.add(materialComponent2);
        
        insert materialList;
        Test.startTest();
        List<Bom_item__c>listBOMItems = new list<Bom_item__c>();
        
        Bom_item__c bomItem = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        
        Bom_item__c bomItem1 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem1.Material_Component__c  = materialChildFert.Id;
        
        Bom_item__c bomItem2 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem2.Material_Component__c  = materialComponent2.Id;
        
        Bom_item__c bomItem3 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem3.Material_Component__c  = materialChildFert2.Id;
        
        listBOMItems.add(bomItem);
        listBOMItems.add(bomItem1);
        listBOMItems.add(bomItem2);
        listBOMItems.add(bomItem3);
        insert listBOMItems;
        
        
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
                        Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                        Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
                        Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
                        Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
                        Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
                        (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
                        (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
                        PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
                        Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
                        (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
                        (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
                        from Material__c where id =:material.ID];
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            
            
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
             
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            
            
            bomWizardCtlr.type = 'Component';
            bomWizardCtlr.rowNumComp = 1;
            bomWizardCtlr.bomID = bomItem2.Id;
            
            bomWizardCtlr.deleteBOMItem();
            
            bomWizardCtlr.type = 'FERT';
            bomWizardCtlr.rowNumberFERT = 1;
            bomWizardCtlr.bomID = bomItem3.Id;
            
            bomWizardCtlr.deleteBOMItem();
            
            // as of now i have created added below code need to change later
            //bomWizardCtlr.setMaterialDetails();
            bomWizardCtlr.type = 'Component';
            bomWizardCtlr.rowNumComp = 0;
            bomWizardCtlr.bomID = bomItem.Id;
            
            bomWizardCtlr.deleteBOMItem();
            
            bomWizardCtlr.type = 'FERT';
            bomWizardCtlr.rowNumberFERT = 0;
            bomWizardCtlr.bomID = bomItem1.Id;
            
            bomWizardCtlr.deleteBOMItem();
            
            
        Test.stopTest();
        
    }
    
    
        
    private static Bom_item__c getBOMItems(Material__c material1,string componentNumber,integer bomQuantity,string componentQuantity, boolean isProductionFlag,Date validFrom,string itemCategory){
        Bom_item__c bomItem = new Bom_item__c(Material__c=material1.id,Component_Number__c=componentNumber,BOM_Quantity__c=bomQuantity,Component_Quantity__c=componentQuantity,Production_Flag__c=isProductionFlag,Valid_From__c=validFrom,Item_Category__c=itemCategory);
        
        return bomItem;
    }
    
    
    // materials details 
    private static Material__c getMaterialDetails(Material__c materialItem,Title__c titleItem,Sub_Label_Code__c subLabelCode,Alternative_Legal_Title__c alternativeLegalTitle){
        // need material additional fields 
        materialItem.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';//date 
        materialItem.Purchase_Value_Key__c = '0000';// string
        materialItem.Transportation_Group__c = '0001';
        materialItem.Plant__c = 'V000';
        materialItem.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';
        materialItem.Material_Type__c ='FERT';
        materialItem.Item_Type__c = 'S (Single)';
        materialItem.Format__c = '02 - DVD';
        materialItem.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
        materialItem.Label_Code__c = '61 - Universal Pictures';
        materialItem.Sub_Label_Code_Lookup__c = subLabelCode.Id;// lookup
        materialItem.General_Item_Category_Group__c ='NORM - Standard item / CU';
        materialItem.Division__c = '10';
        materialItem.Xplant_Material_Status__c = 'AA';
        materialItem.Gross_Weight__c = 0.25;
        materialItem.Net_Weight__c = 0.151;
        materialItem.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        materialItem.Layer__c = 'D05 =00;D09 =00;D10 =00;D14 =00;D18 =00;BR25=00;BR50=00;50/9=00';
        materialItem.Valid_From__c = Date.newInstance(2016,9,07);//'2016-09-07';
        materialItem.Title__c = titleItem.Id;//lookup
        materialItem.TM_Status__c = 'test';
        materialItem.Industry_Sector__c = 'Z';
        materialItem.BOM_Usage__c = '3';
        materialItem.BOM_Category__c = 'M';
        materialItem.Territory__c = 'US';
        materialItem.Street_Date__c = Date.newInstance(2013,05,08);
        materialItem.Base_Unit_of_Measure__c = 'EA';
        materialItem.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        materialItem.Weight_Unit__c = 'LB - US pound';
        materialItem.Create_Version__c = true;
        materialItem.X_Dchain_Status__c = 'AA';
        materialItem.Deletion_Flag__c = false;
        return materialItem;
    }
    
    // sub label code details
    private static Sub_Label_Code__c getSubLabelCode(){
        Sub_Label_Code__c subLabelCode =  new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c = '49';
        subLabelCode.Name = 'TestsubLabelCode';
        subLabelCode.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        return subLabelCode;
    }
    
    // alternative legal title details
    private static Alternative_Legal_Title__c getAlternativeLegalTitle(){
        Alternative_Legal_Title__c alternative_Legal_Title = new Alternative_Legal_Title__c();
        alternative_Legal_Title.name = 'TestAlernativeLegalTitle';
        alternative_Legal_Title.Alternative_Legal_Title_ID__c = '00000007';
        //alternativeLegalTitle.Alternative_Legal_Title_ID_Number__c = '7';
        return alternative_Legal_Title;
    }
    
    // fetch valuation details 
    private static Valuation__c getValuations(Material__c material){
        Valuation__c valuation = new Valuation__c();
        valuation.Material__c = material.id;
        valuation.Valuation_Area__c = 'V000';
        valuation.Valuation_Class__c = '7930 - Finished Goods Home Video';
        valuation.Price_Unit__c = '1000'; 
        valuation.Standard_Price__c = 550;
        valuation.Origin_Group__c = '10';
        valuation.Pricing_Control__c = 'S';
        return valuation;    
    }
    // plant details
    private static Plant__c getPlants(Material__c material){
        Plant__c plant = new Plant__c();
        plant.Material__c = material.id;
        plant.Availability_Check__c = 'CA - Catalog All';
        plant.Valid_From__c = date.newInstance(2000, 11, 11);
        plant.Plant__c = 'V130 - Univ Studios HV';
        plant.MRP_Type__c ='ND - No planning';
        plant.ABC_Indicator__c = 'C - Low Significance - 4 WOS';
        plant.Lot_Size__c = 'Z8 - Dynamic Weekly  lot size 8 weeks';
        plant.Reorder_Point__c = 0;
        plant.Max_Lot_Size__c = 0 ;
        plant.Fixed_Lot_Size__c = 0;
        plant.Max_Stock_Level__c = 0;
        plant.Special_Procurement__c = '50 - Phantom assembly';
        plant.Schedule_Margin_Key__c = '060';
        plant.Period_Ind__c = 'W - Weekly';
        plant.Fwd_Cons_Period__c ='40';
        plant.GR_Processing_Time__c ='1';
        plant.Mixed_MRP__c = '1 - Subassembly planning with final assembly';
        plant.Requirements_Grouping__c= 'T - Display of dependent requirements as a daily total';
        plant.Profit_Center__c= 'V130FM9020';
        plant.Purchasing_Group__c= 'AS1 - Vacant';
        plant.MRP_Controller__c= 'VMD - Catalog Buyer VMD';
        plant.Min_Lot_Size__c= 600;
        plant.Rounding_Value__c= 0 ;
        plant.Plnd_Dely_time__c= '7';
        plant.Stor_Loc_EP__c= '0010';
        plant.Splitting_Ind__c= 'A';
        plant.Bwd_Cons_Period__c= '010';
        plant.Indv_Colle__c= '2';
        plant.Consumption_Mode__c= '2 - Backward/forward consumption';
        plant.Carton_Count__c= 30;
        plant.Procurement_Type__c= 'F - External procurement';
        return plant;    
    }
    // sales data
    private static Sales__c getSales(Material__c material,Operations_Group__c oppGroup){
        Sales__c sales = new Sales__c();
        sales.Material__c = material.Id;
        sales.Material_Group_2__c = 'AR';
        sales.Distribution_Channel__c = '10';
        sales.Tax_Jurisdiction_Code__c ='1';
        sales.County_Sales_Tax__c = '1';
        sales.City_Sales_Tax__c ='1';
        sales.Item_Category_Group__c = 'NORM';
        sales.Sales_Org__c = 'V100 - US Home Video';
        sales.D_Chain_Spec__c = 'FR - Future Release';
        sales.Valid_From__c = Date.newInstance(2000, 01, 1);
        sales.Material_Pricing_Group__c ='D6 - Not Tracked, 33%';
        sales.Operations_Group__c = oppGroup.id;
        sales.Material_Group_3__c = '888 - Master Data Interface Relevant';
        sales.Material_Group_5__c = 'A - Yes-Remove shrink-Place in inventory';
        sales.GST_Canada__c = '0';
        sales.PST_Canada__c = '0';
        sales.PST_Base_GST_CDN__c = '0';
        sales.Material_Statistic_Group__c ='1 - A Material';
        sales.Territory__c ='CDN';
        sales.Pre_Order_Date__c = Date.newInstance(1999, 01, 1); 
        sales.Deliver_Plant__c = 'D0F7';
        return sales;    
    }
    
    // operation group data 
    private static Operations_Group__c getOperation(){
        Operations_Group__c operationGroup = new Operations_Group__c(name = 'TestOperation',Operations_Group_ID__c ='TESTId');
        return operationGroup;
    }
    
    
    
    private static testMethod void testBomwizardcontrollerfunction(){
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Number__c = '2467656';
        material1.BOM_Long_Text__c = 'TEST LONG TEXT PLEASE IGNORE THIS MESSAGE';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        material1.Sub_Label_Code_Lookup__c=sg.id;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //Material__c material1=testClassUtility.createMaterial('02 - DVD','Combo Pack','dummy1','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        insert materialList;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        
        Test.startTest();
        
         List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
            Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
            Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
            Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
            Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
            Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
            (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
            (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
            PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
            Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
            (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
            (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
            from Material__c where id =:material1.ID];
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
        
        
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
        
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            //bomWizardCtlr.selectedMaterialLevel = 
            
            //bomWizardCtlr.getSelectedMat();
            
            
            
            //bomWizardCtlr.lstMaterial = materialList;
            bomWizardCtlr.bomID = bomItem1.id;
            bomWizardCtlr.materialType='Component';
            bomWizardCtlr.materialIndex='1';
            bomWizardCtlr.selectedMaterialLevel=1;
            bomWizardCtlr.rowNumComp=2;
            //bomWizardCtlr.rowNumFERT=1;
            bomWizardCtlr.getSelectedMat();
            
            bomWizardCtlr.saveMaterial();
            bomWizardCtlr.submitForApproval();
            //bomWizardCtlr.cancel();
        Test.stopTest();
    
    }
    
    private static testMethod void testBomwizardcontrollerdeletefunction(){
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        //TriggerUtility.doNotExecute =  true; // soql 101 to over come
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Number__c = '2467656';
        material1.BOM_Long_Text__c = 'TEST LONG TEXT PLEASE IGNORE THIS MESSAGE';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        //material1.BOM_Status__c = 'Approved';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        //Material__c material1=testClassUtility.createMaterial('02 - DVD','Combo Pack','dummy1','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Territory__c = 'US';// TO OVER COME NULL ERROR 
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';// TO OVER COME NULL ERROR 
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        insert materialList;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        //TriggerUtility.doNotExecute =  false; // soql 101 to over come
        Test.startTest();
        
         List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
            Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
            Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
            Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
            Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
            Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
            (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
            (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
            PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
            Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
            (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
            (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
            from Material__c where id =:material1.ID];
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
        
        
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            
            bomWizardCtlr.bomID = bomItem1.id;
            bomWizardCtlr.materialType='FERT';
            bomWizardCtlr.type = 'FERT';
            bomWizardCtlr.rowNumberFERT=0;
            bomWizardCtlr.setMaterialDetails();
            bomWizardCtlr.deleteBOMItem();
            bomWizardCtlr.cancel();

        Test.stopTest();
    
    }
    
    
    private static testMethod void testSendDirectToSAPFunctionality(){
        
        
        Profile p = [select id from profile where name='System Administrator']; 
        
        User u = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testmasterdata', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testmasterdata.com',Master_Data__c = true);


        System.runAs(u) {
        
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Number__c = '2467656';
        material1.BOM_Long_Text__c = 'TEST LONG TEXT PLEASE IGNORE THIS MESSAGE';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        material1.BOM_Status__c = 'Pending Final Approval';
        material1.Sub_Label_Code_Lookup__c=sg.id;
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        //Material__c material1=testClassUtility.createMaterial('02 - DVD','Combo Pack','dummy1','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Territory__c = 'US';
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        insert materialList;
        Test.startTest();
            
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        
        
        
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
            Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
            Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
            Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
            Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
            Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
            (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
            (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
            PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
            Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
            (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
            (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
            from Material__c where id =:material1.ID];
            
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            
            bomWizardCtlr.getSelectedMat();
            bomWizardCtlr.type = 'Component';
            bomWizardCtlr.rowNumComp=0;
            bomWizardCtlr.setMaterialDetails();
            
            bomWizardCtlr.deleteBOMItem();
            
            bomWizardCtlr.sendDirectToSap();
        Test.stopTest();
        }
           
    }
    
     private static testMethod void testScenario11(){
        
        
        Profile p = [select id from profile where name='System Administrator']; 
        
        User u = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testmasterdata', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testmasterdata.com',Master_Data__c = true);


        System.runAs(u) {
        
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;


        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Number__c = '2467656';
        material1.BOM_Long_Text__c = 'TEST LONG TEXT PLEASE IGNORE THIS MESSAGE';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        material1.BOM_Status__c = 'Pending Final Approval';
        material1.Sub_Label_Code_Lookup__c=sg.id;
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        //Material__c material1=testClassUtility.createMaterial('02 - DVD','Combo Pack','dummy1','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Territory__c = 'US';
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        insert materialList;
        Test.startTest();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        
        
        
            
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
            Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
            Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
            Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
            Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
            Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
            (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
            (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
            PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
            Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
            (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
            (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
            from Material__c where id =:material1.ID];
            
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            
            bomWizardCtlr.getSelectedMat();
            bomWizardCtlr.type = 'Component';
            bomWizardCtlr.rowNumComp=0;
            bomWizardCtlr.setItemCategory('','FERT','BF - BABY FERT');
            bomWizardCtlr.setItemCategory('S (Single)','FERT','DS - DISC');
            bomWizardCtlr.setItemCategory('',null,'');
            
            bomWizardCtlr.deleteBOMItem();
            
            bomWizardCtlr.sendDirectToSap();
        Test.stopTest();
        }
           
    }
     private static testMethod void testScenario12(){
        
        
        Profile p = [select id from profile where name='System Administrator']; 
        
        User u = new User(alias = 'standt', email='standarduser@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testmasterdata', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey='America/Los_Angeles', username='standarduser@testmasterdata.com',Master_Data__c = true);


        System.runAs(u) {
        
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Number__c = '2467656';
        material1.BOM_Long_Text__c = 'TEST LONG TEXT PLEASE IGNORE THIS MESSAGE';
        material1.Territory__c = 'US';// TO OVER COME NULL ERROR 
        material1.BOM_Status__c = 'Pending Final Approval';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','DVDR','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        //Material__c material1=testClassUtility.createMaterial('02 - DVD','Combo Pack','dummy1','ROH',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Territory__c = 'US';
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','3D DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        insert materialList;
        Test.startTest();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2',Valid_From__c = date.today());
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        
        
        
            
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
            Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
            Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
            Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
            Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
            Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
            (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
            (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, 
            PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c,Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, 
            Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r),
            (Select id,material__c,material__r.id,material__r.BOM_Quantity__c,material__r.Material_Type__c from BOM_Items1__r ),
            (Select id,Material_Component__r.id,Material_Component__r.BOM_Quantity__c,Material_Component__r.Material_Type__c from BOM_Items__r) 
            from Material__c where id =:material1.ID];
            
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',materialDataToProcess[0].Id);
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            //bomWizardCtlr.getExistingBOMTree();
            bomWizardCtlr.selectedMaterialLevel = 1;
            bomWizardCtlr.materialIndex = '0';
            bomWizardCtlr.sectionCollapseExpand();
            
            BOMWizardController.ApprovalResult cmp = new BOMWizardController.ApprovalResult();
            
        Test.stopTest();
        }
           
    }
    
    static testmethod void testMethod13()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;
        List<Material__c> insMats = new List<Material__c>();
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        material1.Retailer_Rental__c='AMZ (AMAZON)';
        material1.Material_Status__c  = 'Processed in SAP';
        material1.Material_Number__c = '11224488000';
        material1.Sub_Label_Code_Lookup__c=sg.id;
        insMats.add(material1);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        material2.Retailer_Rental__c='AMZ (AMAZON)';
        insMats.add(material2);
        
        Material__c material2B = testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2B.Territory__c = 'US';
        material2B.Retailer_Rental__c='TGT (TARGET)';
        insMats.add(material2B);
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        material3.Retailer_Rental__c='SCR (SCREENER)';
        insMats.add(material3);
        
        Material__c material3B=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3B.Territory__c = 'US';
        material3B.Retailer_Rental__c='KMT (KMART)';
        insMats.add(material3B);
        
        Material__c material4=testClassUtility.createMaterial('11 - ULTRA HD 4K','UHD','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        material4.Retailer_Rental__c='SCR (SCREENER)';
        insMats.add(material4);
        
        Material__c material4B=testClassUtility.createMaterial('11 - ULTRA HD 4K','UHD','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4B.Territory__c = 'US';
        material4B.Retailer_Rental__c='COS (COSTCO)';
        insMats.add(material4B);
        
        Material__c material5=testClassUtility.createMaterial('11 - ULTRA HD 4K','UHD','dummy5','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material5.Retailer_Rental__c='REN (RENTAL)';
        material5.Territory__c = 'US';
        insMats.add(material5);
        
        Material__c material5B=testClassUtility.createMaterial('11 - ULTRA HD 4K','UHD','dummy5','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material5B.Retailer_Rental__c='KMT (KMART)';
        material5B.Territory__c = 'US';
        insMats.add(material5B);
        
        Material__c material6=testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','EST (ELECTRONIC SELL THRU)','dummy6','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material6.Retailer_Rental__c='REN (RENTAL)';
        material6.Territory__c = 'US';
        insMats.add(material6);
        insert insMats;
        
        TriggerUtility.doNotExecute = TRUE;
        List<Bom_item__c> insBoms = new List<Bom_item__c>();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem1);
        
        Bom_item__c bomItem1B=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2B.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem1B);
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem2);
        
        Bom_item__c bomItem2B=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3B.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem2B);
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem3);
        
        Bom_item__c bomItem3B=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4B.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem3B);
        
        Bom_item__c bomItem4=new Bom_item__c(Material__c=material3.id,Material_Component__c=material5.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem4);
        
        Bom_item__c bomItem4B=new Bom_item__c(Material__c=material3.id,Material_Component__c=material5B.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem4B);
        
        Bom_item__c bomItem5=new Bom_item__c(Material__c=material5.id,Material_Component__c=material6.id,Component_Number__c='1',Component_Quantity__c='2');
        insBoms.add(bomItem5);
        
        insert insBoms;
        TriggerUtility.doNotExecute = FALSE;
        
        Test.startTest();
        
        PageReference pageRef = Page.BOMWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid',material1.id );
        Cache.Session.put('selectedMat', insMats);
        BOMWizardController bomWizardCtlr= new BOMWizardController();
        /*bomWizardCtlr.materialType='FERT';
        bomWizardCtlr.materialIndex='0';
        bomWizardCtlr.selectedMaterialLevel=0;
        bomWizardCtlr.getSelectedMat();
        bomWizardCtlr.sectionCollapseExpand();*/
        bomWizardCtlr.rootFERTs[0].childFERTs[1].isNew = TRUE;
        bomWizardCtlr.rootFERTs[0].childComponents[1].isNew = TRUE;
        bomWizardCtlr.rootFERTs[0].childFERTs[0].childFERTs[1].isNew = TRUE;
        bomWizardCtlr.rootFERTs[0].childFERTs[0].childComponents[1].isNew = TRUE;
        
        bomWizardCtlr.saveMaterial();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testMethod_14()
    {
    
        List<Material__c>materialList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        //Deal details
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
                
        Alternative_Legal_Title__c alternativeLegalTitle = getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'UP FEATURES';
        sg.Sub_Label_Code_ID__c = '61';
        Insert sg;

        Material__c material1=testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1 = getMaterialDetails(material1,title,sg,alternativeLegalTitle);
        material1.deal__C = deal.id;
        material1.Sub_Label_Code_Lookup__c=sg.id;
        materialList.add(material1);
        insert materialList;

        
        Valuation__c valuation = getValuations(material1);
        insert valuation;
        
        Plant__c plant = getPlants(material1);
        insert plant ;
        
        Operations_Group__c operationGroup = getOperation();
        insert operationGroup;
        
        Sales__c sales = getSales(material1,operationGroup);
        insert sales;
        
        
        //Material__c material5=testClassUtility.createMaterial('02 - DVD','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        //insert material5;
        
        test.startTest();
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Component_Number__c='1',BOM_Quantity__c=2,Component_Quantity__c='2',Production_Flag__c=true,Valid_From__c=Date.newInstance(2000, 12, 12),Item_Category__c='L');
        insert bomItem1;
        //Material_Component__c
        //system.debug('bomItem1-->'+bomItem1);
        
        
        
            PageReference pageRef = Page.BOMWizard;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('mid',material1.id );
            Cache.Session.put('selectedTitleMat', materialList);
            BOMWizardController bomWizardCtlr= new BOMWizardController();
            bomWizardCtlr.lstMaterial = materialList;
            bomWizardCtlr.bomID = bomItem1.id;
            bomWizardCtlr.materialType='Component';
            bomWizardCtlr.materialIndex='1';
            bomWizardCtlr.selectedMaterialLevel=1;
            bomWizardCtlr.rowNumComp=2;
            //bomWizardCtlr.rowNumFERT=1;
            bomWizardCtlr.getSelectedMat();
            
            BOMWizardController.createUpdateMaterial(materialList[0],sales); 
            
            List<Material__c> matUpdateList=[Select id from Material__c where Original_Material_Number__c=:material1.id];        
            System.assertEquals(matUpdateList.size(),1);
        test.stopTest();
    }
}