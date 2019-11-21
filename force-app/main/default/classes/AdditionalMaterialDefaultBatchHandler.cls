/*****************************************************************************************
Class Name: AdditionalMaterialDefaultBatchHandler 
Purpose: Apex class for handling batch material defaulting on title default deal update.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/10/2017           Suman Kundu              Initial Development
******************************************************************************************/
global class AdditionalMaterialDefaultBatchHandler implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> processingMaterialIds; 
    // Parameterized constructor.
    global AdditionalMaterialDefaultBatchHandler(Set<Id> processingMaterialIds) {
        this.processingMaterialIds = processingMaterialIds;
    }
    
    // Interface start method to grab total context list.
    global List<SObject> start(Database.BatchableContext info) { 
        return fetchContextData();
    }
    
    // Interface execute method to perform actual operation.
    global void execute(Database.BatchableContext info, List<Material__c> scope) {
        DefaultingHandler.processingMaterials = scope;
        DefaultingHandler.isExecutingAdditionalDefaulting = true;
        DefaultingHandler.fetchCompleteDefaultData();
        
        try {
            //populating default for material record
            DefaultingHandler.populateMaterialAdditionalDefaultValues();
            
            //populating default for sales record
            DefaultingHandler.populateSalesAdditionalDefaultValues();
            
            //populating default for plant record
            DefaultingHandler.populatePlantAdditionalDefaultValues();
            
            //populating default for classification
            DefaultingHandler.populateClassificationAdditionalDefaultValues();
            
            //populating default for alternative unit of measure
            DefaultingHandler.populateAUoMAdditionalDefaultValues();
            
            //populating default for valuation
            DefaultingHandler.populateValuationAdditionalDefaultValues();
        }
        catch(Exception ex) {
            System.debug('Exception:: '+ex.getMessage());
        }
        finally {
            // Switching ON execute validation rule flag. // Changed for Deal
            Execute_Material_Validation_Rule__c ins = Execute_Material_Validation_Rule__c.getOrgDefaults();
            ins.Execute_Rule__c = true;
            update ins;
        }
    }
    
    // Method handles the after batch process activity.
    global void finish(Database.BatchableContext info) {
        
    }
    
    // Following method prepares and returns query. 
    private List<Material__c> fetchContextData() {
        String query = 'SELECT ';
        Integer i = 0;
        Set<Id> matIds = processingMaterialIds;
        Set<String> fieldSet = new Set<String>();
        for (Schema.SObjectField fld : Schema.getGlobalDescribe().get('Material__c').getDescribe().fields.getMap().values()) {
            if (fld.getDescribe().isAccessible()) {
                if (i ++ > 0) {
                    query += ',';
                }
                query += fld.getDescribe().getName();
                fieldSet.add(fld.getDescribe().getName());
            }
        }
        if (!fieldSet.contains('TM_Version_Lookup__c') && !fieldSet.contains('tm_version_lookup__c')) {
            query += ',TM_Version_Lookup__c';
        }
        query += ' FROM Material__c WHERE Id IN :matIds';
        return Database.query(query);
    }
}