/*****************************************************************************************
Class Name: Utility
Purpose: This is common utility class contain generic function used across the application.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             13/07/2016           Bhanu Jain               Initial Development
******************************************************************************************/
public class Utility{

    public final static string CUSTOMER_MARKETING_GROUP = 'CAR_Customer_Marketing';
    public final static string MASTER_DATA_USER_GROUP = 'Master_Data_User';
    public final static string CUSTOMER_OPERATIONS_GROUP = 'RF_Customer_Ops';
    public final static string NO_REPLY_EMAIL = 'noreply@nbcuni.com';

    /*****************************************************************
    Method Name: isNull
    Purpose: checks for null value
    ***************************************************************/   
    public static Boolean isNull(Object obj){
        if(obj == null){
            return true;
        }
        return false;
    }
    
    /*****************************************************************
    Method Name: isEmpty
    Purpose: checks for empty value
    ***************************************************************/   
    public static Boolean isEmpty(String obj){
        if(obj == null){
            return true;
        }else if(obj.length() < 1){
            return true;
        }
        return false; 
    }
 
    /*****************************************************************
    Method Name: isEmpty
    Purpose: checks for empty value
    ***************************************************************/   
    public static Boolean isEmpty(List<Object> obj){ 
        if(obj == null){
            return true;
        }else if(obj.size() < 1){
            return true;
        }
        return false;
    }
    
    /*****************************************************************
    Method Name: isEmpty
    Purpose: checks for empty value
    ***************************************************************/   
    public static Boolean isEmpty(Set<Object> obj){
        if(obj == null){
            return true;
        }else if(obj.size() < 1){
            return true;
        }
        return false;
    } 
    
    /*****************************************************************
    Method Name: isEmpty
    Purpose: checks for empty value
    ***************************************************************/   
    public static Boolean isEmpty(Set<String> obj){
        if(obj == null){
            return true;
        }else if(obj.size() < 1){
            return true;
        }
        return false;
    }
    
    /*****************************************************************
    Method Name: isEmpty
    Purpose: checks for empty value
    ***************************************************************/   
    public static Boolean isEmpty(Map<Object,Object> obj){
        if(obj == null){
            return true;
        }else if(obj.size() < 1){
            return true;
        }
        return false;
    }
    
    /*****************************************************************
    Method Name: cloneMaterialList
    Purpose: for cloning a record
    ***************************************************************/   
    public static List<SObject> cloneMaterialList(List<String> idList, Set<String> fieldsToIgnore,String releaseId){
        String query = getQuery(idList,fieldsToIgnore);
        List<SObject> objList = database.query(query);
        List<SObject> clonedObjList = new List<SObject>();
        for(SObject obj : objList){
                obj.put('release__c',releaseId);
                obj.put('CloneHelperField__c',obj.Id);
            clonedObjList.add(obj.clone(false,false,false,false));
        }
        return clonedObjList;
    }
    
    /*****************************************************************
    Method Name: cloneBomList
    Purpose: for cloning a record
    ***************************************************************/   
    public static List<SObject> cloneBomList(List<String> idList, Set<String> fieldsToIgnore,String releaseId){
        String query = getQuery(idList,fieldsToIgnore);
        List<SObject> objList = database.query(query);
         List<SObject> clonedObjList = new List<SObject>();
        for(SObject obj : objList){
                clonedObjList.add((Bom_Item__c)obj.clone(false,false,false,false));
            }
       
        return clonedObjList;
    }    
    
    /*****************************************************************
    Method Name: cloneReleaseMaterialList
    Purpose: for cloning a record
    ***************************************************************/  
    public static List<SObject> cloneReleaseMaterialList(List<String> idList, Set<String> fieldsToIgnore,String releaseId){
            String query = getQuery(idList,fieldsToIgnore);
            List<Release_Material__c> objList = database.query(query);
            List<Release_Material__c> clonedObjList = new List<SObject>();
            for(SObject obj : objList){
                clonedObjList.add((Release_Material__c)obj.clone(false,false,false,false));
            }
            for(Release_Material__c obj : clonedObjList){
                obj.release__c  = releaseId;
            }
            return clonedObjList;
        }   
        
    /*****************************************************************
    Method Name: clone
    Purpose: for cloning a record
    ***************************************************************/      
    public static List<SObject> clone(List<String> idList,Set<String> fieldsToIgnore){

        String query = getQuery(idList,fieldsToIgnore);
        List<SObject> objList;
        List<SObject> clonedObjList;
        try{
            objList = database.query(query);
            clonedObjList = new List<SObject>();
            for(SObject obj : objList){
                obj.put('owner',UserInfo.getUserId());
                SObject rec = obj.clone(false,false,false,false);
                
                if(idList != null && idList.size() > 0 && String.valueOf(Id.valueOf(idList[0]).getSObjectType()).equalsIgnoreCase('Material__c'))
                {
                    Id reqRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
                    if(reqRecordTypeId != null)
                    {
                        rec.put('RecordTypeId', reqRecordTypeId);
                        rec.put('Material_Status__c', 'Draft');
                    }
                }
                clonedObjList.add(rec);
            }           
        }catch(Exception e){
            system.debug('Some exception occured');
            return null;
        }
        
    return clonedObjList;
    }
    
    /*****************************************************************
    Method Name: clone
    Purpose: for cloning a record
    ***************************************************************/      
    public static String clone(String recId, Set<String> fieldsToIgnore){
        List<String> idList = new List<String>();
        idList.add(recId);
        String query = getQuery(idList,fieldsToIgnore);
        List<SObject> objList = database.query(query);
        List<SObject> clonedObjList = new List<SObject>();
        for(SObject obj : objList){
            
            SObject rec = obj.clone(false, false, false, false);
            
            if(recId != null && String.valueOf(Id.valueOf(recId).getSObjectType()).equalsIgnoreCase('Material__c'))
            {
                Id reqRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
                if(reqRecordTypeId != null)
                {
                    rec.put('RecordTypeId', reqRecordTypeId);
                    rec.put('Material_Status__c', 'Draft');
                }
            }
            
            clonedObjList.add(rec);
        }
        System.debug('----Cross_Ref__cB> '+clonedObjList[0].get('Cross_Ref__c'));
        
        List<Database.SaveResult> result = database.insert(clonedObjList,FALSE);
        
        String newId;
        for (Database.SaveResult sr : result) {
            if(sr.isSuccess()){
                system.debug('successfully cloned current record '+sr.getid());
                newId = sr.getId();
            }
        }
        
        return newId;
    }  
    
    /*****************************************************************
    Method Name: getIdVsObjectMap
    Purpose: returns a map
    ***************************************************************/        
    public static Map<String,String> getIdVsObjectMap(){
        Map<String,String> keys = new Map<String,String>();
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset())
        keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);

    return keys;    
    }
    
    /*****************************************************************
    Method Name: getFieldNames
    Purpose: returns field names for an object
    ***************************************************************/      
    public static Set<String> getFieldNames(String SObjectName){
        System.debug('-----SObjectName> '+SObjectName);
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> fieldMap = describe.get(SObjectName).getDescribe().fields.getMap();
        return fieldMap.keySet();
    }
    
    /*****************************************************************
    Method Name: getQuery
    Purpose: returns SOQL
    ***************************************************************/      
    public static String getQuery(List<String> idList, Set<String> fieldsToIgnore){
        
        Map<String,String> idVsObjectNameMap = getIdVsObjectMap();
            String firstThreeChar;
            String SObjectName;
            if(! isEmpty(idList)){
                firstThreeChar = idList.get(0).subString(0,3);
            }
            else
                return '';
            for(String idPreFix : idVsObjectNameMap.keySet()){
                if(idPrefix != null){
                    if(idList.get(0).contains(idPreFix) && firstThreeChar.equals(idPreFix)){
                        SObjectName = idVsObjectNameMap.get(idPreFix);
                        break;
                    }
                }
                
            }       
        String fieldNamesStr = '';
        Set<String> setFieldNames = getFieldNames(SObjectName);
        for(String fieldName : setFieldNames){
            if(fieldsToIgnore != null){
            fieldsToIgnore.add('ownerid');
                if(fieldsToIgnore.contains(fieldName)){
                    continue;
                }
            }
            fieldNamesStr = fieldNamesStr + fieldName + ',';
        }
        fieldNamesStr = fieldNamesStr.subString(0,fieldNamesStr.length() - 1);
        String inClauseStr = '(';
        
        for(String id : idList){
            inClauseStr = inClauseStr + '\'' + Id + '\',';
        }
        inClauseStr = inClauseStr.substring(0,inClauseStr.length() - 1) +')';
        
        String query = 'SELECT '+ fieldNamesStr +' FROM '+ SObjectName + ' WHERE Id in ' + inClauseStr;   
        System.debug('----q>'+query);
        return query;   
    }
   
    /*****************************************************************
    Method Name: cleanString
    Purpose: cleans a string to remove non-ascii and other characters that cause SAP and downstream
             system problems.  Returns string     
    ***************************************************************/      
    public static String cleanString(String oldString){
        
        String nonAscii = '[^\\x00-\\x7F]';
        String specialCharacters = '[|*]';
        String replacement = '';
        String newString;
        // Conversion of oldString to newString broken into 2 steps.  First, take out non-ascii
        // Second, take out other characters that SAP and downstream systems can't process
        newString = oldString.replaceAll(nonAscii, replacement);
        newString = newString.replaceAll(specialCharacters, replacement);
        
        return newString;  
    }
    
 
    /*****************************************************************
    Method Name: parseLongText
    Purpose: parse a string containing line breaks and / carriage returns into a list of string lines that may be 
             consumed by TIBCO for SAP integration
             system problems.  Returns List of BOM Long Text     
    ***************************************************************/      
    public static List<BOM_Long_Text__c> parseLongText(String oldString){
        
        String target = '\r\n';
        String replacement = '\n';
        String newString;

        newString = oldString.replace(target, replacement);
        List<String> stringLines = newString.split('\n');
        //Initialize variables
        List<BOM_Long_Text__c> parseList = new List<BOM_Long_Text__c>();
        Integer counter = 1;
        Integer maxCharacter = 40;
        
        for(String lines : stringLines){
            BOM_Long_Text__c parseLine = new BOM_Long_Text__c(); 
            String tempLine = lines;

            //Handle Text from line
            //Chop up line into additional pieces based on maxCharacter length
            //If length(tempLine) > maxCharacter, then take left(maxCharacter) and assign to parseLine
            //Remove what was assigned from tempLine and loop, until
            //Set order field on record

            do { 
                    System.debug('counter -> '+counter);             
                if(templine.length() > maxCharacter){
                    //add maxCharacters to Line
                    parseLine.Text__c = tempLine.left(maxCharacter);
                    String remainLine = tempLine.removeStart(parseLine.Text__c);
                    tempLine = remainLine;
                    parseLine.Code__c = '';
                    parseLine.Order__c = counter;                    
                    parseList.add(parseLine);
                    System.debug('parseLine.Text -> '+parseLine.Text__c);
                    System.debug('tempLine -> '+tempLine);
                    System.debug('parseLine.Code -> '+parseLine.Code__c);
                    System.debug('parseLine.Order -> '+parseLine.Order__c);                    
                    counter = counter +1;                  
                }
                else{//Handle when templine.length is less than maxCharacters
                    parseLine.Text__c = tempLine;                   
                    parseLine.Code__c = '*';
                    parseLine.Order__c = counter; 
                    System.debug('parseLine.Text -> '+parseLine.Text__c);
                    System.debug('tempLine -> '+tempLine);
                    System.debug('parseLine.Code -> '+parseLine.Code__c);
                    System.debug('parseLine.Order -> '+parseLine.Order__c);   
                    tempLine='';
                    System.debug('tempLine -> '+tempLine);                    
                    parseList.add(parseLine);
                    counter = counter +1;                        
                }
                
                if(counter > 1){
                    maxCharacter = 132;
                }

                
            }while (tempLine.length() <> 0);

        }

        return parseList;  
    }   
    /*****************************************************************
    Method Name: getRecordTypeName
    Purpose: Get Record Type Name for any given Record Type Id
    Created On:  10/10/2018
    Created By:  Ann Luong
    Ticket:  HEITCIRF-170
    ***************************************************************/      
    public static String getRecordTypeName (String recordTypeId, String sObjectTypeName) {
        //RecordType recordType = [select name from RecordType where Id = :recordTypeId limit 1];
        return Schema.getGlobalDescribe().get(sObjectTypeName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }
    /*****************************************************************
    Method Name: getRecordTypeId
    Purpose: Get Record Type Id for any given SObject by Developer Name
    Created On:  10/16/2018
    Created By:  Ann Luong
    Ticket:  HEITCIRF-170
    ***************************************************************/      

    public static Id getRecordTypeId (String recordTypeName, String sObjectTypeName) {
       // RecordType recordType = [select name from RecordType where SobjectType =: sObjectTypeName and Name = :recordTypeName limit 1];
       Id recordTypeId= Schema.getGlobalDescribe().get(sObjectTypeName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
       return recordTypeId;
    }


    /*****************************************************************
    Method Name: getUserId
    Purpose: Get User Id for any given User Name
    Created On:  10/16/2018
    Created By:  Ann Luong
    Ticket:  HEITCIRF-170
    ***************************************************************/      

    public static Id getUserId (String Name) {
        User selUser = [SELECT Id, Name FROM User where name =: Name];
        return selUser.Id; 
    }

    /*****************************************************************
    Method Name: getGroupMembers
    Purpose: Get group member user ids for any given group
    Created On:  10/16/2018
    Created By:  Ann Luong
    Ticket:  HEITCIRF-170
    ***************************************************************/      

    public static List<Id> getGroupMembers (String groupName, String groupType) {

        Group selGroup = null;

        try {
            selGroup = [SELECT id, type, relatedId from Group where DeveloperName =: groupName and Type =: groupType limit 1];
        }
        catch (Exception e) { 
            system.debug(e.getMessage());
        }

        
        if (selGroup != null) {
            switch on selGroup.Type  {
                when 'Regular','Queue' {
                    return GetUserIdsFromGroup(selGroup.Id);
                }
                when 'Role' {
                    return getUserIdsbyRole(selGroup);
                }
                when else {
                    //  Other types are not currently supported
                    return null;
                }
            }            
        }
        else
            return null;

    }

    public static  List<id> GetUserIdsFromGroup(Id selGroupId)
    {
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        List<Id> resultList = new List<Id>();
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = : selGroupId])
        {
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
            }
        }

        resultList.addAll(result);
        return resultList; 
    }


    public static List<Id> getUserIdsbyRole(Group selGroup) {
        Map<Id, User> UserMap = new Map<Id, User>([select Id from User where UserRoleId = :selGroup.relatedId and IsActive = True ]);
        List<Id> userIdList = new List<Id>();
        userIdList.addAll(UserMap.keySet());
        return userIdList;
    }

    public static String getCustomerMarketingGroupName () {
        return (CUSTOMER_MARKETING_GROUP);
    }

    public static String getMasterDataGroupName () {
        return (MASTER_DATA_USER_GROUP);
    }

    public static String getCustomerOperationsGroupName() {
        return (CUSTOMER_OPERATIONS_GROUP);
    }

    public static List<String> getUserEmails(List<Id> userIdList) {
        List<String> emailList = new List<String>();
        if (!userIdList.IsEmpty() && userIdList.size() > 0) {
            list<User> userList = [select id, email from User where Id in :userIdList and IsActive = true];
            for (User u : userList) {
                emailList.add(u.email);
            }
            return emailList;
        }
        else
            return null;
    }

    public static void sendEmail (List<String>recipientList, String subject, String message, String emailTemplate, Id relatedId) {

        if (emailTemplate != null) {
            //  Send Email with Template
            String emailTemplateId = getEmailTemplateId(emailTemplate);
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateId, UserInfo.getUserId(), relatedId);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setToAddresses(recipientList);    
            mail.setReplyTo(NO_REPLY_EMAIL);
            mail.setSaveAsActivity(false);      // Must be set to false, otherwise gives error when trying to sendEmail()
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else {
            //  Send Text Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipientList);
            mail.setSubject(subject);
            mail.setReplyTo(NO_REPLY_EMAIL);
            mail.setPlainTextBody(message);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

    }

    public static Id getEmailTemplateId(String emailTemplateName) {
        EmailTemplate emailTemplate = [select id, Name, DeveloperName from EmailTemplate 
                                        where DeveloperName =: emailTemplateName limit 1];
        return emailTemplate.Id;
    }
    
}