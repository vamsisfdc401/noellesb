/*****************************************************************************************
Trigger Name: AfterupdatevProject
Purpose: Trigger on v_Project_Request__c object
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016                                    Initial Development
******************************************************************************************/
trigger AfterupdatevProject on v_Project_Request__c (After Insert,After Update) {
    if(trigger.isInsert && trigger.isAfter){// || trigger.isUpdate
        vProjectUtility.updateReleaseVProject(trigger.new);
    }
    if(!TriggerUtility.hasTriggerExecuted('v_Project_Request__c')){
        if(trigger.isUpdate && trigger.isAfter){// || trigger.isUpdate
            vProjectUtility.updateVProject(trigger.new);
        }
    }
}