/***********************************************************************************
Class Name: DGF_RightsDigitalReleaseUpdateBatchClassTest
Purpose: Test class for apex class DGF_RightsDigitalReleaseUpdateBatchClassTest and DGF_RightsDigitalReleaseUpdateScheClass
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Mohit                    Initial Development
******************************************************************************************/

@isTest(seeAllData=FALSE)
public class DGF_RightsDigitalRelUpdateBatchClassTest {

    static testMethod void scenario() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        // create a title
        List<Title__c> titleList = new List<Title__c>();
        titleList= DGF_TestDataUtility.createTitle(1);
        
        test.startTest();
        //insert the created title records
            insert titleList;
        // creating TM Version
            list<TM_Version__c>tmvList = DGF_TestDataUtility.createTmVersion(1, titleList);
            for(TM_Version__c tmv : tmvList){
                tmv.Original_Flag__c = TRUE;
            }       
            insert tmvList;
        //Creating Right records
            Right__c USVOD = DGF_TestDataUtility.createRights(titleList[0].id,'VOD','US',true);
            insert USVOD;
            Right__c USEST = DGF_TestDataUtility.createRights(titleList[0].id,'EST','US',true);
            insert USEST;
            Right__c CAVOD = DGF_TestDataUtility.createRights(titleList[0].id,'VOD','CA',true);
            insert CAVOD;
            Right__c CAEST = DGF_TestDataUtility.createRights(titleList[0].id,'EST','CA',true);
            insert CAEST;
            
            Digital_Release__c dg = new Digital_Release__c(Name='test',title__c=titleList[0].id,
                                                           RecordTypeId=FilmRecTypeId,US_Product_Type__c='Theatrical',
                                           					CA_Product_Type__c='Theatrical',
                                                           US_Physical_Street_Date__c=date.today(),
                                                           US_Theatrical_Release_Date__c=date.today());
        // inserting digital release
            insert dg;
        //Create an instance for Batch Class
        	DGF_RightsDigitalReleaseUpdateBatchClass obj = new DGF_RightsDigitalReleaseUpdateBatchClass();
			DataBase.executeBatch(obj); 
        	
        // Scheduel the Batch class.
        	DGF_RightsDigitalReleaseUpdateScheClass.scheduleMe();
        
        	
        Test.stopTest();
    
    }
}