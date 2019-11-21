public class UploadCIRFMaterialsController {
    
    @AuraEnabled
    public Static String getCIRFMaterialTemplate(){
        //String TemplateColumns = 'Material Number,SRP,DRC,Account Retail Price,Promo Cost,Funding Notes,Units to Order,Replen Units,French Required,Sticker Price,Sticker Item Number,Genre/Location/Other Info';
        //return TemplateColumns;
        return Label.CIRF_Material_Upload_Template;
    }
    
     @AuraEnabled
    public Static String checkValidations(Id recordId){
        CIRF_Header__c head  =[select id, CIRF_Status__c from CIRF_Header__c where id = :recordId];
        if(head.CIRF_Status__c == 'Complete'){
            return 'You cannot Upload Materials to this Header';
        }
        if(head.CIRF_Status__c != 'Draft'){
            return 'You cannot Upload Materials to this Header. Select Revise if you need to make any changes';
        }
        return 'success';
    }
        
    
   
    @AuraEnabled
    public Static String UploadCIRFMaterials(String uploadedFile,Id HeaderId){
        
        List<List<String>> finalFieldValues = CIRF_Utility.ReadCSV(uploadedFile);
        System.debug('finalFieldValues '+finalFieldValues);
        if(finalFieldValues.size()<=1){
            return 'blank';
        }
        
        List<CIRF_Material__c> MaterialList=new List<CIRF_Material__c>();
        String newErrorFileLine = '';
        String Errorfile = '';
        integer count=0;
        Boolean errorFlag =  false;
        List<String> headerVals = finalFieldValues.remove(0);
        headervals[headerVals.size()-1] = headervals[headerVals.size()-1].substring(0,headervals[headerVals.size()-1].length()-1);
        
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('CIRF_Material__c').getDescribe().fields.getMap();
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        Map<String,String> csvFldNObjFld=CIRF_Utility.mapCSVHeaderToFieldName(HeaderVals,'CIRF_Material__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'Material Number'){
                    MaterialNumbers.add(cleanFields[j]);
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        
        List<Material__c> queryMaterials = [select id, Material_Number__c, RecordType.Name from Material__c where Material_Number__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        System.debug(queryMaterials);
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.Material_Number__c, mat);
            matIdNumMap.put(mat.id,mat.Material_Number__c);
        }
        System.debug(numberMaterialMap);
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, CIRF_Material__c> CIRFMaterialMap= new Map<String,CIRF_Material__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();
        
        for(List<String> cleanFields: finalFieldValues){
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            
            CIRF_Material__c Material= new CIRF_Material__c();
            Material.CIRF_Header__c = HeaderId;
            Id MaterialrecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
            Material__c relatedMaterial = new Material__c();//recordTypeId = MaterialrecordTypeId// To assign material to CIRF Material using Material Number
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated()){
                            
                            if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.Date)
                            {
                                if(cleanFields[j]!=null && cleanFields[j]!='')
                                {
                                    String[] myDateOnly= cleanFields[j].split(' ');
                                    String[] strDate = myDateOnly[0].split('/');
                                    Integer myIntDate = integer.valueOf(strDate[1]);
                                    Integer myIntMonth = integer.valueOf(strDate[0]);
                                    Integer myIntYear = integer.valueOf(strDate[2]);
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                    Material.put(csvFldNObjFld.get(headerVals[j]),d);
                                }
                            } 
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.INTEGER){
                                if(cleanFields[j]!=null && cleanFields[j]!='' && cleanFields[j].contains(',')){
                                    cleanFields[j] = (cleanFields[j]).remove(',');
                                }
                                if(cleanFields[j] != null && Integer.valueOf(cleanFields[j])!=null && Integer.valueOf(cleanFields[j])<0 ){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Integer.valueOf(cleanFields[j]));
                                }
                            }
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                                if(cleanFields[j]!=null && cleanFields[j] == '1'){
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Boolean.valueOf('TRUE'));
                                }
                                else if(cleanFields[j]!=null && cleanFields[j] == '0'){
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Boolean.valueOf('FALSE'));
                                }
                                else{
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Boolean.valueOf(cleanFields[j]));
                                }
                            }
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.CURRENCY || fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.DOUBLE){
                                if(cleanFields[j] != null && cleanFields[j] != ''){
                                    cleanFields[j] = (cleanFields[j]).removeStart('$');
                                    if(cleanFields[j] != null && cleanFields[j] != '' && cleanFields[j].contains(',')){
                                        cleanFields[j] = (cleanFields[j]).remove(',');
                                    }
                                    if(cleanFields[j] != null && cleanFields[j] != ''){
                                        if(Double.valueOf(cleanFields[j])!=null && Double.valueOf(cleanFields[j])<0){
                                            errorFlag = true;
                                            errorMessage = 'Only positive values are allowed';
                                        }
                                        else{
                                            Material.put(csvFldNObjFld.get(headerVals[j]),Double.valueOf(cleanFields[j]));
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if(csvFldNObjFld.get(headerVals[j]) == 'name')
                                {
                                    //ExternalIdList.add(cleanFields[j]);
                                }
                                Material.put(csvFldNObjFld.get(headerVals[j]),cleanFields[j]);
                                System.debug(cleanFields[j]);
                            }
                        } else if(headerVals[j] == 'Material Number'){
                            //relatedMaterial.Material_Number__c = cleanFields[j];
                            //System.debug(relatedMaterial);
                            //MaterialNumbers.add(cleanFields[j]);
                            System.debug(cleanFields[j]);
                            System.debug(numberMaterialMap.get(cleanFields[j]));
                            if(cleanFields[j] != null && cleanFields[j] != ''){
                                if(numberMaterialMap.get(cleanFields[j])!=null) {
                                    Material.Material_Name__c = (numberMaterialMap.get(cleanFields[j])).id;
                                }
                                else {
                                    errorFlag = true;
                                    //String temp = cleanFields[j];
                                    //System.debug('*** ' +String.escapeSingleQuotes(temp));
                                    errorMessage = 'Material Number does not exist! Please confirm your material and reload';
                                }
                            } else {
                                errorFlag = true;
                                errorMessage = 'Material Number is required.';
                            }
                        } 
                    } if(headerVals[j] == 'Material Number' && (cleanFields[j] == null || cleanFields[j] == '')){
                        errorFlag = true;
                        errorMessage = 'Material Number is required.';
                    }
                }
                Catch(Exception e){
                    errorFlag = true;
                    //errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    errorMessage = headerVals[j] + ' is not in the correct format. Please update and reload';
                    //newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            if(Material.Material_Name__c != null){
                String key=String.valueOf(Material.CIRF_Header__c) + '-' + String.valueOf(matIdNumMap.get(Material.Material_Name__c));
                Material.External_Id__c = key;
            }
            else{
                System.debug(errorMessage);
                /*errorflag = true;
                errorMessage = 'Material name is invalid';*/
            }
            
            if(errorMessage == '' || errorMessage == null){
                CIRFMaterialMap.put(Material.External_Id__c,Material);
                ExternalIdRowNumMap.put(Material.External_Id__c,rowNumber);
                MaterialList.add(Material);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }    
        
        List<CIRF_Material__c> materialUpsertList = CIRFMaterialMap.values();
        System.debug(CIRFMaterialMap.values());
        Database.UpsertResult[] urList = Database.upsert(CIRFMaterialMap.values(), CIRF_Material__c.Fields.External_Id__c, false);
        rowNumber = 0;
        
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