/*****************************************************************************************
TriggerName: GBSProductRightsGroupTrigger
Purpose: Trigger for Product_Rights_Group__c Object
Version : 1.0
DateModified : 05/07/2018
ModifiedBy : Harsha Vardhan P
JIRA : GBS-14
******************************************************************************************/
trigger GBSProductRightsGroupTrigger on Product_Rights_Group__c (after insert, after update) {

    if(trigger.isAfter && trigger.isInsert){
       //call the productRightsGroupInsert of GBSProductRightsGroupTriggerHandler while inserting PRG records 
        GBSProductRightsGroupTriggerHandler.productRightsGroupInsert(trigger.new); 
    }else if(trigger.isAfter && trigger.isUpdate){
        //call the productRightsGroupUpdate of GBSProductRightsGroupTriggerHandler while updating PRG records
        GBSProductRightsGroupTriggerHandler.productRightsGroupUpdate(trigger.new, trigger.oldmap);  
    }
}