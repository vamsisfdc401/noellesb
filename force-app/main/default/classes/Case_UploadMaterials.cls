public class Case_UploadMaterials {
    @AuraEnabled
    public Static String UploadPPMaterials(String uploadedFile,Id HeaderId){
        
        List<List<String>> finalFieldValues = Promo_Utility.ReadCSV(uploadedFile);
        system.debug('fina values'+finalFieldValues.size());
        List<Price_Protection_Materials__c> MaterialList=new List<Price_Protection_Materials__c>();
        String newErrorFileLine = '';
        String Errorfile = '';
        integer count=0;
        Boolean errorFlag =  false;
        List<String> headerVals = finalFieldValues.remove(0);
        headervals[headerVals.size()-1] = headervals[headerVals.size()-1].substring(0,headervals[headerVals.size()-1].length()-1);
        
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('Price_Protection_Materials__c').getDescribe().fields.getMap();
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        Map<String,String> csvFldNObjFld=Promo_Utility.mapCSVHeaderToFieldName(HeaderVals,'Price_Protection_Materials__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        List<String> AccountNames = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'UPC'){
                    if (cleanFields[j] != '' && cleanFields[j] != null)
                    	MaterialNumbers.add(cleanFields[j]);
                }
                if(headerVals[j] == 'Account'){
                    AccountNames.add(cleanFields[j]);
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        
        List<Material__c> queryMaterials = [select id, Material_Number__c, Street_Date__c, UPC__c, Territory__c, CIRF_CDN_D_Chain_Spec__c, CIRF_US_D_Chain_Spec__c, Name, Label_Code__c, RecordType.Name from Material__c where UPC__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        List<Account> queryAccounts = [select id, Name from Account where Name IN :AccountNames AND RecordType.Name = 'UPHE Retailer'];
        System.debug(queryMaterials);
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        Map<String, Account> numberAccountMap = new Map<String, Account>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.UPC__c, mat);
            matIdNumMap.put(mat.id,mat.UPC__c);
        }
        for(Account Acc : queryAccounts){
            numberAccountMap.put(Acc.Name, Acc);
        }
        System.debug(matIdNumMap);
        system.debug(numberAccountMap);
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, Price_Protection_Materials__c> PromoMaterialMap= new Map<String,Price_Protection_Materials__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();
        
        for(List<String> cleanFields: finalFieldValues){
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            Price_Protection_Materials__c Material= new Price_Protection_Materials__c();
            Material.Price_Protection_Program__c = HeaderId;
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated() && headerVals[j]!= 'Account')
                        {
                            system.debug('TJ: Checking for field ' + headerVals[j]);
                             Promo_Utility.Checkvalues(cleanFields,csvFldNObjFld,j,Material,headerVals,fields);
                        } else if(headerVals[j] == 'UPC'){
                            System.debug(cleanFields[j]);
                            System.debug(numberMaterialMap.get(cleanFields[j]));
                            if(numberMaterialMap.get(cleanFields[j])!=null) {
                                Material.Material_Description__c = (numberMaterialMap.get(cleanFields[j])).id;
                            }
                            else {
                                errorFlag = true;
                                errorMessage = 'No material found for the UPC';
                            }
                        } else if(headerVals[j] == 'Material Description'){
                            
                        } else if(headerVals[j] == 'Account'){
                            system.debug('TJ: Came in mapping fields');
                            if (numberAccountMap.get(cleanFields[j]) != null) {
                                Material.Account__c = (numberAccountMap.get(cleanFields[j])).id;
                            } else {
                                Material.Account__c = '';
                            }
                        }
                    }
                }
                Catch(Exception e){
                    errorFlag = true;
                    errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    //newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            if(Material.Material_Description__c != null){// && Material.Material_Name__c != ''){
                String key=String.valueOf(Material.Price_Protection_Program__c) + '-' + String.valueOf(matIdNumMap.get(Material.Material_Description__c)) + '-' + String.valueOf(Material.Account__c);
                Material.ExternalId__c = key;
            }
            else{
                errorflag = true;
                errorMessage = 'Unable to process this record. Please provide a valid UPC';
            }
            
            if(errorMessage == '' || errorMessage == null){
                PromoMaterialMap.put(Material.ExternalId__c,Material);
                ExternalIdRowNumMap.put(Material.ExternalId__c,rowNumber);
                MaterialList.add(Material);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }    
        
        List<Price_Protection_Materials__c> materialUpsertList = PromoMaterialMap.values();
        System.debug(PromoMaterialMap.values());
        Database.UpsertResult[] urList = Database.upsert(PromoMaterialMap.values(), Price_Protection_Materials__c.Fields.ExternalId__c, false);
        rowNumber = 0;
        
        Integer counter = 0;
        for(Database.upsertResult ur : urList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                String extId = materialUpsertList[counter].ExternalId__c;
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
    
    @AuraEnabled
    public Static String UploadPPCaseMaterials(String uploadedFile,Id HeaderId, Boolean LoadViaUI){
        
        List<List<String>> finalFieldValues = Promo_Utility.ReadCSV(uploadedFile);
        system.debug('fina values'+finalFieldValues.size());
        List<Case_Materials__c> MaterialList=new List<Case_Materials__c>();
        String newErrorFileLine = '';
        String Errorfile = '';
        integer count=0;
        Boolean errorFlag =  false;
        List<String> headerVals = finalFieldValues.remove(0);
        if(LoadViaUI)
        	headervals[headerVals.size()-1] = headervals[headerVals.size()-1].substring(0,headervals[headerVals.size()-1].length()-1);
        
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('Case_Materials__c').getDescribe().fields.getMap();
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        Map<String,String> csvFldNObjFld=Promo_Utility.mapCSVHeaderToFieldName(HeaderVals,'Case_Materials__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'UPC' || headerVals[j] == 'PP UPC'){
                    if (cleanFields[j] != '' && cleanFields[j] != null)
                    	MaterialNumbers.add(cleanFields[j]);
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        
        String PriceProtection_Program = [select Associated_Price_Protection_Program__c from Case where Id = : HeaderId][0].Associated_Price_Protection_Program__c;
        
        List<Price_Protection_Materials__c> queryMaterials = [select id, Material_Number__c, UPC__c, Account__c, Format__c, New_Price__c, NEW_SRP__c, Old_Price__c, Old_SRP__c, Price_Protection_Amount_Per_Unit__c, Title__c from Price_Protection_Materials__c where UPC__c IN :MaterialNumbers AND Price_Protection_Program__c = : PriceProtection_Program];
        System.debug(queryMaterials);
        Map<String,Price_Protection_Materials__c> numberMaterialMap = new Map<String,Price_Protection_Materials__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Price_Protection_Materials__c mat : queryMaterials){
            numberMaterialMap.put(mat.UPC__c, mat);
            matIdNumMap.put(mat.id,mat.UPC__c);
        }
        System.debug(matIdNumMap);
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, Case_Materials__c> PromoMaterialMap= new Map<String,Case_Materials__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();
        
        Id CaseRecordTypeId = Schema.SObjectType.Case_Materials__c.getRecordTypeInfosByName().get('Price Protection Claim').getRecordTypeId();
        for(List<String> cleanFields: finalFieldValues){
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            Case_Materials__c Material= new Case_Materials__c();
            Material.Case__c = HeaderId;
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated()){
                            
                            // Only used to check Date values
                            Promo_Utility.Checkvalues(cleanFields,csvFldNObjFld,j,Material,headerVals,fields);
                        } else if(headerVals[j] == 'UPC'){
                            System.debug(cleanFields[j]);
                            System.debug(numberMaterialMap.get(cleanFields[j]));
                            if(numberMaterialMap.get(cleanFields[j])!=null) {
                                Material.PP_Material_Description__c = (numberMaterialMap.get(cleanFields[j])).id;
                            }
                            else {
                                errorFlag = true;
                                errorMessage = 'Invalid UPC';
                            }
                        } else if(headerVals[j] == 'Material Description'){
                            
                        }
                    }
                }
                Catch(Exception e){
                    errorFlag = true;
                    errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    //newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            if(Material.PP_Material_Description__c != null){// && Material.Material_Name__c != ''){
                String key=String.valueOf(Material.Case__c) + '-' + String.valueOf(matIdNumMap.get(Material.PP_Material_Description__c));
                Material.ExternalId__c = key;
            }
            else{
                errorflag = true;
                errorMessage = 'Unable to process this record. Please provide a valid UPC from the Program';
            }
            
            if(errorMessage == '' || errorMessage == null){
                PromoMaterialMap.put(Material.ExternalId__c,Material);
                ExternalIdRowNumMap.put(Material.ExternalId__c,rowNumber);
                MaterialList.add(Material);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }    
        
        List<Case_Materials__c> materialUpsertList = PromoMaterialMap.values();
        System.debug(PromoMaterialMap.values());
        Database.UpsertResult[] urList = Database.upsert(PromoMaterialMap.values(), Case_Materials__c.Fields.ExternalId__c, false);
        rowNumber = 0;
        
        Integer counter = 0;
        for(Database.upsertResult ur : urList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                String extId = materialUpsertList[counter].ExternalId__c;
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
    
    @AuraEnabled
    public Static String UploadShippingCaseMaterials(String uploadedFile,Id HeaderId, Boolean LoadViaUI){
        
        List<List<String>> finalFieldValues = Promo_Utility.ReadCSV(uploadedFile);
        system.debug('fina values'+finalFieldValues.size());
        List<Case_Materials__c> MaterialList=new List<Case_Materials__c>();
        String newErrorFileLine = '';
        String Errorfile = '';
        integer count=0;
        Boolean errorFlag =  false;
        List<String> headerVals = finalFieldValues.remove(0);
        if (LoadViaUI)
        	headervals[headerVals.size()-1] = headervals[headerVals.size()-1].substring(0,headervals[headerVals.size()-1].length()-1);
        
        String[] ErrorfileLines = new List<String>();
        
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get('Case_Materials__c').getDescribe().fields.getMap();
        String errline = String.join(headerVals,',');
        ErrorfileLines.add(errline.substring(0, errline.length()-1)+',ERRORS\n');
        Map<String,String> csvFldNObjFld=Promo_Utility.mapCSVHeaderToFieldName(HeaderVals,'Case_Materials__c');
        system.debug('csvFldNObjFld: ' + csvFldNObjFld);
        
        
        //to get material number
        List<String> MaterialNumbers = new List<String>();
        for(List<String> cleanFields: finalFieldValues){
            Integer j;
            for (j=0;j<headerVals.size();j++){
                if(headerVals[j] == 'UPC' || headerVals[j] == 'UPC #'){
                    if (cleanFields[j] != '' && cleanFields[j] != null)
                    	MaterialNumbers.add(cleanFields[j]);
                }
            }
        }
        //end
        System.debug(MaterialNumbers);
        
        List<Material__c> queryMaterials = [select id, Material_Number__c, Street_Date__c, UPC__c, Territory__c, CIRF_CDN_D_Chain_Spec__c, CIRF_US_D_Chain_Spec__c, Name, Label_Code__c, RecordType.Name from Material__c where UPC__c IN :MaterialNumbers AND (RecordType.Name = 'Material' OR RecordType.Name = 'Request')];
        System.debug(queryMaterials);
        Map<String,Material__c> numberMaterialMap = new Map<String,Material__c>();
        Map<Id,String> matIdNumMap = new Map<Id,String>();
        for(Material__c mat : queryMaterials){
            numberMaterialMap.put(mat.UPC__c, mat);
            matIdNumMap.put(mat.id,mat.UPC__c);
        }
        System.debug(matIdNumMap);
        integer rowNumber = 0;
        Map<Integer,String> rowNumberErrorMap= new Map<Integer,String>(); 
        
        Map<String, Case_Materials__c> PromoMaterialMap= new Map<String,Case_Materials__c>();
        Map<String, Integer> ExternalIdRowNumMap= new Map<String,Integer>();
        
        Id CaseRecordTypeId = Schema.SObjectType.Case_Materials__c.getRecordTypeInfosByName().get('Shipping Issues').getRecordTypeId();
        for(List<String> cleanFields: finalFieldValues){
            newErrorFileLine = '';
            //String errorFileLine ='';
            String errorMessage = '';
            
            Case_Materials__c Material= new Case_Materials__c();
            Material.Case__c = HeaderId;
            Integer j;
            for (j=0;j<headerVals.size();j++){
                try{
                    cleanfields[j] = cleanfields[j].trim();
                    if(cleanFields[j]!=null && cleanFields[j]!=''){
                        if(csvFldNObjFld.get(headerVals[j])!=null && !fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().isCalculated()){
                            Material.put('RecordTypeId', CaseRecordTypeId);
                            Promo_Utility.Checkvalues(cleanFields,csvFldNObjFld,j,Material,headerVals,fields);
                        } else if(headerVals[j] == 'UPC' || headerVals[j] == 'UPC #'){
                            System.debug(cleanFields[j]);
                            System.debug(numberMaterialMap.get(cleanFields[j]));
                            if(numberMaterialMap.get(cleanFields[j])!=null) {
                                Material.Material_Description__c = (numberMaterialMap.get(cleanFields[j])).id;
                            }
                            else {
                                errorFlag = true;
                                errorMessage = 'No material found for the UPC';
                            }
                        } else if(headerVals[j] == 'Material Description'){
                            
                        }
                    }
                }
                Catch(Exception e){
                    errorFlag = true;
                    errorMessage = 'Invalid value : '+ cleanFields[j] +' for field :' + headerVals[j];
                    //newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
                }
                newErrorFileLine+= cleanFields[j].escapeCSV() + ',';
            }
            
            if(Material.Material_Description__c != null){// && Material.Material_Name__c != ''){
                String key=String.valueOf(Material.Case__c) + '-' + String.valueOf(matIdNumMap.get(Material.Material_Description__c))  + '-' + String.valueOf(Material.Issue_Type__c) + '-' + String.valueOf(Material.Resolution_Request__c);
                Material.ExternalId__c = key;
            }
            else{
                errorflag = true;
                errorMessage = 'Unable to process this record. Please provide a valid UPC';
            }
            
            /*system.debug('Material.Issue_Type__c ' + Material.Issue_Type__c);
            system.debug('Material.Resolution_Request__c ' + Material.Resolution_Request__c);
            if(Material.Issue_Type__c == null || Material.Resolution_Request__c == null){
                system.debug('Inside here');
                errorflag = true;
                errorMessage = 'Issue Type and Resolution Request are required while adding Case Material records';
            }*/

            if(errorMessage == '' || errorMessage == null){
                PromoMaterialMap.put(Material.ExternalId__c,Material);
                ExternalIdRowNumMap.put(Material.ExternalId__c,rowNumber);
                MaterialList.add(Material);
            }
            ErrorfileLines.add(newErrorFileLine);
            rowNumberErrorMap.put(rowNumber,errorMessage);
            rowNumber++;
        }    
        
        List<Case_Materials__c> materialUpsertList = PromoMaterialMap.values();
        System.debug(PromoMaterialMap.values());
        Database.UpsertResult[] urList = Database.upsert(PromoMaterialMap.values(), Case_Materials__c.Fields.ExternalId__c, false);
        rowNumber = 0;
        
        Integer counter = 0;
        for(Database.upsertResult ur : urList)
        {
            System.debug(ur);
            if(!ur.isSuccess())
            {
                String errorMessage = '';
                String extId = materialUpsertList[counter].ExternalId__c;
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