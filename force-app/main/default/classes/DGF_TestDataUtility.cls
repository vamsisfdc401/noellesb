/***********************************************************************************
Class Name: DGF_TestDataUtility
Purpose: class for setting up test data
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Mohit                    Initial Development
******************************************************************************************/
public class DGF_TestDataUtility{ 
    
    /*****************************************
Method Name: createDigitalRelease
Purpose: Method to create digital release
*****************************************/    
    public static List<Digital_Release__c> createDigitalRelease(Integer count, string recordType){
        List<Digital_Release__c> lstDG = new List<Digital_Release__c>();
        
        
        for(integer i=1;i<=count;i++){
            Digital_Release__c dg = new Digital_Release__c();
            dg.Name = 'Test DR '+recordType +i;
            dg.US_EPO_Date__c = Date.Today() + 10;
            dg.CA_EPO_Date__c = Date.Today();
            dg.CA_Bundle_Avail_Date__c=date.today();
             dg.of_Seasons__c= 1;
            dg.recordTypeID = recordType;
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
            lstDG.add(dg);            
        }
        
        return lstDG;    
    }
    
    /*****************************************
Method Name: createEPOBonus
Purpose: Method to create EPO and Bonus
*****************************************/    
    public static List<EPO_Bonus__c> createEPOBonus(Integer count, string recordType){
        List<EPO_Bonus__c> lstEPO = new List<EPO_Bonus__c>();
        list<Digital_Release__c> lstRel=new list<Digital_Release__c>();
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();   
        lstRel=createDigitalRelease(1,FilmRecTypeId);
        for(integer i=1;i<=count;i++){
            EPO_Bonus__c epo = new EPO_Bonus__c();
            epo.Name = 'Test ' + i;
            epo.Digital_Release__c=lstRel[0].id;
            epo.RecordTypeId=recordType;
            epo.US_End_Date__c=date.today();
            epo.US_Start_Date__c=date.today();
            epo.CA_End_Date__c=date.today();
            epo.CA_Start_Date__c=date.today();
            lstEPO.add(epo);
        }
        return lstEPO;
    }
    
    /*****************************************
Method Name: createCustomProduct
Purpose: Method to create Product
*****************************************/
    public static List<Product__c> createCustomProduct(Integer count,List<Digital_Release__c> dgtlRelease){
        
        List<Product__c> prodList = new List<Product__c>();
        list<Digital_Release__c> lstRel=new list<Digital_Release__c>();
        
        for(integer i=1;i<=count;i++){
            Product__c prd = new Product__c();
            prd.Name = 'Test ' + i;
            prd.Digital_Release__c = dgtlRelease[0].id;
            prd.HD__c = true;
            prd.SD__c = true;
            prd.UHD__c=true;
            prd.X3D__c=true;
            prd.US_Platform_Offering__c = 'EST';
            prd.CA_Platform_Offering__c = 'EST';
            prd.EST_Tier__c = 'Tier 2';
            prd.CA_EST_Tier__c = 'New Release Premium';
            prodList.add(prd);
        }
        return prodList;
    }
    
    /*****************************************
Method Name: createTitle
Purpose: Method to create Title
*****************************************/
    public static List<Title__c> createTitle(Integer count){
        List<Title__c> titleList = new List<Title__c>();
        for(integer i=1;i<=count;i++){
            Title__c titl = new Title__c();
            titl.Name = 'Test ' + i;
            titl.SGENNO__c = 'SGENNO' + i;
            //titl.Parent_SGENNO__c = 'SGENNO' + i;
            titl.Network_of_Air_Date__c=date.today();
            titl.Active_Flag__c = TRUE;
            titleList.add(titl);
        }
        return titleList;
    }
    
    /*****************************************
Method Name: createAccount
Purpose: Method to create Account
*****************************************/
    public static List<Account> createAccount(Integer count){
        List<Account> accList = new List<Account>();
        for(integer i=1;i<=count;i++){
            Account acnt = new Account();
            acnt.Name = 'Test ' + i;
            acnt.Territory__c='US';
            accList.add(acnt);
        }
        return accList;
    }
    
    /*****************************************
Method Name: createTmVersion
Purpose: Method to create TmVersion
*****************************************/
    public static List<TM_Version__c> createTmVersion(Integer count,List<Title__c> titles){
        List<TM_Version__c> tmVersionList = new List<TM_Version__c>();
        
        for(integer i=0;i<count;i++){
            TM_Version__c tmVersion = new TM_Version__c();
            tmVersion.Name = 'Test ' + i;
            tmVersion.Title__c = titles[i].id;
            tmVersionList.add(tmVersion);
        }
        return tmVersionList;
    }
    
    /*****************************************
Method Name: createProductVersion
Purpose: Method to create ProductVersion
*****************************************/
    public static List<Product_Version__c> createProductVersion(Integer count,List<Product__c> prods,List<TM_Version__c> tmVersions){
        List<Product_Version__c> prodVersionList = new List<Product_Version__c>();
        
        for(integer i=0;i<count;i++){
            Product_Version__c pv = new Product_Version__c();
            pv.Product__c = prods[i].id;
            pv.TM_Version__c = tmVersions[i].id;
            prodVersionList.add(pv);
        }
        return prodVersionList;
    }
    
    /*****************************************
Method Name: createRights
Purpose: Method to create Rights
*****************************************/
    public static Right__c createRights(Id titleId,String platform,String territory,Boolean rights){
        
        Right__c r=new Right__c();
        r.Title__c=titleId;
        r.Platform__c=platform;
        r.Territory__c=territory;
       // r.Rights__c=rights;
        r.Rights_Start_Date__c=date.today();
        r.Rights_End_Date__c=date.today();
        
        return r;
    }
    
    /*****************************************
Method Name: createRights
Purpose: Method to create Rights
*****************************************/
    public static List<Right__c> createRights(Id titleId,String platform,String territory,Boolean rights,integer count){
        List<Right__c> lstRight = new List<Right__c>();
        
        for(integer i=1;i<=count;i++){
            Right__c r=new Right__c();
            r.Title__c=titleId;
            r.Platform__c=platform;
            r.Territory__c=territory;
            //r.Rights__c=rights;
            r.Rights_Start_Date__c=date.today();
            r.Rights_End_Date__c=date.today();  
            lstRight.add(r);      
        }            
        
        return lstRight;
    }
    
    /*****************************************
Method Name: createEPOBonus
Purpose: Method to create EPO and Bonus
*****************************************/    
    public static List<EPO_Bonus__c> createEPOBonus(Integer count, string recordType, ID releaseID){
        List<EPO_Bonus__c> lstEPO = new List<EPO_Bonus__c>();
        list<Digital_Release__c> lstRel=new list<Digital_Release__c>();
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();   
        lstRel=createDigitalRelease(1,FilmRecTypeId);
        for(integer i=1;i<=count;i++){
            EPO_Bonus__c epo = new EPO_Bonus__c();
            epo.Name = 'Test ' + i;
            epo.Digital_Release__c= releaseID;
            epo.RecordTypeId=recordType;
            epo.US_End_Date__c=date.today();
            epo.US_Start_Date__c=date.today();
            epo.CA_End_Date__c=date.today();
            epo.CA_Start_Date__c=date.today();
            lstEPO.add(epo);
        }
        return lstEPO;
    }
    
    
    /*****************************************
Method Name: createProductAccount
Purpose: method to create product accounts
*****************************************/    
    public static List<Product_Account__c> createProductAccount(Integer count,ID productID, ID AccountID){
        List<product_account__c> lstProdAccount = new List<Product_Account__c>();
        
        for(integer i=1;i<=count;i++){
            product_account__c pa = new product_account__c();
            pa.Account__c = AccountID;
            pa.Product__c = productID;
            
            lstProdAccount.add(pa);
        }
        return lstProdAccount;
    }
    
    /*****************************************
Method Name: createBonusAccount
Purpose: method to create bonus accounts
*****************************************/    
    public static List<Bonus_Account__c> createBonusAccount(Integer count,ID bonusID, ID AccountID){
        List<Bonus_Account__c> lstBonusAccount = new List<Bonus_Account__c>();
        
        for(integer i=1;i<=count;i++){
            Bonus_Account__c ba = new Bonus_Account__c();
            ba.Account__c = AccountID;
            ba.Bonus__c = bonusID;
            
            lstBonusAccount.add(ba);
        }
        return lstBonusAccount;
    }
    
    /*****************************************
Method Name: createPromotions
Purpose: method to create promotions
*****************************************/    
    public static List<Promotion__c> createPromotion(Integer count,Id recTypeId){
        List<Promotion__c> lstPromo = new List<Promotion__c>();
        
        for(integer i=1;i<=count;i++){
            Promotion__c pr = new Promotion__c();
            pr.Name = 'test'+i;
            pr.Start_Date__c = date.today();
            pr.End_Date__c = date.today();
            PR.Promotion_Type__c='Collection';
            pr.RecordTypeId = recTypeId;
            pr.Territory__c = 'US';
            lstPromo.add(pr);
        }
        return lstPromo;
    }
    
    /*****************************************
Method Name: createPricing
Purpose: method to create pricing
*****************************************/    
    public static list<Pricing__c> createPricing(String territory,Boolean Hd, Boolean sd, Boolean uhd, Boolean res3d,String Platform,Id ProdId){
        list<Pricing__c>pricingList=new list<Pricing__c>();
        if(hd){
            Pricing__c hdPrice=new Pricing__c(Name='hd',Price_type__c='Original',Territory__c=territory,Resolution__c='HD',Platform__c=platform,Product__c=prodId,wsp__c=10,valid_from__c=date.today()-1);
            pricingList.add(hdPrice);
        }
        if(sd){
            Pricing__c sdPrice=new Pricing__c(Name='Sd',Price_type__c='Original',Territory__c=territory,Resolution__c='SD',Platform__c=platform,Product__c=prodId,wsp__c=10,valid_from__c=date.today()-1);
            pricingList.add(sdPrice);
        }
        if(uhd){
            Pricing__c uhPrice=new Pricing__c(Name='uhd',Price_type__c='Original',Territory__c=territory,Resolution__c='UHD',Platform__c=platform,Product__c=prodId,wsp__c=10,valid_from__c=date.today()-1);
            pricingList.add(uhPrice);
        }
        if(res3d){
            Pricing__c price3d=new Pricing__c(Name='3d',Price_type__c='Original',Territory__c=territory,Resolution__c='3D',Platform__c=platform,Product__c=prodId,wsp__c=10,valid_from__c=date.today()-1);
            pricingList.add(price3d);
        }
        return pricingList;
    }
    
    /*****************************************
Method Name: createSyncDigitalRelease
Purpose: method to create custom setting record for syncing digital release
*****************************************/ 
    public static DGF_SyncDigitalRelease__c createSyncDigitalRelease(Boolean isSyncEnabled){
        DGF_SyncDigitalRelease__c csSyncRelease = new DGF_SyncDigitalRelease__c();
        csSyncRelease.Name = 'Release_Sync';
        csSyncRelease.Sync_Release__c = isSyncEnabled;
        return csSyncRelease;
    }
    
    /*****************************************
Method Name: createReleaseFieldMapping
Purpose: for creating Rf and DGF field mapping
*****************************************/ 
    public static List<DGF_ReleaseFieldMapping__c> createReleaseFieldMapping(){
        
        List<DGF_ReleaseFieldMapping__c> lstRelFieldMapping = new List<DGF_ReleaseFieldMapping__c>();
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping1 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping1.Name = 'FieldMapping_1';
        csReleaseFieldMapping1.Source_Field_API_Name__c = 'Id';
        csReleaseFieldMapping1.Target_Field_API_Name__c = 'US_Release__c';
        csReleaseFieldMapping1.Territory__c = 'US';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping1);
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping2 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping2.Name = 'FieldMapping_2';
        csReleaseFieldMapping2.Source_Field_API_Name__c = 'Id';
        csReleaseFieldMapping2.Target_Field_API_Name__c = 'CA_Release__c';
        csReleaseFieldMapping2.Territory__c = 'CA';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping2);
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping3 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping3.Name = 'FieldMapping_3';
        csReleaseFieldMapping3.Source_Field_API_Name__c = 'Name';
        csReleaseFieldMapping3.Target_Field_API_Name__c = 'Name';
        csReleaseFieldMapping3.Territory__c = 'US & CA';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping3);
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping4 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping4.Name = 'FieldMapping_4';
        csReleaseFieldMapping4.Source_Field_API_Name__c = 'Title__c';
        csReleaseFieldMapping4.Target_Field_API_Name__c = 'Title__c';
        csReleaseFieldMapping4.Territory__c = 'US & CA';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping4);
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping5 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping5.Name = 'FieldMapping_5';
        csReleaseFieldMapping5.Source_Field_API_Name__c = 'Distributor__c';
        csReleaseFieldMapping5.Target_Field_API_Name__c = 'US_Tertiary_Distributor__c';
        csReleaseFieldMapping5.Territory__c = 'US';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping5);
        
        DGF_ReleaseFieldMapping__c csReleaseFieldMapping6 = new DGF_ReleaseFieldMapping__c();
        csReleaseFieldMapping6.Name = 'FieldMapping_6';
        csReleaseFieldMapping6.Source_Field_API_Name__c = 'Distributor__c';
        csReleaseFieldMapping6.Target_Field_API_Name__c = 'CA_Tertiary_Distributor__c';
        csReleaseFieldMapping6.Territory__c = 'CA';
        csReleaseFieldMapping1.Execute_on_Update__c = TRUE;
        lstRelFieldMapping.add(csReleaseFieldMapping6);
        
        return lstRelFieldMapping;
    }
    
    /*****************************************
Method Name: createRFRelease
Purpose: for creating a RF release
*****************************************/ 
    public static List<Release__c> createRFRelease(integer count,string brandGroup,string territory,ID recordType, ID titleId){
        List<Release__c> lstRelDetails = new List<Release__c>();
        
        for(integer i=1;i<=count;i++){
            Release__c rel = new Release__c();
            rel.Name = 'Test' + i;
            rel.Brand_Group__c = brandGroup;
            rel.Territory__c = territory ;
            rel.recordTypeID = recordType;
            rel.Title__c = titleId;
            rel.Street_date__c = Date.Today();
            lstRelDetails.add(rel);
        }
        return lstRelDetails;
    }
    
    /*****************************************
Method Name: createPromoProd
Purpose: for creating a Promotion Product
*****************************************/ 
    public static list<Promotion_Product__c>createPromoProd(Integer count,Id prdId,Id PromoId){
        list<Promotion_Product__c>promoList=new list<Promotion_Product__c>();
        for(integer i=1;i<=count;i++){
            Promotion_Product__c pr=new Promotion_Product__c();
            pr.TPR__c=true;
            pr.TPR_Start_Date__c=date.today();
            pr.TPR_End_date__c=date.today()+30;
            pr.Promotion__c=PromoId;
            pr.Product__c=prdId;
            promolist.add(pr);
        }
        return promoList;
    }
    
    /*****************************************
Method Name: createTPRPricing
Purpose: for creating TPR Pricing
*****************************************/ 
    public static list<Pricing__c>createTPRPricing(ID PrdId,Id promoId,String territory,String Platform){
        list<Pricing__c>priceList=new list<Pricing__c>();
        Pricing__c sd=new Pricing__c(Territory__c=territory,Resolution__c='sd',Platform__c=platform,WSP__c=10,Price_Type__c='TPR Account',Product__c=prdId,Promotion__c=promoId);
        priceList.add(sd);
        Pricing__c hd=new Pricing__c(Territory__c=territory,Resolution__c='hd',Platform__c=platform,WSP__c=10,Price_Type__c='TPR Account',Product__c=prdId,Promotion__c=promoId);
        priceList.add(hd);
        Pricing__c uhd=new Pricing__c(Territory__c=territory,Resolution__c='uhd',Platform__c=platform,WSP__c=10,Price_Type__c='TPR Account',Product__c=prdId,Promotion__c=promoId);
        priceList.add(uhd);
        Pricing__c x3d=new Pricing__c(Territory__c=territory,Resolution__c='3d',Platform__c=platform,WSP__c=10,Price_Type__c='TPR Account',Product__c=prdId,Promotion__c=promoId);
        priceList.add(x3d);
        return priceList;
    }
    
    public static list<Pricing_Tier__c>createPricingTier(){
        Pricing_Tier__C pt1=new Pricing_Tier__c(Territory__c='US',Platform__c='EST',Resolution__c='SD',Product_Type__c='TV',Category__c=DGF_Constants.TV_EPISODE,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt2=new Pricing_Tier__c(Territory__c='US',Platform__c='EST',Resolution__c='HD',Product_Type__c='TV',Category__c=DGF_Constants.TV_EPISODE,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt3=new Pricing_Tier__c(Territory__c='CA',Platform__c='EST',Resolution__c='SD',Product_Type__c='TV',Category__c=DGF_Constants.TV_EPISODE,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt4=new Pricing_Tier__c(Territory__c='CA',Platform__c='EST',Resolution__c='HD',Product_Type__c='TV',Category__c=DGF_Constants.TV_EPISODE,wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt5=new Pricing_Tier__c(Territory__c='US',Platform__c='VOD',Resolution__c='HD',Product_Type__c='Film',Category__c='Current',wsp__C=10,SRP__c=20);
        
        Pricing_Tier__C pt6=new Pricing_Tier__c(Territory__c='CA',Platform__c='EST',Resolution__c='HD',Product_Type__c='Film',Category__c='Tier 2',wsp__C=10,SRP__c=20);
        
        list <Pricing_Tier__c>ptList=new list<Pricing_Tier__c>();
        ptList.add(pt1);
        ptList.add(pt2);
        ptList.add(pt3);
        ptList.add(pt4);
        ptList.add(pt5);
        return ptlist;
    }
    
     public Static User createUser(String profileName,String userName,String nickName)
    {
        User user = new User();
        user.LastName = 'Test User';
        user.Alias = 'TU1';
        user.Email = 'testUser12@gmail.com';
        user.Username = userName;
        user.CommunityNickname = nickName;
       
        
        List<Profile> profileList = [Select Id,Name from Profile where Name=:profileName];

        user.ProfileId = profileList[0].Id;
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        database.insert(user);
        return user;
    }
     public static List<Digital_Release__c> createDigitalRelease1(Integer count, string recordType){
        List<Digital_Release__c> lstDG = new List<Digital_Release__c>();       
        for(integer i=1;i<=count;i++){
            Digital_Release__c dg = new Digital_Release__c();
            dg.Name = 'Test DR '+recordType +i;
            dg.US_EPO_Date__c = Date.Today() + 10;
            dg.CA_EPO_Date__c = Date.Today();
            dg.recordTypeID = recordType;
            dg.Bundle_SYSGEN__c='1234523';
            
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
            lstDG.add(dg);            
        }
        
        return lstDG;    
    } 
    
    
    //========================================== add product ==========================
     public static List<Product__c> createCustomProduct1(Integer count,List<Digital_Release__c> dgtlRelease){
        Id ProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Bundle').getRecordTypeId();        
        List<Product__c> prodList = new List<Product__c>();
        list<Digital_Release__c> lstRel=new list<Digital_Release__c>();
        
        for(integer i=1;i<=count;i++){
            Product__c prd = new Product__c();
            prd.Name = 'Test ' + i;
            prd.RecordTypeId=ProdRecTypeId;
            prd.Digital_Release__c = dgtlRelease[0].id;
            prd.Short_Name__c='Short Name'+i;
            prd.Bundle_Synopsis__c='Bundle snps'+i;
            prodList.add(prd);
        }
        return prodList;
    }
    
     public static List<Product_Version__c> createProductVersion1(Integer count,List<Product__c> prods,List<TM_Version__c> tmVersions){
        List<Product_Version__c> prodVersionList = new List<Product_Version__c>();
        
        for(integer i=0;i<count;i++){
            Product_Version__c pv = new Product_Version__c();
            pv.Product__c = prods[0].id;
            pv.TM_Version__c = tmVersions[i].id;
            prodVersionList.add(pv);
        }
        return prodVersionList;
    }
    
}