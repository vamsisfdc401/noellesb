/*****************************************************************************************
Class Name: DGF_iTunesPricingUpdateMarginBatchTest
Purpose: Test class for apex class DGF_iTunesPricingUpdateMarginDateBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/11/2017           Nandeesh               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)

public class DGF_iTunesPricingUpdateMarginBatchTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-1070
    ***********************************/
    static testMethod void scenario1() {
        
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP', CollaborationType = 'Public');
        insert cg;
        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
        //create Digital release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        Digital_Release__c dgRels = releaseList[0];
        dgRels.New_to_UHD_US_EST_Release_Date__c = System.today();
        dgRels.New_to_UHD_CA_EST_Release_Date__c = System.today();
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
        prcUS.Valid_To__c = System.today()+ 2;
        prcUS.SRP__c = 20;
        insert prcUS;
        
        list<Pricing__c>CApriceList1=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdList[0].id);
        Pricing__c prcCA = CApriceList1[0];
        prcCA.iTunes_Tier__c = 34;
        prcCA.Account__c = 'iTunes';
        prcCA.Valid_From__c = date.today() -5;
        prcCA.Valid_To__c = System.today()+ 2;
        prcCA.SRP__c = 20;
        insert prcCA;
        
        // for Creating New Record
        list<Pricing__c>USpriceList2=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prc1US = USpriceList2[0];
        prc1US.iTunes_Tier__c = 34;
        prc1US.Valid_From__c = System.today() - 5;
        prc1US.Valid_To__c = System.today()+ 2;
        prc1US.SRP__c = 20;
        insert prc1US;
    
        // For Cloning
        list<Pricing__c>USpriceList3=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prc2US = USpriceList3[0];
        prc2US.iTunes_Tier__c = 34;
         prc2US.Price_Type__c ='Reprice';
        prc2US.Valid_From__c = System.today() + 5;
        prc2US.Valid_To__c = System.today()+ 2;
        prc2US.SRP__c = 20;
        insert prc2US;
        
        // For Cloning
        list<Pricing__c>CApriceList3=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prc2CA = CApriceList3[0];
        prc2CA.iTunes_Tier__c = 34;
         prc2CA.Price_Type__c ='Reprice';
        prc2CA.Valid_From__c = System.today() + 5;
        prc2CA.Valid_To__c = System.today()+ 2;
        prc2CA.SRP__c = 20;
        insert prc2CA;
        
        
        // For Cloning
        list<Pricing__c>USpriceList4=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prc2US1 = USpriceList4[0];
        prc2US1.iTunes_Tier__c = 34;
        prc2US1.Territory__c = 'US';
        prc2US1.Price_Type__c ='Reprice';
        prc2US1.Valid_From__c = System.today()-50;
        prc2US1.Valid_To__c = System.today()+ 2;
        prc2US1.SRP__c = 20;
        insert prc2US1;
        
        // For Cloning
        list<Pricing__c>CApriceList4=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'EST', prdList[0].id);
        Pricing__c prc2CA1 = CApriceList4[0];
        prc2CA1.iTunes_Tier__c = 34;
        prc2CA1.Territory__c = 'CA';
        prc2CA1.Price_Type__c ='Reprice';
        prc2CA1.Valid_From__c = System.today() -50;
        prc2CA1.Valid_To__c = System.today()+ 2;
        prc2CA1.SRP__c = 20;
        insert prc2CA1;
        
        //invoke the batch process
        DGF_iTunesPricingUpdateMarginDateBatch btch=new DGF_iTunesPricingUpdateMarginDateBatch();
        database.executebatch(btch,10);
        
        List<Pricing__c> prcList = [Select Id from Pricing__c where Product__c =: prdList[0].id];
       // System.assertEquals(23, prcList.size());
      
        //Scheduling
        DGF_iTunesPricingUpdateBatchScheduler sched=new DGF_iTunesPricingUpdateBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Job', sch, sched);
    }
}