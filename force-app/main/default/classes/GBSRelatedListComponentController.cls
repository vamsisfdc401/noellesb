public class GBSRelatedListComponentController {
	@AuraEnabled
    public static List<Contract_Agent_Contact__c> getRelatedRecords(String recordId, String parentObjAPIName, String parentFieldAPIName, String childObjectAPIName, String lookupFieldAPINameOnChildObject) {
        Workflow__c workflow = [Select Id, Primary_LMS__r.Contract__c From Workflow__c Where Id =:recordId];
        
        return [Select Id, Contract__c, Contact__c, Contact__r.AccountId, Contact__r.Account.Name, Contact__r.Name, Contact__r.Phone, Contact__r.Email From Contract_Agent_Contact__c Where Contract__c =: workflow.Primary_LMS__r.Contract__c];
        /*
        String parentQuery = 'Select Id, ' + parentFieldAPIName + ' From ' + parentObjAPIName + ' Where Id =: recordId';
        
        system.debug(parentquery);
        List<sObject> parent = database.query(parentQuery);
        
        String query = 'Select Id, Contact__c From ' + childObjectAPIName + ' Where ' + lookupFieldAPINameOnChildObject + ' = \'' + getParentFieldValue(parentFieldAPIName, parent[0]) + '\'';
        system.debug(query);
        
        List<Contract_Agent_Contact__c> relatedChildRecords = (List<Contract_Agent_Contact__c>)database.query(query);
        
        //Schema.SObjectType sObjectType = relatedChildRecords.getSObjectType();
        //String listType = 'List<' + sObjectType + '>';
        //List<SObject> resultSet = (List<SObject>)Type.forName(listType).newInstance();
        //resultSet.addAll(relatedChildRecords);
        
        return relatedChildRecords;*/
    }
    public static String getParentFieldValue(String fieldAPIName, sObject obj) {
        if(fieldAPIName != '' && fieldAPIName != null) {
           	if(!fieldAPIName.contains('.')) // direct field of the object
				return (String)obj.get(fieldAPIName);
            else {
                List<String> fieldLiterals = fieldAPIName.split('\\.');
                system.debug(fieldAPIName);
                system.debug(fieldLiterals);
                sObject fieldValue;
                Integer i = 0;
                while(i != fieldLiterals.size()-1) {
                    fieldValue = obj.getSObject(fieldLiterals[i]);
                    i++;
                }
                return (String)fieldValue.get(fieldLiterals[i]);
            }
        }
        else
            return '';
    } 
}