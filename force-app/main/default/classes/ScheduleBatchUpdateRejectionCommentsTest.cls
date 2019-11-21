/*****************************************************************************************
Class Name: ScheduleBatchUpdateRejectionCommentsTest
Purpose: Test class for apex class ScheduleBatchUpdateRejectionComments
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/09/2018           Dinakar                 Initial Development
******************************************************************************************/
@isTest
public class ScheduleBatchUpdateRejectionCommentsTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleBatchUpdateRejectionComments obj = new ScheduleBatchUpdateRejectionComments();  
        String chron = '0 0 23 * * ?';       
        String jobid = System.schedule('testScheduledApex', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        Test.StopTest();
    }

}