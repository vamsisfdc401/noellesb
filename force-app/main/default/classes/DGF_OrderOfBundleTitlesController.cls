public with sharing class DGF_OrderOfBundleTitlesController {
 
 
 /***********************************
    Method Name: fetchTitles
    Purpose: method to fetch Titles from Order of Titles for the Budle Release
    ***********************************/
    @AuraEnabled public static List<String> fetchTitles(ID releaseID) {
        
        system.debug('fetchTitles called with ID>>' + releaseID);
        list<string> titleList;
        titleList = new list<string>();
        
        list<digital_release__c> digiReleaseList = [select id, Order_of_Titles__c from digital_release__c where id  = : releaseID limit 1];
        if(digiReleaseList!=null && digiReleaseList.size()>0){
        	if(string.isNotEmpty(digiReleaseList[0].Order_of_Titles__c)){
        		titleList = digiReleaseList[0].Order_of_Titles__c.split('\r\n');
	            System.debug('titles' + titleList);
	            return titleList;
        	}          
        }
              
        return titleList;
    }   
    
    
    /***********************************
    Method Name: getProductUser
    Purpose: method to get product user
    ***********************************/
    @AuraEnabled public static boolean getProductUser() {
        
        User u = [Select id, name, Profile.Name from User where ID =: userinfo.getUserID()];
        
        if (u != null && (u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER || u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN)) {
            return false;
        }
        else {
            return true;
        }
    }
    
    
    
 /***********************************
    Method Name: searchTitles
    Purpose: method to search for matching Titles from Title Object
    ***********************************/
    
    @AuraEnabled public static List<String> searchTitles(String searchKeyWord) {
        try {
            
            //storing search key word in a variable
            String searchKey = '%' + searchKeyWord + '%';
            List<string> matchingTitles =  new list<string>();
            
            //querying all matching titles            
            List <Title__c> lstOfTitles = [select id, name from Title__c where Name LIKE: searchKey OR Tags__c LIKE : searchKey limit 5000];
                        
            //if list not empty        
            if (!lstOfTitles.isEmpty()) {
                
                //looping over title details
                for (Title__c title : lstOfTitles) {
                	                    
                     matchingTitles.add(title.name);
                }        
            }
            
            //returning the list of records
            return matchingTitles;  
        }
        catch (exception ex) {   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }    
    }    
    
    
    @AuraEnabled 
    public static string updateTitles(ID releaseID , List<String> finalOrder) {
        system.debug('---->'+releaseID+'-----List---->'+finalOrder);
        String message = '';
        if(releaseID != null){
             message = 'sucess!';
            digital_release__c updateRelease = [select id, Order_of_Titles__c from digital_release__c where id  = : releaseID limit 1];
            String orderTitle = '';
            if(finalOrder.size() > 0){
            	for(String mystr : finalOrder ){
                	orderTitle += mystr+'\r\n';
            	}
            }            
            updateRelease.Order_of_Titles__c = orderTitle;
            try{
               update updateRelease; 
            }catch(System.DMLException e){}
        } 
        return message;
    }
}