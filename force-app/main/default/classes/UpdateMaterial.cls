/*****************************************************************************************
Class Name: UpdateMaterial 
Purpose: This class is responsible to create a Update material record from existing processed material and also it creates associated child views. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/07/2016           Ipsita                   Initial Development
******************************************************************************************/
public class UpdateMaterial {
    
    List<Material__c> lstExistingMaterial = new List<Material__c>();
    List<Material__c> lstExistingMaterialClone = new List<Material__c>();
    List<BOM_Item__c> bItemList = new List<BOM_Item__c>();
    
    // Extension constructor.
    public updateMaterial(ApexPages.StandardController controller) {
        
    }
    
    // Capturing existing processed material's Id.
    Id recId = ApexPages.currentPage().getParameters().get('id');
    // Grabing the record type id of Update material.
    Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
    
    // Following method is the core one to create the Update material with its associated child.
    public Pagereference cloneRec(){
        // Setting this variable for not to invoke defaulting functionality during Update material creation. 
        TriggerUtility.checkFromUpdateMaterial = TRUE;
        
        // Fetching SOQL query with its all accessible fields.
        String strMaterial = getCreatableFieldsSOQL('Material__c','Id = : recId');
        
        // Querying material record.
        if(strMaterial!=null && strMaterial!=''){
            lstExistingMaterial  = Database.Query(strMaterial);
        }
        
        // If there is a material.
        if(!lstExistingMaterial.isEmpty()){
            // Following code section queries over child BOm Item and preparing a map.
            Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
            for(BOM_Item__c bom : [SELECT Material__c, Material_Component__c,BOM_Function__c,BOM_Integration_State__c,BOM_Item_Node_Number__c,BOM_Item_Number__c,
                                   BOM_Item_Text_1__c,BOM_Item_Text_2__c,BOM_Quantity__c,Call_Approval_Process__c,Component_Number__c,Component_Quantity__c,
                                   Costing_Flag__c,Deletion_Flag__c,Function__c,Item_Category__c,PIR_Created__c,Production_Flag__c,Sales_Flag__c,Material_Number__c,
                                   Territory__c,Unit_of_Measure__c,Usage_Rate__c,Valid_From__c
                                   FROM BOM_Item__c
                                   WHERE Material__c IN :lstExistingMaterial])
            {
                if(!matBomMap.containsKey(bom.Material__c))
                    matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
                matBomMap.get(bom.Material__c).add(bom);
            }
            
            String bomTextRegEx = Label.SpecialCharacters_Regex;
            Pattern MyPattern = Pattern.compile(bomTextRegEx);
            Matcher MyMatcher;
            String message;
            // Iterating over existing material to clone them and furnish with new required values.
            for(Material__c mat : lstExistingMaterial){
                if(mat.Material_Type__c != 'ZDLT' && mat.Material_Type__c != 'ZVSM' && mat.Material_Type__c != 'Episode (HEEP)'){
                    Material__c matCopy = mat.clone(false,true);
                    matCopy.Name = mat.Name;
                    matCopy.Material_Status__c = 'Draft';
                    matCopy.Brand_Group__c = '';
                    matCopy.RecordTypeId = recTypeId;
                    matCopy.Original_Material_Number__c = mat.id;
                    matCopy.Material_Number__c = mat.Material_Number__c;
                    matCopy.BOM_Integration_State__c = '';
                    matCopy.BOM_Function__c = '';
                    matCopy.Function__c = '004';
                    matCopy.Material_Integration_State__c = '';
                    matCopy.OwnerId =userinfo.getUserId();
                    matCopy.Material_Description_Unique__c = '';
                    matCopy.Sub_Label_Code_Lookup__c = mat.Sub_Label_Code_Lookup__c; //USST-2707
                    //Added for fix for Defect DF-02106
                    matCopy.Record_Type_Filter__c = 'Update';
                    //matCopy.Original_release_date__c=mat.original_release_date__c;
                    matCopy.Direct_Update_Request__c = true; //USST-2856
                    
                    if(mat.BOM_Long_Text__c != null){
                        if(MyPattern.matcher(mat.BOM_Long_Text__c).find()){
                            message=mat.BOM_Long_Text__c;
                            matCopy.BOM_Long_Text__c=message.replaceAll(bomTextRegEx, '');
                            
                        }
                    }
                    lstExistingMaterialClone.add(matCopy); 
                }   
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'ZDLT,HEEP or ZVSM Material Type records may only be edited in SAP'));
                    return null;
                }
            }
            
            // Finally inserting new Update material.
            insert lstExistingMaterialClone; 
            
            /*********** Fetching Child Views ************/
            List<Sales__c> insertableSales = new List<Sales__c>();
            List<Plant__c> insertablePlants = new List<Plant__c>();
            List<Classification__c> insertableCls = new List<Classification__c>();
            List<Alternative_Unit_of_Measure__c> insertableAUoMs = new List<Alternative_Unit_of_Measure__c>();
            List<Valuation__c> insertableVals = new List<Valuation__c>();
            Set<String> validPlants = new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738 //USST-2793
            Set<String> validValuations = new Set<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738 //USST-2793
            
            // Fetching Sales records
            for(Sales__c sales : Database.query(getCreatableFieldsSOQL('Sales__c','Material__c=:recId')))
            {
                insertableSales.add(sales.clone());
            }
            // Fetching Plant records
            for(Plant__c plant : Database.query(getCreatableFieldsSOQL('Plant__c','Material__c=:recId and Plant__c in: validPlants'))) //USST-2738
            {
                if (validPlants.contains(String.valueOf(plant.Plant__c))) { //USST-2793
                    insertablePlants.add(plant.clone());
                    validPlants.remove(String.valueOf(plant.Plant__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            // Fetching Classification records
            for(Classification__c cls : Database.query(getCreatableFieldsSOQL('Classification__c','Material__c=:recId')))
            {
                insertableCls.add(cls.clone());
            }
            // Fetching Alternative Unit of Measure records
            for(Alternative_Unit_of_Measure__c auom : Database.query(getCreatableFieldsSOQL('Alternative_Unit_of_Measure__c','Material__c=:recId')))
            {
                insertableAUoMs.add(auom.clone());
            }
            // Fetching Valuation records
            for(Valuation__c val : Database.query(getCreatableFieldsSOQL('Valuation__c','Material__c=:recId and Valuation_Area__c in: validValuations'))) //USST-2738
            {
                if (validValuations.contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
                    insertableVals.add(val.clone());
                    validValuations.remove(String.valueOf(val.Valuation_Area__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            
            // Iterating over updating materials to associate child views.
            for(Material__c newMat : lstExistingMaterialClone)
            {
                if(insertableSales.size() > 0)
                {
                    for(Sales__c sales : insertableSales)
                    {
                        sales.Material__c = newMat.Id;
                        sales.Function__c = '004';
                        sales.isUpdateRecordType__c = TRUE;
                    }
                }
                if(insertablePlants.size() > 0)
                {
                    for(Plant__c plant : insertablePlants)
                    {
                        plant.Material__c = newMat.Id;
                        plant.Function__c = '004';
                    }
                }
                if(insertableCls.size() > 0)
                {
                    for(Classification__c cls : insertableCls)
                    {
                        cls.Material__c = newMat.Id;
                        cls.Function__c = '004';
                    }
                }
                if(insertableAUoMs.size() > 0)
                {
                    for(Alternative_Unit_of_Measure__c auom : insertableAUoMs)
                    {
                        auom.Material__c = newMat.Id;
                        auom.Function__c = '004';
                    }
                }
                if(insertableVals.size() > 0)
                {
                    for(Valuation__c val : insertableVals)
                    {
                        val.Material__c = newMat.Id;
                        val.Function__c = '004';
                    }
                }
                
            }
            
            // Inserting all the child views.
            if(insertableSales.size() > 0)
            {
                insert insertableSales;
            }
            if(insertablePlants.size() > 0)
            {
                insert insertablePlants;
            }
            if(insertableCls.size() > 0)
            {
                insert insertableCls;
            }
            if(insertableAUoMs.size() > 0)
            {
                insert insertableAUoMs; 
            }
            if(insertableVals.size() > 0)
            {
                insert insertableVals; 
            }
            
        }
        
        // Redirecting to new update material.
        Pagereference targetClonePg = new pageReference('/'+lstExistingMaterialClone[0].Id);    
        targetClonePg.setRedirect(true);
        return targetClonePg;
    }
    
    // Following method helps to build SOQL query with all accessible fields with provided condition. 
    public string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();      
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isAccessible()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
            
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                if(objectName != 'Material__c' && s.equalsIgnoreCase('Function__c'))
                    continue;
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}            
        }
        
        // Returing final built query.
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;        
    }  
}