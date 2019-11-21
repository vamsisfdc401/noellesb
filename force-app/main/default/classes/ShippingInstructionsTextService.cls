/******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/28/2019           saurav                   Initial Development
******************************************************************************************/
/**
* @author --> Saurav
* @date --> 28/02/2019
*
* @group --> NBCU : Home Entertainment(Film), App: POP
*
* @description --> This class will handle below functionalities:
* a) Removing special characters from SpecialShippingInstructions(Promo Order)
* b) Checking special characters in SpecialShippingInstructions(Promo Order)
* @USST-3364 : RITM1631198: SPARK : Non-ASCII characters must be removed from header text when sent to SAP
*/

public with sharing class ShippingInstructionsTextService {
    
    
    
    /**
* @description --> Removing special characters from SpecialShippingInstructions
* @param --> listPromoOrder : List of Promo Order Records
* @return --> NA
*/   
    public static void removingSpecialCharactersFromSpecialShippingInstructions(List<Orders__c> listOfPromoOrder){
        for(Orders__c promoOrder: listOfPromoOrder){
            promoOrder.Special_Shipping_Instructions__c = cleanTextContent(promoOrder.Special_Shipping_Instructions__c);
        }
    }
    
    
    /**
* @description --> Replacing special characters and reoccurring whitespace from SpecialShippingInstructions
* @param --> String- SpecialShippingInstructions
* @return --> string
*/  private static String cleanTextContent(String text){
        if(text != null){
            text = text.replaceAll('[^\\x00-\\x7F]', '');
            text = text.replaceAll('\\s+',' ');
        }
        return text;
    }
    
    /**
* @method --> checkSpecialChars
* @description --> checking for special characters in SpecialShippingInstructions
* @param --> listPromoOrder : List of Promo Order Records
* @return --> NA
*/  
    public static boolean checkSpecialCharsInSpecialShippingInstructions(List<Orders__c> listOfPromoOrder){
        boolean retVal = true;
        if(listOfPromoOrder!=null && listOfPromoOrder.size()>0){
            for(Orders__c promoOrder : listOfPromoOrder){
                if(promoOrder.Special_Shipping_Instructions__c!= null){
                    String shipingTextRegEx=Label.SpecialCharacters_Regex;
                    Pattern MyPattern = Pattern.compile(shipingTextRegEx);
                    Matcher MyMatcher= null;
                    MyMatcher = MyPattern.matcher(promoOrder.Special_Shipping_Instructions__c.trim());
                    if(MyMatcher.find(0)==true){
                        promoOrder.addError(Label.ErrorSpecialShippingInstructions, false);
                        retVal = false;
                    }
                }
            }        
        }
        return retVal;
    } 
}