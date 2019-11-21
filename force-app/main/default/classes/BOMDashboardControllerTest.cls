/*****************************************************************************************
Class Name: BOMDashboardControllerTest
Purpose: Test class for apex class BOMDashboardController 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/07/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class BOMDashboardControllerTest {
    
    private static User userBrand;
    private static User userMasterDataAdmin;
    private static List<User> users;
    private static User objUser;
    private static Release__c objRelease;
    private static Material__c objMaterial;
    private static Title__c objTitle;
    private static Material__c objDisc;
    private static Material__c objDisc1;
    private static List<BOM_Item__c> lstBOMItm = new List<BOM_Item__c>();
    
    /************************************
    Method Name: scenario1
    Purpose: for covering test scenarios
    *************************************/
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
        Test.startTest();
        objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release_Material_Formats__c objCS = new Release_Material_Formats__c(Name='test',Brand_Group__c='Universal Pictures',Components__c='O-CARD,LITHO,STICKER,INSERT',Format__c='DVD',Project_Type__c='New Release');
        insert objCS; 
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        objMaterial = new Material__c(name='dummy1',Label_Code__c='24 - PURE FLIX', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        objDisc = new Material__c(name='dummy2',Label_Code__c='24 - PURE FLIX', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc;
        
        objDisc1 = new Material__c(name='dummy3',Label_Code__c='24 - PURE FLIX', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=FALSE,Item_Code__c = 'DS (DISC)',Item_Type__c='Capitalized Component (ROH)');
        insert objDisc1;
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'Test Material';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US & CDN';
        insert mat1;
        
        for(integer i=1;i<=55;i++){
            BOM_Item__c obj = new BOM_Item__c();
            obj.Material__c = objMaterial.id;
            obj.Material_Component__c = objDisc1.id;
            obj.Territory__c = objMaterial.Territory__c;
            lstBOMItm.add(obj);
        }
        
        insert lstBOMItm;
        
        PageReference pageRef = Page.BOMDashBoard;
        Test.setCurrentPage(pageRef);
        
        String cquery = 'SELECT CaseNumber FROM Case LIMIT 1';
        ApexPages.StandardSetController CS = new ApexPages.StandardSetController(lstBOMItm);
        BOMDashboardController extController = new BOMDashboardController(CS);
        BOMDashboardController classInstance = new BOMDashboardController();
        extController.getBOMItemList();
        extController.first();
        extController.last();
        extController.previous();
        extController.next();
        extController.toggleSort();
        //extController.hasNext =true;
        //extController.hasPrevious =true;
        //extController.pageNumber=1;
        System.AssertEquals(True,extController.hasNext);
        System.AssertEquals(FALSE,extController.hasPrevious);
        System.AssertEquals(1,extController.pageNumber); 
        extController.saveRecordId = objMaterial.id;
        extController.saveBOMId = lstBOMItm[0].id;
        extController.saveEachRecords();           
        
        Test.stopTest(); 
    }        
}