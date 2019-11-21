@isTest
public class Test_Case_EmailService {
    
    public static String EmailBody 	= '';
    //Setup basic data for the Consumption
    public static Account NewAcc 			= createAccount('Test1');
    public static Contact NewConPromo 		= createContact(NewAcc.Id, 'Promo Order Contact');
    public static Contact NewConCust 		= createContactCust(NewAcc.Id, 'UPHE Customer Account Contacts');
    public static Material__c Material1 	= createMaterial('1234567890', '1234567890', 'Material # 1', 'US');
    public static Material__c Material2 	= createMaterial('1234567891', '1234567891', 'Material # 2', 'US');
    public static Material__c Material3 	= createMaterial('1234567892', '1234567892', 'Material # 3', 'US');
    
    //Now create a Program and add the above materials as Program Materials
    public static Price_Protection_Program__c Program 		= createProgram('US', 'Program # 1');
    public static Price_Protection_Materials__c ProgMat1 	= createProgramMaterial(Program.Id, Material1.Id);
    public static Price_Protection_Materials__c ProgMat2 	= createProgramMaterial(Program.Id, Material2.Id);
    public static Price_Protection_Materials__c ProgMat3 	= createProgramMaterial(Program.Id, Material3.Id);
    
    //Setting Up Test Account
    public static Account createAccount(String AccName){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        Account NewAccount = new Account(Name = AccName,
                                         //Sold_To__c = '25035',
                                         Territory__c = 'US',
                                         Promo_Country__c = 'US',
                                         //Ship_To_Code__c = '68221',
                                         recordtypeid = RecordTypeIdAccount
                                        );
        insert NewAccount;
        return NewAccount;
    }
    //Setting Up Test Contact Promo Contact
    public static Contact createContact(Id AccountId, String RecordType){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        Contact Con = new Contact(AccountId = AccountId,
                                  FirstName = 'Tanmay',
                                  LastName = 'Jain',
                                  recordtypeid=RecordTypeIdContact,
                                  Promo_Country__c ='US',
                                  Territory__c ='US',
                                  Email = 'tanmay.jain@capgemini.com'
                                 );
        insert Con;
        return Con;
    }
    //Setting Up Test Contact UPHE Customer Account Contacts
    public static Contact createContactCust(Id AccountId, String RecordType){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        Contact Con = new Contact(AccountId = AccountId,
                                  FirstName = 'Tanmay1',
                                  LastName = 'Jain1',
                                  recordtypeid=RecordTypeIdContact,
                                  Promo_Country__c ='US',
                                  Territory__c ='US',
                                  Email = 'tanmay.jain@outlook.com'
                                 );
        insert Con;
        return Con;
    }
    //Setting Up Test Material
    public static Material__c createMaterial(String MatNumber, String UPC, String MatName, String Territory){
        Id RecordTypeIdMaterial = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        Material__c NewMaterial = new Material__c(Name = MatName,
                                                  Territory__c = Territory,
                                                  Material_Number__c = MatNumber,
                                                  UPC__c = UPC,
                                                  Format_Description__c = 'DVD',
                                                  Format__c = '02 - DVD',
                                                  Material_Type__c = 'FERT',
                                                  recordtypeid = RecordTypeIdMaterial,
                                                  CIRF_US_D_Chain_Spec__c = 'NR - New Release',
                                                  CIRF_CDN_D_Chain_Spec__c = 'NR - New Release',
                                                  Street_Date__c =  Date.newInstance(2015,07,25)
                                                 );
        insert NewMaterial;
        return NewMaterial;
    }
    //Setting Up Price Protection Program
    public static Price_Protection_Program__c createProgram(String Territory, String ProgName){
        Price_Protection_Program__c Program = new Price_Protection_Program__c(program_name__c = ProgName,
                                                                              Territory__c = Territory,
                                                                              Status__c='Draft',
                                                                              Submission_Deadline__c=Date.newInstance(2025,12,15),
                                                                              AR_Use_Only__c=Date.newInstance(2025,12,10),
                                                                              Studio_Partner__c='uphe',
                                                                              Effective_Date__c=System.today().addDays(-1)
                                                                             );
        insert Program;
        return Program;
    }
    //Setting Up Price Protection Material
    public static Price_Protection_Materials__c createProgramMaterial(Id ProgramId, Id MaterialId){
        Price_Protection_Materials__c PPmat = new Price_Protection_Materials__c(Price_Protection_Program__c = ProgramId,
                                                                                New_Price__c =30 ,
                                                                                NEW_SRP__c= 29,
                                                                                Old_Price__c= 17,
                                                                                Old_SRP__c = 15,
                                                                                Title__c = 'New Test',
                                                                                Price_Protection_Amount_Per_Unit__c = 7,
                                                                                Material_Description__c = MaterialId
                                                                               );
        
        insert PPmat;
        return PPmat;
    }
    
    //Generate a text email body based on Record Type
    public static void GenerateTextEmailSkeleton(String CaseRecordType){
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = :CaseRecordType OR Case_Record_Type__c = 'All'];
        
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                EmailBody = EmailBody + '\n' + MetaData.Text_In_Email__c + ' ';
            }
        }
    }
    
    //Testing Price Protection Text Email # 1
    static TestMethod void TestPriceProtectionEmailText_1(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'Price Protection' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' tanmay.jain@capgemini.com <mailto: tanmay.jain@capgemini.com>';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Tanmay1 Jain1';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Test1';
                } else if (TextToCheck == 'Program Name:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Program # 1';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 1';
        email.toAddresses 		= Label.Case_PPEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PPEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'UPC,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.BinaryAttachment CSVFile = new Messaging.InboundEmail.BinaryAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= Blob.valueOf(CSVFileContent);
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing Price Protection Text Email # 2
    static TestMethod void TestPriceProtectionEmailText_2(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'Price Protection' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Test1';
                } else if (TextToCheck == 'Program Name:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Program # 1';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 2';
        email.toAddresses 		= Label.Case_PPEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PPEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'UPC,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing Price Protection Excel Email # 1
    static TestMethod void TestPriceProtectionEmailExcel_1(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'Price Protection' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n tanmay.jain@capgemini.com';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Test1';
                } else if (TextToCheck == 'Program Name:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Program # 1';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 3';
        email.toAddresses 		= Label.Case_PPEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PPEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'UPC,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing PO Discrepancies Text Email # 1
    static TestMethod void TestPODiscrepanciesEmailText_1(){
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'PO Discrepancies' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' tanmay.jain@capgemini.com <mailto: tanmay.jain@capgemini.com>';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Tanmay1 Jain1';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Test1';
                } else if (TextToCheck == 'Billing Date:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' 5/5/2018';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 4';
        email.toAddresses 		= Label.Case_PODEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PODEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'Material Number,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.BinaryAttachment CSVFile = new Messaging.InboundEmail.BinaryAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= Blob.valueOf(CSVFileContent);
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing PO Discrepancies Text Email # 2
    static TestMethod void TestPODiscrepanciesEmailText_2(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'PO Discrepancies' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' Test1';
                } else if (TextToCheck == 'Billing Date:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + ' 5/5/2018';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 5';
        email.toAddresses 		= Label.Case_PODEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PODEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'Material Number,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing PO Discrepancies Excel Email # 1
    static TestMethod void TestPODiscrepanciesEmailExcel_1(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'PO Discrepancies' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n tanmay.jain@capgemini.com';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Test1';
                } else if (TextToCheck == 'Billing Date:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n 5/5/2018';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 6';
        email.toAddresses 		= Label.Case_PODEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PODEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'Material Number,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing PO Discrepancies Failure
    static TestMethod void TestPODiscrepanciesEmailExcel_Failure(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'PO Discrepancies' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n tanmay.jain@capgemini.com';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Test1';
                } else if (TextToCheck == 'Billing Date:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n 5/5/2018';
                } else if (TextToCheck == 'PO #:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n 12345678901234567890';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 6';
        email.toAddresses 		= Label.Case_PODEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PODEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'Material Number,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }
    
    //Testing PO Discrepancies Failure2
    static TestMethod void TestPODiscrepanciesEmailExcel_Failure2(){
        //Now publish the above Program
        Program.Status__c = 'Queued';
        update Program;
        
        //Now generate a skeletal structure of the email
        List <Case_Email_Mapping__mdt> MappingList = [select Field_API_Name__c, Text_In_Email__c from Case_email_mapping__mdt where Case_Record_Type__c = 'PO Discrepancies' OR Case_Record_Type__c = 'All'];
        List <String> EmailTexts = new List <String>();
        if (!MappingList.isEmpty()){
            for(Case_Email_Mapping__mdt MetaData : MappingList){
                String TextToCheck = MetaData.Text_In_Email__c;
                if (TextToCheck == 'Email:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n tanmay.jain@capgemini.com';
                } else if (TextToCheck == 'Contact:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Tanmay Jain';
                } else if (TextToCheck == 'Customer:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n Test1';
                } else if (TextToCheck == 'Billing Date:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n 55/2018';
                } else if (TextToCheck == 'PO #:'){
                    EmailBody = EmailBody + '\n' + TextToCheck + '\n\n 123456';
                } else {
                    EmailBody = EmailBody + '\n' + TextToCheck + ' ';
                }
            }
        }
        
        //Now generate an email
        Messaging.InboundEmail email 	= new Messaging.InboundEmail();
        Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        //Set the email parameters
        email.plainTextBody 	= EmailBody;
        email.subject 			= 'Test Class Method # 6';
        email.toAddresses 		= Label.Case_PODEmailId.split(':');
        env.fromAddress 		= 'tanmay.jain@capgemini.com';
        env.toAddress 			= Label.Case_PODEmailId;
        //Now generate email attachment, a CSV File
        String CSVFileContent 	= 'Material Number,Quantity Ordered,Quantity Received,Unit Cost\n1234567890,100,80,$8\n1234567891,100,80,$8\n1234567893,100,10,8';
        Messaging.InboundEmail.TextAttachment CSVFile = new Messaging.InboundEmail.TextAttachment();
        CSVFile.fileName 		= 'Materials.csv';
        CSVFile.body 			= CSVFileContent;
        CSVFile.mimeTypeSubType = 'text/csv';
        //Attach it to the email
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[]{CSVFile};
        //Send the email;
        Case_EmailService_For_Email2Case EmailService = new Case_EmailService_For_Email2Case();
        EmailService.handleInboundEmail(email, env);
    }}