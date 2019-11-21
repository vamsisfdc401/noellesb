/*****************************************************************************************
Class Name: VProjectRecordInlinePageHandlerTest
Purpose: Test class for apex class  VProjectRecordInlinePageHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
public class VProjectRecordInlinePageHandlerTest{
    @isTest
    static void testMethod_1()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Label_Code__c='24 - PURE FLIX';
        material1.Territory__c = 'US';
        insert material1;
        
        Release_Material__c  rlm = new Release_Material__c ();
        rlm.Material__c= material1.Id;
        rlm.Release__c = release.Id;
        rlm.Allocation_Percentage__c = 10;
        Insert rlm;
        
        v_Project_Request__c vProjReq=new v_Project_Request__c(Release__c=release.id);
        
        Insert vProjReq;
        
        PageReference pageRef = Page.VProjectRecordInlinePage;
        Test.setCurrentPage(pageRef);           
        
        ApexPages.currentPage().getParameters().put('id', vProjReq.id); 
        ApexPAges.StandardController sc = new ApexPages.StandardController(vProjReq);
        VProjectRecordInlinePageHandler conv=new VProjectRecordInlinePageHandler(sc);
        conv.getMatReleases();
        conv.updaVprojectandRelMat();
        conv.cancel();
        
    }
    @isTest
    static void testMethod_2()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Label_Code__c='24 - PURE FLIX';
        material1.Territory__c = 'US';
        insert material1;
        
        Release_Material__c  rlm = new Release_Material__c ();
        rlm.Material__c= material1.Id;
        rlm.Release__c = release.Id;
        rlm.Allocation_Percentage__c = 110;
        Insert rlm;
        
        v_Project_Request__c vProjReq=new v_Project_Request__c(Release__c=release.id);
        
        Insert vProjReq;
        
        PageReference pageRef = Page.VProjectRecordInlinePage;
        Test.setCurrentPage(pageRef);           
        
        ApexPages.currentPage().getParameters().put('id', vProjReq.id); 
        ApexPAges.StandardController sc = new ApexPages.StandardController(vProjReq);
        VProjectRecordInlinePageHandler conv=new VProjectRecordInlinePageHandler(sc);
        conv.getMatReleases();
        conv.updaVprojectandRelMat();
        conv.cancel();
        
    }  
}