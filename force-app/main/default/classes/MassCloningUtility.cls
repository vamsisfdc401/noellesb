/*****************************************************************************************
Class Name: MassCloningUtility
Purpose: Apex class used as Mass Material Update utility.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/10/2017           Suman                    Initial Development
******************************************************************************************/
global with sharing class MassCloningUtility {
    // Following method returns material records.
    public static List<Material__c> fetchMaterials(List<String> materialNumberSet) {
        // Grabing the record type id of Material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        
        return [SELECT Id, Material_Number__c, Material_Type__c, Material_Status__c, Name, SGENNO__c, Territory__c, Item_Code__c
                FROM Material__c 
                WHERE Material_Number__c IN: materialNumberSet AND (RecordTypeId!=:recTypeId ) AND Do_Not_Clone__c=false]; //USST-2687
    }
    
    // Following method returns FERT records only. // Added for REL-152
    public static List<Material__c> fetchFERTs(List<String> materialNumberSet, Set<String> targetTerritories) {
        // Grabing the record type id of Material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        
        return [SELECT Id, Material_Number__c, Material_Type__c, Material_Status__c, Name, SGENNO__c, Territory__c, Item_Code__c
                FROM Material__c 
                WHERE Material_Number__c IN: materialNumberSet AND (RecordTypeId!=:recTypeId ) AND Material_Type__c='FERT' AND Territory__c IN :targetTerritories AND Do_Not_Clone__c=false]; //USST-2687
    }
    
    // Following method returns material records.
    public static List<Material__c> fetchMaterialsForCriteria(String searchCriteria) {
        // Grabing the record type id of Material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        System.debug('searchCriteria:'+ searchCriteria);
        String criteria = '%'+searchCriteria+'%';
        return [SELECT Id, Name, SGENNO__c, Material_Number__c, Material_Type__c, Territory__c, Item_Code__c 
                FROM Material__c 
                WHERE (Name LIKE :criteria OR SGENNO__c LIKE :criteria OR Material_Number__c LIKE :criteria) AND (RecordTypeId!=:recTypeId ) AND Do_Not_Clone__c=false Limit 1000]; //Adding Limit 1000 for USST-2657 //USST-2687
    }
    
    // Following method returns FERT material records only. // Added for REL-152
    public static List<Material__c> fetchFERTsForCriteria(String searchCriteria, Set<String> targetTerritories) {
        // Grabing the record type id of Material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        System.debug('searchCriteria:'+ searchCriteria);
        String criteria = '%'+searchCriteria+'%';
        return [SELECT Id, Name, SGENNO__c, Material_Number__c, Material_Type__c, Territory__c, Item_Code__c 
                FROM Material__c 
                WHERE (Name LIKE :criteria OR SGENNO__c LIKE :criteria OR Material_Number__c LIKE :criteria) AND RecordTypeId!=:recTypeId
                    AND Material_Type__c='FERT' AND Territory__c IN :targetTerritories AND Do_Not_Clone__c=false Limit 1000]; //Adding Limit 1000 for USST-2657 //USST-2687
    }
}