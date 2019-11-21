global class RST_Batch_MagicCallout implements Database.Batchable<String>,   Database.AllowsCallouts,  Database.Stateful, Schedulable{
    
    private RST_MagicInterface.TokenResponse magicTokenResponse;
    RST_Application_Setting__mdt appSettings;
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new RST_Batch_MagicCallout(), 1);
    }
    
    global Iterable<String> start(Database.BatchableContext bc) {
        // store magic token
        magicTokenResponse = RST_MagicInterface.getMagicToken();
        // get basic app settings
        appSettings = [SELECT Playweek_Maximum__c, Playweek_Minimum__c FROM RST_Application_Setting__mdt WHERE DeveloperName = 'Standard' LIMIT 1];
        // use years for batch callout
        return new RST_MagicYearIterable(); 
    }
    
    global void execute(Database.BatchableContext bc, List<String> useYears){
        
        system.debug('useYears : ' + useYears);
        
        system.debug(appSettings); // get app settings for play week min / max
        Integer min_week = Integer.valueOf(appSettings.Playweek_Minimum__c);
        Integer max_week = Integer.valueOf(appSettings.Playweek_Maximum__c);
        Boolean has_min = min_week != null;
        Boolean has_max = max_week != null;
        
        
        for(String useYear : useYears){ // should be only one
            
            Integer startYear = Integer.valueOf(useYear);
            
            string useStartDate = startYear + '-01-01';
            string useEndDate = (startYear + 1) + '-01-01';
            String namedCredential = 'Magic_API';
            String path = '/magic/GetBoxOfficeActual?';
            String uri;
            
            String formattedParameters = 'startDate=' + useStartDate + '&endDate=' + useEndDate;
            system.debug(' go to ' + formattedParameters);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //request.setEndpoint('https://magicstg.api.nbcuni.com/magic/GetBoxOfficeActual?' + formattedParameters);
            uri = (Test.isRunningTest()) ? 'https://callout.' + namedCredential + '.com' + path : 'callout:' + namedCredential + path + formattedParameters;
            //request.setEndpoint('callout:Magic_API/magic/GetBoxOfficeActual?' + formattedParameters);
            request.setEndpoint(uri);
            request.setMethod('GET');
            request.setHeader('Authorization',  'Bearer ' + magicTokenResponse.access_token);
            
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            //system.debug('response.getStatusCode()');
            //system.debug(response.getStatusCode());
            if (response.getStatusCode() == 200) {
                //system.debug('magic body with titles weeks here' );
                //system.debug(response.getBody() );
                Date use_today = system.today();
                
                List<MagicTitle> magicTitles = (List<MagicTitle>)JSON.deserialize(response.getBody(), List<MagicTitle>.class);
                
                //system.debug('we have ' + magicTitles.size() + ' titles for ' + ar.get('openYear'));
                
                //
                // Get all Rentrak Ids from magic data
                //
                Map<String, RST_Title__c> rentrakTitleMap = new Map<String, RST_Title__c>();
                for(MagicTitle mt : magicTitles){
                    system.debug(mt);
                    
                    rentrakTitleMap.put(mt.RenkTrakId, null);
                }
                
                //
                // Get all existing data in salesforce: titles, play weeks, and prime market capacity map for later soql
                //
                Map<String, RST_Title__c> existingTitles = new Map<String, RST_Title__c>();
                for(RST_Title__c  t : [SELECT Id, Name, RenTrak_ID__c, Distributor__c, FS_O_Genre__c, Magic_Id__c, Rating__c, Release_Pattern__c, RenTrak_Genre__c, Wide_Release_Date__c FROM RST_Title__c WHERE RenTrak_ID__c IN :rentrakTitleMap.keyset()]){
                    existingTitles.put(t.RenTrak_ID__c, t);
                }
                
                Map<Date, RST_Market_Capacity__c> mcWeeksMap = new Map<Date, RST_Market_Capacity__c>();
                Map<String, Map<String, RST_Play_Week__c>> rentrakPlayWeekWeekMap = RST_Utilities.getRentrakPlayWeekMap(rentrakTitleMap.keySet());
                List<RST_Title__c> titlesToUpdate = new List<RST_Title__c>();
                //
                // Process magic data against existing data
                //
                for(MagicTitle mt : magicTitles){
                    
                    if(mt.RenkTrakId != null){
                        string rentrakId = mt.RenkTrakId;
                        
                        RST_Title__c curTitle = existingTitles.get(rentrakId);
                        if(curTitle == null){
                            curTitle = new RST_Title__c();
                            curTitle.RenTrak_ID__c = rentrakId;
                        }
                        if(
                            curTitle.Name != mt.Title ||
                            curTitle.Distributor__c != mt.DistributorName ||
                            curTitle.FS_O_Genre__c != mt.FSOGenre ||
                            curTitle.Magic_Id__c != mt.MagicId ||
                            curTitle.Rating__c != mt.RatingName ||
                            curTitle.Release_Pattern__c != mt.ReleasePatternName ||
                            curTitle.RenTrak_Genre__c != mt.MagicGenre ||
                            curTitle.Wide_Release_Date__c != RST_Utilities.convertMagicDate(mt.WideReleasdDate)
                        ){
                            curTitle.Name = mt.Title;
                            curTitle.Distributor__c = mt.DistributorName;
                            curTitle.FS_O_Genre__c = mt.FSOGenre;
                            curTitle.Magic_Id__c = mt.MagicId;
                            curTitle.Rating__c = mt.RatingName;
                            curTitle.Release_Pattern__c = mt.ReleasePatternName;
                            curTitle.RenTrak_Genre__c = mt.MagicGenre;
                            curTitle.Wide_Release_Date__c = RST_Utilities.convertMagicDate(mt.WideReleasdDate);
                            
                            titlesToUpdate.add(curTitle);
                        }
                        existingTitles.put(rentrakId, curTitle);
                        
                        for(MagicPlayWeek mpw : mt.BoxOfficeActuals){
                            
                            Integer usePlayWeek = Integer.valueOf(mpw.PlayWeek);
                            // based on number of playweek, determine if we should save. typicaly save only weeks 1-15 see custom metadata
                            Boolean validPlayWeek = true;
                            if(has_min) validPlayWeek =  (usePlayWeek != null) && Integer.valueOf(usePlayWeek) >= min_week; 
                            if(has_max && validPlayWeek) validPlayWeek = (usePlayWeek != null) && Integer.valueOf(usePlayWeek) <= max_week; 
                            
                            if(mpw.PlayWeekDate != null && validPlayWeek){
                                boolean hasValues = false;
                                
                                Map<String, RST_Play_Week__c> weekMap = rentrakPlayWeekWeekMap.get(rentrakId);
                                if(weekMap == null) {
                                    system.debug('did not find any existing playweeks for this title: ' + rentrakId);
                                    weekMap = new Map<String, RST_Play_Week__c>();
                                }
                                RST_Play_Week__c pw = weekMap.get(String.valueOf(mpw.PlayWeek));
                                if(pw == null) {
                                    system.debug('did not find an existing playweek for this title for this week:' + mpw.PlayWeek);
                                    pw = new RST_Play_Week__c();
                                }
                                pw.Name = mt.Title + ' Week ' + mpw.PlayWeek;
                                pw.Play_Week__c = usePlayWeek;
                                pw.Source__c = 'Magic';
                                pw.RenTrak_Id__c = rentrakId;
                                
                                if(!String.isBlank(mpw.Midweekgross)) pw.Midweek_BO__c = Decimal.valueOf(mpw.Midweekgross) / 1000000;
                                if(!String.isBlank(mpw.WeekendGross)) pw.Weekend_BO__c = Decimal.valueOf(mpw.WeekendGross) / 1000000;
                                if(!String.isBlank(mpw.WeekendGross) && !String.isBlank(mpw.Midweekgross)) hasValues = true;
                                
                                /*
if(!String.isBlank(mpw.WeeklyGross)) {
pw.Total_Week__c = Decimal.valueOf(mpw.WeeklyGross) / 1000000;

}
*/
                                Date pwDate = RST_Utilities.convertMagicDate(mpw.PlayWeekDate);
                                mcWeeksMap.put(pwDate, null);
                                pw.Week_Date__c = pwDate;
                                //if(pw.Week_Date__c < use_today) pw.ParentProcessed__c = true;
                                if(hasValues){
                                    weekMap.put(mpw.PlayWeek, pw);
                                    rentrakPlayWeekWeekMap.put(rentrakId, weekMap);
                                }
                            }                        
                        }
                    }
                }
                if(existingTitles.size() > 0 ){
                    upsert titlesToUpdate;
                    //
                    // reload titles to get any new ids
                    //
                    for(RST_Title__c  t : [SELECT Id, Name, RenTrak_ID__c FROM RST_Title__c WHERE RenTrak_ID__c IN :rentrakTitleMap.keyset()]){
                 	   existingTitles.put(t.RenTrak_ID__c, t);
	                }

                    List<RST_Play_Week__c> pws = new List<RST_Play_Week__c>();
                    
                    system.debug(mcWeeksMap.keySet());
                    for(RST_Market_Capacity__c mc : [SELECT Id, Week_Date__c FROM RST_Market_Capacity__c WHERE Week_Date__c IN :mcWeeksMap.keySet()]){
                        mcWeeksMap.put(mc.Week_Date__c, mc);
                    }
                    
                    // update play weeks title field with id
                    for(RST_Title__c t : existingTitles.values()){
                        
                        Map<String, RST_Play_Week__c> existingPlayWeeksMap = rentrakPlayWeekWeekMap.get(t.RenTrak_ID__c);
                        if(existingPlayWeeksMap != null){
                            for(RST_Play_Week__c pw : existingPlayWeeksMap.values()){
                                //
                                // needs proper id here from possible new titles
                                //
                                if(pw.Title__c == null) pw.Title__c = t.Id;
                                
                                RST_Market_Capacity__c currentMC = mcWeeksMap.get(pw.Week_Date__c);
                                if(currentMC == null){
                                    system.debug('issue linkng playweeks with market capacity');
                                    system.debug(pw);
                                    system.debug(' end - issue linkng playweeks with market capactiy');
                                    
                                } else{
                                    pw.Market_Capacity__c = currentMC.Id;
                                    pws.add(pw);
                                }
                                
                                
                            }
                        } else {
                            system.debug('issue linkng playweeks with titles');
                            system.debug(t);
                            system.debug(t.RenTrak_ID__c);
                            system.debug(' end - issue linkng playweeks with titles');
                        }
                        
                    }
                    upsert pws;
                    
                }
                
                
                
            } else {
                system.debug('error with titles code: ' + response.getStatusCode() + ' ' + response.getBody());
                throw new RST_Exception('error communicating with magic. code: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
        RST_Utilities.parentPlayWeeks(); // link play weeks 1 - 15 as parent child
        
        
        AsyncApexJob a = [SELECT Id, Status, 
                          CreatedDate,
                          ExtendedStatus,
                          NumberOfErrors, 
                          JobItemsProcessed, 
                          TotalJobItems, 
                          CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        /*
// send email if launched from UI ??
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {a.CreatedBy.Email};
mail.setToAddresses(toAddresses);
mail.setSubject('Magic Batch ' + a.Status);
mail.setPlainTextBody('Apex Job: ' + a.Id + ' started at ' + a.CreatedDate + ' to ' + System.now() + ' records processed ' + a.TotalJobItems + 'with '+ a.NumberOfErrors + ' failures.');
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
*/
        
        // log magic complete
        // in future, perhaps capture errors
        String className = 'RST_Batch_MagicCallout';
        Boolean hasIssues = a.NumberOfErrors > 0;
        String traceString = hasIssues ? 'Success' : 'Failures reported';
        
        RST_Utilities.logMagic_Run(className, hasIssues, traceString);
        
    }
    
    public class MagicTitle{
        @AuraEnabled public string RenkTrakId {get;set;}
        @AuraEnabled public string Title {get;set;}
        @AuraEnabled public string MagicId {get;set;}
        @AuraEnabled public string WideReleasdDate {get;set;}
        @AuraEnabled public string FSOGenre {get;set;}
        @AuraEnabled public string MagicGenre {get;set;}
        @AuraEnabled public string DistributorName {get;set;}
        @AuraEnabled public string RatingName {get;set;}
        @AuraEnabled public string ReleasePatternName {get;set;}
        
        @AuraEnabled public List<MagicPlayWeek> BoxOfficeActuals {get;set;}
        
    }
    
    public class MagicPlayWeek{
        
        @AuraEnabled public string PlayWeek {get;set;}
        @AuraEnabled public string MagicReleaseWeek {get;set;}
        @AuraEnabled public string PlayWeekDate {get;set;}
        @AuraEnabled public string WeekendGross {get;set;}
        @AuraEnabled public string WeeklyGross {get;set;}
        @AuraEnabled public string Midweekgross {get;set;}
        
        //@AuraEnabled public List<MagicTitleWeek> PlayWeeks {get; set;} // used for title loads        
    }
}