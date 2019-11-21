//Utility class to create test data

@isTest
public class RFTest_TestDataFactory {    
    public static Id platformApiProfile = Label.PlatformApiProfileId;//get profile id from label to save query
    public static Id brandUserProfile = Label.BrandUserProfileId;//get profile id from label to save query
    public static Id MasterDataProfile = Label.MasterDataAdminProfileId;//get profile id from label to save query
    public static Id ThirdPartyUserProfile = Label.ThirdpartyUserProfileId;//get profile id from label to save query
    public static Id brandUserRole = Label.BrandUser_RoleId;
    Public static void Defaulting()
    {
    	DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d0.Defaulting_Field_API__c = 'Sales_Org__c';
        d0.Transaction_Object_API__c = 'Sales__c';
        d0.Transaction_Field_API__c = 'Sales_Org__c';
        Insert d0;
        
        DefaultingFieldMapping__c d3 = new DefaultingFieldMapping__c();
        d3.Name = 'FieldMapping_d3';
        d3.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d3.Defaulting_Field_API__c = 'Plant__c';
        d3.Transaction_Object_API__c = 'Plant__c';
        d3.Transaction_Field_API__c = 'Plant__c';
        Insert d3;
        
        Material_Territory_Default__c mtd1 = new Material_Territory_Default__c();
        mtd1.Territory_Key__c = 'CDN';
        mtd1.Bwd_Cons_Period__c = '010';
        mtd1.Plant__c = 'V850 - Technicolor Canada';
        mtd1.Sales_Org__c = 'V800 - Canada Home Video';
        mtd1.Stor_Loc_EP__c = '0010';
        mtd1.Valuation_Area__c = 'V850';
        Insert mtd1;
        
		Material_Territory_Default__c mtd2 = new Material_Territory_Default__c();
        mtd2.Territory_Key__c = 'US';
        mtd2.Bwd_Cons_Period__c = '010';
        mtd2.Plant__c = 'V000 - Univ Studios HV Planning Plant';
        mtd2.Sales_Org__c = 'V100 - US Home Video';
        mtd2.Stor_Loc_EP__c = '0010';
        mtd2.Valuation_Area__c = 'V000';
        mtd2.Plant_for_Material__c='V000';
        Insert mtd2;
        
        Material_Territory_Default__c mtd3 = new Material_Territory_Default__c();
        mtd3.Territory_Key__c = 'US & CDN';
        mtd3.Bwd_Cons_Period__c = '010';
        mtd3.Plant__c = 'V000 - Univ Studios HV Planning Plant';
        mtd3.Sales_Org__c = 'V100 - US Home Video';
        mtd3.Stor_Loc_EP__c = '0010';
        mtd3.Valuation_Area__c = 'V000';
        Insert mtd3;
        
        DefaultingFieldMapping__c d6 = new DefaultingFieldMapping__c();
        d6.Name='FieldMapping_4';
        d6.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d6.Defaulting_Field_API__c = 'Purchasing_Group__c';
        d6.Transaction_Object_API__c = 'Plant__c';
        d6.Transaction_Field_API__c = 'Purchasing_Group__c';
        Insert d6;
        
        DefaultingFieldMapping__c d7 = new DefaultingFieldMapping__c();
        d7.Name='FieldMapping_7';
        d7.Defaulting_Object_API__c = 'Material_Label_Code_Default__c';
        d7.Defaulting_Field_API__c = 'MRP_Controller__c';
        d7.Transaction_Object_API__c = 'Plant__c';
        d7.Transaction_Field_API__c = 'MRP_Controller__c';
        Insert d7;
        
        DefaultingFieldMapping__c d8 = new DefaultingFieldMapping__c();
        d8.Name='FieldMapping_8';
        d8.isAdditionalConstriant__c=TRUE;
        d8.Transaction_Object_API__c = 'Sales__c';
        d8.Transaction_Field_API__c = 'Tax_Indicator__c';
        d8.Defaulting_Object_API__c = 'NA';
        d8.Defaulting_Field_API__c = 'NA';
        Insert d8;
        
   		/*     DefaultAdditionalConstirant__mdt da1 = new DefaultAdditionalConstirant__mdt();

		//da1.MasterLabel='Tax_Indicator__c';
        //da1.DeveloperName='Tax_Indicator_1B';
        da1.Material_Type__c='FERT';
        da1.Territory__c='CDN';
        da1.Value__c='1';
      */
               Material_Label_Code_Default__c mlcd1 = new Material_Label_Code_Default__c();
        mlcd1.Label_Code_Key__c='59 - Paramount';
        mlcd1.Volume_Rebate_Group__c='59';
        mlcd1.Purchasing_Group__c='PHJ - PHE Buyer/Planner';
        mlcd1.MRP_Controller__c='PHJ - Buyer/Planner PHJ';
        insert mlcd1;
        
        DefaultingFieldMapping__c d1 = new DefaultingFieldMapping__c();
        d1.Name = 'FieldMapping_2';
        d1.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d1.Defaulting_Field_API__c = 'Plant_for_Material__c';
        d1.Transaction_Object_API__c = 'Material__c';
        d1.Transaction_Field_API__c = 'Plant__c';
        Insert d1;
        
        DefaultingFieldMapping__c d2 = new DefaultingFieldMapping__c();
        d2.Name = 'FieldMapping_3';
        d2.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d2.Defaulting_Field_API__c = 'Valuation_Area__c';
        d2.Transaction_Object_API__c = 'Valuation__c';
        d2.Transaction_Field_API__c = 'Valuation_Area__c';
        Insert d2;

            /*
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
*/
        
    }


    //create new release
    public static Release__c[] createReleases(Integer n, Id titleId, String brandGroup, String territory, String projectType, Id recordType) {
         Release__c[] releases = new Release__c[0];
         for (Integer i = 0 ; i < n; i++) {
             Release__c temp = new Release__c(Name = 'TEST_RELEASE' + i, Title__c = titleId, 
                                                     Street_Date__c = Date.today(), Brand_Group__c = brandGroup,
                                                     Territory__c = territory, Project_Type__c = projectType);
             if (recordType != null) { temp.RecordTypeId = recordType; }                                        
             releases.add(temp);
         }
         return releases;                  
     }
     
    //create new material
    public Static List<Material__c> createMaterials(Integer n, String formatDes, String materialType, String itemType, String itemCode, String territory, String releaseId, Id recordType) {
    
        Material__c[] materials = new Material__c[0];
        for (Integer i = 0 ; i < n; i++) {
            Material__c temp = new Material__c(Name = 'TEST_MATERIAL_UC_123445' + i,
                                                        Format_Description__c = formatDes,
                                                        Material_Type__c = materialType,
                                                        Item_Type__c = itemType,
                                                        Item_Code__c = itemCode,
                                                        Territory__c = territory,
                                                        Release__c = releaseId
                                                      );
            
        if (recordType != null) { temp.RecordTypeId = recordType; } 
            materials.add(temp);
        }
        return materials;
    
    }
    
    //create bom item
    public static Bom_Item__c createBOMItem(Id materialId, Id materialCmpId) {
        BOM_Item__c bom = new BOM_Item__c(Material__c = materialId, 
                                          Material_Component__c = materialCmpId,
                                          Item_Category__c = 'T'
                                         );
        return bom;
    }
    
    //create title
    public static List<Title__c> createTitles(Integer numberOfTitles) {
        List<Title__c> titles = new List<Title__c>();
        for (Integer i = 0 ; i < numberOfTitles; i++) 
        {
        Title__c objTitle = new Title__c();
        objTitle.Name = 'Test Title' + Math.random();
        objTitle.Active_Flag__c = True;
        objTitle.SGENNO__c='0000001';
        titles.add(objTitle);
        }
        return titles;                
    }
    
    public static User createUser(Id profileId, Integer i) {
        return new User(Alias = 'pU' + i, Email='platformuser' + i + '@testalphabetagamma.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileId,
                              TimeZoneSidKey='America/Los_Angeles', UserName='platformuser' + i + '@testalphabetagamma.com');

    }
     
    /* --------------------------Create New Deal --------------------------  */ 
    public static List<Deal__c> CreateDeals(Integer numberOfDeals, Id titleId)
    {    
        List<Deal__c> dealList = new List<Deal__c>();
        for (Integer i = 0 ; i < numberOfDeals; i++) 
        {
        Deal__c deal = new Deal__c();
        deal.Active_Flag__c =  true;
        deal.Name = 'TestDeal' + Math.random();
        deal.Title__c = titleId;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Finance_Default_Deal__c  = true;
        deal.Primary_Deal__c = true;
        //deal.SGENNO__c = '12131';
        deal.Deal_ID__c = '11111';
        dealList.add(deal);
        }         
        return dealList;       
    }
     //create bom item
    public static Bom_Item__c createBOMItems(Id materialId, Id materialCmpId) {
        BOM_Item__c bom = new BOM_Item__c(Material__c = materialId, 
                                          Material_Component__c = materialCmpId,
                                          Item_Category__c = 'T',Bom_Status__c='Draft',Function__c='009'
                                         );
        return bom;
    }
     /* --------------------------Create New Sub label code --------------------------  */ 
    public static Sub_Label_Code__c getSubLabelCode(){
        Sub_Label_Code__c subLabelCode =  new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c = '51';
        subLabelCode.Name = 'MULTI-STUDIO';
        subLabelCode.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        return subLabelCode;
    }

}