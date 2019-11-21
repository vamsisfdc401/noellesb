public class TSA_AppSettingController {
    
    @AuraEnabled
    public Static String getAppStatus(){
        String appStatus = '';
        Date startDate = null;
        Date endDate = null;
        String startDateString = null;
        String endDateString = null;
        TSA_App_Settings__c appSettings;
        List<TSA_App_Settings__c> appSettingsList = [select id, App_Status__c, Schedule_Lock_Start__c, Schedule_Lock_End__c 
                                            from TSA_App_Settings__c 
                                            where Schedule_Lock_Start__c <= TODAY
                                            and Schedule_Lock_End__c >= TODAY];
        
        system.debug('appSettingsList: ' + appSettingsList + ' ' + appSettingsList.size());
        
        if (appSettingsList != null && !appSettingsList.isEmpty() && appSettingsList.size() != 0) { 
            appSettings = appSettingsList[0];
            startDate = appSettings.Schedule_Lock_Start__c;
            endDate = appSettings.Schedule_Lock_End__c;
            startDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            endDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            appStatus = 'TSA Application is on lockdown from ' + startDateString + ' to ' + endDateString;  
   	 }   
        return appStatus;
    }
}