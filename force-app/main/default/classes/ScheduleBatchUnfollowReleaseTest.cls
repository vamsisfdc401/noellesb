/*****************************************************************************************
Class Name: ScheduleBatchUnfollowReleaseTest
Purpose: Test class for apex class ScheduleBatchUnfollowRelease
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna                 Initial Development
******************************************************************************************/
@isTest
public class ScheduleBatchUnfollowReleaseTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleBatchUnfollowRelease obj = new ScheduleBatchUnfollowRelease();  
        String chron = '0 0 23 * * ?';       
        String jobid = System.schedule('testScheduledApex', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        Test.StopTest();
    }

}