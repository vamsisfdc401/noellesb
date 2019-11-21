/*****************************************************************************************
Class Name: DGF_DeleteExceptionBatchTest
Purpose: Test class for apex class DGF_DeleteExceptionBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/06/2017           Prarthana                Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_DeleteExceptionBatchTest {
    
      /***********************************
    Method Name: scenario1
    Purpose: method to test code for deleting the exception log records
    ***********************************/
    static testMethod void scenario1(){
        //create an Exception Log
    	  Exception_Log__c exp = new Exception_Log__c();
          exp.Error_Message__c='Error before Insert';
          exp.Source__c='Product Creation';
          exp.Event__c='Before insert';
    	 insert exp;  
        //update the createdDate of the log to a past date
        Test.setCreatedDate(exp.Id, DateTime.newInstance(2017,05,10));  
        test.startTest();
        //invoke the batch
          DGF_DeleteExceptionLogBatch btch=new DGF_DeleteExceptionLogBatch();
          database.executebatch(btch,100);
        
        //invoking the scheduler
          DGF_DeleteExceptionLogScheduler sched=new DGF_DeleteExceptionLogScheduler();
          String sch = '0 0 23 * * ?';
            system.schedule('Test Job', sch, sched);
        test.stopTest();
    }

}