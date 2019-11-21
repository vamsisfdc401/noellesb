/*****************************************************************************************
Class Name: PlantTriggerHandlerTest
Purpose: Test class for apex class PlantTriggerHandlerTest 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class PlantTriggerHandlerTest {
    
    static TestMethod void scenario1(){       
        Test.startTest();
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease; 
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='ME - TV MULTIPLE EPISODES');
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        insert objMaterial;
        
        Plant__c planttest = new Plant__c(Material__c = objMaterial.Id);
        Database.insert(planttest);
        
        Test.stopTest();
    }
    
}