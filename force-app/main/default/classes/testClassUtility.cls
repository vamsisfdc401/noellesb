/*****************************************************************************************
Class Name: testClassUtility
Purpose: Utility class for all the test classes for record creation.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/08/2016           Suman Kundu              Initial Development
******************************************************************************************/
public class testClassUtility{
    
    /************************************
    Method Name: createTitle
    Purpose: instance of Title will be created and returns 
    *************************************/
        
    public static Title__c createTitle(String name,Boolean active)
    {
        Title__c objTitle=new Title__c();
        objTitle.Name=name;
        objTitle.Active_Flag__c=active;
        return objTitle;
        
    }
    
    /************************************
    Method Name: createRelease
    Purpose: instance of release will be created and returns 
    *************************************/
    
    public static Release__c createRelease(String name,String brandGroup,String projectType,String releaseStatus,id titleId){
         Release__c objRelease = new Release__c();
         objRelease.Internal_Announce_Date__c=Date.Today()-3;
         objRelease.Street_Date__c=Date.Today();
         objRelease.EST_Date__c=Date.Today();
         objRelease.Name=name;
         objRelease.Brand_Group__c=brandGroup;
         objRelease.Project_Type__c=projectType;
         objRelease.Release_Status__c=releaseStatus;
         objRelease.Title__c=titleId;
         
         return objRelease;
    }
   
   	/************************************
    Method Name: createMaterial
    Purpose:  materials mininum required fields  created and returns 
    *************************************/
   
    public static Material__c createMaterial(String format,String Fdescription,String name,String materialtype,String releaseid,Boolean association,String itemType,String itemCode){
        Material__c objMaterial = new Material__c();
        objMaterial.Format__c=format;
        objMaterial.Format_Description__c=Fdescription;
        objMaterial.name=name;
        objMaterial.Material_Type__c=materialtype;
        objMaterial.Release__c=releaseid;
        objMaterial.Association_Required__c=association;
        objMaterial.Item_Type__c=itemType;
        objMaterial.Item_Code__c=itemCode;
        objMaterial.Material_Status__c='Draft';
        
        return objMaterial;
    }
    
    
   	/************************************
    Method Name: MaterialDetails
    Purpose:   materials almost all fields with certain default values created and returns 
    *************************************/
    
    // materials extra field  
    public static Material__c getMaterialDetails(Material__c materialItem,Title__c titleItem,Sub_Label_Code__c subLabelCode,Alternative_Legal_Title__c alternativeLegalTitle,Deal__c dealDetail){
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
        materialItem.Pre_Order_Close_Date__c = Date.newInstance(2013,05,08);
        materialItem.Product_Class__c ='00';
        materialItem.Title_Source__c = '01 - THEATRICAL';
        //materialItem.Deal_ID__c = 'TestDealID';
        materialItem.Deal__c = dealDetail.Id;
        //materialItem.Format_Description__c = 'DVD';
        return materialItem;
    }
    
    // sub label code details
    public static Sub_Label_Code__c getSubLabelCode(){
        Sub_Label_Code__c subLabelCode =  new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c = '49';
        subLabelCode.Name = 'TestsubLabelCode';
        subLabelCode.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        return subLabelCode;
    }
    
    // alternative legal title details
    public static Alternative_Legal_Title__c getAlternativeLegalTitle(){
        Alternative_Legal_Title__c alternative_Legal_Title = new Alternative_Legal_Title__c();
        alternative_Legal_Title.name = 'TestAlernativeLegalTitle';
        alternative_Legal_Title.Alternative_Legal_Title_ID__c = '00000007';
        //alternativeLegalTitle.Alternative_Legal_Title_ID_Number__c = '7';
        return alternative_Legal_Title;
    }
    
    // fetch valuation details 
    public static Valuation__c getValuations(Material__c material){
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
    public static Plant__c getPlants(Material__c material){
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
    public static Sales__c getSales(Material__c material,Operations_Group__c oppGroup){
        Sales__c sales = new Sales__c();
        sales.Material__c = material.Id;
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
        sales.Operations_Group__c = oppGroup.id;
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
        
        return sales;    
    }
       
    
    // operation group data 
    public static Operations_Group__c getOperation(string operationName,string operationGroupId){
        Operations_Group__c operationGroup = new Operations_Group__c(name = operationName,Operations_Group_ID__c =operationGroupId);
        return operationGroup;
    }
    
    // deal details 
    public static Deal__c getDeal(Title__c title){
        Deal__c deal = new Deal__c();
        deal.Active_Flag__c =  true;
        deal.Name = 'TestDeal';
        deal.Title__c = title.ID;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Finance_Default_Deal__c  = true;
        deal.Primary_Deal__c = true;
        deal.SGENNO__c = '12131';
        deal.Deal_ID__c = '11111';
        return deal;        
    }
    // classification details created and returned 
    public static Classification__c getClassifications(Material__c material){
        Classification__c classification =  new Classification__c();
        classification.Material__c =  material.id;
        classification.Packaging_Type_US__c = '01 - Paper Sleeve';
        return classification;
    }
    // release material details created and return
     public static Release_Material__c getReleaseMat(Id releaseId,Id materialId){
         Release_Material__c releaseMat=new Release_Material__c();
         releaseMat.Release__c=releaseId;
         releaseMat.Material__c=materialId;
         return releaseMat;

     }
}