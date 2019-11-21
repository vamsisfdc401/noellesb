/*****************************************************************************************
Class Name: MassNotifyTriggerHandler
Purpose: This class handles to mass follow releases by users belongs to public groups
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna             Initial Development
******************************************************************************************/
public with sharing class MassNotifyTriggerHandler{
    
    public static Map<Id,List<Id>> mapReleaseShareRoles = new Map<Id,List<Id>>();
    public static Map<Id,List<Id>> mapReleaseShareUsers = new Map<Id,List<Id>>();
    public static Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();    //REL-43
    public static Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();  //REL-43
    public static map<Id,Set<Id>> mapRelRoleparentRoles = new map<Id,Set<Id>>();
    public static map<Id,Set<Id>> mapRelShareUsers = new map<Id,Set<Id>>();
    public static map<Integer,Set<Id>> mapRoleParentIds = new map<Integer,Set<Id>>();
    public static Boolean isRootroles = TRUE;
    
    @Future
    /***************************************************
    Added for REL-43
    Method Name: massFollowRelease
    Purpose:follow newly created releases by public group
    ****************************************************/
    public static void massFollowRelease(Set<Id> setrelIds){
        try
        {
            TriggerUtility.checkMassFollow = TRUE;
            Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
            Map<Id,Id> mapUserRole = new Map<Id,Id>();
            Set<Id> relIds = new Set<Id>();
            Set<Id> objectIds = new Set<Id>();
            Set<EntitySubscription> tempInsFollows = new Set<EntitySubscription>();
            List<EntitySubscription> insFollows = new List<EntitySubscription>();
            Set<String> lstPublicGroup = new Set<String>();
            lstPublicGroup.add('UPHE Biz Comm');
            lstPublicGroup.add('UPHE Tech Ops');
            lstPublicGroup.add('Universal New Release Planning'); //USST-2743
            lstPublicGroup.add('Universal Catalog Planning Group'); //USST-2743
            lstPublicGroup.add('Master Data-UNI'); //USST-2743
            map<String,Boolean> recordEditAccess = new map<String,Boolean>();
            mapUserRole = userOfPublicGroup(lstPublicGroup);
            relIds.addAll(setrelIds);
            objectIds.addAll(relIds);
            objectIds.addAll(mapUserRole.keySet());
            
            //fetch the roles associated to releses getting created
            getRoleAccessToRelease(relIds);
            for(Id rel : relIds)
            {
                for(Id uid : mapUserRole.keySet())  
                    {
                        if(mapRelRoleparentRoles.get(rel) != null && ((mapRelRoleparentRoles.get(rel)).contains(mapUserRole.get(uid)) || mapRelShareUsers.get(rel).contains(uid)))
                        {
                            tempInsFollows.add(new EntitySubscription(ParentId = rel, SubscriberId = uid));
                        }
                    }   
            }
            
            System.debug('tempInsFollows:'+ tempInsFollows);
            insFollows.addAll(tempInsFollows);
            System.debug('insFollows:'+ insFollows);
            //To insert list of EntitySubscription records in system mode. To allow users to follow release who has access to release but that user is not accessible by logged in user.
            MassNotifyTriggerHelper.massFollowRelease(insFollows);
        }
        // Managing the error.
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }
    
    /***************************************************
    Added for REL-43
    Method Name: userOfPublicGroup
    Purpose: returns users belongs to public group
    ****************************************************/
    public static map<Id,Id> userOfPublicGroup (Set<String> lstPublicGroup)
    {
        Set<String> userIds = new Set<String>();
        Map<Id, Group> mapGroups = new Map<Id, Group>([Select Id,Name from Group where Name IN :lstPublicGroup]);
        System.debug('mapGroups:'+mapGroups);
        Map<Id,GroupMember> mapGroupMembers = new Map<Id,GroupMember>([Select Id, GroupId,UserOrGroupId from GroupMember where GroupId IN :mapGroups.keySet()]);
        System.debug('mapGroupMembers:'+mapGroupMembers);
        Map<Id,Id> mapUserRole = new Map<Id,Id>();
        for(GroupMember mem : mapGroupMembers.values())
        {
            if(String.valueof(mem.UserOrGroupId).startsWith(discResUser.getKeyPrefix()))
            {
                userIds.add(mem.UserOrGroupId);
            }
        }
        map<Id,User> mapUsers = new map<Id,User>([SELECT Id,ProfileId,UserRoleId,UserType FROM User where Id IN : userIds and IsActive = TRUE]); //USST-3033
        for(User usr: mapUsers.values())
        {
            mapUserRole.put(usr.Id,usr.UserRoleId); 
        }   
        System.debug('mapUserRole:'+mapUserRole);
        return mapUserRole;
    }
    
    /***************************************************
    Added for REL-43
    Method Name: getRoleAccessToRelease
    Purpose: code get release record accessible roles and users 
    ****************************************************/
    public static void getRoleAccessToRelease (Set<Id> lstRelIds)
    {
        Set<Id> setGroupIds = new Set<Id>();
        Set<Id> setRoleIds = new Set<Id>();
        map<Integer,Set<Id>> mapSpecificRoles = new map<Integer,Set<Id>>();
        //Release_Share contains details of release and its associated roles and users accessible 
        map<Id, Release__Share> mapRelShareRecord = new map<Id, Release__Share>([SELECT AccessLevel,ParentId,RowCause,UserOrGroupId FROM Release__Share WHERE ParentId IN :lstRelIds]);
        map<Id,List<Id>> mapRelShareRoles = new map<Id,List<Id>>();
        for(Release__Share relShare : mapRelShareRecord.values())
        {
            //Roles are generally relatedTo groups. mapRelShareRoles stores release and its associated groups related to roles accessible
            if(!String.valueof(relShare.UserOrGroupId).startsWith(discResUser.getKeyPrefix()))
            {
                setGroupIds.add(relShare.UserOrGroupId);
                if(mapRelShareRoles.containsKey(relShare.ParentId)) 
                {
                    mapRelShareRoles.get(relShare.ParentId).add(relShare.UserOrGroupId);
                }
                else
                {
                    List<Id> tempId = new List<Id>();
                    tempId.add(relShare.UserOrGroupId);
                    mapRelShareRoles.put(relShare.ParentId,tempId);
                }   
                    
            }
            //mapRelShareUsers stores release and its associated users accessible
            else
            {
                if(mapRelShareUsers.containsKey(relShare.ParentId)) 
                {
                    mapRelShareUsers.get(relShare.ParentId).add(relShare.UserOrGroupId);
                }
                else
                {
                    Set<Id> tempId = new Set<Id>();
                    tempId.add(relShare.UserOrGroupId);
                    mapRelShareUsers.put(relShare.ParentId,tempId);
                }
                
            }   
        }
        System.debug('mapRelShareRoles:'+ mapRelShareRoles);
        System.debug('mapRelShareUsers:'+ mapRelShareUsers);
        map<Id,Id> mapGroupRelatedRole = new map<Id,Id>();
        //fetching all related roles associate to groups
        List<Group> roleRelatedToGroup = [SELECT Id,Name,OwnerId,RelatedId,Type FROM Group WHERE Id IN : setGroupIds];
        for(Group groupId : roleRelatedToGroup) 
        {
            setRoleIds.add(groupId.RelatedId);
            mapGroupRelatedRole.put(groupId.Id,groupId.RelatedId);
        }   
        system.debug('mapGroupRelatedRole:'+ mapGroupRelatedRole);
        
        //fetching all parents roles of given roles based on role hierarchy
        mapSpecificRoles = getParentRoleId(setRoleIds); 
        System.debug('mapSpecificRoles:'+ mapSpecificRoles);
        map<Id,Set<Id>> mapRoleParentRoles = new map<Id,Set<Id>>();
        //mapping child roles to all of its parent roles
        for(Integer num : mapSpecificRoles.keySet())
        {
            List<Id> temproleIds = new List<Id>();
            temproleIds.addAll(mapSpecificRoles.get(num));
            mapRoleParentRoles.put(temproleIds.get(0),mapSpecificRoles.get(num));   
        }
        System.debug('mapRoleParentRoles:'+ mapRoleParentRoles);
        
        //mapping release and all of its roles accessible
        for(Id relId : lstRelIds)
        {
            if(mapRelRoleparentRoles.containsKey(relId))    
                {
                    if(mapRelShareRoles.get(relId) != null)
                    {   
                        for(Id roleId: mapRelShareRoles.get(relId))
                        {
                            (mapRelRoleparentRoles.get(relId)).addAll(mapRoleParentRoles.get(mapGroupRelatedRole.get(roleId))); 
                        }
                    }   
                }
                else
                {
                    if(mapRelShareRoles.get(relId) != null)
                    {
                        Set<Id> tempId = new Set<Id>();
                        for(Id roleId: mapRelShareRoles.get(relId))
                        {
                            tempId.addAll(mapRoleParentRoles.get(mapGroupRelatedRole.get(roleId)));
                        }   
                        mapRelRoleparentRoles.put(relId,tempId);
                    }   
                }   
        }   
        System.debug('mapRelRoleparentRoles:'+ mapRelRoleparentRoles);
        
    
    }
    /*****************************************************************************************************************************
    Added for REL-43
    Method Name: getParentRoleId
    Purpose:  To get all Parent Roles.
    Return Type : returning roles and its parents for different releases,first occurence of set will contain first child role. 
    ******************************************************************************************************************************/
    
    public static map<Integer,Set<Id>> getParentRoleId(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        Integer cnt = 0;
        if(isRootroles)
        {   
            for(Id roleid : roleIds)
            {
                cnt = cnt + 1;
                Set<Id> tempId = new Set<Id>();
                tempId.add(roleid);
                mapRoleParentIds.put(cnt,tempId);   
            }
            isRootroles = FALSE;
        }   
        System.debug('mapRoleParentIds**'+ mapRoleParentIds);
        List<UserRole> lstUserRoles = [select Id, ParentRoleId from UserRole where Id IN: roleIds];
        System.debug('lstUserRoles:'+ lstUserRoles);
        for(UserRole ur :lstUserRoles) {
            for(Integer num : mapRoleParentIds.keySet())
            {
                if(mapRoleParentIds.get(num).contains(ur.Id))
                {
                    if(ur.ParentRoleId != null && !((mapRoleParentIds.get(num)).contains(ur.ParentRoleId)))
                    {
                        mapRoleParentIds.get(num).add(ur.ParentRoleId);
                        System.debug('mapRoleParentIds:'+ mapRoleParentIds);
                        break;
                    }   
                }       
            }
            if(ur.ParentRoleId != null) 
                currentRoleIds.add(ur.ParentRoleId);
        }
        
        System.debug('currentRoleIds**'+ currentRoleIds);
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            getParentRoleId(currentRoleIds);
        }
        System.debug('mapRoleParentIds:'+ mapRoleParentIds);
        return mapRoleParentIds;
    }


}