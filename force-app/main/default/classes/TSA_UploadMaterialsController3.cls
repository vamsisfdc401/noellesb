public class TSA_UploadMaterialsController3 {
    static final integer BATCH_SIZE = 300; 
    static final String INVALID_REQUEST = 'Invalid Upload Request - Status is not Draft';
    static final String INVALID_DELETE = 'Error(s) found when clearing out existing data - Error message: ';
    
    @AuraEnabled
    public static String doConstructor(Id HeaderId){
        Request_Header__c header = new Request_Header__c();
        header = [SELECT id, status__c from Request_Header__c where id =: HeaderId];
        return header.Status__c;
    }//end constructor
    
    @AuraEnabled
    public Static String UploadMaterials(String uploadedFile,Id HeaderId) {
        //file vars
        String file = EncodingUtil.urlDecode(uploadedFile, 'UTF-8');             
        String[] fileLines;
        String[] fileHeaders = new String[]{};
        List<String> fileHeadersCleaned = new List<String>{};
        
        //Salesforce field vars
        Map<String, SObjectField> fields;
        //map of field label and field API name, respectively
        Map<String,String> FieldlabelApiNameMap = new Map<String,String>();
        Map<String, String> acceptableMediaTypes = new Map<String, String>();
        Map<String, String> acceptableMediaNames = new Map<String, String>();
        
        //Request Material / Material vars
        List<Request_Material__c> RAMaterialList = new List<Request_Material__c>();
        Set<String> MaterialUploadSet = new Set<String>();
        Set<String> MaterialDuplicateSet = new Set<String>();
        Map<String, Material__c> MaterialMap = new Map<String, Material__c>();
        
        //batch vars
        List<Request_Detail__c> batchList = new List<Request_Detail__c>();
        
        //error vars
        String Errorfile = '';
        Boolean errorFlag =  false;
        String errorMessage = ' ';
        String errorFileLine ='';
        String[] ErrorfileLines = new List<String>();
        
        //Validate Request
        errorMessage = ValidateRequest(HeaderId);
        //Clear existing data
        errorMessage = ClearExistingData(HeaderId);
        
        //end vars and begin work --------------------------------------------------------------
        //--------------------------------------------------------------------------------------
        //--------------------------------------------------------------------------------------
        
        //setup object field vars
        fields = getObjectFields('Request_Material__c');
        FieldlabelApiNameMap = getObjectFieldsLabel(fields);
        acceptableMediaTypes = getMediaTypes();
        acceptableMediaNames = getMediaNames();
          
        //break apart file
        fileLines = file.split('\n');
        fileHeaders = filelines[0].split(',');
        system.debug('fileLines: ' + fileLines);
        system.debug('fileHeaders: ' + fileHeaders);

        
        //clean headers
        for(String columnHeader: fileHeaders){
            columnHeader = columnHeader.trim().toLowerCase();
            FileHeadersCleaned.add(columnHeader);
        }//end for loop
        
        //initialize error file
        ErrorfileLines.add(filelines[0].substring(0, filelines[0].length()-1)+',ERRORS\n');        
        
        //match columnHeaders to fields
        for(String columnHeader: FileHeadersCleaned){
            if(FieldlabelApiNameMap.containsKey(columnHeader)){
                system.debug('We found the API Name as: '+FieldlabelApiNameMap.get(columnHeader));    
            }//end if
            else{
                system.debug('We were not able to find the field to match this column: '+columnHeader);
                errorMessage = errorMessage + columnHeader + ': INVALID Column Name; ';
                ErrorFlag = true;
            }//end else
        }//end for loop
        
        //deal with column name problems
        if(ErrorFlag == true){
            errorMessage = 'ERROR: THE COLUMN NAMES ARE NOT CORRECT, PLEASE DOWNLOAD THE UPLOAD TEMPLATE AGAIN AND RETRY ||| ' + errorMessage;
            errorfileLines.add(errorFileLine.substring(0, errorFileLine.length())+errorMessage+'\n');
        }
        
        //remove header as it's not a Request Material row
        fileLines.remove(0);
        
        //gather material list
        for (String fileRow: fileLines){
            fileRow = fileRow.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            fileRow = fileRow.replaceAll('""','DBLQT');
            //system.debug('fileRow: ' + fileRow);
            List<String> rowColumnValues = new List<String>();
            rowColumnValues =splitFields(fileRow);
            //system.debug('rowColumnValues: ' + rowColumnValues.size());
            
            Integer columnNumber = 0;
            for(String columnValue: rowColumnValues){
                String headerValue = fileHeadersCleaned.get(columnNumber);
                //system.debug('headerValue: ' + fileHeadersCleaned.get(columnNumber));
                system.debug('header value: ' + headerValue);
                if(headerValue == 'Material Number'){
                    //system.debug('material number: ' + columnValue);
                    MaterialUploadSet.add(columnValue);   
                }//end if
                columnNumber++;
            }//end for columns
        }//end get material list

        system.debug('Material Set: ' + MaterialUploadSet);
        
        //setup Materials Map
        if (Test.isRunningTest())
            MaterialMap = TSA_TestDataFactory.createMaterialMap();
        else
            MaterialMap = getMaterials(MaterialUploadSet);
        
        system.debug('The value of the material map is: '+MaterialMap);  
        
        //go through each row for processing
        for (String fileRow: fileLines){
            errorFileLine = fileRow;
            errorMessage = '';
            Date adStart = Date.parse('1/1/1900');            
            Request_Material__c RAmaterial= new Request_Material__c();
            
            //go through each column of each row
            system.debug('fileRow: ' + fileRow);
            String[] rowColumnValues = new String[]{};
            rowColumnValues = splitFields(fileRow);
            system.debug('rowColumnValues: ' + rowColumnValues);
            
            Integer columnNumber = 0;
            for(String columnValue: rowColumnValues){
                //we have already validated that the field exists in Salesforce
                String headerValue = fileHeadersCleaned.get(columnNumber);
                String sfFieldAPIName = FieldlabelApiNameMap.get(headerValue);         
                
                //validations for each columnValue
                if(columnValue == ''){
                    //errorMessage = errorMessage + headerValue + ': Cannot be BLANK'
                }//end if column is blank
                
                if(headerValue == 'Material Number'){
                    Material__c material = new Material__c();
                    if(MaterialMap.containsKey(columnValue)) {
                        //  AL - HEITTSU-54 - Remove Material Duplicate Check
                        //  && !MaterialDuplicateSet.contains(columnValue)){
                        material = MaterialMap.get(columnValue);
                        RAMaterial.Material__c = material.id;
                        MaterialDuplicateSet.add(columnValue);
                    }//end check to see if material number is valid
                    else 
                    if (!MaterialMap.containsKey(columnValue)){
                        errorMessage = errorMessage + headerValue + ': INVALID Material Number; ';
                        errorFlag = true;
                    }
                    /*  AL - HEITTSU-54 - Remove Material Duplicate check
                    else if(MaterialDuplicateSet.contains(columnValue)){
                        errorMessage = errorMessage + headerValue + ': DUPLICATE Material Number; ';
                        errorFlag = true;
                    }
                    */
                }
                
                if(headerValue == 'Material Effective Date'){
                    try{
                        RAMaterial.TSA_Material_Effective_Date2__c = Date.parse(columnValue);
                    }//end try
                    catch(exception e){
                        errorMessage = errorMessage + headerValue + ': ' + e + '; ';
                        errorFlag = true;
                    }//end catch
                    
                }//end Material Effective Date column check
                
                if(headerValue == 'Ad Start Date'){
                    try{
                        RAMaterial.TSA_Ad_Start_Date__c = Date.parse(columnValue);
                        adStart = Date.parse(columnValue);
                    }//end try
                    catch(exception e){
                        errorMessage = errorMessage + headerValue + ': ' + e + '; ';
                        errorFlag = true;
                    }//end catch
                }//end Ad Start Date column check 
                
                if(headerValue == 'Ad End Date'){
                    try{
                        RAMaterial.TSA_Ad_End_Date__c = Date.parse(columnValue);    
                    }//end try
                    catch(exception e){
                        errorMessage = errorMessage + headerValue + ': ' + e + '; ';
                        errorFlag = true;
                    }//end catch
                    
                    if(RAMaterial.TSA_Ad_End_Date__c != null){
                        if(RAMaterial.TSA_Ad_End_Date__c < adStart){
                            errorMessage = errorMessage + headerValue + ': Ad End Date cannot be before Ad Start Date'+ '; ';    
                        }
                    }
                }//end Ad End Date column check 
                
                if(headerValue == 'Cost'){
                    try{
                        RAMaterial.TSA_Cost__c = Double.valueOf(columnValue);    
                    }//end try
                    catch(exception e){
                        errorMessage = errorMessage + headerValue + ': ' + e + '; ';
                        errorFlag = true;
                    }//end catch
                }//end Cost column check 
                
                //  AL - HEITTSU-55
                if(headerValue == 'Control Number'){
                    RAMaterial.TSA_Control_Number__c = columnValue;    
                } 
                
                if(headerValue == 'Media Type'){
                    //system.debug('---Media Type: ' + columnValue);
                    //system.debug('---acceptableMediaTypes: ' + acceptableMediaTypes);
                    if(acceptableMediaTypes.get(columnValue) != null){
                        RAMaterial.TSA_Media_Type__c = acceptableMediaTypes.get(columnValue);  
                        system.debug('---Media Type Insert: ' + acceptableMediaTypes.get(columnValue));  
                    }
                    else{
                        errorMessage = errorMessage + headerValue + ': INVALID Media Type; ';
                        errorFlag = true;    
                    }
                }//end Media Type column check 
                
                if(headerValue == 'Media Name'){
                    if(acceptableMediaNames.get(columnValue) != null){
                        RAMaterial.TSA_Media_Name__c = acceptableMediaNames.get(columnValue);    
                    }
                    else{
                        errorMessage = errorMessage + headerValue + ': INVALID Media Name; ';
                        errorFlag = true;    
                    }    
                }//end Media Name column check 
                
                if(headerValue == 'Comments'){
                    String trimmedcolumnValue = columnValue.left(255);
                    RAMaterial.TSA_Comments__c = trimmedcolumnValue;    
                }//end Comments column check 
            
               columnNumber++;
            }//end for loop for each column of each row
            
            if(errorFlag == False){
                RAMaterialList.add(RAMaterial);  
                //system.debug('---RAM Material: ' + RAMaterial);  
            }
            
            errorMessage = ',' + errorMessage;
            errorfileLines.add(errorFileLine.substring(0, errorFileLine.length()-1)+errorMessage+'\n');
            errorMessage = '';
            //add Material to a Set to ensure no duplicates.
            
        }//end for loop for fileRows
        
        If(fileLines.size() == 0){
            errorMessage = ', The file is EMPTY:';
            errorfileLines.add(errorFileLine.substring(0, errorFileLine.length())+errorMessage+'\n');
            errorFlag = true;
        }
        
        
        //do batch work if there are no errors
        If(ErrorFlag == false){           
            Decimal i = double.valueOf(RAMaterialList.size()) / BATCH_SIZE;
            Integer numBatches = (i.round(System.RoundingMode.CEILING)).intValue();
            //system.debug('number of Batches: ' + numBatches);
            
            //deal with batches
            Integer batchnum = 1;
            while(batchnum <= numBatches){
                Request_Detail__c batch = new Request_Detail__c();
                    batch.Status__c = 'Draft';
                    batch.Request_Header__c = headerId;
                    batch.TA_Batch_Number__c = batchnum;
                batchList.add(batch);
                batchnum++;
            }//end while
            try {
               insert batchList;
            }
            catch (DMLException e) {
                throw new DMLException('ERROR:  Batch Insert failed - ' + e.getMessage());
            }
            
        }//end batch work
        
        //do RA Material work if there are no errors
        If(ErrorFlag == false){
            for(Request_Detail__c batch: batchList){
                Integer recordNum = 1;
                Double totalCost = 0;
                for(Request_Material__c RAMaterial: RAMaterialList){
                    if(recordNum <= BATCH_SIZE){
                        If(RAMaterial.Request_Detail__c == null){
                            RAMaterial.Request_Detail__c = batch.id;
                            totalCost = totalCost + RAMaterial.TSA_Cost__c;
                            recordNum++;
                        }//end if not already added
                    }//end if under batch size
                    RAMaterial.Request_Header__c = headerId;
                    batch.TA_Batch_Number__c = recordNum;
                    //                                                                                                                                                                                                                                                                                                                  RAMaterial.TSA_Fund__c = '0001 - RMF';
                    batch.TSA_Cost_Total__c = totalCost;
                }//end RA Material for loop
            }//end batch for loop
            
            insert RAMaterialList;
            update batchList;
        }//end RA Materials work
      

        
        //Create Error file if there are errors       
        if(ErrorFlag == true){
            
            errorFile = String.join(ErrorfileLines,'');
            //System.debug('Error File: ' + errorFile);
            //System.debug('Error File CSV: ' + errorFile.escapeCSV());
            return errorFile;
        }
        
        return '';
    }//end main @AuraEnabled method
    
    
    public static Map<String, SObjectField> getObjectfields(String objectAPIName){
        Map<String, SObjectField> fields = new Map<String, SObjectField>();
        try{
            fields = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        }//end try
        catch(exception e){
            system.debug('There was a problem querying for the field Map');
        }//end catch
        return fields;  
    }//end getObjectfields method
    
    public static Map<String, String> getObjectfieldsLabel (Map<String, SObjectField> objectfieldMap){
        Map<String,String> FieldlabelApiNameMap = new Map<String,String>();
        try{
        for(String fieldName:objectfieldMap.keyset()){
                FieldlabelApiNameMap.put(objectfieldMap.get(fieldname).getDescribe().getLabel().toLowerCase(),fieldName);
            }//end for loop
        }//end try
        catch(exception e){
            system.debug('There was a problem querying for the field Labels');    
        }
        return FieldlabelApiNameMap;   
    }//end getObjectfieldsLabel method
    
    public static Map<String, String> getMediaTypes(){
        Map<String, String> mediaTypes = new Map<String, String>();
        
        Schema.DescribeFieldResult F = Request_Material__c.TSA_Media_Type__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        
        for(Schema.PicklistEntry pe: P){
            mediaTypes.put(pe.getLabel(), pe.getValue());
        }
        return mediaTypes;
    }
    
    public static Map<String, String> getMediaNames(){
        Map<String, String> mediaNames = new Map<String, String>();
        
        Schema.DescribeFieldResult F = Request_Material__c.TSA_Media_Name__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        
        for(Schema.PicklistEntry pe: P){
            mediaNames.put(pe.getLabel(), pe.getValue());
        }
        return mediaNames;
    }
    
        
    public static Map<String, Material__c> getMaterials(Set<String> mapNumbers){
        system.debug('getMaterials');
        Id MaterialrecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        List<Material__c> materialList = new List<Material__c>();
        Map<String, Material__c> MaterialMap = new Map<String, Material__c>();
        
        try{
            materialList = [SELECT id, Material_Number__c, Material_Type__c, Item_Type__c from Material__c 
                            WHERE Material_Type__c = 'FERT'
                           AND Item_Type__c != 'D (Display Vehicle)'
                           AND Item_Type__c != 'C - Components'
                           AND RecordTypeId =: MaterialrecordTypeId
                           AND Material_Number__c IN :mapNumbers];
            system.debug('Material List: ' + materialList);

        }//end try
        catch(exception e){
            system.debug('There was a problem getting the list of Materials from the database'); 
        }//end catch

        
        for(Material__c material: materialList){
            MaterialMap.put(material.Material_Number__c, material);   
        } 
        return MaterialMap;
    }//end getMaterials method
    
    public static String ClearExistingData(Id HeaderId) {
        //Delete TSA Batches and Materials
        string result;
        List<Request_Material__c> materialList = [select id from Request_Material__c where Request_Header__c =: HeaderId];
        List<Request_Detail__c> batchList = [select id from Request_Detail__c where Request_Header__c = : HeaderId];
        try {
            delete materialList;
            delete batchList;
        }
        Catch(Exception e){
             result = INVALID_DELETE + e.getMessage();
         }        
        return result;
    }//end ClearExistingDate method
    
    public static string ValidateRequest(Id HeaderId) {
        string result = '';
        Request_Header__c requestHeader = [select Id, Status__c from Request_Header__c where Id = :HeaderId limit 1];
        if (requestHeader.Status__c != 'Draft')
            result = INVALID_REQUEST;        
        return result;
    }//end ValidateRequest method
   
    public static List<string> splitFields(String row) {
        List<String> fields = row.split(',');
        system.debug('row: ' + fields);
            
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
            for(String field : fields) {
                //system.debug('field = ' + field);
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                    system.debug('field: ' + field);
                }
            }

        system.debug('cleanFields: ' + cleanFields);
        return cleanFields;
    
    }


}