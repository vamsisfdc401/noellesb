//Utility method to do CIRF validations
public class CIRFValidationUtil {
    //class constants
    final static String CIRF_STATUS_LOCKED = System.Label.CIRF_Locked_Status;//store locked status
    final static String CIRF_STATUS_SUBMITTED = 'Submitted';//submitted status
    //object api names
    public final static String CIRF_MATERIALS = 'CIRF_Material__c';
    public final static String CIRF_CORRUGATE_MATERIALS = 'CIRF_Corrugate_Material__c';
    public final static String CIRF_CORRUGATE = 'CIRF_Corrugate__c';
    
    public static Set<Id> userIdsFromGroup;
    public static Map<Id,AccountTeamMember> accountTeamMap;
    public static Map<String, Boolean> unlockedFieldMap;
    
    //generic method called from CIRF_Material__c, CIRF_Corrugate_Material__c, CIRF_Corrugate__c before update, before insert and before delete operations
    public static void processRecords(String objectAPIName) {
        if(System.Label.CIRF_Status_Validation_ON_OFF.equalsIgnoreCase('ON') 
           && !Label.CIRF_Val_Util_SysAdmin_Ids.contains(UserInfo.getProfileId())){
            List<Sobject> sobjectList = Trigger.isDelete ? Trigger.old : Trigger.new;
            Map<Id, Id> mapOfIdToParentId = new Map<Id, Id>();
            Map<Id,String> corrIds = new Map<Id,String>();
            
            for(Sobject obj: sobjectList) {
                System.debug('objectAPIName'+objectAPIName);
                System.debug('CIRF_CORRUGATE_MATERIALS'+CIRF_CORRUGATE_MATERIALS);
                if(objectAPIName == CIRF_CORRUGATE_MATERIALS){
                    System.debug('Inside if');
                    corrIds.put((Id)obj.get('CIRF_Corrugate__c'), obj.id);
                }
                else{
                    System.debug('Inside Else');
                    mapOfIdToParentId.put(obj.Id, (Id)obj.get('CIRF_Header__c'));
                    system.debug('mapofIdToParentId: ' + mapOfIdToParentId);
                }
            }
            System.debug('corrIds** '+corrIds);
            if(!corrIds.values().isEmpty()){
                Map<Id,CIRF_Corrugate__c> relatedCorMap = new Map<Id,CIRF_Corrugate__c>([select id, CIRF_Header__c from CIRF_Corrugate__c where id IN :corrIds.keyset()]);
                /*for(CIRF_Corrugate__c cc : relatedCorMap.values()){
                    mapOfIdToParentId.put(corrIds.get(cc.id), cc.CIRF_Header__c);
                }*/
                for(Sobject obj: sobjectList) {
                    if(objectAPIName == CIRF_CORRUGATE_MATERIALS){
                        mapOfIdToParentId.put(obj.id, (relatedCorMap.get((Id)obj.get('CIRF_Corrugate__c'))).CIRF_Header__c);
                    }
                }
            }
            
            //query CIRF Header as for insert status this field will be populated in formula field
            Map<Id, CIRF_Header__c> mapOfCIRFHeader = new Map<Id, CIRF_Header__c> ([Select Id, CIRF_Status__c, Retailer__c from CIRF_Header__c where Id =: mapOfIdToParentId.values()]);
            Set<Id> relaccId = new Set<Id>(); 
            
            for(CIRF_Header__c cirfHeader: mapOfCIRFHeader.values()) {
                if(cirfHeader.Retailer__c != null) {
                    relaccId.add(cirfHeader.Retailer__c);
                }
            }
            //get all users from group
            Set<String> groupIds = new Set<String> ();
            groupIds.addAll(System.Label.CIRF_Validation_GroupIds.split(','));
            if(userIdsFromGroup==null){
                System.debug('123** inside first if');
                userIdsFromGroup = getUserIdsFromGroup(groupIds);
            }
            if(accountTeamMap==null){
                System.debug('123** inside second if');
               accountTeamMap = new Map<Id,AccountTeamMember>([select id,UserId, AccountId from AccountTeamMember where AccountId IN : relaccId AND TeamMemberRole='CIRF RIM Team']);  
            }
            System.debug('123** '+userIdsFromGroup);
            System.debug('123** '+accountTeamMap);
            Map<Id,Set<Id>> accountToATMsMap = new Map<Id,Set<Id>>();
            for(AccountTeamMember atm: accountTeamMap.values()) {
                if(!accountToATMsMap.containsKey(atm.accountId)) {
                    accountToATMsMap.put(atm.accountId,new Set<Id>());
                }
                accountToATMsMap.get(atm.accountId).add(atm.UserId);
            }
            system.debug('*****accountToATMsMap' + accountToATMsMap);
            
            system.debug('SobjectList: ' + sobjectList);
            for(Sobject obj: sobjectList) {
                system.debug('Debug obj: ' + obj);
                CIRF_Header__c masterHeader;
                if(objectAPIName == CIRF_CORRUGATE_MATERIALS){
                    System.debug('detected cor mat');
                    System.debug(obj.id);
                    System.debug(((CIRF_Corrugate_Material__c)obj).CIRF_Corrugate__c);
                    System.debug('mapOfIdToParentId ' +mapOfIdToParentId);
                    System.debug('mapOfCIRFHeader '+mapOfCIRFHeader);
                    //masterHeader = mapOfCIRFHeader.get(mapOfIdToParentId.get(((CIRF_Corrugate_Material__c)obj).CIRF_Corrugate__c));
                    masterHeader = mapOfCIRFHeader.get(mapOfIdToParentId.get(obj.id));
                }
                else {
                    System.debug('detected else');
                    masterHeader = mapOfCIRFHeader.get((Id)obj.get('CIRF_Header__c'));
                }
                
                system.debug('*****masterHeader ' + masterHeader );
                system.debug('****mapOfCIRFHeader' + mapOfCIRFHeader);
                Set<Id> userIds = new Set<Id> ();
                System.debug('Master '+masterHeader.Retailer__c);
                if(accountToATMsMap.containsKey(masterHeader.Retailer__c)) {
                    userIds = accountToATMsMap.get(masterHeader.Retailer__c);
                }
                System.debug('masterHeader.CIRF_Status__c '+masterHeader.CIRF_Status__c);
                if(masterHeader.CIRF_Status__c != null) {
                    String errorMessage = '';
                    if(masterHeader.CIRF_Status__c == CIRF_STATUS_SUBMITTED) {
                        System.debug('Val Inside submitted');
                        errorMessage = doCIRFSubmittedValidation(objectAPIName, userIds, userIdsFromGroup);
                    } else {
                        System.debug('Val Inside Else');
                        errorMessage = doCIRFLockedStatusValidation(masterHeader.CIRF_Status__c);
                    }

                    //  01/31/2019 - AL - HEITCIRF-221
                    if(errorMessage != '' && trigger.isUpdate) {
                        //check if error message is not blank and get list of changed fields
                        List<String> updFieldList = getUpdFieldList(objectAPIName, masterHeader.CIRF_Status__c, obj);
                        system.debug('####updFieldList:  ' + updFieldList);
                        if (updFieldList.isEmpty() && updFieldlist != null)
                        {
                            errorMessage = '';
                        }
                        
                        
                    }
                    
                    if(errorMessage != ''){
                        obj.addError(errorMessage);
                        }
                }
            }
            
            
        }

    }
    
    //generic method called from CIRF_Material__c, CIRF_Corrugate_Material__c, CIRF_Corrugate__c before update, before insert and before delete operations to check for submitted status
    public static String doCIRFSubmittedValidation(String objectAPIName, Set<Id> rimUserIds, Set<Id> userIdsFromGroup) {
        if(Trigger.isExecuting) {
            if(objectAPIName == CIRF_MATERIALS) {
                if(Trigger.isInsert || Trigger.isDelete) {
                    if(!rimUserIds.contains(UserInfo.getUserId()) ) {//RB2:Changing so only RIM can add or delete removing -> && !userIdsFromGroup.contains(UserInfo.getUserId())
                        return 'You are not allowed to create or delete while in submitted, please revise your CIRF back to draft.';
                    }
                } else  {//RB2:Adding logic where only RIM or planning can make changes to the CIRF
                    if(!rimUserIds.contains(UserInfo.getUserId()) && !userIdsFromGroup.contains(UserInfo.getUserId()) ) {
                        return 'You are not allowed to edit your CIRF while it is in submitted status, please revise your CIRF back to draft.';
                    }
                }
            } else if(objectAPIName == CIRF_CORRUGATE || objectAPIName == CIRF_CORRUGATE_MATERIALS) {
                System.debug('*** isRimUser ' + rimUserIds.contains(UserInfo.getUserId()));
                System.debug('*** isPlannerUser ' + userIdsFromGroup.contains(UserInfo.getUserId()));
                if((!rimUserIds.contains(UserInfo.getUserId()) && (!userIdsFromGroup.contains(UserInfo.getUserId()))) && 
                    (Trigger.isInsert || Trigger.isDelete || Trigger.isUpdate)
                  ) 
                {
                    system.debug('*** doCIRFSubmittedValidation');
                    return 'You are not allowed to create or edit or delete this record, please revise your CIRF back to draft.';
                }
            }
        }
        return '';
    }
    
    //generic method called from CIRF_Material__c, CIRF_Corrugate_Material__c, CIRF_Corrugate__c before update, before insert and before delete operations to check if CIRF is locked
    public static String doCIRFLockedStatusValidation(String status) {
        System.debug('Val inside locked method');
        if(Trigger.isExecuting) {
            System.debug('Val Status' + status);
            if(CIRF_STATUS_LOCKED.containsIgnoreCase(status)) {
                return 'This record is locked! Please revise this CIRF back to draft if you need to make any changes';
            }
        }
        return '';
    }
    
    //generic method to get all users from a group, uses recursive queries to get all users.
    public static Set<id> getUserIdsFromGroup(Set<String> groupIds) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<String> groupIdProxys = new Set<String>();
        // Loop through all group members in a group
        for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds]) {
            // If the user or group id is a user
            if(((String)m.UserOrGroupId).startsWith(userType)) {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType)) {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(m.UserOrGroupId);
            }
        }
        if(groupIdProxys.size() > 0) {
            result.addAll(getUserIdsFromGroup(groupIdProxys));
        }
        return result;  
    }

    //  01/31/2019 - AL - HEITCIRF-221

    public static Map<String, Boolean> populateUnlockedFieldMap() {
        Map<String, Boolean> unlockedFieldMdt = new Map<String, Boolean>();
        for (CIRF_Unlocked_Field__mdt ufl : [SELECT MasterLabel, CIRF_Field_Name__c, CIRF_Header_Status__c, CIRF_Object_Name__c
                                                     FROM CIRF_Unlocked_Field__mdt
                                            ]) {
                unlockedFieldMdt.put(ufl.CIRF_Object_Name__c + '.' + ufl.CIRF_Field_Name__c + '-' + ufl.CIRF_Header_Status__c, True);
                
                //system.debug('####Example Unlocked Map:' +ufl.CIRF_Object_Name__c + '.' + ufl.CIRF_Field_Name__c + '-' + ufl.CIRF_Header_Status__c);
        }

        return unlockedFieldMdt;
    }


    public static Boolean isUnlockedField(String sObjectName, string fieldName, string headerStatus) {
        if (unlockedFieldMap == null) {
            unlockedFieldMap = populateUnlockedFieldMap();
        }

        system.debug('####CheckingisUnlocked: ' + sObjectName + '.' + fieldName + '-' + headerStatus);

        return (unlockedFieldMap.containsKey(sObjectName + '.' + fieldName + '-' + headerStatus));
    }

    public static List<String> getUpdFieldList(String sObjectName, String headerStatus, sObject obj) {
        system.debug('####getUpdFieldList: ');
        List<String> updFieldlist = new List<String>();

        SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();

        system.debug('####mFields:  ' + mfields);
        

        system.debug('####newMap: ' + trigger.newMap);

        system.debug('#####oldMap: ' + trigger.oldMap);

        for (sObject newRec : trigger.new) {
            sObject oldRec = trigger.oldMap.get(newRec.Id);
            for (String fieldName : mfields.keyset()) {
                if (!isUnlockedField(sObjectName, fieldName,headerStatus))
                    //system.debug('####IsLocked: ' + sObjectName + '.' + fieldName + '-' + headerStatus);
                   if (newRec.get(fieldName) != oldRec.get(fieldName)) {
                        updFieldList.add(fieldName);
                       //system.debug('####IsChanged: ' + sObjectName + '.' + fieldName + '-' + headerStatus);
                   }
            }
        }

        return updFieldList;
        
    }






}