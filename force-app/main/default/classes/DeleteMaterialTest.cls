/*****************************************************************************************
Class Name: DeleteMaterialTest
Purpose: Test class for apex class DeleteMaterial 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0                                               Initial Development
******************************************************************************************/
@IsTest
private class DeleteMaterialTest {
    
    private static list<Release_Material__c> releaseMaterialRecords;
    private static list<v_Material__c> vMaterialRecords;
    private static list<Bom_item__c> bomItemRecords;
    private static Material__c materialDetails;
    
    private static void createData(){
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        // release 
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        materialDetails =  getMaterials(release);
        
        // vProject data
        v_Project_Request__c vProject = new v_Project_Request__c();
        vProject.Title__c = title.id;
        vProject.Release__c = release.id;
        insert vProject;
        
        
        bomItemRecords = getBOMItems(materialDetails);
        
        releaseMaterialRecords = getReleaseMaterials(release,materialDetails);
        
        vMaterialRecords = getVMaterials(vProject,materialDetails);
    }
    
    private static Material__c getMaterials(Release__c release){
        // material data
        Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','TESTMaterial','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material.Territory__c = 'US';
        insert material;
        return material;
    }
    
    private static Bom_item__c getBOMItems(Material__c material1,string componentNumber,integer bomQuantity,string componentQuantity, boolean isProductionFlag,Date validFrom,string itemCategory){
        Bom_item__c bomItem = new Bom_item__c(Material__c=material1.id,Component_Number__c=componentNumber,BOM_Quantity__c=bomQuantity,Component_Quantity__c=componentQuantity,Production_Flag__c=isProductionFlag,Valid_From__c=validFrom,Item_Category__c=itemCategory);
        
        return bomItem;
    }
    
    // bom item details 
    private static List<Bom_item__c>getBOMItems(Material__c material){
        list<Bom_item__c>bomItemsList =  new list<Bom_item__c>();
        
        // bom item data
        Bom_item__c bomItem1 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItemsList.add(bomItem1);
        
        insert bomItemsList;
        
        return bomItemsList;
        
    }
    
    // release materials
    private static list<Release_Material__c>getReleaseMaterials(Release__c release,Material__c material){
        list<Release_Material__c>releaseMaterialsList =  new list<Release_Material__c>();
        // release materials 
        Release_Material__c releaseMaterials =  new Release_Material__c();
        releaseMaterials.Release__c =  release.id;
        releaseMaterials.Material__c = material.id;
        releaseMaterialsList.add(releaseMaterials);
        insert releaseMaterialsList;
        return releaseMaterialsList;
        
    }
    
    // v-materials details
    private static List<v_Material__c>getVMaterials(v_Project_Request__c vProject,Material__c material){
        list<v_Material__c>vMaterialList = new list<v_Material__c>();
        // V Materials 
        v_Material__c vMaterial = new v_Material__c(v_Project__c=vProject.Id);
        vMaterial.Material__c = material.id;
        vMaterialList.add(vMaterial);
        
        insert vMaterialList;
        return vMaterialList;
    }


    @isTest
    static void testMethod_1(){
        createData();
        
        Test.StartTest();
            DeleteMaterial.deleteVMaterial(vMaterialRecords);
        Test.StopTest();
    }
    
    private static testMethod void testRequestForDeletion(){
      
      // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
      
      // release 
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
      
      Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
      
      Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','TESTMaterial','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
      material.Material_Status__c = 'Processed in SAP';
      material.Material_Integration_State__c =  'P';
      material.RecordTypeId = recTypeId;
      material.Territory__c = 'US';
      
      insert material;
      
      
      List<Material__c>materialList = [select id ,Format__c,Format_Description__c,Material_Type__c,name,Release__c,Association_Required__c,Item_Type__c,Item_Code__c,Material_Status__c from Material__c where id =: material.id];
      
      // cover classification trigger handler also
      
      Classification__c classificationDetails = testClassUtility.getClassifications(materialList[0]);
      classificationDetails.Aspect_Ratio__c = 'AWS';
      
      insert classificationDetails;
      classificationDetails.Aspect_Ratio__c = 'VAR';
      update classificationDetails;
    
      
      // cover classification trigger handle
      
      
      Test.startTest(); 
      
        PageReference pageRef = Page.RequestForDeletion;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('id',materialList[0].id);
          DeleteMaterial contrller =  new DeleteMaterial();
          contrller.materialDeleteionRequest();
          
          
      Test.stopTest();
    }
    
    public static  testMethod void testDeleteMaterial1(){
        
        Release__c rel = new release__c();
        rel.Name = 'test123';
        insert rel;
        triggerUtility.sobjectExecutedEvents.remove('Release__c');
        
        v_Project_Request__c vpr = new v_Project_Request__c();
        vpr.Release__c = rel.id;
        insert vpr;
        
        Material__c mat2 = new Material__c();
        mat2.Name = 'testMat';
        mat2.Label_Code__c ='61 - Universal Pictures';
        mat2.Material_Status__c = 'Draft';
        mat2.Material_Type__c = 'FERT';
        mat2.release__c = rel.id;
        mat2.Format__c= '02 - DVD'; 
        mat2.Territory__c = 'US';
        insert mat2;
         test.startTest();
        sales__c s = new sales__c();
        s.material__c = mat2.id;
        plant__c p = new plant__c();
        p.material__c = mat2.id;
        Alternative_Unit_of_Measure__c am = new Alternative_Unit_of_Measure__c();
        am.material__c = mat2.id;
        valuation__c val = new valuation__c();
        val.material__c = mat2.id;
        classification__c cls = new classification__c();
        cls.material__c = mat2.id;
        
        v_Material__c vmat = new v_Material__c();
        vmat.Material__c = mat2.id;
        vmat.v_Project__c = vpr.id;
        vmat.Status__c = 'Pending';
        
        triggerUtility.checkMaterialBeforeInsertTriggerExecuted = false;
        triggerUtility.checkMaterialAfterInsertTriggerExecuted = false;
        triggerUtility.checkMaterialBeforeUpdateTriggerExecuted = false;
        triggerUtility.checkMaterialAfterUpdateTriggerExecuted = false; 
        
        Release_Material__c rm = new Release_Material__c();
        rm.material__c = mat2.id;
        rm.release__c = rel.id;
        insert rm;
        
        Material__c mat3 = new Material__c();
        mat3.Name = 'testMatComp';
        mat3.release__c = rel.id;
        mat3.Material_Status__c = 'Draft';
        mat3.Material_Type__c = 'ROH';
        mat3.Item_Type__c = 'C - Components';
        insert mat3;
         test.stopTest();
        triggerUtility.checkMaterialBeforeInsertTriggerExecuted = false;
        triggerUtility.checkMaterialAfterInsertTriggerExecuted = false;
        triggerUtility.checkMaterialBeforeUpdateTriggerExecuted = false;
        triggerUtility.checkMaterialAfterUpdateTriggerExecuted = false; 
        
        Release_Material__c rm1 = new Release_Material__c();
        rm1.material__c = mat3.id;
        rm1.release__c = rel.id;
        insert rm1;
        
        BOM_Item__c bitem = new BOM_Item__c();
        bitem.Material__c = mat2.id;
        bitem.Material_Component__c = mat3.id;
        insert bitem;
        
        DeleteMaterial.deleteMaterial(mat2.id);
     }
    Static List < Title__c > title;
    Static List < Release__c > release;
    Static List < Material__c > material;
    Static List < Sales__c > sales;
    Static List < Plant__c > plants;
    Static List < Classification__c > classifications;
    Static List < Alternative_Unit_of_Measure__c > auomObj;
    Static List < Valuation__c > valuations;
    Static BOM_Item__c bom;
   // Private Static list < v_Material__c > vMaterialRecords;
//    Private Static list < Release_Material__c > releaseMaterialRecords;

    Static Integer numberOfMaterials = 2;
    Static Integer numberOfReleases = 1;
    Static Integer numberOfTitles = 1;
    Static Integer numberOfSales = 1;
    Static Integer numberOfPlants = 1;
    Static Integer numberOfClassifications = 1;
    Static Integer numberOfAUoM = 1;
    Static Integer numberOfValuations = 1;

    Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_DVD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;

        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        List<Material__c> material1 = [Select id from Material__c where id =: testId];
        system.assertEquals(material1.size(), 0);
        System.debug(LoggingLevel.ERROR, 'Id1--' + material1.size());
        test.stopTest();
    }


        Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_CD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(numberOfMaterials, 'CD', 'FERT', 'M (Multipack)', 'MT - MULTI-TITLE', 'US', release[0].id);
        material[1].Title__c = Title[0].id;
        material[1].Format__c = '02 - DVD';
        material[1].Item_Type__c = 'S (SINGLE)';
        material[1].Item_Code__c = 'BF - BABY FERT';
        material[1].Territory__c = 'US & CDN';
        material[1].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        bom = RF_TestDataFactory.CreateBOMItems(material[0].id, material[1].id);

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        //system.assertEquals(material.size(), 0);

        test.stopTest();
    }

    Static TestMethod Void Sgl_Pos_Adm_MaterialDeletionRequest_DVD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
         Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        RFTest_TestDataFactory.Defaulting();
        release = RF_TestDataFactory.CreateReleases(numberOfReleases, title[0].id, 'Family', 'US', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
         material[0].Material_Status__c = 'Processed in SAP';
        material[0].Material_Integration_State__c = 'P';
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;
       
        List < Plant__c > PlantList = [select id, Plant__c from Plant__c where material__c =: Material[0].id];
        system.assertEquals(PlantList[0].Plant__c, 'V000 - Univ Studios HV Planning Plant');
        PageReference pageRef = Page.RequestForDeletion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', material[0].id);
        DeleteMaterial contrller = new DeleteMaterial();
        contrller.materialDeleteionRequest();
        //DeleteMaterial.deleteMaterial(material[0].id);
        Material__c updMat = [Select Id, Name,Material_Status__c, (SELECT id, D_Chain_Spec__c, Function__c from sales__r) from Material__c where Original_Material_Number__c =:material[0].Id];
        Material__c updMat1 = [Select Id, (SELECT id, Plant_Specific_Matl_Status__c, Function__c from Plants__r) from Material__c where Original_Material_Number__c =:
            material[0].Id
        ];

        system.assertEquals(material.size(), 1);
        system.assertEquals(updMat1.Plants__r.size(), 1);
        system.assertEquals(updMat1.Plants__r[0].Plant_Specific_Matl_Status__c, 'XX - Never Released');
        system.assertEquals(updMat.sales__r[0].D_Chain_Spec__c, 'XX - Never Released');
        system.assertEquals(updMat.sales__r[0].Function__c, '003');
        system.assertEquals(updMat.Name.contains('DNU'), true);
        Test.stopTest();
    
    }

    Static TestMethod Void Sgl_Pos_Adm_deleteVMaterial_DVD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
 
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        release = RF_TestDataFactory.CreateReleases(numberOfReleases, title[0].id, 'Family', 'US', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
        insert vMaterialRecords;

        releaseMaterialRecords = RF_TestDataFactory.getReleaseMaterials(release[0].id, material[0].id);
        insert releaseMaterialRecords;

        Id testId = vMaterialRecords[0].id;
        DeleteMaterial.deleteVMaterial(vMaterialRecords);

        vMaterialRecords = [Select id from v_Material__c where id =: testId];
        system.assertEquals(vMaterialRecords.size(), 0);
        Test.StopTest();
    }

   /* Static TestMethod Void Sgl_Pos_Adm_activateMaterialRequest_DVD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
         
         Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
        insert release;


        material = RF_TestDataFactory.CreateMaterials(numberOfMaterials, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
        material[0].material_status__c = 'Deleted';
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        material[1].Material_Type__c = 'Z009';
        material[1].Format_Description__c = 'BD';
        material[1].Component_Type__c = 'CORRUGATE';
        material[1].Item_Code__c = 'CC - CORRUGATE';
        insert material;
        test.startTest();
        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
        insert vMaterialRecords;

        bom = RF_TestDataFactory.CreateBOMItems(material[0].id, material[1].id);

        PageReference pageRef = Page.RequestForDeletion;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', material[0].id);
        DeleteMaterial contrller = new DeleteMaterial();
        contrller.activateMaterialRequest();
        
        Material__c updMat = [Select Id, Name,Material_Status__c from Material__c where Original_Material_Number__c =:material[0].Id];
        //system.assertEquals(updMat.Material_Status__c, 'Submitted');
        Test.StopTest();
    }*/

    Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_CDN() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;

        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'CDN', release[0].id);
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        system.assertEquals(material.size(), 0);

        test.stopTest();
    }

    Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_USCDN() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;

        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
            
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        system.assertEquals(material.size(), 0);

        test.stopTest();
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_DeleteMaterial_CDN() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;

            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);

            test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Neg_PfmUsr_DeleteMaterial_CDN() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;

            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'CDN', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            material[0].Label_Code__c='61 - Universal Pictures';
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 1);

            test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Neg_BrandUsr_DeleteMaterial_vMaterial() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            test.stopTest();

            vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
            try {
                insert vMaterialRecords;
            }
            catch(DmlException ex){
            System.Assert(ex.getDmlStatusCode(0).contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'));
            }
        }
    }

    Static TestMethod Void Sgl_Neg_PfmUsr_DeleteMaterial_vMaterial() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id; 
            material[0].Label_Code__c='61 - Universal Pictures';
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
            insert vMaterialRecords;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 1);

            test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Neg_PfmUsr_DeleteMaterial_vMaterial_USCDN() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
             
             Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
             
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'BD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            material[0].Label_Code__c='61 - Universal Pictures';
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
            insert vMaterialRecords;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 1);

            test.stopTest();
        }
    }


    Static TestMethod Void Sgl_Neg_BrandUsr_activateMaterialRequest() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].material_status__c = 'Deleted';
            material[0].deal__c = deal.id;
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
            try {
                insert vMaterialRecords;
            } catch(DmlException ex){
            System.Assert(ex.getDmlStatusCode(0).contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'));
            }
            Test.StopTest();
        }
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_DeleteMaterial_USCDN() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);

            test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Neg_PfmUsr_DeleteMaterial_USCDN() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'CDN', 'New Release');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].deal__c = deal.id;
            material[0].Label_Code__c='61 - Universal Pictures';
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 1);

            test.stopTest();
        }
    }

     /*Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_vMaterial_CD() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(numberOfMaterials, 'CD', 'FERT', 'M (Multipack)', 'MT - MULTI-TITLE', 'US', release[0].id);
        material[1].Title__c = Title[0].id;
        material[1].deal__c = deal.id;
        material[1].Format__c = '02 - DVD';
        material[1].Item_Type__c = 'S (SINGLE)';
        material[1].Item_Code__c = 'BF - BABY FERT';
        material[1].Territory__c = 'US & CDN';
        insert material;
        test.stopTest();
        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
        insert vMaterialRecords;

        bom = RF_TestDataFactory.CreateBOMItems(material[0].id, material[1].id);

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        //system.assertEquals(material.size(), 0);
        
    } */

    Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_vMaterial_USCDN() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
        material[0].Title__c = Title[0].id;
        material[0].deal__c = deal.id;
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        vMaterialRecords = RF_TestDataFactory.getVMaterials(vpr.id, material[0].id);
        insert vMaterialRecords;

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        system.assertEquals(material.size(), 0);
        test.stopTest();
    }

    Static TestMethod Void Sgl_Pos_Adm_DeleteMaterial_PA() {
        title = RF_TestDataFactory.CreateTitles(numberOfTitles);
        Insert title;
       
        release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
        insert release;

        test.startTest();
        material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'D (Display Vehicle)', 'PA - PALLET', 'US', release[0].id);
        
        insert material;

        v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
        insert vpr;

        Id testId = material[0].id;
        DeleteMaterial.deleteMaterial(material[0].id);

        material = [Select id from Material__c where id =: testId];
        system.assertEquals(material.size(), 0);

        test.stopTest();
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_DeleteMaterial_PA() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;

            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'D (Display Vehicle)', 'PA - PALLET', 'US', release[0].id);
            insert material;

            v_Project_Request__c vpr = RF_TestDataFactory.CreatevProjectReq(release[0].id, null);
            insert vpr;

            Id testId = material[0].id;
            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);

            test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_DeleteMaterial_DVDR() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            material = RF_TestDataFactory.CreateMaterials(3, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US & CDN', release[0].id);
            material[0].Title__c = title[0].id;
            material[0].deal__c = deal.id;
            material[0].Name='test1';
            material[0].Format__c='02 - DVD';
            
            material[1].Material_Type__c = 'ROH';
            material[1].Format_Description__c = 'BD';
            material[1].Name='test2';
            material[1].Format__c='02 - DVD';
            material[1].Item_Type__c = 'C - Components';
            material[1].Item_Code__c='DS - DISC';
            material[1].Component_Type__c = 'DISC DVD';

            material[2].Material_Type__c = 'ROH';
            material[2].Format_Description__c = 'CD';
            material[2].Name='test3';
            material[2].Item_Type__c = 'C - Components';
            material[2].Format__c='02 - DVD';
            material[2].Item_Code__c='CC - CORRUGATE';
            material[2].Component_Type__c = 'CORRUGATE';
            
            insert material;
            test.startTest();

            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);

            insert bomList;
            PageReference pageRef = Page.RequestForDeletion;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', material[0].id);
            DeleteMaterial contrller = new DeleteMaterial();
            contrller.materialDeleteionRequest();
            system.assertEquals(material.size(), 3);
            Id testId = material[0].id;

            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);

            Test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_MaterialDeletionRequest_MCL() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

           
            material = RF_TestDataFactory.CreateMaterials(5, 'CD', 'FERT', 'M (Multipack)', 'COLLECTION PACK', 'US', release[0].id);
      material[0].Name='test1';
      material[0].Format__c='02 - DVD';
            
            material[1].Material_Type__c = 'FERT';
            material[1].Name='test2';
            material[1].Format_Description__c = 'DVD';
            material[1].Item_Type__c = 'S (SINGLE)';
            material[1].Item_Code__c = 'SS - SINGLE SELECTION';
            material[1].Format__c='02 - DVD';
            material[1].Title__c = title[0].id;
            material[1].deal__c = deal.id;

            material[2].Material_Type__c = 'ROH';
            material[2].Name='test3';
            material[2].Format_Description__c = 'BD-R';
            material[2].Item_Type__c='C - Components';
      material[2].Item_Code__c='DS - DISC';
      material[2].Format__c='02 - DVD';
            material[2].Component_Type__c = 'DISC CD';

            material[3].Material_Type__c = 'FERT';
            material[3].Name='test4';
            material[3].Format_Description__c = 'DVDR';
            material[3].Item_Type__c = 'S (SINGLE)';
            material[3].Item_Code__c = 'SS - SINGLE SELECTION';
            material[3].Format__c='02 - DVD';
            material[3].Title__c = title[0].id;
            material[3].deal__c = deal.id;
            
            material[4].Material_Type__c = 'ROH';
            material[4].Name='test5';
            material[4].Format_Description__c = 'BD';
            material[4].Item_Type__c='C - Components';
      material[4].Item_Code__c='DS - DISC';
      material[4].Format__c='02 - DVD';
            material[4].Component_Type__c = 'DISC CD';
            material[4].Territory__c = 'US';
            insert material;
             test.startTest();
            material[0].Material_Status__c='Processed in SAP';
            material[1].Material_Status__c='Processed in SAP';
            material[3].Material_Status__c='Processed in SAP';
            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);
      
            Bom_Item__c bom4 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[3].id);
            bom4.Item_Category__c = 'L';
            bom4.Component_Quantity__c = '1';
            bomList.add(bom4);
            
            Bom_Item__c bom3 = RFTest_TestDataFactory.createBOMItems(material[3].id, material[4].id);
            bom3.Item_Category__c = 'L';
            bom3.Component_Quantity__c = '1';
            bomList.add(bom3);

            insert bomList;
            PageReference pageRef = Page.RequestForDeletion;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', material[0].id);
            DeleteMaterial contrller = new DeleteMaterial();
            contrller.materialDeleteionRequest();
            system.assertEquals(material.size(), 5);
            Id testId = material[0].id;

            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);
            Test.stopTest();
        }
    }


    Static TestMethod Void Sgl_Pos_Pfm_MaterialDeletionRequest_SingleSAP() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(1, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
            material[0].Material_Status__c = 'Processed in SAP';
            material[0].Title__c = Title[0].id;
            material[0].deal__c= deal.id;
            material[0].Label_Code__c='61 - Universal Pictures';
            insert material;

            PageReference pageRef = Page.RequestForDeletion;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', material[0].id);
            DeleteMaterial contrller = new DeleteMaterial();
            contrller.materialDeleteionRequest();
            system.assertEquals(material.size(), 1);

            Test.stopTest();
        }
    }

    Static TestMethod Void Sgl_Pos_BrandUsr_MaterialDeletionRequest_CD() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(7, 'CD', 'FERT', 'M (Multipack)', 'MT - MULTI-TITLE', 'US', release[0].id);
            material[0].Name='test11';
            material[0].Material_Status__c = 'Draft';
      material[0].Format__c='02 - DVD';
            
            material[1].Material_Type__c = 'FERT';
            material[1].Name='test2';
            material[1].Format_Description__c = 'DVDR';
            material[1].Item_Type__c = 'S (SINGLE)';
            material[1].Item_Code__c = 'ME - MULTIPLE EPISODES';
            material[1].Format__c='02 - DVD';
            material[1].Title__c = Title[0].id;
            material[1].deal__c = deal.id;
            material[2].Material_Type__c = 'ROH';
            material[2].Name='test3';
            material[2].Format_Description__c = 'BD';
            material[2].Item_Type__c='C - Components';
            material[2].Item_Code__c='DS - DISC';
            material[2].Component_Type__c = 'DISC CD';
            material[2].Format__c='02 - DVD';

            material[3].Material_Type__c = 'ROH';
            material[3].Name='test4';
            material[3].Format_Description__c = 'UHD';
            material[3].Item_Type__c='C - Components';
            material[3].Item_Code__c='PG - PACKAGING';
            material[3].Component_Type__c = 'O-CARD';
            material[3].Format__c='02 - DVD';

            material[4].Material_Type__c = 'FERT';
            material[4].Name='test5';
            material[4].Format_Description__c = 'DVD';
            material[4].Item_Type__c = 'S (SINGLE)';
            material[4].Item_Code__c = 'SE - SINGLE EPISODES';
            material[4].Title__c = Title[0].id;
            material[4].deal__c= deal.id;
            material[5].Material_Type__c = 'ROH';
            material[5].Name='test6';
            material[5].Format_Description__c = 'BD-R';
            material[5].Item_Type__c='C - Components';
            material[5].Item_Code__c='DS - DISC';
            material[5].Component_Type__c = 'DISC BD';
            material[5].Format__c='02 - DVD';

            material[6].Material_Type__c = 'ROH';
            material[6].Name='test7';
            material[6].Format_Description__c = 'COMBO PACK';
            material[6].Item_Type__c='C - Components';
            material[6].Item_Code__c='PG - PACKAGING';
            material[6].Component_Type__c = 'JCARD';
            material[6].Format__c='02 - DVD';

            insert material;

            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);

            Bom_Item__c bom3 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[3].id);
            bom3.Item_Category__c = 'L';
            bom3.Component_Quantity__c = '1';
            bomList.add(bom3);

            Bom_Item__c bom4 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[4].id);
            bom4.Item_Category__c = 'L';
            bom4.Component_Quantity__c = '1';
            bomList.add(bom4);

            Bom_Item__c bom5 = RFTest_TestDataFactory.createBOMItems(material[4].id, material[5].id);
            bom5.Item_Category__c = 'L';
            bom5.Component_Quantity__c = '1';
            bomList.add(bom5);

            Bom_Item__c bom6 = RFTest_TestDataFactory.createBOMItems(material[4].id, material[6].id);
            bom6.Item_Category__c = 'L';
            bom6.Component_Quantity__c = '1';
            bomList.add(bom6);
            insert bomList;
            Id testId = material[0].id;

            DeleteMaterial.deleteMaterial(material[0].id);

            material = [Select id from Material__c where id =: testId];
            system.assertEquals(material.size(), 0);
            Test.stopTest();
        }
    }


    Static TestMethod Void Sgl_Pos_BrandUsr_DeleteMaterial_ROH_Z009() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
              Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(3, 'CD', 'FERT', 'S (SINGLE)', 'SS - SINGLE SELECTION', 'US', release[0].id);
            material[0].Title__c = Title[0].id;
            material[0].Name='test11';
            material[0].Material_Status__c = 'Draft';
      material[0].Format__c='02 - DVD';
            material[0].Deal__c= deal.id;
            material[1].Material_Type__c = 'ROH';
            material[1].Format_Description__c = 'DVD';
            material[1].Name='test12';
            material[1].Item_Type__c='C - Components';
            material[1].Component_Type__c = 'DISC DVD';
            material[1].Item_Code__c = 'DS - DISC';
            material[1].Format__c='02 - DVD';

            material[2].Material_Type__c = 'Z009';
            material[2].Format_Description__c = 'BD';
            material[2].Name='test13';
            material[2].Item_Type__c='C - Components';
            material[2].Component_Type__c = 'CORRUGATE';
            material[2].Item_Code__c = 'CC - CORRUGATE';
            material[2].Format__c='02 - DVD';

            insert material;

            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);
            insert bomList;

            Id testId = material[1].id;

            DeleteMaterial.deleteMaterial(material[1].id);

            List<Material__c> material1=[Select id from Material__c where id =: testId];
            system.assertEquals(material1.size(), 0);

            test.stopTest();
        }
    }


    Static TestMethod Void Sgl_Pos_BrandUsr_MaterialDeletionRequest_SentBack() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title[0].id,SGENNO__c=Title[0].SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            release = RF_TestDataFactory.CreateReleases(numberOfReleases, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(5, 'DVD', 'FERT', 'S (Single)', 'SS (Single Selection)', 'US', release[0].id);
            material[0].Material_Status__c = 'Sent back';
            material[0].Material_Integration_State__c = 'P';
            material[0].Title__c = Title[0].id;
             material[0].Deal__c= deal.id;
            material[1].Material_Type__c = 'ROH';
            material[1].Format_Description__c = 'CD';
            material[1].Item_Code__c = 'DISC CD';
            material[1].Material_Status__c = 'Draft';

            material[2].Material_Type__c = 'ROH';
            material[2].Format_Description__c = 'BD';
            material[2].Item_Code__c = 'LITHO';
            material[2].Material_Status__c = 'Draft';

            material[3].Material_Type__c = 'ROH';
            material[3].Format_Description__c = 'DVDR';
            material[3].Item_Code__c = 'INSERT';
            material[3].Material_Status__c = 'Draft';

            material[4].Material_Type__c = 'ROH';
            material[4].Format_Description__c = 'UHD';
            material[4].Item_Code__c = 'CORRUGATE';
            material[4].Material_Status__c = 'Draft';

            insert material;

            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);

            Bom_Item__c bom3 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[3].id);
            bom3.Item_Category__c = 'L';
            bom3.Component_Quantity__c = '1';
            bomList.add(bom3);

            Bom_Item__c bom4 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[4].id);
            bom4.Item_Category__c = 'L';
            bom4.Component_Quantity__c = '1';
            bomList.add(bom4);
            insert bomList;
            PageReference pageRef = Page.RequestForDeletion;
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            ApexPages.currentPage().getParameters().put('id', material[0].id);
            DeleteMaterial contrller = new DeleteMaterial();
            contrller.materialDeleteionRequest();
            system.assertEquals(material[0].Material_Status__c, 'Sent back');
            system.assertEquals(material.size(), 5);
            
        }
    }
    /* Static TestMethod Void Sgl_Pos_PfmUsr_MaterialDeletionRequest_CD() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.platformApiProfile, 1);
        System.runAs(u) {
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;

            release = RF_TestDataFactory.CreateReleases(1, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            
            material = RF_TestDataFactory.CreateMaterials(4, 'CD', 'FERT', 'M (Multipack)', 'CL-COLLECTION PACK', 'US', release[0].id);
            material[0].Material_Status__c = 'Processed in SAP';
            material[0].Material_Integration_State__c = 'P';
            material[0].Name='test1';
      material[0].Format__c='02 - DVD';

            material[1].Material_Type__c = 'FERT';
            material[1].Name='test2';
            material[1].Format_Description__c = 'DVD';
            material[1].Item_Type__c = 'S (SINGLE)';
            material[1].Item_Code__c = 'SS - SINGLE SELECTION';
            material[1].Format__c='02 - DVD';
            material[1].Title__c = title[0].id;

            material[2].Material_Type__c = 'ROH';
            material[2].Name='test3';
            material[2].Format_Description__c = 'BD-R';
            material[2].Component_Type__c = 'DISC CD';
            material[2].Item_Type__c='C - Components';
      material[2].Item_Code__c='DS - DISC';
      material[2].Format__c='02 - DVD';

            material[3].Material_Type__c = 'ROH';
            material[3].Name='test4';
            material[3].Format_Description__c = 'BD';
            material[3].Component_Type__c = 'DISC CD';
            material[3].Item_Type__c='C - Components';
      material[3].Item_Code__c='DS - DISC';
      material[3].Format__c='02 - DVD';
            test.startTest();
            insert material;
            Test.stopTest();
            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);
            
            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[2].id);
            bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);

            Bom_Item__c bom3 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[3].id);
            bom3.Item_Category__c = 'L';
            bom3.Component_Quantity__c = '1';
            bomList.add(bom3);
            insert bomList;
            PageReference pageRef = Page.RequestForDeletion;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', material[0].id);
            DeleteMaterial contrller = new DeleteMaterial();
            contrller.materialDeleteionRequest();
            system.assertEquals(material[0].Material_Status__c, 'Processed in SAP');
            system.assertEquals(material.size(), 4);
            
        }
    } */

    Static TestMethod Void Sgl_Pos_BrandUsr_MaterialDeletionRequest_COM() {
        User u = RFTest_TestDataFactory.createUser(RFTest_TestDataFactory.brandUserProfile, 2);
        System.runAs(u) {
            RFTest_TestDataFactory.Defaulting();
            title = RF_TestDataFactory.CreateTitles(numberOfTitles);
            Insert title;

            release = RF_TestDataFactory.CreateReleases(numberOfReleases, title[0].id, 'Family', 'US', 'New Release Mattel');
            insert release;

            test.startTest();
            material = RF_TestDataFactory.CreateMaterials(4, 'CD', 'FERT', 'M (Multipack)', 'COLLECTION PACK', 'US', release[0].id);
      material[0].Name='test13';
      material[0].Format__c='20 - CD (COMPACT DISC)';
            
            material[1].Name = 'Test12';
            material[1].Material_Type__c = 'FERT';
            material[1].Format_Description__c = 'DVD';
            material[1].Item_Type__c = 'S (SINGLE)';
            material[1].Item_Code__c = 'SS - SINGLE SELECTION';
            material[1].Format__c='02 - DVD';
            
            material[2].Name = 'Test13';
            material[2].Material_Type__c = 'ROH';
            material[2].Format_Description__c = 'BD-R';
            material[2].Item_Type__c='C - Components';
            material[2].Item_Code__c='DS - DISC';
            material[2].Format__c='02 - DVD';
            material[2].Component_Type__c = 'DISC CD';
            
            material[3].Name = 'Test14';
            material[3].Material_Type__c = 'ROH';
            material[3].Format_Description__c = 'BD';
            material[3].Item_Type__c='C - Components';
            material[3].Item_Code__c='DS - DISC';
            material[3].Format__c='02 - DVD';
            material[3].Component_Type__c = 'DISC CD';
            
            insert material;
            
            material[0].Material_Status__c='Processed in SAP';
            material[0].Material_Integration_State__c = 'P';
            material[1].Material_Status__c='Processed in SAP';
            material[2].Material_Status__c='Processed in SAP';
            material[3].Material_Status__c='Processed in SAP';
            List < Bom_Item__c > bomList = new List < Bom_item__c > ();
            Bom_Item__c bom1 = RFTest_TestDataFactory.createBOMItems(material[0].id, material[1].id);
            //bom1.Item_Category__c = 'L';
            bom1.Component_Quantity__c = '1';
            bomList.add(bom1);

            Bom_Item__c bom2 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[2].id);
            //bom2.Item_Category__c = 'L';
            bom2.Component_Quantity__c = '1';
            bomList.add(bom2);

            Bom_Item__c bom3 = RFTest_TestDataFactory.createBOMItems(material[1].id, material[3].id);
            //bom3.Item_Category__c = 'L';
            bom3.Component_Quantity__c = '1';
            bomList.add(bom3);
            insert bomList;

            system.assertEquals(material.size(), 4);
         
            Test.stopTest();
        }
    }
}