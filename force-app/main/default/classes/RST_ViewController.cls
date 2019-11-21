public with sharing class RST_ViewController {
    
/*
* Code assisting with lighting components: RST_TitleDetail
* 											RST_PlayWeek_Detail
* 										    RST_MarketCapacity
* @LastmModifiedby --> saurav- COES-25
* @LastModifieddate --> 18/03/2019
*
* @group --> NBCU : Home Entertainment(Film org), App: RST
* 
*/
    
    
    @AuraEnabled
    public static RST_Application_Setting__mdt getApplicationSettings() {
        return [SELECT Title_Report_URL__c, Market_Capacity_Week_Range__c, Title_Week_Range__c, Weeks_Before_Title_Start_Date__c
                FROM RST_Application_Setting__mdt
                WHERE DeveloperName = 'Standard' LIMIT 1];
    }
    
    @AuraEnabled
    public static List<RST_Market_Capacity__c> getWeeksAll(){
        List<RST_Market_Capacity__c> weeks = [SELECT Id, Name ,
                                              Average_Available_dollars__c,
                                              Average_Market_Capacity__c,
                                              Max_Available_dollars__c,
                                              Max_Market_Capacity__c,
                                              Min_Available_dollars__c,
                                              Min_Market_Capacity__c,
                                              Occupied_dollars__c,
                                              Occupied_dollar__c,
                                              Week_Date__c
                                              FROM 
                                              RST_Market_Capacity__c WHERE CALENDAR_YEAR(Week_Date__c) >= 2016 ORDER BY Week_Date__c];
        return weeks;
    }
    
    @AuraEnabled
    public static WeekDetails getPlayWeeksForWeek(String weekSelected){
        WeekDetails response = new WeekDetails();
        system.debug('weekSelected');
        system.debug(weekSelected);
        
        String yyyy, mm, dd;
        yyyy = weekSelected.mid(0,4);
        mm = weekSelected.mid(5,2);
        dd = weekSelected.mid(8,2);
        system.debug('parse this: ' + yyyy + '/' + mm + '/' + dd);
        Date useWeekDate = date.parse( mm + '/' + dd + '/' + yyyy);
        system.debug('useWeekDate');
        system.debug(useWeekDate);
        
        List<RST_Play_Week__c> playweeks = [SELECT Id, Name,
                                            Midweek_BO__c,
                                            Midweek_Drop__c,
                                            Play_Week__c,
                                            Play_Week_Child__c,
                                            Play_Week_Parent__c,
                                            Source__c,
                                            Title__r.Name,
                                            Week_Date__c,
                                            Weekend_BO__c,
                                            Weekend_Drop__c,
                                            Cumulative__c,
                                            LastModifiedBy.Name,
                                            LastModifiedDate,
                                            Total_BO_formula__c,
                                            TST_Total_Week_BO_Drop__c,
                                            Title__r.Distributor__c, 
                                            Title__r.Rating__c, 
                                            Title__r.Lock_Title__c        
                                            FROM 
                                            RST_Play_Week__c
                                            WHERE 
                                            Week_Date__c = :useWeekDate
                                            ORDER BY Weekend_BO__c DESC];
        response.titlePlayWeeks = playweeks;
        return response;
    }
    
    
    @AuraEnabled
    public static List<RST_Title__c> getTitlesAll() {
        List<RST_Title__c> titles = [SELECT Id, Name,
                                     Distributor__c, 
                                     FS_O_Genre__c, 
                                     Lock_Title__c, 
                                     Magic_Id__c, 
                                     Multiple__c,
                                     Rating__c, 
                                     Release_Pattern__c, 
                                     RenTrak_Genre__c, 
                                     RenTrak_ID__c, 
                                     Total_Cumulative_BO__c, 
                                     Wide_Opening_Weekend__c, 
                                     Wide_Release_Date__c,
                                     LastModifiedBy.Name,
                                     LastModifiedDate
                                     FROM 
                                     RST_Title__c WHERE CALENDAR_YEAR( Wide_Release_Date__c) >= 2016
                                     ORDER BY Name];
        return titles;    
    }
    
    /**
    * @description --> Apex Controller for RST_TitleDetail Lightning Comp- COES-25
    * @method--> sortingByFieldOfTittle
    * @param --> String: sortField and boolean: isAsc :- Sorting by field.
    * @return --> List of RST_Title__c
    */ 
    @AuraEnabled
    public static list <RST_Title__c> sortingByFieldOfTittle(String sortField, boolean isAsc) {
        String sSoqlForTitle = 'SELECT Id,Name,Distributor__c,FS_O_Genre__c,Lock_Title__c,Magic_Id__c,Multiple__c,Rating__c,Release_Pattern__c, RenTrak_Genre__c, RenTrak_ID__c, Total_Cumulative_BO__c, Wide_Opening_Weekend__c,Wide_Release_Date__c, LastModifiedBy.Name,LastModifiedDate';
        sSoqlForTitle += ' From RST_Title__c WHERE CALENDAR_YEAR( Wide_Release_Date__c) >= 2016';
        system.debug('sortField-->' + sortField);
        
        if (sortField != '') {
            sSoqlForTitle += ' order by ' + sortField;
            if (isAsc) {
                sSoqlForTitle += ' asc';
            } else {
                sSoqlForTitle += ' desc';
            }
        }
        system.debug('Query for Title '+sSoqlForTitle);
        List<RST_Title__c> listOfTitle= new List<RST_Title__c>();
        List <RST_Title__c> finalListOfTitle = new List <RST_Title__c>();
        try {
            listOfTitle = Database.query(sSoqlForTitle);
            if(listOfTitle!=null){
            for (RST_Title__c c: listOfTitle) {
                finalListOfTitle.add(c);
            }
          }
            return finalListOfTitle;
        } 
        catch (Exception ex) {
            system.debug('The following exception has occurred: Empty finalListOfTitle' + ex.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static String setTitleLocked(String titleId, Boolean isLocked){
        try{
            RST_Title__c thisTitle = new RST_Title__c(Id = titleId, Lock_Title__c = isLocked);
            upsert thisTitle;
        }catch(Exception e){
            return 'Fail - ' + e.getMessage();
        }
        return 'Success';
    }
    @AuraEnabled
    public static PlayWeek setNestedPlayWeeks(String titleId, String titlePlayWeek){
        system.debug('titlePlayWeek');
        system.debug(titlePlayWeek);
        
        PlayWeek this_pw = (PlayWeek)JSON.deserialize(titlePlayWeek, PlayWeek.class);
        
        system.debug('this_pw');
        system.debug(this_pw);
        
        List<RST_Play_Week__c> pws = new List<RST_Play_Week__c>();
        pws = getPlayWeekList(this_pw, pws);
        
        system.debug('pws');
        
        
        for(RST_Play_Week__c pw : pws){
            system.debug(pw);
        }
        
        upsert pws;
        
        return getNestedPlayWeeks(titleId);
    }
    
    @AuraEnabled
    public static PlayWeek getNestedPlayWeeks(String titleId){
        Map<Id, RST_Play_Week__c> playweeks = new Map<Id, RST_Play_Week__c>([SELECT Id, Name,
                                                                             Midweek_BO__c,
                                                                             Midweek_Drop__c,
                                                                             Play_Week__c,
                                                                             Play_Week_Child__c,
                                                                             Play_Week_Parent__c,
                                                                             Source__c,
                                                                             Title__r.Name,
                                                                             Week_Date__c,
                                                                             Weekend_BO__c,
                                                                             Weekend_Drop__c,
                                                                             Cumulative__c,
                                                                             LastModifiedBy.Name,
                                                                             LastModifiedDate,
                                                                             Total_BO_formula__c,
                                                                             TST_Total_Week_BO_Drop__c,
                                                                             Title__r.Distributor__c, 
                                                                             Title__r.Rating__c, 
                                                                             Title__r.Lock_Title__c
                                                                             FROM 
                                                                             RST_Play_Week__c
                                                                             WHERE 
                                                                             Title__c = :titleId
                                                                             ORDER BY 
                                                                             Week_Date__c]);
        
        PlayWeek usePW = new PlayWeek();
        //for(Play_Week__c pw :playweeks ){
        
        usePW.pw = playweeks.values()[0]; //playweeks.get(playweeks.keySet()[0]);
        usePW.child = loadChild(playweeks, usePW.pw.Play_Week_Child__c);
        //}
        return usePW;
    }
    
    private static PlayWeek loadChild(Map<Id,RST_Play_Week__c> pwMap, Id parentId ){
        if(parentId != null){
            PlayWeek childPW = new PlayWeek();
            childPW.pw = pwMap.get(parentId);
            childPW.child = loadChild(pwMap, childPW.pw.Play_Week_Child__c);
            return childPW;
        }
        return null;
    }
    private static List<RST_Play_Week__c> getPlayWeekList(PlayWeek pw, List<RST_Play_Week__c> this_list){
        this_list.add(pw.pw);
        if(pw.child != null){
            return getPlayWeekList(pw.child, this_list);
        } 
        return this_list;
    }
    public class PlayWeek{
        @AuraEnabled public RST_Play_Week__c pw {get;set;}
        @AuraEnabled public PlayWeek child {get;set;}
    }
    
    public class WeekDetails{
        @AuraEnabled public List<RST_Play_Week__c> titlePlayWeeks {get;set;}
    }
    
}