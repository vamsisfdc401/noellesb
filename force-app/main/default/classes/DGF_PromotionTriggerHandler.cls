/***********************************************************************************
Class Name: DGF_PromotionTriggerHandler
Purpose: Handler class for Promotion trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/05/2017           Prarthana                Initial Development
1.1             06/11/2017           Mohit                    DFOR-423 National Promotion Update Notification
******************************************************************************************/
public class DGF_PromotionTriggerHandler{
    
    /*****private declaration*****/
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> deleteableDataSet = new Map<String, List<SObject>>();       
    private static set<ID> setPromoId = new Set<ID>();
    private static Promotion__c  prOld;    
    private static String profileName;
    private static Id AccRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.ACCOUNT_PROMOTION).getRecordTypeId();
    private static Id NationalRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.NATIONAL_PROMOTION).getRecordTypeId();
    private static Id FreeEpsodeRecTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
	private static Id TVReleaseRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
	private static Id TVProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();

    private static map<String,Digital_Date__c> digitalDateMap = new map<String,Digital_Date__c>();
    
    /***********************************
    Method Name: resetDataSet
    Purpose: method to reset context data variable
    ***********************************/
    private static void resetDataSet(){    
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear(); 
        setPromoId.clear();
    }
    
    /***********************************
    Method Name: getDataSet
    Purpose: method for executing SOQL
    ***********************************/
    @testVisible private static void getDataSet() {
        
        //checking if promotion ID are present
        if (!setPromoId.isEmpty()) {
            if (!fetchDataSet.containsKey('Digital_Date__c')) {
                fetchDataSet.put('Digital_Date__c', new Map<ID,sObject>());
            }
            
            //looping over Digital Date
            for (Digital_Date__c digDate : [Select ID, Name,Date_API_Name__c, Promotion__c, Digital_Release__c, Release_Date__c, Release_Date_Type__c 
                                                                FROM Digital_Date__c where Promotion__c IN:setPromoId ]) {                
                fetchDataSet.get('Digital_Date__c').put(digDate.ID, digDate);  
            } 
            
            if (!fetchDataSet.containsKey('Promotion_Account__c')) {
                fetchDataSet.put('Promotion_Account__c', new Map<ID,sObject>());
            }
            
            //looping over Promotion Account Records
            for (Promotion_Account__c pa : [SELECT ID, Promotion__c from Promotion_Account__c where Promotion__c IN:setPromoId]) {
                fetchDataSet.get('Promotion_Account__c').put(pa.ID, pa);  
            }
            
            if (!fetchDataSet.containsKey('Pricing__c')) {
                fetchDataSet.put('Pricing__c', new Map<ID,sObject>());
            }
            
            //looping over Pricing Record
            for (Pricing__c price : [SELECT ID, Promotion__c from Pricing__c where Promotion__c IN : setPromoId]) {
                fetchDataSet.get('Pricing__c').put(price.ID, price);  
            }
            
            if (!fetchDataSet.containsKey('Promotion_Product__c')) {
                fetchDataSet.put('Promotion_Product__c', new Map<ID,sObject>());
            }
            
            //looping over Promotion Account Records
            for (Promotion_Product__c pp : [SELECT ID, TPR__c, Product__r.Digital_Release__r.Free_First_Episode_Start_Date__c, Product__r.Digital_Release__r.Free_First_Episode_End_Date__c, Product__r.RecordTypeId, Product__r.Digital_Release__r.recordTypeId, Promotion__c from Promotion_Product__c where Promotion__c IN : setPromoId]) {
                fetchDataSet.get('Promotion_Product__c').put(pp.ID, pp);  
            }
            
            //getting promotion details with child records
            if (!fetchDataSet.containsKey('Promotion__c')) {
                fetchDataSet.put('Promotion__c', new Map<ID,sObject>());
            }
            
            //looping over promotion records
            for (Promotion__c promotion : [Select id, name, start_date__c, end_date__c, (Select id, name, start_date__c, end_date__c, RecordTypeId from Promotions__r) 
                                                from Promotion__c where Id IN : setPromoId]) {
                fetchDataSet.get('Promotion__c').put(promotion.ID, promotion);  
            }
        }
        
        Id profileId = userinfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    }
    
    /***********************************
    Method Name: commitDataSet
    Purpose: Method for performing DML operations
    ***********************************/
    @testVisible private static void commitDataSet() {
        
        //for inserting records
        if (!insertableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : insertableDataSet.keySet()) {
                
                //get list to be inserted
                List<SObject> dataSet = insertableDataSet.get(sobjectApi);
                
                //inserting records
                if (!dataSet.isEmpty()) {
                    insert dataSet;
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
                    catch (DMLException ex) {
                        Trigger.New[0].addError(ex.getDMLMessage(0));
                    }
                }
            }
        }
        
        //for deleting records
        if (!deleteableDataSet.isEmpty()) {
            //looping over collection
            for (String sobjectApi : deleteableDataSet.keySet()) {
                
                //getting list to delete
                List<SObject> dataSet = deleteableDataSet.get(sobjectApi);
                
                //deleting records
                if (!dataSet.isEmpty()) {
                    delete dataSet;
                }
            }
        }
    }
    
    /***********************************
    Method Name: executeOnBeforeInsert
    Purpose:Should execute only for before insert event
    ***********************************/    
    public static void executeOnBeforeInsert() {
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion__c promo : (List<Promotion__c>)trigger.new) {
            if (profileName == DGF_Constants.PROFILE_PRODUCT_USER) {
                if (promo.RecordTypeid == AccRecTypeId) {                    
                    promo.addError(DGF_Constants.DGF_Product_user_Account_Promotion_Validation);
                }
            }
            else if (profileName == DGF_Constants.PROFILE_ACCOUNT_USER) {
                if (promo.RecordTypeid == NationalRecTypeId) {
                    promo.addError(DGF_Constants.DGF_Account_User_Nation_Promo_Creation);
                }
                else if (promo.RecordTypeid == FreeEpsodeRecTypeId) {
                    promo.addError(DGF_Constants.DGF_Account_User_Free_Episode_Creation);
                }
            }
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose:Should execute only for before delete event
    ***********************************/    
    public static void executeOnBeforeDelete() {
        
        //first iteration over trigger.new to create collections
        for (Promotion__c promo : (List<Promotion__c>)trigger.old) {
            setPromoId.add(promo.id);
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion__c promo : (List<Promotion__c>)trigger.old) {
            if (profileName == DGF_Constants.PROFILE_PRODUCT_USER) {
                if (promo.RecordTypeid == AccRecTypeId) {
                    promo.addError(DGF_Constants.DGF_Product_User_Account_Promotion_Deletion);
                }
            }
            else if (profileName == DGF_Constants.PROFILE_ACCOUNT_USER) {
                if (promo.RecordTypeid == NationalRecTypeId) {
                    promo.addError(DGF_Constants.DGF_Product_User_National_Promotion_Deletion);
                }
                else if(promo.RecordTypeid == FreeEpsodeRecTypeId){
                    promo.addError(DGF_Constants.DGF_Account_User_Free_Episode_Deletion);
                }
            }
            
            //to delete Digital Date on deletion of Promotion
            for (sobject digiDate : fetchDataSet.get('Digital_Date__c').values()) {
                if (deleteableDataSet.containsKey('Digital_Date__c')) {
                    list<sobject> deleteList = deleteableDataSet.get('Digital_Date__c');
                    deleteList.add(digiDate);                    
                }
                else {
                    deleteableDataSet.put('Digital_Date__c', new List<SObject>{digiDate});
                }              
            }
            
            //to delete Promotion Account on deletion of Promotion
            for (sobject pa : fetchDataSet.get('Promotion_Account__c').values()) {
                if (deleteableDataSet.containsKey('Promotion_Account__c')) {
                    list<sobject> deleteList = deleteableDataSet.get('Promotion_Account__c');
                    deleteList.add(pa);                    
                }
                else {
                    deleteableDataSet.put('Promotion_Account__c', new List<SObject>{pa});
                }              
            }
            
            //to delete Promotion Product Pricing on deletion of Promotion
            for (sobject pr : fetchDataSet.get('Pricing__c').values()) {
                if (deleteableDataSet.containsKey('Pricing__c')) {
                    list<sobject> deleteList = deleteableDataSet.get('Pricing__c');
                    deleteList.add(pr);                    
                }
                else {
                    deleteableDataSet.put('Pricing__c', new List<SObject>{pr});
                }              
            }   
            
            //national offering deletion notification
            chatterPostOnPromotionDeletion(promo);            
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
    Method Name: executeOnAfterDelete
    Purpose:Should execute only for after delete event
    ***********************************/    
    public static void executeOnAfterDelete() {
        
        if (!DGF_TriggerUtility.lstFeedItemDeleteEvent.isEmpty()) {
            insert DGF_TriggerUtility.lstFeedItemDeleteEvent;
        }       
    }
    
    /***********************************
    Method Name: executeOnAfterInsert
    Purpose:Should execute only for after insert event
    ***********************************/    
    public static void executeOnAfterInsert() {
        
        //fetching data set for processing
        getDataSet();          
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion__c promo : (List<Promotion__c>)trigger.new) {            
            //method to create digital date records.
            createDigitalDates(promo);                      
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }    
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose:Should execute only for before update event
    ***********************************/    
    public static void executeOnBeforeUpdate(){
        //first iteration over trigger.new to create collections
		  for (Promotion__c promo : (List<Promotion__c>)trigger.new) {
				  setPromoId.add(promo.id);
				  prOld = (Promotion__c)Trigger.oldMap.get(promo.Id);
		  }
		  
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for(Promotion__c promo : (List<Promotion__c>)trigger.new){
			if (promo.RecordTypeid == FreeEpsodeRecTypeId && promo.Sync_Free_First_Episode_Dates__c && prOld.Sync_Free_First_Episode_Dates__c != promo.Sync_Free_First_Episode_Dates__c) {
				// method to sync free episode dates - DFOR-1097
				syncFreeEpisodeDates(promo);
			}
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
	
	 /***********************************
    Method Name: syncFreeEpisodeDates
    Purpose: Method to sync free episode dates
    ***********************************/    
    public static void syncFreeEpisodeDates (Promotion__c promo) {
        map<Id,Promotion_Product__c> promoProdMap = new map<Id, Promotion_Product__c>();
        //iterate over the promotion product records
        if (fetchDataSet != null && fetchDataSet.get('Promotion_Product__c') != null) {
            for (sobject pp : fetchDataSet.get('Promotion_Product__c').values()) {
                Promotion_Product__c promoPrd = (Promotion_Product__c)pp;
                //check for the Promotion Product associated to the Promotion 
                if(promoPrd.Promotion__c == promo.id && promoPrd.Product__r.recordTypeId == TVProdRecTypeId && promoPrd.Product__r.Digital_Release__r.RecordTypeId == TVReleaseRecTypeId) {
                    promoProdMap.put(promoPrd.id,promoPrd);
                }
            }
        }
        //if only 1 promotion Product is associated then sync the start and end date of promotion
        if(promoProdMap.size() == 1) {
            for(Promotion_Product__c promoPrd : promoProdMap.values()) {
                promo.Start_Date__c = promoPrd.Product__r.Digital_Release__r.Free_First_Episode_Start_Date__c;
                promo.End_Date__c = promoPrd.Product__r.Digital_Release__r.Free_First_Episode_End_Date__c;
            }
        }
        //if more than 1 promotion Product is associated throw an error
        else if(promoProdMap.size() > 1) {
            promo.addError('Free Episode Dates from Digital Release can only be synced to one TV product. Please remove any additional products.');
        }
        
    }
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {
        
        //first iteration over trigger.new to create collections
        for (Promotion__c promo : (List<Promotion__c>)trigger.new) {
            //creating a set og digital release ID
            if (!setPromoId.contains(promo.ID)) {
                setPromoId.add(promo.ID);
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        if (fetchDataSet != null && fetchDataSet.get('Digital_Date__c') != null) {            
            for (sobject digiDate : fetchDataSet.get('Digital_Date__c').values()) {
                Digital_Date__c digDate = (Digital_date__c)digiDate;
                digitalDateMap.put(digDate.Promotion__c + ':' + digDate.Date_API_Name__c, digDate);
            }            
        }
        
        //second iteration over Trigger.New for actual iteration
        for (Promotion__c promo : (List<Promotion__c>)trigger.new) {
            prOld = (Promotion__c) Trigger.OldMap.get(promo.Id);
            
            //if date is modified call updateDigitalDate method
            if ( prOld.Start_Date__c != promo.Start_Date__c) {
                updatePromoDates(promo,'Start_Date__c',promo.Start_Date__c); 
                if (promo.Start_Date__c != NULL) {
                    updateDigitalDate(promo,'Start_Date__c',promo.Start_Date__c);  
                }
                
                //if date is removed, call deleteDigitalDate method
                else if (promo.Start_Date__c == NULL ) {
                    deleteDigitalDate(promo,'Start_Date__c');
                }
            }
            
            if (prOld.End_Date__c!=promo.End_Date__c) {
                updatePromoDates(promo,'End_Date__c', promo.End_Date__c); 
                if (promo.End_Date__c != NULL) {
                    updateDigitalDate(promo,'End_Date__c',promo.End_Date__c);   
                }
                else if (promo.End_Date__c == NULL) {
                    deleteDigitalDate(promo,'End_Date__c');
                }         
            }
            
            //DFOR-423: National promotion notification
            if (promo.RecordTypeId == NationalRecTypeId && (promo.Start_Date__c != prOld.Start_Date__c || promo.End_Date__c != prOld.End_Date__c)) {
                chatterPostOnChildPromotion(promo);
            }
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
     /***********************************
    Method Name: updatePromoDates DFOR-868
    Purpose:method to update dates on Promotion Account and Promotion Products
    ***********************************/    
    public static void updatePromoDates(Promotion__c promo, String api, Date dt) {
        map<id,sobject> dataToBeUpdatedMap = new map<id,sobject>();
        
        //check for the associated Promotion Accounts
        if (fetchDataSet != null && fetchDataSet.get('Promotion_Account__c') != null) {            
            for (sobject pa : fetchDataSet.get('Promotion_Account__c').values()) {
                Promotion_Account__c promoAcc = (Promotion_Account__c)pa;
                //update the start and end date of the Promotion Account
                if(promoAcc.promotion__c == promo.id) {
                    if (api == 'Start_Date__c') {
                        promoAcc.Start_Date__c = dt;
                    }
                    else if (api == 'End_Date__c') {
                        promoAcc.End_Date__c = dt;
                    }
                    dataToBeUpdatedMap.put(promoAcc.id, promoAcc);
                }
            }            
        }
        
        //check for associated Promotion Products
        if (fetchDataSet != null && fetchDataSet.get('Promotion_Product__c') != null) {            
            for (sobject pp : fetchDataSet.get('Promotion_Product__c').values()) {
                Promotion_Product__c promoPrd = (Promotion_Product__c)pp;
                //update the start and end date of the Promotion Product
                if(promoPrd.promotion__c == promo.id) {
                    if (api == 'Start_Date__c') {
                        if (promoPrd.TPR__c ) {
                            promoPrd.tpr_start_date__c = dt;
                        }
                        promoPrd.Collection_Start_Date__c = dt;
                    }
                    else if (api == 'End_Date__c') {
                        if (promoPrd.TPR__c ) {
                            promoPrd.tpr_end_date__c = dt;
                        }
                        promoPrd.Collection_End_Date__c = dt;
                    }
                    dataToBeUpdatedMap.put(promoPrd.id, promoPrd);
                }
            }            
        }
        
        //add the Promotion account records to the updateableDataSet
        if (updateableDataSet.containsKey('Promotion_Account__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Promotion_Account__c');
            
            for (Sobject pa : dataToBeUpdatedMap.values()) {
                updateMap.put(pa.id,pa);
            }
        }
        else {
            updateableDataSet.put('Promotion_Account__c',dataToBeUpdatedMap);
        }
        
        //add the Promotion product records to the updateableDataSet
        if (updateableDataSet.containsKey('Promotion_Product__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Promotion_Product__c');
            
            for (Sobject pp : dataToBeUpdatedMap.values()) {
                updateMap.put(pp.id,pp);
            }
        }
        else {
            updateableDataSet.put('Promotion_Product__c', dataToBeUpdatedMap);
        }        
    }

    /***********************************
    Method Name: updateDigitalDate
    Purpose:method to update Digital dates
    ***********************************/    
    public static void updateDigitalDate(Promotion__c promo, String api, Date dt) {
        
        list<sobject> dataToBeInsertedList = new list<sobject>();
        map<id,sobject> dataToBeUpdatedMap = new map<id,sobject>();
        
        if (!digitalDateMap.containsKey(promo.id + ':' + api)) {
            //create new digital date record for newly added dates
            Digital_Date__c digitalDate = new Digital_Date__c(Date_API_Name__c=api, Promotion__c=promo.id, Release_Date__c=dt, 
                                            Release_Date_Type__c=Schema.getGlobalDescribe().get('Promotion__c').getDescribe().fields.getMap().get(api).getDescribe().getLabel());
            dataToBeInsertedList.add(digitalDate);
        }
        //update existing digital date records
        else {
            Digital_Date__c digitalDate = digitalDateMap.get(promo.id + ':' + api);
            
            if (digitalDate.Release_Date__c != dt) {
                digitalDate.Release_Date__c = dt;
                dataToBeUpdatedMap.put(digitalDate.id, digitalDate);
            }
        }
        
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList = insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }
        
        if (updateableDataSet.containsKey('Digital_Date__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Digital_Date__c');
            
            for (Sobject dd : dataToBeUpdatedMap.values()) {
                updateMap.put(dd.id,dd);
            }
        }
        else {
            updateableDataSet.put('Digital_Date__c', dataToBeUpdatedMap);
        }
    }    
    
    /***********************************
    Method Name: deleteDigitalDate
    Purpose:method to delete Digital dates
    ***********************************/  
    public static void deleteDigitalDate(Promotion__c promo, String api) {
        list<sobject> dataToBeDeletedList = new list<sobject>();
        
        //for dates cleared out on Promotion, delete the corresponding digital date record
        if (digitalDateMap.containsKey(promo.id + ':' + api)) {
            Digital_Date__c digitalDate = digitalDateMap.get(promo.id + ':' + api);
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
    Method Name:modifyDigitalDates
    Purpose: for changing digital dates
    *****************************************/   
    private static void createDigitalDates(Promotion__c promo) {
        list<sobject> dataToBeInsertedList = new list<sobject>();
        
        //create start date digital date record
        if (promo.Start_Date__c != NULL && !digitalDateMap.containsKey(promo.id + ':' + 'Start_Date__c')) {
            Digital_Date__c digitalDate = new Digital_Date__c(Date_API_Name__c = 'Start_Date__c', Promotion__c = promo.id, Release_Date__c = promo.Start_Date__c,
                                         Release_Date_Type__c = Schema.getGlobalDescribe().get('Promotion__c').getDescribe().fields.getMap().get('Start_Date__c').getDescribe().getLabel());
            dataToBeInsertedList.add(digitalDate);
        }
        
        //create end date digital date record
        if (promo.End_Date__c != NULL && !digitalDateMap.containsKey(promo.id + ':' + 'End_Date__c')) {
            Digital_Date__c digitalDate = new Digital_Date__c(Date_API_Name__c = 'End_Date__c', Promotion__c = promo.id, Release_Date__c = promo.End_Date__c, 
                                             Release_Date_Type__c = Schema.getGlobalDescribe().get('Promotion__c').getDescribe().fields.getMap().get('End_Date__c').getDescribe().getLabel());
            dataToBeInsertedList.add(digitalDate);
        }
        
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList = insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }       
    }
    
    /*****************************************
    Method Name: chatterPostOnChildPromotion
    Purpose: DFOR-423 for posting a chatter on child promotion if start/end date is updated on nation promotion
    *****************************************/   
    private static void chatterPostOnChildPromotion(Promotion__c promo){
        
        //if promotion instance is not present
        if (!fetchDataSet.containsKey('Promotion__c') || !fetchDataSet.get('Promotion__c').containsKey(promo.Id)) {
            return;
        }
        
        //adding feeditem key to insertable data set
        if (!insertableDataSet.containsKey('FeedItem')) {
            insertableDataSet.put('FeedItem', new List<sObject>());
        }
        
        //getting promotion details
        Promotion__c promotionDetails = (Promotion__c)fetchDataSet.get('Promotion__c').get(promo.Id);
        
        //if child records are present
        if (!promotionDetails.Promotions__r.isEmpty()) {
            //looping over child promotion records
            for (Promotion__c promotionChild : promotionDetails.Promotions__r) {
                
                //if child promotion is of type account
                if (promotionChild.RecordTypeId == AccRecTypeId) {
                    
                    //creating an instance of feed item
                    FeedItem post = new FeedItem();
                    post.ParentId = promotionChild.Id; 
                    post.Body = 'National Offering dates have been updated: ';
                    
                    if (promotionDetails.Start_Date__c == null) {
                        post.Body = post.Body + 'NA';
                    }
                    else {
                        post.Body = post.Body + promotionDetails.Start_Date__c.format();
                    }
                    
                    if (promotionDetails.End_Date__c == null) {
                        post.Body = post.Body + ' - NA';
                    }
                    else {
                        post.Body = post.Body + ' - ' + promotionDetails.End_Date__c.format();
                    } 
                    
                    //adding details to insertable data set
                    insertableDataSet.get('FeedItem').add(post);  
                }
            }
        }
    }
    
    /*****************************************
    Method Name: chatterPostOnChildPromotion
    Purpose: DFOR-423 for posting a chatter on child promotion national promotion is deleted
    *****************************************/   
    private static void chatterPostOnPromotionDeletion(Promotion__c promo) {
        //if promotion instance is not present
        if (!fetchDataSet.containsKey('Promotion__c') || !fetchDataSet.get('Promotion__c').containsKey(promo.Id)) {
            return;
        }
        
        //getting promotion details
        Promotion__c promotionDetails = (Promotion__c)fetchDataSet.get('Promotion__c').get(promo.Id);
        
        //if child records are present
        if (!promotionDetails.Promotions__r.isEmpty()) {
            //looping over child promotion records
            for (Promotion__c promotionChild : promotionDetails.Promotions__r) {
                
                //if child promotion is of type account
                if (promotionChild.RecordTypeId == AccRecTypeId) {
                    //creating an instance of feed item
                    FeedItem post = new FeedItem();
                    post.ParentId = promotionChild.Id; 
                    post.Body = 'National Offering is deleted.';               
                    
                    //adding details to insertable data set
                    DGF_TriggerUtility.lstFeedItemDeleteEvent.add(post);  
                }
            }
        }
    }
}