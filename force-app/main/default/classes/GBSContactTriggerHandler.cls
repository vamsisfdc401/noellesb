/*****************************************************************************************
Class Name: GBSContactTriggerHandler
Purpose: Apex class for ContactTrigger
Version : 2.0
DateCreated : 4/25/2018
ModifiedDate : 07/11/2018
CreatedBy : Jay
ModifiedBy : Lakshmi(For GBS-495)
******************************************************************************************/
public class GBSContactTriggerHandler {
    
    //Get Licensee and Agent Contact recordtypes 
    
    private static Id agentContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AGENTCONTACT).getRecordTypeId();
    private static Id licenseeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
    private static Id factoryContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.FACTORYCONTACT).getRecordTypeId();
    private static Id tradeOfficeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.TRADEOFFICECONTACT).getRecordTypeId();      
    private static Id auditFirmContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AUDITFIRMCONTACT).getRecordTypeId();
    private static Id dealmakerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.DEALMAKERCONTACT).getRecordTypeId();
    private static Id gbsDefaultAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.GBSDEFAULTACCOUNT).getRecordTypeId();
       
    /********************************************************************************
Method Name: buildFactoryContactString
Purpose: method to Concatenated Factory Contacts into field on Factory (GBS-283)
********************************************************************************/
    public static void buildFactoryContactString(List<Contact> contactRecords){
        //Get the Factory Ids associated to trigger.new
        Set<Id> factoryIds = new Set<Id>();
        Contact oldContact;
        List<Factory__c> factoryList = new List<Factory__c>();
        Map<Id, String> factoryContacts = new Map<Id, String>();
        
        for (Contact con : contactRecords) {
            if(Trigger.isUpdate)
                oldContact = (Contact)Trigger.oldMap.get(con.Id);
            
            //  Checks for a value for Factory, if INSERT/DELETE event
            //  Checks if any of Email/HasOptedOutOfEmail/facotry are updated, if UPDATE event
            if(Trigger.isAfter && ((Trigger.isInsert || Trigger.isDelete) && con.Factory__c != NULL) || (Trigger.isUpdate && con.Factory__c != null && (con.Email != oldContact.Email || con.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail || con.Factory__c != oldContact.Factory__c))){
                factoryIds.add(con.Factory__c);
                
                //  If Factory is changed on Contact, then the Contacts field of old Factory is also added for processing
                if(Trigger.isAfter && Trigger.isUpdate && oldContact.Factory__c != null)
                    factoryIds.add(oldContact.Factory__c);
            }
        }
        
        //Get the Contact records related to those Factories
        List<Contact> contactList = [Select Id, Name, Phone, HasOptedOutOfEmail, Email, Factory__c from Contact WHERE Factory__c IN :factoryIds];
        
        //Concatenate Name, Phone and Email into Contacts field on factory
        for(Contact con: contactList){
            String contactDetailsText = '';
            
            if(con.HasOptedOutOfEmail == false){                 
                contactDetailsText = (!String.isBlank(con.Name) ? con.Name : '') + (!String.isBlank(con.Phone) ? ',' + con.Phone : '') + (!String.isBlank(con.Email) ? ',' + con.Email : ''); 
                
                if(!factoryContacts.containsKey(con.Factory__c))
                    factoryContacts.put(con.Factory__c, contactDetailsText);
                else
                    factoryContacts.put(con.Factory__c, factoryContacts.get(con.Factory__c) + ' || ' + contactDetailsText);
                
            }               
        }
        
        for(Id factoryId : factoryIds) {
            //  Updates Factory's Contacts field with associated Factory Contacts' details 
            if(factoryContacts.containsKey(factoryId))
                factoryList.add(new Factory__c(Id = factoryId, Contacts__c = factoryContacts.get(factoryId)));
            else    //  Updates the Factory's Contacts field to BLANK if no factory Contacts are associated 
                factoryList.add(new Factory__c(Id = factoryId, Contacts__c = ''));
                
        }
        
        update factoryList; 
    } 
    
    /********************************************************************************
Method Name: buildContactEmailAndNames
Purpose: method to Concatenate Contact Emails and Contact Names into a field on the Contact Parent 
Created by : Jay Ehrgott for (GBS-334)
Modified by : Lakshmi Penamatsa for (GBS-407)
********************************************************************************/    
    public static void buildContactEmailAndNames(){         
        
        //Get the parent record Ids associated to trigger.new
        Set<Id> factoryId = new Set<Id>();
        Set<Id> auditFirmId = new Set<Id>();
        Set<Id> tradeOfficeId = new Set<Id>();
        Set<Id> accountsId = new Set<Id>();
        
        if(Trigger.IsInsert || Trigger.IsUpdate)
        {
            for (Contact con : (List<Contact>)trigger.new){       
                if(con.Factory__c != NULL && con.RecordTypeId == factoryContactRecTypeId){
                    factoryId.add(con.Factory__c);
                }
                if(con.Audit_Firm__c!= NULL && con.RecordTypeId == auditFirmContactRecTypeId){
                    auditFirmId.add(con.Audit_Firm__c);
                }
                if(con.Trade_Office__c!= NULL && con.RecordTypeId == tradeOfficeContactRecTypeId){
                    tradeOfficeId.add(con.Trade_Office__c);
                }
                if(con.AccountId!= NULL && (con.RecordTypeId == agentContactRecTypeId || con.RecordTypeId == licenseeContactRecTypeId)){
                    accountsId.add(con.AccountId);
                }              
            }           
        }
        else if(Trigger.IsDelete)
        {
            for (Contact con : (List<Contact>)trigger.old){
                if(con.Factory__c != NULL && con.RecordTypeId == factoryContactRecTypeId){
                    factoryId.add(con.Factory__c);
                }
                if(con.Audit_Firm__c!= NULL && con.RecordTypeId == auditFirmContactRecTypeId){
                    auditFirmId.add(con.Audit_Firm__c);
                }
                if(con.Trade_Office__c!= NULL && con.RecordTypeId == tradeOfficeContactRecTypeId){
                    tradeOfficeId.add(con.Trade_Office__c);
                }
                if(con.AccountId!= NULL && (con.RecordTypeId== agentContactRecTypeId || con.RecordTypeId== licenseeContactRecTypeId)){
                    accountsId.add(con.AccountId);
                }
            }
        }              
        //Get the Contact records related to Factories(GBS Factory), Trade Offices (GBS Trade Office), Audit Firms(GBS Audit Firm), and Accounts (Licensees and Agents)
        List<Contact> factoryContactList = [Select Id, Name, Phone, Email, CC_Emails__c, FirstName, LastName, HasOptedOutOfEmail, Factory__c, RecordTypeId from Contact WHERE (Factory__c IN :factoryId)];
        List<Contact> auditFirmContactList = [Select Id, Name, Phone, Email, CC_Emails__c, FirstName, LastName, HasOptedOutOfEmail, Audit_Firm__c, RecordTypeId from Contact WHERE (Audit_Firm__c IN :auditFirmId)];
        List<Contact> tradeOfficeContactList = [Select Id, Name, Phone, Email, CC_Emails__c, FirstName, LastName, HasOptedOutOfEmail, Trade_Office__c, RecordTypeId from Contact WHERE (Trade_Office__c IN :tradeOfficeId)];
        List<Contact> accountContactList = [Select Id, Name, Phone, Email, CC_Emails__c, FirstName, LastName, HasOptedOutOfEmail, AccountId, RecordTypeId from Contact WHERE (AccountId IN :accountsId)];
        
        //construct Lists to put updated Contact Email and Contact Names string on        
        List<Factory__c> factoryList = [Select Id, Contact_Emails__c, CC_Emails_c__c, Contact_Names__c from Factory__c WHERE Id IN :factoryId];        
        List<Audit_Firm__c> auditFirmList = [Select Id, Contact_Emails__c, Contact_Names__c from Audit_Firm__c WHERE Id IN :auditFirmId];
        List<Trade_Office__c> tradeOfficeList = [Select Id, Contact_Emails__c, Contact_Names__c from Trade_Office__c WHERE Id IN :tradeOfficeId];            
        List<Account> accountList = [Select Id, Contact_Emails__c, Contact_Names__c from Account WHERE Id IN :accountsId];
        
        
        //Iterate through the Factories and Contacts to update the Contact Email and Contact Names string
        for (Factory__c factory : factoryList){
            //Reset string to blank
            factory.Contact_Emails__c  = '';
            factory.Contact_Names__c  = '';
            
            List<String> contactNamesList = new List<String>();
            List<String> contactEmailsList = new List<String>();
            //Concatenate Email into Contact Email and Contact Names field on Factory
            for(Contact con: factoryContactList){
                //included condition for recordtype check as part of GBS-708 to prevent RSGContacts from appending emails
                if(con.Factory__c == factory.Id && con.HasOptedOutOfEmail == false && con.RecordTypeId == factoryContactRecTypeId){                   
                   
                    if(con.Email != null){
                        contactEmailsList.add(con.Email);
                    }
                    
                    // added for GBS-606
                    if(con.CC_Emails__c != null){
                        contactEmailsList.add(con.CC_Emails__c);
                    }
                                       
                    if(con.FirstName != null){
                        contactNamesList.add(con.FirstName +' '+con.LastName);    
                    }else{
                        contactNamesList.add(con.LastName); 
                    }                                      
                }
            }
            
            //included for GBS-712 to concatenate ; at the end
            if(!contactEmailsList.isEmpty()){
                factory.Contact_Emails__c = String.join(contactEmailsList, ';')+';';
            }
            factory.Contact_Names__c = String.join(contactNamesList, ';');
        }
        
        //Iterate through the Audit Firms and Contacts to update the Contact Email and Contact Names string
        for (Audit_Firm__c auditFirm : auditFirmList){
            //Reset string to blank
            auditFirm.Contact_Emails__c = '';
            auditFirm.Contact_Names__c = '';
            
            List<String> contactNamesList = new List<String>();
            List<String> contactEmailsList = new List<String>();
            //Concatenate Email into Contact Email and Contact Names field on Audit Firm
            for(Contact con: auditFirmContactList){ 
                //included condition for recordtype check as part of GBS-708 to prevent RSGContacts from appending emails
                if(con.Audit_Firm__c == auditFirm.Id && con.HasOptedOutOfEmail == false && con.RecordTypeId == auditFirmContactRecTypeId){
                    if(con.Email != null){
                        contactEmailsList.add(con.Email);
                    }
                    //added for GBS-606
                    if(con.CC_Emails__c != null){
                        contactEmailsList.add(con.CC_Emails__c);
                    }
                    
                    if(con.FirstName != null){
                        contactNamesList.add(con.FirstName +' '+con.LastName);    
                    }
                    else{
                        contactNamesList.add(con.LastName); 
                    }  
                }
            }
            
            //included for GBS-712 to concatenate ; at the end
            if(!contactEmailsList.isEmpty()){
                auditFirm.Contact_Emails__c = String.join(contactEmailsList, ';')+';';
            }            
            auditFirm.Contact_Names__c = String.join(contactNamesList, ';');
        }                      
        
        //Iterate through the Trade Offices and Contacts to update the Contact Email and Contact Names string
        for (Trade_Office__c tradeOffice : tradeOfficeList){
            //Reset string to blank
            tradeOffice.Contact_Emails__c  = '';
            tradeOffice.Contact_Names__c = '';
            
            List<String> contactNamesList = new List<String>();
            List<String> contactEmailsList = new List<String>();
            //Concatenate Email into Contact Email and Contact Names field on Trade Office
            for(Contact con: tradeOfficeContactList){
                //included condition for recordtype check as part of GBS-708 to prevent RSGContacts from appending emails
                if(con.Trade_Office__c == tradeOffice.Id && con.HasOptedOutOfEmail == false && con.RecordTypeId == tradeOfficeContactRecTypeId){
                    if(con.Email != null){
                        contactEmailsList.add(con.Email);
                    }
                    
                    //added for GBS-606
                    if(con.CC_Emails__c != null){
                        contactEmailsList.add(con.CC_Emails__c);
                    }
                    
                    if(con.FirstName != null){
                        contactNamesList.add(con.FirstName +' '+con.LastName);    
                    }
                    else{
                        contactNamesList.add(con.LastName); 
                    }  
                }
            }
            //included for GBS-712 to concatenate ; at the end
            if(!contactEmailsList.isEmpty()){
               tradeOffice.Contact_Emails__c = String.join(contactEmailsList, ';')+';';
            }  
            
            tradeOffice.Contact_Names__c = String.join(contactNamesList, ';');
            
        } 
        
        //Iterate through the Accounts and Contacts to update the Contact Email and Contact Names string
        for (Account account : accountList){
            //Reset string to blank
            account.Contact_Emails__c  = '';
            account.Contact_Names__c = '';
            
            List<String> contactNamesList = new List<String>();
            List<String> contactEmailsList = new List<String>();
            //Concatenate Email into Contact Email and Contact Names field on Trade Office
            for(Contact con: accountContactList){
                //included condition for recordtype check as part of GBS-708 to prevent RSGContacts from appending emails
                if(con.AccountId == account.Id && con.HasOptedOutOfEmail == false && (con.RecordTypeId== agentContactRecTypeId || con.RecordTypeId== licenseeContactRecTypeId) ){
                    if(con.Email != null){
                        contactEmailsList.add(con.Email);
                    }
                    
                    //added for GBS-606
                    if(con.CC_Emails__c != null){
                        contactEmailsList.add(con.CC_Emails__c);
                    }
                    
                    if(con.FirstName != null){
                        contactNamesList.add(con.FirstName +' '+con.LastName);    
                    }
                    else{
                        contactNamesList.add(con.LastName); 
                    }  
                }
            }
            
            //included for GBS-712 to concatenate ; at the end
            if(!contactEmailsList.isEmpty()){
               account.Contact_Emails__c = String.join(contactEmailsList, ';')+';';
            } 
            
            account.Contact_Names__c = String.join(contactNamesList, ';');
        }               
        
        //check if list is empty or null
        if((factoryList != null && !factoryList.isEmpty()) || 
           (auditFirmList != null && !auditFirmList.isEmpty()) ||
           (tradeOfficeList != null && !tradeOfficeList.isEmpty()) || 
           (accountList != null && !accountList.isEmpty())){
               
               try{ 
                   update factoryList;       
                   update auditFirmList;        
                   update tradeOfficeList;
                   update accountList;
               }catch(DmlException e){
                   //  Log exception
                   DGF_ExceptionLogController.createExceptionLog('While Updating Factory,AuditFirm,TradeOffice,Account Record based on input from Contact record', 'GBSContactTriggerHandler.buildContactEmailAndNames', e.getMessage());
               }
           }
        
        
    }   
    
    /********************************************************************************
Method Name: setPrivateContactAccount
Purpose: method to set a generic parent Account for Factory, Trade Office, or Audit
Context:  Designed to run in after trigger
Firm Contacts that would be otherwise be private (GBS-338)
********************************************************************************/          
    public static void setPrivateContactAccount(){
        
        Account factoryDefaultAccount = [Select Id, Name, RecordTypeId from Account WHERE 
                                         (Name = :GBSConstants.DEFAULTFACTORYACCOUNT AND RecordTypeId = :gbsDefaultAccountRecTypeId)];        
        Account auditFirmDefaultAccount = [Select Id, Name, RecordTypeId from Account WHERE 
                                           (Name = :GBSConstants.DEFAULTAUDITFIRMACCOUNT AND RecordTypeId = :gbsDefaultAccountRecTypeId)];        
        Account tradeOfficeDefaultAccount = [Select Id, Name, RecordTypeId from Account WHERE 
                                             (Name = :GBSConstants.DEFAULTTRADEOFFICEACCOUNT AND RecordTypeId = :gbsDefaultAccountRecTypeId)];
        Account dealmakerDefaultAccount = [Select Id, Name, RecordTypeId from Account WHERE 
                                           (Name = :GBSConstants.DEFAULTDEALMAKERACCOUNT AND RecordTypeId = :gbsDefaultAccountRecTypeId)];
        
        
        if(Trigger.IsInsert || Trigger.IsUpdate)
        {
            List<Contact> contactList = (List<Contact>)trigger.new;
            
            for (Contact con : contactList){
                if(con.RecordTypeId == factoryContactRecTypeId){
                    con.AccountId =	factoryDefaultAccount.Id;    
                } 
                if(con.RecordTypeId == tradeOfficeContactRecTypeId){
                    con.AccountId =	tradeOfficeDefaultAccount.Id;                      
                } 
                if(con.RecordTypeId == auditFirmContactRecTypeId){
                    con.AccountId =	auditFirmDefaultAccount.Id;                      
                }
                if(con.RecordTypeId == dealmakerContactRecTypeId){
                    con.AccountId =	dealmakerDefaultAccount.Id;                      
                }
            }
        }
        
    }  
    
    /********************************************************************************
Method Name: checkContactChildRecords
Purpose: method to check if the Contact contains ContractAgentContact records
Context:  Designed to run in before trigger only in Delete
Created by : Lakshmi Penamatsa for (GBS-467)
********************************************************************************/   
    public static void checkContactChildRecords(){
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact contactRecord: (List<Contact>)Trigger.old){
            contactIds.add(contactRecord.Id);
        }
        
        List<Contract_Agent_Contact__c> contractAgentList = [select Id, Contact_Email_Updated__c, Contact__c, Contract__c FROM Contract_Agent_Contact__c
                                                             where Contact__c IN: contactIds];
        
        //map containing Id and contact for all the above Set - contactIds 
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Email, HasOptedOutOfEmail FROM Contact WHERE Id IN: contactIds]);        
        
        //loop through the entire list of contractAgentList
        for(Contract_Agent_Contact__c contractAgentContact : contractAgentList){
            //get the contact
            Contact contactRecord = contactMap.get(contractAgentContact.Contact__c);
            
            if (contractAgentContact.Contact__c == contactRecord.Id)
            {
                Trigger.oldMap.get(contactRecord.id).addError(Label.GBS_Contact_Deletion_Error_Message);
            }
        }  
    }
 
/********************************************************************************
Method Name: buildContactRecordType
Purpose: method will create a gbscontactrecordtype and update it based 
         on the object(Factory/Account/TradeOffice/AuditFirm) selected
Context:  Designed to run in before trigger only in Insert and Update
Created by : Lakshmi Penamatsa for (GBS-634)
********************************************************************************/ 
    public static void buildContactRecordType(){       
       
        if(Trigger.IsInsert || Trigger.IsUpdate){
            List<Contact> contactList = (List<Contact>)trigger.new;
           
            //forming a map with recordtypeName and recordtypeId
            Map<String,Id> mapContactRecordTypes = new Map<String,Id>{};
            mapContactRecordTypes.put(GBSConstants.AGENTCONTACT,agentContactRecTypeId);
            mapContactRecordTypes.put(GBSConstants.LICENSEECONTACT,licenseeContactRecTypeId);

            //added for account record type identification associated to the gbs contact
            Set<String> setAccID = new Set<String>();
            for (Contact contact : contactList){
                setAccID.add(contact.accountid);
            }
            
            Map<Id,Account> mapAccount = new Map<Id,Account>([Select id,RecordType.Name,RecordTypeId from Account where id in :setAccID]);
            
            for (Contact contact : contactList){
                //for GBSAgentContact and GBSLicenseeContact recordtype
                if(contact.AccountId!= NULL && mapAccount.containsKey(contact.AccountId)){
                    Account account = mapAccount.get(contact.AccountId);
                    if(mapContactRecordTypes.containsKey(account.RecordType.Name)){
                        contact.RecordTypeId = mapContactRecordTypes.get(account.RecordType.Name);
                    }
                }
                //for GBSFactoryContact recordtype
                else if(contact.Factory__c != NULL){
                    contact.RecordTypeId = factoryContactRecTypeId;                     
                }
                //for GBSTradeOfficeContact recordtype
                else if(contact.Trade_Office__c!= NULL){
                    contact.RecordTypeId = tradeOfficeContactRecTypeId;                     
                }
                //for GBSAuditFirmContact recordtype
                else if(contact.Audit_Firm__c!= NULL){
                    contact.RecordTypeId = auditFirmContactRecTypeId;                     
                }                
               
            }            
        }
    }   
    
/********************************************************************************
Method Name: checkContactChildRecords
Purpose: This method is use to create or update the Contract Agent 
         Contact based on the territory linked with contact
Context:  This method will run after insert and afer update
Created by : Amarendra Kumar (GBS-635)
********************************************************************************/
		public static void createOrUpdateContractObject() {	   
		    
		    Map<Id,List<Product_Rights_Group__c>>  accountIdToPRGListMap 
		                                           =  new Map<Id,List<Product_Rights_Group__c>>(); 
		    Set<Id> accountIdSet                   = new Set<Id>();		    
		    List<Contract_Agent_Contact__c> cACToInserted = new List<Contract_Agent_Contact__c>();
		    Set<Id> contactIdSetDelete                   = new Set<Id>();
		    
		    for(Contact contact  : (List<Contact>)Trigger.New ) {
		        if(contact.RecordTypeId == agentContactRecTypeId && contact.AccountId <> null){
		             accountIdSet.add(contact.AccountId);
		             contactIdSetDelete.add(contact.Id);
		        }
		    }
		   
		    if(contactIdSetDelete != null && contactIdSetDelete.size() > 0){
		       deleteContractAgentContact(contactIdSetDelete);
		    }
		    
		    for(Product_Rights_Group__c productRightGroupObj : [Select Contract__c,Contract__r.Agent__r.Id,Territories__c,
		                                                        Rights_Group_End_Date__c 
		                                                        from Product_Rights_Group__c where Contract__r.Agent__r.Id
		                                                        IN : accountIdSet AND Contract__r.Contract_End_Date__c > 
		                                                        TODAY]){
		                                                        	
			      if(!accountIdToPRGListMap.containsKey(productRightGroupObj.Contract__r.Agent__r.Id)){
	                   accountIdToPRGListMap.put(productRightGroupObj.Contract__r.Agent__r.Id, 
	                                                          new List<Product_Rights_Group__c>{productRightGroupObj});
			      } else {
	                   accountIdToPRGListMap.get(productRightGroupObj.Contract__r.Agent__r.Id).add(productRightGroupObj); 
			      }  			                                     	
		    
		    }
		    		    
		    for(Contact contact  : (List<Contact>) Trigger.New){
		    	
		        if(contact.RecordTypeId == agentContactRecTypeId && contact.AccountId <> null && 
		           contact.Territory__c <> null){
		        	 
		             List<String> territoryContactNames = contact.Territory__c.split(';');
		             Set<Id> contactIdSet = new Set<Id>();	
		             
		             if(accountIdToPRGListMap.get(contact.AccountId) != null && 
		               accountIdToPRGListMap.get(contact.AccountId).size() > 0){
		               	             
			               for(Product_Rights_Group__c prgObj : accountIdToPRGListMap.get(contact.AccountId)){
			               	    if(prgObj.Territories__c <> null){
				                    for(String territoryName :  prgObj.Territories__c.split(';')){
				                         if(territoryContactNames.contains(territoryName) || 
				                            territoryContactNames.contains('WorldWide')){  
				                               contactIdSet.add(prgObj.Contract__c);
				                         }
				                    }
			                   }
			             
			               } 
		              }
		             
		              if(contactIdSet <> null && contactIdSet.size()  > 0 ){
		              	  for(Id contactId : contactIdSet){
			                  cACToInserted.add(new Contract_Agent_Contact__c(Contact__c = contact.Id ,
			                                                                  Contract__c = contactId));
		              	  }
		              } 		             
		        }
		    }
		    
		    if(cACToInserted <> null && cACToInserted.size() > 0){
		        insert cACToInserted ;
		    }	    
		    
		}
		
		@TestVisible
		private static void deleteContractAgentContact(Set<Id> contactIdSet){
			if(contactIdSet <> null && contactIdSet.size() > 0){
			   List<Contract_Agent_Contact__c> contractAgentConList = [Select Id from Contract_Agent_Contact__c where
			                                                          Contact__c IN : contactIdSet];
			   
			   if(contractAgentConList <> null && contractAgentConList.size() > 0){
			       delete contractAgentConList ;
			   }                                                       
			}
		}
    
}