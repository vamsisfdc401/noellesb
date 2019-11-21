/*****************************************************************************************
Class Name: MassUpdateMaterialGenerator
Purpose: Apex class to generate Mass Update Materials.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/13/2017           Suman                    Initial Development
******************************************************************************************/
global class MassUpdateMaterialGenerator implements Database.Batchable<sObject>, Database.Stateful
{
    global final Id headerId;
    global Map<String, ResultLine> existingBatchResults = new Map<String, ResultLine>();
    global Map<String, Map<String, String>> objFieldMap = new Map<String, Map<String, String>>();
    global class ResultLine
    {
        global String materialNumber;
        global String status;
        global String reason;
    }
    
    global MassUpdateMaterialGenerator(Id headerId)
    {
        this.headerId = headerId;
    }
    
    // Fetching the complete context data.
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // Fetch the field relationship and generate mapping.
        for(MassUpdateFieldMapping__c mapping : MassUpdateFieldMapping__c.getall().values())
        {
            if(!objFieldMap.containsKey( mapping.Transaction_Object_API__c ))
                objFieldMap.put( mapping.Transaction_Object_API__c, new Map<String, String>() );
            objFieldMap.get( mapping.Transaction_Object_API__c).put(mapping.Request_Field_API__c, mapping.Transaction_Field_API__c);
        }
        
        Id reqHeaderId = headerId;
        // Changed for REL-103
        return Database.getQueryLocator('SELECT Id,Material_Group_2__c,Material_Group_3__c,Material_Group_5__c,Material_Number__c,Source_Material__c,MPM__c,MRP_Controller__c,' +
                                        'Operations_Group__c,Purchasing_Group__c,Sales_Planning_Group__c,Component__c,Subformat__c,Technical_Format__c,Sales_Org__c ' +
                                        'FROM Material_Update_Request__c ' +
                                        'WHERE Mass_Update_Header__c=:reqHeaderId AND Request_Status__c=\'Open\' AND Request_Updated__c=true ' +
                                        'ORDER BY Material_Number__c');
    }
    
    // Executing the batch process.
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        // Grabing the record type id of Update material.
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Id clsCompRecTypeId = Schema.Sobjecttype.Classification__c.getRecordTypeInfosByName().get('Universal Components').getRecordTypeId();
        
        // Setting this variable for not to invoke defaulting functionality during Update material creation. 
        TriggerUtility.checkFromUpdateMaterial = TRUE;
        
        Set<Id> sourceMatIds = new Set<Id>();
        Map<String, Map<String, Material_Update_Request__c>> matNoRequestMap = new Map<String, Map<String, Material_Update_Request__c>>();
        // Iterating over the requests to grab source material Ids.
        for(Material_Update_Request__c mreq : (List<Material_Update_Request__c>) scope)
        {
            sourceMatIds.add(mreq.Source_Material__c);
            if(!matNoRequestMap.containsKey(mreq.Material_Number__c))
                matNoRequestMap.put(mreq.Material_Number__c, new Map<String, Material_Update_Request__c>());
            matNoRequestMap.get(mreq.Material_Number__c).put(mreq.Sales_Org__c, mreq);
        }
        
        try
        {
            // Following variables keep the cloned data in storage.
            Map<String, Material__c> matNoMaterialMap = new Map<String, Material__c>();
            Map<String, List<Sales__c>> matNoSalesMap = new Map<String, List<Sales__c>>();
            Map<String, List<Plant__c>> matNoPlantsMap = new Map<String, List<Plant__c>>();
            Map<String, List<Classification__c>> matNoClsMap = new Map<String, List<Classification__c>>();
            Map<String, List<Alternative_Unit_of_Measure__c >> matNoAUoMsMap = new Map<String, List<Alternative_Unit_of_Measure__c >>();
            Map<String, List<Valuation__c>> matNoValsMap = new Map<String, List<Valuation__c>>();
            
            String bomTextRegEx = Label.SpecialCharacters_Regex;
            Pattern MyPattern = Pattern.compile(bomTextRegEx);
            Matcher MyMatcher;
            String message;
            // Fetch material and prepare material map
            for(Material__c mat : Database.query(getCreatableFieldsSOQL('Material__c', 'Id IN: sourceMatIds')))
            {
                if(mat.Material_Type__c != 'ZDLT' && mat.Material_Type__c != 'ZVSM' && mat.Material_Type__c != 'Episode (HEEP)'){
                    Material__c matCopy = mat.clone(false,true);
                    matCopy.Name = mat.Name;
                    matCopy.Material_Status__c = 'Approved';
                    matCopy.Brand_Group__c = '';
                    matCopy.RecordTypeId = recTypeId;
                    matCopy.Original_Material_Number__c = mat.id;
                    matCopy.Material_Number__c = mat.Material_Number__c;
                    matCopy.BOM_Integration_State__c = '';
                    matCopy.BOM_Function__c = '';
                    matCopy.Function__c = '004';
                    matCopy.Material_Integration_State__c = 'N';
                    matCopy.OwnerId =userinfo.getUserId();
                    matCopy.Material_Description_Unique__c = '';
                    //Added for fix for Defect DF-02106
                    matCopy.Record_Type_Filter__c = 'Update';
                    matCopy.Execute_Validation_Rule__c = false;
                    //matCopy.Original_release_date__c=mat.original_release_date__c;
                    matCopy.Mass_Update_Request__c = true; //USST-2856
                    
                    if(mat.BOM_Long_Text__c != null){
                        if(MyPattern.matcher(mat.BOM_Long_Text__c).find()){
                            message=mat.BOM_Long_Text__c;
                            matCopy.BOM_Long_Text__c=message.replaceAll(bomTextRegEx, '');
                        }
                    }
                    
                    // Populate requested changes.
                    populateRequestedChanges('Material__c', mat.Material_Number__c, matCopy, matNoRequestMap);
                    
                    matNoMaterialMap.put(mat.Material_Number__c, matCopy); 
                }   
                else{
                    ResultLine res = new ResultLine();
                    res.materialNumber = mat.Material_Number__c;
                    res.status = 'Failed';
                    res.reason = 'ZDLT,HEEP or ZVSM Material Type records may only be edited in SAP';
                    existingBatchResults.put(res.materialNumber, res);
                }
            }
            
            // Fetch sales and prepare source, sales map
            for(Sales__c sales : Database.query(getCreatableFieldsSOQL('Sales__c', 'Material__c IN: sourceMatIds')))
            {
                if(!matNoSalesMap.containsKey(sales.Material__r.Material_Number__c))
                    matNoSalesMap.put(sales.Material__r.Material_Number__c, new List<Sales__c>());
                
                // Prepare Sales instance.
                Sales__c sCopy = sales.clone();
                
                // Populate requested changes.
                populateRequestedChanges('Sales__c', sales.Material__r.Material_Number__c, sCopy, matNoRequestMap);
                
                matNoSalesMap.get(sales.Material__r.Material_Number__c).add(sCopy);
            }
            
            // Fetch plant and prepare source, plant map
            for(Plant__c plant : Database.query(getCreatableFieldsSOQL('Plant__c', 'Material__c IN: sourceMatIds')))
            {
                if(!matNoPlantsMap.containsKey(plant.Material__r.Material_Number__c))
                    matNoPlantsMap.put(plant.Material__r.Material_Number__c, new List<Plant__c>());
                
                // Prepare Plant instance.
                Plant__c pCopy = plant.clone();
                
                // Populate requested changes.
                populateRequestedChanges('Plant__c', plant.Material__r.Material_Number__c, pCopy, matNoRequestMap);
                System.debug('----pMatNo> '+plant.Material__r.Material_Number__c);
                matNoPlantsMap.get(plant.Material__r.Material_Number__c).add(pCopy);
            }
            
            // Fetch Classification and prepare source, Classification map
            for(Classification__c cls : Database.query(getCreatableFieldsSOQL('Classification__c', 'Material__c IN: sourceMatIds')))
            {
                if(!matNoClsMap.containsKey(cls.Material__r.Material_Number__c))
                    matNoClsMap.put(cls.Material__r.Material_Number__c, new List<Classification__c>());
                
                // Prepare classification instance.
                Classification__c cCopy = cls.clone();
                
                // Populate requested changes only for Universal Component Record Type.
                if(cls.RecordTypeId == clsCompRecTypeId)
                    populateRequestedChanges('Classification__c', cls.Material__r.Material_Number__c, cCopy, matNoRequestMap);
                
                matNoClsMap.get(cls.Material__r.Material_Number__c).add(cCopy);
            }
            
            // Fetch auom and prepare source, auom map
            for(Alternative_Unit_of_Measure__c auom : Database.query(getCreatableFieldsSOQL('Alternative_Unit_of_Measure__c', 'Material__c IN: sourceMatIds')))
            {
                if(!matNoAUoMsMap.containsKey(auom.Material__r.Material_Number__c))
                    matNoAUoMsMap.put(auom.Material__r.Material_Number__c, new List<Alternative_Unit_of_Measure__c>());
                
                // Prepare auom instance.
                Alternative_Unit_of_Measure__c aCopy = auom.clone();
                
                // Populate requested changes.
                populateRequestedChanges('Alternative_Unit_of_Measure__c', auom.Material__r.Material_Number__c, aCopy, matNoRequestMap);
                
                matNoAUoMsMap.get(auom.Material__r.Material_Number__c).add(aCopy);
            }
            
            // Fetch Valuation and prepare source, Valuation map
            for(Valuation__c val : Database.query(getCreatableFieldsSOQL('Valuation__c', 'Material__c IN: sourceMatIds')))
            {
                if(!matNoValsMap.containsKey(val.Material__r.Material_Number__c))
                    matNoValsMap.put(val.Material__r.Material_Number__c, new List<Valuation__c>());
                
                // Prepare Valuation instance.
                Valuation__c vCopy = val.clone();
                
                // Populate requested changes.
                populateRequestedChanges('Valuation__c', val.Material__r.Material_Number__c, vCopy, matNoRequestMap);
                
                matNoValsMap.get(val.Material__r.Material_Number__c).add(vCopy);
            }
            
            // Insert materials.
            Integer index = 0;
            Integer errCount = 0;
            Map<String, Id> matNoMatIdMap = new Map<String, Id>();
            Database.SaveResult[] srMatList = Database.insert(matNoMaterialMap.values(), false);
            for (Database.SaveResult sr : srMatList) 
            {
                // If error occurred.
                if(!sr.isSuccess()) 
                {
                    String reason = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) 
                    {
                        if(errCount ++ > 0)
                            reason += ' ';    //'\r\n';
                        reason += err.getStatusCode() + ': ' + err.getMessage().replaceAll('\r\n', '').replaceAll('\n', '') + '.';
                    }
                    
                    // Instantiating Result line.
                    ResultLine res = new ResultLine();
                    res.materialNumber = matNoMaterialMap.values()[index].Material_Number__c;
                    res.status = 'Failed';
                    res.reason = reason;
                    existingBatchResults.put(res.materialNumber, res);
                }
                else
                {
                    // Instantiating Result line.
                    ResultLine res = new ResultLine();
                    res.materialNumber = matNoMaterialMap.values()[index].Material_Number__c;
                    res.status = 'Success';
                    res.reason = '';
                    existingBatchResults.put(res.materialNumber, res);
                    
                    matNoMatIdMap.put(res.materialNumber, sr.getId());
                }
                index ++;
            }
            
            // Parenting child views and insert them only for successful mats.
            List<Sales__c> insertableSalesList = new List<Sales__c>();
            List<Plant__c> insertablePlantList = new List<Plant__c>();
            List<Classification__c> insertableClsList = new List<Classification__c>();
            List<Alternative_Unit_of_Measure__c > insertableAUoMList = new List<Alternative_Unit_of_Measure__c >();
            List<Valuation__c> insertableValList = new List<Valuation__c>();
            
            for(String matNo : matNoMatIdMap.keySet())
            {
                // Preparing sales data.
                if(matNoSalesMap.containsKey(matNo))
                {
                    for(Sales__c sales : matNoSalesMap.get(matNo))
                    {
                        sales.Material__c = matNoMatIdMap.get(matNo);
                        sales.Function__c = '004';
                        sales.isUpdateRecordType__c = TRUE;
                        
                        insertableSalesList.add(sales);
                    }
                }
                
                // Preparing plant data.
                if(matNoPlantsMap.containsKey(matNo))
                {
                    for(Plant__c plant : matNoPlantsMap.get(matNo))
                    {
                        plant.Material__c = matNoMatIdMap.get(matNo);
                        plant.Function__c = '004';
                        
                        insertablePlantList.add(plant);
                    }
                }
                
                // Preparing Classification data.
                if(matNoClsMap.containsKey(matNo))
                {
                    for(Classification__c cls : matNoClsMap.get(matNo))
                    {
                        cls.Material__c = matNoMatIdMap.get(matNo);
                        cls.Function__c = '004';
                        
                        insertableClsList.add(cls);
                    }
                }
                
                // Preparing AUoM data.
                if(matNoAUoMsMap.containsKey(matNo))
                {
                    for(Alternative_Unit_of_Measure__c auom : matNoAUoMsMap.get(matNo))
                    {
                        auom.Material__c = matNoMatIdMap.get(matNo);
                        auom.Function__c = '004';
                        
                        insertableAUoMList.add(auom);
                    }
                }
                
                // Preparing Valuation data.
                if(matNoValsMap.containsKey(matNo))
                {
                    for(Valuation__c val : matNoValsMap.get(matNo))
                    {
                        val.Material__c = matNoMatIdMap.get(matNo);
                        val.Function__c = '004';
                        
                        insertableValList.add(val);
                    }
                }
            }
            
            // Commit the changes in Child Views
            if(insertableSalesList.size() > 0)
                insert insertableSalesList;
            if(insertablePlantList.size() > 0)
                insert insertablePlantList;
            if(insertableClsList.size() > 0)
                insert insertableClsList;
            if(insertableAUoMList.size() > 0)
                insert insertableAUoMList;
            if(insertableValList.size() > 0)
                insert insertableValList;
            
            // Update all the successful requests to closed and update the target material Id.
            List<Material_Update_Request__c> updateableMReqList = new List<Material_Update_Request__c>();
            for(String matNo : matNoMatIdMap.keySet())
            {
                List<Material_Update_Request__c> mreqList = matNoRequestMap.get(matNo).values();
                for(Material_Update_Request__c mreq : mreqList)
                {
                    mreq.Request_Status__c = 'Closed';
                    mreq.Target_Material__c = matNoMatIdMap.get(matNo);
                    updateableMReqList.add(mreq);
                }
            }
            if(updateableMReqList.size() > 0)
            {
                update updateableMReqList;
            }
        }
        // Managing the error.
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }
    
    // Final method to be called once batch is complete.
    global void finish(Database.BatchableContext BC)
    {
        // Update the header status.
        update new Mass_Update_Header__c(Id=headerId, Status__c='Processed');
        
        // Create attachment CSV with Result.
        if(existingBatchResults.size() > 0)
        {
            String csvData = 'Material Number,Status,Reason\n';
            for(ResultLine res : existingBatchResults.values())
            {
                csvData += res.materialNumber + ',' + res.status + ',' +res.reason + '\n';
            }
            
            Blob csvFile = Blob.valueOf(csvData);
            Attachment attachment = new Attachment();
            attachment.Body = csvFile;
            attachment.Name = String.valueOf( headerId + '_' + DateTime.now().format('MM-dd-yyyy\'T\'hh:mm:ss\'Z\'') + '.csv' );
            attachment.ParentId = headerId; 
            insert attachment;
        }
    }
    
    // Following method is responsible to populate the requested changes in transactional objects. // Changed for REL-103
    private void populateRequestedChanges(String objectType, String materialNumber, SObject ins, Map<String, Map<String, Material_Update_Request__c>> matNoRequestMap)
    {
        // Get the relevant change request for the material number.
        Map<String, Material_Update_Request__c> mreqList = matNoRequestMap.get(materialNumber);
        
        // Get the associated fields to be changed.
        Map<String, String> fieldMap = objFieldMap.get(objectType);
        
        if(mreqList == null || fieldMap == null)
            return;
        
        // Evaluate value and Assigning values to each field.
        for(String reqField : fieldMap.keySet())
        {
            String tranField = fieldMap.get(reqField);
            
            // Check each field, evaluate based on Object Type (Material, Plant etc) and Territory priority and take value from material request instance.
            // If Object type is Sales, Plant or Valuation consider different territory in request and pick the value according to instance territory
            if(objectType.equalsIgnoreCase('Sales__c') || objectType.equalsIgnoreCase('Plant__c') || objectType.equalsIgnoreCase('Valuation__c'))
            {
                Material_Update_Request__c mreq;
                if(String.valueOf(ins.get('Territory__c')).contains('US'))
                    mreq = mreqList.get('V100');
                else
                    mreq = mreqList.get('V800');
                
                if(mreq != null && mreq.get(reqField) != null)
                    ins.put(tranField, mreq.get(reqField));
            }
            // If Object type is Material, Classification or AUoM take non-null or evaluate conflicting value from both requests.
            else if(objectType.equalsIgnoreCase('Material__c') || objectType.equalsIgnoreCase('Classification__c') || objectType.equalsIgnoreCase('Alternative_Unit_of_Measure__c'))
            {
                // Resolve conflict.
                if(mreqList.size() > 1)
                {
                    Material_Update_Request__c mreqUS = mreqList.get('V100');
                    Material_Update_Request__c mreqCDN = mreqList.get('V800');
                    
                    // Fetching both values.
                    if(mreqUS != null && mreqUS.get(reqField) != null)
                    {
                        ins.put(tranField, mreqUS.get(reqField));
                    }
                    else if(mreqCDN != null && mreqCDN.get(reqField) != null)
                    {
                        ins.put(tranField, mreqCDN.get(reqField));
                    }
                }
                else if(mreqList.size() == 1)
                {
                    Material_Update_Request__c mreq = mreqList.values()[0];
                    if(mreq != null && mreq.get(reqField) != null)
                        ins.put(tranField, mreq.get(reqField));
                }
            }
        }
    }
    
    // Following method helps to build SOQL query with all accessible fields with provided condition.
    private string getCreatableFieldsSOQL(String objectName, String whereClause)
    {
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
            
            if(!objectName.equalsIgnoreCase('Material__c'))
                selectFields.add('Material__r.Material_Number__c');
        }
        
        if (!selectFields.isEmpty()){
            for (String s : selectFields){
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