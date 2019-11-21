global with sharing class RST_MagicYearIterator implements Iterator<String> {
    //AggregateResult [] results {get;set;}
    List<String> results {get;set;}
    // tracks which result item is returned
    Integer index {get; set;} 

    global RST_MagicYearIterator() {
        index = 0;
        results = new List<String>();

        RST_Application_Setting__mdt magicSettings = [SELECT Magic_Future_Years__c, Magic_Start_Date__c FROM  RST_Application_Setting__mdt WHERE DeveloperName = 'Standard'];
        Integer startYear = magicSettings.Magic_Start_Date__c.year();
        Integer endYear = (Test.isRunningTest()) ? magicSettings.Magic_Start_Date__c.year() + 1 : System.today().year() + Integer.valueOf(magicSettings.Magic_Future_Years__c);
        for(Integer y = startYear; y < endYear; y++) results.add(String.valueOf(y));
        system.debug(results);
        //results = Database.query(query);
        //results = new List<String>();
    } 

    global boolean hasNext(){ 
        return results != null && !results.isEmpty() && index < results.size(); 
    }    

    global String next(){        
        return results[index++];            
    }       
}