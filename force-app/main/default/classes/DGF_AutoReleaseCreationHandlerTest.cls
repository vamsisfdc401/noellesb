/***********************************************************************************
Class Name: DGF_AutoReleaseCreationHandlerTest
Purpose: Test class for apex class DGF_AutoReleaseCreationHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/05/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class DGF_AutoReleaseCreationHandlerTest {
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario1(){
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable releases syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //enable digital release syncing
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;        
        
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_US,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insert insertRFRelease;
        
        test.startTest();
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                insertRFRelease[0].Brand_Group__c = 'None';
                insertRFRelease[0].Digital__c = FALSE;
                insertRFRelease[0].Digital_Release__c = null;
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            try {
                DGF_TriggerUtility.executeReleaseTrigger = TRUE;
                insertRFRelease[0].Brand_Group__c = DGF_Constants.BG_1440;
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            try{
                delete insertRFRelease;
            }
            catch(exception ex){
            }            
            
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario2
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario2() {
        
        //creating title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable release syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //creating release field mapping
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;  
        
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_CDN,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insert insertRFRelease;
        
        test.startTest();
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                insertRFRelease[0].Brand_Group__c = 'None';
                insertRFRelease[0].Digital__c = FALSE;
                insertRFRelease[0].Digital_Release__c = null;
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            try {
                DGF_TriggerUtility.executeReleaseTrigger = TRUE;
                insertRFRelease[0].Brand_Group__c = DGF_Constants.BG_1440;
                insertRFRelease[0].Distributor__c = '12';
                update insertRFRelease;
            }
            catch (exception ex) {
            }
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario3
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario3(){
        
        //creating title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //creating digital release
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //creating release field mapping
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;  
        
        //creating release
        Id recordTypeIDCompetitveRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_COMPETITIVE).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_US,recordTypeIDCompetitveRF,insertTitle[0].ID);
        insert insertRFRelease;
        
       test.startTest();
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                insertRFRelease[0].Brand_Group__c = 'None';
                insertRFRelease[0].Digital__c = FALSE;
                insertRFRelease[0].Digital_Release__c = null;
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            try {
                DGF_TriggerUtility.executeReleaseTrigger = TRUE;
                insertRFRelease[0].Brand_Group__c = DGF_Constants.BG_1440;
                insertRFRelease[0].Distributor__c = '12';
                update insertRFRelease;
            }
            catch (exception ex) {
            }
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario4
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario4() {
        
        //creating title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(5);
        insert insertTitle ;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable release sync
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //create release field mapping
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;  
        
        //create release
        Id recordTypeIDCompetitveRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_COMPETITIVE).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_CDN,recordTypeIDCompetitveRF,insertTitle[0].ID);
        insert insertRFRelease;
        
        test.startTest();
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                insertRFRelease[0].Brand_Group__c = 'None';
                insertRFRelease[0].Digital__c = FALSE;
                insertRFRelease[0].Digital_Release__c = null;
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            try {
                DGF_TriggerUtility.executeReleaseTrigger = TRUE;
                insertRFRelease[0].Brand_Group__c = DGF_Constants.BG_1440;
                insertRFRelease[0].Distributor__c = '12';
                update insertRFRelease;
            }
            catch (exception ex) {
            }
            
            delete insertRFRelease;
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario5
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario5() {
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable releases syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //enable digital release syncing
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;        
        
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,null,DGF_Constants.TERRITORY_US,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insert insertRFRelease;
            

        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  

        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;
        
        insertDG[0].US_Release__c = insertRFRelease[0].Id;
        DGF_TriggerUtility.isProcessStartedFromRelease = FALSE;
        update insertDG;
        
        System.AssertEquals(TRUE,insertDG[0].US_Release__c == insertRFRelease[0].Id);
        
        insertRFRelease[0].Digital__c = TRUE;
        insertRFRelease[0].Digital_Release__c = insertDG[0].Id;
        insertRFRelease[0].Distributor__c = '12';
        update insertRFRelease;
        
        test.startTest();           
            delete insertRFRelease;
        test.stopTest();
    }
    
    /***********************************
    Method Name: scenario6
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    /*static testMethod void scenario6() {
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cg.id,MemberId = userInfo.getUserId() );
        //insert cgm;
        List<CollaborationGroup> cgList = [SELECT Id,Name From CollaborationGroup WHERE Name =:DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP OR NAME=:DGF_Constants.DD_OPS_USER_CHATTER_GROUP];
        system.debug('collabaration groups are ' + cgList );
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable releases syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //enable digital release syncing
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;        
        
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,null,DGF_Constants.TERRITORY_US,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insert insertRFRelease;
            

        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  

        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;
        
        insertDG[0].US_Release__c = insertRFRelease[0].Id;
        DGF_TriggerUtility.isProcessStartedFromRelease = FALSE;
        update insertDG;
        
        insertRFRelease[0].Digital__c = TRUE;
        insertRFRelease[0].Digital_Release__c = insertDG[0].Id;
        insertRFRelease[0].Release_Status__c = 'Materials Not Requested';
        insertRFRelease[0].Brand_Group__c = DGF_Constants.BG_1440;
        update insertRFRelease;
        
        test.startTest();   
            DGF_TriggerUtility.sobjectExecutedEvents.get('Release__c').remove('AFTER UPDATE');
            insertRFRelease[0].Release_Status__c = 'Cancelled';
            insertRFRelease[0].Distributor__c = '12';
            insertRFRelease[0].X3D__c = TRUE;
            try {
                update insertRFRelease;
            }
            catch(Exception e) {
            }
            System.AssertEquals(TRUE,insertRFRelease[0].Release_Status__c == 'Cancelled');          
            
            DGF_TriggerUtility.sobjectExecutedEvents.get('Release__c').remove('AFTER UPDATE');
            insertRFRelease[0].Digital__c = FALSE;
            insertRFRelease[0].Distributor__c = '122';          
            try {
                update insertRFRelease;
            }
            catch(Exception e) {
            }
            
            DGF_TriggerUtility.sobjectExecutedEvents.get('Release__c').remove('AFTER UPDATE');
            insertRFRelease[0].Digital__c = TRUE;
            insertRFRelease[0].Distributor__c = '122';
            insertRFRelease[0].UHD__c = TRUE;           
            try {
                update insertRFRelease;
            }
            catch(Exception e) {
            }
            System.AssertEquals(TRUE,insertRFRelease[0].Digital__c == TRUE);
        test.stopTest();
    }*/
    
    /***********************************
    Method Name: scenario7
    Purpose: method to test code for DFOR-78
    ***********************************/ 
    static testMethod void scenario7() {
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable releases syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //enable digital release syncing
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_US,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insertRFRelease[0].Digital__c = true;
        insert insertRFRelease;
        Release__c rel = [SELECT Acquisition__c,Alternate_EST_Date__c,Alternate_Physical_Street_Date__c,Alternate_VOD_Date__c,Association_Needed__c,
                A_K_A__c,Box_Office_Filter__c,Brand_Group__c,Cancel_Release__c,Component__c,CreatedById,CreatedDate,CurrencyIsoCode,Deal_ID__c,Deal_Indicator__c,
                Deal__c,Digital_PIN_Date__c,Digital_Release__c,Digital__c,Discs__c,Distribution_Rights__c,Distributor_Short_Name__c,Distributor__c,
                DOM_Box_Office_Total__c,DOM_Open_W_E_Total__c,Early_Awareness_Date__c,EST_Date__c,EST_to_BD_DVD__c,EST_to_PIN_Window__c,Expiration_Date__c,
                First_International_Release_Date__c,First_Theatrical_Date__c,Formats__c,Format_Name__c,Format__c,Genre__c,HD__c,Id,Internal_Announce_Date__c,
                INT_Box_Office_Total__c,In_Plant_Date__c,IsDeleted,Label_Code__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,Linear_Premiere_Date__c,Master_Schedule_Indicator__c,materialcount__c,Material_Counter__c,Name,
                Online_Consumer_Solicitation_Date__c,Order_of_Data__c,Original_Release_Date__c,OwnerId,Physical_Street_Date__c,Pretty_Indicator__c,
                Previous_Street_Date__c,Pre_Order_Close_Date__c,Product_Type__c,Project_Type__c,Promotion_End_Date__c,Promotion_Name_Abbreviation__c,
                Promotion_Type__c,Rating__c,RecordTypeId,Release_Migration_Key__c,Release_Patterns__c,Release_Status__c,Release_Sync__c,Release__c,RMF__c,SD__c,
                SGENNO_ReadOnly__c,SGENNO__c,Street_Date__c,Sync_Dates__c,SystemModstamp,Template_Type__c,Territory__c,Theatrical_Dates__c,Theatrical_Release_Dates__c,
                Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,Title_ID__c,Title__c,TM_Version__c,Trade_Solicitation_Date__c,UHD__c,User_Brand_Group__c,
                Visual_Format__c,VOD_Street_Date__c,V_Project_Number__c,v_Project_Required__c,v_Project__c,Windowed_Rental_Pre_Order_Close_Date__c,
                Windowed_Rental_Street_Date__c,Window_Type__c,WW_Box_Office_Total__c,X3D__c FROM Release__c
                                WHERE Id = :insertRFRelease[0].Id];
        Release__c cloneRel = rel.clone();
        cloneRel.Digital__c = false;
        DGF_QueueableRFAndDGFIntegration instanceDefaults = new DGF_QueueableRFAndDGFIntegration();
        instanceDefaults.mapReleaseNew = new Map<Id,Release__c>();
        instanceDefaults.mapReleaseOld = new Map<Id,Release__c>();
        instanceDefaults.mapReleaseNew.put(rel.Id,rel);
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;
        rel.Digital_Release__c = insertDG[0].Id;
        update rel;
        instanceDefaults.triggerContext = DGF_Constants.AFTER_INSERT;
        Id jobID = System.enqueueJob(instanceDefaults);
        test.startTest();
            instanceDefaults.mapReleaseOld.put(rel.Id,cloneRel);
            //instanceDefaults.triggerContext = DGF_Constants.AFTER_UPDATE;
            //jobID = System.enqueueJob(instanceDefaults);
            try {
                DGF_AutoReleaseCreationHandler.executeOnAfterUpdate(instanceDefaults.mapReleaseOld, instanceDefaults.mapReleaseNew, DGF_Constants.AFTER_UPDATE); 
            }
            catch(Exception ex) {
            }
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                Release__c relUpdt = new Release__c();                
                relUpdt.Id = insertRFRelease[0].Id;
                relUpdt.Release_Status__c = 'Cancelled';
                update relUpdt;
                insertDG[0].US_Release__c = null;
                insertDG[0].CA_Release__c = null; 
                update insertDG[0];
                DGF_AutoReleaseCreationHandler.executeOnAfterDelete(instanceDefaults.mapReleaseOld,DGF_Constants.AFTER_DELETE);
                instanceDefaults.triggerContext = DGF_Constants.AFTER_UPDATE;
                jobID = System.enqueueJob(instanceDefaults);
                instanceDefaults.triggerContext = DGF_Constants.AFTER_DELETE;
                jobID = System.enqueueJob(instanceDefaults);
            }
            catch (exception ex) {
            }
        test.stopTest();
    }
    static testMethod void scenario8() {
        
        //creating an instance of title
        List<Title__c> insertTitle = DGF_TestDataUtility.createTitle(1);
        insert insertTitle ;
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;        
        //creating rights
        List<Right__c> insertRight1 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','US',TRUE,1);
        List<Right__c> insertRight2 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','US',TRUE,1);
        List<Right__c> insertRight3 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'EST','CA',TRUE,1);
        List<Right__c> insertRight4 = DGF_TestDataUtility.createRights(insertTitle[0].ID,'VOD','CA',TRUE,1);
        List<Right__c> insertRight = new List<Right__c>(); 
        insertRight.addAll(insertRight1);
        insertRight.addAll(insertRight2);
        insertRight.addAll(insertRight3);
        insertRight.addAll(insertRight4);
        insert insertRight;
        
        //enable releases syncing
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_TestDataUtility.createSyncDigitalRelease(TRUE);        
        insert csSyncRelease;
        
        //enable digital release syncing
        list<DGF_ReleaseFieldMapping__c> csReleaseFieldMapping = DGF_TestDataUtility.createReleaseFieldMapping();
        insert csReleaseFieldMapping;        
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        //creating release
        Id recordTypeIDTheatricalRF = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get(DGF_Constants.RT_THEATRICAL).getRecordTypeId();
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;
        List<Release__c> insertRFRelease = DGF_TestDataUtility.createRFRelease(1,DGF_Constants.BG_UNIVERSAL_PICTURES,DGF_Constants.TERRITORY_US,recordTypeIDTheatricalRF,insertTitle[0].ID);
        insertRFRelease[0].Digital__c = false;
        insertRFRelease[0].Release_Status__c = 'Materials Requested';
        insert insertRFRelease;
        Release__c rel = [SELECT Acquisition__c,Alternate_EST_Date__c,Alternate_Physical_Street_Date__c,Alternate_VOD_Date__c,Association_Needed__c,
                A_K_A__c,Box_Office_Filter__c,Brand_Group__c,Cancel_Release__c,Component__c,CreatedById,CreatedDate,CurrencyIsoCode,Deal_ID__c,Deal_Indicator__c,
                Deal__c,Digital_PIN_Date__c,Digital_Release__c,Digital__c,Discs__c,Distribution_Rights__c,Distributor_Short_Name__c,Distributor__c,
                DOM_Box_Office_Total__c,DOM_Open_W_E_Total__c,Early_Awareness_Date__c,EST_Date__c,EST_to_BD_DVD__c,EST_to_PIN_Window__c,Expiration_Date__c,
                First_International_Release_Date__c,First_Theatrical_Date__c,Formats__c,Format_Name__c,Format__c,Genre__c,HD__c,Id,Internal_Announce_Date__c,
                INT_Box_Office_Total__c,In_Plant_Date__c,IsDeleted,Label_Code__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,Linear_Premiere_Date__c,Master_Schedule_Indicator__c,materialcount__c,Material_Counter__c,Name,
                Online_Consumer_Solicitation_Date__c,Order_of_Data__c,Original_Release_Date__c,OwnerId,Physical_Street_Date__c,Pretty_Indicator__c,
                Previous_Street_Date__c,Pre_Order_Close_Date__c,Product_Type__c,Project_Type__c,Promotion_End_Date__c,Promotion_Name_Abbreviation__c,
                Promotion_Type__c,Rating__c,RecordTypeId,Release_Migration_Key__c,Release_Patterns__c,Release_Status__c,Release_Sync__c,Release__c,RMF__c,SD__c,
                SGENNO_ReadOnly__c,SGENNO__c,Street_Date__c,Sync_Dates__c,SystemModstamp,Template_Type__c,Territory__c,Theatrical_Dates__c,Theatrical_Release_Dates__c,
                Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,Title_ID__c,Title__c,TM_Version__c,Trade_Solicitation_Date__c,UHD__c,User_Brand_Group__c,
                Visual_Format__c,VOD_Street_Date__c,V_Project_Number__c,v_Project_Required__c,v_Project__c,Windowed_Rental_Pre_Order_Close_Date__c,
                Windowed_Rental_Street_Date__c,Window_Type__c,WW_Box_Office_Total__c,X3D__c FROM Release__c
                                WHERE Id = :insertRFRelease[0].Id];
        Release__c cloneRel = rel.clone();       
        insert cloneRel;
         cloneRel.Digital__c = false;
        cloneRel.Release_Status__c='Cancelled';
        cloneRel.Digital_Release__c = insertDG[0].Id;
        update cloneRel;
        DGF_QueueableRFAndDGFIntegration instanceDefaults = new DGF_QueueableRFAndDGFIntegration();
        instanceDefaults.mapReleaseNew = new Map<Id,Release__c>();
        instanceDefaults.mapReleaseOld = new Map<Id,Release__c>();
        instanceDefaults.mapReleaseNew.put(rel.Id,cloneRel);system.debug('Release_Status__c '+instanceDefaults.mapReleaseNew.get(rel.Id).Release_Status__c);
        
        rel.Digital_Release__c = insertDG[0].Id;
        update rel;
        instanceDefaults.triggerContext = DGF_Constants.AFTER_INSERT;
        Id jobID = System.enqueueJob(instanceDefaults);
        test.startTest();
            instanceDefaults.mapReleaseOld.put(rel.Id,rel);system.debug('Release_Status__c '+instanceDefaults.mapReleaseOld.get(rel.Id).Release_Status__c);
            //instanceDefaults.triggerContext = DGF_Constants.AFTER_UPDATE;
            //jobID = System.enqueueJob(instanceDefaults);
            try {
                DGF_AutoReleaseCreationHandler.executeOnAfterUpdate(instanceDefaults.mapReleaseOld, instanceDefaults.mapReleaseNew, DGF_Constants.AFTER_UPDATE); 
            }
            catch(Exception ex) {
            }
            System.AssertEquals(TRUE,insertRFRelease[0].Brand_Group__c == DGF_Constants.BG_UNIVERSAL_PICTURES);
            //updating release
            try {
                Release__c relUpdt = new Release__c();                
                relUpdt.Id = insertRFRelease[0].Id;
                relUpdt.Release_Status__c = 'Cancelled';
                update relUpdt;
                insertDG[0].US_Release__c = null;
                insertDG[0].CA_Release__c = null; 
                update insertDG[0];
                DGF_AutoReleaseCreationHandler.executeOnAfterDelete(instanceDefaults.mapReleaseOld,DGF_Constants.AFTER_DELETE);
                instanceDefaults.triggerContext = DGF_Constants.AFTER_UPDATE;
                jobID = System.enqueueJob(instanceDefaults);
                instanceDefaults.triggerContext = DGF_Constants.AFTER_DELETE;
                jobID = System.enqueueJob(instanceDefaults);
            }
            catch (exception ex) {
            }
        test.stopTest();
    }
}