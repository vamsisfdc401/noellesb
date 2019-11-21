/*****************************************************************************************
Class Name: ScheduleGBSBatchFactoryStatusTest
Purpose: Test class for apex class ScheduleGBSBatchFactoryStatusUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/27/2018           Ashok Raghavan           Initial Development (GBS 276)
******************************************************************************************/
@isTest
public class ScheduleGBSBatchFactoryStatusTest 
{
   public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleGBSBatchFactoryStatusUpdate sh1 = new ScheduleGBSBatchFactoryStatusUpdate();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchCheck', sch, sh1);
        Test.StopTest();
    }
}