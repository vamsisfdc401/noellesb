/*****************************************************************************************
Class Name: DGF_VODRePriceBatchTest
Purpose: Test class for apex class DGF_VODRePriceBatch
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/05/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public class DGF_VODRePriceBatchTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-42
    ***********************************/
    static testMethod void scenario1(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        
        //create the release
        list<Digital_Release__c>releaseList=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insert releaseList; 
        
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(3, releaseList);
        insert prdList;
        
        // create VOD Pricing Records
        list<Pricing__c>USpriceList1=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'VOD', prdList[0].id);
        insert USpriceList1;
        list<Pricing__c>CApriceList1=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdList[0].id);
        insert CApriceList1;
        list<Pricing__c>USpriceList2=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'VOD', prdList[1].id);
        insert USpriceList2;
        list<Pricing__c>CApriceList2=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdList[1].id);
        insert CApriceList2;
        list<Pricing__c>USpriceList3=DGF_TestDataUtility.createPricing('US', true, true, true, true, 'VOD', prdList[2].id);
        insert USpriceList3;
        list<Pricing__c>CApriceList3=DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdList[2].id);
        insert CApriceList3;
        
        test.startTest();
        //set the VOD Tier on the Product
        prdList[0].US_VOD_Tier__c='Pre-Theatrical';
        prdList[0].CA_VOD_Tier__c='Pre-Theatrical';
        prdList[0].RecordTypeId=FilmPrdRecTypeId;
        update  prdList[0];
        prdList[1].US_VOD_Tier__c='Day and Date with Theatrical';
        prdList[1].CA_VOD_Tier__c='Day and Date with Theatrical';
        prdList[1].RecordTypeId=FilmPrdRecTypeId;
        update  prdList[1];
        prdList[2].US_VOD_Tier__c='Current';
        prdList[2].CA_VOD_Tier__c='Current';
        prdList[2].RecordTypeId=FilmPrdRecTypeId;
        update  prdList[2];
        //set the category on the Pricing
        for(Pricing__c pr:USpriceList1){
            pr.Category__c='Pre-Theatrical';
        }
        update USpriceList1;
        
        
        for(Pricing__c pr:CApriceList1){
            pr.Category__c='Pre-Theatrical';
        }
        update CApriceList1;
        for(Pricing__c pr:USpriceList2){
            pr.Category__c='Day and Date with Theatrical';
        }
        update USpriceList2;
        
        
        for(Pricing__c pr:CApriceList2){
            pr.Category__c='Day and Date with Theatrical';
        }
        update CApriceList2;
        
        for(Pricing__c pr:USpriceList3){
            pr.Category__c='Current';
        }
        update USpriceList3;
        
        
        for(Pricing__c pr:CApriceList3){
            pr.Category__c='Current';
        }
        update CApriceList3;
        //invoke the batch process
        DGF_VODRePricingBatch btch=new DGF_VODRePricingBatch();
        database.executebatch(btch,100);
        list<Pricing__c>prList=[SELECT ID FROM Pricing__c where Product__c =: prdList[0].id];
        System.assertEquals(8,prList.size());
        test.stopTest();
        
        
    }
}