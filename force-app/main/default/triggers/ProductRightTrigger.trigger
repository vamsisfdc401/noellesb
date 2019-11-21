trigger ProductRightTrigger on Product_Right__c (before insert, after insert, before update, after update, before delete,after delete) {
    
    //check after context
    if (trigger.isAfter){
        GBSProductRightTriggerHandler.buildProductDetailString();
       GBSProductRightTriggerHandler.SetLMSFlagonParentContract();
    }
    else if (trigger.isBefore && trigger.isinsert)
    {
         for( Product_Right__c PRT: Trigger.new)
         {
            PRT.Product_LMS_Status__c = PRT.Product_Flag__c;
         }
    }
}