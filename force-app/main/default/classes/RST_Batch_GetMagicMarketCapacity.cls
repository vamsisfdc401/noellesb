global class RST_Batch_GetMagicMarketCapacity implements Database.Batchable<String>,   Database.AllowsCallouts,  Database.Stateful, Schedulable{

    //http://magicstg.api.nbcuni.com/magic/GetmarketcapacityDetails?FromDate=2015-01-01&ToDate=2024-01-01&TerritoryId=178

    private RST_MagicInterface.TokenResponse magicTokenResponse;
    private string territoryId;

    global void execute(SchedulableContext sc){
        Database.executeBatch(new RST_Batch_GetMagicMarketCapacity(), 1);
    }

    global Iterable<String> start(Database.BatchableContext bc) {
        magicTokenResponse = RST_MagicInterface.getMagicToken();
        territoryId = '178';
        // change iterable to custom set to account for adding null at end of set
        /*
        return new RST_TitleYearIterable(
            'SELECT Calendar_Year(Week_Date__c) openYear, count(Id) num FROM RST_Play_Week__c GROUP BY Calendar_Year(Week_Date__c)'
        ); 
        */     
        return new RST_MagicYearIterable();
    }
    

    global void execute(Database.BatchableContext bc, List<String> useYears){
        system.debug('useYears : ' + useYears);
        for(String useYear : useYears) { // there should be only one

            Integer startYear = Integer.valueOf(useYear);

            //string useStartDate = '01/01/' + ar.get('openYear');
            //string useEndDate = '01/01/' + (startYear + 1);

            string useStartDate = startYear + '-01-01';
            string useEndDate = (startYear + 1) + '-01-01';

            /*
            AggregateResult ar = (AggregateResult)sObj;
            System.debug('>>>> COUNT : ' + ar.get('num') + ' during >>>> YEAR : ' + ar.get('openYear'));

            Integer startYear = Integer.valueOf(ar.get('openYear'));
            string useStartDate = ar.get('openYear') + '-01-01';
            string useEndDate = (startYear + 1) + '-01-01';
            */

            String formattedParameters = 'fromDate=' + useStartDate + '&toDate=' + useEndDate + '&TerritoryId=' + territoryId;
            system.debug(' go to ' + formattedParameters);
            String namedCredentials = 'Magic_API';
            String path = '/magic/GetmarketcapacityDetails?';
            String uri;
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //request.setEndpoint('https://magicstg.api.nbcuni.com/magic/GetmarketcapacityDetails?' + formattedParameters);
            uri = (Test.isRunningTest()) ? 'https://callout.' + namedCredentials + '.com' + path: 'callout:' + namedCredentials + path + formattedParameters;     
            request.setEndpoint(uri);
            //request.setEndpoint('callout:Magic_API/magic/GetmarketcapacityDetails?' + formattedParameters);
            request.setMethod('GET');
            request.setHeader('Authorization',  'Bearer ' + magicTokenResponse.access_token);

            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            //system.debug('response.getStatusCode()');
            //system.debug(response.getStatusCode());
            if (response.getStatusCode() == 200) {
                //system.debug('magic body with titles weeks here' );
                //system.debug(response.getBody() );

                List<MagicMarketCapacity> magicMarketCapacities = (List<MagicMarketCapacity>)JSON.deserialize(response.getBody(), List<MagicMarketCapacity>.class);

                Map<Date, MagicMarketCapacity> magicResultMap = new Map<Date, MagicMarketCapacity>();
                for(MagicMarketCapacity mmc : magicMarketCapacities){
                    Date weekDate = date.valueof(mmc.Weekendstartdate);
                    magicResultMap.put(weekDate, mmc);
                    system.debug(mmc);
                    //system.debug(mmc.Weekendstartdate);
                    //system.debug(weekDate);
                    system.debug(String.valueOf(weekDate));
                }

                Map<Date, RST_Market_Capacity__c> existingMarketCapacities = new Map<Date, RST_Market_Capacity__c>();
                for(RST_Market_Capacity__c existingMC : [SELECT Id, Name, Week_Date__c FROM RST_Market_Capacity__c WHERE Week_Date__c IN :magicResultMap.keySet()]){
                    existingMarketCapacities.put(existingMC.Week_Date__c, existingMC);
                }

                for(MagicMarketCapacity mmc : magicMarketCapacities){
                    RST_Market_Capacity__c curMC = existingMarketCapacities.get(date.valueOf(mmc.Weekendstartdate));
                    if(curMC == null){
                        system.debug('creating a new market capacity record');
                        curMC = new RST_Market_Capacity__c();
                    }
                    curMC.Name = String.valueOf(Date.valueOf(mmc.Weekendstartdate));
                    curMC.Territory_Id__c = territoryId;
                    curMC.Average_Market_Capacity__c = Decimal.valueOf(mmc.Mean);
                    curMC.Max_Market_Capacity__c = Decimal.valueOf(mmc.Max);
                    curMC.Min_Market_Capacity__c = Decimal.valueOf(mmc.Min);
                    curMC.Week_Date__c = date.valueOf(mmc.Weekendstartdate);

                    existingMarketCapacities.put(date.valueOf(mmc.Weekendstartdate), curMC);

                }

                if(existingMarketCapacities.size() > 0 ) upsert existingMarketCapacities.values();


            } else {
                system.debug('error with titles code: ' + response.getStatusCode() + ' ' + response.getBody());
                throw new RST_Exception('error communicating with magic. code: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        }
    }

    global void finish(Database.BatchableContext bc){
    }

    public class MagicMarketCapacity{
        @AuraEnabled public string Weekendstartdate {get;set;}
        @AuraEnabled public string Max {get;set;}
        @AuraEnabled public string Mean {get;set;}
        @AuraEnabled public string Min {get;set;}
    }

}