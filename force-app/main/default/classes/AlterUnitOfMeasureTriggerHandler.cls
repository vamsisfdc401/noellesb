/*****************************************************************************************
Class Name: AlterUnitOfMeasureTriggerHandler
Purpose: Sales Trigger handler class to handle logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/09/2016                                    Initial Development
******************************************************************************************/
public class AlterUnitOfMeasureTriggerHandler
{
    private static String uProfileName;
    
    // Defining Static Constructor
    static
    {
        if(TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
    }
    
    // Following method handles Before Insert event.
    public static void executeOnBeforeInsert()
    {
       Set<Id> matIds = new Set<Id>();
       for(Alternative_Unit_of_Measure__c ins : (List<Alternative_Unit_of_Measure__c>)Trigger.New)
       {
           if(ins.Material__c != null)
               matIds.add(ins.Material__c);
       }
       
       Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, RecordTypeId, Weight_Unit__c, Gross_Weight__c, Net_Weight__c, 
                                                                    Original_Material_Number__c, Original_Material_Number__r.Material_Status__c
                                                                    FROM Material__c WHERE Id IN :matIds]);
       Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
       
       // Iterating over Alternative Unit of Measure
       for(Alternative_Unit_of_Measure__c ins : (List<Alternative_Unit_of_Measure__c>)Trigger.New)
       {
          if(uProfileName == 'Platform API'){
              ins.Function__c = '023';
           }
          else
          {
           if((ins.Function__c == null || ins.Function__c.trim() == '') && 
              ins.Material__c != null && materialMap.get(ins.Material__c).RecordTypeId == recTypeId && materialMap.get(ins.Material__c).Original_Material_Number__c != null)
           {
               if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Processed in SAP')
                   ins.Function__c = '004';
               else if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Sent to SAP' ||
                       materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'SAP Error')
               {
                   ins.Function__c = '004';
               }
           }
           else if(ins.Function__c == null || ins.Function__c.trim() == '')
               ins.Function__c = '009';
               
           if(ins.Alternative_Unit_of_Measure__c=='EA - Each' && ins.Material__c != null && materialMap.get(ins.Material__c).Weight_Unit__c != null) 
              ins.Weight_Unit__c =  materialMap.get(ins.Material__c).Weight_Unit__c;
           if(ins.Alternative_Unit_of_Measure__c=='EA - Each' && ins.Material__c != null && materialMap.get(ins.Material__c).Gross_Weight__c != null) 
              ins.Gross_Weight__c =  materialMap.get(ins.Material__c).Gross_Weight__c;
           if(ins.Alternative_Unit_of_Measure__c=='EA - Each' && ins.Material__c != null && materialMap.get(ins.Material__c).Net_Weight__c != null) 
              ins.Net_Weight__c =  materialMap.get(ins.Material__c).Net_Weight__c ;          
          }     
       }
       
       // Checking for NON Platform API User.
       if(userinfo.getProfileId()!=system.label.ProfileId_Platform_API){
            List<Alternative_Unit_of_Measure__c> allRelatedAlternateUnitfMeasures = new List<Alternative_Unit_of_Measure__c>();
            
            List<Id> allMasterMaterialIds = new List<Id>();
        
            for(Alternative_Unit_of_Measure__c altUnitOfMeasure : (List<Alternative_Unit_of_Measure__c>)Trigger.New){
                if(altUnitOfMeasure.Alternative_Unit_of_Measure__c!=NULL && altUnitOfMeasure.Material__c!=NULL){
                    allMasterMaterialIds.add(altUnitOfMeasure.Material__c);
                }
            }  
            allRelatedAlternateUnitfMeasures = [Select id,Alternative_Unit_of_Measure__c,Material__c from Alternative_Unit_of_Measure__c where Material__c IN :allMasterMaterialIds];     
            
            
            for(Alternative_Unit_of_Measure__c currentUnitOfMeasure : (List<Alternative_Unit_of_Measure__c>)Trigger.New){
                if(currentUnitOfMeasure.Alternative_Unit_of_Measure__c!=NULL && currentUnitOfMeasure.Material__c!=NULL){
                 for(Alternative_Unit_of_Measure__c relatedUnitOfMeasure : allRelatedAlternateUnitfMeasures ){
                     if(relatedUnitOfMeasure.id != currentUnitOfMeasure.id && relatedUnitOfMeasure.Alternative_Unit_of_Measure__c != NULL && currentUnitOfMeasure.Alternative_Unit_of_Measure__c == relatedUnitOfMeasure.Alternative_Unit_of_Measure__c &&
                        relatedUnitOfMeasure.Material__c == currentUnitOfMeasure.Material__c){
                        currentUnitOfMeasure.addError('A single material may not have two of the same alternative units of measure.');
                     }
                 }
                }
            }       
        }
    }
    
    // Following method handles Before Update event.
    public static void executeOnBeforeUpdate()
    {
        for(Alternative_Unit_of_Measure__c ins : (List<Alternative_Unit_of_Measure__c>)Trigger.New)
        {
           if(uProfileName == 'Platform API'){
              ins.Function__c = '023';
           }
           else
           {
              if(ins.Function__c == '023')
                ins.Function__c = '004';
              if(ins.Deletion_Flag__c)
                ins.Function__c = '003';
           }      
        }
        
        // Checking Platform API user.
        if(userinfo.getProfileId()!=system.label.ProfileId_Platform_API){
            List<Alternative_Unit_of_Measure__c> allRelatedAlternateUnitfMeasures = new List<Alternative_Unit_of_Measure__c>();
            
            List<Id> allMasterMaterialIds = new List<Id>();
        
            for(Alternative_Unit_of_Measure__c altUnitOfMeasure : (List<Alternative_Unit_of_Measure__c>)Trigger.New){
                if(altUnitOfMeasure.Alternative_Unit_of_Measure__c!=NULL && altUnitOfMeasure.Material__c!=NULL){
                    allMasterMaterialIds.add(altUnitOfMeasure.Material__c);
                }
            }  
            allRelatedAlternateUnitfMeasures = [Select id,Alternative_Unit_of_Measure__c,Material__c from Alternative_Unit_of_Measure__c where Material__c IN :allMasterMaterialIds];     
            
            // Iterating over AUoM objects
            for(Alternative_Unit_of_Measure__c currentUnitOfMeasure : (List<Alternative_Unit_of_Measure__c>)Trigger.New){
                if(currentUnitOfMeasure.Alternative_Unit_of_Measure__c!=NULL && currentUnitOfMeasure.Material__c!=NULL){
                 for(Alternative_Unit_of_Measure__c relatedUnitOfMeasure : allRelatedAlternateUnitfMeasures ){
                     if(relatedUnitOfMeasure.id!=currentUnitOfMeasure.id && relatedUnitOfMeasure.Alternative_Unit_of_Measure__c!=NULL && currentUnitOfMeasure.Alternative_Unit_of_Measure__c==relatedUnitOfMeasure.Alternative_Unit_of_Measure__c &&
                        relatedUnitOfMeasure.Material__c == currentUnitOfMeasure.Material__c){
                        currentUnitOfMeasure.addError('A single material may not have two of the same alternative units of measure.');
                     }
                 }
                }
            }       
        }
    }
    
    // Following method handles After Update event. USST-2955
    public static void executeOnAfterUpdate() {
        Alternative_Unit_of_Measure__c oldAuom;
        List<Plant__c> lstPlant = new List<Plant__c>();
        List<Plant__c> lstUpdtPlant = new List<Plant__c>();
        List<String> validPlants = new List<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES'};
         
        for (Alternative_Unit_of_Measure__c auom : (List<Alternative_Unit_of_Measure__c>)Trigger.New) {
            oldAuom = (Alternative_Unit_of_Measure__c)Trigger.oldMap.get(auom.Id);
            if (auom.Alternative_Unit_of_Measure__c == 'CAR - US Carton' && auom.Numerator_Conversion__c != oldAuom.Numerator_Conversion__c) {
                lstPlant = [Select Id, Rounding_Value__c from Plant__c where Material__c =: auom.Material__c and Plant__c IN: validPlants];
                if (lstPlant.size() > 0) {
                    for (Plant__c plant : lstPlant) {
                        plant.Rounding_Value__c = Decimal.valueOf(auom.Numerator_Conversion__c);
                        lstUpdtPlant.add(plant);
                    }
                }
            }
            else if (auom.Alternative_Unit_of_Measure__c == 'CCC - Canadian Carton Cnt' && auom.Numerator_Conversion__c != oldAuom.Numerator_Conversion__c  ) {
                lstPlant = [Select Id, Rounding_Value__c from Plant__c where Material__c =: auom.Material__c and Plant__c = 'V850 - Technicolor Canada'];
                system.debug('lstPlant :: '+lstPlant);
                if (lstPlant.size() > 0) {
                    for (Plant__c plant : lstPlant) {
                        plant.Rounding_Value__c = Decimal.valueOf(auom.Numerator_Conversion__c);
                        lstUpdtPlant.add(plant);
                    }
                }
            }
        }
        system.debug('lstUpdtPlant :: '+lstUpdtPlant);
        if (lstUpdtPlant.size() > 0) {
            system.debug('lstUpdtPlant :: '+lstUpdtPlant);
            update lstUpdtPlant;
        }
    }
}