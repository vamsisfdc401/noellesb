/*****************************************************************************************
Class Name: ScheduleBatchMassEmailCommunicationTest
Purpose: Test class for apex class ScheduleBatchMassEmailCommunication
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna                 Initial Development
******************************************************************************************/
@isTest
public class ScheduleBatchMassEmailCommunicationTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleBatchMassEmailCommunication obj = new ScheduleBatchMassEmailCommunication();  
        String chron = '0 0 23 * * ?';       
        String jobid = System.schedule('testScheduledApex', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
        Test.StopTest();
    }

}