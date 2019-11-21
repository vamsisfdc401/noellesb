/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (seeAllData=FALSE)
private class DGF_OrderOfBundleTitlesControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        List<string> orderTitles = new List<string> {'Order 1','Order 2','Order 3','Order 4'};
        string orderTitleString = '';
        String searchTitleKey = '';
        
            for(String mystr : orderTitles ){
                orderTitleString += mystr+'\r\n';
            }
        
        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
        //
        Title__c DigiTitle =  DGF_TestDataUtility.createTitle(1).get(0);
        insert digiTitle ;
        searchTitleKey = digiTitle.name;
        
        //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        releaseList[0].Order_of_Titles__c = orderTitleString;
        insert releaseList;
        
        List<String> returnString = DGF_OrderOfBundleTitlesController.fetchTitles(releaseList[0].id);
        
        string updateResponse = DGF_OrderOfBundleTitlesController.updateTitles(releaseList[0].id, returnString);
        
        system.assertEquals(updateResponse, 'sucess!');
        
        releaseList[0].Order_of_Titles__c = '';
        
        update releaseList;
        
        List<String>  returnStringNA = DGF_OrderOfBundleTitlesController.fetchTitles(releaseList[0].id);
        system.debug('returnStringNA'+ returnStringNA);
        
        //check product user
        System.AssertEquals(FALSE, DGF_OrderOfBundleTitlesController.getProductUser());
        
        //Search Titles
        System.AssertEquals(new List<string>{searchTitleKey}, DGF_OrderOfBundleTitlesController.searchTitles(searchTitleKey));
        
        
        
    }
}