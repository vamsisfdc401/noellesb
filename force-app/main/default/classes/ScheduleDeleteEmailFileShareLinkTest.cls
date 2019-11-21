/*****************************************************************************************
Class Name: ScheduleDeleteEmailFileShareLinkTest
Purpose: Test class for apex class ScheduleGBSBatchLMSStatusUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/07/2018           Ashok Raghavan           Initial Development
******************************************************************************************/
@isTest
public class ScheduleDeleteEmailFileShareLinkTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleDeleteEmailFileShareLink sh1 = new ScheduleDeleteEmailFileShareLink();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchCheck', sch, sh1);
        Test.StopTest();
    }

}