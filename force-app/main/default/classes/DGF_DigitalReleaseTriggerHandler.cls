/***********************************************************************************
Class Name: DGF_DigitalReleaseTriggerHandler
Purpose: Handler class for digital release trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/04/2017           Mohit                    Initial Development
1.1             02/11/2017           Mohit                    DFOR-846: Updating resolution on products updateProductResolution()
1.2             06/12/2017          Nandeesh                  DFOR-105: Title Hierarchy for TV - Create links between Series and Season updateSeriesDigitalRelease()
1.3             11/10/2018          Naga                      DFOR-1526 : Adding or Removing products,pre-order products when RecordType changes from Film to Competitive and vice versa.
******************************************************************************************/
public without sharing class DGF_DigitalReleaseTriggerHandler {
    
    /*****private declaration*****/
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> deleteableDataSet = new Map<String, List<SObject>>();
    private static set<ID> setDigitalReleaseId = new Set<ID>();
    private static set<ID> setTitleId = new Set<ID>();
    private static set<ID> setTVReleaseParentIds = new Set<ID>();
    private static Digital_Release__c dgOld; 
    private static Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id CompRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.COMPETETIVE ).getRecordTypeId();
    private static Id ProdFilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id ProdTVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id PreOrderProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
    private static Id BonusFilmRecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get(DGF_Constants.FILM_BONUS).getRecordTypeId();
    private static Id FreeEpisodePromoRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
    private static map<String,Digital_Date__c>digitalDateMap=new map<String,Digital_Date__c>();
    private static Boolean isUSESTRight = FALSE;
    private static Boolean isUSVODRight = FALSE;
    private static Boolean isCAESTRight = FALSE;
    private static Boolean isCAVODRight = FALSE;
    private static set<ID> setProductId = new Set<ID>();
    private static Map<string,string> mapDateField = new Map<string,string>();
    private static set<Id> setTitleIDAll = new Set<Id>();
    private static list<Digital_Release__c> bundleReleaseList = new list<Digital_Release__c>();
    private static Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
    private static set<ID> setSeriesDigitalReleaseId = new Set<ID>();
    private static Id SeriesRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.SERIES).getRecordTypeId();
    private static Map<Id,Decimal> aggregateCountMap = new Map<Id,Decimal>();
    private static Map<Id,Decimal> aggregateSumMap = new Map<Id,Decimal>();
    private static AggregateResult[] result ;
    private static set<Id> promoSet = new set<Id> ();
    private static Map<id, Digital_Release__c> tvTitleReleaseMap = new Map<id, Digital_Release__c>();
    private static Map<id, Digital_Release__c> seriesDigiReleaseMap = new Map<id, Digital_Release__c>();
    private static Set<id> seriesDigiReleaseList = new Set<id>();
    public static list<Product_Account__c> deleteProdAccList = new list<Product_Account__c>();
    /***********************************
Method Name: resetDataSet
Purpose: method to reset context data variable
***********************************/
    private static void resetDataSet() {    
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear(); 
        setDigitalReleaseId.clear();
        digitalDateMap.clear();
        setTitleId.clear();
        setProductId.clear();
        bundleReleaseList.clear();
        setSeriesDigitalReleaseId.clear();
        deleteProdAccList.clear();
    }
    
    /***********************************
Method Name: getDataSet
Purpose: method for executing SOQL
***********************************/
    @testVisible private static void getDataSet() {
        //checking if digital release ID are present
        if (!setDigitalReleaseId.isEmpty()) {
            //adding a instance of digital release in the map
            if (!fetchDataSet.containsKey('Digital_Release__c')){
                fetchDataSet.put('Digital_Release__c',new Map<ID,sObject>());
            }                
            
            //looping over digital release
            for (Digital_Release__c dg : [Select ID, US_EST_Date__c, US_EPO_Date__c, US_VOD_Start_Date__c, (Select id, name, RecordTypeID, Package__c, Platform__c,
                                                                                                            Start_Date__c, VOD_Start_Date__c from EPO_Bonus__r), (Select id, name, HD__c, X3D__c, UHD__c, SD__c from Products__r) from Digital_Release__c where id in:setDigitalReleaseId ]) {
                                                                                                                fetchDataSet.get('Digital_Release__c').put(dg.ID, dg);  
                                                                                                            } 
            Map<Id,EPO_Bonus__c> epoBonusMap = new map<Id, EPO_Bonus__c> ([Select id, name, RecordTypeID, Package__c, Platform__c, Start_Date__c, VOD_Start_Date__c from EPO_Bonus__c where Digital_Release__c IN:fetchDataSet.get('Digital_Release__c').keySet()]);
            fetchDataSet.put('EPO_Bonus__c',epoBonusMap);
            
            if (!fetchDataSet.containsKey('Digital_Date__c')) {
                fetchDataSet.put('Digital_Date__c',new Map<ID,sObject>());
            }
            
            //looping over Digital Date
            for (Digital_Date__c digDate : [Select ID, Name, Date_API_Name__c, Digital_Release__c, Release_Date__c, Release_Date_Type__c 
                                            FROM Digital_Date__c where Digital_Release__c IN:setDigitalReleaseId ]) {
                                                fetchDataSet.get('Digital_Date__c').put(digDate.ID, digDate);  
                                            } 
            
            if (!fetchDataSet.containsKey('Product__c')) {
                fetchDataSet.put('Product__c',new Map<ID,sObject>());
            }
            
            //looping over Products related to the release in context
            for (Product__c prod:[SELECT Id, Digital_Release__c, X3D__c, HD__c, SD__c, UHD__c, US_Platform_Offering__c, CA_EST_Tier__C,
                                  CA_Platform_Offering__c, Digital_Release__r.US_Launch_VOD_Categorization__c, US_VOD_Tier__c, CA_VOD_Tier__c,
                                  Digital_Release__r.CA_Launch_VOD_Categorization__c, Digital_Release__r.US_EPO_Date__c,
                                  Digital_Release__r.CA_EPO_Date__c, Digital_Release__r.US_EST_Date__c,EST_Tier__c,
                                  Digital_Release__r.CA_EST_Date__c, Digital_Release__r.US_VOD_Start_Date__c,
                                  Digital_Release__r.CA_VOD_Start_Date__c, Digital_Release__r.US_VOD_End_Date__c,
                                  Digital_Release__r.CA_VOD_End_Date__c, RecordTypeId ,
                                  (SELECT ID, Launch_Date__c, Pre_Order_Date__c, Product__c, Account__c, Account__r.Territory__c FROM Product_Account__r ), 
                                  (Select id , promotion__c from Product_Promotions__r where promotion__r.RecordTypeId =:FreeEpisodePromoRecTypeId and Promotion__r.Sync_Free_First_Episode_Dates__c = true )
                                  FROM Product__c where Digital_Release__c IN:setDigitalReleaseId]) {
                                      fetchDataSet.get('Product__c').put(prod.id,prod);        
                                      for(Promotion_Product__C promoPrd : prod.Product_Promotions__r) {
                                          promoSet.add(promoPrd.promotion__c);
                                      }                                  
                                  }
            Map<Id, Pricing__c> ProductPricingMap =  new Map<Id, Pricing__c> ([SELECT ID, Category__c, Margin__c, Platform__c, Price_Type__c,
                                                                               iTunes_Tier__c, Product__c, Resolution__c, SRP__c,Territory__c, Valid_From__c, Valid_To__c, WSP__c,promotion__c FROM Pricing__c where Product__c IN:fetchDataSet.get('Product__c').keySet()]) ;
            fetchDataSet.put('ProductPricing',ProductPricingMap);
            
            //query promotions associated to the promotion products
            if (!fetchDataSet.containsKey('Promotion__c')) {
                fetchDataSet.put('Promotion__c',new Map<ID,sObject>());
            }
            for(Promotion__c pr: [SELECT ID, Start_Date__c, End_Date__c from promotion__c where id in:promoSet]) {
                fetchDataSet.get('Promotion__c').put(pr.id,pr);       
            }
            if (!fetchDataSet.containsKey('EPO_Bonus__c')) {
                fetchDataSet.put('EPO_Bonus__c',new Map<ID,sObject>());
            }
            
            for(EPO_Bonus__c bonus : [SELECT ID, Name, RecordTypeID, Package__c, Platform__c, Start_Date__c, VOD_Start_Date__c, Digital_Release__c, Bonus_Type__c, us_start_date__c, ca_start_date__c ,(Select ID, Account__c FROM Bonus_Account__r) FROM EPO_Bonus__c where Digital_Release__c  in:setDigitalReleaseId]) {
                fetchDataSet.get('EPO_Bonus__c').put(bonus.id,bonus);
            }
            
            
        } 
        
        
        //get title details
        if (!setTitleId.isEmpty()) {      
            if (!fetchDataSet.containsKey('Title__c')) {
                fetchDataSet.put('Title__c',new Map<ID,sObject>());
            }
            
            for (Title__c title:[select id, Network_of_Air_Date__c, Initial_Release_Air_Year__c, name, (Select id, name, Platform__c, Territory__c,
                                                                                                        Rights_End_Date__c, Rights_Start_Date__c, Rights__c from Rights__r) from Title__c where id IN:setTitleID]) {               
                                                                                                            fetchDataSet.get('Title__c').put(title.ID, title);  
                                                                                                        }
        }
        
        //get title details
        if (!setTitleIDAll.isEmpty()) {      
            if (!fetchDataSet.containsKey('Title1__c')) {
                fetchDataSet.put('Title1__c',new Map<ID,sObject>());
            }
            
            for (Title__c title:[select id,Network_of_Air_Date__c,EIDR__c,name,(Select id,name,Platform__c,Territory__c,Rights_End_Date__c,Rights_Start_Date__c,
                                                                                Rights__c from Rights__r), (Select id, name,TVD_SAFE_Production_ID__c, Version_EIDR__c from TM_Versions__r where Original_Flag__c = TRUE) 
                                 from Title__c where id IN:setTitleIDAll]) {
                                     fetchDataSet.get('Title1__c').put(title.ID, title);  
                                 }
            
            set<String>titleIdSet = new set<String>();
            for (Id title : setTitleIDAll) {
                if (title != null) {
                    String s = String.valueOf(title).substring(0,15);
                    titleIdSet.add(s);
                }                
            }      
            
            set<Id> releaseSet = new set<Id>();
            // query product versions associated to the title            
            for (Product_Version__c pv:[SELECT ID,Product_Title__c,Product_Release__c FROM Product_Version__c where Product_Title__c IN:titleIdSet]) {
                releaseSet.add(pv.Product_Release__c);               
            }
            
            if (!releaseSet.isEmpty()) {
                bundleReleaseList=[SELECT ID,CreatedDate,US_Bundle_Avail_Date__c,CA_Bundle_Avail_Date__c,CA_Bundle_Pre_Purchase_Date__c,
                                   US_Bundle_Pre_Purchase_Date__c FROM Digital_Release__c where id in:releaseSet and RecordTypeId=:BundleRecTypeId];
                        }
            
            //1381
            if(!seriesDigiReleaseList.isEmpty()){
                seriesDigiReleaseMap = new Map<id, digital_release__C>([select id, (select id, Scripted_Reality__c, Categorization__c,
                                                                                    //Network_of_Air__c  DFOR-1578
                                                                                    US_Network_of_Air__c,
                                                                                    //Network_Categorization__c DFOR-1578 DFOR-1095 CA_Network_of_Air__c
                                                                                    US_Network_Categorization__c,CA_Network_of_Air__c,
                                                                                    TV_Studio__c from digital_releases__r) from digital_release__c where id in : seriesDigiReleaseList]);
            } 
        }
        
        //getting all date field for digital release object
        if (mapDateField.isEmpty()) {
            for (Schema.SObjectField field : Digital_Release__c.getSobjectType().getDescribe().fields.getMap().values()) {
                if (Schema.DisplayType.DATE == field.getDescribe().getType()) {
                    mapDateField.put(field.getDescribe().getName(),field.getDescribe().getLabel());
                }
            }
        }
        if (!fetchDataSet.containsKey('Digital_Release__c')){
            fetchDataSet.put('Digital_Release__c',new Map<ID,sObject>());
        }       
        if(!setSeriesDigitalReleaseId.isEmpty()){
            for (Digital_Release__c dg : [select id,Scripted_Reality__c , categorization__c ,
                                          //Network_of_Air__c DFOR-1578 DFOR-1095 CA_Network_of_Air__c
                                          US_Network_of_Air__c ,CA_Network_of_Air__c, 
                                          //Network_Categorization__c DFOR-1578
                                          US_Network_Categorization__c , 
                                          TV_Studio__c , of_Seasons__c , of_Eps_in_Season_without_Bonus__c,
                                          (select id,Scripted_Reality__c , categorization__c ,
                                           //Network_of_Air__c DFOR-1578
                                           US_Network_of_Air__c ,
                                           // Network_Categorization__c DFOR-1578 DFOR-1095 CA_Network_of_Air__c
                                           US_Network_Categorization__c ,CA_Network_of_Air__c,
                                           TV_Studio__c , of_Seasons__c , of_Eps_in_Season_without_Bonus__c From Digital_Releases__r 
                                           WHERE RecordtypeId =: TVRecTypeId)
                                          From Digital_Release__c where id in:setSeriesDigitalReleaseId ]) {
                                              fetchDataSet.get('Digital_Release__c').put(dg.ID, dg);
                                          } 
            
            result = [SELECT Count(ID) cnt , SUM(of_Eps_in_Season_without_Bonus__c) summ , Series_Name__c seriesId FROM Digital_Release__c Where Series_Name__c  IN : setSeriesDigitalReleaseId AND Season_Type__c =: DGF_Constants.MAIN Group By Series_Name__c ];  
            
            for(AggregateResult ar : result)  {
                aggregateCountMap.put((Id)ar.get('seriesId'), (Decimal)ar.get('cnt'));
                aggregateSumMap.put((Id)ar.get('seriesId'), (Decimal)ar.get('summ')) ;
            }
            
        }
        if (!fetchDataSet.containsKey('Account')) {
            fetchDataSet.put('Account',new Map<ID,sObject>());
        }
        //query for all accounts with Digital Partner RecordType
        for(Account acc : [SELECT ID, RecordTypeId, Pre_order__c, Territory__c, RecordType.Name, Categorization__c, Scripted_Reality__c, Network_Categorization__c, Bonus__c FROM Account where 
                           RecordTypeId =:AccRecTypeId ]) {
                               fetchDataSet.get('Account').put(acc.ID, acc);
                           }
        //Fetch parent release values for Series when Release created from Parent.
        
        if(!setTVReleaseParentIds.isEmpty()){
            if (!fetchDataSet.containsKey('Series_Parent')){
                fetchDataSet.put('Series_Parent',new Map<ID,sObject>());
            } 
            
            for(Digital_Release__c dg : [select id, Name, TV_Studio__c,
                                         //Network_of_Air__c DFOR-1578
                                         US_Network_of_Air__c ,
                                         //Network_Categorization__c DFOR-1578 DFOR-1095CA_Network_of_Air__c
                                         US_Network_Categorization__c ,CA_Network_of_Air__c from Digital_Release__c where id in: setTVReleaseParentIds]){
                                             fetchDataSet.get('Series_Parent').put(dg.ID, dg);
                                         }
        }
        
    }
    
    /***********************************
Method Name: getProductPricingList
Purpose: return list of pricing records for product
***********************************/ 
    public Static List<Pricing__c> getProductPricingList(Id productId) {
        List<Pricing__c> productPricingList = new List<Pricing__c>();
        List<Pricing__c> pricingList = fetchDataSet.get('ProductPricing').values();
        for(Pricing__c price: pricingList) {
            if(price.Product__c == productId ) {
                productPricingList.add(price);
            }
        }
        return productPricingList;
    }
    
    /***********************************
Method Name: commitDataSet
Purpose: Method for performing DML operations
***********************************/
    @testVisible private static void commitDataSet() {       
        if(!deleteProdAccList.isEmpty()) {
            delete deleteProdAccList;
        }
        //for deleting records
        if (!deleteableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : deleteableDataSet.keySet()) {
                
                //getting list to delete
                List<SObject> dataSet = deleteableDataSet.get(sobjectApi);
                
                if (sobjectApi == 'Digital_Date__c') {
                    DGF_SystemModeUtility objSystemVar = new DGF_SystemModeUtility();
                    objSystemVar.deleteDigitalDateRecords(dataSet);
                }                
                //deleting records
                else if (!dataSet.isEmpty()) {
                    delete dataSet;
                }
            }
        }
        
        //for inserting records
        if (!insertableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                List<SObject> dataSet = insertableDataSet.get(sobjectApi);
                //inserting records
                if (!dataSet.isEmpty()) {
                    //database.insert(dataSet,false);
                    try {
                        insert dataset;
                    }
                    catch (DMLException de) {
                        Trigger.New[0].addError(de.getDMLMessage(0));
                    }
                    catch (Exception ex) {
                        Trigger.New[0].addError(ex.getMessage());
                    }
                }
            }
        }
        
        //for updating records
        if (!updateableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : updateableDataSet.keySet()) {    
                
                // getting list to update            
                Map<Id, SObject> dataSet = updateableDataSet.get(sobjectApi);
                
                //updating records
                if (!dataSet.isEmpty()) {
                    try {
                        update dataSet.values();
                    }
                    catch (DMLException de) {
                        Trigger.New[0].addError(de.getDMLMessage(0));
                    }
                    catch (Exception ex) {
                        Trigger.New[0].addError(ex.getMessage());
                    }                   
                }
            }
        }
    }
    
    /***********************************
Method Name: executeOnBeforeInsert
Purpose:Should execute only for before insert event
***********************************/    
    public static void executeOnBeforeInsert() {
        System.debug('Inside executeOnBeforeInsert');
        
        //first iteration over trigger.new to create collections
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            //creating a set og digital release ID
            if (!setTitleId.contains(dg.title__c)) {
                setTitleId.add(dg.title__c);
            }
            
            //default iTunes price dates from physical street date for US/CA 
            if (dg.RecordTypeId == FilmRecTypeId) { //DFOR-1259
                dg.US_iTunes_Price_Date__c = dg.US_Physical_Street_Date__c!=null ? dg.US_Physical_Street_Date__c : dg.US_EST_Date__c!=null ? dg.US_EST_Date__c : null;
                dg.CA_iTunes_Price_Date__c = dg.CA_Physical_Street_Date__c!=null ? dg.CA_Physical_Street_Date__c : dg.CA_EST_Date__c!=null ? dg.CA_EST_Date__c : null;
                
                //DFOR - 1442
                dg.US_Suppression_Lift_Date__c = dg.US_Digital_PIN_Date__c!=null? dg.US_Digital_PIN_Date__c : null;
                dg.CA_Suppression_Lift_Date__c = dg.CA_Digital_PIN_Date__c!=null? dg.CA_Digital_PIN_Date__c : null;
                
                //DFOR-31 -  Set the value of Hotel Rights Checkbox
                if (dg.US_Launch_VOD_Categorization__c == 'Catalog') {
                    dg.hotel_rights__c = false;                    
                }
                
                if (!dg.hotel_rights__c) {
                    dg.US_Hotel_Start_Date__c = null;
                    dg.US_Hotel_End_Date__c = null;
                    dg.CA_Hotel_End_Date__c = null;
                    dg.CA_Hotel_Start_Date__c = null;
                }
                
                 //DFOR-1620
                if(dg.CA_Release__c != NULL && dg.CA_VOD_Start_Date__c!=null) {
                    //dg.CA_Launch_VOD_Categorization__c = 'Current';
                    dg.CA_Launch_VOD_Categorization__c = dg.US_Launch_VOD_Categorization__c;
                    dg.CA_Active_VOD_Categorization__c = dg.US_Active_VOD_Categorization__c;
                    
                }
            }
            //Gathering ParentRecIds from child to getData if Release created from Action Button.
            if(dg.RecordTypeId == TVRecTypeId){
                setTVReleaseParentIds.add(dg.Series_Name__c);
            }
            
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) { 
            System.debug('Inside executeOnBeforeInsert Digital_Release__c 2nd iteration');
            calculateReleaseDates(dg,null);
            defaultPrimaryAndSecondaryDistributors(dg);
            
            if (dg.Release_State__c == 'Cancelled') {
                dg.visibility__c = 'Draft';
            }
            
            if (dg.Release_State__c == 'Inactive' ) {
                dg.visibility__c = 'Visible';
            }
            
            //validating rights
            if (dg.recordTypeId == FilmRecTypeId && dg.Title__c != null) {
                validateRights(dg);
            }
            else if (dg.RecordTypeID == TVRecTypeId && dg.Title__c != null && dg.US_Network_of_Air__c!= null) {
                defaultNetworkCategorization(dg);
            }
            //DFOR-1258 - Season Pass            
            if(dg.RecordTypeID == TVRecTypeId) {
                //DFOR-1378  Auto Populate Release Name.
                if(dg.Series_Name__c!=null && dg.Season__c!=null){ 
                    digital_release__c seriesRelease = (digital_release__c) fetchDataSet.get('Series_Parent').get(dg.Series_Name__c);
                    dg.name = seriesRelease.Name + ' - Season ' + dg.Season__c;
                }
                
                if(dg.categorization__c != null) { 
                    if(dg.categorization__c == 'Current') {
                        dg.season_pass__c = true;
                    }
                    else if(dg.categorization__c == 'Library' || dg.categorization__c == 'Hybrid') {
                        dg.season_pass__c = false;
                    }
                }
            }
            //populate child TV records from SeriesParent
            if(dg.RecordTypeId == TVRecTypeId && dg.Create_From_Parent__c == true){
                Digital_Release__C seriesRelease = new  Digital_Release__C();
                seriesRelease = (Digital_Release__C)fetchDataSet.get('Series_Parent').get(dg.Series_Name__c);
                //dg.Network_Categorization__c = seriesRelease.Network_Categorization__c; DFOR-1578
                dg.US_Network_Categorization__c = seriesRelease.US_Network_Categorization__c; 
                //dg.Network_of_Air__c = seriesRelease.Network_of_Air__c; DFOR-1578 DFOr-1095 CA_Network_of_Air__c
                dg.US_Network_of_Air__c = seriesRelease.US_Network_of_Air__c;
                dg.CA_Network_of_Air__c = seriesRelease.CA_Network_of_Air__c; 
                dg.TV_Studio__c = seriesRelease.TV_Studio__c;
            }          
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
Method Name: createTVSeriesforFirstSeason
Purpose:DFOR-1380 - 
***********************************/    
    
    public static void evalSeriesCreationForFirstSeasonRec(Map<id, Digital_Release__c> titleDGMap){
        Map<id, Digital_Release__c> childParentMap =  new Map<id, Digital_Release__c>();
        list<Digital_Release__c> seriesCreateList =  new list<Digital_Release__c>();
        map<id, id> childParentTitleMap =  new map<id, id>();  
        set<id> parentIdSet =  new set <id>();   
        list<Digital_Release__c> updateTVDigiRelease =   new List<Digital_Release__c>();
        
        List<title__C> titleList = [select id, Parent_Title__c from Title__c where id in :titleDGMap.keyset()];
        
        if(!titleList.isEmpty()){
            for(title__C childtitle: titleList){
                childParentTitleMap.put(childtitle.id, childtitle.Parent_Title__c);
            }   
        }
        
        List<digital_Release__c> seriesReleaseList = [select id, title__c from digital_release__c where title__c in :childParentTitleMap.values()];
                if(!seriesReleaseList.isEmpty()){
            for(digital_Release__c series: seriesReleaseList){
                parentIdSet.add(series.title__c);
            }
        }      
        
        for(Digital_Release__c dg: titleDGMap.values()){
            if(!parentIdSet.contains(childParentTitleMap.get(dg.title__c))){
                digital_Release__c parentRelease = new digital_Release__c();
                parentRelease = createSeriesForSeasonRec(dg, childParentTitleMap);
                childParentMap.put(dg.id, parentRelease);
            }
        }
        
        if(childParentMap!=null && childParentMap.size()>0){
            try{
                Database.Upsert (childParentMap.values());
            }catch(Exception e){
                System.debug('Exception creating parent Series for the Child TV Record' + e.getMessage());
            }        
            
            List<digital_release__c> childDigiReleases = new List<digital_release__c>();
            
            for(Id dgId : childParentMap.keySet())
                childDigiReleases.add(new digital_release__c(Id=dgId, Series_Name__c = childParentMap.get(dgId).Id));
            
            if(!childDigiReleases.isEmpty())
                Database.update(childDigiReleases);
            
        }
        
    }
    
    public static Digital_Release__c createSeriesForSeasonRec(Digital_Release__c dg, map<id,id> childParentTitleMap){
        Digital_Release__c seriesRelease = new Digital_Release__c();
        
        seriesRelease.name = dg.name.contains('-')? dg.name.substringbefore('-') : dg.name;
        seriesRelease.title__c = childParentTitleMap.get(dg.title__c);
        seriesRelease.Scripted_Reality__c = dg.Scripted_Reality__c;
        seriesRelease.Categorization__c = dg.Categorization__c;
        //seriesRelease.Network_of_Air__c = dg.Network_of_Air__c; DFOR-1578
        seriesRelease.US_Network_of_Air__c = dg.US_Network_of_Air__c;
        // seriesRelease.Network_Categorization__c = dg.Network_Categorization__c; DFOR-1578
        seriesRelease.US_Network_Categorization__c = dg.US_Network_Categorization__c; 
        seriesRelease.TV_Studio__c = dg.TV_Studio__c;        
        seriesRelease.RecordTypeId = SeriesRecTypeId;
        System.debug('Enter into One?');
        return seriesRelease; 
    }
    
    
    /*****************DFOR-1380 END *************************/
    
    /***********************************
Method Name: defaultNetworkCategorization
Purpose:DFOR-158 - default Network Categorization
***********************************/ 
    public static void defaultNetworkCategorization(Digital_Release__c dg) {
        
        //if map does not contains key then return
        if (!fetchDataSet.containsKey('Title__c') || !fetchDataSet.get('Title__c').containsKey(dg.Title__c)) {
            return;
        }   
        
        //getting title instance
        Title__c ttl = (Title__c)fetchDataSet.get('Title__c').get(dg.Title__c);
        Map<String,DGF_Network_Categorization__c> networkOfCategMap = DGF_Network_Categorization__c.getAll();
        DGF_Network_Categorization__c networkCateg;
        
        //if Initial Release Year is less than 2000 then set the categorization to 'Library'
        if ((ttl.Initial_Release_Air_Year__c != null && Integer.valueOf(ttl.Initial_Release_Air_Year__c) < 2000 && Integer.valueOf(ttl.Initial_Release_Air_Year__c) > 0)) {
            dg.US_Network_Categorization__c = 'Library';
        }
        
        //setting the value of Network Categorization based on Network of Air
        else if ((ttl.Initial_Release_Air_Year__c != null && (Integer.valueOf(ttl.Initial_Release_Air_Year__c) == 0 || Integer.valueOf(ttl.Initial_Release_Air_Year__c) >= 2000))
                 || ttl.Initial_Release_Air_Year__c == ''  ||  ttl.Initial_Release_Air_Year__c == null) {
                     //if (networkOfCategMap.containsKey(dg.Network_of_Air__c)) DFOR-1578
                     if (networkOfCategMap.containsKey(dg.US_Network_of_Air__c)) {
                         //networkCateg = networkOfCategMap.get(dg.Network_of_Air__c); DFOR-1578
                         networkCateg = networkOfCategMap.get(dg.US_Network_of_Air__c);
                         //dg.Network_Categorization__c = networkCateg.name; DFOR-1578
                         dg.US_Network_Categorization__c = networkCateg.name;
                     }
                     else {
                         //dg.Network_Categorization__c = 'Off-Network Studio';
                         dg.US_Network_Categorization__c = 'Off-Network Studio';
                     }
                 }        
    }
    
    /***********************************
Method Name: executeOnAfterInsert
Purpose:Should execute only for after insert event
***********************************/    
    public static void executeOnAfterInsert() {
        
        //first iteration over trigger.new to create collections
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            if (dg.recordTypeId==TVRecTypeId && dg.title__c != null) {
                setTitleId.add(dg.title__c);
            }
            
            //creating a set of digital release ID
            if (!setTitleIDAll.contains(dg.title__c) && dg.title__c != null) {
                setTitleIDAll.add(dg.title__c);
            }
            
            if(dg.RecordTypeId == TVRecTypeId && dg.Season_Type__c == DGF_Constants.MAIN && dg.Series_Name__c != null){
                setSeriesDigitalReleaseId.add(dg.Series_Name__c);                
            }
            
        }   
        
        //fetching data set for processing
        getDataSet();
        // DGF_TriggerUtility.runOnce = TRUE;
        //second iteration over Trigger.New for actual iteration
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            
            //DFOR-250-update the title associated to the TV Release
            // DFOR-1578 Replaced Network_of_Air__c,Network_Categorization__c with US_Network_of_Air__c,US_Network_Categorization__c for Digital Release Object Only
            if (dg.recordTypeiD == TVRecTypeId && dg.title__c != null) {
                if (dg.TV_Studio__c != null || dg.US_Network_of_Air__c != null || dg.US_Network_Categorization__c!= null || dg.Season_On_Air_Premiere_Date__c != null || dg.Day_of_Week__c != null) {
                    updateTVTitle(dg.title__c,dg.TV_Studio__c,dg.US_Network_of_Air__c,dg.US_Network_Categorization__c,dg.Season_On_Air_Premiere_Date__c,dg.Day_of_Week__c);
                }
            }
            
            //method to create digital date records
            if (dg.RecordtypeId != CompRecTypeId) {
                createDigitalDates(dg);
            }
            //create Pre Order Product - DFOR-263
            if(dg.RecordtypeId == FilmRecTypeId && dg.US_EPO_Date__c != null) {
                createPreOrderProduct(dg);
            }
            
            //for film/tv digital release automatically create products
            if ((dg.RecordtypeId == FilmRecTypeId || dg.RecordtypeId == TVRecTypeId) && dg.Title__c != null) {
                system.debug('==============');
                createProducts(dg);
                
            }
            if (dg.RecordTypeId == TVRecTypeId && dg.Season_Type__c == DGF_Constants.MAIN && dg.Series_Name__c != null) {
                //if(DGF_TriggerUtility.runOnce){
                updateSeriesDigitalRelease(dg);       
                //}
            }
            
            system.debug('dg.RecordTypeId====='+dg.RecordTypeId);
            system.debug('dg.Series_Name__c====='+dg.Series_Name__c);
            //12-7-2018
            
            system.debug('dg.Season__c====='+dg.Season__c);
            system.debug('dg.title__c====='+dg.title__c);
            system.debug('dg.RecordTypeId====='+dg.RecordTypeId);
            // If TV-Season1 Create SeriesRec  - DFOR 1381
            if(dg.RecordTypeId == TVRecTypeId && dg.Series_Name__c==null && dg.Season__c!=null && dg.title__c!=null &&
               (dg.Season__c.equalsIgnoreCase('1')||dg.Season__c.equalsIgnoreCase('Vol.1'))){
                   tvTitleReleaseMap.put(dg.title__c, dg); 
               }
            
        }
        
        evalSeriesCreationForFirstSeasonRec(tvTitleReleaseMap); 
        
        //DFOR-1381 END
        
        //performing DML
        commitDataSet();  
        
        //create product versions for automatically created products
        createProductVersions();    
        
        
        
        
        
        
        //clear data set
        resetDataSet(); 
    }
    
    /***********************************
Method Name: createPreOrderProduct
Purpose:DFOR-263 method to create pre order product
***********************************/    
    public static void createPreOrderProduct(Digital_Release__c dg) {
        Product__c prod = new Product__c (Name = dg.name+' Pre-Order' , RecordTypeId = PreOrderProdRecTypeId , Digital_Release__c = dg.id);
        
        //getting title details
        if (dg.Title__c != null) { //DFOR-1507
            Title__c ttl = (Title__c)fetchDataSet.get('Title1__c').get(dg.Title__c);
            prod.L1_EIDR__c = ttl.EIDR__c;
            //if original TM Version present on Title  DFOR - 1470
            if(!ttl.TM_Versions__r.isEmpty()) {
                TM_Version__c tmv = ttl.TM_Versions__r[0];                
                prod.Product_ID__c = tmv.TVD_SAFE_Production_ID__c;
                prod.EIDR__c = tmv.Version_EIDR__c;
            }
        }
        //adding product instance to map
        if (!insertableDataSet.containsKey('Product__c')) {
            insertableDataSet.put('Product__c',new List<sObject>());
        }
        
        //adding details to insertable data set
        insertableDataSet.get('Product__c').add(prod); 
        
        //boolean variable to identify if we need to create product version records // //1498 - Need for Sync from TMVersion
        DGF_TriggerUtility.isProductCreatedAutomatically = TRUE;
    }
    
    /***********************************
Method Name: deletePreOrderProduct
Purpose:DFOR-263 method to delete pre order product
***********************************/    
    private static void deletePreOrderProduct (Product__c prod) {
        if(fetchDataSet.containsKey('Product__c')) {
            sobject obj = fetchDataSet.get('Product__c').get(prod.id) ;
            Product__c prd = (Product__c)obj;
            for(Product_Account__c pa : prd.Product_Account__r) {
                deleteProdAccList.add(pa);
            }
            
        }
        if (!deleteableDataSet.containsKey('Product__c')) {
            deleteableDataSet.put('Product__c', new List<SObject>());
        }
        deleteableDataSet.get('Product__c').add(prod);  
    }
    
    /***********************************
Method Name: updateTVTitle
Purpose:DFOR-250 method to update fields on Title associated to TV Release
***********************************/    
    public static void updateTVTitle(Id titleId,String TVStudio,String networkOfAir,String NetworkCateg,Date seasonPreDate,String dow) {
        
        if (fetchDataSet.containsKey('Title__c') && fetchDataSet.get('Title__c') != null) {
            
            if (fetchDataSet.get('Title__c').containsKey(titleId)) {
                
                //get the title to be updated
                Title__c title = (Title__c)fetchDataSet.get('Title__c').get(titleId);
                title.TV_Studio__c = TVStudio;
                title.Network_of_Air__c = networkOfAir;
                title.Network_Categorization__c = NetworkCateg;
                title.Network_of_Air_Date__c = seasonPreDate;
                title.Day_of_Week__c = dow;
                
                //add it to the updateable dataset
                if (updateableDataSet.containsKey('Title__c')) {
                    Map<Id,SObject> updateMap = updateableDataSet.get('Title__c');
                    updateMap.put(title.id,title);                    
                }
                else {
                    Map<Id,SObject> updateMap = new map<Id,sobject>();
                    updateMap.put(title.id,title);
                    updateableDataSet.put('Title__c',updateMap);
                }
            }
        }
    }
    
    /***********************************
Method Name: executeOnBeforeUpdate
Purpose:Should execute only for before update event
***********************************/    
    public static void executeOnBeforeUpdate() {
        
        //first iteration over trigger.new to create collections
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            
            //creating a set og digital release ID
            if (!setTitleId.contains(dg.title__c)) {
                setTitleId.add(dg.title__c);
            }
            
            if (!setDigitalReleaseId.contains(dg.ID)) {
                setDigitalReleaseId.add(dg.ID);
            }
            
            //default iTunes price dates from physical street date for US/CA
            if (dg.RecordTypeId == FilmRecTypeId) {
                dgOld = (Digital_Release__c)Trigger.oldMap.get(dg.Id);
                if(dg.CA_release__c != null) {
                    dg.CA_Launch_VOD_Categorization__c = dg.US_Launch_VOD_Categorization__c;
                      // 1/10/2019
                    dg.CA_Active_VOD_Categorization__c = dg.US_Active_VOD_Categorization__c;  
                }   //DFOR-1259
                if ((dg.US_iTunes_Price_Date__c == null && dg.US_Physical_Street_Date__c!=null) && (dgOld.US_Physical_Street_Date__c != dg.US_Physical_Street_Date__c)) {
                    dg.US_iTunes_Price_Date__c = dg.US_Physical_Street_Date__c;
                }else if((dg.US_iTunes_Price_Date__c == null && dg.US_EST_Date__c!=null) && (dgOld.US_EST_Date__c != dg.US_EST_Date__c)){
                    dg.US_iTunes_Price_Date__c = dg.US_EST_Date__c;
                }
                
                if ((dg.CA_iTunes_Price_Date__c == null && dg.CA_Physical_Street_Date__c!=null) && (dgOld.CA_Physical_Street_Date__c != dg.CA_Physical_Street_Date__c)) {
                    dg.CA_iTunes_Price_Date__c = dg.CA_Physical_Street_Date__c;
                }else if((dg.CA_iTunes_Price_Date__c == null && dg.CA_EST_Date__c!=null) && (dgOld.CA_EST_Date__c != dg.CA_EST_Date__c)){
                    dg.CA_iTunes_Price_Date__c = dg.CA_EST_Date__c;
                }
                
                //DFOR-1442
                if(dgOld.US_Digital_PIN_Date__c != dg.US_Digital_PIN_Date__c){
                    dg.US_Suppression_Lift_Date__c = dg.US_Digital_PIN_Date__c;
                }
                if(dgOld.CA_Digital_PIN_Date__c != dg.CA_Digital_PIN_Date__c){
                    dg.CA_Suppression_Lift_Date__c = dg.CA_Digital_PIN_Date__c;
                }
                
                //DFOR-31 -  Set the value of Hotel Rights Checkbox
                if (dg.US_Launch_VOD_Categorization__c == 'Catalog') {
                    dg.hotel_rights__c = false;                    
                }
                
                if (!dg.hotel_rights__c) {
                    dg.US_Hotel_Start_Date__c = null;
                    dg.US_Hotel_End_Date__c = null;
                    dg.CA_Hotel_End_Date__c = null;
                    dg.CA_Hotel_Start_Date__c = null;
                }                
            }   
            
        }   
        
        //fetching data set for processing  
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
            
            if (dg.Release_State__c == 'Cancelled') {
                dg.visibility__c = 'Draft';
            }
            
            if (dg.Release_State__c == 'Inactive' ) {
                dg.visibility__c = 'Visible';
            }
            
            //validating rights
            if (dg.recordTypeId == FilmRecTypeId && dg.Title__c != null) {                
                Boolean isExecuted = FALSE;
                
                //looping over all date field to check if any on them is changed 
                for (string strAPI : mapDateField.keySet()) {
                    if (dg.get(strAPI) != dgOld.get(strAPI) && !isExecuted) {
                        validateRights(dg);
                        isExecuted = TRUE;
                        DGF_TriggerUtility.isChatterPostRequired = TRUE;                        
                    }                   
                }                
            }
            else if (dg.RecordTypeID == TVRecTypeId && dg.Title__c != null && dg.US_Network_of_Air__c != dgOld.US_Network_of_Air__c) {
                defaultNetworkCategorization(dg);
            }
            
            //method to calculate release dates
            if ((dgOld.US_EST_Date__c != dg.US_EST_Date__c && dg.US_EPO_Date__c == NULL) || (dgOld.CA_EST_Date__c != dg.CA_EST_Date__c && dg.CA_EPO_Date__c == NULL)) {
                if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c') != null) {
                    for (sobject pr:fetchDataSet.get('Product__c').values()) {
                        Product__c prod = (Product__c)pr;
                        if (prod.Digital_Release__c == dg.id) {
                            list<Pricing__c> pricinglist = getProductPricingList(prod.Id);
                            if (!pricinglist.isEmpty()) {
                                for (Pricing__c price : pricinglist) {
                                    if (price.territory__c == DGF_Constants.TERRITORY_US && dgOld.US_EST_Date__c != dg.US_EST_Date__c && dg.US_EPO_Date__c == NULL) {
                                        if (price.valid_to__c != null && dg.US_EST_Date__c > price.valid_to__c && price.platform__c == DGF_Constants.PLATFORM_EST ) {
                                            dg.addError(DGF_Constants.DGF_US_EST_Date_Validation);
                                            continue;
                                        }
                                    }
                                    else if (price.territory__c == DGF_Constants.TERRITORY_CA && dgOld.CA_EST_Date__c != dg.CA_EST_Date__c && dg.CA_EPO_Date__c == NULL) {
                                        if (price.valid_to__c != null && dg.CA_EST_Date__c > price.valid_to__c && price.platform__c == DGF_Constants.PLATFORM_EST  ) {
                                            dg.addError(DGF_Constants.DGF_CA_EST_Date_Validation);
                                            continue;
                                        }
                                    }                                    
                                }
                            }
                        }
                    }
                }
            }
            
            if ((dgOld.US_EPO_Date__c != dg.US_EPO_Date__c && dg.US_EPO_Date__c != NULL) || (dgOld.CA_EPO_Date__c != dg.CA_EPO_Date__c && dg.CA_EPO_Date__c != NULL)) {
                if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c') != null) {
                    for (sobject pr : fetchDataSet.get('Product__c').values()) {
                        Product__c prod = (Product__c)pr;
                        if (prod.Digital_Release__c == dg.id) {
                            list<Pricing__c> pricingList = getProductPricingList(prod.Id);
                            if (!pricingList.isEmpty()) {
                                for (Pricing__c price : pricingList) {
                                    if (price.territory__c == DGF_Constants.TERRITORY_US && dgOld.US_EPO_Date__c != dg.US_EPO_Date__c && dg.US_EPO_Date__c != NULL) {
                                        if (price.valid_to__c != null && dg.US_EPO_Date__c > price.valid_to__c && price.platform__c == DGF_Constants.PLATFORM_EST && price.Price_Type__c == DGF_Constants.ORIGINAL ) {
                                            dg.addError(DGF_Constants.DGF_US_Pre_Order_Date_Validation);
                                            continue;
                                        }
                                    }
                                    else if (price.territory__c == DGF_Constants.TERRITORY_CA && dgOld.CA_EPO_Date__c != dg.CA_EPO_Date__c && dg.CA_EPO_Date__c != NULL) {
                                        if (price.valid_to__C != null && dg.CA_EPO_Date__c > price.valid_to__c && price.platform__c == DGF_Constants.PLATFORM_EST  && price.Price_Type__c == DGF_Constants.ORIGINAL) {
                                            dg.addError(DGF_Constants.DGF_CA_Pre_Order_Date_Validation);
                                            continue;
                                        }
                                    }                                    
                                }
                            }
                        }
                    }
                }
            }
            //DFOR-1258- Season Pass
            if(dg.recordTypeId ==TVRecTypeId) {
                if(dg.categorization__c != null && dgOld.Categorization__c != dg.categorization__c) {
                    if(dg.categorization__c == 'Current') {
                        dg.season_pass__c = true;
                    }
                    else if(dg.categorization__c == 'Library' || dg.categorization__c == 'Hybrid') {
                        dg.season_pass__c = false;
                    }
                }
            }
            
            //method to auto-calculate release dates
            calculateReleaseDates(dg,dgOld);
            
            if (dgOld.US_Tertiary_Distributor__c != dg.US_Tertiary_Distributor__c || dgOld.CA_Tertiary_Distributor__c != dg.CA_Tertiary_Distributor__c) { //USST-3115
                defaultPrimaryAndSecondaryDistributors(dg);                
            }
            
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
Method Name: calculateReleaseDates
Purpose:Method to auto calculate release dates -DFOR-39
***********************************/    
    public static void calculateReleaseDates(Digital_Release__c dg,Digital_Release__c digOld) {
        
        //calculation of dates for film recordtype
        if (dg.RecordTypeId==FilmRecTypeId || dg.recordTypeId==CompRecTypeId ) {
            
            //calculate US VOD Start date            
            if ( dg.US_Release__c == NULL && ((digOld == null && dg.US_VOD_Start_Date__c == null) || (digOld != null && dg.US_VOD_Start_Date__c == digOld.US_VOD_Start_Date__c && 
                                                                                                      dg.US_Physical_Street_Date__c != digOld.US_Physical_Street_Date__c))) {
                                                                                                          //auto calculate US VOD Dates if US VOD Rights are present
                                                                                                          dg.US_VOD_Start_Date__c = dg.US_Physical_Street_Date__c;
                                                                                                      }
            
            //calculate US VOD End date
            if ((digOld == null && dg.US_VOD_End_Date__c == null)|| (digOld != null && dg.US_VOD_End_Date__c == digOld.US_VOD_End_Date__c 
                                                                     && dg.US_VOD_Start_Date__c != digOld.US_VOD_Start_Date__c)) {
                                                                         //auto calculate US VOD Dates if US VOD Rights are present                
                                                                         dg.US_VOD_End_Date__c = (dg.US_VOD_Start_Date__c != NULL) ? dg.US_VOD_Start_Date__c + 120 : NULL;
                                                                     }
            
            //calculate US EST Date
            if ( dg.US_Release__c == NULL && ((digOld == null && dg.US_EST_Date__c == null) || (digOld != null && dg.US_EST_Date__c == digOld.US_EST_Date__c && dg.US_VOD_Start_Date__c != digOld.US_VOD_Start_Date__c))) {
                //auto calculate US EST  Dates if US VOD Rights are present                
                dg.US_EST_Date__c = (dg.US_VOD_Start_Date__c != NULL ) ? dg.US_VOD_Start_Date__c - 14 : NULL;                
            }
            
            //calculate US EPO Date for different values to Tertiary distriutor            
            if (dg.US_Release__c == NULL && ((digOld == null && dg.US_EPO_Date__c == null) || (digOld != null && dg.US_EPO_Date__c == digOld.US_EPO_Date__c && 
                                                                                               (dg.US_Theatrical_Release_Date__c != digOld.US_Theatrical_Release_Date__c || dg.US_Tertiary_Distributor__c != digold.US_Tertiary_Distributor__c || 
                                                                                                dg.US_Product_Type__c != digOld.US_Product_Type__c)))) {
                                                                                                    if (dg.US_Tertiary_Distributor__c == 'Universal' || dg.US_Tertiary_Distributor__c == 'Pure' ||  dg.US_Tertiary_Distributor__c == 'Blumhouse' || 
                                                                                                        dg.US_Tertiary_Distributor__c == 'GKIDs' || dg.US_Tertiary_Distributor__c == 'Gramercy' || dg.US_Tertiary_Distributor__c == 'Film Arcade, LLC' || 
                                                                                                        dg.US_Tertiary_Distributor__c == 'Legendary' || dg.US_Tertiary_Distributor__c == 'STX Entertainment' || dg.US_Tertiary_Distributor__c == 'Bleecker St.' || 
                                                                                                        dg.US_Tertiary_Distributor__c == 'Picturehouse') {
                                                                                                            if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL ) {                        
                                                                                                                dg.US_EPO_Date__c = dg.US_Theatrical_Release_Date__c;
                                                                                                            }
                                                                                                            else {
                                                                                                                dg.US_EPO_Date__c = null;
                                                                                                            }
                                                                                                        }
                                                                                                    
                                                                                                    if (dg.US_Tertiary_Distributor__c == 'Focus'  ) {
                                                                                                        if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL ) {                        
                                                                                                            dg.US_EPO_Date__c = dg.US_Theatrical_Release_Date__c;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.US_EPO_Date__c = null;
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                    if (dg.US_Tertiary_Distributor__c == 'Open Road' ) {
                                                                                                        if ( dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL ) {                        
                                                                                                            dg.US_EPO_Date__c = (dg.US_Theatrical_Release_Date__c!=NULL ) ? dg.US_Theatrical_Release_Date__c + 21 : NULL;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.US_EPO_Date__c = null;
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                    if (dg.US_Tertiary_Distributor__c == 'Focus World' ) {
                                                                                                        if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL) {                        
                                                                                                            dg.US_EPO_Date__c = (dg.US_Theatrical_Release_Date__c != NULL) ? dg.US_Theatrical_Release_Date__c - 28 : NULL;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.US_EPO_Date__c = null;
                                                                                                        }       
                                                                                                    }                
                                                                                                }  
            
            if (dg.US_Release__c == NULL && ((digOld == null && dg.US_EPO_Date__c == null) || (digOld != null && dg.US_EPO_Date__c == digOld.US_EPO_Date__c && (dg.US_EST_Date__c != digOld.US_EST_Date__c || 
                                                                                                                                                                dg.US_Tertiary_Distributor__c != digold.US_Tertiary_Distributor__c || dg.US_Product_Type__c != digOld.US_Product_Type__c)))) {
                                                                                                                                                                    if (dg.US_Tertiary_Distributor__c == 'Mattel' ) {
                                                                                                                                                                        if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL ) {                        
                                                                                                                                                                            dg.US_EPO_Date__c = (dg.US_EST_Date__c != NULL ) ? dg.US_EST_Date__c - 28 : NULL;
                                                                                                                                                                        }
                                                                                                                                                                        else {
                                                                                                                                                                            dg.US_EPO_Date__c = null;
                                                                                                                                                                        }
                                                                                                                                                                    }
                                                                                                                                                                } 
            
            //calculate CA VOD Start Date
            if (dg.CA_Release__c == NULL && ((digOld == null && dg.CA_VOD_Start_Date__c == null) || (digOld != null && dg.CA_VOD_Start_Date__c == digOld.CA_VOD_Start_Date__c && 
                                                                                                     dg.CA_Physical_Street_Date__c != digOld.CA_Physical_Street_Date__c))) {                
                                                                                                         dg.CA_VOD_Start_Date__c = dg.CA_Physical_Street_Date__c;                
                                                                                                     }
            
            //calculate CA VOD End Date
            if ((digOld == null && dg.CA_VOD_End_Date__c == null) || (digOld != null && dg.CA_VOD_End_Date__c == digOld.CA_VOD_End_Date__c && 
                                                                      dg.CA_VOD_Start_Date__c != digOld.CA_VOD_Start_Date__c)) {                
                                                                          dg.CA_VOD_End_Date__c = (dg.CA_VOD_Start_Date__c != NULL ) ? dg.CA_VOD_Start_Date__c + 120 : NULL;                
                                                                      }
            
            //calculate CA EST Date
            if (dg.CA_Release__c == NULL && ((digOld == null && dg.CA_EST_Date__c == null) || (digOld != null && dg.CA_EST_Date__c == digOld.CA_EST_Date__c && dg.CA_VOD_Start_Date__c != digOld.CA_VOD_Start_Date__c))) {                
                dg.CA_EST_Date__c = (dg.CA_VOD_Start_Date__c != NULL ) ? dg.CA_VOD_Start_Date__c - 14 : NULL;                
            }
            
            if (dg.CA_Release__c == NULL && ((digOld == null && dg.CA_EPO_Date__c == null) || (digOld != null && dg.CA_EPO_Date__c == digOld.CA_EPO_Date__c  && 
                                                                                               (digOld.CA_Theatrical_Release_Date__c != dg.CA_Theatrical_Release_Date__c || dg.CA_Tertiary_Distributor__c != digOld.CA_Tertiary_Distributor__c || 
                                                                                                dg.CA_Product_Type__c != digOld.CA_Product_Type__c)))) {
                                                                                                    if (dg.CA_Tertiary_Distributor__c == 'Universal' || dg.CA_Tertiary_Distributor__c == 'Pure' ||  dg.CA_Tertiary_Distributor__c == 'Blumhouse' || 
                                                                                                        dg.CA_Tertiary_Distributor__c == 'GKIDs' || dg.CA_Tertiary_Distributor__c == 'Gramercy' || dg.CA_Tertiary_Distributor__c == 'Film Arcade, LLC' || 
                                                                                                        dg.CA_Tertiary_Distributor__c == 'Legendary' || dg.CA_Tertiary_Distributor__c == 'STX Entertainment' || dg.CA_Tertiary_Distributor__c == 'Bleecker St.' || 
                                                                                                        dg.CA_Tertiary_Distributor__c == 'Picturehouse' ) {
                                                                                                            if (dg.CA_Product_Type__c == 'Theatrical') {                        
                                                                                                                dg.CA_EPO_Date__c = dg.CA_Theatrical_Release_Date__c;
                                                                                                            }
                                                                                                            else {
                                                                                                                dg.CA_EPO_Date__c = null;
                                                                                                            }
                                                                                                        }
                                                                                                    
                                                                                                    if (dg.CA_Tertiary_Distributor__c == 'Focus' ) {
                                                                                                        if (dg.CA_Product_Type__c == 'Theatrical') {                        
                                                                                                            dg.CA_EPO_Date__c = dg.CA_Theatrical_Release_Date__c;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.CA_EPO_Date__c = null;
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                    if (dg.CA_Tertiary_Distributor__c == 'Open Road' ) {
                                                                                                        if ( dg.CA_Product_Type__c == 'Theatrical') {
                                                                                                            dg.CA_EPO_Date__c = (dg.CA_Theatrical_Release_Date__c!=NULL ) ? dg.CA_Theatrical_Release_Date__c + 21 : NULL;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.CA_EPO_Date__c = null;
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                    if (dg.CA_Tertiary_Distributor__c == 'Focus World' ) {
                                                                                                        if (dg.CA_Product_Type__c == 'Theatrical') {                        
                                                                                                            dg.CA_EPO_Date__c = (dg.CA_Theatrical_Release_Date__c != NULL ) ? dg.CA_Theatrical_Release_Date__c - 28 : NULL;
                                                                                                        }
                                                                                                        else {
                                                                                                            dg.CA_EPO_Date__c = null;
                                                                                                        }
                                                                                                    }                
                                                                                                }    
            
            if ((dg.CA_Release__c == NULL && (digOld == null && dg.CA_EPO_Date__c == null) || (digOld != null && dg.CA_EPO_Date__c == digOld.CA_EPO_Date__c  && (digOld.CA_EST_Date__c != dg.CA_EST_Date__c|| 
                                                                                                                                                                 dg.CA_Tertiary_Distributor__c != digOld.CA_Tertiary_Distributor__c || dg.CA_Product_Type__c != digOld.CA_Product_Type__c)))) {
                                                                                                                                                                     if (dg.CA_Tertiary_Distributor__c == 'Mattel') {
                                                                                                                                                                         if (dg.CA_Product_Type__c == 'Theatrical') {                        
                                                                                                                                                                             dg.CA_EPO_Date__c = (dg.CA_EST_Date__c != NULL) ? dg.CA_EST_Date__c - 28 : NULL;
                                                                                                                                                                         }
                                                                                                                                                                         else {
                                                                                                                                                                             dg.CA_EPO_Date__c = null;
                                                                                                                                                                         }
                                                                                                                                                                     }
                                                                                                                                                                 }
            
            //calculate US Hotel Start Date
            //DFOR-31 Calculate Hotel and Disc to digital Dates only for Film Releases
            if (dg.RecordTypeId == FilmRecTypeId) {
                if (((digOld == null && dg.US_Hotel_Start_Date__c == null) || (digOld != null && dg.US_Hotel_Start_Date__c == digOld.US_Hotel_Start_Date__c)) && dg.Hotel_Rights__c) {
                    if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL) {
                        if (digold == null) {
                            dg.US_Hotel_Start_Date__c = (dg.US_Theatrical_Release_Date__c != NULL ) ? dg.US_Theatrical_Release_Date__c + 52 : null;
                        }
                        else {
                            if (dg.US_Theatrical_Release_Date__c != digOld.US_Theatrical_Release_Date__c || dg.US_Product_Type__c != digold.US_Product_Type__c || 
                                dg.Hotel_Rights__c != digold.Hotel_Rights__c) {
                                    dg.US_Hotel_Start_Date__c = (dg.US_Theatrical_Release_Date__c != NULL ) ? dg.US_Theatrical_Release_Date__c + 52 : null;
                                }
                        }
                    }
                    else if (dg.US_Product_Type__c == DGF_Constants.PRODUCT_DIRECT_TO_VIDEO) {
                        if (digold == null) {
                            dg.US_Hotel_Start_Date__c = dg.US_VOD_Start_Date__c;
                        }
                        else {
                            if (dg.US_VOD_Start_Date__c != digOld.US_VOD_Start_Date__c  || dg.US_Product_Type__c != digold.US_Product_Type__c || dg.Hotel_Rights__c != digold.Hotel_Rights__c) {
                                dg.US_Hotel_Start_Date__c = dg.US_VOD_Start_Date__c;
                            }
                        }
                    }
                }
                
                //calculate CA Hotel Start Date
                if (((digOld == null && dg.CA_Hotel_Start_Date__c == null) || (digOld != null && dg.CA_Hotel_Start_Date__c == digOld.CA_Hotel_Start_Date__c)) && dg.Hotel_Rights__c) {
                    if (dg.CA_Product_Type__c == DGF_Constants.PRODUCT_THEATRICAL) {
                        if (digOld == null) {
                            dg.CA_Hotel_Start_Date__c = (dg.CA_Theatrical_Release_Date__c != NULL ) ? dg.CA_Theatrical_Release_Date__c + 52 : NULL;
                        }
                        else {
                            if (dg.CA_Theatrical_Release_Date__c != digOld.CA_Theatrical_Release_Date__c || dg.CA_Product_Type__c != digOld.CA_Product_Type__c || 
                                dg.Hotel_Rights__c != digold.Hotel_Rights__c) {
                                    dg.CA_Hotel_Start_Date__c = (dg.CA_Theatrical_Release_Date__c != NULL ) ? dg.CA_Theatrical_Release_Date__c + 52 : NULL;
                                }
                        }
                    }
                    else if (dg.CA_Product_Type__c == DGF_Constants.PRODUCT_DIRECT_TO_VIDEO) {
                        if (digOld == null) {
                            dg.CA_Hotel_Start_Date__c = dg.CA_VOD_Start_Date__c;
                        }
                        else {
                            if (dg.CA_VOD_Start_Date__c != digold.CA_VOD_Start_Date__c || dg.CA_Product_Type__c != digOld.CA_Product_Type__c || 
                                dg.Hotel_Rights__c != digold.Hotel_Rights__c) {
                                    dg.CA_Hotel_Start_Date__c = dg.CA_VOD_Start_Date__c;
                                }
                        }
                    }
                }
                
                //calculate CA Hotel End Date
                if (((digOld == null && dg.CA_Hotel_End_Date__c == null) || (digOld != null && dg.CA_Hotel_End_Date__c == digOld.CA_Hotel_End_Date__c && 
                                                                             (dg.CA_VOD_End_Date__c != digold.CA_VOD_End_Date__c || dg.Hotel_Rights__c != digold.Hotel_Rights__c))) && dg.Hotel_Rights__c) {
                                                                                 dg.CA_Hotel_End_Date__c = dg.CA_VOD_End_Date__c;
                                                                             }
                
                //calculate US Hotel End Date
                if (((digOld == null && dg.US_Hotel_End_Date__c == null)|| (digOld != null && dg.US_Hotel_End_Date__c == digOld.US_Hotel_End_Date__c && 
                                                                            (dg.US_VOD_End_Date__c != digOld.US_VOD_End_Date__c || dg.Hotel_Rights__c != digold.Hotel_Rights__c))) && dg.Hotel_Rights__c) {
                                                                                dg.US_Hotel_End_Date__c = dg.US_VOD_End_Date__c;
                                                                            }
                
                //calculate US Disc to Digital Date
                if ((digOld == null && dg.US_Disc_to_Digital_Date__c == null) || (digOld != null && dg.US_Disc_to_Digital_Date__c == digOld.US_Disc_to_Digital_Date__c 
                                                                                  && dg.US_EST_Date__c != digOld.US_EST_Date__c)) {
                                                                                      dg.US_Disc_to_Digital_Date__c = (dg.US_EST_Date__c != NULL) ? dg.US_EST_Date__c + 365 : NULL;
                                                                                  }
                
                //calculate CA Disc to digital Date
                if ((digOld == null && dg.CA_Disc_to_Digital_Date__c == null) || (digOld != null && dg.CA_Disc_to_Digital_Date__c == digOld.CA_Disc_to_Digital_Date__c &&
                                                                                  dg.CA_EST_Date__c != digOld.CA_EST_Date__c)) {
                                                                                      dg.CA_Disc_to_Digital_Date__c = (dg.CA_EST_Date__c != NULL) ? dg.CA_EST_Date__c + 365 : NULL;
                                                                                  }
            }
            
        }        
    }
    
    /***********************************
Method Name: executeOnAfterUpdate
Purpose:Should execute only for after update event
***********************************/    
    public static void executeOnAfterUpdate() {
        map<Id,Product_Account__c> prodAccUpdateMap =  new map<Id,Product_Account__c>();   
        map<Id,Pricing__c> pricingUpdateMap = new map<Id,Pricing__c>();
        map<Id,Promotion__c> promoUpdateMap = new map<Id,Promotion__c> ();
        set<Id> prodIdSet = new set<Id>();
        list<Product__c>prodList = new list<Product__c>();
        list<sobject>prodAccList =  new list<sobject>();
        list<sobject>bonusAccList =  new list<sobject>();
         list<Pricing__c> insertTVpricingList = new list<Pricing__c>();
        set<id> tvDigitalRecIdSet = new set<id>();  
        set<id> tvDigitalRecIdSetDel = new set<id>(); 
        
        // below lines of code is added on 10-05-2018 -DFOR-1526
        Boolean recordTypeChanged = false;
        Boolean recordTypeCFChanged = false;
        String recType = '';
        set<Id> drIdSet = new set<Id>();
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {            
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);            
            recType = dg.RecordtypeId;
            //for competitive digital release automatically delete products
            if (dgOld.RecordtypeId == FilmRecTypeId && dg.RecordtypeId == CompRecTypeId){
                drIdSet.add(dg.Id);
                recordTypeChanged = true;                
            }            
            if (dgOld.RecordtypeId == CompRecTypeId && dg.RecordtypeId == FilmRecTypeId){
                recordTypeCFChanged = true;
                drIdSet.add(dg.Id);
                if (!setDigitalReleaseId.contains(dg.ID)) {
                    setDigitalReleaseId.add(dg.ID);
                }
                if (!setTitleIDAll.contains(dg.title__c) && dg.title__c!=null) {
                    setTitleIDAll.add(dg.title__c);
                }
            }
        }
        if(recordTypeChanged == true)
        {
            
            if(drIdSet!=null && drIdSet.size()>0)
            {
                deleteRecords(drIdSet);
            }
        }
        
        if(recordTypeCFChanged == true)
        {           
            executeOnAfterInsert();               
            //st<EPO_Bonus__c> lstBs = [SELECT Id, Package__c FROM EPO_Bonus__c WHERE Digital_Release__c IN: drIdSet];
            List<Digital_Release__c> digitalrelasebouns = [select id ,name from Digital_Release__c where Id IN : drIdSet];            
            List<EPO_Bonus__c> bonuslist = new List<EPO_Bonus__c>();
            if(digitalrelasebouns!=null && digitalrelasebouns.size()>0)
            {
                for(Digital_Release__c dr: digitalrelasebouns){
                    
                    EPO_Bonus__c creatBonus = new EPO_Bonus__c();
                    creatBonus.Name= 'iTunes Extras Package';
                    creatBonus.RecordTypeId = BonusFilmRecTypeId; 
                    creatBonus.Platform__c = 'EST';                    
                    creatBonus.Package__c= 'iTunes Extras';
                    creatBonus.Digital_Release__c = dr.Id;
                    bonuslist.add(creatBonus);
                }                
            }
            if(bonuslist !=null && bonuslist.size()>0) {
                insert bonuslist;
            }
            
            
        }
        
        // above lines of code is added on 10-05-2018 for DFOR-1526 ****
        
        //first iteration over trigger.new to create collections
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            //creating a set og digital release ID
            if (!setDigitalReleaseId.contains(dg.ID)) {
                setDigitalReleaseId.add(dg.ID);
            }
            
            if (dg.recordTypeId==TVRecTypeId && dg.title__c!=null) {
                setTitleId.add(dg.title__c);
            }
            
            //creating a set og digital release ID
            if (!setTitleIDAll.contains(dg.title__c) && dg.title__c!=null) {
                setTitleIDAll.add(dg.title__c);
            }
            
            if (dg.RecordTypeId == TVRecTypeId && dg.Season_Type__c == DGF_Constants.MAIN && dg.Series_Name__c != null || (dgOld.Season_Type__c == DGF_Constants.MAIN && dg.Season_Type__c != DGF_Constants.MAIN  )){
                setSeriesDigitalReleaseId.add(dg.Series_Name__c);
            }
            
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
            //1381
            //DFOR-1578 Repalced Network_of_Air__c,Network_Categorization__c with US_Network_of_Air__c,US_Network_Categorization__c on Digital Release Object.
            if(dg.RecordTypeId == SeriesRecTypeId && dg.title__c!=null &&
               (dg.CA_Network_of_Air__c != dgOld.CA_Network_of_Air__c || dg.Scripted_Reality__c != dgOld.Scripted_Reality__c || dg.Categorization__c != dgOld.Categorization__c || dg.US_Network_of_Air__c != dgOld.US_Network_of_Air__c || dg.US_Network_Categorization__c != dgOld.US_Network_Categorization__c ||  dg.TV_Studio__c != dgOld.TV_Studio__c)){
                   
                   seriesDigiReleaseList.add(dg.id);
               }
        }   
        
        //fetching data set for processing
        getDataSet();    
        
        if (fetchDataSet != null && fetchDataSet.get('Digital_Date__c') != null) {
            
            for (sobject digiDate:fetchDataSet.get('Digital_Date__c').values()) {
                Digital_Date__c digDate=(Digital_date__c)digiDate;
                digitalDateMap.put(digDate.Digital_Release__c+':'+digDate.Date_API_Name__c,digDate);
            }            
        }
        // DGF_TriggerUtility.runOnce = TRUE;
        //second iteration over Trigger.New for actual iteration
        for (Digital_Release__c dg : (List<Digital_Release__c>)trigger.new) {
            
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
            
            //for film/tv digital release automatically create products
            if ((dg.RecordtypeId == FilmRecTypeId || dg.RecordtypeId == TVRecTypeId) && dg.Title__c != null && 
                dg.Title__c != dgOld.Title__c) {
                    //DFOR-1472
                    System.debug('Executing this code');
                    boolean prodExists = false;
                    Digital_Release__c dgProd = (Digital_Release__c) fetchDataSet.get('Digital_Release__c').get(dg.id);             
                    Title__c ttl = (Title__c)fetchDataSet.get('Title1__c').get(dg.Title__c);
                    if(dgProd.Products__r!=null && dgProd.Products__r.size()>0){ 
                        for(product__c prod: dgProd.products__r){
                            if( dg.RecordtypeId == FilmRecTypeId  && ttl.name.equalsIgnoreCase(prod.name)){
                                prodExists = true;
                            }else if(dg.RecordtypeId == TVRecTypeId && dg.name.equalsIgnoreCase(prod.name)){
                                prodExists = true;
                            }
                        }
                    }
                    if(!prodExists) createProducts(dg);
                }
            
            //calling method to update resolutions
            if (dg.HD__c != dgOld.HD__c || dg.SD__c != dgOld.SD__c || dg.UHD__c != dgOld.UHD__c || dg.X3D__c != dgOld.X3D__c) {
                updateProductResolution(dg);
            }
            
            
            //update/delete the digital date records when the date fields are updated
            if (dg.RecordtypeId != CompRecTypeId) {
                for (string strAPI : mapDateField.keySet()) {
                    if (dg.get(strAPI) != NULL) {
                        updateDigitalDate(dg,strAPI,Date.valueOf(dg.get(strAPI)));
                    }  
                    else if (dg.get(strAPI) == NULL) {
                        deleteDigitalDate(dg,strAPI);
                    }
                }       
            }
            
            //for film recordType
            if (dg.RecordTypeId == FilmRecTypeId) {
                if (dgOld.US_EST_Date__c != dg.US_EST_Date__c) {
                    updateBonusDates(dg,DGF_Constants.PLATFORM_EST);
                    if (!bundleReleaseList.isEmpty()) {
                        updateBundleReleaseDates(bundleReleaseList,'US EST Date',dg.createdDate,dg.US_EST_Date__c);
                    }
                }
                
                if (dgOld.US_EPO_Date__c != dg.US_EPO_Date__c) {
                    //Update Product Account Pre-Order Date when the US Pre order date is changed
                    if(fetchDataSet.containsKey('Product__c')) {
                        for(Sobject prod: fetchDataSet.get('Product__c').values()) {
                            Product__c prd = (Product__c)prod;
                            if(prd.digital_release__c == dg.id && prd.recordTypeId == PreOrderProdRecTypeId && dg.US_EPO_Date__c != null) {
                                for(Product_Account__c pa : prd.Product_Account__r) {
                                    pa.Pre_Order_Date__c = dg.US_EPO_Date__c;
                                    prodAccUpdateMap.put(pa.id,pa);
                                }
                            }
                        }
                    }
                    
                    updateBonusDates(dg,'Pre-Order');
                    if (!bundleReleaseList.isEmpty()) {
                        updateBundleReleaseDates(bundleReleaseList,'US EPO Date',dg.createdDate,dg.US_EPO_Date__c);
                    }  
                    // if US PreOrder Date is populated then create PreOrder Product
                    if(dgOld.US_EPO_Date__c == null && dg.US_EPO_Date__c != null) {
                        if (dgOld.RecordtypeId != CompRecTypeId && dg.RecordtypeId != FilmRecTypeId){
                            createPreOrderProduct(dg);
                        }
                        
                    }
                    
                }
                
                if (dgOld.US_VOD_Start_Date__c != dg.US_VOD_Start_Date__c) {
                    updateBonusDates(dg,DGF_Constants.PLATFORM_VOD);
                }
                
                if (dgOld.CA_EST_Date__c != dg.CA_EST_Date__c) {
                    if(!bundleReleaseList.isEmpty()){
                        updateBundleReleaseDates(bundleReleaseList,'CA EST Date',dg.createdDate,dg.CA_EST_Date__c);
                    }
                }
                
                if (dgOld.CA_EPO_Date__c != dg.CA_EPO_Date__c) {
                    if(!bundleReleaseList.isEmpty()){
                        updateBundleReleaseDates(bundleReleaseList,'CA EPO Date',dg.createdDate,dg.CA_EPO_Date__c);
                    }
                }
                
                //if there are products associated to the release
                if (fetchDataSet != null && fetchDataSet.get('Product__c') != null) {
                    for (sobject pr:fetchDataSet.get('Product__c').values()) {
                        Product__c prod = (Product__c)pr;
                        if (prod.Digital_Release__c == dg.id) {
                            //dfor-263 - Delete Pre order products
                            if( dg.US_EPO_Date__c == null && dgOld.US_EPO_Date__c != null) {
                                if(prod.recordTypeId == PreOrderProdRecTypeId) {
                                    deletePreOrderProduct(prod);
                                }
                            }
                            if (dg.US_Launch_VOD_Categorization__c != dgold.US_Launch_VOD_Categorization__c) {
                                updateProductVODTier(prod,DGF_Constants.TERRITORY_US,dg.US_Launch_VOD_Categorization__c);
                            }
                            
                            if (dg.CA_Launch_VOD_Categorization__c != dgOld.CA_Launch_VOD_Categorization__c) {
                                updateProductVODTier(prod,DGF_Constants.TERRITORY_CA,dg.CA_Launch_VOD_Categorization__c);
                            }
                            
                            list<Pricing__c>pricingList = getProductPricingList(prod.Id);
                            if (!pricingList.isEmpty() && prod.recordTypeId == prodFilmRecTypeId) {
                                //if there are pricing records for thr products
                                for (Pricing__c price:pricingList) {
                                    
                                    boolean validUHDDate = false;  //If Original and UHD for EST Platform Retain date from New to UHD EST -  DFOR 1375
                                    
                                    //UHD, Original, EST  - US
                                    if('Original'.equalsIgnoreCase(price.Price_Type__c) &&  'UHD'.equalsIgnoreCase(price.Resolution__c) && price.Platform__c == DGF_Constants.PLATFORM_EST){                                        
                                        if(price.Territory__c == DGF_Constants.TERRITORY_US){ //US
                                            if(dg.New_to_UHD_US_EST_Release_Date__c != null){
                                                validUHDDate = true;
                                                if(dg.New_to_UHD_US_EST_Release_Date__c != dgOld.New_to_UHD_US_EST_Release_Date__c){
                                                    updatePricingRecord(price,dg.New_to_UHD_US_EST_Release_Date__c,'validFrom');
                                                }  
                                            }else{
                                                if(dg.New_to_UHD_US_EST_Release_Date__c != dgOld.New_to_UHD_US_EST_Release_Date__c){
                                                    if(dg.US_EPO_Date__c==null){
                                                        updatePricingRecord(price,dg.US_EST_Date__c,'validFrom');
                                                    }else{
                                                        updatePricingRecord(price,dg.US_EPO_Date__c,'validFrom');
                                                    }
                                                }
                                            }      
                                            
                                        }else if(price.Territory__c == DGF_Constants.TERRITORY_CA){ //CA
                                            if(dg.New_to_UHD_CA_EST_Release_Date__c != null){
                                                validUHDDate = true;
                                                if(dg.New_to_UHD_CA_EST_Release_Date__c != dgOld.New_to_UHD_CA_EST_Release_Date__c){                                            
                                                    updatePricingRecord(price,dg.New_to_UHD_CA_EST_Release_Date__c,'validFrom');
                                                }  
                                            }else{
                                                if(dg.New_to_UHD_CA_EST_Release_Date__c != dgOld.New_to_UHD_CA_EST_Release_Date__c){
                                                    if(dg.CA_EPO_Date__c==null){
                                                        updatePricingRecord(price,dg.CA_EST_Date__c,'validFrom');
                                                    }else{
                                                        updatePricingRecord(price,dg.CA_EPO_Date__c,'validFrom');
                                                    }
                                                }
                                            }
                                            
                                        }                                                                   
                                    }
                                    
                                    
                                    
                                    //update pricing record on change of US Pre order date
                                    if ( !validUHDDate && dg.US_EPO_Date__c != null && dg.US_EPO_Date__c != dgOld.US_EPO_Date__c) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_EST && price.Territory__c == DGF_Constants.TERRITORY_US) {
                                            updatePricingRecord(price,dg.US_EPO_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of CA Pre order date
                                    if (!validUHDDate && dg.CA_EPO_Date__c != null && dg.CA_EPO_Date__c != dgOld.CA_EPO_Date__c) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_EST && price.Territory__c == DGF_Constants.TERRITORY_CA) {
                                            updatePricingRecord(price,dg.CA_EPO_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of US Pre order date to null
                                    if (!validUHDDate && ((dg.US_EPO_Date__c == null && dgOld.US_EPO_Date__c != null) || (dg.US_EST_Date__c != dgOld.US_EST_Date__c && dg.US_EPO_Date__c == null))) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_EST && price.Territory__c == DGF_Constants.TERRITORY_US) {
                                            updatePricingRecord(price,dg.US_EST_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of CA Pre order date to null
                                    if (!validUHDDate && ((dg.CA_EPO_Date__c == null && dgOld.CA_EPO_Date__c != null) || (dg.CA_EST_Date__c != dgOld.CA_EST_Date__c && dg.CA_EPO_Date__c == null))) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_EST && price.Territory__c == DGF_Constants.TERRITORY_CA) {
                                            updatePricingRecord(price,dg.CA_EST_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of US VOD Start Date
                                    if (dg.US_VOD_Start_Date__c!=dgOld.US_VOD_Start_Date__c ) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_US) {
                                            updatePricingRecord(price,dg.US_VOD_Start_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of CA VOD Start Date
                                    if (dg.CA_VOD_Start_Date__c!=dgOld.CA_VOD_Start_Date__c ) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_CA) {
                                            updatePricingRecord(price,dg.CA_VOD_Start_Date__c,'validFrom');
                                        }
                                    }
                                    
                                    //update pricing record on change of US VOD End Date
                                    if (dg.US_VOD_End_Date__c != dgOld.US_VOD_End_Date__c ) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_US) {
                                            updatePricingRecord(price,dg.US_VOD_End_Date__c,'validTo');
                                        }
                                    }
                                    
                                    //update pricing record on change of CA VOD End Date
                                    if (dg.CA_VOD_End_Date__c!=dgOld.CA_VOD_End_Date__c ) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_CA) {
                                            updatePricingRecord(price,dg.CA_VOD_End_Date__c,'validTo');
                                        }
                                    }
                                    
                                    
                                    //update pricing record on change of US Launch Categorization
                                    if (dg.US_Launch_VOD_Categorization__c != dgOld.US_Launch_VOD_Categorization__c) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_US) {                                            
                                            deleteProductPricing( price);
                                        }
                                        
                                        if (dg.US_Launch_VOD_Categorization__c != null ) {
                                            prodIdSet.add(prod.id);
                                        }
                                    }
                                    
                                    //update pricing record on change of CA Launch Categorization
                                    if (dg.CA_Launch_VOD_Categorization__c != dgOld.CA_Launch_VOD_Categorization__c) {
                                        if (price.Price_Type__c == 'Original' && price.Platform__c == DGF_Constants.PLATFORM_VOD && price.Territory__c == DGF_Constants.TERRITORY_CA) {
                                            deleteProductPricing(price);
                                        }
                                        
                                        if (dg.CA_Launch_VOD_Categorization__c != null) {
                                            prodIdSet.add(prod.id);
                                        }
                                    }
                                }
                            }
                        } 
                    }                   
                }
            }
            
            if (dg.RecordTypeId==TVRecTypeId) {
                
                //DFOR-250
                if (dg.title__c!=null) {
                    //update the Title associated to the TV Release
                    //DFOR-1578 Replaced Network of Air and Network Categorization with Us Network of Air and US NetworkCategorization on Digital Release object
                    if (dg.TV_Studio__c != null || dg.US_Network_of_Air__c != null || dg.US_Network_Categorization__c != null || dg.Season_On_Air_Premiere_Date__c 
                        != null || dg.Day_of_Week__c != null) {
                            //updateTVTitle(dg.title__c, dg.TV_Studio__c, dg.Network_of_Air__c, dg.Network_Categorization__c, dg.Season_On_Air_Premiere_Date__c, dg.Day_of_Week__c); DFOR-1578
                            updateTVTitle(dg.title__c, dg.TV_Studio__c, dg.US_Network_of_Air__c, dg.US_Network_Categorization__c, dg.Season_On_Air_Premiere_Date__c, dg.Day_of_Week__c);
                        }
                }
                
                if(fetchDataSet.containsKey('EPO_Bonus__c') && fetchDataSet.get('EPO_Bonus__c') != null) {
                    for(sobject obj : fetchDataset.get('EPO_Bonus__c').values()) {
                        EPO_Bonus__c bonus =(EPO_Bonus__c)obj;
                        if(bonus.Digital_Release__c == dg.Id) {
                            //if(!bonus.Bonus_Account__r.isEmpty()) {
                            ////DFOR-1578 Replaced Network of Air and Network Categorization with Us Network of Air and US NetworkCategorization on Digital Release object
                            if(dg.Categorization__c !=dgOld.Categorization__c || dg.Scripted_Reality__c != dgOld.Scripted_Reality__c || dg.US_Network_Categorization__c != dgOld.US_Network_Categorization__c ) {
                                for(Bonus_Account__c ba: bonus.Bonus_Account__r) {
                                    if (!deleteableDataSet.containsKey('Bonus_Account__c')) {
                                        deleteableDataSet.put('Bonus_Account__c', new List<SObject>());
                                    }
                                    deleteableDataSet.get('Bonus_Account__c').add(ba);  
                                }
                                if(fetchDataSet.containsKey('Account')) {
                                    list<sobject>accList = fetchDataSet.get('Account').values();
                                    bonusAccList = DGF_DigitalReleaseTriggerHelper.createBonusAccounts(dg,bonus,accList);
                                }
                            }
                            //}
                        }
                    }
                }
                 
                //dfor-168
                if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c')!=null) {
                    for (sobject pr:fetchDataSet.get('Product__c').values()) {
                        Product__c prod=(Product__c)pr;
                        boolean caPriceDateUpdated = false;
                        if (prod.Digital_Release__c == dg.id) {
                            system.debug('===dg.==='+dg.Clone_pricing_records_from_last_season__c);
                            system.debug('===prod.Id==='+prod.Id);
                            
                            list<Pricing__c>pricingList = getProductPricingList(prod.Id);
                            if (!pricingList.isEmpty() && prod.recordTypeId == ProdTVRecTypeId) {
                                for (Pricing__c price :pricingList) {
                                    if ((dg.CA_EST_Launch_Date__c != null && dgOld.CA_EST_Launch_Date__c != dg.CA_EST_Launch_Date__c) || (dg.US_EST_Launch_Date__c !=null 
                                                                                                                                          && dgOld.US_EST_Launch_Date__c != dg.US_EST_Launch_Date__c)) {
                                                                                                                                              if (price.price_type__c == 'Original') {
                                                                                                                                                  if ((dg.CA_EST_Launch_Date__c != null && dgOld.CA_EST_Launch_Date__c != dg.CA_EST_Launch_Date__c) && price.territory__c == DGF_Constants.TERRITORY_CA) {
                                                                                                                                                      price.Valid_From__c = dg.CA_EST_Launch_Date__c;
                                                                                                                                                      pricingUpdateMap.put(price.id,price);
                                                                                                                                                       caPriceDateUpdated = true;
                                                                                                                                                  }
                                                                                                                                                  
                                                                                                                                                  if ((dg.US_EST_Launch_Date__c != null && dgOld.US_EST_Launch_Date__c != dg.US_EST_Launch_Date__c) && price.territory__c == DGF_Constants.TERRITORY_US) {
                                                                                                                                                      price.Valid_From__c = dg.US_EST_Launch_Date__c;
                                                                                                                                                      pricingUpdateMap.put(price.id,price);
                                                                                                                                                  }
                                                                                                                                              }
                                                                                                                                          }
                                }
                                 if(caPriceDateUpdated)createFeedItem('The CA Valid From Dates have been updated',dg.id);
                            }
                            //DFOR-153
                            if(!prod.Product_Account__r.isEmpty()) {
                                for (Product_Account__c pa : prod.Product_Account__r) {
                                    //DFOR-1310  
                                    if(dg.Categorization__c !=dgOld.Categorization__c || dg.Scripted_Reality__c != dgOld.Scripted_Reality__c || dg.US_Network_Categorization__c != dgOld.US_Network_Categorization__c ) {
                                        if (!deleteableDataSet.containsKey('Product_Account__c')) {
                                            deleteableDataSet.put('Product_Account__c', new List<SObject>());
                                        }
                                        deleteableDataSet.get('Product_Account__c').add(pa);  
                                        if(fetchDataSet.containsKey('Account')) {
                                            list<sobject>accList = fetchDataSet.get('Account').values();
                                            prodAccList = DGF_DigitalReleaseTriggerHelper.createProductAccounts(dg,prod,accList);
                                        }
                                    }
                                    //DFOR-1578 Replaced Network of Air and Network Categorization with Us Network of Air and US NetworkCategorization on Digital Release object
                                    if(dg.Categorization__c ==dgOld.Categorization__c && dg.Scripted_Reality__c == dgOld.Scripted_Reality__c && dg.US_Network_Categorization__c == dgOld.US_Network_Categorization__c ) {
                                        //stamp product account launch date based on Account's territory and EST Launch Date
                                        if (( dgOld.CA_EST_Launch_Date__c != dg.CA_EST_Launch_Date__c) && pa.Account__r.territory__c == DGF_Constants.TERRITORY_CA) {
                                            pa.Launch_Date__c = dg.CA_EST_Launch_Date__c;
                                            prodAccUpdateMap.put(pa.id,pa);
                                        }
                                        if (( dgOld.US_EST_Launch_Date__c != dg.US_EST_Launch_Date__c) && pa.Account__r.territory__c == DGF_Constants.TERRITORY_US) {
                                            pa.Launch_Date__c = dg.US_EST_Launch_Date__c;
                                            prodAccUpdateMap.put(pa.id,pa);
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
                //DFOR-1097
                if(dg.Free_First_Episode_Start_Date__c != dgOld.Free_First_Episode_Start_Date__c || dg.Free_First_Episode_End_Date__c != dgOld.Free_First_Episode_End_Date__c) {
                    //sync free episode dates
                    if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c')!=null) {
                        for (sobject pr:fetchDataSet.get('Product__c').values()) {
                            Product__c prod=(Product__c)pr;
                            
                            if (prod.Digital_Release__c == dg.id) {
                                for(Promotion_Product__c promoPrd : prod.Product_Promotions__r) {
                                    if(fetchDataSet.containsKey('Promotion__c') && fetchdataSet.get('Promotion__c').containsKey(promoPrd.Promotion__c)) {
                                        sobject obj = fetchdataSet.get('Promotion__c').get(promoPrd.Promotion__c);
                                        Promotion__c promo = (Promotion__c)obj;
                                        //sync free episode start date
                                        if(dg.Free_First_Episode_Start_Date__c != dgOld.Free_First_Episode_Start_Date__c) {
                                            promo.start_Date__c = dg.Free_First_Episode_Start_Date__c;
                                            promoUpdateMap.put(promo.id,promo);
                                        }
                                        //sync free episode end date
                                        if(dg.Free_First_Episode_End_Date__c != dgOld.Free_First_Episode_End_Date__c) {
                                            promo.end_Date__c = dg.Free_First_Episode_End_Date__c;
                                            promoUpdateMap.put(promo.id,promo);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                             //DFOR - 1592
                if(dg.CA_EST_Launch_Date__c != dgOld.CA_EST_Launch_Date__c ){
                  //create pricing based of US pricing if any / update Original pricing records if present
                  if(dgOld.CA_EST_Launch_Date__c==null && dg.CA_EST_Launch_Date__c!=null){
                    //createRecordsIf they do not exist already
                    tvDigitalRecIdSet.add(dg.id); 
                  }                  
                  if(dgOld.CA_EST_Launch_Date__c!=null && dg.CA_EST_Launch_Date__c==null){
                    tvDigitalRecIdSetDel.add(dg.id);
                    if (fetchDataSet != null && fetchDataSet.get('Product__c') != null) {
                        for (sobject pr:fetchDataSet.get('Product__c').values()) {
                            Product__c prod = (Product__c)pr;
                            if (prod.Digital_Release__c == dg.id) {
                              list<Pricing__c>pricingList = getProductPricingList(prod.Id);
                                if (!pricingList.isEmpty() ) {
                                    //if there are pricing records for thr products
                                    boolean caExists = false;
                                    for (Pricing__c price:pricingList) {
                                      if(price.territory__c == DGF_Constants.TERRITORY_CA && price.category__c !=DGF_Constants.TV_EPISODE){
                                        deleteProductPricing(price);  
                                        caExists = true;
                                      }
                                        
                                    }
                                    if(caExists)createFeedItem('CA Pricing has been deleted',dg.id); 
                                }  
                            }
                        }
                    }
                  }
                }
                        }
            
            
             
            if(dg.RecordTypeId == TVRecTypeId && dg.Season_Type__c == DGF_Constants.MAIN && dg.Series_Name__c != null || 
               (dgOld.Season_Type__c == DGF_Constants.MAIN && dg.Season_Type__c != DGF_Constants.MAIN  )  ){
                   
                   updateSeriesDigitalRelease(dg);       
                   
               } 
            //dfor-1381
            if(!seriesDigiReleaseMap.isEmpty() && seriesDigiReleaseMap.containsKey(dg.id)){
                updateTVDigitalReleaseWthSeries(dg);              
            }
            //dfor-1494
            if(dg.Release_State__c!=dgOld.Release_State__c && dg.Release_State__c == DGF_Constants.CANCELLED){ 
                System.debug('delete prod account in digitrigger>>>'+ dg.id);
                if (fetchDataSet.containsKey('Product__c') && fetchDataSet.get('Product__c')!=null) {
                    for (sobject pr:fetchDataSet.get('Product__c').values()) {
                        Product__c prod=(Product__c)pr;
                        
                        if (prod.Digital_Release__c == dg.id) {
                            if(!prod.Product_Account__r.isEmpty()) {
                                for (Product_Account__c pa : prod.Product_Account__r) {                                        
                                    if (!deleteableDataSet.containsKey('Product_Account__c')) {
                                        deleteableDataSet.put('Product_Account__c', new List<SObject>());
                                    }
                                    deleteableDataSet.get('Product_Account__c').add(pa);
                                }
                            }
                            
                        }
                    }
                }                  
            }////dfor-1494 END
        }   
        
        if (updateableDataSet.containsKey('Pricing__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Pricing__c');
            for (Sobject pricing:pricingUpdateMap.values()) {
                updateMap.put(pricing.id,pricing);
            }
        }
        else{
            updateableDataSet.put('Pricing__c',pricingUpdateMap);
        }
        
        if (updateableDataSet.containsKey('Product_Account__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Product_Account__c');
            for (Sobject pa:prodAccUpdateMap.values()) {
                updateMap.put(pa.id,pa);
            }
        }
        else{
            updateableDataSet.put('Product_Account__c',prodAccUpdateMap);
        }
        
        if (updateableDataSet.containsKey('Promotion__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Promotion__c');
            for (Sobject pr:promoUpdateMap.values()) {
                updateMap.put(pr.id,pr);
            }
        }
        else{
            updateableDataSet.put('Promotion__c',promoUpdateMap);
        }
        if (insertableDataSet.containsKey('Product_Account__c')) {
            List<SObject> insertList = insertableDataSet.get('Product_Account__c');
            insertList.addAll(prodAccList);
        }
        else {
            insertableDataSet.put('Product_Account__c',prodAccList);
        }
        
        if (insertableDataSet.containsKey('Bonus_Account__c')) {
            List<SObject> insertList = insertableDataSet.get('Bonus_Account__c');
            insertList.addAll(bonusAccList);
        }
        else {
            insertableDataSet.put('Bonus_Account__c',bonusAccList);
        }
        
        //performing DML
        commitDataSet();    
        
        //creating product version
        createProductVersions();
        //createCATVPricingRecods
        if(!tvDigitalRecIdSet.isEmpty()){                    
           list<product__c> productDetailsList = [SELECT Id, Digital_Release__r.id,Digital_Release__c,
            (SELECT ID,Category__c,iTunes_Tier__c,Margin__c,Account__c, Platform__c, Price_Type__c, Product__c, 
              Resolution__c, SRP__c, Territory__c, Valid_From__c, Valid_To__c, WSP__c  FROM Pricing__r where Promotion__c = null order by Territory__c ASC)
               FROM Product__c where Digital_Release__c IN: tvDigitalRecIdSet];
               
           if(!productDetailsList.isEmpty()){
             for(product__c prod: productDetailsList){
               Digital_Release__c dg = (Digital_Release__c) trigger.newMap.get(prod.Digital_Release__c);
               List<pricing__c> caPriceList = new List<pricing__c>();
               caPriceList = DGF_DefaultProductPricing.defaultTVPricingforCAFromUS(prod, dg); 
               if(!caPriceList.isEmpty()){
                 insertTVpricingList.addAll(caPriceList);
                  createFeedItem('CA Pricing has been created to reflect current US Pricing',prod.Digital_Release__r.id); 
               }
               
             } 
           }
           
           if(!insertTVpricingList.isEmpty()){
             try {
                    upsert insertTVpricingList;
                }
                catch (DMLException de) {
                    Trigger.New[0].addError(de.getDMLMessage(0));
                }
                catch (Exception ex) {
                    Trigger.New[0].addError(ex.getMessage());
                }
           }  
           
           //iterate Map for FeedItems and Insert
           for (String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                if(sobjectApi.equalsIgnoreCase('feeditem')){
                   List<SObject> dataSet = insertableDataSet.get(sobjectApi);
                  //inserting records
                  if (!dataSet.isEmpty()) {
                      //database.insert(dataSet,false);
                      try {
                          insert dataset;
                      }
                      catch (DMLException de) {
                          Trigger.New[0].addError(de.getDMLMessage(0));
                      }
                      catch (Exception ex) {
                          Trigger.New[0].addError(ex.getMessage());
                      }
                  }  
                
                }
               
            }        
        }
        //call the createPricingrecords  method to create new pricing records
        if (!prodIdSet.isEmpty()) {
            Map<ID,Product__c> mapProductDetails = new Map<ID,Product__c>([SELECT Id, Digital_Release__c, X3D__c, HD__c, SD__c, UHD__c, US_Platform_Offering__c,
                                                                           CA_Platform_Offering__c, Digital_Release__r.US_Launch_VOD_Categorization__c,
                                                                           Digital_Release__r.CA_Launch_VOD_Categorization__c, Digital_Release__r.US_EPO_Date__c,
                                                                           Digital_Release__r.CA_EPO_Date__c, Digital_Release__r.US_EST_Date__c, EST_Tier__c, CA_EST_Tier__c,
                                                                           Digital_Release__r.CA_EST_Date__c, Digital_Release__r.US_VOD_Start_Date__c,
                                                                           Digital_Release__r.CA_VOD_Start_Date__c, Digital_Release__r.US_VOD_End_Date__c,
                                                                           Digital_Release__r.New_to_UHD_US_EST_Release_Date__c, Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,
                                                                           Digital_Release__r.CA_VOD_End_Date__c, RecordTypeId , (SELECT ID,Category__c,iTunes_Tier__c,Margin__c, 
                                                                                                                                  Platform__c, Price_Type__c, Product__c, Resolution__c, SRP__c, Territory__c, Valid_From__c, Valid_To__c, 
                                                                                                                                  WSP__c FROM Pricing__r)FROM Product__c where Digital_Release__c IN:setDigitalReleaseId]);
            if (!mapProductDetails.isEmpty()) {
                for (Id prodId : prodIdSet) {
                    if (mapProductDetails.containsKey(prodId)) {
                        prodList.add(mapProductDetails.get(prodId));
                    }
                }               
            }
            
            list<Pricing__c> pricingList = new list<Pricing__c>();
            
            DGF_TriggerUtility.isCalledFromDigitalTriggerHandler = True;
            pricingList = DGF_ProductTriggerHandler.createPricingrecords(prodList,true);
            DGF_TriggerUtility.isCalledFromDigitalTriggerHandler = False;
            
            if (!pricingList.isEmpty()) {
                try {
                    insert pricingList;
                }
                catch (DMLException de) {
                    Trigger.New[0].addError(de.getDMLMessage(0));
                }
                catch (Exception ex) {
                    Trigger.New[0].addError(ex.getMessage());
                }
            }
        }
        //clear data set
        resetDataSet();    
        
    } 
    public static void createFeedItem(string message, id prodId){      
       if (!insertableDataSet.containsKey('FeedItem')) {
                insertableDataSet.put('FeedItem', new List<sObject>());
            }
      //creating an instance of feed item
        FeedItem post = new FeedItem();
        post.ParentId = prodId; 
        post.IsRichText = TRUE;
        post.Body = message;
        insertableDataSet.get('FeedItem').add(post);
    } 
    
    
    
    
    
    /***********************************
Method Name: updateBonusDates
Purpose:method to update dates of related Bonus release-DFOR-845
***********************************/    
    public static void updateBonusDates(Digital_Release__c rel1, String dateType){
        map<Id,EPO_Bonus__c>bonusMap=new map<Id,EPO_Bonus__c>();
        
        if(!fetchDataSet.containsKey('Digital_Release__c') || !fetchDataSet.get('Digital_Release__c').containsKey(rel1.id)){
            return;
        }
        
        Digital_Release__c rel = (Digital_Release__c)fetchDataSet.get('Digital_Release__c').get(rel1.id);
        if(fetchDataSet.containsKey('EPO_Bonus__c')) {
            
            for(sobject obj : fetchDataSet.get('EPO_Bonus__c').values()){
                EPO_Bonus__c bonus = (EPO_Bonus__c)obj;
                if(bonus.Digital_Release__c == rel.Id) {
                    if(bonus.RecordTypeId != BonusFilmRecTypeId)
                        continue;
                    Set<String> PlatformValues = new Set<String>();
                    Set<String> PackageValues = new Set<String>();
                    if(bonus.Platform__c != null)
                        PlatformValues.addAll(bonus.Platform__c.split(';'));
                    if(bonus.Package__c != null)
                        PackageValues.addAll(bonus.Package__c.split(';'));
                    if(PlatformValues.contains(DGF_Constants.PLATFORM_EST) && !PackageValues.contains('Pre-Order') && dateType == DGF_Constants.PLATFORM_EST){
                        bonus.Start_Date__c = rel.US_EST_Date__c;
                        bonusMap.put(bonus.Id, bonus);
                    }
                    if(PlatformValues.contains(DGF_Constants.PLATFORM_EST) && PackageValues.contains('Pre-Order') && dateType == 'Pre-Order'){
                        bonus.Start_Date__c = rel.US_EPO_Date__c;
                        bonusMap.put(bonus.Id, bonus);
                    }
                    if(PlatformValues.contains(DGF_Constants.PLATFORM_VOD) && dateType == DGF_Constants.PLATFORM_VOD){
                        bonus.VOD_Start_Date__c = rel.US_VOD_Start_Date__c;
                        bonusMap.put(bonus.Id, bonus);
                    }
                }
            }
        }
        if(updateableDataSet.containsKey('EPO_Bonus__c')){
            Map<Id,SObject> updateMap=updateableDataSet.get('EPO_Bonus__c');
            for(Sobject bonus:bonusMap.values()){
                updateMap.put(bonus.id,bonus);
            }
        }
        else{
            updateableDataSet.put('EPO_Bonus__c',bonusMap);
        }
    }
    
    /***********************************
Method Name: updateBundleReleaseDates
Purpose:method to update dates of bundle release-DFOR-651
***********************************/    
    public static void updateBundleReleaseDates(list<Digital_Release__c>relList,String fieldToUpdate,DateTime createdDate,Date dateVal) {
        System.debug('Test--------------1');
        map<Id,Digital_Release__c>releaseMap = new map<Id,Digital_Release__c>();
        for(Digital_Release__c dg : relList){
            if(dg.createdDate > createdDate){
                if(fieldToUpdate == 'US EST Date'){
                    dg.US_Bundle_Avail_Date__c = dateval;
                    releaseMap.put(dg.id,dg);
                }
                else if (fieldToUpdate == 'US EPO Date') {
                    dg.US_Bundle_Pre_Purchase_Date__c = dateval;
                    releaseMap.put(dg.id,dg);
                }
                else if (fieldToUpdate=='CA EST Date') {
                    dg.CA_Bundle_Avail_Date__c = dateval;
                    releaseMap.put(dg.id,dg);
                }
                else if (fieldToUpdate=='CA EPO Date') {
                    dg.CA_Bundle_Pre_Purchase_Date__c = dateval;
                    releaseMap.put(dg.id,dg);
                }
            }
        }
        
        if (updateableDataSet.containsKey('Digital_Release__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Digital_Release__c');
            for (Sobject release:releaseMap.values()) {
                updateMap.put(release.id,release);
            }
        }
        else {
            
            updateableDataSet.put('Digital_Release__c',releaseMap);
        }
    }
    
    /***********************************
Method Name: updateProductVODTier
Purpose:method to update the VOD Tier on Product
***********************************/    
    public static void updateProductVODTier(Product__c prod,String territory,String categorization) {
        map<Id,Product__c> prodUpdateMap = new map<Id,Product__c>();
        
        // check for the territory and update the Product VOD Tier with the Launch Categorization value
        if (territory == DGF_Constants.TERRITORY_US) {
            prod.US_VOD_Tier__c = categorization;
            //When Categorization is null, removing VOD from US Platform offering
            if (categorization == null || categorization == '') {
                
                if (prod.US_Platform_Offering__c != NULL && prod.US_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                    prod.US_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
                }
                else {
                    prod.US_Platform_Offering__c = null;
                }
            }            
        }
        else if (territory == DGF_Constants.TERRITORY_CA) {
            prod.CA_VOD_Tier__c = categorization;
            
            //When Categorization is null, removing VOD from CA Platform offering
            if (categorization == null || categorization == '') {
                if (prod.CA_Platform_Offering__c != NULL && prod.CA_Platform_Offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                    prod.CA_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
                }
                else {
                    prod.CA_Platform_Offering__c=null;
                }
            }
        }
        
        prodUpdateMap.put(prod.id,prod);
        if (updateableDataSet.containsKey('Product__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Product__c');
            
            for (Sobject product:prodUpdateMap.values()) {
                updateMap.put(product.id,product);
            }
        }
        else {
            updateableDataSet.put('Product__c',prodUpdateMap);
        }
    }
    
    /*****************************************
Method Name: deleteProductPricing
Purpose: method for deleting Pricing record 
*****************************************/   
    public static void deleteProductPricing(Pricing__c price) {
        
        if (!deleteableDataSet.containsKey('Pricing__c')) {
            deleteableDataSet.put('Pricing__c', new List<SObject>());
        }
        deleteableDataSet.get('Pricing__c').add(price);  
    }
    
    /*****************************************
Method Name: updatePricingRecord
Purpose: method for updating Pricing records - DFOR-44
*****************************************/  
    public static void updatePricingRecord(Pricing__c price,Date dt,String fieldToUpdate) {
        map<Id,Pricing__c> pricingUpdateMap = new map<Id,Pricing__c>();
        
        //update the valid from date on the pricing record
        if (fieldToUpdate == 'validFrom') {
            price.Valid_From__c = dt;
            pricingUpdateMap.put(price.id,price);
        }
        
        //update the valid to date on the pricing record
        else if (fieldToUpdate=='validTo') {
            price.Valid_To__c = dt;
            pricingUpdateMap.put(price.id,price);
        }        
        
        if (updateableDataSet.containsKey('Pricing__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Pricing__c');
            
            for (Sobject pricing : pricingUpdateMap.values()) {
                updateMap.put(pricing.id,pricing);
            }
        }
        else {
            updateableDataSet.put('Pricing__c',pricingUpdateMap);
        }        
    }
    
    /*****************************************
Method Name: updateDigitalDate
Purpose: method for updating Digital Date record 
*****************************************/   
    public static void updateDigitalDate(Digital_Release__c dg,String api,Date dt) {
        
        list<sobject>dataToBeInsertedList = new list<sobject>();
        map<id,sobject>dataToBeUpdatedMap = new map<id,sobject>();
        
        //if no digital date record is created, then create new digital date record
        if (!digitalDateMap.containsKey(dg.id + ':' + api)) {
            Digital_Date__c digitalDate = new Digital_Date__c(Date_API_Name__c=api, Digital_Release__c=dg.id, Release_Date__c=dt,
                                                              Release_Date_Type__c=Schema.getGlobalDescribe().get('Digital_Release__c').getDescribe().fields.getMap().get(api).getDescribe().getLabel());
            dataToBeInsertedList.add(digitalDate);
        }
        //update the existing digital date record with new value
        else {
            
            Digital_Date__c digitalDate = digitalDateMap.get(dg.id + ':' + api);
            
            if (digitalDate.Release_Date__c != dt) {
                digitalDate.Release_Date__c = dt;
                dataToBeUpdatedMap.put(digitalDate.id,digitalDate);
            }                
        }
        
        //insert the new digital date record
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList = insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }
        
        //update the digital date record
        if (updateableDataSet.containsKey('Digital_Date__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Digital_Date__c');
            
            for (Sobject dd : dataToBeUpdatedMap.values()) {
                updateMap.put(dd.id,dd);
            }
        }
        else {
            updateableDataSet.put('Digital_Date__c',dataToBeUpdatedMap);
        }
    }    
    
    /*****************************************
Method Name: deleteDigitalDate
Purpose: method for deleting Digital Date record 
*****************************************/
    public static void deleteDigitalDate(Digital_Release__c dg, String api) {
        list<sobject>dataToBeDeletedList = new list<sobject>();
        
        //if a date on release is blanked out, then delete the corresponding digital date record
        if (digitalDateMap.containsKey(dg.id + ':' + api)) {
            Digital_Date__c digitalDate = digitalDateMap.get(dg.id+':'+api);
            dataToBeDeletedList.add(digitalDate);
        }
        
        if (deleteableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> deleteList = deleteableDataSet.get('Digital_Date__c');
            deleteList.addAll(dataToBeDeletedList);
        }
        else {
            deleteableDataSet.put('Digital_Date__c',dataToBeDeletedList);
        }
    }
    
    /*****************************************
Method Name: createDigitalDates
Purpose: Method to create the Digital Dates based on the updates to the Digital Release
*****************************************/   
    private static void createDigitalDates(Digital_Release__c dg) {
        list<sobject>dataToBeInsertedList = new list<sobject>();
        map<id,sobject>dataToBeUpdatedMap = new map<id,sobject>();
        list<sobject>dataToBeDeletedList = new list<sobject>();
        
        //create diital dates for film recordType        
        for (string strAPI : mapDateField.keySet()) {
            if (dg.get(strAPI) != NULL  ) {
                Digital_Date__c digitalDate = new Digital_Date__c(Date_API_Name__c=strAPI, Digital_Release__c=dg.id, Release_Date__c=Date.valueOf(dg.get(strAPI)), 
                                                                  Release_Date_Type__c=Schema.getGlobalDescribe().get('Digital_Release__c').getDescribe().fields.getMap().get(strAPI).getDescribe().getLabel());
                dataToBeInsertedList.add(digitalDate);                
            }                   
        }  
        
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList = insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }
    }
    
    /***********************************
Method Name: defaultPrimaryAndSecondaryDistributors
Purpose:Method to default Primary and Secondary Distributors -DFOR-21
***********************************/     
    public static void defaultPrimaryAndSecondaryDistributors(Digital_Release__c dg) {
        Map<String,DGF_Release_Distributors__c> distributorMap = DGF_Release_Distributors__c.getAll();
        DGF_Release_Distributors__c digitalrelease;
        
        if (dg.US_Tertiary_Distributor__c != null && distributorMap.containsKey(dg.US_Tertiary_Distributor__c)) {
            digitalrelease = distributorMap.get(dg.US_Tertiary_Distributor__c);
            dg.US_Primary_Distributor__c = digitalrelease.Primary_Distributor__c;
            dg.US_Secondary_Distributor__c = digitalrelease.Secondary_Distributor__c;
        } 
        else {
            dg.US_Primary_Distributor__c = null;
            dg.US_Secondary_Distributor__c = null;
        }  
        //USST-3115 --- start
        if (dg.CA_Tertiary_Distributor__c != null && distributorMap.containsKey(dg.CA_Tertiary_Distributor__c)) {
            digitalrelease = distributorMap.get(dg.CA_Tertiary_Distributor__c);
            dg.CA_Primary_Distributor__c = digitalrelease.Primary_Distributor__c;
            dg.CA_Secondary_Distributor__c = digitalrelease.Secondary_Distributor__c;
        } 
        else {
            dg.CA_Primary_Distributor__c = null;
            dg.CA_Secondary_Distributor__c = null;
        }    
        //USST-3115 --- end      
    }
    
    /***********************************
Method Name: defaultTVReleaseName
Purpose:Method to default name for TV release DFOR-418
***********************************/
    public static void defaultTVReleaseName(Digital_Release__c dg) {
        
        if (fetchDataSet.containsKey('Title__c') && fetchDataSet.get('Title__c').containsKey(dg.Title__c)) {
            dg.Name = ((Title__c)fetchDataSet.get('Title__c').get(dg.Title__c)).Name;
        }   
    }
    
    /***********************************
Method Name: validateRights
Purpose: validate rights of a title
***********************************/
    public static void validateRights(Digital_Release__c dg) {
        
        //if map does not contains key then return
        if (!fetchDataSet.containsKey('Title__c') || !fetchDataSet.get('Title__c').containsKey(dg.Title__c)) {
            return;
        }   
        
        //getting title instance
        Title__c ttl = (Title__c)fetchDataSet.get('Title__c').get(dg.Title__c);
        
        //reset value to false
        dg.US_EST_Rights__c = FALSE;
        dg.US_VOD_Rights__c = FALSE;
        dg.CA_EST_Rights__c = FALSE;
        dg.CA_VOD_Rights__c = FALSE;
        
        //looping over related rights
        for (Right__c rght : ttl.Rights__r) {
            //if rights territory is US            
            if (rght.Territory__c == DGF_Constants.TERRITORY_US) {                      
                if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE)  {
                    dg.US_VOD_Rights__c = TRUE;
                }                            
                else if (rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) {  
                    dg.US_EST_Rights__c = TRUE; 
                }
            }
            //if rights territory is CA
            else if (rght.Territory__c == DGF_Constants.TERRITORY_CA) {                       
                if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE) {
                    dg.CA_VOD_Rights__c = TRUE;
                }                            
                else if (rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) { 
                    dg.CA_EST_Rights__c = TRUE;        
                }                        
            }  
        }
        
        //if all rights present then set rights validated to TRUE
        if (dg.US_EST_Rights__c && dg.US_VOD_Rights__c && dg.CA_EST_Rights__c && dg.CA_VOD_Rights__c && dg.Rights_Validated__c == FALSE) {
            dg.Rights_Validated__c = TRUE;
        }
    }
    
    /***********************************
Method Name: createProducts
Purpose: products will be created automatically for Film/TV Digital release linked to a title will original TM Version
***********************************/
    public static void createProducts(Digital_Release__c dg) {
        //if map does not contains key then return
        system.debug('fetchDataSet====='+fetchDataSet);
        if (!fetchDataSet.containsKey('Title1__c') || !fetchDataSet.get('Title1__c').containsKey(dg.Title__c)) {
            return;
        }
        
        //getting title details
        Title__c ttl = (Title__c)fetchDataSet.get('Title1__c').get(dg.Title__c);
        
        //if original TM Version present on Title
        if (!ttl.TM_Versions__r.isEmpty()) {
            TM_Version__c tmv = ttl.TM_Versions__r[0];
            
            Product__c prod = new Product__c();
            
            //if film digital release
            if (dg.RecordtypeId == FilmRecTypeId) {
                prod.Name = ttl.Name;
                prod.RecordTypeID = ProdFilmRecTypeId;
                prod.EST_Tier__c = DGF_Constants.NEW_RELEASE_STANDARD;
                prod.CA_EST_Tier__c = DGF_Constants.NEW_RELEASE_STANDARD;
                 if(dg.CA_EST_Date__c!=null  && dg.CA_Release__c != NULL) {
                  if(dg.CA_VOD_Start_Date__c!=null){
                    prod.CA_Platform_Offering__c = Label.DGF_CA_Film_Product_Platform_Default;
                  }else{
                    prod.CA_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
                  }
                }
                if(dg.US_EST_Date__C!=null){                  
                  if(dg.US_VOD_Start_Date__c!=null){
                    prod.US_Platform_Offering__c = Label.DGF_US_Film_Product_Platform_Default;
                  }else{
                    prod.US_Platform_Offering__c = DGF_Constants.PLATFORM_EST;
                  }
                }
            }
            //if TV digital release
            else {
                prod.Name = String.Valueof(dg.Name).length() > 80 ? String.Valueof(dg.Name).substring(0,79) : dg.Name;
                prod.RecordTypeID = ProdTVRecTypeId;
            }       
            
            //setting common fields
            prod.Digital_Release__c = dg.id;            
            prod.Product_ID__c = tmv.TVD_SAFE_Production_ID__c;
            prod.EIDR__c = tmv.Version_EIDR__c;
            prod.HD__c = dg.HD__c;
            prod.SD__c = dg.SD__c;
            prod.X3D__c = dg.X3D__c;
            prod.UHD__c = dg.UHD__c;
            
            //adding product instance to map
            if (!insertableDataSet.containsKey('Product__c')) {
                insertableDataSet.put('Product__c',new List<sObject>());
            }
            
            //adding details to insertable data set
            insertableDataSet.get('Product__c').add(prod);  
            
            //boolean variable to identify if we need to create product version records
            DGF_TriggerUtility.isProductCreatedAutomatically = TRUE;
        }
    }
    
    /***********************************
Method Name: createProductVersions
Purpose: create product versions for automatically created products
***********************************/
    public static void createProductVersions() {      
        //creating product versions for products created automatically
        if (DGF_TriggerUtility.isProductCreatedAutomatically) {
            
            //list of products versions to be inserted
            List<Product_Version__c> lstProdVersion = new List<Product_Version__c>();
            
            //looping over inserted products
            if (insertableDataSet.get('Product__c') != null) {
                for (Product__c prod : (List<Product__c>)insertableDataSet.get('Product__c')) {
                    
                    //creating instance of digital release, title and product version
                    Digital_Release__c dg = new Digital_Release__c();
                    Title__c ttl = new Title__c();
                    Product_Version__c pv = new Product_Version__c();
                    
                    //getting digital release details
                    if (Trigger.NewMap.containsKey(prod.Digital_Release__c)) {
                        dg = (Digital_Release__c)Trigger.NewMap.get(prod.Digital_Release__c);
                    }
                    
                    //if dg not null
                    if (dg != null && dg.Title__c != null) { //DFOR-1507
                        //getting title details
                        ttl = (Title__c)fetchDataSet.get('Title1__c').get(dg.Title__c);
                        
                        //if tm version present for title
                        if (!ttl.TM_Versions__r.isEmpty()) {
                            //creating instance for product version
                            pv.Name =  ttl.Name + ' ' + ttl.TM_Versions__r[0].Name;
                            pv.TM_Version__c = ttl.TM_Versions__r[0].id;
                            pv.Product__c = prod.id;
                            lstProdVersion.add(pv);
                        }
                    }               
                }
            }
            //inserting product version records
            if (!lstProdVersion.isEmpty()) {
                insert lstProdVersion;
            }
        }
    }  
    
    /***********************************
Method Name: updateProductResolution
Purpose: update resolution on related products
***********************************/
    public static void updateProductResolution(Digital_Release__c dg) {
        
        //if map does not contains key then return
        if (!fetchDataSet.containsKey('Digital_Release__c') || !fetchDataSet.get('Digital_Release__c').containsKey(dg.Id)) {
            return;
        }
        
        //getting digital release details details
        Digital_Release__c dgUpdt = (Digital_Release__c)fetchDataSet.get('Digital_Release__c').get(dg.Id);
        Digital_Release__c dgOld = (Digital_Release__c)Trigger.OldMap.get(dg.Id);
        
        //if release has associated products
        if (!dgUpdt.Products__r.isEmpty()) {
            //looping over product list
            for (Product__c prod : dgUpdt.Products__r) {
                
                //adding product key to update  map
                Product__c updtProd = new Product__c();
                if (!updateableDataSet.containsKey('Product__c')) {
                    updateableDataSet.put('Product__c', new Map<Id, SObject>());
                }
                
                //creating an instance of product
                if (!updateableDataSet.get('Product__c').containsKey(prod.ID)) {
                    updtProd = prod;
                }
                else {
                    updtProd = (Product__c) updateableDataSet.get('Product__c').get(prod.ID);
                }               
                
                //if hd resolution changed
                if (dg.HD__c != dgOld.HD__c) {
                    updtProd.HD__c = dg.HD__c;
                }
                
                //if SD resolution is changed
                if (dg.SD__c != dgOld.SD__c) {
                    updtProd.SD__c = dg.SD__c;
                } 
                
                //if UHD resolution is changed
                if (dg.UHD__c != dgOld.UHD__c) {
                    updtProd.UHD__c = dg.UHD__c;
                } 
                
                //if 3D resolution is changed
                if (dg.X3D__c != dgOld.X3D__c) {
                    updtProd.X3D__c = dg.X3D__c;
                }  
                
                //adding instance to updateable data set
                updateableDataSet.get('Product__c').put(prod.ID, updtProd);
            }        
        }
    }
    
    /***********************************
Method Name: updateSeriesDigitalRelease
Purpose: update Series Digital from TV Digital info
***********************************/
    public static void updateSeriesDigitalRelease(Digital_Release__c dg) {
        if (!fetchDataSet.containsKey('Digital_Release__c') || !fetchDataSet.get('Digital_Release__c').containsKey(dg.Series_Name__c)) {
            return;
        }
        
        Digital_Release__c dgSeriesUpdt = (Digital_Release__c)fetchDataSet.get('Digital_Release__c').get(dg.Series_Name__c);
        
        dgSeriesUpdt.Scripted_Reality__c = dg.Scripted_Reality__c != null ? dg.Scripted_Reality__c : dgSeriesUpdt.Scripted_Reality__c ;
        dgSeriesUpdt.categorization__c = dg.categorization__c != null ? dg.categorization__c : dgSeriesUpdt.categorization__c ;
        //dgSeriesUpdt.Network_of_Air__c = dg.Network_of_Air__c != null ? dg.Network_of_Air__c : dgSeriesUpdt.Network_of_Air__c ; DFOR-1578
        //dgSeriesUpdt.Network_Categorization__c= dg.Network_Categorization__c != null ? dg.Network_Categorization__c : dgSeriesUpdt.Network_Categorization__c ; DFOR-1578
        dgSeriesUpdt.US_Network_of_Air__c = dg.US_Network_of_Air__c != null ? dg.US_Network_of_Air__c : dgSeriesUpdt.US_Network_of_Air__c ;
        dgSeriesUpdt.US_Network_Categorization__c= dg.US_Network_Categorization__c != null ? dg.US_Network_Categorization__c : dgSeriesUpdt.US_Network_Categorization__c ;
        dgSeriesUpdt.TV_Studio__c = dg.TV_Studio__c != null ? dg.TV_Studio__c : dgSeriesUpdt.TV_Studio__c ;
        dgSeriesUpdt.CA_Network_of_Air__c = dg.CA_Network_of_Air__c != null ? dg.CA_Network_of_Air__c: dgSeriesUpdt.CA_Network_of_Air__c ; //DFOR-1095
        dgSeriesUpdt.of_Seasons__c =  aggregateCountMap.get(dg.Series_Name__c) ; 
        dgSeriesUpdt.of_Eps_in_Series__c =  aggregateSumMap.get(dg.Series_Name__c) ;
        
        
        
        if (!updateableDataSet.containsKey('Digital_Release__c')) {
            updateableDataSet.put('Digital_Release__c', new Map<Id, SObject>());
        }
        
        //adding instance to updateable data set
        updateableDataSet.get('Digital_Release__c').put(dgSeriesUpdt.ID, dgSeriesUpdt); 
        DGF_TriggerUtility.executeDigitalReleaseTrigger = FALSE;
    }
    
    /********************************************************/
    //dfor-1381
    /********************************************************/
    
    public static void updateTVDigitalReleaseWthSeries(Digital_Release__c dg) {
        
        dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
        
        if (!updateableDataSet.containsKey('Digital_Release__c')) {
            updateableDataSet.put('Digital_Release__c', new Map<Id, SObject>());
        }
        
        if(seriesDigiReleaseMap!=null && seriesDigiReleaseMap.containsKey(dg.id) && seriesDigiReleaseMap.get(dg.id).digital_releases__r!=null){
            System.debug('Demo on aca newteork of air change');
            string newscriptedRealty = '';
            string categorization = '';
            string nwofAir = '';
            string nwCategorization = '';
            string tvStudio = '';
            String canwofAir = '';
            
            boolean scriptRealityChange = false;
            boolean categorizationChange = false;
            boolean nwofAirChange = false;
            boolean nwCategorizationChange = false;
            boolean tvStudioChange = false;
            boolean canwofAirChange =false;
            
            if(dg.Scripted_Reality__c != dgOld.Scripted_Reality__c){
                newscriptedRealty = dg.Scripted_Reality__c;
                scriptRealityChange = true;
            }
            if(dg.CA_Network_of_Air__c != dgOld.CA_Network_of_Air__c){
                canwofAir = dg.CA_Network_of_Air__c;
                canwofAirChange = true;
            }            
            if(dg.Categorization__c != dgOld.Categorization__c){
                categorization = dg.Categorization__c;
                categorizationChange = true;
            }
            //if(dg.US_Network_of_Air__c != dgOld.Network_of_Air__c){ DFOR 1578
            if(dg.US_Network_of_Air__c != dgOld.US_Network_of_Air__c){
                //nwofAir = dg.Network_of_Air__c; DFOR-1578
                nwofAir = dg.US_Network_of_Air__c;
                nwofAirChange = true;
            }
            //if(dg.Network_Categorization__c != dgOld.Network_Categorization__c){ DFOR-1578
            if(dg.US_Network_Categorization__c != dgOld.US_Network_Categorization__c){
                //nwCategorization = dg.Network_Categorization__c; DFOR-1578
                nwCategorization = dg.US_Network_Categorization__c;
                nwCategorizationChange = true;
            }
            if(dg.TV_Studio__c != dgOld.TV_Studio__c){
                tvStudio = dg.TV_Studio__c;
                tvStudioChange = true;
            }
            for(digital_release__c dgChild : seriesDigiReleaseMap.get(dg.id).digital_releases__r){
                if(scriptRealityChange){
                    dgChild.Scripted_Reality__c = newscriptedRealty;
                }
                if(categorizationChange){
                    dgChild.Categorization__c = categorization;
                }
                if(nwofAirChange){
                    //dgChild.Network_of_Air__c= nwofAir; DFOR-1578
                    dgChild.US_Network_of_Air__c= nwofAir;
                }
                if(canwofAirChange){
                    dgChild.CA_Network_of_Air__c=canwofAir;
                    
                }
                if(nwCategorizationChange){
                    //dgChild.Network_Categorization__c = nwCategorization; DFOR-1578
                    dgChild.US_Network_Categorization__c = nwCategorization;
                }
                if(tvStudioChange){
                    dgChild.TV_Studio__c = tvStudio;
                }
                //adding instance to updateable data set
                updateableDataSet.get('Digital_Release__c').put(dgChild.ID, dgChild); 
            }
            
        } 
        
        DGF_TriggerUtility.executeDigitalReleaseTrigger = FALSE;
    } 
    
    //inner class to run required logic in system mode
    public without sharing class DGF_SystemModeUtility {
        //for deleting digital date records
        public void deleteDigitalDateRecords(List<Digital_Release__c> delDigitalDate) {
            if (!delDigitalDate.isEmpty()) {
                delete delDigitalDate;
            }
        }
    }
    /***********************************
DFOR-1526
Method Name: deleteRecords
Purpose: Delete product,pre-order and productAccount records and also delete bonus records.
***********************************/    
    public static void deleteRecords(Set<Id> drSet){
        list<Product__c> lstProds = [SELECT ID FROM Product__c WHERE Digital_Release__c IN :drSet];
        set<Id> prodSet = new set<Id>();
        if(lstProds!=null && lstProds.size()>0){
            for(Product__c pObj : lstProds)
            {
                prodSet.add(pObj.Id);
            }          
        }        
        list<Product_Account__c> lstPa = [SELECT ID FROM Product_Account__c WHERE Product__c IN : prodSet];
        if(lstPa!= null && lstPa.size()>0){             
            delete lstPa;
            
        } 
        if(lstProds !=null && lstProds.size()>0){
            delete lstProds;
        }
        
        list<EPO_Bonus__c> lstBs = [SELECT Id, Package__c FROM EPO_Bonus__c WHERE Digital_Release__c IN: drSet];
        set<Id> bonusset = new set<Id>();
        if(lstBs!=null && lstBs.size()>0){
            delete lstBs;  
        }   
        
        //EPO_Bonus__c
    }
    
    // For Calling GTM Server Webservice
    public static String CallingGTMServerWebservice(List<Digital_Release__c> digList,List<Digital_Release__c> digListOld)
    {
        System.debug('Inside the handler class');
        String message='';
        
        list<String>drIds=new list<String>();
        for(Digital_Release__c dr: digList)
        {  
            for(Digital_Release__c dr1: digListOld)
            {
                if(dr.Send_to_GTM__c != dr1.Send_to_GTM__c && dr.Send_to_GTM__c==true)
                    drIds.add(dr.id);
                
            }
            
        }
        List<Product__c> pdList=[select id, Version_Type__c from Product__c where Digital_Release__c =: drIds];
        integer i=0;  
        for(Product__c pv: pdList){
            if(pv.Version_Type__c=='Theatrical'){
                i=i+1;
            }
        }
        if(i>1){
            message='Product Version Type has more than one Theatrical';
        }
        else{
            list<Product_Version__c> prVesion=[select id from Product_Version__c where Product__r.Digital_Release__c in:drIds  and Product__r.Short_Name__c!=null and TM_Version__r.TVD_SAFE_Production_ID__c!='' and (Product__r.Digital_Release__r.CA_Bundle_Avail_Date__c!=null or Product__r.Digital_Release__r.US_Bundle_Avail_Date__c!=null)];      
            system.debug('=====prVesion===='+prVesion);           
            if(prVesion.size()>=2)
            {                
                list<Digital_Release__c> digiList = [select id , name ,CA_Bundle_Avail_Date__c,Bundle_Genre__c,US_Bundle_Avail_Date__c,	Visibility__c,	Send_to_GTM__c,Primary_Bundle_Genre__c,CA_Bundle_Pre_Purchase_Date__c,
                                                     US_Bundle_Pre_Purchase_Date__c,Deactivation_Date__c,
                                                     (select id, name,Digital_Release__c,Product_ID__c, Version_Type__c,Short_Name__c,Bundle_Synopsis__c from Products__r) from Digital_Release__c where id=:drIds[0]];         
                User users=[Select Id,FederationIdentifier,Name,Email from User where Id=:userinfo.getuserId()];
                List<Product_Version__c> prodVerList=[select id, name,Product__c,TM_Version__c from Product_Version__c];
                map<id,list<Product_Version__c>> orderMap = new map<id,list<Product_Version__c>>();
                for(Product_Version__c info : [select id, name,Product__c,TM_Version__c from Product_Version__c])            
                {
                    if(orderMap.containskey(info.Product__c))
                    {
                        orderMap.get(info.Product__c).add(info);
                    }                        
                    else
                    {
                        list<Product_Version__c> temp = new list<Product_Version__c>();
                        temp.add(info) ;
                        orderMap.put(info.Product__c,temp);
                    }
                }  
                String input=''; 
                String input1='"entityList": [{';
                String input2='';
                string input3='';
                String inputDt='';
                String inputDt1='';
                String inputDt2='';
                String inputDt3='';
                String inputDt4='';
                String inputBundleGenre='';
                String inp=''; 
                List<String> bundleGenreList= new List<String>();
                
                for(Digital_Release__c dr:digiList)
                {      
                    if(dr.Bundle_Genre__c != null) {
                        System.debug('Bundle Genre is not null');
                        bundleGenreList=dr.Bundle_Genre__c.split(';');
                        system.debug('***Bundle genre '+bundleGenreList);
                    }
                    
                    input='{"SourceID":"'+dr.id+'","SourceName":"DGFR","SourceTitleName":"'+dr.name+'","SystemSSO":"206611836","UserSSO":"'+users.FederationIdentifier+'",';
                    integer yearr=0;
                    if(dr.CA_Bundle_Avail_Date__c != null && dr.US_Bundle_Avail_Date__c != null){
                         
                        if(dr.CA_Bundle_Avail_Date__c >= dr.US_Bundle_Avail_Date__c){
                            yearr=dr.CA_Bundle_Avail_Date__c.year();
                             
                        }
                        if(dr.CA_Bundle_Avail_Date__c<=dr.US_Bundle_Avail_Date__c){
                            yearr=dr.US_Bundle_Avail_Date__c.year();                             
                        }
                    }                    
                    else if(dr.CA_Bundle_Avail_Date__c!=null){
                        yearr=dr.CA_Bundle_Avail_Date__c.year();
                    }
                    else if(dr.US_Bundle_Avail_Date__c!=null){
                        yearr=dr.US_Bundle_Avail_Date__c.year();
                    }                    
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    String unique1 = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                    string gnrDesc='';
                    system.debug('**** Parent unique1 '+unique1);
                    system.debug('**** Products__r '+dr.Products__r);
                    for (DigitalRelease__c mySetting : DigitalRelease__c.getAll().values()){                  
                        if(dr.Primary_Bundle_Genre__c==mySetting.name){
                            gnrDesc=mySetting.DGF_GenreCode__c;
                            system.debug('*** DigitalRelease__c **'+gnrDesc);
                        }
                        
                    }
                    for(Product__c p:dr.Products__r)
                    {
                        system.debug('**** p'+p);
                        string vType='';
                        
                        for (VersionType_In_Product__c setting : VersionType_In_Product__c.getAll().values()){
                            
                            if(p.Version_Type__c==setting.name){
                                vType=setting.Version_Type__c;
                            }
                            
                        }
                        
                        
                        Blob b1 = Crypto.GenerateAESKey(128);
                        String h1 = EncodingUtil.ConvertTohex(b1);
                        String unique2 = h1.SubString(0,8)+ '-' + h1.SubString(8,12) + '-' + h1.SubString(12,16) + '-' + h1.SubString(16,20) + '-' + h1.substring(20);
                        system.debug('****Crosref Unique 1 '+unique2);
                        
                        Blob b2 = Crypto.GenerateAESKey(128);
                        String h2 = EncodingUtil.ConvertTohex(b2);
                        String unique3 = h2.SubString(0,8)+ '-' + h2.SubString(8,12) + '-' + h2.SubString(12,16) + '-' + h2.SubString(16,20) + '-' + h2.substring(20);
                        system.debug('**** Crosref Unique 1 '+unique3);
                        
                        String parentUniqueId=unique2+','+unique3;
                        system.debug('**** parentLinkId '+parentUniqueId);     
                        if(input2==''){
                            input2='"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                                +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                                +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'" ,"crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                                +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                                +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                            String synop='';
                            if(p.Bundle_Synopsis__c!=null) {
                                synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                            }
                            input2=input2+synop;
                        }
                        else {
                            input2=input2+'{"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                                +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                                +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'", "crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                                +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                                +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                            String synop='';
                            if(p.Bundle_Synopsis__c!=null) {
                                synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                            }
                            input2=input2+synop;
                        }
                        system.debug('**** input2'+input2);
                        if(orderMap.containsKey(p.id) && orderMap.get(p.id).size() > 0){
                            for(Product_Version__c orderRec : orderMap.get(p.id)){
                                System.debug('OrderRec'+orderRec);
                                // Product_Version__c pvc = [select id ,TM_Version__c from Product_Version__c where Id =:orderRec.Id];
                                TM_Version__c tmv = [SELECT Id,Name,TVD_SAFE_Production_ID__c FROM TM_Version__c WHERE Id =:orderRec.TM_Version__c];
                                if(input3==''){	
                                    input3=',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                                }
                                else{	
                                    input3=input3+',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                                }
                            }
                        }
                        
                    }
                    input2=input2+'{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "Y","genreDesc": "'+gnrDesc+'"},"parentLinkId": "'+unique1+'"}';
                    if(bundleGenreList.size()>0){
                        for(integer j=0;j<bundleGenreList.size();j++){
                            for (DigitalRelease__c mySetting1 : DigitalRelease__c.getAll().values()){                  
                                if(bundleGenreList[j]== mySetting1.name && bundleGenreList[j] != dr.Primary_Bundle_Genre__c ){
                                    String gnrDesc1 =mySetting1.DGF_GenreCode__c; // code for genre
                                    system.debug('genDesc1'+gnrDesc1);
                                    if(inputBundleGenre==''){
                                        inputBundleGenre=',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                                    } 
                                    else{
                                        inputBundleGenre=inputBundleGenre+',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    inp=',{"type": "Title",  "linkId": "'+unique1+'","currentRequestType": {"masterRequestType": "Title","requestType": "Title"},"operation": "AD",'
                        +'"data": {"productType": "CMPL","levelTagDesc": "TITLE","releaseStatusDesc": "REL","titleNameDelimited": "'+dr.name+'","originalMarket":"EDU","productionYear":"'+yearr+'"}}';
                    
                    if(dr.CA_Bundle_Pre_Purchase_Date__c!=null){
                        inputDt=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                            +'"data": {"eventTypeDesc": "CAPREORDBD","eventDate":"'+dr.CA_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
                    }
                    if(dr.CA_Bundle_Avail_Date__c!=null){
                        inputDt1=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                            +'"data": {"eventTypeDesc": "CASTREETBD","eventDate":"'+dr.CA_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
                    }
                    if(dr.US_Bundle_Pre_Purchase_Date__c!=null){
                        inputDt2=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                            +'"data": {"eventTypeDesc": "USPREORDBD","eventDate":"'+dr.US_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
                    }
                    if(dr.Deactivation_Date__c!=null){
                        inputDt3=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                            +'"data": {"eventTypeDesc": "BDLDDUS","eventDate":"'+dr.Deactivation_Date__c+'"},"parentLinkId": "'+unique1+'"}';
                    }
                    if(dr.US_Bundle_Avail_Date__c!=null){
                        inputDt4=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                            +'"data": {"eventTypeDesc": "USSTREETBD","eventDate":"'+dr.US_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
                    }                  
                    input3=input3+']}';                    
                }               
                System.debug('**3**'+input3);
                input=input+input1+input2+inputBundleGenre+inp+inputDt+inputDt1+inputDt2+inputDt3+inputDt4+input3;              
                
                SendJsonString.SendDigitalReleaseWithProducts(input,drIds[0]);               
            }
            else if(drIds.size()>0)
            {
                message='Product Versions / Production ID / Short Name / CA or US Bundle Avail Date is missing in one or more Products';  
            }
        }
        return message;
    }
    public static void CallUpdateFieldsWebservice(List<Digital_Release__c> drList,List<Digital_Release__c> drListOld)
    {
        Boolean primaryGenre=false;
        Boolean bndlGenre=false;
        
        Boolean CAbundlePreDate_AD=false;
        Boolean CAbundlePreDate_ED=false;
        
        Boolean CAbundleAvailDate_AD=false;
        Boolean CAbundleAvailDate_ED=false;
        
        Boolean CAbundlePrePurchDate_AD=false;
        Boolean CAbundlePrePurchDate_ED=false;
        
        Boolean DeactDate_AD=false;
        Boolean DeactDate_ED=false;
        
        Boolean USbundleAvailDate_AD=false;
        Boolean USbundleAvailDate_ED=false;
        
        list<String>drIds=new list<String>();
        for(Digital_Release__c dr: drList)
        {
            for(Digital_Release__c dr1: drListOld)
            {
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' )
                    drIds.add(dr.id);
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr.Primary_Bundle_Genre__c !=dr1.Primary_Bundle_Genre__c)
                    primaryGenre=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr.Bundle_Genre__c!=dr1.Bundle_Genre__c)
                    bndlGenre=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.CA_Bundle_Pre_Purchase_Date__c==null && dr.CA_Bundle_Pre_Purchase_Date__c!=null)
                    CAbundlePreDate_AD=true;
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.CA_Bundle_Pre_Purchase_Date__c!=null && dr1.CA_Bundle_Pre_Purchase_Date__c!=dr.CA_Bundle_Pre_Purchase_Date__c)
                    CAbundlePreDate_ED=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.CA_Bundle_Avail_Date__c==null && dr.CA_Bundle_Avail_Date__c!=null)
                    CAbundleAvailDate_AD=true;
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.CA_Bundle_Avail_Date__c!=null && dr1.CA_Bundle_Avail_Date__c!=dr.CA_Bundle_Avail_Date__c)
                    CAbundleAvailDate_ED=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.US_Bundle_Pre_Purchase_Date__c==null && dr.US_Bundle_Pre_Purchase_Date__c!=null)
                    CAbundlePrePurchDate_AD=true;
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.US_Bundle_Pre_Purchase_Date__c!=null && dr1.US_Bundle_Pre_Purchase_Date__c!=dr.US_Bundle_Pre_Purchase_Date__c)
                    CAbundlePrePurchDate_ED=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.Deactivation_Date__c==null && dr.Deactivation_Date__c!=null)
                    DeactDate_AD=true;
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.Deactivation_Date__c!=null && dr1.Deactivation_Date__c!=dr.Deactivation_Date__c)
                    DeactDate_ED=true;
                
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.US_Bundle_Avail_Date__c==null && dr.US_Bundle_Avail_Date__c!=null)
                    USbundleAvailDate_AD=true;
                if(dr.Send_to_GTM__c==true && dr.Bundle_SYSGEN__c !=null && dr.Visibility__c=='Visible' && dr1.US_Bundle_Avail_Date__c!=null && dr1.US_Bundle_Avail_Date__c!=dr.US_Bundle_Avail_Date__c)
                    USbundleAvailDate_ED=true;
            }
        }
        
        SendJsonString.DigitalReleaseUpdateOnly(drIds,primaryGenre,bndlGenre,CAbundlePreDate_AD,CAbundlePreDate_ED,CAbundleAvailDate_AD,CAbundleAvailDate_ED,CAbundlePrePurchDate_AD,CAbundlePrePurchDate_ED,DeactDate_AD,DeactDate_ED,USbundleAvailDate_AD,USbundleAvailDate_ED );
        
    }
    public static Void CallingGTMServerWebserviceAfter_Bundle_SYSGEN_Update(List<Digital_Release__c> digList,List<Digital_Release__c> digOldList)  {
        list<Digital_Release__c> digiList=new list<Digital_Release__c>();
        
        system.debug('**** in side bundle sysgen method');
        Profile p1=[select id,name from profile where name='Platform API'];
        system.debug('**** in side bundle sysgen method 2'+p1);
        List<user> u=[select id, alias from user where profileid=:p1.id];
        system.debug('**** in side bundle sysgen method 3'+u);
        
        //============================================================================================
        digiList = [select id , name ,CA_Bundle_Avail_Date__c,Bundle_SYSGEN__c,Bundle_Genre__c,US_Bundle_Avail_Date__c,	Visibility__c,	Send_to_GTM__c,Primary_Bundle_Genre__c,CA_Bundle_Pre_Purchase_Date__c,
                    US_Bundle_Pre_Purchase_Date__c,Deactivation_Date__c,
                    (select id, name,Digital_Release__c,Product_ID__c, Version_Type__c,Short_Name__c,Bundle_Synopsis__c from Products__r) from Digital_Release__c where id=:digList[0].id];         
        User users=[Select Id,FederationIdentifier,Name,Email from User where Id=:userinfo.getuserId()];
        List<Product_Version__c> prodVerList=[select id, name,Product__c,TM_Version__c from Product_Version__c];
        map<id,list<Product_Version__c>> orderMap = new map<id,list<Product_Version__c>>();
        for(Product_Version__c info : [select id, name,Product__c,TM_Version__c from Product_Version__c])            
        {
            if(orderMap.containskey(info.Product__c))
            {
                orderMap.get(info.Product__c).add(info);
            }                        
            else
            {
                list<Product_Version__c> temp = new list<Product_Version__c>();
                temp.add(info) ;
                orderMap.put(info.Product__c,temp);
            }
        }  
        String input=''; 
        String input1='"entityList": [{';
        String input2='';
        string input3='';
        String inputDt='';
        String inputDt1='';
        String inputDt2='';
        String inputDt3='';
        String inputDt4='';
        String inputBundleGenre='';
        String inp='';     
        List<ID> pdList=new List<ID>();
        List<String> bundleGenreList= new List<String>();
        for(Digital_Release__c dr:digiList)
        {      
            if(dr.Bundle_Genre__c != null) {
                System.debug('Bundle Genre is not null');
                bundleGenreList=dr.Bundle_Genre__c.split(';');
                system.debug('***Bundle genre '+bundleGenreList);
            }           
            input='{"SourceID":"'+dr.id+'","SourceName":"DGFR","SourceTitleName":"'+dr.name+'","SystemSSO":"206611836","UserSSO":"'+users.FederationIdentifier+'",';
            integer yearr=0;
            if(dr.CA_Bundle_Avail_Date__c!=null && dr.US_Bundle_Avail_Date__c!=null){
                if(dr.CA_Bundle_Avail_Date__c>=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.CA_Bundle_Avail_Date__c.year();
                }
                if(dr.CA_Bundle_Avail_Date__c<=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.US_Bundle_Avail_Date__c.year();
                }
            }
            else if(dr.CA_Bundle_Avail_Date__c!=null){
                yearr=dr.CA_Bundle_Avail_Date__c.year();
            }
            else if(dr.US_Bundle_Avail_Date__c!=null){
                yearr=dr.US_Bundle_Avail_Date__c.year();
            }
            
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String unique1 = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            string gnrDesc='';
            system.debug('**** Parent unique1 '+unique1);
            system.debug('**** Products__r '+dr.Products__r);
            for (DigitalRelease__c mySetting : DigitalRelease__c.getAll().values()){                  
                if(dr.Primary_Bundle_Genre__c==mySetting.name){
                    gnrDesc=mySetting.DGF_GenreCode__c;
                    system.debug('*** DigitalRelease__c **'+gnrDesc);
                }
                
            }
            for(Product__c p:dr.Products__r)
            {
                system.debug('**** p'+p);
                string vType='';
                
                for (VersionType_In_Product__c setting : VersionType_In_Product__c.getAll().values()){
                    
                    if(p.Version_Type__c==setting.name){
                        vType=setting.Version_Type__c;
                    }
                    
                }
                
                
                Blob b1 = Crypto.GenerateAESKey(128);
                String h1 = EncodingUtil.ConvertTohex(b1);
                String unique2 = h1.SubString(0,8)+ '-' + h1.SubString(8,12) + '-' + h1.SubString(12,16) + '-' + h1.SubString(16,20) + '-' + h1.substring(20);
                system.debug('****Crosref Unique 1 '+unique2);
                
                Blob b2 = Crypto.GenerateAESKey(128);
                String h2 = EncodingUtil.ConvertTohex(b2);
                String unique3 = h2.SubString(0,8)+ '-' + h2.SubString(8,12) + '-' + h2.SubString(12,16) + '-' + h2.SubString(16,20) + '-' + h2.substring(20);
                system.debug('**** Crosref Unique 1 '+unique3);
                
                String parentUniqueId=unique2+','+unique3;
                system.debug('**** parentLinkId '+parentUniqueId);     
                if(input2==''){
                    input2='"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                        +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'", "crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                        +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                    String synop='';
                    if(p.Bundle_Synopsis__c!=null) {
                        synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                    }
                    input2=input2+synop;
                }
                else{
                    input2=input2+'{"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                        +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'", "crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                        +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                    String synop='';
                    if(p.Bundle_Synopsis__c!=null) {
                        synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                    }
                    input2=input2+synop;
                }
                system.debug('**** input2'+input2);
                if(orderMap.containsKey(p.id) && orderMap.get(p.id).size() > 0){
                    for(Product_Version__c orderRec : orderMap.get(p.id)){
                        System.debug('OrderRec'+orderRec);
                        // Product_Version__c pvc = [select id ,TM_Version__c from Product_Version__c where Id =:orderRec.Id];
                        TM_Version__c tmv = [SELECT Id,Name,TVD_SAFE_Production_ID__c FROM TM_Version__c WHERE Id =:orderRec.TM_Version__c];
                        if(input3==''){	
                            input3=',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                        }
                        else{	
                            input3=input3+',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                        }
                    }
                }
                
            }
            input2=input2+'{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "Y","genreDesc": "'+gnrDesc+'"},"parentLinkId": "'+unique1+'"}';
            if(bundleGenreList.size()>0 || test.isRunningTest()){
                for(integer i=0;i<bundleGenreList.size();i++){
                    for (DigitalRelease__c mySetting1 : DigitalRelease__c.getAll().values()){                  
                        if(bundleGenreList[i]== mySetting1.name && bundleGenreList[i] != dr.Primary_Bundle_Genre__c ){
                            String gnrDesc1 =mySetting1.DGF_GenreCode__c; // code for genre
                            system.debug('genDesc1'+gnrDesc1);
                            if(inputBundleGenre==''){
                                inputBundleGenre=',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                            } 
                            else{
                                inputBundleGenre=inputBundleGenre+',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                            }
                        }
                        
                    }
                    
                }
            }
            inp=',{"type": "Title",  "linkId": "'+unique1+'","currentRequestType": {"masterRequestType": "Title","requestType": "Title"},"operation": "ED",'
                +'"data": {"titleId_s": "'+dr.Bundle_SYSGEN__c+'","productType": "CMPL","levelTagDesc": "TITLE","releaseStatusDesc": "REL","titleNameDelimited": "'+dr.name+'","originalMarket":"EDU","productionYear":"'+yearr+'"}}';
            
            if(dr.CA_Bundle_Pre_Purchase_Date__c!=null){
                inputDt=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "CAPREORDBD","eventDate":"'+dr.CA_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(dr.CA_Bundle_Avail_Date__c!=null){
                inputDt1=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "CASTREETBD","eventDate":"'+dr.CA_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(dr.US_Bundle_Pre_Purchase_Date__c!=null){
                inputDt2=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "USPREORDBD","eventDate":"'+dr.US_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(dr.Deactivation_Date__c!=null){
                inputDt3=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "BDLDDUS","eventDate":"'+dr.Deactivation_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(dr.US_Bundle_Avail_Date__c!=null){
                inputDt4=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "USSTREETBD","eventDate":"'+dr.US_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            //input2=input2+inputDt+inputDt1+inputDt2+inputDt3+inputDt4;
            
            input3=input3+']}'; 
            
        }
        
        
        
        System.debug('**3**'+input3);
        input=input+input1+input2+inputBundleGenre+inp+inputDt+inputDt1+inputDt2+inputDt3+inputDt4+input3;
        
        //=========================================================================================
        SendJsonString.SendDigitalReleaseWithProductsAfterBundle_SYSGEN_Update(input,digList[0].id);
        
        
    }
    
}