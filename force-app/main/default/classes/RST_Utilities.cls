public with sharing class RST_Utilities {
    
    public static Date convertMagicDate(String magicDate){
        //Date useDate = system.today();
        String yyyy, mm, dd;
        yyyy = magicDate.mid(0,4);
        mm = magicDate.mid(4,2);
        dd = magicDate.mid(6,2);
        system.debug('parse this: ' + yyyy + '/' + mm + '/' + dd);
        return date.parse( mm + '/' + dd + '/' + yyyy);
        
    }

    public static Set<String> getRentrakIdsFromSFId(Set<String> sfIds){
        Set<String> rentrakIds = new Set<String>();
        for(RST_Title__c selectedTitle : [SELECT Id, RenTrak_Id__c FROM RST_Title__c WHERE Id IN :sfIds]){
            rentrakIds.add(selectedTitle.RenTrak_Id__c);
        }
        return rentrakIds;
    }
    public Static Map<String, Map<String, RST_Play_Week__c>> getRentrakPlayWeekMapForTitleId(Set<String> titleIds){
        Set<String> rentrakIds = getRentrakIdsFromSFId(titleIds);
        return getRentrakPlayWeekMap(rentrakIds);
    }

    public Static Map<String, Map<String, RST_Play_Week__c>> getRentrakPlayWeekMap(Set<String> rentrakIds){
        //Map<String, Map<String, RST_Play_Week__c>> myMap = new Map<String, Map<String, RST_Play_Week__c>>();

        List<RST_Play_Week__c> rentrakPlayWeeks = [SELECT Id, Name, Weekend_BO__c , Midweek_BO__c, Play_Week__c, Source__c, RenTrak_Id__c, Title__c, Total_BO_formula__c, Week_Date__c FROM RST_Play_Week__c WHERE RenTrak_Id__c IN :rentrakIds ORDER BY RenTrak_Id__c];
            // first map for rentrak, second map for week
        Map<String, Map<String, RST_Play_Week__c>> rentrakPlayWeekWeekMap = new Map<String, Map<String,RST_Play_Week__c>>();
        for(RST_Play_Week__c pw : rentrakPlayWeeks){
            Map<String, RST_Play_Week__c> weekMap = rentrakPlayWeekWeekMap.get(pw.RenTrak_Id__c);
            if(weekMap == null) weekMap = new Map<String, RST_Play_Week__c>();
            weekMap.put(String.valueOf(pw.Play_Week__c), pw);
            rentrakPlayWeekWeekMap.put(pw.RenTrak_Id__c, weekMap);
        }

        return rentrakPlayWeekWeekMap; 
    }
    
    public static void parentPlayWeeks() {
        //system.debug('process play weeks for parent child relationship');
        
        Set<String> orphanedTitles = new Set<String>();
        for(AggregateResult ar : [SELECT Title__c FROM RST_Play_Week__c WHERE ParentProcessed__c = false AND Play_Week__c != null GROUP BY Title__c]){
            orphanedTitles.add((String) ar.get('Title__c'));
        }
        system.debug('unique title ids');
        system.debug(orphanedTitles);

        if(orphanedTitles.size() > 0){

        
            List<RST_Play_Week__c> pws = [SELECT Id, 
                                    Title__c,
                                    Title__r.Name,
                                    Play_Week__c, 
                                    Play_Week_Child__c, 
                                    Play_Week_Parent__c 
                                FROM 
                                    RST_Play_Week__c 
                                WHERE 
                                    Title__c IN :orphanedTitles
                                ORDER BY 
                                    Title__r.Name, Week_Date__c];
            //system.debug('unprocessed playweeks ' + pws.size());       
            Integer n = pws.size() - 1;         
            if(n > 1){           
                for(integer i = 1; i < n; i++){
                    //system.debug('pws[' + i + ']: ' + pws[i]);
                    pws[i].Play_Week_Parent__c = (pws[i-1].Title__c == pws[i].Title__c && pws[i-1].Play_Week__c == (pws[i].Play_Week__c - 1)) ? pws[i-1].Id : null;
                    pws[i].Play_Week_Child__c = (pws[i+1].Title__c == pws[i].Title__c && pws[i+1].Play_Week__c == (pws[i].Play_Week__c + 1)) ? pws[i+1].Id : null;
                    pws[i].ParentProcessed__c = true;
                }
                    
                pws[n].ParentProcessed__c = true;
                pws[n].Play_Week_Parent__c = (pws[n-1].Title__c == pws[n].Title__c && pws[n-1].Play_Week__c == (pws[n].Play_Week__c + 1)) ? pws[n-1].Id : null;
                pws[0].Play_Week_Child__c = (pws[1].Title__c == pws[0].Title__c && pws[0].Play_Week__c == (pws[1].Play_Week__c - 1)) ? pws[1].Id : null;
                pws[0].ParentProcessed__c = true;
            }
            //system.debug(pws[n]);
            //system.debug(pws[0]);

            update pws;
        }
    }
    
    //Return a Map of <Id(Title Id), List<RST_Play_Week__c>(Playweeks related to Title)>
    public static Map<Id, List<RST_Play_Week__c>> getTitlePlayWeekMap(List<RST_Play_Week__c> pwList) {
        //Gather all Title Ids related to each Play Week in the list
        Set<Id> titleIdList = new Set<Id>();
        for (RST_Play_Week__c pw : pwList) {
            titleIdList.add(pw.Title__c);
        }
        //Query for all PlayWeeks related to the Title Ids from original Play Week List
        List<RST_Play_Week__c> allPlayWeeksToConsider = new List<RST_Play_Week__c>();
        if (titleIdList.size() > 0) {
            allPlayWeeksToConsider = [SELECT Id, Name, Midweek_BO__c, Midweek_Drop__c, Play_Week__c, Play_Week_Child__c,
                                      Play_Week_Parent__c, Source__c, Title__c, Weekend_BO__c, Weekend_Drop__c
                                      FROM RST_Play_Week__c
                                      WHERE Title__c IN :titleIdList
                                      ORDER BY Title__c, Play_Week__c];
        }
        //Populate Map of <Id(Title ID), List<RST_Play_Week__c>(Play Weeks related to Title)>
        Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap = new Map<Id, List<RST_Play_Week__c>>();

        for(RST_Play_Week__c pw : allPlayWeeksToConsider) {
            	if(titlePlayWeekMap.containsKey(pw.Title__c)) {
                    List<RST_Play_Week__c> playWeeks = titlePlayWeekMap.get(pw.Title__c);
                    playWeeks.add(pw);
                    titlePlayWeekMap.put(pw.Title__c, playWeeks);
                } 
                else {
                        titlePlayWeekMap.put(pw.Title__c, new List<RST_Play_Week__c> {pw});
                }
        }
        return titlePlayWeekMap;
    }
	
    //Updates BOs for Magic Play Weeks and updates Drop Rates for Non-Magic PlayWeeks
    public static void updatePlayWeeksChildren(Map<Id, List<RST_Play_Week__c>> titlePlayWeekMap) {
        List<RST_Play_Week__c> playWeeksToUpdate = new List<RST_Play_Week__c>();
		
        //Iterate through each title and update each title's Play Weeks
        for (Id titleId : titlePlayWeekMap.keySet()) {
            RST_Play_Week__c currentPlayWeek = titlePlayWeekMap.get(titleId)[0];
            RST_Play_Week__c currentPlayWeekChild = new RST_Play_Week__c();
            Integer index = 1; //index for first child playweek
            Integer playWeekListSize = titlePlayWeekMap.get(titleId).size();
            
            //Main loop which goes through list of PlayWeeks in Title/PlayWeek map
			while (index < playWeekListSize) {
                //If the current play week has no parent, update its drop rates to null
                if (currentPlayWeek.Play_Week_Parent__c == null && currentPlayWeek.Play_Week__c == 1) {
                    currentPlayWeek.Weekend_Drop__c = null;
                    currentPlayWeek.Midweek_Drop__c = null;
                    playWeeksToUpdate.add(currentPlayWeek);
                }
                
                //Only update child play weeks if the current play week has a child
                if(currentPlayWeek.Play_Week_Child__c != null) {
                    //Get child of current Play Week
                    currentPlayWeekChild = titlePlayWeekMap.get(titleId)[index];
                    //If Child Play Week Source == 'Magic' update its Drop Rates
                    if (currentPlayWeekChild.Source__c == 'Magic') {
                        if (currentPlayWeek.Weekend_BO__c > 0 && currentPlayWeekChild.Weekend_BO__c > 0) {
                        currentPlayWeekChild.Weekend_Drop__c = ((currentPlayWeekChild.Weekend_BO__c / currentPlayWeek.Weekend_BO__c) - 1) * 100; 
                        }
                        else {
                            currentPlayWeekChild.Weekend_Drop__c = 0;
                        }
                        if (currentPlayWeek.MidWeek_BO__c > 0 && currentPlayWeekChild.MidWeek_BO__c > 0) {
                            currentPlayWeekChild.MidWeek_Drop__c = ((currentPlayWeekChild.MidWeek_BO__c / currentPlayWeek.MidWeek_BO__c) - 1) * 100; 
                        }
                        else {
                            currentPlayWeekChild.MidWeek_Drop__c = 0;
                        }
                    } 
                    // Child Play Week Source is not equal to 'Magic'
                    else {
                        if(currentPlayWeek.Weekend_BO__c > 0 && currentPlayWeekChild.Weekend_Drop__c != null) {
                        //Update current Play Week child Weekend BO
                        currentPlayWeekChild.Weekend_BO__c = currentPlayWeek.Weekend_BO__c + 
                                                            (currentPlayWeek.Weekend_BO__c * (currentPlayWeekChild.Weekend_Drop__c/100)); 
                        }
                        if(currentPlayWeek.MidWeek_BO__c > 0 && currentPlayWeekChild.MidWeek_Drop__c != null) {
                            //Update current Play Week child MidWeek BO
                            currentPlayWeekChild.MidWeek_BO__c = currentPlayWeek.MidWeek_BO__c + 
                                                                (currentPlayWeek.MidWeek_BO__c * (currentPlayWeekChild.MidWeek_Drop__c/100)); 
                        }                    
                    }   
                }  
                //current Play Week does not have a child
                else {
                    currentPlayWeekChild = null;
                }
                
                if (currentPlayWeekChild != null) {
                    playWeeksToUpdate.add(currentPlayWeekChild);
                    currentPlayWeek = currentPlayWeekChild;
                }
                //In the case that there are non-consecutive play weeks in title,
                //grab the next playweek in the map, if there is one
                else {
                    //if (index < playWeekListSize) {
                        currentPlayWeek = titlePlayWeekMap.get(titleId)[index];
                    //}
                }
                index++; 
        	}
        }
        /*
        system.debug('playWeeksToUpdate');
        system.debug(playWeeksToUpdate);
        for(RST_Play_Week__c pw : playWeeksToUpdate){
            system.debug(pw);
        }
		*/
        update playWeeksToUpdate;
    }

    //public static void logRST_Error(String className, String methodName, String functionName, String traceString, Boolean isError){
    public static void logRST_Error(String className, Boolean isError, String traceString){
        
        String baseURL = System.URL.getSalesforceBaseUrl().ToExternalForm();

        RST_Process_Log__c  log = new RST_Process_Log__c ();
        log.Base_URL__c = baseURL;
        log.Class__c = className;
		log.isError__c = isError;
        log.Trace__c = traceString;
        log.Type__c = 'CSV';

        insert log;
        
    }
    public static void logMagic_Run(String className, Boolean isError, String traceString){
        
        String baseURL = System.URL.getSalesforceBaseUrl().ToExternalForm();        
        
        RST_Process_Log__c  log = new RST_Process_Log__c ();
        log.Base_URL__c = baseURL;
        log.Class__c = className;
		log.isError__c = isError;
        log.Trace__c = traceString;
        log.Type__c = 'Magic';
        insert log;
        
    }
}