global class Case_EmailService_For_Email2Case implements Messaging.InboundEmailHandler{
    
    //Variables to be used across the code
    //Below three are the Email variables to be used across
    Public static String EmailSubject 	= '';
    Public static String EmailBody 		= '';
    Public static String EmailFrom 		= '';
    Public static String EmailHTML 		= '';
    Public static String CaseRecordType = '';
    
    //Below variables will be used for parsing the emails
    public Map <String, String> EmailTextToField 	= new Map <String, String>();
    public Map <String, String> FieldToValue 		= new Map <String, String>();
    public List <String> EmailTexts 				= new List <String>();
    public static Boolean MappingFound 				= false;
    public List <String> ExcelEmailText 			= new List <String>();
    //Below variable to log the errors
    public static String ErrorsDuringProcess 		= '';
    
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('Email Subject' + email.subject);
        system.debug('Email Content' + email.plainTextBody);
        system.debug('Email From' + envelope.fromAddress);
        system.debug('Email Text Attachments' + email.textAttachments);
        system.debug('Email Binary Attachments' + email.binaryAttachments);
        system.debug('Email To' + email.toAddresses);
        
        //Initialize the variables
        EmailSubject 	= String.valueOf(email.subject);
        EmailBody 		= String.valueOf(email.plainTextBody);
        EmailBody 		= EmailBody.replace('\t', ' ');
        EmailFrom 		= String.valueOf(envelope.fromAddress);
        EmailHTML 		= String.valueOf(email.htmlBody);
        system.debug('EmailBody: ' + EmailBody);
        
        Case NewCase 			= new Case();
        IdentifyRecordTypeFromEmail(String.valueOf(email.toAddresses));
        NewCase 			= CreateCase();
        //system.debug('Created Case: ' + NewCase.Id);
        
        if (NewCase != null){
            if(email.textAttachments != null){
                //Create Text Attachment records and process a CSV if found
                for (Messaging.Inboundemail.TextAttachment Attachments : email.textAttachments){
                    Attachment InComingAttachment 	= new Attachment();
                    InComingAttachment.Name 		= Attachments.fileName;
                    InComingAttachment.Body 		= Blob.valueOf(Attachments.body);
                    InComingAttachment.ParentId 	= NewCase.Id;
                    insert InComingAttachment;
                    
                    if (Attachments.fileName.indexOf('.csv') != -1){
                        system.debug('Found a CSV file to process');
                        ProcessCSVFile(Attachments.fileName, Attachments.body, NewCase.Id);
                    }
                }
            }
            
            if (email.binaryAttachments != null){
                //Create Binary Attachment records and process a CSV file if found
                for (Messaging.Inboundemail.BinaryAttachment Attachments : email.binaryAttachments){
                    Attachment InComingAttachment 	= new Attachment();
                    InComingAttachment.Name 		= Attachments.fileName;
                    InComingAttachment.Body 		= Attachments.body;
                    InComingAttachment.ParentId 	= NewCase.Id;
                    insert InComingAttachment;
                    
                    if (Attachments.fileName.indexOf('.csv') != -1){
                        system.debug('Found a CSV file to process in Binary');
                        ProcessCSVFile(Attachments.fileName, Attachments.body.toString(), NewCase.Id);
                    }
                }
            }
            //Send an acknowledgement email to the customer
            SendAcknowledgementEmail([Select CaseNumber from Case where Id = :NewCase.Id][0].CaseNumber);
        }
        return result;
    }
    
    public Case CreateCase(){
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseRecordType).getRecordTypeId();
        Case NewCase = new Case(RecordTypeId 		= RecordTypeIdCase,
                                Status 				= 'New',
                                Subject 			= EmailSubject,
                                Description 		= EmailBody,
                                SuppliedEmail 		= EmailFrom,
                                //Temporary_Field__c 	= EmailHTML,
                                Origin 				= 'Email'
                               );
        if (CaseRecordType 			== 'Price Protection'){
            NewPPCase_Values(NewCase);
        }else if (CaseRecordType 	== 'PO Discrepancies'){
            NewPODCase_Values(NewCase);
        }
        //AssociateContactAccount(NewCase);
        try{
	        insert NewCase;
	        return NewCase;
        } catch (System.DmlException e){
            system.debug('Error Inserting Case');
            ErrorsDuringProcess = 'Error Details: ';
            for (Integer i = 0; i < e.getNumDml(); i++){
                ErrorsDuringProcess = ErrorsDuringProcess + '\n' + e.getDmlMessage(i) + '\n\n';
            }
            SendErrorEmail();
        }
        return null;
    }
    
    //Identify what Record Type should be
    public void IdentifyRecordTypeFromEmail(String EmailTo){
        //Query the meta data table to fetch the record type from the email addressed to
        String EmailToLeft 		= EmailTo.left(EmailTo.length() - 1);
        EmailTo 				= EmailToLeft.right(EmailToLeft.length() - 1);
        CaseRecordType = [select Record_Type__c from Case_Email_Id__mdt where Email_Id__c = :EmailTo][0].Record_Type__c;
    }
    
    //Parse the emails and initialize the Global Map and List variables
    public void ReadEmailAndSetupMaps(){
        //Query the meta data table to fetch all Price Protection & common records
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = :CaseRecordType OR Case_Record_Type__c = 'All'];
        
        if (!MappingList.isEmpty()){
            MappingFound = true;
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                EmailTextToField.put(MetaData.Text_In_Email__c, MetaData.Field_API_Name__c);
                FieldToValue.put(MetaData.Field_API_Name__c, ParseEmailContent(MetaData.Text_In_Email__c));
                EmailTexts.add(MetaData.Text_In_Email__c);
            }
        }
    }
    
    //Associate Case to the Input Group Name
    public Case AssociateToGroup(Case CaseRecord, String GroupName){
        List <Group> GroupQuery = [SELECT Id,Name FROM Group WHERE Name = :GroupName];
        if (!GroupQuery.isEmpty()){
            CaseRecord.OwnerId 	= GroupQuery[0].Id;
        }
        return CaseRecord;
    }
    
    //Setup data for a New Price Protection Case
    public Case NewPPCase_Values(Case CaseRecord){
        try{
            //First try and process email in text format
            ReadEmailAndSetupMaps();
        } catch (Exception e){
            //If it fails, then the email is in Excel format. Try this instead
            system.debug('Now trying reading Excel format');
            ReadExcelEmailAndSetupMaps();
        }
        
        //Run the logic only if the mapping is found. Else just skip the entire thing.
        if (MappingFound){
            //These will be used for the lookups of the Contact and Account
            String EmailToLookup 		= '';
            String ContactToLookup 		= '';
            String AccountToLookup 		= '';
            String CurrentFieldName		= '';
            String CurrentFieldValue 	= '';
            
            for (String EmailTextList : EmailTexts){
                CurrentFieldName = EmailTextToField.get(EmailTextList);
                CurrentFieldValue = FieldToValue.get(CurrentFieldName);
                //Check for Program Name
                if (CurrentFieldName == 'Associated_Price_Protection_Program__c'){
                    if (CurrentFieldValue != '#N/A'){
                        CaseRecord.Territory__c = 'US';
                        List <Price_Protection_Program__c> ProgramQuery = [select Id, Territory__c from Price_Protection_Program__c where Status__c = 'Published' and program_name__c LIKE :Escape_Characters(CurrentFieldValue)];
                        if (!ProgramQuery.isEmpty()){
                            CaseRecord.Territory__c 							= ProgramQuery[0].Territory__c;
                            CaseRecord.Associated_Price_Protection_Program__c 	= ProgramQuery[0].Id;
                        }
                    }
                } else if (CurrentFieldName == EmailTextList){
                    //Logic for Lookup Fields such as Contact and Account.
                    //For these, the Text To lookup is same as the field name in the Meta Data Setup
                    //This helps identify these special fields uniquely
                    if (CurrentFieldName 	== 'Email:'){
                        EmailToLookup 		= CurrentFieldValue;
                    } else if (CurrentFieldName == 'Contact:'){
                        ContactToLookup 	= CurrentFieldValue;
                    } else if (CurrentFieldName == 'Customer:'){
                        AccountToLookup 	= CurrentFieldValue;
                    }
                } else {
                    if (CurrentFieldValue 	== '#N/A')
                        CurrentFieldValue 	= '--BLANK--';
                    CaseRecord.put (CurrentFieldName, CurrentFieldValue);
                }
            }
            //Associate Contact
            AssociateContact(CaseRecord, EmailToLookup, ContactToLookup);
            //Associate Account
            AssociateAccount(CaseRecord, AccountToLookup);
            //Assign to Price Protection cases UPHE Credit Queue
            AssociateToGroup(CaseRecord, 'Price Protection cases UPHE Credit');
        }
        return CaseRecord;
    }
    
    //Setup data for a PO Discrepancies case
    public Case NewPODCase_Values(Case CaseRecord){
        try{
            //First try and process email in text format
            ReadEmailAndSetupMaps();
        } catch (Exception e){
            //If it fails, then the email is in Excel format. Try this instead
            system.debug('Now trying reading Excel format');
            ReadExcelEmailAndSetupMaps();
        }
        //ReadEmailAndSetupMaps('PO Discrepancies');
        //Run the logic only if the mapping is found. Else just skip the entire thing.
        if (MappingFound){
            //These will be used for the lookups of the Contact and Account
            String EmailToLookup 		= '';
            String ContactToLookup 		= '';
            String AccountToLookup 		= '';
            String CurrentFieldName		= '';
            String CurrentFieldValue 	= '';
            
            for (String EmailTextList : EmailTexts){
                CurrentFieldName = EmailTextToField.get(EmailTextList);
                CurrentFieldValue = FieldToValue.get(CurrentFieldName);
                if (CurrentFieldName == EmailTextList){
                    //Logic for Lookup Fields such as Contact and Account.
                    //For these, the Text To lookup is same as the field name in the Meta Data Setup
                    //This helps identify these special fields uniquely
                    if (CurrentFieldName 	== 'Email:'){
                        EmailToLookup 		= CurrentFieldValue;
                    } else if (CurrentFieldName == 'Contact:'){
                        ContactToLookup 	= CurrentFieldValue;
                    } else if (CurrentFieldName == 'Customer:'){
                        AccountToLookup 	= CurrentFieldValue;
                    }
                } else if (CurrentFieldName == 'Territory__c'){
                    if (CurrentFieldValue 	== '#N/A')
                        CurrentFieldValue 	= 'US';
                    CaseRecord.Territory__c = CurrentFieldValue;
                } else if (CurrentFieldName == 'Billing_Date__c'){
                    if (CurrentFieldValue 	!= '#N/A'){
                        String[] DateValue 	= CurrentFieldValue.split('/');
                        try{
                            Date FormattedDate 			= Date.newInstance(Integer.valueOf(DateValue[2]), Integer.valueOf(DateValue[0]), Integer.valueOf(DateValue[1]));
                            CaseRecord.Billing_Date__c 	= FormattedDate;
                        } catch (Exception e) {
                            ErrorsDuringProcess 		= ErrorsDuringProcess + '\n' + EmailTextList + ' value received as ' + CurrentFieldValue + '. This is an invalid Date value and was skipped during processing.\nNo action required from you.';
                        }
                    }
                } else {
                    if (CurrentFieldValue 	== '#N/A')
                        CurrentFieldValue 	= '--BLANK--';
                    CaseRecord.put(CurrentFieldName, CurrentFieldValue);
                }
            }
            //Associate Contact
            AssociateContact(CaseRecord, EmailToLookup, ContactToLookup);
            //Associate Account
            AssociateAccount(CaseRecord, AccountToLookup);
            //Assign to PO Discrepancy cases UPHE Customer Ops Queue
            AssociateToGroup(CaseRecord, 'PO Discrepancy cases UPHE Customer Ops');
        }
        return CaseRecord;
    }
    
    //Associate the Contact to the Case
    public static Case AssociateContact(Case CaseRecord, String EmailToLookup, String ContactToLookup){
        //Clean up the email value to remove the <mailto:> hyperlink some email clients automatically add
        Integer MailtoFound = EmailToLookup.indexOf('<mailto:');
        if (MailtoFound 	!= -1)
            EmailToLookup 	= EmailToLookup.left(EmailToLookup.length() - MailtoFound);
        
        //Build the query
        Boolean UseOR 			= false;
        String ContactQuery 	= 'Select Id, RecordTypeId from Contact where ';
        if (EmailToLookup 		!= '#N/A'){
            ContactQuery 		= ContactQuery + 'Email = :EmailToLookup ';
            UseOr 				= true;
        }
        if (ContactToLookup 	!= '#N/A'){
            if (UseOr)
                ContactQuery 	= ContactQuery + ' OR Name = :ContactToLookup';
            else
                ContactQuery 	= ContactQuery + ' Name = :ContactToLookup';
            UseOr 				= true;
        }
        
        //If UseOr is set to True that means at least one of Email From or Contact Name was found in the Email Description
        if (UseOr){
            Id RecordTypeIdContact 			= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('UPHE Customer Account Contacts').getRecordTypeId();
            Boolean CustomerContactFound 	= false;
            Id CustomerContactRecord;
            List <Contact> ContactRecords 	= Database.query(ContactQuery);
            if (!ContactRecords.isEmpty()){
                for (Contact ConRecLoop : ContactRecords){
                    if (ConRecLoop.RecordTypeId 	== RecordTypeIdContact){
                        CustomerContactRecord 		= ConRecLoop.Id;
                        CustomerContactFound 		= true;
                        //Exit the flow if the record is found
                        break;
                    }
                }
                if (!CustomerContactFound)
                    CustomerContactRecord 	= ContactRecords[0].Id;
                
                CaseRecord.ContactId 		= CustomerContactRecord;
            }
        }
        return CaseRecord;
    }
    
    //Associate Account to the Case
    public static Case AssociateAccount(Case CaseRecord, String AccountToLookup){
        if (AccountToLookup != '#N/A'){
            Id RecordTypeIdAccount 			= Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
            List <Account> AccountQuery 	= [select Id from Account where Name = :AccountToLookup and RecordTypeId = :RecordTypeIdAccount];
            if (!AccountQuery.isEmpty()){
                CaseRecord.Customer__c 		= AccountQuery[0].Id;
            }
        }
        return CaseRecord;
    }
    
    //Lookup the input and return the output value for that field from the email message
    public static String ParseEmailContent(String TextToLookup){
        string TextValue 			= '#N/A';
        Integer TextLocation 		= EmailBody.indexOf(TextToLookup);
        if (TextLocation 			!= -1){
            String[] TextLines 		= EmailBody.right(EmailBody.length() - TextLocation).split('\n');
            //Below is to replace '(' and ')' in the Text To Lookup and Text Line 1
            //System is unable to split if the above are present
            Integer Text2LookupBracket 	= TextToLookup.indexOf('(');
            Integer TextLineBracket 	= TextLines[0].indexOf('(');
            String TextLine1 			= TextLines[0];
            if (Text2LookupBracket == TextLineBracket && TextLineBracket != -1){
                TextToLookup 			= TextToLookup.replace('(', '');
                TextLine1 				= TextLine1.left(TextLineBracket) + TextLine1.right(TextLine1.length() - (TextLineBracket + 1));
                Text2LookupBracket 		= TextToLookup.indexOf(')');
                TextLineBracket 		= TextLine1.indexOf(')');
                if (Text2LookupBracket == TextLineBracket && TextLineBracket != -1){
	                TextToLookup 		= TextToLookup.replace(')', '');
                    TextLine1 			= TextLine1.left(TextLineBracket) + TextLine1.right(TextLine1.length() - (TextLineBracket + 1));
                }
            }
            String[] ContentLine 	= TextLine1.split(TextToLookup);
            system.debug('ContentLine: ' + ContentLine);
            String ContentValue 	= ContentLine[1].trim();
            if (ContentValue 		!= ''){
                TextValue 			= ContentValue;
            }
        }
        return TextValue;
    }
    
    //Parse the emails and initialize the Global Map and List variables
    public void ReadExcelEmailAndSetupMaps(){
        //Query the meta data table to fetch all Price Protection & common records
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = :CaseRecordType OR Case_Record_Type__c = 'All'];
        
        //Setup a List of strings by splitting the Email Body with new line character
        List <String> EmailBodyNewLineSplit = EmailBody.split('\n');
        
        if (!MappingList.isEmpty()){
            MappingFound = true;
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                EmailTextToField.put(MetaData.Text_In_Email__c, MetaData.Field_API_Name__c);
                //FieldToValue.put(MetaData.Field_API_Name__c, ParseExcelEmailContent(MetaData.Text_In_Email__c));
                EmailTexts.add(MetaData.Text_In_Email__c);
            }
        }
        if (MappingFound && !EmailBodyNewLineSplit.isEmpty()){
            //Now trim the EmailBodyNewLineSplit list and create a new list to process.
            //This new List will have no blank spaces and the list elements will be trimmed
            List <String> EmailBodyTrimmed = new List <String>();
            String ProcessingText = '';
            for (String ListLoop : EmailBodyNewLineSplit){
                ProcessingText = ListLoop.trim();
                if (ProcessingText != ''){
                    EmailBodyTrimmed.add(ProcessingText);
                }
            }
            system.debug('EmailBodyTrimmed: ' + EmailBodyTrimmed);
            if (!EmailBodyTrimmed.isEmpty()){
                system.debug('Testing element 0: ' + EmailBodyTrimmed[0]);
                //Do the below logic only if there is something in the Trimmed list
                //A field name element will be followed by either an element value or another element name
                //For each element in the list of Trimmed text, check if the value is present in the EmailTexts List
                //In case it is present, then it means that the value is a field name element
                //In case it is not present, then it implies that the value is the content of the field
                //In case the following line is not part of the mapped fields but is a data element, it will end with a colon ':' symbol
                //Any text ending with this will be ignored
                Integer ElementNumber 	= 0;
                Integer ListSize 		= EmailBodyTrimmed.size();
                String NextValueInLine 	= '';
                EmailBody 				= '';
                for (String EmailValues : EmailBodyTrimmed){
                    NextValueInLine = '';
                    if (EmailTexts.indexOf(EmailValues) != -1){
                        //This signifies that the email value is a part of the list of fields
                        if (ElementNumber + 1 < ListSize){
                            //Above is to ensure that the logic does not go out of bounds
                            //In case the last line is an element to map and it does not have anything following it,
                            //then it will be put in as --BLANK--
                            NextValueInLine = EmailBodyTrimmed[ElementNumber + 1];
                            if (NextValueInLine.right(1) != ':'){
                                //The above is to ensure that the last character is not a ':' sign
                                //We are working with the assumption that a : indicates a field value
                                //Generating a new EmailBody variable to process for the Parsing logic
                                EmailBody = EmailBody + '\n' + EmailValues + ' ' + NextValueInLine;
                            }
                        }// End of if (ElementNumber + 1 < ListSize)
                    }
                    //Increment the element number pointer
                    ElementNumber++;
                }// End of for (String EmailValues : EmailBodyTrimmed)
                for(Case_Email_Mapping__mdt MetaData : MappingList){
                    //Re-do the looping for the Meta Data object to setup the FieldToValue map.
                    //This map relies on the Text Body of the email which does not come in proper shape for Excel
                    FieldToValue.put(MetaData.Field_API_Name__c, ParseEmailContent(MetaData.Text_In_Email__c));
                }
            }// End of if (!EmailBodyTrimmed.isEmpty())
        }// End of if (MappingFound && !EmailBodyNewLineSplit.isEmpty())
    }
    
    public void ProcessCSVFile(String AttachmentName, String AttachmentBody, Id CaseId){
        String encoded 		= EncodingUtil.urlEncode (AttachmentBody, 'UTF-8');
        String UploadResult = '';
        if (CaseRecordType 	== 'Price Protection'){
            UploadResult 	= Case_UploadMaterials.UploadPPCaseMaterials (encoded, CaseId, true);
        } else {
            UploadResult 	= Case_UploadMaterials.UploadShippingCaseMaterials (encoded, CaseId, true);
        }
        if (UploadResult 	!= ''){
            //Do this to create the Error File and attach it against the created Case
            Attachment ErrorFile 	= new Attachment();
            ErrorFile.Name 			= 'Error Output for ' + AttachmentName;
            ErrorFile.Body 			= Blob.valueOf(UploadResult);
            ErrorFile.ParentId 		= CaseId;
            insert ErrorFile;
        }
    }
    
    //Send a confirmation email to the person sending email with the Case Details
    public void SendAcknowledgementEmail(String CaseNum){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {EmailFrom};
        message.optOutPolicy = 'FILTER';
        message.subject =  'New ' + CaseRecordType + ' Case created with Case # ' + CaseNum;
        message.plainTextBody = 'Hello \n\nThank you for your email. We have recorded a new Case # ' + CaseNum + ' for it.';
        if (ErrorsDuringProcess != ''){
            message.plainTextBody = message.plainTextBody + '\n\nThere were following errors while processing your request:\n' + ErrorsDuringProcess;
        }
        message.plaintextbody = message.plaintextbody + '\n\nThank You,' + '\n\nNote: This is a system generated email. Please do not reply to it';
        message.setReplyTo('do-not-reply-this-will-bounce@nbcuni.com');
        message.setSenderDisplayName('NBCU Case Wizard');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    //Send an error email to the sender informing them if there are issues
    public void SendErrorEmail(){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {EmailFrom};
        message.optOutPolicy = 'FILTER';
        message.subject = 'Unable to process the email';
        message.plainTextBody = 'Hello \n\nThank you for your email. Unfortunately we encountered issues while processing it.';
        message.plaintextbody = message.plainTextBody + '\n\n' + ErrorsDuringProcess;
        message.plaintextbody = message.plaintextbody + '\n\nThank You,' + '\n\nNote: This is a system generated email. Please do not reply to it';
        message.setReplyTo('do-not-reply-this-will-bounce@nbcuni.com');
        message.setSenderDisplayName('NBCU Case Wizard');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    //Escape special characters such as "(" & ")". These are not supported in the SOQL and will cause failures
    public String Escape_Characters(String InputText){
        InputText = InputText.replace ('(', '%');
        InputText = InputText.replace (')', '%');
        system.debug('InputText: ' + InputText);
        return InputText;
    }
}