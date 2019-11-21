public without sharing class MaterialUtility{

    public static List<Material__c> getAllMats(Set<string> setNewMatName){
        return [Select id from Material__c where Name in:setNewMatName and Material_Status__c != 'Sent Back']; //added sent back status for usst-2386
    }
    
}