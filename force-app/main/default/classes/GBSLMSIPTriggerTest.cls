/*****************************************************************************************
Class Name: GBSLMSIPTriggerTest
Purpose: Test class for GBSLMSIPTrigger and it's handler
Version : 1.0
Date Created : 05/18/2018
Created By : Harsha Vardhan P
JIRA : GBS-278
******************************************************************************************/
@isTest
private class GBSLMSIPTriggerTest {

    private static testMethod void test() {
	    Intellectual_Property__c IP = new Intellectual_Property__c(Name = 'Test Intellectual Property');
	    insert IP;
	    
	    LMS__c LMS = new LMS__c();
	    insert LMS;
	    
        GBS_LMS_IP__c LMSIP = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP1 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP2 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP3 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP4 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP5 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP6 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP7 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP8 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP9 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP10 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        insert new List<GBS_LMS_IP__c>{LMSIP, LMSIP1, LMSIP2, LMSIP3, LMSIP4, LMSIP5, LMSIP6, LMSIP7, LMSIP8, LMSIP9, LMSIP10};
        
        delete [Select Id From GBS_LMS_IP__c];
	}
	
	private static testMethod void test1() {
	    GBSTriggerManager__c GBSLMSIPTrigger = new GBSTriggerManager__c();
		GBSLMSIPTrigger.Name = 'GBSLMSIPTrigger'; 
        GBSLMSIPTrigger.GBSDisable__c = true; 
		insert GBSLMSIPTrigger;
	    
	    Intellectual_Property__c IP = new Intellectual_Property__c(Name = 'Test Intellectual Property');
	    insert IP;
	    
	    LMS__c LMS = new LMS__c();
	    insert LMS;
	    
        GBS_LMS_IP__c LMSIP = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP1 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP2 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP3 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP4 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP5 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP6 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP7 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP8 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP9 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        GBS_LMS_IP__c LMSIP10 = new GBS_LMS_IP__c(GBS_LMS__c = LMS.Id, GBS_Intellectual_Property__c = IP.Id);
        insert new List<GBS_LMS_IP__c>{LMSIP, LMSIP1, LMSIP2, LMSIP3, LMSIP4, LMSIP5, LMSIP6, LMSIP7, LMSIP8, LMSIP9, LMSIP10};
        
        delete [Select Id From GBS_LMS_IP__c];
	}

}