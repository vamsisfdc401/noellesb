/*****************************************************************************************
Class Name: DGF_AutoReleaseCreationHandler
Purpose: handler for creating digital releases automatically from release force release
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/05/2017           Mohit                    Initial Development
1.1             31/10/2017           Mohit                    DFOR-846: Method updateDigitalRelease() updated
******************************************************************************************/
public without sharing class DGF_AutoReleaseCreationHandler {
    
    /*private variable declaration*/
    private static Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
    private static Id recordTypeIDCompetitveRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_COMPETITIVE).getRecordTypeId();
    private static Id recordTypeIDFILMDGF = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id recordTypeIDCompetitveDGF = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_COMPETITIVE).getRecordTypeId();
    private static DGF_SyncDigitalRelease__c csSyncRelease = DGF_SyncDigitalRelease__c.getValues(DGF_Constants.CS_RELEASE_SYNC);
    private static List<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_ReleaseFieldMapping__c.getall().values();
    private static List<Digital_Release__c> insertDigitalRelease = new List<Digital_Release__c>();
    private static List<Digital_Release__c> updateDigitalRelease = new List<Digital_Release__c>(); 
    private static Map<id,Digital_Release__c> mapUpdateDigitalRelease = new Map<Id,Digital_Release__c>(); 
    private static List<Digital_Release__c> deletetableDigitalRelease = new List<Digital_Release__c>();     
    private static List<Release__c> updateRFRelease = new List<Release__c>();
    private static Set<ID> setDigitalReleaseID = new Set<ID>();
    private static Map<Id,Digital_Release__c> mapDigitalReleaseDetails = new Map<Id,Digital_Release__c>();
    private static List<CollaborationGroup> chatterGroupId = new List<CollaborationGroup>();
    private static List<CollaborationGroupMember> chatterGroupMembers = new List<CollaborationGroupMember>();
    private static List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();   
    private static List<User> lstUserDetails = new List<User>();
    private static Set<String> setBrandGroup = new Set<String>();
    private static Set<Id> setOwnerId = new Set<Id>();
    public static Set<Id> dummyReleaseIdSet = new Set<Id>();
    /***********************************
    Method Name: executeOnBeforeInsert
    Purpose: in before insert context
    ***********************************/
    public static void executeOnBeforeInsert() {
    
         //if process started from Release
        DGF_TriggerUtility.isProcessStartedFromRelease = TRUE;
        system.debug('trigger.new is ' + trigger.new);
        //if release sync is enabled between release force and digital force 
        if (csSyncRelease != null && csSyncRelease.Sync_Release__c == TRUE) {
            
            //looping over release force release 
            for (Release__c rel : (List<Release__c>)trigger.new) { 
                       
                //if theatrical releaseforce reelase
                if (rel.RecordTypeID == recordTypeIDTheatricalRF && rel.Release_Status__c != DGF_Constants.CANCELLED) {
                    //then check for label code to set digital checkbox to true
                    if ((rel.Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES || rel.Brand_Group__c == DGF_Constants.BG_1440 || 
                                        rel.Brand_Group__c == DGF_Constants.BG_PARTNERS || rel.Brand_Group__c == DGF_Constants.BG_FAMILY || rel.Brand_Group__c == DGF_Constants.BG_CONTENT_GROUP) && rel.Digital__c == FALSE ) { //USST-2972
                        rel.Digital__c = TRUE;                        
                    }
                }
                
                //if competitve release then set digital check box to true
                else if (rel.RecordTypeID == recordTypeIDCompetitveRF && rel.Digital__c == FALSE && rel.Release_Status__c != DGF_Constants.CANCELLED) {
                    rel.Digital__c = TRUE;
                } 
                
                //default early awareness date and priduct type
                if (rel.Digital__c == TRUE) {    
                    //USST-2972 --- start
                    if (rel.Brand_Group__c == 'Content Group' && rel.EST_Date__c != null) {
                        rel.Early_Awareness_Date__c = Date.Valueof(rel.EST_Date__c).addDays(-14);
                    }
                    else {
                        rel.Early_Awareness_Date__c = rel.First_Theatrical_Date__c;
                    }
                    //USST-2972 --- end
                    if (rel.First_Theatrical_Date__c == null) {
                        rel.Product_Type__c = DGF_Constants.PRODUCT_DIRECT_TO_VIDEO;
                    }
                    else {
                        rel.Product_Type__c = DGF_Constants.PRODUCT_THEATRICAL;
                    }
                    
                    //Added as part of DFOR-1037 to calculate Digital PIN Date on physical release
                    if ((rel.RecordTypeID == recordTypeIDTheatricalRF || rel.RecordTypeID == recordTypeIDCompetitveRF) && rel.EST_Date__c != null) { //USST-3175
                        rel.Digital_PIN_Date__c = Date.Valueof(rel.EST_Date__c).addDays(-42);
                    }
                    //DFOR-1269 Digital PIN should be blank when EST is updated to blank
                    else if ((rel.RecordTypeID == recordTypeIDTheatricalRF || rel.RecordTypeID == recordTypeIDCompetitveRF) && rel.EST_Date__c == null) { //USST-3175
                        rel.Digital_PIN_Date__c = null;
                    }
                }
            }       
        }
    }
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose: in before update context
    ***********************************/
    public static void executeOnBeforeUpdate() {
        
        //if process started from Release
        DGF_TriggerUtility.isProcessStartedFromRelease = TRUE;
        
        //if release sync is enabled between release force and digital force 
        if (csSyncRelease != null && csSyncRelease.Sync_Release__c == TRUE) {
            set<id> releaseIdSet = new set<id>();
            
            //looping over release force release 
            for (Release__c rel : (List<Release__c>)trigger.new) {
                
                //getting old instance of release
                Release__c relOld = (Release__c) Trigger.OldMap.get(rel.Id);
                
                //if theatrical releaseforce reelase
                if (rel.RecordTypeID == recordTypeIDTheatricalRF && rel.Release_Status__c != DGF_Constants.CANCELLED) {
                    //then check for label code to set digital checkbox to true
                    if ((relOld.Brand_Group__c != DGF_Constants.BG_UNIVERSAL_PICTURES && relOld.Brand_Group__c != DGF_Constants.BG_1440 && 
                                      relOld.Brand_Group__c != DGF_Constants.BG_PARTNERS && relOld.Brand_Group__c != DGF_Constants.BG_FAMILY) && 
                                      (rel.Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES || rel.Brand_Group__c == DGF_Constants.BG_1440 || 
                                       rel.Brand_Group__c == DGF_Constants.BG_PARTNERS || rel.Brand_Group__c == DGF_Constants.BG_FAMILY) && rel.Digital__c == FALSE ) {
                        rel.Digital__c = TRUE;
                    }
                }
                
                
                //default early awareness date and priduct type
                if (rel.Digital__c == TRUE && (rel.First_Theatrical_Date__c != relOld.First_Theatrical_Date__c || rel.Digital__c != relOld.Digital__c)) {
                    if (rel.Brand_Group__c != 'Content Group') { //USST-2972
                        rel.Early_Awareness_Date__c = rel.First_Theatrical_Date__c; 
                    }
                    
                    if (rel.First_Theatrical_Date__c == null) {
                        rel.Product_Type__c = DGF_Constants.PRODUCT_DIRECT_TO_VIDEO;
                    }
                    else {
                        rel.Product_Type__c = DGF_Constants.PRODUCT_THEATRICAL;
                    }
                }
                
                //USST-2972 --- start
                if (rel.Digital__c == TRUE && (rel.EST_Date__c != relOld.EST_Date__c || rel.Digital__c != relOld.Digital__c 
                    || rel.Brand_Group__c != relOld.Brand_Group__c) && rel.Brand_Group__c == 'Content Group') {
                    rel.Early_Awareness_Date__c = Date.Valueof(rel.EST_Date__c).addDays(-14);
                }
                //USST-2972 --- end
                
                //Added as part of DFOR-1037 to calculate Digital PIN Date on physical release
                //USST-2984 --- start
                if (rel.Digital__c != relOld.Digital__c || rel.RecordTypeID != relOld.RecordTypeID || rel.EST_Date__c != relOld.EST_Date__c) {
                    if (rel.Digital__c == TRUE && (rel.RecordTypeID == recordTypeIDTheatricalRF || rel.RecordTypeID == recordTypeIDCompetitveRF) && rel.EST_Date__c != null) { //USST-3175 
                        rel.Digital_PIN_Date__c = Date.Valueof(rel.EST_Date__c).addDays(-42);
                    }
                    //DFOR-1269 Digital PIN should be blank when EST is updated to blank
                    else if (rel.Digital__c == TRUE && ((rel.RecordTypeID != recordTypeIDTheatricalRF && rel.RecordTypeID != recordTypeIDCompetitveRF) || rel.EST_Date__c == null)) { //USST-3175
                        rel.Digital_PIN_Date__c = null;
                    }
                }
                //USST-2984 --- end
                
                //DFOR-1483
                if(rel.Digital__c == TRUE && rel.Digital_Release__c==null){
                    releaseIdSet.add(rel.id);
                }
                System.debug('1483 1>>>' + releaseIdSet);
            }  
            
            //DFOR-1483    
            if(releaseIdSet.size()>0){
                Map<id, digital_release__c> releaseDigiMap = new Map<id, digital_release__c>();
                List<digital_release__c> digiList = [select id,US_Release__c,CA_Release__c from digital_release__c where (US_Release__c = :releaseIdSet or CA_Release__c = :releaseIdSet) ];
                
                if(digiList!=null && digiList.size()>0){
                    for(digital_release__c dg: digiList){
                        if(dg.US_Release__c!=null){
                            releaseDigiMap.put(dg.US_Release__c, dg);
                        }else if(dg.CA_Release__c!=null){
                            releaseDigiMap.put(dg.CA_Release__c, dg);
                        }
                    }                   
                }
                
                for(Release__c rel : (List<Release__c>)trigger.new){
                    if(releaseIdSet.contains(rel.id)){
                        if(releaseDigiMap.containsKey(rel.id)){                         
                            if(rel.Territory__c.equalsIgnoreCase('CDN') || rel.Territory__c.equalsIgnoreCase('Canada')){
                                if(releaseDigiMap.get(rel.id).CA_Release__c!=null){
                                   rel.Digital_Release__c = releaseDigiMap.get(rel.id).id; 
                                    System.debug('Setting Val>>CA' + releaseDigiMap.get(rel.id).id);
                                }  
                            }else if(rel.Territory__c.equalsIgnoreCase('US')){
                                if(releaseDigiMap.get(rel.id).US_Release__c!=null){
                                    System.debug('Setting Val>>US' + releaseDigiMap.get(rel.id).id);
                                   rel.Digital_Release__c = releaseDigiMap.get(rel.id).id; 
                                } 
                            }
                        }
                    }       
                }
            }   
        }       
    }
    
    /***********************************
    Method Name: executeOnAfterInsert
    Purpose: in after insert context
    ***********************************/
    public static void executeOnAfterInsert(Map<Id, Release__c> mapReleaseNew, string triggerContext) {
        
        //if release sync is enabled between release force and digital force 
        if (csSyncRelease != null && csSyncRelease.Sync_Release__c == TRUE) {
            
            //creating a set of digital release ID
            for (Release__c rel : mapReleaseNew.values()) {                
                //getting list of digital release ID to be updated
                if (rel.Digital__c == TRUE && rel.Digital_Release__c != null) {
                    setDigitalReleaseID.add(rel.Digital_Release__c);
                }               
            }
            
            //getting details of digital release
            getDigitalReleaseDetails(/*setDigitalReleaseID,*/ triggerContext);
            
            //looping over release force release 
            for (Release__c rel : mapReleaseNew.values()) {
                
                //if digital checkbox is true and no digital release exists then create new digital release
                if (rel.Digital__c == TRUE && rel.Digital_Release__c == null) {
                    //logic for creating digital release
                    createDigitalRelease(rel);
                }
                //if digital checkbox is true and digital release exists then update digital release
                else if (rel.Digital__c == TRUE && rel.Digital_Release__c != null) {
                    //logic for updating digital release
                    updateDigitalRelease(rel, null, triggerContext);
                }
            }
            
            //for DML
            commitRecords();
            
            //for clearing data set
            resetDataSet();
        }    
    }
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose: in after update context
    ***********************************/
    public static void executeOnAfterUpdate(Map<Id, Release__c> mapReleaseOld, Map<Id, Release__c> mapReleaseNew, string triggerContext) {
        
        Boolean isChanged = FALSE;

        for (Release__c relNew : mapReleaseNew.values()) {
            Release__c relOld = mapReleaseOld.get(relNew.Id);

            //looping over field mapping
            for (DGF_ReleaseFieldMapping__c csFieldMap : csReleaseFieldMapping) {
                
                if (csFieldMap.Source_Field_API_Name__c == 'PTV_SOD_Provider__c' && relNew.PTV_SOD_Provider__c == 'Other') 
                    continue; //USST-3106
                    
                if (relNew.get(csFieldMap.Source_Field_API_Name__c) != relOld.get(csFieldMap.Source_Field_API_Name__c)) {
                    isChanged = TRUE;
                }
            }
            
            if ((relNew.Digital__c != relOld.Digital__c) || (relNew.Release_Status__c != relOld.Release_Status__c)) {
                isChanged = TRUE;
            }
            
            setBrandGroup.add(relNew.Brand_Group__c);
            setOwnerId.add(relNew.OwnerId);
        }
        system.debug('executeOnAfterUpdate isChanged is ' + isChanged );
        //if release sync is enabled between release force and digital force 
        if (csSyncRelease != null && csSyncRelease.Sync_Release__c == TRUE && isChanged) {     

            //creating a set of digital release ID
            for (Release__c rel : mapReleaseNew.values()) {                
                //getting list of digital release ID to be updated
                if (rel.Digital__c == TRUE && rel.Digital_Release__c != null) {
                    setDigitalReleaseID.add(rel.Digital_Release__c);
                }               
            }
            
            //getting details of digital release
            getDigitalReleaseDetails(/*setDigitalReleaseID,*/ triggerContext);
                       
            //looping over release force release 
            for (Release__c rel : mapReleaseNew.values()) {
                system.debug('dummyReleaseIdSet is ' + dummyReleaseIdSet);
                //getting old instance of release
                Release__c relOld = mapReleaseOld.get(rel.Id);
                
                //if digital checkbox is true and no digital release exists then create new digital release
                if ((relOld.Digital__c!= rel.Digital__c && rel.Digital__c == TRUE) && rel.Digital_Release__c == null) { //DFOR-1472, 1483
                    //logic for creating digital release
                    createDigitalRelease(rel);
                }
                //if digital checkbox is true and digital release exists then update digital release
                else if (rel.Digital__c == TRUE && rel.Digital_Release__c != null) {
                    //logic for updating digital release
                    system.debug('updating rel ' + rel);
                    system.debug('updating mapReleaseOld ' + mapReleaseOld);
                    system.debug('updating triggerContext ' + triggerContext);
                    updateDigitalRelease(rel, mapReleaseOld, triggerContext);
                }else if((relOld.Digital__c!= rel.Digital__c) && rel.Digital__c == FALSE && rel.Digital_Release__c != null){//DFOR-1494
                    Digital_Release__c dg = mapUpdateDigitalRelease.containsKey(rel.Digital_Release__c)  ? mapUpdateDigitalRelease.get(rel.Digital_Release__c) : new Digital_Release__c(); 
                       
                        dg.Id = rel.Digital_Release__c;
                        
                        if(rel.release_status__c == DGF_Constants.CANCELLED){
                            dg.put('Release_State__c', DGF_Constants.CANCELLED);
                        }
                        
                        if (dg != null) {
                            mapUpdateDigitalRelease.put(dg.id,dg);
                        }
                }
                
                //if release status is changed to cancelled or digital checkbox is set to FALSE then below will be executed
                if (((relOld.Release_Status__c != DGF_Constants.CANCELLED && rel.Release_Status__c == DGF_Constants.CANCELLED) || 
                                   (relOld.Release_Status__c == DGF_Constants.CANCELLED && rel.Release_Status__c != DGF_Constants.CANCELLED)) && rel.Digital_Release__c != null) {
                    
                    String subject;
                    string msg;
                    
                    if (rel.Release_Status__c == DGF_Constants.CANCELLED) {
                        subject = 'Physical release ' + rel.Name + ' ' + DGF_Constants.CANCELLED;
                        msg = '<p>Physical Release has been cancelled. Below are the details: </p>';
                    }
                    else {
                        subject = 'Physical release ' + rel.Name + ' ' + DGF_Constants.UNCANCELLED;
                        msg = '<p>Physical Release has been uncancelled. Below are the details: </p>';
                    } 
                    
                    msg = msg +  '<p><b> Username:  </b> ' + DGF_TriggerUtility.currentUser.Name + '</p>';
                    msg = msg +  '<p><b> Change Date:  </b> ' + rel.lastmodifiedDate + '</p>';
                    msg = msg +  '<p><b> Release Name:  </b> ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rel.Id + '">' + rel.Name + '</a>' + '</p>';
                    msg = msg +  '<p><b> Release Territory:  </b> ' + rel.Territory__c + '</p>';  
                    
                    createEmailInstance(msg, subject, 'ONLY_GROUP', rel.Brand_Group__c, rel.OwnerId);
                }
                else if (!dummyReleaseIdSet.contains(rel.Id) && ((relOld.Digital__c == TRUE && rel.Digital__c == FALSE) || (relOld.Digital__c == FALSE && rel.Digital__c == TRUE)) &&  rel.Digital_Release__c != null) {
                    System.debug('enter email...' +rel);
                    System.debug('old release...' +relOld);
                    String subject;
                    string msg;
                    
                    if (rel.Digital__c == FALSE) {
                        subject = 'Physical release ' + rel.Name + ' Sync Removed';
                        msg = '<p>Digital Release is no longer synced with the Physical Release. Below are the details: </p>';
                    }
                    else {
                        subject = 'Physical release ' + rel.Name + ' Synced with Digital Release';
                        msg = '<p>Digital Release is synced with the Physical Release. Below are the details: </p>';
                    }  
                    
                    msg = msg +  '<p><b> Username:  </b> ' + DGF_TriggerUtility.currentUser.Name + '</p>';
                    msg = msg +  '<p><b> Change Date:  </b> ' + rel.lastmodifiedDate + '</p>';
                    msg = msg +  '<p><b> Release Name:  </b> ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rel.Id + '">' + rel.Name + '</a>' + '</p>';
                    msg = msg +  '<p><b> Release Territory:  </b> ' + rel.Territory__c + '</p>';  
                    
                    createEmailInstance(msg, subject, 'ONLY_GROUP', rel.Brand_Group__c, rel.OwnerId);
                }
                
                //Below added as part of DFOR-1037
                if (rel.Digital__c == TRUE && rel.Release_Status__c != DGF_Constants.CANCELLED && rel.Digital_PIN_Date__c != relOld.Digital_PIN_Date__c 
                                                                                                && rel.EST_to_PIN_Window__c < 42 && rel.RecordTypeID == recordTypeIDTheatricalRF) {
                                                                                                
                                                                                                    
                    String subject;
                    string msg;
                    
                    //setting email subject
                    subject = 'ALERT: PIN less than 42 days for ' + rel.Name ;
                    
                    //setting email body
                    msg = '<p>The below Release has a PIN date less than 42 days before EST</p>';                   
                    msg = msg +  '<p><b> Title:  </b> ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rel.Id + '">' + rel.Name + '</a>' + '</p>';
                    msg = msg +  '<p><b> PIN Date:  </b> ' + (rel.Digital_PIN_Date__c).format() + '</p>';  
                    msg = msg +  '<p><b> EST Date:  </b> ' + (rel.EST_Date__c).format() + '</p>';
                    msg = msg +  '<p><b> Window:  </b> ' + rel.EST_to_PIN_Window__c + '</p>';
                    
                    createEmailInstance(msg, subject, 'BOTH_GROUP_AND_USER', rel.Brand_Group__c, rel.OwnerId);
                }               
            }
            
            //for DML
            commitRecords();
            
            //sending emails
            if (!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
            
            //for clearing data set
            resetDataSet();
        }    
    }
    
    /***********************************
    Method Name: executeOnAfterDelete
    Purpose: in after delete context
    ***********************************/
    public static void executeOnAfterDelete(Map<Id, Release__c> mapReleaseOld, string triggerContext) {
        
        //if release sync is enabled between release force and digital force 
        if (csSyncRelease != null && csSyncRelease.Sync_Release__c == TRUE) {   
        
            //creating a set of digital release ID
            for (Release__c rel : mapReleaseOld.values()) {                
                //getting list of digital release ID to be updated
                if (rel.Digital__c == TRUE && rel.Digital_Release__c != null) {
                    setDigitalReleaseID.add(rel.Digital_Release__c);
                }               
            }
            
            //getting details of digital release
            getDigitalReleaseDetails(/*setDigitalReleaseID,*/ triggerContext);
            
            //looping over release force release 
            for (Release__c rel : mapReleaseOld.values()) {
                //if map is not null and map contains Digital Release
                if (!mapDigitalReleaseDetails.isEmpty() && mapDigitalReleaseDetails.containsKey(rel.Digital_Release__c)) {
                    
                    //getting instance of digital release
                    Digital_Release__c dg = mapDigitalReleaseDetails.get(rel.Digital_Release__c);
                    
                    //setting US Release look up to null if US RF release is being deleted
                    if (rel.Territory__c == DGF_Constants.TERRITORY_US) {
                        dg.US_Release__c = null;
                    }
                    //setting CA release look up to null if CA RF release is being deleted
                    else if (rel.Territory__c == DGF_Constants.TERRITORY_CDN) {
                        dg.CA_Release__c = null;
                    }
                    
                    //updating map with new instance
                    mapDigitalReleaseDetails.put(dg.Id,dg);
                }               
            }           
            
            //method for delete releases for which both the lookups are null
            deleteDigitalRelease();
        }       
    }
    
    /***********************************
    Method Name: createDigitalRelease
    Purpose: method to create digital release
    ***********************************/
    public static void createDigitalRelease(Release__c rel) {
        
        //if release not null and field mapping present
        if (rel != null && !csReleaseFieldMapping.isEmpty()) {
            
            Digital_Release__c dg = new Digital_Release__c();
            
            //setting record type of digital release
            if (rel.RecordTypeID == recordTypeIDTheatricalRF) {
                dg.put('RecordTypeID',recordTypeIDFILMDGF);
            }
            else if (rel.RecordTypeID == recordTypeIDCompetitveRF) {
                dg.put('RecordTypeID',recordTypeIDCompetitveDGF);
            }
            
            //looping over field mapping
            for (DGF_ReleaseFieldMapping__c csFieldMap : csReleaseFieldMapping) {
                if (csFieldMap.Source_Field_API_Name__c == 'PTV_SOD_Provider__c' && rel.PTV_SOD_Provider__c == 'Other') 
                    continue; //USST-3106
                    
                //if territory US
                if (rel.Territory__c == DGF_Constants.TERRITORY_US && csFieldMap.Territory__c == DGF_Constants.TERRITORY_US) {                    
                    //when populating distributor
                    if (csFieldMap.Source_Field_API_Name__c == 'Distributor__c' && rel.get(csFieldMap.Source_Field_API_Name__c) == null) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,DGF_Constants.UNIVERSAL);
                    }
                    else {
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    }                    
                }
                
                //if territory CDN
                if (rel.Territory__c == DGF_Constants.TERRITORY_CDN && csFieldMap.Territory__c == DGF_Constants.TERRITORY_CA) {
                    //when populating distributor
                    if (csFieldMap.Source_Field_API_Name__c == 'Distributor__c' && rel.get(csFieldMap.Source_Field_API_Name__c) == null) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,DGF_Constants.UNIVERSAL);
                    }
                    else {
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    }      
                }
                
                //for common target fields
                if (csFieldMap.Territory__c == DGF_Constants.TERRITORY_US_CA) {
                    dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                }               
            }
            if (rel.PTV_SOD_Provider__c == 'Other' && rel.Territory__c == 'US') {
                dg.put('US_PTV_SOD_Provider__c', rel.Other_Provider__c); //USST-3106
            }
            else if (rel.PTV_SOD_Provider__c == 'Other' && rel.Territory__c == 'CDN') {
                dg.put('CA_PTV_SOD_Provider__c', rel.Other_Provider__c); //USST-3106
            }
            
            //adding instance to insertable list
            if (dg != null) {
                insertDigitalRelease.add(dg);
            }           
        }        
    }
    
    /***********************************
    Method Name: updateDigitalRelease
    Purpose: method to update digital release
    ***********************************/
    public static void updateDigitalRelease(Release__c rel, Map<Id, Release__c> mapReleaseOld, string trgContext) {
        system.debug('in updateDigitalRelease ');
        system.debug('rel is '+ rel);
        system.debug('mapReleaseOld is '+ mapReleaseOld);
        system.debug('trgContext is ' + trgContext);
        //if release not null and field mapping present
        if (rel != null && !csReleaseFieldMapping.isEmpty()) {
            System.debug('mapUpdateDigitalRelease...'+mapUpdateDigitalRelease);
            Digital_Release__c dg = mapUpdateDigitalRelease.containsKey(rel.Digital_Release__c)  ? mapUpdateDigitalRelease.get(rel.Digital_Release__c) : new Digital_Release__c(); 
            Boolean isFieldNotChanged = FALSE;          
            
            //setting ID to digital release ID
            dg.Id = rel.Digital_Release__c;
            
            
            //looping over field mapping
            for (DGF_ReleaseFieldMapping__c csFieldMap : csReleaseFieldMapping) {  
                if (csFieldMap.Source_Field_API_Name__c == 'PTV_SOD_Provider__c' && rel.PTV_SOD_Provider__c == 'Other') 
                    continue; //USST-3106
                    
                //setting default value to false
                isFieldNotChanged = FALSE;
                
                //checking trigger context
                if(trgContext == DGF_Constants.AFTER_UPDATE){
                    //getting old instance of physical release
                    Release__c relOld = mapReleaseOld.get(rel.Id);
                    
                    //if old and new value same
                    if (rel.get(csFieldMap.Source_Field_API_Name__c) == relOld.get(csFieldMap.Source_Field_API_Name__c) && rel.get('Digital__c') == relOld.get('Digital__c')) {
                        isFieldNotChanged = TRUE;
                    }
                }                
                system.debug('isFieldNotChanged is ' + isFieldNotChanged );
                //skip if field should not be synced
                if (!csFieldMap.Execute_on_Update__c || isFieldNotChanged)  {                    
                    continue; 
                }
                
                //if territory US
                if (rel.Territory__c == DGF_Constants.TERRITORY_US && csFieldMap.Territory__c == DGF_Constants.TERRITORY_US) {       
                    //when populating distributor
                    if (csFieldMap.Source_Field_API_Name__c == 'Distributor__c' && rel.get(csFieldMap.Source_Field_API_Name__c) == null) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,DGF_Constants.UNIVERSAL);
                    }
                    else {
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    }
                }
                
                //if territory CDN
                if (rel.Territory__c == DGF_Constants.TERRITORY_CDN && csFieldMap.Territory__c == DGF_Constants.TERRITORY_CA) {
                    //when populating distributor
                    system.debug('csFieldMap.Source_Field_API_Name__c is ' + csFieldMap.Source_Field_API_Name__c);
                    if (csFieldMap.Source_Field_API_Name__c == 'Distributor__c' && rel.get(csFieldMap.Source_Field_API_Name__c) == null) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,DGF_Constants.UNIVERSAL);
                    }
                    else {
                        system.debug('updating ' + csFieldMap.Target_Field_API_Name__c + ' to value '+ rel.get(csFieldMap.Source_Field_API_Name__c));
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    }
                }    

                //common fields should only be updated from US release
                if (!mapDigitalReleaseDetails.isEmpty() && mapDigitalReleaseDetails.containsKey(rel.Digital_Release__c)) {
                    
                    //if release is US then always update using US release
                    if (rel.Territory__c == DGF_Constants.TERRITORY_US && csFieldMap.Territory__c == DGF_Constants.TERRITORY_US_CA) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    } 
                    //if there is no US release then update using CDN release
                    else if (rel.Territory__c == DGF_Constants.TERRITORY_CDN && mapDigitalReleaseDetails.get(rel.Digital_Release__c).US_Release__c == null && 
                                                                                                            csFieldMap.Territory__c == DGF_Constants.TERRITORY_US_CA) {
                        dg.put(csFieldMap.Target_Field_API_Name__c,rel.get(csFieldMap.Source_Field_API_Name__c));
                    }
                }                                  
            }
            
            //adding instance to updateable map 
            if (dg != null) {
                mapUpdateDigitalRelease.put(dg.id,dg);
            }
            system.debug('mapUpdateDigitalRelease is ' + mapUpdateDigitalRelease);
        }                
    }
    
     /***********************************
    Method Name: deleteDigitalRelease
    Purpose: method to delete digital release
    ***********************************/
    public static void deleteDigitalRelease() {
        
        //if map not empty
        if (!mapDigitalReleaseDetails.isEmpty()) {
            //looping over map
            for (Id dgId : mapDigitalReleaseDetails.keySet()) {
                //getting instance of digital release from map
                Digital_Release__c dg = mapDigitalReleaseDetails.get(dgId);
                
                //if both look ups are null then delete digital release
                if (dg.US_Release__c == null && dg.CA_Release__c == null) {
                    deletetableDigitalRelease.add(dg);
                }               
            }
        }
        
        //if there are records to be deleted
        if (!deletetableDigitalRelease.isEmpty()) {
            //getting list of products to delete
            List<Product__c> lstProdsToDelete = [Select Id from Product__c where Digital_Release__c in: deletetableDigitalRelease];
            
            //getting list of products pricing to delete
            List<Pricing__c> lstProdPricingToDelete = [Select Id from Pricing__c where Product__c in: lstProdsToDelete];
            
            //getting list of product versions to delete
            List<Product_Version__c> lstProdVersionToDelete = [Select Id from Product_Version__c where Product__c in:lstProdsToDelete];
            
            //getting list of product account to delete
            List<Product_Account__c> lstProdAccountToDelete = [Select id from Product_Account__c where Product__c in:lstProdsToDelete];
            
            //getting list of Bonus records to delete
            List<EPO_Bonus__c> lstBonusToDelete = [Select Id from EPO_Bonus__c where Digital_Release__c in: deletetableDigitalRelease];
            
            //getting list of Bonus accounts to delete
            List<Bonus_Account__c> lstBonusAccountToDelete = [Select id from Bonus_Account__c where Bonus__c in: lstBonusToDelete];
            
            //getting list of SVOD to delete
            List<Catalog_Window__c> lstSVODWindow = [Select id from Catalog_Window__c where Digital_Release__c in: deletetableDigitalRelease];
            
            //Digital Date
            List<Digital_Date__c> lstDigitalDates = [Select id from Digital_Date__c where Digital_Release__c in: deletetableDigitalRelease];
            
            //delete SVOD window if not empty
            if (!lstSVODWindow.isEmpty()) {
                delete lstSVODWindow;                   
            }
            
            //delete digital Dates if not empty
            if (!lstDigitalDates.isEmpty()) {
                delete lstDigitalDates;                   
            }
            
            //delete product versions if not empty
            if (!lstProdVersionToDelete.isEmpty()) {
                delete lstProdVersionToDelete;
            }
            
            //delete product pricing
            if (!lstProdPricingToDelete.isEmpty()) {
                delete lstProdPricingToDelete;
            }
            
            //delete product accounts if not empty
            if (!lstProdAccountToDelete.isEmpty()) {
                delete lstProdAccountToDelete;
            }
            
            //delete bonus account if not empty
            if (!lstBonusAccountToDelete.isEmpty()) {
                delete lstBonusAccountToDelete;
            }
            
            //delete Bonus records
            if (!lstBonusToDelete.isEmpty()) {
                delete lstBonusToDelete;
            }
            
            //delete products 
            if (!lstProdsToDelete.isEmpty()) {
                delete lstProdsToDelete;
            }
            
            //deleting digital release
            delete deletetableDigitalRelease;
        }        
    }
    
    /***********************************
    Method Name: commitRecords
    Purpose: method for DML
    ***********************************/
    public static void commitRecords(){
        
        //inserting records
        if (!insertDigitalRelease.isEmpty()) {
            //DFOR-1472 Duplicate Releases -  Additional Check before Inserting.
            removeDupeRecords();
            insert insertDigitalRelease;
            
            //updating digital release Id on release force release
            updateDGReleaseIdOnRFRelease();
        }

        if (!mapUpdateDigitalRelease.isEmpty()) {
            system.debug('ETL testing');
            //update mapUpdateDigitalRelease.values();
            //USST-3106 --- start
            if (UserInfo.getProfileId() == Label.PlatformApiProfileId) {
                DGF_TriggerUtility.InformaticaUpdate = TRUE;            
            }
            Database.SaveResult[] srList = Database.update(mapUpdateDigitalRelease.values(), false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated digital Release: ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error in Digital Release update : '+ sr.getId() + ': ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
            DGF_TriggerUtility.InformaticaUpdate = FALSE;
            //USST-3106 --- end
        }
        system.debug('mapUpdateDigitalRelease.values() is ' + mapUpdateDigitalRelease.values());
    }
    
    
    /***********************************
    Method Name: removeDupeRecords
    Purpose: method for checking Duplicates before Inserting 
    ***********************************/
    public static void removeDupeRecords(){ 
        set<id> releaseIdSet = new set<id>();
        Map<id, digital_release__c> releaseIdDigiMap =  new Map<id, digital_release__c>();
            
        if (!insertDigitalRelease.isEmpty()){
                                    
            list<digital_release__c> resultList = new list<digital_release__c>();
            System.debug('ITR1 Before Dupe Size::' + insertDigitalRelease.size());
            if (!insertDigitalRelease.isEmpty()){
                for(digital_release__c dg : insertDigitalRelease){
                    id releaseId = dg.US_Release__c!=null? dg.US_Release__c : dg.CA_Release__c;
                    System.debug('ITR1RELEASE ID??' + releaseId);
                    if(releaseId!=null){
                        if(!releaseIdDigiMap.containsKey(releaseId)){
                            releaseIdDigiMap.put(releaseId, dg);
                        }else{
                            System.debug('ITR1Duplicate Found>>' + releaseId );
                        }
                    }                   
                }               
                if(releaseIdDigiMap.size()>0){
                    insertDigitalRelease.clear();
                    insertDigitalRelease.addAll(releaseIdDigiMap.values());
                    System.debug('ITR1 After Dupe Size::' + insertDigitalRelease.size());
                }
                
            
                if(releaseIdDigiMap.size()>0){
                    set<Id> attachedReleaseId = new set<id>();
                                        
                    releaseIdSet = releaseIdDigiMap.keyset();
                    
                    List<digital_release__c> digiList = [select id,US_Release__c,CA_Release__c from digital_release__c where (US_Release__c = :releaseIdSet or CA_Release__c = :releaseIdSet) ];
                    if(digiList!=null && digiList.size()>0){                        
                        for(digital_release__c dg : digiList){
                            id releaseId = dg.US_Release__c!=null? dg.US_Release__c : dg.CA_Release__c;                         
                            System.debug('List ITR2RELEASE ID??' + releaseId);
                            if(releaseId!=null){
                                attachedReleaseId.add(releaseId);
                            }                           
                        }
                        if(attachedReleaseId.size()>0){
                            
                            for(id digiId: attachedReleaseId){
                                System.debug('SET ITR2 RELEASE ID??' + digiId);
                                if(releaseIdDigiMap.containsKey(digiId)){
                                    releaseIdDigiMap.remove(digiId);
                                    System.debug('ITR2Duplicate Found>>' + digiId );
                                }
                            }                           
                        }                       
                        
                        if(releaseIdDigiMap.size()>0){
                            insertDigitalRelease.clear();
                            insertDigitalRelease.addAll(resultList);
                            
                        }else{
                            insertDigitalRelease.clear();
                        } 
                        System.debug('ITR2 After Dupe Size::' + insertDigitalRelease.size());   
                    } 
                }                    
            }
        }
        System.debug('FINAL  removeDupeRecords insertDigitalRelease>>' + insertDigitalRelease);
        
    }
    
    
    /***********************************
    Method Name: resetDataSet
    Purpose: clear collection
    ***********************************/
    public static void resetDataSet() {        
        insertDigitalRelease.clear();       
        updateDigitalRelease.clear();
        mapUpdateDigitalRelease.clear();
        mails.clear();
        lstUserDetails.clear();
        setBrandGroup.clear();
        setOwnerId.clear();
    }
    
    /***********************************
    Method Name: updateDGReleaseIdOnRFRelease
    Purpose: update digitalforce release Id on release force release
    ***********************************/
    public static void updateDGReleaseIdOnRFRelease(){
        //if insertable list not empty
        if (!insertDigitalRelease.isEmpty()) {
            
            //looping over insertable list
            for (Digital_Release__c dg : insertDigitalRelease) {
                //creating an instance of release
                Release__c rel = new Release__c();
                
                //setting release ID
                if (dg.US_Release__c != null) {
                    rel.id = dg.US_Release__c;
                }               
                else if (dg.CA_Release__c != null) {
                    rel.id = dg.CA_Release__c;
                }
                
                //setting digitalforce release ID
                rel.Digital_Release__c = dg.Id;
                
                //adding instance to list
                updateRFRelease.add(rel);               
            }
            
            //updating releaseforce release with digitalforce release ID
            if (!updateRFRelease.isEmpty()) {
                DGF_TriggerUtility.executeReleaseTrigger = FALSE;
                Update updateRFRelease;
            }
        }
    }
    
    /***********************************
    Method Name: getDigitalReleaseDetails
    Purpose: get release details
    ***********************************/
    public static void getDigitalReleaseDetails(/*Set<Id> setDGid,*/ string trgContext) {        
        //getting digital release details in a map
       
        if (setDigitalReleaseID != null && setDigitalReleaseID.size() > 0) {
            //USST-3106 --- start
            if (trgContext == DGF_Constants.AFTER_UPDATE) {
                mapDigitalReleaseDetails = new Map<Id,Digital_Release__c>([Select Id,Name,US_Release__c,CA_Release__c from Digital_Release__c where ID in: setDigitalReleaseID FOR UPDATE]);
            }
            else {
                mapDigitalReleaseDetails = new Map<Id,Digital_Release__c>([Select Id,Name,US_Release__c,CA_Release__c from Digital_Release__c where ID in: setDigitalReleaseID]);
            }
            //USST-3106 --- end
        }  
        
        //getting chatter group id
        if (trgContext == DGF_Constants.AFTER_UPDATE) {
            chatterGroupId = [SELECT Id,Name From CollaborationGroup WHERE Name =:DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP OR NAME=:DGF_Constants.DD_OPS_USER_CHATTER_GROUP];
            
            chatterGroupMembers = [Select MemberId,Member.name,Member.Email from CollaborationGroupMember where CollaborationGroupId in: chatterGroupId ];
            
            //getting user details based on brand group or record owner
            if (setBrandGroup != null || setOwnerId != null) {
                lstUserDetails = [Select id, name, Email, Brand_Group__c from User where ID in: setOwnerId OR Brand_Group__c =:setBrandGroup];
            }       
        }
    }
    
    /***********************************
    Method Name: addChatterPost
    Purpose: for adding chatter post
    ***********************************/
    public static void createEmailInstance(string strPostReason, string mailSubject, string initiationPoint, string brandGroup, Id recordOwnerId) {
        
        //set to check if email has already been added
        Set<string> setEmailAdded = new Set<string>();
        List<string> lstEmail = new List<string>();
        //if chatter group or user list is not empty        
        if (!chatterGroupMembers.isEmpty() || !lstUserDetails.isEmpty()) {
            //creating an instance of email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(mailSubject);
            
            //looping over chatter group members
            for(CollaborationGroupMember grpMember: chatterGroupMembers){
                //if email id has not been added already
                if (!setEmailAdded.contains(grpMember.Member.Email)) {
                    lstEmail.add(grpMember.Member.Email);
                    //mail.setToAddresses( new List<String>{grpMember.Member.Email});
                    setEmailAdded.add(grpMember.Member.Email);
                }                
            }  
            
            //if logic is for both user and group
            if (initiationPoint == 'BOTH_GROUP_AND_USER' && !lstUserDetails.isEmpty()) {
                //looping over user list
                for (User u : lstUserDetails) {
                    //if email id has not been added already
                    if (!setEmailAdded.contains(u.Email) && (u.Brand_Group__c == brandGroup || u.Id == recordOwnerId)) {
                        lstEmail.add(u.Email);
                        //mail.setToAddresses( new List<String>{u.Email});
                        setEmailAdded.add(u.Email);
                    }   
                }
            }
            //settting to address and html body
            mail.setToAddresses(lstEmail);
            mail.setHtmlBody(strPostReason); 
            mails.add(mail);            
        }
    }
}