public class PromoOrder_CancelOrderByAdmin {
    @AuraEnabled
    public static Boolean IsUserPromoAdmin(){
        //Lookup to check if the SPARK Admin Multi select pick list field has value 'Promo Order' in it
        Boolean PromoAdmin 	= false;
        String AdminValue 	= [SELECT SPARK_Admin__c FROM User WHERE id =:userinfo.getUserId()][0].SPARK_Admin__c;
        system.debug('AdminValue: ' + AdminValue);
        Integer AdminUser 	= -1;
        if (AdminValue != null && AdminValue != ''){
	         AdminUser 		= AdminValue.indexOf('Promo Order');
        }
        if (AdminUser != -1){
            PromoAdmin = true;
        }
        return PromoAdmin;
    }
    @AuraEnabled
    public static String OrderStatus(Id PromoOrderId){
        String PromoOrderStatus = [Select Status__c from Orders__c where Id = :PromoOrderId][0].Status__c;
        return PromoOrderStatus;
    }
    @AuraEnabled
    public static Boolean CancelPromoOrder(Id PromoOrderId){
        //Try and cancel the Promo Order. Bypass the validations to cancel the order
        Boolean OrderCanceled 	= false;
        Bypass_TPWV__c BypassCS = Bypass_TPWV__c.getInstance();
        Boolean BypassValidations = BypassCS.Bypass_Validation_Rules__c;
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = true;
            upsert BypassCS;
        }
        
        //First cancel all the Promo Order Materials under the selected Order
        List <Promo_Order_Materials__c> PromoOrderMaterials = [Select Id, Status__c from Promo_Order_Materials__c where Order_ID__c = :PromoOrderId];
        for (Promo_Order_Materials__c PromoMaterials : PromoOrderMaterials){
            PromoMaterials.Status__c = 'X';
        }
        Update PromoOrderMaterials;
        //Now cancel the main order itself
        for (Orders__c PromoOrder : [Select Id, Status__c, pop_integration_status__c from Orders__c where Id = :PromoOrderId]){
            PromoOrder.Status__c = 'X';
            PromoOrder.pop_integration_status__c = '';
            Update PromoOrder;
            OrderCanceled = true;
        }
        
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = false;
            upsert BypassCS;
        }
        return OrderCanceled;
    }
}