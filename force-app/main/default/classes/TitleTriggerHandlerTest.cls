/***********************************************************************************
Class Name: TitleTriggerHandlerTest
Purpose: Test class for apex class TitleTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/08/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class TitleTriggerHandlerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario1(){
        
        //Get GTM recordTypeId 
        Id recTypeIdGTM = Schema.Sobjecttype.Title__c.getRecordTypeInfosByName().get('GTM').getRecordTypeId();
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(50);
        for(Title__c title : insertTitle){
            title.RecordTypeID = recTypeIdGTM;
        }
        insert insertTitle;
        System.assert(insertTitle!=null);
        test.startTest();
        //creating an instance of title
        List<Title__c> insertTitles = DGF_TestDataUtility.createTitle(50);
        for(Title__c title : insertTitles){
            integer count =1;
            title.RecordTypeID = recTypeIdGTM;
            title.Parent_SGENNO__c = 'SGENNO' + count;
            title.SGENNO__c = null;
            count++;
        }
        insert insertTitles;
        List<Title__c> titleList = [Select Parent_Title__c from Title__c where Id in : insertTitles];
        
        for(Title__c ttls : titleList){
            System.assert(ttls.Parent_Title__c != null);
        }
       test.stopTest();
    }

}