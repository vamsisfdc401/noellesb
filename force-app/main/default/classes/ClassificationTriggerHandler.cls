/*****************************************************************************************
Trigger Name: ClassificationTriggerHandler
Purpose: Trigger handling business logic for Classification
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             30/09/2016                                    Initial Development
******************************************************************************************/
public class ClassificationTriggerHandler
{
    private static String uProfileName;
    
    // Static constructor
    static
    {
        if(TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
    }
    
    // Handles before insert event
    public static void executeOnBeforeInsert()
    {
        Set<Id> matIds = new Set<Id>();
       for(Classification__c ins : (List<Classification__c>)Trigger.New)
       {
           if(ins.Material__c != null)
               matIds.add(ins.Material__c);
       }
       
       Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, RecordTypeId, Weight_Unit__c, Gross_Weight__c, Net_Weight__c, 
                                                                    Original_Material_Number__c, Original_Material_Number__r.Material_Status__c 
                                                                    FROM Material__c WHERE Id IN :matIds]);
       Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
    
        if(uProfileName == 'Platform API'){
            for(Classification__c each : (List<Classification__c>)Trigger.New)
            {       
                each.Function__c = '023';
            }
        }
        else
        // Checking for platform user login.
        //if(userinfo.getProfileId()!=system.label.ProfileId_Platform_API)
        {
            List<Classification__c> allRelatedClassifications = new List<Classification__c>();
                    
            List<Id> allMasterMaterialIds = new List<Id>();
        
            for(Classification__c classification : (List<Classification__c>)Trigger.New){
                
                if((classification.Function__c == null || classification.Function__c.trim() == '') &&
                   classification.Material__c != null && materialMap.get(classification.Material__c).RecordTypeId == recTypeId && materialMap.get(classification.Material__c).Original_Material_Number__c != null)
                {
                     if(materialMap.get(classification.Material__c).Original_Material_Number__r.Material_Status__c == 'Processed in SAP')
                         classification.Function__c = '004';
                     else if(materialMap.get(classification.Material__c).Original_Material_Number__r.Material_Status__c == 'Sent to SAP' ||
                             materialMap.get(classification.Material__c).Original_Material_Number__r.Material_Status__c == 'SAP Error')
                     {
                         /*if(classification.Classification_Key__c != null)
                             classification.Function__c = '004';
                         else
                             classification.Function__c = '009';*/
                         classification.Function__c = '004';
                     }
                }
                else if(classification.Function__c == null || classification.Function__c.trim() == '')
                    classification.Function__c = '009';
                
                if(classification.Material__c!=NULL && classification.RecordTypeID!=NULL)
                {
                    allMasterMaterialIds.add(classification.Material__c);
                }
            }  
            if (allMasterMaterialIds.size() > 0) { //Added for 101 error 04/10/2018
                allRelatedClassifications = [Select id,RecordTypeID,Territory__c,Material__c from Classification__c where Material__c IN :allMasterMaterialIds]; 
                system.debug('allRelatedClassifications=== '+Trigger.New.size() + ' :: ' +allRelatedClassifications);    
            }
            Id classficationRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
                   
            for(Classification__c currentClassification : (List<Classification__c>)Trigger.New){
             if(currentClassification.RecordTypeID!=NULL && currentClassification.Material__c!=NULL){
                 if (allRelatedClassifications.size() > 0) { //Added for 101 error 04/10/2018
                     for(Classification__c relatedClassification : allRelatedClassifications ){
                         if(currentClassification.RecordTypeID == classficationRecordTypeId){
                          continue;
                           // currentClassification.addError('A single material may not have two of the same classification assignments.');
                         }
                         system.debug('relatedClassification=== '+relatedClassification); 
                         system.debug('currentClassification=== '+currentClassification);    
                         if(relatedClassification.id != currentClassification.id && relatedClassification.RecordTypeID != NULL && currentClassification.RecordTypeID == relatedClassification.RecordTypeID && 
                            relatedClassification.Material__c == currentClassification.Material__c){
                            system.debug('inside if');
                            currentClassification.addError('A single material may not have two of the same classification assignments.');
                         }
                     }
                 }
             }
            }       
        }
    }
    
    // Handles before update event
    public static void executeOnBeforeUpdate()
    {
    
        // Checking for platform user and updating the function on classification.
        if(uProfileName == 'Platform API'){
            for(Classification__c each : (List<Classification__c>)Trigger.New)
            {       
                each.Function__c = '023';
            }
        }
        else
        // Checking for not to be platform user.
        //if(userinfo.getProfileId()!=system.label.ProfileId_Platform_API)
        {
            List<Classification__c> allRelatedClassifications = new List<Classification__c>();
                    
            List<Id> allMasterMaterialIds = new List<Id>();
        
            for(Classification__c classification : (List<Classification__c>)Trigger.New){
                if(classification.Material__c!=NULL && classification.RecordTypeID!=NULL){
                    allMasterMaterialIds.add(classification.Material__c);
                }
                if(classification.Function__c == '023')
                    classification.Function__c = '004';
                if(classification.Deletion_Flag__c)
                    classification.Function__c = '003';
            }  
            allRelatedClassifications = [Select id,RecordTypeID,Territory__c,Material__c from Classification__c where Material__c IN :allMasterMaterialIds];     
            Id classficationRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
            
            for(Classification__c currentClassification : (List<Classification__c>)Trigger.New){
             if(currentClassification.RecordTypeID!=NULL && currentClassification.Material__c!=NULL){
                 for(Classification__c relatedClassification : allRelatedClassifications ){
                     if(currentClassification.RecordTypeID == classficationRecordTypeId){
                        continue;              
                         //currentClassification.addError('A single material may not have two of the same classification assignments.');
                     }
                     
                     if(relatedClassification.id != currentClassification.id && relatedClassification.RecordTypeID != NULL && currentClassification.RecordTypeID == relatedClassification.RecordTypeID &&
                        relatedClassification.Material__c == currentClassification.Material__c){
                        currentClassification.addError('A single material may not have two of the same classification assignments.');
                     }
                 }
             }
            }       
        }
    }
    
    // Handles after insert event
    public static void executeOnAfterInsert()
    {
        Map<String, String> aspectRatioTechFormatMap = new Map<String, String>{'AWS' => '03 - ANAMORPHIC WIDESCREEN',
                                                                               'VAR' => '04 - VARIOUS',
                                                                               'WS' => '02 - WIDESCREEN'};
        Map<Id, String> materialTechFormatMap = new Map<Id, String>();
        
        // Iterating over classification context.
        for(Classification__c cls : (List<Classification__c>)Trigger.New)
        {
            if(cls.Material__c != null && !materialTechFormatMap.containsKey(cls.Material__c) && 
               cls.Aspect_Ratio__c != null && aspectRatioTechFormatMap.containsKey(cls.Aspect_Ratio__c))
            {
                materialTechFormatMap.put(cls.Material__c, aspectRatioTechFormatMap.get(cls.Aspect_Ratio__c));
            }
        }
        
        // Changed for REL-103
        if(materialTechFormatMap.size() > 0 && !TriggerUtility.checkFromUpdateMaterial)
        {
            List<Material__c> updateableMaterials = new List<Material__c>();
            for(Id matId : materialTechFormatMap.keySet())
            {
                updateableMaterials.add(new Material__c(Id=matId, Technical_Format__c=materialTechFormatMap.get(matId)));
            }
            
            update updateableMaterials;
        }
    }
    
    // Handles after update event
    public static void executeOnAfterUpdate()
    {
        Map<String, String> aspectRatioTechFormatMap = new Map<String, String>{'AWS' => '03 - ANAMORPHIC WIDESCREEN',
                                                                               'VAR' => '04 - VARIOUS',
                                                                               'WS' => '02 - WIDESCREEN'};
        Map<Id, String> materialTechFormatMap = new Map<Id, String>();
        
        // Iterating over classification context.
        for(Id clsId : Trigger.newMap.keySet())
        {
            Classification__c cls = (Classification__c)Trigger.newMap.get(clsId);
            Classification__c oldCls = (Classification__c)Trigger.oldMap.get(clsId);
            
            if(cls.Aspect_Ratio__c != oldCls.Aspect_Ratio__c &&
               cls.Material__c != null && !materialTechFormatMap.containsKey(cls.Material__c) && 
               cls.Aspect_Ratio__c != null && aspectRatioTechFormatMap.containsKey(cls.Aspect_Ratio__c))
            {
                materialTechFormatMap.put(cls.Material__c, aspectRatioTechFormatMap.get(cls.Aspect_Ratio__c));
            }
        }
        
        // Updating materials. // Changed for REL-103
        if(materialTechFormatMap.size() > 0 && !TriggerUtility.checkFromUpdateMaterial)
        {
            List<Material__c> updateableMaterials = new List<Material__c>();
            for(Id matId : materialTechFormatMap.keySet())
            {
                updateableMaterials.add(new Material__c(Id=matId, Technical_Format__c=materialTechFormatMap.get(matId)));
            }
            
            update updateableMaterials;
        }
    }
}