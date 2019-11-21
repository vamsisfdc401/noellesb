/*****************************************************************************************
TriggerName: TriggerUtility
Purpose: Utility class for triggers
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/07/2016           Mohit                    Initial Development
******************************************************************************************/
public Class TriggerUtility{
    @testVisible
    private static boolean checkMaterialBeforeInsertTriggerExecuted = TRUE;
    @testVisible
    private static boolean checkMaterialAfterInsertTriggerExecuted = TRUE;
    @testVisible
    private static boolean checkMaterialAfterUpdateTriggerExecuted = TRUE;
    private static boolean checkBOMBeforeTriggerExecuted = TRUE;
    private static boolean checkBOMAfterTriggerExecuted = TRUE;
    private static boolean checkReleaseTriggerExecuted = TRUE;
    private static boolean checkSalesBeforeTriggerExecuted = TRUE;
    private static boolean checkSalesAfterTriggerExecuted = TRUE;
    
    public static boolean checkFromQueueable = FALSE;    // Changed for Error 
    public static boolean initiatedFromDeal = FALSE;    // Added for REL-174
    public static boolean initiatedFromMaterial = FALSE;
    public static boolean initiatedFromRelease = FALSE;
    public static boolean initiatedFromWizard = FALSE;    // Added for RE-190
    public static boolean initiatedFromFuture = FALSE;    // Added for RE-60
    public static boolean executeQueueable = TRUE;
    public static boolean checkReleaseAfterUpdateExecuted = FALSE;    
    public static Boolean isSpecialCase = FALSE;
    public static Boolean doNotExecute = FALSE;
    public static Boolean doNotExecuteOnMaterialUpdate = FALSE;
    public static Boolean doNotExecuteDefaulting = FALSE;
    public static Boolean doNotExecuteOnMaterialCloningUpdate = FALSE;
    public static Boolean allowBeforeUpdateTriggerExecution = FALSE;
    public static Boolean allowAfterUpdateTriggerExecution = FALSE;
    public static boolean checkFromTemplate = FALSE;
    public static boolean checkNotFromChild = TRUE;
    public static Boolean checkFromCloning = FALSE;
    public static Boolean checkFromMassCloneIn = FALSE;    // Added for REL-40
    public static Boolean checkMassFollow = FALSE;   //Added for REL-43
    public static Boolean checkMassChatterPost = FALSE;  //Added for REL-43
    public static Boolean checkFromUpdateMaterial = FALSE;
    public static Boolean checkFromDefaulting = FALSE;
    public static Boolean followMaterialNamingConvension = FALSE;
    public static Map<String, Set<String>> sobjectExecutedEvents = new Map<String, Set<String>>() ; 
    public static boolean checkMaterialBeforeUpdateTriggerExecuted = TRUE;
    public static boolean checkDateUpdate=FALSE;
    public static boolean checkMatGrpUpdate=FALSE;//RE-14
     public static boolean isMassUploadItmQty=FALSE;//REL-95
    
    public static User currentUser;
    
    // Static constructor to execute once in a transaction.
    static{
        currentUser = [Select id,name,email,ProfileID,Profile.Name,UserRole.Name,Label_Code__c,Brand_Group__c,Master_Data__c from User where ID =:userInfo.getUserID()];       
    }
    
    // Following method returns whether Release trigger already executed in a transaction.
    public static boolean releaseTriggerExecuted(){
        if(checkReleaseTriggerExecuted){
            if(!isSpecialCase)
                checkReleaseTriggerExecuted =false;
            return true;
        }else{
            return checkReleaseTriggerExecuted;
        }
    }
    
    // Following method returns whether Material trigger already executed in a transaction.
    public static boolean materialTriggerExecuted()
    {
        if(doNotExecute)
            return false;
        
        // Special case.
        if(allowBeforeUpdateTriggerExecution && Trigger.isBefore && Trigger.isUpdate)
        {
            return true;
        }
        else if(allowAfterUpdateTriggerExecution && Trigger.isAfter && Trigger.isUpdate)
        {
            return true;
        }
        
        // Before Insert
        if(Trigger.isBefore && Trigger.isInsert)
        {
            if(checkMaterialBeforeInsertTriggerExecuted){
                if(!isSpecialCase)
                    checkMaterialBeforeInsertTriggerExecuted = false;
                return true;
            }else{
                return checkMaterialBeforeInsertTriggerExecuted;
            }
        }
        // After Insert
        else if(Trigger.isAfter && Trigger.isInsert)
        {
            if(checkMaterialAfterInsertTriggerExecuted){
                if(!isSpecialCase)
                    checkMaterialAfterInsertTriggerExecuted = false;
                return true;
            }else{
                return checkMaterialAfterInsertTriggerExecuted;
            }
        }
        // Before Update
        else if(Trigger.isBefore && Trigger.isUpdate)
        {
            if(doNotExecuteOnMaterialUpdate)
                return false;
            
            if(checkMaterialBeforeUpdateTriggerExecuted){
                if(!isSpecialCase)
                    checkMaterialBeforeUpdateTriggerExecuted = false;
                return true;
            }else{
                return checkMaterialBeforeUpdateTriggerExecuted;
            }
        }
        // After Update
        else if(Trigger.isAfter && Trigger.isUpdate)
        {
            if(doNotExecuteOnMaterialUpdate)
                return false;
            
            if(checkMaterialAfterUpdateTriggerExecuted){
                if(!isSpecialCase)
                    checkMaterialAfterUpdateTriggerExecuted = false;
                return true;
            }else{
                return checkMaterialAfterUpdateTriggerExecuted;
            }
        }
        return true;
    }
    
    //Common method for recursive check
    public static Boolean hasTriggerExecuted(String sobjectType)
    {
        if(doNotExecute)
            return true;
        
        if(Trigger.isExecuting)
        {
            String triggerContext = '';
            if(!sobjectExecutedEvents.containsKey(sobjectType))
                sobjectExecutedEvents.put(sobjectType, new Set<String>());
            
            if(Trigger.isBefore)
                triggerContext = 'BEFORE';
            else 
                triggerContext = 'AFTER';
            
            if(Trigger.isInsert)
                triggerContext += ' INSERT';
            else if(Trigger.isUpdate)
                triggerContext += ' UPDATE';
            else if(Trigger.isDelete)
                triggerContext += ' DELETE';
            else if(Trigger.isUndelete)
                triggerContext += ' UNDELETE';
            
            if(sobjectExecutedEvents.get(sobjectType).contains(triggerContext))
                return true;
            else
            {
                sobjectExecutedEvents.get(sobjectType).add(triggerContext);
                return false;
            }
        }
        return true;
    }
    
    /*****************************************************************
    Method Name: setVariableValue
    Purpose: set's boolean variables checkMaterialBeforeUpdateTriggerExecuted or checkMaterialAfterUpdateTriggerExecuted value 
    ***************************************************************/ 
    
    public static void setVariableValue(String variableName, Boolean val)
    {
        if(variableName == 'checkMaterialBeforeUpdateTriggerExecuted')
            checkMaterialBeforeUpdateTriggerExecuted = val;
        else if(variableName == 'checkMaterialAfterUpdateTriggerExecuted')
            checkMaterialAfterUpdateTriggerExecuted = val;
    }
    /*****************************************************************
    Method Name: checkDateUpdate
    Purpose: return boolean checkDateUpdate
    ***************************************************************/
    
    public static boolean checkDateUpdate() {
        return checkDateUpdate;
    }
    /*****************************************************************
    Method Name: setcheckDateUpdate
    Purpose: set's boolean variable checkDateUpdate
    ***************************************************************/
    
    public static void setcheckDateUpdate() {
        checkDateUpdate= true;
    }
    
}