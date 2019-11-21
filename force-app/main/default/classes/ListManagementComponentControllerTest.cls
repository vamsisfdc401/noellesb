/*****************************************************************************************
Class Name: ListManagementComponentControllerTest
Purpose: Test class for apex class ListManagementComponentController 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class ListManagementComponentControllerTest {
    
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
                           //UserRoleId=objRole.Id, 
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
       
        Release_Material_Formats__c objCS = new Release_Material_Formats__c(Name='test1',Brand_Group__c='Universal Pictures',Components__c='O-CARD,LITHO,STICKER,INSERT',Format__c='DVD',Project_Type__c='New Release');
        insert objCS; 
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease; 
        
        objMaterial = new Material__c(name='dummy1',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objMaterial = new Material__c(name='dummy2',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objDisc = new Material__c(name='dummy3',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='123',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
       
        objDisc1 = new Material__c(name='1235',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc1;
               
        objDisc1 = new Material__c(name='1232',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'SS - SINGLE SELECTION',Item_Type__c='S (Single)');
        //objDisc1.Material_Type__c = 'Episode (HEEP)';
        objDisc1.Episode__c = objMaterial.Id ;
        objDisc1.Deletion_Flag__c = FALSE;
        insert objDisc1;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        objDisc1 = new Material__c(name='122323',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'SS - SINGLE SELECTION',Item_Type__c='Capitalized Component (ROH)');
        objDisc1.Title__c = objTitle.Id;
        objDisc1.Item_Code__c = 'BF - BABY FERT';
        objDisc1.Format_Description__c = 'DVD';
        objDisc1.Format__c = '02 - DVD';
        objDisc1.Material_Number__c = '123' ;
        insert objDisc1;
        
        Material__c objDisc2 = new Material__c(name='New323',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc2.Title__c = objTitle.Id;
        objDisc2.Item_Code__c = 'BF - BABY FERT';
        objDisc2.Format_Description__c = 'DVD';
        objDisc2.Format__c = '02 - DVD';
        objDisc2.Material_Number__c = '123' ;
        insert objDisc2;
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US & CDN';
        mat1.Label_Code__c='24 - PURE FLIX';
        insert mat1;
        
        lstMaterial.add(mat1);
       
        Attachment attach=new Attachment();        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body \n Line 2 \n Line 3');
        attach.body=bodyBlob;
        attach.parentId=mat1.id;
        insert attach;
       
        /**************** Test for Title Proccess *********************/      
        Test.startTest(); // ADDED ON 14.12     
            /**** Setting Page Reference ****/         
            PageReference pageRef = Page.ListManagementComponent;
            pageRef.getParameters().put('mid',mat1.Id);
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            ListManagementComponentController extController = new ListManagementComponentController();
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
    
            extController.cancelSelection();
            
        Test.stopTest(); 
    }
 
    static TestMethod void scenario2(){       
        //Test.startTest();
        Profile objProfile=[Select Id from Profile where Name ='System Administrator'];        
        objUser = new User(alias = 'TestUser', 
                           email='test@test.com',
                           emailencodingkey='UTF-8', 
                           lastname='Testing', 
                           languagelocalekey='en_US',
                           localesidkey='en_US', 
                           //UserRoleId=objRole.Id, 
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
       
        Release_Material_Formats__c objCS = new Release_Material_Formats__c(Name='te31st',Brand_Group__c='Universal Pictures',Components__c='O-CARD,LITHO,STICKER,INSERT',Format__c='DVD',Project_Type__c='New Release');
        insert objCS; 
        
        objRelease = new Release__c(Name='Test Relea13se',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease; 
        
        objMaterial = new Material__c(name='dumm232334y',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objMaterial = new Material__c(name='d23ummy',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        lstMaterial.add(objMaterial);
        
        objDisc = new Material__c(name='dummy1',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc = new Material__c(name='12311',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        lstMaterial.add(objDisc);
        
        objDisc1 = new Material__c(name='1232333',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc1;
        
        objDisc1 = new Material__c(name='123332',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'SS - SINGLE SELECTION',Item_Type__c='S (Single)');
        //objDisc1.Material_Type__c = 'Episode (HEEP)';
        objDisc1.Episode__c = objMaterial.Id ;
        objDisc1.Deletion_Flag__c = FALSE;
        insert objDisc1;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        objDisc1 = new Material__c(name='12123',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc1.Title__c = objTitle.Id;
        objDisc1.Item_Code__c = 'BF - BABY FERT';
        objDisc1.Format__c = '02 - DVD';
        objDisc1.Format_Description__c = 'DVD';
        objDisc1.Material_Number__c = '123' ;
        insert objDisc1;
        
        Material__c objDisc2 = new Material__c(name='114423',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        objDisc2.Title__c = objTitle.Id;
        objDisc2.Item_Code__c = 'BF - BABY FERT';
        objDisc2.Format_Description__c = 'DVD';
        objDisc2.Format__c = '02 - DVD';
        objDisc2.Material_Number__c = '123' ;
        //insert objDisc2;
        
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
             
      /**************** Test for Episode Proccess *********************/
       Test.startTest();
            /**** Setting Page Reference ****/
            PageReference pageRef = Page.ListManagementComponent;
            pageRef.getParameters().put('mid',mat1.Id);
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            ListManagementComponentController extController = new ListManagementComponentController();
            extController.searchCriteria = '12123';
            extController.rdActivityType = 3 ;  
            extController.btnSearch();
      
            extController.first();
            extController.last();
            extController.previous();
            extController.next();
           
            extController.ParamId = objDisc1.Id ;
            
            extController.mtRowNumber = 1 ;
            //extController.setSelectedEpisode();
            extController.mtRowNumber = 1 ;
            extController.removeSelectedEpisode();
            
            extController.mtRowNumber = 1 ;
            //extController.setSelectedEpisode(); 
            extController.removeAll();
            
            extController.mtRowNumber = 1 ;
            //extController.setSelectedEpisode();          
            extController.submit();    
            
            
            extController.manualAddCriterial='12123';       
            extController.btnManualAdd();
            
            extController.csvFileBody = bodyBlob ;            
            extController.btnUploadCSV();
            
      /**************** Test for Material Proccess *********************/       
            
            /**** Setting Page Reference ****/
            pageRef = Page.ListManagementComponent;
            pageRef.getParameters().put('mid',mat1.Id);
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            extController = new ListManagementComponentController();
            extController.manualAddCriterial = '12123';
            extController.rdActivityType = 1 ;
            
            extController.manualAddCriterial='12123';       
            extController.btnManualAdd();
            
            extController.searchCriteria = '12123';
            extController.rdActivityType = 1 ;  
            extController.btnSearch();
 
            extController.first();
            extController.last();
            extController.previous();
            extController.next();
            
            
            boolean b3 = extController.hasPrevious;
            boolean b4 = extController.hasNext;
            integer intPG = extController.pageNumber;
             
            extController.ParamId = objDisc1.Id ;    
                      
            extController.mtRowNumber = 0 ;  
            extController.setSelectedMaterial();
            extController.selectedLast();
            extController.selectedFirst();
            boolean b1 = extController.selectedHasPrevious;
            boolean b2 = extController.selectedHasNext;
            extController.mtRowNumber = 0 ;
            extController.removeSelectedMaterial();
            
            extController.csvFileBody = bodyBlob ;            
            extController.btnUploadCSV();
            
            extController.searchCriteria = '12123';
            extController.rdActivityType = 1 ;  
            extController.btnSearch();
            
            extController.submit(); 
            PageReference returnPage1= extController.cancelSelected();
            PageReference returnPage2= extController.sendDirecttoSAP();
            extController.selectedNext();
            extController.selectedPrevious();
            //extController.selectedLast();
            //extController.selectedFirst();
            Integer returnNum = extController.resultSize;
            
            PageReference pageRef1 = Page.ListManagementComponent;
            //pageRef1.getParameters().put('mid','');
            pageRef1.getParameters().put('source','materiallistview');
            Test.setCurrentPage(pageRef1);
            /*ListManagementComponentController extController1 = new ListManagementComponentController();
            extController1.rdActivityType = 1 ;
            extController1.btnUploadCSV();     
            extController1.submit(); */
            Test.stopTest();    
            
        
    }
    
    
    
    
   private static testMethod void testMaterialListFunctionality(){
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Title__c title = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE);
        insert title;
        
        Release__c release = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert release ; 
        
        Material__c material = new Material__c(name='dummy2',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = release.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        materialList.add(material);
        
        Material__c objMaterialComponent = new Material__c(name='dummy1',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = release.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        lstMaterial.add(objMaterialComponent);
        
        // inserting the material list
        insert materialList;
        
        Test.StartTest();
            PageReference pageRef1 = Page.ListManagementComponent;
            pageRef1.getParameters().put('source','materiallistview');
            pageRef1.getParameters().put('mid',material.id);
            Test.setCurrentPage(pageRef1);
            ListManagementComponentController contrl= new ListManagementComponentController();
            contrl.rdActivityType = 1 ;
            contrl.searchCriteria = '12123';
            contrl.btnSearch();
            contrl.accept();
            //contrl.setSelectedEpisode();
            
        Test.StopTest();
        
    }         
    
    private static testMethod void testScenario5(){
        
        List<Material__c>materialList =  new list<Material__c>();
        
        Title__c title = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE);
        insert title;
        
        Release__c release = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert release ; 
        
        Material__c material = new Material__c(name='dummy2',Material_Type__c= 'FERT',Label_Code__c='24 - PURE FLIX',Release__c = release.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        materialList.add(material);
        
        Material__c objMaterialComponent = new Material__c(name='dummy1',Material_Type__c= 'ROH',Label_Code__c='24 - PURE FLIX',Release__c = release.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        lstMaterial.add(objMaterialComponent);
        
        // inserting the material list
        insert materialList;
        
        Test.StartTest();
            PageReference pageRef1 = Page.ListManagementComponent;
            pageRef1.getParameters().put('source','materiallistview');
            //pageRef1.getParameters().put('mid',material.id);
            Test.setCurrentPage(pageRef1);
            ListManagementComponentController contrl= new ListManagementComponentController();
            contrl.rdActivityType = 1 ;
            contrl.manualAddCriterial= '12123';
            contrl.btnManualAdd();
            contrl.accept();
            //contrl.setSelectedEpisode();
            
        Test.StopTest();
        
    }         
}