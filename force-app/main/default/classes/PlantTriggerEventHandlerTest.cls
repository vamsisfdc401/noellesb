/*****************************************************************************************
Class Name: PlantTriggerEventHandlerTest
Purpose: Test class for apex class PlantTriggerEventHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             18/10/2016           Ashwini Gnanamurthy      Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class PlantTriggerEventHandlerTest{
    
    static TestMethod void scenario1(){       
        Test.startTest();       
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease; 
        
        Material__c objMaterial = new Material__c(name='dummy',Label_Code__c='24 - PURE FLIX', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        
        Plant__c planttest = new Plant__c(Material__c = objMaterial.Id);
        Database.insert(planttest);
        
        planttest.Function__c = '023';
        Database.update(planttest);
        
        planttest.Deletion_Flag__c= true;
        Database.update(planttest);
        
        
        Test.stopTest();
    }
    
    static TestMethod void scenario2(){  
        Test.startTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Platform API' LIMIT 1];
        
        User platformUser = new User(LastName = 'Last',
                                     FirstName='Test',
                                     Alias = 'jliv',
                                     Email = 'test@nbcutest.com',
                                     Username = 'test@nbcutest.com',
                                     ProfileId = profileId.id,
                                     TimeZoneSidKey = 'GMT',
                                     LanguageLocaleKey = 'en_US',
                                     EmailEncodingKey = 'UTF-8',
                                     LocaleSidKey = 'en_US'
                                    );
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease; 
        
        Material__c objMaterial = new Material__c(name='dummy',Label_Code__c='24 - PURE FLIX', Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        insert objMaterial;
        
        
        system.runas(platformUser){   
            
            System.debug('Current User: ' + UserInfo.getProfileId());
            
            Plant__c planttest2 = new Plant__c(Material__c = objMaterial.Id);
            Database.insert(planttest2);
            
            planttest2.Function__c = '023';
            Database.update(planttest2);
            
            planttest2.Deletion_Flag__c= true;
            Database.update(planttest2);
            
        }
        Test.stopTest();
    }
    
}