/*
 * Author: Kyle Novelli
 * Date: 12/17/2018
 * Company: Slalom
 * Description: Test class for all code related to RST_App User Interface
 * 
 */
@isTest
public class RST_UserInterfaceTest {
	private static date getLastFriday(){
        datetime thePast = system.now().addDays(-1);
        while(thePast.format('u') != '5'){
            thePast = thePast.addDays(-1);
        }
        return date.valueOf(thePast);
    }
    
    public static void createMarketCapacityWeeks(Date startDate, Integer numWeeks){

        if(startDate == null) startDate = getLastFriday(); // first most recent friday
        if(numWeeks == null) numWeeks = 5;

        List<RST_Market_Capacity__c> mcs = new List<RST_Market_Capacity__c>();
        for(Integer i = 0 ; i < numWeeks; i++){
            RST_Market_Capacity__c mc = new RST_Market_Capacity__c();
            mc.Week_Date__c = startDate;
            startDate = startDate.addDays(7);
            mcs.add(mc);
        }
        insert mcs;
    }

    private static List<RST_Title__c> createTestTitles(Integer numTitles) 
    {
        List<RST_Title__c> titlesToInsert = new List<RST_Title__c>();
        for (Integer i = 1; i <= numTitles; i++) {
            RST_Title__c newTitle = new RST_Title__c(Name = 'Test Title ' + i,
                                                     Distributor__c = 'WB',
                                                     Rating__c = 'R',
                                                     RenTrak_ID__c = String.valueOf(13609 + i),
                									 Wide_Release_Date__c = System.today()
                                                     );
            titlesToInsert.add(newTitle);
        }
        insert titlesToInsert;
        return titlesToInsert;
    }
    
    private static List<RST_Play_Week__c> createTestPlayWeeks(List<RST_Title__c> titles, Integer numPlayWeeks,
                                                              Decimal startingWkndBOAmount, Decimal startingMdwkBOAmount,
                                                              Decimal constantWkndDropRate, Decimal constantMdwkDropRate) 
    {
        createMarketCapacityWeeks(null,numPlayWeeks);
        
        Decimal currentWkndBO = startingWkndBOAmount;
        Decimal currentMdwkBO = startingMdwkBOAmount;                                                        
        List<RST_Play_Week__c> playWeeksToInsert = new List<RST_Play_Week__c>();                                                        
        for (RST_Title__c t : titles) {
            //Date currDate = System.today();
            Date lastFriday = getLastFriday();
            
            List<RST_Market_Capacity__c> mcList = [SELECT Id FROM RST_Market_Capacity__c];
            //create playweeks
            for (Integer i = 1; i <= numPlayWeeks; i++) {
                RST_Play_Week__c newPlayWeek = new RST_Play_Week__c(Name = t.Name + ' Week ' + String.valueOf(i),
                                                                    Play_Week__c = i,
                                                                    Title__c = t.id,
                                                                    RenTrak_Id__c = t.RenTrak_ID__c,
                                                                    Weekend_BO__c = (i == 1) ? startingWkndBOAmount/1000000 : (startingWkndBOAmount + (startingWkndBOAmount * (constantWkndDropRate/100)))/1000000,
                                                                    Weekend_Drop__c = (i == 1) ? null : constantWkndDropRate,
                                                                    MidWeek_BO__c = (i == 1) ? startingMdwkBOAmount/1000000 : (startingMdwkBOAmount + (startingMdwkBOAmount * (constantMdwkDropRate/100)))/1000000,
                                                                    MidWeek_Drop__c = (i == 1) ? null : constantMdwkDropRate,
                                                                    Source__c = (i / numPlayWeeks <= 0.5) ? 'Magic' : 'CSV',
                                                                    Week_Date__c = lastFriday,
                                                                    Title_Open_Date__c = t.Wide_Release_Date__c,
                                                                    Market_Max__c = 500000,
                                                                    Market_Capacity__c = mcList[i-1].id);
                playWeeksToInsert.add(newPlayWeek);
                lastFriday = lastFriday + 7;
            }
        }
        insert playWeeksToInsert;
        return playWeeksToInsert;
    }
    
    /***********Test Methods for RST_ViewController***********/
    public static testmethod void lockTitleTest() {
        //Test error lock title
        String errorMessage = RST_ViewController.setTitleLocked('not an id', false);
        System.assert(errorMessage.contains('Fail'));
        
        //Test successful lock title
        List<RST_Title__c> titleList = createTestTitles(1);
        String successMessage = RST_ViewController.setTitleLocked(titleList[0].Id, false);
        System.assert(successMessage.contains('Success'));   
        
        List<RST_Title__c> titleList2 = RST_ViewController.getTitlesAll();
        System.assertEquals(1, titleList2.size());
    }
    
    public static testmethod void getMarketCapacityWeeksTest() {
        createMarketCapacityWeeks(null, 20);
        RST_ViewController.getWeeksAll();
        List<RST_Market_Capacity__c> mcList = [SELECT Id FROM RST_Market_Capacity__c];
        System.assertEquals(20, mcList.size());
    }
    
    public static testmethod void getPlayWeeksForWeekTest() {
        Date d = getLastFriday();
        List<RST_Title__c> titleList = createTestTitles(3);
        List<RST_Play_Week__c> pwList = createTestPlayWeeks(titleList, 15, 20000000, 10000000, -50.00, -50.00);
        RST_ViewController.WeekDetails wd = RST_ViewController.getPlayWeeksForWeek(String.valueOf(d));
        System.assertEquals(3, wd.titlePlayWeeks.size());
        d = d + (7 * 14);
        RST_ViewController.WeekDetails wd2 = RST_ViewController.getPlayWeeksForWeek(String.valueOf(d));
        System.assertEquals(3, wd2.titlePlayWeeks.size());
    }
    
    public static testmethod void nestedPlayWeeksTest() {
        List<RST_Title__c> titleList = createTestTitles(3);
        List<RST_Play_Week__c> pwList = createTestPlayWeeks(titleList, 15, 20000000, 10000000, -50.00, -50.00);
        Map<Id, RST_Play_Week__C> pwMap = new Map<Id, RST_Play_Week__c>();
        for (RST_Play_Week__c pw : pwList) {
            pwMap.put(pw.Id, pw);
        }
        RST_ViewController.PlayWeek pw = RST_ViewController.getNestedPlayWeeks(titleList[0].id);
        Date d = getLastFriday();
        System.assertEquals(pw.pw.Weekend_BO__c, 20);
        List<RST_Play_Week__c> pwList2 = new List<RST_Play_Week__c>();
        RST_ViewController.PlayWeek pw2 = RST_ViewController.setNestedPlayWeeks(titleList[0].id, JSON.serialize(pw));
        System.assertEquals(pw2.pw.MidWeek_BO__c, 10);
    }
    
    public static testmethod void getApplicationSettings() {
        RST_Application_Setting__mdt appSettings = RST_ViewController.getApplicationSettings();
        System.assertNotEquals(null, appSettings);
    }
    /***********End of Test Methods for RST_ViewController***********/
    
    /***********Test Methods for RST_VF_Reports_Controller***********/
    
	
}