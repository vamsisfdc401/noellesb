/*****************************************************************************************
Purpose: Common test utility class
Comments:
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/15/2018           Rakshita                 Initial Development
******************************************************************************************

*******************************************************************************************************************************************
Method Name                                                                 
*******************************************************************************************************************************************
1> CreateMaterials(Integer numberOfMaterials, String releaseId)
2> CreateReleases(Integer numberOfReleases, Id titleId)
3> CreateTitles(Integer numberOfTitles)
4> CreateSales(Integer numberOfSales, Id materialId)
5> CreatePlants(Integer numberOfPlants, Id materialId)
6> CreateClassifications(Integer numberOfClassifications, Id materialId)
7> CreateAUoMs(Integer numberOfAUoM, Id materialId)
8> CreateValuations(Integer numberOfValuations, Id materialId)

*******************************************************************************************************************************************/


@isTest
Public Class RF_TestDataFactory
{

    public static Id platformApiProfile = Label.PlatformApiProfileId;//get profile id from label to save query
    public static Id brandUserProfile = Label.BrandUserProfileId;//get profile id from label to save query
    public static Id masterDataAdminProfile = Label.Master_Data_Admin;//get profile id from label to save query
    public static Id ThirdPartyUserProfile = Label.ThirdpartyUserProfileId;//get profile id from label to save query
    
    /* --------------------------Create New User--------------------------  */    
    public static User createUser(Id profileId, Integer i) 
    {
        return new User(Alias = 'pU' + i, Email='platformuser' + i + '@testalphabetagamma.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileId,
                              TimeZoneSidKey='America/Los_Angeles', UserName='platformuser' + i + '@testalphabetagamma.com');
    }
    
	Public static void Defaulting()
    {
    	DefaultingFieldMapping__c d0 = new DefaultingFieldMapping__c();
        d0.Name = 'FieldMapping_d0';
        d0.Defaulting_Object_API__c = 'Material_Territory_Default__c';
        d0.Defaulting_Field_API__c = 'Sales_Org__c';
        d0.Transaction_Object_API__c = 'Sales__c';
        d0.Transaction_Field_API__c = 'Sales_Org__c';
        Insert d0;
        
        Material_Territory_Default__c mtd1 = new Material_Territory_Default__c();
        mtd1.Territory_Key__c = 'CDN';
        mtd1.Bwd_Cons_Period__c = '010';
        mtd1.Plant__c = 'V850 - Univ Studios HV Planning Plant';
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


    /* --------------------------Create New Material--------------------------  */    
    Public Static List<Material__c> CreateMaterials(Integer numberOfMaterials, String formatDes, String materialType, String itemType, String itemCode, String territory, String releaseId)
    {
    
        List<Material__c> materials = new List<Material__c>();
        for (Integer i = 0 ; i < numberOfMaterials; i++) 
        {
        Material__c objMaterial = new Material__c();
        objMaterial.name = 'Test Material' + Math.random();
        objMaterial.Format_Description__c = formatDes;
        objMaterial.Material_Type__c = materialType;
        objMaterial.Item_Type__c = itemType;
        objMaterial.Item_Code__c = itemCode;
        objMaterial.Territory__c = territory;
        objMaterial.Release__c = releaseId;
        objMaterial.Material_Status__c='Draft';

        materials.add(objMaterial);
        }  
        return materials;
    }
    Public Static List<Plant__c> CreatePlants1(Integer numberOfPlants, Id materialId)
    {
        List<Plant__c> plantList = new List<Plant__c>();
        for (Integer i = 0 ; i < numberOfPlants; i++) 
        {
        Plant__c plant = new Plant__c();
        plant.Material__c = materialId;
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
        plant.Purchasing_Group__c= 'PHJ';
        plant.MRP_Controller__c= 'PHJ';
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
           
        plantList.add(plant);
        }
        
        return plantList;
        
    }

        /* --------------------------Create New Release--------------------------  */         
    Public Static List<Release__c> CreateReleases(Integer numberOfReleases, Id titleId, String brandGroup, String territory, String projectType)   
    {
         List<Release__c> releases = new List<Release__c>();
         for (Integer i = 0 ; i < numberOfReleases; i++) 
         {
         Release__c objRelease = new Release__c();
         objRelease.Name = 'Test Release' + Math.random();
         objRelease.Title__c = titleId;
         objRelease.Street_Date__c = Date.Today();
         objRelease.Brand_Group__c = brandGroup;
         objRelease.Territory__c = territory;
         objRelease.Project_Type__c = projectType;
         releases.add(objRelease);
         }
         return releases;                  
    }
    
        /* --------------------------Create New Title--------------------------  */        
    Public Static List<Title__c> CreateTitles(Integer numberOfTitles)
    {
        List<Title__c> titles = new List<Title__c>();
        for (Integer i = 0 ; i < numberOfTitles; i++) 
        {
        Title__c objTitle = new Title__c();
        objTitle.Name = 'Test Title' + Math.random();
        objTitle.Active_Flag__c = True;
        objTitle.SGENNO__c='000123';
        titles.add(objTitle);
        }
        return titles;                
    }
    
    /*--------------------------Create New Sales--------------------------  */
    public Static List<Sales__c> CreateSales(Integer numberOfSales, Id materialId)
    {
        List<Sales__c> salesList = new List<Sales__c>();
        for (Integer i = 0 ; i < numberOfSales; i++) 
        {
        Sales__c sales = new Sales__c();
        sales.Material__c = materialId;
        sales.Material_Group_2__c = 'AR';
        sales.Distribution_Channel__c = '10';
        sales.Tax_Jurisdiction_Code__c ='1';
        sales.County_Sales_Tax__c = '1';
        sales.City_Sales_Tax__c ='0';
        sales.Item_Category_Group__c = 'NORM';
        sales.Sales_Org__c = 'V100 - US Home Video';
        sales.D_Chain_Spec__c = 'FR - Future Release';
        sales.Valid_From__c = Date.newInstance(2000, 01, 1);
        sales.Material_Pricing_Group__c ='D6 - Not Tracked, 33%';
        sales.Material_Group_3__c = '888 - Master Data Interface Relevant';
        sales.Material_Group_5__c = 'A - Yes-Remove shrink-Place in inventory';
        sales.GST_Canada__c = '0';
        sales.PST_Canada__c = '0';
        sales.PST_Base_GST_CDN__c = '0';
        sales.Material_Statistic_Group__c ='1 - A Material';
        sales.Territory__c ='US';
        sales.Pre_Order_Date__c = Date.newInstance(1999, 01, 1); 
        sales.Deliver_Plant__c = 'D0F7';
        sales.Tax_Indicator__c = 'Y';
        
        salesList.add(sales);
        }
        return salesList;     
    }

  /*--------------------------Create New Plant--------------------------*/  
    Public Static List<Plant__c> CreatePlants(Integer numberOfPlants, Id materialId)
    {
        List<Plant__c> plantList = new List<Plant__c>();
        for (Integer i = 0 ; i < numberOfPlants; i++) 
        {
        Plant__c plant = new Plant__c();
        plant.Material__c = materialId;
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
           
        plantList.add(plant);
        }
        return plantList;
        
    }
    
     /*--------------------------Create New Classification--------------------------  */
    Public Static List<Classification__c> CreateClassifications(Integer numberOfClassifications, Id materialId)
    {
        List<Classification__c> classificationList = new List<Classification__c>();
        for (Integer i = 0 ; i < numberOfClassifications; i++) 
        {
        Classification__c classification =  new Classification__c();
        classification.Material__c =  materialId;
        classification.Packaging_Type_US__c = '01 - Paper Sleeve';
        classificationList.add(classification);
        }
        return classificationList;
    }
        
 /*--------------------------Create New Alternative Unit of Measure--------------------------  */
    Public Static List<Alternative_Unit_of_Measure__c> CreateAUoMs(Integer numberOfAUoM, Id materialId)
    {
        List<Alternative_Unit_of_Measure__c> AUoMList = new List<Alternative_Unit_of_Measure__c>();
        for (Integer i = 0 ; i < numberOfAUoM; i++) 
        {
        Alternative_Unit_of_Measure__c auomObj = new Alternative_Unit_of_Measure__c();
        auomObj.Material__c =  materialId;
        auomObj.Additional_Default__c = True;
        AUoMList.add(auomObj);
        }
        return AUoMList;
    }
        
    /* --------------------------Create New Valuation--------------------------  */
    Public Static List<Valuation__c> CreateValuations(Integer numberOfValuations, Id materialId)
    {
        List<Valuation__c> valuationList = new List<Valuation__c>();
        for (Integer i = 0 ; i < numberOfValuations; i++) 
        {   
        Valuation__c valuation = new Valuation__c();
        valuation.Material__c = materialId;
        valuation.Valuation_Area__c = 'V000';
        valuation.Valuation_Class__c = '7930 - Finished Goods Home Video';
        valuation.Price_Unit__c = '1000'; 
        valuation.Standard_Price__c = 550;
        valuation.Origin_Group__c = '10';
        valuation.Pricing_Control__c = 'S';
        valuationList.add(valuation);
        }
        return valuationList;
    } 
   
       
    /* --------------------------Create New BOM Item--------------------------  */
    Public Static BOM_Item__c CreateBOMItems(Id materialId, Id materialCmpId)
    {
        BOM_Item__c bom = generateBOMItems(materialId, materialCmpId);
        
        Insert bom;
        return bom;
    } 
    
    public static Bom_Item__c createBOMItem(Id materialId, Id materialCmpId) 
    {
        BOM_Item__c bom = new BOM_Item__c(Material__c = materialId, 
                                          Material_Component__c = materialCmpId);
        return bom;
    } 
    
    public static Bom_Item__c generateBOMItems(Id materialId, Id materialCmpId) {
        BOM_Item__c bom = new BOM_Item__c();
        bom.Material__c = materialId;
        bom.Material_Component__c= materialCmpId;
        //bom.Item_Category__c = 'T';
        return bom;
    }
    
     /* --------------------------Create New V Project Request--------------------------  */
    Public Static v_Project_Request__c  CreatevProjectReq(Id releaseId, Id titleId)
    {
        v_Project_Request__c vProjReq = new v_Project_Request__c();
        vProjReq.Release__c = releaseId;
        vProjReq.Title__c = titleId;
        
        return vProjReq;
    }  
    
     /* --------------------------Create New V Material--------------------------  */
    Public Static List<v_Material__c> getVMaterials(Id vProjectId,Id materialId)
    {
        list<v_Material__c> vMaterialList = new list<v_Material__c>();
        // V Materials 
        v_Material__c vMaterial = new v_Material__c(v_Project__c = vProjectId);
        vMaterial.Material__c = materialId;
        vMaterialList.add(vMaterial);
        
        return vMaterialList;
    }
    
    /* --------------------------Create New Release Material--------------------------  */
    Public Static list<Release_Material__c>getReleaseMaterials(Id releaseId,Id materialId)
    {
        list<Release_Material__c>releaseMaterialsList =  new list<Release_Material__c>();
        // release materials 
        Release_Material__c releaseMaterials =  new Release_Material__c();
        releaseMaterials.Release__c =  releaseId;
        releaseMaterials.Material__c = materialId;
        releaseMaterialsList.add(releaseMaterials);
        
        return releaseMaterialsList;
    }  
    
      /* --------------------------Create New Sub label code --------------------------  */ 
    public static Sub_Label_Code__c getSubLabelCode(){
        Sub_Label_Code__c subLabelCode =  new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c = '49';
        subLabelCode.Name = 'TestsubLabelCode';
        subLabelCode.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        return subLabelCode;
    }
    
    /* --------------------------Create New Alternative legal title --------------------------  */ 
    public static Alternative_Legal_Title__c getAlternativeLegalTitle(){
        Alternative_Legal_Title__c alternative_Legal_Title = new Alternative_Legal_Title__c();
        alternative_Legal_Title.name = 'TestAlernativeLegalTitle';
        alternative_Legal_Title.Alternative_Legal_Title_ID__c = '00000007';
        return alternative_Legal_Title;
    }
    
    /* --------------------------Create New Alternative legal title --------------------------  */ 
    public static Operations_Group__c  getOperation(string operationName,string operationGroupId)
    {
        Operations_Group__c operationGroup = new Operations_Group__c(
        name = operationName,
        Operations_Group_ID__c = operationGroupId);
        return operationGroup;
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
    /************************************One test*********************/
      Public Static List<Material__c> CreateMaterial(Integer numberOfMaterials, String formatDes, String materialType, String itemType, String itemCode, String territory)
    {
    
        List<Material__c> materials = new List<Material__c>();
        for (Integer i = 0 ; i < numberOfMaterials; i++) 
        {
        Material__c objMaterial = new Material__c();
        objMaterial.name = 'Test Material' + Math.random();
        objMaterial.Format_Description__c = formatDes;
        objMaterial.Material_Type__c = materialType;
        objMaterial.Item_Type__c = itemType;
        objMaterial.Item_Code__c = itemCode;
        objMaterial.Territory__c = territory;
        materials.add(objMaterial);
        }
        return materials;
    
    }
   
}