@IsTest
public class RST_MagicAPITest {
    
    //helper methods
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
                                                     RenTrak_ID__c = String.valueOf(10000 + i),
                                                     FS_O_Genre__c = 'Action/Adventure',
                									 Wide_Release_Date__c = System.today() - 1
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
        createMarketCapacityWeeks(getLastFriday(), 1);
        RST_Market_Capacity__c mc = [SELECT Id, Name FROM RST_Market_Capacity__c];
        Decimal currentWkndBO = startingWkndBOAmount;
        Decimal currentMdwkBO = startingMdwkBOAmount;                                                        
        List<RST_Play_Week__c> playWeeksToInsert = new List<RST_Play_Week__c>();                                                        
        for (RST_Title__c t : titles) {
            Date currDate = System.today();
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
                                                                    Week_Date__c = (i == 1) ? currDate : currDate + 7,
                                                                    Title_Open_Date__c = t.Wide_Release_Date__c,
                                                                    Market_Max__c = 500000,
                                                                    Market_Capacity__c = mc.Id);
                playWeeksToInsert.add(newPlayWeek);
            }
        }
        insert playWeeksToInsert;
        return playWeeksToInsert;
    }
    
    public static testmethod void testGetToken() {
        String tokenResponseBody = '{' +
                                    '"access_token": "testAccessToken",' +
                                    '"token_type": "bearer",' +
                                    '"expires_in": 3599 ' +
                                    '}';
        //Test successfull callout requesting access token
        RST_SingleRequestMock fakeTokenResponse = new RST_SingleRequestMock(200, 'Complete', tokenResponseBody, null);
        Test.setMock(HttpCalloutMock.class, fakeTokenResponse);
        RST_MagicInterface.TokenResponse token = RST_MagicInterface.getMagicToken();
        System.assertEquals('testAccessToken', token.access_token);
        System.assertEquals('bearer', token.token_type);
        System.assertEquals('3599', token.expires_in);
        //Test caught error for non-successful callout requesting access token
        RST_SingleRequestMock fakeBadTokenResponse = new RST_SingleRequestMock(500, 'Complete', tokenResponseBody, null);
        Test.setMock(HttpCalloutMock.class, fakeBadTokenResponse);
        try{RST_MagicInterface.TokenResponse badToken = RST_MagicInterface.getMagicToken();}
        catch(Exception e) {System.assertEquals('error communicating with magic. code: 500', e.getMessage());}
        
    }
    
    public static testmethod void testScheduleMarketCapacity() {
        String tokenResponseBody = '{' +
                                    '"access_token": "testAccessToken",' +
                                    '"token_type": "bearer",' +
                                    '"expires_in": 3599 ' +
                                    '}';
        String marketCapacityResponseBody = '[' +
                                                '{' +
                                                    '"Weekendstartdate": "2018-11-30T00:00:00",' +
                                                    '"Max": 119,' +
                                                    '"Mean": 99,' +
                                                    '"Min": 78' +
                                                '},' +
                                                '{' +
                                                    '"Weekendstartdate": "2018-12-07T00:00:00",' +
                                                    '"Max": 105,' +
                                                    '"Mean": 93,' +
                                                    '"Min": 78' +
                                                '},' +
                                                '{' +
                                                    '"Weekendstartdate": "2018-12-14T00:00:00",' +
                                                    '"Max": 117,' +
                                                    '"Mean": 89,' +
                                                    '"Min": 77' +
                                                '},' +
                                                '{' +
                                                    '"Weekendstartdate": "2018-12-21T00:00:00",' +
                                                    '"Max": 296,' +
                                                    '"Mean": 212,' +
                                                    '"Min": 178' +
                                                '},' +
                                                '{' +
                                                    '"Weekendstartdate": "2018-12-28T00:00:00",' +
                                                    '"Max": 0,' +
                                                    '"Mean": 0,' +
                                                    '"Min": 0' +
                                                '}' +
                                            ']';
        RST_SingleRequestMock fakeTokenResponse = new RST_SingleRequestMock(200, 'Complete', tokenResponseBody, null);
        RST_SingleRequestMock fakeMarketCapacityResponse = new RST_SingleRequestMock(200, 'Complete', marketCapacityResponseBody, null);
        
        Map<String, HttpCalloutMock> endpointMockMap = new Map<String, HttpCalloutMock>();
        endpointMockMap.put('https://callout.Magic_API.com/token', fakeTokenResponse);
        endpointMockMap.put('https://callout.Magic_API.com/magic/GetmarketcapacityDetails?', fakeMarketCapacityResponse);
        
        HttpCalloutMock multiCalloutMock = new RST_MultiRequestMock(endpointMockMap);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RST_Market_Capacity__c mc = new RST_Market_Capacity__c(Name='2018-11-30T00:00:00',
                                                               Territory_Id__c = '178',
                                                               Average_Market_Capacity__c = 99,
                                                               Max_Market_Capacity__c = 119,
                                                               Min_Market_Capacity__c = 78,
                                                               Week_Date__c = Date.valueOf('2018-11-30T00:00:00'));
        insert mc;

        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Schedule Market Capacity Job', CRON_EXP, new RST_Batch_GetMagicMarketCapacity() );   
        Test.stopTest();
        system.assertEquals(1, [SELECT count() FROM CronTrigger WHERE Id = :jobId]); //Job created
    }
    
    public static testmethod void testNewTitleOptions() {
        Integer MAX_TITLES = 3;
        List<RST_Title__c> titles = createTestTitles(MAX_TITLES);
        RST_NewTitle_Controller.NewTitleOptions titleOptions = RST_NewTitle_Controller.getNewTitleOptions();
        System.assertEquals('10001', titleOptions.titles[0].rentrak_Id__c);
    }
    
    public static testmethod void testNewTitleWithComparableTitles() {
		Integer MAX_TITLES = 3;
        String tokenResponseBody = '{' +
                                    '"access_token": "testAccessToken",' +
                                    '"token_type": "bearer",' +
                                    '"expires_in": 3599 ' +
                                    '}';
        String newTitleResponseBody = 		'[' +
                                                '{' +
                                                    '"ReportingWeek": 1,' +
                                                    '"Decay": null,' +
                                                    '"AvgWeekEndGross": 62612763,' +
                                                    '"SumWeekEndGross": 125225526' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 2,' +
                                                    '"Decay": -56.47,' +
                                                    '"AvgWeekEndGross": 24909332,' +
                                                    '"SumWeekEndGross": 24909332' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 3,' +
                                                    '"Decay": -48.6,' +
                                                    '"AvgWeekEndGross": 12802644,' +
                                                    '"SumWeekEndGross": 12802644' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 4,' +
                                                    '"Decay": -38.2,' +
                                                    '"AvgWeekEndGross": 7911445,' +
                                                    '"SumWeekEndGross": 7911445' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 5,' +
                                                    '"Decay": -30.56,' +
                                                    '"AvgWeekEndGross": 5493417,' +
                                                    '"SumWeekEndGross": 5493417' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 6,' +
                                                    '"Decay": -26.17,' +
                                                    '"AvgWeekEndGross": 4055465,' +
                                                    '"SumWeekEndGross": 4055465' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 7,' +
                                                    '"Decay": -24.22,' +
                                                    '"AvgWeekEndGross": 3073116,' +
                                                    '"SumWeekEndGross": 3073116' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 8,' +
                                                    '"Decay": -6.75,' +
                                                    '"AvgWeekEndGross": 2865558,' +
                                                    '"SumWeekEndGross": 2865558' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 9,' +
                                                    '"Decay": -42.14,' +
                                                    '"AvgWeekEndGross": 1657917,' +
                                                    '"SumWeekEndGross": 1657917' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 10,' +
                                                    '"Decay": -44.32,' +
                                                    '"AvgWeekEndGross": 922985,' +
                                                    '"SumWeekEndGross": 922985' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 11,' +
                                                    '"Decay": -61.75,' +
                                                    '"AvgWeekEndGross": 353003,' +
                                                    '"SumWeekEndGross": 353003' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 12,' +
                                                    '"Decay": -63.2,' +
                                                    '"AvgWeekEndGross": 129887,' +
                                                    '"SumWeekEndGross": 129887' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 13,' +
                                                    '"Decay": -23.83,' +
                                                    '"AvgWeekEndGross": 98930,' +
                                                    '"SumWeekEndGross": 98930' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 14,' +
                                                    '"Decay": -25.86,' +
                                                    '"AvgWeekEndGross": 73342,' +
                                                    '"SumWeekEndGross": 73342' +
                                                '},' +
                                                '{' +
                                                    '"ReportingWeek": 15,' +
                                                    '"Decay": 223.61,' +
                                                    '"AvgWeekEndGross": 237347,' +
                                                    '"SumWeekEndGross": 237347' +
                                                '}' +
                                            ']';
        RST_SingleRequestMock fakeTokenResponse = new RST_SingleRequestMock(200, 'Complete', tokenResponseBody, null);
        RST_SingleRequestMock fakenewTitleResponse = new RST_SingleRequestMock(200, 'Complete', newTitleResponseBody, null);
        
        Map<String, HttpCalloutMock> endpointMockMap = new Map<String, HttpCalloutMock>();
        endpointMockMap.put('https://callout.Magic_API.com/token', fakeTokenResponse);
        endpointMockMap.put('https://callout.Magic_API.com/magic/GeForecastingBasedonComparableTitles', fakenewTitleResponse);
        
        HttpCalloutMock multiCalloutMock = new RST_MultiRequestMock(endpointMockMap);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        List<RST_Title__c> titles = createTestTitles(MAX_TITLES);
        createMarketCapacityWeeks(System.today().addDays(-7) , 20);
        system.assert([SELECT Id FROM RST_Market_Capacity__c].size() > 0);
        
        
        RST_Title__c newTitle = new RST_Title__c(Name = 'Test New Title',
                                                     Distributor__c = 'WB',
                                                     Rating__c = 'R',
                                                     RenTrak_ID__c = String.valueOf(10005),
                                                     FS_O_Genre__c = 'Action/Adventure',
                                                 	 Rentrak_Genre__c = 'Action',
                									 Wide_Release_Date__c = System.today() - 7
                                                     );
        insert newTitle;
        String [] titleIds = new String [] {titles[0].id,titles[1].id,titles[2].id};
        RST_NewTitle_Controller.UserOptions userOptions = new RST_NewTitle_Controller.UserOptions();
        userOptions.Id = newTitle.id;
        userOptions.Weekend_BO = '50';
        userOptions.Midweek_BO = '20';
        userOptions.forecastModel = 'Compare';
        //userOptions.seasonModel = 'NonSummer';                                                                              
        //userOptions.RenTrak_Genre = 'Action';                                                                              
        userOptions.titles = titleIds;   
        String options = JSON.serialize(userOptions);
        Test.startTest();
        	RST_NewTitle_Controller.MagicResult mr = RST_NewTitle_Controller.getMagicForecast(options);
        test.stopTest();
        
        system.assert([SELECT Id FROM RST_Play_Week__c WHERE Title__c = :newTitle.id].size() == 15);
        
    }

    public static testmethod void testNewTitleWithGenre() {
		//Integer MAX_TITLES = 3;
        String tokenResponseBody = '{' +
                                    '"access_token": "testAccessToken",' +
                                    '"token_type": "bearer",' +
                                    '"expires_in": 3599 ' +
                                    '}';
        String newTitleResponseBody = 
            '[' +
                '{' +
                    '"Forecasting": "NonSummer",' +
                    '"GenreName": "Action/Adventure",' +
                    '"Summary": [' +
                                '{' +
                                    '"ReportingWeek": 1,' +
                                    '"Decay": null,' +
                                    '"AvgWeekEndGross": 25197783.4084,' +
                                    '"SumWeekEndGross": 1789042622' +
                                '},' +
                                '{' +
                                    '"ReportingWeek": 2,' +
                                    '"Decay": -54.8705,' +
                                    '"AvgWeekEndGross": 11765621.5352,' +
                                    '"SumWeekEndGross": 835359129' +
                                '},' +
                                '{' +
                                    '"ReportingWeek": 3,' +
                                    '"Decay": -54.5978,' +
                                    '"AvgWeekEndGross": 5766391.7285,' +
                                    '"SumWeekEndGross": 403647421' +
                                '}' +
            	   			  ']' +
    			'},' +
                    '{' +
                        '"Forecasting": "Summer",' +
                        '"GenreName": "Action/Adventure",' +
                        '"Summary": [' +
                            '{' +
                                '"ReportingWeek": 1,' +
                                '"Decay": null,' +
                                '"AvgWeekEndGross": 24944431.8484,' +
                                '"SumWeekEndGross": 823166251' +
                            '},' +
                            '{' +
                                '"ReportingWeek": 2,' +
                                '"Decay": -52.4806,' +
                                '"AvgWeekEndGross": 11300687.5757,' +
                                '"SumWeekEndGross": 372922690' +
                            '},' +
                            '{' +
                                '"ReportingWeek": 3,' +
                                '"Decay": -50.819,' +
                                '"AvgWeekEndGross": 6029279.5757,' +
                                '"SumWeekEndGross": 198966226' +
                            '}' +
                            ']' +
                    '}' +
            ']';
        RST_SingleRequestMock fakeTokenResponse = new RST_SingleRequestMock(200, 'Complete', tokenResponseBody, null);
        RST_SingleRequestMock fakenewTitleResponse = new RST_SingleRequestMock(200, 'Complete', newTitleResponseBody, null);
        
        Map<String, HttpCalloutMock> endpointMockMap = new Map<String, HttpCalloutMock>();
        endpointMockMap.put('https://callout.Magic_API.com/token', fakeTokenResponse);
        endpointMockMap.put('https://callout.Magic_API.com/magic/GetBoxofficeForecasting', fakenewTitleResponse);
        
        HttpCalloutMock multiCalloutMock = new RST_MultiRequestMock(endpointMockMap);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        //List<RST_Title__c> titles = createTestTitles(MAX_TITLES);
        createMarketCapacityWeeks(System.today().addDays(-7) , 20);
        system.assert([SELECT Id FROM RST_Market_Capacity__c].size() > 0);
        
        
        RST_Title__c newTitle = new RST_Title__c(Name = 'Test New Title',
                                                     Distributor__c = 'WB',
                                                     Rating__c = 'R',
                                                     RenTrak_ID__c = String.valueOf(10005),
                                                     FS_O_Genre__c = 'Action/Adventure',
                                                 	 Rentrak_Genre__c = 'Action',
                									 Wide_Release_Date__c = System.today() - 7
                                                     );
        insert newTitle;
        //String [] titleIds = new String [] {titles[0].id,titles[1].id,titles[2].id};
        RST_NewTitle_Controller.UserOptions userOptions = new RST_NewTitle_Controller.UserOptions();
        userOptions.Id = newTitle.id;
        userOptions.Weekend_BO = '50';
        userOptions.Midweek_BO = '20';
        userOptions.forecastModel = 'Genre';
        userOptions.seasonModel = 'NonSummer';                                                                              
        userOptions.RenTrak_Genre = 'Action/Adventure';                                                                              
        //userOptions.titles = titleIds;   
        String options = JSON.serialize(userOptions);
        Test.startTest();
        	RST_NewTitle_Controller.MagicResult mr = RST_NewTitle_Controller.getMagicForecast(options);
        test.stopTest();
        
        system.assert([SELECT Id FROM RST_Play_Week__c WHERE Title__c = :newTitle.id].size() == 3);
        
    }
    
    public static testmethod void testGetBoxOfficeActuals() {
		//Integer MAX_TITLES = 3;
        String tokenResponseBody = '{' +
                                    '"access_token": "testAccessToken",' +
                                    '"token_type": "bearer",' +
                                    '"expires_in": 3599 ' +
                                    '}';
        String boxOfficeActualsBody = 
            '[' +
                '{' +
                    '"RenkTrakId": 132961,' +
                    '"Title": "Test Title 1",' +
                    '"RatingName": "R",' +
                    '"MagicId": 35929,' +
                    '"WideReleasdDate": 20181130,' +
                    '"FSOGenre": "Horror",' +
                    '"MagicGenre": "Horror",' +
                    '"DistributorName": "SONY",' +
                    '"ReleasePatternName": "WIDE",' +
                    '"BoxOfficeActuals": [' +
                        '{' +
                            '"PlayWeek": 1,' +
                            '"MagicReleaseWeek": 1,' +
                            '"PlayWeekDate": 20181130,' +
                            '"WeekendGross": 6401744,' +
                            '"WeeklyGross": 8331549,' +
                            '"Midweekgross": 1929805' +
                        '},' +
                        '{' +
                            '"PlayWeek": 2,' +
                            '"MagicReleaseWeek": 2,' +
                            '"PlayWeekDate": 20181207,' +
                            '"WeekendGross": 3170546,' +
                            '"WeeklyGross": 4393356,' +
                            '"Midweekgross": 1222810' +
                        '},' +
                        '{' +
                            '"PlayWeek": 3,' +
                            '"MagicReleaseWeek": 3,' +
                            '"PlayWeekDate": 20181214,' +
                            '"WeekendGross": 1184814,' +
                            '"WeeklyGross": 1339016,' +
                            '"Midweekgross": 154202' +
                        '}' +
                    ']' +
                '},' +
                '{' +
                   '"RenkTrakId": 133113,' +
                    '"Title": "Test Title 2",' +
                    '"RatingName": "PG-13",' +
                    '"MagicId": 36444,' +
                    '"WideReleasdDate": 20181228,' +
                    '"FSOGenre": "Comedy",' +
                    '"MagicGenre": "Comedy",' +
                    '"DistributorName": "SONY",' +
                    '"ReleasePatternName": "WIDE",' +
                    '"BoxOfficeActuals": [' +
                        '{' +
            				'"PlayWeek": 1,' +
                            '"MagicReleaseWeek": 1,' +
                            '"PlayWeekDate": 20181214,' +
                            '"WeekendGross": 35363376,' +
                            '"WeeklyGross": 38129205,' +
                            '"Midweekgross": 2765829' +
                        '}' +
                    ']' +
                '}' +
            ']';
        RST_SingleRequestMock fakeTokenResponse = new RST_SingleRequestMock(200, 'Complete', tokenResponseBody, null);
        RST_SingleRequestMock fakeboxOfficeActualsResponse = new RST_SingleRequestMock(200, 'Complete', boxOfficeActualsBody, null);
        
        Map<String, HttpCalloutMock> endpointMockMap = new Map<String, HttpCalloutMock>();
        endpointMockMap.put('https://callout.Magic_API.com/token', fakeTokenResponse);
        endpointMockMap.put('https://callout.Magic_API.com/magic/GetBoxOfficeActual?', fakeboxOfficeActualsResponse);
        
        HttpCalloutMock multiCalloutMock = new RST_MultiRequestMock(endpointMockMap);
        
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        Test.startTest();
        	RST_NewTitle_Controller.refreshMagic();
        Test.stopTest();
        
        System.assert([SELECT Id FROM RST_Title__c].size() == 2);
    }
}