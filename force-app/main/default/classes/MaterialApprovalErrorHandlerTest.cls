/*****************************************************************************************
Class Name: MaterialApprovalErrorHandlerTest
Purpose: Test class for apex class  MaterialApprovalErrorHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
private class MaterialApprovalErrorHandlerTest{
@isTest
static void testMethod_1()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id);
        objMaterial.Territory__c = 'US';
        insert objMaterial;
        
        Material__c objMaterial1 = new Material__c(name='dummy1',Material_Type__c= 'ROH',Release__c = objRelease.id);
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        Sales__c s = new Sales__c();
        s.Material__c = objMaterial.Id;
        Insert s;
        
        Sales__c s1 = new Sales__c();
        s1.Material__c = objMaterial1.Id;
        Insert s1; 
        
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;       
        Insert p;
        
        Plant__c p1 = new Plant__c();
        p1.Material__c = objMaterial1.id;       
        Insert p1;
        
        Valuation__c eachValuation =  new Valuation__c ();
        eachValuation.Material__c = objMaterial.id;
        insert eachValuation;
         
        Valuation__c eachValuation1 =  new Valuation__c ();
        eachValuation1.Material__c = objMaterial1.id;
        insert eachValuation1;
       
        PageReference pageRef = Page.MaterialApprovalError;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objMaterial.id);       
        ApexPAges.StandardController sc = new ApexPages.StandardController(objMaterial);
        MaterialApprovalErrorHandler conv=new MaterialApprovalErrorHandler(sc);
         
        PageReference pageRef1 = Page.MaterialApprovalError;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', objMaterial1.id);       
        ApexPAges.StandardController sc1 = new ApexPages.StandardController(objMaterial);
        MaterialApprovalErrorHandler conv1=new MaterialApprovalErrorHandler(sc1);
         
         
       
      Test.stopTest();          
    }
    
@isTest
static void testMethod_2()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy12',Material_Type__c= 'FERT',Release__c = objRelease.id ,Material_status__c='Submitted');
        objMaterial.Territory__c = 'US';
        insert objMaterial;
        
        Material__c objMaterial1 = new Material__c(name='dummy1123',Material_Type__c= 'ROH',Release__c = objRelease.id,Material_status__c='Submitted');
        objMaterial1.Territory__c = 'US';
        insert objMaterial1;
        
        Sales__c s = new Sales__c();
        s.Material__c = objMaterial.Id;
        Insert s; 
        
        Plant__c p = new Plant__c();
        p.Material__c = objMaterial.id;       
        Insert p;
        
        Valuation__c eachValuation =  new Valuation__c ();
        eachValuation.Material__c = objMaterial.id;
        insert eachValuation;
        
        Sales__c s1 = new Sales__c();
        s1.Material__c = objMaterial1.Id;
        Insert s1; 
        
        Plant__c p1 = new Plant__c();
        p1.Material__c = objMaterial1.id;       
        Insert p1;
        
        Valuation__c eachValuation1 =  new Valuation__c ();
        eachValuation1.Material__c = objMaterial1.id;
        insert eachValuation1;
         
       
        PageReference pageRef = Page.MaterialApprovalError;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objMaterial.id);       
        ApexPAges.StandardController sc = new ApexPages.StandardController(objMaterial);
        MaterialApprovalErrorHandler conv=new MaterialApprovalErrorHandler(sc);
        
        PageReference pageRef1 = Page.MaterialApprovalError;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', objMaterial1.id);       
        ApexPAges.StandardController sc1 = new ApexPages.StandardController(objMaterial);
        MaterialApprovalErrorHandler conv1=new MaterialApprovalErrorHandler(sc1);
        
        conv1.loadPage();
       
      Test.stopTest();          
    }    
     
 }