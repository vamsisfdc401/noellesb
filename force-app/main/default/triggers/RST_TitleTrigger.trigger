/*****************************************************************************************
TriggerName: UpdatePlayWeekDates 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/27/2019           Piyush                    Initial Development
******************************************************************************************/
trigger RST_TitleTrigger on RST_Title__c (after update) {
 if(trigger.isafter && Trigger.isUpdate){
     RST_TitleTriggerHandler.updatePlayWeekDate(trigger.new,trigger.oldMap);
 }
}