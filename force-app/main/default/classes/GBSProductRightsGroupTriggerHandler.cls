/*****************************************************************************************
Class Name: GBSProductRightsGroupTriggerHandler
Purpose: Handler class for GBSProductRightsGroupTrigger
Version : 1.0
Created Date : 04/26/2018
Created By : Lakshmi Penamatsa
Modified By : Harsha Polepalli, 05/07/2018
JIRA : GBS-14
******************************************************************************************/
public without sharing class GBSProductRightsGroupTriggerHandler {
    
    /********************************************************
    Method Name: productRightsGroupInsert
    Purpose: Method to Insert records into Contract_Agent_Contact__c junction object.
    Parameters: List<Product_Rights_Group__c>
    Return Type: void
    *********************************************************/ 
    public static void productRightsGroupInsert(List<Product_Rights_Group__c> productRightsGroupList){
        Map<String, Set<String>> ContractIdToTerritoriesMap = new Map<String, Set<String>>();
        Map<String, String> contractIdToAccountIdMap = new Map<String, String>();
        Map<String, List<Contact>> accountIdToContactsMap = new Map<String, List<Contact>>();
        Set<String> existingContractContactAssociations = new Set<String>();
        List<Contract_Agent_Contact__c> contactContractAssociations = new List<Contract_Agent_Contact__c>();
        
        //  Iterate through Product Groups Right data
        for(Product_Rights_Group__c PRG : productRightsGroupList) {
            //  Prepare a map with ContractId as key and Territoties as value
            if(PRG.Territories__c != null) {
                if(!ContractIdToTerritoriesMap.containsKey(PRG.Contract__c))
                    ContractIdToTerritoriesMap.put(PRG.Contract__c, new Set<String>(PRG.Territories__c.split(';')));
                else
                    ContractIdToTerritoriesMap.get(PRG.Contract__c).addAll(PRG.Territories__c.split(';'));
            }
        }
        
        //  Query and iterate through Contracts whose Ids in Map1's keyset
        for(Contract__c contract : [Select Id, Agent__c From Contract__c Where Id IN : ContractIdToTerritoriesMap.keyset() AND Agent__c != null]) {
            //  Prepare a map with ContractId as key and Contract's Account as value
            contractIdToAccountIdMap.put(contract.Id, contract.Agent__c);
        }
        
        if(contractIdToAccountIdMap.isEmpty()) return;
        
        //  Query and iterate through Contacts where AccountIds in contractIdToAccountIdMap values
        for(Contact contact : [Select Id, AccountId, Territory__c From Contact Where AccountId IN : contractIdToAccountIdMap.values()]) {
            //  Prepare a map where AccountId is key and the List<Contact> with the same account as value
            if(!accountIdToContactsMap.containsKey(contact.AccountId))
                accountIdToContactsMap.put(contact.AccountId, new List<Contact>{contact}); 
            else
                accountIdToContactsMap.get(contact.AccountId).add(contact);
        }
        
        //  Get existing Contract-Contact associations, to avoid duplicates
        for(Contract_Agent_Contact__c contractAgentContact : [Select Id, Contract__c, Contact__c From Contract_Agent_Contact__c Where Contract__c IN : ContractIdToTerritoriesMap.keyset()]) {
            existingContractContactAssociations.add(contractAgentContact.Contract__c + ':' + contractAgentContact.Contact__c);
        }
        
        //  iterate through Contract Ids collected from Product Rights group records
        for(Id contractId : contractIdToAccountIdMap.keyset()) {
            //  Get AccountId
            Id accountId = contractIdToAccountIdMap.get(contractId);
            //  Get Territories
            Set<String> contractTerritories = ContractIdToTerritoriesMap.get(contractId);
            //  Get Contacts of Contract's Account 
            List<Contact> contacts = new List<Contact>(accountIdToContactsMap.get(accountId));
            
            //  Iterate through Contacts collected above
            for(Contact contact : contacts) {
                //  Skip the iteration, if Contact has no Territories
                if(contact.Territory__c == null) continue;
                //  Get Contact's Territories
                Set<String> contactTerritories = new Set<String>(contact.Territory__c.split(';'));
                //  Take Contract's Territories into a temporary set
                Set<String> contractTerritoriesTemp = new Set<String>(contractTerritories);
                //  RemoveAll method returns TRUE if there are any common values in both the sets, FALSE otherwise
                if(contactTerritories.contains('WorldWide') || contractTerritoriesTemp.removeAll(contactTerritories)) {
                    //  Proceeds only if the current Contract-Contact is not present in the system
                    if(!existingContractContactAssociations.contains(contractId + ':' + contact.Id)) {
                        //  Create new Contract-Contact Association
                        Contract_Agent_Contact__c contactContract = new Contract_Agent_Contact__c();
                        contactContract.Contact__c = contact.Id;
                        contactContract.Contract__c = contractId;
                        contactContractAssociations.add(contactContract);
                    }
                    
                }
            }
            try {
                insert contactContractAssociations;
            }catch(DmlException e) {
                //  Log exception
                DGF_ExceptionLogController.createExceptionLog('While creating new Product Rights Group', 'GBSProductRightsGroupTriggerHandler', e.getMessage());
            }
        }
    }    
    
    /********************************************************
    Method Name: productRightsGroupUpdate
    Purpose: Method to Update records of Contract_Agent_Contact__c junction object.
    Parameters: List<Product_Rights_Group__c> , Map<Id, Product_Rights_Group__c> 
    Return Type: void
    *********************************************************/
    public static void productRightsGroupUpdate(List<Product_Rights_Group__c> productRightsGroupList, Map<Id, Product_Rights_Group__c> oldTriggerPRG){
        Map<Id, Product_Rights_Group__c> productRightsGroupIdsMap = new Map<Id, Product_Rights_Group__c>();
        
        //  Iterate through updated Product Right Group records 
        for(Product_Rights_Group__c productRightsGroup : productRightsGroupList){
            Product_Rights_Group__c productRightsGroupOld = oldTriggerPRG.get(productRightsGroup.Id);
            
            //  Check if Contract or Territory is updated 
            if(productRightsGroupOld.Contract__c != productRightsGroup.Contract__c || productRightsGroupOld.Territories__c != productRightsGroup.Territories__c) {
                //  Collect Product Right Group Id to delete all associated Contract-Contact Junction data
                productRightsGroupIdsMap.put(productRightsGroup.Id, productRightsGroup);
            }
        }
        
        //  Re-create Contract-Contact junction data
        productRightsGroupInsert(productRightsGroupIdsMap.values());
    }
}