@isTest
private class MaterialTriggerHandlerTest2 {
    
    // Following method is used to prepare data setup.
    @testSetup 
    static void dataSetup() {
        List<Component_ItemCode_Mapping__c> compMapList = new List<Component_ItemCode_Mapping__c>();
        compMapList.add(new Component_ItemCode_Mapping__c(Name='BELLY BAND', Item_Code__c='PG - PACKAGING'));
        compMapList.add(new Component_ItemCode_Mapping__c(Name='DISC CD', Item_Code__c='DS - DISC'));
        compMapList.add(new Component_ItemCode_Mapping__c(Name='INSERT', Item_Code__c='PG - PACKAGING'));
        compMapList.add(new Component_ItemCode_Mapping__c(Name='DISC DVD', Item_Code__c='DS - DISC'));
        insert compMapList;
        
        List<LabelCode_SubLabelCode_Map__c> lblCodeMapList = new List<LabelCode_SubLabelCode_Map__c>();
        LabelCode_SubLabelCode_Map__c lblMap1 = new LabelCode_SubLabelCode_Map__c();
        lblMap1.Name = '61 - Universal Pictures';
        lblMap1.Sub_Label_Code_Id__c = '61';
        lblCodeMapList.add(lblMap1);
        
        LabelCode_SubLabelCode_Map__c lblMap2 = new LabelCode_SubLabelCode_Map__c();
        lblMap2.Name = '87 - JOINT CORR/MULTI-STUDIO';
        lblMap2.Sub_Label_Code_Id__c = '87';
        lblCodeMapList.add(lblMap2);
        insert lblCodeMapList;
        
        List<Title__c> ttlList = new List<Title__c>();
        Title__c objTitle1 = new Title__c(Name='DummyTitle', Active_Flag__c=true,SGENNO__c='12345');
        ttlList.add(objTitle1);
        Title__c objTitle2 = new Title__c(Name='DummyTitle2', Active_Flag__c=true,SGENNO__c='264857');
        ttlList.add(objTitle2);
        Title__c objTitle3 = new Title__c(Name='DummyTitle3', Active_Flag__c=true,SGENNO__c='264975');
        ttlList.add(objTitle3);
        insert ttlList;
        
        TM_Version__c tmV = new TM_Version__c(Name='Dummy_TM', Title__c=objTitle1.Id, Original_Flag__c=TRUE);
        insert tmv;
        
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
        
        List<Deal__c> insertableDeals = new List<Deal__c>();
        Deal__c deal1=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle1.id,Label_Code__c='61 - Universal Pictures',Deal_ID__c='564654',SGENNO__c=objTitle1.SGENNO__c,
                                 Origin_Code__c='010 - Universal Pictures',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
        insertableDeals.add(deal1);
        Deal__c deal2=new Deal__c(Name='Deal2',Finance_Default_Deal__c=false,Title__c=objTitle1.id,SGENNO__c=objTitle1.SGENNO__c,Label_Code__c='62 - Focus',Deal_ID__c='56414651',
                                 Origin_Code__c='025 - Focus Features',Legal_Owner__c='9007',Royalty_Owner__c='4030',Financial_Owner__c='U425', Active_Flag__c=true);
        insertableDeals.add(deal2);
        Deal__c deal3=new Deal__c(Name='Deal3',Finance_Default_Deal__c=true,Title__c=objTitle2.id,SGENNO__c=objTitle2.SGENNO__c,Label_Code__c='61 - Universal Pictures',Deal_ID__c='6454648',Origin_Code__c='010 - Universal Pictures',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
        insertableDeals.add(deal3);
        Deal__c deal4=new Deal__c(Name='Deal4',Finance_Default_Deal__c=true,Title__c=objTitle3.id,SGENNO__c=objTitle3.SGENNO__c,Label_Code__c='62 - Focus',Deal_ID__c='6514984',Origin_Code__c='025 - Focus Features',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
        insertableDeals.add(deal4);
        insert insertableDeals;
        
        List<TM_Version__c> insTMVersions = new List<TM_Version__c>();
        TM_Version__c tmv1 = new TM_Version__c(Name='Television', Title__c=objTitle1.Id, Active_Flag__c=true, Original_Flag__c=true, Rating__c='NC17');
        insTMVersions.add(tmv1);
        TM_Version__c tmv2 = new TM_Version__c(Name='Television', Title__c=objTitle2.Id, Active_Flag__c=true, Original_Flag__c=true, Rating__c='NC17');
        insTMVersions.add(tmv2);
        TM_Version__c tmv3 = new TM_Version__c(Name='Television', Title__c=objTitle3.Id, Active_Flag__c=true, Original_Flag__c=true, Rating__c='NC17');
        insTMVersions.add(tmv3);
        insert insTMVersions;
        
        List<Default_DealID_Mapping__c> dealMapList = new List<Default_DealID_Mapping__c>();
        dealMapList.add(new Default_DealID_Mapping__c(Name='61 - Universal Pictures', DEAL_ID__c='PKGDEAL00085'));
        insert dealMapList;
        
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
        List<DefaultingFieldMapping__c> defFldMapList = new List<DefaultingFieldMapping__c>();
        DefaultingFieldMapping__c d = new DefaultingFieldMapping__c();
        d.Name = 'FieldMapping_1';
        d.Defaulting_Object_API__c = 'Material_Format_Default__c';
        d.Defaulting_Field_API__c = 'Material_Group_3__c';
        d.Transaction_Object_API__c = 'Sales__c';
        d.Transaction_Field_API__c = 'Material_Group_3__c';
        defFldMapList.add(d);
        
        DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d0.Defaulting_Field_API__c = 'Tax_Jurisdiction_Code__c';
        d0.Transaction_Object_API__c = 'Sales__c';
        d0.Transaction_Field_API__c = 'Tax_Jurisdiction_Code__c OR GST_Canada__c';
        defFldMapList.add(d0);
        
        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_2';
        d1.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d1.Defaulting_Field_API__c = 'Indv_Colle__c';
        d1.Transaction_Object_API__c = 'Plant__c';
        d1.Transaction_Field_API__c = 'Indv_Colle__c';
        defFldMapList.add(d1);
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_3';
        d2.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d2.Defaulting_Field_API__c = 'Standard_Price__c';
        d2.Transaction_Object_API__c = 'Valuation__c';
        d2.Transaction_Field_API__c = 'Standard_Price__c';
        defFldMapList.add(d2);
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_4';
        d3.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d3.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d3.Transaction_Object_API__c = 'Material__c';
        d3.Transaction_Field_API__c = 'Alternative_Legal_Title_Lookup__c';
        d3.Execute_on_Update__c = TRUE;
        defFldMapList.add(d3);
        
        DefaultingFieldMapping__c d4 = new DefaultingFieldMapping__c();
        d4.Name = 'FieldMapping_5';
        d4.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d4.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d4.Transaction_Object_API__c = 'Classification__c';
        d4.Transaction_Field_API__c = 'Copyright_Holder__c';
        defFldMapList.add(d4);
        
        DefaultingFieldMapping__c d5 = new DefaultingFieldMapping__c();
        d5.Name = 'FieldMapping_6';
        d5.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d5.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d5.Transaction_Object_API__c = 'Alternative_Unit_of_Measure__c';
        d5.Transaction_Field_API__c = 'International_Article_Number__c';
        defFldMapList.add(d5);
        
        insert defFldMapList;
    }
    
    @isTest
    static void testCreateUpdateSingleSSFERT() {
        Map<String, Id> titleMap = new Map<String, Id>();
        Map<String, String> titleMap1 = new Map<String, String>();
        Map<String, Id> dealMap = new Map<String, Id>();
        Test.startTest();
        for (Title__c objTitle : [SELECT Id, Name,SGENNO__c FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
            titleMap1.put(objTitle.Name, objTitle.SGENNO__c );
        }
        List<Deal__c> lstDeals = [SELECT Id, Name, SGENNO__c,title__r.SGENNO__c FROM Deal__c order by Name];

        
        TM_Version__c tmv2 = [SELECT Id FROM TM_Version__c WHERE Title__c=:titleMap.get('DummyTitle2')];
        
        List<Release__c> insRelList = new List<Release__c>();
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), 
                                    First_Theatrical_Date__c=Date.Today().addDays(10), Windowed_Rental_Street_Date__c=Date.Today().addDays(10), 
                                    Windowed_Rental_Pre_Order_Close_Date__c=Date.Today().addDays(10));
        insRelList.add(objRelease1);
        Release__c objRelease2 = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), 
                                    First_Theatrical_Date__c=Date.Today().addDays(10));
        insRelList.add(objRelease2);
        insert insRelList;
        
        
        
        List<Material__c> insMatList = new List<Material__c>();
        Material__c objMaterial = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_S-SS1', Material_Type__c='FERT',Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle'));
        objMaterial.Deal__c = lstDeals[0].id;
        objMaterial.Label_Code__c = '61 - Universal Pictures';
        objMaterial.TM_Origin_Code__c = '010 - Universal Pictures';
        insMatList.add(objMaterial);
        Material__c objMaterial2 = new Material__c(Territory__c='US & CDN', Format_Description__c='EST (ELECTRONIC SELL THRU)', Material_Status__c='Draft', Name='Dummy_S-SS2', Material_Type__c='FERT',Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle2'),Retailer_Rental__c='SCR (SCREENER)', Format__c='08 - EST (ELECTRONIC SELL THRU)');
        objMaterial2.deal__c =lstDeals[2].id    ;
        insMatList.add(objMaterial2);
        Material__c objMaterial3 = new Material__c(Territory__c='US', Format_Description__c='BD', Material_Status__c='Draft', Name='Dummy_S-SS3', Material_Type__c='FERT',Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle3'),Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)');
        objMaterial3.Format__c = '02 - DVD';
        objMaterial3.deal__c =lstDeals[3].id    ;
        insMatList.add(objMaterial3);
        Material__c objMaterial4 = new Material__c(Territory__c='US & CDN', Format_Description__c='EST (ELECTRONIC SELL THRU)', Material_Status__c='Draft', Name='Dummy_S-SS4', Material_Type__c='FERT',Release__c = objRelease2.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle2'),Retailer_Rental__c='AMZ (AMAZON)', Format__c='08 - EST (ELECTRONIC SELL THRU)');
        objMaterial4.deal__c =lstDeals[2].id    ;
        insMatList.add(objMaterial4);
        Material__c objMaterial5 = new Material__c(Territory__c='US', Format_Description__c='GWP', Material_Status__c='Draft', Name='Dummy_S-SS5', Material_Type__c='FERT',Release__c = objRelease2.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle3'),Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)');
        objMaterial5.deal__c =lstDeals[3].id    ;
        insMatList.add(objMaterial5);
        Material__c objMaterial6 = new Material__c(Territory__c='US & CDN', Format_Description__c='EST (ELECTRONIC SELL THRU)', Material_Status__c='Draft', Name='Dummy_S-SS6', Material_Type__c='FERT',Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle2'),Retailer_Rental__c='FUT (FUTURE SHOP)', Format__c='08 - EST (ELECTRONIC SELL THRU)');
         objMaterial6.deal__c =lstDeals[2].id;                                  
        insMatList.add(objMaterial6);
        Material__c objMaterial7 = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_ROH-Disc', Material_Type__c='ROH',Release__c = objRelease2.id, Item_Type__c='C - Components', Item_Code__c='DS - DISC', Retailer_Rental__c='NTF (NETFLIX)');
        objMaterial7.Label_Code__c = '61 - Universal Pictures';
        objMaterial7.Component_Type__c = 'DISC DVD';
        objMaterial7.Format__c = '02 - DVD';
        objMaterial7.Execute_Validation_Rule__c = false;
        insMatList.add(objMaterial7);
        
        TriggerUtility.checkFromUpdateMaterial = false;
        system.debug('list materials'+insMatList);
        system.debug('list lstDeals'+lstDeals);
        system.debug('list titleMap'+titleMap);
        system.debug('list titleMap1'+titleMap1);
        
        insert insMatList;
        
        List<BOM_Item__c> insBomList = new List<BOM_Item__c>();
        BOM_Item__c bom1 = new BOM_Item__c(Material__c=objMaterial4.Id, Material_Component__c=objMaterial7.Id);
        insBomList.add(bom1);
        TriggerUtility.doNotExecute = TRUE;
        insert insBomList;
        TriggerUtility.doNotExecute = FALSE;
        
        Test.stopTest();
        List<Material__c> upMatList = new List<Material__c>();
        objMaterial2.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        objMaterial2.Territory__c = 'US';
        objMaterial2.Title_Source__c = '03 - MADE FOR VIDEO';
        upMatList.add(objMaterial2);
        objMaterial3.Retailer_Rental__c = 'AMZ (AMAZON)';
        objMaterial3.Territory__c = 'US & CDN';
        upMatList.add(objMaterial3);
        objMaterial4.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        objMaterial4.Release__c = objRelease1.id;
        objMaterial4.BOM_Status__c = 'Processed in SAP';
        objMaterial4.Valid_From__c = Date.today().addDays(20);
        objMaterial4.RecordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        upMatList.add(objMaterial4);
        objMaterial5.Retailer_Rental__c = 'SCR (SCREENER)';
        //objMaterial5.Title__c = titleMap.get('DummyTitle2');
        //objMaterial5.Deal__c = lstDeals[2].id;
        objMaterial5.TM_Version_Lookup__c = tmv2.Id;
        objMaterial5.TM_Origin_Code__c = '010 - Universal Pictures';
        upMatList.add(objMaterial5);
        objMaterial6.Deletion_Flag__c = true;
        objMaterial6.Date_Change_Update__c = true;
        objMaterial6.Original_Material_Number__c = objMaterial5.Id;
        upMatList.add(objMaterial6);
        
        TriggerUtility.allowBeforeUpdateTriggerExecution = true;
        TriggerUtility.allowAfterUpdateTriggerExecution = true;
        TriggerUtility.initiatedFromRelease = false;
        TriggerUtility.initiatedFromMaterial = false;
        TriggerUtility.checkFromUpdateMaterial = false;
        
        update upMatList;
        
        MaterialTriggerHandler.updatePreOrderDatefromMaterial1(new List<Material__c>{objMaterial6});
        
        TriggerUtility.doNotExecute = true;
        objMaterial7.material_status__c = 'Submitted';
        objMaterial4.material_status__c = 'Sent Back';
        update new List<Material__c>{objMaterial4, objMaterial7};
        
        MaterialTriggerHandler.updateComponentOnSentBack(new Set<Id>{objMaterial4.Id});
        TriggerUtility.doNotExecute = false;
        
        
    }
    
    @isTest
    static void testCreateUpdateSingleBFFERT() {
        Title__c objTitle = [SELECT Id FROM Title__c WHERE Name='DummyTitle'];
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Test.startTest();
        
        Material__c objMaterial = new Material__c(Territory__c='US & CDN', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_S-BF', Material_Type__c='FERT', 
                                    Release__c = objRelease.id, Item_Type__c='S (Single)', Item_Code__c='BF - BABY FERT', Title__c=objTitle.Id);
        objMaterial.Deal__c = deal.Id;
        objMaterial.Label_Code__c = '61 - Universal Pictures';
        objMaterial.TM_Origin_Code__c = '010 - Universal Pictures';
        objMaterial.Format__c = '02 - DVD';
        insert objMaterial;
        
        TriggerUtility.doNotExecute = true;
        
        Material__c mat = new Material__c(Id=objMaterial.Id);
        mat.deletion_flag__c = false;
        mat.Material_Status__c = 'Deleted';
        MaterialTriggerHandler.updateMatStatusOnActivate(new List<Material__c>{mat});
        
        mat.Material_Status__c = 'Deleted';
        mat.Request_For_Reactivation__c = true;
        mat.Partial_Deletion_Request__c = true;
        update mat;
       ProcessInstanceWorkitem[] workItems = [SELECT Id
               FROM ProcessInstanceWorkitem 
              WHERE ProcessInstance.TargetObjectId = :mat.Id
                AND ProcessInstance.Status = 'Pending'];
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction('Removed');
        IF(workItems.size()>0){
        pwr.setWorkItemId(workItems[0].id);
        Approval.ProcessResult result = Approval.process(pwr);
        }
        
        MaterialTriggerHandler.deleteReleaseMaterial(new Set<Id>{mat.Id});
        
        mat.RecordTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        mat.material_status__c = 'Sent Back';
        mat.Request_For_Reactivation__c = true;
        mat.Partial_Deletion_Request__c = true;
        update mat;
        
        TriggerUtility.doNotExecute = false;
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testCreateUpdateDisplayFERT() {
        Title__c objTitle = [SELECT Id FROM Title__c WHERE Name='DummyTitle'];
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Test.startTest();
        
        Material__c objMaterial = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_D-CU', Material_Type__c='FERT', 
                                    Release__c = objRelease.id, Item_Type__c='D (Display Vehicle)', Item_Code__c='CU - CUBE');
        objMaterial.Label_Code__c = '61 - Universal Pictures';
        objMaterial.Format__c = '02 - DVD';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateUpdateROHDiscComponent() {
        Title__c objTitle = [SELECT Id FROM Title__c WHERE Name='DummyTitle'];
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Test.startTest();
        
        Material__c objMaterial = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_ROH-Disc', Material_Type__c='ROH', 
                                    Release__c = objRelease.id, Item_Type__c='C - Components', Item_Code__c='DS - DISC');
        objMaterial.Label_Code__c = '61 - Universal Pictures';
        objMaterial.Component_Type__c = 'DISC DVD';
        objMaterial.Format__c = '02 - DVD';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateUpdateSingleSSFERT2() {
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        TM_Version__c tmv2 = [SELECT Id FROM TM_Version__c WHERE Title__c=:titleMap.get('DummyTitle2')];
        
        List<Release__c> insRelList = new List<Release__c>();
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), 
                                    First_Theatrical_Date__c=Date.Today().addDays(10), Windowed_Rental_Street_Date__c=Date.Today().addDays(10), 
                                    Windowed_Rental_Pre_Order_Close_Date__c=Date.Today().addDays(10));
        insRelList.add(objRelease1);
        Release__c objRelease2 = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), 
                                    First_Theatrical_Date__c=Date.Today().addDays(10));
        insRelList.add(objRelease2);
        insert insRelList;
        
        Test.startTest();
        
        List<Material__c> insMatList = new List<Material__c>();
        Material__c objMaterial31 = new Material__c(Territory__c='US', Format_Description__c='BD', Material_Status__c='Draft', Name='Dummy_S-SS31', Material_Type__c='FERT', 
                                    Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle3'),
                                    Retailer_Rental__c='ET1 (ENTERTAINMENT ONE)');
        objMaterial31.Format__c = '02 - DVD';
        objMaterial31.Sales_Org__c = 'V100';
        insMatList.add(objMaterial31);
        Material__c objMaterial8 = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_ROH-Disc2', Material_Type__c='ROH', 
                                    Release__c = objRelease2.id, Item_Type__c='C - Components', Item_Code__c='PG - PACKAGING', Retailer_Rental__c='TRU (TOYS R US)');
        objMaterial8.Label_Code__c = '61 - Universal Pictures';
        objMaterial8.Component_Type__c = 'LITHO';
        objMaterial8.Format__c = '02 - DVD';
        objMaterial8.Execute_Validation_Rule__c = false;
        insMatList.add(objMaterial8);
        
        TriggerUtility.checkFromUpdateMaterial = false;
        insert insMatList;
        
        List<BOM_Item__c> insBomList = new List<BOM_Item__c>();
        BOM_Item__c bom2 = new BOM_Item__c(Material__c=objMaterial31.Id, Material_Component__c=objMaterial8.Id);
        insBomList.add(bom2);
        TriggerUtility.doNotExecute = TRUE;
        insert insBomList;
        TriggerUtility.doNotExecute = FALSE;
        
        objMaterial31.Material_Status__c = 'Approved';
        MaterialTriggerHandler.updatePlantandCreatePlanRecord(new List<Material__c> {objMaterial31});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod_6()
    {
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c = 'New Release');
        insert objRelease; 
        
        List<Material__c> insertableMats = new List<Material__c>();
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Material_Status__c='Draft', Format_Description__c='DVD');
        insert matFERT1;
        
        Material__c matFERT2 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD');
        insert matFERT2;
        Test.startTest();
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
        
          
        
        MaterialTriggerHandler.updateTerritoryInChildComponents(new Set<Id>{matFERT1.Id});
        MaterialTriggerHandler.removeChildViews4TerritoryChange(new Map<Id, String>{matFERT2.Id=>'CDN'});
        MaterialTriggerHandler.removeChildViews4MaterialDelete(new Set<Id>{matFERT1.Id});
        
        Test.stopTest();  
    }
    
    @isTest
    static void testMethod_7()
    {
        Test.startTest();
        
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        TriggerUtility.checkFromTemplate = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US',Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION');
        insert objMaterial;
        
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
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-4,Name='Test Release1',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), First_Theatrical_Date__c=Date.Today().addDays(2), Trade_Solicitation_Date__c=Date.Today().addDays(2), Windowed_Rental_Street_Date__c=Date.today(), Windowed_Rental_Pre_Order_Close_Date__c=Date.today());
        insert objRelease1;
        
        TriggerUtility.doNotExecute = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US',Label_Code__c='61 - Universal Pictures', Title__c=titleMap.get('DummyTitle'),deal__c =deal.id, Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)' );
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
                                        profileid=objProfile.ID,
                                        country='United States',
                                        timezonesidkey='America/Los_Angeles',  
                                        username='testadmin345@test.com',
                                        isActive = true);
        System.runAs(platformApiUser) {
        
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal = [SELECT Id FROM Deal__c WHERE Name='Deal1'];
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-4,Name='Test Release1',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), First_Theatrical_Date__c=Date.Today().addDays(2), Trade_Solicitation_Date__c=Date.Today().addDays(2), Windowed_Rental_Street_Date__c=Date.today(), Windowed_Rental_Pre_Order_Close_Date__c=Date.today());
        insert objRelease1;
        
        TriggerUtility.doNotExecute = TRUE;
        Material__c objMaterial = new Material__c(Territory__c='US', Title__c=titleMap.get('DummyTitle'), Format__c = '02 - DVD',Label_Code__c='24 - PURE FLIX',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - SINGLE SELECTION', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)' );
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
}