public class UploadOrderMaterialsController {
    
    @AuraEnabled
    public Static String UploadOrderMaterials(String uploadedFile,Id HeaderId){
        //Read the CSV File
        List<List<String>> finalFieldValues = Promo_Utility.ReadCSV(uploadedFile);
        system.debug('fina values'+finalFieldValues.size());
        
        List<Promo_Order_Materials__c> MaterialList=new List<Promo_Order_Materials__c>();
        String newErrorFileLine = '';
        String Errorfile = '';
        integer count=0;
        Boolean errorFlag =  false;
        
        //Fetch the Header line from the CSV File
        List<String> headerVals = finalFieldValues.remove(0);
        headervals[headerVals.size()-1] = headervals[headerVals.size()-1].substring(0,headervals[headerVals.size()-1].length()-1);
        
        String[] ErrorfileLines = new List<String>();
        
        //Get the Object & its fields description such as API Names, Data Type
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('Promo_Order_Materials__c').getDescribe().fields.getMap();
        
        //Setup the Error File Headers
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        
        //Map the CSV Headers to their Field API Names
        Map<String,String> csvFldNObjFld=Promo_Utility.mapCSVHeaderToFieldName(HeaderVals,'Promo_Order_Materials__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        //Below loop is to separate the Lookup / Special fields from the general flow
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'Material Number'){
                    MaterialNumbers.add(cleanFields[j].trim());
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        
        //Fetch the list of Materials based on the query criterion
        List<Material__c> queryMaterials = [select id, Material_Number__c, Street_Date__c, UPC__c, Territory__c, CIRF_CDN_D_Chain_Spec__c, CIRF_US_D_Chain_Spec__c, Name, Label_Code__c, RecordType.Name from Material__c where Material_Number__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        System.debug(queryMaterials);
        
        //Map the Materials to Material Numbers and Materials to Material Ids
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.Material_Number__c, mat);
            matIdNumMap.put(mat.id,mat.Material_Number__c);
        }
        System.debug(matIdNumMap);
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, Promo_Order_Materials__c> PromoMaterialMap= new Map<String,Promo_Order_Materials__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();
        
        //Loop through all the CSV Lines of data
        for(List<String> cleanFields: finalFieldValues){
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            
            Promo_Order_Materials__c Material= new Promo_Order_Materials__c();
            Material.Order_ID__c = HeaderId;
            Integer j;
            //Loop through the CSV Headers and for each header map the field data in the CSV File
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated())
                        {
                            //Map the fields based on the field data type. The above if logic filters out the Lookup / Special fields defined earlier
                            Promo_Utility.Checkvalues(cleanFields,csvFldNObjFld,j,Material,headerVals,fields);
                        } else if(headerVals[j] == 'Material Number'){
                            System.debug(cleanFields[j]);
                            System.debug(numberMaterialMap.get(cleanFields[j]));
                            //Map the Material Number's Id to the Material Description field on the Promo Order Material object if Material is found
                            if(numberMaterialMap.get(cleanFields[j])!=null) {
                                Material.Material_Description__c = (numberMaterialMap.get(cleanFields[j])).id;
                            }
                            else {
                                errorFlag = true;
                                errorMessage = 'Invalid Material Number';
                            }
                        } else if(headerVals[j] == 'Material Description'){
                            //Do nothing if user inputs Material Description
                        }
                    }
                }
                Catch(Exception e){
                    //Come here in case of any exceptions
                    errorFlag = true;
                    errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    //newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            //Check if the Material Description was mapped. If it was, generate an External Id for processing. Else give error message
            if(Material.Material_Description__c != null){// && Material.Material_Name__c != ''){
                String key=String.valueOf(Material.Order_Id__c) + '-' + String.valueOf(matIdNumMap.get(Material.Material_Description__c));
                Material.External_Id__c = key;
            }
            else{
                errorflag = true;
                errorMessage = 'Material number is invalid';
            }
            
            //In case there are any error messages, build the error file
            if(errorMessage == '' || errorMessage == null){
                PromoMaterialMap.put(Material.External_Id__c,Material);
                ExternalIdRowNumMap.put(Material.External_Id__c,rowNumber);
                MaterialList.add(Material);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }    
        //End of looping through CSV Data
        
        //Upsert the data into the Promo Order Materials object
        List<Promo_Order_Materials__c> materialUpsertList = PromoMaterialMap.values();
        System.debug(PromoMaterialMap.values());
        Database.UpsertResult[] urList = Database.upsert(PromoMaterialMap.values(), Promo_Order_Materials__c.Fields.External_Id__c, false);
        rowNumber = 0;
        
        //Process the Upsert result and build a map for all the rows
        Integer counter = 0;
        for(Database.upsertResult ur : urList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                String extId = materialUpsertList[counter].External_Id__c;
                Integer actualRow = ExternalIdRowNumMap.get(extId);
                for(Database.Error er: ur.getErrors())
                {
                    System.debug(er);
                    errorFlag=true;
                    System.debug(er.getMessage());
                    errorMessage += ' ' + er.getMessage();
                }
                rowNumberErrorMap.put(actualRow,errorMessage);
            }
            rowNumber++;
            counter++;
        }
        System.debug(rowNumberErrorMap);
        
        //In case there were any errors, then setup the file in CSV format for output to the user
        if(ErrorFlag == true){
            for(Integer index : rowNumberErrorMap.keySet()){
                errorFileLines[index+1] = errorFileLines[index+1].substring(0,errorFileLines[index+1].length()-1)+ ','+rowNumberErrorMap.get(index) + '\n';
            }
            
            errorFile = String.join(ErrorfileLines,'');
            return errorFile;
        }
        return '';
    }
}