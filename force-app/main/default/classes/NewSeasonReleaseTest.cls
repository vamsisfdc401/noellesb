@isTest(seeAllData=FALSE)
public class NewSeasonReleaseTest {
    
    /***********************************
Method Name: scenario1   FOR DFOR-1095
***********************************/
    static testMethod void scenario1(){
        
        Id BundlePrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();   
        Id SeriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
        Id TVId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        //getting list of digital release records to be created       
        List<Digital_Release__c> insertDG1 = DGF_TestDataUtility.createDigitalRelease(1,SeriesRecTypeId);
        List<Digital_Release__c> insertDG2 = DGF_TestDataUtility.createDigitalRelease(1,TVId);
        List<Digital_Release__c> insertDG3 = DGF_TestDataUtility.createDigitalRelease(1,TVId);
        List<Digital_Release__c> insertDG4 = DGF_TestDataUtility.createDigitalRelease(1,TVId);
        test.startTest();
        DGF_TriggerUtility.executePricingTrigger = false;
        //inserting digital release
        Title__c titl = new Title__c();
        titl.Name = 'Test ';
        titl.SGENNO__c = 'SGENNO';             
        titl.Network_of_Air_Date__c=date.today();
        titl.Active_Flag__c = TRUE;
        insert titl;           
        insert insertDG1; //series  record
        
        
        insertDG4[0].title__c = titl.Id;
        insertDG4[0].Season__c = '1';
        insertDG4[0].Create_From_Parent__c = true;
        insertDG4[0].Series_Name__c = insertDG1[0].Id; 
        insertDG4[0].Name = 'Test1';
        insert insertDG4; // season 1
        
        insertDG3[0].title__c = titl.Id;
        insertDG3[0].Season__c = '2';
        insertDG3[0].Create_From_Parent__c = true;
        insertDG3[0].Series_Name__c = insertDG1[0].Id;
         insertDG3[0].Name='Test2';
         insert insertDG3; // season 2
        
        insertDG2[0].title__c = titl.Id;
        insertDG2[0].Season__c = '3';
        insertDG2[0].Create_From_Parent__c = true;
        insertDG2[0].Series_Name__c = insertDG1[0].Id;
         insertDG2[0].Name='Test3';
         insert insertDG2; // season 3 
        
        
        //list<Title__c>titleList = DGF_TestDataUtility.createTitle(1);
        // insert titleList;   
        Id recTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Episode Pricing').getRecordTypeId();        
     
        Product__c prd = new Product__c();
        prd.RecordTypeId=recTypeId;
        prd.Name = 'Test ';
        prd.Digital_Release__c = insertDG2[0].Id;
        prd.HD__c = true;
        prd.SD__c = true;
        prd.UHD__c=true;
        prd.X3D__c=true;
        prd.US_Platform_Offering__c = 'EST';
        prd.CA_Platform_Offering__c = 'EST';
        prd.EST_Tier__c = 'Tier 2';
        prd.CA_EST_Tier__c = 'New Release Premium';
        prd.Short_Name__c='test';
        insert prd;
        
        Product__c prd1 = new Product__c();
        prd.RecordTypeId=recTypeId;
        prd1.Name = 'Test ';
        prd1.Digital_Release__c = insertDG2[0].Id;
        prd1.HD__c = true;
        prd1.SD__c = true;
        prd1.UHD__c=true;
        prd1.X3D__c=true;
        prd1.US_Platform_Offering__c = 'EST';
        prd1.CA_Platform_Offering__c = 'EST';
        prd1.EST_Tier__c = 'Tier 2';
        prd1.CA_EST_Tier__c = 'New Release Premium';
        prd1.Short_Name__c='Test';
        insert prd1;            
        DGF_TriggerUtility.productriggerExecuted = false;
        //create the products
        list<Product__c> prdList=DGF_TestDataUtility.createCustomProduct(1, insertDG2);
        for(Product__c prd11 : prdList){
            prd11.RecordTypeID = BundlePrdRecTypeId;
            prd11.CA_Platform_Offering__c = null;
            prd11.SD__c = false;
            prd11.UHD__c = false;
            prd11.X3D__c = false;
            prd11.Short_Name__c='test';
        }
        insert prdList;
        
        
        //querying Price List
        List<Pricing__c> prcList = [Select Id,Name,resolution__c,territory__c,platform__c,category__c,account__c,valid_from__c,valid_to__c from Pricing__c where Product__c =: prdList[0].Id];
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=true;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        
        Pricing__c prc1 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() + 25);
        if(prc1.Territory__c == 'CA')
            prc1.Valid_From__c=  insertDG4[0].CA_EST_Launch_Date__c;
        if(prc1.Territory__c == 'US')
            prc1.Valid_From__c=  insertDG4[0].US_EST_Launch_Date__c;
        //Enabling trigger
        DGF_TriggerUtility.executePricingTrigger=false;
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        Pricing__c prc2 = new Pricing__c(Name='US EST HD', Resolution__c='HD', Territory__c='US', Price_Type__c ='Original',Platform__c='EST', Category__c='Tier 2',product__c = prdList[0].Id,Valid_From__c = date.today() - 25,Valid_To__c = date.today() - 15);
        if(prc2.Territory__c == 'CA')
            prc2.Valid_From__c=  insertDG4[0].CA_EST_Launch_Date__c;
        if(prc2.Territory__c == 'US')
            prc2.Valid_From__c=  insertDG4[0].US_EST_Launch_Date__c;
        
        List<Pricing__c> lstPriceInsert = new List<Pricing__c>();
        lstPriceInsert.add(prc1);
        lstPriceInsert.add(prc2);
        insert lstPriceInsert;
        
        String recId = insertDG1[0].Id;        
        String strTitle = titl.id;
        String dgid= insertDG2[0].id;
        String prodId = prd.id; 
        NewSeasonRelease.getSeasonOptions(recId);
        NewSeasonRelease.saveRec(recId,'strName', strTitle, dgid);        
        ClonePreviousSeasonPricing.getSeasonOptions(recId);        
        ClonePreviousSeasonPricing.clonePricingRecords(prodId,dgid);
        test.stopTest();
    }
}