public class CIRFCorrugateUploadController {
    
    @AuraEnabled
    public Static String getCIRFCorrugateTemplate(){
        String TemplateColumns = 'Corrugate Request Name,Number of Stores,Corrugate Type,Street Date Sticker Required,PHE MPM Issue,Fully Built,Material Number,Facings,Units Per Pocket,Quebec Corrugate,Number Of Empties';
        return TemplateColumns;
    }
    
    @AuraEnabled
    public Static String checkValidations(Id recordId){
        CIRF_Header__c head  =[select id, CIRF_Status__c from CIRF_Header__c where id = :recordId];
        if(head.CIRF_Status__c == 'Complete'){
            return 'You cannot Upload Corrugates to this Header';
        }
        if(head.CIRF_Status__c != 'Draft' && head.CIRF_Status__c != 'Submitted'){
            return 'You cannot Upload Corrugates to this Header. Select Revise if you need to make any changes';
        }
        return 'success';
    }
    
    @AuraEnabled
    public static String CIRFCorrugateUpload(String uploadedFile,Id HeaderId){
        System.debug(uploadedFile);
        List<List<String>> finalFieldValues = CIRF_Utility.ReadCSV(uploadedFile);
        
        if(finalFieldValues.size()<=1){
            return 'blank';
        }
        
        system.debug(finalFieldValues);
        
        String newErrorFileLine = '';
        String Errorfile = '';
        Boolean errorFlag =  false;
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> Corfields= Schema.getGlobalDescribe().get('CIRF_Corrugate__c').getDescribe().fields.getMap();
        Map<String, SObjectField> CorMatfields= Schema.getGlobalDescribe().get('CIRF_Corrugate_Material__c').getDescribe().fields.getMap();
        
        List<String> headerVals = finalFieldValues.remove(0);
        
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        
        Map<String,String> csvFldNObjFldCorrugate=CIRF_Utility.mapCSVHeaderToFieldName(HeaderVals,'CIRF_Corrugate__c');
        Map<String,String> csvFldNObjFldCorMaterial=CIRF_Utility.mapCSVHeaderToFieldName(HeaderVals,'CIRF_Corrugate_Material__c');
        
        System.debug(csvFldNObjFldCorrugate);
        System.debug(csvFldNObjFldCorMaterial);
        
        List<CIRF_Corrugate__c> CorrugateList=new List<CIRF_Corrugate__c>();
        List<CIRF_Corrugate_Material__c> CorMaterialList=new List<CIRF_Corrugate_Material__c>();
        
        Map<String,CIRF_Corrugate__c> CorrugateMap= new Map<String,CIRF_Corrugate__c>();
        Map<String,CIRF_Corrugate_Material__c> CorMaterialMap= new Map<String,CIRF_Corrugate_Material__c>();
        
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>();
        Integer rowNum = 0; 
        Map<String,Integer> CorMatExternalIdRowNumMap = new Map<String,Integer>();
        Map<String,Integer> CorExternalIdRowNumMap = new Map<String,Integer>();
        
        //to get material numbers
        List<String> MaterialNumbers = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'Material Number'){
                    MaterialNumbers.add(cleanFields[j]);
                }
            }
        }
        System.debug(MaterialNumbers);
        //end
        
        List<Material__c> queryMaterials = [select id, Material_Number__c, RecordType.Name from Material__c where Material_Number__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        System.debug(queryMaterials);
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.Material_Number__c, mat);
            matIdNumMap.put(mat.id,mat.Material_Number__c);
        }
        
        for(List<String> cleanFields: finalFieldValues){
            CIRF_Corrugate__c corrugate= new CIRF_Corrugate__c();
            CIRF_Corrugate_Material__c CorMaterial = new CIRF_Corrugate_Material__c();
            
            newErrorFileLine = '';
            String errorMessage = '';
            
            corrugate.CIRF_Header__c = HeaderId;
            String MaterialNumber;
            Material__c relatedMaterial =  new Material__c();
            CIRF_Corrugate__c relatedCorrugate = new CIRF_Corrugate__c();
            
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFldCorrugate.get(headerVals[j])!=null && !Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().isCalculated()){
                            
                            if(Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.Date)
                            {
                                if(cleanFields[j]!=null && cleanFields[j]!='')
                                {
                                    String[] myDateOnly= cleanFields[j].split(' ');
                                    String[] strDate = myDateOnly[0].split('/');
                                    Integer myIntDate = integer.valueOf(strDate[1]);
                                    Integer myIntMonth = integer.valueOf(strDate[0]);
                                    Integer myIntYear = integer.valueOf(strDate[2]);
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),d);
                                }
                            } 
                            else if(Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.INTEGER){
                                if(Integer.valueOf(cleanFields[j])!=null && Integer.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),Integer.valueOf(cleanFields[j]));
                                }
                            }
                            else if(Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                                if(cleanFields[j] == '1'){
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),Boolean.valueOf('TRUE'));
                                }
                                else if(cleanFields[j] == '0'){
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),Boolean.valueOf('FALSE'));
                                }
                                else{
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),Boolean.valueOf(cleanFields[j]));
                                }
                            }
                            else if(Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.CURRENCY || Corfields.get(csvFldNObjFldCorrugate.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.DOUBLE){
                                if(Double.valueOf(cleanFields[j])!=null && Double.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),Double.valueOf(cleanFields[j]));
                                }
                            }
                            else
                            {
                                /*if(csvFldNObjFldCorrugate.get(headerVals[j]) == 'name')
{
//ExternalIdList.add(cleanFields[j]);
}*/
                                corrugate.put(csvFldNObjFldCorrugate.get(headerVals[j]),cleanFields[j]);
                            }
                        } 
                        if(csvFldNObjFldCorMaterial.get(headerVals[j])!=null && !CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().isCalculated()){
                            cleanfields[j] = cleanfields[j].trim();
                            if(CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.Date)
                            {
                                if(cleanFields[j]!=null && cleanFields[j]!='')
                                {
                                    String[] myDateOnly= cleanFields[j].split(' ');
                                    String[] strDate = myDateOnly[0].split('/');
                                    Integer myIntDate = integer.valueOf(strDate[1]);
                                    Integer myIntMonth = integer.valueOf(strDate[0]);
                                    Integer myIntYear = integer.valueOf(strDate[2]);
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                    CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),d);
                                }
                            } 
                            else if(CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.INTEGER){
                                if(Integer.valueOf(cleanFields[j])!=null && Integer.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),Integer.valueOf(cleanFields[j]));
                                }
                            }
                            else if(CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                                if(cleanFields[j] == '1'){
                                    CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),Boolean.valueOf('TRUE'));
                                }
                                else if(cleanFields[j] == '0'){
                                   CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),Boolean.valueOf('FALSE'));
                                }
                                else{
                                    CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),Boolean.valueOf(cleanFields[j]));
                                }
                            }
                            else if(CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.CURRENCY || CorMatfields.get(csvFldNObjFldCorMaterial.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.DOUBLE){
                                if(Double.valueOf(cleanFields[j])!=null && Double.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),Double.valueOf(cleanFields[j]));
                                }
                            }
                            else
                            {
                                /*if(csvFldNObjFldCorMaterial.get(headerVals[j]) == 'name')
{
//ExternalIdList.add(cleanFields[j]);
}*/
                                CorMaterial.put(csvFldNObjFldCorMaterial.get(headerVals[j]),cleanFields[j]);
                            }
                        }
                    }
                    if(headerVals[j] == 'Material Number'){
                        //relatedMaterial.Material_Number__c = cleanFields[j];
                        System.debug(cleanFields[j]);
                        System.debug(numberMaterialMap.get(cleanFields[j]));
                        if(cleanFields[j] != null || cleanFields[j] != ''){
                            if(numberMaterialMap.get(cleanFields[j])!=null) {
                                CorMaterial.Material_Name__c = (numberMaterialMap.get(cleanFields[j])).id;
                            }
                            else {
                                errorFlag = true;
                                errorMessage = 'Material Number does not exist! Please confirm your material and reload';
                            }
                        } else {
                            errorFlag = true;
                            errorMessage = 'Material Number is Required';
                        }
                    }
                } Catch(Exception e){
                    errorFlag = true;
                    //errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    errorMessage = headerVals[j] + ' is not in the correct format. Please update and reload';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            if(Corrugate.CIRF_Header__c != null && Corrugate.Corrugate_Request_Name__c != null && Corrugate.Corrugate_Request_Name__c != ''){
                Corrugate.Corrugate_External_Id__c = Corrugate.CIRF_Header__c + '' + Corrugate.Corrugate_Request_Name__c;
                CorExternalIdRowNumMap.put(Corrugate.Corrugate_External_Id__c,rowNum);
                if(matIdNumMap.get(CorMaterial.Material_Name__c) != null && matIdNumMap.get(CorMaterial.Material_Name__c) != ''){
                    CorMaterial.External_Id__c = Corrugate.Corrugate_External_Id__c + '' + matIdNumMap.get(CorMaterial.Material_Name__c);
                    relatedCorrugate.Corrugate_External_Id__c = Corrugate.Corrugate_External_Id__c;
                    CorMaterial.CIRF_Corrugate__r = relatedCorrugate;
                    //CorMaterial.Material_Name__r = relatedMaterial;
                    CorMatExternalIdRowNumMap.put(CorMaterial.External_Id__c,rowNum);
                }
                else{
                    errorFlag = true;
                    if(errorMessage == null || errorMessage == '')
                        errorMessage = 'Material Number is invalid';
                }
            } else {
                errorFlag = true;
                errorMessage = 'Corrugate Request Name is required';
            }
            
            if(errorMessage == '' || errorMessage == null){
                CorMaterialMap.put(CorMaterial.External_Id__c,CorMaterial);
                CorrugateMap.put(Corrugate.Corrugate_External_Id__c,Corrugate);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNum,errorMessage);
            rowNum++;
        }
        System.debug(CorrugateMap);
        System.debug(CorMaterialMap);
        
        List<CIRF_Corrugate__c> CorrugateUpsertList = CorrugateMap.values();
        List<CIRF_Corrugate_Material__c> CorMaterialUpsertList = CorMaterialMap.values();
        System.debug(CorMaterialMap);
        
        Database.UpsertResult[] urCorList = Database.upsert(CorrugateUpsertList, CIRF_Corrugate__c.Fields.Corrugate_External_Id__c, false);
        Database.UpsertResult[] urCorMatList = Database.upsert(CorMaterialUpsertList, CIRF_Corrugate_Material__c.Fields.External_Id__c, false);
        
        Integer counter = 0;
        for(Database.upsertResult ur : urCorList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                String extId = CorrugateUpsertList[counter].Corrugate_External_Id__c;
                Integer actualRow = CorExternalIdRowNumMap.get(extId);
                for(Database.Error er: ur.getErrors())
                {
                    System.debug(er);
                    errorFlag=true;
                    System.debug(er.getMessage());
                    errorMessage += ' ' + er.getMessage();
                }
                rowNumberErrorMap.put(actualRow,errorMessage.escapeCSV());
            }
            counter++;
        }
        Counter = 0;
        for(Database.upsertResult ur : urCorMatList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String extId = CorMaterialUpsertList[counter].External_Id__c;
                Integer actualRow = CorMatExternalIdRowNumMap.get(extId);
                String errorMessage = rowNumberErrorMap.get(actualRow);
                for(Database.Error er: ur.getErrors())
                {
                    System.debug(er);
                    errorFlag=true;
                    System.debug(er.getMessage());
                    errorMessage += ' ' + er.getMessage();
                }
                rowNumberErrorMap.put(actualRow,errorMessage.escapeCSV());
            }
            Counter++;
        }
        System.debug('*****'+rowNumberErrorMap);
        
        if(ErrorFlag == true){
            for(Integer index : rowNumberErrorMap.keySet()){
                errorFileLines[index+1] = errorFileLines[index+1].substring(0,errorFileLines[index+1].length()-1)+ ','+rowNumberErrorMap.get(index) + '\n';
            }
            //ErrorFileLines.add(0,String.join(Header,','));
            errorFile = String.join(ErrorfileLines,'');
            return errorFile;
        }
        return '';   
    }   
}