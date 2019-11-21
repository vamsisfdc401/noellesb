/*****************************************************************************************
Class Name: ScheduleBatchVProjectUpdateTest
Purpose: Test class for apex class ScheduleBatchVProjectUpdate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/10/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest
public class ScheduleBatchVProjectUpdateTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleBatchVProjectUpdate sh1 = new ScheduleBatchVProjectUpdate();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchCheck', sch, sh1);
        Test.StopTest();
    }

}