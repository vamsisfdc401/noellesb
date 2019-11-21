public class CIRF_Utility {
    
    @AuraEnabled
    public Static List<List<String>> ReadCSV(String uploadedFile){
        String file = EncodingUtil.urlDecode(uploadedFile, 'UTF-8');
        //System.debug(file);
        String[] fileLines;
        fileLines = file.split('\n');
        //System.debug('file lines ++ ' + fileLines);
        List<List<String>> cleanFieldsList = new List<List<String>>();
        List<String> externalIdList=new List<String>();
        
        //Iterate through every line and create a Account record for each row
        for (Integer i=0;i<fileLines.size();i++)
        {
            fileLines[i]= fileLines[i].replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",').replaceall('\n','');
            fileLines[i]= fileLines[i].replaceAll('""','DBLQT');
            if (fileLines[i].replaceAll(',','').trim().length() == 0) continue;
            
            else
            {   
                List<String> fieldValues = filelines[i].split(',');  
                List<String> cleanFields = new List<String>();
                String compositeField;
                Boolean makeCompositeField = false;
                for(integer j=0;j<fieldvalues.size();j++ ) {
                    String field=fieldValues[j];
                    if (field.startsWith('"') && field.endsWith('"') && field.length()!=1) {
                        cleanFields.add(field.replaceAll('DBLQT','"'));
                    } else if (field.endsWith('"') && makeCompositeField) {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                        makeCompositeField = false;
                    }else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                        if(j==(fieldvalues.size()-1))
                        {
                            cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                        }
                    }  else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                        if(j==(fieldvalues.size()-1))
                        {
                            cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                        }
                    } else if(field.endsWith('"') && field.length()!=1 && cleanFields.size()> 0){
                        string previousfield = '';
                        previousfield = cleanFields.get(cleanFields.size()-1);    
                        cleanFields.set(cleanFields.size()-1,previousfield+ ',' +field.replaceAll('"','').replaceAll('DBLQT','"'));
                    } else {                
                        cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                    }
                }
                cleanFieldsList.add(cleanFields);                             
            }   
        } 
        List<List<String>> finalFieldValues=new List<List<String>>();
        integer count=1;
        List<String> headerVals = cleanFieldsList[0];
        finalFieldValues.add(headerVals);
        while(count<cleanfieldsList.size())
        {
            while(cleanFieldsList[count].size()<headerVals.size())
            {
                List<String> fieldList=cleanfieldsList[count];
                cleanFieldsList.remove(count);
                fieldList[fieldList.size()-1]=fieldList[fieldList.size()-1]+'\n'+cleanFieldsList[count][0];
                for(integer i=1;i<cleanFieldsList[count].size();i++)
                {
                    fieldList.add(cleanFieldsList[count][i]);
                }
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
        
        Map<String,String> csvFldNObjFld=new Map<String,String>();
        Map<String, SObjectField> fields= Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        Map<String,String> FieldlabelApiNameMap = new Map<String,String>();
        
        for(String fieldName:fields.keyset()){
            FieldlabelApiNameMap.put(fields.get(fieldname).getDescribe().getLabel().toLowerCase(),fieldName);
        }
        
        integer columnNumber = 0;
        for(String columnHeader:HeaderVals)
        {
            System.debug('****'+columnHeader);
            if(columnHeader.trim().length()>0){
                if(columnNumber == (HeaderVals.size()-1) && columnheader.trim()!=null && FieldlabelApiNameMap.containsKey(columnHeader.trim().toLowerCase().substring(0,columnHeader.trim().length()-1).trim())){
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
    
    @AuraEnabled
    public Static CIRF_Header__c ReviseCIRF(CIRF_Header__c header, Boolean revision){
        List<Id> relIds = new List<Id>();
        List<Task> tasksToUpdate = new List<Task>();
        header.RIM_Approval__c=false;
        header.Planner_Approval__c = false;
        header.RIM_Approval_Reason__c = '';
       /* header.Revision__c += 1;
        
        if(revision){
            header.Revision__c += 1;
        }
		*/
        System.debug('Inside utility');
        System.debug('header.CIRF_Materials__r '+ header.CIRF_Materials__r);
        if(header.CIRF_Materials__r==null){
            CIRF_Header__c nhead = [select id, (select id from CIRF_Materials__r) from CIRF_Header__c where id = :header.id];
            for(CIRF_Material__c cm : nhead.CIRF_Materials__r) {
                relIds.add(cm.id);
        	}
        }
        else {
            for(CIRF_Material__c cm : header.CIRF_Materials__r) {
            	relIds.add(cm.id);
        	}
        }
        system.debug('Materials ID---'+relIds);
        List<CIRF_Material__c> relCIRFMaterials = [select id, name, Corrugate_Units__c, CIRF_Header__c, CIRF_Material_Status__c, Creator_Approval__c, Units_to_Order__c from CIRF_Material__c where CIRF_Header__c= :header.id AND CIRF_Material_Status__c != 'Cancelled'];
        System.debug(relCIRFMaterials);
        if(!relCIRFMaterials.isEmpty())
        {
            for(CIRF_Material__c cm: relCIRFMaterials)
            {
                cm.CIRF_Material_Status__c='Draft';
                cm.Creator_Approval__c=false;
                cm.Customer_Marketing_Approval__c=false;
                cm.Customer_Marketing_Approval__c=false;
                cm.Planning_Approval__c=false;
                cm.RIM_Approval__c=false;
                cm.Customer_Marketing_Approval_Reason__c='';
                cm.Planning_Approval_Reason__c='';
                cm.RIM_Approval_Reason__c='';
                cm.On_Hand_Qty__c = null;
            }
            
            for(Task tk : [select id, Status, WhatId, CIRF_Header__c, isClosed from Task where 
                           CIRF_Header__c = :header.id AND isClosed = false]) {
                               tk.Status = 'Completed';
                               tasksToUpdate.add(tk);
                           }
            
            List<CIRF_Corrugate__c> relCIRFCorr = [select id, name,  CIRF_Header__c, Corrugate_Status__c from CIRF_Corrugate__c where CIRF_Header__c= :header.id];
            System.debug(relCIRFCorr);
            if(!relCIRFCorr.isEmpty())
            {
                for(CIRF_Corrugate__C cc: relCIRFCorr) {
                    cc.Corrugate_Status__c='Draft';
                }
            }
            try{
                update relCIRFMaterials;
            	update tasksToUpdate;
            	update relCIRFCorr;
            }
            catch(Exception e){
                //Throw new Exception(e.getMessage());
            }
        }
        return header;
    }
    
    public Static Map<Id,List<String>> getGroupMemberEmails(List<Id> GroupIds){
        List<GroupMember> GroupMemberList = [Select Id,UserOrGroupId,GroupId from GroupMember where GroupId=: GroupIds];
        Map<Id,List<String>> GroupMemberEmailMap = new Map<Id,List<String>>();
        return GroupMemberEmailMap;
    }
    
    //To avoid cross trigger updating - HEITCIRF-272 
    Public Static Map<String,Boolean> allowTriggerUpdate = new Map<String,Boolean>();
    
    public Static void GetPlanningGroupByLabelCode(){
        
    }
}