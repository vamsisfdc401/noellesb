/***********************************************************************************
Class Name: DGF_EPOBonusTriggerHandlerTest
Purpose: Test class for apex class DGF_EPOBonusTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/04/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_EPOBonusTriggerHandlerTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-35-Film Bonus
    ***********************************/
    static testMethod void scenario1() {
        //getting record type for EPO&Bonus
        Id FilmEPORecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get(DGF_Constants.FILM_BONUS).getRecordTypeId();    
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
         //create Account records
        Account acc= new Account (EST_Only__c = 'EST', Name = 'iTunes', RecordTypeId = AccRecTypeId, Categorization__c ='Current' ,Scripted_Reality__c ='Reality' ,Network_Categorization__c ='Bravo' , Bonus__c = 'Season Only');
        insert acc;
        //getting list of EPOBonus records to be created
        List<EPO_Bonus__c> insertEPO = DGF_TestDataUtility.createEPOBonus(10,FilmEPORecTypeId);
        test.startTest();
        //Creating EPO Record
        insertEPO[0].package__c = 'A la carte';
        insertEPO[0].platform__c = 'EST';
        insert insertEPO;
        LIST<Digital_Date__C> lstDD=[SELECT ID,Release_Date__C from Digital_Date__c where EPO_Bonus__c=:insertEPO[0].id];
        update insertEPO[0];
        list<EPO_Bonus__c>epoList=[SELECT ID FROM EPO_Bonus__c];
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-35-TV Bonus
    ***********************************/
    static testMethod void scenario2() {
        //getting record type for EPO&Bonus
        Id TVRecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get(DGF_Constants.TV_BONUS).getRecordTypeId();    
        //getting list of EPOBonus records to be created
        List<EPO_Bonus__c> insertEPO = DGF_TestDataUtility.createEPOBonus(10,TVRecTypeId);
        test.startTest();
        //create TV Bonus EPO
        insert insertEPO;
        
        LIST<Digital_Date__C> lstDD=[SELECT ID,Release_Date__C from Digital_Date__c where EPO_Bonus__c=:insertEPO[0].id];
        System.assertEquals(date.today(),lstDD[0].release_date__c);
        //update dates of the EPO
        insertEPO[0].US_End_Date__c = date.today()+1;
        insertEPO[0].US_Start_Date__c = date.today()+1;
        insertEPO[0].CA_Start_Date__c = date.today()+1;
        insertEPO[0].CA_End_Date__c = date.today()+1;
        update insertEPO[0];
        
        insertEPO[0].US_End_Date__c = NULL;
        insertEPO[0].US_Start_Date__c = NULL;
        insertEPO[0].CA_Start_Date__c = NULL;
        insertEPO[0].CA_End_Date__c = NULL;
        update insertEPO[0];
        delete  insertEPO[0];
        test.stopTest();
    }
      /***********************************
    Method Name: scenario3
    Purpose: method to test code for DFOR-153
    ***********************************/
    static testMethod void scenario3() {
        
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get('TV Bonus').getRecordTypeId();
        //create Account records
        Account acc= new Account (Name = 'iTunes', RecordTypeId = AccRecTypeId, Categorization__c ='Current' ,Scripted_Reality__c ='Reality' ,Network_Categorization__c ='Bravo' , Bonus__c = 'Season Only');
        insert acc;
        System.AssertEquals( TRUE , acc.id != null , 'Account Record not Created');
        
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, TVRecTypeId);
        insertdgtlRels[0].Categorization__c = 'Current';
        insertdgtlRels[0].Scripted_Reality__c = 'Reality';
        //insertdgtlRels[0].US_Network_Categorization__c = 'Bravo'; DFOR-1578
        insertdgtlRels[0].US_Network_Categorization__c = 'Bravo';
        insertdgtlRels[0].TV_Studio__c = 'Bravo';
        //inserting Digital Release
        insert insertdgtlRels;
        System.AssertEquals( TRUE , insertdgtlRels[0].id != null , 'Digital Release Record not Created');
        
        test.startTest();
        List<EPO_Bonus__c> insertEPO = DGF_TestDataUtility.createEPOBonus(1,TVRecTypeIdPrd);
        insertEPO[0].Digital_release__c = insertdgtlRels[0].id;
        insertEPO[0].bonus_type__c = 'Season Only';
        
        insert insertEPO[0];
        System.AssertEquals( TRUE , insertEPO[0].id != null , 'Bonus Record not Created');
        //verify that bonus account is created
        Integer bonusAccCount = [SELECT Count() from Bonus_Account__c where Bonus__c =:insertEPO[0].id];
        System.assertEquals(1, bonusAccCount , ' Bonus account not created');
        test.stopTest();
    }
}