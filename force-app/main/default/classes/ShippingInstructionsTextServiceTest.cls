/**
* @author --> saurav
* @date --> 28/02/2019
*
* @group --> NBCU : Home Entertainment(Film), App: POP
*
* @description --> This class is used to cover unit test for ShippingInstructionsTextService.
*/


@isTest
public class ShippingInstructionsTextServiceTest {
    
    /**
    * @description --> Creating Test Data for unit test
    * @param --> NA
    * @return --> NA
    */
    @testSetup static void createData(){
        Id soldToAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Promo Orders').getRecordTypeId();
        Account soldToAccount= new Account(name='TestPromoAccount', RecordTypeId=soldToAccountRecordType);
        insert soldToAccount;
      
        Id soldToContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Promo Order Contact').getRecordTypeId();
		Contact contact = new contact(LastName='test', RecordtypeId= soldToContactRecordType, AccountId = soldToAccount.Id);
        insert contact;
        //To Store test promoOrder records
        List<Orders__c> promoOrderListToInsert = new List<Orders__c>();

        promoOrderListToInsert.add(new Orders__c(
            								 Request_Name__c ='Testing Promo Order',
                                             SSO_ID__c = '123456789',
                                             Purpose_for_Request__c = 'Free Goods',
                                             Requested_Delivery_Date__c = System.today().addMonths(1),
								             Special_Shipping_Instructions__c = 'Test',
									         Ship_To_Contact__c = contact.Id,
            								 Sold_to_Name__c = soldToAccount.Id
                                            ));
        insert promoOrderListToInsert;
    }
    
    
    /**
    * @description --> Unit Test for validation of special characters in SpecialShippingInstructions 
    * @param --> NA
    * @return --> NA
    */  
    @isTest
	public static void testValidation(){
        try{
            Orders__c order = [SELECT ID, Special_Shipping_Instructions__c FROM Orders__c limit 1];
            order.Special_Shipping_Instructions__c = '#';
            update order;
            System.assert(true, 'Failed to check the validation error');
        }
        catch(Exception ex){
			System.assertEquals(true, ex.getMessage().contains(Label.ErrorSpecialShippingInstructions), 'Fail to add ErrorSpecialShippingInstructions validation');
        }
	}
    
    
    /**
    * @description --> Unit Test for removing special characters from SpecialShippingInstructions 
    * @param --> NA
    * @return --> NA
    */ 
    @isTest
	public static void testIgnoreSave(){
		Orders__c order = [SELECT ID, Special_Shipping_Instructions__c FROM Orders__c limit 1];
		order.Special_Shipping_Instructions__c = 'first line \n secondline';
        update order;
        order = [SELECT ID, Special_Shipping_Instructions__c FROM Orders__c where Id =:order.Id];
        System.assertEquals(order.Special_Shipping_Instructions__c, 'first line secondline', 'Failed to update Special_Shipping_Instructions__c');
	}
	
}