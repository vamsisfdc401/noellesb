/*****************************************************************************************
Class Name: ReleaseMaterialBulkApprovalHandlerTest
Purpose: Test class for apex class  ReleaseMaterialBulkApprovalHandler Controller
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/

@isTest
public class ReleaseMaterialBulkApprovalHandlerTest{
    @isTest
    static void testMethod_1()
    {    
        List<Material__c>matList=new List<Material__c>();
        List<Bom_item__c>bomItemList=new List<Bom_item__c>();
        
        
        Title__c title=testClassUtility.createTitle('Test Title_REL_METH1',true);
        title.SGENNO__c='000123';
        insert title;       
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Sub_Label_Code__c subLabelCode= new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c ='testdataid';
        insert subLabelCode;
        
        Alternative_Legal_Title__c altLegalTitle= new Alternative_Legal_Title__c();
        altLegalTitle.Alternative_Legal_Title_ID__c=title.id;
        insert altLegalTitle;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy2','FERT',release.id,TRUE,'M (Multipack)','CL - COLLECTION PACK');
        material1.Label_Code__c ='24 - PURE FLIX';
        material1.Street_Date__c =system.today(); 
        material1.Base_Unit_of_Measure__c  ='EA'; 
        material1.Material_Group__c='24112505 - Freight & Shipping - Pallet'; 
        material1.Weight_Unit__c ='G - Gram'; 
        material1.Create_Version__c =false; 
        material1.X_Dchain_Status__c ='te';
        material1.X_Dchain_Valid_From__c =system.today();
        material1.Purchase_Value_Key__c ='te'; 
        material1.Transportation_Group__c    ='te';
        material1.Plant__c ='t'; 
        material1.Xplant_Valid_From__c=system.today();       
        material1.Technical_Format__c ='01 - FULL FRAME';        
        material1.Sub_Label_Code_Lookup__c=subLabelCode.id; 
        material1.General_Item_Category_Group__c='SAMM - Generic material'; 
        material1.Division__c ='t'; 
        material1.Xplant_Material_Status__c='t';    
        material1.Gross_Weight__c =2; 
        material1.Net_Weight__c =2; 
        material1.Alternative_Legal_Title_Lookup__c =altLegalTitle.id;   
        material1.Layer__c ='t';  
        material1.Valid_From__c = system.today();       
        material1.TM_Status__c='03 - PENDING';
        material1.Industry_Sector__c ='t'; 
        material1.BOM_Usage__c='t'; 
        material1.BOM_Category__c='t';   
        material1.Territory__c = 'US'; 
        material1.material_status__c='Draft';
        material1.Material_Type__c='FERT';
        material1.release__c=release.id;
        matList.add(material1) ;               

        
        Material__c objCompMaterial = new Material__c(name='dummy22',Material_Type__c= 'ROH');
        objCompMaterial.Material_Status__c='Draft'; 
        objCompMaterial.Deletion_Flag__c=false;
        objCompMaterial.Item_Type__c = 'C - Components';
        objCompMaterial.Item_Code__c = 'RG - REGIE STICKER'; 
        matList.add(objCompMaterial);
        
        insert matList;
        
        Release_Material__c releaseMaterial1 = testClassUtility.getReleaseMat(release.id,material1.Id);
        Release_Material__c releaseMaterial2 = testClassUtility.getReleaseMat(release.id,objCompMaterial.Id);
        List<Release_Material__c> releaseMatList = new List<Release_Material__c>{releaseMaterial1,releaseMaterial2};
        insert releaseMatList;
        Test.startTest();     
       BOM_Item__c b = new BOM_Item__c();
       
       b.Material__c = objCompMaterial.Id;   
       b.Material_Component__C= material1.Id;
       
       b.Item_Category__c='N';
       b.Valid_From__c= system.today();
       b.Production_Flag__c = true;
       b.Component_Quantity__c='2';
       bomItemList.add(b);

       
       BOM_Item__c b1 = new BOM_Item__c();
       b1.Material__c = material1.Id;
       b1.Material_Component__C= objCompMaterial.Id;
       b1.Item_Category__c='N';
       b1.Valid_From__c= system.today();
       b1.Production_Flag__c = true;
       b1.Component_Quantity__c='2';
       bomItemList.add(b1);
       
       insert bomItemList;
       
       // added on 30.12
       Valuation__c valuation = testClassUtility.getValuations(material1);
       insert valuation;
        
       Plant__c plant = testClassUtility.getPlants(material1);
       insert plant ;
        
       Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
       insert operationGroup;
        
       Sales__c sales = testClassUtility.getSales(material1,operationGroup);
       insert sales;
       
       
       Classification__c classification = new Classification__c();
       classification.Material__c= material1.id;
       classification.Packaging_Type_US__c='09 - Box';
       classification.RecordTypeId=Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Components').getRecordTypeId();
       insert classification;
      
       
           ReleaseMaterialBulkApprovalHandler.checkMultipack(release.id);
           ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(release.id);
           ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(release.id);
       Test.stoptest();     
    }
    
    @isTest
    static void testMethod_2()
    {    
        List<Material__c>matList=new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title_REL_METH2',true);
        title.SGENNO__c='000123';
        insert title; 
      
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        
        Release__c release=testClassUtility.createRelease('Test Release1','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Sub_Label_Code__c subLabelCode= new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c ='testdataid';
        insert subLabelCode;
        
        Alternative_Legal_Title__c altLegalTitle= new Alternative_Legal_Title__c();
        altLegalTitle.Alternative_Legal_Title_ID__c=title.id;
        insert altLegalTitle;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Label_Code__c='61 - Universal Pictures';
        material1.Street_Date__c =system.today(); 
        material1.Base_Unit_of_Measure__c  ='EA'; 
        material1.Material_Group__c='24112505 - Freight & Shipping - Pallet'; 
        material1.Weight_Unit__c ='G - Gram'; 
        material1.Create_Version__c =false; 
        material1.X_Dchain_Status__c ='te';
        material1.X_Dchain_Valid_From__c =system.today();
        material1.Purchase_Value_Key__c ='te'; 
        material1.Transportation_Group__c    ='te';
        material1.Plant__c ='t'; 
        material1.Xplant_Valid_From__c=system.today();       
        material1.Technical_Format__c ='01 - FULL FRAME';        
        material1.Sub_Label_Code_Lookup__c=subLabelCode.id; 
        material1.General_Item_Category_Group__c='SAMM - Generic material'; 
        material1.Division__c ='t'; 
        material1.Xplant_Material_Status__c='t';    
        material1.Gross_Weight__c =2; 
        material1.Net_Weight__c =2; 
        material1.Alternative_Legal_Title_Lookup__c =altLegalTitle.id;   
        material1.Layer__c ='t';  
        material1.Valid_From__c = system.today();       
        material1.Title__c=title.id; 
        material1.deal__c = deal.id;
        material1.TM_Status__c='03 - PENDING';
        material1.Industry_Sector__c ='t'; 
        material1.BOM_Usage__c='t'; 
        material1.BOM_Category__c='t';   
        material1.Territory__c = 'US';
        material1.material_status__c='Draft';
        material1.Material_Description_Unique__c='TestRelease1/Dummy';
        matList.add(material1) ;               
        
        Material__c objCompMaterial = new Material__c(name='dummy22',Material_Type__c= 'ROH');
        objCompMaterial.Material_Status__c='Draft'; 
        objCompMaterial.Deletion_Flag__c=false;
        objCompMaterial.Item_Type__c = 'C - Components';
        objCompMaterial.Item_Code__c = 'RG - REGIE STICKER'; 
        objCompMaterial.Label_Code__c='61 - Universal Pictures';
        matList.add(objCompMaterial);
        
        insert matList;
        
        Release_Material__c releaseMaterial= new Release_Material__c();
        releaseMaterial.Material__c=material1.id;
        releaseMaterial.Release__c= release.id;
        insert releaseMaterial;       
             
       BOM_Item__c b = new BOM_Item__c();
       b.Material__c = material1.Id;
       b.Material_Component__C= objCompMaterial.Id;
       b.Item_Category__c='N';
       b.Valid_From__c= system.today();
       b.Production_Flag__c = true;
       b.Component_Quantity__c='2';
       TriggerUtility.doNotExecute = True;
       Insert b;
       TriggerUtility.doNotExecute = False;
              // added on 30.12
       Valuation__c valuation = testClassUtility.getValuations(material1);
       insert valuation;
        
       Plant__c plant = testClassUtility.getPlants(material1);
       insert plant ;
        
       Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
       insert operationGroup;
        
       Sales__c sales = testClassUtility.getSales(material1,operationGroup);
       Test.startTest();
       insert sales;
       
       
        ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(release.id);
       Test.stopTest();
    }
    
    private static testMethod void testNonFertMaterial(){
        list<Material__c>materialList =  new List<Material__c>();
        list<Plant__c>plantList=new List<Plant__c>();
        list<Classification__c>classificationList=new List<Classification__c>();
        list<Valuation__c>valuationList=new List<Valuation__c>();
        list<Sales__c>salesList=new List<Sales__c>();
        list<release_Material__c>releaseMatList=new List<release_Material__c>();

        
        // title details
        Title__c title=testClassUtility.createTitle('Test Title_ForNONFERT1',true);
        title.SGENNO__c='000123';
        insert title;
        // deal details 
        Deal__c dealDetails=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title.id,SGENNO__c=Title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert dealDetails;
        
        // sub label code details
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        // alternative legal title details
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // release details
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
       
       
        // materials details
        Material__c material1 = testClassUtility.createMaterial('13 - HD VOD','DVD','dummy98','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        
        
        material1 = testClassUtility.getMaterialDetails(material1,title,sub_Label_Code,alternativeLegalTitle,dealDetails);
        
        
        Material__c materialComponent = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTCOMPONENT','ROH',release.id,TRUE,'C - Components','PG - PACKAGING');
        materialComponent = testClassUtility.getMaterialDetails(materialComponent,title,sub_Label_Code,alternativeLegalTitle,dealDetails);


        materialList.add(material1);
        materialList.add(materialComponent);
        insert materialList;
        
        Valuation__c valuation1 = testClassUtility.getValuations(material1);
        Valuation__c valuation2 = testClassUtility.getValuations(materialComponent);
        valuationList.add(valuation1);
        valuationList.add(valuation2);
        insert valuationList;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        Plant__c plant1 = testClassUtility.getPlants(materialComponent);
        plantList.add(plant);
        plantList.add(plant1);
        insert plantList;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        Bom_item__c bomItem = getBOMItems(material1,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        TriggerUtility.doNotExecute = True;
        insert bomItem;
        TriggerUtility.doNotExecute = False;
        
        Release_Material__c relMat1=testClassUtility.getReleaseMat(release.id,material1.id);
        Release_Material__c relMat2=testClassUtility.getReleaseMat(release.id,materialComponent.Id);
        releaseMatList.add(relMat1);
        releaseMatList.add(relMat2);
        insert releaseMatList;
        
        Test.startTest();
        ReleaseMaterialBulkApprovalHandler.checkMultipack(release.id);
        ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(release.id);
            ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(release.id);
        Test.stopTest();
        
    }
    
    private static Bom_item__c getBOMItems(Material__c material1,string componentNumber,integer bomQuantity,string componentQuantity, boolean isProductionFlag,Date validFrom,string itemCategory){
        Bom_item__c bomItem = new Bom_item__c(Material__c=material1.id,Component_Number__c=componentNumber,BOM_Quantity__c=bomQuantity,Component_Quantity__c=componentQuantity,Production_Flag__c=isProductionFlag,Valid_From__c=validFrom,Item_Category__c=itemCategory);
        
        return bomItem;
    }
  
      private static testMethod void testNonFertMaterial1(){
          list<Material__c>materialList =  new List<Material__c>();
        list<Plant__c>plantList=new List<Plant__c>();
        list<Classification__c>classificationList=new List<Classification__c>();
        list<Valuation__c>valuationList=new List<Valuation__c>();
        list<Sales__c>salesList=new List<Sales__c>();
        list<release_Material__c>releaseMatList=new List<release_Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title_ForNonFert',true);
        title.SGENNO__c='000123';
        insert title;
        
         // deal details 
        Deal__c dealDetails=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title.id,SGENNO__c=Title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert dealDetails;
               
        // sub label code details
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        // alternative legal title details
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // release details
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        // materials details
        Material__c material1 = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTCOMPONENT','ROH',release.id,TRUE,'C - Components','PG - PACKAGING');
        material1 = testClassUtility.getMaterialDetails(material1,title,sub_Label_Code,alternativeLegalTitle,dealDetails);
        
        materialList.add(material1);
        insert materialList;
        
        Valuation__c valuation1 = testClassUtility.getValuations(material1);
        valuationList.add(valuation1);
        insert valuationList;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        plantList.add(plant);
        insert plantList;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        
        Release_Material__c relMat1=testClassUtility.getReleaseMat(release.id,material1.id);
        releaseMatList.add(relMat1);
        insert releaseMatList;
        
        Test.startTest();
        ReleaseMaterialBulkApprovalHandler.checkMultipack(release.id);
        ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(release.id);
            ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(release.id);
        Test.stopTest();

        
      }
      
      
      private static testMethod void testMaterialforMultipack(){
        
        List<Material__c> materialList=  new List<Material__c>();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title_ForMulti',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // materials details
        Material__c materialItem =  getMaterialDetails('M (Multipack)','ME - TV MULTIPLE EPISODES',release.id,'08 - EST (ELECTRONIC SELL THRU)','ROH');
        
        materialItem.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        materialItem.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        materialItem.Label_Code__c ='24 - PURE FLIX';


        materialList.add(materialItem);
        TriggerUtility.doNotExecute = TRUE;
        insert materialList;
        TriggerUtility.doNotExecute = FALSE;
        
        Release_Material__c releaseMaterial = testClassUtility.getReleaseMat(release.id,materialItem.Id);
        insert releaseMaterial;
        
        Valuation__c valuation = testClassUtility.getValuations(materialItem);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(materialItem);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        plant.Additional_Default__c = true;
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(materialItem,operationGroup);
        insert sales;
        
        
        // component material data
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.BOM_Quantity__c = 1;
        materialComponent.Prior_BOM_Quantity__c = '011';
        insert materialComponent;
        
        Bom_item__c bomItem = getBOMItems(materialItem,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        insert bomItem;
        
        Test.startTest();
            
                    List<Material__c>materialDataToProcess = [Select id,Release__r.Id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where Release__c = :release.id];
             ReleaseMaterialBulkApprovalHandler.checkMultipack(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(materialDataToProcess[0].release__r.id); 
                   
        
        Test.stopTest();
        
        
        
    }
    
    private static testMethod void testMaterialforFERTDiplayVechicle(){
        
        List<Material__c> materialList=  new List<Material__c>();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title_ForFertD',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // materials details
        Material__c materialItem =  getMaterialDetails('D (Display Vehicle)','ME - TV MULTIPLE EPISODES',release.id,'08 - EST (ELECTRONIC SELL THRU)','FERT');
        
        materialItem.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        materialItem.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        materialItem.Label_Code__c ='24 - PURE FLIX';
        materialItem.Street_Date__c =  system.TODAY();

        materialList.add(materialItem);
        TriggerUtility.doNotExecute = True;
        insert materialList;
        TriggerUtility.doNotExecute = False;
        
        Valuation__c valuation = testClassUtility.getValuations(materialItem);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(materialItem);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        plant.Additional_Default__c = true;
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(materialItem,operationGroup);
        insert sales;
        
        Release_Material__c releaseMaterial = testClassUtility.getReleaseMat(release.id,materialItem.Id);
        insert releaseMaterial;
        
        
        // component material data
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.BOM_Quantity__c = 1;
        materialComponent.Prior_BOM_Quantity__c = '011';
        materialComponent.Street_Date__c =  system.TODAY();
        insert materialComponent;
        
        
        Bom_item__c bomItem = getBOMItems(materialComponent,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialItem.Id;
        insert bomItem;

        Test.startTest();
            List<Material__c>materialDataToProcess = [Select id,Release__r.Id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where Release__c = :release.id];
                          
                        
                        
             ReleaseMaterialBulkApprovalHandler.checkMultipack(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(materialDataToProcess[0].release__r.id);
        
        
        Test.stopTest();
        
        
        
    }
    
    private static testMethod void testMaterialforFERTItemTypeSingle(){
        
        List<Material__c> materialList=  new List<Material__c>();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title_ForFERT',true);
        title.SGENNO__c='000123';
        insert title;
         // deal details 
        Deal__c dealDetails=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=Title.id,SGENNO__c=Title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert dealDetails;
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // materials details''
        Material__c materialItem =  getMaterialDetails('S (Single)','SS - SINGLE SELECTION',release.id,'08 - EST (ELECTRONIC SELL THRU)','FERT');
        
        materialItem.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        materialItem.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        materialItem.Label_Code__c='61 - Universal Pictures';
        materialItem.Title__c=title.id; 
        materialItem.deal__c=dealDetails.id; 
        materialList.add(materialItem);
        TriggerUtility.doNotExecute = TRUE;
        insert materialList;
        TriggerUtility.doNotExecute = FALSE;
        
        Valuation__c valuation = testClassUtility.getValuations(materialItem);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(materialItem);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        plant.Additional_Default__c = true;
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(materialItem,operationGroup);
        insert sales;
        
        Release_Material__c releaseMaterial = testClassUtility.getReleaseMat(release.id,materialItem.Id);
        insert releaseMaterial;
        
        
        // component material data
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.BOM_Quantity__c = 1;
        materialComponent.Prior_BOM_Quantity__c = '011';
        insert materialComponent;
        
        
        Bom_item__c bomItem = getBOMItems(materialItem,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        TriggerUtility.doNotExecute = True;
        insert bomItem;
        TriggerUtility.doNotExecute = False;

        Test.startTest();
        List<Material__c>materialDataToProcess = [Select id,Release__r.Id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where Release__c = :release.id];
             ReleaseMaterialBulkApprovalHandler.checkMultipack(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(materialDataToProcess[0].release__r.id); 
        
        
        Test.stopTest();
        
        
        
    }
    
    public static Release__c createRelease(String name,String brandGroup,String projectType,String releaseStatus){
         Release__c objRelease = new Release__c();
         objRelease.Internal_Announce_Date__c=Date.Today()-3;
         objRelease.Street_Date__c=Date.Today();
         objRelease.EST_Date__c=Date.Today();
         objRelease.Name=name;
         objRelease.Brand_Group__c=brandGroup;
         objRelease.Project_Type__c=projectType;
         objRelease.Release_Status__c=releaseStatus;
         
         return objRelease;
    }
    
    
    
    // create dummy data
    private static Release__c createData(){
        // Preparing Data setup
        
        Release__c release=createRelease('Test Release','Family','New Release Mattel','Materials Not Requested');
        insert release;
        
        
        return release;
    }
    
    public static testMethod void testOverallFunctionality(){
        Release__c releaseRrd = createData();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;

        
        // HOLDS MATERIAL DETAILS 
        List<Material__c> materialList = new List<Material__c>();
        
        // FERT materal details 
        Material__c material1=getMaterialDetails('M (Multipack)','CL - COLLECTION PACK',releaseRrd.id,'DVD','FERT');
        
        material1.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        material1.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        material1.Label_Code__c ='24 - PURE FLIX';
        
        // display vechicle details
        Material__c material3 = getMaterialDetails('D (Display Vehicle)','CS - CLIP STRIP',releaseRrd.id,'BD','FERT');
        material3.Format_Description__c = 'BD';
        material3.name = 'dummy2';
        
        material3.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        material3.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        material3.Label_Code__c ='24 - PURE FLIX';
        
        // single and est electionic sell details 
        Material__c material4 = getMaterialDetails('S (Single)','SS - SINGLE SELECTION',releaseRrd.id,'08 - EST (ELECTRONIC SELL THRU)','FERT');
        material4.Format_Description__c = 'EST (ELECTRONIC SELL THRU)';
        material4.name = 'dummy4';
        
        material4.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        material4.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        material4.Label_Code__c ='24 - PURE FLIX';
        
        
        materialList.add(material1);
        materialList.add(material3);
        materialList.add(material4);
        
        insert materialList;
        
        // holds bom items details which connects materials
        List<Bom_item__c> bomItemList = new List<Bom_item__c>();
        
        Bom_item__c bomItem1 = getBOMItems(material1,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem1.Material_Component__c  = material3.Id;

        
        Bom_item__c bomItem2 = getBOMItems(material1,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem2.Material_Component__c  = material4.Id;

        bomItemList.add(bomItem1);
        bomItemList.add(bomItem2);
        
        insert bomItemList;
        
        Test.startTest();
            List<Material__c>materialDataToProcess = [Select id,Release__r.Id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where Release__c = :releaseRrd.id];
             ReleaseMaterialBulkApprovalHandler.checkMultipack(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkDisplayVehicle(materialDataToProcess[0].release__r.id);
             ReleaseMaterialBulkApprovalHandler.checkSAPFieldsComplete(materialDataToProcess[0].release__r.id); 
        Test.stopTest();
    }
    
    
    
    private static Material__c getMaterialDetails(String itemType,string itemCode,ID releaseId,string format,string materialType){
        // materials details
        Material__c material1 = testClassUtility.createMaterial(format,'DVD','dummy98',materialType,releaseId,TRUE,itemType,itemCode);
        // component material data

        material1.Deletion_Flag__c = false;
        material1.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);
        material1.Purchase_Value_Key__c = '0000';
        material1.Transportation_Group__c = '0001';
        material1.Plant__c = 'V000';
        material1.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);
        material1.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
       
        material1.General_Item_Category_Group__c ='NORM - Standard item / CU';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        material1.Gross_Weight__c = 0.25;
        material1.Net_Weight__c = 0.151;
       
        material1.Valid_From__c = Date.newInstance(2016,9,07);
        material1.Industry_Sector__c = 'Z';
        material1.BOM_Usage__c = '3';
        material1.BOM_Category__c = 'M';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        material1.Weight_Unit__c = 'LB - US pound';
        material1.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        material1.Create_Version__c = true;
        material1.X_Dchain_Status__c = 'AA';
        material1.Base_Unit_of_Measure__c = 'EA';
        material1.Pre_Order_Close_Date__c = Date.newInstance(2013,05,08);
        material1.Street_Date__c = Date.newInstance(2013,05,08);
        if (itemType == 'D (Display Vehicle)')
            material1.Territory__c = 'US';
        else
            material1.Territory__c = 'US & CDN';
        material1.TM_Status__c='03 - PENDING';
        return material1;
    }
 }