/***********************************************************************
 Class Name:DGF_RightsDigitalReleaseUpdateScheClass
 Purpose:It will Schedule the RightsDigitalReleaseUpdateBatchClass
************************************************************************
version  DateModified     ModifiedBy           Change
1.0		 10/23/2018       Naga				    Initial Development DFOR-1652

************************************************************************/
global class DGF_RightsDigitalReleaseUpdateScheClass implements Schedulable{

    public static String sched = '0 0 4 1/1 * ? *';  //Every Day at 4:00 am.
	
    global static String scheduleMe() {
        DGF_RightsDigitalReleaseUpdateScheClass SC = new DGF_RightsDigitalReleaseUpdateScheClass(); 
        return System.schedule('My batch Job', sched, SC);
    }

    global void execute(SchedulableContext sc) {

        DGF_RightsDigitalReleaseUpdateBatchClass b1 = new DGF_RightsDigitalReleaseUpdateBatchClass();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}