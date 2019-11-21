/*****************************************************************************************
Class Name: ScheduleGBSBatchLMSStatusUpdateTest
Purpose: Test class for apex class ScheduleGBSBatchLMSStatusUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/09/2018           Ashok Raghavan           Initial Development
******************************************************************************************/
@isTest
public class ScheduleGBSBatchLMSStatusUpdateTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleGBSBatchLMSStatusUpdate sh1 = new ScheduleGBSBatchLMSStatusUpdate();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchCheck', sch, sh1);
        Test.StopTest();
    }

}