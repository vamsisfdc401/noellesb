@isTest(seeAllData = FALSE)
public class DGF_PricingTiersSelectionTest {
	static testMethod void scenario1() {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        Id FilmRecTypeIdPrd = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();
        List<Digital_Release__c> lstDG = new List<Digital_Release__c>();
        
        
        for(integer i=1;i<=1;i++){
            Digital_Release__c dg = new Digital_Release__c();
            dg.Name = 'Test ' + i;
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
            dg.US_Launch_VOD_Categorization__c = 'Current';
            dg.CA_Launch_VOD_Categorization__c = 'Current';
            dg.US_EPO_Date__c = date.today() - 10;
            dg.CA_EPO_Date__c = date.today() - 10;
            dg.of_Titles_in_Bundle__c = 3;
            lstDG.add(dg);            
        }
        insert lstDG;
        //getting list of Digital release records to be created
        //List<Digital_Release__c> insertdgtlRels = DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        
        
        //inserting Digital Release
        //insert insertdgtlRels;
        //System.assertEquals(1, insertdgtlRels.size());
        
        //insert Pricing Tier
        //list<Pricing_Tier__c>ptList=new list<Pricing_Tier__c>();
        //ptList=DGF_TestDataUtility.createPricingtier();
        Pricing_Tier__C pt1=new Pricing_Tier__c(Territory__c='US',No_of_Titles__c = 3, Platform__c='EST',Resolution__c='SD',Product_Type__c='Bundle',Category__c=DGF_Constants.NEW_RELEASE_STANDARD,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt2=new Pricing_Tier__c(Territory__c='US',No_of_Titles__c = 3, Platform__c='EST',Resolution__c='HD',Product_Type__c='Bundle',Category__c=DGF_Constants.NEW_RELEASE_PREMIUM,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt3=new Pricing_Tier__c(Territory__c='CA',No_of_Titles__c = 3, Platform__c='EST',Resolution__c='SD',Product_Type__c='Bundle',Category__c=DGF_Constants.NEW_RELEASE_STANDARD,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt4=new Pricing_Tier__c(Territory__c='CA',No_of_Titles__c = 3, Platform__c='EST',Resolution__c='HD',Product_Type__c='Bundle',Category__c=DGF_Constants.NEW_RELEASE_PREMIUM,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt5=new Pricing_Tier__c(Territory__c='US',No_of_Titles__c = 3, Platform__c='VOD',Resolution__c='HD',Product_Type__c='Bundle',Category__c='Current',wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt6=new Pricing_Tier__c(Territory__c='CA',No_of_Titles__c = 3, Platform__c='EST',Resolution__c='HD',Product_Type__c='Bundle',Category__c='Tier 2',wsp__C=10,SRP__c=20);
        
        list <Pricing_Tier__c>ptList=new list<Pricing_Tier__c>();
        ptList.add(pt1);
        ptList.add(pt2);
        ptList.add(pt3);
        ptList.add(pt4);
        ptList.add(pt5);
        //return ptlist;
        insert ptlist;
        
        //getting list of Product records to be created
        List<Product__c> insertProd = DGF_TestDataUtility.createCustomProduct(5,lstDG);
        for(Product__c pr : insertProd){
            pr.RecordTypeId = FilmRecTypeIdPrd;
        }
        
        //inserting Products
        insert insertProd;
        
        
        test.startTest();
        List<DGF_PricingTiersSelection.PTierRecords> lstPTs = new List<DGF_PricingTiersSelection.PTierRecords>();
        lstPTs = DGF_PricingTiersSelection.getPTRecords(lstDG[0].Id);
        lstPTs[0].isSelected = true;
        
        String strLst = JSON.serialize(lstPTs);
        DGF_PricingTiersSelection.savePricingTiers(strLst, String.valueOf(lstDG[0].Id), 'Original', '2018-11-16');
        lstPTs[1].isSelected = true;
        
        lstPTs = DGF_PricingTiersSelection.getPTRecords(lstDG[0].Id);
        DGF_PricingTiersSelection.getProductSel(lstDG[0].Id);
        DGF_PricingTiersSelection.getUserProfile();
        Test.stopTest();
    }
}