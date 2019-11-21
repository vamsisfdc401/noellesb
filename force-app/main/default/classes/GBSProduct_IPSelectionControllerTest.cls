/*****************************************************************************************
Class Name: GBSProduct_IPSelectionControllerTest
Purpose: Test class for GBSProduct_IPSelectionController class
Version : 1.0
Created Date : 06/06/2018
Created By : Harsha Polepalli
JIRA : GBS-55
******************************************************************************************/
@isTest
private class GBSProduct_IPSelectionControllerTest {
    
    @testSetup
    private static void testData() {
        //  Insert Account
        List<Account> accounts = GBSTestDataUtility.createAccount(1, Schema.sObjectType.Account.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId());
        insert accounts;
        
        //  Insert GBS Contract
        List<Contract__c> contracts = GBSTestDataUtility.createContract(accounts[0].Id, 1); 
        contracts[0].Contract_End_Date__c = system.today();
        insert contracts;
        
        //  Insert Product Rights Group
        List<Product_Rights_Group__c> PRGList = GBSTestDataUtility.createProductRightsGroup(contracts[0].Id, 1);
        PRGList[0].Rights_Group_End_Date__c = system.today()+ 2;
        PRGList[0].Contract__c = contracts[0].Id;
        insert PRGList;
        
        //  Insert Product Type
        List<Product_Type__c> productTypes = GBSTestDataUtility.createProductType(1);
        insert productTypes;
        
        //  Insert Product Rights
        List<Product_Right__c> productRights = GBSTestDataUtility.createProductRight(PRGList, productTypes); 
        productRights[0].Product_LMS_Status__c = 'Required';        
        insert productRights;
        
        //  Insert Intellectual Property
        List<Intellectual_Property__c> IPList = GBSTestDataUtility.createIP(1);
        insert IPList;
        
        //  Insert Intellectual Property Right
        List<Intellectual_Property_Right__c> IPRights = GBSTestDataUtility.createIPRight(PRGList, IPList);
        insert IPRights;
        
        //  Insert LMS
        List<LMS__c> LMSList = GBSTestDataUtility.createLMS(1);
        LMSList[0].Contract__c = contracts[0].Id;
        LMSList[0].Product_Rights_Group__c = PRGList[0].Id;
        LMSList[0].Licensee__c = accounts[0].Id;
        LMSList[0].LMS_IP__c = 'test';
        LMSList[0].LMS_Product_Detail__c = 'test';
        LMSList[0].LMS_Status__c = 'Submitted';
        insert LMSList;
        
        //Insert GBS_LMS_Product__c
        GBS_LMS_Product__c gbsLMSProduct = new GBS_LMS_Product__c();
        gbsLMSProduct.GBS_LMS__c = LMSList[0].Id;
        gbsLMSProduct.GBS_Product_Type__c = productTypes[0].Id;
        
        insert gbsLMSProduct;
               
    }
    
    private static testMethod void test() {
        List<LMS__c> LMSList = [Select Id From LMS__c];
        List<Product_Rights_Group__c> PRGList = [Select Id From Product_Rights_Group__c];
        List<Product_Right__c> productTypes = [Select Id, Product_Type__c From Product_Right__c];
        List<Intellectual_Property_Right__c> IPList = [Select Id, Intellectual_Property__c From Intellectual_Property_Right__c];
        List<GBS_LMS_Product__c> gbsLMSProductList = [Select Id, GBS_Product_Type__c, GBS_Product_Type__r.Name,
                                          GBS_Product_Type__r.Product_Hierarchy__c,GBS_LMS__c
                                          From GBS_LMS_Product__c];

        
        test.startTest();
        GBSProduct_IPSelectionController.loadLMSDetails(LMSList[0].Id);
       // GBSProduct_IPSelectionController.loadRelatedIPRights(new List<Intellectual_Property_Right__c>(), PRGList[0].Id, LMSList[0].Id);
        //GBSProduct_IPSelectionController.loadRelatedProductRights(new List<Product_Right__c>(), PRGList[0].Id);
        GBSProduct_IPSelectionController.loadSelectedIPRights(PRGList[0].Id, LMSList[0].Id);
        //GBSProduct_IPSelectionController.loadSelectedProductRights(PRGList[0].Id, LMSList[0].Id);
        //GBSProduct_IPSelectionController.getIPRights(new List<Intellectual_Property_Right__c>(), '', PRGList[0].Id);
        //GBSProduct_IPSelectionController.getProductRights(new List<Product_Right__c>(), '',PRGList[0].Id);
        //GBSProduct_IPSelectionController.save(productTypes, IPList, LMSList[0].Id, PRGList[0].Id);
        GBSProduct_IPSelectionController.setLMSStatus(LMSList[0].Id);
        //GBSProduct_IPSelectionController.setLMSFlagonPRG(PRGList[0].Id, productTypes, IPList);
        
       // GBSProduct_IPSelectionController.loadRelatedIPRights(GBSProduct_IPSelectionController.loadSelectedIPRights(PRGList[0].Id, LMSList[0].Id), PRGList[0].Id, LMSList[0].Id);
        //GBSProduct_IPSelectionController.loadRelatedProductRights(GBSProduct_IPSelectionController.loadSelectedProductRights(PRGList[0].Id, LMSList[0].Id), PRGList[0].Id);
        GBSProduct_IPSelectionController.loadSelectedIPRights(PRGList[0].Id, LMSList[0].Id);
        //GBSProduct_IPSelectionController.loadSelectedProductRights(PRGList[0].Id, LMSList[0].Id);
        
        test.stopTest();
    }
    
    private static testMethod void unitTest() {
        
        List<LMS__c> LMSList = [Select Id,Contract__c From LMS__c];
        List<Product_Rights_Group__c> PRGList = [Select Id From Product_Rights_Group__c];
        List<Product_Right__c> productTypes = [Select Id, Product_Type__c,Name From Product_Right__c];
        List<Intellectual_Property_Right__c> IPList = [Select Id, Intellectual_Property__c From 
                                                       Intellectual_Property_Right__c];
        List<Intellectual_Property__c> IPDataList       = [Select Id,Name  From 
                                                       Intellectual_Property__c];  
        
        List<Contract__c> contracts     = [Select Id,Name  From Contract__c]; 
        List<GBS_LMS_Product__c> gbsLMSProductList = [Select Id, GBS_Product_Type__c, GBS_Product_Type__r.Name,
                                          GBS_Product_Type__r.Product_Hierarchy__c,GBS_LMS__c
                                          From GBS_LMS_Product__c];
        
        List<Product_Type__c> productTypesList = [Select Id,Name,Product_Hierarchy__c  From Product_Type__c]; 
        
        test.startTest();
        List<GBSProduct_IPSelectionController.ProductWrapper> productWrapperObjList = new
                    List<GBSProduct_IPSelectionController.ProductWrapper>();
        
        List<GBSProduct_IPSelectionController.IPWrapper> ipWrapperObjList = 
                    new List<GBSProduct_IPSelectionController.IPWrapper>();
        
        GBSProduct_IPSelectionController.ProductWrapper productWrapperObj = 
                    new GBSProduct_IPSelectionController.ProductWrapper(); 
        
        productWrapperObj.isSelected = false ;
        productWrapperObj.prodHierarchy = 'Test';
        productWrapperObj.prodId = productTypes.get(0).Id;
        productWrapperObj.prodName = productTypes.get(0).Name ;
        
        productWrapperObjList.add(productWrapperObj);
        
        GBSProduct_IPSelectionController.IPWrapper ipWrapperObj = 
                    new GBSProduct_IPSelectionController.IPWrapper();
        
        ipWrapperObj.IPId   =  IPDataList.get(0).Id ;
        ipWrapperObj.IPName =  IPDataList.get(0).Name ;
        ipWrapperObj.isSelected = false ;
        
        ipWrapperObjList.add(ipWrapperObj);
        GBSProduct_IPSelectionController.saveUpdated(JSON.serialize(productWrapperObjList),
                                                     JSON.serialize(ipWrapperObjList),
                                                     String.valueOf(LMSList.get(0).Id),
                                                     null,
                                                     String.valueOf(contracts.get(0).Id)
                                                    );
        
        GBSProduct_IPSelectionController.loadRelatedProductRights(JSON.serialize(productWrapperObjList),
                                                                 String.valueOf(contracts.get(0).Id));
        
        GBSProduct_IPSelectionController.loadRelatedIPRights(JSON.serialize(productWrapperObjList),
                                                             null,
                                                             LMSList.get(0));
        
        
        
        GBSProduct_IPSelectionController.loadRelatedIPRightsUpdated(JSON.serialize(productWrapperObjList),
                                                                   null,
                                                                   LMSList.get(0),
                                                                   JSON.serialize(ipWrapperObjList));
        
        //System.debug('================= ++++++++++= '+gbsLMSProductList);
        //GBSProduct_IPSelectionController.loadSelectedProductRights(null,new LMS__C(Id=gbsLMSProductList.get(0).GBS_LMS__c));
        
        GBSProduct_IPSelectionController.getProductRights(JSON.serialize(productWrapperObjList),
                                                         't',
                                                         null,
                                                         String.valueOf(contracts.get(0).Id));
        
        GBSProduct_IPSelectionController.getIPRights( JSON.serialize(ipWrapperObjList),
                                                    't',
                                                    null,
                                                    String.valueOf(contracts.get(0).Id), 
                                                    JSON.serialize(productWrapperObjList));
        GBSProduct_IPSelectionController.createConflictTaskAndUpdateLMS(String.valueOf(IPDataList.get(0).Id),
                                                                        String.valueOf(LMSList.get(0).Id)
                                                                       );
        
         GBSProduct_IPSelectionController.loadSelectedIPRights(null,
                                                               LMSList.get(0).Id
                                                               );        
       
        test.stopTest();
 
        
    }
    
    private static testMethod void unitTest1() {
        List<LMS__c> LMSList = [Select Id,Contract__c From LMS__c];
        List<GBS_LMS_Product__c> gbsLMSProductList = [Select Id, GBS_Product_Type__c, GBS_Product_Type__r.Name,
                                          GBS_Product_Type__r.Product_Hierarchy__c,GBS_LMS__c
                                          From GBS_LMS_Product__c];
        
        List<Product_Type__c> productTypesList = [Select Id,Name,Product_Hierarchy__c  From Product_Type__c]; 
        
        GBSProduct_IPSelectionController.loadSelectedProductRights(null,new LMS__C(Id=gbsLMSProductList.get(0).GBS_LMS__c));
        
        
        GBSProduct_IPSelectionController.ProductWrapper  obj1 = new GBSProduct_IPSelectionController.ProductWrapper();
        obj1.prodName = '';
        obj1.prodId     = '1111';
        obj1.prodHierarchy  = '1111';
        obj1.isSelected  = true ;
        
        GBSProduct_IPSelectionController.IPWrapper obj2 = new GBSProduct_IPSelectionController.IPWrapper();
        obj2 .IPName= '';
        obj2 .IPId = '1111';
        obj2 .isSelected =  true ;
        
    }
    
    private static testMethod void unitTest2() {
    
         List<LMS__c> LMSList = [Select Id,Contract__c From LMS__c];
        List<Product_Rights_Group__c> PRGList = [Select Id From Product_Rights_Group__c];
        List<Product_Right__c> productTypes = [Select Id, Product_Type__c,Name From Product_Right__c];
        List<Intellectual_Property_Right__c> IPList = [Select Id, Intellectual_Property__c From 
                                                       Intellectual_Property_Right__c];
        List<Intellectual_Property__c> IPDataList       = [Select Id,Name  From 
                                                       Intellectual_Property__c];  
        
        List<Contract__c> contracts     = [Select Id,Name  From Contract__c]; 
        List<GBS_LMS_Product__c> gbsLMSProductList = [Select Id, GBS_Product_Type__c, GBS_Product_Type__r.Name,
                                          GBS_Product_Type__r.Product_Hierarchy__c,GBS_LMS__c
                                          From GBS_LMS_Product__c];
        
        List<Product_Type__c> productTypesList = [Select Id,Name,Product_Hierarchy__c  From Product_Type__c]; 
        
        test.startTest();
        List<GBSProduct_IPSelectionController.ProductWrapper> productWrapperObjList = new
                    List<GBSProduct_IPSelectionController.ProductWrapper>();
        
        List<GBSProduct_IPSelectionController.IPWrapper> ipWrapperObjList = 
                    new List<GBSProduct_IPSelectionController.IPWrapper>();
        
        GBSProduct_IPSelectionController.ProductWrapper productWrapperObj = 
                    new GBSProduct_IPSelectionController.ProductWrapper(); 
        
        productWrapperObj.isSelected = false ;
        productWrapperObj.prodHierarchy = 'Test';
        productWrapperObj.prodId = productTypes.get(0).Product_Type__c ;
        productWrapperObj.prodName = productTypes.get(0).Name ;
        
        productWrapperObjList.add(productWrapperObj);
        
        GBSProduct_IPSelectionController.IPWrapper ipWrapperObj = 
                    new GBSProduct_IPSelectionController.IPWrapper();
        
        ipWrapperObj.IPId   =  IPDataList.get(0).Id ;
        ipWrapperObj.IPName =  IPDataList.get(0).Name ;
        ipWrapperObj.isSelected = false ;
        
        ipWrapperObjList.add(ipWrapperObj);
        GBSProduct_IPSelectionController.updateConflictCheckOnPRAndIpMismatch(productWrapperObjList,
                                                     ipWrapperObjList,
                                                     String.valueOf(LMSList.get(0).Id),
                                                     String.valueOf(contracts.get(0).Id)
                                                    );
    
    }

}