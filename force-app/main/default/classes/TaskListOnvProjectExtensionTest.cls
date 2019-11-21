/*****************************************************************************************
Class Name: TaskListOnvProjectExtensionTest
Purpose: Test class for apex class TaskListOnvProjectExtension
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/10/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest
public class TaskListOnvProjectExtensionTest{

    /*****************************************************************
    Method Name: testMethod_1
    Purpose: test method
    ***************************************************************/ 
    static testmethod void testMethod_1(){
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        v_Project_Request__c vProj = new v_Project_Request__c();
        vProj.Release__c = release.ID;
        vProj.SAP_Project_Description__c = 'Test';
        vProj.Project_Category__c = 'V006';
        vProj.Project_Studio__c = '001';
        vProj.POS_Order_End_Date__c = Date.Today();
        vProj.Project_Finish_Date__c = Date.Today();
        vProj.Return_End_Date__c = Date.Today();
        insert vProj;
        
        Task objTask = new Task();
        //objTask.Owner.ID = userinfo.getUserID();
        objTask.Subject = 'Test';
        objTask.WhatID = vProj.ID;
        insert objTask;
        
        PageReference pref = Page.TaskListOnvProject;
        pref.getParameters().put('id',vProj.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController con = new ApexPages.StandardController(vProj);
        TaskListOnvProjectExtension  ext = new TaskListOnvProjectExtension(con);    
        
        ext.first();  
        ext.recordID = objTask.ID;
        ext.updateTask();
        ext.recordID = objTask.ID;
        ext.closeTask();
        
        System.AssertEquals(FALSE,ext.getDisableNext());
        System.AssertEquals(FALSE,ext.getDisablePrevious());
    }
    
    /*****************************************************************
    Method Name: testMethod_2
    Purpose: test method
    ***************************************************************/ 
    static testmethod void testMethod_2(){      
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        v_Project_Request__c vProj = new v_Project_Request__c();
        vProj.Release__c = release.ID;
        vProj.SAP_Project_Description__c = 'Test';
        vProj.Project_Category__c = 'V006';
        vProj.Project_Studio__c = '001';
        vProj.POS_Order_End_Date__c = Date.Today();
        vProj.Project_Finish_Date__c = Date.Today();
        vProj.Return_End_Date__c = Date.Today();
        insert vProj;
        
        List<Task> lstTask = new List<Task>();
        for(integer i=0;i<=21;i++){
            Task objTask = new Task();
            objTask.Subject = 'Test';
            objTask.WhatID = vProj.ID;
            lstTask.add(objTask);
        }
        
        insert lstTask;
        
        PageReference pref = Page.TaskListOnvProject;
        pref.getParameters().put('id',vProj.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController con = new ApexPages.StandardController(vProj);
        TaskListOnvProjectExtension  ext = new TaskListOnvProjectExtension(con); 

        ext.toggleSort();       
        ext.first();
        ext.next();
        ext.next();
        ext.previous();
        ext.last();
        System.AssertEquals(FALSE,ext.getDisableNext());
        System.AssertEquals(TRUE,ext.getDisablePrevious());
    }
    
    /*****************************************************************
    Method Name: testMethod_3
    Purpose: test method
    ***************************************************************/ 
    static testmethod void testMethod_3(){      
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        v_Project_Request__c vProj = new v_Project_Request__c();
        vProj.Release__c = release.ID;
        vProj.SAP_Project_Description__c = 'Test';
        vProj.Project_Category__c = 'V006';
        vProj.Project_Studio__c = '001';
        vProj.POS_Order_End_Date__c = Date.Today();
        vProj.Project_Finish_Date__c = Date.Today();
        vProj.Return_End_Date__c = Date.Today();
        insert vProj;
        
        PageReference pref = Page.TaskListOnvProject;
        pref.getParameters().put('id',vProj.id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController con = new ApexPages.StandardController(vProj);
        TaskListOnvProjectExtension  ext = new TaskListOnvProjectExtension(con);   
        
        ext.updateTask();
        ext.closeTask();
        
        System.AssertEquals(FALSE,ext.getDisableNext());
        System.AssertEquals(FALSE,ext.getDisablePrevious());

    }

}