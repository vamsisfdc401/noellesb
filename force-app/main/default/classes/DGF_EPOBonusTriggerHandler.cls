/***********************************************************************************
Class Name: DGF_EPO&BonusTriggerHandler
Purpose: Handler class for EPO&Bonus trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             25/04/2017           Prarthana                Initial Development
1.1             04/12/2017           Prarthana                DFOR-153

******************************************************************************************/
public without sharing class DGF_EPOBonusTriggerHandler {
    
    /*****private declaration*****/
    private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
    private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
    private static Map<String, List<SObject>> deleteableDataSet = new Map<String, List<SObject>>();       
    private static set<ID> setEPOId = new Set<ID>();
    private static EPO_Bonus__c  epOld;       
    private static Id FilmBonusTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get(DGF_Constants.FILM_BONUS).getRecordTypeId();
    private static Id TVBonusRecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get(DGF_Constants.TV_BONUS).getRecordTypeId();
    private static map<String,Digital_Date__c>digitalDateMap=new map<String,Digital_Date__c>();
    private static Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DGF_Constants.DIGITAL_PARTNER).getRecordTypeId();
    
    /***********************************
  Method Name: resetDataSet
  Purpose: method to reset context data variable
  ***********************************/
    private static void resetDataSet() {    
        fetchDataSet.clear();
        insertableDataSet.clear();
        updateableDataSet.clear();
        deleteableDataSet.clear(); 
        setEPOId.clear();
    }
    
    /***********************************
  Method Name: getDataSet
  Purpose: method for executing SOQL
  ***********************************/
    @testVisible private static void getDataSet() {
        //checking if digital release ID are present
        if (!setEPOId.isEmpty()) {
            if (!fetchDataSet.containsKey('EPO_Bonus__c')) {
                fetchDataSet.put('EPO_Bonus__c',new Map<ID,sObject>());
            }
            for(EPO_Bonus__c epo : [SELECT ID, Start_Date__c, US_Start_Date__c, CA_Start_Date__c, Platform__c, Package__c,  Digital_Release__c, RecordTypeId, Digital_Release__r.RecordTypeId, Digital_Release__r.Categorization__c, Digital_Release__r.Scripted_Reality__c,
                                    //Digital_Release__r.Network_Categorization__c DFOR-1578
                                    Digital_Release__r.US_Network_Categorization__c, Digital_Release__r.TV_Studio__c, Bonus_Type__c FROM EPO_Bonus__c where id in:setEPOId]) {
                                        fetchDataSet.get('EPO_Bonus__c').put(epo.ID, epo);            
                                    }
            if (!fetchDataSet.containsKey('Digital_Date__c')) {
                fetchDataSet.put('Digital_Date__c',new Map<ID,sObject>());
            }
            
            //looping over Digital Date
            for (Digital_Date__c digDate : [Select ID,Name,Date_API_Name__c,EPO_Bonus__c,Digital_Release__c,Release_Date__c,Release_Date_Type__c FROM Digital_Date__c where EPO_Bonus__c IN:setEPOId ]) {
                fetchDataSet.get('Digital_Date__c').put(digDate.ID, digDate);  
            } 
            
            if (!fetchDataSet.containsKey('Bonus_Account__c')) {
                fetchDataSet.put('Bonus_Account__c',new Map<ID,sObject>());
            }
            
            for(Bonus_Account__c ba: [SELECT ID, Bonus__r.US_Start_Date__c, Bonus__r.US_End_Date__c, Bonus__r.CA_Start_Date__c, 
                                      Bonus__r.CA_End_Date__c, Start_Date__c, Account__r.Territory__c FROM Bonus_Account__c where Bonus__c IN:setEPOId]) {
                                          fetchDataSet.get('Bonus_Account__c').put(ba.ID, ba);
                                      }
        }
        if (!fetchDataSet.containsKey('Account')) {
            fetchDataSet.put('Account',new Map<ID,sObject>());
        }
        //query for all accounts with Digital Partner RecordType
        for(Account acc : [SELECT ID, RecordTypeId, EST_Only__c, EST_VOD__c, Territory__c, RecordType.Name, Categorization__c, Scripted_Reality__c, Network_Categorization__c, Bonus__c FROM Account where 
                           RecordTypeId =:AccRecTypeId ]) {
                               fetchDataSet.get('Account').put(acc.ID, acc);
         }
    }
                                                    
    /***********************************
  Method Name: commitDataSet
  Purpose: Method for performing DML operations
  ***********************************/
    @testVisible private static void commitDataSet() {
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
                    update dataSet.values();
                }
            }
        }
        
        
    }
    
    /***********************************
  Method Name: executeOnBeforeDelete
  Purpose:Should execute only for before delete event
  ***********************************/    
    public static void executeOnBeforeDelete() {
        
        //first iteration over trigger.new to create collections
        for(EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.old){
            setEPOId.add(epo.id);
        }
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (EPO_Bonus__c dg : (List<EPO_Bonus__c>)trigger.old) {
            for (sobject digiDate:fetchDataSet.get('Digital_Date__c').values()) {
                if (deleteableDataSet.containsKey('Digital_Date__c')) {
                    list<sobject> deleteList=deleteableDataSet.get('Digital_Date__c');
                    deleteList.add(digiDate);
                    
                }
                else {
                    deleteableDataSet.put('Digital_Date__c', new List<SObject>{digiDate});
                }
            }   
        }
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();   
    }
    
    /***********************************
  Method Name: executeOnBeforeInsert
  Purpose:Should execute only for before insert event
  ***********************************/    
    public static void executeOnBeforeInsert() {
        //first iteration over trigger.new to create collections
        for (EPO_Bonus__c dg : (List<EPO_Bonus__c>)trigger.new) {
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (EPO_Bonus__c dg : (List<EPO_Bonus__c>)trigger.new) {
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
  Method Name: executeOnAfterInsert
  Purpose:Should execute only for after insert event
  ***********************************/    
    public static void executeOnAfterInsert(){
        //first iteration over trigger.new to create collections
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
            setEPOId.add(epo.id);
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
            //method to create digital date records
            createDigitalDates(epo);
            //create Bonus Accounts fot TV Release
            if(epo.RecordTypeId == TVBonusRecTypeId) {
                createTVBonusAccounts(epo);
            }
            //create Bonus Accounts fot TV Release
              else if(epo.RecordTypeId == FilmBonusTypeId) {
                createFilmBonusAccounts(epo);
              }
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
  /***********************************
  Method Name: createFilmBonusAccounts
  Purpose:Method to create film bonus accounts
  ***********************************/ 
    public static void createFilmBonusAccounts(EPO_Bonus__c epo) {
        
        list<sobject> bonusAccList = new list<sobject> ();
        if(fetchDataSet.containsKey('EPO_Bonus__c')) {
            sobject obj = fetchDataset.get('EPO_Bonus__c').get(epo.id);
            epo = (EPO_Bonus__c)obj;
        }
        if(fetchDataSet.containsKey('Bonus_Account__c')) {
             for (sobject ba : fetchDataSet.get('Bonus_Account__c').values()) {
                 Bonus_Account__c  bonusAcc = (Bonus_Account__c)ba;
                 if(bonusAcc.bonus__c == epo.id) {
                    if (deleteableDataSet.containsKey('Bonus_Account__c')) {
                        list<sobject> deleteList=deleteableDataSet.get('Bonus_Account__c');
                        deleteList.add(ba);
                        
                    }
                    else {
                        deleteableDataSet.put('Bonus_Account__c', new List<SObject>{ba});
                    }
                 }
            }   
        }
        if(fetchDataSet.containsKey('Account')) {
            //iterate over all the accounts
            for(sobject obj : fetchDataSet.get('Account').values()) { 
                Account acc = (Account)obj;
                if(epo.package__c != null && epo.package__c.contains(DGF_Constants.ALA_CARTE)) {
                    if(epo.platform__c != null && epo.platform__c.contains(DGF_Constants.PLATFORM_EST) && epo.platform__c.contains(DGF_Constants.PLATFORM_VOD) 
                       && acc.EST_VOD__c != null) {
                           //create a Bonus Account record
                           Bonus_Account__c bonusAcc = new Bonus_Account__c (Bonus__c = epo.Id , Account__c = acc.Id, Notes__c = acc.EST_VOD__c,Start_Date__c = epo.Start_Date__c);
                           bonusAccList.add(bonusAcc);
                       }
                    else if (epo.platform__c == DGF_Constants.PLATFORM_EST && acc.EST_Only__c != null) {
                        //create a Bonus Account record
                        Bonus_Account__c bonusAcc = new Bonus_Account__c (Bonus__c = epo.Id , Account__c = acc.Id, Notes__c = acc.EST_Only__c, Start_Date__c = epo.Start_date__c);
                        bonusAccList.add(bonusAcc);
                    }
                }
            }
        }
        //insert the newly created Bonus Account
        if (insertableDataSet.containsKey('Bonus_Account__c')) {
            List<SObject> insertList = insertableDataSet.get('Bonus_Account__c');
            insertList.addAll(bonusAccList);
        }
        else {
            insertableDataSet.put('Bonus_Account__c',bonusAccList);
        }
    }
  
    /***********************************
  Method Name: createTVBonusAccounts
  Purpose:DFOR-153 method to create Bonus Accounts
  ***********************************/
    public static void createTVBonusAccounts(EPO_Bonus__c epo) {
        list<sobject> bonusAccList = new list<sobject> ();
        if(fetchDataSet.containsKey('EPO_Bonus__c')) {
            sobject obj = fetchDataset.get('EPO_Bonus__c').get(epo.id);
            epo = (EPO_Bonus__c)obj;
        }
        
        if(fetchDataSet.containsKey('Account')) {
            //iterate over all the accounts
            for(sobject obj : fetchDataSet.get('Account').values()) { 
                Account acc = (Account)obj;
                //compare the fields to check the Bonus accounts to be created
                if(acc.Categorization__c != null && epo.Digital_Release__r.Categorization__c != null && acc.Categorization__c.contains(epo.Digital_Release__r.Categorization__c) &&
                   acc.Scripted_Reality__c !=null && epo.Digital_Release__r.Scripted_Reality__c !=null && acc.Scripted_Reality__c.contains(epo.Digital_Release__r.Scripted_Reality__c) &&
                   // acc.Network_Categorization__c !=null && epo.Digital_Release__r.US_Network_Categorization__c !=null && acc.Network_Categorization__c.contains(epo.Digital_Release__r.US_Network_Categorization__c)  && DFOR-1578
                   acc.Network_Categorization__c !=null && epo.Digital_Release__r.US_Network_Categorization__c !=null && acc.Network_Categorization__c.contains(epo.Digital_Release__r.US_Network_Categorization__c)  &&
                   acc.Bonus__c != null && epo.Bonus_Type__c !=null && acc.Bonus__c.contains(epo.Bonus_Type__c)) {
                       //create a Bonus Account record
                       Bonus_Account__c bonusAcc = new Bonus_Account__c (Bonus__c = epo.Id , Account__c = acc.Id);
                       if(acc.territory__c ==DGF_Constants.TERRITORY_US && epo.us_start_date__c != null) {
                           bonusAcc.start_date__c = epo.us_start_date__c;
                       }
                       else if(acc.territory__c ==DGF_Constants.TERRITORY_CA && epo.ca_start_date__c != null) {
                           bonusAcc.start_date__c = epo.ca_start_date__c;
                       }
                       bonusAccList.add(bonusAcc);
                   }
            }
        }
        //insert the newly created Bonus Account
        if (insertableDataSet.containsKey('Bonus_Account__c')) {
            List<SObject> insertList = insertableDataSet.get('Bonus_Account__c');
            insertList.addAll(bonusAccList);
        }
        else {
            insertableDataSet.put('Bonus_Account__c',bonusAccList);
        }
    }
    
    /***********************************
  Method Name: executeOnBeforeUpdate
  Purpose:Should execute only for before update event
  ***********************************/    
    public static void executeOnBeforeUpdate() {
        //first iteration over trigger.new to create collections
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        //second iteration over Trigger.New for actual iteration
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    
    /***********************************
  Method Name: executeOnAfterUpdate
  Purpose:Should execute only for after update event
  ***********************************/    
    public static void executeOnAfterUpdate() {
        Boolean createTVBonus = false;
        map<Id,Bonus_Account__c> bonusAccUpdateMap = new map<Id,Bonus_Account__c>();
        //first iteration over trigger.new to create collections
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
            //creating a set og digital release ID
            if (!setEPOId.contains(epo.ID)) {
                setEPOId.add(epo.ID);
            }
        }   
        
        //fetching data set for processing
        getDataSet();  
        
        if (fetchDataSet != null && fetchDataSet.get('Digital_Date__c') != null) {
            
            for (sobject digiDate:fetchDataSet.get('Digital_Date__c').values()) {
                Digital_Date__c digDate=(Digital_date__c)digiDate;
                digitalDateMap.put(digDate.EPO_Bonus__c+':'+digDate.Date_API_Name__c,digDate);
            }            
        }
        
        //second iteration over Trigger.New for actual iteration
        for (EPO_Bonus__c epo : (List<EPO_Bonus__c>)trigger.new) {
            epOld = (EPO_Bonus__c) Trigger.OldMap.get(epo.Id);
            if (epo.RecordTypeId==FilmBonusTypeId) {
                if ((epo.platform__c != null && epOld.Platform__c != epo.Platform__c) || epOld.Package__c != epo.Package__c) {
                    createFilmBonusAccounts(epo);
                }
                if (epo.Start_Date__c!=NULL && (epOld.Start_Date__c!=epo.Start_Date__c || epOld.Digital_Release__c!=epo.Digital_Release__c )) {
                    updateDigitalDate(epo,'Start_Date__c',epo.Start_Date__c);
                    
                }
                else if (epo.Start_Date__c == NULL ) {
                    deleteDigitalDate(epo,'Start_Date__c');
                }
                
                //iterate over associated bonus accounts
                if(fetchDataSet.containsKey('Bonus_Account__c')) {
                    for (sobject obj:fetchDataSet.get('Bonus_Account__c').values()) {
                        Bonus_Account__c ba = (Bonus_Account__c)obj;
                        //update bonus account start date for US Territory
                        if(ba.bonus__c == epo.id && epo.Start_Date__c != epOld.Start_Date__c  && epo.package__c == epOld.Package__c && epo.platform__c == epOld.Platform__c) {
                            ba.Start_Date__c = epo.Start_Date__c;
                            bonusAccUpdateMap.put(ba.id,ba);
                        }
                        
                    }
                }
            }       
            else if (epo.RecordTypeId==TVBonusRecTypeId) {
                if (epo.US_Start_Date__c!=NULL && (epOld.US_Start_Date__c!=epo.US_Start_Date__c || epOld.Digital_Release__c!=epo.Digital_Release__c )) {
                    updateDigitalDate(epo,'US_Start_Date__c',epo.US_Start_Date__c);
                }
                else if (epo.US_Start_Date__c==NULL ) {
                    deleteDigitalDate(epo,'US_Start_Date__c');
                }
                if (epo.US_End_Date__c!=NULL && (epOld.US_End_Date__c!=epo.US_End_Date__c || epOld.Digital_Release__c!=epo.Digital_Release__c )) {
                    updateDigitalDate(epo,'US_End_Date__c',epo.US_End_Date__c);
                }
                else if (epo.US_End_Date__c==NULL ) {
                    deleteDigitalDate(epo,'US_End_Date__c');
                }
                if (epo.CA_Start_Date__c!=NULL && (epOld.CA_Start_Date__c!=epo.CA_Start_Date__c || epOld.Digital_Release__c!=epo.Digital_Release__c )) {
                    updateDigitalDate(epo,'CA_Start_Date__c',epo.CA_Start_Date__c);
                    
                }
                else if (epo.CA_Start_Date__c==NULL ) {
                    deleteDigitalDate(epo,'CA_Start_Date__c');
                }
                if (epo.CA_End_Date__c!=NULL && (epOld.CA_End_Date__c!=epo.CA_End_Date__c || epOld.Digital_Release__c!=epo.Digital_Release__c )) {
                    updateDigitalDate(epo,'CA_End_Date__c',epo.CA_End_Date__c);
                }
                else if (epo.CA_End_Date__c==NULL ) {
                    deleteDigitalDate(epo,'CA_End_Date__c');
                }
                //iterate over associated bonus accounts
                if(fetchDataSet.containsKey('Bonus_Account__c')) {
                    for (sobject obj:fetchDataSet.get('Bonus_Account__c').values()) {
                        Bonus_Account__c ba = (Bonus_Account__c)obj;
                        if(epo.Bonus_Type__c == epOld.Bonus_Type__c) {
                            //update bonus account start date for US Territory
                            if(ba.bonus__c == epo.id && epo.US_Start_Date__c != epOld.US_Start_Date__c && ba.Account__r.territory__c == DGF_Constants.TERRITORY_US ) {
                                ba.Start_Date__c = epo.US_Start_Date__c;
                                bonusAccUpdateMap.put(ba.id,ba);
                            }
                            //update bonus account start date for CA Territory
                            if(ba.bonus__c == epo.id && epo.CA_Start_Date__c != epOld.CA_Start_Date__c && ba.Account__r.territory__c == DGF_Constants.TERRITORY_CA) {
                                ba.Start_Date__c = epo.CA_Start_Date__c;
                                bonusAccUpdateMap.put(ba.id,ba);
                            }
                        }
                        
                        if(epo.Bonus_Type__c != epOld.Bonus_Type__c) {
                            if (!deleteableDataSet.containsKey('Bonus_Account__c')) {
                                deleteableDataSet.put('Bonus_Account__c', new List<SObject>());
                            }
                            deleteableDataSet.get('Bonus_Account__c').add(ba);  
                            //createTVBonus = true;
                            //break;
                        }
                        
                    }
                    
                }
                if(epo.Bonus_Type__c != epOld.Bonus_Type__c) {
                    createTVBonusAccounts(epo);
                }
                //if(createTVBonus) {
                    //createTVBonusAccounts(epo);
                //}
            }
        }
        if (updateableDataSet.containsKey('Bonus_Account__c')) {
            Map<Id,SObject> updateMap = updateableDataSet.get('Bonus_Account__c');
            for (Sobject ba:bonusAccUpdateMap.values()) {
                updateMap.put(ba.id,ba);
            }
        }
        else{
            updateableDataSet.put('Bonus_Account__c',bonusAccUpdateMap);
        }
        
        //performing DML
        commitDataSet();
        
        //clear data set
        resetDataSet();    
    }
    /***********************************
Method Name: updateDigitalDate
Purpose:method to update Digital dates
***********************************/    
    public static void updateDigitalDate(EPO_Bonus__c epo, String api, Date dt) {
        list<sobject>dataToBeInsertedList=new list<sobject>();
        map<id,sobject>dataToBeUpdatedMap=new map<id,sobject>();
        // if a new date field is populated then create a Digital Date record
        if (!digitalDateMap.containsKey(epo.id+':'+api)) {
            
            Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c=api,EPO_Bonus__c=epo.id,Release_Date__c=dt,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get(api).getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
            dataToBeInsertedList.add(digitalDate);
        }
        //if a date field is updated then update the existing digital date record
        else {
            Digital_Date__c digitalDate=digitalDateMap.get(epo.id+':'+api);
            if (digitalDate.Release_Date__c!=dt || digitalDate.Digital_Release__c!=epo.Digital_Release__c) {
                digitalDate.Release_Date__c=dt;
                digitalDate.Digital_Release__c=epo.Digital_Release__c;
                dataToBeUpdatedMap.put(digitalDate.id,digitalDate);
            }
        }
        //add to inserteableDataSet
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList=insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }
        //add to updateableDatSet
        if (updateableDataSet.containsKey('Digital_Date__c')) {
            Map<Id,SObject> updateMap=updateableDataSet.get('Digital_Date__c');
            for(Sobject dd:dataToBeUpdatedMap.values()){
                updateMap.put(dd.id,dd);
            }
        }
        else {
            updateableDataSet.put('Digital_Date__c',dataToBeUpdatedMap);
        }
    }
    
    
    /***********************************
Method Name: deleteDigitalDate
Purpose:method to delete Digital dates
***********************************/  
    public static void deleteDigitalDate(EPO_Bonus__c epo, String api) {
        list<sobject>dataToBeDeletedList=new list<sobject>();
        //If a date field is cleared out, delete the digital date record
        if (digitalDateMap.containsKey(epo.id+':'+api)) {
            Digital_Date__c digitalDate=digitalDateMap.get(epo.id+':'+api);
            dataToBeDeletedList.add(digitalDate);
        }
        if (deleteableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> deleteList=deleteableDataSet.get('Digital_Date__c');
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
    private static void createDigitalDates(EPO_Bonus__c epo) {
        list<sobject>dataToBeInsertedList=new list<sobject>();
        //Creating digital date records for the Film recordType
        if (epo.RecordTypeId==FilmBonusTypeId) {
            if (epo.Start_Date__c!=NULL && !digitalDateMap.containsKey(epo.id+':'+'Start_Date__c')) {
                Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c='Start_Date__c',EPO_Bonus__c=epo.id,Release_Date__c=epo.Start_Date__c,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get('Start_Date__c').getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
                dataToBeInsertedList.add(digitalDate);
            }
        }
        
        //Creating digital date records for the TV recordType
        if (epo.RecordTypeId==TVBonusRecTypeId) {
            if (epo.US_Start_Date__c!=NULL && !digitalDateMap.containsKey(epo.id+':'+'US_Start_Date__c')) {
                Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c='US_Start_Date__c',EPO_Bonus__c=epo.id,Release_Date__c=epo.US_Start_Date__c,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get('US_Start_Date__c').getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
                dataToBeInsertedList.add(digitalDate);
            }
            if (epo.US_End_Date__c!=NULL && !digitalDateMap.containsKey(epo.id+':'+'US_End_Date__c')) {
                Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c='US_End_Date__c',EPO_Bonus__c=epo.id,Release_Date__c=epo.US_End_Date__c,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get('US_End_Date__c').getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
                dataToBeInsertedList.add(digitalDate);
            }
            if (epo.CA_Start_Date__c!=NULL && !digitalDateMap.containsKey(epo.id+':'+'CA_Start_Date__c')) {
                Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c='CA_Start_Date__c',EPO_Bonus__c=epo.id,Release_Date__c=epo.CA_Start_Date__c,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get('CA_Start_Date__c').getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
                dataToBeInsertedList.add(digitalDate);
            }
            if (epo.CA_End_Date__c!=NULL && !digitalDateMap.containsKey(epo.id+':'+'CA_End_Date__c')) {
                Digital_Date__c digitalDate=new Digital_Date__c(Date_API_Name__c='CA_End_Date__c',EPO_Bonus__c=epo.id,Release_Date__c=epo.CA_End_Date__c,Release_Date_Type__c=Schema.getGlobalDescribe().get('EPO_Bonus__c').getDescribe().fields.getMap().get('CA_End_Date__c').getDescribe().getLabel(),Digital_Release__c=epo.Digital_Release__c);
                dataToBeInsertedList.add(digitalDate);
            }
        }
        
        if (insertableDataSet.containsKey('Digital_Date__c')) {
            List<SObject> insertList=insertableDataSet.get('Digital_Date__c');
            insertList.addAll(dataToBeInsertedList);
        }
        else {
            insertableDataSet.put('Digital_Date__c',dataToBeInsertedList);
        }
    }
}