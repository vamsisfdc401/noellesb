public with sharing class RST_ForecastController {
    /*
    @AuraEnabled
    public static List<RST_Version__c> getAllVersions(){
        return [SELECT Id, Name FROM RST_Version__c];
    }


    @AuraEnabled
    public static String getVersionMagic(Id versionId){
        System.debug('go to magic for version ' + versionId);
        return RST_Controller.callMagicForVersion(versionId);
    }
    */
    
    /*
    no longer grabbing magic data by title id
    @AuraEnabled
    public static String getTitleMagic(String titleRentrakId){
        System.debug('go to magic for title rentrak ' + titleRentrakId);
        return RST_Controller.callMagicForTitle(titleRentrakId);
    }
    */
    

    /*
    @AuraEnabled
    public static List<Week> getVersionWeeks(Id versionId){

        List<Week> v_weeks = new List<Week>();
        Date use_start_date = system.today().toStartOfWeek().addDays(5);
        Date use_end_date = system.today().addMonths(4).toStartOfWeek().addDays(5);

        

        //select count(id) , Week_Date__c FROM RST_Play_Week__c group by Week_Date__c order by Week_Date__c
        AggregateResult[] ars = [SELECT Count(id) Num, Week_Date__c Week FROM RST_Play_Week__c GROUP BY Week_Date__c ORDER BY Week_Date__c];
        for (AggregateResult ar : ars)  {
            Week temp_week = new Week();
            System.debug('rId' + ar.get('Week'));
            System.debug('count' + ar.get('Num'));   
            temp_week.weekDate = (Date) ar.get('Week') ;
            temp_week.numTitles = (Integer) ar.get('Num') ;

            if(temp_week.weekDate == use_start_date ) temp_week.isStartDate = true;
            if(temp_week.weekDate == use_end_date ) temp_week.isEndDate = true;
            v_weeks.add(temp_week);
        }
        
        return v_weeks;
    }

    @AuraEnabled
    public static VersionInfo getVersionWeeksDetail(Id versionId, String startDate, String endDate){
        system.debug('versionId ' + versionId);
        system.debug('startDate ' + startDate);
        system.debug('endDate ' + endDate);

        Date useStartDate = Date.valueOf(startDate);
        Date useEndDate = Date.valueOf(endDate);

        system.debug('useStartDate ' + useStartDate);
        system.debug('useEndDate ' + useEndDate);

        
        RST_Version__c version = [SELECT Id, Name FROM RST_Version__c WHERE Id = :versionId];
        List<RST_Play_Week__c> version_weeks = [SELECT Id, Name, 
                                        Market_Max__c,
                                        Play_Week__c,
                                        RenTrak_Id__c,
                                        Title_Open_Date__c,
                                        //Title_TEMP__c,
                                        Total_Week__c,
                                        Week_Date__c,
                                        Weekend_Drop__c
                                    FROM
                                        RST_Play_Week__c
                                    WHERE 
                                        Version__c = :versionId AND
                                        Week_Date__c >= :useStartDate AND
                                        Week_Date__c <= :useEndDate 
                                    ORDER BY
                                        //Title_TEMP__c, 
                                        Week_Date__c];
        VersionInfo vi = new VersionInfo();
        vi.version = version;
        Set<String> titles_used = new Set<String>();
        Set<Date> weeks_used = new Set<Date>();
        List<Week> pre_weeks = new List<Week>();
        //Date minDate, maxDate;
        Title cur_title; 
        for(RST_Play_Week__c pw : version_weeks){
            if(!titles_used.contains(pw.Title_TEMP__c)){

                
                cur_title = new Title();
                cur_title.name = pw.Title_TEMP__c;
                cur_title.renTrakId = pw.RenTrak_Id__c;
                cur_title.startDate = pw.Title_Open_Date__c;
                vi.titles.add(cur_title);
                titles_used.add(pw.Title_TEMP__c);
            }
            
            if(!weeks_used.contains(pw.Week_Date__c)){
                Week this_week = new Week();
                //this_week.useDate = pw.Week_Date__c;
                this_week.weekDate = pw.Week_Date__c; //.format();
                //this_week.marketCap = pw.Market_Max__c.setscale(3);
                pre_weeks.add(this_week);
                weeks_used.add(pw.Week_Date__c);
            }
            // fix amount for sisplay in millions
            //pw.Total_Week__c = pw.Total_Week__c.setscale(3);
            cur_title.playWeeks.add(pw);
            
        }
        //system.debug(pre_weeks);
        pre_weeks.sort(); // sorted
        //system.debug(pre_weeks);
        vi.weeks = pre_weeks;
        return vi;
        

    }



    @AuraEnabled
    public static VersionInfo getVersion(Id versionId){
        Date startDate, endDate;
        startDate = System.today();
        endDate = startDate.addMonths(2);

        //return getVersionWeeks(versionId, startDate, endDate);
        

        RST_Version__c version = [SELECT Id, Name FROM RST_Version__c WHERE Id = :versionId];
        
        List<RST_Play_Week__c> version_weeks = [SELECT Id, Name, 
                                        Market_Max__c,
                                        Play_Week__c,
                                        RenTrak_Id__c,
                                        Title_Open_Date__c,
                                        Title_TEMP__c,
                                        Total_Week__c,
                                        Title__r.Name,
                                        Week_Date__c,
                                        Weekend_Drop__c
                                    FROM
                                        RST_Play_Week__c
                                    WHERE 
                                        Version__c = :versionId AND
                                        Week_Date__c = NEXT_N_MONTHS:2
                                    ORDER BY
                                        Title_TEMP__c, Week_Date__c];

        VersionInfo vi = new VersionInfo();
        vi.version = version;
        Set<String> titles_used = new Set<String>();
        Set<Date> weeks_used = new Set<Date>();
        List<Week> pre_weeks = new List<Week>();
        //Date minDate, maxDate;
        Title cur_title; 
        for(RST_Play_Week__c pw : version_weeks){
            if(!titles_used.contains(pw.Title__r.Name)){

                
                cur_title = new Title();
                cur_title.name = pw.Title__r.Name;
                cur_title.renTrakId = pw.RenTrak_Id__c;
                cur_title.startDate = pw.Title_Open_Date__c;
                vi.titles.add(cur_title);
                titles_used.add(pw.Title_TEMP__c);
            }
            
            if(!weeks_used.contains(pw.Week_Date__c)){
                Week this_week = new Week();
                //this_week.useDate = pw.Week_Date__c;
                this_week.weekDate = pw.Week_Date__c; //.format();
                //this_week.marketCap = pw.Market_Max__c.setscale(3);
                pre_weeks.add(this_week);
                weeks_used.add(pw.Week_Date__c);
            }
            // fix amount for sisplay in millions
            //pw.Total_Week__c = pw.Total_Week__c.setscale(3);
            cur_title.playWeeks.add(pw);
            
        }
        //system.debug(pre_weeks);
        pre_weeks.sort(); // sorted
        //system.debug(pre_weeks);
        vi.weeks = pre_weeks;
        return vi;
        
    }

    public class VersionInfo{
        
        @AuraEnabled public RST_Version__c version {get;set;}
        @AuraEnabled public List<Title> titles{get;set;}
        @AuraEnabled public List<Week> weeks{get;set;}
        @AuraEnabled public date minDate {get;set;}
        @AuraEnabled public date maxDate {get;set;}

        public VersionInfo(){
            titles = new List<Title>();
            weeks = new List<Week>();
        }
        
    }

    public class Title{
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public string renTrakId {get;set;}
        @AuraEnabled public string posterUrl {get;set;}
        @AuraEnabled public date startDate {get;set;}
        @AuraEnabled public List<RST_Play_Week__c> playWeeks {get;set;}
        //@AuraEnabled public Map<String, RST_Play_Week__c> playWeeksMap {get;set;}

        public Title(){
            playWeeks = new List<RST_Play_Week__c>();
            //playWeeksMap = new Map<String, RST_Play_Week__c>();
        }

    }

    public class Week implements Comparable{
        //@AuraEnabled public date useDate {get;set;}
        @AuraEnabled public Date weekDate {get;set;}
        @AuraEnabled public Boolean isStartDate {get;set;}
        @AuraEnabled public Boolean isEndDate {get;set;}
        @AuraEnabled public decimal marketCap {get;set;}
        @AuraEnabled public Integer numTitles {get;set;}

        public Integer compareTo(Object compareTo) {
            Week compareToWeek = (Week)compareTo;
            if (weekDate == compareToWeek.weekDate) return 0;
            if (weekDate > compareToWeek.weekDate) return 1;
            return -1;        
        }
    }
    */
}