public class CIRFMaterialExceptionsUpload {
	public static List<String> validExcType = new List<String>{'Distribution Only','Manufacturing and Distribution','Temporary Status Exception'};
    
    @AuraEnabled
    public Static String getCIRFMaterialExceptionTemplate(){
        String TemplateColumns = 'Material,Retailer,Exception Type,Start Date,End Date';
        return TemplateColumns;
    }
    
    @AuraEnabled
    public static String CIRFMaterialExceptionsUploadMethod(String uploadedFile){
     	System.debug(uploadedFile);
        List<List<String>> finalFieldValues = CIRF_Utility.ReadCSV(uploadedFile);
        
        if(finalFieldValues.size()<=1){
            return 'blank';
        }
        List<CIRF_Material_Exceptions__c> MaterialList=new List<CIRF_Material_Exceptions__c>();
		String newErrorFileLine = '';
        String Errorfile = '';
        Boolean errorFlag =  false;
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('CIRF_Material_Exceptions__c').getDescribe().fields.getMap();
        
        List<String> headerVals = finalFieldValues.remove(0);
        
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        Map<String,String> csvFldNObjFld=CIRF_Utility.mapCSVHeaderToFieldName(HeaderVals,'CIRF_Material_Exceptions__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        List<String> retailerNames = new List<String>();
        List<String> headerNames = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'Material'){
                    MaterialNumbers.add(cleanFields[j]);
                }
                else if(headerVals[j] == 'Retailer'){
                    retailerNames.add(cleanFields[j]);
                }
                else if(headerVals[j] == 'CIRF Header'){
                    headerNames.add(cleanFields[j]);
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        System.debug(retailerNames);
        
        //for querying materials
        List<Material__c> queryMaterials = [select id, Material_Number__c, RecordType.Name from Material__c where Material_Number__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        System.debug(queryMaterials);
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.Material_Number__c, mat);
            matIdNumMap.put(mat.id,mat.Material_Number__c);
        }
        System.debug(matIdNumMap);
        
        List<Account> queriedRetailers = [SELECT Id, Name, RecordType.Name FROM Account where RecordType.Name = 'UPHE Retailer' AND Name IN :retailerNames];
        Map<String, Id> retailerMap = new Map<String,Id>();
        for(Account acc : queriedRetailers){
            retailerMap.put(acc.Name, acc.Id);
        }
        
        List<CIRF_Header__c> queriedHeaders = [select id, Name from CIRF_Header__c where Name IN :headerNames];
        Map<String, Id> headerMap = new Map<String,Id>();
        for(CIRF_Header__c head : queriedHeaders){
            headerMap.put(head.Name, head.Id);
        }
        
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, CIRF_Material_Exceptions__c> CIRFMaterialMap= new Map<String,CIRF_Material_Exceptions__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();

        for(List<String> cleanFields: finalFieldValues){
            String key = '';
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            System.debug('cleanFields1 '+cleanFields);
            CIRF_Material_Exceptions__c Material= new CIRF_Material_Exceptions__c();
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    System.debug('cleanfields[j] '+cleanfields[j]);
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        //if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated()){
                            if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.Date)
                            {
                                System.debug('Inside date');
                                if(cleanFields[j]!=null && cleanFields[j]!='')
                                {
                                    String[] myDateOnly= cleanFields[j].split(' ');
                                    String[] strDate = myDateOnly[0].split('/');
                                    Integer myIntDate = integer.valueOf(strDate[1]);
                                    Integer myIntMonth = integer.valueOf(strDate[0]);
                                    Integer myIntYear = integer.valueOf(strDate[2]);
                                    Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                    Material.put(csvFldNObjFld.get(headerVals[j]),d);
                                    System.debug('Mat date '+ Material);
                                }
                            } 
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.INTEGER){
                                if(Integer.valueOf(cleanFields[j])!=null && Integer.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Integer.valueOf(cleanFields[j]));
                                }
                            }
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.BOOLEAN){
                                Material.put(csvFldNObjFld.get(headerVals[j]),Boolean.valueOf(cleanFields[j]));
                            }
                            else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.CURRENCY || fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.DOUBLE){
                                if(Double.valueOf(cleanFields[j])!=null && Double.valueOf(cleanFields[j])<0){
                                    errorFlag = true;
                                    errorMessage = 'Only positive values are allowed';
                                }
                                else{
                                    Material.put(csvFldNObjFld.get(headerVals[j]),Double.valueOf(cleanFields[j]));
                                }
                            }
                            /*else
                            {
                                if(csvFldNObjFld.get(headerVals[j]) == 'name')
                                {
                                    //ExternalIdList.add(cleanFields[j]);
                                }
                                Material.put(csvFldNObjFld.get(headerVals[j]),cleanFields[j]);
                                System.debug(cleanFields[j]);
                            }*/
                        //} 
                    else if(headerVals[j] == 'Material'){
                            if(cleanFields[j] != null && cleanFields[j] != ''){
                                if(numberMaterialMap.get(cleanFields[j])!=null) {
                                    Material.Material__c = (numberMaterialMap.get(cleanFields[j])).id;
                                    System.debug('mat '+Material.Material__c);
                                }
                                else {
                                    errorFlag = true;
                                    errorMessage = 'Material Number does not exist! Please confirm your material and reload';
                                }
                            } else {
                                errorFlag = true;
                                errorMessage = 'Material is required.';
                            }
                        }
                        else if(headerVals[j] == 'Retailer'){
                            if(cleanFields[j] != null && cleanFields[j] != ''){
                                if(retailerMap.get(cleanFields[j])!=null) {
                                    Material.Retailer__c = (retailerMap.get(cleanFields[j]));
                                    System.debug('ret '+Material.Retailer__c);
                                }
                                else {
                                    errorFlag = true;
                                    errorMessage = 'Invalid Retailer';
                                }
                            } else {
                                errorFlag = true;
                                errorMessage = 'Retailer is required.';
                            }
                        }
                        else if(headerVals[j] == 'CIRF Header'){
                            if(cleanFields[j] != null && cleanFields[j] != ''){
                                if(headerMap.get(cleanFields[j])!=null) {
                                    Material.CIRF_Header__c = (headerMap.get(cleanFields[j]));
                                    //System.debug('ret '+Material.Retailer__c);
                                }
                                else {
                                    errorFlag = true;
                                    errorMessage = 'Invalid Header';
                                }
                            }
                        }
                        else if(headerVals[j] == 'Exception Type'){
                            if(cleanFields[j] != null && cleanFields[j] != ''){
                                Material.Exception_Type__c = cleanFields[j];
                            }
                            else{
                                Material.Exception_Type__c = 'Temporary Status Exception';
                            }
                            if(!validExcType.contains(Material.Exception_Type__c)){
                                errorFlag = true;
                                errorMessage = '"Invalid exception type. Please use one of the following: Distribution Only, Manufacturing and Distribution, Temporary Status Exception"';
                            }
                        }
                    } if(headerVals[j] == 'Material' && (cleanFields[j] == null || cleanFields[j] == '')){
                        errorFlag = true;
                        errorMessage = 'Material is required.';
                    } if(headerVals[j] == 'Retailer' && (cleanFields[j] == null || cleanFields[j] == '')){
                        errorFlag = true;
                        errorMessage = 'Retailer is required.';
                    }
                }
                Catch(Exception e){
                    errorFlag = true;
                    //errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    errorMessage = headerVals[j] + ' is not in the correct format. Please update and reload';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                System.debug('errorMessage1 '+errorMessage);
            }
            System.debug('errorMessage out'+errorMessage);
            if(Material.Material__c != null){
                key=String.valueOf(Material.Material__c) + '-' + String.valueOf(Material.Retailer__c);
            }
            if(errorMessage == '' || errorMessage == null){
                MaterialList.add(Material);
                System.debug('Material added '+ MaterialList);
                ExternalIdRowNumMap.put(key,rowNumber);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }
        System.debug('ErrorfileLines '+ErrorfileLines);
        CIRFMaterialExceptionTriggerHandler.executedFromUpload = true;
        Database.UpsertResult[] urList = Database.upsert(MaterialList, false);
        rowNumber = 0;
        Integer counter = 0;
        for(Database.upsertResult ur : urList)
        {
            String key = '';
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                key=String.valueOf(MaterialList[counter].Material__c) + '-' + String.valueOf(MaterialList[counter].Retailer__c);
                Integer actualRow = ExternalIdRowNumMap.get(key);
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
        
    	return null;
    }
    
}