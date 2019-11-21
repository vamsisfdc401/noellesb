/*****************************************************************************************
Class Name: SetAdditionalDefaults 
Purpose: Apex class to set additonal default values asynchronusly
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/09/2016           Suman/Mohit       Initial Development
******************************************************************************************/
public class SetAdditionalOtherDefaults implements Queueable {

    public List<Material__c> lstMaterial;
    public Set<ID> materialID;
    public Map<Id, String> materialTerritoryMap;
    public Boolean checkFromCloning = FALSE;
    
    /************************************
    Method Name: execute
    Purpose: this method invoked to populate the default fields on material record   
    *************************************/
    
    public void execute(QueueableContext context) {
        
        String query = 'SELECT ';
        Integer i = 0;
        Set<String> fieldSet = new Set<String>();
        for(Schema.SObjectField fld : Schema.getGlobalDescribe().get('Material__c').getDescribe().fields.getMap().values())
        {
            if(fld.getDescribe().isAccessible())
            {
                if(i ++ > 0)
                    query += ','; 
                query += fld.getDescribe().getName();
                fieldSet.add(fld.getDescribe().getName());
            }
        }
        if(!fieldSet.contains('TM_Version_Lookup__c') && !fieldSet.contains('tm_version_lookup__c'))
        {
            query += ',TM_Version_Lookup__c';
        }
        query += ' FROM Material__c WHERE Id IN :materialID';
        System.debug('----Qry> '+query);
        lstMaterial = Database.query(query);
        
        // Assigning cloning state
        TriggerUtility.checkFromCloning = checkFromCloning ;
        
        // If material's territory got changed and this method is called populate only changed territory.
        if(materialTerritoryMap != null && materialTerritoryMap.size() > 0)
        {
            for(Material__c mat : lstMaterial)
            {
                if(materialTerritoryMap.containsKey(mat.Id) && materialTerritoryMap.get(mat.Id) != '')
                {
                    mat.Territory__c = materialTerritoryMap.get(mat.Id);
                }
            }
        }
        
        System.Debug('check material details '+lstMaterial);
        
        DefaultingHandler.processingMaterials = lstMaterial;
        DefaultingHandler.isExecutingAdditionalDefaulting = true;
        DefaultingHandler.fetchCompleteDefaultData();
                        
        //populating default for classification
        DefaultingHandler.populateClassificationAdditionalDefaultValues();
        
        //populating default for alternative unit of measure
        DefaultingHandler.populateAUoMAdditionalDefaultValues();
        
        //populating default for valuation
        DefaultingHandler.populateValuationAdditionalDefaultValues(); 
    }

}