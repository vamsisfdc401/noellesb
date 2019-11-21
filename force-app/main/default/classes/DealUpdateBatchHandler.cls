/*****************************************************************************************
Class Name: DealUpdateBatchHandler 
Purpose: Apex class for handling batch material update on title default deal update.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/10/2017           Suman Kundu              Initial Development
******************************************************************************************/
global class DealUpdateBatchHandler implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> titleIds;
    private Map<String, Origin_Code__c> originCodeMap;
    private Map<Id, Deal__c> titleDealMap;
    global Set<Id> processingMaterialIds = new Set<Id>();
    
    // Parameterized constructor.
    global DealUpdateBatchHandler(Set<Id> titleIds, Map<Id, Deal__c> titleDealMap) {
        this.titleIds = titleIds;
        this.titleDealMap = titleDealMap;
    }
    
    // Interface start method to grab total context list.
    global List<SObject> start(Database.BatchableContext info) { 
        prepareOriginCodeMap();
        return fetchAssociatedMaterials();
    }
    
    // Interface execute method to perform actual operation.
    global void execute(Database.BatchableContext info, List<Material__c> scope) {
        TriggerUtility.initiatedFromDeal = true;
        TriggerUtility.executeQueueable = false;
        TriggerUtility.checkFromQueueable = true;
        Map<Id, Set<Id>> parentChildMap = new Map<Id, Set<Id>>();
        
        // Fetching the child components from context FERTs.
        for(BOM_Item__c bom : [SELECT Id, Material_Component__c, Material_Component__r.Material_Status__c, Material__c
                               FROM BOM_Item__c
                               WHERE Material__c IN: scope AND
                                    (Material_Component__r.Material_Status__c = 'Draft' OR Material_Component__r.Material_Status__c = 'Sent Back' OR 
                                     Material_Component__r.Material_Status__c = 'Submitted') AND (Material_Component__r.Material_Type__c =  'ROH' OR 
                                     Material_Component__r.Material_Type__c = 'Z009') AND Material_Component__r.Deal__c = null]) { // Changed for Deal
            if (!parentChildMap.containsKey(bom.Material__c)) {
                parentChildMap.put(bom.Material__c, new Set<Id>());
            }
            parentChildMap.get(bom.Material__c).add(bom.Material_Component__c);
        }
        
        Map<Id, Material__c> updateableMaterials = new Map<Id, Material__c>();
        List<Id> matIds = new List<Id>();
        // Executing over the context FERTs to update deal changes.
        for (Material__c mat : scope) {
            if (mat.Title__c != null && titleDealMap.containsKey(mat.Title__c)) {
                mat.Deal__c = titleDealMap.get(mat.Title__c).Id;
                mat.Deal_ID__c = titleDealMap.get(mat.Title__c).Deal_ID__c; //USST-2728
                if(titleDealMap.get(mat.Title__c).Label_Code__c != null) {
                    mat.Label_Code__c = titleDealMap.get(mat.Title__c).Label_Code__c;
                    //DF-02152 begin
                    // Modified for REL-136 --START
                    if (titleDealMap.get(mat.Title__c).Origin_Code__c != null && 
                        originCodeMap.containsKey(titleDealMap.get(mat.Title__c).Origin_Code__c)) {
                        //USST-2728 & USST-2669 ---- start
                        if (originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c != null
                            && originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c != ''
                            && originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c == mat.Deal_ID__c) {
                            system.debug('Enter 2728');
                            mat.Label_Code__c = originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Label_Code_2__c;
                            mat.Sub_Label_Code_Lookup__c = originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Sub_Label_Code_2__c;
                        }
                        else {
                        system.debug('Enter 2728');
                            mat.Label_Code__c = originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Label_Code__c;
                            mat.Sub_Label_Code_Lookup__c = originCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Sub_Label_Code__c;
                        }
                        //USST-2728 & USST-2669 ---- end
                    }
                    
                    // Modified for REL-136 --END
                    //DF-02152 end
                    mat.TM_Origin_Code__c = titleDealMap.get(mat.Title__c).Origin_Code__c; //usst-2477
                    mat.Legal_Owner__c = titleDealMap.get(mat.Title__c).Legal_Owner__c; //usst-2477
                    mat.Financial_Owner__c = titleDealMap.get(mat.Title__c).Financial_Owner__c; //usst-2477
                }
                
                matIds.add(mat.Id);
                updateableMaterials.put(mat.Id, mat);
                processingMaterialIds.add(mat.Id);
                
                // Checking for child components
                if (parentChildMap.containsKey(mat.Id)) {
                    for (Id childCompId : parentChildMap.get(mat.Id)) {
                        updateableMaterials.put(childCompId, new Material__c(Id=childCompId, Label_Code__c=mat.Label_Code__c));
                        matIds.add(childCompId);
                        processingMaterialIds.add(childCompId);
                    }
                }
            }
        }
        
        // Commiting changes in Database. // Changed for Deal
        if (updateableMaterials.size() > 0) {
            // Checking if any material is in locked status, then unlock records.
            if (matIds.size() > 0) {
                List<Id> unlockingIds = new List<Id>();
                Map<Id, Boolean> lockingResult = Approval.isLocked(matIds);
                for (String rId : matIds) {
                    if (lockingResult.get(rId)) {
                        unlockingIds.add(Id.valueOf(rId));
                    }
                }
                
                if (unlockingIds.size() > 0) {
                    TriggerUtility.doNotExecute = true;
                    Approval.unlock(unlockingIds);
                    TriggerUtility.doNotExecute = false;
                }
            }
            
            // Switching off execute validation rule flag. // Changed for Deal
            Execute_Material_Validation_Rule__c ins = Execute_Material_Validation_Rule__c.getOrgDefaults();
            ins.Execute_Rule__c = false;
            update ins;
            
            update updateableMaterials.values();
        }
    }
    
    // Method handles the after batch process activity.
    global void finish(Database.BatchableContext info) {
        // Intiate the dependent Asynchronous Defaulting Batch Jobs.
        Database.executeBatch(new AdditionalMaterialDefaultBatchHandler(processingMaterialIds), 50);
    }
    
    // Following method prepares the map of Origin Code name and instance.
    private void prepareOriginCodeMap() {
        originCodeMap = new Map<String, Origin_Code__c>();
        for (Origin_Code__c oCode : [SELECT Sub_Label_Code__c, Label_Code__c, Origin_Code__c, Label_Code_2__c, Sub_Label_Code_2__c, Default_Deal_ID__c   
                                     FROM Origin_Code__c]) { //USST-2728 & USST-2669
            originCodeMap.put(oCode.Origin_Code__c, oCode);
        }
    }
    
    // Following method retreives the FERTs and Components related to the provided title.
    private List<Material__c> fetchAssociatedMaterials() {
        return [SELECT Id, Deal__c, Title__c, Release__c, Label_Code__c, Item_Type__c, Material_Status__c 
                FROM Material__c 
                WHERE Title__c IN :titleIds AND 
                    (Material_Status__c = 'Draft' OR Material_Status__c = 'Sent Back' OR Material_Status__c = 'Submitted') AND 
                    Item_Type__c = 'S (Single)' AND Deal__c = null]; // Changed for Deal
    }
}