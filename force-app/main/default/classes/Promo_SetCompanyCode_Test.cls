@isTest
private class Promo_SetCompanyCode_Test {
    @isTest static void CreatePromoOrder() {
        Orders__c PromoOrder = new Orders__c(Request_Name__c            ='Testing Promo Order',
                                             SSO_ID__c                  = '123456789',
                                             Purpose_for_Request__c     = 'Free Goods',
                                             Requested_Delivery_Date__c = System.today().addMonths(1)
                                            );
        insert PromoOrder;
        delete PromoOrder;
    }
}