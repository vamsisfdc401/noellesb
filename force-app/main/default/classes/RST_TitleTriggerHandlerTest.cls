/**********************************
Class Name: UpdatePlayWeekDatesHandlerTest
Purpose: Test class for UpdatePlayWeekDatesHandler and UpdatePlayWeekDates trigger
Version : 1.0
DateCreated : 03/28/2019
CreatedBy : Piyush
********************************/
@isTest
private class RST_TitleTriggerHandlerTest {
    
    private static testMethod void test() {
        
        //Create Title for Playweeks
        Test.startTest();
        RST_Title__c t = new RST_Title__c(Name = 'Test Title',
                                          Wide_Release_Date__c = Date.today(),
                                          RenTrak_Id__c = '10000');
        insert t;
        
        RST_Market_Capacity__c mc = new RST_Market_Capacity__c(Week_Date__c = System.Today());
        insert mc;
        
        List<RST_Play_Week__c> pwToInsert = new List<RST_Play_Week__c>();
        //Create PlayWeek with Source == 'Magic'
        RST_Play_Week__c pw1 = new RST_Play_Week__c(Name = 'Test PlayWeek 1',
                                                    Title__c = t.id,
                                                    Play_Week__c = 1,
                                                    Source__c = 'CSV',
                                                    Weekend_BO__c = 100,
                                                    Midweek_BO__c = 50,
                                                    Week_Date__c = System.Today(),
                                                    Title_Open_Date__c = System.Today(),
                                                    RenTrak_Id__c ='10000',
                                                    Market_Capacity__c = mc.id,
                                                    ParentProcessed__c=true
                                                   );
        RST_Play_Week__c pw2 = new RST_Play_Week__c(Name = 'Test PlayWeek 1',
                                                    Title__c = t.id,
                                                    Play_Week__c = 2,
                                                    Source__c = 'CSV',
                                                    Weekend_BO__c = 100,
                                                    Midweek_BO__c = 50,
                                                    Week_Date__c = System.Today(),
                                                    Title_Open_Date__c = System.Today(),
                                                    RenTrak_Id__c ='10000',
                                                    Market_Capacity__c = mc.id,
                                                    ParentProcessed__c=true
                                                   );
        
        pwToInsert.add(pw1);
        pwToInsert.add(pw2);
        insert pwToInsert;
        t.Wide_Release_Date__c=Date.today().addDays(7);
        update t;
        Test.stopTest();
        RST_Play_Week__c rstPW = [Select Week_Date__c from RST_Play_Week__c LIMIT 1];
        System.assertEquals(rstPW.Week_Date__c, Date.today().addDays(7));
        
    }
    
}