/*****************************************************************************************
Class Name: DGF_TPRPricingControllerTest
Purpose: Test class for apex class DGF_TPRPricingController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             14/06/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public  with Sharing class DGF_TPRPricingControllerTest {
    static list<Promotion__c>promoList{get;set;}
    static list<Promotion_Product__c>promoPrd{get;set;}
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test creation and updation of US TPR Prices-DFOR-43
    ***********************************/
    static testMethod void scenario1() {
        //method to create the data
        createData();
        test.startTest();
        String accountId;
        //fetch the Promotion products by passing the promotion ID
        List<DGF_TPRPricingWrapper.ProductPricingWrapper>wrpList = DGF_TPRPricingController.fetchRelatedRecords(promoList[0].id,accountId);
        for(DGF_TPRPricingWrapper.ProductPricingWrapper wrp:wrpList) {
            //create US EST TPR Prices
            wrp.edited = 'US-EST-SD-WSP-TPR;US-EST-HD-WSP-TPR;US-EST-UHD-WSP-TPR;US-EST-3D-WSP-TPR;CA-EST-SD-WSP-TPR;';
            wrp.edited += 'CA-EST-HD-WSP-TPR;CA-EST-UHD-WSP-TPR;CA-EST-3D-WSP-TPR; US-EST-SD-SRP-TPR;US-EST-HD-SRP-TPR;US-EST-UHD-SRP-TPR;';
            wrp.edited += 'US-EST-3D-SRP-TPR;CA-EST-SD-SRP-TPR;CA-EST-HD-SRP-TPR;CA-EST-UHD-SRP-TPR;CA-EST-3D-SRP-TPR';
            
            wrp.usESTSDWSPTPR = '10';
            wrp.usESTHDWSPTPR = '10';
            wrp.usESTUHDWSPTPR = '10';
            wrp.usEST3DWSPTPR = '10';
            wrp.caESTSDWSPTPR = '10';
            wrp.caESTHDWSPTPR = '10';
            wrp.caESTUHDWSPTPR = '10';
            wrp.caEST3DWSPTPR = '10';
            
            wrp.usESTSDSRPTPR = '10';
            wrp.usESTHDSRPTPR = '10';
            wrp.usESTUHDSRPTPR = '10';
            wrp.usEST3DSRPTPR = '10';
            wrp.caESTSDSRPTPR = '10';
            wrp.caESTHDSRPTPR = '10';
            wrp.caESTUHDSRPTPR = '10';
            wrp.caEST3DSRPTPR = '10';
            
            wrp.edited += ';US-VOD-SD-WSP-TPR;US-VOD-HD-WSP-TPR;US-VOD-UHD-WSP-TPR;US-VOD-3D-WSP-TPR;CA-VOD-SD-WSP-TPR;CA-VOD-HD-WSP-TPR;CA-VOD-UHD-WSP-TPR;CA-VOD-3D-WSP-TPR';
            wrp.usVODSDWSPTPR = '10';
            wrp.usVODHDWSPTPR = '10';
            wrp.usVODUHDWSPTPR = '10';
            wrp.usVOD3DWSPTPR = '10';
            wrp.caVODSDWSPTPR = '10';
            wrp.caVODHDWSPTPR = '10';
            wrp.caVODUHDWSPTPR = '10';
            wrp.caVOD3DWSPTPR = '10';
            wrp.dateChanged = true;
            wrp.startDate = '2020-10-10';
            wrp.endDate = '2020-10-10';
        }
        string strJSON = JSON.serialize(wrpList);
        DGF_TPRPricingController.saveTPRPrices(strJSON, 'Account Promotion',promoList[0].id,promoList[0].Territory__c);
        //update the iTunes Pricing
        for(DGF_TPRPricingWrapper.ProductPricingWrapper wrp:wrpList) {
            wrp.edited  += ';US-SD-SRP-TPR_iTunes;US-HD-SRP-TPR_iTunes;US-UHD-SRP-TPR_iTunes;US-3D-SRP-TPR_iTunes;';
            wrp.edited += 'CA-SD-SRP-TPR_iTunes;CA-HD-SRP-TPR_iTunes;';
            wrp.edited += 'CA-UHD-SRP-TPR_iTunes;CA-3D-SRP-TPR_iTunes';
            wrp.usVODSDWSPTPR = '10';
            wrp.usVODHDWSPTPR = '10';
            wrp.usVODUHDWSPTPR = '10';
            wrp.usVOD3DWSPTPR = '10';
            wrp.caVODSDWSPTPR = '10';
            wrp.caVODHDWSPTPR = '10';
            wrp.caVODUHDWSPTPR = '10';
            wrp.caVOD3DWSPTPR = '10';
        }
        string strJSON1 = JSON.serialize(wrpList);
        DGF_TPRPricingController.saveTPRPrices(strJSON1, 'Account Promotion',promoList[0].id,promoList[0].Territory__c);
        
        System.assertEquals(3,DGF_TPRPricingController.getProdCount(promoList[0].id));
        DGF_TPRPricingController.getProfileDetails(promoList[0].id);
        //delete a promotion-product
        DGF_TPRPricingController.deletePromoProduct(promoPrd[0].id, 'promo');
        test.stopTest();
        
    }
    /***********************************
    Method Name: scenario2
    Purpose: method to testCollections-DFOR-43
    ***********************************/
    static testMethod void scenario2(){
        //method to create data
        createData();
        List<DGF_TPRPricingWrapper.ProductPricingWrapper>wrpList1 = DGF_TPRPricingController.fetchCollections(promoList[0].id);
        string strJSON = JSON.serialize(wrpList1);
        //edit a promotion product
        DGF_TPRPricingController.editPromoPrd(strJSON, 0);
        //get the recordType of the promotion
        DGF_TPRPricingController.fetchRecordType(promoList[0].id);
        //get the promotion type of the promotion
        System.assertEquals('Collection', DGF_TPRPricingController.fetchPromotionType(promoList[0].id));
        
    }
    
    /***********************************
    Method Name: scenario3
    Purpose: method to negative scenarios for DFOR-43
    ***********************************/
    static testMethod void scenario3() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId(); 
        Id NatRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('National Promotion').getRecordTypeId(); 
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        String accountId;
        insert releaseList;
        Product__c prd = new Product__c(Name='test', Digital_Release__c=releaseList[0].id);
        insert prd;
        promoList = DGF_TestDataUtility.createPromotion(2, AccRecTypeId);
        insert promoList;
        
        promoPrd = DGF_TestDataUtility.createPromoProd(1,prd.id,promoList[0].id);
        insert promoPrd;
        //fetch records where Product's platform offering is null
        List<DGF_TPRPricingWrapper.ProductPricingWrapper>wrpList1 = DGF_TPRPricingController.fetchRelatedRecords(promoList[0].id, accountId);
        string strJSON1 = JSON.serialize(wrpList1);
        
        Product__c prd1 = new Product__c(Name = 'test',Digital_Release__c = releaseList[0].id,US_Platform_Offering__c = 'iVOD',CA_Platform_Offering__c = 'cVOD');
        insert prd1;
        list<Promotion_Product__c> promoPrd1 = DGF_TestDataUtility.createPromoProd(1,prd1.id,promoList[1].id);
        insert promoPrd1;
        //fetch records where Platform offering is VOD
        List<DGF_TPRPricingWrapper.ProductPricingWrapper>wrpList2 = DGF_TPRPricingController.fetchRelatedRecords(promoList[1].id,accountId);
        string strJSON2 = JSON.serialize(wrpList2);
        list<Promotion__c> promo = DGF_TestDataUtility.createPromotion(1, NatRecTypeId);
        insert promo;
        System.assertEquals(false, DGF_TPRPricingController.getProfileDetails(promo[0].id));
        //fetch Promotion Territory
        promoList[0].Territory__c = 'US';
        update promoList;
        System.assertEquals('US', DGF_TPRPricingController.fetchPromoTerritories(promoList[0].id));
        }
    
    
    /***********************************
    Method Name: createData
    Purpose: method to create Data
    ***********************************/
    static void createData(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        //create digital release
        list<Digital_Release__c>releaseList = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert releaseList;
        //create products associated to release
        list<Product__c>prdList = DGF_TestDataUtility.createCustomProduct(2, releaseList);
        insert prdList;
        for(Product__c prd:prdList) {
            prd.Us_Platform_Offering__c = 'EST;iVOD';
            prd.CA_Platform_Offering__c = 'EST;iVOD';
            prd.recordTypeId = FilmPrdRecTypeId;
            prd.est_tier__c = 'New Release Standard';
            prd.ca_est_tier__c = 'New Release Standard';
        }
        update prdlist;
        list<Pricing__c>usPriceList = DGF_TestDataUtility.createPricing('US',true,true,true,true,'EST',prdList[0].id);
        insert usPriceList;
        
        //create CA Pricing records for the created product
        list<Pricing__c>caPriceList = DGF_TestDataUtility.createPricing('CA',true,true,true,true,'EST',prdList[0].id);
        insert caPriceList;
        Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
        
        Id NationalPromotionId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('National Promotion').getRecordTypeId();
        Id AccountPromotionId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
          
        //promoList = DGF_TestDataUtility.createPromotion(3, AccRecTypeId);
        promoList=new list<Promotion__c>();
        for(Promotion__c pro:DGF_TestDataUtility.createPromotion(3, NationalPromotionId)){
            pro.Visibility__c='Visible';
            promoList.add(pro);
        }
        for(Promotion__c pro:DGF_TestDataUtility.createPromotion(3, AccRecTypeId)){
            pro.Visibility__c='Visible';
            promoList.add(pro);
        }
        insert promoList;
        
        
        list<Account> acclist=DGF_TestDataUtility.createAccount(2);
        insert accList;
        
        list<promotion_Account__c> proAccountlist=new list<promotion_Account__c>();
        for(integer i=0;i<acclist.size();i++){
            promotion_Account__c proAcc=new promotion_Account__c(Promotion__c=promoList[i].id,Account__c=acclist[i].id);
            proAccountlist.add(proAcc);
        }
        insert proAccountlist;
        promoPrd = DGF_TestDataUtility.createPromoProd(1, prdlist[0].id,promoList[0].id);
           
        for(integer i=0;i<promoList.size();i++){
            promotion_product__c proProduct=new promotion_Product__c(TPR__c=true,TPR_Start_Date__c=date.today(),TPR_End_date__c=date.today()+30,Promotion__c=promoList[i].id,Product__c=prdlist[0].id);
            promoPrd.add(proProduct);
        }
        insert promoPrd;
        promoPrd[0].collection_start_date__c = date.today();
        promoPrd[0].collection_end_date__c = date.today();
        update promoPrd[0];
        promoPrd = DGF_TestDataUtility.createPromoProd(1, prdlist[1].id,promoList[0].id);
        
        
        insert promoPrd;
        //create pricing records
        list<Pricing__c>usiTunesList = DGF_TestDataUtility.createPricing('US', true, true, true, true, 'EST', prdlist[1].id);
        insert usiTunesList;
        for(Pricing__c p : usiTunesList) {
            p.promotion__c = promoList[0].id;
            p.account__c = 'iTunes';
            p.price_type__c = 'TPR Account';
        }
        update usiTunesList;
        
        list<Pricing__c>caiTunesList = DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'EST', prdlist[1].id);
        insert caiTunesList;
        for(Pricing__c p : caiTunesList) {
            p.promotion__c = promoList[0].id;
            p.account__c = 'iTunes';
            p.price_type__c = 'TPR Account';
        }
        update caiTunesList;
        
        list<Pricing__c>usVODPricing = DGF_TestDataUtility.createPricing('US', true, true, true, true, 'VOD', prdlist[1].id);
        insert usVODPricing;
        for(Pricing__c p : usiTunesList) {
            p.promotion__c = promoList[0].id;
            p.price_type__c = 'TPR Account';
        }
        update usVODPricing;
        
        list<Pricing__c>caVODPricing = DGF_TestDataUtility.createPricing('CA', true, true, true, true, 'VOD', prdlist[1].id);
        insert caVODPricing;
        for(Pricing__c p : caVODPricing) {
            p.promotion__c = promoList[0].id;
            p.price_type__c = 'TPR Account';
        }
        update caVODPricing;
    }
}