/*
 * Author: Kyle Novelli
 * Date: 12/04/2018
 * Company: Slalom
 * Description: Class used to hold Business logic for Apex Trigger: RST_Playweek_Trigger
 * 
 * 				After Insert: First handle creating the parent/child relationship between PlayWeeks.
 * 							  Retrieve inserted PlayWeeks with source = 'Magic' or 'CSV'.
 * 							  PlayWeeks are then placed into a Map with their related Title.
 * 							  Each of the PlayWeeks children have their Cumulative BOs updated
 * 							  and either BOs or BO Drop Rates updated based on their parent PlayWeek.
 * 
 * 				After Update: First handle maintaining the parent/child relationship between PlayWeeks.
 * 							  Retrieve updated PlayWeeks where the Source has changed from 'User' or 'CSV'
 * 							  to 'Magic' OR Source = 'Magic' and either BO values have changed.			  
 * 							  PlayWeeks are then placed into a Map with their related Title.
 * 							  Each of the PlayWeeks children have their Cumulative BOs updated
 * 							  and either BOs or BO Drop Rates updated based on their parent PlayWeek.
 */ 
public class RST_Playweek_TriggerHandler extends TriggerHandler {
	 
    public override void afterInsert() {
        RST_Utilities.parentPlayWeeks();
        //Get all PlayWeeks being inserted with Source = 'Magic' or Source = 'CSV'
        List<RST_Play_Week__c> newMagicPlayWeeks = [SELECT Id, Name, Midweek_BO__c, Midweek_Drop__c, Play_Week__c, Play_Week_Child__c,
                                                      	   Play_Week_Parent__c, Source__c, Title__c, Weekend_BO__c, Weekend_Drop__c
                                                    FROM RST_Play_Week__c
                                                    WHERE Id IN :(List<RST_Play_Week__c>)Trigger.new AND (Source__c = 'Magic' OR Source__c = 'CSV')
                                                    ORDER BY Title__c, Play_Week__c];
        Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap = RST_Utilities.getTitlePlayWeekMap(newMagicPlayWeeks);
        RST_Utilities.updatePlayWeeksChildren(titlePlayWeekMap); 
        updateCumulativeBOs(titlePlayWeekMap);
    }
    
    public override void afterUpdate() {
        RST_Utilities.parentPlayWeeks();
        updatePlayWeeksChildrenAfterMagicUpdate((Map<Id, RST_Play_Week__c>) Trigger.oldMap,
                                                (Map<Id, RST_Play_Week__c>) Trigger.newMap);
        updateCumulativeBOsAfterUpdate((Map<Id, RST_Play_Week__c>) Trigger.oldMap,
                                       (Map<Id, RST_Play_Week__c>) Trigger.newMap);
    }
    
    public static void updateCumulativeBOs(Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap) {
        List<RST_Play_Week__c> playWeeksToUpdate = new List<RST_Play_Week__c>();
        Decimal currentCumulativeBO;
        for (Id titleId : titlePlayWeekMap.keySet()) {
            currentCumulativeBO = 0.0;
            for (RST_Play_Week__c pw : titlePlayWeekMap.get(titleId)) {
                currentCumulativeBO = currentCumulativeBO + pw.Weekend_BO__c + pw.MidWeek_BO__c;
                pw.Cumulative__c = currentCumulativeBO;
                playWeeksToUpdate.add(pw);
            }
        }
        update playWeeksToUpdate;
    }
    
    public static void updateCumulativeBOsAfterUpdate(Map<Id, RST_Play_Week__c> oldPlayWeeks,
                                                      Map<id, RST_Play_Week__c> newPlayWeeks) 
    {
		List<RST_Play_Week__c> magicPlayWeeks = getMagicPlayWeeks(oldPlayWeeks, newPlayWeeks); 
        Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap = RST_Utilities.getTitlePlayWeekMap(magicPlayWeeks);
        updateCumulativeBOs(titlePlayWeekMap);                                                  
    }

    public static void updatePlayWeeksChildrenAfterMagicUpdate(Map<Id, RST_Play_Week__c> oldPlayWeeks,
                                                               Map<id, RST_Play_Week__c> newPlayWeeks) 
    {
     	List<RST_Play_Week__c> magicPlayWeeks = getMagicPlayWeeks(oldPlayWeeks, newPlayWeeks);
        Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap = RST_Utilities.getTitlePlayWeekMap(magicPlayWeeks);
        RST_Utilities.updatePlayWeeksChildren(titlePlayWeekMap);    
    }
    
    public static List<RST_Play_Week__c> getMagicPlayWeeks(Map<Id, RST_Play_Week__c> oldPlayWeeks,
                                                          Map<id, RST_Play_Week__c> newPlayWeeks) 
    {
        List<Id> pwResultIds = new List<Id>();
        List<RST_Play_Week__c> pwResults = new List<RST_Play_Week__c>();
        //iterate through Lists of Play Weeks and populate a List of Play Weeks that meet the criteria: 
        //Old Play Week Source NOT equal to 'Magic' AND New Play Week Source equal to 'Magic' (the case that CSV and Magic data matches)
        //OR
        //New Play Week Source equal to 'Magic' AND (Weekend BO changed OR MidWeek BO changed)
        for (Id pwId : newPlayWeeks.keySet()) {
            if( (oldPlayWeeks.get(pwId).Source__c != 'Magic' && newPlayWeeks.get(pwId).Source__c == 'Magic') || 
              (newPlayWeeks.get(pwId).Source__c == 'Magic' && 
              (oldPlayWeeks.get(pwId).Weekend_BO__c != newPlayWeeks.get(pwId).Weekend_BO__c || oldPlayWeeks.get(pwId).Midweek_BO__c != newPlayWeeks.get(pwId).Midweek_BO__c)) ) {
                  pwResultIds.add(pwId);
            }
        }
        if (pwResultIds.size() > 0) {
            pWResults = [SELECT Id, Name, Midweek_BO__c, Midweek_Drop__c, Play_Week__c, Play_Week_Child__c,
                          Play_Week_Parent__c, Source__c, Title__c, Weekend_BO__c, Weekend_Drop__c
                          FROM RST_Play_Week__c
                          WHERE Id IN :pwResultIds
                          ORDER BY Title__c, Play_Week__c];
        }
        return pwResults;
    }
}