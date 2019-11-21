/*****************************************************************************************
Class Name: ReleaseCloningControllerTest
Purpose: Test class for apex class ReleaseCloningController 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class ReleaseCloningControllerTest{
    
    @isTest
    static void scenario1(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='US');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Material__c objMaterial2 = new Material__c(name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial2;
        
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial.Id);
        insert rm;
        
        Release_Material__c rm2 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial2.Id);
        insert rm2;

        BOM_Item__c boi = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial2.Id);
        insert boi;
        
        
         // 19.12 added 
        //Release__c parentRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='CDN',Release__c = objRelease.id,Label_Code__c='12 - Nelvana');
        //insert parentRelease;
        
        Test.startTest();
        /**** Setting Page Reference ****/
        
          PageReference pageRef = Page.ReleaseCloning;
          pageRef.getParameters().put('recordId',objRelease.Id);
          pageRef.getParameters().put('retURL',objRelease.Id);
          Test.setCurrentPage(pageRef);
            
        /**** Constructing Controller Instance ****/
          ReleaseCloningController extController = new ReleaseCloningController();
          extController.useExistingReleaseFlag = 'CreateNewRelease' ;
          extController.createNew = TRUE ;
          extController.showReleasePanel();
  
          extController.save();
          extController.save2();
          Test.stopTest();
                
    }
    
    @isTest
    static void scenario2(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
             
        test.startTest();          
        /**** Setting Page Reference ****/
        
          PageReference pageRef = Page.ReleaseCloning;
          pageRef.getParameters().put('recordId',objMaterial.Id);
          pageRef.getParameters().put('retURL',objMaterial.Id);
          Test.setCurrentPage(pageRef);
            
        /**** Constructing Controller Instance ****/
          ReleaseCloningController extController = new ReleaseCloningController();
          extController.useExistingReleaseFlag = 'CreateNewRelease' ;
          extController.createNew = TRUE ;
          extController.showReleasePanel(); 
          extController.newRelease.name = '1234' ;
          extController.save();
          extController.cancel();
          test.stopTest();
                
    }
    
    @isTest
    static void scenario3(){
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='US',Title__c = title.id);
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
         
        Material__c objMaterial2 = new Material__c(name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial2;
        
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial.Id);
        insert rm;
        
        Release_Material__c rm2 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial2.Id);
        insert rm2;

        BOM_Item__c boi = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial2.Id);
        insert boi;
        
        
         // 19.12 added 
        //Release__c parentRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='CDN',Release__c = objRelease.id,Label_Code__c='12 - Nelvana');
        //insert parentRelease;

        
        Title__c title1=testClassUtility.createTitle('Test Title1',true);
        title1.SGENNO__c='000122';
        insert title1;
        
        
        
        Test.startTest();
          MaterialComponentWrapper materialComponentWrap = new MaterialComponentWrapper(null,null);
          list<MaterialComponentWrapper>listMaterialComponentWrap = new list<MaterialComponentWrapper>{materialComponentWrap};
          
          MaterialComponentWrapper childMaterialComponentWrap = new MaterialComponentWrapper(null,null);
          list<MaterialComponentWrapper>childListMaterialComponentWrap = new list<MaterialComponentWrapper>{childMaterialComponentWrap};   
              
          MaterialFERTWrapper childfertWrapper =  new MaterialFERTWrapper(title1.Id,title1.SGENNO__c,null); 
          childfertWrapper.childComponents = childListMaterialComponentWrap;
          List<MaterialFERTWrapper>childWrapperList = new list<MaterialFERTWrapper>{childfertWrapper};
          
        
          MaterialFERTWrapper fertWrapper =  new MaterialFERTWrapper(title.Id,title.SGENNO__c,null);
          fertWrapper.childComponents = listMaterialComponentWrap;
          fertWrapper.childFERTs = childWrapperList;
          List<MaterialFERTWrapper>fertWrapperList = new list<MaterialFERTWrapper>{fertWrapper};
           
        
        /**** Setting Page Reference ****/
        
          PageReference pageRef = Page.ReleaseCloning;
          pageRef.getParameters().put('recordId',objRelease.Id);
          pageRef.getParameters().put('retURL',objRelease.Id);
          Test.setCurrentPage(pageRef);
            
        /**** Constructing Controller Instance ****/
          ReleaseCloningController extController = new ReleaseCloningController();
          extController.useExistingReleaseFlag = 'CreateNewRelease' ;
          extController.createNew = TRUE ;
          extController.showReleasePanel();
          List<SelectOption> actionsOption = extController.getAction();
          extController.save();
          Test.stopTest();
                 
    }
    
    private static testMethod void checkNullValues(){
        
        
        Test.startTest();
        /**** Setting Page Reference ****/
          PageReference pageRef = Page.ReleaseCloning;
          //pageRef.getParameters().put('recordId',objRelease.Id);
          //pageRef.getParameters().put('retURL',objRelease.Id);
          Test.setCurrentPage(pageRef);
            
        /**** Constructing Controller Instance ****/
          ReleaseCloningController extController = new ReleaseCloningController();
          //extController.useExistingReleaseFlag = 'CreateNewRelease' ;
          //extController.createNew = TRUE ;
          //extController.showReleasePanel();
          //List<SelectOption> actionsOption = extController.getAction();
          extController.save();
        Test.stopTest();
    }
    
    // release instance  
    public static Release__c createRelease(String name,String brandGroup,String projectType,String releaseStatus){
         Release__c objRelease = new Release__c();
         objRelease.Internal_Announce_Date__c=Date.Today()-3;
         objRelease.Street_Date__c=Date.Today();
         objRelease.EST_Date__c=Date.Today();
         objRelease.Name=name;
         objRelease.Brand_Group__c=brandGroup;
         objRelease.Project_Type__c=projectType;
         objRelease.Release_Status__c=releaseStatus;
         //objRelease.Title__c=titleId;
         
         return objRelease;
    }
    
    
    // create dummy data
    private static Release__c createReleaseData(){
        // Preparing Data setup
                
        Release__c release=createRelease('Test Release','Family','New Release Mattel','Materials Not Requested');
        release.Territory__c='US';
        insert release;
        return release;
    }
    
    private static Bom_item__c getBOMItems(Material__c material1,string componentNumber,integer bomQuantity,string componentQuantity, boolean isProductionFlag,Date validFrom,string itemCategory){
        Bom_item__c bomItem = new Bom_item__c(Material__c=material1.id,Component_Number__c=componentNumber,BOM_Quantity__c=bomQuantity,Component_Quantity__c=componentQuantity,Production_Flag__c=isProductionFlag,Valid_From__c=validFrom,Item_Category__c=itemCategory);
        
        return bomItem;
    }
    
    private static testMethod void testReleaseSaveFunctionality(){
        Release__c releaseRrd =  createReleaseData();
        
        // HOLDS MATERIAL DETAILS 
        List<Material__c> materialList = new List<Material__c>();
        
        // FERT materal details 
        //Material__c material1=getMaterialDetails('M (Multipack)','CL - COLLECTION PACK',releaseRrd.id,'DVD','FERT');
        
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',releaseRrd.id,TRUE,'M (Multipack)','MT - MULTI-TITLE'); 
        material1.Territory__c = 'US';
        
        Material__c material2 = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','dummy2','ROH',releaseRrd.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material2.Territory__c = 'US';
        
        Material__c material3 = testClassUtility.createMaterial('09 - BLU-RAY','BD','dummy3','FERT',releaseRrd.id,TRUE,'S (Single)','SS - SINGLE SELECTION'); 
        material3.Territory__c = 'US';
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
                
        insert materialList;
        
        // holds bom items details which connects materials
        List<Bom_item__c> bomItemList = new List<Bom_item__c>();
        
        Bom_item__c bomItem1 = getBOMItems(material1,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem1.Material_Component__c  = material2.Id;
        //insert bomItem1;
        
        Bom_item__c bomItem2 = getBOMItems(material1,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem2.Material_Component__c  = material3.Id;
        insert bomItem2;
        
        //Bom_item__c bomItem = getBOMItems(materialItem,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        //bomItem.Material_Component__c  = materialComponent.Id;
        //insert bomItem;
        bomItemList.add(bomItem1);
       // bomItemList.add(bomItem2);
        
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
            
        
        
            /**** Setting Page Reference ****/
          PageReference pageRef = Page.ReleaseCloning;
          Test.setCurrentPage(pageRef);
          pageRef.getParameters().put('recordId',materialDataToProcess[0].Release__r.Id);
          //pageRef.getParameters().put('retURL',objRelease.Id);
            
            /**** Constructing Controller Instance ****/
          ReleaseCloningController controller = new ReleaseCloningController();
          controller.newRelease.Territory__c = 'CDN';
          controller.save();
          controller.save2();
        Test.stopTest();
    }
    
    
    private static Material__c getMaterialDetails(){
        Release__c releaseRrd = createReleaseData();
        Material__c material = testClassUtility.createMaterial('09 - BLU-RAY','BD','dummy3','FERT',releaseRrd.id,TRUE,'S (Single)','SS - SINGLE SELECTION'); 
        return material;
    }
    
    
    private static testMethod void testStandaloneMaterialFunction(){
        
        Material__c materialDetails =  getMaterialDetails();
        materialDetails.Territory__c = 'US';
        insert materialDetails;
        
        
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
                            from Material__c where Id = :materialDetails.id];
                
            
            
                /**** Setting Page Reference ****/
              PageReference pageRef = Page.ReleaseCloning;
              Test.setCurrentPage(pageRef);
              pageRef.getParameters().put('recordId',materialDataToProcess[0].Id);
              //pageRef.getParameters().put('retURL',objRelease.Id);
                
                /**** Constructing Controller Instance ****/
              ReleaseCloningController controller = new ReleaseCloningController();
              controller.createStandAloneMaterial =  true;
              controller.save();
        Test.stopTest();
    }
    
    @isTest
    static void scenario4(){
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        List<Release__c> insRelList = new List<Release__c>();
        Release__c objRelease = new Release__c(Name='Test Release CDN',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='CDN',Title__c = title.id, Promotion_Name_Abbreviation__c='SU998');
        insRelList.add(objRelease);
        
        Release__c objRelease2 = new Release__c(Name='Test Release US',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='US',Title__c = title.id,Promotion_Name_Abbreviation__c='SU999');
        insRelList.add(objRelease2);
        
        insert insRelList;
        
        List<Material__c> insMatList = new List<Material__c>();
        Material__c objMaterial = new Material__c(name='FERT_1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='CDN', Item_type__c= 'M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Retailer_Rental__c='REN (RENTAL)');
        insMatList.add(objMaterial);
        
        Material__c objComp = new Material__c(name='Comp_1',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='CDN', Item_type__c= 'C - Components', Item_Code__c='DS - DISC', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)');
        insMatList.add(objComp);
        
        Material__c objMaterial2 = new Material__c(name='FERT_2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='CDN', Item_type__c= 'S (Single)', Item_Code__c='SS - Single Selection', Retailer_Rental__c='XXR (WINDOWED RENTAL)');
        insMatList.add(objMaterial2);
        
        Material__c objMaterial3 = new Material__c(name='FERT_3',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US & CDN', Item_type__c= 'S (Single)', Item_Code__c='SS - Single Selection', Retailer_Rental__c='SCR (SCREENER)');
        insMatList.add(objMaterial3);
        
        insert insMatList;
        
        List<Release_Material__c> insRMList = new List<Release_Material__c>();
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial.Id);
        insRMList.add(rm);
        
        Release_Material__c rm2 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial2.Id);
        insRMList.add(rm2);
        
        Release_Material__c rm3 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objComp.Id);
        insRMList.add(rm3);
        
        Release_Material__c rm4 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial3.Id);
        insRMList.add(rm4);
        
        insert insRMList;

        List<BOM_Item__c> insBomList = new List<BOM_Item__c>();
        BOM_Item__c boi1 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial2.Id);
        insBomList.add(boi1);
        
        BOM_Item__c boi2 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial3.Id);
        insBomList.add(boi2);
        
        BOM_Item__c boi3 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objComp.Id);
        insBomList.add(boi3);
        
        insert insBomList;
        
        Test.startTest();
        
        PageReference pageRef = Page.ReleaseCloning;
        pageRef.getParameters().put('recordId',objRelease.Id);
        pageRef.getParameters().put('retURL',objRelease.Id);
        Test.setCurrentPage(pageRef);

        /**** Constructing Controller Instance ****/
        ReleaseCloningController extController = new ReleaseCloningController();
        extController.useExistingReleaseFlag = 'SelectExistingRelease' ;
        extController.createNew = false;
        extController.showReleasePanel();
        extController.materialObjNewRelease.Release__c = objRelease2.Id;
        extController.hasDifferentTerritory();
        extController.checkNegativeTesting = true;
        extController.redirectToReviewPage();
        extController.backToReleaseCloning();
        extController.selectedMaterialLevel = 1;
        extController.materialIndex = '0';
        extController.sectionCollapseExpand();
        extController.switchView();
        extController.shouldCopyHierarchyForTerritoryChange = true;
        extController.save();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void scenario5(){
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        List<Release__c> insRelList = new List<Release__c>();
        Release__c objRelease = new Release__c(Name='Test Release CDN',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='CDN',Title__c = title.id, Promotion_Name_Abbreviation__c='SU998');
        insRelList.add(objRelease);
        
        insert insRelList;
        
        List<Material__c> insMatList = new List<Material__c>();
        Material__c objMaterial = new Material__c(name='FERT_1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Retailer_Rental__c='REN (RENTAL)');
        insMatList.add(objMaterial);
        
        Material__c objComp = new Material__c(name='Comp_1',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'C - Components', Item_Code__c='DS - DISC', Retailer_Rental__c='28R (28-DAY WINDOW RENTAL)');
        insMatList.add(objComp);
        
        Material__c objMaterial2 = new Material__c(name='FERT_2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS - Single Selection', Retailer_Rental__c='XXR (WINDOWED RENTAL)');
        insMatList.add(objMaterial2);
        
        Material__c objMaterial3 = new Material__c(name='FERT_3',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US & CDN', Item_type__c= 'S (Single)', Item_Code__c='SS - Single Selection', Retailer_Rental__c='SCR (SCREENER)');
        insMatList.add(objMaterial3);
        
        Material__c objComp2 = new Material__c(name='Comp_2',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'C - Components', Item_Code__c='DS - DISC', Retailer_Rental__c='WMT (WALMART)');
        insMatList.add(objComp2);
        
        Material__c objMaterial4 = new Material__c(name='FERT_2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS - Single Selection', Retailer_Rental__c='COS (COSTCO)');
        insMatList.add(objMaterial4);
        
        insert insMatList;
        
        List<Release_Material__c> insRMList = new List<Release_Material__c>();
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial.Id);
        insRMList.add(rm);
        
        Release_Material__c rm2 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial2.Id);
        insRMList.add(rm2);
        
        Release_Material__c rm3 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objComp.Id);
        insRMList.add(rm3);
        
        Release_Material__c rm4 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial3.Id);
        insRMList.add(rm4);
        
        Release_Material__c rm5 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objComp2.Id);
        insRMList.add(rm5);
        
        Release_Material__c rm6 = new Release_Material__c(Release__c = objRelease.Id , Material__c = objMaterial4.Id);
        insRMList.add(rm6);
        
        insert insRMList;

        List<BOM_Item__c> insBomList = new List<BOM_Item__c>();
        BOM_Item__c boi1 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial2.Id);
        insBomList.add(boi1);
        
        BOM_Item__c boi2 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objMaterial3.Id);
        insBomList.add(boi2);
        
        BOM_Item__c boi3 = new BOM_Item__c(Material__c = objMaterial.Id , Material_Component__c = objComp.Id);
        insBomList.add(boi3);
        
        BOM_Item__c boi4 = new BOM_Item__c(Material__c = objMaterial2.Id , Material_Component__c = objMaterial4.Id);
        insBomList.add(boi4);
        
        BOM_Item__c boi5 = new BOM_Item__c(Material__c = objMaterial2.Id , Material_Component__c = objComp2.Id);
        insBomList.add(boi5);
        
        insert insBomList;
        
        Test.startTest();
        
        PageReference pageRef = Page.ReleaseCloning;
        pageRef.getParameters().put('recordId',objMaterial.Id);
        pageRef.getParameters().put('retURL',objMaterial.Id);
        Test.setCurrentPage(pageRef);

        /**** Constructing Controller Instance ****/
        ReleaseCloningController extController = new ReleaseCloningController();
        extController.matTempIns.Territory__c = 'CDN';
        extController.hasDifferentTerritory();
        extController.switchView();
        extController.useExistingReleaseFlag = 'CreateNewRelease' ;
        extController.createNew = true;
        extController.showReleasePanel();
        extController.newRelease.Territory__c = 'CDN';
        extController.hasDifferentTerritory();
        extController.checkNegativeTesting = true;
        extController.save();
        
        Test.stopTest();
        
    }
}