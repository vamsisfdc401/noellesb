/*****************************************************************************************
Class Name: BatchUnfollowRelease
Purpose: This class handles to unfollow user from release when start date of Release is Current date
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             12/10/2017           Jyothsna             Initial Development
******************************************************************************************/

global class BatchUnfollowRelease implements Database.Batchable<sObject> {
    
    // Fetching the complete context data.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
        String query = 'SELECT Id,Street_Date__c,Name,RecordTypeId FROM Release__c where Street_Date__c = TODAY AND RecordTypeId != :CompRecordTypeId';
        return Database.getQueryLocator(query);
    }
   
    // Executing the batch process.
    global void execute(Database.BatchableContext BC, List<Release__c> lstRelease) {
        try
        {
            Set<Id> setRelIds = new Set<Id>();
            Set<Id> setUsersPublicGroup = new Set<Id>();
            map<Id,List<EntitySubscription>> mapReleaseEntityRecord = new map<Id,List<EntitySubscription>>();
            Set<String> lstPublicGroup = new Set<String>();
            lstPublicGroup.add(ReleaseTriggerHandler.UPHE_Biz_Comm_Public_Group);
            lstPublicGroup.add(ReleaseTriggerHandler.UPHE_Tech_Ops_Public_Group);
            List<EntitySubscription> lstUsersFollowRelease = new List<EntitySubscription>();
            List<EntitySubscription> lstdelEntity = new List<EntitySubscription>();
            
            //set which hold users belongs to given public group
            setUsersPublicGroup = ReleaseTriggerHandler.userOfPublicGroup(lstPublicGroup);
            for(Release__c rel : lstRelease)
            {
                setRelIds.add(rel.Id);  
            }
            
            //fetching users following releases
            lstUsersFollowRelease = [Select id,ParentId,SubscriberId from EntitySubscription where ParentId IN :setRelIds LIMIT 1000];
            system.debug('lstUsersFollowRelease:'+ lstUsersFollowRelease);
            for(EntitySubscription follow : lstUsersFollowRelease)
            {
                if(mapReleaseEntityRecord.containsKey(follow.ParentId)) 
                {
                    mapReleaseEntityRecord.get(follow.ParentId).add(follow);
                }
                else
                {
                    List<EntitySubscription> temprecord = new List<EntitySubscription>();
                    temprecord.add(follow);
                    mapReleaseEntityRecord.put(follow.ParentId,temprecord);
                }       
            }
            System.debug('mapReleaseEntityRecord:'+ mapReleaseEntityRecord);
            
            //Unfollow users following releases and belongs to public groups
            if(mapReleaseEntityRecord != null && mapReleaseEntityRecord.size() > 0) 
            {
                for(Id relId : mapReleaseEntityRecord.keySet())
                {
                    for(EntitySubscription entity : mapReleaseEntityRecord.get(relId))
                    {   
                        if(setUsersPublicGroup.contains(entity.SubscriberId))   
                        {
                            lstdelEntity.add(entity);   
                        }   
                    }   
                }   
            }   
            System.debug('lstdelEntity:'+ lstdelEntity);
            delete lstdelEntity;
        }
        // Managing the error.
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}