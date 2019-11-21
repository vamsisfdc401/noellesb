/*****************************************************************************************
Class Name: DefaultingHandlerTest
Purpose: Test class for apex class  DefaultingHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
private class DefaultingHandlerTest{
    
    @isTest
    // Six Constraint Defaulting
    static void testMethod_1()
    {
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
        //Insert d;
        
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
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name = 'FieldMapping_71';
        d6.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d6.Defaulting_Field_API__c = 'Plant__c';
        d6.Transaction_Object_API__c = 'Plant__c';
        d6.Transaction_Field_API__c = 'Plant__c';
        Insert d6;
        
        DefaultingFieldMapping__c d7 = new DefaultingFieldMapping__c();
        d7.Name = 'FieldMapping_7';
        d7.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d7.Defaulting_Field_API__c = 'Sales_Org__c';
        d7.Transaction_Object_API__c = 'Sales__c';
        d7.Transaction_Field_API__c = 'Sales_Org__c';
        Insert d7;
        
        Component_ItemCode_Mapping__c icm = new Component_ItemCode_Mapping__c();
        icm.Name= 'BELLY BAND';
        icm.Item_Code__c = 'PG - PACKAGING';
        Insert icm;
         
        
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=true, SGENNO__c='12345', Runtime_US__c='ABC');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='UR');
        insert tmv;
        
        Alternative_Legal_Title__c altLgl = new Alternative_Legal_Title__c(Name='TestALT', Alternative_Legal_Title_ID__c='12345');
        insert altLgl;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Test.startTest();
        
        Material__c objMaterial = new Material__c(Name='Test-MAT001', Title__c=objTitle.Id, deal__c = deal.id,Territory__c = 'US', Label_Code__c='61 - Universal Pictures', Retailer_Rental__c='KMT (KMART)', Format__c = '02 - DVD',Format_Description__c= 'DVD', Material_Status__c='Draft', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Material__c objMaterial1 = new Material__c(Name='Test-MAT002', Territory__c = 'US',Format__c = '02 - DVD',Format_Description__c= 'DVD', Material_Status__c='Draft', Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Type__c = 'C - Components', Item_Code__c = 'RG - REGIE STICKER');
        insert objMaterial1;
      
        TriggerUtility.allowBeforeUpdateTriggerExecution = TRUE;
        TriggerUtility.allowAfterUpdateTriggerExecution = TRUE;
        DefaultingHandler.hasInsertExecuted = false;
        
        
              
        DefaultingHandler def =  new DefaultingHandler();
      
        Test.stopTest();          
    }
    
    @isTest
    // Additional Constraint Defaulting
    static void testMethod_2()
    {
        TriggerUtility.checkFromCloning = TRUE;
        TriggerUtility.checkFromUpdateMaterial = false;
        
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
        
        Alternative_Legal_Title__c altLgl = new Alternative_Legal_Title__c(Name='TestALT', Alternative_Legal_Title_ID__c='12345');
        insert altLgl;
        Material_Item_Type_Default__c mitd = new Material_Item_Type_Default__c();
        mitd.Item_Type_Key__c = 'S (Single)';
        mitd.Item_Code__c = 'SS - SINGLE SELECTION';
        mitd.Item_Category_Group__c = 'NORM';
        mitd.Material_Group_3__c = '888 - Master Data Interface Relevant';
        mitd.Material_Pricing_Group__c = 'D6';
        mitd.Xplant_Material_Status__c = 'NA';
        mitd.Alternative_Legal_Title__c = altLgl.Id;
        Insert mitd;
        
        Material_Label_Code_Default__c mlcd =  new Material_Label_Code_Default__c();
        mlcd.Label_Code_Key__c = '11 - TVA Films';
        Insert mlcd;
        
        Material_Material_Type_Default__c mmtd = new Material_Material_Type_Default__c();
        mmtd.Material_Type_Key__c = 'FERT';
        mmtd.Material_Type_Key_Unique__c = 'FERT';
        mmtd.Availability_Check__c  = 'NR - New Release';
        mmtd.Tax_Jurisdiction_Code__c ='1';
        Insert mmtd;
        
        Material_Territory_Default__c mtd = new Material_Territory_Default__c();
        mtd.Territory_Key__c = 'US';
        mtd.Bwd_Cons_Period__c = '010';
        mtd.Plant__c = 'V000 - Univ Studios HV Planning Plant';
        mtd.Sales_Org__c = 'V100 - US Home Video';
        mtd.Stor_Loc_EP__c = '0010';
        mtd.Valuation_Area__c = 'R - Retail';
        Insert mtd;
        
        // Configuring Custom Settings Data.
        DefaultingFieldMapping__c d02 = new DefaultingFieldMapping__c();
        d02.Name = 'FieldMapping_d02';
        d02.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d02.Defaulting_Field_API__c = 'Tax_Jurisdiction_Code__c';
        d02.Transaction_Object_API__c = 'Sales__c';
        d02.Transaction_Field_API__c = 'Tax_Jurisdiction_Code__c OR GST_Canada__c';
        Insert d02;
        
        DefaultingFieldMapping__c d12 = new DefaultingFieldMapping__c();
        d12.Name = 'FieldMapping_22';
        d12.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d12.Defaulting_Field_API__c = 'Indv_Colle__c';
        d12.Transaction_Object_API__c = 'Plant__c';
        d12.Transaction_Field_API__c = 'Indv_Colle__c';
        Insert d12;
        
        DefaultingFieldMapping__c d22 = new DefaultingFieldMapping__c();
        d22.Name = 'FieldMapping_32';
        d22.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d22.Defaulting_Field_API__c = 'Standard_Price__c';
        d22.Transaction_Object_API__c = 'Valuation__c';
        d22.Transaction_Field_API__c = 'Standard_Price__c';
        Insert d22;
        
        DefaultingFieldMapping__c d32 = new DefaultingFieldMapping__c();
        d32.Name = 'FieldMapping_42';
        d32.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d32.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d32.Transaction_Object_API__c = 'Material__c';
        d32.Transaction_Field_API__c = 'Alternative_Legal_Title_Lookup__c';
        Insert d32;
        
        DefaultingFieldMapping__c d42 = new DefaultingFieldMapping__c();
        d42.Name = 'FieldMapping_52';
        d42.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d42.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d42.Transaction_Object_API__c = 'Classification__c';
        d42.Transaction_Field_API__c = 'Copyright_Holder__c';
        Insert d42;
        
        DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'NA';
        d0.Defaulting_Field_API__c = 'NA';
        d0.Transaction_Object_API__c = 'Material__c';
        d0.Transaction_Field_API__c = 'Division__c';
        d0.isAdditionalConstriant__c = true;
        d0.Cloning_Default_Property__c = 'Y';
        Insert d0;

        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_d1';
        d1.Defaulting_Object_API__c = 'NA';
        d1.Defaulting_Field_API__c = 'NA';
        d1.Transaction_Object_API__c = 'Sales__c';
        d1.Transaction_Field_API__c = 'Material_Group_3__c';
        d1.isAdditionalConstriant__c = true;
        d1.Cloning_Default_Property__c = 'Y';
        Insert d1;
        
        DefaultingFieldMapping__c d1S = new DefaultingFieldMapping__c();
        d1S.Name = 'FieldMapping_d1S';
        d1S.Defaulting_Object_API__c = 'NA';
        d1S.Defaulting_Field_API__c = 'NA';
        d1S.Transaction_Object_API__c = 'Sales__c';
        d1S.Transaction_Field_API__c = 'City_Sales_Tax__c OR PST_Base_GST_CDN__c';
        d1S.isAdditionalConstriant__c = true;
        d1S.Cloning_Default_Property__c = 'Y';
        Insert d1S;
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_d2';
        d2.Defaulting_Object_API__c = 'NA';
        d2.Defaulting_Field_API__c = 'NA';
        d2.Transaction_Object_API__c = 'Plant__c';
        d2.Transaction_Field_API__c = 'Rounding_Value__c';
        d2.isAdditionalConstriant__c = true;
        d2.Cloning_Default_Property__c = 'Y';
        Insert d2;
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_d3';
        d3.Defaulting_Object_API__c = 'NA';
        d3.Defaulting_Field_API__c = 'NA';
        d3.Transaction_Object_API__c = 'Valuation__c';
        d3.Transaction_Field_API__c = 'Standard_Price__c';
        d3.isAdditionalConstriant__c = true;
        d3.Cloning_Default_Property__c = 'Y';
        Insert d3;
        
        DefaultingFieldMapping__c d4 = new DefaultingFieldMapping__c();
        d4.Name = 'FieldMapping_d4';
        d4.Defaulting_Object_API__c = 'NA';
        d4.Defaulting_Field_API__c = 'NA';
        d4.Transaction_Object_API__c = 'Classification__c';
        d4.Transaction_Field_API__c = 'Packaging_Type_US__c';
        d4.isAdditionalConstriant__c = true;
        d4.Cloning_Default_Property__c = 'Y';
        Insert d4;
        
        DefaultingFieldMapping__c d5 = new DefaultingFieldMapping__c();
        d5.Name = 'FieldMapping_d5';
        d5.Defaulting_Object_API__c = 'NA';
        d5.Defaulting_Field_API__c = 'NA';
        d5.Transaction_Object_API__c = 'Sales__c';
        d5.Transaction_Field_API__c = 'Material_Group_5__c';
        d5.isAdditionalConstriant__c = true;
        d5.Cloning_Default_Property__c = 'Y';
        Insert d5;
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name = 'FieldMapping_d6';
        d6.Defaulting_Object_API__c = 'NA';
        d6.Defaulting_Field_API__c = 'NA';
        d6.Transaction_Object_API__c = 'Sales__c';
        d6.Transaction_Field_API__c = 'Tax_Indicator__c';
        d6.isAdditionalConstriant__c = true;
        d6.Cloning_Default_Property__c = 'Y';
        Insert d6;
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true, Runtime_US__c='ABC',SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='UR');
        insert tmv;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Test.startTest();
        
        Material__c objMaterial = new Material__c(Territory__c='US', Title__c=objTitle.Id, deal__c = deal.id, Format__c='02 - DVD',Format_Description__c='DVD', Material_Status__c='Draft', Name='dummy', Material_Type__c='FERT', Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)', Label_Code__c='61 - Universal Pictures', Retailer_Rental__c='KMT (KMART)');
        insert objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    // Territory Change Defaulting
    static void testMethod_3()
    {
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
        mmtd.Tax_Jurisdiction_Code__c ='1';
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
        //Insert d;
        
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
        d1.isAdditionalConstriant__c = false; // added on 1.03.2017
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
        
        Component_ItemCode_Mapping__c icm = new Component_ItemCode_Mapping__c();
        icm.Name= 'BELLY BAND';
        icm.Item_Code__c = 'PG - PACKAGING';
        Insert icm;
        
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true, Runtime_US__c='ABC',SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='NR');
        insert tmv;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(Territory__c = 'US', Title__c=objTitle.Id, deal__C = deal.Id, Label_Code__c='61 - Universal Pictures',Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Test.startTest();
        
        TriggerUtility.allowAfterUpdateTriggerExecution = TRUE;
        objMaterial.Territory__c = 'US & CDN';
        update objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    // Change Territory for 6 constraint.
    static void testMethod_4()
    {
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
        //Insert d;
        
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
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name = 'FieldMapping_71';
        d6.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d6.Defaulting_Field_API__c = 'Plant__c';
        d6.Transaction_Object_API__c = 'Plant__c';
        d6.Transaction_Field_API__c = 'Plant__c';
        Insert d6;
        
        DefaultingFieldMapping__c d7 = new DefaultingFieldMapping__c();
        d7.Name = 'FieldMapping_7';
        d7.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d7.Defaulting_Field_API__c = 'Sales_Org__c';
        d7.Transaction_Object_API__c = 'Sales__c';
        d7.Transaction_Field_API__c = 'Sales_Org__c';
        Insert d7;
        
        Component_ItemCode_Mapping__c icm = new Component_ItemCode_Mapping__c();
        icm.Name= 'BELLY BAND';
        icm.Item_Code__c = 'PG - PACKAGING';
        Insert icm;
         
        
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=true, SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='PG13');
        insert tmv;
        
        Alternative_Legal_Title__c altLgl = new Alternative_Legal_Title__c(Name='TestALT', Alternative_Legal_Title_ID__c='12345');
        insert altLgl;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        TriggerUtility.doNotExecute = true;
        Material__c objMaterial = new Material__c(Name='Test-MAT001', Title__c=objTitle.Id, deal__c = deal.id, Territory__c = 'CDN', Label_Code__c='61 - Universal Pictures', Format__c = '02 - DVD',Format_Description__c= 'DVD', Material_Status__c='Draft', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION');
        insert objMaterial;
        TriggerUtility.doNotExecute = false;
        
        Test.startTest();
        
        DefaultingHandler.hasInsertExecuted = false;
        objMaterial.Territory__c = 'US & CDN';
        update objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    // Change Territory for Additional Constraint Defaulting
    static void testMethod_5()
    {
        TriggerUtility.checkFromCloning = TRUE;
        TriggerUtility.checkFromUpdateMaterial = false;
        
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
        
        Alternative_Legal_Title__c altLgl = new Alternative_Legal_Title__c(Name='TestALT', Alternative_Legal_Title_ID__c='12345');
        insert altLgl;
        Material_Item_Type_Default__c mitd = new Material_Item_Type_Default__c();
        mitd.Item_Type_Key__c = 'S (Single)';
        mitd.Item_Code__c = 'SS - SINGLE SELECTION';
        mitd.Item_Category_Group__c = 'NORM';
        mitd.Material_Group_3__c = '888 - Master Data Interface Relevant';
        mitd.Material_Pricing_Group__c = 'D6';
        mitd.Xplant_Material_Status__c = 'NA';
        mitd.Alternative_Legal_Title__c = altLgl.Id;
        Insert mitd;
        
        Material_Label_Code_Default__c mlcd =  new Material_Label_Code_Default__c();
        mlcd.Label_Code_Key__c = '11 - TVA Films';
        Insert mlcd;
        
        Material_Material_Type_Default__c mmtd = new Material_Material_Type_Default__c();
        mmtd.Material_Type_Key__c = 'FERT';
        mmtd.Material_Type_Key_Unique__c = 'FERT';
        mmtd.Availability_Check__c  = 'NR - New Release';
        mmtd.Tax_Jurisdiction_Code__c ='1';
        Insert mmtd;
        
        Material_Territory_Default__c mtd = new Material_Territory_Default__c();
        mtd.Territory_Key__c = 'US';
        mtd.Bwd_Cons_Period__c = '010';
        mtd.Plant__c = 'V000 - Univ Studios HV Planning Plant';
        mtd.Sales_Org__c = 'V100 - US Home Video';
        mtd.Stor_Loc_EP__c = '0010';
        mtd.Valuation_Area__c = 'R - Retail';
        Insert mtd;
        
        // Configuring Custom Settings Data.
        DefaultingFieldMapping__c d02 = new DefaultingFieldMapping__c();
        d02.Name = 'FieldMapping_d02';
        d02.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d02.Defaulting_Field_API__c = 'Tax_Jurisdiction_Code__c';
        d02.Transaction_Object_API__c = 'Sales__c';
        d02.Transaction_Field_API__c = 'Tax_Jurisdiction_Code__c OR GST_Canada__c';
        Insert d02;
        
        DefaultingFieldMapping__c d12 = new DefaultingFieldMapping__c();
        d12.Name = 'FieldMapping_22';
        d12.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d12.Defaulting_Field_API__c = 'Indv_Colle__c';
        d12.Transaction_Object_API__c = 'Plant__c';
        d12.Transaction_Field_API__c = 'Indv_Colle__c';
        Insert d12;
        
        DefaultingFieldMapping__c d22 = new DefaultingFieldMapping__c();
        d22.Name = 'FieldMapping_32';
        d22.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d22.Defaulting_Field_API__c = 'Standard_Price__c';
        d22.Transaction_Object_API__c = 'Valuation__c';
        d22.Transaction_Field_API__c = 'Standard_Price__c';
        Insert d22;
        
        DefaultingFieldMapping__c d32 = new DefaultingFieldMapping__c();
        d32.Name = 'FieldMapping_42';
        d32.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d32.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d32.Transaction_Object_API__c = 'Material__c';
        d32.Transaction_Field_API__c = 'Alternative_Legal_Title_Lookup__c';
        Insert d32;
        
        DefaultingFieldMapping__c d42 = new DefaultingFieldMapping__c();
        d42.Name = 'FieldMapping_52';
        d42.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        d42.Defaulting_Field_API__c = 'Alternative_Legal_Title__c';
        d42.Transaction_Object_API__c = 'Classification__c';
        d42.Transaction_Field_API__c = 'Copyright_Holder__c';
        Insert d42;
        
        DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'NA';
        d0.Defaulting_Field_API__c = 'NA';
        d0.Transaction_Object_API__c = 'Material__c';
        d0.Transaction_Field_API__c = 'Division__c';
        d0.isAdditionalConstriant__c = true;
        d0.Cloning_Default_Property__c = 'Y';
        Insert d0;

        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_d1';
        d1.Defaulting_Object_API__c = 'NA';
        d1.Defaulting_Field_API__c = 'NA';
        d1.Transaction_Object_API__c = 'Sales__c';
        d1.Transaction_Field_API__c = 'Material_Group_3__c';
        d1.isAdditionalConstriant__c = true;
        d1.Cloning_Default_Property__c = 'Y';
        Insert d1;
        
        DefaultingFieldMapping__c d1S = new DefaultingFieldMapping__c();
        d1S.Name = 'FieldMapping_d1S';
        d1S.Defaulting_Object_API__c = 'NA';
        d1S.Defaulting_Field_API__c = 'NA';
        d1S.Transaction_Object_API__c = 'Sales__c';
        d1S.Transaction_Field_API__c = 'City_Sales_Tax__c OR PST_Base_GST_CDN__c';
        d1S.isAdditionalConstriant__c = true;
        d1S.Cloning_Default_Property__c = 'Y';
        Insert d1S;
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_d2';
        d2.Defaulting_Object_API__c = 'NA';
        d2.Defaulting_Field_API__c = 'NA';
        d2.Transaction_Object_API__c = 'Plant__c';
        d2.Transaction_Field_API__c = 'Rounding_Value__c';
        d2.isAdditionalConstriant__c = true;
        d2.Cloning_Default_Property__c = 'Y';
        Insert d2;
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_d3';
        d3.Defaulting_Object_API__c = 'NA';
        d3.Defaulting_Field_API__c = 'NA';
        d3.Transaction_Object_API__c = 'Valuation__c';
        d3.Transaction_Field_API__c = 'Standard_Price__c';
        d3.isAdditionalConstriant__c = true;
        d3.Cloning_Default_Property__c = 'Y';
        Insert d3;
        
        DefaultingFieldMapping__c d4 = new DefaultingFieldMapping__c();
        d4.Name = 'FieldMapping_d4';
        d4.Defaulting_Object_API__c = 'NA';
        d4.Defaulting_Field_API__c = 'NA';
        d4.Transaction_Object_API__c = 'Classification__c';
        d4.Transaction_Field_API__c = 'Packaging_Type_US__c';
        d4.isAdditionalConstriant__c = true;
        d4.Cloning_Default_Property__c = 'Y';
        Insert d4;
        
        DefaultingFieldMapping__c d5 = new DefaultingFieldMapping__c();
        d5.Name = 'FieldMapping_d5';
        d5.Defaulting_Object_API__c = 'NA';
        d5.Defaulting_Field_API__c = 'NA';
        d5.Transaction_Object_API__c = 'Sales__c';
        d5.Transaction_Field_API__c = 'Material_Group_5__c';
        d5.isAdditionalConstriant__c = true;
        d5.Cloning_Default_Property__c = 'Y';
        Insert d5;
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name = 'FieldMapping_d6';
        d6.Defaulting_Object_API__c = 'NA';
        d6.Defaulting_Field_API__c = 'NA';
        d6.Transaction_Object_API__c = 'Sales__c';
        d6.Transaction_Field_API__c = 'Tax_Indicator__c';
        d6.isAdditionalConstriant__c = true;
        d6.Cloning_Default_Property__c = 'Y';
        Insert d6;
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='NC17');
        insert tmv;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        TriggerUtility.doNotExecute = true;
        Material__c objMaterial = new Material__c(Territory__c='US', Format__c='02 - DVD',Format_Description__c='DVD', Material_Status__c='Draft', Name='dummy', Material_Type__c='FERT', Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        TriggerUtility.doNotExecute = false;
        
        Test.startTest();
        
        DefaultingHandler.hasInsertExecuted = false;
        objMaterial.Territory__c = 'US & CDN';
        update objMaterial;
        
        Test.stopTest();
    }
    
    @isTest
    // Cloning for 6 constraint.
    static void testMethod_6()
    {
        // Defining custom settings
        DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d0.Defaulting_Field_API__c = 'Division__c';
        d0.Transaction_Object_API__c = 'Material__c';
        d0.Transaction_Field_API__c = 'Division__c';
        d0.Cloning_Default_Property__c = 'N';
        Insert d0;
        
        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_d1';
        d1.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d1.Defaulting_Field_API__c = 'Material_Group_2__c';
        d1.Transaction_Object_API__c = 'Sales__c';
        d1.Transaction_Field_API__c = 'Material_Group_2__c';
        d1.Cloning_Default_Property__c = 'N';
        Insert d1;
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_d2';
        d2.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d2.Defaulting_Field_API__c = 'Consumption_Mode__c';
        d2.Transaction_Object_API__c = 'Plant__c';
        d2.Transaction_Field_API__c = 'Consumption_Mode__c';
        d2.Cloning_Default_Property__c = 'N';
        Insert d2;
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_d3';
        d3.Defaulting_Object_API__c = 'Material_Format_Default__c';
        d3.Defaulting_Field_API__c = 'Aspect_Ratio__c';
        d3.Transaction_Object_API__c = 'Classification__c';
        d3.Transaction_Field_API__c = 'Aspect_Ratio__c';
        d3.Cloning_Default_Property__c = 'N';
        Insert d3;
        
        DefaultingFieldMapping__c d4 = new DefaultingFieldMapping__c();
        d4.Name = 'FieldMapping_d4';
        d4.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        d4.Defaulting_Field_API__c = 'Standard_Price__c';
        d4.Transaction_Object_API__c = 'Valuation__c';
        d4.Transaction_Field_API__c = 'Standard_Price__c';
        d4.Cloning_Default_Property__c = 'N';
        Insert d4;
        
        DefaultingFieldMapping__c d5 = new DefaultingFieldMapping__c();
        d5.Name = 'FieldMapping_d5';
        d5.Defaulting_Object_API__c = 'NA';
        d5.Defaulting_Field_API__c = 'NA';
        d5.Transaction_Object_API__c = 'Alternative_Unit_of_Measure__c';
        d5.Transaction_Field_API__c = 'Deletion_Flag__c';
        d5.Cloning_Default_Property__c = 'Y W/ FALSE';
        Insert d5;
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name = 'FieldMapping_d6';
        d6.Defaulting_Object_API__c = 'NA';
        d6.Defaulting_Field_API__c = 'NA';
        d6.Transaction_Object_API__c = 'Alternative_Unit_of_Measure__c';
        d6.Transaction_Field_API__c = 'International_Article_Number__c';
        d6.Cloning_Default_Property__c = 'Y w/ blank';
        Insert d6;
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        TM_Version__c tmv = new TM_Version__c(Name='Theatrical', Title__c=objTitle.Id, Active_Flag__c=true, Original_Flag__c=true, TM_Version_ID__c='20072', Series_Sys__c='198', Version_Type__c='TH - Theatrical', Rating__c='UR');
        insert tmv;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        TriggerUtility.doNotExecute = true;
        
        Material__c objMaterial = new Material__c(Territory__c='US', Format__c='02 - DVD',Format_Description__c='DVD', Material_Status__c='Draft', Name='dummy', Material_Type__c='FERT', Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - Single Selection');
        insert objMaterial;
        
        Sales__c sales = new Sales__c(Material__c=objMaterial.Id, Material_Group_2__c='AR', Sales_Org__c='V100 - US Home Video', Territory__c='US');
        insert sales;
        
        Plant__c plant = new Plant__c(Material__c=objMaterial.Id, Plant__c='V000 - Univ Studios HV Planning Plant', Consumption_Mode__c='3 - Forward consumption only', Territory__c='US');
        insert plant;
        
        Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        Classification__c cls = new Classification__c(Material__c=objMaterial.Id, RecordTypeId=generalRecordTypeId, Aspect_Ratio__c='AWS');
        insert cls;
        
        Alternative_Unit_of_Measure__c alt = new Alternative_Unit_of_Measure__c(Material__c=objMaterial.Id, International_Article_Number__c='ART-003794', Alternative_Unit_of_Measure__c='EA - Each', Territory__c='US');
        insert alt;
        
        Valuation__c val = new Valuation__c(Material__c=objMaterial.Id, Valuation_Area__c='V000', Standard_Price__c=10, Territory__c='US');
        insert val;
        
        TriggerUtility.doNotExecute = false;
        
        Test.startTest();
        
        TriggerUtility.checkFromCloning = true;
        TriggerUtility.checkFromUpdateMaterial = false;
        Material__c cloneMaterial = new Material__c(CloneHelperField__c=objMaterial.Id, Territory__c='US', Format__c='02 - DVD',Format_Description__c='DVD', Material_Status__c='Draft', Name='DummyClone', Material_Type__c='FERT', Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS - Single Selection');
        insert cloneMaterial;
        
        
        Test.stopTest();
    }
}