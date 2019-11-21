/*****************************************************************************************
Class Name: AlterUnitOfMeasureTriggerHandlerTest
Purpose: Test class of AlterUnitOfMeasureTriggerHandler.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/10/2016                                    Initial Development
******************************************************************************************/
@isTest(SeeAllData = FALSE)
public class AlterUnitOfMeasureTriggerHandlerTest {
    
    @isTest
    public static void Scenario1(){
    Test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); 
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.RecordtypeId = recTypeId;
        objMaterial1.Territory__c = 'CDN'; // OVER COME NULL POINTER ERROR
        insert objMaterial1;
        
       Alternative_Unit_of_Measure__c aum = new Alternative_Unit_of_Measure__c();
       aum.Material__c = objMaterial1.Id; 
       Insert aum;
       
       Alternative_Unit_of_Measure__c aum1 = new Alternative_Unit_of_Measure__c();
       aum1.Material__c = objMaterial1.Id; 
       aum1.Alternative_Unit_of_Measure__c= 'RSU - Retail unit';
       Insert aum1;
       
       //AlterUnitOfMeasureTriggerHandler.executeOnBeforeInsert();
       //AlterUnitOfMeasureTriggerHandler.executeOnBeforeUpdate();
       
      Test.stopTest();    
    }
    
 
    @isTest
    public static void Scenario2(){
    Test.startTest();
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); 
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.RecordtypeId = recTypeId;
        objMaterial1.Territory__c = 'CDN';  //OVER COME NULL POINTER ERROR
        insert objMaterial1;
        
       Alternative_Unit_of_Measure__c aum = new Alternative_Unit_of_Measure__c();
       aum.Material__c = objMaterial1.Id; 
       aum.Alternative_Unit_of_Measure__c= 'EA - Each';
       Insert aum;
       
       Alternative_Unit_of_Measure__c aum1 = new Alternative_Unit_of_Measure__c();
       aum1.Material__c = objMaterial1.Id; 
       aum1.Alternative_Unit_of_Measure__c= 'RSU - Retail unit';
       Insert aum1; 
       
       //AlterUnitOfMeasureTriggerHandler.executeOnBeforeInsert();
       //AlterUnitOfMeasureTriggerHandler.executeOnBeforeUpdate();
       
      Test.stopTest();    
    }   
 }