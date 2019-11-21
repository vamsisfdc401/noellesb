/***********************************************************************************
Class Name: DGF_DigitalReleaseTriggerHandlerTest
Purpose: Test class for apex class DGF_DigitalReleaseTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_DigitalReleaseTriggerHandlerTest   {
    
    /***********************************
Method Name: scenario1
Purpose: method to test code for DFOR-119
***********************************/
    static testMethod void scenario1() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10,FilmRecTypeId);
        
        test.startTest();
        //inserting digital release
        insert insertDG;
        
        //getting EPO records created
        List<EPO_Bonus__c> lstEPORecords = [Select id from EPO_Bonus__c];
        
        //asserting the count of records
        System.AssertEquals(0,lstEPORecords.size());
        
        //updating digital release records to remove US EPO Date
        for(Digital_Release__c dg : insertDG){
            insertDG[0].US_EPO_Date__c = null;
        }
        
        //updating list
        update insertDG;
        
        //getting EPO records after deletion
        List<EPO_Bonus__c> lstEPORecords1 = [Select id from EPO_Bonus__c];    
        System.AssertEquals(TRUE, lstEPORecords1.isEmpty());
        
        test.stopTest();    
    }
    
    /***********************************
Method Name: scenario2
Purpose: method to test code for DFOR-35 for Film Release by updating the release dates
***********************************/
    static testMethod void scenario2() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        Id comRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();    
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        
        test.startTest();
        //inserting digital release
        insert insertDG;
        
        EPO_Bonus__c epo = new EPO_Bonus__c();
        epo.Name = 'Test ';
        epo.Digital_Release__c= insertDG[0].Id;
        //epo.RecordTypeId=FilmRecTypeId;
        epo.US_End_Date__c=date.today();
        epo.US_Start_Date__c=date.today();
        epo.CA_End_Date__c=date.today();
        epo.CA_Start_Date__c=date.today();
        Insert epo;
        
        Product__c prd = new Product__c();
        prd.Name = 'Test ';
        prd.Digital_Release__c = insertDG[0].Id;
        prd.HD__c = true;
        prd.SD__c = true;
        prd.UHD__c=true;
        prd.X3D__c=true;
        prd.US_Platform_Offering__c = 'EST';
        prd.CA_Platform_Offering__c = 'EST';
        prd.EST_Tier__c = 'Tier 2';
        prd.CA_EST_Tier__c = 'New Release Premium';
        insert prd;
        
        List<Account> insertAcc = DGF_TestDataUtility.createAccount(1);
        insert insertAcc;
        
        product_account__c pa = new product_account__c();
        pa.Account__c = insertAcc[0].Id;
        pa.Product__c = prd.Id;
        insert pa;
        
        List<Digital_Date__c> lstDateRecords = [Select id from Digital_Date__c];
        System.assertNotEquals(10, lstDateRecords.size());
        
        //updating the dates
        insertDG[0].US_EPO_Date__c = Date.Today()+1;
        insertDG[0].CA_EPO_Date__c = Date.Today()+1;
        insertDG[0].US_Theatrical_Release_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Street_Date__c = Date.Today()+1;
        insertDG[0].US_EST_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].US_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Solicitation_Date__c  = Date.Today()+1;
        //insertDG[0].US_Digital_Soicitation_Date__c = Date.Today()+1;    
        insertDG[0].US_Redbox_Rental_Date__c = Date.Today()+1;   
        insertDG[0].US_Linear_Premiere_Date__c = Date.Today()+1;  
        insertDG[0].CA_Theatrical_Release_Date__c = Date.Today()+1;  
        insertDG[0].CA_Physical_Street_Date__c = Date.Today()+1;  
        insertDG[0].CA_EST_Date__c = Date.Today()+1;  
        insertDG[0].CA_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_VOD_End_Date__c = Date.Today()+1; 
        insertDG[0].CA_Hotel_Start_Date__c = Date.Today()+1;  
        insertDG[0].CA_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].CA_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Physical_Solicitation_Date__c = Date.Today()+1;   
        //insertDG[0].CA_Digital_Soicitation_Date__c = Date.Today()+1; 
        insertDG[0].CA_Redbox_Rental_Date__c = Date.Today()+1;  
        insertDG[0].CA_Linear_Premiere_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;  
        insertDG[0].US_Day_and_Date_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].US_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;    
        insertDG[0].US_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].CA_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].Deactivation_Date__c = Date.Today()+1;
        insertDG[0].US_Disc_to_Digital_Date__c = Date.Today()+1;
        insertDG[0].CA_Disc_to_Digital_Date__c = Date.Today()+1;
        
        insertDG[0].recordTypeID = comRecTypeId;
        database.update(insertDG[0]);
        
        insertDG[0].recordTypeID = FilmRecTypeId;
        database.update(insertDG[0]);
        database.delete( insertDG[0]);
        
        List<Digital_Date__c> lstDateRecords1 = [Select id from Digital_Date__c];
        System.assertEquals(TRUE, lstDateRecords1.size() > 0);
        test.stopTest();
    }
    
    static testMethod void scenario22() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        Id comRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();    
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,comRecTypeId);
        Digital_Release__c dg = new Digital_Release__c();
        dg.Name = 'Test ';
        dg.US_EPO_Date__c = Date.Today() + 10;
        dg.CA_EPO_Date__c = Date.Today();
        dg.recordTypeID = FilmRecTypeId;
        dg.US_Theatrical_Release_Date__c = Date.Today();
        dg.US_Physical_Street_Date__c = Date.Today();
        dg.US_EST_Date__c = Date.Today() + 1;
        dg.US_VOD_Start_Date__c = Date.Today() + 10;
        dg.US_VOD_End_Date__c = Date.Today() + 20;
        dg.US_Hotel_Start_Date__c = Date.Today();
        dg.US_Hotel_End_Date__c  = Date.Today();
        dg.US_SVOD_Start_Date__c     = Date.Today();
        dg.US_Physical_Solicitation_Date__c     = Date.Today();
        //dg.US_Digital_Soicitation_Date__c = Date.Today();    
        dg.US_Redbox_Rental_Date__c  = Date.Today();   
        dg.US_Linear_Premiere_Date__c   = Date.Today();  
        dg.CA_Theatrical_Release_Date__c   = Date.Today();  
        dg.CA_Physical_Street_Date__c   = Date.Today();  
        dg.CA_EST_Date__c   = Date.Today();  
        dg.CA_VOD_Start_Date__c  = Date.Today() + 10;   
        dg.CA_VOD_End_Date__c    = Date.Today() + 20; 
        dg.CA_Hotel_Start_Date__c   = Date.Today();  
        dg.CA_Hotel_End_Date__c     = Date.Today();
        dg.CA_SVOD_Start_Date__c     = Date.Today();
        dg.CA_Physical_Solicitation_Date__c  = Date.Today();   
        //dg.CA_Digital_Soicitation_Date__c    = Date.Today(); 
        dg.CA_Redbox_Rental_Date__c   = Date.Today();  
        dg.CA_Linear_Premiere_Date__c = Date.Today();
        dg.US_Pre_Theatrical_VOD_Start_Date__c = Date.Today();
        dg.US_Pre_Theatrical_VOD_End_Date__c = Date.Today();
        dg.US_Day_and_Date_VOD_Start_Date__c   = Date.Today();  
        dg.US_Day_and_Date_VOD_End_Date__c   = Date.Today();  
        dg.US_New_Release_Standard_VOD_Start_Date__c = Date.Today();    
        dg.US_New_Release_Standard_VOD_End_Date__c   = Date.Today();  
        //dg.US_Catalog_VOD_End_Date__c     = Date.Today();
        // dg.US_Catalog_VOD_Start_Date__c     = Date.Today();
        dg.CA_Pre_Theatrical_VOD_Start_Date__c     = Date.Today();
        dg.CA_Pre_Theatrical_VOD_End_Date__c     = Date.Today();
        dg.CA_Day_and_Date_VOD_Start_Date__c = Date.Today();
        dg.CA_Day_and_Date_VOD_End_Date__c     = Date.Today();
        dg.CA_New_Release_Standard_VOD_Start_Date__c  = Date.Today();   
        dg.CA_New_Release_Standard_VOD_End_Date__c   = Date.Today();  
        //dg.CA_Catalog_VOD_Start_Date__c     = Date.Today();
        // dg.CA_Catalog_VOD_End_Date__c     = Date.Today();
        dg.US_EST_Launch_Date__c     = Date.Today();
        dg.US_Initial_EST_Launch_Date__c     = Date.Today();
        dg.US_SVOD_Start_Date__c      = Date.Today();
        dg.CA_EST_Launch_Date__c      = Date.Today();
        dg.CA_Initial_EST_Launch_Date__c    = Date.Today();  
        dg.CA_SVOD_Start_Date__c      = Date.Today();
        dg.US_Bundle_Avail_Date__c      = Date.Today();
        dg.New_to_HD_CA_EST_Release_Date__c=date.today();
        dg.New_to_HD_CA_VOD_Release_Date__c=date.today();
        dg.New_to_HD_US_EST_Release_Date__c=date.today();
        dg.New_to_HD_US_VOD_Release_Date__c=date.today();
        dg.New_to_UHD_CA_EST_Release_Date__c=date.today();
        dg.New_to_UHD_CA_VOD_Release_Date__c=date.today();
        dg.New_to_UHD_US_EST_Release_Date__c=date.today();
        dg.New_to_UHD_US_VOD_Release_Date__c=date.today();
        dg.Free_First_Episode_End_Date__c=date.today();
        dg.Free_First_Episode_Start_Date__c=date.today();
        dg.Deactivation_Date__c=date.today();
        dg.US_Bundle_Pre_Purchase_Date__c=date.today();
        dg.US_Disc_to_Digital_Date__c=date.today();
        dg.CA_Disc_to_Digital_Date__c=date.today();
        dg.US_Product_Type__c='Theatrical';
        dg.US_Launch_VOD_Categorization__c = 'Catalog';
        dg.CA_Launch_VOD_Categorization__c = 'Current';
        insertDG.add(dg);            
        
        test.startTest();
        //inserting digital release
        insert insertDG;
        
        List<Digital_Date__c> lstDateRecords = [Select id from Digital_Date__c];
        System.assertNotEquals(10, lstDateRecords.size());
        
        //updating the dates
        insertDG[0].US_EPO_Date__c = Date.Today()+1;
        insertDG[0].CA_EPO_Date__c = Date.Today()+1;
        insertDG[0].US_Theatrical_Release_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Street_Date__c = Date.Today()+1;
        insertDG[0].US_EST_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].US_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Solicitation_Date__c  = Date.Today()+1;
        //insertDG[0].US_Digital_Soicitation_Date__c = Date.Today()+1;    
        insertDG[0].US_Redbox_Rental_Date__c = Date.Today()+1;   
        insertDG[0].US_Linear_Premiere_Date__c = Date.Today()+1;  
        insertDG[0].CA_Theatrical_Release_Date__c = Date.Today()+1;  
        insertDG[0].CA_Physical_Street_Date__c = Date.Today()+1;  
        insertDG[0].CA_EST_Date__c = Date.Today()+1;  
        insertDG[0].CA_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_VOD_End_Date__c = Date.Today()+1; 
        insertDG[0].CA_Hotel_Start_Date__c = Date.Today()+1;  
        insertDG[0].CA_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].CA_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Physical_Solicitation_Date__c = Date.Today()+1;   
        //insertDG[0].CA_Digital_Soicitation_Date__c = Date.Today()+1; 
        insertDG[0].CA_Redbox_Rental_Date__c = Date.Today()+1;  
        insertDG[0].CA_Linear_Premiere_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;  
        insertDG[0].US_Day_and_Date_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].US_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;    
        insertDG[0].US_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].CA_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].Deactivation_Date__c = Date.Today()+1;
        insertDG[0].US_Disc_to_Digital_Date__c = Date.Today()+1;
        insertDG[0].CA_Disc_to_Digital_Date__c = Date.Today()+1;
        //insertDG[0].hotel_rights__c = true;
        insertDG[0].US_Launch_VOD_Categorization__c = 'Catalog';
        insertDG[0].recordTypeID = FilmRecTypeId;
        database.update(insertDG[0]);
        
        insertDG[0].recordTypeID = FilmRecTypeId;
        database.update(insertDG[0]);
        database.delete( insertDG[0]);
        
        List<Digital_Date__c> lstDateRecords1 = [Select id from Digital_Date__c];
        System.assertEquals(TRUE, lstDateRecords1.size() > 0);
        test.stopTest();
    }
    
    static testMethod void scenario23() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        Id comRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();    
        Id SeriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
        Id TVId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,comRecTypeId);
        List<Digital_Release__c> insertDG1 = DGF_TestDataUtility.createDigitalRelease(1,SeriesRecTypeId);
        List<Digital_Release__c> insertDG2 = DGF_TestDataUtility.createDigitalRelease(1,TVId);
        List<Digital_Release__c> insertDG3 = DGF_TestDataUtility.createDigitalRelease(1,TVId);
        test.startTest();
        //inserting digital release
        Title__c titl = new Title__c();
        titl.Name = 'Test ';
        titl.SGENNO__c = 'SGENNO';
        //titl.Parent_SGENNO__c = 'SGENNO' + i;
        titl.Network_of_Air_Date__c=date.today();
        titl.Active_Flag__c = TRUE;
        insert titl;
        insert insertDG;
        insert insertDG1;
        
        insertDG2[0].title__c = titl.Id;
        insertDG2[0].Season__c = '1';
        insertDG2[0].Create_From_Parent__c = true;
        insertDG2[0].Series_Name__c = insertDG1[0].Id;
        insert insertDG2;
        
        insertDG3[0].title__c = titl.Id;
        insertDG3[0].Season__c = '1';
        //insert insertDG3;
        
        list<Title__c>titleList = DGF_TestDataUtility.createTitle(1);
        insert titleList;
        
        List<Digital_Date__c> lstDateRecords = [Select id from Digital_Date__c];
        System.assertNotEquals(10, lstDateRecords.size());
        
        EPO_Bonus__c epo = new EPO_Bonus__c();
        epo.Name = 'Test ';
        epo.Digital_Release__c= insertDG[0].Id;
        //epo.RecordTypeId=FilmRecTypeId;
        epo.US_End_Date__c=date.today();
        epo.US_Start_Date__c=date.today();
        epo.CA_End_Date__c=date.today();
        epo.CA_Start_Date__c=date.today();
        Insert epo;
        
        Product__c prd = new Product__c();
        prd.Name = 'Test ';
        prd.Digital_Release__c = insertDG[0].Id;
        prd.HD__c = true;
        prd.SD__c = true;
        prd.UHD__c=true;
        prd.X3D__c=true;
        prd.US_Platform_Offering__c = 'EST';
        prd.CA_Platform_Offering__c = 'EST';
        prd.EST_Tier__c = 'Tier 2';
        prd.CA_EST_Tier__c = 'New Release Premium';
        insert prd;
        
        List<Account> insertAcc = DGF_TestDataUtility.createAccount(1);
        insert insertAcc;
        
        product_account__c pa = new product_account__c();
        pa.Account__c = insertAcc[0].Id;
        pa.Product__c = prd.Id;
        insert pa;
        
        //updating the dates
        insertDG[0].US_EPO_Date__c = Date.Today()+1;
        insertDG[0].CA_EPO_Date__c = Date.Today()+1;
        insertDG[0].US_Theatrical_Release_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Street_Date__c = Date.Today()+1;
        insertDG[0].US_EST_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].US_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Physical_Solicitation_Date__c  = Date.Today()+1;
        //insertDG[0].US_Digital_Soicitation_Date__c = Date.Today()+1;    
        insertDG[0].US_Redbox_Rental_Date__c = Date.Today()+1;   
        insertDG[0].US_Linear_Premiere_Date__c = Date.Today()+1;  
        insertDG[0].CA_Theatrical_Release_Date__c = Date.Today()+1;  
        insertDG[0].CA_Physical_Street_Date__c = Date.Today()+1;  
        insertDG[0].CA_EST_Date__c = Date.Today()+1;  
        insertDG[0].CA_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_VOD_End_Date__c = Date.Today()+1; 
        insertDG[0].CA_Hotel_Start_Date__c = Date.Today()+1;  
        insertDG[0].CA_Hotel_End_Date__c = Date.Today()+1;
        insertDG[0].CA_SVOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Physical_Solicitation_Date__c = Date.Today()+1;   
        //insertDG[0].CA_Digital_Soicitation_Date__c = Date.Today()+1; 
        insertDG[0].CA_Redbox_Rental_Date__c = Date.Today()+1;  
        insertDG[0].CA_Linear_Premiere_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].US_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].US_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;  
        insertDG[0].US_Day_and_Date_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].US_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;    
        insertDG[0].US_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;  
        insertDG[0].CA_Pre_Theatrical_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Pre_Theatrical_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_Start_Date__c = Date.Today()+1;
        insertDG[0].CA_Day_and_Date_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].CA_New_Release_Standard_VOD_Start_Date__c = Date.Today()+1;   
        insertDG[0].CA_New_Release_Standard_VOD_End_Date__c = Date.Today()+1;
        insertDG[0].Deactivation_Date__c = Date.Today()+1;
        insertDG[0].US_Disc_to_Digital_Date__c = Date.Today()+1;
        insertDG[0].CA_Disc_to_Digital_Date__c = Date.Today()+1;
        insertDG[0].Scripted_Reality__c = 'Scripted';
        
        insertDG[0].title__c = titleList[0].Id;
        insertDG[0].recordTypeID = SeriesRecTypeId;
        database.update(insertDG[0]);
        
        insertDG[0].recordTypeID = FilmRecTypeId;
        database.update(insertDG[0]);
        database.delete( insertDG[0]);
        
        List<Digital_Date__c> lstDateRecords1 = [Select id from Digital_Date__c];
        System.assertEquals(TRUE, lstDateRecords1.size() > 0);
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario3
Purpose: method to test code for DFOR-35 for Film Release by clearing out the release dates
***********************************/
    static testMethod void scenario3() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        
        test.startTest();
        //inserting digital release
        insert insertDG;
        insertDG[0].US_EPO_Date__c = NULL;
        insertDG[0].CA_EPO_Date__c = NULL;
        insertDG[0].US_Theatrical_Release_Date__c = NULL;
        insertDG[0].US_Physical_Street_Date__c = NULL;
        insertDG[0].US_EST_Date__c = NULL;
        insertDG[0].US_VOD_Start_Date__c = NULL;
        insertDG[0].US_VOD_End_Date__c = NULL;
        insertDG[0].US_Hotel_Start_Date__c = NULL;
        insertDG[0].US_Hotel_End_Date__c  = NULL;
        insertDG[0].US_SVOD_Start_Date__c = NULL;
        insertDG[0].US_Physical_Solicitation_Date__c = NULL;
        //insertDG[0].US_Digital_Soicitation_Date__c = NULL;    
        insertDG[0].US_Redbox_Rental_Date__c = NULL;   
        insertDG[0].US_Linear_Premiere_Date__c = NULL;  
        insertDG[0].CA_Theatrical_Release_Date__c = NULL;  
        insertDG[0].CA_Physical_Street_Date__c = NULL;  
        insertDG[0].CA_EST_Date__c = NULL;  
        insertDG[0].CA_VOD_Start_Date__c = NULL;   
        insertDG[0].CA_VOD_End_Date__c = NULL; 
        insertDG[0].CA_Hotel_Start_Date__c = NULL;  
        insertDG[0].CA_Hotel_End_Date__c = NULL;
        insertDG[0].CA_SVOD_Start_Date__c = NULL;
        insertDG[0].CA_Physical_Solicitation_Date__c = NULL;   
        //insertDG[0].CA_Digital_Soicitation_Date__c = NULL; 
        insertDG[0].CA_Redbox_Rental_Date__c = NULL;  
        insertDG[0].CA_Linear_Premiere_Date__c = NULL;
        insertDG[0].US_Pre_Theatrical_VOD_Start_Date__c = NULL;
        insertDG[0].US_Pre_Theatrical_VOD_End_Date__c = NULL;
        insertDG[0].US_Day_and_Date_VOD_Start_Date__c = NULL;  
        insertDG[0].US_Day_and_Date_VOD_End_Date__c = NULL;  
        insertDG[0].US_New_Release_Standard_VOD_Start_Date__c = NULL;    
        insertDG[0].US_New_Release_Standard_VOD_End_Date__c = NULL;  
        insertDG[0].CA_Pre_Theatrical_VOD_Start_Date__c = NULL;
        insertDG[0].CA_Pre_Theatrical_VOD_End_Date__c = NULL;
        insertDG[0].CA_Day_and_Date_VOD_Start_Date__c = NULL;
        insertDG[0].CA_Day_and_Date_VOD_End_Date__c = NULL;
        insertDG[0].CA_New_Release_Standard_VOD_Start_Date__c = NULL;   
        insertDG[0].CA_New_Release_Standard_VOD_End_Date__c = NULL; 
        insertDG[0].Deactivation_Date__c = NULL;
        insertDG[0].US_Disc_to_Digital_Date__c = NULL;
        insertDG[0].CA_Disc_to_Digital_Date__c = NULL;
        database.update(insertDG[0]);
        
        List<Digital_Date__c> lstDateRecords = [Select id from Digital_Date__c];
        System.assertNotEquals(TRUE, lstDateRecords.size() == 0);
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario4
Purpose: method to test code for DFOR-35 for TV Release
***********************************/
    static testMethod void scenario4() {
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();   
        Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id FreeEpiRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        list<Title__c>titleList = DGF_TestDataUtility.createTitle(1);
        insert titleList;
        titleList[0].initial_release_air_year__c = '2000';
        update titleList[0];
        
        test.startTest();
        
        insert insertDG;
        List<Digital_Date__c> lstDateRecords = [Select id, Release_Date__c from Digital_Date__c where Digital_Release__c =: insertDG[0].id];
        System.assertEquals(date.today(),lstDateRecords[0].Release_Date__c);
        
        //updating dates for TV Release
        insertDG[0].US_EST_Launch_Date__c = date.today()+1;
        insertDG[0].US_Initial_EST_Launch_Date__c = date.today()+1;
        insertDG[0].US_SVOD_Start_Date__c = date.today()+1;
        insertDG[0].CA_EST_Launch_Date__c = date.today()+1;
        insertDG[0].CA_Initial_EST_Launch_Date__c = date.today()+1;
        insertDG[0].CA_SVOD_Start_Date__c = date.today()+1;
        insertDG[0].Free_First_Episode_End_Date__c = date.today()+1;
        insertDG[0].Free_First_Episode_Start_Date__c = date.today()+1;
        insertDG[0].Deactivation_Date__c = date.today()+1;
        insertDG[0].US_Network_of_Air__c = 'ABC';          
        database.update(insertDG[0]);
        
        insertDG[0].US_EST_Launch_Date__c = NULL;
        insertDG[0].US_Initial_EST_Launch_Date__c = NULL;
        insertDG[0].US_SVOD_Start_Date__c = NULL;
        insertDG[0].CA_EST_Launch_Date__c = NULL;
        insertDG[0].CA_Initial_EST_Launch_Date__c = NULL;
        insertDG[0].CA_SVOD_Start_Date__c = NULL;
        insertDG[0].Free_First_Episode_End_Date__c = NULL;
        insertDG[0].Free_First_Episode_Start_Date__c = NULL;
        insertDG[0].Deactivation_Date__c = NULL;
        database.update(insertDG[0]);        
        test.stopTest();
    }
    
    
    /***********************************
Method Name: scenario5
Purpose: method to test code for DFOR-35 for Bundle Release
***********************************/
    static testMethod void scenario5() {
        //getting record type for digital release
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();    
        Digital_Release__c bundleRelease = new Digital_Release__c(Name= 'Bundle', RecordTypeId = BundleRecTypeId, Deactivation_Date__c = date.today()+1,
                                                                  US_Bundle_Avail_Date__c = date.today(), US_Bundle_Pre_Purchase_Date__c = date.today(), CA_Bundle_Avail_Date__c = date.today(),
                                                                  CA_Bundle_Pre_Purchase_Date__c = date.today());
        
        test.startTest();
        insert bundleRelease;
        bundleRelease.Deactivation_Date__c = null;
        bundleRelease.US_Bundle_Avail_Date__c = null;
        bundleRelease.US_Bundle_Pre_Purchase_Date__c = null;
        bundleRelease.CA_Bundle_Avail_Date__c = null;
        bundleRelease.ca_Bundle_Pre_Purchase_Date__c = null;
        UPDATE bundleRelease;           
        test.stoptest();
    }
    
    /***********************************
Method Name: scenario6
Purpose: method to test code for DFOR-39 for Film Release
***********************************/
    static testMethod void scenario6() {
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        
        //create a title
        List<Title__c> titleList = new List<Title__c>();
        titleList= DGF_TestDataUtility.createTitle(1);
        
        test.startTest();
        //insert the created title records
        insert titleList;
        
        //creating TM Version
        list<TM_Version__c>tmvList = DGF_TestDataUtility.createTmVersion(1, titleList);
        for(TM_Version__c tmv : tmvList){
            tmv.Original_Flag__c = TRUE;
        }       
        insert tmvList;
        
        //create Right records
        Right__c USVOD = DGF_TestDataUtility.createRights(titleList[0].id,'VOD','US',true);
        insert USVOD;
        Right__c USEST = DGF_TestDataUtility.createRights(titleList[0].id,'EST','US',true);
        insert USEST;
        Right__c CAVOD = DGF_TestDataUtility.createRights(titleList[0].id,'VOD','CA',true);
        insert CAVOD;
        Right__c CAEST = DGF_TestDataUtility.createRights(titleList[0].id,'EST','CA',true);
        insert CAEST;
        
        Digital_Release__c dg = new Digital_Release__c(Name='test',title__c=titleList[0].id,RecordTypeId=FilmRecTypeId,US_Product_Type__c='Theatrical',
                                                       CA_Product_Type__c='Theatrical',US_Physical_Street_Date__c=date.today(),US_Theatrical_Release_Date__c=date.today());
        //inserting digital release
        insert dg;
        //query the inserted release
        Digital_Release__c dgr = [SELECT ID, US_VOD_Start_Date__c, US_Physical_Street_Date__c FROM Digital_Release__c where id=:dg.id];
        System.assertEquals(date.today(), dgr.US_VOD_Start_Date__c);
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario7
Purpose: method to test code for DFOR-39 for TV Release
***********************************/
    static testMethod void scenario7() {
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();  
        
        //create a title
        List<Title__c> titleList = new List<Title__c>();
        titleList = DGF_TestDataUtility.createTitle(1);
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        
        test.startTest();
        //insert the created title records
        insert titleList;
        insertDG[0].title__c = titleList[0].id;
        insert insertDG[0];
        
        Digital_Release__c dg = [SELECT ID,US_EST_Launch_Date__c from Digital_release__c where id=:insertDG[0].id];
        System.assertEquals(date.today(),dg.US_EST_Launch_Date__c);
        
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        dg.US_EST_Launch_Date__c = null;
        dg.US_Initial_EST_Launch_Date__c = null;
        dg.US_SVOD_Start_Date__c = null;
        dg.CA_EST_Launch_Date__c = null;
        dg.CA_Initial_EST_Launch_Date__c = null;
        dg.CA_SVOD_Start_Date__c = null;
        update dg;
        test.stopTest();
        
    }
    
    /****************************************
Method Name: scenario8
Purpose: method to test DFOR-44- updating pricing and product when release is updated
***********************************/
    static testMethod void scenario8() {
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();   
        Id FilmPrdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        
        test.startTest();
        //insert the Digital Release
        insert insertDG;
        
        list<Product__c>prdList = DGF_TestDataUtility.createCustomProduct(1, insertDG);
        
        //create products related to the release
        insert prdList;
        
        //set recordTypeId of the product
        prdList[0].recordTypeId = FilmPrdRecTypeId;
        update prdList[0];
        
        //create pricing records
        list<Pricing__c> pricingUSESTList = DGF_TestDataUtility.createPricing('US', true, true, false, false, 'EST', prdList[0].id);
        insert pricingUSESTList;
        
        list<Pricing__c>pricingCAESTList = DGF_TestDataUtility.createPricing('CA', true, true, false, false, 'EST', prdList[0].id);
        insert pricingCAESTList;
        
        list<Pricing__c>pricingCAVODList = DGF_TestDataUtility.createPricing('CA', true, true, false, false, 'VOD', prdList[0].id);
        insert pricingCAVODList;
        
        list<Pricing__c>pricingUSVODList = DGF_TestDataUtility.createPricing('US', true, true, false, false, 'VOD', prdList[0].id);
        insert pricingUSVODList;
        
        //update the fields on release
        insertDG[0].US_Launch_VOD_Categorization__c = 'Pre-Theatrical';
        insertDG[0].CA_Launch_VOD_Categorization__c = 'Catalog';
        insertDG[0].US_EPO_Date__c = date.today();
        insertDG[0].CA_EPO_Date__c = date.today();
        update insertDG[0];
        
        list<Product__c> prd = [SELECT US_VOD_Tier__c from Product__c where id=:prdList[0].id];
        System.assertEquals('Pre-Theatrical', prd[0].US_VOD_Tier__C);
        
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario9
Purpose: method to test calculation of dates
***********************************/
    static testMethod void scenario9(){
        
        //getting film record type id
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId(); 
        
        //creating digital release
        Digital_Release__c dg=new Digital_Release__c(Name ='release', US_Tertiary_Distributor__c='Universal', CA_Tertiary_Distributor__c='Universal',
                                                     US_Product_Type__c = DGF_Constants.PRODUCT_THEATRICAL, CA_Product_Type__c = DGF_Constants.PRODUCT_THEATRICAL,
                                                     US_Theatrical_Release_Date__c = date.today(), CA_Theatrical_Release_Date__c = date.today(), RecordTypeId = FilmRecTypeId);
        insert dg;
        
        test.startTest();
        dg.US_Theatrical_Release_Date__c = date.today()+5;
        dg.US_Tertiary_Distributor__c = 'Focus';
        dg.CA_Theatrical_Release_Date__c = date.today()+5;
        dg.CA_Tertiary_Distributor__c = 'Focus';
        update dg;
        
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        dg.US_Theatrical_Release_Date__c = date.today()+10;
        dg.US_Tertiary_Distributor__c = 'Open Road';
        dg.CA_Theatrical_Release_Date__c = date.today()+10;
        dg.CA_Tertiary_Distributor__c = 'Open Road';
        update dg;
        
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        dg.US_Theatrical_Release_Date__c = date.today()+15;
        dg.US_Tertiary_Distributor__c = 'Focus World';
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        dg.CA_Theatrical_Release_Date__c = date.today()+15;
        dg.CA_Tertiary_Distributor__c = 'Focus World';
        update dg;
        
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        dg.US_EST_Date__c = date.today();
        dg.US_Tertiary_Distributor__c = 'Mattel';
        dg.CA_EST_Date__c = date.today();
        dg.CA_Tertiary_Distributor__c='Mattel';
        dg.New_to_HD_CA_EST_Release_Date__c = date.today()+11;
        dg.New_to_HD_CA_VOD_Release_Date__c = date.today()+12;
        dg.New_to_HD_US_EST_Release_Date__c = date.today()-12;
        dg.New_to_HD_US_VOD_Release_Date__c = date.today()+14;
        dg.New_to_UHD_CA_EST_Release_Date__c = date.today()+14;
        dg.New_to_UHD_CA_VOD_Release_Date__c = date.today()+14;
        dg.New_to_UHD_US_EST_Release_Date__c = date.today()+14;
        dg.New_to_UHD_US_VOD_Release_Date__c = date.today()+14;
        update dg;
        
        //creating title records
        list<Title__c>titleList = DGF_TestDataUtility.createTitle(2);
        insert titleList;
        
        //creating version records
        list<TM_Version__c>tmvList = DGF_TestDataUtility.createTmVersion(2, titleList);
        insert tmvList;        
        
        System.AssertEquals(TRUE, tmvList.size() > 0);
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario10
Purpose: for testing bonus scenario
***********************************/
    static testMethod void scenario10() {
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        //getting record type ids
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId(); 
        Id bundleRecType = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId(); 
        
        //creating title records
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
        
        //creating digital release
        list<Digital_Release__c> digReleaseList = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insert digReleaseList;
        
        test.startTest();
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        digReleaseList[0].title__c = titleList[0].id;
        update digReleaseList[0];
        
        list<Digital_Release__c> bundleReleaseList = DGF_TestDataUtility.createDigitalRelease(1, bundleRecType);
        insert bundleReleaseList;
        
        list<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(1, bundleReleaseList);
        insert prdList;
        
        list<Product_version__c> prdversionList = DGF_TestDataUtility.createProductVersion(1, prdList, tmvList);
        insert prdVersionList;
        
        list<Product_Version__c> pvList = [SELECT ID,Product_Title__c FROM Product_Version__c where id =:prdVersionList[0].id];
        DGF_TriggerUtility.sobjectExecutedEvents.clear();
        digReleaseList[0].US_EST_Date__c = date.today()+20;
        digReleaseList[0].US_EPO_Date__c = date.today()+25;
        digReleaseList[0].CA_EST_Date__c = date.today()+20;
        digReleaseList[0].CA_EPO_Date__c = date.today()+25;
        update  digReleaseList[0];
        
        Digital_Release__c bunRel = [SELECT ID,US_Bundle_Avail_Date__c FROM Digital_Release__c where id=:bundleReleaseList[0].id];  
        System.AssertEquals(TRUE, bunRel != null);
        test.stopTest();
    }    
    
    /***********************************
Method Name: scenario11
Purpose: method to test code for DFOR-846
***********************************/
    static testMethod void scenario11(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);   
        for(TM_Version__c tm : insertTmVersion ){
            tm.TVD_SAFE_Production_ID__c = '123';
            tm.Version_EIDR__c = '43';
        }     
        insert insertTmVersion;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();    
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(10,FilmRecTypeId);
        insert insertDG;
        
        //getting record type for digital release
        Id FilmRecTypeIdProd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        
        Product__c prodFilm = new Product__c();
        prodFilm.Name = 'FILM PROD';
        prodFilm.RecordTypeId = FilmRecTypeIdProd;
        prodFilm.Digital_Release__c = insertDG[0].Id;        
        insert prodFilm;
        
        test.startTest();
        System.AssertEquals(TRUE, prodFilm.UHD__c == FALSE);
        insertDG[0].UHD__c = TRUE;
        update insertDG;
        
        List<Product__c> lstProd = [Select id, UHD__c from Product__c where ID =: prodFilm.id];
        System.AssertEquals(TRUE, lstProd[0].UHD__c == TRUE);            
        test.stopTest();        
    }
    
    static testMethod void scenario12() {
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();   
        Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id FreeEpiRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        insert insertDG;
        //insert product records
        list<Product__c> prodList = DGF_TestDataUtility.createCustomProduct(1, insertDG);
        prodList [0].recordTypeId = TVProdRecTypeId;
        insert prodList;
        //create free episode promotion
        list<Promotion__c> promoList = DGF_TestDataUtility.createPromotion(1, FreeEpiRecTypeId);
        promoList[0].Sync_Free_First_Episode_Dates__c  = true;
        insert promoList;
        //create promotion product record
        list<Promotion_Product__c> promoProdList = DGF_TestDataUtility.createPromoProd(1, prodList[0].id, promoList[0].id);
        insert promoProdList;
        Account acc = new Account (Name = 'test' , territory__c = 'US');
        insert acc;
        //insert product account record
        Product_Account__c prodAcc = new Product_Account__c (Product__c = prodList[0].id, Account__c = acc.id);
        insert prodAcc;
        test.startTest();
        //update dates on TV Release
        insertDG[0].US_EST_Launch_Date__c =date.today()+1;
        insertDG[0].Free_First_Episode_Start_Date__c = date.today()+2;
        insertDG[0].Free_First_Episode_End_Date__c = date.today()+3;
        update  insertDG[0];
        System.assertEquals(date.today(), promoList[0].start_date__c);
        test.stopTest();
    }
    
    /***********************************
Method Name: scenario13
Purpose: method to test code for DFOR-105
***********************************/
    static testMethod void scenario13(){
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        System.AssertEquals( TRUE , insertTitle[0].id != null , 'Title Record not Created');
        
        List<TM_Version__c> insertTmVersion = DGF_TestDataUtility.createTmVersion(5,insertTitle);        
        insert insertTmVersion;
        System.AssertEquals( TRUE , insertTmVersion[0].id != null , 'TM Version Record not Created');
        
        //getting record type for digital release
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id TVRecTypeIdPro = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id SeriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDGSeries = DGF_TestDataUtility.createDigitalRelease(1,SeriesRecTypeId);
        insert insertDGSeries;
        System.AssertEquals( TRUE , insertDGSeries[0].id != null , 'Series Digital Release Record not Created');
        
        List<Digital_Release__c> insertDGTV = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        
        for (Digital_Release__c  rel: insertDGTV) {
            rel.Series_Name__c = insertDGSeries[0].id;
            rel.Season_Type__c = 'Main';
        }
        
        test.startTest();
        insert insertDGTV;
        System.AssertEquals( TRUE , insertDGTV[0].id != null , 'TV Digital Release Record not Created');
        update insertDGTV;
        
        Digital_Release__c seriesRel = [SELECT ID,of_Seasons__c  FROM Digital_Release__c where id=:insertDGSeries[0].id];  
        System.AssertEquals(1, seriesRel.of_Seasons__c , 'No of Season is Not Updated');
        test.stopTest();
    }
    /***********************************
Method Name: scenario14
Purpose: method to test code for DFOR-153
***********************************/
    static testMethod void scenario14(){
        //getting record type IDs
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
        Id TVRecTypeIdPrd = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get('TV Bonus').getRecordTypeId();
        Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        //create Account records
        Account acc= new Account (Name = 'iTunes', RecordTypeId = AccRecTypeId, Categorization__c ='Current' ,Scripted_Reality__c ='Reality' ,Network_Categorization__c ='Bravo' , Bonus__c = 'Season Only');
        insert acc;
        Account acc1= new Account (Name = 'iTunes', RecordTypeId = AccRecTypeId, Categorization__c ='Current' ,Scripted_Reality__c ='Reality' ,Network_Categorization__c ='Chiller' , Bonus__c = 'Season Only');
        insert acc1;
        System.AssertEquals( TRUE , acc.id != null , 'Account Record not Created');
        
        //create TV Digital Release
        List<Digital_Release__c> insertDGTV = DGF_TestDataUtility.createDigitalRelease(1,TVRecTypeId);
        insertDGTV[0].Categorization__c = 'Current';
        insertDGTV[0].Scripted_Reality__c = 'Reality';
        // insertDGTV[0].Network_Categorization__c = 'Bravo'; DFOR-1578
        insertDGTV[0].US_Network_Categorization__c = 'Bravo';
        insertDGTV[0].TV_Studio__c = 'Bravo';
        insert insertDGTV;
        System.AssertEquals( TRUE , insertDGTV[0].id != null , 'TV Digital Release Record not Created');
        
        //create a TV Bonus record
        List<EPO_Bonus__c> insertEPO = DGF_TestDataUtility.createEPOBonus(1,TVRecTypeIdPrd);
        insertEPO[0].Digital_release__c = insertDGTV[0].id;
        insertEPO[0].bonus_type__c = 'Season Only';
        insert insertEPO[0];
        System.AssertEquals( TRUE , insertEPO[0].id != null , 'Bonus Record not Created');
        
        //create TV Product Record
        List<Product__c> prdList = DGF_TestDataUtility.createCustomProduct(1, insertDGTV);
        prdList[0].recordTypeId = TVProdRecTypeId;
        insert prdList;
        
        test.startTest();
        //update the Network Categorization on TV Release
        //insertDGTV[0].Network_Categorization__c = 'Chiller'; //DFOR-1578
        insertDGTV[0].US_Network_Categorization__c = 'Chiller';
        update insertDGTV[0];
        Bonus_Account__c ba = [SELECT ID, Account__c, Account__r.Network_Categorization__c FROM Bonus_Account__c where Bonus__c =:insertEPO[0].id];
        System.assertEquals('Chiller', ba.Account__r.Network_Categorization__c);
        test.stopTest();
    }
    
    //===================================================================
    //	
    //	created for Sent to GTM Rest callout 
    //
    //===================================================================
    static testMethod void scenarioSendToGTM(){
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        //getting record type IDs
        Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new SendJSONString_MockTest());
        
        //create TV Digital Release
        List<Digital_Release__c> insertDGTV = DGF_TestDataUtility.createDigitalRelease1(1,TVRecTypeId);
        
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
        insertDGTV[0].Primary_Bundle_Genre__c='Action';
        insertDGTV[0].Bundle_Genre__c='Action; Adventure';
        update insertDGTV[0];
        List<String> idds=new List<String>();
        idds.add(insertDGTV[0].id);
        Boolean bundleGnr=true;
        Boolean CAPreDT_AD=true;
        Boolean CAPreDT_ED=true;
        Boolean CAavDT_AD=true;
        Boolean CAavDT_ED=true;
        Boolean CAPrePurDT_AD=true;
        Boolean CAPrePurDT_ED=true;
        Boolean DeactDT_AD=true;
        Boolean DeactDT_ED=true;
        Boolean USAvail_AD=true;
        Boolean USAvail_ED=true;
        boolean primaryGnr=true;
        SendJsonString.DigitalReleaseUpdateOnly(idds,primaryGnr, bundleGnr,  CAPreDT_AD, CAPreDT_ED, CAavDT_AD, CAavDT_ED, CAPrePurDT_AD, CAPrePurDT_ED,  DeactDT_AD, DeactDT_ED, USAvail_AD, USAvail_ED);
        test.stopTest();
    }
}