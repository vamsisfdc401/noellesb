/*****************************************************************************************
Class Name: MaterialTriggerHelper
Purpose: This class helps Material Trigger to find data across the org without maintaining sharing rule.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/02/2017           Suman Kundu              Initial Development
*****************************************************************************************/
public without sharing class MaterialTriggerHelper
{ 
    /***********************************/
    // Method Name: checkDuplicateMaterialUPC
    // Purpose:Checks for Duplicate Material
    /***********************************/
    public static void checkDuplicateMaterialUPC(){
        // Changed for REL-40
        if(TriggerUtility.checkFromCloning || TriggerUtility.checkFromMassCloneIn)
            return;
        
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<string> setMatUPC = new Set<string>();
        List<Material__c> lstDuplicateMaterial = new List<Material__c>();
        Set<String> setDuplicateUPC = new Set<String>();
        
        for(Material__c mat : (List<Material__c>)Trigger.New)
        {
            Material__c oldMat;
            if(Trigger.isUpdate)
                oldMat = (Material__c) Trigger.oldMap.get(mat.Id);
            
            if((Trigger.isInsert && mat.UPC__c != null && mat.UPC__c != '' && mat.RecordTypeID != recTypeId) || 
               (Trigger.isUpdate && mat.UPC__c != oldMat.UPC__c && mat.UPC__c != null && mat.UPC__c != '' && mat.RecordTypeID != recTypeId))
            {
                // Checking in trigger's internal change set
                if(setMatUPC.contains(mat.UPC__c.trim())) {
                    mat.addError('This UPC is already in use: '+mat.UPC__c.trim());                 
                }
                else
                    setMatUPC.add(mat.UPC__c.trim());
            }
        }
        
        System.Debug('@@@check set val '+setMatUPC);
        
        if(!setMatUPC.isEmpty())
        {
            if(Trigger.isInsert)
                lstDuplicateMaterial = [Select id,UPC__c from Material__c where RecordType.Name <> 'Update' and UPC__c in:setMatUPC limit 1000]; //Added record type check for usst-2460
            else if(Trigger.isUpdate)
                lstDuplicateMaterial = [Select id,UPC__c from Material__c where UPC__c in:setMatUPC AND Id NOT IN: Trigger.NewMap.keySet() limit 1000];
            
            if(!lstDuplicateMaterial.isEmpty())
            {
                for(Material__c mat : lstDuplicateMaterial)
                {
                    if(string.valueof(mat.UPC__c) != null && string.valueof(mat.UPC__c)!= '' && !setDuplicateUPC.contains((string.valueof(mat.UPC__c).trim()))){
                        setDuplicateUPC.add((string.valueof(mat.UPC__c).trim()));
                    }
                }
            }
        }
        
        if(!setDuplicateUPC.isEmpty()){
            Trigger.new[0].addError('This UPC is already in use: '+setDuplicateUPC);
        }
    }
    
    /***********************************
    Method Name: checkDuplicateMaterialDescription
    Purpose:Checks for Duplicate Material
    ***********************************/
    public static void checkDuplicateMaterialDescription(){
        // Added for REL-40
        if(TriggerUtility.checkFromMassCloneIn)
            return;
        
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<string> setMatDesc = new Set<string>();
        List<Material__c> lstDuplicateMaterial = new List<Material__c>();
        Set<String> setDuplicateMat = new Set<String>();        
        
        for(Material__c mat : (List<Material__c>)Trigger.New){
            if(mat.RecordTypeID != recTypeId){
                if((Trigger.isInsert && !setMatDesc.contains((string.valueof(mat.Name).trim()))) || (Trigger.isUpdate && !setMatDesc.contains((string.valueof(mat.Name).trim())) && ((Material__c)Trigger.NewMap.get(mat.id)).Name != ((Material__c)Trigger.OldMap.get(mat.id)).Name)){
                    setMatDesc.add(string.valueof(mat.Name).trim());
                }
                else if ((Trigger.isInsert && setMatDesc.contains((string.valueof(mat.Name).trim()))) || (Trigger.isUpdate && setMatDesc.contains((string.valueof(mat.Name).trim())) && ((Material__c)Trigger.NewMap.get(mat.id)).Name != ((Material__c)Trigger.OldMap.get(mat.id)).Name)){
                    setDuplicateMat.add((string.valueof(mat.Name).trim()));
                    system.debug('@@@@mat Name: ' + string.valueof(mat.Name));
                }   
            }                   
        }
        
        if(!setMatDesc.isEmpty()){
            lstDuplicateMaterial = [Select id,name from Material__c where name in:setMatDesc and Material_Status__c != 'Sent Back']; //added sent back status for usst-2386
            
            if(!lstDuplicateMaterial.isEmpty()){
                for(Material__c mat : lstDuplicateMaterial){
                    if(!setDuplicateMat.contains((string.valueof(mat.Name).trim()))){
                        setDuplicateMat.add((string.valueof(mat.Name).trim()));
                        system.debug('@@@@Duplicate Mat: ' + mat.Name);
                    }
                }
            }
        }

        //  Bypass duplicate check in Test mode
        if (!Test.isRunningTest())
            if(!setDuplicateMat.isEmpty()){
                Trigger.new[0].addError('Duplicate material found with description: '+setDuplicateMat);
            }
    }
}