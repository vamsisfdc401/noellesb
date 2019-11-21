/***********************************************************************************
Class Name: DGF_ProductTriggerHandlerTest
Purpose: Test class for apex class DGF_ProductTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/04/2017           Jata                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_ProductTriggerHandlerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-44
    ***********************************/
    static testMethod void scenario1() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insertdgtlRels[0].US_EPO_Date__c = date.today() - 10;
        insertdgtlRels[0].CA_EPO_Date__c = date.today() - 10;
        
        //inserting Digital Release
        insert insertdgtlRels;
        System.assertEquals(1, insertdgtlRels.size());
        
        //insert Pricing Tier
        list<Pricing_Tier__c>ptList=new list<Pricing_Tier__c>();
        ptList=DGF_TestDataUtility.createPricingtier();
        insert ptlist;
        
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
        }
        
        //inserting Products
        insert insertProd;
        System.assertEquals(5, insertProd.size());
        
        //updating Products
        Product__c prod = insertProd[0];
        List<Pricing__c> prcngList = [Select Id from Pricing__c where product__c =: prod.Id];
        DGF_TriggerUtility.priceEffectiveDate = Date.today();
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.EST_Tier__c = 'Tier 3';
        prod.CA_EST_Tier__c = 'Tier 2';
        update prod;
        
        test.startTest();
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.SD__c = false;
        prod.UHD__c = true;
        update prod;
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.US_Platform_Offering__c = 'iVOD;cVOD';
        prod.CA_Platform_Offering__c = 'iVOD;EST';
        update prod;
        Product__c pr = [Select Id, US_Platform_Offering__c, CA_Platform_Offering__c from Product__c where ID =: prod.Id];
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.US_Platform_Offering__c = null;
        prod.CA_Platform_Offering__c = 'iVOD';
        update prod;
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.SD__c = true;
        prod.HD__c = true;
        prod.X3D__c = true;
        prod.US_Platform_Offering__c = 'EST;iVOD';
        //  update prod;
        
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.HD__c = false;
        prod.X3D__c = false;
        prod.US_Platform_Offering__c = 'EST';
        // update prod;
        
        Test.stopTest();
    }
    
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-44-TV Product Type
    ***********************************/
    static testMethod void scenario2() {
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        list<Pricing_Tier__c> ptList = new list<Pricing_Tier__c>();
        ptList = DGF_TestDataUtility.createPricingtier();
        insert ptlist;
        test.startTest();
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, TVRecTypeId);
        
        //inserting Digital Release
        insert insertdgtlRels;
        System.assertEquals(1, insertdgtlRels.size());
        
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(1, insertdgtlRels);
        for (Product__c prod : insertProd) {
            prod.RecordTypeId=TVRecTypeIdPrd;
        }
        insert insertProd;
        test.stopTest();
    }
    /***********************************
    Method Name: scenario3
    Purpose: method to test code for DFOR-44-Film Product Type
    ***********************************/
    static testMethod void scenario3() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insertdgtlRels[0].US_EPO_Date__c = date.today() - 10;
        insertdgtlRels[0].CA_EPO_Date__c = date.today() - 10;
        
        //inserting Digital Release
        insert insertdgtlRels;
        System.assertEquals(1, insertdgtlRels.size());
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(5,insertdgtlRels);
        for(Product__c pr : insertProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
        }
        
        //inserting Products
        insert insertProd;
        System.assertEquals(5, insertProd.size());
        
        //updating Products
        Product__c prod = insertProd[0];
        test.startTest();
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger = true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.SD__c = true;
        prod.HD__c = true;
        prod.X3D__c = true;
        prod.US_Platform_Offering__c = 'EST;iVOD';
        update prod;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        prod.HD__c = false;
        prod.X3D__c = false;
        prod.US_Platform_Offering__c = 'EST';
        update prod;
        test.stopTest();
        
    }
    /***********************************
    Method Name: scenario4
    Purpose: method to test code for DFOR-153
    ***********************************/
    static testMethod void scenario4() {
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
        //create Account records
        Account acc= new Account (Name = 'iTunes', RecordTypeId = AccRecTypeId, Categorization__c ='Current' ,Scripted_Reality__c ='Reality' ,Network_Categorization__c ='Bravo' );
        insert acc;
        //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, TVRecTypeId);
        insertdgtlRels[0].Categorization__c = 'Current';
        insertdgtlRels[0].Scripted_Reality__c = 'Reality';
        // insertdgtlRels[0].US_Network_Categorization__c = 'Bravo'; DFOR-1578
        insertdgtlRels[0].US_Network_Categorization__c = 'Bravo';
        insertdgtlRels[0].TV_Studio__c = 'Bravo';
        //inserting Digital Release
        insert insertdgtlRels;
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(1, insertdgtlRels);
        test.startTest();
            for (Product__c prod : insertProd) {
                prod.RecordTypeId=TVRecTypeIdPrd;
                
            }
            insert insertProd;
            Integer prodAccCount = [Select count() from Product_Account__c where Product__c =:insertProd[0].id];
            System.assertEquals(1, prodAccCount);
       test.stopTest();
    }
    
     /***********************************
    Method Name: scenario5
    Purpose: method to test code for DFOR-263
    ***********************************/
    static testMethod void scenario5() {
         //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
         Id PreOrderRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
        
         //getting list of Digital release records to be created
        List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        //inserting Digital Release
        insert insertdgtlRels;
        
          //insert a preorder Product
        Product__c prod = new Product__c (Digital_Release__c = insertdgtlRels [0].id, Version_Availability__c = 'Theatrical', RecordTypeId = PreOrderRecTypeId );
        insert prod;
        Account acc = new Account (Name = 'Test' , Pre_Order_Best_Version__c = true);
        insert acc;
        Product_Account__c pa = new Product_Account__c (Product__c = prod.id , Account__c = acc.id);
        insert pa;
        
        prod.Version_Availability__c = 'Theatrical;Alternate';
        
        update prod;
        System.AssertEquals('Theatrical;Alternate',prod.Version_Availability__c);
    }
     
    //======================== for Webservice callouts ========================
    //
    //=========================================================================
    
     static testMethod void scenarioProductAddition() {
          CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        //getting record type IDs
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new SendJSONString_MockTest());
        
        //create TV Digital Release
        List<Digital_Release__c> insertDGTV = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        
        insert insertDGTV;
        String jsstring='{"entityList": [ { "type": "Version", "currentRequestType": {"masterRequestType": "Version", "requestType": "Version"}, "operation": "AD","data":{"versionType": "UNRATED", "versionNameDelimited": "Unrated", "language": "ENG"},"parentLinkId": "797e13cf-36d2-42b5-bbbb-2c7e69c22e4b,5ff2ac96-f39a-4d33-8bca-3b876753485a"},  {"type": "CrossRef", "linkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF", "crossRefNameDelimited": "All Media DGF short name","crossRefNumber": "DGF1234"}, "parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503" },  { "type": "CrossRef", "linkId": "797e13cf-36d2-42b5-bbbb-2c7e69c22e4b","currentRequestType": { "masterRequestType": "CrossRef", "requestType": "CrossRef"}, "operation": "AD",  "data": { "sourceDesc": "BDLF","crossRefNameDelimited": "All Media DGF Long Name","versionNameDelimited": "All Media"  }, "parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503"}, {"type": "Genre",  "linkId": "ec7b9a95-fab8-4683-9c5f-6cccda9cfdc3", "currentRequestType": { "masterRequestType":"Title", "requestType": "Genre"},"operation": "AD", "data": { "primaryGenre": "Y", "genreDesc": "ACT" },"parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503"    }, { "type": "Synopsis", "linkId": "45c912a3-a0db-405b-8b56-53a2e4d9b873", "currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis" },"operation": "AD", "data": {"languageDesc": "ENG",  "synopsisText": "synopsis for bundle title" },"parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b" }, { "type": "Synopsis",       "currentRequestType": {    "masterRequestType": "Title", "requestType": "Synopsis"   },  "operation": "AD", "data": {  "languageDesc": "ENG", "synopsisText": "second synopsis for bundles test"  },  "parentLinkId": "c64426c6-6fdb-42e5-9a9f-122d031fa67b,b2aa1cb5-aa0b-4023-9c59-0a8b0bc5935a"    },    {   "type": "Title",  "linkId": "e14596fa-bf21-4fda-843c-16a32b922503", "currentRequestType": {    "masterRequestType": "Title", "requestType": "Title"   }, "operation": "AD","data": {        "productType": "CMPL", "levelTagDesc": "TITLE", "releaseStatusDesc": "REL", "titleNameDelimited": "DGF CMPL INTEGRATION PID", "originalMarket": "EDU",    "productionYear": 2017    }  },  { "type": "Compilation",  "linkId": "6fe8748c-8c5f-45f1-aba7-a2887b0e3bf3",  "currentRequestType": {     "masterRequestType": "Title",  "requestType": "CMPL_Title"  },      "operation": "AD",  "data": {  "crossRefNumber": "TOC-09",  "sourceCode": "TVD"  },  "parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b"    },    {      "type": "Compilation",  "linkId": "1d062c83-59e9-4c6b-8c56-46358c1c9a29", "currentRequestType": { "masterRequestType": "Title",  "requestType": "CMPL_Title"  }, "operation": "AD", "data": {        "sourceCode": "TVD",  "crossRefNumber": "BG106"  },  "parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b"  }   ]}';
        SendJsonString.SendDigitalReleaseWithProducts(jsstring,insertDGTV[0].id);
        
        
        list<Title__c> titleList = DGF_TestDataUtility.createTitle(2);
        insert titleList;
        
        //creating version records
        list<TM_Version__c>tmvList = DGF_TestDataUtility.createTmVersion(2, titleList);
        insert tmvList;
        
        //populating tvd safe production id on version
        for (TM_Version__c tm : tmvList ) {
            tm.TVD_SAFE_Production_ID__c = '123';
        }  
        
        update tmvList;
        
        
        List<Product__c> prdList = DGF_TestDataUtility.createCustomProduct1(1, insertDGTV);        
        insert prdList;
        
        list<Product_version__c> prdversionList =DGF_TestDataUtility.createProductVersion1(2,prdList,tmvList);
        insert prdversionList;
        test.startTest();       
        
        insertDGTV[0].send_to_Gtm__c = true;
        update insertDGTV[0];
        
        insertDGTV[0].Bundle_SYSGEN__c = '78965412';
        
        update insertDGTV[0];
         
        prdList[0].Short_Name__c='test1';
        prdList[0].Bundle_Synopsis__c='Test1';
        
        update prdList[0];
        
         prdList[0].Bundle_Id__c='9874521';
          prdList[0].Short_Name__c='test123';
          update prdList[0]; 
        
         test.stopTest();
       
    }
    static testMethod void scenarioProductUpdation() {
          CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        //getting record type IDs
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new SendJSONString_MockTest());
        
        //create TV Digital Release
        List<Digital_Release__c> insertDGTV = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        
        insert insertDGTV;
        String jsstring='{"entityList": [ { "type": "Version", "currentRequestType": {"masterRequestType": "Version", "requestType": "Version"}, "operation": "AD","data":{"versionType": "UNRATED", "versionNameDelimited": "Unrated", "language": "ENG"},"parentLinkId": "797e13cf-36d2-42b5-bbbb-2c7e69c22e4b,5ff2ac96-f39a-4d33-8bca-3b876753485a"},  {"type": "CrossRef", "linkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF", "crossRefNameDelimited": "All Media DGF short name","crossRefNumber": "DGF1234"}, "parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503" },  { "type": "CrossRef", "linkId": "797e13cf-36d2-42b5-bbbb-2c7e69c22e4b","currentRequestType": { "masterRequestType": "CrossRef", "requestType": "CrossRef"}, "operation": "AD",  "data": { "sourceDesc": "BDLF","crossRefNameDelimited": "All Media DGF Long Name","versionNameDelimited": "All Media"  }, "parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503"}, {"type": "Genre",  "linkId": "ec7b9a95-fab8-4683-9c5f-6cccda9cfdc3", "currentRequestType": { "masterRequestType":"Title", "requestType": "Genre"},"operation": "AD", "data": { "primaryGenre": "Y", "genreDesc": "ACT" },"parentLinkId": "e14596fa-bf21-4fda-843c-16a32b922503"    }, { "type": "Synopsis", "linkId": "45c912a3-a0db-405b-8b56-53a2e4d9b873", "currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis" },"operation": "AD", "data": {"languageDesc": "ENG",  "synopsisText": "synopsis for bundle title" },"parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b" }, { "type": "Synopsis",       "currentRequestType": {    "masterRequestType": "Title", "requestType": "Synopsis"   },  "operation": "AD", "data": {  "languageDesc": "ENG", "synopsisText": "second synopsis for bundles test"  },  "parentLinkId": "c64426c6-6fdb-42e5-9a9f-122d031fa67b,b2aa1cb5-aa0b-4023-9c59-0a8b0bc5935a"    },    {   "type": "Title",  "linkId": "e14596fa-bf21-4fda-843c-16a32b922503", "currentRequestType": {    "masterRequestType": "Title", "requestType": "Title"   }, "operation": "AD","data": {        "productType": "CMPL", "levelTagDesc": "TITLE", "releaseStatusDesc": "REL", "titleNameDelimited": "DGF CMPL INTEGRATION PID", "originalMarket": "EDU",    "productionYear": 2017    }  },  { "type": "Compilation",  "linkId": "6fe8748c-8c5f-45f1-aba7-a2887b0e3bf3",  "currentRequestType": {     "masterRequestType": "Title",  "requestType": "CMPL_Title"  },      "operation": "AD",  "data": {  "crossRefNumber": "TOC-09",  "sourceCode": "TVD"  },  "parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b"    },    {      "type": "Compilation",  "linkId": "1d062c83-59e9-4c6b-8c56-46358c1c9a29", "currentRequestType": { "masterRequestType": "Title",  "requestType": "CMPL_Title"  }, "operation": "AD", "data": {        "sourceCode": "TVD",  "crossRefNumber": "BG106"  },  "parentLinkId": "5ff2ac96-f39a-4d33-8bca-3b876753485a,797e13cf-36d2-42b5-bbbb-2c7e69c22e4b"  }   ]}';
        SendJsonString.SendDigitalReleaseWithProducts(jsstring,insertDGTV[0].id);
        
        
        list<Title__c> titleList = DGF_TestDataUtility.createTitle(2);
        insert titleList;
        
        //creating version records
        list<TM_Version__c>tmvList = DGF_TestDataUtility.createTmVersion(2, titleList);
        insert tmvList;
        
        //populating tvd safe production id on version
        for (TM_Version__c tm : tmvList ) {
            tm.TVD_SAFE_Production_ID__c = '123';
        }  
        
        update tmvList;
        
        
        List<Product__c> prdList = DGF_TestDataUtility.createCustomProduct1(1, insertDGTV);        
        insert prdList;
        
        list<Product_version__c> prdversionList =DGF_TestDataUtility.createProductVersion1(2,prdList,tmvList);
        insert prdversionList;
        test.startTest();       
        
        insertDGTV[0].send_to_Gtm__c = true;
        update insertDGTV[0];
        
        insertDGTV[0].Bundle_SYSGEN__c = '78965412';
        
        update insertDGTV[0];
         
        prdList[0].Short_Name__c='test1';
        prdList[0].Bundle_Synopsis__c='Test1';
        prdList[0].JSON_Send__c=true;
        update prdList[0];
        
         prdList[0].Bundle_Id__c='9874521';
          prdList[0].Short_Name__c='test123';
          update prdList[0];     
        
         test.stopTest();
       
    }
}