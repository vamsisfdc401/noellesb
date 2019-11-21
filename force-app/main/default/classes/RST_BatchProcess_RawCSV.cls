global class RST_BatchProcess_RawCSV implements Database.Batchable<sObject> , Database.Stateful{
    
    private Map<String, Integer> columnHeaders = new Map<String, Integer>();
    private Map<String, RST_Forecast_CSV_Column__mdt> csvColumnMap;
    private RST_Application_Setting__mdt appSettings;
    private Id versionId;
    private Id useUploadId;
    private Set<String> real_issues = new Set<String>();
    
    public RST_BatchProcess_RawCSV(String uploadId){
        useUploadId = uploadId;
        
        RST_Version__c new_version = new RST_Version__c();
        new_version.Name = 'BaseLine ' + system.today();
        new_version.Upload__c = uploadId;
        insert new_version;
        versionId = new_version.Id;
        
        RST_RawCSVLine__c columnHeaderRow = [SELECT Id, RawCSV__c, UploadId__c FROM RST_RawCSVLine__c WHERE Is_Header__c = true AND UploadId__c = :uploadId LIMIT 1];
        List<String> columnHeaderString = new List<String>{columnHeaderRow.RawCSV__c};
            List<List<String>> csvLines = CSV_Reader.parseCSVColumns(columnHeaderString, false);
        if(columnHeaders.size() == 0 ){ 
            for(Integer i = 0 ; i < csvLines[0].size(); i++){
                columnHeaders.put(csvLines[0][i], i);
            }
        }
        system.debug(columnHeaders);
        
        csvColumnMap = new Map<String, RST_Forecast_CSV_Column__mdt>();
        for(RST_Forecast_CSV_Column__mdt csvColumn : [SELECT MasterLabel, QualifiedApiName, Bypass_Auto_Save__c, Column_Name__c, Data_Type__c, Mapped_Field__c, Required__c FROM RST_Forecast_CSV_Column__mdt]){
            csvColumnMap.put(csvColumn.QualifiedApiName, csvColumn);
        }
        
        appSettings = [SELECT Playweek_Maximum__c, Playweek_Minimum__c FROM RST_Application_Setting__mdt WHERE DeveloperName = 'Standard' LIMIT 1];
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Processed__c, RawCSV__c, UploadId__c FROM RST_RawCSVLine__c WHERE Processed__c = false  AND Is_Header__c = false AND UploadId__c = \'' + useUploadId + '\' ORDER BY Name'
        );
    }
    global void execute(Database.BatchableContext bc, List<RST_RawCSVLine__c> records){
        
        try{
            
            
            String uploadId;
            List<String> linesToParse = new List<String>();
            for(RST_RawCSVLine__c raw : records){
                uploadId = raw.UploadId__c;
                linesToParse.add(raw.RawCSV__c);
                raw.Processed__c = true; // will update after records inserted
            }
            List<List<String>> csvLines;
            try{
                csvLines = CSV_Reader.parseCSVColumns(linesToParse, false);
            } catch(Exception e){
                system.debug('failed csv parse on: '+ linesToParse);
                throw new RST_Exception('failed csv parse on: '+ linesToParse);
            }
            
            
            if(columnHeaders.size() == 0 ){ // theres a problem
                throw new RST_Exception('no column headers for batch processing');
            } else {
                
                for(String columnLabel : csvColumnMap.keySet()){
                    RST_Forecast_CSV_Column__mdt csvColumn = csvColumnMap.get(columnLabel);
                    
                    if(!columnHeaders.containsKey(csvColumn.Column_Name__c)){
                        system.debug('missing column ' + csvColumn.Column_Name__c);
                        
                        String className, methodName, functionName, trace;
                        className = 'RST_BatchProcess_RawCSV';
                        methodName = 'execute';
                        functionName = 'checking columns';
                        trace = 'missing required field: ' + csvColumn.Column_Name__c;
                        
                        throw new RST_Exception('missing required field: ' + csvColumn.Column_Name__c);
                    }
                }
                
                system.debug(appSettings); // get app settings for play week min / max
                Integer min_week = Integer.valueOf(appSettings.Playweek_Minimum__c);
                Integer max_week = Integer.valueOf(appSettings.Playweek_Maximum__c);
                Boolean has_min = min_week != null;
                Boolean has_max = max_week != null;
                
                List<RST_Play_Week__c> newTitlePlayWeeks = new List<RST_Play_Week__c>();
                Map<String, RST_Title__c> rentrakTitleMap = new Map<String, RST_Title__c>(); // need to get current list as well
                
                Map<Date, RST_Market_Capacity__c> mcWeeksMap = new Map<Date, RST_Market_Capacity__c>();
                List<RST_Play_Week__c> pws = new List<RST_Play_Week__c>();
                for(Integer row = 0; row < csvLines.size(); row++){
                    List<String> use_row = csvLines[row];
                    
                    String rentrakId = use_row[ columnHeaders.get( csvColumnMap.get('Rentrak_Id').Column_Name__c)];
                    String useTitle = use_row[ columnHeaders.get( csvColumnMap.get('Title').Column_Name__c)];
                    String usePlayWeek = use_row[ columnHeaders.get( csvColumnMap.get('Play_Week_Number').Column_Name__c)];
                    String usePlayWeekDate = use_row[ columnHeaders.get( csvColumnMap.get('Play_Week_Date').Column_Name__c)];
                    String pw_name = useTitle + ' Week: ' + usePlayWeek;
                    String useReleaseDate = use_row[ columnHeaders.get( csvColumnMap.get('Open_Date').Column_Name__c)];
                    
                    Boolean validPlayWeek = true;
                    if(has_min) validPlayWeek =  (usePlayWeek != null) && Integer.valueOf(usePlayWeek) >= min_week; 
                    if(has_max && validPlayWeek) validPlayWeek = (usePlayWeek != null) && Integer.valueOf(usePlayWeek) <= max_week; 
                    
                    if(validPlayWeek){
                        
                        RST_Title__c currentTitle = rentrakTitleMap.get(rentrakId);
                        if(currentTitle == null){
                            currentTitle = new RST_Title__c(); // reference record
                            currentTitle.RenTrak_Id__c = rentrakId;
                            currentTitle.Wide_Release_Date__c = date.parse(useReleaseDate);
                        }
                        currentTitle.Name = useTitle;
                        rentrakTitleMap.put(rentrakId, currentTitle); // overwrites the title, used to link up after
                        
                        mcWeeksMap.put( date.parse( usePlayWeekDate ) , null); // just overwrite the week, used to get weeks and link ids later
                        
                        
                        RST_Play_Week__c pw = new RST_Play_Week__c();
                        pw.Name = pw_name;
                        pw.Version__c = versionId; //new_version.Id;
                        pw.Source__c = 'CSV';
                        
                        for(RST_Forecast_CSV_Column__mdt columnDef : csvColumnMap.values()){
                            String cellValue = use_row[columnHeaders.get(columnDef.Column_Name__c)];
                            if(!columnDef.Bypass_Auto_Save__c && cellValue != ''){ // some columns are for titles and some data is empty
                                try{
                                    switch on columnDef.Data_Type__c {
                                        when 'String'{
                                            pw.put( columnDef.Mapped_Field__c,  cellValue);
                                        } when 'Date'{
                                            pw.put(columnDef.Mapped_Field__c, date.parse( cellValue));
                                        } when 'Decimal'{
                                            pw.put(columnDef.Mapped_Field__c, Decimal.valueOf( cellValue ));
                                        } when 'Percent'{
                                            pw.put(columnDef.Mapped_Field__c, Decimal.valueOf( cellValue ) * 100);
                                        }
                                    }
                                } catch (Exception e){
                                    system.debug('data cast issue ' + columnDef);
                                    system.debug('data: ' + cellValue );
                                    
                                    throw new RST_Exception('issue converting : ' + cellValue + ' -- ' + columnDef.Column_Name__c + ' -- ' + columnDef.QualifiedApiName);
                                }
                            }
                        }              
                        
                        newTitlePlayWeeks.add(pw);
                    }
                    
                }
                
                // prep data for merging
                for(RST_Title__c t : [SELECT Id, Lock_Title__c, RenTrak_Id__c FROM RST_Title__c WHERE RenTrak_Id__c IN :rentrakTitleMap.keySet()]){
                    rentrakTitleMap.put(t.RenTrak_Id__c, t);
                }
                
                //
                // Get all market capacitys from playweeks dates
                // 
                for(RST_Market_Capacity__c mc : [SELECT Id, Week_Date__c FROM RST_Market_Capacity__c WHERE Week_Date__c IN :mcWeeksMap.keySet()]){
                    mcWeeksMap.put(mc.Week_Date__c, mc);
                }
                
                //
                // get all play weeks that exist in salesforce based on rentrak id
                // 
                Map<String, Map<String, RST_Play_Week__c>> rentrakPlayWeekWeekMap = RST_Utilities.getRentrakPlayWeekMap(rentrakTitleMap.keySet());
                
                if(newTitlePlayWeeks.size() > 0){
                    try{
                        
                        upsert rentrakTitleMap.values();
                        List<RST_Play_Week__c> playWeeksToUpsert = new List<RST_Play_Week__c>();
                        
                        for(RST_Play_Week__c pw : (List<RST_Play_Week__c>) newTitlePlayWeeks){
                            
                            RST_Title__c currentTitle = rentrakTitleMap.get(pw.RenTrak_Id__c);
                            pw.Title__c = currentTitle.Id; //rentrakTitleMap.get(pw.RenTrak_Id__c).Id;
                            
                            RST_Market_Capacity__c currentMC = mcWeeksMap.get(pw.Week_Date__c);
                            pw.Market_Capacity__c = currentMC.Id;
                            
                            Map<String, RST_Play_Week__c> weekMap = rentrakPlayWeekWeekMap.get(pw.RenTrak_Id__c);
                            
                            if(weekMap == null) { // no existing playweeks, add this one
                                //system.debug('did not find any existing playweeks for this title: ' + pw.RenTrak_Id__c);
                                playWeeksToUpsert.add(pw);
                            } else {
                                // there are playweeks for this title, do they have this week?
                                RST_Play_Week__c existingPW = weekMap.get(String.valueOf(pw.Play_Week__c));
                                if(existingPW == null){
                                    system.debug('did not find an existing playweek for this title for this week:' + pw.Play_Week__c);
                                    playWeeksToUpsert.add(pw);
                                } else {
                                    if(existingPW.Source__c == 'Magic' || currentTitle.Lock_Title__c){ // or locked also?
                                        system.debug('record either magic or locked, will not overwrite' + existingPW);
                                        //pw = existingPW; // overwrite csv value with existing value
                                        //system.debug('now pw record: ' + pw);
                                    } else {
                                        system.debug('this play week was not edited by magic or locked:' + pw.Play_Week__c);
                                        pw.Id = existingPW.Id; // overwrites existing pw data with what was in csv file
                                        playWeeksToUpsert.add(pw); 
                                    }
                                    
                                } 
                                
                            }
                        }   
                        
                        if(playWeeksToUpsert.size() > 0 ) upsert playWeeksToUpsert;
                        
                        delete records; // set to processed earlier
                        
                    } catch(Exception e){
                        system.debug('issue saving: ' + e.getMessage());
                        throw new RST_Exception('issue saving :' + e.getMessage() + ' ; ' + e.getCause());
                    }
                    
                }
                
                
            }
            
        }catch(RST_Exception re){
            real_issues.add(re.getMessage());
        }
                
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations        
        delete [SELECT Id FROM RST_RawCSVLine__c]; // should only contain version header at this point
        
        RST_Utilities.parentPlayWeeks(); // link play weeks 1 - 15 as parent child
        
        AsyncApexJob a = [SELECT Id, Status, 
                          CreatedDate,
                          ExtendedStatus,
                          NumberOfErrors, 
                          JobItemsProcessed, 
                          TotalJobItems, 
                          CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
        String className = 'BatchProcessRawCSV';
        Boolean hasIssues = real_issues.size() > 0;
        String traceString = 'Success';
        
        if(hasIssues ){            
            RST_Utilities.logRST_Error(className, hasIssues, String.valueOf(real_issues));
        } else {
            RST_Utilities.logRST_Error(className, hasIssues, traceString);
        }
    }    
}