/*****************************************************************************************
Class Name: TestDefaultHandler
Purpose: This is the Test Class of DefaultHandler.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/08/2016           Suman Kundu              Initial Development
******************************************************************************************/
@isTest
private class TestDefaultHandler
{
    /*private static User userBrand;
    
    // Preparing basic setup data
    private static void prepareSetupData()
    {
        // Creating brand user.
        Profile profileBrand = [select id from profile where name='Brand User' ];        
        userBrand = new User(alias = 'testBD', 
                             email = 'test1@test.com',
                             emailencodingkey = 'UTF-8', 
                             lastname = 'Testing', 
                             languagelocalekey = 'en_US',
                             localesidkey = 'en_US', 
                             profileid = profileBrand.ID,
                             country = 'United States',
                             timezonesidkey = 'America/Los_Angeles', 
                             username = 'testBrand@test.com.brand',
                             isActive = true);     
        insert userBrand;
        
        // Preparing test setup data.
        List<DefaultingFieldMapping__c> defaultFieldMappingList = new List<DefaultingFieldMapping__c>();
        
        DefaultingFieldMapping__c def1 = new DefaultingFieldMapping__c();
        def1.Name = 'FieldMapping_1';
        def1.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        def1.Defaulting_Field_API__c = 'Xplant_Material_Status__c';
        def1.Transaction_Object_API__c = 'Material__c';
        def1.Transaction_Field_API__c = 'Xplant_Material_Status__c';
        defaultFieldMappingList.add(def1);
        
        DefaultingFieldMapping__c def2 = new DefaultingFieldMapping__c();
        def2.Name = 'FieldMapping_2';
        def2.Defaulting_Object_API__c = 'Material_Format_Default__c';
        def2.Defaulting_Field_API__c = 'Material_Group_3__c';
        def2.Transaction_Object_API__c = 'Sales__c';
        def2.Transaction_Field_API__c = 'Material_Group_3__c';
        defaultFieldMappingList.add(def2);
        
        DefaultingFieldMapping__c def3 = new DefaultingFieldMapping__c();
        def3.Name = 'FieldMapping_3';
        def3.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        def3.Defaulting_Field_API__c = 'City_Sales_Tax__c';
        def3.Transaction_Object_API__c = 'Sales__c';
        def3.Transaction_Field_API__c = 'City_Sales_Tax__c OR PST_Base_GST_CDN__c';
        defaultFieldMappingList.add(def3);
        
        DefaultingFieldMapping__c def4 = new DefaultingFieldMapping__c();
        def4.Name = 'FieldMapping_4';
        def4.Defaulting_Object_API__c = 'Material_Item_Type_Default__c';
        def4.Defaulting_Field_API__c = 'Rounding_Value__c';
        def4.Transaction_Object_API__c = 'Plant__c';
        def4.Transaction_Field_API__c = 'Rounding_Value__c';
        defaultFieldMappingList.add(def4);
        
        DefaultingFieldMapping__c def5 = new DefaultingFieldMapping__c();
        def5.Name = 'FieldMapping_5';
        def5.Defaulting_Object_API__c = 'Material_Material_Type_Default__c';
        def5.Defaulting_Field_API__c = 'Max_Stock_Level__c';
        def5.Transaction_Object_API__c = 'Alternative_Unit_of_Measure__c';
        def5.Transaction_Field_API__c = 'Length__c';
        defaultFieldMappingList.add(def5);
        
        DefaultingFieldMapping__c def6 = new DefaultingFieldMapping__c();
        def6.Name = 'FieldMapping_6';
        def6.Defaulting_Object_API__c = 'Material_Format_Default__c';
        def6.Defaulting_Field_API__c = 'Format__c';
        def6.Transaction_Object_API__c = 'Classification__c';
        def6.Transaction_Field_API__c = 'Format__c';
        defaultFieldMappingList.add(def6);
        
        DefaultingFieldMapping__c def7 = new DefaultingFieldMapping__c();
        def7.Name = 'FieldMapping_7';
        def7.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        def7.Defaulting_Field_API__c = 'Valuation_Area__c';
        def7.Transaction_Object_API__c = 'Valuation__c';
        def7.Transaction_Field_API__c = 'Valuation_Area__c';
        defaultFieldMappingList.add(def7);
        
        insert defaultFieldMappingList;
        
        // Preparing Default records
        // Creating Material Type default record.
        Material_Material_Type_Default__c defMatType = new Material_Material_Type_Default__c();
        defMatType.Material_Type_Key__c = 'FERT';
        defMatType.Max_Stock_Level__c = 1000;
        defMatType.City_Sales_Tax__c = '1';
        insert defMatType;
        
        // Creating Item Type default record. 
        Material_Item_Type_Default__c defItmType = new Material_Item_Type_Default__c();
        defItmType.Item_Type_Key__c = 'S (Single)';
        defItmType.Rounding_Value__c = 10;
        defItmType.Xplant_Material_Status__c = 'AA';
        insert defItmType;
        
        // Creating Item Code default record.
        Material_Item_Code_Default__c defItmCode = new Material_Item_Code_Default__c();
        defItmCode.Item_Code_Key__c = 'SS - SINGLE SELECTION';
        insert defItmCode;
        
        // Creating Label Code default record.
        Material_Label_Code_Default__c defLblCode = new Material_Label_Code_Default__c();
        defLblCode.Label_Code_Key__c = '61 - Universal Pictures';
        insert defLblCode;
        
        // Creating Format default record.
        Material_Format_Default__c defFormat = new Material_Format_Default__c();
        defFormat.Format_Key__c = 'DVD';
        defFormat.Format__c = '02 - DVD';
        defFormat.Material_Group_3__c = '888 - Master Data Interface Relevant';
        insert defFormat;
        
        // Creating Territory default record.
        Material_Territory_Default__c defTrritory = new Material_Territory_Default__c();
        defTrritory.Territory_Key__c = 'US';
        defTrritory.Valuation_Area__c = 'R - Retail';
        insert defTrritory;
    }
    
    @isTest
    static void testMethod1()
    {
        // Calling setup method
        prepareSetupData();
        
        Material__c mat1;
        Material__c mat2;
        
        Test.startTest();
        
        System.runAs(userBrand) 
        {
            Release__c release = new Release__c(Name='Test Release', Street_Date__c = Date.Today(), Brand_Group__c = 'Universal Pictures', 
                                                Project_Type__c = 'New Release');
            insert release;
            
            // Creating FERT material for US.
            mat1 = new Material__c();
            mat1.Name = 'Test Material';
            mat1.Release__c = release.Id;
            mat1.Material_Type__c = 'FERT';
            mat1.Item_Type__c = 'S (Single)';
            mat1.Item_Code__c = 'SS - SINGLE SELECTION';
            mat1.Label_Code__c = '61 - Universal Pictures';
            mat1.Format_Description__c = 'DVD';
            mat1.Territory__c = 'US';
            
            insert mat1;
            
            // Creating FERT material for CDN.
            mat2 = new Material__c();
            mat2.Name = 'Test Material';
            mat2.Release__c = release.Id;
            mat2.Material_Type__c = 'FERT';
            mat2.Item_Type__c = 'S (Single)';
            mat2.Item_Code__c = 'SS - SINGLE SELECTION';
            mat2.Label_Code__c = '61 - Universal Pictures';
            mat2.Format_Description__c = 'DVD';
            mat2.Territory__c = 'CDN';
            
            insert mat2;
        }
        
        Test.stopTest();
        
        Material__c matUSTest = [SELECT Xplant_Material_Status__c, (SELECT City_Sales_Tax__c, PST_Base_GST_CDN__c FROM Sales__r)
                                 FROM Material__c
                                 WHERE Id = :mat1.Id
                                ];
        //System.assertEquals(matUSTest.Xplant_Material_Status__c, 'AA');
        if(matUSTest.Sales__r != null && matUSTest.Sales__r.size() > 0)
        {
            System.assertEquals(matUSTest.Sales__r[0].City_Sales_Tax__c, '1');
        }
        
        Material__c matCDNTest = [SELECT Xplant_Material_Status__c, (SELECT City_Sales_Tax__c, PST_Base_GST_CDN__c FROM Sales__r)
                                  FROM Material__c
                                  WHERE Id = :mat2.Id
                                 ];
        if(matCDNTest.Sales__r != null && matCDNTest.Sales__r.size() > 0)
        {
            System.assertEquals(matCDNTest.Sales__r[0].PST_Base_GST_CDN__c, '1');
        }
    }*/
}