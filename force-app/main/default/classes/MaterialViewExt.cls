/*****************************************************************************************
Class Name: MaterialViewExt
Purpose: Apex class for material detail page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/02/2017           Mohit                    Initial Development
******************************************************************************************/
public with sharing class MaterialViewExt {
    
    /*Public variables*/
    public Boolean enablePoller {get;set;}
    
    /*Private variables*/
    private ApexPages.StandardController controller {get; set;}
    private material__c materialDetails; 
    private Boolean isMaterialDefaulted;
    private Boolean isPlantDefaulted;
    private Boolean isSalesDefaulted;
    private Boolean isClassificationDefaulted;
    private Boolean isAUoMDefaulted;
    private Boolean isValuationDefaulted;
    @testVisible private Boolean additionalPoll;
    private ID requestRecordTypeID;
    
    /*****************************************************************
    Method Name: MaterialViewExt
    Purpose : constructor of class
    ***************************************************************/
    public MaterialViewExt(ApexPages.StandardController controller) {        
        //getting material details
        this.controller = controller;
        
        if(!Test.isRunningTest()){
            this.controller.addFields(new List<String>{'Id', 'Name', 'Defaults_Processing__c', 'RecordTypeID', 'Material_Status__c'}); //USST-2764
        }
        this.materialDetails = (Material__c)controller.getRecord();
        
        //setting default value for variables
        isMaterialDefaulted = FALSE; 
        isPlantDefaulted = FALSE;
        isSalesDefaulted = FALSE;
        isClassificationDefaulted = FALSE;
        isAUoMDefaulted = FALSE;
        isValuationDefaulted = FALSE;
        requestRecordTypeID = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        //polling should not work for existing records which are already defaulted
        if(materialDetails.Defaults_Processing__c == FALSE || materialDetails.RecordTypeID != requestRecordTypeID || materialDetails.Material_Status__c == 'Approved' || materialDetails.Material_Status__c == 'Sent to SAP' || materialDetails.Material_Status__c == 'SAP Error' || materialDetails.Material_Status__c == 'Processed in SAP'){ //USST-2764
            additionalPoll = TRUE;
            enablePoller = FALSE;
        }
        else{
            additionalPoll = FALSE;
            enablePoller = TRUE;
        }
        
    }
    
    /*****************************************************************
    Method Name: checkDefaultingCompletion
    Purpose : method to check if defaulting is completed
    ***************************************************************/    
    public void checkDefaultingCompletion(){        
        //checking if polling has to be executed one last time  
        if(!additionalPoll){
            //creating lists for updating records
            List<Sales__c> updateSalesList = new List<Sales__c>();
            List<Plant__c> updatePlantList = new List<Plant__c>();
            List<Classification__c> updateClassificationList = new List<Classification__c>();
            List<Alternative_Unit_of_Measure__c> updateAUoMList = new List<Alternative_Unit_of_Measure__c>();
            List<Valuation__c> updateValuationList = new List<Valuation__c>();
            List<Material__c> updateMaterialList = new List<Material__c>();
            
            try{
                //SOQL for getting material and child view details
                for(Material__c mat : [SELECT Id, Defaulting_Material__c, Defaults_Processing__c,
                                       (SELECT Id,Additional_Default__c FROM Sales__r),
                                       (SELECT Id,Additional_Default__c FROM Plants__r),
                                       (SELECT Id,Additional_Default__c FROM Classifications__r),
                                       (SELECT Id,Additional_Default__c FROM Alternative_Units_of_Measure__r),
                                       (SELECT Id,Additional_Default__c FROM Valuations__r)
                                       FROM Material__c
                                       WHERE Id =:materialDetails.ID])
                {
                    //if material defaulted then creating material instance for update
                    if(mat.Defaulting_Material__c == TRUE){
                        isMaterialDefaulted = TRUE;
                        
                        Material__c mt = new Material__c();
                        mt.id = mat.ID;
                        mt.Defaulting_Material__c = FALSE;
                        mt.Defaults_Processing__c = FALSE;
                        
                        updateMaterialList.add(mt);
                    }
                    
                    //if Sales defaulted then creating Sale instance for update
                    if(mat.Sales__r.size() > 0){ 
                        for(sales__c sales : mat.Sales__r){
                            if(sales.Additional_Default__c == TRUE){
                                Sales__c s = new Sales__c();
                                s.ID = sales.ID;
                                s.Additional_Default__c = FALSE;
                                
                                updateSalesList.add(s);
                                isSalesDefaulted = TRUE;
                            }                                
                        }                
                    }
                    else{
                        isSalesDefaulted = TRUE;
                    }
                    
                    //if plant defaulted then creating plant instance for update
                    if(mat.Plants__r.size() > 0){
                        for(Plant__c plant : mat.Plants__r){
                            if(plant.Additional_Default__c == TRUE){
                                Plant__c p = new Plant__c();
                                p.ID = plant.ID;
                                p.Additional_Default__c = FALSE;
                                
                                updatePlantList.add(p);
                                isPlantDefaulted = TRUE;
                            }
                        }   
                    }
                    else{
                        isPlantDefaulted = TRUE;
                    }
                    
                    //if classification defaulted then creating classification instance for update
                    if(mat.Classifications__r.size() > 0){
                        for(Classification__c classification : mat.Classifications__r){
                            if(classification.Additional_Default__c == TRUE){
                                Classification__c c = new Classification__c();
                                c.ID = classification.ID;
                                c.Additional_Default__c = FALSE;
                                
                                updateClassificationList.add(c);
                                isClassificationDefaulted = TRUE;
                            }
                        }   
                    }
                    else{
                        isClassificationDefaulted = TRUE;
                    }
                    
                    //if alternative unit of measure defaulted then creating alternative unit of measure instance for update
                    if(mat.Alternative_Units_of_Measure__r.size() > 0){
                        for(Alternative_Unit_of_Measure__c auom: mat.Alternative_Units_of_Measure__r){
                            if(auom.Additional_Default__c == TRUE){
                                Alternative_Unit_of_Measure__c a = new Alternative_Unit_of_Measure__c();
                                a.ID = auom.ID;
                                a.Additional_Default__c = FALSE;
                                
                                updateAUoMList.add(a);
                                isAUoMDefaulted = TRUE;
                            }
                        }   
                    }
                    else{
                        isAUoMDefaulted = TRUE;
                    }
                    
                    //if valuation defaulted then creating valuation instance for update
                    if(mat.Valuations__r.size() > 0){
                        for(Valuation__c valuation : mat.Valuations__r){
                            if(valuation.Additional_Default__c == TRUE){
                                Valuation__c v = new Valuation__c();
                                v.ID = valuation.ID;
                                v.Additional_Default__c = FALSE;
                                
                                updateValuationList.add(v);
                                isValuationDefaulted = TRUE;
                            }
                        }   
                    }  
                    else{
                        isValuationDefaulted = TRUE;
                    }
                }
                
                //if all records are defaulted then execute below
                if(isMaterialDefaulted && isSalesDefaulted && isPlantDefaulted && isClassificationDefaulted && isAUoMDefaulted && isValuationDefaulted){
                    //polling one last time to show updated values on page
                    additionalPoll = TRUE;
                    
                    //updating material list 
                    if(!updateMaterialList.isEmpty()){
                        update updateMaterialList;
                    }
                    
                    //updating sales list
                    if(!updateSalesList.isEmpty()){
                        update updateSalesList;
                    }
                    
                    //update plant list
                    if(!updatePlantList.isEmpty()){
                        update updatePlantList;
                    }
                    
                    //update classification list
                    if(!updateClassificationList.isEmpty()){
                        update updateClassificationList;
                    }
                    
                    //update alternative unit of measure list
                    if(!updateAUoMList.isEmpty()){
                        update updateAUoMList;
                    }
                    
                    //update valuation list
                    if(!updateValuationList.isEmpty()){
                        update updateValuationList;
                    }
                }
            }
            catch(exception ex){
                System.Debug('Exception Error '+ex.getMessage());
            }
        }
        else{
            //stop polling
            enablePoller = FALSE;
        }
    }    
}