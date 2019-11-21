/*****************************************************************************************
Class Name: BOMItemTriggerHandlerTest 
Purpose: Test class for apex class  BOMItemTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest(SeeAllData = FAlSE)
public class BOMItemTriggerHandlerTest {
    
    @isTest
    public static void Scenario1(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns.Territory__c = 'US';
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;    
    }
    
    @isTest
    public static void Scenario2(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns.Territory__c = 'US';
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'ROH',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='DS - DISC');
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;    
    }
    
     @isTest
    public static void Scenario3(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns.Territory__c = 'US';
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Approved',name='dummy2',Material_Type__c= 'Z009',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='C - Components',Item_Code__c='PG - PACKAGING');
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;    
    }
    
    @isTest
    public static void Scenario4(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        materialIns.Territory__c = 'US';
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',
                                                   name='dummy2',Material_Type__c= 'FERT',Release__c = release.id, Format__c='02 - DVD',
                                                   Item_Code__c='BF - BABY FERT' );
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;    
    }
    
    @isTest
    public static void Scenario5(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S - 1010','SS (Single Selection)');
        insert materialIns;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',
                                                   name='dummy2',Material_Type__c= 'FERT',Release__c = release.id, Format__c='02 - DVD', 
                                                   Item_Type__c='S (Single)',Item_Code__c='BF - BABY FERT');
        insert objMaterial1;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
        insert bomItem;    
    }
    

    @isTest
    public static void Scenario7(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Platform API'];
          User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg12312.com');
                          
        system.runAs(u){
            Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
            
        Material__c materialIns = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',
                                                   name='dummy1',Material_Type__c= 'FERT',Release__c = release.id, Format__c='02 - DVD',
                                                   Item_Type__c='D (Display Vehicle)',Item_Code__c='CU - CUBE',Base_Quantity__c = '9');
        TriggerUtility.doNotExecute= true;
        insert materialIns;
        TriggerUtility.doNotExecute= false;
        
        Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',
                                                   name='dummy2',Material_Type__c= 'FERT',Release__c = release.id, Format__c='02 - DVD',
                                                  Item_Code__c='BF - BABY FERT');
        TriggerUtility.doNotExecute= true;
        insert objMaterial1;
        TriggerUtility.doNotExecute= false;
        
        BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id, 
                                             Component_Quantity__c = '8');
        insert bomItem; 
        
        delete bomItem;
        }                  
    }

     @isTest
    public static void Scenario8(){
        Profile p= [Select Id, Name from Profile where Name =: 'Platform API' limit 1];
 
        User u = new User(Alias = 'standt', Email='standarduser213321@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser02@testorg.com');

        System.runAs(u){
            Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
            insert release;
            
            Material__c materialIns=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S - 1010','SS (Single Selection)');
            TriggerUtility.doNotExecute= true;
            insert materialIns;
            TriggerUtility.doNotExecute= false;
            
            Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',
                                                       name='dummy2',Material_Type__c= 'FERT',Release__c = release.id, Format__c='02 - DVD',
                                                       Item_Type__c='S (Single)',Item_Code__c='BF - BABY FERT');
            TriggerUtility.doNotExecute= true;
            insert objMaterial1;
            TriggerUtility.doNotExecute= false;
            
            BOM_Item__c bomItem= new BOM_Item__c(Material__c=materialIns.id,Material_Component__c=objMaterial1.id);
            insert bomItem;
       }     
    }
}