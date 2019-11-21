/*****************************************************************************************
Class Name: DealUpdateBatchHandlerTest
Purpose: Test class for apex class DealUpdateBatchHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/15/2017           Suman                    Initial Development
******************************************************************************************/
@isTest
private class DealUpdateBatchHandlerTest {
    
    // Following method is used to prepare data setup. 
    @testSetup 
    static void dataSetup()
    {
        Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
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
        Title__c objTitle2 = new Title__c(Name='DummyTitle2', Active_Flag__c=true,SGENNO__c='23458');
        ttlList.add(objTitle2);
        Title__c objTitle3 = new Title__c(Name='DummyTitle3', Active_Flag__c=true,SGENNO__c='65248');
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
        Deal__c deal1=new Deal__c(Name='Deal1',Finance_Default_Deal__c=false,Title__c=objTitle1.id,Label_Code__c='61 - Universal Pictures',Deal_ID__c='PKGDEAL00217',SGENNO__c='472652',
                                 Origin_Code__c='010 - Universal Pictures',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
        insertableDeals.add(deal1);
        Deal__c deal2=new Deal__c(Name='Deal2',Finance_Default_Deal__c=false,Title__c=objTitle1.id,Label_Code__c='62 - Focus',Deal_ID__c='PKGDEAL00217',SGENNO__c=objTitle1.SGENNO__c,
                                 Origin_Code__c='025 - Focus Features',Legal_Owner__c='9007',Royalty_Owner__c='4030',Financial_Owner__c='U425', Active_Flag__c=true);
        insertableDeals.add(deal2);
        Deal__c deal3=new Deal__c(Name='Deal3',Finance_Default_Deal__c=true,Title__c=objTitle2.id,Label_Code__c='61 - Universal Pictures',Deal_ID__c='PKGDEAL00217',SGENNO__c='472652',
                                 Origin_Code__c='010 - Universal Pictures',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
        insertableDeals.add(deal3);
        Deal__c deal4=new Deal__c(Name='Deal3',Finance_Default_Deal__c=true,Title__c=objTitle3.id,Label_Code__c='62 - Focus',Deal_ID__c='PKGDEAL00085',SGENNO__c='472652',
                                 Origin_Code__c='025 - Focus Features',Legal_Owner__c='9006',Royalty_Owner__c='4029',Financial_Owner__c='U424', Active_Flag__c=true);
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
    static void testCreateUpdateSingleSSFERT()
    {
        Map<String, Id> titleMap = new Map<String, Id>();
        for (Title__c objTitle : [SELECT Id, Name FROM Title__c]) {
            titleMap.put(objTitle.Name, objTitle.Id);
        }
        Deal__c deal2 = [SELECT Id, Label_Code__c, Origin_Code__c, Legal_Owner__c, Financial_Owner__c FROM Deal__c WHERE Name='Deal2'];
        
        List<Release__c> insRelList = new List<Release__c>();
        Release__c objRelease1 = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c=Date.Today(),Brand_Group__c='Family',
                                    Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today(), 
                                    First_Theatrical_Date__c=Date.Today().addDays(10), Windowed_Rental_Street_Date__c=Date.Today().addDays(10), 
                                    Windowed_Rental_Pre_Order_Close_Date__c=Date.Today().addDays(10), Title__c=titleMap.get('DummyTitle'));
        insRelList.add(objRelease1);
        insert insRelList;
        
        Test.startTest();
        
        List<Material__c> insMatList = new List<Material__c>();
        Material__c objMaterial = new Material__c(Territory__c='US', Format_Description__c='DVD', Material_Status__c='Draft', Name='Dummy_S-SS1', Material_Type__c='FERT', 
                                    Release__c = objRelease1.id, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Title__c=titleMap.get('DummyTitle'));
        objMaterial.Label_Code__c = '61 - Universal Pictures';
        objMaterial.TM_Origin_Code__c = '010 - Universal Pictures';
        objMaterial.Deal__c = deal2.Id;
        insMatList.add(objMaterial);
        
        Material__c material2 = testClassUtility.createMaterial('12 - VOD', 'BD-R', 'dummy2', 'ROH', objRelease1.id, TRUE, 'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        insMatList.add(material2);
        
        TriggerUtility.checkFromUpdateMaterial = false;
        insert insMatList;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=objMaterial.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        TriggerUtility.doNotExecute = FALSE;
        
        deal2.Finance_Default_Deal__c = true;
        update deal2;
        
        //ID batchprocessid = Database.executeBatch(new DealUpdateBatchHandler(new Set<Id>{titleMap.get('DummyTitle')}, new Map<Id, Deal__c>{titleMap.get('DummyTitle') => deal2}));
        
        Test.stopTest();
        
        Material__c updatedMat = [SELECT Id, Deal__c, Legal_Owner__c FROM Material__c WHERE Id=:objMaterial.Id];
        System.assertEquals(updatedMat.Deal__c, deal2.Id);
        System.assertEquals(updatedMat.Legal_Owner__c, deal2.Legal_Owner__c);
    }
}