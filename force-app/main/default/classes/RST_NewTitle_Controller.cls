public with sharing class RST_NewTitle_Controller {
    
    @AuraEnabled
    public static Object refreshMagic(){
        Id batchprocessid = Database.executeBatch(new RST_Batch_MagicCallout(), 1);
        return batchprocessid;
    }
    
    @AuraEnabled
    public static String checkMagicUpdated(){
        RST_Process_Log__c magicStatus = [SELECT Id, 
                                          		Type__c, 
                                          		isError__c, 
                                          		CreatedDate 
                                          	FROM 
                                          		RST_Process_Log__c 
                                          	WHERE 
                                          		Type__c = 'Magic' AND 
                                          		isError__c = false
                                         	ORDER BY CreatedDate DESC LIMIT 1];
        if(magicStatus == null){
            return 'No successful Magic Updates';
            
        } else {
            String formattedDateTime = magicStatus.CreatedDate.format('MM/dd/yyyy hh:mm:ss a');
            return 'Last Magic Update: ' + formattedDateTime;
        }
    }
    
    @AuraEnabled
    public static NewTitleOptions getNewTitleOptions(){
        NewTitleOptions options = new NewTitleOptions();
        options.titles = [SELECT Id, Name, RenTrak_Id__c, FS_O_Genre__c, Wide_Release_Date__c FROM RST_Title__c WHERE Wide_Release_Date__c < Today ORDER By Name];
        
        
        Set<String> genres = new Set<String>();

        for (RST_Title__c title : options.titles)  {
            if(  ! String.isEmpty( title.FS_O_Genre__c) && !genres.contains(title.FS_O_Genre__c) ) { 
                genres.add( title.FS_O_Genre__c); 
            }
        }
        options.genres = genres;

        return options;
    }

    @AuraEnabled
    public static MagicResult getMagicForecast(String options){
        MagicResult forecastResult = new MagicResult();
        try{

        
            UserOptions use_options = (UserOptions)JSON.deserialize(options, UserOptions.class);
            system.debug(use_options);

            RST_MagicInterface.TokenResponse magicTokenResponse = RST_MagicInterface.getMagicToken();
            system.debug(magicTokenResponse);

            String magicEndPoint;
            String formattedParameters = '';
            String namedCredential = 'Magic_API';
        	String path = '/magic/';
        	String uri;
            
            if(use_options.forecastModel == 'Compare'){
                system.debug('need rentrak ids from a sf id');
                
                // pass titles
                Set<String> titleIds = new Set<String>(use_options.titles);
                
                Set<String> rentrakIds = RST_Utilities.getRentrakIdsFromSFId(titleIds);

                magicEndPoint = 'GeForecastingBasedonComparableTitles';
                path += 'GeForecastingBasedonComparableTitles';
                formattedParameters = '?rentrakids=' + string.join(new List<String>(rentrakIds),',');
            } else {
                system.debug('prepping for genre forecast');
                // genre based
                magicEndPoint = 'GetBoxofficeForecasting';
                path += 'GetBoxofficeForecasting';
            }

            //system.debug(magicEndPoint);
            system.debug(path);
            system.debug(formattedParameters);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            uri = (Test.isRunningTest()) ? 'https://callout.' + namedCredential + '.com' + path : 'callout:' + namedCredential + path + formattedParameters;
            //request.setEndpoint('https://magicstg.api.nbcuni.com/magic/' + magicEndPoint + formattedParameters);
            request.setEndpoint(uri);
            request.setMethod('GET');
            request.setHeader('Authorization',  'Bearer ' + magicTokenResponse.access_token);

            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            //system.debug('response.getStatusCode()');
            //system.debug(response.getStatusCode());
            if (response.getStatusCode() == 200) {

                //system.debug('magic body with titles weeks here' );
                system.debug(response.getBody() );
                //Date use_today = system.today();

                if(use_options.forecastModel == 'Genre'){
                    List<GenreForecast> genreForecasts = (List<GenreForecast>)JSON.deserialize(response.getBody(), List<GenreForecast>.class);
                    system.debug(genreForecasts);
                    for(GenreForecast gf : genreForecasts){
                        if(gf.GenreName == use_options.RenTrak_Genre && gf.Forecasting == use_options.seasonModel){
                            system.debug('process for ' + gf.GenreName);
                            processPlayWeeks(gf.Summary, use_options);
                            continue;
                        }
                    }
                } else {
                    List<PlayWeekDecay> compForecast = (List<PlayWeekDecay>)JSON.deserialize(response.getBody(), List<PlayWeekDecay>.class);
                    system.debug(compForecast);
                    processPlayWeeks(compForecast, use_options);
                }
                //List<MagicTitle> magicTitles = (List<MagicTitle>)JSON.deserialize(response.getBody(), List<MagicTitle>.class);

                //system.debug('we have ' + magicTitles.size() + ' titles for ' + ar.get('openYear'));

            }
        } catch (Exception e){
            forecastResult.result = 'Error';
            forecastResult.issues.add('issue w forecast ' + e.getMessage());

            
        }
        return forecastResult;
    }

    private static void processPlayWeeks(List<PlayWeekDecay> pwds,UserOptions use_options){

        RST_Application_Setting__mdt appSettings = [SELECT Playweek_Maximum__c, Playweek_Minimum__c FROM RST_Application_Setting__mdt WHERE DeveloperName = 'Standard' LIMIT 1];
        system.debug(appSettings); // get app settings for play week min / max
        Integer min_week = Integer.valueOf(appSettings.Playweek_Minimum__c);
        Integer max_week = Integer.valueOf(appSettings.Playweek_Maximum__c);
        Boolean has_min = min_week != null;
        Boolean has_max = max_week != null;

        RST_Title__c use_title = [SELECT Id, Name, RenTrak_Id__c, FS_O_Genre__c, Wide_Release_Date__c FROM RST_Title__c WHERE Id = :use_options.Id];

        Set<String> titleIds = new Set<String>{use_options.Id};

        Map<String, Map<String, RST_Play_Week__c>> rentrakPlayWeekMap = RST_Utilities.getRentrakPlayWeekMapForTitleId( titleIds );
        system.debug(rentrakPlayWeekMap);

        system.debug(pwds);
        // only one title, so get its play week map
        
        Map<String, RST_Play_Week__c> pw_map; 
        Map<Date, RST_Market_Capacity__c> mcWeeksMap = new Map<Date, RST_Market_Capacity__c>();
            
        
        if(rentrakPlayWeekMap.size() == 1){
           pw_map = rentrakPlayWeekMap.get(new List<String>(rentrakPlayWeekMap.keySet())[0]); //rentrakPlayWeekMap[0];
        } else {
            pw_map = new Map<String, RST_Play_Week__c>();
        }
        system.debug(pw_map);

        //start with original users values
        Decimal startWeekBO = Decimal.valueOf(use_options.Midweek_BO);
        Decimal startWkndBO = Decimal.valueOf(use_options.Weekend_BO);
        Date startWeekDate = use_title.Wide_Release_Date__c;

        for(PlayWeekDecay pwd : pwds){
            RST_Play_Week__c this_pw = pw_map.get(String.valueOf(pwd.ReportingWeek));
            if(this_pw == null) {
                this_pw = new RST_Play_Week__c();
                this_pw.Title__c = use_options.Id;
            }
            
            Integer usePlayWeek = Integer.valueOf(pwd.ReportingWeek);
            Boolean validPlayWeek = true;
            if(has_min) validPlayWeek =  (usePlayWeek != null) && Integer.valueOf(usePlayWeek) >= min_week; 
            //system.debug('validPlayWeek ' + validPlayWeek + ' from has_min: ' + has_min + ' on min_week: ' + min_week + ' for playweek: ' + usePlayWeek);
            if(has_max && validPlayWeek) validPlayWeek = (usePlayWeek != null) && Integer.valueOf(usePlayWeek) <= max_week; 
            //system.debug('validPlayWeek ' + validPlayWeek + ' from has_max: ' + has_max + ' on max_week: ' + max_week + ' for playweek: ' + usePlayWeek);

            if(validPlayWeek){

                this_pw.Name = use_title.Name + ' Week ' + pwd.ReportingWeek;
                this_pw.Play_Week__c = usePlayWeek;
                this_pw.Week_Date__c = startWeekDate; // calculated value based on opening date
                mcWeeksMap.put(startWeekDate, null);
                    
                startWeekDate = startWeekDate.addDays(7); // set for next weeks record
                
                
                Decimal useDecay = 0;
                if(!String.isBlank(pwd.Decay)){
                    //pw.Midweek_BO__c = Decimal.valueOf(mpw.Midweekgross) / 1000000;
                    useDecay = Decimal.valueOf(pwd.Decay);
                    this_pw.Midweek_Drop__c = useDecay;
                    this_pw.Weekend_Drop__c = useDecay;
                    
                } 
                startWeekBO = startWeekBO + ((useDecay / 100) * startWeekBO);
                startWkndBO = startWkndBO + ((useDecay / 100) * startWkndBO);
                this_pw.Midweek_BO__c = startWeekBO;
                this_pw.Weekend_BO__c = startWkndBO;

                this_pw.Source__c = 'User';

                pw_map.put(pwd.ReportingWeek, this_pw);
            }
        }
        
        system.debug([SELECT Id, Week_Date__c FROM RST_Market_Capacity__c]);
        system.debug(mcWeeksMap.keySet());
        List<RST_Market_Capacity__c> titlesWeeks = [SELECT Id, Week_Date__c FROM RST_Market_Capacity__c WHERE Week_Date__c IN :mcWeeksMap.keySet()];
        system.debug(titlesWeeks);
        for(RST_Market_Capacity__c mc : titlesWeeks){
            mcWeeksMap.put(mc.Week_Date__c, mc);
        }
        for(RST_Play_Week__c pw : pw_map.values()){
            system.debug('pw.Week_Date__c: ' + pw.Week_Date__c);
            pw.Market_Capacity__c = mcWeeksMap.get(pw.Week_Date__c).Id;
        }

        upsert pw_map.values();
        RST_Utilities.parentPlayWeeks();

    }

    public class NewTitleOptions{
        @AuraEnabled public List<RST_Title__c> titles {get;set;}
        @AuraEnabled public Set<String> genres {get;set;}
    }

    public class UserOptions{
        @AuraEnabled public string Id {get; set;}
        @AuraEnabled public string Weekend_BO {get; set;}
        @AuraEnabled public string Midweek_BO {get; set;}
        @AuraEnabled public string forecastModel {get; set;}
        @AuraEnabled public string seasonModel {get; set;}
        @AuraEnabled public string RenTrak_Genre {get; set;}
        @AuraEnabled public string[] titles {get; set;}
    }

    public class GenreForecast{
        @AuraEnabled public string Forecasting {get; set;}
        @AuraEnabled public string GenreName {get; set;}
        @AuraEnabled public List<PlayWeekDecay> Summary {get; set;}
    }

    public class PlayWeekDecay{
        @AuraEnabled public string ReportingWeek {get; set;}
        @AuraEnabled public string Decay {get; set;}
        @AuraEnabled public string AvgWeekEndGross {get; set;}
        @AuraEnabled public string SumWeekEndGross {get; set;}
    }

    public class MagicResult{

        @AuraEnabled public String result {get; set;}
        @AuraEnabled public List<String> issues {get; set;}

        public MagicResult(){
            result = 'Success';
            issues = new List<String>();
        }
    }

}