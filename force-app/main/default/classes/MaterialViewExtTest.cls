/*****************************************************************************************
Class Name: MaterialViewExtTest
Purpose: Test class for apex class MaterialViewExt
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             06/02/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seealldata = false)
public class MaterialViewExtTest{
    
    static testmethod void testMethod_1()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Territory__c = 'US'; // TO OVER COME NULL POINTER 
        insert material1;
        
        test.startTest();
        PageReference pageRef = Page.MaterialView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        MaterialViewExt matView = new MaterialViewExt(sc);
        matView.checkDefaultingCompletion();     
        test.stopTest();
    }
    
    static testmethod void testMethod_2()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);         
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Defaults_Processing__c = TRUE;
        material1.Defaulting_Material__c = TRUE;
        material1.Territory__c = 'US';// TO OVER COME NULL POINTER 
        insert material1; 
        
        Sales__c s = new Sales__c();
        s.Material__c = material1.Id;
        s.Additional_Default__c = TRUE;
        s.Territory__c = 'US';        
        Insert s;
        
        Plant__c p = new Plant__c();
        p.Material__c = material1.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        p.Additional_Default__c = TRUE;
        Insert p;
        
        Valuation__c val = new Valuation__c();
        val.Material__c = material1.id;
        val.Valuation_Area__c='V000';
        val.Moving_Price__c = 10;
        val.Origin_Group__c = '0001';
        val.Price_Unit__c = 'AA';
        val.Standard_Price__c = 0.01;
        val.Valuation_Class__c = '7920 - Finished products';
        val.Valuation_Type__c = 'A';
        val.Additional_Default__c = TRUE;
        insert val;
        
        Classification__c cls = new Classification__c();
        cls.Material__c = material1.id;
        cls.Additional_Default__c = TRUE;
        insert cls;
        
        Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c();
        auom.Material__c = material1.id;
        auom.Additional_Default__c = TRUE;
        insert auom;  
        
        test.startTest();
        PageReference pageRef = Page.MaterialView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        MaterialViewExt matView = new MaterialViewExt(sc);
        matView.checkDefaultingCompletion();   
        test.stopTest();     
    }
    
    static testmethod void testMethod_3()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);         
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Defaults_Processing__c = TRUE;
        material1.Defaulting_Material__c = TRUE;
        material1.Territory__c = 'US';// TO OVER COME NULL POINTER 
        insert material1; 
        
        Sales__c s = new Sales__c();
        s.Material__c = material1.Id;
        s.Additional_Default__c = TRUE;
        s.Territory__c = 'US';        
        Insert s;
        
        Plant__c p = new Plant__c();
        p.Material__c = material1.id;
        p.Plant__c = 'V000 - Univ Studios HV Planning Plant'; 
        p.Additional_Default__c = TRUE;
        Insert p;
        
        Valuation__c val = new Valuation__c();
        val.Material__c = material1.id;
        val.Valuation_Area__c='V000';
        val.Moving_Price__c = 10;
        val.Origin_Group__c = '0001';
        val.Price_Unit__c = 'AA';
        val.Standard_Price__c = 0.01;
        val.Valuation_Class__c = '7920 - Finished products';
        val.Valuation_Type__c = 'A';
        val.Additional_Default__c = TRUE;
        insert val;
        
        Classification__c cls = new Classification__c();
        cls.Material__c = material1.id;
        cls.Additional_Default__c = TRUE;
        insert cls;
        
        Alternative_Unit_of_Measure__c auom = new Alternative_Unit_of_Measure__c();
        auom.Material__c = material1.id;
        auom.Additional_Default__c = TRUE;
        insert auom;  
        
        test.startTest();
        PageReference pageRef = Page.MaterialView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        MaterialViewExt matView = new MaterialViewExt(sc);
        matView.additionalPoll = FALSE;
        matView.checkDefaultingCompletion(); 
        test.stopTest();       
    }
    
    static testmethod void testMethod_4()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);         
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Defaults_Processing__c = TRUE;
        material1.Defaulting_Material__c = TRUE;
        material1.Territory__c = 'US';// TO OVER COME NULL POINTER 
        insert material1; 
        
        test.startTest();
        PageReference pageRef = Page.MaterialView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(material1);
        MaterialViewExt matView = new MaterialViewExt(sc);
        matView.additionalPoll = FALSE;
        matView.checkDefaultingCompletion(); 
        test.stopTest();       
    }
}