/***********************************************************************************
Class Name: DGF_TriggerUtility
Purpose: Utility class for digitalforce triggers
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             24/04/2017           Mohit                    Initial Development
******************************************************************************************/
public Class DGF_TriggerUtility{
    
    /****private declarations****/
    @testVisible private static string testChatterGroup = 'TEST CLASS CHATTER GROUP';
    
    /****public declarations****/
    public static Map<String, Set<String>> sobjectExecutedEvents = new Map<String, Set<String>>() ;     
    public static User currentUser;
    public static Set<String> setProductType = new Set<String>();
    public static Set<String> setTerritory = new Set<String>();
    public static Set<String> setResolution = new Set<String>();
    public static Set<String> setPlatform = new Set<String>();
    public static Set<String> setCategory = new Set<String>();
    public static Boolean productriggerExecuted=true;
    public static Date priceEffectiveDate;
    public static Map<ID, Map<string,string>> mapOldPlatformOffering =  new Map<ID, Map<string,string>> ();
    public static Boolean checkPricingUniqueness = TRUE;
    public static Boolean executeReleaseTrigger = TRUE;
    public static Boolean executePricingTrigger = TRUE;
    public static Boolean isTestRunning = TRUE;
    public static Boolean isProcessStartedFromRelease = FALSE;
    public static Boolean isBulkReprice = False;
    public static Map<ID, string> mapOfProductBulkReprice =  new Map<ID, string> ();
    public static Boolean isCloningProcess = FALSE;
    public static Boolean isBeforeUpdate = FALSE;
    public static Boolean isChatterPostRequired = FALSE;
    public static Boolean isTVPricing = TRUE;
    public static Boolean isCalledFromDigitalTriggerHandler = False;
    public static Boolean isBonusTriggerExecuted = FALSE;
    public static Boolean isProductCreatedAutomatically = FALSE;
    public static Boolean dontDefaultTPRPrices = FALSE;
    public static List<FeedItem> lstFeedItemDeleteEvent = new List<FeedItem>();
    public static CollaborationGroup chatterGroup;
    public static List<CollaborationGroup> lstChatterGroup = new List<CollaborationGroup>();
    public static Boolean getDataSetFromBatch = FALSE;
    public static Boolean runOnce = FALSE;
    public static Boolean executeDigitalReleaseTrigger = TRUE;
    //DFOR-1272: below variable has been created to prevent queueable job getting added to the queue multiple times
    public static Boolean isJobAdded = FALSE;
    //DFOR-1297 CDN changes not flowing to digital release
    public static Set<Id> recordProcessedSet = new Set<Id>();
    public static Boolean InformaticaUpdate = FALSE; //USST-3106
    
    // Static constructor to execute once in a transaction.
    static {
        currentUser = [Select id, name, email, ProfileID, Profile.Name, UserRole.Name from User where ID =:userInfo.getUserID()];       
    }    
    
    //getting ID of chatter group
    
    static {
        if(Test.isRunningTest()){
            lstChatterGroup = [SELECT Id,Name From CollaborationGroup WHERE Name =:testChatterGroup];
        }else{
            lstChatterGroup = [SELECT Id,Name From CollaborationGroup WHERE Name =:DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP LIMIT 1];
        }        
        
        if(!lstChatterGroup.isEmpty()){
            chatterGroup = lstChatterGroup[0];
        }
    }
    
    /**************************************
    Method Name: hasTriggerExecuted
    Purpose: Common method for recursive check
    **************************************/
    public static Boolean hasTriggerExecuted(String sobjectType) {
        //if trigger is executing
        if (Trigger.isExecuting) {
            String triggerContext = '';
            
            //check if map already contains object 
            if (!sobjectExecutedEvents.containsKey(sobjectType)) {
                sobjectExecutedEvents.put(sobjectType, new Set<String>());
            }
            
            //checking trigger context
            if (Trigger.isBefore) {
                triggerContext = 'BEFORE';
            }                
            else {
                triggerContext = 'AFTER';
            }                 
            
            if (Trigger.isInsert) {
                triggerContext += ' INSERT';
            }                
            else if (Trigger.isUpdate) {
                triggerContext += ' UPDATE';
            }                
            else if (Trigger.isDelete) {
                triggerContext += ' DELETE';
            }                
            else if (Trigger.isUndelete) {
                triggerContext += ' UNDELETE';
            }                
            
            //updating map with trigger context
            if (sobjectExecutedEvents.get(sobjectType).contains(triggerContext)) {
                return true;
            }
            else {
                sobjectExecutedEvents.get(sobjectType).add(triggerContext);
                return false;
            }
        }
        return true;
    }    
    /**************************************
    Method Name: hasRecordProcessed
    Purpose: purpose to find is a record is already processed
    **************************************/
    public static boolean hasRecordProcessed(Id recordId) {
        if (Trigger.isExecuting) {
            if(recordProcessedSet.contains(recordId)) {
                return true;
            }
            else {
                recordProcessedSet.add(recordId);
                return false;
            }
        }
        return true;
    }
}