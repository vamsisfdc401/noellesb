/**
* @LastmModifiedby --> saurav
* @LastModifieddate --> 28/02/2019
*
* @group --> NBCU : Home Entertainment(Film), App: POP
*
* @description --> This trigger will be used to delegate the 
*                  new values to Handler class.
*/
trigger Promo_SetCompanyCode on Orders__c (before insert, before update, After update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //When a Promo Order is inserted, set the Company Code and the Label Code
            //One user may have multiple Company codes. Set the first record found by default
            List <Promo_Company_Code__c> CompanyCodes = [select Id from Promo_Company_Code__c where OwnerId = :userInfo.getUserID() and Default__c = true];
            for (Orders__c PromoOrders : Trigger.New) {
                if (CompanyCodes.size() > 0){
                    PromoOrders.Company_Code_Lookup__c = CompanyCodes[0].Id;
                }
            }
            PromoOrderTriggerHandler.executeOnBeforeInsert(Trigger.new);
        }    
        if(Trigger.isUpdate){
            PromoOrderTriggerHandler.executeOnBeforeUpdate(Trigger.new);
        }             
    }
    else if (Trigger.isAfter){ 
        if (!Trigger.isDelete){
            for (Orders__c RecordLoop : Trigger.new){
                if (RecordLoop.Expedited_Approved__c == true && RecordLoop.Status__c == 'Draft'){
                    SimpleServerSideController.submitAndProcessApprovalRequest(RecordLoop.Id);
                }
            }
        }
    }
}