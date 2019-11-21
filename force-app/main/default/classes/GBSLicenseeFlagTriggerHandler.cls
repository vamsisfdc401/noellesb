/*****************************************************************************************
Class Name: GBSLicenseeFlagTriggerHandler
Purpose: Handler class for GBSContractTrigger and PCWorkflowTrigger
Version : 1.0
Created Date : 05/16/2018
Modified Date: 08/21/2018
Created By : Lakshmi Penamatsa
JIRA : Modified for GBS-729
******************************************************************************************/
public without sharing class GBSLicenseeFlagTriggerHandler {

    private static Id workflowRecTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get(GBSConstants.GBSPARTNEREXEMPTIONWORKFLOW).getRecordTypeId();
    private static Id licenseeRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEEACCOUNT).getRecordTypeId();

    /********************************************************
    Method Name: workFlowInsert
    Purpose: Method to Insert records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/ 
    public static void workFlowInsert(List<Workflow__c> workFlowList){
       Set<Id> licenseeIDs = new Set<Id>();
        for(Workflow__c workflow : workFlowList){
            //check for partner exemption record type of workflow record
            if(workFlow.RecordTypeId == workflowRecTypeId && workflow.Licensee__c!= null){
                licenseeIDs.add(workflow.Licensee__c); 
            }
        }
        
        //check if set is empty or null
        if(licenseeIDs != null && !licenseeIDs.isEmpty()){
            setLicenseeFlag(licenseeIDs);
        }
    }
    
    /********************************************************
    Method Name: workFlowUpdate
    Purpose: Method to Update records into Workflow__c object.
    Parameters: List<Workflow__c>,Map<Id,Workflow__c>
    Return Type: void
    *********************************************************/ 
    public static void workFlowUpdate(List<Workflow__c> workFlowList, Map<Id,Workflow__c> oldWorkFlowMap){      
        Set<Id> licenseeIDSUpdate = new Set<Id>();
        for(Workflow__c workFlow : workFlowList){
            Workflow__c oldWorkflow = oldWorkFlowMap.get(workFlow.Id);
            //check for partner exemption record type of workflow record
            if(workFlow.RecordTypeId == workflowRecTypeId || oldWorkflow.RecordTypeId == workflowRecTypeId){
                //check if licensee or action status fields are changed on workflow record                
                if(workFlow.Licensee__c != oldWorkflow.Licensee__c || oldWorkflow.Action_Status__c != workFlow.Action_Status__c){
                    // check if licensee is updated on workflow record , in order to update the licensee flag of both the new and old records
                    if(workFlow.Licensee__c != oldWorkflow.Licensee__c){
                        if(oldWorkflow.Licensee__c != null){
                            licenseeIDSUpdate.add(oldWorkflow.Licensee__c); 
                        }
                    }
                    if(workFlow.Licensee__c != null){
                        licenseeIDSUpdate.add(workflow.Licensee__c); 
                    }
                }
            }
        }
        
        //check if set is empty or null
        if(licenseeIDSUpdate != null && !licenseeIDSUpdate.isEmpty()){
            setLicenseeFlag(licenseeIDSUpdate);
        }
        
    }
    
    /********************************************************
    Method Name: workFlowDelete
    Purpose: Method to Delete records into Workflow__c object.
    Parameters: List<Workflow__c>
    Return Type: void
    *********************************************************/ 
    public static void workFlowDelete(List<Workflow__c> workFlowList){        
        Set<Id> licenseeIDs = new Set<Id>();
        for(Workflow__c workflow : workFlowList){
            //check for partner exemption record type of workflow record
            if(workFlow.RecordTypeId == workflowRecTypeId && workflow.Licensee__c != null){
                licenseeIDs.add(workflow.Licensee__c);
            }
        }
        
        //check if set is empty or null
        if(licenseeIDs != null && !licenseeIDs.isEmpty()){
            setLicenseeFlag(licenseeIDs);  
        }
    }
    
    /********************************************************
    Method Name: gbsContractInsert
    Purpose: Method to Insert records into Contract__c object.
    Parameters: List<Contract__c>
    Return Type: void
    *********************************************************/ 
    public static void gbsContractInsert(List<Contract__c> gbsContractList){
        Set<Id> licenseeIDs = new Set<Id>();
        for(Contract__c contract : gbsContractList){
            if(contract.Licensee__c!= null){
                licenseeIDs.add(contract.Licensee__c); 
            }
        }
        
        //check if set is empty or null
        if(licenseeIDs != null && !licenseeIDs.isEmpty()){
            setLicenseeFlag(licenseeIDs);
        }
    }
    
    /********************************************************
    Method Name: gbsContractUpdate
    Purpose: Method to Update records into Contract__c object.
    Parameters: List<Contract__c>,Map<Id,Contract__c>
    Return Type: void
    *********************************************************/ 
    public static void gbsContractUpdate(List<Contract__c> gbsContractList, Map<Id,Contract__c> oldGBSContractMap){
        Set<Id> licenseeIDSUpdate = new Set<Id>();
        Set<Id> contractIDset = new Set<Id>(); //USST-3150
        for(Contract__c gbsContract : gbsContractList){
            Contract__c oldGBSContract = oldGBSContractMap.get(gbsContract.Id); 
             //check if licensee or action status fields are changed on workflow record
            if(gbsContract.Licensee__c != oldGBSContract.Licensee__c || oldGBSContract.Contract_Status__c != gbsContract.Contract_Status__c || gbsContract.LMS_Flag__c != oldGBSContract.LMS_Flag__c){
                // check if licensee is updated on workflow record , in order to update the licensee flag of both the new and old records
                if(gbsContract.Licensee__c != oldGBSContract.Licensee__c){
                    //check if the contract had licensee field as null before updation
                    if(oldGBSContract.Licensee__c != null){
                        licenseeIDSUpdate.add(oldGBSContract.Licensee__c); 
                    }
                }
                 //check if the contract is updated with licensee field as null
                if(gbsContract.Licensee__c != null){
                    licenseeIDSUpdate.add(gbsContract.Licensee__c);
                }
                //USST-3150 -- start
                if (gbsContract.LMS_Flag__c != oldGBSContract.LMS_Flag__c && gbsContract.LMS_Flag__c == 'Partner Exemption - Under Review') {
                    contractIDset.add(gbsContract.Id);
                }
                //USST-3150 -- end
            }
        }
   
        //check if set is empty or null
        if(licenseeIDSUpdate != null && !licenseeIDSUpdate.isEmpty()){ 
            setLicenseeFlag(licenseeIDSUpdate);
        }
        //USST-3150 -- start
        if (contractIDset != null && !contractIDset.isEmpty()) {
            Map<Id,Product_Rights_Group__c> mapPRG = new Map<Id,Product_Rights_Group__c>([Select Id from Product_Rights_Group__c where Contract__c IN: contractIDset]);
            if (mapPRG != null && !mapPRG.isEmpty()) {
                List<Intellectual_Property_Right__c> lstIPRights = [Select Id, LMS_Flag__c from Intellectual_Property_Right__c where Product_Rights_Group__c IN: mapPRG.keySet() and LMS_Flag__c <> 'Partner Exemption - Under Review'];
                List<Product_Right__c> lstProdRights = [Select Id, LMS_Flag__c, Product_Type__c from Product_Right__c where Product_Rights_Group__c IN: mapPRG.keySet() and LMS_Flag__c <> 'Partner Exemption - Under Review'];
                List<ID> lstProdTypeIDs = new List<ID>();
                if (lstIPRights != null && !lstIPRights.isEmpty()) {
                    for (Intellectual_Property_Right__c ipRight : lstIPRights) {
                        ipRight.LMS_Flag__c = 'Partner Exemption - Under Review';
                    }
                    update lstIPRights;
                }
                if (lstProdRights != null && !lstProdRights.isEmpty()) {
                    for (Product_Right__c prodRight : lstProdRights) {
                        if (prodRight.Product_Type__c != null) {
                            lstProdTypeIDs.add(prodRight.Product_Type__c);
                        }
                        prodRight.LMS_Flag__c = 'Partner Exemption - Under Review';
                    }
                    update lstProdRights;
                }
                if (lstProdTypeIDs != null && !lstProdTypeIDs.isEmpty()) {
                    List<Product_Type__c> lstprodType = [Select Id, LMS_Flag__c from Product_Type__c where Id IN: lstProdTypeIDs and LMS_Flag__c <> 'Partner Exemption - Under Review'];
                    if (lstprodType != null && !lstprodType.isEmpty()) {
                        for (Product_Type__c prodType : lstprodType) {
                            prodType.LMS_Flag__c = 'Partner Exemption - Under Review';
                        }
                        update lstprodType;
                    }
                }
            }
        }
        //USST-3150 -- end
    }
    
    /********************************************************
    Method Name: gbsContractDelete
    Purpose: Method to Delete records into Contract__c object.
    Parameters: List<Contract__c>
    Return Type: void
    *********************************************************/ 
    public static void gbsContractDelete(List<Contract__c> gbsContractList){
        Set<Id> licenseeIDs = new Set<Id>();
        for(Contract__c contract : gbsContractList){
            if(contract.Licensee__c != null){
                licenseeIDs.add(contract.Licensee__c); 
            }
        }
        
        //check if set is empty or null
        if(licenseeIDs != null && !licenseeIDs.isEmpty()){ 
            setLicenseeFlag(licenseeIDs);
        }        
    }
    
    /********************************************************
    Method Name: setLicenseeFlag
    Purpose: Method to Update Licensee Flag field on Account object.
    Parameters: Set<Id>
    Return Type: void
    *********************************************************/
    public static void setLicenseeFlag(Set<Id> licenseeIds) {
       List<Account> accountsLicenseeFlagUpdateList = new List<Account>();
       Map<Id,List<Workflow__c>> partnerExemptionWorkFlowMap = new Map<Id,List<Workflow__c>>();
       Map<Id,List<Contract__c>> activeContractsMap = new Map<Id,List<Contract__c>>();
       Map<Id,List<Contract__c>> activeContractsLMSFlagMap = new Map<Id,List<Contract__c>>(); 
       Map<Id,List<Contract__c>> inactiveContractsMap = new Map<Id,List<Contract__c>>();
       List<Workflow__c> partnerExemptionWorkflowList = [Select Id, Licensee__c, Action_Status__c
                                                         FROM Workflow__c 
                                                         WHERE Licensee__c IN: licenseeIds 
                                                         AND RecordTypeId =: workflowRecTypeId 
                                                         AND (Action_Status__c !=: GBSConstants.GBSPARTNEREXEMPTIONDISAPPROVED)];
       List<Contract__c> activeContractsList = [Select Id, Licensee__c, Contract_Status__c, LMS_Flag__c
                                                from Contract__c 
                                                where Licensee__c IN: licenseeIds 
                                                AND (Contract_Status__c !=: GBSConstants.GBSCONTRACTSTATUSTERMINATED
                                                AND Contract_Status__c !=: GBSConstants.GBSCONTRACTSTATUSCANCELLED 
                                                AND Contract_Status__c !=: GBSConstants.GBSCONTRACTSTATUSEXPIRED)];
       List<Contract__c> inactiveContractsList = [Select Id, Licensee__c, Contract_Status__c 
                                                  from Contract__c 
                                                  where Licensee__c IN: licenseeIds 
                                                  AND (Contract_Status__c =: GBSConstants.GBSCONTRACTSTATUSTERMINATED 
                                                  OR Contract_Status__c =: GBSConstants.GBSCONTRACTSTATUSCANCELLED 
                                                  OR Contract_Status__c =: GBSConstants.GBSCONTRACTSTATUSEXPIRED)];
       
        //partner exemption work flow 
        for(Workflow__c partnerWorkFlow : partnerExemptionWorkflowList){
           
            if(partnerWorkFlow.Action_Status__c != null){
                if(!partnerExemptionWorkFlowMap.containsKey(partnerWorkFlow.Licensee__c)){
                    partnerExemptionWorkFlowMap.put(partnerWorkFlow.Licensee__c, new List<Workflow__c>{partnerWorkFlow});
                }
                else
                {
                    partnerExemptionWorkFlowMap.get(partnerWorkFlow.Licensee__c).add(partnerWorkFlow); 
                }
            }
        }
        
        //active contracts 
        for(Contract__c contract: activeContractsList){
            //active contracts with no approved factories
            if(contract.LMS_Flag__c == GBSConstants.GBSNOLMSSUBMITTED 
               || contract.LMS_Flag__c == GBSConstants.GBSLMSNOAPPROVEDFACTORIES){
                   if(!activeContractsMap.containsKey(contract.Licensee__c)){
                       activeContractsMap.put(contract.Licensee__c, new List<Contract__c>{contract});
                   }
                   else
                   {
                       activeContractsMap.get(contract.Licensee__c).add(contract); 
                   }   
               }
            else{
                //active contracts - added for GBS-729 
                if(!activeContractsLMSFlagMap.containsKey(contract.Licensee__c)){
                    activeContractsLMSFlagMap.put(contract.Licensee__c, new List<Contract__c>{contract});
                }
                else
                {
                    activeContractsLMSFlagMap.get(contract.Licensee__c).add(contract); 
                }   
            }
            
        }
        
        //inactive contracts 
         for(Contract__c contract: inactiveContractsList){
            if(!inactiveContractsMap.containsKey(contract.Licensee__c)){
                inactiveContractsMap.put(contract.Licensee__c, new List<Contract__c>{contract});
            }
            else
            {
                inactiveContractsMap.get(contract.Licensee__c).add(contract); 
            } 
        }
        
        for(Id licenseeId : licenseeIds){ 
            Account acc = new Account(Id = licenseeId);
            Set<String> partnerExemptionSet = new Set<String>();
            //check partner exemption workflow
            if(partnerExemptionWorkFlowMap.get(licenseeId) != null) {
                //added for GBS-632
                for(WorkFlow__c partnerExemptionworkFlow : partnerExemptionWorkFlowMap.get(licenseeId)){
                    partnerExemptionSet.add(partnerExemptionworkFlow.Action_Status__c);
                }
                
                if(partnerExemptionSet.contains(GBSConstants.GBSPARTNEREXEMPTIONAPPROVED)){
                    acc.Licensee_Flag__c = 'Exempt Partner'; 
                }
                else if(partnerExemptionSet.contains(GBSConstants.GBSPARTNEREXEMPTIONAPPROVEDCONDITIONALLY)){
                    acc.Licensee_Flag__c = 'Partner Exemption - Conditionally Approved'; 
                }else{
                    acc.Licensee_Flag__c = 'Partner Exemption - Under Review'; 
                }
                
            }
            // to check for Active contracts with LMS Flag other than No Approved Factories/No LMS's Submitted            
            else if(activeContractsLMSFlagMap.get(licenseeId) != null) {
                acc.Licensee_Flag__c = '';
            }
            // to check for Active contracts with LMS Flag - No Approved Factories/No LMS's Submitted
            else if(activeContractsMap.get(licenseeId) != null) { 
                acc.Licensee_Flag__c = 'No Approved Factories'; // modified for GBS-762
            }
            // to check for Inactive contracts
            else if(inactiveContractsMap.get(licenseeId) != null) {  
                acc.Licensee_Flag__c = 'No Active Contracts';
            }           
            else {
                acc.Licensee_Flag__c = '';
            }
         accountsLicenseeFlagUpdateList.add(acc);
        }
        
        //check if list is empty or null
        if(accountsLicenseeFlagUpdateList.size() > 0 && accountsLicenseeFlagUpdateList !=null){
            update accountsLicenseeFlagUpdateList;            
        }
    }
    
  
}