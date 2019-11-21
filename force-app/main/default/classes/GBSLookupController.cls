/*****************************************************************************************
Class Name: GBSLookupController
Purpose: Apex class for LookupComponent
Version : 1.0
Created Date : 07/30/2018
Created By : Lakshmi Penamatsa
JIRA : GBS-564
******************************************************************************************/
public without sharing class GBSLookupController {

    /********************************************************
    Method Name: searchDB
    Purpose: Method to get the list of productrightsgroup associated to the contract
    Return Type: List<String>
    *********************************************************/ 
    @AuraEnabled 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Text1,
                                  String fld_API_Text2, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText,String contractId){
                                      
        Set<Id> RecentlyViewedPRGRecordIds = new Map<Id, RecentlyViewed>([Select Id From RecentlyViewed Where Type = 'Product_Rights_Group__c']).keyset();
        String query = '';
        String searchFilteredText = searchText;
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
   
                                      
        if(searchText == '\'%%\'') {
            query = 'SELECT '+fld_API_Text+' ,'+fld_API_Text1+' ,'+fld_API_Text2+ ' ,'+fld_API_Val+ 
                ' FROM '+objectName+
                ' WHERE Contract__c =:contractId AND Id IN : RecentlyViewedPRGRecordIds';                                      
        }
         else {
            query = 'SELECT '+fld_API_Text+' ,'+fld_API_Text1+' ,'+fld_API_Text2+ ' ,'+fld_API_Val+ 
                    ' FROM '+objectName+
                    ' WHERE Contract__c =:contractId';
            
        }
               
        List<Product_Rights_Group__c> prgList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();        
        
        for(Product_Rights_Group__c prg : prgList){
            
            if(prg.Name.containsIgnoreCase(searchFilteredText) || 
               prg.Product_Details__c.containsIgnoreCase(searchFilteredText) ||
               prg.IP_Details__c.containsIgnoreCase(searchFilteredText)) {
                
                ResultWrapper obj = new ResultWrapper();
                obj.objName = objectName;
                obj.text = String.valueOf(prg.Name);
                obj.text1 = String.valueOf(prg.Product_Details__c);
                obj.text2 = String.valueOf(prg.IP_Details__c);
                obj.val = String.valueOf(prg.Id);                
                lstRet.add(obj);
            }                             
        }
      
         return JSON.serialize(lstRet) ;
    }
    
     public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String text1{get;set;}
        public String text2{get;set;}
        public String val{get;set;}
    }
}