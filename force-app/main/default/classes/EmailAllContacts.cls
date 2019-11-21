public class EmailAllContacts {

    @InvocableMethod (Label = 'Email all CAR contacts on the account' description = 'Input should be the account you want to email "|" email template name "|" Object ID to Send this To')
    Public Static Void EmailVendors(List<String> AccountIDEmailTemplateCurrentObject)
    {
        List<String> AccountIDs = New list<String>();
        List<String> EmailTemplatesList = New list<String>();
        List<String> CurrentObjectList = New list<String>();
        System.debug('In the email vendor log ' + AccountIDEmailTemplateCurrentObject);
        
        
        For (String CurrentString : AccountIDEmailTemplateCurrentObject)
        {
            //Check to see if you were passed something valid
            If (CurrentString.contains('NO ACCOUNT'))
        	{
            	return;
        	}
            
            //Break the input apart into Account IDs and Templates
            Integer FirstSeperator = CurrentString.indexOf('|');
            Integer SecondSeperator = CurrentString.indexOf('|',FirstSeperator +1);
            System.debug(FirstSeperator + ' ' + SecondSeperator);
            
            AccountIDs.add(CurrentString.left(FirstSeperator));
            EmailTemplatesList.add(CurrentString.mid(FirstSeperator+1, SecondSeperator-FirstSeperator-1));
            CurrentObjectList.add(CurrentString.right(CurrentString.length()-SecondSeperator-1));
            System.debug('Looping Through it Account IDs ' + AccountIDs);
            System.debug('Looping Through it Templates ' + EmailTemplatesList);  
            System.debug('Looping Through Current Objects' + CurrentObjectList);
        }
        
        List<String> RecordTypes = New List<String>();
        RecordTypes.Add('CAR Vendor');
        
		//Find the list of contacts to email
        List<Contact> ContactsToEmail = EmailAllContacts.FindContacts(AccountIDs, RecordTypes);
    	//Send them an email for every template passed
    	EmailAllContacts.EmailContactsWithTemplate(ContactsToEmail, EmailTemplatesList, CurrentObjectList);
        
    }
    
	Public Static List<Contact> FindContacts(List<String> ThisAccountId, List<String> PassedRecordTypes)
    {
        //Create a blank list of contacts
        List<Contact> AllContacts = new List<Contact>();
        List<Id> AllRecordTypes = new List<Id>();
        LIst<Id> ConvertedAccountIDs = new List<Id>();
        System.debug('In the Finding Contacts');
        
        //Find all the contacts associated with the record type associated with this Account
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Contact.getRecordTypeInfosByName();
    	For (String ThisRecordType : PassedRecordTypes)
        {
            //Find the Record Type ID for the Passed Record Type and add it to this list
            AllRecordTypes.add(recordTypes.get(ThisRecordType).getRecordTypeId());
        }  
        
        //Turn the account ID into an acutal ID to be used later
        For (String FindingAccountID : ThisAccountId)
        {
            ConvertedAccountIDs.add(Id.valueof(FindingAccountID));
        }
            
        //Find all contacts associated with this record type
        Contact[] CurrentContacts = [Select Name, Email, AccountId, RecordTypeId 
                                 From Contact
                                 WHERE (RecordTypeId in :AllRecordTypes
                                 AND AccountId in :ConvertedAccountIDs)];
        AllContacts.addAll(CurrentContacts);
        
        
        System.debug('Looping Through it All Contacts ' + AllContacts);
         
        
        return AllContacts;
    }
    
    Public Static Void EmailContactsWithTemplate(List<Contact> Contacts, List<String> EmailTemplates, List<String> WhatIds)
    {
        System.debug('In the EmailContactsWithTemplate ');
        //Create a list of Converted Contacts
        List<Id> ConvertedContactIDs = new List<Id>();
        For (Contact CurrentContact : Contacts)
        {
             ConvertedContactIDs.add(CurrentContact.Id);
        }
        
        //Create a list of all Email template IDs
        List<Id> ConvertedEmailTemplateIDs = New List<Id>();
        EmailTemplate[] ActualEmailTemplates= [Select Id from EmailTemplate WHERE DeveloperName in :EmailTemplates];
        For (EmailTemplate CurrentTemplate : ActualEmailTemplates)
        {
            ConvertedEmailTemplateIDs.add(CurrentTemplate.ID);
        }
        System.debug('Converted System Template IDs ' + ConvertedEmailTemplateIDs);
        
        
        //Prepare to send everyone a message
        List<Messaging.SingleEmailMessage> MyMessages = new List<Messaging.SingleEmailMessage>();
        For (String CurrentTemplate : ConvertedEmailTemplateIDs)
        {
            For (String CurrentID : WhatIds)
            {
                For (String CurrentContact : ConvertedContactIDs)
                {
            		Messaging.reserveSingleEmailCapacity(1);
            		Messaging.SingleEmailMessage MyMessage = new Messaging.SingleEmailMessage();
            
           			MyMessage.setTemplateId(Id.valueof(CurrentTemplate));
                	MyMessage.setTargetObjectId(CurrentContact);
            		MyMessage.setWhatId(ID.valueof(CurrentID));
            		System.Debug('Current Template ' + CurrentTemplate);
            		MyMessages.add(MyMessage);
                }
            }
        }
        //Send those messages!
        Messaging.sendemail(MyMessages);
    }
    
}