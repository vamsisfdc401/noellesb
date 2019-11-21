/*****************************************************************************************
Class Name: update_Insert_ReleaseDateTest
Purpose: Test class for apex trigger update_Insert_ReleaseDate  on Release
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Viraj                    Initial Development
******************************************************************************************/
@IsTest(SeeAllData=false)
private class update_Insert_ReleaseDateTest {
    
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
            objUser.Brand_Group__c = 'Partners' ;
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
        System.runas(objUser){
            objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,SGENNO__c='12345');
            insert objTitle;
            
            Title__c objTitle2 = new Title__c(Name='DummyTitle2',Active_Flag__c=TRUE,SGENNO__c='26475');
            insert objTitle2;
            
            /***** Condition : With Distributer Date HE_Major = TRUE *****/
            
            Distributor_Date__c objDDate = new Distributor_Date__c(Distributor__c = 'A24 Films',HE_Major__c= TRUE);
            objDDate.Start_Date__c = System.TODAY();
            objDDate.End_Date__c = System.TODAY() + 15 ;
            objDDate.Theatrical_to_BD_DVD__c = 2;
            objDDate.Theatrical_to_VOD__c = 3;
            objDDate.EST_to_BD_DVD__c = 4;
            insert objDDate;
            
            objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',
                                        Project_Type__c = 'New Release', Title__c = objTitle.Id, Distributor__c = 'BST',
                                        First_Theatrical_Date__c = SYSTEM.TODAY(),EST_Date__c = SYSTEM.TODAY(),
                                        VOD_Street_Date__c = SYSTEM.TODAY() + 2 , Alternate_Physical_Street_Date__c = SYSTEM.TODAY()
                                        ,Alternate_EST_Date__c = SYSTEM.TODAY() , Alternate_VOD_Date__c = SYSTEM.TODAY());
            
            objRelease.Label_Code__c = '62 - Focus' ;
            insert objRelease;
            
            Release_Date__c relDate = new Release_Date__c();
            relDate.Release__c = objRelease.id;
            relDate.Release_Date_Type__c = 'EST Date';
            relDate.Release_Date__c = objRelease.EST_Date__c;
            relDate.Distributor__c = objRelease.Distributor__c;
            relDate.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate.Visual_Format__c = objRelease.Visual_Format__c;
            relDate.Brand_Group__c = objRelease.Brand_Group__c;
            relDate.Label_Code__c = objRelease.Label_Code__c;
            relDate.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate;
            
            Release_Date__c relDate1 = new Release_Date__c();
            relDate1.Release__c = objRelease.id;
            relDate1.Release_Date_Type__c = 'Alternate Street Date';
            relDate1.Release_Date__c = objRelease.Alternate_Physical_Street_Date__c;
            relDate1.Distributor__c = objRelease.Distributor__c;
            relDate1.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate1.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate1.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate1.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate1.Visual_Format__c = objRelease.Visual_Format__c;
            relDate1.Brand_Group__c = objRelease.Brand_Group__c;
            relDate1.Label_Code__c = objRelease.Label_Code__c;
            relDate1.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate1;
            
            Release_Date__c relDate2 = new Release_Date__c();
            relDate2.Release__c = objRelease.id;
            relDate2.Release_Date_Type__c = 'Alternate EST Date';
            relDate2.Release_Date__c = objRelease.Alternate_EST_Date__c;
            relDate2.Distributor__c = objRelease.Distributor__c;
            relDate2.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate2.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate2.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate2.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate2.Visual_Format__c = objRelease.Visual_Format__c;
            relDate2.Brand_Group__c = objRelease.Brand_Group__c;
            relDate2.Label_Code__c = objRelease.Label_Code__c;
            relDate2.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate2;
            
            Release_Date__c relDate3 = new Release_Date__c();
            relDate3.Release__c = objRelease.id;
            relDate3.Release_Date_Type__c = 'Alternate VOD Street Date';
            relDate3.Release_Date__c = objRelease.Alternate_VOD_Date__c;
            relDate3.Distributor__c = objRelease.Distributor__c;
            relDate3.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate3.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate3.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate3.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate3.Visual_Format__c = objRelease.Visual_Format__c;
            relDate3.Brand_Group__c = objRelease.Brand_Group__c;
            relDate3.Label_Code__c = objRelease.Label_Code__c;
            relDate3.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate3;
            
            Release_Date__c relDate4 = new Release_Date__c();
            relDate4.Release__c = objRelease.id;
            relDate4.Release_Date_Type__c = 'Street Date';
            relDate4.Release_Date__c = objRelease.Street_Date__c;
            relDate4.Distributor__c = objRelease.Distributor__c;
            relDate4.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate4.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate4.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate4.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate4.Visual_Format__c = objRelease.Visual_Format__c;
            relDate4.Brand_Group__c = objRelease.Brand_Group__c;
            relDate4.Label_Code__c = objRelease.Label_Code__c;
            relDate4.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate4;
            
            Release_Date__c relDate5 = new Release_Date__c();
            relDate5.Release__c = objRelease.id;
            relDate5.Release_Date_Type__c = 'Theatrical Release Date';
            relDate5.Release_Date__c = objRelease.First_Theatrical_Date__c;
            relDate5.Distributor__c = objRelease.Distributor__c;
            relDate5.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate5.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate5.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate5.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate5.Visual_Format__c = objRelease.Visual_Format__c;
            relDate5.Brand_Group__c = objRelease.Brand_Group__c;
            relDate5.Label_Code__c = objRelease.Label_Code__c;
            relDate5.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate5;
            
            Release_Date__c relDate6 = new Release_Date__c();
            relDate6.Release__c = objRelease.id;
            relDate6.Release_Date_Type__c = 'VOD Street Date';
            relDate6.Release_Date__c = objRelease.VOD_Street_Date__c;
            relDate6.Distributor__c = objRelease.Distributor__c;
            relDate6.Distributor_Short_Name__c = objRelease.Distributor_Short_Name__c;
            relDate6.DOM_Box_Office_Total__c = objRelease.DOM_Box_Office_Total__c;
            relDate6.DOM_Open_W_E_Total__c = objRelease.DOM_Open_W_E_Total__c;
            relDate6.Release_Pattern__c = objRelease.Release_Patterns__c;
            relDate6.Visual_Format__c = objRelease.Visual_Format__c;
            relDate6.Brand_Group__c = objRelease.Brand_Group__c;
            relDate6.Label_Code__c = objRelease.Label_Code__c;
            relDate6.Acquisition__c = objRelease.Acquisition__c; 
            insert relDate6;
            
            objRelease.Alternate_Physical_Street_Date__c =  SYSTEM.TODAY() + 5 ;
            objRelease.Alternate_EST_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.Alternate_VOD_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.EST_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.First_Theatrical_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.Street_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.VOD_Street_Date__c = SYSTEM.TODAY() + 5 ;
            objRelease.Distributor__c = 'Universal';
            objRelease.DOM_Box_Office_Total__c = 1;
            objRelease.DOM_Open_W_E_Total__c = 2;
            objRelease.Label_Code__c = '61 - Universal Pictures';
            
            update objRelease;
            
            //chatterOnDateUpdate.chatterOnMaterialDateUpdate(trigger.new);

        }
        Test.stopTest(); 
    }  
}