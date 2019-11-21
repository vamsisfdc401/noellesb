/*****************************************************************************************
Class Name: GBSContractAgentContactTriggerHandler
Purpose: Apex class for GBSContractAgentContactTrigger
Version : 1.0
DateCreated : 06/13/2018
CreatedBy : Lakshmi(For GBS-467)
******************************************************************************************/
public without sharing class GBSContractAgentContactTriggerHandler {
    
    
/********************************************************************************
Method Name: buildContactEmails
Purpose: method to Concatenate Contact Emails into a field on the ContractAgentContact 
Created by : Lakshmi Penamatsa for (GBS-467)
********************************************************************************/    
    public static void buildContactEmails(List<Contract_Agent_Contact__c> contractAgentContactList){
        //Get the parent record Ids associated to trigger
        Set<Id> contractIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> allContactIds = new Set<Id>();
        
        Map<Id,Set<String>> contractContactListMap = new Map<Id,Set<String>>();
        List<Contract__c> updateContractList = new List<Contract__c>();
        
        //loop through the trigger.new  
        for(Contract_Agent_Contact__c contractAgentContact : contractAgentContactList){
            // add the contractIds and contactIds to Set
            if(contractAgentContact.Contract__c != NULL){
                contractIds.add(contractAgentContact.Contract__c);
            }
            if(contractAgentContact.Contact__c != NULL){
                contactIds.add(contractAgentContact.Contact__c);
            }                
        }
        
        
        //Get the Contract_Agent_Contact__c records related to contractIds Set
        List<Contract_Agent_Contact__c> contractContactList = [SELECT Id, Contact_Email_Updated__c, Contact__c, Contract__c FROM Contract_Agent_Contact__c WHERE Contract__c IN: contractIds];   
        
        //loop through the entire list of Contract_Agent_Contact__c and get allContactIds
        for(Contract_Agent_Contact__c contractAgentContact : contractContactList){
            allContactIds.add(contractAgentContact.Contact__c);
        }
        
        //map containing Id and contact for all the above Set - allContactIds 
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Email, HasOptedOutOfEmail FROM Contact WHERE Id IN: allContactIds]);        
        
        //loop through the entire list of contractContactList
        for(Contract_Agent_Contact__c contractAgentContact : contractContactList){
            //get the contact
            Contact contactRecord = contactMap.get(contractAgentContact.Contact__c);
            if(contactRecord != null){
                //check if contactrecord's HasOptedOutOfEmail is false
                if(contactRecord.HasOptedOutOfEmail == false && contactRecord.Email != null){
                    if(!contractContactListMap.containsKey(contractAgentContact.Contract__c)){
                        contractContactListMap.put(contractAgentContact.Contract__c, new Set<String>{contactRecord.Email});
                    }else{
                        contractContactListMap.get(contractAgentContact.Contract__c).add(contactRecord.Email);  
                    }
                }
            }
        }
        
        //loop through contractIds
        for(Id contractId : contractIds){
            Contract__c contract = new Contract__c(Id = contractId);
            //get the set strings from the contractContactListMap for the contract
            Set<String> contactEmailsSet = contractContactListMap.get(contractId);
            //check if contactEmailsSet is not null and not empty
            if(contactEmailsSet != null && !contactEmailsSet.isEmpty()){
                //concatenate the strings with ; and add to Agent_Contact_Emails__c of Contract__c
                contract.Agent_Contact_Emails__c = String.join((Iterable<String>)contactEmailsSet, ';');  //USST-3140
                updateContractList.add(contract); 
            }else{
                contract.Agent_Contact_Emails__c = ''; 
                updateContractList.add(contract);
            }
            
        }
        
        //check if updateContractList is not null and not empty
        if(updateContractList.size() > 0 && updateContractList !=null){
            update updateContractList;
        }
        
    }      
    
}