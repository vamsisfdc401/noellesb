/*****************************************************************************************
Class Name: UpdatePlayWeekDatesHandler
Purpose: Class for handling RST Title Trigger (JIRA Ticket - COES-28)
******************************************************************************************
Version         DateModified            ModifiedBy                  Change
1.0             03/27/2019              Piyush                       Initial Development 
******************************************************************************************/
public class RST_TitleTriggerHandler {
    
    // used to update playweek date when wide_release_date changes
    public static void updatePlayWeekDate(List<RST_Title__c> lstRSTTitle,Map<ID,RST_Title__c> mapOldRSTTitle){
        Map<ID,RST_Title__c> mapRSTTitle = new Map<ID,RST_Title__c>();
        for(RST_Title__c rstTitle : lstRSTTitle){
            if(rstTitle.Wide_Release_Date__c != mapOldRSTTitle.get(rstTitle.Id).Wide_Release_Date__c){
			 mapRSTTitle.put(rstTitle.Id,rstTitle);      
            }
        }
        if(!mapRSTTitle.IsEmpty()){
            List<RST_Play_Week__c> lstPlayWeeks = new List<RST_Play_Week__c>();
            for(RST_Play_Week__c rstPlayWeek : [Select Play_Week__c,Title__c,Week_Date__c from RST_Play_Week__c where Title__c in:mapRSTTitle.keySet()]){
                if(rstPlayWeek.Play_Week__c != null){
                    if(rstPlayWeek.Play_Week__c == 1){
                        rstPlayWeek.Week_Date__c = mapRSTTitle.get(rstPlayWeek.Title__c).Wide_Release_Date__c;
                    }
                    else if(rstPlayWeek.Play_Week__c > 1){
                          Integer weeknum=(Integer)rstPlayWeek.Play_Week__c;  
                          rstPlayWeek.Week_Date__c=mapRSTTitle.get(rstPlayWeek.Title__c).Wide_Release_Date__c.addDays(7*(weeknum-1));
                    }
                    lstPlayWeeks.add(rstPlayWeek);
                }
            }
            if(!lstPlayWeeks.IsEmpty()){
                update lstPlayWeeks;
            }
        }
    }

}