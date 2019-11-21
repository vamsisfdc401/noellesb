trigger GBSIntellectualPropertyRightTrigger on Intellectual_Property_Right__c (before insert, after insert, before update, after update, before delete,after delete) {
    //check after context
    if (trigger.isAfter){
        GBSIPRightTriggerHandler.buildIPDetailString();
    }
}