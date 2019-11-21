/*****************************************************************************************
Class Name: DefaultingHandler
Purpose: This class is called from Material Trigger. It is responsible to default the Material
        and its child records (Sales, Plant etc.). 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/08/2016           Suman Kundu              Initial Development
******************************************************************************************/
public without sharing class DefaultingHandler
{
    // This object captures both constraint and target's object and key field mapping.
    private class ObjectKeyFieldInfo
    {
        public String constraintObjectAPI;
        public String constraintFieldAPI;
        public String materialFieldAPI;
        
        public ObjectKeyFieldInfo(String constraintObjectAPI, String constraintFieldAPI, String materialFieldAPI)
        {
            this.constraintObjectAPI = constraintObjectAPI;
            this.constraintFieldAPI = constraintFieldAPI;
            this.materialFieldAPI = materialFieldAPI;
        }
    }
    public static Boolean fromCloning = false;
    public static Boolean isExecutingAdditionalDefaulting = false;
    private static Boolean isDefaultDataFetched = false;
    public static List<Material__c> processingMaterials;
    private static Map<String, Integer> orderOfConstraints = new Map<String, Integer>{'Material Type'=>1, 'Item Type'=>2, 'Item Code'=>3, 'Label Code'=>4, 'Format'=>5, 'Territory'=>6};
    private static Map<String, String> defaultingObjectConstraintMap;
    
    // This map holds the constraint and target object key field mapping for comparing constraint values.
    private static Map<String, ObjectKeyFieldInfo> constraintObjectFieldMap;
    
    // This map contains constrain and unique values to fetch default records.
    private static Map<String, Set<String>> constraintSearchValueMap;
    
    // Following map will contain constraint with its search value and default record.
    private static Map<String, Map<String, SObject>> constraintSearchValDefaultMap;
    
    // This map contains all the material associated values.
    private static Map<Id, Release__c> releaseMap;
    
    // This map will hold the field mapping for transactional object fields and Defaulting object
    private static Map<String, Map<String, List<DefaultingFieldMapping__c>>> objectFieldDefaultFieldMap;
    
    // Following map holds the title details.
    private static Map<Id, Title__c> titleMap;
    private static Map<Id, String> titleSGENNOMap = new Map<Id, String>();
    private static Map<Id, TM_Version__c> titleTMVersionMap = new Map<Id, TM_Version__c>();
    private static Map<String, Id> sgennoLegalTitleMap = new Map<String, Id>();
    
    // Following map holds the TM Version details.
    private static Map<Id, TM_Version__c> tmVersionMap;
    
    // Storing Cloning Data
    private static Map<String, Set<String>> cloningObjectFieldsMap = new Map<String, Set<String>>();
    private static Map<String, Id> cloneToOriginalMatMap = new Map<String, Id>();
    private static Map<Id, Material__c> originalMaterialMap = new Map<Id, Material__c>();
    
    // 6 contraint variables
    private static Map<String, Map<String, Map<String, DefaultingFieldMapping__c>>> objectFieldConstraintMap = new Map<String, Map<String, Map<String, DefaultingFieldMapping__c>>>();
    // For cloning specific field only
    private static Map<String, Map<String, List<DefaultingFieldMapping__c>>> objectFieldConstraint4ClnMap = new Map<String, Map<String, List<DefaultingFieldMapping__c>>>();
    private Static String ADDITIONAL_CONSGTRIANT = 'isAdditionalConstriant__c';
    // Below Variable added for 2546
    private static Map<String, Integer> componentTypetoVal= new Map<String, Integer>{'NATIONAL ONPACK/GWP' => 0, 'DISC DVD' => 0,'STICKER PREMIUM' => 2,'DISC BD' => 0,'DISC UHD' => 0,'DISC CD' => 0,'STEELBOOK' => 1,
        'RIGID SLIPCASE' => 1, 'DIGI-PACK' => 1,'MEGAPACK' => 1,'SLIPCASE' => 1,'LITHO DOUBLE-SIDED' => 1,'LITHO SLIMPACK' => 1,'LITHO' => 1,
        'INSERT' => 2, 'UV INSERT' => 2, 'DC INSERT' => 2, 'O-CARD' => 2,'BELLY BAND' => 2,'JCARD' => 2,'BOOKLET INSERT' => 2,'LONGBOX/GIFTBOX' => 1,'LCARD' => 2, 'STICKER' => 4,'RMF RETAILER EXCL. GWP' => 0,'CCARD' => 2,'ONSERT' => 2,'O-CARD W/FOIL' => 2}; //USST-3078
        
    static 
    {
        // Preparing map for key comparing fields to fetch proper records.
        constraintObjectFieldMap = new Map<String, ObjectKeyFieldInfo>{
                                        'Material Type' => new ObjectKeyFieldInfo('Material_Material_Type_Default__c', 'Material_Type_Key__c', 'Material_Type__c'),
                                        'Item Type' => new ObjectKeyFieldInfo('Material_Item_Type_Default__c', 'Item_Type_Key__c', 'Item_Type__c'),
                                        'Item Code' => new ObjectKeyFieldInfo('Material_Item_Code_Default__c', 'Item_Code_Key__c', 'Item_Code__c'),
                                        'Label Code' => new ObjectKeyFieldInfo('Material_Label_Code_Default__c', 'Label_Code_Key__c', 'Label_Code__c'),
                                        'Format' => new ObjectKeyFieldInfo('Material_Format_Default__c', 'Format_Key__c', 'Format_Description__c'),
                                        'Territory' => new ObjectKeyFieldInfo('Material_Territory_Default__c', 'Territory_Key__c', 'Territory__c')
                                    };
        defaultingObjectConstraintMap = new Map<String, String> {
                                        'Material_Material_Type_Default__c' => 'Material Type',
                                        'Material_Item_Type_Default__c' => 'Item Type',
                                        'Material_Item_Code_Default__c' => 'Item Code',
                                        'Material_Label_Code_Default__c' => 'Label Code',
                                        'Material_Format_Default__c' => 'Format',
                                        'Material_Territory_Default__c' => 'Territory'
                                    };
        
        // Instantiating constraint search map and constraint search default record map.
        constraintSearchValueMap = new Map<String, Set<String>>();
        constraintSearchValDefaultMap = new Map<String, Map<String, SObject>>();
        
        for(String constraintName : constraintObjectFieldMap.keySet())
        {
            constraintSearchValueMap.put(constraintName, new Set<String>());
            constraintSearchValDefaultMap.put(constraintName, new Map<String, SObject>());
        }
        
        objectFieldDefaultFieldMap = new Map<String, Map<String, List<DefaultingFieldMapping__c>>>();
        
    }
    
    // This method is responsible to extract all data from Default objects.
    public static void fetchCompleteDefaultData()
    {
        //USST-2546 --- start
        List<ComponentExtensionOnClone__c> mcs = ComponentExtensionOnClone__c.getall().values();
        Boolean chkCompExt = false;
        IF(!Test.isRunningTest()){
            chkCompExt = mcs[0].checkFromComponentExtension__c; 
        }
        system.debug('chkCompExt :: '+chkCompExt);
        //USST-2546 --- end
        if(isDefaultDataFetched)
            return;
        
        isDefaultDataFetched = true;
        Set<Id> releaseIds = new Set<Id>();
        
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        Set<Id> titleIds = new Set<Id>();
        Set<Id> tmVersionIds = new Set<Id>();
        
        // Fetching Release IDs to query and all other constraint details.
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            System.debug('mat/comp ::::::'+mat.Name);
            if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null)
            {
                // As it may come from before insert where there would not be ID, keeping name value.
                cloneToOriginalMatMap.put(mat.Name, mat.CloneHelperField__c);
            }
            
            if(mat.Release__c != null)
                releaseIds.add(mat.Release__c);
            
            if(mat.Title__c != null)
                titleIds.add(mat.Title__c);
            
            if(mat.TM_Version_Lookup__c != null)
                tmVersionIds.add(mat.TM_Version_Lookup__c);
            
            // Fetching material details
            for(String constraintName : constraintObjectFieldMap.keySet())
            {
                ObjectKeyFieldInfo objFld = constraintObjectFieldMap.get(constraintName);
                
                // Key field value is populated.
                if(mat.get(objFld.materialFieldAPI) != null)
                {
                    if(constraintName != 'Territory')
                        constraintSearchValueMap.get(constraintName).add(String.valueOf(mat.get(objFld.materialFieldAPI)));
                    else
                    {
                        if(String.valueOf(mat.get(objFld.materialFieldAPI)).containsIgnoreCase('US'))
                            constraintSearchValueMap.get(constraintName).add('US');
                        if(String.valueOf(mat.get(objFld.materialFieldAPI)).containsIgnoreCase('CDN'))
                            constraintSearchValueMap.get(constraintName).add('CDN');
                    }
                }
            }
        }
        
        // Extracting associated title details.
        if(titleIds.size() > 0)
        {
            // Changed for RE-61 to add MPAA Rating field in query.
            titleMap = new Map<Id, Title__c>([SELECT Id, SGENNO__c, Series_SGENNO__c, Genre_Primary__c, Runtime_US__c,
                                              (SELECT Id, Title__c, Rating__c FROM TM_Versions__r where Original_Flag__c=TRUE) 
                                              FROM Title__c WHERE Id IN: titleIds]);
            
            if(titleMap != null && titleMap.size() > 0)
            {
                Set<String> sysgenSet = new Set<String>();
                for(Title__c title : titleMap.values())
                {
                    if(title.SGENNO__c != null && title.SGENNO__c != '')
                    {
                        sysgenSet.add(title.SGENNO__c);
                        
                        titleSGENNOMap.put(title.Id, title.SGENNO__c);
                    }
                    
                    //creating title TM Version map 
                    if(!titleTMVersionMap.containsKey(title.ID) && title.TM_Versions__r != null && title.TM_Versions__r.size() > 0)
                    {
                        titleTMVersionMap.put(title.ID, title.TM_Versions__r[0]);
                        tmVersionIds.add(title.TM_Versions__r[0].Id);
                    }
                }
                
                if(sysgenSet.size() > 0)
                {
                    for(Alternative_Legal_Title__c alt : [SELECT Id, Alternative_Legal_Title_ID__c,Alternative_Legal_Title_ID_Number__c
                                                          FROM Alternative_Legal_Title__c WHERE Alternative_Legal_Title_ID_Number__c IN: sysgenSet])
                    {
                        sgennoLegalTitleMap.put(alt.Alternative_Legal_Title_ID_Number__c, alt.Id);
                    }
                }
            }
        }
        
        // Extract associated Release Details.
        if(releaseIds.size() > 0)
        {
            releaseMap = new Map<Id, Release__c>([SELECT Id, Deal__c, Brand_Group__c, Project_Type__c, 
                                                  Physical_Street_Date__c, First_Theatrical_Date__c 
                                                  FROM Release__c WHERE Id IN :releaseIds]);
        }
        
        // Extracting associated TM Versions.
        if(tmVersionIds.size() > 0)
        {
            tmVersionMap = new Map<Id, TM_Version__c>([SELECT Id, Version_Type__c, Original_Flag__c  
                                                       FROM TM_Version__c WHERE Id IN: tmVersionIds]); //USST-2787
        }
        
        // Extracting default values on the basis of material's constraint field.
        for(String constraintName : constraintSearchValueMap.keySet())
        {
            ObjectKeyFieldInfo objFld = constraintObjectFieldMap.get(constraintName);
            Set<String> searchValSet = constraintSearchValueMap.get(constraintName);
            
            // Check if there is any value to serach for the constraint fields
            if(searchValSet != null && searchValSet.size() > 0)
            {
                // Build dynamic query string.
                String query = 'SELECT ';
                Integer i = 0;
                for(Schema.SObjectField fldSchema : Schema.getGlobalDescribe().get(objFld.constraintObjectAPI).getDescribe().fields.getMap().values())
                {
                    Schema.DescribeFieldResult fld = fldSchema.getDescribe();
                    if(fld.isCustom())
                    {
                        if(i ++ > 0)
                            query += ',';    
                        query += fld.getName();
                    }
                }
                
                query += ' FROM ' + objFld.constraintObjectAPI;
                if(constraintName != 'Territory')
                {
                    // For cloning it needs to run again for child where values are required.
                    if(!TriggerUtility.checkFromCloning)
                        query += ' WHERE ' + objFld.constraintFieldAPI + ' IN :searchValSet';
                }
                else
                    query += ' WHERE ' + objFld.constraintFieldAPI + ' IN (\'US\',\'CDN\')';
                
                // Extracting default values and collecting them in map.
                for(SObject defRecord : Database.query(query))
                {
                    constraintSearchValDefaultMap.get(constraintName).put(String.valueOf(defRecord.get(objFld.constraintFieldAPI)), defRecord);
                }
            }
        }
        
        // Object and field mapping (for cloning).
        cloningObjectFieldsMap = new Map<String, Set<String>>();
        
        // Fetching Material field mapping details from custom settings.
        for(DefaultingFieldMapping__c defFldObj : DefaultingFieldMapping__c.getall().values())
        {
            System.debug('defFldObj----'+ defFldObj);
            System.debug(allowToFetchAllDefaultData);
            System.debug(Trigger.isExecuting);
            System.debug(Trigger.isUpdate);
            System.debug(defFldObj.Execute_on_Update__c);
            System.debug(TriggerUtility.checkFromCloning);
            System.debug(isExecutingAdditionalDefaulting);
            System.debug(defFldObj.isAdditionalConstriant__c); 
            System.debug(TriggerUtility.checkFromTemplate);
            System.debug(defFldObj.Defaulting_Object_API__c);
            
            if(!allowToFetchAllDefaultData && Trigger.isExecuting && Trigger.isUpdate && defFldObj.Execute_on_Update__c != null && !defFldObj.Execute_on_Update__c) {
                System.debug('Enter If 1');
                continue;
            }
            
                        
            if(TriggerUtility.checkFromTemplate && defFldObj.Defaulting_Object_API__c == 'NA') {
                System.debug('Enter If 2');
                continue;
            }
            
                       
            // Executing additional defaulting and non-additional field comes, ignore.
            if(isExecutingAdditionalDefaulting && !defFldObj.isAdditionalConstriant__c) {
                System.debug('Enter If 3');
                continue;
            }
            
            
            // Executing non-additional defaulting and additional field comes, ignore.
            else if(!isExecutingAdditionalDefaulting && defFldObj.isAdditionalConstriant__c && !TriggerUtility.checkFromCloning && !chkCompExt) { //USST-2546
                System.debug('Enter If 4');
                continue;
            }
        
            // For cloning, to collect data from source record preparing object fields map.
            if(TriggerUtility.checkFromCloning && defFldObj.Cloning_Default_Property__c != null && defFldObj.Cloning_Default_Property__c == 'N')
            {
                if(!cloningObjectFieldsMap.containsKey(defFldObj.Transaction_Object_API__c))
                    cloningObjectFieldsMap.put(defFldObj.Transaction_Object_API__c, new Set<String>());
                
                cloningObjectFieldsMap.get(defFldObj.Transaction_Object_API__c).add(defFldObj.Transaction_Field_API__c);
            }
            
            // Checking if object does not exist in map.
            if(!objectFieldDefaultFieldMap.containsKey(defFldObj.Transaction_Object_API__c))
                objectFieldDefaultFieldMap.put(defFldObj.Transaction_Object_API__c, new Map<String, List<DefaultingFieldMapping__c>>());
            
            // Checking if Field does not exist in map.
            if(!objectFieldDefaultFieldMap.get(defFldObj.Transaction_Object_API__c).containsKey(defFldObj.Transaction_Field_API__c))
                objectFieldDefaultFieldMap.get(defFldObj.Transaction_Object_API__c).put(defFldObj.Transaction_Field_API__c, new List<DefaultingFieldMapping__c>());
            
            objectFieldDefaultFieldMap.get(defFldObj.Transaction_Object_API__c).get(defFldObj.Transaction_Field_API__c).add(defFldObj);
            
            // 6 constraint field setup without additional and cloning specific new fields.
            if(!isExecutingAdditionalDefaulting && defFldObj.Defaulting_Object_API__c != 'NA' && 
               defaultingObjectConstraintMap.containsKey(defFldObj.Defaulting_Object_API__c))
            {
                if(!objectFieldConstraintMap.containsKey(defFldObj.Transaction_Object_API__c))
                    objectFieldConstraintMap.put(defFldObj.Transaction_Object_API__c, new Map<String, Map<String, DefaultingFieldMapping__c>>());
                
                if(!objectFieldConstraintMap.get(defFldObj.Transaction_Object_API__c).containsKey(defFldObj.Transaction_Field_API__c))
                {
                    objectFieldConstraintMap.get(defFldObj.Transaction_Object_API__c).put(defFldObj.Transaction_Field_API__c, new Map<String, DefaultingFieldMapping__c>());
                }
                
                objectFieldConstraintMap.get(defFldObj.Transaction_Object_API__c).get(defFldObj.Transaction_Field_API__c).put(defaultingObjectConstraintMap.get(defFldObj.Defaulting_Object_API__c), defFldObj);
            }
            else if(TriggerUtility.checkFromCloning && !isExecutingAdditionalDefaulting && defFldObj.Defaulting_Object_API__c == 'NA' &&
                    !defFldObj.isAdditionalConstriant__c && defFldObj.Cloning_Default_Property__c != 'N')
            {
                if(!objectFieldConstraint4ClnMap.containsKey(defFldObj.Transaction_Object_API__c))
                    objectFieldConstraint4ClnMap.put(defFldObj.Transaction_Object_API__c, new Map<String, List<DefaultingFieldMapping__c>>());
                
                if(!objectFieldConstraint4ClnMap.get(defFldObj.Transaction_Object_API__c).containsKey(defFldObj.Transaction_Field_API__c))
                {
                    objectFieldConstraint4ClnMap.get(defFldObj.Transaction_Object_API__c).put(defFldObj.Transaction_Field_API__c, new List<DefaultingFieldMapping__c>());
                }
                
                objectFieldConstraint4ClnMap.get(defFldObj.Transaction_Object_API__c).get(defFldObj.Transaction_Field_API__c).add(defFldObj);
            }
        }
        
        // Fetching original material and child views details.
        if(TriggerUtility.checkFromCloning && cloningObjectFieldsMap.size() > 0 && cloneToOriginalMatMap.size() > 0)
        {
            String originalDataQuery = 'SELECT Id,Name,Territory__c'; //USST-2961
            if(cloningObjectFieldsMap.containsKey('Material__c'))
            {
                for(String fieldApi : cloningObjectFieldsMap.get('Material__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
            }
            if(cloningObjectFieldsMap.containsKey('Sales__c'))
            {
                originalDataQuery += ',(SELECT Sales_Org__c';
                for(String fieldApi : cloningObjectFieldsMap.get('Sales__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
                originalDataQuery += ' FROM Sales__r)';
            }
            if(cloningObjectFieldsMap.containsKey('Plant__c'))
            {
                originalDataQuery += ',(SELECT Plant__c,Territory__c'; //USST-2968
                for(String fieldApi : cloningObjectFieldsMap.get('Plant__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
                originalDataQuery += ' FROM Plants__r)';
            }
            if(cloningObjectFieldsMap.containsKey('Classification__c'))
            {
                originalDataQuery += ',(SELECT RecordTypeId';
                for(String fieldApi : cloningObjectFieldsMap.get('Classification__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
                originalDataQuery += ' FROM Classifications__r)';
            }
            if(cloningObjectFieldsMap.containsKey('Alternative_Unit_of_Measure__c'))
            {
                originalDataQuery += ',(SELECT Alternative_Unit_of_Measure__c';
                for(String fieldApi : cloningObjectFieldsMap.get('Alternative_Unit_of_Measure__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
                originalDataQuery += ' FROM Alternative_Units_of_Measure__r)';
            }
            if(cloningObjectFieldsMap.containsKey('Valuation__c'))
            {
                originalDataQuery += ',(SELECT Valuation_Area__c';
                for(String fieldApi : cloningObjectFieldsMap.get('Valuation__c'))
                {
                    originalDataQuery += ',' + fieldApi;
                }
                originalDataQuery += ' FROM Valuations__r)';
            }
            List<Id> originalMatIds = cloneToOriginalMatMap.values();
            originalDataQuery += ' FROM Material__c WHERE Id IN: originalMatIds';
            
            // Extracting all the original material and their views (for cloning)
            if(TriggerUtility.checkFromCloning && cloneToOriginalMatMap.size() > 0)
            {
                originalMaterialMap = new Map<Id, Material__c>((List<Material__c>)Database.query(originalDataQuery));
            }
        }
    }
    
    private static Set<Id> materialsWithLabelChangedIds = new Set<Id>();
    @testVisible private static Boolean hasInsertExecuted = false;
    // This method is solely responsible for applying the default values in Material fields.
    public static void applyDefaultValues()
    {
        if(Trigger.IsInsert)
            hasInsertExecuted = true;
        else if(Trigger.IsUpdate && hasInsertExecuted)
            return;
            
        // Fetch defaulting data on the basis of material.
        if(Trigger.IsBefore && /*!TriggerUtility.checkFromCloning &&*/ !TriggerUtility.checkFromTemplate && !TriggerUtility.checkFromUpdateMaterial)
        {
            if(Trigger.isExecuting && Trigger.isUpdate)
            {
                // Get materials with label code changed.
                for(Material__c mat : (List<Material__c>)Trigger.New)
                {
                    Material__c oldMat = (Material__c) Trigger.OldMap.get(mat.Id);
                    if(mat.Label_Code__c != oldMat.Label_Code__c && mat.Label_Code__c != null)
                        materialsWithLabelChangedIds.add(mat.id);
                }
                
                if(materialsWithLabelChangedIds.size() == 0)
                    return;
            }
            
            fetchCompleteDefaultData();
            populateMaterialDefaultValues();
        }
        else if(Trigger.IsAfter && !TriggerUtility.checkFromTemplate && !TriggerUtility.checkFromUpdateMaterial)
        {
            if(Trigger.isExecuting && Trigger.isUpdate)
            {
                // Get materials with label code changed.
                for(Material__c mat : (List<Material__c>)Trigger.New)
                {
                    Material__c oldMat = (Material__c) Trigger.OldMap.get(mat.Id);
                    Material__c newMat = (Material__c) Trigger.newMap.get(mat.Id);
                    if(mat.Label_Code__c != oldMat.Label_Code__c && mat.Label_Code__c != null)
                        materialsWithLabelChangedIds.add(mat.id);
                }
                
                if(materialsWithLabelChangedIds.size() == 0)
                    return;
            }
            
            fetchCompleteDefaultData();
            populateSalesDefaultValues();
            populatePlantDefaultValues();
            populateClassificationDefaultValues();
            populateAUoMDefaultValues();
            populateValuationDefaultValues();
            
            
            if(TriggerUtility.executeQueueable)
            {
            SetAdditionaMateriallDefaults instanceDefaults1 = new SetAdditionaMateriallDefaults();
            instanceDefaults1.materialID = Trigger.newMap.keySet();
            instanceDefaults1.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults1);
            
            SetAdditionalSalesDefaults instanceDefaults2 = new SetAdditionalSalesDefaults();
            instanceDefaults2.materialID = Trigger.newMap.keySet();
            instanceDefaults2.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults2);
            
            SetAdditionalPlantDefaults instanceDefaults3 = new SetAdditionalPlantDefaults();
            instanceDefaults3.materialID = Trigger.newMap.keySet();
            instanceDefaults3.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults3);
            
            SetAdditionalOtherDefaults instanceDefaults4 = new SetAdditionalOtherDefaults();
            instanceDefaults4.materialID = Trigger.newMap.keySet();
            instanceDefaults4.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults4);
            }
        }
    }
    
    // This method populates default values in material record.
    public static void populateMaterialDefaultValues()
    {
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        
        // Iterating on material records to populate values in material.
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            
            // Defaulting alternative legal title field.
            if(mat.Item_Type__c == 'S (Single)' && mat.Title__c != null && 
               titleSGENNOMap.containsKey(mat.Title__c) && sgennoLegalTitleMap.containsKey(titleSGENNOMap.get(mat.Title__c)))
            {
                mat.Alternative_Legal_Title_Lookup__c = sgennoLegalTitleMap.get(titleSGENNOMap.get(mat.Title__c));
            }
            
            if(mat.Material_Type__c == 'FERT' && mat.Title__c != null && mat.TM_Version_Lookup__c == null && titleTMVersionMap.containsKey(mat.Title__c) && TriggerUtility.checkFromUpdateMaterial == false)
            {
                mat.TM_Version_Lookup__c = titleTMVersionMap.get(mat.Title__c).Id;
            }
            // Defaulting Title Source
            //USST-2787 --- start
            if(mat.Material_Type__c == 'FERT' && mat.Item_Type__c == 'D (Display Vehicle)')
            {
                mat.Title_Source__c = '04 - VARIOUS';
            }
            else if(mat.Material_Type__c == 'FERT' && mat.Title__c == null && TriggerUtility.currentUser != null)
            {
                if ((mat.Release__c != null && releaseMap != null && releaseMap.containsKey(mat.Release__c) && releaseMap.get(mat.Release__c).Brand_Group__c == 'Universal Pictures') || (mat.Release__c == null && TriggerUtility.currentUser.Brand_Group__c == 'Universal Pictures')) 
                {
                    mat.Title_Source__c = '01 - THEATRICAL';
                }
                else if ((mat.Release__c != null && releaseMap != null && releaseMap.containsKey(mat.Release__c) && releaseMap.get(mat.Release__c).Brand_Group__c == '1440') || (mat.Release__c == null && TriggerUtility.currentUser.Brand_Group__c == '1440'))
                {
                    mat.Title_Source__c = '03 - MADE FOR VIDEO';
                }
                else if ((mat.Release__c != null && releaseMap != null && releaseMap.containsKey(mat.Release__c) && releaseMap.get(mat.Release__c).Brand_Group__c == 'TV') || (mat.Release__c == null && TriggerUtility.currentUser.Brand_Group__c == 'TV'))
                {
                    mat.Title_Source__c = '02 - TELEVISION';
                }
                
            } 
            else if(mat.Material_Type__c == 'FERT' && mat.Title__c != null && titleSGENNOMap.containsKey(mat.Title__c) && mat.TM_Version_Lookup__c != null && tmVersionMap != null && tmVersionMap.containsKey(mat.TM_Version_Lookup__c) && tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c != null && tmVersionMap.get(mat.TM_Version_Lookup__c).Original_Flag__c == true)
            {
                if (tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'TH - Theatrical' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'DIRCUT - Director\'s Cut' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'UNRATED - Unrated' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'EXTEND - Extended' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'AIR - Airline' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'IMAX - IMAX')
                {
                    mat.Title_Source__c = '01 - THEATRICAL';
                }
                else if (tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'NONTH - Non-Theatrical' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'HV - Home Video' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'DTV - Direct To Video')
                {
                    mat.Title_Source__c = '03 - MADE FOR VIDEO';
                }
                else if (tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'TV - Television' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'SO - Stretchout' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'DIGITAL - Digital' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'UNC - Uncensored')
                {
                    mat.Title_Source__c = '02 - TELEVISION';
                }
                if (mat.Label_Code__c == '46 - DREAMWORKS ANIMATION' && (tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'TV - Television' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'SO - Stretchout' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'DIGITAL - Digital' || tmVersionMap.get(mat.TM_Version_Lookup__c).Version_Type__c == 'UNC - Uncensored'))
                {
                    mat.Title_Source__c = '03 - MADE FOR VIDEO';
                }
            }
            //USST-2787 --- end
            // Populating Project Type.
            if(mat.Release__c != null && releaseMap != null && releaseMap.containsKey(mat.Release__c))
            {
                Release__c rel = releaseMap.get(mat.Release__c);
                
                if(rel != null && mat.Material_Type__c == 'FERT' && rel.Project_Type__c != null)
                {
                    mat.Project_Type__c = rel.Project_Type__c;
                }
            }
            // If no Release is in FERT Material, set project type.
            else if(mat.Material_Type__c == 'FERT')
            {

            }
            
            if(mat.Material_Type__c == 'ROH' && (mat.Base_Quantity__c == null || mat.Base_Quantity__c == ''))
                mat.Base_Quantity__c = '0';
            mat.Valid_From__c = Date.today();
            mat.Xplant_Valid_From__c = Date.today();
            mat.X_Dchain_Valid_From__c = Date.today();
            
            // Special naming convention for Regie Sticker.
            if(mat.Item_Type__c == 'C - Components' && mat.Item_Code__c == 'RG - REGIE STICKER')
            {
                mat.Territory__c = 'CDN';
                mat.Format_Description__c = '';
                mat.Material_Group__c = '82121508 - Printing - Wrap/Tag/Label/Seal/Bag/Sticker Printing';
            }
            
            Integer executedConstraints = -1;
            // Iterates over material fields in the 6 constraint map.
            populateSixConstraintDefault(rec, rec, 'Material__c', null);
            
            // For cloning where field does not depend on 6 constraint and additional defaulting
            setCloningSpecificDefault(rec, 'Material__c');
            
            // Copying value from existing material for cloning where defaulting not required.
            if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c))
            {
                // As it may come from before insert where there would not be ID, keeping name value.
                Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                
                for(String matFieldAPI : cloningObjectFieldsMap.get('Material__c'))
                {
                    List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Material__c').get(matFieldAPI);
                    for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                    {
                        if(defFieldMap.Cloning_Default_Property__c == 'N')
                        {
                            mat.put(matFieldAPI, sourceMat.get(matFieldAPI));
                        }
                    }
                }
            }
            
            if(mat.Material_Type__c == 'FERT')
                mat.BOM_Usage__c = '3';
            
            if(mat.Material_Type__c != null && (mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009') && mat.Item_Code__c != 'DS - DISC')
            {
                mat.Format__c = null;
                mat.Technical_Format__c = null;
            }
            else if(mat.Material_Type__c != null && mat.Material_Type__c == 'FERT' && mat.Item_Code__c == 'BF - BABY FERT')
            {
                mat.Street_Date__c = null;
                mat.Pre_Order_Close_Date__c = null;
            }
            
            if(mat.Territory__c != null && mat.Territory__c.contains('US'))
            {
                mat.Sales_Org__c = 'V100';
                mat.Tax_Indicator__c = '0';
            }
            else if(mat.Territory__c != null && mat.Territory__c.contains('CDN'))
            {
                mat.Sales_Org__c = 'V800';
                mat.Tax_Indicator__c = '1';
            }
            system.debug('Checking the date fields----'+mat.Street_Date__c + date.today() );
            if(mat.Territory__c != null && mat.Territory__c.contains('US'))
                mat.Plant__c = 'V000';
            
            if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                mat.D_Chain_Spec__c = 'NR';
            else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' && mat.Street_Date__c != null && mat.Street_Date__c <= Date.today()) // Adding for 2248
                mat.D_Chain_Spec__c = 'AC';
            else if(mat.Item_Code__c == 'BF - BABY FERT')
                mat.D_Chain_Spec__c = 'AC';
            else if(mat.Material_Type__c == 'FERT' && mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)')
                mat.D_Chain_Spec__c = 'FR';
            else
                mat.D_Chain_Spec__c = 'NR';
            
            if(mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)'){
                if(mat.Format__c == '09 - BLU-RAY' || mat.Format_Description__c == '3D BD' || mat.Format_Description__c == '3D DVD'){
                    mat.Case_Color_new__c = 'Blue';
                }
                
                else if(mat.Format_Description__c == 'UHD'){
                    mat.Case_Color_new__c = 'UHD Black';
                }
                else if(mat.Format_Description__c == '3D UHD'){
                    mat.Case_Color_new__c = null;
                }
                // Updated for RE-116
                else if(mat.Format__c == '11 - ULTRA HD 4K' || ((mat.Format__c == '02 - DVD' || mat.Format__c == '20 - CD (COMPACT DISC)') && releaseMap != null && releaseMap.containsKey(mat.Release__c) && releaseMap.get(mat.Release__c).Brand_Group__c != 'TV')){
                    mat.Case_Color_new__c = 'Black';
                }
                // Updated for RE-116
                else if((mat.Format__c == '02 - DVD' || mat.Format__c == '20 - CD (COMPACT DISC)') && releaseMap != null && releaseMap.containsKey(mat.Release__c) && releaseMap.get(mat.Release__c).Brand_Group__c == 'TV'){
                    mat.Case_Color_new__c = 'Clear';
                }
            }
            else{
                mat.Case_Color_new__c = null;
            }
        }
    }
    
    // Following method is responsible to populate Material default values according to Additional Defaulting Setup.
    public static void populateMaterialAdditionalDefaultValues()
    {
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        
        // Defaulting for exceptional fields. This should execute after previous defaultng defaulted all the basic fields.
        // Because this level defaulting may happen on previous level defaulted values.
        for(SObject rec : processingMaterials)
        {
            // Iterates over material fields in the map.
            if(objectFieldDefaultFieldMap.get('Material__c') != null)
            {
                for(String matFieldAPI : objectFieldDefaultFieldMap.get('Material__c').keySet())
                {
                    List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Material__c').get(matFieldAPI);
                    for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                    {
                        if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                            if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                continue;
                            else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                            {
                                populateCloningDefault(rec, matFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                continue;
                            }
                            
                            String value = AdditionalConstirantHelper.getConstirantValue(rec, matFieldAPI, null);
                            if(value != null) {
                                DefaultValueUtil.populateValues(rec, matFieldAPI, value);
                                continue;
                            }
                        }
                    }
                }
            }
            
            System.debug('##TriggerUtility.checkFromCloning'+TriggerUtility.checkFromCloning);
            // Added for RE-190
            if((TriggerUtility.initiatedFromWizard || TriggerUtility.checkFromCloning) && String.valueOf(rec.get('Item_Type__c')) == 'D (Display Vehicle)' )
            {
                // make product class blank
                rec.put('Product_Class__c', null);
            }
            
            rec.put('Defaulting_Material__c', true);
        }
        
        TriggerUtility.checkFromDefaulting = TRUE;
        update processingMaterials;
    }
    
    // Follwoing thod is responsible to populate Sales default values according to Defaulting Setup.
    public static void populateSalesDefaultValues()
    {
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        else if(Trigger.isExecuting && Trigger.isUpdate && (materialsWithLabelChangedIds == null || materialsWithLabelChangedIds.size() == 0))
            return;
        
        Map<Id, Map<String, Sales__c>> materialSalesMap = new Map<Id, Map<String, Sales__c>>();
        if(Trigger.isExecuting && Trigger.isUpdate && materialsWithLabelChangedIds.size() > 0)
        {
            for(Sales__c sales : [SELECT Id, Material__c, Territory__c 
                                  FROM Sales__c WHERE Material__c IN :materialsWithLabelChangedIds])
            {
                if(!materialSalesMap.containsKey(sales.Material__c))
                {
                    materialSalesMap.put(sales.Material__c, new Map<String, Sales__c>());
                }
                
                if(sales.Territory__c == null)
                    materialSalesMap.get(sales.Material__c).put('US', sales);
                else
                    materialSalesMap.get(sales.Material__c).put(sales.Territory__c, sales);
            }
        }
        
        List<Sales__c> insertableSalesList = new List<Sales__c>();
        
        for(SObject rec : processingMaterials)
        {
            if(Trigger.isExecuting && Trigger.isUpdate && !materialsWithLabelChangedIds.contains(rec.Id))
                continue;
            
            Material__c mat = (Material__c) rec;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Sales__c sales;
                
                if(Trigger.isExecuting && Trigger.isUpdate)
                {
                    if(territories != null && territories.size() > 0)
                        sales = materialSalesMap.get(mat.Id).get(territories[i]);
                    else
                        sales = materialSalesMap.get(mat.Id).get('US');
                }
                else
                {
                    sales = new Sales__c();
                    
                    // Assigning child records to parent material.
                    if(mat.Id != null)
                    {
                        sales.Material__c = mat.Id;                 
                    }
                }
                
                if(sales == null)
                    continue;
                
                if(territories != null && territories.size() > 0)
                    sales.Territory__c = territories[i];
                
                if(rec.get('Function__c') == '004')
                {
                    sales.Function__c = '023';                  
                }
                
                sales.Valid_From__c = Date.today();
                
                // Iterates over Sales fields in the map.
                populateSixConstraintDefault(rec, sales, 'Sales__c', ((territories != null && territories.size() > 0) ? territories[i] : null));
                
                // For cloning where field does not depend on 6 constraint and additional defaulting
                setCloningSpecificDefault(sales, 'Sales__c');
                
                // Copying value from existing material for cloning where defaulting not required.
                if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c) &&
                   cloningObjectFieldsMap.containsKey('Sales__c'))
                {
                    // As it may come from before insert where there would not be ID, keeping name value.
                    Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                    Sales__c sourceSales;
                    for(Sales__c oSales : sourceMat.Sales__r)
                    {
                        //if(oSales.Sales_Org__c == sourceSales.Sales_Org__c)
                        {
                            sourceSales = oSales;
                            break;
                        }
                    }
                    
                    if(sourceSales != null)
                    {
                        for(String salesFieldAPI : cloningObjectFieldsMap.get('Sales__c'))
                        {
                            for(String constraintName : constraintObjectFieldMap.keySet())
                            {
                                List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Sales__c').get(salesFieldAPI);
                                for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                                {
                                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    {
                                        sales.put(salesFieldAPI, sourceSales.get(salesFieldAPI));
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(mat.Item_Type__c == 'D (Display Vehicle)' || mat.Item_Code__c == 'BF - BABY FERT')
                {
                    sales.Material_Group_2__c = null;
                }
                else if(mat.Material_Type__c != null && (mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009'))
                {
                    sales.Volume_Rebate_Group__c = null;
                }
                
                if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                    sales.D_Chain_Spec__c = 'NR - New Release';
                else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' && mat.Street_Date__c != null && mat.Street_Date__c <= Date.today()) // Added street date equal for 2248
                    sales.D_Chain_Spec__c = 'AC - Active Catalog';
                else if(mat.Item_Code__c == 'BF - BABY FERT')
                    sales.D_Chain_Spec__c = 'AC - Active Catalog';
                else if(mat.Material_Type__c == 'FERT' &&  mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)') // Added Format__c condition for 2248
                    sales.D_Chain_Spec__c = 'FR - Future Release';
                else
                    sales.D_Chain_Spec__c = 'NR - New Release';
                
                
                //USST-2493--- start :: Defaulting for MaterialPricing Group
                if (mat.Material_Type__c == 'FERT') {
                    if (mat.Item_Type__c == 'D (Display Vehicle)') {
                        sales.Material_Pricing_Group__c = 'Z0 - Not Tracked';
                    }
                    else if (mat.Label_Code__c == '89 - FUNIMATION') {
                        sales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                    }
                    else if (mat.Label_Code__c == '45 - PICTUREHOUSE') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '57 - BLEECKER STREET') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '88 - Cinedigm') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '58 - HiT Entertainment') {
                        sales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                    }
                    else if (mat.Label_Code__c == '24 - PURE FLIX') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '49 - PBS') {
                        sales.Material_Pricing_Group__c = 'D8 - Not Tracked, 35%';
                    }
                    else if (mat.Label_Code__c == '86 – SHOUT! Factory') {
                        sales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                    }
                    else if (mat.Label_Code__c == '36 - NEON RATED LLC') {
                        sales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                    }
                    else if (mat.Label_Code__c == '32 - Elevation' && sales.territory__c == 'CDN') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '23 - Remstar' && sales.territory__c == 'CDN') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '78 - D Films' && sales.territory__c == 'CDN') {
                        sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                    }
                    else if (mat.Label_Code__c == '59 - Paramount') {
                        if (mat.Title_Source__c == '02 - TELEVISION') {
                            sales.Material_Pricing_Group__c = 'D7 - Not Tracked, 34%'; //USST-3162
                        }
                        else {
                            sales.Material_Pricing_Group__c = 'E2 - Not Tracked, 38%'; //USST-3162
                        }
                    }
                    else if (sales.territory__c == 'US' && (mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)')) {
                        sales.Material_Pricing_Group__c = 'E8 - Not Tracked, 44%'; //USST-3162
                    }
                    else if (sales.territory__c == 'CDN' && (mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)')) {
                        if (mat.Title_Source__c == '02 - TELEVISION') {
                            sales.Material_Pricing_Group__c = 'D5 - Not Tracked, 32%'; //USST-3162
                        }
                        else {
                            sales.Material_Pricing_Group__c = 'E1 - Not Tracked, 37%'; //USST-3162
                        }
                    }
                }
                //USST-2493--- end :: Defaulting for MaterialPricing Group
                
                // Adding sales instance into list
                insertableSalesList.add(sales);
            }
        }
        
        // Inserting Sales records.
        if(insertableSalesList.size() > 0)
            Database.upsert(insertableSalesList, false);
        
    }
    
    // Follwoing thod is responsible to populate Plant default values according to Defaulting Setup.
    public static void populatePlantDefaultValues()
    {
   
        Set<Id> matIds = new Set<Id>();
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        else if(Trigger.isExecuting && Trigger.isUpdate && (materialsWithLabelChangedIds == null || materialsWithLabelChangedIds.size() == 0))
            return;
        
        Map<Id, Map<String, Plant__c>> materialPlantMap = new Map<Id, Map<String, Plant__c>>();
        if(Trigger.isExecuting && Trigger.isUpdate && materialsWithLabelChangedIds.size() > 0)
        {
            for(Plant__c plant : [SELECT Id, Material__c, Territory__c,Bwd_Cons_Period__c,Min_Lot_Size__c,Component_Scrap_Percentage__c 
                                  FROM Plant__c WHERE Material__c IN :materialsWithLabelChangedIds])
            {
                if(!materialplantMap.containsKey(plant.Material__c))
                {
                    materialplantMap.put(plant.Material__c, new Map<String, Plant__c>());
                }
                
                if(plant.Territory__c == null)
                    materialplantMap.get(plant.Material__c).put('US', plant);
                else
                    materialplantMap.get(plant.Material__c).put(plant.Territory__c, plant);
            }
        }
        
        List<Plant__c> insertablePlantList = new List<Plant__c>();
        
        for(SObject rec : processingMaterials)
        {
            if(Trigger.isExecuting && Trigger.isUpdate && !materialsWithLabelChangedIds.contains(rec.Id))
                continue;
            
            Material__c mat = (Material__c) rec;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Plant__c plant;
                
                if(Trigger.isExecuting && Trigger.isUpdate)
                {
                    if(territories != null && territories.size() > 0)
                        plant = materialplantMap.get(mat.Id).get(territories[i]);
                    else
                        plant = materialplantMap.get(mat.Id).get('US');
                }
                else
                {
                    plant = new Plant__c();
                    // Assigning child records to parent material.
                    if(mat.Id != null)
                    {
                        plant.Material__c = mat.Id;
                    }
                }
                
                if(territories != null && territories.size() > 0)
                    plant.Territory__c = territories[i];
                
                if(rec.get('Function__c') == '004')
                {
                    plant.Function__c = '023';
                }
                
                plant.Valid_From__c = Date.today();
                
                // Iterates over Plant fields in the map.
                populateSixConstraintDefault(rec, plant, 'Plant__c', ((territories != null && territories.size() > 0) ? territories[i] : null));
                
                // For cloning where field does not depend on 6 constraint and additional defaulting
                setCloningSpecificDefault(plant, 'Plant__c');
                
                // Copying value from existing material for cloning where defaulting not required.
                if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c) &&
                   cloningObjectFieldsMap.containsKey('Plant__c'))
                {
                    // As it may come from before insert where there would not be ID, keeping name value.
                    Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                    Plant__c sourcePlant;
                    for(Plant__c oPlant : sourceMat.Plants__r)
                    {
                        //USST-2968 --- start
                        if (sourceMat.Territory__c == mat.Territory__c) {
                            if(oPlant.Plant__c == plant.Plant__c)
                            {
                                sourcePlant = oPlant;
                                break;
                            }
                        }
                        else if (sourceMat.Territory__c == 'US & CDN') {
                            if (oPlant.Territory__c == plant.Territory__c ) {
                                sourcePlant = oPlant;
                                break;
                            }
                        }
                        else {
                            sourcePlant = oPlant;
                            break;
                        }
                        //USST-2968 --- end
                        
                    }
                    
                    if(sourcePlant != null)
                    {
                        for(String plantFieldAPI : cloningObjectFieldsMap.get('Plant__c'))
                        {
                            for(String constraintName : constraintObjectFieldMap.keySet())
                            {
                                List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Plant__c').get(plantFieldAPI);
                                for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                                {
                                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    {
                                        plant.put(plantFieldAPI, sourcePlant.get(plantFieldAPI));
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(plant.Plant__c == 'V500 - Technicolor')
                    plant.Stor_Loc_EP__c = '0020';
                else if(plant.Territory__c != null)
                {
                    if(plant.Territory__c == 'US')
                        plant.Stor_Loc_EP__c = '0010';
                    else if(plant.Territory__c == 'CDN')
                        plant.Stor_Loc_EP__c = '0101';
                }
                
                if(mat.Material_Type__c == 'Z009')
                {
                    plant.Indv_Colle__c = null;
                }
                //DF-01950 START
                if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                    plant.Plant_Specific_Matl_Status__c = 'NR - New Release';
                else if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c < Date.today())
                    plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                else if(mat.Item_Code__c == 'BF - BABY FERT')
                    plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                else if(mat.Material_Type__c == 'FERT')
                    plant.Plant_Specific_Matl_Status__c = 'FR - Future Release';
                else
                    plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                //DF-01950 END
                // Adding Plant instance into list
                insertablePlantList.add(plant);
            }
        }
        
        // Inserting Plant records.
        if(insertablePlantList.size() > 0)
        {
            Boolean tmpFlagHolder = TriggerUtility.doNotExecute;
            TriggerUtility.doNotExecute = false;
            Database.upsert(insertablePlantList, false);
            TriggerUtility.doNotExecute = tmpFlagHolder;
        }
    }
    
    // Follwoing thod is responsible to populate Classification default values according to Defaulting Setup.
    public static void populateClassificationDefaultValues()
    {
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        else if(Trigger.isExecuting && Trigger.isUpdate && (materialsWithLabelChangedIds == null || materialsWithLabelChangedIds.size() == 0))
            return;
        
        Map<Id, Classification__c> materialclsMap = new Map<Id, Classification__c>();
        Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();  
        if(Trigger.isExecuting && Trigger.isUpdate && materialsWithLabelChangedIds.size() > 0)
        {
            for(Classification__c cls : [SELECT Id, Material__c, Territory__c 
                                         FROM Classification__c 
                                         WHERE Material__c IN :materialsWithLabelChangedIds AND RecordTypeId=:generalRecordTypeId])
            {
                materialclsMap.put(cls.Material__c, cls);
            }
        }
        
        List<Classification__c> insertableClassificationList = new List<Classification__c>();
        
        set<id> matId = new set<id>();
        for(SObject rec : processingMaterials)
        {
            if(Trigger.isExecuting && Trigger.isUpdate && !materialsWithLabelChangedIds.contains(rec.Id))
                continue;
            
            Material__c mat = (Material__c) rec;
            matId.add(mat.id);
        }
        
        Map<Id, Classification__c> materialClassificationMap = new Map<Id, Classification__c>();
        for(Classification__c clRec : [SELECT Id, Material__c 
                                       FROM Classification__c 
                                       WHERE Material__c IN :matId AND RecordTypeID=:generalRecordTypeId])
        {
            if(clRec.Material__c != null)
                materialClassificationMap.put(clRec.Material__c, clRec);
        }
        
        for(SObject rec : processingMaterials)
        {
            if(Trigger.isExecuting && Trigger.isUpdate && !materialsWithLabelChangedIds.contains(rec.Id))
                continue;
            
            Material__c mat = (Material__c) rec;
                Classification__c cls;
                
                if(Trigger.isExecuting && Trigger.isUpdate && materialclsMap.containsKey(mat.Id))
                {
                    cls = materialclsMap.get(mat.Id);
                }
                else
                {
                    if(materialClassificationMap.size() > 0 && materialClassificationMap.containsKey(mat.Id)){
                        cls = materialClassificationMap.get(mat.Id);
                    }
                    else{
                        cls = new Classification__c(Function__c='009');
                        cls.Material__c = mat.Id;
                    } 
                }
                
                if(cls != null && mat.Territory__c != null && mat.Territory__c.trim() != '')
                {
                    cls.Territory__c = (mat.Territory__c.contains('US') ? 'US' : 'CDN');
                }
                
                // Iterates over Classification fields in the map.
                populateSixConstraintDefault(rec, cls, 'Classification__c', null);
                
                // For cloning where field does not depend on 6 constraint and additional defaulting
                setCloningSpecificDefault(cls, 'Classification__c');
                
                // Copying value from existing material for cloning where defaulting not required.
                if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c) && 
                   cloningObjectFieldsMap.containsKey('Classification__c'))
                {
                    // As it may come from before insert where there would not be ID, keeping name value.
                    Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                    Classification__c sourceCls;
                    for(Classification__c oCls : sourceMat.Classifications__r)
                    {
                        if(oCls.RecordTypeId == cls.RecordTypeId)
                        {
                            sourceCls = oCls;
                            break;
                        }
                    }
                    
                    if(sourceCls != null)
                    {
                        for(String clsFieldAPI : cloningObjectFieldsMap.get('Classification__c'))
                        {
                            for(String constraintName : constraintObjectFieldMap.keySet())
                            {
                                List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Classification__c').get(clsFieldAPI);
                                for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                                {
                                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    {
                                        cls.put(clsFieldAPI, sourceCls.get(clsFieldAPI));
                                    }
                                }
                            }
                        }
                    }
                }
                   if(mat.Material_Type__c == 'FERT' && titleMap != null && titleMap.size() > 0 && mat.Title__c != null && titleMap.containsKey(mat.Title__c) && 
                   titleMap.get(mat.Title__c).Genre_Primary__c != null && Genre_Code_Mapping__c.getInstance(titleMap.get(mat.Title__c).Genre_Primary__c) != null)
                {
                    cls.Genre_US__c = Genre_Code_Mapping__c.getInstance(titleMap.get(mat.Title__c).Genre_Primary__c).Genre_Code__c;
                }
                //Modified Regie sticker defaulting for USST-2400
                   if(mat.Material_Type__c == 'FERT' && ((mat.Item_Type__c == 'S (Single)' && mat.Item_Code__c != 'BF - BABY FERT') || mat.Item_Type__c == 'M (Multipack)') && mat.Territory__c != null && mat.Territory__c.contains('CDN') && LabelCode_Ignores_Regie__c.getInstance(mat.Label_Code__c) != null) {
                        cls.Regie_Sticker_for_Canada__c = '';
                   }
                   else {
                       cls.Regie_Sticker_for_Canada__c = 'Y - Yes';
                   }
                
                if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
                    cls.Aspect_Ratio__c = null;
                
                if(mat.Material_Type__c == 'FERT')
                {
                    system.debug('Label Code ::'+mat.Label_Code__c);
                    system.debug('Retailer Rental ::'+mat.Retailer_Rental__c );
                    if(mat.Label_Code__c == '59 - Paramount' && mat.Retailer_Rental__c == null)
                        cls.National_vs_Retailer__c = 'N - National';
                    else if(mat.Label_Code__c == '59 - Paramount' && (mat.Retailer_Rental__c == 'REN (RENTAL)' || mat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || mat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)'))
                        cls.National_vs_Retailer__c = 'N - National';
                    else if(mat.Label_Code__c == '59 - Paramount' && mat.Retailer_Rental__c != null)
                        cls.National_vs_Retailer__c = 'R - Retailer Specific';
                    else 
                        cls.National_vs_Retailer__c = null;
                    system.debug('National vs Retailer ::'+cls.National_vs_Retailer__c);
                    // Defaulting Run Time field from Title.
                        if(mat.Title__c != null && titleMap != null && titleMap.containsKey(mat.Title__c) && titleMap.get(mat.Title__c).Runtime_US__c != null)
                        cls.Run_Time__c = titleMap.get(mat.Title__c).Runtime_US__c;
                    
                    if(mat.Title__c != null && titleTMVersionMap != null && titleTMVersionMap.containsKey(mat.Title__c))
                    {
                        // Added for RE-61
                        if(titleTMVersionMap.get(mat.Title__c).Rating__c != null)
                        {
                            if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'NC17')
                                cls.Rating_US__c = '05 - NC-17';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'R')
                                cls.Rating_US__c = '04 - R';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'G')
                                cls.Rating_US__c = '01 - G';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'PG')
                                cls.Rating_US__c = '02 - PG';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'PG13')
                                cls.Rating_US__c = '03 - PG-13';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'NR')
                                cls.Rating_US__c = '07 - Not Rated';
                            else if(titleTMVersionMap.get(mat.Title__c).Rating__c == 'UR')
                                cls.Rating_US__c = '07 - Not Rated';
                        }
                        else
                        {
                            cls.Rating_US__c = null;
                        }
                    }
                }
                
                // Adding Classification instance into list
                insertableClassificationList.add(cls);
        }
        
        try{
            // Inserting Classification records.
            if(insertableClassificationList.size() > 0)
                Database.upsert(insertableClassificationList, false);
        } 
        catch(Exception ex){}
    }
    
    // Follwoing thod is responsible to populate Alternative Unit of Measure default values according to Defaulting Setup.
    public static void populateAUoMDefaultValues()
    {
        if(Trigger.isExecuting)
        {
            if(Trigger.isUpdate)
                return;
            processingMaterials = Trigger.New;
        }
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        
        List<Alternative_Unit_of_Measure__c> insertableAltUnitMeasureList = new List<Alternative_Unit_of_Measure__c>();
        List<Alternative_Unit_of_Measure__c> tempInsertableAltUnitMeasureList = new List<Alternative_Unit_of_Measure__c>();
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            
            tempInsertableAltUnitMeasureList.clear();
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            if(mat.Material_Type__c == 'FERT')
            {
                // Added for RE-17
                String dchainSpec = '';
                if(mat.Item_Type__c == 'D (Display Vehicle)' || Test.isRunningTest())
                {
                    if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                        dchainSpec = 'NR - New Release';
                    else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' && mat.Street_Date__c != null && mat.Street_Date__c < Date.today())
                        dchainSpec = 'AC - Active Catalog';
                    else if(mat.Item_Code__c == 'BF - BABY FERT')
                        dchainSpec = 'AC - Active Catalog';
                    else if(mat.Material_Type__c == 'FERT')
                        dchainSpec = 'FR - Future Release';
                    else
                        dchainSpec = 'NR - New Release';
                }
                
                Alternative_Unit_of_Measure__c alt1 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='EA - Each', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
                alt1.Length__c = .5;
                alt1.Width__c = 5.25;
                alt1.Height__c = 7.5;
                alt1.Length_Width_Height_Unit__c = 'IN';
                if(mat.Territory__c == 'CDN')
                    alt1.Territory__c = 'CDN';
                tempInsertableAltUnitMeasureList.add(alt1);
                Alternative_Unit_of_Measure__c alt2 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='RSU - Retail Sellable Unit', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
                // Added for RE-17
                if(mat.Item_Type__c == 'D (Display Vehicle)' && dchainSpec == 'FR - Future Release' && mat.Total_Item_Qty__c != null)
                    alt2.Denominator_Conversion__c = String.valueOf(Integer.valueOf(mat.Total_Item_Qty__c));
                
                if(mat.Territory__c == 'CDN')
                    alt2.Territory__c = 'CDN';
                tempInsertableAltUnitMeasureList.add(alt2);
                //USST-2246 START ---1
                if(mat.Territory__c != null && mat.Territory__c.trim() != '' && mat.Territory__c.contains('CDN')) 
                {
                    Alternative_Unit_of_Measure__c alt3 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='CCC - Canadian Carton Cnt', Denominator_Conversion__c='1', Territory__c='CDN');
                    if(mat.Item_Code__c =='VP - VALUE PACK' || mat.Item_Code__c =='CL - COLLECTION PACK' || mat.Item_Code__c =='XS - SPECIAL SINGLE')
                    {  //USST-2860 added VP   
                        alt3.Numerator_Conversion__c='15'; 
                    } 
                    else if(mat.Territory__c != null && mat.Territory__c.trim() != '' && mat.Territory__c.contains('CDN') && mat.Item_Type__c == 'D (Display Vehicle)')
                    {
                        alt3.Numerator_Conversion__c='1';
                    }   
                    else
                    {
                        alt3.Numerator_Conversion__c='30' ;
                    }   
                    tempInsertableAltUnitMeasureList.add(alt3);
                }
                
                //USST-2246 END ---1
                if(mat.Item_Type__c != 'D (Display Vehicle)')
                {
                    Alternative_Unit_of_Measure__c alt4 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='END - Exp# Disk', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
                    if(mat.Territory__c == 'CDN')
                        alt4.Territory__c = 'CDN';
                    tempInsertableAltUnitMeasureList.add(alt4);
                    Alternative_Unit_of_Measure__c alt5 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='ENU - Exp# Units', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
                    if(mat.Territory__c == 'CDN')
                        alt5.Territory__c = 'CDN';
                    tempInsertableAltUnitMeasureList.add(alt5);
                }
                //USST-2246 START ---2
                System.debug('*****altcarmat>'+mat.Territory__c);
                System.debug('*****altcarmat>'+mat.Item_Code__c);
                if(mat.Territory__c != null && mat.Territory__c.trim() != '' && mat.Territory__c.contains('US')) 
                {
                    Alternative_Unit_of_Measure__c alt6 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='CAR - US Carton', Denominator_Conversion__c='1', Territory__c='US');
                    if(mat.Item_Code__c =='VP - VALUE PACK' || mat.Item_Code__c =='CL - COLLECTION PACK' || mat.Item_Code__c =='XS - SPECIAL SINGLE')
                    {     //USST-2860 added VP  
                        alt6.Numerator_Conversion__c='15'; 
                    }
                    //USST-2349 START
                    else  if(mat.Item_Type__c == 'D (Display Vehicle)')
                    { 
                        alt6.Numerator_Conversion__c = '1';
                    }   
                    else
                    {
                    System.debug('*****altcarmat>'+alt6.Numerator_Conversion__c);
                        alt6.Numerator_Conversion__c = '30';
                    }
                    //USST-2349 END
                    tempInsertableAltUnitMeasureList.add(alt6);
                }
                
                //USST-2246 END ---2
            }
            else if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
            {
                Alternative_Unit_of_Measure__c alt7 = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='EA - Each', Denominator_Conversion__c='1', Numerator_Conversion__c='1');
                if(mat.Territory__c == 'CDN')
                    alt7.Territory__c = 'CDN';
                tempInsertableAltUnitMeasureList.add(alt7);
            }
            
            for(Alternative_Unit_of_Measure__c alt : tempInsertableAltUnitMeasureList)
            {
                if(rec.get('Function__c') == '004')
                {
                    alt.Function__c = '023';
                }
                
                // Assigning child records to parent material.
                if(mat.Id != null)
                {
                    alt.Material__c = mat.Id;
                }
                
                // Iterates over Alternative Unit of Measure fields in the map.
                populateSixConstraintDefault(rec, alt, 'Alternative_Unit_of_Measure__c', alt.Territory__c);
                
                // For cloning where field does not depend on 6 constraint and additional defaulting
                setCloningSpecificDefault(alt, 'Alternative_Unit_of_Measure__c');
                
                // Copying value from existing material for cloning where defaulting not required.
                if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c) && 
                   cloningObjectFieldsMap.containsKey('Alternative_Unit_of_Measure__c'))
                {
                    // As it may come from before insert where there would not be ID, keeping name value.
                    Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                    Alternative_Unit_of_Measure__c sourceAlt;
                    
                    for(Alternative_Unit_of_Measure__c oAlt : sourceMat.Alternative_Units_of_Measure__r)
                    {
                        //for DF-02137, uncommented for cloning of Alternative Unit of Measure Records
                        //USST-2961 --- start
                        if (sourceMat.Territory__c != 'US & CDN' && oAlt.Alternative_Unit_of_Measure__c == 'CCC - Canadian Carton Cnt' && alt.Alternative_Unit_of_Measure__c == 'CAR - US Carton') {
                            sourceAlt = oAlt;
                            sourceAlt.Alternative_Unit_of_Measure__c = 'CAR - US Carton';
                            sourceAlt.Numerator_Conversion__c = oAlt.Numerator_Conversion__c;
                            sourceAlt.Territory__c = 'US';
                            break;
                        }
                        else if (sourceMat.Territory__c != 'US & CDN' && oAlt.Alternative_Unit_of_Measure__c == 'CAR - US Carton' && alt.Alternative_Unit_of_Measure__c == 'CCC - Canadian Carton Cnt') {
                            sourceAlt = oAlt;
                            sourceAlt.Alternative_Unit_of_Measure__c = 'CCC - Canadian Carton Cnt';
                            sourceAlt.Numerator_Conversion__c = oAlt.Numerator_Conversion__c;
                            sourceAlt.Territory__c = 'CDN';
                            break;
                        }
                        else if((sourceMat.Territory__c != 'US & CDN' && alt.Alternative_Unit_of_Measure__c != 'CAR - US Carton' && alt.Alternative_Unit_of_Measure__c != 'CCC - Canadian Carton Cnt') && oAlt.Alternative_Unit_of_Measure__c == alt.Alternative_Unit_of_Measure__c) {
                            sourceAlt = oAlt;
                            break;
                        }
                        else if (oAlt.Alternative_Unit_of_Measure__c == alt.Alternative_Unit_of_Measure__c) {
                            sourceAlt = oAlt;
                            break;
                        }
                        //USST-2961 --- end
                    }
                    
                    if(sourceAlt != null)
                    {
                        for(String altFieldAPI : cloningObjectFieldsMap.get('Alternative_Unit_of_Measure__c'))
                        {
                            for(String constraintName : constraintObjectFieldMap.keySet())
                            {
                                List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Alternative_Unit_of_Measure__c').get(altFieldAPI);
                                for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                                {
                                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    {
                                        if (altFieldAPI != 'Denominator_Conversion__c') { //USST-2751
                                            alt.put(altFieldAPI, sourceAlt.get(altFieldAPI));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                insertableAltUnitMeasureList.add(alt);
            }
        }       
         
        // Inserting Alternative Unit of Measure records.
        if(insertableAltUnitMeasureList.size() > 0)
            insert insertableAltUnitMeasureList;
       
    }
    
    // Follwoing thod is responsible to populate valuation default values according to Defaulting Setup.
    public static void populateValuationDefaultValues()
    {
        if(Trigger.isExecuting)
            processingMaterials = Trigger.New;
        
        if(processingMaterials == null || processingMaterials.size() == 0)
            return;
        else if(Trigger.isExecuting && Trigger.isUpdate && (materialsWithLabelChangedIds == null || materialsWithLabelChangedIds.size() == 0))
            return;
        
        Map<Id, Map<String, Valuation__c>> materialvalMap = new Map<Id, Map<String, Valuation__c>>();
        if(Trigger.isExecuting && Trigger.isUpdate && materialsWithLabelChangedIds.size() > 0)
        {
            for(Valuation__c val : [SELECT Id, Material__c, Territory__c,Origin_Group__c,material__r.Component_Type__c,material__r.item_code__c 
                                  FROM Valuation__c WHERE Material__c IN :materialsWithLabelChangedIds])
            {
                if(!materialvalMap.containsKey(val.Material__c))
                {
                    materialvalMap.put(val.Material__c, new Map<String, Valuation__c>());
                }
                
                if(val.Territory__c == null)
                    materialvalMap.get(val.Material__c).put('US', val);
                else
                    materialvalMap.get(val.Material__c).put(val.Territory__c, val);
            }
        }
        
        List<Valuation__c> insertableValuationList = new List<Valuation__c>();
        for(SObject rec : processingMaterials)
        {
            if(Trigger.isExecuting && Trigger.isUpdate && !materialsWithLabelChangedIds.contains(rec.Id))
                continue;
            
            Material__c mat = (Material__c) rec;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Valuation__c valuation;
                
                if(Trigger.isExecuting && Trigger.isUpdate && materialvalMap!=null && materialvalMap.get(mat.Id)!=null)//updated for REL-12
                {
                    if(territories != null && territories.size() > 0)
                        valuation = materialvalMap.get(mat.Id).get(territories[i]);
                    else
                        valuation = materialvalMap.get(mat.Id).get('US');
                }
                else
                {
                    //As part of STY-870 no valuation views to be added for Z009
                    if(mat.material_type__c!='Z009'){
                        valuation = new Valuation__c();
                        
                        // Assigning child records to parent material.
                        if(mat.Id != null)
                        {
                            valuation.Material__c = mat.Id;
                        }
                    }
                }
                
                if(territories != null && territories.size() > 0 && valuation!=null)
                    valuation.Territory__c = territories[i];
                
                if(rec.get('Function__c') == '004' && valuation!=null)
                {
                    valuation.Function__c = '023';
                }
                
                // Iterates over Valuation fields in the map.
                populateSixConstraintDefault(rec, valuation, 'Valuation__c', ((territories != null && territories.size() > 0) ? territories[i] : null));
                
                // For cloning where field does not depend on 6 constraint and additional defaulting
                setCloningSpecificDefault(valuation, 'Valuation__c');
                
                // Copying value from existing material for cloning where defaulting not required.
                if(TriggerUtility.checkFromCloning && mat.CloneHelperField__c != null && originalMaterialMap.containsKey(mat.CloneHelperField__c) && 
                   cloningObjectFieldsMap.containsKey('Valuation__c'))
                {
                    // As it may come from before insert where there would not be ID, keeping name value.
                    Material__c sourceMat = originalMaterialMap.get(mat.CloneHelperField__c);
                    Valuation__c sourceVal;
                    for(Valuation__c oVal : sourceMat.Valuations__r)
                    {
                        //if(oVal.Valuation_Area__c == valuation.Valuation_Area__c)
                        {
                            sourceVal = oVal;
                            break;
                        }
                    }
                    
                    if(sourceVal != null)
                    {
                        for(String valFieldAPI : cloningObjectFieldsMap.get('Valuation__c'))
                        {
                            for(String constraintName : constraintObjectFieldMap.keySet())
                            {
                                List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Valuation__c').get(valFieldAPI);
                                for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                                {
                                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    {
                                        valuation.put(valFieldAPI, sourceVal.get(valFieldAPI));
                                        
                                    }
                                  
                                }
                            }
                        }
                    }
                }
                
                // Adding Valuation instance into list
                if(valuation != null)
                    insertableValuationList.add(valuation);
            }
        }
        
         // Inserting Valuation records.
        if(insertableValuationList.size() > 0)
        {
            //insert insertableValuationList;
              Database.upsert(insertableValuationList, false);
        }
    }
    
    private static Boolean allowToFetchAllDefaultData = false;
    // This method creates and populates default values in material's child object records.
    public static void createChildRecordForTerritoryChange()
    {
        // Switch off cloning
        Boolean captureCloningState = TriggerUtility.checkFromCloning;
        TriggerUtility.checkFromCloning = false;
        
        allowToFetchAllDefaultData = true;
        fetchCompleteDefaultData();
        allowToFetchAllDefaultData = false;
        
        // Initiating child record inserttion lists.
        List<Sales__c> insertableSalesList = new List<Sales__c>();
        List<Plant__c> insertablePlantList = new List<Plant__c>();
        List<Alternative_Unit_of_Measure__c> insertableAltUnitMeasureList = new List<Alternative_Unit_of_Measure__c>();
        List<Valuation__c> insertableValuationList = new List<Valuation__c>();
        Map<Id, String> materialTerritoryMap = new Map<Id, String>();
        //USST-2546 --- start
        List<ComponentExtensionOnClone__c> mcs = ComponentExtensionOnClone__c.getall().values();
        Boolean chkCompExt = false;
        IF(!Test.isRunningTest()){
            chkCompExt = mcs[0].checkFromComponentExtension__c; 
        }
        system.debug('chkCompExt :: '+chkCompExt);
        //USST-2546 --- end
        // Iterating on material records to populate values in all the material child records.
        for(SObject rec : Trigger.New)
        {
            Material__c mat = (Material__c) rec;
            Material__c oldMat = (Material__c) Trigger.oldMap.get(mat.Id);
            
            if(mat.Material_Type__c == 'Episode (HEEP)')
            {
                continue;
            }
            
            if(mat.Territory__c != oldMat.Territory__c && mat.Territory__c != null && mat.Territory__c.equalsIgnoreCase('US & CDN') && 
               (oldMat.Territory__c == 'US' || oldMat.Territory__c == 'CDN'))
            {
                String territory = '';
                if(oldMat.Territory__c == 'CDN')
                    territory = 'US';
                else if(oldMat.Territory__c == 'US')
                    territory = 'CDN';
                
                materialTerritoryMap.put(mat.Id, territory);
                // Creating sales instance
                Sales__c sales = new Sales__c(Territory__c=territory);
                sales.Valid_From__c = Date.today();
                
                // Creating Plant instance
                Plant__c plant = new Plant__c(Territory__c=territory);
                plant.Valid_From__c = Date.today();
                
                
                // Creating Alternative Unit of Measure instance
                Alternative_Unit_of_Measure__c alt;
                if(mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009' && territory == 'US')
                 { //USST-2246
                    alt = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='CAR - US Carton', Denominator_Conversion__c='1', Territory__c=territory);
                    if(mat.Item_Code__c =='CL - COLLECTION PACK' || mat.Item_Code__c =='XS - SPECIAL SINGLE')
                    {
                        alt.Numerator_Conversion__c='15';
                    }
                    else  if(mat.Item_Type__c == 'D (Display Vehicle)')
                    { 
                        alt.Numerator_Conversion__c = '1';
                    }   
                     else
                    {
                       alt.Numerator_Conversion__c = '30';
                    }
                    
                    insertableAltUnitMeasureList.add(alt);
                }
                else if(mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009' && territory == 'CDN')
                { //USST-2246
                    alt = new Alternative_Unit_of_Measure__c(Alternative_Unit_of_Measure__c='CCC - Canadian Carton Cnt', Denominator_Conversion__c='1', Territory__c=territory);
                     if(mat.Item_Code__c =='CL - COLLECTION PACK' || mat.Item_Code__c =='XS - SPECIAL SINGLE')
                     {
                         alt.Numerator_Conversion__c='15'; 
                     }
                     else  if(mat.Item_Type__c == 'D (Display Vehicle)')
                    { 
                        alt.Numerator_Conversion__c = '1';
                    }   
                     else
                    {
                       alt.Numerator_Conversion__c = '30';
                    }
                     
                    insertableAltUnitMeasureList.add(alt);
                }
                
                // Creating Valuation instance
                Valuation__c valuation;
                if(mat.Material_Type__c != 'Z009')
                    valuation = new Valuation__c(Territory__c=territory);
                
                if(rec.get('Function__c') == '004')
                {
                    sales.Function__c = '009';
                    plant.Function__c = '009';
                    if(alt != null)
                        alt.Function__c = '009';
                    if(valuation != null)
                        valuation.Function__c = '009';
                }
                
                // Assigning child records to parent material.
                if(mat.Id != null)
                {
                    sales.Material__c = mat.Id;
                    plant.Material__c = mat.Id;
                    if(alt != null)
                        alt.Material__c = mat.Id;
                    if(valuation != null)
                        valuation.Material__c = mat.Id;
                }
                
                // Iterates over Sales fields in the map.
                if(sales != null)
                { 
                System.Debug('*****Execute_Validation__c'+sales.Execute_Validation__c);
                    populateSixConstraintDefault(mat, sales, 'Sales__c', ((territory != null && territory != '') ? territory : null));
                        
                    if(mat.Item_Type__c == 'D (Display Vehicle)' || mat.Item_Code__c == 'BF - BABY FERT')
                    {
                        sales.Material_Group_2__c = null;
                    }
                    
                    if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                        sales.D_Chain_Spec__c = 'NR - New Release';
                    else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' && mat.Street_Date__c != null && mat.Street_Date__c < Date.today())
                        sales.D_Chain_Spec__c = 'AC - Active Catalog';
                    else if(mat.Item_Code__c == 'BF - BABY FERT')
                        sales.D_Chain_Spec__c = 'AC - Active Catalog';
                    else if(mat.Material_Type__c == 'FERT')
                        sales.D_Chain_Spec__c = 'FR - Future Release';
                    else
                        sales.D_Chain_Spec__c = 'NR - New Release';
                    
                     // Added for RE-33
                    sales.Execute_Validation__c = true;
                    
                    if(TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
                    {
                    System.Debug('--------Execute_Validation__c'+sales.Execute_Validation__c);
                        sales.Execute_Validation__c = false;
                    }
                    //USST-2493--- start :: Defaulting for MaterialPricing Group
                    if (mat.Material_Type__c == 'FERT') {
                        if (mat.Item_Type__c == 'D (Display Vehicle)') {
                            sales.Material_Pricing_Group__c = 'Z0 - Not Tracked';
                        }
                        else if (mat.Label_Code__c == '89 - FUNIMATION') {
                            sales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                        }
                        else if (mat.Label_Code__c == '45 - PICTUREHOUSE') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '57 - BLEECKER STREET') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '88 - Cinedigm') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '58 - HiT Entertainment') {
                            sales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                        }
                        else if (mat.Label_Code__c == '24 - PURE FLIX') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '49 - PBS') {
                            sales.Material_Pricing_Group__c = 'D8 - Not Tracked, 35%';
                        }
                        else if (mat.Label_Code__c == '86 – SHOUT! Factory') {
                            sales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                        }
                        else if (mat.Label_Code__c == '36 - NEON RATED LLC') {
                            sales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                        }
                        else if (mat.Label_Code__c == '32 - Elevation' && sales.territory__c == 'CDN') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '23 - Remstar' && sales.territory__c == 'CDN') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '78 - D Films' && sales.territory__c == 'CDN') {
                            sales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                        }
                        else if (mat.Label_Code__c == '59 - Paramount') {
                            if (mat.Title_Source__c == '02 - TELEVISION') {
                                sales.Material_Pricing_Group__c = 'D7 - Not Tracked, 34%'; //USST-3162
                            }
                            else {
                                sales.Material_Pricing_Group__c = 'E2 - Not Tracked, 38%'; //USST-3162
                            }
                        }
                        else if (sales.territory__c == 'US' && (mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)')) {
                            sales.Material_Pricing_Group__c = 'E8 - Not Tracked, 44%'; //USST-3162
                        }
                        else if (sales.territory__c == 'CDN' && (mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)')) {
                            if (mat.Title_Source__c == '02 - TELEVISION') {
                                sales.Material_Pricing_Group__c = 'D5 - Not Tracked, 32%'; //USST-3162
                            }
                            else {
                                sales.Material_Pricing_Group__c = 'E1 - Not Tracked, 37%'; //USST-3162
                            }
                        }
                    }
                    //USST-2493--- end :: Defaulting for MaterialPricing Group                
                    
                    
                    // Adding sales instance into list
                    insertableSalesList.add(sales);
                }
                
                // Iterates over Plant fields in the map.
                if(plant != null)
                {
                    populateSixConstraintDefault(mat, plant, 'Plant__c', ((territory != null && territory != '') ? territory : null));
                        
                    if(plant.Plant__c == 'V500 - Technicolor')
                        plant.Stor_Loc_EP__c = '0020';
                    else if(plant.Territory__c != null)
                    {
                        if(plant.Territory__c == 'US')
                            plant.Stor_Loc_EP__c = '0010';
                        else if(plant.Territory__c == 'CDN')
                            plant.Stor_Loc_EP__c = '0101';
                    }
                    
                    if(mat.Material_Type__c == 'Z009')
                    {
                        plant.Indv_Colle__c = null;
                    }
                    //DF-01950 START
                    if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c > Date.today())
                        plant.Plant_Specific_Matl_Status__c = 'NR - New Release';
                    else if((mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format_Description__c == 'EST (ELECTRONIC SELL THRU)') && mat.Street_Date__c != null && mat.Street_Date__c < Date.today())
                        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                    else if(mat.Item_Code__c == 'BF - BABY FERT')
                        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                    else if(mat.Material_Type__c == 'FERT')
                        plant.Plant_Specific_Matl_Status__c = 'FR - Future Release';
                    else
                        plant.Plant_Specific_Matl_Status__c = 'AC - Active Catalog';
                    //DF-01950 END
                    
                    // Added for RE-33
                    plant.Execute_Validation__c = true;
                    
                    if(TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
                        plant.Execute_Validation__c = false;
                    
                    // Adding Plant instance into list
                    insertablePlantList.add(plant);
                }
                
                // Iterates over Alternative Unit of Measure fields in the map.
                if(alt != null)
                {
                    populateSixConstraintDefault(mat, alt, 'Alternative_Unit_of_Measure__c', ((territory != null && territory != '') ? territory : null));
                    
                     // Added for RE-33
                    alt.Execute_Validation__c = true;
                    
                    if(TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
                        alt.Execute_Validation__c = false;                    
                }
                
                // Iterates over Valuation fields in the map.
                if(valuation != null)
                {
                    populateSixConstraintDefault(mat, valuation, 'Valuation__c', ((territory != null && territory != '') ? territory : null));
                    
                    // Added for RE-33
                    valuation.Execute_Validation__c = true;
                    
                    if(TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
                        valuation.Execute_Validation__c = false;
                    
                    // Adding Valuation instance into list
                    insertableValuationList.add(valuation);
                }
            }
        }
        
        // Inserting Sales records.
        if(insertableSalesList.size() > 0){
             system.debug('new sales created::'+insertableSalesList);
            insert insertableSalesList;
        }
        
        // Inserting Plant records.
        if(insertablePlantList.size() > 0)
            insert insertablePlantList;
        
        // Inserting Alternative Unit of Measure records.
        if(insertableAltUnitMeasureList.size() > 0)
            insert insertableAltUnitMeasureList;
        
        // Inserting Valuation records.
        if(insertableValuationList.size() > 0)
            insert insertableValuationList;
        
        if(materialTerritoryMap != null && materialTerritoryMap.size() > 0 && !chkCompExt) //USST-2546 --- start
        {
            SetAdditionalSalesDefaults instanceDefaults2 = new SetAdditionalSalesDefaults();
            instanceDefaults2.materialID = materialTerritoryMap.keySet();
            instanceDefaults2.materialTerritoryMap = materialTerritoryMap;
            instanceDefaults2.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults2);
            
            SetAdditionalPlantDefaults instanceDefaults3 = new SetAdditionalPlantDefaults();
            instanceDefaults3.materialID = materialTerritoryMap.keySet();
            instanceDefaults3.materialTerritoryMap = materialTerritoryMap;
            instanceDefaults3.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults3);
            
            SetAdditionalOtherDefaults instanceDefaults4 = new SetAdditionalOtherDefaults();
            instanceDefaults4.materialID = materialTerritoryMap.keySet();
            instanceDefaults4.materialTerritoryMap = materialTerritoryMap;
            instanceDefaults4.checkFromCloning = TriggerUtility.checkFromCloning;
            System.enqueueJob(instanceDefaults4);
        }
        
        TriggerUtility.checkFromCloning = captureCloningState;
    }
    
    // Following method is called for defaulting the additional fields for Sales object.
    public static void populateSalesAdditionalDefaultValues()
    {
        system.debug('I am checking here-----');
        Set<Id> matIds = new Set<Id>();
        for(SObject rec : processingMaterials)
        {
            matIds.add(rec.Id);
        }
        
        Map<Id, Map<String, Sales__c>> materialSalesMap = new Map<Id, Map<String, Sales__c>>();
        for(Sales__c sales : [SELECT Id, Material__c, Territory__c,Material__r.recordTypeId,Material__r.territory__c,Tax_Indicator__c
                              FROM Sales__c WHERE Material__c IN :matIds])
        {
            system.debug('2546 sales :: '+sales);
            if(!materialSalesMap.containsKey(sales.Material__c))
            {
                materialSalesMap.put(sales.Material__c, new Map<String, Sales__c>());
            }
            
            if(sales.Territory__c == null)
                materialSalesMap.get(sales.Material__c).put('US', sales);
            else
                materialSalesMap.get(sales.Material__c).put(sales.Territory__c, sales);
        }
        System.debug('*****materialSalesMap> '+materialSalesMap);
        
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            if(!materialSalesMap.containsKey(mat.Id))
                continue;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Sales__c sales;
                if(territories != null && territories.size() > 0)
                    sales = materialSalesMap.get(mat.Id).get(territories[i]);
                else
                    sales = materialSalesMap.get(mat.Id).get('US');
                
                // Iterates over Sales fields in the map.
                if(sales != null && objectFieldDefaultFieldMap.get('Sales__c') != null)
                {
                    system.debug('chkfromcloning :: '+TriggerUtility.checkFromCloning);
                    for(String salesFieldAPI : objectFieldDefaultFieldMap.get('Sales__c').keySet())
                    {
                        System.debug('*****SalesFields>> '+salesFieldAPI);
                        List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Sales__c').get(salesFieldAPI);
                        system.debug('I am checking the issue----'+defFieldMapList.size());
                        for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                        {
                            if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                                if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    continue;
                                else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                                {
                                    system.debug('I am coming in line no 2128---sales'+sales);
                                    system.debug('I am coming in line no 2128---salesFieldAPI'+salesFieldAPI);
                                    system.debug('I am coming in line no 2128---Cloning Default'+defFieldMap.Cloning_Default_Property__c);
                                    populateCloningDefault(sales, salesFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                    continue;
                                }
                                system.debug('I am coming in line no--- rec'+rec);
                                system.debug('I am coming in line no 2135---sales.Territory__c'+sales.Territory__c);
                                String value = AdditionalConstirantHelper.getConstirantValue(rec, salesFieldAPI, sales.Territory__c);
                                System.debug('Consolidated values---- '+salesFieldAPI+'::::'+sales.Territory__c+'::::'+value);
                                    system.debug('I am coming in line no 2137 Sales---'+sales);
                                    system.debug('I am coming in line no 2137 SalesFieldAPI---'+salesFieldAPI);
                                    system.debug('I am coming in line no 2137---Cloning Default'+defFieldMap.Cloning_Default_Property__c);
                                if(value != null) {
                                    system.debug('I am coming in line no 2143 Value---'+value);
                                    DefaultValueUtil.populateValues(sales, salesFieldAPI, value);
                                    continue;
                                }
                                
                            }
                            
                        }
                    }
                }
                
                if(sales != null)
                    sales.Additional_Default__c = true;
            }
        }
        
        List<Sales__c> updatetableSalesList = new List<Sales__c>();
        for(Id matId : materialSalesMap.keySet())
        {
            if(materialSalesMap.containsKey(matId))
                updatetableSalesList.addAll(materialSalesMap.get(matId).values());
        }
        
        if(!updatetableSalesList.isEmpty())
        {
            TriggerUtility.doNotExecute = true;
            List<ComponentExtensionOnClone__c> mcs = ComponentExtensionOnClone__c.getall().values();
             Boolean chkCompExt = false;
                IF(!Test.isRunningTest()){
                    chkCompExt = mcs[0].checkFromComponentExtension__c; 
                } 
             if(chkCompExt){
                 for(Sales__c objSales : updatetableSalesList){
                if(objSales.Tax_Indicator__c == null && objSales.Territory__c =='CDN' && fromCloning ){
                    objSales.Tax_Indicator__c = '1';
                }
            }
             }
            
            //USST-2546--- end
            update updatetableSalesList;
        }
    }
    
    // Following method is called for defaulting the additional fields for Plant object.
    public static void populatePlantAdditionalDefaultValues()
    {
    
        Set<Id> matIds = new Set<Id>();
        for(SObject rec : processingMaterials)
        {
            matIds.add(rec.Id);
        }
        
        Map<Id, Map<String, Plant__c>> materialPlantMap = new Map<Id, Map<String, Plant__c>>();
        for(Plant__c plant : [SELECT Id, Material__c, Territory__c,material__r.item_code__c,material__r.material_type__c,Min_Lot_Size__c,Material__r.Component_Type__c,Component_Scrap_Percentage__c 
                              FROM Plant__c WHERE Material__c IN :matIds])
        
        {
            if(!materialplantMap.containsKey(plant.Material__c))
            {
                materialplantMap.put(plant.Material__c, new Map<String, Plant__c>());
            }
            if(plant.Territory__c == null)
                materialplantMap.get(plant.Material__c).put('US', plant);
            else
                materialplantMap.get(plant.Material__c).put(plant.Territory__c, plant);
        }
        
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            if(!materialplantMap.containsKey(mat.Id))
                continue;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Plant__c plant;
                if(territories != null && territories.size() > 0)
                    plant = materialplantMap.get(mat.Id).get(territories[i]);
                else
                    plant = materialplantMap.get(mat.Id).get('US');
                
                // Iterates over Plant fields in the map.
                if(objectFieldDefaultFieldMap.get('Plant__c') != null)
                {
                    for(String plantFieldAPI : objectFieldDefaultFieldMap.get('Plant__c').keySet())
                    {
                        List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Plant__c').get(plantFieldAPI);
                        
                        for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                        {
                            if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                                if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    continue;
                                else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                                {
                                    populateCloningDefault(plant, plantFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                    continue;
                                }
                                
                                String value = AdditionalConstirantHelper.getConstirantValue(rec, plantFieldAPI, plant.Territory__c);
                                if(value != null) {
                                    DefaultValueUtil.populateValues(plant, plantFieldAPI, value);
                                    continue;
                                }
                            }
                        }
                    }
                }
                if(mat.Item_Code__c == 'CL - COLLECTION PACK' && plant.Territory__c == 'CDN'){

                }
                
                if(plant!=null)
                    plant.Additional_Default__c = true;    
            }
        }
        
        List<Plant__c> updatetableplantList = new List<Plant__c>();
        for(Id matId : materialplantMap.keySet())
        {
            if(materialplantMap.containsKey(matId))
                updatetableplantList.addAll(materialplantMap.get(matId).values());
        }
        
        if(!updatetableplantList.isEmpty())
        {
            TriggerUtility.doNotExecute = true;
            List<ComponentExtensionOnClone__c> mcs = ComponentExtensionOnClone__c.getall().values();
            Boolean chkCompExt = false;
            IF(!Test.isRunningTest()){
                chkCompExt = mcs[0].checkFromComponentExtension__c; 
            } 
            if(chkCompExt){
            for(Plant__c objPlant : updatetableplantList){
                if(objPlant.Bwd_Cons_Period__c == null ){
                  if(objPlant.material__r.material_type__c == 'FERT'){
                      objPlant.Bwd_Cons_Period__c = '000';
                      }
                  else if(objPlant.material__r.material_type__c == 'Z009'){
                        objPlant.Bwd_Cons_Period__c = '000';
                  }
                  else if(objPlant.material__r.material_type__c == 'ROH'){
                        objPlant.Bwd_Cons_Period__c = '000' ;
                  }
                    
                }
                if(objPlant.Component_Scrap_Percentage__c == null){
                    if(objPlant.Material__r.Component_Type__c =='CORRUGATE'){
                          objPlant.Component_Scrap_Percentage__c = 1.5;
                     }
                     else if(componentTypetoVal.containskey(objPlant.Material__r.Component_Type__c)){
                           objPlant.Component_Scrap_Percentage__c = componentTypetoVal.get(objPlant.Material__r.Component_Type__c);
                      }
                      else{
                           objPlant.Component_Scrap_Percentage__c = 0;
                      }
                }
               // USST -2546 Start
                if(objplant.Min_Lot_Size__c == null && (objPlant.Material__r.Material_type__c =='ROH' || objPlant.Material__r.Material_type__c== 'Z009')){
                    system.debug('Checking for min Lot side---'+objPlant.id);
                       objplant.Min_Lot_Size__c = 0;
                  }
                  // USST - 2546 end
            }
            }
            update updatetableplantList;
        }
    }
    
    // Following method is called for defaulting the additional fields for Classification object.
    public static void populateClassificationAdditionalDefaultValues()
    {
        Set<Id> matIds = new Set<Id>();
        for(SObject rec : processingMaterials)
        {
            matIds.add(rec.Id);
        }
        
        Map<Id, Map<Id, Classification__c>> materialclsMap = new Map<Id, Map<Id, Classification__c>>();
        Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        Id componentRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Components').getRecordTypeId();
        for(Classification__c cls : [SELECT Id, Material__c, Territory__c, RecordTypeId 
                                     FROM Classification__c 
                                     WHERE Material__c IN :matIds])
        {
            if(!materialclsMap.containsKey(cls.Material__c))
            {
                materialclsMap.put(cls.Material__c, new Map<Id, Classification__c>());
            }
            
            materialclsMap.get(cls.Material__c).put(cls.RecordTypeId, cls);
        }
        
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            if(!materialclsMap.containsKey(mat.Id))
                continue;
            
            // Iterates over Classification fields in the map.
            if(objectFieldDefaultFieldMap.get('Classification__c') != null)
            {
                for(String clsFieldAPI : objectFieldDefaultFieldMap.get('Classification__c').keySet())
                {
                    Classification__c cls;
                    if(clsFieldAPI.equalsIgnoreCase('Component__c'))
                        cls = materialclsMap.get(mat.Id).get(componentRecordTypeId);
                    else
                        cls = materialclsMap.get(mat.Id).get(generalRecordTypeId);
                    
                    if(cls == null)
                    {
                        cls = materialclsMap.get(mat.Id).get(generalRecordTypeId);
                        if(cls != null)
                            cls.Additional_Default__c = true;    
                        continue;
                    }
                    
                    List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Classification__c').get(clsFieldAPI);
                    
                    for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                    {
                        if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                            if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                continue;
                            else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                            {
                                populateCloningDefault(cls, clsFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                continue;
                            }
                            
                            String value = AdditionalConstirantHelper.getConstirantValue(rec, clsFieldAPI, cls.Territory__c);
                            if(value != null) {
                                DefaultValueUtil.populateValues(cls, clsFieldAPI, value);
                                continue;
                            }
                        }
                    }
                    
                    cls.Additional_Default__c = true;    
                }
            }
        }
        
        List<Classification__c> updatetableclsList = new List<Classification__c>();
        for(Id matId : materialclsMap.keySet())
        {
            if(materialclsMap.containsKey(matId) && materialclsMap.get(matId) != null)
            {
                for(Classification__c cls : materialclsMap.get(matId).values())
                {
                    cls.Additional_Default__c = true;
                    updatetableclsList.add(cls);
                }
            }
        }
        
        try {
            if(!updatetableclsList.isEmpty())
            {
                TriggerUtility.doNotExecute = true;
                Database.update(updatetableclsList, false);
            }
        }
        catch(Exception ex) {}
    }
    
    // Following method is called for defaulting the additional fields for Alternative Unit of Measure object.
    public static void populateAUoMAdditionalDefaultValues()
    {
        Set<Id> matIds = new Set<Id>();
        for(SObject rec : processingMaterials)
        {
            matIds.add(rec.Id);
        }
        
        Map<Id, Map<String, Alternative_Unit_of_Measure__c>> materialaltMap = new Map<Id, Map<String, Alternative_Unit_of_Measure__c>>();
        for(Alternative_Unit_of_Measure__c alt : [SELECT Id, Material__c, Territory__c 
                              FROM Alternative_Unit_of_Measure__c WHERE Material__c IN :matIds])
        {
            if(!materialaltMap.containsKey(alt.Material__c))
            {
                materialaltMap.put(alt.Material__c, new Map<String, Alternative_Unit_of_Measure__c>());
            }
            
            if(alt.Territory__c == null)
                materialaltMap.get(alt.Material__c).put('US', alt);
            else
                materialaltMap.get(alt.Material__c).put(alt.Territory__c, alt);
        }
        
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            if(!materialaltMap.containsKey(mat.Id))
                continue;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Alternative_Unit_of_Measure__c alt;
                if(territories != null && territories.size() > 0)
                    alt = materialaltMap.get(mat.Id).get(territories[i]);
                else
                    alt = materialaltMap.get(mat.Id).get('US');
                
                // Iterates over Alternative Unit of Measure fields in the map.
                if(objectFieldDefaultFieldMap.get('Alternative_Unit_of_Measure__c') != null)
                {
                    for(String altFieldAPI : objectFieldDefaultFieldMap.get('Alternative_Unit_of_Measure__c').keySet())
                    {
                        List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Alternative_Unit_of_Measure__c').get(altFieldAPI);
                        
                        for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                        {
                            if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                                if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    continue;
                                else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                                {
                                    populateCloningDefault(alt, altFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                    continue;
                                }
                                
                                String value = AdditionalConstirantHelper.getConstirantValue(rec, altFieldAPI, alt.Territory__c);
                                if(value != null) {
                                    DefaultValueUtil.populateValues(alt, altFieldAPI, value);
                                    continue;
                                }
                            }
                        }
                    }
                }
                if(alt != null)
                    alt.Additional_Default__c = true;    
            }
        }
        
        List<Alternative_Unit_of_Measure__c> updatetablealtList = new List<Alternative_Unit_of_Measure__c>();
        for(Id matId : materialaltMap.keySet())
        {
            if(materialaltMap.containsKey(matId))
                updatetablealtList.addAll(materialaltMap.get(matId).values());
        }
        
        if(!updatetablealtList.isEmpty())
        {
            TriggerUtility.doNotExecute = true;
            update updatetablealtList;
        }
    }
    
    // Following method is called for defaulting the additional fields for Valuation object.
    public static void populateValuationAdditionalDefaultValues()
    {
       Set<Id> matIds = new Set<Id>();
        for(SObject rec : processingMaterials)
        {
            matIds.add(rec.Id);
        }
        
        Map<Id, Map<String, Valuation__c>> materialvalMap = new Map<Id, Map<String, Valuation__c>>();
        for(Valuation__c val : [SELECT Id, Material__c, Territory__c,Origin_Group__c,material__r.component_type__c,material__r.Material_Type__c,material__r.Item_Code__c
                              FROM Valuation__c WHERE Material__c IN :matIds])
        {
            if(!materialvalMap.containsKey(val.Material__c))
            {
                materialvalMap.put(val.Material__c, new Map<String, Valuation__c>());
            }
            
            if(val.Territory__c == null)
                materialvalMap.get(val.Material__c).put('US', val);
            else
                materialvalMap.get(val.Material__c).put(val.Territory__c, val);
        }
        
        for(SObject rec : processingMaterials)
        {
            Material__c mat = (Material__c) rec;
            if(!materialvalMap.containsKey(mat.Id))
                continue;
            List<String> territories;
            if(mat.Territory__c != null && mat.Territory__c.trim() != '')
            {
                territories = mat.Territory__c.trim().split(' & ');
            }
            Integer noOfExec = (territories != null && territories.size() > 0 ? territories.size() : 1);            
            
            for(Integer i = 0; i < noOfExec; i ++)
            {
                Valuation__c val;
                try
                {
                    if(territories != null && territories.size() > 0)
                        val = materialvalMap.get(mat.Id).get(territories[i]);
                    else
                        val = materialvalMap.get(mat.Id).get('US');
                }
                catch(Exception ex)
                {
                    continue;
                }
                
                // Iterates over Valuation fields in the map.
                if(val != null && objectFieldDefaultFieldMap.get('Valuation__c') != null)
                {
                    for(String valFieldAPI : objectFieldDefaultFieldMap.get('Valuation__c').keySet())
                    {
                        List<DefaultingFieldMapping__c> defFieldMapList = objectFieldDefaultFieldMap.get('Valuation__c').get(valFieldAPI);
                        
                        for(DefaultingFieldMapping__c defFieldMap : defFieldMapList)
                        {
                            if(defFieldMap.get('isAdditionalConstriant__c') != null && Boolean.valueOf(defFieldMap.get('isAdditionalConstriant__c'))){
                                if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                                    continue;
                                else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                                {
                                    populateCloningDefault(val, valFieldAPI, defFieldMap.Cloning_Default_Property__c);
                                    continue;
                                }
                                
                                String value = AdditionalConstirantHelper.getConstirantValue(rec, valFieldAPI, val.Territory__c);
                                if(value != null) {
                                    DefaultValueUtil.populateValues(val, valFieldAPI, value);
                                    continue;
                                }
                            }
                        }
                    }
                }
                if(val!=null)val.Additional_Default__c = true;    
            }
        }
        
        List<Valuation__c> updatetablevalList = new List<Valuation__c>();
        for(Id matId : materialvalMap.keySet())
        {
            if(materialvalMap.containsKey(matId))
                updatetablevalList.addAll(materialvalMap.get(matId).values());
        }
        
        if(!updatetablevalList.isEmpty())
        {
            TriggerUtility.doNotExecute = true;
            //USST-2546 Starts
            List<ComponentExtensionOnClone__c> mcs = ComponentExtensionOnClone__c.getall().values();
        Boolean chkCompExt = false;
        IF(!Test.isRunningTest()){
            chkCompExt = mcs[0].checkFromComponentExtension__c; 
        } 
        if(chkCompExt){
            for(Valuation__c objVal : updatetablevalList){
                if(objVal.Origin_Group__c == null  ){
                    if(objVal.material__r.material_type__c == 'ROH' && objVal.material__r.component_type__c == 'STICKER' ){
                        objVal.Origin_Group__c = '50';
                    }
                    if((objVal.material__r.material_type__c == 'ROH' && objVal.material__r.component_type__c == 'STICKER PREMIUM') || (objVal.material__r.material_type__c == 'Z009' && objVal.material__r.component_type__c == 'CORRUGATE') ){
                        if(objVal.material__r.item_code__c == 'PG - PACKAGING'){
                            objVal.Origin_Group__c = '40';
                        }
                        else if(objVal.material__r.item_code__c == 'DS - DISC' ||  objVal.material__r.item_code__c == 'DA - DISC ART' || objVal.material__r.item_code__c == 'DL - DISC LAYER'){
                             objVal.Origin_Group__c = '10';
                        }
                    }
                    if(objVal.material__r.material_type__c == 'Z009' && objVal.material__r.component_type__c != 'CORRUGATE'){
                        if(objVal.material__r.item_code__c == 'PG - PACKAGING'){
                            objVal.Origin_Group__c = '40';
                        }
                        else if(objVal.material__r.item_code__c == 'DS - DISC' ||  objVal.material__r.item_code__c == 'DA - DISC ART' || objVal.material__r.item_code__c == 'DL - DISC LAYER'){
                             objVal.Origin_Group__c = '10';
                        }
                    }
                     if(objVal.material__r.material_type__c == 'ROH' && objVal.material__r.component_type__c != 'STICKER PREMIUM'){
                        if(objVal.material__r.item_code__c == 'PG - PACKAGING'){
                            objVal.Origin_Group__c = '40';
                        }
                        else if(objVal.material__r.item_code__c == 'DS - DISC' ||  objVal.material__r.item_code__c == 'DA - DISC ART' || objVal.material__r.item_code__c == 'DL - DISC LAYER'){
                             objVal.Origin_Group__c = '10';
                        }
                    }
                    
                }
            }
            }
            // USST - 2546 end
            update updatetablevalList;
        }
    }
    
    private static void populateCloningDefault(SObject rec, String fieldAPI, String valueProperty)
    {
        if(rec != null && fieldAPI != null && valueProperty != null)
        {
            if(valueProperty.equalsIgnoreCase('Y W/ BLANK'))
            {
                rec.put(fieldAPI, null);
            }
            else if(valueProperty.equalsIgnoreCase('Y W/ FALSE'))
            {
                rec.put(fieldAPI, false);
            }
        }
    }
    
    // Following method is responsible to handle the defaulting following six constraint logic. 
    public static void populateSixConstraintDefault(SObject comparingIns, SObject operatingIns, String sObjectType, String territory)
    {
        if(comparingIns == null || operatingIns == null)
            return;
        
        Integer executedConstraints = -1;
        if(objectFieldConstraintMap.containsKey(sObjectType))
        {
            for(String fieldAPI : objectFieldConstraintMap.get(sObjectType).keySet())
            {
                executedConstraints = -1;
                for(String constraintName : objectFieldConstraintMap.get(sObjectType).get(fieldAPI).keySet())
                {
                    // Checking if already executed constraint is greater than current constraint priority.
                    if(executedConstraints > orderOfConstraints.get(constraintName))
                        continue;
                        
                    DefaultingFieldMapping__c defFieldMap = objectFieldConstraintMap.get(sObjectType).get(fieldAPI).get(constraintName);
                    
                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                        continue;
                    else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                    {
                        populateCloningDefault(operatingIns, fieldAPI, defFieldMap.Cloning_Default_Property__c);
                        continue;
                    }
                        
                    if(constraintName != 'Territory' || sObjectType == 'Material__c' || sObjectType == 'Classification__c')
                    {
                        // Fetched the material value for the contraint field.
                        Object consFldVal = comparingIns.get(constraintObjectFieldMap.get(constraintName).materialFieldAPI);
                        if(consFldVal != null &&
                           constraintSearchValDefaultMap.get(constraintName).containsKey(String.valueOf(consFldVal)))
                        {
                            SObject defaultRecord = constraintSearchValDefaultMap.get(constraintName).get(String.valueOf(consFldVal));
                            if(defaultRecord != null && defaultRecord.get(defFieldMap.Defaulting_Field_API__c) != null)
                            {
                                if(fieldAPI.trim().containsIgnoreCase(' OR ') && sObjectType != 'Material__c' && sObjectType != 'Classification__c')
                                {
                                    List<String> splitFields = fieldAPI.split(' OR ');
                                    if(territory == null || (territory != null && territory.containsIgnoreCase('US')))
                                    {
                                        // Populating target object fields
                                        operatingIns.put(splitFields[0].trim(), defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                                    }
                                    else if(territory != null && territory.containsIgnoreCase('CDN'))
                                    {
                                        // Populating target object fields
                                        operatingIns.put(splitFields[1].trim(), defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                                    }
                                }
                                else
                                {
                                    // Populating target object fields
                                    operatingIns.put(fieldAPI, defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                                }
                                executedConstraints = orderOfConstraints.get(constraintName);
                            }
                        }
                    }
                    // For Territory constraint.
                    else if((sObjectType == 'Alternative_Unit_of_Measure__c' && territory != null) || sObjectType != 'Alternative_Unit_of_Measure__c')
                    {
                        SObject defaultRecord = constraintSearchValDefaultMap.get(constraintName).get(territory != null ? territory : 'US');
                        if(defaultRecord != null && String.valueOf(defaultRecord.Id.getSObjectType()).equalsIgnorecase(defFieldMap.Defaulting_Object_API__c) && defaultRecord.get(defFieldMap.Defaulting_Field_API__c) != null)
                        {
                            if(fieldAPI.trim().containsIgnoreCase(' OR '))
                            {
                                List<String> splitFields = fieldAPI.split(' OR ');
                                if(territory == null || (territory != null && territory.containsIgnoreCase('US')))
                                {
                                    // Populating operating instance fields
                                    operatingIns.put(splitFields[0].trim(), defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                                }
                                else if(territory != null && territory.containsIgnoreCase('CDN'))
                                {
                                    // Populating operating instance fields
                                    operatingIns.put(splitFields[1].trim(), defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                                }
                            }
                            else
                            {
                                // Populating operating instance fields
                                operatingIns.put(fieldAPI, defaultRecord.get(defFieldMap.Defaulting_Field_API__c));
                            }
                            executedConstraints = orderOfConstraints.get(constraintName);
                        }
                    }
                }
            }
        }
    }
    
    // For cloning where field does not depend on 6 constraint and additional defaulting
    public static void setCloningSpecificDefault(SObject operatingIns, String sObjectType)
    {
        if(TriggerUtility.checkFromCloning && objectFieldConstraint4ClnMap.containsKey(sObjectType))
        {
            for(String fieldAPI : objectFieldConstraint4ClnMap.get(sObjectType).keySet())
            {
                for(DefaultingFieldMapping__c defFieldMap : objectFieldConstraint4ClnMap.get(sObjectType).get(fieldAPI))
                {
                    if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c == 'N')
                        continue;
                    else if(TriggerUtility.checkFromCloning && defFieldMap.Cloning_Default_Property__c != 'Y')
                    {
                        populateCloningDefault(operatingIns, fieldAPI, defFieldMap.Cloning_Default_Property__c);
                    }
                }
            }
        }
    }
}