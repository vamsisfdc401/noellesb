/*****************************************************************************************
Class Name: MassMaterialUpdateUtility
Purpose: Apex class used as Mass Material Update utility.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/13/2017           Suman                    Initial Development
******************************************************************************************/
global without sharing class MassMaterialUpdateUtility 
{
    // Following method returns material update requests.
    public static List<Material_Update_Request__c> fetchMaterialRequests(Set<String> materialNumberSet, String status)
    {
        return [SELECT Name, Material_Number__c, Mass_Update_Header__r.Name, Sales_Org__c 
                FROM Material_Update_Request__c 
                WHERE Material_Number__c IN: materialNumberSet AND Request_Status__c=:status AND Mass_Update_Header__r.Status__c='Open'
                ORDER BY Material_Number__c, Sales_Org__c];
    }
    
    // Following method returns material records.
    public static List<Material__c> fetchMaterials(Set<String> materialNumberSet)
    {
        // Grabing the record type id of Material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        // Changed for REL-103
        return [SELECT Id, Material_Number__c, Material_Type__c, Territory__c
                FROM Material__c 
                WHERE Material_Number__c IN: materialNumberSet AND RecordTypeId!=:recTypeId AND Material_Status__c!='Deleted'];
    }
    
    // Following method initiates the Mass Update Material Creating batch job.
    webService static Id initiateMassMaterialBatch(Id headerId) 
    { 
         return Database.executeBatch( new MassUpdateMaterialGenerator(headerId) ); 
    }
}