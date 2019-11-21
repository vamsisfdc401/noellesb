/*****************************************************************************************
Class Name: ListManagementComponentControllerTest
Purpose: Test class for apex class ListManagementComponentController 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class wizardListManagementComponentTest {
    
    private static User userBrand;
    private static User userMasterDataAdmin;
    private static List<User> users;
    private static User objUser;
    private static Release__c objRelease;
    private static Material__c objMaterial;
    private static Title__c objTitle;
    private static Material__c objDisc;
    private static Material__c objDisc1;
    private static List<Material__c> lstMaterial = new List<Material__c>() ;
    private static List<BOM_Item__c> lstBOMItm = new List<BOM_Item__c>();
    
    static TestMethod void scenario1(){       
        
        Profile objProfile=[Select Id from Profile where Name ='System Administrator'];        
        objUser = new User(alias = 'TestUser', 
                           email='test@test.com',
                           emailencodingkey='UTF-8', 
                           lastname='Testing', 
                           languagelocalekey='en_US',
                           localesidkey='en_US', 
                           profileid=objProfile.ID,
                           country='United States',
                           timezonesidkey='America/Los_Angeles', 
                           username='testadmin345@test.com',
                           isActive = true);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Database.insert(objUser);
        }        
        
        Profile profileBrand = [select id from profile where name='Brand User' ];        
        userBrand = new User(alias = 'testBD', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand@test.com.brand',
                             isActive = true);     
        Database.insert(userBrand);
        
        Profile profileMaster = [select id from profile where name='Master Data Admin' ];        
        userMasterDataAdmin = new User(alias = 'TestMa', 
                                       email='testmaster@test.com',
                                       emailencodingkey='UTF-8', 
                                       lastname='Testing', 
                                       languagelocalekey='en_US',
                                       localesidkey='en_US', 
                                       profileid=profileMaster.ID,
                                       country='United States',
                                       timezonesidkey='America/Los_Angeles', 
                                       username='testMaster@test.com.master',
                                       isActive = true);                 
        Database.insert(userMasterDataAdmin);
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Release_Material_Formats__c objCS = new Release_Material_Formats__c(Name='test',Brand_Group__c='Universal Pictures',Components__c='O-CARD,LITHO,STICKER,INSERT',Format__c='DVD',Project_Type__c='New Release');
        insert objCS; 
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        objMaterial = new Material__c(name='dummy1',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objMaterial = new Material__c(name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objDisc = new Material__c(name='dummy3',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='dummy4',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='1231',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc1 = new Material__c(name='1232',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc1;
        
        objDisc1 = new Material__c(name='1233',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc1.Material_Type__c = 'ROH';
        objDisc1.Episode__c = objMaterial.Id ;
        objDisc1.Deletion_Flag__c = FALSE;
        insert objDisc1;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        objDisc1 = new Material__c(name='1234',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc1.Title__c = objTitle.Id;
        objDisc1.Item_Code__c = 'BF - BABY FERT';
        objDisc1.Format_Description__c = 'DVD';
        objDisc1.Material_Number__c = '123' ;
        objDisc1.Format__c = '02 - DVD';
        insert objDisc1;
        
        Material__c objDisc2 = new Material__c(name='12345',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc2.Title__c = objTitle.Id;
        objDisc2.Item_Code__c = 'BF - BABY FERT';
        objDisc2.Format_Description__c = 'DVD';
        objDisc2.Material_Number__c = '123';
        objDisc2.Format__c = '02 - DVD';
        insert objDisc2;
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US & CDN';
        insert mat1;
        
        lstMaterial.add(mat1);
        
        Attachment attach=new Attachment();        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body \n Line 2 \n Line 3');
        attach.body=bodyBlob;
        attach.parentId=mat1.id;
        insert attach;
        
        /**************** Test for ROH Proccess *********************/
        Test.startTest();  
        /**** Setting Page Reference ****/          
        PageReference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('mid',mat1.Id);
        pageRef.getParameters().put('matType','ROH');
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        wizardListManagementComponentController extController = new wizardListManagementComponentController();
        extController.searchCriteria = 'DummyTitle';
        extController.rdActivityType = 2 ;  
        extController.btnSearch();
        
        extController.first();
        extController.last();
        extController.previous();
        extController.next();
        
        extController.ParamId = objTitle.Id ;  
        
        extController.mtRowNumber = 0 ;
        extController.setSelectedTitle();
        extController.mtRowNumber = 0 ;
        extController.removeSelectedTitle();
        
        extController.mtRowNumber = 0 ;
        extController.setSelectedTitle(); 
        extController.removeAll();
        
        extController.mtRowNumber = 0 ;
        extController.setSelectedTitle();          
        extController.submit();    
        
        extController.removeAll();
        extController.submit();   
        
        extController.manualAddCriterial='DummyTitle';       
        extController.btnManualAdd();
        
        extController.csvFileBody = bodyBlob ;            
        extController.btnUploadCSV();
        
        extController.hasNext =true;
        extController.hasPrevious =true;
        extController.pageNumber=1;
        
        Boolean flag = True;
        Integer x;
        flag = extController.selectedHasNext;
        
        flag=extController.selectedHasPrevious;
        x=extController.selectedPageNumber;
        x=extController.selectedResultSize;            
        
        Test.stopTest(); 
    }
    
    static TestMethod void scenario2(){       
        
        Profile objProfile=[Select Id from Profile where Name ='System Administrator'];        
        objUser = new User(alias = 'TestUser', 
                           email='test@test.com',
                           emailencodingkey='UTF-8', 
                           lastname='Testing', 
                           languagelocalekey='en_US',
                           localesidkey='en_US', 
                           profileid=objProfile.ID,
                           country='United States',
                           timezonesidkey='America/Los_Angeles', 
                           username='testadmin345@test.com',
                           isActive = true);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Database.insert(objUser);
        }        
        
        Profile profileBrand = [select id from profile where name='Brand User' ];        
        userBrand = new User(alias = 'testBD', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand@test.com.brand',
                             isActive = true);     
        Database.insert(userBrand);
        
        Profile profileMaster = [select id from profile where name='Master Data Admin' ];        
        userMasterDataAdmin = new User(alias = 'TestMa', 
                                       email='testmaster@test.com',
                                       emailencodingkey='UTF-8', 
                                       lastname='Testing', 
                                       languagelocalekey='en_US',
                                       localesidkey='en_US', 
                                       profileid=profileMaster.ID,
                                       country='United States',
                                       timezonesidkey='America/Los_Angeles', 
                                       username='testMaster@test.com.master',
                                       isActive = true);                 
        Database.insert(userMasterDataAdmin);
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Release_Material_Formats__c objCS = new Release_Material_Formats__c(Name='test',Brand_Group__c='Universal Pictures',Components__c='O-CARD,LITHO,STICKER,INSERT',Format__c='DVD',Project_Type__c='New Release');
        insert objCS; 
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        objMaterial = new Material__c(name='dummy1',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objMaterial = new Material__c(name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objDisc = new Material__c(name='dummy3',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='dummy4',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='123',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc1 = new Material__c(name='1234',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc1;
        
        objDisc1 = new Material__c(name='1235',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc1.Material_Type__c = 'ROH';
        objDisc1.Episode__c = objMaterial.Id ;
        objDisc1.Deletion_Flag__c = FALSE;
        insert objDisc1;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        objDisc1 = new Material__c(name='1236',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Type__c='S (Single)');
        objDisc1.Title__c = objTitle.Id;
        objDisc1.Item_Code__c = 'BF - BABY FERT';
        objDisc1.Format_Description__c = 'DVD';
        objDisc1.Material_Number__c = '123';
        objDisc1.Format__c = '02 - DVD';
        objDisc1.Territory__c = 'US & CDN'; // added on 20-dec 
        insert objDisc1;
        
        Material__c objDisc2 = new Material__c(name='12347',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='C - Components');
        objDisc2.Title__c = objTitle.Id;
        objDisc2.Item_Code__c = 'BF - BABY FERT';
        objDisc2.Format_Description__c = 'DVD';
        objDisc2.Material_Number__c = '123' ;
        objDisc2.Format__c = '02 - DVD';
        objDisc1.Territory__c = 'US & CDN'; // added on 20-dec 
        insert objDisc2;
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US & CDN';
        insert mat1;
        
        lstMaterial.add(mat1);
        
        Attachment attach=new Attachment();        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body \n Line 2 \n Line 3');
        attach.body=bodyBlob;
        attach.parentId=mat1.id;
        insert attach;
        
        /**************** Test for ROH Proccess *********************/
        
        Test.startTest();
        /**** Setting Page Reference ****/
        Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('mid',mat1.Id);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        wizardListManagementComponentController extController = new wizardListManagementComponentController();
        extController.searchCriteria = '123';
        extController.rdActivityType = 3 ;  
        extController.btnSearch();
        
        extController.first();
        extController.last();
        extController.previous();
        extController.next();
        
        extController.manualAddCriterial='123';       
        extController.btnManualAdd();
        
        extController.csvFileBody = bodyBlob ;            
        extController.btnUploadCSV();
        
        extController.accept();
        
        extController.searchCriteria = '123';
        extController.rdActivityType = 1 ;  
        extController.btnSearch();
        
        extController.manualAddCriterial='123';       
        extController.btnManualAdd();
        
        extController.csvFileBody = bodyBlob ;            
        extController.btnUploadCSV();
        
        pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('mid',mat1.Id);
        pageRef.getParameters().put('matType','ROH');
        
        Test.setCurrentPage(pageRef);
        
        extController = new wizardListManagementComponentController();
        extController.searchCriteria = '123';
        extController.rdActivityType = 1 ;  
        extController.btnSearch();
        
        extController.first();
        extController.last();
        extController.previous();
        extController.next();
        
        extController.selectedFirst();
        extController.selectedLast();          
        extController.selectedPrevious();
        extController.selectedNext();
        
        
        Integer y;
        Boolean flag2;
        y=extController.selectedPageNumber;
        y=extController.selectedResultSize;
        y=extController.resultSize;
        y=extController.pageNumber;
        flag2=extController.hasNext;
        flag2=extController.hasPrevious;
        
        extController.manualAddCriterial='123';       
        extController.btnManualAdd();
        
        extController.ParamId = objDisc1.Id ;
        extController.mtRowNumber = 0 ;  
        extController.setSelectedMaterial();
        extController.mtRowNumber = 0 ;
        extController.removeSelectedMaterial();
        
        extController.manualAddCriterial='123';       
        extController.btnManualAdd();
        
        extController.mtRowNumber = 0 ;  
        extController.setSelectedMaterial();
        
        extController.submit();
        
        extController.removeAll();
        extController.submit();
        extController.csvFileBody = bodyBlob ;            
        extController.btnUploadCSV();
        
        
        Test.stopTest(); 
    }
    
    
    
    
    private static testMethod void testFertMaterialCSVFunction(){
        
        UserRole userRole =  [Select id,name from UserRole where name ='UPHE Domestic Operations' Limit 1];
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt11', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,UserRoleId = userRole.id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com11');
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Database.insert(u);
        }  
        
        
        List<Material__c>materialList  = new list<Material__c>();
        
        Release__c release = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release',Territory__c='US');
        insert release;
        
        
        // material 
        Material__c material =  testClassUtility.createMaterial('02 - DVD','DVD','materialCSV','FERT',release.Id,true,'S (Single)','SS - SINGLE SELECTION');
        material.Territory__c = 'US';
        material.Material_Number__c = '12121312312';
        material.Material_Integration_State__c = 'S';
        
        materialList.add(material);
        
        insert  materialList; 
        
        
        System.runAs(u){
            Test.startTest();
            
            List<Material__c>materialDataToProcess = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
                                                      Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                                                      Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,Xplant_Material_Status__c,Xplant_Valid_From__c,
                                                      Gross_Weight__c,Net_Weight__c,Weight_Unit__c,Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,Purchase_Value_Key__c, 
                                                      Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,
                                                      Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c
                                                      from Material__c where id IN :materialList];
            
            
            /**** Setting Page Reference ****/
            Pagereference pageRef = Page.wizardListManagementComponent;
            pageRef.getParameters().put('mid',materialDataToProcess[0].Id);
            pageRef.getParameters().put('matType',materialDataToProcess[0].Material_Type__c);
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            wizardListManagementComponentController controller = new wizardListManagementComponentController();
            
            string materialCSVString = 'name\n 12121312312 \n Line 3';
            controller.csvFileBody = blob.valueOf(materialCSVString);
            controller.csvAsString = 'Test csvfile';
            controller.csvContentType = '.csv';
            
            controller.btnUploadCSV();
            
            Test.stopTest();
        }
    }
    
     /***********************************
    Method Name: clonningScenario - csv
    Purpose:Test method for testing REL-10 Scenario 2
    ***********************************/
    
    static TestMethod void clonningScenarioCsv(){
        Profile p = [select id from profile where name='Master Data Admin']; 
        User u = new User(alias = 'standt111', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com111');
                          
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
         test.startTest();                  
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release; 
        
        Id RecordTypeIdRequest = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();

        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='12345678000';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='000';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummyROH','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        //material2.material_status__c='Processed in SAP';
        //material2.material_number__c='345679000';
        insert material2;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Material__c materialVersion1=testClassUtility.createMaterial('02 - DVD','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion1.Territory__c = 'US';
        materialVersion1.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='234';
        materialVersion1.material_number__c='12345678000';
        materialVersion1.recordTypeId=RecordTypeIdRequest;
        insert materialVersion1;
         test.stopTest();
        Material__c materialVersion2=testClassUtility.createMaterial('02 - DVD','DVD','dummy4','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion2.Territory__c = 'US';
        materialVersion2.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='231';
        materialVersion2.Selection_ID__c='345674';
        materialVersion2.recordTypeId=RecordTypeIdRequest;
        insert materialVersion2;
        
        Material__c materialVersion3=testClassUtility.createMaterial('02 - DVD','DVD','dummy5','FERT',release.id,TRUE,'M (Multipack)','CL - COLLECTION PACK');
        materialVersion3.Territory__c = 'US';
        materialVersion3.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='234';
        materialVersion3.recordTypeId=RecordTypeIdRequest;
        insert materialVersion3;
        
        Material__c materialComponent2=testClassUtility.createMaterial('02 - DVD','DVD','dummy9','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialComponent2.Territory__c = 'US';
        materialComponent2.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='234';
        materialComponent2.recordTypeId=RecordTypeIdRequest;
        insert materialComponent2;    
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=materialVersion3.id,Material_Component__c=materialComponent2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;             
                                
        Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('source','wizard');
        pageRef.getParameters().put('territory',material1.Territory__c);
        pageRef.getParameters().put('from','bomWizard');
        pageRef.getParameters().put('isClone','true');
        pageRef.getParameters().put('matID',material1.ID);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        wizardListManagementComponentController controller = new wizardListManagementComponentController();
                   
        controller.searchCriteria='02 - DVD_version';
        controller.rdActivityType=1;
        controller.btnSearch();
        
        string materialCSVString = 'name\n 12345678000 \n Line 3';
        controller.csvFileBody = blob.valueOf(materialCSVString);
        controller.csvAsString = 'Test csvfile';
        controller.csvContentType = '.csv';
        controller.btnUploadCSV();
                            
        controller.lstSelectedMaterial.add(materialVersion1);
        controller.lstSelectedMaterial.add(materialVersion2);
        controller.lstSelectedMaterial.add(materialVersion3);
        System.assertEquals(controller.lstSelectedMaterial.size(), 3);
                  
        controller.cloneBOM();                                                                                                                                                                                                                  
    }
    
    /*****************************************************************************************************
    Method Name: clonningScenario1
    Purpose:Test method for testing REL-10 Checks if BOM already exists in Versioned material else clones
    ******************************************************************************************************/
    
    
        static TestMethod void clonningScenario1(){
        Profile p = [select id from profile where name='Master Data Admin']; 
        User u = new User(alias = 'standt111', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com111');
                          
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        test.startTest();                 
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release; 
        
        Id RecordTypeIdRequest = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();

                         
                          
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='12345678000';
        material1.Selection_ID__c='00345678';
        material1.Selection_Version__c='000';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='345679000';
        insert material2;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
         test.stopTest();
        Material__c materialVersion1=testClassUtility.createMaterial('02 - DVD_version','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion1.Territory__c = 'US';
        materialVersion1.material_status__c='Processed in SAP';
        materialVersion1.Selection_ID__c='00345678';
        materialVersion1.selection_version__c='132';
        materialVersion1.material_number__c='12345678000';
        materialVersion1.recordTypeId=RecordTypeIdRequest;
        insert materialVersion1;
        
        Material__c versionCompoenent2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy9','ROH',release.id,TRUE,'C - Components','DS - DISC');
        versionCompoenent2.Territory__c = 'US';
        versionCompoenent2.material_status__c='Draft';
        versionCompoenent2.material_number__c='345629000';
        insert versionCompoenent2;    
        
        Material__c materialVersion2=testClassUtility.createMaterial('02 - DVD','DVD','dummyV','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion2.Territory__c = 'US';
        materialVersion2.material_status__c='Processed in SAP';
        materialVersion2.Selection_ID__c='00345678';
        materialVersion2.selection_version__c='132';
        materialVersion2.material_number__c='12345678000';
        materialVersion2.recordTypeId=RecordTypeIdRequest;
        insert materialVersion2;
        
        Bom_item__c bomItem2=new Bom_item__c(Material__c=materialVersion1.id,Material_Component__c=versionCompoenent2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem2;            
                                                    
        Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('source','wizard');
        pageRef.getParameters().put('territory',material1.Territory__c);
        pageRef.getParameters().put('from','bomWizard');
        pageRef.getParameters().put('isClone','true');
        pageRef.getParameters().put('matID',material1.ID);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        wizardListManagementComponentController controller = new wizardListManagementComponentController();
        
        controller.autoPopulateVersionedMaterials();
        controller.searchCriteria='DVD';
        controller.rdActivityType=1;
        controller.btnSearch();
                              
        controller.lstSelectedMaterial.add(materialVersion1);
         controller.lstSelectedMaterial.add(materialVersion2);
        
        System.assertEquals(controller.lstSelectedMaterial.size(), 2);
                   
        controller.cloneBOM();
       
                                                                                                                                                                                                                  
    }
    
    /****************************************************************************
    Method Name: clonningScenario1
    Purpose:Test method for testing REL-10 Single type shouln't cloned to single
    *****************************************************************************/
    
    
        static TestMethod void clonningScenario2(){
        Profile p = [select id from profile where name='Master Data Admin']; 
        User u = new User(alias = 'standt111', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com111');
                          
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
           test.startTest();                
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release; 
        
        Id RecordTypeIdRequest = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();                      
                          
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'M (Multipack)','CL - COLLECTION PACK');
        material1.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='12345678000';
        material1.Selection_ID__c='00345678';
        material1.Selection_Version__c='000';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('02 - DVD','DVD','dummy2','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material2.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='345679000';
        insert material2;
        
        TriggerUtility.doNotExecute = TRUE;
        Bom_item__c bomItem1=new Bom_item__c(Material__c=material1.id,Material_Component__c=material2.id,Component_Number__c='1',Component_Quantity__c='2');
        insert bomItem1;
        
        Material__c materialVersion1=testClassUtility.createMaterial('02 - DVD_version','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion1.Territory__c = 'US';
        materialVersion1.material_status__c='Draft';
        materialVersion1.Selection_ID__c='00345678';
        materialVersion1.selection_version__c='132';
        materialVersion1.material_number__c='12345678000';
        materialVersion1.recordTypeId=RecordTypeIdRequest;
        insert materialVersion1; 
         test.stopTest();
        Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('source','wizard');
        pageRef.getParameters().put('territory',material1.Territory__c);
        pageRef.getParameters().put('from','bomWizard');
        pageRef.getParameters().put('isClone','true');
        pageRef.getParameters().put('matID',material1.ID);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        wizardListManagementComponentController controller = new wizardListManagementComponentController();
        
        controller.autoPopulateVersionedMaterials();
        controller.searchCriteria='12345678000';
        controller.rdActivityType=1;
        controller.btnSearch();
                            
        controller.lstSelectedMaterial.add(materialVersion1);
        
        System.assertEquals(controller.lstSelectedMaterial.size(), 1);
                  
        controller.cloneBOM();
       
                                                                                                                                                                                                                  
    }
    
   /*******************************************************************************************************************
    Method Name: clonningScenario3
    Purpose:Test method for testing REL-10 If there are no BOM ITems present in the base material it will throw up error
    ********************************************************************************************************************/
    
    
        static TestMethod void clonningScenario3(){
        Profile p = [select id from profile where name='Master Data Admin']; 
        User u = new User(alias = 'standt111', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com111');
                          
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
                          
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release; 
        
        Id RecordTypeIdRequest = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
    
                          
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummyM','FERT',release.id,TRUE,'M (Multipack)','CL - COLLECTION PACK');
        material1.Territory__c = 'US';
        material1.material_status__c='Processed in SAP';
        material1.material_number__c='12345778000';
        material1.Selection_ID__c='00345778';
        material1.Selection_Version__c='000';
        insert material1;
              
        Material__c materialVersion1=testClassUtility.createMaterial('02 - DVD_version','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion1.Territory__c = 'US';
        materialVersion1.material_status__c='Draft';
        materialVersion1.Selection_ID__c='00345778';
        materialVersion1.selection_version__c='132';
        materialVersion1.material_number__c='12345678000';
        materialVersion1.recordTypeId=RecordTypeIdRequest;
        insert materialVersion1;
        
         Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('source','wizard');
        pageRef.getParameters().put('territory',material1.Territory__c);
        pageRef.getParameters().put('from','bomWizard');
        pageRef.getParameters().put('isClone','true');
        pageRef.getParameters().put('matID',material1.ID);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        wizardListManagementComponentController controller = new wizardListManagementComponentController();
        
        controller.autoPopulateVersionedMaterials();
        controller.searchCriteria='12345678000';
        controller.rdActivityType=1;
        controller.btnSearch();
                          
        controller.lstSelectedMaterial.add(materialVersion1);
        
        System.assertEquals(controller.lstSelectedMaterial.size(), 1);
                
        controller.cloneBOM();
       
                                                                                                                                                                                                                  
    }

    /***********************************
    Method Name: massItemQty Upload
    Purpose:Test method for testing REL-10 massItemQty Upload
    ***********************************/
    
    static TestMethod void massItemQtyUpload(){
        Profile p = [select id from profile where name='Master Data Admin']; 
        User u = new User(alias = 'standt111', email='standarduser@testorg.com1', 
                          emailencodingkey='UTF-8', lastname='Testing11', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standardusera@testorg.com111');
                          
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
                          
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release; 
        
        Id RecordTypeIdRequest = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();

                         
                          
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'D (Display Vehicle)','CU - CUBE');
        material1.Territory__c = 'US';
        insert material1;
                
        TriggerUtility.doNotExecute = TRUE;
                
        Material__c materialVersion1=testClassUtility.createMaterial('02 - DVD','DVD','dummy3','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion1.Territory__c = 'US';
        materialVersion1.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='234';
        materialVersion1.material_number__c='12345678000';
        materialVersion1.recordTypeId=RecordTypeIdRequest;
        insert materialVersion1;
        
        Material__c materialVersion2=testClassUtility.createMaterial('02 - DVD','DVD','dummy4','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialVersion2.Territory__c = 'US';
        materialVersion2.material_status__c='Draft';
        material1.selection_Id__c='00345678';
        material1.Selection_version__c='231';
        materialVersion2.Selection_ID__c='345674';
        materialVersion1.material_number__c='12345278000';
        materialVersion2.recordTypeId=RecordTypeIdRequest;
        insert materialVersion2;
        
         
        Pagereference pageRef = Page.wizardListManagementComponent;
        pageRef.getParameters().put('source','wizard');
        pageRef.getParameters().put('territory',material1.Territory__c);
        pageRef.getParameters().put('from','bomWizard');
        pageRef.getParameters().put('isClone','true');
        pageRef.getParameters().put('matID',material1.ID);
        pageRef.getParameters().put('matType','FERT');
        Test.setCurrentPage(pageRef);
        
        wizardListManagementComponentController controller = new wizardListManagementComponentController();
                    
        controller.searchCriteria='02 - DVD_version';
        controller.rdActivityType=1;
        controller.btnSearch();
        
        string materialCSVString = 'name,ItemQty\n 12345678000,2\n 12345278000,\'#\'';
        controller.csvFileBody = blob.valueOf(materialCSVString);
        controller.csvAsString = 'Test csvfile';
        controller.csvContentType = '.csv';
        controller.btnUploadCSV();
                            
        controller.lstSelectedMaterial.add(materialVersion1);
        controller.lstSelectedMaterial.add(materialVersion2);
        System.assertEquals(controller.lstSelectedMaterial.size(), 2);
        
        
        controller.accept();
       
                                                                                                                                                                                                                  
    }

  
}