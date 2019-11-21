global class CIRFMaterialForecastStatusBatch implements Database.Batchable<sObject>{
    
    Static List<String> StageList=new List<String>{'Loaded','Published'};
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select Id, Stage__c,Archive_Date__c,Forecast_Week_calc__c from CIRF_Material_Forecast__c where Stage__c=:StageList';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CIRF_Material_Forecast__c> ForecastList){
        List<CIRF_Material_Forecast__c> UpdateList = new List<CIRF_Material_Forecast__c>();
        for(CIRF_Material_Forecast__c mf : ForecastList){
            if(mf.Forecast_Week_calc__c < Date.today() && StageList.contains(mf.Stage__c)){
                mf.Stage__c = 'Complete';
                UpdateList.add(mf);
            }
            if(mf.Archive_Date__c != null){
                mf.Archive_Date__c = Date.today();
            }
            
        }
        Update UpdateList;
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}