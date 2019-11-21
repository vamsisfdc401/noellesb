/*****************************************************************************************
Class Name: MaterialApprovalHandlerTest
Purpose: Test class for apex class MaterialApprovalHandler 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0                                  Asha                     Initial Development
******************************************************************************************/
@isTest
private class MaterialApprovalHandlerTest{
    
    // Following method is used to prepare data setup. // Changed for Deal
    @testSetup 
    static void dataSetup() {
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
        
        // Inserting Origin Codes.
        List<Origin_Code__c> insertableOriginCodes = new List<Origin_Code__c>();
        Origin_Code__c oCode1 = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insertableOriginCodes.add(oCode1);
        Origin_Code__c oCode2 = new Origin_Code__c(Origin_Code__c='025 - Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code__c=sLblCode3.Id);
        insertableOriginCodes.add(oCode2);
        insert insertableOriginCodes;
    }

    @isTest
    static void testMethod_1()
    {
       
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        system.debug('Title created' +objTitle.id);
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);

        Material__c materialComponent = testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','EST (ELECTRONIC SELL THRU)','MATERIALComponentTEST','FERT',objRelease.Id,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');
        
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        //Changed the below code as per Deal Change logic
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='ROH';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';               
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachMat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Label_Code__c='61 - Universal Pictures';
        Insert eachMat;
        
        system.debug('eachMat created' +eachMat.id);
        
        Operations_Group__c operationGroup =  testClassUtility.getOperation('TestOperationTest','TestGroupID');
        insert operationGroup;
        
        Sales__c s = testClassUtility.getSales(eachMat,operationGroup);
        s.City_Sales_Tax__c ='1';
        insert s;
        
        system.debug('Sales__c created' +s.id);

        
        Plant__c p = testClassUtility.getPlants(eachMat); // added on 27.12
        p.Safety_Stock__c = 1230;
        p.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        p.Component_Scrap_Percentage__c = 2.00;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= materialComponent.id;  
        
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(eachMat);
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(eachMat.Id);
        
        Valuation__c valuation = testClassUtility.getValuations(eachMat); // added on 27.12
        insert valuation;
        
        Classification__c classification = testClassUtility.getClassifications(eachMat);// added on 27.12
        insert classification;
        
        Test.startTest(); // added to overcome 101 soql
        Material__c materialItem = [Select id,Material_Number__c,BOM_Status__c,Deletion_Flag__c,Label_Code__c,Prior_BOM_Quantity__c,BOM_Quantity__c,Material_Status__c,Format__c,
            Material_Type__c,Item_Type__c,Item_Code__c,(Select id,material__c,material__r.Material_Type__c,material__r.id,material__r.Item_Code__c,material__r.Item_Type__c from BOM_Items1__r),
            (Select id,Material_Component__r.Material_Type__c,Material_Component__r.id,Material_Component__r.Item_Code__c,Material_Component__r.Item_Type__c from BOM_Items__r) from Material__c Where  id  =: eachMat.id ];
        
        MaterialApprovalHandler.submitJointCorrugateMaterial(materialItem.Id);
       
        eachMat.Material_Type__c='FERT';
        
        update eachMat;
      
        MaterialApprovalHandler.submitJointCorrugateBOM(bomItem.id);
        MaterialApprovalHandler.submitPhantomTray(eachMat.Id);
        Test.stopTest();
             
    } 
    @isTest
    static void testMethod_2()
    {   
        
        LabelCode_Ignores_Regie__c labelCodeIgnore =  new LabelCode_Ignores_Regie__c();
        labelCodeIgnore.name = '23 - Remstar';
        
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        system.debug('Title created' +objTitle.id);
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        list<Material__c> materialList = new list<Material__c>();
        
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX'; 
        objMaterial.Territory__c ='US';
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX'; 
        objMaterial1.Territory__c ='US';
        materialList.add(objMaterial1);
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        //Changed the below code as per Deal Change logic
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='FERT';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';               
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c ='US';
        materialList.add(eachMat);
        
        Test.startTest();
        system.debug('eachMat created' +eachMat.id);
        
        
        insert materialList;
        
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);

        Test.stopTest();            
    }
    @isTest
    static void testMethod_3()
    {   
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX'; 
        objMaterial.Territory__c = 'US';
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX'; 
        objMaterial1.Territory__c = 'US';
        materialList.add(objMaterial1); 
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        //Changed the below code as per Deal Change logic
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='ROH';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';                 
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c = 'US';
        materialList.add(eachMat); 
        system.debug('eachMat created' +eachMat.id);
        
        Test.startTest();
        Insert materialList;
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(eachMat);
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(eachMat.Id);
        MaterialApprovalHandler.approveChildMaterials(eachMat.Id);
        Test.stopTest(); 
    }
    
    @isTest
    static void testMethod_4()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX';
        objMaterial.Territory__c ='US'; 
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX'; 
        objMaterial1.Territory__c ='US';
        materialList.add(objMaterial1);
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        //Changed the below code as per Deal Change logic
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='FERT';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';              
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c ='US';
        
        materialList.add(eachMat);
        insert materialList;
        system.debug('eachMat created' +eachMat.id);
        
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        TriggerUtility.doNotExecute = TRUE;
        insert bomItem;
        TriggerUtility.doNotExecute = false;
        
        system.debug('bomItem created' +bomItem.id);
        
        Test.startTest();
            list<Material__c> matList = new list<Material__c>();
            matList.add(eachMat);
            
            set<Id> matId1 = new Set<Id>();
            matId1.add(eachMat.Id);
            MaterialApprovalHandler.multiPackIds= matId1;
            MaterialApprovalHandler.requestMaterialIds = matId1;
            MaterialApprovalHandler.multiPackMap.put(eachMat.id, 'test');
            MaterialApprovalHandler.componentIds= matId1;
            MaterialApprovalHandler.submitMaterialHierarchyForApproval();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod_5()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX'; 
        objMaterial.Territory__c = 'US';
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX';
        objMaterial1.Territory__c = 'US';
        materialList.add(objMaterial1);
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        //Changed the below code as per Deal Change logic
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='ROH';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';              
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c = 'US';
        
        materialList.add(eachMat);
        
        Test.startTest();
        insert materialList;
        
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);
        
        Valuation__c valuation = new Valuation__c();
        valuation.Material__c = eachMat.id;
        insert valuation;
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(eachMat);
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(eachMat.Id);
        MaterialApprovalHandler.fetchChildMaterials(matId1, 1);
        Test.stopTest(); 
    }
   
    @isTest
    static void Test_2(){
        
        list<Material__c>materialList =  new List<Material__c>();
        Title__c title=testClassUtility.createTitle('Test Title_Method 6',true);
        title.SGENNO__c='000123';
        insert title;
        
        Deal__c dealDetails = testClassUtility.getDeal(title);
        dealDetails.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        dealdetails.SGENNO__c = title.SGENNO__c;
        insert dealDetails;
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1 = testClassUtility.createMaterial('13 - HD VOD','DVD','dummy98','FERT',release.id,TRUE,'M (Multipack)','ME - TV MULTIPLE EPISODES');
                
        material1 = testClassUtility.getMaterialDetails(material1,title,sub_Label_Code,alternativeLegalTitle,dealDetails);
        
        materialList.add(material1);

        insert materialList;
        
        Valuation__c valuation = testClassUtility.getValuations(material1);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        
        Test.startTest();
        List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id IN :materialList];
        
        MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(new set<Id>{materialDataToProcess[0].id});
        
        MaterialApprovalHandler.checkSAPallFieldsComplete(materialDataToProcess);   // 3.01.2017
         materialApprovalHandler.defaultTitleSourceforMultipack();
        Test.stopTest();
    } 
    
    
    
    @isTest
    static void testMethod_7(){
        list<Material__c>materialList =  new List<Material__c>();
        
        list<Material__c>materialListToInsert =  new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;

        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material = testClassUtility.createMaterial('13 - HD VOD','DVD','TEST','FERT',release.id,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');

        material.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        material.Material_Number__c = '123401';
        material.Deletion_Flag__c =false;
        material.Prior_BOM_Quantity__c ='123w';
        material.BOM_Quantity__c = 1;
        
        Material__c materialComponent = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTCOMPONENT','FERT',release.id,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');
        materialComponent.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        materialComponent.Material_Number__c = '12340';
        materialComponent.Deletion_Flag__c =false;
        materialComponent.Prior_BOM_Quantity__c ='123w';
        materialComponent.BOM_Quantity__c = 1;
        
        Material__c materialComponent1 = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTCOMPONENT1','FERT',release.id,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');
        materialComponent1.BOM_Quantity__c = 1;
        materialListToInsert.add(material);
        materialListToInsert.add(materialComponent1);
        materialListToInsert.add(materialComponent);
        
        
        // inserting material list
        insert materialListToInsert;
        Test.startTest();
        
        list<Bom_item__c>bomItemList =  new list<Bom_item__c>();
        Bom_item__c bomItem = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        
        Bom_item__c bomItem2 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem2.Material_Component__c  = materialComponent1.Id;
        
        
        Bom_item__c bomItem1 = getBOMItems(materialComponent,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem1.Material_Component__c  = material.Id;
        
        bomItemList.add(bomItem);
        bomItemList.add(bomItem2);
        insert bomItemList;
        
        
        materialList = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
                                                    Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                                                    Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,
                                                    Xplant_Material_Status__c,Xplant_Valid_From__c,Gross_Weight__c,Net_Weight__c,Weight_Unit__c, 
                                                    Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,
                                                    Purchase_Value_Key__c, Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,
                                                    BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,
                                                    (Select Pricing_Control__c, Price_Unit__c, Standard_Price__c, Origin_Group__c, Material__c, Valuation_Class__c, Valuation_Area__c From Valuations__r),
                                                    (Select Distribution_Channel__c, Tax_Indicator__c, Territory__c, Valid_From__c, Tax_Jurisdiction_Code__c, County_Sales_Tax__c, City_Sales_Tax__c, GST_Canada__c, PST_Canada__c, Sales_Org__c, D_Chain_Spec__c, Material_Statistic_Group__c, 
                                                     Item_Category_Group__c, Material_Group_3__c, Material_Group_5__c, Material_Pricing_Group__c, Operations_Group__c, Deliver_Plant__c From Sales__r)
                                                    from Material__c where Id in :materialListToInsert];
                                     
       
        MaterialApprovalHandler.submitJointCorrugateMaterial(materialList[0].id);

        MaterialApprovalHandler.submitPhantomTray(materialList[1].id);
    
        MaterialApprovalHandler.submitPhantomTray(materialList[0].id);
        MaterialApprovalHandler.updateJointCorrugateMaterials(new set<id>{materialList[0].id,materialList[1].id});
        MaterialApprovalHandler.submitAndProcessApprovalRequest(materialList[1].id);

        

        Test.stopTest();
    } 
    
    private static Bom_item__c getBOMItems(Material__c material1,string componentNumber,integer bomQuantity,string componentQuantity, boolean isProductionFlag,Date validFrom,string itemCategory){
        Bom_item__c bomItem = new Bom_item__c(Material__c=material1.id,Component_Number__c=componentNumber,BOM_Quantity__c=bomQuantity,Component_Quantity__c=componentQuantity,Production_Flag__c=isProductionFlag,Valid_From__c=validFrom,Item_Category__c=itemCategory);
        
        return bomItem;
    }
    
    @isTest
    static void testMethod_8(){
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        
        List<Material__c>materialsList =  new list<Material__c>();
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // material data
        Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','TESTMaterial','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material.Deletion_Flag__c = false;
        material.Selection_Reference_Number__c = '12311230000';
        material.Label_Code__c = '61 - Universal Pictures';
        material.Territory__c = 'US';
        
        
        // component material data
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.Label_Code__c = '61 - Universal Pictures';
     
        materialComponent.Territory__c = 'US';
        
        Material__c material1 =  testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','EST (ELECTRONIC SELL THRU)','TESTMaterial11','FERT',release.id,TRUE,'D (Display Vehicle)','SS - SINGLE SELECTION');
        material1.Deletion_Flag__c = false;
        material1.Selection_Reference_Number__c = '12310100000';
        material1.Material_Number__c='1213233';
        material1.Label_Code__c = '61 - Universal Pictures';
        
        material1.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';//date 
        material1.Purchase_Value_Key__c = '0000';// string
        material1.Transportation_Group__c = '0001';
        material1.Plant__c = 'V000';
        material1.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';
        material1.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
        material1.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        
        material1.General_Item_Category_Group__c ='NORM - Standard item / CU';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        
        material1.Gross_Weight__c = 0.25;
        material1.Net_Weight__c = 0.151;
        material1.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        
        material1.Valid_From__c = Date.newInstance(2016,9,07);//'2016-09-07';
        
        material1.Industry_Sector__c = 'Z';
        material1.BOM_Usage__c = '3';
        material1.BOM_Category__c = 'M';
        material1.TM_Status__c = '01 - APPROVED';
        
        
        material1.Street_Date__c = Date.newInstance(2013,05,08);
        material1.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        material1.Create_Version__c = true;
        material1.X_Dchain_Status__c = 'AA';
        material1.Base_Unit_of_Measure__c = 'EA';
        material1.Territory__c = 'US';
        
        materialsList.add(material);
        materialsList.add(materialComponent);
        materialsList.add(material1);
        insert materialsList;
        
        // holds bom items
        List<Bom_item__c>bomItems =  new list<Bom_item__c>();
        
        Bom_item__c bomItem1 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem1.Material_Component__c  = materialComponent.Id;
        
        Bom_item__c bomItem2 = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem2.Material_Component__c  = material1.Id;
        
        bomItems.add(bomItem1);
        bomItems.add(bomItem2);
        
        insert bomItems;
        Test.startTest();
            
            List<Material__c>materialItem = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id =:material1.id];
            
            
            Integer count = MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialItem[0].id);
            
        Test.stopTest();
        
    }
    
    
    private static testMethod void testSubmitJointCorrugateBOM(){
        
        List<Material__c>materialList = new list<Material__c>();
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        
        // material data
        Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','TESTMaterial','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material.Deletion_Flag__c = false;
        material.Selection_Reference_Number__c = '12311230000';
        material.Territory__c = 'US';
        
        // component material data
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        materialComponent.Deletion_Flag__c = false;
        materialComponent.Selection_Reference_Number__c = '12410100000';
        materialComponent.BOM_Quantity__c = 1;
        materialComponent.Prior_BOM_Quantity__c = '011';
        materialComponent.Territory__c = 'US';
        
        materialList.add(material);
        materialList.add(materialComponent);
        
        insert materialList;
        
        
        Bom_item__c bomItem = getBOMItems(material,'1',2,'2',true,Date.newInstance(2000, 12, 12),'L');
        bomItem.Material_Component__c  = materialComponent.Id;
        
        insert bomItem;
        
        Test.startTest();
            
            BOM_Item__c bomItemsFT = [SELECT Material_Component__c, Material_Component__r.BOM_Quantity__c,Material__r.BOM_Status__c,Material__r.BOM_Quantity__c,
                                        Material__r.Prior_BOM_Quantity__c,Material_Component__r.Prior_BOM_Quantity__c FROM BOM_Item__c
                                        WHERE id = :bomItem.id AND Material_Component__c != null AND 
                                            Material_Component__r.Material_Type__c='FERT' AND 
                                            Material__r.Material_Type__c='FERT'];
            
            system.assertNotEquals(null,bomItemsFT);
            string result = MaterialApprovalHandler.submitJointCorrugateBOM(bomItemsFT.Id);
            system.assertNotEquals(null,result);
        
        Test.stopTest();
        
        
    }
    

    private static testMethod void testMaterialforNonFERT(){
        
        List<Material__c> materialList=  new List<Material__c>();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        
        
        // title data
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        
        Release__c release=testClassUtility.createRelease('Test Release11','Universal Pictures','New Release','Materials Not Requested',title.id);
        insert release;
        
        // materials details
        Material__c material1 = testClassUtility.createMaterial(null,null,'dummy98M1','ROH',null,TRUE,'C - Components','PG - PACKAGING');
        // component material data
        material1.Deletion_Flag__c = false;
        
        
        material1.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';//date 
        material1.Purchase_Value_Key__c = '0000';// string
        material1.Transportation_Group__c = '0001';
        material1.Plant__c = 'V000';
        material1.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';
        material1.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
        material1.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        
        material1.General_Item_Category_Group__c ='NORM - Standard item / CU';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        
        material1.Gross_Weight__c = 0.25;
        material1.Net_Weight__c = 0.151;
        material1.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        
        material1.Valid_From__c = Date.newInstance(2016,9,07);//'2016-09-07';
        
        material1.Industry_Sector__c = 'Z';
        material1.BOM_Usage__c = '3';
        material1.BOM_Category__c = 'M';
        
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        material1.Gross_Weight__c = 0.25;
        material1.Weight_Unit__c = 'LB - US pound';
        material1.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        material1.Create_Version__c = true;
        material1.X_Dchain_Status__c = 'AA';
        material1.Base_Unit_of_Measure__c = 'EA';
        material1.Pre_Order_Close_Date__c = Date.newInstance(2013,05,08);
        
        material1.Street_Date__c = Date.newInstance(2013,05,08);
        
        
        Material__c material2 = testClassUtility.createMaterial(null,null,'dummy98M2','ROH',null,TRUE,'C - Components','PG - PACKAGING');
        material2.component_type__c='LITHO SLIMPACK';
        material2.Selection_Reference_Number__c='84819004000';
        materialList.add(material1);
        materialList.add(material2);
        insert materialList;
        
        Valuation__c valuation = testClassUtility.getValuations(material1);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        
        Test.startTest();
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id IN :materialList];
            
            system.assertNotEquals(null,materialDataToProcess[0].id);
            MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(new set<Id>{materialDataToProcess[0].id});
            MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(new set<Id>{materialDataToProcess[1].id});
            
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[0].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[1].id);
        
        
        Test.stopTest();
        
        
        
    }

    private static testMethod void testMaterialforJointCorrugate(){
        
        List<Material__c> materialList=  new List<Material__c>();
        
        Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;

        
        Release__c release =  new Release__c();
        release.Internal_Announce_Date__c=Date.Today()-3;
        release.Street_Date__c=Date.Today();
        release.EST_Date__c=Date.Today();
        release.Name='Test Release11';
        release.Brand_Group__c = 'Universal Pictures';
        release.Project_Type__c = 'New Release';
        release.Release_Status__c = 'Materials Not Requested';
        insert release;
        
        
        // materials details
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy981','FERT',null,TRUE,'D (Display Vehicle)','CU - CUBE');
        material1.Deletion_Flag__c = false;
        material1.recordtypeid = materialRecordTypeId ;
        material1.title_source__c = '01 - THEATRICAL';
        material1.Territory__c = 'US';
        material1.Label_code__c='87 - JOINT CORR/MULTI-STUDIO';
        
        Material__c material2 = testClassUtility.createMaterial('13 - HD VOD','DVDR','dummy980_FT1','FERT',null,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');
        material2.Deletion_Flag__c = false;
        material2.recordtypeid = materialRecordTypeId ;
        material2.Territory__c = 'US';
        material2.Label_code__c='61 - Universal Pictures';
        
        Material__c material3 = testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','dummy980_FT2','FERT',null,TRUE,'D (Display Vehicle)','FT - PHANTOM TRAY');
        material3.Deletion_Flag__c = false;
        material3.recordtypeid = materialRecordTypeId ;
        material3.Territory__c = 'US';
        material3.Label_code__c='61 - Universal Pictures';
        material3.selection_reference_number__c='12345678000';
        
        
        // component material data
        Material__c material4 =  testClassUtility.createMaterial('02 - DVD','DVD','dummy980_M1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material4.Deletion_Flag__c = false;
        material4.recordtypeid = materialRecordTypeId ;
        material4.Territory__c = 'US';
        material4.material_status__c='Processed in SAP';
        material4.material_Number__c='12345678000';
        
        Material__c material5 = testClassUtility.createMaterial('09 - BLU-RAY','BD','dummy980_M2','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material5.Deletion_Flag__c = false;
        material5.recordtypeid = materialRecordTypeId ;
        material5.Territory__c = 'US';
        material5.material_status__c='Processed in SAP';
        material5.material_Number__c='23456781000';
        
        Material__c material6 = testClassUtility.createMaterial('13 - HD VOD','DVDR','dummy980_New','FERT',null,TRUE,'D (Display Vehicle)','CS - CLIP STRIP');
        material6.Deletion_Flag__c = false;
        material6.recordtypeid = materialRecordTypeId ;
        material6.Territory__c = 'US';
        material6.Label_code__c='61 - Universal Pictures';
        
        material1.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';//date 
        material1.Purchase_Value_Key__c = '0000';// string
        material1.Transportation_Group__c = '0001';
        material1.Plant__c = 'V000';
        material1.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';
        material1.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
        material1.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        
        material1.General_Item_Category_Group__c ='NORM - Standard item / CU';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        
        material1.Gross_Weight__c = 0.25;
        material1.Net_Weight__c = 0.151;
        material1.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        
        material1.Valid_From__c = Date.newInstance(2016,9,07);//'2016-09-07';
        
        material1.Industry_Sector__c = 'Z';
        material1.BOM_Usage__c = '3';
        material1.BOM_Category__c = 'M';
        
        material1.Weight_Unit__c = 'LB - US pound';
        material1.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        material1.Create_Version__c = true;
        material1.X_Dchain_Status__c = 'AA';
        material1.Base_Unit_of_Measure__c = 'EA';
        material1.Pre_Order_Close_Date__c = Date.newInstance(2013,05,08);
        
        material1.Street_Date__c = Date.newInstance(2013,05,08);
        

        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        materialList.add(material4);
        materialList.add(material5);
        materialList.add(material6);
        insert materialList;
        Test.startTest();
        
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c= material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=material1.id,Material_Component__c= material3.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;
        
        Bom_item__c bomItem3=new Bom_item__c(Material__c=material2.id,Material_Component__c= material4.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem3;
        
        Bom_item__c bomItem4=new Bom_item__c(Material__c=material3.id,Material_Component__c= material5.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem4;
        
        Bom_item__c bomItem5=new Bom_item__c(Material__c=material6.id,Material_Component__c= material5.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem5;
        
        Valuation__c valuation = testClassUtility.getValuations(material1);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        
        
        
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id =: material1.id];
                        
             List<Material__c>materialDataToProcess1 = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id =: material6.id];           
            
            system.assertNotEquals(null,materialDataToProcess[0].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[0].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess1[0].id);
            Test.stopTest();
    }

   /* private static testMethod void testMaterialforUpdate(){
        
        List<Material__c> materialList=  new List<Material__c>();
        Set<Id>matIds=new Set<Id>();
        
        Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;

        
        Release__c release =  new Release__c();
        release.Internal_Announce_Date__c=Date.Today()-3;
        release.Street_Date__c=Date.Today();
        release.EST_Date__c=Date.Today();
        release.Name='Test Release11';
        release.Brand_Group__c = 'Universal Pictures';
        release.Project_Type__c = 'New Release';
        release.Release_Status__c = 'Materials Not Requested';
        insert release;
        
        
        // materials details
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy981','FERT',release.id,TRUE,'D (Display Vehicle)','ME - TV MULTIPLE EPISODES');
        material1.Deletion_Flag__c = false;
        material1.recordtypeid = materialRecordTypeId ;
        material1.title_source__c = '01 - THEATRICAL';
        material1.Territory__c = 'US';
                
        Material__c material2 = testClassUtility.createMaterial('13 - HD VOD','DVDR','dummy980','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Deletion_Flag__c = false;
        material2.recordtypeid = materialRecordTypeId ;
        material2.Territory__c = 'US';
        
        // component material data
        Material__c material3 =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',release.id,TRUE,'C - Components','PG - PACKAGING');
        material3.Deletion_Flag__c = false;
        material3.recordtypeid = materialRecordTypeId ;
        material3.Territory__c = 'US';
        
        Material__c material4 = testClassUtility.createMaterial('13 - HD VOD','DVDR','dummy980','FERT',release.id,TRUE,'M (MultiPack)','ME - TV MULTIPLE EPISODES');
        material4.Deletion_Flag__c = false;
        material4.recordtypeid = materialRecordTypeId ;
        material4.Territory__c = 'US';
        
        material1.X_Dchain_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';//date 
        material1.Purchase_Value_Key__c = '0000';// string
        material1.Transportation_Group__c = '0001';
        material1.Plant__c = 'V000';
        material1.Xplant_Valid_From__c = Date.newInstance(2016,8, 30);//'2016-08-30';
        material1.Technical_Format__c = '03 - ANAMORPHIC WIDESCREEN';
        material1.Sub_Label_Code_Lookup__c = sub_Label_Code.Id;// lookup
        
        material1.General_Item_Category_Group__c ='NORM - Standard item / CU';
        material1.Division__c = '10';
        material1.Xplant_Material_Status__c = 'AA';
        
        material1.Gross_Weight__c = 0.25;
        material1.Net_Weight__c = 0.151;
        material1.Alternative_Legal_Title_Lookup__c = alternativeLegalTitle.Id;// lookup
        
        material1.Valid_From__c = Date.newInstance(2016,9,07);//'2016-09-07';
        
        material1.Industry_Sector__c = 'Z';
        material1.BOM_Usage__c = '3';
        material1.BOM_Category__c = 'M';
        
        material1.Weight_Unit__c = 'LB - US pound';
        material1.Material_Group__c = '55111514 - Product Duplication - Motion pictures on Digital Video';
        material1.Create_Version__c = true;
        material1.X_Dchain_Status__c = 'AA';
        material1.Base_Unit_of_Measure__c = 'EA';
        material1.Pre_Order_Close_Date__c = Date.newInstance(2013,05,08);
        
        material1.Street_Date__c = Date.newInstance(2013,05,08);
         
        
        
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        materialList.add(material4);
        insert materialList;
        
        matIds.add(material1.id);
        matIds.add(material2.id);
        matIds.add(material3.id);
        matIds.add(material4.id);
        
        Valuation__c valuation = testClassUtility.getValuations(material1);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        plant.Safety_Stock__c = 012;
        plant.MRP_Controller__c = 'PH1 - Buyer/Planner PH1';
        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
        plant.MRP_Type__c = 'M0 - MPS, fixing type -0-';
        plant.Max_Lot_Size__c = 01;
        plant.Component_Scrap_Percentage__c = 1.00;
        plant.plant__c = 'V001 - Univ Studios HV';
        plant.Availability_Check__c = '02 - Individ.requirements';
        
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        Classification__c classification=testClassUtility.getClassifications(material1);
        insert classification;
        
        Test.startTest();
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id in: matIds];
            
            system.assertNotEquals(null,materialDataToProcess[0].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[0].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[1].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[2].id);
            MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[3].id);
        Test.stopTest();
    }*/

    @isTest
    static void testMethod_delete()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX'; 
        objMaterial.Territory__c = 'US';
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX';
        objMaterial1.Territory__c = 'US';
        
        materialList.add(objMaterial1);
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
        
         Operations_Group__c operationGroup =  testClassUtility.getOperation('TestOperationTest','TestGroupID');
        insert operationGroup;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='ROH';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';              
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        
        eachMat.Territory__c = 'US';
        materialList.add(eachMat);
        
        Test.startTest();
        insert materialList;
        
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        s.Distribution_Channel__c='10' ;
        s.Deliver_Plant__c ='V300'; 
        s.Tax_Jurisdiction_Code__c ='1'; 
        s.Territory__c='US';
        s.County_Sales_Tax__c ='1';
        s.City_Sales_Tax__c ='1'; 
        s.Item_Category_Group__c ='ZUMF - SC Display Vehicles'; 
        s.Sales_Org__c ='V100 - US Home Video'; 
        s.D_Chain_Spec__c ='XX - Never Released'; 
        s.Valid_From__c =System.today();
        s.Volume_Rebate_Group__c ='61';
        s.Material_Pricing_Group__c ='Z0 - Not Tracked'; 
        s.Operations_Group__c =operationGroup.id; 
        s.Material_Group_3__c ='888 - Master Data Interface Relevant'; 
        s.Material_Group_5__c ='A - Yes-Remove shrink-Place in inventory';  
        s.Material_Statistic_Group__c='1 - \'A\' Material';
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Valid_From__c=System.today(); 
        
        p.Plant__c='V000 - Univ Studios HV Planning Plant';
        p.Availability_Check__c ='CT - Catalog'; 
        p.MRP_Type__c ='PD - MRP'; 
        p.ABC_Indicator__c ='C - Low Significance - 4 WOS'; 
        p.Lot_Size__c ='Z4 - Dynamic Weekly lot size 4 weeks'; 
        p.Max_Lot_Size__c =0.0;
        p.Max_Stock_Level__c =0.0; 
        p.Special_Procurement__c ='30 - Subcontracting'; 
        p.Schedule_Margin_Key__c ='060'; 
        p.Period_Ind__c ='W - Weekly';
        p.Fwd_Cons_Period__c ='040'; 
        p.GR_Processing_Time__c ='1';
        p.Mixed_MRP__c ='1 - Subassembly planning with final assembly'; 
        p.Requirements_Grouping__c ='T - Display of dependent requirements as a daily total';
        p.Profit_Center__c ='V130FM9020'; 
        p.Purchasing_Group__c ='VM4 - New Rls Buyer VM4'; 
        p.MRP_Controller__c ='VM4 - Prod Planner VM4'; 
        p.Min_Lot_Size__c  =1.0; 
        p.Rounding_Value__c =1.0; 
        p.Plnd_Dely_time__c ='7'; 
        p.Stor_Loc_EP__c ='Sto1';
        p.Splitting_Ind__c ='A'; 
        p.Bwd_Cons_Period__c ='040';
        p.Indv_Colle__c ='2';
        p.Consumption_Mode__c='2 - Backward/forward consumption';
        p.Procurement_Type__c='F - External procurement'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);
        
        Valuation__c v= new Valuation__c();
        v.Material__c = eachMat.id;
        v.Valuation_Area__c='V000';
        v.Valuation_Class__c='7930 - Finished Goods Home Video';
        v.Price_Unit__c='1000'; 
        v.Standard_Price__c=700.00;
        v.Origin_Group__c='10';
        v.Pricing_Control__c='S';
        insert v;
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(eachMat);
        
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(eachMat.Id);
        MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(matId1);
        MaterialApprovalHandler.deleteUpdateMaterials(eachMat.id);
        Test.stopTest(); 
    }

    @isTest
    static void testMethod_MaterialApproval()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id,SGENNO__c=objTitle.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        system.debug('Release created' +objRelease.id);
        
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c='24 - PURE FLIX'; 
        objMaterial.Territory__c = 'US';
        materialList.add(objMaterial);
        
        system.debug('Material created' +objMaterial.id);
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVDR',Material_Status__c='Draft',name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Label_Code__c='24 - PURE FLIX';
        objMaterial1.Territory__c = 'US';
        
        materialList.add(objMaterial1);
        
        system.debug('objMaterial1 created' +objMaterial1.id);
        
        Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg=[Select id from Sub_Label_Code__c where Sub_Label_Code_ID__c='87'];
        
        system.debug('Sub_Label_Code__c created' +sg.id);
                
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
        
         Operations_Group__c operationGroup =  testClassUtility.getOperation('TestOperationTest','TestGroupID');
        insert operationGroup;
             
        system.debug('Alternative_Legal_Title__c created' +alt.id);
           
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='FERT';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='BF - BABY FERT';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        eachMat.Label_Code__c='24 - PURE FLIX';              
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachmat.deal__c = deal.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        
        eachMat.Territory__c = 'US & CDN';
        materialList.add(eachMat);
        
        Test.startTest();
        insert materialList;
        
        Sales__c s = new Sales__c();
        s.Material__c = eachMat.Id;
        s.Distribution_Channel__c='10' ;
        s.Deliver_Plant__c ='V300'; 
        s.Tax_Jurisdiction_Code__c ='1'; 
        s.Territory__c='US';
        s.County_Sales_Tax__c ='1';
        s.City_Sales_Tax__c ='1'; 
        s.Item_Category_Group__c ='ZUMF - SC Display Vehicles'; 
        s.Sales_Org__c ='V100 - US Home Video'; 
        s.D_Chain_Spec__c ='XX - Never Released'; 
        s.Valid_From__c =System.today();
        s.Volume_Rebate_Group__c ='61';
        s.Material_Pricing_Group__c ='Z0 - Not Tracked'; 
        s.Operations_Group__c =operationGroup.id; 
        s.Material_Group_3__c ='888 - Master Data Interface Relevant'; 
        s.Material_Group_5__c ='A - Yes-Remove shrink-Place in inventory';  
        s.Material_Statistic_Group__c='1 - \'A\' Material';
        Insert s; 
        
        system.debug('Sales__c created' +s.id);
        
        Plant__c p = new Plant__c();
        p.Material__c = eachMat.id;
        p.Valid_From__c=System.today(); 
        
        p.Plant__c='V000 - Univ Studios HV Planning Plant';
        p.Availability_Check__c ='CT - Catalog'; 
        p.MRP_Type__c ='PD - MRP'; 
        p.ABC_Indicator__c ='C - Low Significance - 4 WOS'; 
        p.Lot_Size__c ='Z4 - Dynamic Weekly lot size 4 weeks'; 
        p.Max_Lot_Size__c =0.0;
        p.Max_Stock_Level__c =0.0; 
        p.Special_Procurement__c ='30 - Subcontracting'; 
        p.Schedule_Margin_Key__c ='060'; 
        p.Period_Ind__c ='W - Weekly';
        p.Fwd_Cons_Period__c ='040'; 
        p.GR_Processing_Time__c ='1';
        p.Mixed_MRP__c ='1 - Subassembly planning with final assembly'; 
        p.Requirements_Grouping__c ='T - Display of dependent requirements as a daily total';
        p.Profit_Center__c ='V130FM9020'; 
        p.Purchasing_Group__c ='VM4 - New Rls Buyer VM4'; 
        p.MRP_Controller__c ='VM4 - Prod Planner VM4'; 
        p.Min_Lot_Size__c  =1.0; 
        p.Rounding_Value__c =1.0; 
        p.Plnd_Dely_time__c ='7'; 
        p.Stor_Loc_EP__c ='Sto1';
        p.Splitting_Ind__c ='A'; 
        p.Bwd_Cons_Period__c ='040';
        p.Indv_Colle__c ='2';
        p.Consumption_Mode__c='2 - Backward/forward consumption';
        p.Procurement_Type__c='F - External procurement'; 
        Insert p;
        
        system.debug('Plant created' +p.id);
        
        BOM_Item__c bomItem= new BOM_Item__c();
        bomItem.Material__c= eachMat.id;
        bomItem.Material_Component__c= eachMat.id; 
        insert bomItem;
        
        system.debug('bomItem created' +bomItem.id);
        
        Valuation__c v= new Valuation__c();
        v.Material__c = eachMat.id;
        v.Valuation_Area__c='V000';
        v.Valuation_Class__c='7930 - Finished Goods Home Video';
        v.Price_Unit__c='1000'; 
        v.Standard_Price__c=700.00;
        v.Origin_Group__c='10';
        v.Pricing_Control__c='S';
        insert v;
        
        list<Material__c> matList = new list<Material__c>();
        matList.add(eachMat);
        
        
        set<Id> matId1 = new Set<Id>();
        matId1.add(eachMat.Id);
        MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(matId1);
        MaterialApprovalHandler.deleteUpdateMaterials(eachMat.id);
        Test.stopTest(); 
    }

     @isTest
    static void Test_1(){
        
        list<Material__c>materialList =  new List<Material__c>();
        Title__c title=testClassUtility.createTitle('Test Title_Method 6',true);
        title.SGENNO__c='000123';
        insert title;
        
        Deal__c dealDetails = testClassUtility.getDeal(title);
        dealDetails.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        dealDetails.SGENNO__c = title.SGENNO__c;
        insert dealDetails;
        
        Sub_Label_Code__c sub_Label_Code = testClassUtility.getSubLabelCode();
        insert sub_Label_Code;
        
        Alternative_Legal_Title__c alternativeLegalTitle = testClassUtility.getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1 = testClassUtility.createMaterial('17 - BD-R','DVD','dummy98','FERT',release.id,TRUE,'M (Multipack)','ME - TV MULTIPLE EPISODES');
        material1.Label_Code__c='24 - PURE FLIX';       
        material1 = testClassUtility.getMaterialDetails(material1,title,sub_Label_Code,alternativeLegalTitle,dealDetails);
        
        materialList.add(material1);

        insert materialList;
        
        Valuation__c valuation = testClassUtility.getValuations(material1);
        insert valuation;
        
        Plant__c plant = testClassUtility.getPlants(material1);
        insert plant ;
        
        Operations_Group__c operationGroup = testClassUtility.getOperation('TestOperation','TESTId');
        insert operationGroup;
        
        Sales__c sales = testClassUtility.getSales(material1,operationGroup);
        insert sales;
        
        
        Test.startTest();
        List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
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
                        from Material__c where id IN :materialList];
        
        MaterialApprovalHandler.checkSAPFieldsCompleteHierarchy(new set<Id>{materialDataToProcess[0].id});
        
        MaterialApprovalHandler.checkSAPallFieldsComplete(materialDataToProcess);   // 3.01.2017
        Integer count = MaterialApprovalHandler.submitReleaseMaterialsForApproval(materialDataToProcess[0].id);
        Test.stopTest();
    } 
    
 }