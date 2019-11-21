@isTest
private class serversideController_test {
    
    @isTest static void CreatePromoOrder() {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Promo Orders').getRecordTypeId();
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Promo Order Contact').getRecordTypeId();
        Account Newt = new Account( Name = 'Test1',
                                   //Sold_To__c = '25035',
                                   Territory__c = 'US',
                                   Promo_Country__c = 'US',
                                   //Ship_To_Code__c = '68221',
                                   recordtypeid = RecordTypeIdAccount
        );
        insert Newt;
 		Contact Con = new Contact( AccountId = Newt.Id,
                                   LastName = 'Syed',
                                   recordtypeid=RecordTypeIdContact,
                                  Promo_Country__c ='US',
                                   Territory__c ='US'
                                   
        );
        insert Con;
        Material__c Pop = new Material__c(Name = 'PromoTestMat',
                                          Format_Description__c = 'DVD',
                                          Format__c = '02 - DVD',
                                          Territory__c = 'US',
                                          Material_Type__c = 'FERT',
                                          UPC__c = '12345698745',
                                          Material_Number__c = '234567890',
                                          CIRF_US_D_Chain_Spec__c = 'NR - New Release',
                                          CIRF_CDN_D_Chain_Spec__c = 'NR - New Release',
                                          Street_Date__c = System.today().adddays(1),
                                          Item_Code__c = 'SS - SINGLE SELECTION',
                                          Item_Type__c = 'S (Single)',
                                          Label_code__c = '61 - Universal Pictures'
                                          //Release__c = releaseId
        );
        insert Pop;
        Orders__c PromoOrder = new Orders__c(Request_Name__c            ='Testing Promo Order',
                                             SSO_ID__c                  = '123456789',
                                             Purpose_for_Request__c     = 'Free Goods',
                                             Days_Ok_before_Street__c = 10,
                                             Requested_Delivery_Date__c = System.today().adddays(1),
                                             Sold_to_Name__c = Newt.Id,
                                             Ship_To_Contact__c = Con.Id
                                             );
        insert PromoOrder;
        Promo_Order_Materials__c material= new Promo_Order_Materials__c(Order_ID__c = PromoOrder.Id,
                                                                    	Material_Description__c = Pop.Id,
                                                                        Quantity__c = 10
                                                                        
        );
        insert material;
        test.startTest();
        SimpleServerSideController.submitAndProcessApprovalRequest(PromoOrder.id);
        Decimal ThresholdLimit = SimpleServerSideController.ThresholdOfSubmitter();
    	test.stoptest();
    }
    
}