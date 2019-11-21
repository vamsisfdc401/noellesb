/**
* @author --> Saurav
* @date --> 28/02/2019
*
* @group --> NBCU : Home Entertainment(Film), App: POP
*
* @description --> This class will delegate control to Service layer(ShippingInstructionsTextService Apex class).
*/

public with sharing class PromoOrderTriggerHandler {
    
    
    /**
    * @description --> Handles before Insert trigger event
    * @method--> executeOnBeforeInsert
    * @param --> listOfPromoOrder :  Records to be inserted
    * @return --> NA
    */ 
    public static void executeOnBeforeInsert(List<Orders__c> listOfPromoOrder){
        //Checking special characters in SpecialShippingInstructions
        if(ShippingInstructionsTextService.checkSpecialCharsInSpecialShippingInstructions(listOfPromoOrder)){
			ShippingInstructionsTextService.removingSpecialCharactersFromSpecialShippingInstructions(listOfPromoOrder);
        }
    }
    
    
   /**
    * @description --> Handles before update trigger event
    * @method--> executeOnBeforeUpdate
    * @param --> listOfPromoOrder :  Records to be updated
    * @return --> NA
    */ 
    public static void executeOnBeforeUpdate(List<Orders__c> listOfPromoOrder){
        // Checking special characters in SpecialShippingInstructions
        if(ShippingInstructionsTextService.checkSpecialCharsInSpecialShippingInstructions(listOfPromoOrder)){
	        ShippingInstructionsTextService.removingSpecialCharactersFromSpecialShippingInstructions(listOfPromoOrder);
        }
    }
}