/*
 * Author: Kyle Novelli
 * Date: 12/04/2018
 * Company: Slalom
 * Description: Test class for RST_Playweek_TriggerHandler
 * 
 */
@isTest
public class RST_PlayWeek_TriggerHander_Test {
	
    public static testmethod void testUpdatePlayWeekChildren() {
        //Create Title for Playweeks
        RST_Title__c t = new RST_Title__c(Name = 'Test Title',
                                  Wide_Release_Date__c = System.Today(),
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
                                                   Market_Capacity__c = mc.id
                                                   );

        pwToInsert.add(pw1);
        RST_Play_Week__c pw2 = new RST_Play_Week__c(Name = 'Test PlayWeek 2',
            									   Title__c = t.id,
                                                   Play_Week__c = 2,
                                                   Source__c = 'CSV',
                                                   Weekend_BO__c = 50,
                                                   Midweek_BO__c = 25,
                                                   Weekend_Drop__c = -50,
                                                   MidWeek_Drop__c = -50,
                                                   Week_Date__c = System.Today()+7,
                                                   Title_Open_Date__c = System.Today(),
                                                   //Play_Week_Parent__c	= pw1.id,
                                                    RenTrak_Id__c ='10000',
                                                   Market_Capacity__c = mc.id
                                                   );

        pwToInsert.add(pw2);
        
        RST_Play_Week__c pw3 = new RST_Play_Week__c(Name = 'Test PlayWeek 3',
            									   Title__c = t.id,
                                                   Play_Week__c = 3,
                                                   Source__c = 'CSV',
                                                   Weekend_BO__c = 25,
                                                   Midweek_BO__c = 12.5,
                                                   Weekend_Drop__c = -50,
                                                   MidWeek_Drop__c = -50,
                                                   Week_Date__c = System.Today()+14,
                                                   Title_Open_Date__c = System.Today(),
                                                   //Play_Week_Parent__c	= pw2.id,
                                                    RenTrak_Id__c ='10000',
                                                   Market_Capacity__c = mc.id
                                                   );
        pwToInsert.add(pw3);
        insert pwToInsert;
        RST_Play_Week__c testPw3 = [SELECT Id, Cumulative__c FROM RST_Play_Week__c WHERE Name = 'Test PlayWeek 3'];
        System.assertEquals(262.5, testPw3.Cumulative__c);
        pw1.Weekend_BO__c = 200;
        pw1.MidWeek_BO__c = 100;
        pw1.Source__c = 'Magic';
        update pw1;
        
        RST_Play_Week__c pw2Test = [SELECT Id, Name, Weekend_BO__c, MidWeek_BO__c
                                    FROM RST_Play_Week__c
                                    WHERE Name = 'Test Playweek 2' LIMIT 1];
        
        RST_Play_Week__c pw3Test = [SELECT Id, Name, Weekend_BO__c, MidWeek_BO__c
                                    FROM RST_Play_Week__c
                                    WHERE Name = 'Test Playweek 3' LIMIT 1];
        System.assertEquals(pw2Test.Weekend_BO__c, 100);
        System.assertEquals(pw2Test.MidWeek_BO__c, 50);
        System.assertEquals(pw3Test.Weekend_BO__c, 50);
        System.assertEquals(pw3Test.MidWeek_BO__c, 25);
        
        pw2Test.Source__c = 'Magic';
        pw2Test.Weekend_BO__c = 120;
        pw2Test.Midweek_BO__c = 60;
        update pw2Test;
        
        RST_Play_Week__c pw2Test2 = [SELECT Id, Name, Weekend_BO__c, MidWeek_BO__c, Weekend_Drop__c, MidWeek_Drop__c
                                    FROM RST_Play_Week__c
                                    WHERE Name = 'Test Playweek 2' LIMIT 1];
        
        System.assertEquals(pw2Test2.Weekend_Drop__c, -40.00);
        System.assertEquals(pw2Test2.MidWeek_Drop__c, -40.00);
        
        RST_Play_Week__c pw3Test2 = [SELECT Id, Name, Weekend_BO__c, MidWeek_BO__c
                                    FROM RST_Play_Week__c
                                    WHERE Name = 'Test Playweek 3' LIMIT 1];
        System.assertEquals(pw3Test2.Weekend_BO__c, 60);
        System.assertEquals(pw3Test2.MidWeek_BO__c, 30);
        
    }
}