/*****************************************************************************************
Class Name: DGF_ExceptionLogControllerTest
Purpose: Test class for DGF_ExceptionLogController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/06/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_ExceptionLogControllerTest {
     /***********************************
    Method Name: scenario1
    Purpose: method to test creation of Exception record
    ***********************************/
    static testMethod void scenario1(){
        test.startTest();
        try{
            //perform a divide by zero operation
            Integer i=20/0;
        }
        catch (Exception e){
            //call the createExceptionlog method to create the Exception Log record
            DGF_ExceptionLogController.createExceptionLog('Test', 'Test', e.getMessage());
        }
        //query for the created exception log
        list<Exception_log__c>exp=[SELECT ID,error_message__c from exception_log__c];
        //verify the error message of the exception log record
        System.assertEquals('Divide by 0', exp[0].error_message__c);
        test.stopTest();
    }
    
}