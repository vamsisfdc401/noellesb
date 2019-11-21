/*****************************************************************************************
Class Name: SetAdditionalDefaultsTest
Purpose: Test class for apex setAdditionalDefaults  Controller
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/

@isTest(SeeAllData = false)
public class SetAdditionalDefaultsTest {
     @isTest
     public static void setPlantDefaults(){
         Set<id>materiallist=new Set<id>();
         Map<id,String>materialMap=new Map<id,String>();
         
         Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
         material1.territory__c='US';
         insert material1;
        //materiallist.add(material1.id);
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','FERT',null,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material2.territory__c='CDN';
        insert material2;
        materiallist.add(material2.id);
        
        materialMap.put(material1.id,'CDN');
     
        Test.startTest();
            SetAdditionalPlantDefaults setAddDef=new SetAdditionalPlantDefaults();
            setAddDef.materialId=materiallist;
            setAddDef.materialTerritoryMap=materialMap;
            System.enqueueJob(setAddDef);
        Test.stopTest();
     } 
     
     @isTest
     public static void setSalesDefaults(){
         Set<id>materiallist=new Set<id>();
         Map<id,String>materialMap=new Map<id,String>();
         
         Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
         material1.territory__c='US';
         insert material1;
        //materiallist.add(material1.id);
        materialMap.put(material1.id,'CDN');
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','FERT',null,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material2.territory__c='US';
        insert material2;
        materiallist.add(material2.id);
       
     
        Test.startTest();
            SetAdditionalSalesDefaults setAddDef=new SetAdditionalSalesDefaults();
            setAddDef.materialId=materiallist;
            setAddDef.materialTerritoryMap=materialMap;
            System.enqueueJob(setAddDef);          
        Test.stopTest();
     } 
     
     @isTest
     public static void setMaterialDefaults(){
         Set<id>materiallist=new Set<id>();
         Map<id,String>materialMap=new Map<id,String>();
         
         Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
         material1.territory__c='CDN';
         insert material1;
       // materiallist.add(material1.id);
        materialMap.put(material1.id,'US');
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','FERT',null,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material2.territory__c='CDN';
        insert material2;
        materiallist.add(material2.id);
     
        Test.startTest();
            SetAdditionaMateriallDefaults setAddDef=new SetAdditionaMateriallDefaults();
            setAddDef.materialId=materiallist;
            setAddDef.materialTerritoryMap=materialMap;
            System.enqueueJob(setAddDef);          
        Test.stopTest();
     }    
     
     @isTest
     public static void setOtherDefaults(){
         Set<id>materiallist=new Set<id>();
         Map<id,String>materialMap=new Map<id,String>();
         
         Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
         material1.territory__c='US';
         insert material1;
        //materiallist.add(material1.id);
        materialMap.put(material1.id,'CDN');
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','FERT',null,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material2.territory__c='US';
        insert material2;
        materiallist.add(material2.id);
     
        Test.startTest();
            SetAdditionalOtherDefaults setAddDef=new SetAdditionalOtherDefaults();
            setAddDef.materialId=materiallist;
            setAddDef.materialTerritoryMap=materialMap;
            System.enqueueJob(setAddDef);          
        Test.stopTest();
     }
}