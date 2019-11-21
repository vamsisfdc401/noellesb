/*****************************************************************************************
Class Name: AdditionalConstirantHelper
Purpose: Apex class for Handling defaulting logic for additional fields.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             13/09/2016           Pawel                    Initial Development
******************************************************************************************/
public with sharing class AdditionalConstirantHelper {
    
    private static List<String> metadataFields;
    private static Map<Id, Set<String>> metadataProcessed = new Map<Id, Set<String>>();
    private static Map<String, Map<String, Map<String, SearchNode>>> fieldSearchNodeMap = new Map<String, Map<String, Map<String, SearchNode>>>();
    private static Map<String, Set<String>> fieldRequiredConstraints = new Map<String, Set<String>>();
    private static Map<String, List<String>> fieldConstraintsOrderMap = new Map<String, List<String>>();
    private static Map<String, Set<String>> fieldConstraintsWithSpecialCriteriaMap = new Map<String, Set<String>>();
    private static List<String> constiantFiledList;
    private static Set<String> exculdingFieldSet = new Set<String> {'Value__c','Priorty__c'};
    private static Map<String, List<DefaultAdditionalConstirant__mdt>> fieldConstraintMap = new Map<String, List<DefaultAdditionalConstirant__mdt>>();
    private static String query;
    // This set keeps track of all the fields that has already maintained in tree for a metadata.
    private static Set<String> searchedFields;
    private static Boolean isElseCondition = false;
    
    private class SearchNode
    {
        // Map to store metadata field => field value to compare => search node.
        Map<String, Map<String, SearchNode>> searchNodeMap = new Map<String, Map<String, SearchNode>>();
        // If no more criteria field found, metadata value will be stored in below field.
        String value;
    }
    
    /************************************
    Method Name: AdditionalConstirantHelper
    Purpose:static constructor
    *************************************/ 
    static {
        Long startTime = DateTime.now().getTime();
        query = 'SELECT ';
        Integer i = 0;
        constiantFiledList = new List<String> ();
        searchedFields = new Set<String>();
        metadataFields = new List<String>{'Material_Type__c', 'Item_Type__c', 'Item_Code__c', 'Component_Type__c', 'Format__c', 'Format_Description__c', 'Territory__c', 'Label_Code__c', 'Brand_Group__c', 'Project_Type__c', 'Aspect_Ratio__c', 'Plant__c', 'Old_Material_No__c', 'Selection_Reference_Number__c', 'Title_Source__c', 'Checking_Else__c'};
        
        // Building query to fetch all relevant defaulting setup.
        for(Schema.SObjectField fldSchema : Schema.getGlobalDescribe().get('DefaultAdditionalConstirant__mdt').getDescribe().fields.getMap().values()){
             Schema.DescribeFieldResult fld = fldSchema.getDescribe();  
             String fieldName = fld.getName();
             if(fld.isCustom() ){
                
                if(!exculdingFieldSet.contains(fieldName)){ 
                    constiantFiledList.add(fieldName);
                }
                if(i ++ > 0){
                     query += ',';    
                }
                query += fieldName;
            }
        }
        
        query += ', MasterLabel FROM DefaultAdditionalConstirant__mdt ORDER BY MasterLabel, Priorty__c ASC';
        
        // Querying and preparing data setup.
        for(DefaultAdditionalConstirant__mdt consMdt : Database.query(query))
        {
            if(!fieldSearchNodeMap.containsKey(consMdt.MasterLabel))
            {
                fieldSearchNodeMap.put(consMdt.MasterLabel, new Map<String, Map<String, SearchNode>>());
                fieldRequiredConstraints.put(consMdt.MasterLabel, new Set<String>());
                fieldConstraintsWithSpecialCriteriaMap.put(consMdt.MasterLabel, new Set<String>());
            }
            
            Set<String> fieldsHavingValue = getNotNulValuesForConstraints(consMdt);
            //System.debug('=====fieldsHavingValue> '+fieldsHavingValue);
            if(!fieldsHavingValue.isEmpty())
            {
                fieldRequiredConstraints.get(consMdt.MasterLabel).addAll(fieldsHavingValue);
                searchedFields.clear();
                getNodeTree(consMdt, fieldsHavingValue, 0, fieldSearchNodeMap.get(consMdt.MasterLabel), fieldConstraintsWithSpecialCriteriaMap.get(consMdt.MasterLabel));
            }
        }
        
        // Need to put required contraints for each field in reverse order as it should execute.
        for(String opField : fieldRequiredConstraints.keySet())
        {
            fieldConstraintsOrderMap.put(opField, new List<String>());
            Set<String> requiredConstraints = fieldRequiredConstraints.get(opField);
            for(Integer j = (metadataFields.size() - 1); j >= 0; j --)
            {
                if(metadataFields[j].equalsIgnoreCase('Checking_Else__c'))
                    continue;
                if(requiredConstraints.contains(metadataFields[j].toLowerCase()))
                    fieldConstraintsOrderMap.get(opField).add(metadataFields[j]);
            }
            
            if(requiredConstraints.contains('checking_else__c'))
                fieldConstraintsOrderMap.get(opField).add('Checking_Else__c');
        }
        fieldRequiredConstraints.clear();
        
        Long endTime = DateTime.now().getTime();
        String fld = 'Standard_Price__c';    //Material_Group_3__c  Material_Pricing_Group__c(fix) Tax_Indicator__c(only Territory dependent)
        System.debug('=====>'+fld+' :: '+JSON.serialize(fieldSearchNodeMap.get(fld)));
        System.debug('=====>'+fld+' :: '+fieldConstraintsOrderMap.get(fld));
        System.debug('******Total Time> '+(endTime - startTime)+'ms');
    }
    
    // Following method builds the Node Tree from a metadata. 
    private static void getNodeTree(DefaultAdditionalConstirant__mdt consMdt, Set<String> fieldsHavingValue, 
                                    Integer processedIndex, Map<String, Map<String, SearchNode>> executingFieldNode, 
                                    Set<String> spclCriterialFields)
    {
        if(executingFieldNode == null)
            executingFieldNode = new Map<String, Map<String, SearchNode>>();
        
        // Iterate over all metadata fields sequencally.
        for(Integer i = processedIndex; i < metadataFields.size(); )
        {
            // Executing criteria field.
            String metadataField = metadataFields[i].toLowerCase();
            
            // If current field is one of the criteria in current metadata.
            if(fieldsHavingValue.contains(metadataField))
            {
                searchedFields.add(metadataField);
                
                if(!executingFieldNode.containsKey(metadataField))
                    executingFieldNode.put(metadataField, new Map<String, SearchNode>());
                
                String criteriaValue = String.valueOf(consMdt.get(metadataField));
                if(!executingFieldNode.get(metadataField).containsKey(criteriaValue))
                    executingFieldNode.get(metadataField).put(criteriaValue, new SearchNode());
                
                // If criteria value is having special criteria, put it in map.
                if(criteriaValue == 'CHECK_EMPTY' || criteriaValue == 'CHECK_NOT_EMPTY')
                    spclCriterialFields.add(metadataField.toLowerCase());
                
                // If search is complete for all constraint fields.
                if(searchedFields.containsAll(fieldsHavingValue))
                {
                    // Build searchNode with value
                    executingFieldNode.get(metadataField).get(criteriaValue).value = consMdt.Value__c;
                }
                else
                {
                    // Call recursively to populate other fields.
                    getNodeTree(consMdt, fieldsHavingValue, (i + 1), executingFieldNode.get(metadataField).get(criteriaValue).searchNodeMap, spclCriterialFields);
                    break;
                }
            }
            
            i ++;
        }
    }

    private static Set<String> fieldsInObject;
    // Iterates recursively to fetch the value from tree.
    private static String getValueFromDataTree(SObject sobj, String fieldApi, String territory, 
                                               Map<String, Map<String, SearchNode>> executingFieldNode, Set<String> spclCriterialFields)
    {
        // Iterate constraint fields in backward direction.
        for(String contraintField : fieldConstraintsOrderMap.get(fieldApi))
        {
            //System.debug('-----> '+contraintField+' :: '+executingFieldNode.keySet()+' :: '+fieldsInObject);
            if(executingFieldNode.containsKey(contraintField.toLowerCase()))
            {
                // Checks if field is in sobject field list and field doesnot have special criteria.
                if(fieldsInObject.contains(contraintField.toLowerCase()) && !spclCriterialFields.contains(contraintField.toLowerCase()))
                {
                    Object recordFldVal = sobj.get(contraintField.toLowerCase());
                    // Non territory fields.
                    if(!contraintField.equalsIgnoreCase('Territory__c') && recordFldVal != null && 
                       executingFieldNode.get(contraintField.toLowerCase()).containsKey(String.valueOf(recordFldVal)))
                    {
                        SearchNode cNode = executingFieldNode.get(contraintField.toLowerCase()).get(String.valueOf(recordFldVal));
                        // If node has some chain, continue the flow.
                        if(cNode.searchNodeMap != null && cNode.searchNodeMap.size() > 0)
                        {
                            String val = getValueFromDataTree(sobj, fieldApi, territory, cNode.searchNodeMap, spclCriterialFields);
                            // If child chain found value.
                            if(val != null)
                                return val;
                            // If no value comes back.
                            else if(cNode.value != null)
                                return cNode.value;
                        }
                        // If there is no chain left.
                        else if(cNode.value != null)
                            return cNode.value;
                    }
                    // Handle territory specially.
                    else if(contraintField.equalsIgnoreCase('Territory__c') && 
                            ((territory == null && recordFldVal != null && 
                              executingFieldNode.get(contraintField.toLowerCase()).containsKey(String.valueOf(recordFldVal))) || 
                             (territory != null && executingFieldNode.get(contraintField.toLowerCase()).containsKey(territory))))
                    {
                        SearchNode cNode;
                        if(territory == null)
                            cNode = executingFieldNode.get(contraintField.toLowerCase()).get(String.valueOf(recordFldVal));
                        else
                            cNode = executingFieldNode.get(contraintField.toLowerCase()).get(territory);
                        
                        // If node has some chain, continue the flow.
                        if(cNode.searchNodeMap != null && cNode.searchNodeMap.size() > 0)
                        {
                            String val = getValueFromDataTree(sobj, fieldApi, territory, cNode.searchNodeMap, spclCriterialFields);
                            // If child chain found value.
                            if(val != null)
                                return val;
                            // If no value comes back.
                            else if(cNode.value != null)
                                return cNode.value;
                        }
                        // If there is no chain left.
                        else if(cNode.value != null)
                            return cNode.value;
                    }
                    
                    continue;
                }
                
                // If constraint has value like check empty or not empty.
                for(String consValue : executingFieldNode.get(contraintField.toLowerCase()).keySet())
                {
                    // If record satisfies contraint criteria. 
                    if(validateConstraintValue(contraintField, consValue, (fieldsInObject.contains(contraintField.toLowerCase()) ? sobj.get(contraintField.toLowerCase()) : null), territory))
                    {
                        SearchNode cNode = executingFieldNode.get(contraintField.toLowerCase()).get(consValue);
                        if(cNode.searchNodeMap != null && cNode.searchNodeMap.size() > 0)
                        {
                            String val = getValueFromDataTree(sobj, fieldApi, territory, cNode.searchNodeMap, spclCriterialFields);
                            if(val != null)
                                return val;
                            else if(cNode.value != null)
                                return cNode.value;
                        }
                        else if(cNode.value != null)
                            return cNode.value;
                    }
                }
            }
        }
        
        return null;
    }
    
    // Validate constraint value with object value.
    private static Boolean validateConstraintValue(String consField, Object consValue, Object recordFieldValue, String territory)
    {
        System.debug('***** Validate> '+consField+' :: '+consValue+' :: '+recordFieldValue);
        if(!consField.equalsIgnoreCase('Checking_Else__c') && !consField.equalsIgnoreCase('Territory__c') &&
           consValue != null && !String.valueOf(consValue).equalsIgnoreCase('CHECK_EMPTY') && 
           !String.valueOf(consValue).equalsIgnoreCase('CHECK_NOT_EMPTY'))
        {
            if(fieldsInObject.contains(consField.toLowerCase()) && consValue == recordFieldValue)
            {
                return true;
            }
        }
        else if(consValue != null && String.valueOf(consValue).equalsIgnoreCase('CHECK_EMPTY') && 
                fieldsInObject.contains(consField.toLowerCase()) && recordFieldValue == null)
        {
            System.debug('****coming empty');
            return true;
        }
        else if(consValue != null && String.valueOf(consValue).equalsIgnoreCase('CHECK_NOT_EMPTY') && 
                fieldsInObject.contains(consField.toLowerCase()) && recordFieldValue != null)
        {
            System.debug('****coming non-empty');
            return true;
        }
        else if(consField.equalsIgnoreCase('Checking_Else__c') && Boolean.valueOf(consValue))
        {
            isElseCondition = true;
            return true;
        }
        else if((territory == null && consField.equalsIgnoreCase('Territory__c') && consValue != null && fieldsInObject.contains(consField.toLowerCase()) &&
                recordFieldValue != null && String.valueOf(recordFieldValue).containsIgnoreCase(String.valueOf(consValue))) || 
                (territory != null && territory.equalsIgnoreCase(String.valueOf(consValue))))
        {
            return true;
        }
        
        return false;
    }
    
    /************************************
    Method Name: getConstirantValue
    Purpose:Below method is called from Defaulting Handler class to get the value for a given field when it satisfies other constraint.
    *************************************/ 
    public static String getConstirantValue(SObject sobj, String consColoumn, String territory)
    {
        System.debug('*****consColoumn> '+consColoumn);
        if(!fieldSearchNodeMap.containsKey(consColoumn))
            return null;
        
        fieldsInObject = Schema.getGlobalDescribe().get(String.valueOf(sobj.getsObjectType())).getDescribe().fields.getMap().keySet();
        isElseCondition = false;
        
        Long startTime = DateTime.now().getTime();
        String retVal = getValueFromDataTree(sobj, consColoumn, territory, fieldSearchNodeMap.get(consColoumn), fieldConstraintsWithSpecialCriteriaMap.get(consColoumn));
        Long endTime = DateTime.now().getTime();
        System.debug('****** Total Execution Time> '+(endTime - startTime)+'ms');
        
        return retVal;
    }

    /************************************
    Method Name: getNotNulValuesForConstraints
    Purpose: Following method fetches out the contraint fields need to be checked.
    *************************************/
    private static Set<String> getNotNulValuesForConstraints(DefaultAdditionalConstirant__mdt mdt) {
        Set<String> valueCheckList = new Set<String>();
        for(String consField:constiantFiledList) {

            if(mdt.get(consField) != null){
                if(consField.equalsIgnoreCase('Checking_Else__c') && Boolean.valueOf(mdt.get(consField)))
                    valueCheckList.add(consField.toLowerCase());
                else if(!consField.equalsIgnoreCase('Checking_Else__c'))
                    valueCheckList.add(consField.toLowerCase());
            }
        }
        return valueCheckList;
    }

}