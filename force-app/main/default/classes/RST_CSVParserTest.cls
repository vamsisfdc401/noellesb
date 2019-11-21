/*
 * Author: Kyle Novelli
 * Date: 12/10/2018
 * Company: Slalom
 * Description: Test class for all code related to CSV loading/parsing 
 * 
 */
@isTest
private class RST_CSVParserTest {

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

    private static String convertToCSVDate(Date d) {
        return d.month() + '/' + d.day() + '/' + d.year();
    }
    
    private static List<Title> createTestTitles(Integer numTitles) 
    {
        List<Title> titleList = new List<Title>();
        for (Integer i = 1; i <= numTitles; i++) {
            String tName = 'TestTitle' + String.valueOf(i);
            String tDistributor = 'WB';
            String tRating = 'R';
            String tRenTrakId = String.valueOf(13609 + i);
            Date tWideReleaseDate = System.today();
            
            
            Title newTitle = new Title(tName, tDistributor, tRating, tRenTrakId, tWideReleaseDate);
            titleList.add(newTitle);
        }
        return titleList;
    }
        
    private static List<PlayWeek> createTestPlayWeeks(List<Title> titles, Integer numPlayWeeks,
                                                      Decimal startingWkndBOAmount, Decimal startingMdwkBOAmount,
                                                      Decimal constantWkndDropRate, Decimal constantMdwkDropRate) 
    {
        Decimal currentWkndBO = startingWkndBOAmount;
        Decimal currentMdwkBO = startingMdwkBOAmount;                                                        
        List<PlayWeek> playWeeksToInsert = new List<PlayWeek>();                                                        
        for (Title t : titles) {
            Date currDate = System.today();
            Decimal pwWeekendBO = startingWkndBOAmount;
            Decimal pwMidWeekBO = startingMdwkBOAmount;
            //Date pwWeekDate = System.today();
            Date pwWeekDate = getLastFriday();
            //create playweeks
            for (Integer i = 1; i <= numPlayWeeks; i++) {
                Title pwTitle = t;
                String pwName = t.Name + ' Week ' + String.valueOf(i);
                Integer pwPlayWeek = i;
                String pwRentrakId = t.rentrakId;
                pwWeekendBO = (i == 1) ? pwWeekendBO : (pwWeekendBO + (pwWeekendBO * (constantWkndDropRate/100)));
                Decimal pwWeekendDrop = (i == 1) ? null : constantWkndDropRate;
                pwMidWeekBO = (i == 1) ? pwMidWeekBO : (pwMidWeekBO + (pwMidWeekBO * (constantMdwkDropRate/100)));
                Decimal pwMidWeekDrop = (i == 1) ? null : constantMdwkDropRate;
                String pwSource = (i / numPlayWeeks <= 0.5) ? 'Magic' : 'CSV';
                pwWeekDate = (i == 1) ? pwWeekDate : pwWeekDate.addDays(7);
                Date pwTitleOpenDate = t.wideReleaseDate;
                Decimal pwMarketMax = 500000;
                           
                PlayWeek newPlayWeek = new PlayWeek(pwTitle, pwName, pwPlayweek, pwRentrakId, pwWeekendBO/1000000, pwWeekendDrop,
                                                    pwMidWeekBO/1000000, pwMidWeekDrop, pwSource, pwWeekDate, pwTitleOpenDate, pwMarketMax);
                playWeeksToInsert.add(newPlayWeek);
            }
        }
        return playWeeksToInsert;
    }
    
    //Return a Map of <Id(Title Id), List<PlayWeek>(Playweeks related to Title)>
    public static Map<Title, List<PlayWeek>> getTitlePlayWeekMap(List<PlayWeek> pwList) {
        //Gather all Title Ids related to each Play Week in the list
        Set<Title> titleList = new Set<Title>();
        for (PlayWeek pw : pwList) {
            titleList.add(pw.title);
        }
        //Populate Map of <Title, List<PlayWeek>(Play Weeks related to Title)>
        Map<Title, List<PlayWeek>> titlePlayWeekMap = new Map<Title, List<PlayWeek>>();

        for(PlayWeek pw : pwList) {
            	if(titlePlayWeekMap.containsKey(pw.title)) {
                    List<PlayWeek> playWeeks = titlePlayWeekMap.get(pw.title);
                    playWeeks.add(pw);
                    titlePlayWeekMap.put(pw.Title, playWeeks);
                } 
                else {
                        titlePlayWeekMap.put(pw.Title, new List<PlayWeek> {pw});
                }
        }
        return titlePlayWeekMap;
    }
    
    /*
    private static List<RST_Title__c> createTestTitles(Integer numTitles) 
    {
        List<RST_Title__c> titlesToInsert = new List<RST_Title__c>();
        for (Integer i = 1; i <= numTitles; i++) {
            RST_Title__c newTitle = new RST_Title__c(Name = 'Test Title ' + i,
                                                     Distributor__c = 'WB',
                                                     Rating__c = 'R',
                                                     RenTrak_ID__c = String.valueOf(13609 + i),
                									 Wide_Release_Date__c = System.today()
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
                                                                    Market_Max__c = 500000);
                playWeeksToInsert.add(newPlayWeek);
            }
        }
        insert playWeeksToInsert;
        return playWeeksToInsert;
    }
	*/
    private static String createTestDyanmicCSVString(Map<Title, List<PlayWeek>> titlePlayWeekMap, Map<String, RST_Forecast_CSV_Column__mdt> csvColumns) {
        String eol = '\r\n';
        String csvBodyString = '';
        for(RST_Forecast_CSV_Column__mdt column : csvColumns.values()){
            csvBodyString += column.Column_Name__c + ',';
        }
        csvBodyString = csvBodyString.removeEnd(',') + eol;
        system.debug(csvBodyString);
        for (Title t : titlePlayWeekMap.keySet()) {
            List<PlayWeek> pwList = titlePlayWeekMap.get(t);

            String titleName = Parser.DQUOTE + t.name + Parser.DQUOTE;
            //String titleName = t.name;
            Date titleOpen = t.wideReleaseDate;

            Decimal cumulativeTitleBO = 0.0;

            for(PlayWeek pw : pwList) {

                cumulativeTitleBO += pw.weekendBO + pw.midWeekBO;

                for(RST_Forecast_CSV_Column__mdt column : csvColumns.values()){
                    switch on column.QualifiedApiName{
                        when 'Title'{
                            csvBodyString += titleName;
                        } when 'Open_Date'{
                            csvBodyString += convertToCSVDate(titleOpen);
                        } when 'Midweek_BO'{
                            csvBodyString += String.valueOf(pw.midWeekBO);
                        } when 'Midweek_Decay'{
                            csvBodyString += pw.midWeekDrop != null ? String.valueOf(pw.midWeekDrop) : '';
                        } when 'Play_Week_Date'{
                            csvBodyString += convertToCSVDate(pw.weekDate);
                        } when 'Play_Week_Number'{
                            csvBodyString += String.valueOf(pw.playWeek);
                        } when 'Rentrak_Id'{
                            csvBodyString += pw.rentrakId;
                        } when 'Weekend_BO'{
                            csvBodyString += String.valueOf(pw.weekendBO);
                        } when 'Weekend_Decay'{
                            csvBodyString += pw.weekendDrop != null ? String.valueOf(pw.weekendDrop) : '';
                        } when else {
                            csvBodyString += 'unknwn';
                        }
                    }
                    csvBodyString += ',';
                }   
                csvBodyString = csvBodyString.removeEnd(',') + eol;
            }
        }
        system.debug(csvBodyString);

        //remove final newline from csvBodyString
        csvBodyString = csvBodyString.substring(0, csvBodyString.length()-4);
        return csvBodyString;

    }

    private static String createTestCSVString(Map<Title, List<PlayWeek>> titlePlayWeekMap) 
    {
        String csvBodyString = '';
        //Add 1st third of headers
        csvBodyString += 'TitleCode1,Title,Date,Week0,3DWkndCalc0,MidWeekCalc0,WeekendActual0,MidWeekActual0,WkndDrop0,WeekDrop0,';
        //Add 2nd third of headers
        csvBodyString += 'PlayWeek0,%ofWeekend,TotalWeek0,Cumulative0,Dist,Rating,BookingTitleNo4,Director,Cast,tbl_Rentrak_Release Calendar_Rating,Synopsis,';
        //Add 3rd third of headers
        csvBodyString += '%WkndDrop,AvgOfWeekend Gross,MaxOfWeekend Gross,MinOfWeekend Gross,AvailableAvg,AvailableMax,AvailableMin,Rank,Code,45';
        csvBodyString += '\r\n'; //new line; end of headers
        
        
        //Create CSV rows for PlayWeeks
        for (Title t : titlePlayWeekMap.keySet()) {
            List<PlayWeek> pwList = titlePlayWeekMap.get(t);
            Decimal cumulativeTitleBO = 0.0;
            for(PlayWeek pw : pwList) {
                cumulativeTitleBO += pw.weekendBO + pw.midWeekBO;
                csvBodyString += (pw.rentrakId + convertToCSVDate(pw.titleOpenDate) + ','); //1st Column: TitleCode1
                csvBodyString += (t.name + ','); //2nd Column: Title (required)
                csvBodyString += (convertToCSVDate(pw.titleOpenDate) + ','); //3rd Column: Date (required)
                csvBodyString += (convertToCSVDate(pw.weekDate) + ','); //4th Column: Week0 (required)
                csvBodyString += (String.valueOf(pw.weekendBO) + ','); //5th Column: 3DWkndCalc0 (required)
                csvBodyString += (String.valueOf(pw.midWeekBO) + ','); //6th Column: MidWeekCalc0 (required)
                csvBodyString += (String.valueOf((pw.weekendBO*1000000)) + ','); //7th Column: WeekendActual0
                csvBodyString += (String.valueOf((pw.midWeekBO*1000000)) + ','); //8th Column: MidWeekActual0
                csvBodyString += (pw.weekendDrop == null) ? ',' : (String.valueOf(pw.weekendDrop) + ','); //9th Column: WkndDrop0 (required)
                csvBodyString += (pw.midWeekDrop == null) ? ',' : (String.valueOf(pw.midWeekDrop) + ','); //10th Column: WeekDrop0 (required)
                csvBodyString += (String.valueOf(pw.playWeek) + ','); //11th Column: PlayWeek0 (required)
                csvBodyString += ','; //12th Column: %ofWeekend
                csvBodyString += (String.valueOf(pw.weekendBO + pw.midWeekBO) + ','); //13th Column: TotalWeek0 (required)
                csvBodyString += (String.valueOf(cumulativeTitleBO) + ','); //14th Column: Cumulative0 (required)
                csvBodyString += (pw.title.distributor + ','); //15th Column: Dist
                csvBodyString += (pw.title.rating + ','); //16th Column: Rating
                csvBodyString += (pw.rentrakId + ','); //17th Column: BookingTitleNo4 (required)
                csvBodyString += ','; //18th Column: Director
                csvBodyString += ','; //19th Column: Cast
                csvBodyString += ','; //20th Column: tbl_Rentrack_Release Calendar_Rating
                csvBodyString += ','; //21st Column: Synopsis
                csvBodyString += String.valueOf(pw.weekendDrop) + ','; //22nd Column: %WkndDrop
                csvBodyString += ','; //23rd Column: AvgOfWeekend Gross
                csvBodyString += ','; //24th Column: MaxOfWeekend Gross
                csvBodyString += ','; //25th Column: MinOfWeekend Gross
                csvBodyString += ','; //26th Column: AvailableAvg
                csvBodyString += (String.valueOf(pw.marketMax) + ','); //27th Column: AvailableMax (required)
                csvBodyString += ','; //28th Column: AvailableMin
                csvBodyString += ','; //29th Column: Rank
                csvBodyString += ','; //30th Column: Code
                csvBodyString += ','; //31st Column: 45
                csvBodyString += '\r\n'; //new line; end of csv row
            } 
        }
        //remove final newline from csvBodyString
        csvBodyString = csvBodyString.substring(0, csvBodyString.length()-4);
        return csvBodyString;
    }

    //private static void createTestCSVFile(String filename, RST_Forecast_Upload__c fu, Blob csvBody) 
    private static void createTestCSVFile(RST_Forecast_Upload__c fu, Blob csvBody) {
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'Test_CSV.csv';
        cv.Title = 'Test_CSV.csv - ' + String.valueOf(System.Today());
        cv.VersionData = csvBody;
        System.debug('Content Version: ' + cv);
        insert cv;
        
        //Get the content document id from cv
        Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocumentId;
        cdl.LinkedEntityId = fu.id;
        cdl.ShareType = 'I';   
        insert cdl;
    }
    public static testmethod void testErrorHandling() {
        Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            if(csvColumn.QualifiedApiName == 'Title') csvColumn.Column_Name__c = 'Not the title';
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }

        Integer MAX_WEEKS = 15;
        Integer MAX_TITLES = 3;

        List<Title> testTitles = createTestTitles(MAX_TITLES);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, MAX_WEEKS, 20000000, 10000000, -50.00, -50.00);

        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);

        RST_Forecast_Upload__c testUpload = new RST_Forecast_Upload__c();
        insert testUpload;
        createTestCSVFile(testUpload, Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap)) );

        // number of content docuemnts for upload > 0
        system.assert([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testUpload.Id].size() > 0); 

        Test.startTest();
        RST_Controller.ParseResults csv_to_lines = RST_Controller.processCSVLines(testUpload.Id);
        //System.assertEquals('Success', csv_to_lines.result);
        if(csv_to_lines.result == 'Success'){
            RST_Controller.processRawCSV_Batch(testUpload.Id);
            //Database.ExecuteBatch(new RST_BatchProcess_RawCSV(testUpload.Id));
        }
        Test.stopTest();

        
		
        List<RST_Process_Log__c > resultErr = [SELECT Id, Class__c, Function__c, Method__c, Name, Trace__c FROM RST_Process_Log__c ];
        system.debug('resultErr: ' + resultErr);
        system.debug('resultErr.size(): ' + resultErr.size());
        system.assert(resultErr.size() > 0); //testPlayWeeks.size());
		
    }

    public static testmethod void testDynamicColumnNames() {

        RST_Application_Setting__mdt appSettings = [SELECT Playweek_Maximum__c, Playweek_Minimum__c FROM RST_Application_Setting__mdt WHERE DeveloperName = 'Standard' LIMIT 1];
        Integer min_week = Integer.valueOf(appSettings.Playweek_Minimum__c);
        Integer max_week = Integer.valueOf(appSettings.Playweek_Maximum__c);
        Boolean has_min = min_week != null;
        Boolean has_max = max_week != null;


        Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        
        Integer MAX_WEEKS = 20;
        Integer MAX_TITLES = 4;

        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);

        List<RST_Market_Capacity__c> weeks = [SELECT Id, Name FROM RST_Market_Capacity__c];
        system.debug('weeks.size(): ' + weeks.size());
        system.assert(MAX_WEEKS == weeks.size());


        // test objects arent actual sobjects...
        List<Title> testTitles = createTestTitles(MAX_TITLES);
        //List<RST_Title__c> actualTitles = new List<RST_Title__c>();
        /*
        Map<String, RST_Title__c> actualTitlesMap = new Map<String, RST_Title__c>();

        for(Title t : testTitles){
            RST_Title__c newT = new RST_Title__c();
            newT.RenTrak_ID__c = t.rentrakId;
            actualTitlesMap.put(newT.RenTrak_ID__c, newT);
        }
        */
        //insert actualTitlesMap.values();
        /*
        for(RST_Title__c actualTitle : [SELECT Id, RenTrak_ID__c FROM RST_Title__c]){
            actualTitlesMap.put(actualTitle.RenTrak_ID__c, actualTitle);
        }
        */

        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, MAX_WEEKS, 20000000, 10000000, -50.00, -50.00);
        /*
        List<RST_Play_Week__c> actual_pws = new List<RST_Play_Week__c>();
        for(PlayWeek pw : testPlayWeeks){
            Id actualTitleId = actualTitlesMap.get(pw.rentrakId).Id;
            system.debug('actualTitleId: ' + actualTitleId);
            actual_pws.add(getRST_Play_Week(pw, actualTitleId));
        }
        */
        //insert actual_pws;

        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);

        RST_Forecast_Upload__c testUpload = new RST_Forecast_Upload__c();
        insert testUpload;
        createTestCSVFile(testUpload, Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap)) );

        // number of content docuemnts for upload > 0
        system.assert([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testUpload.Id].size() > 0); 

        Test.startTest();
        RST_Controller.ParseResults csv_to_lines = RST_Controller.processCSVLines(testUpload.Id);
        if(csv_to_lines.result == 'Success'){
            Database.ExecuteBatch(new RST_BatchProcess_RawCSV(testUpload.Id));
        }
        
        Test.stopTest();
        
        List<RST_Play_Week__c> resultPWs = [SELECT Id FROM RST_Play_Week__c];
        system.debug('resultPWs.size(): ' + resultPWs.size());
        system.debug('testPlayWeeks.size(): ' + testPlayWeeks.size());
        Integer checkTotal = (has_max && max_week < MAX_WEEKS) ? max_week * MAX_TITLES : MAX_WEEKS * MAX_TITLES;
        system.assert(resultPWs.size() == checkTotal); //testPlayWeeks.size());
        
        //test version handler
        List<RST_Version__c> versionList = [SELECT Id FROM RST_Version__c];
        System.assertEquals(1, versionList.size());
        delete versionList;
        //test forecastupload handler
        List<ContentDocument> fileList = [SELECT Id FROM ContentDocument];
        System.assertEquals(0, fileList.size());

    }
    
    
    public static testmethod void testOverWriteCSVData() {
        

        Integer MAX_WEEKS = 12;
        
        Map<Date, RST_Market_Capacity__c> mcWeekMap = new Map<Date, RST_Market_Capacity__c>();
        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);
        for(RST_Market_Capacity__c week : [SELECT Id, Name, Week_Date__c FROM RST_Market_Capacity__c]){
            mcWeekMap.put(week.Week_Date__c , week);
        }
		

        // test objects arent actual sobjects...
        List<Title> testTitles = createTestTitles(3);
        //List<RST_Title__c> actualTitles = new List<RST_Title__c>();
        Map<String, RST_Title__c> actualTitlesMap = new Map<String, RST_Title__c>();

        for(Title t : testTitles){
            RST_Title__c newT = new RST_Title__c();
            newT.RenTrak_ID__c = t.rentrakId;
            actualTitlesMap.put(newT.RenTrak_ID__c, newT);
        }
        insert actualTitlesMap.values();
        
        for(RST_Title__c actualTitle : [SELECT Id, RenTrak_ID__c FROM RST_Title__c]){
            actualTitlesMap.put(actualTitle.RenTrak_ID__c, actualTitle);
        }

		system.debug(mcWeekMap);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, MAX_WEEKS, 20000000, 10000000, -50.00, -50.00);
        system.debug('testPlayWeeks: ' + testPlayWeeks);
        List<RST_Play_Week__c> actual_pws = new List<RST_Play_Week__c>();
        for(PlayWeek pw : testPlayWeeks){
            
            Id actualTitleId = actualTitlesMap.get(pw.rentrakId).Id;
            system.debug('pw: ' + pw);
            system.debug('pw.weekdate: ' + pw.weekdate);
            Date useDate = Date.newInstance( pw.weekdate.year(), pw.weekdate.month(), pw.weekdate.day());
            Id mcId = mcWeekMap.get(useDate).Id;
            actual_pws.add(getRST_Play_Week(pw, actualTitleId, mcId));
        }
        insert actual_pws;

        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);

        RST_Forecast_Upload__c testUpload = new RST_Forecast_Upload__c();
        insert testUpload;
        createTestCSVFile(testUpload, Blob.valueOf(createTestCSVString(titlePlayWeekMap)) );
        
        List<List<String>> test_code_coverage = CSV_Reader.parseCSV(createTestCSVString(titlePlayWeekMap), false);

        // number of content docuemnts for upload > 0
        system.assert([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testUpload.Id].size() > 0); 

        Test.startTest();
        RST_Controller.ParseResults csv_to_lines = RST_Controller.processCSVLines(testUpload.Id);
        if(csv_to_lines.result == 'Success'){
            Database.ExecuteBatch(new RST_BatchProcess_RawCSV(testUpload.Id));
        }
        Test.stopTest();
        
        List<RST_Play_Week__c> resultPWs = [SELECT Id FROM RST_Play_Week__c];
        system.debug('resultPWs.size(): ' + resultPWs.size());
        system.debug('testPlayWeeks.size(): ' + testPlayWeeks.size());
        system.assert(resultPWs.size() == testPlayWeeks.size());
        

    }
    /*
    public static testmethod void testOverWriteMagicData() {
        //***** TO DO *****
    }
    */

    public static testmethod void testInboundEmailHandler() {
		Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        Integer MAX_WEEKS = 20;

        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);

       	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Inbound Email Handler';
        email.fromAddress = 'kyle.novelli@slalom.com';
        email.plainTextBody = 'TEST';
        
        //Add Binary Attachment
        Messaging.InboundEmail.BinaryAttachment csv = new Messaging.InboundEmail.BinaryAttachment();
        List<Title> testTitles = createTestTitles(3);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, 15, 20000000, 10000000, -50.00, -50.00);
        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);
        csv.body = Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap));
        csv.fileName = 'Test_CSV.csv';
        email.BinaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {csv};
            
        //call the email service class and test it with the data
        RST_Inbound_Email_Handler ieh = new RST_Inbound_Email_Handler();
        Messaging.InboundEmailResult result = ieh.handleInboundEmail(email, env);

        System.assertEquals('Successfully processed attached CSV file from Inbound Email.\r\nYour file: ' + csv.filename + ' has been processed for the Release Scheduling Tool.', result.message);
        
    }
    
    public static testmethod void testInboundEmailHandlerWithTwoAttachments() {
		Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        Integer MAX_WEEKS = 20;

        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);

       	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Inbound Email Handler';
        email.fromAddress = 'kyle.novelli@slalom.com';
        email.plainTextBody = 'TEST';
        
        //Add Binary Attachment
        Messaging.InboundEmail.BinaryAttachment csv = new Messaging.InboundEmail.BinaryAttachment();
        Messaging.InboundEmail.BinaryAttachment csv2 = new Messaging.InboundEmail.BinaryAttachment();
        List<Title> testTitles = createTestTitles(3);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, 15, 20000000, 10000000, -50.00, -50.00);
        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);
        csv.body = Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap));
        csv2.body = Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap));
        csv.fileName = 'Test_CSV.csv';
        csv2.fileName = 'Test_CSV2.csv';
        email.BinaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {csv, csv2};
            
        //call the email service class and test it with the data
        RST_Inbound_Email_Handler ieh = new RST_Inbound_Email_Handler();
        
        Messaging.InboundEmailResult result = ieh.handleInboundEmail(email, env);
        System.assertEquals('Inbound Email contains more than one file. Please ensure there is only one file attached to your Inbound Email.', result.message);
        
    }
    
    public static testmethod void testInboundEmailHandlerWithNoAttachments() {
		Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        Integer MAX_WEEKS = 20;

        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);

       	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Inbound Email Handler';
        email.fromAddress = 'kyle.novelli@slalom.com';
        email.plainTextBody = 'TEST';

        List<Title> testTitles = createTestTitles(3);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, 15, 20000000, 10000000, -50.00, -50.00);
        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);
            
        //call the email service class and test it with the data
        RST_Inbound_Email_Handler ieh = new RST_Inbound_Email_Handler();
        
        Messaging.InboundEmailResult result = ieh.handleInboundEmail(email, env);
        System.assertEquals('Inbound Email did not contain any CSV attachment. Please ensure there is a CSV attached to your Inbound Email.', result.message);
        
    }
    
    public static testmethod void testInboundEmailHandlerWithNonCSVAttachment() {
		Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT Id, MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        Integer MAX_WEEKS = 20;

        createMarketCapacityWeeks(getLastFriday(), MAX_WEEKS);

       	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Inbound Email Handler';
        email.fromAddress = 'kyle.novelli@slalom.com';
        email.plainTextBody = 'TEST';
        
        //Add Binary Attachment
        Messaging.InboundEmail.BinaryAttachment csv = new Messaging.InboundEmail.BinaryAttachment();
        List<Title> testTitles = createTestTitles(3);
        List<PlayWeek> testPlayWeeks = createTestPlayWeeks(testTitles, 15, 20000000, 10000000, -50.00, -50.00);
        Map<Title, List<PlayWeek>> titlePlayWeekMap = getTitlePlayWeekMap(testPlayWeeks);
        csv.body = Blob.valueOf(createTestDyanmicCSVString(titlePlayWeekMap, csvColumnMap));
        csv.fileName = 'Test_CSV.xml';
        email.BinaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] {csv};
            
        //call the email service class and test it with the data
        RST_Inbound_Email_Handler ieh = new RST_Inbound_Email_Handler();
        Messaging.InboundEmailResult result = ieh.handleInboundEmail(email, env);

        System.assertEquals('Inbound Email attached file is not of type CSV. Please ensure the file attached to your Inbound Email is of type CSV.', result.message);
        
    }
    
    private static RST_Play_Week__c getRST_Play_Week(PlayWeek ui_pw, String actualTitleId, Id mcId){
        RST_Play_Week__c pw = new RST_Play_Week__c();
        pw.Midweek_BO__c = ui_pw.midWeekBO;
        pw.Midweek_Drop__c = ui_pw.midWeekDrop;
        pw.Play_Week__c = ui_pw.playweek;
        pw.Market_Capacity__c = mcId;
        pw.Name = ui_pw.name;
        pw.RenTrak_Id__c = ui_pw.rentrakId;
        pw.Source__c = 'CSV';
        pw.Title__c = actualTitleId;
        pw.Week_Date__c = ui_pw.weekdate;
        pw.Weekend_BO__c = ui_pw.weekendBO;
        pw.Weekend_Drop__c = ui_pw.weekendDrop;
        

        return pw;
    }
    
    static testmethod void parserConstantsTest() {
        System.assert(Parser.COMMA == ',');
        System.assert(Parser.CR == '\r');
        System.assert(Parser.LF == '\n');
        System.assert(Parser.CRLF == '\r\n');
        System.assert(Parser.LFCR == '\n\r');
        System.assert(Parser.DQUOTE == '"');
        System.assert(Parser.DQUOTEDQUOTE == '""');
        
    }
    
    //Wrapper Classes used to assist in creating test CSV data
    
    //Wrapper Class for Test
    private class Title {
        public String name;
        public String distributor;
        public String rating;
        public String rentrakId;
        public Date wideReleaseDate;
        
        Title() {
            name = 'Test Title';
            distributor = 'WB';
            rating = 'R';
            rentrakId = '00000';
            wideReleaseDate = System.today();
        }
        
        Title(String name, String distributor, String rating, String rentrakId, Date wideReleaseDate) {
            this.name = name;
            this.distributor = distributor;
            this.rating = rating;
            this.rentrakId = rentrakId;
            this.wideReleaseDate = wideReleaseDate;
        }
    }
    
    //Wrapper Class for Play Week
    private class PlayWeek {
        public Title title;
        public String name;
        public Integer playweek;
        public String rentrakId;
        public Decimal weekendBO;
        public Decimal weekendDrop;
        public Decimal midWeekBO;
        public Decimal midWeekDrop;
        public String source;
        public Date weekdate;
        public Date titleOpenDate;
        public Decimal marketMax;
            
        PlayWeek() {
            title = new Title();
            name = 'Test Title Week';
            playweek = 0;
            rentrakId = '00000';
            weekendBO = 10000000;
            weekendDrop = -50.00;
            midWeekBO = 5000000;
            midWeekDrop = -50.00;
            source = 'CSV';
            weekdate = System.today();
            titleOpenDate = System.today();
            marketMax = 500000;
        }    
            
        PlayWeek(Title title, String name, Integer playweek, String rentrakId, Decimal weekendBO, Decimal weekendDrop,
                 Decimal midWeekBO, Decimal midWeekDrop, String source, Date weekDate, Date titleOpenDate, Decimal marketMax) {
            this.title = title;
            this.name = name;
            this.playweek = playweek;
            this.rentrakId = rentrakId;
            this.weekendBO = weekendBO;
            this.weekendDrop = weekendDrop;
            this.midWeekBO = midWeekBO;
            this.midWeekDrop = midWeekDrop;
            this.source = source;
            this.weekdate = Date.valueOf(weekDate);
            this.titleOpenDate = titleOpenDate;
            this.marketMax = marketMax;
        } 
    }
}