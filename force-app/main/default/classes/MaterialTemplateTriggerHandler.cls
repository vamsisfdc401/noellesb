/*****************************************************************************************
Class Name: MaterialTemplateTriggerHandler
Purpose: This Class is for handling Material Template's trigger logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/23/2017           Suman                    Initial Development
******************************************************************************************/
public class MaterialTemplateTriggerHandler
{
    /***********************************
    Method Name: executeOnAfterInsertUpdate
    Purpose:Should execute after after insert or update event.
    ***********************************/    
    public static void executeOnAfterInsertUpdate()
    {
        try
        {
            Map<String, Set<Id>> brandGrpUserMap = new Map<String, Set<Id>>();
            Map<String, Set<Id>> brandGrpTempltMap = new Map<String, Set<Id>>();
            List<Material_Template__share> insertableTemplateShares = new List<Material_Template__share>();
            Set<Id> updatingBrdGrpTempIds = new Set<Id>(); 
            
            // Collecting unique brand groups.
            Integer i = 0;
            for(Material_Template__c temp : (List<Material_Template__c>) Trigger.New)
            {
                if(temp.Brand_Group__c != null && temp.Brand_Group__c.trim() != '' && (Trigger.isInsert ||
                   (Trigger.isUpdate && temp.Brand_Group__c != ((Material_Template__c) Trigger.Old[i]).Brand_Group__c)))
                {
                    if(!brandGrpTempltMap.containsKey(temp.Brand_Group__c))
                        brandGrpTempltMap.put(temp.Brand_Group__c, new Set<Id>());
                    brandGrpTempltMap.get(temp.Brand_Group__c).add(temp.Id);
                    
                    // If context is on update, collect template ids to remove sharing.
                    if(Trigger.isUpdate)
                        updatingBrdGrpTempIds.add(temp.Id);
                }
                i ++;
            }
            
            // For update, if there are existing sharing rules, fetch and delete.
            if(updatingBrdGrpTempIds.size() > 0)
            {
                List<Material_Template__share> delTemplateShares = [SELECT Id FROM Material_Template__share 
                                                                    WHERE ParentId=:updatingBrdGrpTempIds AND 
                                                                          RowCause=:Schema.Material_Template__share.RowCause.Brand_Group_Sharing__c];
                if(delTemplateShares != null && delTemplateShares.size() > 0)
                {
                    delete delTemplateShares;
                }
            }
            
            // Fetching users associated to the brand groups.
            for(User usr : [SELECT Id, Brand_Group__c FROM User WHERE Brand_Group__c IN: brandGrpTempltMap.keySet() AND IsActive=true])
            {
                // Checking if user brand group is not empty.
                if(usr.Brand_Group__c != null)
                {
                    // Checking if brand group already exists or not.
                    if(!brandGrpUserMap.containsKey(usr.Brand_Group__c))
                    {
                        brandGrpUserMap.put(usr.Brand_Group__c, new Set<Id>());
                    }
                    brandGrpUserMap.get(usr.Brand_Group__c).add(usr.Id);
                }
            }
            
            // Iterate over template Brand groups and build sharing records.
            for(String brandGrp : brandGrpTempltMap.keySet())
            {
                Set<Id> templateIds = brandGrpTempltMap.get(brandGrp);
                Set<Id> userIds = brandGrpUserMap.get(brandGrp);
                
                // Iterating over current brand group templates.
                for(Id tempId : templateIds)
                {
                    // Iterating over current brand group users.
                    if(userIds != null && userIds.size() > 0)    // Added for REL-133
                    {
                        for(Id usrId : userIds)
                        {
                            // Creating template sharing.
                            Material_Template__share tempShare = new Material_Template__share();
                            tempShare.ParentId = tempId;
                            tempShare.UserOrGroupId  = usrId;
                            tempShare.AccessLevel = 'edit';
                            tempShare.RowCause = Schema.Material_Template__share.RowCause.Brand_Group_Sharing__c;
                            
                            insertableTemplateShares.add(tempShare);
                        }
                    }
                }
            }
            
            // Inserting template sharing details.
            if(insertableTemplateShares.size() > 0)
            {
                insert insertableTemplateShares;
            }
        }
        catch(Exception ex)
        {
            if(Trigger.New.size() > 0)
                Trigger.New[0].addError('ERROR: '+ex.getMessage());
        }
    }
}