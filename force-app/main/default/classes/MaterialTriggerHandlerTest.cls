/*****************************************************************************************
Class Name: MaterialTriggerHandlerTest
Purpose: This class is responsible to test the MaterialTriggerHandler class. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             30/09/2016           Jay                      Initial Development
******************************************************************************************/
@isTest
private class MaterialTriggerHandlerTest{
    
    // Following method is used to prepare data setup.
    static void dataSetup()
    {
         Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
        // Inserting Sub-Label Codes.
        List<Sub_Label_Code__c> subLblList = new List<Sub_Label_Code__c>();
        Sub_Label_Code__c sLblCode = new Sub_Label_Code__c(Name='SNAG FILMS', Label_Code__c='87 - JOINT CORR/MULTI-STUDIO', Sub_Label_Code_ID__c='87');
        subLblList.add(sLblCode);
        Sub_Label_Code__c sLblCode2 = new Sub_Label_Code__c(Name='UP Features', Label_Code__c='61 - Universal Pictures', Sub_Label_Code_ID__c='61');
        subLblList.add(sLblCode2);
        Sub_Label_Code__c sLblCode3 = new Sub_Label_Code__c(Name='Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code_ID__c='62');
        subLblList.add(sLblCode3);
        insert subLblList;
    
        LabelCode_SubLabelCode_Map__c lblMap1 = new LabelCode_SubLabelCode_Map__c();
        lblMap1.Name = '61 - Universal Pictures';
        lblMap1.Sub_Label_Code_Id__c = '61';
        insert lblMap1;
        
        LabelCode_SubLabelCode_Map__c lblMap2 = new LabelCode_SubLabelCode_Map__c();
        lblMap2.Name = '87 - JOINT CORR/MULTI-STUDIO';
        lblMap2.Sub_Label_Code_Id__c = '87';
        insert lblMap2;
        
        // Inserting Origin Codes.
        List<Origin_Code__c> insertableOriginCodes = new List<Origin_Code__c>();
        Origin_Code__c oCode1 = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insertableOriginCodes.add(oCode1);
        Origin_Code__c oCode2 = new Origin_Code__c(Origin_Code__c='025 - Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code__c=sLblCode3.Id);
        insertableOriginCodes.add(oCode2);
        insert insertableOriginCodes;
        
        /*Sub_Label_Code__c sLblCode = new Sub_Label_Code__c(Name='SNAG FILMS', Label_Code__c='87 - JOINT CORR/MULTI-STUDIO', Sub_Label_Code_ID__c='87');
        insert sLblCode;
        
        Sub_Label_Code__c sLblCode2 = new Sub_Label_Code__c(Name='UP Features', Label_Code__c='61 - Universal Pictures', Sub_Label_Code_ID__c='61');
        insert sLblCode2;
        
        Origin_Code__c oCode = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insert oCode;*/
        
        
               
        //Default object 
        Material_Format_Default__c mfd = new Material_Format_Default__c();
        mfd.Format_Key__c = 'EST (ELECTRONIC SELL THRU)';
        mfd.Format_Key_Unique__c = 'EST (ELECTRONIC SELL THRU)';
        mfd.Format__c = '08 - EST (ELECTRONIC SELL THRU)';
        mfd.Material_Group_3__c = 'ZZZ - NOT Master Data Interface Relevant';
        mfd.Material_Group_5__c = 'Z - 3rd PARTY - DO NOT EDI';
        Insert mfd;
        
        Material_Item_Code_Default__c micd = new Material_Item_Code_Default__c();
        micd.Item_Code_Key__c = 'SS - SINGLE SELECTION';
        micd.Item_Code_Key__c = 'SS - SINGLE SELECTION';
        micd.D_Chain_Spec__c= 'FR - Future Release';
        micd.Material_Group_5__c = 'D - Yes-Put away dirty';
        micd.Plnd_Dely_time__c = '7 Days';
        Insert micd;
        
        Material_Item_Type_Default__c mitd = new Material_Item_Type_Default__c();
        mitd.Item_Type_Key__c = 'S (Single)';
        mitd.Item_Code__c = 'SS - SINGLE SELECTION';
        mitd.Item_Category_Group__c = 'NORM';
        mitd.Material_Group_3__c = '888 - Master Data Interface Relevant';
        mitd.Material_Pricing_Group__c = 'D6';
        mitd.Xplant_Material_Status__c = 'NA';
        Insert mitd;
        
        Material_Label_Code_Default__c mlcd =  new Material_Label_Code_Default__c();
        mlcd.Label_Code_Key__c = '11 - TVA Films';
        Insert mlcd;
        
        Material_Material_Type_Default__c mmtd = new Material_Material_Type_Default__c();
        mmtd.Material_Type_Key__c = 'FERT';
        mmtd.Material_Type_Key_Unique__c = 'FERT';
        mmtd.Availability_Check__c  = 'NR - New Release';
        mmtd.Tax_Jurisdiction_Code__c = '1';
        mmtd.City_Sales_Tax__c = '1';
        Insert mmtd;
        
        Material_Territory_Default__c mtd = new Material_Territory_Default__c();
        mtd.Territory_Key__c = 'US';
        mtd.Bwd_Cons_Period__c = '010';
        mtd.Plant__c = 'V000 - Univ Studios HV Planning Plant';
        mtd.Sales_Org__c = 'V100 - US Home Video';
        mtd.Stor_Loc_EP__c = '0010';
        mtd.Valuation_Area__c = 'R - Retail';
        Insert mtd;
        
        //Define Custome Settings.
        DefaultingFieldMapping__c d = new DefaultingFieldMapping__c();
        d.Name = 'FieldMapping_1';
        d.Defaulting_Object_API__c = 'Material_Format_Default__c';
        d.Defaulting_Field_API__c = 'Material_Group_3__c';
        d.Transaction_Object_API__c = 'Sales__c';
        d.Transaction_Field_API__c = 'Material_Group_3__c';
        
        DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d0.Defaulting_Field_API__c = 'Tax_Jurisdiction_Code__c';
        d0.Transaction_Object_API__c = 'Sales__c';
        d0.Transaction_Field_API__c = 'Tax_Jurisdiction_Code__c OR GST_Canada__c';
        Insert d0;
        
        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_2';
        d1.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d1.Defaulting_Field_API__c = 'Indv_Colle__c';
        d1.Transaction_Object_API__c = 'Plant__c';
        d1.Transaction_Field_API__c = 'Indv_Colle__c';
        Insert d1;
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_3';
        d2.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d2.Defaulting_Field_API__c = 'Standard_Price__c';
        d2.Transaction_Object_API__c = 'Valuation__c';
        d2.Transaction_Field_API__c = 'Standard_Price__c';
        Insert d2;
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_4';
        d3.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d3.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d3.Transaction_Object_API__c = 'Material__c';
        d3.Transaction_Field_API__c = 'Alternative_Legal_Title_Lookup__c';
        d3.Execute_on_Update__c = TRUE;
        Insert d3;
        
        DefaultingFieldMapping__c d4 = new DefaultingFieldMapping__c();
        d4.Name = 'FieldMapping_5';
        d4.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d4.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d4.Transaction_Object_API__c = 'Classification__c';
        d4.Transaction_Field_API__c = 'Copyright_Holder__c';
        Insert d4;
        
        DefaultingFieldMapping__c d5 = new DefaultingFieldMapping__c();
        d5.Name = 'FieldMapping_6';
        d5.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d5.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d5.Transaction_Object_API__c = 'Alternative_Unit_of_Measure__c';
        d5.Transaction_Field_API__c = 'International_Article_Number__c';
        Insert d5;
    }
    
    @isTest
    static void testMethod_1()
    {
        dataSetup();

        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        TM_Version__c tmV = new TM_Version__c(Name='Dummy_TM', Title__c=objTitle.Id, Original_Flag__c=TRUE);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', TM_Origin_Code__c='010 - Universal Pictures', Title__c=objTitle.Id);
        insert objMaterial;
        //System.assert([SELECT Id FROM Plant__c WHERE Material__c=:objMaterial.Id].size() > 0);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='44536723000',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        insert objMaterial1;
        
        Material__c mat1 = new Material__c();
        mat1.Material_Number__c ='34536723000';
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US & CDN';
        mat1.Episode__c = objMaterial1.Id;
        mat1.Label_Code__c='24 - PURE FLIX';
        insert mat1;
        
        Sales__c s = new Sales__c();
        s.Material__c = objMaterial.Id;
        Insert s; 
        
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(objMaterial);
        
        list<Material__c> matList1 = new list<Material__c>();
        matList1.add(objMaterial);
        
        set<Id> matId = new Set<Id>();
        matId.add(mat1.Episode__c);
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(objMaterial1.Id);
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
        
        
        Set<String> statusToCheck = new Set<String>{'Sent to SAP', 'SAP Error', 'Process in SAP'};
            Test.startTest();
        //MaterialTriggerHandler.updateMaterialSettlementOnChild(matId);  // commented on 13.03
        //MaterialTriggerHandler.updateMaterialHeepOnParent(matId);// commented on 13.03
        MaterialTriggerHandler.updatePlantandCreatePlanRecord(matList1);
        //MaterialTriggerHandler.updateMaterialCounterOnStatus(relId);
        /*System.runAs(platformApiUser) {
        MaterialTriggerHandler.updateBOMFunction();
        MaterialTriggerHandler.updateBOMStatusJointCorrugate1();
        }*/
        
        Test.stopTest();          
    } 
    
    @isTest
    static void testMethod_2()
    {
        Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Format_Description__c= 'DVD',Label_Code__c='24 - PURE FLIX',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION');
        objMaterial.Territory__c = 'US';
        insert objMaterial;
        
        Sales__c s = new Sales__c();
        s.Material__c = objMaterial.Id;
        Insert s;
        
        Test.stopTest();  
        
    }  
    @isTest
    static void testMethod_3()
    {
        Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Format_Description__c= 'DVDR',Label_Code__c='24 - PURE FLIX',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Territory__c = 'US';
        insert objMaterial;
        
        Sales__c s = new Sales__c();
        s.Material__c = objMaterial.Id;
        Insert s; 
        update objMaterial;
        Test.stopTest();  
        
    }   
    
    @isTest
    static void testMethod_4()
    {
        Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()+3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Title__c=objTitle.Id,Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.territory__c='US';
        insert objMaterial;
        
        
        Material__c updateMaterial=[select id,Material_type__c,material_status__c from material__c where id=:objMaterial.id];
        updateMaterial.Net_Weight__c=10;
        updateMaterial.Gross_Weight__c=11;
        updateMaterial.material_status__c='Approved';
        Update updateMaterial; 
        
        Test.stopTest();  
        
    }
    
    @isTest
    static void testMethod_5()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Brand User'];
        User u = new User(Alias = 'standt', Email='standarduserbrand@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserbrand@testorg.com');
        
        insert u;
        
        Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Financial_Owner__c=u.id,Legal_Owner__c=u.id,Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Title__c=objTitle.Id,Internal_Announce_Date__c=Date.Today()+3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Title__c=objTitle.Id,Label_Code__c='61 - Universal Pictures',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Format__c='02 - DVD';
        objMaterial.territory__c='US';
        objMaterial.Deal__c = deal.Id;
        insert objMaterial;
        
        Material__c updateMaterial=[select id,Material_type__c,material_status__c from material__c where id=:objMaterial.id];
        updateMaterial.Net_Weight__c=10;
        updateMaterial.Gross_Weight__c=11;
        updateMaterial.material_status__c='Approved';
        Update updateMaterial; 
        
        Test.stopTest();  
        
    }               
    
    @isTest
    static void testMethod_6()
    {
        dataSetup();
        
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id,Origin_Code__c = '010 - Universal Pictures',Label_Code__c='61 - Universal Pictures');
        insert(dealObj);
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c = 'New Release');
        insert objRelease; 
        
        List<Material__c> insertableMats = new List<Material__c>();
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Material_Status__c='Draft', Format_Description__c='DVD');
        insert matFERT1;
        
        Material__c matFERT2 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD');
        insert matFERT2;
        
        Material__c matROH1 = new Material__c(name='Test ROH 1', Material_Description_Unique__c='Test ROH 1', Material_Type__c= 'ROH', Release__c=objRelease.id, Territory__c='US', Item_type__c='C - Components', Item_Code__c='PG - PACKAGING', Material_Status__c='Draft', Format_Description__c='DVD', Component_Type__c='LITHO');
        insert matROH1;
        
        Plant__c planttest = new Plant__c(Material__c = matFERT1.Id,territory__c='CDN');
        Database.insert(planttest);
        
        List<BOM_Item__c> insertableBomItems = new List<BOM_Item__c>();
        
        BOM_Item__c bom1 = new BOM_Item__c(Material__c=matFERT1.Id, Material_Component__c=matFERT2.Id);
        insertableBomItems.add(bom1);
        
        BOM_Item__c bom2 = new BOM_Item__c(Material__c=matFERT2.Id, Material_Component__c=matROH1.Id);
        insertableBomItems.add(bom2);
        
        insert insertableBomItems;
        
        Test.startTest();  
        
        MaterialTriggerHandler.updateTerritoryInChildComponents(new Set<Id>{matFERT1.Id});
        MaterialTriggerHandler.removeChildViews4TerritoryChange(new Map<Id, String>{matFERT2.Id=>'CDN'});
        MaterialTriggerHandler.removeChildViews4MaterialDelete(new Set<Id>{matFERT1.Id});
        
        Test.stopTest();  
    }
    
    @isTest
    static void testMethod_7()
    {
        dataSetup();
        
        Test.startTest();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        TriggerUtility.checkFromTemplate = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION');
        insert objMaterial;
        
        //TriggerUtility.doNotExecute = TRUE;
        objMaterial.Material_Status__c = 'Approved';
        objMaterial.BOM_Status__c = 'Approved';
        objMaterial.Sales_Org__c = 'V100';
        update objMaterial;
        Sales__c sales = new Sales__c();
        sales.Material__c = objMaterial.id;
        insert sales;
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        Classification__c cls = new Classification__c();
        cls.Material__c = objMaterial.id;
        insert cls;
        Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c();
        auom.Material__c = objMaterial.id;
        insert auom;
        Valuation__c val = new Valuation__c();
        val.Material__c = objMaterial.id;
        val.Valuation_Area__c='V000';
        val.Moving_Price__c = 10;
        val.Origin_Group__c = '0001';
        val.Price_Unit__c = 'AA';
        val.Standard_Price__c = 0.01;
        val.Valuation_Class__c = '7920 - Finished products';
        val.Valuation_Type__c = 'A';
        insert val;
        
        
        
        MaterialTriggerHandler.updatePlantandCreatePlanRecord(new List<Material__c>{objMaterial});
        //TriggerUtility.doNotExecute = FALSE;
        
        MaterialTriggerHandler.executeForTest = TRUE;
        MaterialTriggerHandler.testNewMatsMap = new Map<Id, Material__c>{objMaterial.Id=>objMaterial};
            Material__c oldIns = objMaterial.clone(TRUE, FALSE, FALSE, FALSE);
        oldIns.Material_Status__c='Draft';
        oldIns.BOM_Status__c = 'Draft';
        MaterialTriggerHandler.testOldMatsMap = new Map<Id, Material__c>{oldIns.Id=>oldIns};
            MaterialTriggerHandler.testMatIds = new Set<Id>{objMaterial.Id};
                MaterialTriggerHandler.updateStatusOnIntegrationState();
        
        MaterialTriggerHandler.testOldMatsMap = new Map<Id, Material__c>{objMaterial.Id=>objMaterial};
            Material__c newIns = objMaterial.clone(TRUE, FALSE, FALSE, FALSE);
        newIns.Material_Integration_State__c = 'P';
        newIns.BOM_Integration_State__c = 'P';
        MaterialTriggerHandler.testNewMatsMap = new Map<Id, Material__c>{newIns.Id=>newIns};
            MaterialTriggerHandler.updateStatusOnIntegrationState();
        
        MaterialTriggerHandler.testOldMatsMap = new Map<Id, Material__c>{newIns.Id=>newIns};
            Material__c newIns1 = newIns.clone(TRUE, FALSE, FALSE, FALSE);
        newIns1.Material_Integration_State__c = 'E';
        newIns1.BOM_Integration_State__c = 'E';
        MaterialTriggerHandler.testNewMatsMap = new Map<Id, Material__c>{newIns1.Id=>newIns1};
            MaterialTriggerHandler.updateStatusOnIntegrationState();
        
        MaterialTriggerHandler.testOldMatsMap = new Map<Id, Material__c>{newIns1.Id=>newIns1};
            Material__c newIns2 = newIns1.clone(TRUE, FALSE, FALSE, FALSE);
        newIns2.Material_Integration_State__c = 'S';
        newIns2.BOM_Integration_State__c = 'S';
        MaterialTriggerHandler.testNewMatsMap = new Map<Id, Material__c>{newIns2.Id=>newIns2};
            MaterialTriggerHandler.updateStatusOnIntegrationState();
        
        List<Release_Material__c> rm = [SELECT Id FROM Release_Material__c WHERE Material__c=:objMaterial.Id];
        if(rm != null && rm.size() > 0)
            delete rm;
        
        TriggerUtility.checkFromTemplate = FALSE;
        delete objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    static void testMethod_8()
    {
        
        dataSetup();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-4,Name='Test Release1',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), First_Theatrical_Date__c=Date.Today().addDays(2), Trade_Solicitation_Date__c=Date.Today().addDays(2), Windowed_Rental_Street_Date__c=Date.today(), Windowed_Rental_Pre_Order_Close_Date__c=Date.today());
        insert objRelease1;
        
        TriggerUtility.doNotExecute = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US', Title__c=objTitle.Id, Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)' );
        insert objMaterial;
        
        Sales__c sales = new Sales__c();
        sales.Material__c = objMaterial.id;
        insert sales;
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        Classification__c cls = new Classification__c();
        cls.Material__c = objMaterial.id;
        insert cls;
        Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c();
        auom.Material__c = objMaterial.id;
        insert auom;
        Valuation__c val = new Valuation__c();
        val.Material__c = objMaterial.id;
        val.Valuation_Area__c='V000';
        val.Moving_Price__c = 10;
        val.Origin_Group__c = '0001';
        val.Price_Unit__c = 'AA';
        val.Standard_Price__c = 0.01;
        val.Valuation_Class__c = '7920 - Finished products';
        val.Valuation_Type__c = 'A';
        insert val;
        
        Test.startTest();
        
        objMaterial.Valid_From__c = Date.today();
        objMaterial.RecordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        objMaterial.Release__c = objRelease1.Id;
        objMaterial.Deletion_Flag__c = TRUE;
        update objMaterial;
        
        Material__c objMaterial_JC = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='87 - JOINT CORR/MULTI-STUDIO',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy_JC',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='D (Display Vehicle)',Item_Code__c='CT - CARTON', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)', Base_Quantity__c='1', BOM_Quantity__c=1);
        insert objMaterial_JC;
        
        Material__c objMaterial_FT = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy_FT',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='D (Display Vehicle)',Item_Code__c='FT - PHANTOM TRAY', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)', Base_Quantity__c='1', BOM_Quantity__c=1);
        insert objMaterial_FT;
        
        BOM_Item__c bom1 = new BOM_Item__c(Material__c=objMaterial_JC.Id, Material_Component__c=objMaterial_FT.Id, Component_Quantity__c='1');
        insert bom1;
        
        TriggerUtility.doNotExecute = FALSE;
        TriggerUtility.allowAfterUpdateTriggerExecution = TRUE;
        TriggerUtility.executeQueueable = FALSE;
        objMaterial_JC.Material_Number__c = '11223344000';
        update objMaterial_JC;
        
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethod_9()
    {
        Profile objProfile=[Select Id from Profile where Name ='Platform API'];        
        User platformApiUser = new User(alias = 'TestUser', 
                                        email='test@test.com',
                                        emailencodingkey='UTF-8',
                                        FirstName='API',            
                                        lastname='User', 
                                        languagelocalekey='en_US',
                                        localesidkey='en_US', 
                                        //UserRoleId=objRole.Id, 
                                        profileid=objProfile.ID,
                                        country='United States',
                                        timezonesidkey='America/Los_Angeles',  
                                        username='testadmin345@test.com',
                                        isActive = true);
        System.runAs(platformApiUser) {
        dataSetup();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-4,Name='Test Release1',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), First_Theatrical_Date__c=Date.Today().addDays(2), Trade_Solicitation_Date__c=Date.Today().addDays(2), Windowed_Rental_Street_Date__c=Date.today(), Windowed_Rental_Pre_Order_Close_Date__c=Date.today());
        insert objRelease1;
        
        TriggerUtility.doNotExecute = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US', Title__c=objTitle.Id, Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)' );
        insert objMaterial;
        
        Sales__c sales = new Sales__c();
        sales.Material__c = objMaterial.id;
        insert sales;
        
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        Classification__c cls = new Classification__c();
        cls.Material__c = objMaterial.id;
        insert cls;
        
        Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c();
        auom.Material__c = objMaterial.id;
        insert auom;
        
        Valuation__c val = new Valuation__c();
        val.Material__c = objMaterial.id;
        val.Valuation_Area__c='V000';
        val.Moving_Price__c = 10;
        val.Origin_Group__c = '0001';
        val.Price_Unit__c = 'AA';
        val.Standard_Price__c = 0.01;
        val.Valuation_Class__c = '7920 - Finished products';
        val.Valuation_Type__c = 'A';
        insert val;
        
        
        
        objMaterial.Valid_From__c = Date.today();
        objMaterial.RecordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        
        objMaterial.Release__c = objRelease1.Id;
        objMaterial.Deletion_Flag__c = TRUE;
        update objMaterial;
        
        Material__c objMaterial_JC = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='87 - JOINT CORR/MULTI-STUDIO',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy_JC',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='D (Display Vehicle)',Item_Code__c='CT - CARTON', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)', Base_Quantity__c='1', BOM_Quantity__c=1);
        objMaterial_JC.SAP_Update_Indicator__c = false;
        insert objMaterial_JC;
        
        Material__c objMaterial_FT = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy_FT',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='D (Display Vehicle)',Item_Code__c='FT - PHANTOM TRAY', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)', Base_Quantity__c='1', BOM_Quantity__c=1);
        insert objMaterial_FT;
        
        BOM_Item__c bom1 = new BOM_Item__c(Material__c=objMaterial_JC.Id, Material_Component__c=objMaterial_FT.Id, Component_Quantity__c='1');
        insert bom1;
        
        string recordUpdateId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Test.startTest();
        List<Material__c>materialDataToProcess = [Select id,UPC__c,SAP_Update_Indicator__c,Release__r.Id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id= :objMaterial_JC.id];
        
        
        
        
        TriggerUtility.doNotExecute = FALSE;
        TriggerUtility.allowAfterUpdateTriggerExecution = TRUE;
        TriggerUtility.executeQueueable = FALSE;
        materialDataToProcess[0].Material_Status__c = 'Approved';
        materialDataToProcess[0].Material_Number__c = '11223344000';
        materialDataToProcess[0].Material_Integration_State__c = 'P';
        materialDataToProcess[0].SAP_Update_Indicator__c = True;
        materialDataToProcess[0].recordTypeId = recordUpdateId ;
        materialDataToProcess[0].Deletion_Flag__c = TRUE;
        materialDataToProcess[0].UPC__c = '32111';
        update materialDataToProcess;
        
        
        
        
        Test.stopTest();
        }
    }
    
    private static testMethod void testDeleteFunction(){
        
        Title__c title = testClassUtility.createTitle('TestTitle',true);
        title.SGENNO__c='264897';
        insert title;
        
        Release__c release = testClassUtility.createRelease('releaseTest','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        Material__c material = new Material__c(Territory__c='US', Title__c=title.Id, Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)' );
        //material.Release__c = release.id;
        //TriggerUtility.doNotExecute = FALSE;
        insert material;
        TriggerUtility.doNotExecute = false;
        Test.startTest();
        
           List <Material__c >materialList = [select id from Material__c where id=:material.id];
           delete materialList ;
        Test.StopTest();
    }
    
}