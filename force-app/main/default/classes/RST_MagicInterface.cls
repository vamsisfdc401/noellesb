public with sharing class RST_MagicInterface {

    //private TokenResponse myAuthResponse {get; set;}; 

    /*
    public static void getLatestForRentrak(Set<String> rentrakIds) {
        system.debug('preparing for api call to magic: ' + rentrakIds);
        try{
            TokenResponse myAuthResponse = getMagicToken();
            if(myAuthResponse!= null){
                updateRentrakData(myAuthResponse, rentrakIds);
            }
        } catch(RST_Exception re){
            // would return something if im trying to let user know
        }
        
        
    }

    */

    public static TokenResponse getMagicToken(){
        TokenResponse myAuthResponse;
        String namedCredential = 'Magic_API';
        String path = '/token';
        String uri;
        String body;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://magicstg.api.nbcuni.com/token');
        uri = (Test.isRunningTest()) ? 'https://callout.' + namedCredential + '.com' + path : 'callout:' + namedCredential + path;
        request.setEndpoint(uri);
        //request.setEndpoint('callout:Magic_API/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //request.setBody('grant_type=password&username=MagicUni@api&password=Ws8D7pNv#EbL(-t,c;9}');
        body = (Test.isRunningTest()) ? 'grant_type=password&username=MagicUni@api&password=Ws8D7pNv#EbL(-t,c;9}' : 'grant_type=password&username={!$Credential.Username}&password={!$Credential.Password}';
        request.setBody(body);
        //request.setBody('grant_type=password&username={!$Credential.Username}&password={!$Credential.Password}');

        system.debug(request);

        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        system.debug('response.getStatusCode()');
        system.debug(response.getStatusCode());
        if (response.getStatusCode() == 200) {
            //system.debug('response.getBody()' );
            //system.debug(response.getBody() );
            
            myAuthResponse = (TokenResponse)JSON.deserialize(response.getBody(), TokenResponse.class);
            return myAuthResponse;
            //system.debug(myAuthResponse);

            //
            
        } else {
            system.debug('error with token');
            throw new RST_Exception('error communicating with magic. code: ' + response.getStatusCode());
            //return null;    
        }
        
    }

    
    /*
    private static void updateRentrakData(TokenResponse magicToken, Set<String> rentrakIds){
        List<MagicTitleWeek> magicTitles = new List<MagicTitleWeek>();
        // limit set to test integration
        
        String use_rentrak_id_string = '';
        Integer i = 0 ;
        for(String rId : rentrakIds){
            if(i < 100) {
            use_rentrak_id_string += rId + ',';
            i++; }
        }
        use_rentrak_id_string = use_rentrak_id_string.removeEnd(',');
        //system.debug('use_rentrak_id_string');
        //system.debug(use_rentrak_id_string);
        //https://magicstg.api.nbcuni.com/magic/GetBoxOfficeActual?titleIds=91797,75291,137316,133133,53813,99196

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://magicstg.api.nbcuni.com/magic/GetBoxOfficeActual?titleIds=' + use_rentrak_id_string );//104165,104354');// + String.join(new List<String>(small_set), ','));
        //request.setEndpoint('https://magicstg.api.nbcuni.com/magic/GetBoxOfficeActual?titleIds=104165,104354');// + String.join(new List<String>(small_set), ','));
        
        request.setMethod('GET');
        request.setHeader('Authorization',  'Bearer ' + magicToken.access_token);
        //request.setBody('grant_type=password&username=MagicUni@api&password=Ws8D7pNv#EbL(-t,c;9}');

        //system.debug(request);

        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        //system.debug('response.getStatusCode()');
        //system.debug(response.getStatusCode());
        if (response.getStatusCode() == 200) {
            //system.debug('magic body with titles weeks here' );
            //system.debug(response.getBody() );

            magicTitles = (List<MagicTitleWeek>)JSON.deserialize(response.getBody(), List<MagicTitleWeek>.class);

            processTitles(magicTitles);

        } else {
            system.debug('error with titles code: ' + response.getStatusCode() + ' ' + response.getBody());
            throw new RST_Exception('error communicating with magic. code: ' + response.getStatusCode() + ' ' + response.getBody());
        }

    }
    */

    /*
    private static void processTitles(List<MagicTitleWeek> magicTitlePlayWeeks){
        system.debug('enhance titles from magic return');
        //system.debug(magicTitlePlayWeeks);
        //String curTitleName = '';
        Set<String> usedRentrakIds = new Set<String>();
        //MagicTitleWeek cur_titleWeek;
        //List<MagicTitleWeek> titles = new List<MagicTitleWeek>();
        for(MagicTitleWeek title : magicTitlePlayWeeks){
            
            if(!usedRentrakIds.contains(title.RentTrakId)){
                usedRentrakIds.add(title.RentTrakId);
                //cur_title = title;
                //cur_title.PlayWeeks = new List<MagicTitleWeek>();
                //titles.add(cur_title);
            }
            //cur_title.PlayWeeks.add(title);
            
        }
        // see what titles alreay exist in salesforce based on rentrak id
        Map<String, RST_Title__c> rentrakTitleMap = new Map<String, RST_Title__c>();
        List<RST_Title__c> existingTitles = [SELECT Id, Name, Distributor__c, FS_O_Genre__c, Lock_Title__c, Release_Pattern__c, RenTrak_ID__c, RenTrak_Genre__c, Wide_Release_Date__c FROM RST_Title__c WHERE RenTrak_ID__c IN :usedRentrakIds];
        for(RST_Title__c title : existingTitles){
            rentrakTitleMap.put(title.RenTrak_ID__c, title);
        }

        
        // see what play weeks alreay exist in salesforce based on rentrak id
        List<RST_Play_Week__c> rentrakPlayWeeks = [SELECT Id, Name, Weekend_BO__c , RST_Play_Week__c, RenTrak_Id__c FROM RST_Play_Week__c WHERE RenTrak_Id__c IN :usedRentrakIds];
        //Map<String, RST_Play_Week__c> rentrakPlayWeekMap = new Map<String, RST_Play_Week__c>();

        // first map for rentrak, second map for week
        Map<String, Map<String, RST_Play_Week__c>> rentrakPlayWeekWeekMap = new Map<String, Map<String,RST_Play_Week__c>>();
        
        for(RST_Play_Week__c pw : rentrakPlayWeeks){
            Map<String, RST_Play_Week__c> weekMap = rentrakPlayWeekWeekMap.get(pw.RenTrak_Id__c);
            if(weekMap == null) weekMap = new Map<String, RST_Play_Week__c>();
            weekMap.put(String.valueOf(pw.RST_Play_Week__c), pw);

            rentrakPlayWeekWeekMap.put(pw.RenTrak_Id__c, weekMap);
        }

        // go through magic data and align with salesforce
        for(MagicTitleWeek title : magicTitlePlayWeeks){
            system.debug('magic title: '+ title);
            // see if title exists, if not, add new to list
            String cur_magicTitleRentrakId = title.RentTrakId;
            RST_Title__c cur_Title = rentrakTitleMap.get(cur_magicTitleRentrakId);
            if(cur_Title == null){
                cur_Title = new RST_Title__c();
            }
            cur_Title.Name = title.TitleName;
            cur_Title.RenTrak_ID__c = title.RentTrakId;
                
            cur_Title.Distributor__c = title.DistributorName;
            cur_Title.FS_O_Genre__c = title.FSOGenre;
            cur_Title.Release_Pattern__c = title.ReleasePatternName;
            cur_Title.RenTrak_Genre__c = title.MagicGenre;
            if(title.WideReleasdDate != ''){
                system.debug('convertMagicDate(title.WideReleasdDate) : ' + convertMagicDate(title.WideReleasdDate));
                cur_Title.Wide_Release_Date__c = convertMagicDate(title.WideReleasdDate);
            }

            rentrakTitleMap.put(cur_magicTitleRentrakId, cur_Title);

            system.debug('rentrakPlayWeekWeekMap ' + rentrakPlayWeekWeekMap);
            
            if(!String.isBlank(title.PlayWeek)){

            
                Map<String, RST_Play_Week__c> weekMap = rentrakPlayWeekWeekMap.get(cur_magicTitleRentrakId); // returns all playweeks for rentrak
                system.debug('weekMap : ' + weekMap);
                if(weekMap == null) weekMap = new Map<String, RST_Play_Week__c>();
                RST_Play_Week__c titlePlayWeek = weekMap.get(title.PlayWeek); // returns the playweek for particular week num (1-15)
                if(titlePlayWeek == null){ 
                    titlePlayWeek = new RST_Play_Week__c();
                    
                    titlePlayWeek.Name = title.TitleName + ' Week: ' + title.PlayWeek;
                    titlePlayWeek.RenTrak_ID__c = cur_magicTitleRentrakId;
                    //titlePlayWeek.RST_Play_Week__c = !String.isBlank(title.PlayWeek) ? Integer.valueOf(title.PlayWeek) : null;
                    titlePlayWeek.RST_Play_Week__c = Integer.valueOf(title.PlayWeek);
                    titlePlayWeek.Week_Date__c = !String.isBlank(title.PlayWeekDate) ? convertMagicDate(title.PlayWeekDate) : null;
                    
                }
                system.debug('titlePlayWeek');
                SYSTEM.DEBUG(titlePlayWeek);
                
                
                titlePlayWeek.Midweek_BO__c = !String.isBlank(title.Midweekgross) ? Decimal.valueOf(title.Midweekgross) / 1000000 : null;
                titlePlayWeek.Total_Week__c = !String.isBlank(title.WeeklyGross) ? Decimal.valueOf(title.WeeklyGross) / 1000000 : null;
                titlePlayWeek.Weekend_BO__c = !String.isBlank(title.WeekendGross) ? Decimal.valueOf(title.WeekendGross) / 1000000 : null;
                titlePlayWeek.Source__c = 'Magic';


                weekMap.put(title.PlayWeek, titlePlayWeek);

                rentrakPlayWeekWeekMap.put(cur_magicTitleRentrakId, weekMap);
            
            }

        }
        //Midweek_BO__c
        system.debug('rentrakTitleMap.values():' + rentrakTitleMap.values());
        upsert rentrakTitleMap.values();
        system.debug('saved titles');
        

        //upsert rentrakPlayWeekMap.values(); // new double map needs parsing, linking titles as well
        
        /* RENAME SECTION
        List<RST_Play_Week__c> allPlayWeeks = new List<RST_Play_Week__c>();
        for(Map<String, RST_Play_Week__c> weekMap : rentrakPlayWeekWeekMap.values()){
            for(RST_Play_Week__c pw : weekMap.values()){
                pw.Title__c = rentrakTitleMap.get(pw.RenTrak_ID__c).Id;
                allPlayWeeks.add(pw);
            }
        }
        upsert allPlayWeeks;
        
    }
    */
    /*
    private static Date convertMagicDate(String magicDate){
        Date useDate = system.today();
        String yyyy, mm, dd;
        yyyy = magicDate.mid(0,4);
        mm = magicDate.mid(4,2);
        dd = magicDate.mid(6,2);
        system.debug('parse this: ' + yyyy + '/' + mm + '/' + dd);
        return date.parse( mm + '/' + dd + '/' + yyyy);
        
    }
*/
    public class TokenResponse{
        @AuraEnabled public string access_token {get;set;}
        @AuraEnabled public string token_type {get;set;}
        @AuraEnabled public string expires_in {get;set;}
    }
/*
    public class MagicTitleWeek{
        @AuraEnabled public string RentTrakId {get;set;}
        @AuraEnabled public string PlayWeek {get;set;}
        @AuraEnabled public string MagicReleaseWeek {get;set;}
        @AuraEnabled public string MagicId {get;set;}
        @AuraEnabled public string WideReleasdDate {get;set;}
        @AuraEnabled public string PlayWeekDate {get;set;}
        @AuraEnabled public string TitleName {get;set;}
        @AuraEnabled public string FSOGenre {get;set;}
        @AuraEnabled public string MagicGenre {get;set;}
        @AuraEnabled public string DistributorName {get;set;}
        @AuraEnabled public string ReleasePatternName {get;set;}
        @AuraEnabled public string WeekendGross {get;set;}
        @AuraEnabled public string WeeklyGross {get;set;}
        @AuraEnabled public string Midweekgross {get;set;}

        //@AuraEnabled public List<MagicTitleWeek> PlayWeeks {get; set;} // used for title loads        
    }
*/
    /*
    public class MagicTitle{
        @AuraEnabled public string RentTrakId {get;set;}
        @AuraEnabled public string MagicReleaseWeek {get;set;}
        @AuraEnabled public string MagicId {get;set;}
        @AuraEnabled public string WideReleasdDate {get;set;}
        @AuraEnabled public string TitleName {get;set;}
        @AuraEnabled public string FSOGenre {get;set;}
        @AuraEnabled public string MagicGenre {get;set;}
        @AuraEnabled public string DistributorName {get;set;}
        @AuraEnabled public string ReleasePatternName {get;set;}

        

        
    }
    */
    
}