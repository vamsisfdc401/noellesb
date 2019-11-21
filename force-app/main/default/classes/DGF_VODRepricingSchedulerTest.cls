/*****************************************************************************************
Class Name: DGF_VODRepricingSchedulerTest
Purpose: Test class for apex class DGF_VODRepricingScheduler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/05/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_VODRepricingSchedulerTest {
      /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-42
    ***********************************/
    static testMethod void scenario1(){
        test.startTest();
         DGF_VODRepricingScheduler sched=new DGF_VODRepricingScheduler();
          String sch = '0 0 23 * * ?';
            system.schedule('Test Job', sch, sched);
            String jobid = system.schedule('Test VOD Job', sch, sched);
             CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
            System.assertEquals(sch,ct.CronExpression);          
        test.stopTest();
    }
}