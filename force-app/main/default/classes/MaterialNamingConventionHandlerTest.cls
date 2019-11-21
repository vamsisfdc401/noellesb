/*****************************************************************************************
Class Name: MaterialNamingConventionHandlerTest
Purpose: Test class for apex class MaterialNamingConventionHandler 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             15/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class MaterialNamingConventionHandlerTest{
    
    private static Release__c objRelease;
    private static Material__c objMaterial;
    private static Title__c objTitle;
    
    static TestMethod void scenario1(){
        Test.startTest();
        
        Profile profileBrand = [select id from profile where name='Platform API'];        
        User userBrand = new User(alias = 'testBD', 
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
        
        objRelease = new Release__c(Name='Test Release Length for Greater than 21 values',
                                    Street_Date__c = Date.Today(),Brand_Group__c='TV',
                                    Project_Type__c = 'Catalog',
                                    Promotion_Name_Abbreviation__c = 'Test', 
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE, 
                                Title_Abbreviation__c = 'TestAbbreviation Lng',
                                Sort_Name__c = 'SortName Length for Greater than 21 values');
        insert objTitle;
        
        objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'D (Display Vehicle)', 
                                      Item_Code__c='SS (Single Selection)', Format_Description__c = 'COMBO PACK', 
                                      Retailer_Rental__c='Test Rent Retailer');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    static TestMethod void scenario2(){
        Test.startTest();             
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,
                                Title_Abbreviation__c = '', Sort_Name__c = 'A',SGENNO__c='12345');
        insert objTitle;
        
        objMaterial = new Material__c(name='dummy',Material_Type__c= 'ROH',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Title__c=objTitle.Id,
                                      Format_Description__c = 'CONTRA', Retailer_Rental__c='A');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        objMaterial = new Material__c(name='dummy2',Material_Type__c= 'FERT',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US & CDN', Item_type__c= 'S (Single)', 
                                      Item_Code__c='BF - BABY FERT', Title__c=objTitle.Id,
                                      Format_Description__c = 'DVD', Retailer_Rental__c='A', Format__c='02 - DVD');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        MaterialNamingConventionHandler.getFERTMaterialName(objMaterial, objRelease, objTitle);
        
        Test.stopTest();
    }
    
    static TestMethod void scenario3(){
        Test.startTest();
        
        objRelease = new Release__c(Name='Test Release Length for Greater than 21 values',
                                    Street_Date__c = Date.Today(),Brand_Group__c='TV',
                                    Project_Type__c = 'Catalog',
                                    Promotion_Name_Abbreviation__c = 'Test', 
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE, 
                                Title_Abbreviation__c = '', /*TestAbbreviation Lng*/
                                Sort_Name__c = 'SortName Length for Greater than 21 values',SGENNO__c='12345');
        insert objTitle;
        
        objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Format_Description__c = 'COMBO PACK', 
                                      Retailer_Rental__c='Test Rent Retailer', Title__c=objTitle.Id);
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        MaterialNamingConventionHandler.getFERTMaterialName(objMaterial, objRelease, objTitle);
        
        Test.stopTest();
    }
    
    static TestMethod void scenario4(){
        Test.startTest();
        
        objRelease = new Release__c(Name='Test Release Length for Greater than 21 values',
                                    Street_Date__c = Date.Today(),Brand_Group__c='TV',
                                    Project_Type__c = 'Catalog',
                                    Promotion_Name_Abbreviation__c = 'Test', 
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,                                
                                Sort_Name__c = 'SortName Length for Greater than 21 values');
        insert objTitle;
        
        objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Format_Description__c = 'COMBO PACK', 
                                      Retailer_Rental__c='Test Rent Retailer');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    static TestMethod void scenario5(){
        Test.startTest();
        
        objRelease = new Release__c(Name='Test Release Length for Greater than 21 values',
                                    Street_Date__c = Date.Today(),Brand_Group__c='TV',
                                    Project_Type__c = 'Catalog',
                                    Promotion_Name_Abbreviation__c = 'Test', 
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE, 
                                Title_Abbreviation__c = null,                               
                                Sort_Name__c = 'SortName Length for Greater than 21 values',SGENNO__c='12345');
        insert objTitle;
        
        objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Format_Description__c = 'CONTRA', 
                                      Retailer_Rental__c='Test Rent Retailer', Title__c=objTitle.Id);
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    static TestMethod void scenario6(){
        
        Test.startTest();        
        
        ComponentNamingConventions__c cnc = new ComponentNamingConventions__c(Name = 'DISC',Abbreviation__c ='DISC');
        Database.insert(cnc);     
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,
                                Title_Abbreviation__c = 'TitleAbbr', Sort_Name__c = 'A',SGENNO__c='12345');
        insert objTitle;
        
        objMaterial = new Material__c(name='DVD',Material_Type__c= 'ROH',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Title__c=objTitle.Id,
                                      Format_Description__c = 'COMBO PACK', Retailer_Rental__c='A',
                                      Component_Type_Abbreviation__c = 'OCARD');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    static TestMethod void scenario7(){
        
        Test.startTest();        
        
        ComponentNamingConventions__c cnc = new ComponentNamingConventions__c(Name = 'DISC DVD',Abbreviation__c ='DISC');
        Database.insert(cnc);     
        
        objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,
                                Title_Abbreviation__c = 'TitleAbbr', Sort_Name__c = 'A');
        insert objTitle;
        
        objMaterial = new Material__c(name='DISC',Material_Type__c= 'ROH',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Component_Type_Abbreviation__c = 'OCARD',
                                      Format_Description__c = 'COMBO PACK', Retailer_Rental__c='A');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
    static TestMethod void scenario8(){
        
        Test.startTest();        
        
        ComponentNamingConventions__c cnc = new ComponentNamingConventions__c(Name = 'DISC BD',Abbreviation__c ='DISC');
        Database.insert(cnc);   
        
        Component_ItemCode_Mapping__c cim = new Component_ItemCode_Mapping__c(Name = 'DISC BD', Item_Code__c = 'DS - DISC');  
        Database.insert(cim);
        
        objRelease = new Release__c(Name='Test Release Length for Greater than 21 values',
                                    Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',
                                    Territory__c = 'CDN');
        insert objRelease;
        
        objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=TRUE,
                                Title_Abbreviation__c = 'TitleAbbr', Sort_Name__c = 'A');
        insert objTitle;
        
        objMaterial = new Material__c(name='DISC BD',Material_Type__c= 'ROH',Release__c = objRelease.id,
                                      Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', 
                                      Item_Code__c='SS (Single Selection)', Component_Type_Abbreviation__c = 'OCARD',
                                      Format_Description__c = 'COMBO PACK', Retailer_Rental__c='A',
                                      Component_Type__c = 'DISC BD', Format__c = '09 - BLU-RAY');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Test.stopTest();
    }
    
}