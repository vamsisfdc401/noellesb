/*****************************************************************************************
Class Name: VProjectRecordTest
Purpose: Test class for apex class VProjectRecord Controller
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/09/2016           Viraj                    Initial Development
******************************************************************************************/
@isTest(SeeAllData=FALSE)
private class VProjectRecordTest{
    
    @isTest
    static void scenario1(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        /**** Setting Page Reference ****/       
        PageReference pageRef = Page.VProjectRecordNew;
        pageRef.getParameters().put('Id',objRelease.Id);
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        ApexPages.StandardController sc = new ApexPages.StandardController(objRelease);
        VProjectRecordHandler extController = new VProjectRecordHandler(sc);
        extController.saveVproject();  
    }
    
    @isTest
    static void scenario2(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        v_Project_Request__c vprc = new v_Project_Request__c(Release__c = objRelease.Id);
        insert vprc;
        
        /**** Setting Page Reference ****/
        
        PageReference pageRef = Page.VProjectRecordNew;
        pageRef.getParameters().put('Id',objRelease.Id);
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        ApexPages.StandardController sc = new ApexPages.StandardController(objRelease);
        VProjectRecordHandler extController = new VProjectRecordHandler(sc);
        extController.saveVproject();  
    }
    
    @isTest
    static void scenario3(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id, Material__c = objMaterial.Id,
                                                         Allocation_Percentage__c = 20);
        insert(rm);
        
        v_Project_Request__c vprc = new v_Project_Request__c(Release__c = objRelease.Id);
        insert vprc;
        
        /**** Setting Page Reference ****/
        
        PageReference pageRef = Page.VProjectRecordNew;
        pageRef.getParameters().put('Id',objRelease.Id);
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        ApexPages.StandardController sc = new ApexPages.StandardController(objRelease);
        VProjectRecordHandler extController = new VProjectRecordHandler(sc);
        extController.getMatReleases();
        extController.updaVprojectandRelMat();
        extController.cancel();
        
    }
    
    
    @isTest
    static void scenario4(){
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Release_Material__c rm = new Release_Material__c(Release__c = objRelease.Id, Material__c = objMaterial.Id,
                                                         Allocation_Percentage__c = 120);
        insert(rm);
        
        v_Project_Request__c vprc = new v_Project_Request__c(Release__c = objRelease.Id);
        insert vprc;
        
        /**** Setting Page Reference ****/
        
        PageReference pageRef = Page.VProjectRecordNew;
        pageRef.getParameters().put('Id',objRelease.Id);
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        ApexPages.StandardController sc = new ApexPages.StandardController(objRelease);
        VProjectRecordHandler extController = new VProjectRecordHandler(sc);
        extController.getMatReleases();
        extController.updaVprojectandRelMat();
        extController.cancel();
        
    } 
}