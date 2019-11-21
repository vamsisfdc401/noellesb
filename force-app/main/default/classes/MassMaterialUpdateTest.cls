/*****************************************************************************************
Class Name: MassMaterialUpdateTest
Purpose: Test class for apex class Mass Material Update functionality. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/18/2017           Suman                    Initial Development
******************************************************************************************/
@isTest(seeAllData = false)
public class MassMaterialUpdateTest
{
    // Test data setup.
    @TestSetup
    static void setupData()
    {
        List<Material__c> materialList = new List<Material__c>();
        List<MassUpdateFieldMapping__c> fieldMappingList = new List<MassUpdateFieldMapping__c>();
        
        // Creating Mass Update Material field configuration.
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_1', Request_Field_API__c='Sales_Planning_Group__c', 
                                                           Transaction_Object_API__c='Material__c', Transaction_Field_API__c='Sales_Planning_Group__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_2', Request_Field_API__c='Subformat__c', 
                                                           Transaction_Object_API__c='Material__c', Transaction_Field_API__c='Subformat__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_3', Request_Field_API__c='Technical_Format__c', 
                                                           Transaction_Object_API__c='Material__c', Transaction_Field_API__c='Technical_Format__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_4', Request_Field_API__c='MPM__c', 
                                                           Transaction_Object_API__c='Material__c', Transaction_Field_API__c='MPM_Issue__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_5', Request_Field_API__c='MRP_Controller__c', 
                                                           Transaction_Object_API__c='Plant__c', Transaction_Field_API__c='MRP_Controller__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_6', Request_Field_API__c='Purchasing_Group__c', 
                                                           Transaction_Object_API__c='Plant__c', Transaction_Field_API__c='Purchasing_Group__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_7', Request_Field_API__c='Component__c', 
                                                           Transaction_Object_API__c='Classification__c', Transaction_Field_API__c='Component__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_8', Request_Field_API__c='Operations_Group__c', 
                                                           Transaction_Object_API__c='Sales__c', Transaction_Field_API__c='Operations_Group__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_9', Request_Field_API__c='Material_Group_2__c', 
                                                           Transaction_Object_API__c='Sales__c', Transaction_Field_API__c='Material_Group_2__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_10', Request_Field_API__c='Material_Group_3__c', 
                                                           Transaction_Object_API__c='Sales__c', Transaction_Field_API__c='Material_Group_3__c'));
        fieldMappingList.add(new MassUpdateFieldMapping__c(Name='FieldMapping_11', Request_Field_API__c='Material_Group_5__c', 
                                                           Transaction_Object_API__c='Sales__c', Transaction_Field_API__c='Material_Group_5__c'));
        insert fieldMappingList;
        
        // Title details
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        //Deal details
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
        insert deal;
        
        // Creating sub label code
        Sub_Label_Code__c sub_Label_Code = getSubLabelCode();
        insert sub_Label_Code;
        
        // Creating Alternative Legal Title.
        Alternative_Legal_Title__c alternativeLegalTitle = getAlternativeLegalTitle();
        insert alternativeLegalTitle;
        
        // Creating Operation group.
        Operations_Group__c operationGroup = getOperation();
        insert operationGroup;
        
        // Creating Release.
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Title__c = title.id);
        insert objRelease;
        
        // Preparing material records
        Material__c objMaterial2 = testClassUtility.createMaterial('02 - DVD','DVDR','dummy','FERT',objRelease.id,TRUE,'S (Single)','SS (Single Selection)');
        objMaterial2.Territory__c = 'US';
        objMaterial2.Material_Number__c = '89017863000';
        objMaterial2.Name = 'TestMat-002';
        materialList.add(objMaterial2);
        
        Material__c objMaterial3 = testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',objRelease.id,TRUE,'S (Single)','SS (Single Selection)');
        //objMaterial3 = objMaterial3,title,sub_Label_Code,alternativeLegalTitle);
        objMaterial3.Territory__c = 'CDN';
        objMaterial3.Label_Code__c = '61 - Universal Pictures';
        objMaterial3.Material_Number__c = '89017864000';
        objMaterial3.Material_Number__c = '89017864000';
        objMaterial3.Name = 'TestMat-003';
        materialList.add(objMaterial3);
        
        Material__c objMaterial4 = testClassUtility.createMaterial('02 - DVD','BD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        objMaterial4 = getMaterialDetails(objMaterial4, title, null, null);
        objMaterial4.Territory__c = null;
        objMaterial4.Label_Code__c = '61 - Universal Pictures';   
        objMaterial4.Material_Number__c = '89017252000';
        objMaterial4.Name = 'TestMat-011';
        objMaterial4.deal__C = deal.id;
        materialList.add(objMaterial4);
        
        insert materialList;
        
        // Creating an existing Open Mass Header.
        Mass_Update_Header__c header = new Mass_Update_Header__c();
        insert header;
        
        // Creating an existing open request for a material.
        Material_Update_Request__c mreq1 = new Material_Update_Request__c(Mass_Update_Header__c=header.Id, Material_Number__c='89017864000', Source_Material__c=objMaterial3.Id, Sales_Org__c='V800');
        insert mreq1;
        Material_Update_Request__c mreq2 = new Material_Update_Request__c(Mass_Update_Header__c=header.Id, Material_Number__c='89017252000', Source_Material__c=objMaterial4.Id);
        insert mreq2;
        //Added For Deal  Change logic - Start
        List<ComponentExtensionOnClone__c> compExt = new List<ComponentExtensionOnClone__c>();
        ComponentExtensionOnClone__c ce = new ComponentExtensionOnClone__c();
        ce.name='test';
        ce.checkFromComponentExtension__c =true;
        compExt.add(ce);
        insert compExt;
    }
    
    // Mass Update Material Negative Flow 
    @isTest
    static void testScenario1()
    {
        UserRole paraRole = [SELECT Id FROM UserRole WHERE DeveloperName='Paramount'];
        // Creating user.
        Profile profilePara = [select id from profile where name='Third Party User' ];        
        User paramountUser = new User(alias = 'testPara', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara@test.com.para',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        Database.insert(paramountUser);
        Test.startTest();
        System.runAs(paramountUser)
        {
            Title__c title=testClassUtility.createTitle('Test Title 2',true);
            title.SGENNO__c='000124';
            insert title;
            
             //Deal details
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            // Creating sub label code
            Sub_Label_Code__c sub_Label_Code = new Sub_Label_Code__c();
            sub_Label_Code.Sub_Label_Code_ID__c = '59';
            sub_Label_Code.Name = 'TestsubLabelCode';
            sub_Label_Code.Label_Code__c = '59 - Paramount';
            insert sub_Label_Code;
            
            // Creating Alternative Legal Title.
            Alternative_Legal_Title__c alternativeLegalTitle = new Alternative_Legal_Title__c();
            alternativeLegalTitle.name = 'TestAlernativeLegalTitle2';
            alternativeLegalTitle.Alternative_Legal_Title_ID__c = '00000008';
            insert alternativeLegalTitle;
            
            // Creating Operation group.
            Operations_Group__c operationGroup = new Operations_Group__c(name = 'TestOperation2', Operations_Group_ID__c ='TESTId2');
            insert operationGroup;
            
            Material__c objMaterial = testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
            objMaterial = getMaterialDetails(objMaterial, title, sub_Label_Code, alternativeLegalTitle);
            objMaterial.Label_Code__c = '59 - Paramount';
            objMaterial.Material_Number__c = '89017862000';
            objMaterial.Name = 'TestMat-001';
            objMaterial.deal__C = deal.id;
            objMaterial.Label_Code__c='61 - Universal Pictures';
            insert objMaterial;
            
            // Creating valuation.
            Valuation__c valuation = getValuations(objMaterial);
            insert valuation;
            
            // Creating Plant.
            Plant__c plant = getPlants(objMaterial);
            TriggerUtility.donotexecute = TRUE;
            insert plant ;
            TriggerUtility.donotexecute = FALSE;
            
            // Creating Sales.
            Sales__c sales = getSales(objMaterial, operationGroup);
            TriggerUtility.donotexecute = TRUE;
            insert sales;
            TriggerUtility.donotexecute = FALSE;
        }
        
        Test.stopTest();
        
        // Running the test execution as Paramount user.
        System.runAs(paramountUser)
        {
            PageReference pageRef = Page.MassMaterialUpload;
            Test.setCurrentPage(pageRef);
            
            // Constructing Controller Instance 
            MassMaterialUpdateController con = new MassMaterialUpdateController();
            
            // Providing header details.
            con.header.Description__c = 'Desc';
            con.saveHeader();
            
            // Header is created.
            System.assert(con.recId != null);
            
            // Without selecting file, click import button.
            con.btnUploadCSV();
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please upload valid file')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Uploading an invalid file.
            Blob bodyBlob2 = Blob.valueOf('Material Number \n ');
            con.csvFileBody = bodyBlob2;
            con.csvAsString = 'matNo.csv';
            con.csvContentType = 'text/csv';
            con.btnUploadCSV();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please upload the file with data')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Uploading valid file.
            Blob bodyBlob = Blob.valueOf('Material Number \n 89017862000 \n 89017863000 \n 89017864000 \n 89017865000 \n 89017252000');
            con.csvFileBody = bodyBlob;
            con.btnUploadCSV();
            
            System.assert(con.totalUniqueMatNos == 5);
            System.assert(con.totalErroneousMatNos == 4);
            System.assert(con.totalEligibleMatNos == 1);
            
            for(MassMaterialUpdateController.ValidationMessage msg : con.errorMessages)
            {
                System.debug('>>>>> '+msg.materialNumber+' :: '+msg.errorMessage);
            }
            
            con.proceedAnyWay();
            System.assert(!con.hasError);
            
            con.submit();
            con.cancel();
            
            pageRef.getParameters().put('id', con.header.Id);
            pageRef.getParameters().put('retURL', '/MassUpdateHeaderView?id='+con.header.Id);
            MassMaterialUpdateController con2 = new MassMaterialUpdateController();
            con2.cancel();
        }
        
        
    }
    
    // Mass Update Material Possitive Flow 
    @isTest
    static void testScenario2()
    {
        // Creating user.
        UserRole upheRole = [SELECT Id FROM UserRole WHERE DeveloperName='UPHE_Brand'];
        Profile profileBrand = [select id from profile where name='Brand User' ];
        User brandUser = new User(alias = 'testBrnd', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand@test.com.brand',
                             Label_Code__c='61 - Universal Pictures',
                             UserRoleId=upheRole.Id,
                             isActive = true);
        Database.insert(brandUser);
        Title__c title;
        Sub_Label_Code__c sub_Label_Code;
        Alternative_Legal_Title__c alternativeLegalTitle;
        Operations_Group__c operationGroup;
        Test.startTest();
        System.runAs(brandUser)
        {
            TriggerUtility.donotexecute = TRUE;
            
            title=testClassUtility.createTitle('Test Title 3',true);
            title.SGENNO__c='000125';
            insert title;
            
            //Deal details
            Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=title.id,SGENNO__c=title.SGENNO__c,Label_Code__c='61 - Universal Pictures',Origin_Code__c = '010 - Universal Pictures');
            insert deal;
            
            // Creating sub label code
            sub_Label_Code = new Sub_Label_Code__c();
            sub_Label_Code.Sub_Label_Code_ID__c = '61';
            sub_Label_Code.Name = 'TestsubLabelCode2';
            sub_Label_Code.Label_Code__c = '61 - Universal Pictures';
            insert sub_Label_Code;
            
            // Creating Alternative Legal Title.
            alternativeLegalTitle = new Alternative_Legal_Title__c();
            alternativeLegalTitle.name = 'TestAlernativeLegalTitle3';
            alternativeLegalTitle.Alternative_Legal_Title_ID__c = '00000009';
            insert alternativeLegalTitle;
            
            // Creating Operation group.
            operationGroup = new Operations_Group__c(name = 'TestOperation3', Operations_Group_ID__c ='TESTId3');
            insert operationGroup;
            
            List<Material__c> matList = new List<Material__c>();
            Material__c objMaterial = testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
            objMaterial = getMaterialDetails(objMaterial, title, sub_Label_Code, alternativeLegalTitle);
            objMaterial.Label_Code__c = '61 - Universal Pictures';
            objMaterial.Material_Number__c = '89017862000';
            objMaterial.Name = 'TestMat-001';
            objMaterial.BOM_Long_Text__c = 'ABC';
            objMaterial.Territory__c = 'US & CDN';
            objMaterial.deal__C = deal.id;
            matList.add(objMaterial);
            
            Material__c objMaterial2 = testClassUtility.createMaterial('02 - DVD','BD','dummy2','ROH',null,TRUE,'C - Components','DS - DISC');
            objMaterial2.Label_Code__c = '61 - Universal Pictures';
            objMaterial2.Material_Number__c = '89017865';
            objMaterial2.Name = 'TestMat-002';
            objMaterial2.BOM_Long_Text__c = 'ABC';
            objMaterial2.Territory__c = 'CDN';
            
            matList.add(objMaterial2);
            
            insert matList;
            
            // Creating valuation.
            Valuation__c valuation = getValuations(objMaterial);
            insert valuation;
            
            // Creating Plant.
            Plant__c plant = getPlants(objMaterial);
            insert plant ;
            
            // Creating Sales.
            Sales__c sales = getSales(objMaterial, operationGroup);
            insert sales;
            
            // Creating Classification.
            Id clsRecTypeId = Schema.Sobjecttype.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
            Id clsCompRecTypeId = Schema.Sobjecttype.Classification__c.getRecordTypeInfosByName().get('Universal Components').getRecordTypeId();
            List<Classification__c> insClassList = new List<Classification__c>();
            Classification__c cls = new Classification__c(RecordTypeId=clsRecTypeId, Material__c=objMaterial.Id, Genre_US__c='Musical', Aspect_Ratio__c='AWS');
            insClassList.add(cls);
            Classification__c cls2 = new Classification__c(RecordTypeId=clsCompRecTypeId, Material__c=objMaterial2.Id, Genre_US__c='Musical', Aspect_Ratio__c='AWS');
            insClassList.add(cls2);
            insert insClassList;
            
            // Creating Alternative Unit of Measure
            Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c(Material__c=objMaterial.Id, Alternative_Unit_of_Measure__c='RSU - Retail Sellable Unit', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
            insert auom;
            TriggerUtility.donotexecute = FALSE;
        }
        
        Id jobId, recId;
        Test.stopTest();
        
        
        // Running the test execution as Paramount user.
        System.runAs(brandUser)
        {
            PageReference pageRef = Page.MassMaterialUpload;
            pageRef.getParameters().put('retURL', '/home/home.jsp');
            Test.setCurrentPage(pageRef);
            
            // Constructing Controller Instance 
            MassMaterialUpdateController con = new MassMaterialUpdateController();
            
            // Providing header details.
            con.header.Description__c = 'Desc';
            con.saveHeader();
            
            // Header is created.
            System.assert(con.recId != null);
            
            con.forceInclude = true;
            // Uploading valid file.
            Blob bodyBlob = Blob.valueOf('Material Number \n 89017862000 \n 89017865 \n 89017863000 \n 89017864000 \n 89017865000 \n 89017252000');
            con.csvFileBody = bodyBlob;
            con.csvAsString = 'matNo.csv';
            con.csvContentType = 'text/csv';
            
            con.btnUploadCSV();
            con.proceedAnyWay();
            System.assert(!con.hasError);
            
            con.submit();
            con.cancel();
            
            // Changing the request value (as happens in GridBuddy) 
            List<Material_Update_Request__c> mreqList = new List<Material_Update_Request__c>();
            for(Material_Update_Request__c mreq : [SELECT Id, MRP_Controller__c
                                                   FROM Material_Update_Request__c WHERE Mass_Update_Header__c=:con.recId])
            {
                mreq.MRP_Controller__c = 'PHA - Buyer/Planner PHA';
                mreqList.add(mreq);
            }
            update mreqList;
            
            jobId = MassMaterialUpdateUtility.initiateMassMaterialBatch(con.recId);
            recId = con.recId;
        }
        
        
       
    }
    
    // Testing trigger scenarios.
    @isTest
    static void testScenario3()
    {
        // Creating user.
        UserRole upheRole = [SELECT Id FROM UserRole WHERE DeveloperName='UPHE_Brand'];
        Profile profileBrand = [select id from profile where name='Brand User' ];
        User brandUser = new User(alias = 'testBrnd', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand@test.com.brand',
                             Label_Code__c='61 - Universal Pictures',
                             UserRoleId=upheRole.Id,
                             isActive = true);
        Database.insert(brandUser);
        Title__c title;
        Sub_Label_Code__c sub_Label_Code;
        Alternative_Legal_Title__c alternativeLegalTitle;
        Operations_Group__c operationGroup;
        
        System.runAs(brandUser)
        {   Test.startTest();
            Material__c objMaterial1 = testClassUtility.createMaterial('02 - DVD','UHD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
            objMaterial1.Territory__c = 'US & CDN';
            objMaterial1.Label_Code__c = '61 - Universal Pictures';
            objMaterial1.Material_Number__c = '89017252000';
            objMaterial1.Name = 'TestMat-011';
            objMaterial1.Retailer_Rental__c = 'TGT (TARGET)';
            insert objMaterial1;
            
            // Creating an existing Open Mass Header.
            Mass_Update_Header__c header = new Mass_Update_Header__c();
            insert header;
            Test.stopTest();
            // Creating an existing open request for a material.
            Material_Update_Request__c mreq1 = new Material_Update_Request__c(Mass_Update_Header__c=header.Id, Material_Number__c='89017252000', Source_Material__c=objMaterial1.Id, Sales_Org__c='V100');
            insert mreq1;
            Material_Update_Request__c mreq2 = new Material_Update_Request__c(Mass_Update_Header__c=header.Id, Material_Number__c='89017252000', Source_Material__c=objMaterial1.Id, Sales_Org__c='V800');
            insert mreq2;
            
            
            
            List<Material_Update_Request__c> upReqs = new List<Material_Update_Request__c>();
            mreq1.MPM__c = '122';
            upReqs.add(mreq1);
            mreq2.MPM__c = '123';
            upReqs.add(mreq2);
            
            try
            {
                update upReqs;
            }
            catch(Exception ex)
            {
                // Asserting error
                System.assert(ex.getMessage().contains('There are different values in field: \'MPM\' for material number: 89017252000.'));
            }
            
            
        }
    }
    
    
    // ************ Following Methods Generates Test Records ***************
    // materials details 
    private static Material__c getMaterialDetails(Material__c materialItem,Title__c titleItem,Sub_Label_Code__c subLabelCode,Alternative_Legal_Title__c alternativeLegalTitle){
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
        if(subLabelCode != null)
            materialItem.Sub_Label_Code_Lookup__c = subLabelCode.Id;// lookup
        materialItem.General_Item_Category_Group__c ='NORM - Standard item / CU';
        materialItem.Division__c = '10';
        materialItem.Xplant_Material_Status__c = 'AA';
        materialItem.Gross_Weight__c = 0.25;
        materialItem.Net_Weight__c = 0.151;
        if(alternativeLegalTitle != null)
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
        return materialItem;
    }
    
    // sub label code details
    private static Sub_Label_Code__c getSubLabelCode(){
        Sub_Label_Code__c subLabelCode =  new Sub_Label_Code__c();
        subLabelCode.Sub_Label_Code_ID__c = '49';
        subLabelCode.Name = 'TestsubLabelCode';
        subLabelCode.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO';
        return subLabelCode;
    }
    
    // alternative legal title details
    private static Alternative_Legal_Title__c getAlternativeLegalTitle(){
        Alternative_Legal_Title__c alternative_Legal_Title = new Alternative_Legal_Title__c();
        alternative_Legal_Title.name = 'TestAlernativeLegalTitle';
        alternative_Legal_Title.Alternative_Legal_Title_ID__c = '00000007';
        return alternative_Legal_Title;
    }
    
    // fetch valuation details 
    private static Valuation__c getValuations(Material__c material){
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
    private static Plant__c getPlants(Material__c material){
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
    private static Sales__c getSales(Material__c material,Operations_Group__c oppGroup){
        Sales__c sales = new Sales__c();
        sales.Material__c = material.Id;
        sales.Material_Group_2__c = 'AR';
        sales.Distribution_Channel__c = '10';
        sales.Tax_Jurisdiction_Code__c ='1';
        sales.County_Sales_Tax__c = '1';
        sales.City_Sales_Tax__c ='1';
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
        sales.Territory__c ='CDN';
        sales.Pre_Order_Date__c = Date.newInstance(1999, 01, 1); 
        sales.Deliver_Plant__c = 'D0F7';
        return sales;      
    }
    
    // operation group data 
    private static Operations_Group__c getOperation(){
        Operations_Group__c operationGroup = new Operations_Group__c(name = 'TestOperation',Operations_Group_ID__c ='TESTId');
        return operationGroup;
    }
}