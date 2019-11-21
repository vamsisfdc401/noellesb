public class SimpleServerSideController {
    @AuraEnabled
    public static boolean submitAndProcessApprovalRequest(id promoid)
    {
        User userRecord = [SELECT Id FROM User WHERE id =:userinfo.getUserId()];
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval');
        req1.setObjectId(promoid );
        req1.setSubmitterId(userRecord.ID);
        system.debug('user record :'+userRecord.id);
        List <Orders__c> PromoOrderRecord = [select Id, Shipping_Conditions__c, Expedited_Approved__c, Status__c from Orders__c where Id =: promoid];
        if (PromoOrderRecord[0].Shipping_Conditions__c != 'Z1' && PromoOrderRecord[0].Expedited_Approved__c == false){
            req1.setProcessDefinitionNameOrId('Ask_for_Approvals_Expedited_Shipping');// provide approval process name
        } else {
            req1.setProcessDefinitionNameOrId('Ask_for_Approvals');// provide approval process name
        }
        //req1.setSkipEntryCriteria(true);
        // Submit the approval request for the account
        Approval.ProcessResult result1 = Approval.process(req1);
        system.debug('error code'+result1.getErrors());
        system.debug('result check'+result1.isSuccess());
        // First, get the ID of the newly created item    }
        return result1.isSuccess();
    }
    @AuraEnabled
    public static Decimal ThresholdOfSubmitter(){
        Decimal ThresholdValue = [SELECT Promo_Approval_Threshold_Amount__c FROM User WHERE id =:userinfo.getUserId()][0].Promo_Approval_Threshold_Amount__c;
        system.debug(ThresholdValue);
        if (ThresholdValue != null){
            return ThresholdValue;
        } else {
            return 0;
        }
        
    }
}