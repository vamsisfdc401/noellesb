public class Promo_Utility {
    
    @AuraEnabled
    public Static List<List<String>> ReadCSV(String uploadedFile){
        //Decode the file assuming it is in UTF-8 format
        String file = EncodingUtil.urlDecode(uploadedFile, 'UTF-8');
        //System.debug(file);
        String[] fileLines;
        
        //Prepare a list by splitting the entire output into New Line characters.
        fileLines = file.split('\n');
        //System.debug('file lines ++ ' + fileLines);
        List<List<String>> cleanFieldsList = new List<List<String>>();
        List<String> externalIdList=new List<String>();
        
        //Clean up each row item
        for (Integer i=0;i<fileLines.size();i++)
        {
            //Replace special characters
            fileLines[i]= fileLines[i].replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",').replaceall('\n','');
            fileLines[i]= fileLines[i].replaceAll('""','DBLQT');
            if (fileLines[i].replaceAll(',','').trim().length() == 0) continue;
            
            else
            {   
                //Split by ',' to get individual cell values
                List<String> fieldValues = filelines[i].split(',');  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                for(integer j=0;j<fieldvalues.size();j++ ) {
                    //Generate a composite field in case there are special characters like '"', 
                    String field=fieldValues[j];
                    if (field.startsWith('"') && field.endsWith('"') && field.length()!=1) 	{cleanFields.add(field.replaceAll('DBLQT','"'));}
                    else if (field.endsWith('"') && makeCompositeField) 					{compositeField += ',' + field; cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"')); makeCompositeField = false;}
                    else if (field.startsWith('"')) 										{makeCompositeField = true; compositeField = field; if(j==(fieldvalues.size()-1)){cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));}}
                    else if (makeCompositeField) 											{compositeField +=  ',' + field; if(j==(fieldvalues.size()-1)){cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));}}
                    else if(field.endsWith('"') && field.length()!=1 && cleanFields.size()> 0){string previousfield = ''; previousfield = cleanFields.get(cleanFields.size()-1); cleanFields.set(cleanFields.size()-1,previousfield+ ',' +field.replaceAll('"','').replaceAll('DBLQT','"'));}
                    else {cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));}
                }
                cleanFieldsList.add(cleanFields);                             
            }   
        } 
        //Build the list for consumption in code. The Header Values will be at Row # 0
        List<List<String>> finalFieldValues=new List<List<String>>();
        integer count=1;
        List<String> headerVals = cleanFieldsList[0];
        finalFieldValues.add(headerVals);
        while(count<cleanfieldsList.size())
        {
            while(cleanFieldsList[count].size()<headerVals.size())
            {
                //Loop through the cleaned up data and put in the list for consumption
                List<String> fieldList=cleanfieldsList[count]; cleanFieldsList.remove(count);
                fieldList[fieldList.size()-1]=fieldList[fieldList.size()-1]+'\n'+cleanFieldsList[count][0];
                for(integer i=1;i<cleanFieldsList[count].size();i++){fieldList.add(cleanFieldsList[count][i]);}
                cleanFieldsList[count]=fieldList;
            }
            List<String> fieldList = cleanFieldsList[count];
            fieldList[fieldList.size()-1] = fieldList[fieldList.size()-1].substring(0,fieldList[fieldList.size()-1].length()-1);
            finalFieldValues.add(fieldList);
            count= count+1;
        }
        //contains the field values from CSV with header at line 0
        System.debug('FINAL CSV VALUES ++ ' + finalFieldValues);
        return finalFieldValues;
    }
    
    public Static Map<String,String> mapCSVHeaderToFieldName(List<String> HeaderVals,String ObjectName){
        //This function will accept the Header Values from a processed CSV file and map it to the Object's Field Labels
        Map<String,String> csvFldNObjFld=new Map<String,String>();
        
        //Get the Schema description for the Object's fields
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        Map<String,String> FieldlabelApiNameMap = new Map<String,String>();
        
        //Convert all field names to lower case
        for(String fieldName:fields.keyset()){
            FieldlabelApiNameMap.put(fields.get(fieldname).getDescribe().getLabel().toLowerCase(),fieldName);
        }
        
        integer columnNumber = 0;
        for(String columnHeader:HeaderVals)
        {
            System.debug('****'+columnHeader);
            if(columnHeader.trim().length()>0){
                //Come into this for all cases where the Column Header has a value
                //Compare the column headers to the field maps and setup the data
                //Separate Logic for the first column
                if(columnNumber == (HeaderVals.size()-1) && columnheader.trim()!=null && FieldlabelApiNameMap.containsKey(columnHeader.trim().toLowerCase().substring(0,columnHeader.length()-1).trim())){
                    csvFldNObjFld.put(columnHeader.substring(0, columnHeader.length()-1),FieldlabelApiNameMap.get(columnHeader.trim().toLowerCase().substring(0,columnHeader.length()-1).trim()));
                    System.debug('1st if');
                }
                else if(columnheader.trim()!=null && FieldlabelApiNameMap.containsKey(columnHeader.trim().toLowerCase()))
                {
                    csvFldNObjFld.put(columnHeader,FieldlabelApiNameMap.get(columnHeader.trim().toLowerCase()));
                }
            }
            columnNumber ++;
        }
        return csvFldNObjFld;
    }
    
    public Static sobject Checkvalues(List<String> cleanFields, Map<String,String> csvFldNObjFld,Integer j, sObject Material,List<String> headerVals, Map<String, SObjectField> fields){
        //This logic maps the CSV field values to their target fields
        //It maps data based on the data type
        //We are ignoring the name column in this mapping
        if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.Date)
        {
            if(cleanFields[j]!=null && cleanFields[j]!='')
            {String[] myDateOnly= cleanFields[j].split(' '); String[] strDate = myDateOnly[0].split('/'); Integer myIntDate = integer.valueOf(strDate[1]); Integer myIntMonth = integer.valueOf(strDate[0]); Integer myIntYear = integer.valueOf(strDate[2]); Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate); Material.put(csvFldNObjFld.get(headerVals[j]),d);}
        }
        if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.INTEGER){Material.put(csvFldNObjFld.get(headerVals[j]),Integer.valueOf(cleanFields[j]));}
        else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.BOOLEAN){Material.put(csvFldNObjFld.get(headerVals[j]),Boolean.valueOf(cleanFields[j]));}
        else if(fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.CURRENCY || fields.get(csvFldNObjFld.get(headerVals[j])).getDescribe().getType() == Schema.DisplayType.DOUBLE){Material.put(csvFldNObjFld.get(headerVals[j]),Double.valueOf(cleanFields[j]));}
        else
        {
            if(csvFldNObjFld.get(headerVals[j]) == 'name'){/*Do Nothing*/}
            Material.put(csvFldNObjFld.get(headerVals[j]),cleanFields[j]);
            System.debug(cleanFields[j]);
        }
        return Material;
    }
}