/*****************************************************************************************
Class Name: TriggerUtilityTest
Purpose: Test class for apex class TriggerUtility
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
public class TriggerUtilityTest {
    
    private static User userBrand;
    
    @isTest
    public static void testTriggerUtility()
    {
        Profile profileBrand = [select id from profile where name='Brand User' ];        
        userBrand = new User(alias = 'testBD', 
                             email = 'test1@test.com',
                             emailencodingkey = 'UTF-8', 
                             lastname = 'Testing', 
                             languagelocalekey = 'en_US',
                             localesidkey = 'en_US', 
                             profileid = profileBrand.ID,
                             country = 'United States',
                             timezonesidkey = 'America/Los_Angeles', 
                             username = 'testBrand@test.com.brand',
                             isActive = true);     
        insert userBrand;
        
        Material__c mat1;
        Material__c mat2;
        
        BOM_Item__c bom;
        
        test.startTest();
        
        system.assertEquals(true, TriggerUtility.releaseTriggerExecuted());
        system.assertEquals(false, TriggerUtility.releaseTriggerExecuted());
        
        System.runAs(userBrand) 
        {
            Release__c release = new Release__c(Name='Test Release', Street_Date__c = Date.Today(), Brand_Group__c = 'Universal Pictures', 
                                                Project_Type__c = 'New Release');
            insert release;
            
            // Creating FERT material for US.
            mat1 = new Material__c();
            mat1.Name = 'Test Material';
            mat1.Release__c = release.Id;
            mat1.Material_Type__c = 'FERT';
            mat1.Item_Type__c = 'S (Single)';
            mat1.Item_Code__c = 'SS - SINGLE SELECTION';
            mat1.Label_Code__c = '61 - Universal Pictures';
            mat1.Format_Description__c = 'DVD';
            mat1.Territory__c = 'US';
            
            insert mat1;
            
            // Creating FERT material for CDN.
            mat2 = new Material__c();
            mat2.Name = 'Test Material1';
            mat2.Release__c = release.Id;
            mat2.Material_Type__c = 'FERT';
            mat2.Item_Type__c = 'S (Single)';
            mat2.Item_Code__c = 'SS - SINGLE SELECTION';
            mat2.Label_Code__c = '61 - Universal Pictures';
            mat2.Format_Description__c = 'DVD';
            mat2.Territory__c = 'CDN';
            
            insert mat2;
            
        }
        System.runAs(userBrand)
        {
            Release__c release = new Release__c(Name='Test Release', Street_Date__c = Date.Today(), Brand_Group__c = 'Universal Pictures', 
                                                Project_Type__c = 'New Release');
            insert release;
            
            // Creating FERT material for US.
            mat1 = new Material__c();
            mat1.Name = 'Test Material44';
            mat1.Release__c = release.Id;
            mat1.Material_Type__c = 'FERT';
            mat1.Item_Type__c = 'S (Single)';
            mat1.Item_Code__c = 'SS - SINGLE SELECTION';
            mat1.Label_Code__c = '61 - Universal Pictures';
            mat1.Format_Description__c = 'DVD';
            mat1.Territory__c = 'US';
            
            insert mat1;
            bom = new BOM_Item__c();
            bom.Material_Component__c = mat1.Id;
            bom.Material__c = mat1.Id;
            
            TriggerUtility.doNotExecute=true;    
            insert bom;
            TriggerUtility.doNotExecute=false;
            
        }
        
        test.stopTest();
    }
    
}