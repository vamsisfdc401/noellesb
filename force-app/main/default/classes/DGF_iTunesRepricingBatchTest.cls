/*****************************************************************************************
Class Name: DGF_iTunesRepricingBatchTest
Purpose: Test class for apex class DGF_iTunesRepricingBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/05/2017           Jata               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)

public class DGF_iTunesRepricingBatchTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-152
    ***********************************/
    static testMethod void scenario1(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        //create Dogital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        Digital_Release__c dgRels = releaseList[0];
        dgRels.US_Physical_Street_Date__c = System.today();
        dgRels.CA_Physical_Street_Date__c = System.today();
        dgRels.US_iTunes_Price_Date__c = System.today(); 
        dgRels.CA_iTunes_Price_Date__c = System.today();
        insert dgRels;
        System.assert(dgRels!=null);
        
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(10, releaseList);
        for(Product__c prd : prdList){
            prd.RecordTypeId = FilmPrdRecTypeId;
        }
        insert prdList;
        System.assertEquals(10, prdList.size());
        
        test.startTest();
        // create VOD Pricing Records
        list<Pricing__c>USpriceList1=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prcUS = USpriceList1[0];
        prcUS.iTunes_Tier__c = 34;
        prcUS.Account__c = 'iTunes';
        prcUS.Valid_From__c = date.today() -5;
        prcUS.Valid_To__c = null;
        prcUS.SRP__c = 20;
        insert prcUS;
        
        list<Pricing__c>CApriceList1=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdList[0].id);
        Pricing__c prcCA = CApriceList1[0];
        prcCA.iTunes_Tier__c = 34;
        prcCA.Account__c = 'iTunes';
        prcCA.Valid_From__c = date.today() -5;
        prcCA.Valid_To__c = null;
        prcCA.SRP__c = 20;
        insert prcCA;
        //invoke the batch process
        DGF_iTunesRepricingBatch btch=new DGF_iTunesRepricingBatch();
        database.executebatch(btch,10);
        
        List<Pricing__c> prcList = [Select Id from Pricing__c where Product__c =: prdList[0].id];
        //Scheduling
        DGF_iTunesRepricingBatchScheduler sched=new DGF_iTunesRepricingBatchScheduler();
          String sch = '0 0 23 * * ?';
            system.schedule('Test Job', sch, sched);
       test.stopTest();
    }
}