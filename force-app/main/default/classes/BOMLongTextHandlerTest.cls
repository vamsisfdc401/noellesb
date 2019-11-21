/*****************************************************************************************
Class Name: BOMLongTextHandlerTest 
Purpose: This class is responsible to Handle logic that should be executed when BOM Long Text field is changed 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/02/2017           Jata                   Initial Development
******************************************************************************************/
@isTest
public class BOMLongTextHandlerTest {
    @isTest
    static void testMethod_1()
    {
        List<Material__c> materialList = new List<Material__c>();
        List<Material__c> materialListToUpdate = new List<Material__c>();
        
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.BOM_Long_Text__c = 'This class is responsible to Handle logic that should be executed when BOM Long Text field is inserted ';
        material1.Territory__c = 'US';
        
        materialList.add(material1);
        
        Material__c material2= testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',null,TRUE,'C - Components','DS - DISC');
        material2.BOM_Long_Text__c = 'This class is responsible to Handle logic that should be executed when BOM Long Text field is updated ';
        material2.Territory__c = 'US';
        materialList.add(material2);
        
        Material__c material3 = testClassUtility.createMaterial('12 - VOD','COMBO PACK','dummy3','FERT',null,TRUE,'S (Single)','SS - SINGLE SELECTION');
        material3.BOM_Long_Text__c = 'This class is responsible to Handle logic that should be executed when BOM Long Text field is deleted ';
        material3.Territory__c = 'US';
        materialList.add(material3);
        
        Test.startTest();
        System.assert(materialList.size()>0);
        insert materialList;
        
        for(Material__c mtrl : materialList){
            mtrl.BOM_Long_Text__c = null;
            materialListToUpdate.add(mtrl);
        }
        
        System.assert(materialListToUpdate.size()>0);
        update materialListToUpdate;
        Test.stopTest();
    }

     private static testMethod void  testMethod_2(){
        TriggerUtility.checkFromCloning = true;
        Material__c material1 = testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.BOM_Long_Text__c = 'This class is responsible to Handle logic that should be executed when BOM Long Text field is inserted ';
        material1.Territory__c = 'US';
        insert material1;
        
        
        Material__c mat = [select id ,BOM_Long_Text__c from Material__c where id=:material1.id];
        Test.startTest();
            mat.BOM_Long_Text__c = null;
            update mat;
            system.assertEquals(null,mat.BOM_Long_Text__c);
            System.assertNotEquals('This class is responsible to Handle logic that should be executed when BOM Long Text field is inserted ',mat.BOM_Long_Text__c);
            
        Test.StopTest();
        
    }
}