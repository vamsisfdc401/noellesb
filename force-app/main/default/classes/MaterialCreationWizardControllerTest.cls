/*****************************************************************************************
Class Name: MaterialCreationWizardControllerTest
Purpose: Test class for apex class  MaterialCreationWizardController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
2.0             12/09/2017           Jyothsna                  Made changes as part of REL-20
******************************************************************************************/
@isTest
private class MaterialCreationWizardControllerTest{
    
    static testmethod void testMethod_1()
    {
         test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'MaterialDetail');
        ApexPages.currentPage().getParameters().put('id', material1.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController();       
        test.StopTest();
    }
    
    static testmethod void testMethod_2()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'MaterialListView');
        
        MaterialCreationWizardController material= new MaterialCreationWizardController();  
        test.StopTest();        
    }
    
    static testmethod void testMethod_3()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','TV','New Release','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.stopTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseDetail');
        ApexPages.currentPage().getParameters().put('id', release.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController materialIns= new MaterialCreationWizardController(); 
        
        material.setStreetDateOnTitleChange();
        
        material.setReleaseName();
        material.openPopUp();
        material.closePopUp();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.addMaterial();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.copyMaterialTree();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.setTitleDetails();
        
        material.setMaterialDetails();
        material.setKeyFields(material.rootFERTs[0].instance,null,null,null,null,null,null,null,null,null,null,FALSE,null,null);
        material.cancel();
        material.backMaterialDescription();
        material.submit();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.setMaterialDefault();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createSalesRecord();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createPlantRecord();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createClassificationRecord();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createAUoMRecord();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createValuationRecord();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.checkLinkComponents = TRUE;
        material.redirectUserAndSetQueue();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.setTerritoryDetails();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.checkLinkComponents = FALSE;
        material.redirectUserAndSetQueue();
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.createBOMItem();
        
        material.negativeScearioTesting = TRUE;
        material.createBOMItem();
        material.negativeScearioTesting = TRUE;
        material.setMaterialDefault();
        material.negativeScearioTesting = TRUE;
        material.createSalesRecord();
        material.negativeScearioTesting = TRUE;
        material.createPlantRecord();
        material.negativeScearioTesting = TRUE;
        material.createClassificationRecord();
        material.negativeScearioTesting = TRUE;
        material.createAUoMRecord();
        material.negativeScearioTesting = TRUE;
        material.createValuationRecord();
        material.negativeScearioTesting = TRUE;
        material.redirectUserAndSetQueue();
        material.negativeScearioTesting = TRUE;
        material.setTerritoryDetails();
        
        material.rootFERTs = material.rootFERTs[0].newFERTs;
        material.rootFERTs = material.rootFERTs[0].existingFERTs;
        
        materialIns.addFormats();        
        materialIns.rootFERTs[0].instance.Format_Description__c = 'DVD';
        materialIns.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        materialIns.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt = new List<Material__c>();
        lstTempMt.add(material4);
        cache.session.put('selectedMat',lstTempMt);
        materialIns.getSelectedMat();
        materialIns.rootFERTs[0].childComponents[2].isExisting = TRUE;
        materialIns.componentIndex = 2;
        materialIns.updateTerritoryOfDisc();   //REL - 20
        materialIns.removeComponent();   
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.componentIndex = 1;
        materialIns.removeComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'FERT';
        List<Material__c> lstTempMt1 = new List<Material__c>();
        lstTempMt1.add(material3);
        cache.session.put('selectedMat',lstTempMt1);
        materialIns.getSelectedMat();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt2 = new List<Material__c>();
        lstTempMt2.add(material4);
        cache.session.put('selectedTitleMat',lstTempMt2);
        materialIns.getSelectedMat();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'FERT';
        List<Material__c> lstTempMt3 = new List<Material__c>();
        lstTempMt3.add(material3);
        cache.session.put('selectedTitleMat',lstTempMt3);
        materialIns.getSelectedMat();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt4 = new List<Material__c>();
        lstTempMt4.add(material4);
        cache.session.put('selectedTitleNewMat',lstTempMt4);
        materialIns.getSelectedMat();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'FERT';
        List<Material__c> lstTempMt5 = new List<Material__c>();
        lstTempMt5.add(material3);
        cache.session.put('selectedTitleNewMat',lstTempMt5);
        materialIns.getSelectedMat();
        
        
    }
    
    static testmethod void testMethod_4()
    {
        
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
       
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseListView');
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        material.setMaterialDefault();
        material.createSalesRecord();
        material.createPlantRecord();
        material.createClassificationRecord();
        material.createAUoMRecord();
        material.createValuationRecord();
        
        material.checkLinkComponents = TRUE;
        material.negativeScearioTesting = FALSE;
        material.redirectUserAndSetQueue(); 
        
        material.formatRowToRemove = 1;
        material.compRowNumber = 1;
        material.compChildRowNumber = 1;
        material.formatChildRowToRemove = 1;
        material.addComponentsToIndex = 1;
        material.addMaterialsToIndex = 1;
        material.addChildComponentsToIndex = 1;
        material.frmtRowNumChild = 1;
        material.frmtRowNumParent = 1;
        
        material.setStreetDateOnTitleChange();
        
        material.setReleaseName();
        material.openPopUp();
        material.closePopUp();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.addMaterial();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.copyMaterialTree();
        
        material.materialIndex = '0';
        material.selectedMaterialLevel = 1;
        material.setTitleDetails();
        
        material.setMaterialDetails();
        material.setKeyFields(material.rootFERTs[0].instance,null,null,null,null,null,null,null,null,null,null,FALSE,null,null);
        material.cancel();
        material.backMaterialDescription();
        material.submit();
        material.setMaterialDefault();
        material.createSalesRecord();
        material.createPlantRecord();
        material.createClassificationRecord();
        material.createAUoMRecord();
        material.createValuationRecord();
        material.redirectUserAndSetQueue();
        material.setTerritoryDetails();
        
        material.materialIndex = '0';
        material.removeFERTs();
        
        test.stopTest();
        
    }
    
    static testmethod void testMethod_5()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
       
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController material11= new MaterialCreationWizardController(); 
        
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.checkLinkComponents = FALSE;
        material.redirectUserAndSetQueue();  
        
        material.addFormats();        
        material.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material.lstMaterialRecords.add(material5);
        material.submit();
        
        material11.addFormats();        
        material11.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material11.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material11.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material11.lstMaterialRecords = new List<Material__c>();
        material11.lstMaterialRecords.add(material5);
        material11.showMPM = TRUE;
        material11.submit();
        
        test.stopTest();
    }
    
    static testmethod void testMethod_6()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.id;
        material1.Territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController material12 = new MaterialCreationWizardController();
        MaterialCreationWizardController material13 = new MaterialCreationWizardController();
        MaterialCreationWizardController material14 = new MaterialCreationWizardController(); 
        
        material.negativeScearioTesting = FALSE;
        material.hasException = FALSE;
        material.checkLinkComponents = FALSE;
        material.redirectUserAndSetQueue();  
        
        material.addFormats();        
        material.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material.lstMaterialRecords.add(material5);
        material.submit();
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = null;
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Territory__c = null;
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Material_Type__c = 'ROH';        
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'BD';
        material12.rootFERTs[0].instance.Material_Type__c = 'FERT';        
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'BF - BABY FERT';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'BD';
        material12.rootFERTs[0].instance.Material_Type__c = 'FERT';        
        material12.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material12.rootFERTs[0].instance.Item_Code__c = 'CL - COLLECTION PACK';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Title__c = title.id;
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Title__c = null;
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'CE - COMPILATIONS';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Title__c = title.id;
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Material_Type__c = 'FERT';        
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'BF - BABY FERT';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Territory__c = 'US';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        
        release.Territory__c = 'US';
        material12.releaseDetails = release;
        material12.addFormats();        
        material12.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material12.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material12.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material12.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material12.rootFERTs[0].instance.Territory__c = 'CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material12.lstMaterialRecords = new List<Material__c>();
        material12.lstMaterialRecords.add(material5);
        material12.mapTitleDetails = new Map<ID,Title__c>();
        material12.prepareCompleteBOMHierarchy(material12.rootFERTs);
        
        release.Territory__c = 'US';
        material13.releaseDetails = release;
        material13.addFormats();        
        material13.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material13.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material13.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material13.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.rootFERTs[0].instance.Title__c = title.id;
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        material13.releaseDetails = release;
        material13.addFormats();        
        material13.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material13.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material13.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material13.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.rootFERTs[0].instance.Title__c = title.id;
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,deal);        
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        material13.releaseDetails = release;
        material13.addFormats();        
        material13.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material13.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material13.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material13.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.rootFERTs[0].instance.Title__c = title.id;
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null);        
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        material13.releaseDetails = release;
        material13.addFormats();        
        material13.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material13.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material13.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material13.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.rootFERTs[0].instance.Title__c = title.id;
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null);        
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        material13.releaseDetails = release;
        material13.addFormats();        
        material13.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material13.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        material13.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        material13.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null);        
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        List<SelectOption> tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[2].getValue();
        material13.setTemplateMaterials();
        material13.selectedTemplateId = tempOptions[0].getValue();
        material13.setTemplateMaterials();
        material13.showMPM = true;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();
        material13.showMPM = false;
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        // Added during REL-45
        List<SelectOption> discOpts = material13.discTypes;
        String selDsc = material13.selectedDiscType;
        Integer cntDsc = material13.multiDiscQty;
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].childComponents[0].instance.ID = material2.ID;
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].childComponents[0].instance.Component_Type__c = null;
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = 'CDN';
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = null;
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].instance.Territory__c = 'US';
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = 'CDN';
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = 'US';
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].instance.Territory__c = 'US';
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = 'US';
        material13.rootFERTs[0].childComponents[0].instance.Component_Type__c = 'DISC BD';
        material13.prepareCompleteBOMHierarchy(material13.rootFERTs);
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material13.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material13.lstMaterialRecords = new List<Material__c>();
        material13.lstMaterialRecords.add(material5);
        material13.mapTitleDetails = new Map<ID,Title__c>();
        material13.mapTitleDetails.put(title.ID,title);
        material13.titleDealMap = new Map<ID,Deal__c>();
        material13.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material13.availableTemplates;
        material13.selectedTemplateId = tempOptions[1].getValue();
        material13.setTemplateMaterials();     
        
        material13.rootFERTs[0].instance.Territory__c = 'US';
        material13.rootFERTs[0].childComponents[0].instance.Territory__c = 'US';
        material13.rootFERTs[0].childComponents[0].instance.Component_Type__c = 'DISC BD';
        material.rootFERTs[0].childComponents = material.rootFERTs[0].newComponents;
        material.rootFERTs[0].childComponents = material.rootFERTs[0].existingComponents;
        
        test.stopTest();
    }
    
    
    static testmethod void testMethod_7()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        // Added during REL-45
        List<SelectOption> discOpts = material14.discTypes;
        material14.selectedDiscType = discOpts[1].getValue();
        material14.multiDiscQty = 0;
        material14.createMultipleDisc();
        material14.multiDiscQty = 80;
        material14.createMultipleDisc();
        material14.multiDiscQty = 2;
        material14.createMultipleDisc();
        
        List<Material__c> lstTempMt6 = new List<Material__c>();
        lstTempMt6.add(material2);
        cache.session.put('selectedMat',lstTempMt6);
        material14.getSelectedMat();  
        material14.rootFERTs[0].childFERTs[0].instance.Item_Type__c = 'S (Single)';
        material14.rootFERTs[0].childFERTs[0].instance.Item_Code__c = 'BF - BABY FERT';    
        material14.rootFERTs[0].childFERTs[0].instance.Territory__c = 'CDN'; 
        System.debug('Check child list size '+material14.rootFERTs[0].childFERTs.size());     
        material14.prepareCompleteBOMHierarchy(material14.rootFERTs);
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'CL - COLLECTION PACK';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt7 = new List<Material__c>();
        lstTempMt7.add(material2);
        cache.session.put('selectedMat',lstTempMt7);
        material14.getSelectedMat();  
        material14.rootFERTs[0].childFERTs[0].instance.Item_Type__c = 'S (Single)';
        material14.rootFERTs[0].childFERTs[0].instance.Item_Code__c = 'BF - BABY FERT';    
        material14.rootFERTs[0].childFERTs[0].instance.Territory__c = 'US'; 
        System.debug('Check child list size '+material14.rootFERTs[0].childFERTs.size());     
        material14.prepareCompleteBOMHierarchy(material14.rootFERTs);
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt8 = new List<Material__c>();
        lstTempMt8.add(material2);
        cache.session.put('selectedMat',lstTempMt8);
        material14.getSelectedMat();  
        material14.rootFERTs[0].childFERTs[0].instance.Item_Type__c = 'S (Single)';
        material14.rootFERTs[0].childFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';    
        material14.rootFERTs[0].childFERTs[0].instance.Territory__c = 'US'; 
        System.debug('Check child list size '+material14.rootFERTs[0].childFERTs.size());     
        material14.prepareCompleteBOMHierarchy(material14.rootFERTs);
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt9 = new List<Material__c>();
        lstTempMt9.add(material2);
        cache.session.put('selectedMat',lstTempMt9);
        material14.getSelectedMat();  
        material14.rootFERTs[0].childFERTs[0].instance.Item_Type__c = 'S (Single)';
        material14.rootFERTs[0].childFERTs[0].instance.Item_Code__c = 'BF - BABY FERT';    
        material14.rootFERTs[0].childFERTs[0].instance.Territory__c = 'CDN'; 
        System.debug('Check child list size '+material14.rootFERTs[0].childFERTs.size());     
        material14.prepareCompleteBOMHierarchy(material14.rootFERTs);
        
        Set<ID> setID = new Set<ID>();
        setID.add(material1.ID);
        setID.add(material2.ID);
        setID.add(material3.ID);
        setID.add(material4.ID);
        material14.fetchBOMHierarchyToDelete(setID);
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt10 = new List<Material__c>();
        lstTempMt10.add(material2);
        cache.session.put('selectedMat',lstTempMt10);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt11 = new List<Material__c>();
        lstTempMt11.add(material2);
        cache.session.put('selectedMat',lstTempMt11);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'D (Display Vehicle)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.ID = material1.ID;
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt121 = new List<Material__c>();
        lstTempMt121.add(material2);
        cache.session.put('selectedMat',lstTempMt121);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt111 = new List<Material__c>();
        lstTempMt111.add(material2);
        cache.session.put('selectedMat',lstTempMt111);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.removeFERTs();
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = null;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt112 = new List<Material__c>();
        lstTempMt112.add(material2);
        cache.session.put('selectedMat',lstTempMt112);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release1;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        test.stopTest();
    }
    
    
    static testmethod void testMethod_8()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release1;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = null;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Test';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt20 = new List<Material__c>();
        lstTempMt20.add(material2);
        cache.session.put('selectedMat',lstTempMt20);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = FALSE;
        material14.rootFERTs[0].childFERTs[0].bomItemId= null;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Test';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt11 = new List<Material__c>();
        lstTempMt11.add(material2);
        cache.session.put('selectedMat',lstTempMt11);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;
        material14.addComponent();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt111 = new List<Material__c>();
        lstTempMt111.add(material2);
        cache.session.put('selectedMat',lstTempMt111);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;
        material14.addMaterial();
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt141 = new List<Material__c>();
        lstTempMt141.add(material2);
        cache.session.put('selectedMat',lstTempMt141);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;
        material14.qtyCount = 2;
        material14.copyMaterialTree();
        
        material14.addFormats();
        release.Title__c = title.ID;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt201 = new List<Material__c>();
        lstTempMt201.add(material2);
        cache.session.put('selectedMat',lstTempMt201);
        material14.getSelectedMat();  
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].bomItemId= null;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        material14.addFormats();
        release1.Title__c = title.ID;
        material14.releaseDetails = release1;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt2011 = new List<Material__c>();
        lstTempMt2011.add(material2);
        cache.session.put('selectedMat',lstTempMt2011);
        material14.getSelectedMat();  
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].bomItemId= null;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        
        material14.addFormats();
        release.Title__c = title.ID;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt2101 = new List<Material__c>();
        lstTempMt2101.add(material2);
        cache.session.put('selectedMat',lstTempMt2101);
        material14.getSelectedMat();  
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].bomItemId= null;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
        
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material14.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.mapTitleDetails.put(title.ID,title);
        material14.titleDealMap = new Map<ID,Deal__c>();
        material14.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        List<SelectOption> tempOptions = material14.availableTemplates;
        material14.selectedTemplateId = tempOptions[1].getValue();
        material14.setTemplateMaterials();     
        
        release.Title__c = title.ID;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childComponents [0].instance = material2;
        material14.rootFERTs[0].childComponents [0].isExisting = TRUE;
        material14.rootFERTs[0].childComponents [0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childComponents [0].instance.Release__c = release.ID;
        material14.removeComponent();
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material14.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.mapTitleDetails.put(title.ID,title);
        material14.titleDealMap = new Map<ID,Deal__c>();
        material14.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material14.availableTemplates;
        material14.selectedTemplateId = tempOptions[1].getValue();
        material14.setTemplateMaterials();     
        
        release.Title__c = title.ID;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 1;        
        material14.rootFERTs[0].childComponents [0].instance = material2;
        material14.rootFERTs[0].childComponents [0].isExisting = TRUE;
        material14.rootFERTs[0].childComponents [0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childComponents [0].instance.Release__c = release.ID;
        material14.removeComponent();
        
        release.Territory__c = 'US';
        release.Label_Code__c = '61 - Universal Pictures';
        release.Brand_Group__c = 'TV';
        release.Project_Type__c = 'New Release';
        material14.releaseDetails = release;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.mapTitleDetails.put(title.ID,title);
        material14.titleDealMap = new Map<ID,Deal__c>();
        material14.titleDealMap.put(deal.Title__c,null); 
        // Changed for REL-45
        tempOptions = material14.availableTemplates;
        material14.selectedTemplateId = tempOptions[1].getValue();
        material14.setTemplateMaterials();     
        
        release.Title__c = title.ID;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'In Progress';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].isExisting = TRUE;
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 1;        
        material14.rootFERTs[0].childComponents [0].instance = material2;
        material14.rootFERTs[0].childComponents [0].isExisting = TRUE;
        for(integer i=0;i<material14.rootFERTs[0].childComponents.size();i++){
            material14.rootFERTs[0].childComponents [0].instance.Material_Status__c = 'Processed in SAP';
        }
        
        material14.rootFERTs[0].childComponents [0].instance.Release__c = release.ID;
        material14.removeComponent();
        material14.sectionCollapseExpand();
        material14.setSubLabelCode();
        test.stopTest();
    }
    
    static testmethod void testMethod_9()
    {
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c = Label.G1200_SGENNO;
        insert title;

        Title__c title1=testClassUtility.createTitle('Test Title1',true);
        title1.SGENNO__c='000123';
        insert title1;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '24 - PURE FLIX';
        deal.Deal_ID__c = '1234';
        deal.Origin_Code__c= '027 - Direct To Video';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        release1.Label_Code__c = '61 - Universal Pictures';
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        User u = [Select id,Label_Code__c from User where ID =: userinfo.getUserID()];
        
        LabelCode_SubLabelCode_Map__c csLSM = new LabelCode_SubLabelCode_Map__c();
        if(u.Label_Code__c != null){
            csLSM.Name= u.Label_Code__c;
        }else{
            csLSM.Name= '61 - Universal Pictures';
        }
        
        csLSM.Sub_Label_Code_Id__c = '61';
        insert csLSM;

        LabelCode_SubLabelCode_Map__c csLSM1 = new LabelCode_SubLabelCode_Map__c();
        csLSM1.Name= '24 - PURE FLIX';
        csLSM1.Sub_Label_Code_Id__c = '61';
        insert csLSM1;

        LabelCode_SubLabelCode_Map__c csLSM2 = new LabelCode_SubLabelCode_Map__c();
        csLSM2.Name= '32 - Elevation';
        csLSM2.Sub_Label_Code_Id__c = '61';
        insert csLSM2;      
        
        Origin_Code__c insertOC = new Origin_Code__c();
        insertOC.Label_Code__c = '32 - Elevation';
        insertOC.Origin_Code__c = '027 - Direct To Video';
        insert insertOC;
        /*
        Sub_Label_Code__c insertSubLblCode = new Sub_Label_Code__c();
        insertSubLblCode.Name = 'UP FEATURES';
        insertSubLblCode.Sub_Label_Code_ID__c = '61';
        insertSubLblCode.Label_Code__c = '61 - Universal Pictures';
        insert insertSubLblCode;
        */
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        
        release.Title__c = null;
        material14.releaseDetails = release1; 
        material14.addFormats();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.setTitleDetailsG1200();
        
        material14.setMaterialDetails();
        
        test.StopTest();
    }
    
    static testmethod void testMethod_18()
    {
        
        test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseListView');
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        material.setMaterialDefault();
        material.createSalesRecord();
        material.createPlantRecord();
        material.createClassificationRecord();
        material.createAUoMRecord();
        material.createValuationRecord();
        
        material.checkLinkComponents = TRUE;
        material.negativeScearioTesting = FALSE;
        material.redirectUserAndSetQueue(); 
        
        material.formatRowToRemove = 1;
        material.compRowNumber = 1;
        material.compChildRowNumber = 1;
        material.formatChildRowToRemove = 1;
        material.addComponentsToIndex = 1;
        material.addMaterialsToIndex = 1;
        material.addChildComponentsToIndex = 1;
        material.frmtRowNumChild = 1;
        material.frmtRowNumParent = 1;
        
        material.releaseDetails.Brand_Group__c = 'Universal Pictures';
        material.releaseDetails.Project_Type__c = 'New Release';
        integer i = material.rootIns.numberOfRecords;
        material.rootIns.updatePaginationCounter();
        material.rootIns.nextPage();
        material.rootIns.firstPage();
        material.rootIns.getDisableNext();
        material.rootIns.getDisablePrevious();
        material.rootIns.getPageList();
        test.StopTest();
    }
    
    static testmethod void testMethod_19()
    {    
          test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        TriggerUtility.doNotExecute = FALSE;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseListView');
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        material.setMaterialDefault();
        material.createSalesRecord();
        material.createPlantRecord();
        material.createClassificationRecord();
        material.createAUoMRecord();
        material.createValuationRecord();
        
        material.checkLinkComponents = TRUE;
        material.negativeScearioTesting = FALSE;
        material.redirectUserAndSetQueue(); 
        
        material.formatRowToRemove = 1;
        material.compRowNumber = 1;
        material.compChildRowNumber = 1;
        material.formatChildRowToRemove = 1;
        material.addComponentsToIndex = 1;
        material.addMaterialsToIndex = 1;
        material.addChildComponentsToIndex = 1;
        material.frmtRowNumChild = 1;
        material.frmtRowNumParent = 1;
        
        material.releaseDetails.Brand_Group__c = 'Universal Pictures';
        material.releaseDetails.Project_Type__c = 'New Release';
        material.addFormats();
        material.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material.rootFERTs[0].instance.Title__c = null;
        material.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material.rootFERTs[0].instance.Release__c = release.ID;
        material.rootFERTs[0].isExisting = TRUE;    
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material3);
        cache.session.put('selectedMat',lstTempMt19);        
        material.materialIndex = '0;0';
        material.selectedMaterialLevel = 2;    
        material.getSelectedMat();
        material.setPageNumberForBOMHierarchy(material.rootFERTs);
        test.StopTest();
    }
    
    static testmethod void testMethod_20()
    {
         
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','TV','New Release','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','TV','New Release','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
         Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        test.StopTest();
       Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseDetail');
        ApexPages.currentPage().getParameters().put('id', release.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController materialIns= new MaterialCreationWizardController(); 
        
        materialIns.addFormats();        
        materialIns.rootFERTs[0].instance.Format_Description__c = 'DVD';
        materialIns.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        materialIns.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt = new List<Material__c>();
        lstTempMt.add(material4);
        cache.session.put('selectedMat',lstTempMt);
        materialIns.getSelectedMat();
        materialIns.rootFERTs[0].childComponents[2].isExisting = TRUE;
        materialIns.rootFERTs[0].childComponents[2].instance.Release__c = release1.id;
        materialIns.componentIndex = 2;
        materialIns.removeComponent();   
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.componentIndex = 1;
        materialIns.removeComponent();
        
        
    }
    static testmethod void testMethod_21()
    {
         
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','TV','New Release','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','TV','New Release','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.stopTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
       
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseDetail');
        ApexPages.currentPage().getParameters().put('id', release.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController materialIns= new MaterialCreationWizardController(); 
        
        materialIns.addFormats();        
        materialIns.rootFERTs[0].instance.Format_Description__c = 'DVD';
        materialIns.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        materialIns.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt = new List<Material__c>();
        lstTempMt.add(material4);
        cache.session.put('selectedMat',lstTempMt);
        materialIns.getSelectedMat();
        materialIns.rootFERTs[0].childComponents[2].isExisting = TRUE;
        materialIns.rootFERTs[0].childComponents[2].instance.Release__c = release1.id;
        materialIns.rootFERTs[0].childComponents[2].instance.Material_Status__c  = 'Processed in SAP';
        materialIns.componentIndex = 2;
        materialIns.removeComponent();   
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.componentIndex = 1;
        materialIns.removeComponent();
        
        
    }
    
    static testmethod void testMethod_22()
    {
         
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','TV','New Release','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','TV','New Release','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.stopTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseDetail');
        ApexPages.currentPage().getParameters().put('id', Release.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController materialIns= new MaterialCreationWizardController(); 
        
        materialIns.addFormats();        
        materialIns.rootFERTs[0].instance.Format_Description__c = 'DVD';
        materialIns.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        materialIns.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt = new List<Material__c>();
        lstTempMt.add(material4);
        cache.session.put('selectedMat',lstTempMt);
        materialIns.getSelectedMat();
        materialIns.rootFERTs[0].instance.id = material3.id;
        materialIns.rootFERTs[0].childComponents[2].isExisting = TRUE;
        materialIns.rootFERTs[0].childComponents[2].instance.Release__c = release1.id;
        materialIns.rootFERTs[0].childComponents[2].instance.Material_Status__c  = 'Draft';
        materialIns.rootFERTs[0].childComponents[2].instance.Component_Material__c = material3.id;
        materialIns.componentIndex = 2;
        materialIns.releaseDetails= null;
        materialIns.removeComponent();   
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.componentIndex = 1;
        
        materialIns.removeComponent();
        
        
    } 
        static testmethod void testMethod_23()
    {
         
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        test.startTest();
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
   
        test.stopTest();
    }
    
    static testmethod void testMethod_24()
    {
         test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.removeFERTs();
   
        test.stopTest();
    }
    
    static testmethod void testMethod_25()
    {
         test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].instance.ID = material1.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Draft';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].childFERTs[0].instance.Component_Material__c = material1.ID;
        material14.releaseDetails = null;
        material14.removeFERTs();
   
        test.stopTest();
    }
    
    static testmethod void testMethod_26()
    {
         test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
		deal.SGENNO__c = title.SGENNO__c;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
		material1.deal__c = deal.id;
        insert material1;
        test.stopTest();
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material1.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].instance.ID = material1.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].childFERTs[0].instance.Component_Material__c = material1.ID;
        material14.rootFERTs[0].childFERTs[0].bomItemId = bomItem2.ID;
        material14.removeFERTs();
   
        
    }
    
    static testmethod void testMethod_27()
    {
         
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
		deal.SGENNO__c = title.SGENNO__c;
        deal.Finance_Default_Deal__c = TRUE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures';
        deal.Deal_ID__c = '1234';
        insert deal;         
        test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c=title.ID;
        material1.territory__c='US';
        material1.deal__c = deal.id;
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        test.stopTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material5=testClassUtility.createMaterial('12 - VOD','BD-R','dummyf43','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        
        
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material1.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'TitleDetail');
        ApexPages.currentPage().getParameters().put('id', title.id);
        
        MaterialCreationWizardController material14= new MaterialCreationWizardController(); 
        
        material14.addFormats();
        release.Title__c = null;
        material14.releaseDetails = release;        
        material14.rootFERTs[0].instance.Format_Description__c = 'DVD';
        material14.rootFERTs[0].instance.Item_Type__c = 'M (Multipack)';
        material14.rootFERTs[0].instance.Item_Code__c = 'MT - MULTI-TITLE';
        material14.rootFERTs[0].instance.BOM_Status__c = 'Draft';
        material14.rootFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].instance.Title__c = null;
        material14.rootFERTs[0].instance.Material_Type__c = 'FERT';
        material14.rootFERTs[0].instance.Label_Code__c = '61 - Universal Pictures';
        material14.rootFERTs[0].instance.Territory__c = 'US & CDN';
        material14.rootFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].instance.ID = material1.ID;
        material5.Label_Code__c = '61 - Universal Pictures';
        material14.lstMaterialRecords = new List<Material__c>();
        material14.lstMaterialRecords.add(material5);
        material14.mapTitleDetails = new Map<ID,Title__c>();
        material14.materialIndex = '0';
        material14.selectedMaterialLevel = 1;
        material14.materialType = 'FERT';
        List<Material__c> lstTempMt19 = new List<Material__c>();
        lstTempMt19.add(material2);
        cache.session.put('selectedMat',lstTempMt19);
        material14.getSelectedMat();  
        material14.materialIndex = '0;0';
        material14.selectedMaterialLevel = 2;        
        material14.rootFERTs[0].childFERTs[0].instance = material2;
        material14.rootFERTs[0].childFERTs[0].isExisting = TRUE;
        material14.rootFERTs[0].childFERTs[0].instance.Material_Status__c = 'Processed in SAP';
        material14.rootFERTs[0].childFERTs[0].instance.Release__c = release.ID;
        material14.rootFERTs[0].childFERTs[0].instance.Component_Material__c = material1.ID;
        material14.rootFERTs[0].childFERTs[0].bomItemId = bomItem2.ID;
        material14.resetMaterialList(material14.rootFERTs);
   
        
    }
    
    static testmethod void testMethod_28()
    {
         test.startTest();
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','TV','New Release','Materials Not Requested',title.id);
        insert release;
        
        Release__c release1=testClassUtility.createRelease('Test Release1','TV','New Release','Materials Not Requested',title.id);
        insert release1;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insert material2;
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        test.stopTest();
        Material__c material3=testClassUtility.createMaterial('12 - VOD','BD-R','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.Territory__c = 'US';
        insert material3;
        
        Material__c material4=testClassUtility.createMaterial('12 - VOD','BD-R','dummy4','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material4.Territory__c = 'US';
        insert material4;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c=material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material3.id,Material_Component__c=material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        
        PageReference pageRef = Page.MaterialCreationWizard;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('source', 'ReleaseDetail');
        ApexPages.currentPage().getParameters().put('id', Release.id);
        
        MaterialCreationWizardController material= new MaterialCreationWizardController(); 
        MaterialCreationWizardController materialIns= new MaterialCreationWizardController(); 
        
        materialIns.addFormats();        
        materialIns.rootFERTs[0].instance.Format_Description__c = 'DVD';
        materialIns.rootFERTs[0].instance.Item_Type__c = 'S (Single)';
        materialIns.rootFERTs[0].instance.Item_Code__c = 'SS - SINGLE SELECTION';
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.addComponent();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.copyMaterialTree();
        
        materialIns.materialIndex = '0';
        materialIns.selectedMaterialLevel = 1;
        materialIns.materialType = 'COMPONENT';
        List<Material__c> lstTempMt = new List<Material__c>();
        lstTempMt.add(material4);
        cache.session.put('selectedMat',lstTempMt);
        materialIns.getSelectedMat();
        materialIns.rootFERTs[0].instance.id = null;
        materialIns.rootFERTs[0].childComponents[2].isExisting = FALSE;
        materialIns.rootFERTs[0].childComponents[2].instance.Release__c = release1.id;
        materialIns.rootFERTs[0].childComponents[2].instance.Material_Status__c  = 'Draft';
        materialIns.rootFERTs[0].childComponents[2].instance.Component_Material__c = material3.id;
        materialIns.componentIndex = 2;
        materialIns.releaseDetails= null;
        try{
            materialIns.resetMaterialList(materialIns.rootFERTs);  
        }
        catch(exception e){
        }
        
         try{
            materialIns.getHierarchy(materialIns.rootFERTs);  
        }
        catch(exception e){
        }
        
         try{
            materialIns.matFERTIds = new Set<ID>();
            materialIns.matROHIds = new Set<ID>();
            materialIns.prepareBOMItems(materialIns.rootFERTs);  
        }
        catch(exception e){
        }
        
        materialIns.releaseDetails= release1;
        materialIns.lstMaterialRecords = new List<Material__c>();
        materialIns.lstMaterialRecords.add(material4);
        materialIns.hasException = TRUE;
        materialIns.redirectUserAndSetQueue();        
        
    }
    
    // Test data setup.  -REL-45
    @TestSetup
    static void setupData()
    {
        
        //Added For Deal  Change logic - Start
        Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
        List<Sub_Label_Code__c> subLblList = new List<Sub_Label_Code__c>();
        Sub_Label_Code__c sLblCode = new Sub_Label_Code__c(Name='SNAG FILMS', Label_Code__c='87 - JOINT CORR/MULTI-STUDIO', Sub_Label_Code_ID__c='87');
        subLblList.add(sLblCode);
        Sub_Label_Code__c sLblCode2 = new Sub_Label_Code__c(Name='UP Features', Label_Code__c='61 - Universal Pictures', Sub_Label_Code_ID__c='61');
        subLblList.add(sLblCode2);
        Sub_Label_Code__c sLblCode3 = new Sub_Label_Code__c(Name='Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code_ID__c='62');
        subLblList.add(sLblCode3);
        insert subLblList;
        
        List<Origin_Code__c> insertableOriginCodes = new List<Origin_Code__c>();
        Origin_Code__c oCode1 = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insertableOriginCodes.add(oCode1);
        Origin_Code__c oCode2 = new Origin_Code__c(Origin_Code__c='025 - Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code__c=sLblCode3.Id);
        insertableOriginCodes.add(oCode2);
        insert insertableOriginCodes;
        //Added For Deal  Change logic - Start
      
        // Preparing material records
        Material__c objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
        objMaterial.Territory__c = 'US';
        objMaterial.Material_Number__c = '29017863';
        objMaterial.Name = 'TestMat-002';
        insert objMaterial;
        
        // Creating a template.
        List<Material_Template__c> matTempList = new List<Material_Template__c>();
        Material_Template__c mt1 = new Material_Template__c(Template_Name__c='UNI-TV: Temp1', Brand_Group__c='TV', Is_Active__c=true);
        matTempList.add(mt1);
        Material_Template__c mt2 = new Material_Template__c(Template_Name__c='UNI-TV: Temp2', Brand_Group__c='TV', Is_Active__c=true);
        matTempList.add(mt2);
        insert matTempList;
        
        // Creating child material details.
        List<Material_Detail__c> matDetList = new List<Material_Detail__c>();
        Material_Detail__c matDet1 = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                        Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)');
        matDetList.add(matDet1);
        Material_Detail__c matDet2 = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='BF - BABY FERT', Format__c='DVD', 
                                        Material_Template__c=mt1.Id, Quantity__c=2, Retailer_Rental__c='TGT (TARGET)');
        matDetList.add(matDet2);
        insert matDetList;
        
        // Creating associated component details.
        // Creating associated component details.
        List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='DISC DVD'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='LITHO'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='INSERT'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='STICKER'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Existing_Component__c=objMaterial.Id));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet2.Id, Component_Type__c='DISC DVD'));
        insert compDetList;
    }
}