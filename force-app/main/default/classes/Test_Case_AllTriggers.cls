@isTest
public class Test_Case_AllTriggers {
    public static Bypass_TPWV__c BypassCS 		= Bypass_TPWV__c.getInstance();
    public static Boolean BypassValidations 	= BypassCS.Bypass_Validation_Rules__c;
    public static Id POD_RecTypeId 				= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PO Discrepancies').getRecordTypeId();
    public static Id PP_RecTypeId 				= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Price Protection').getRecordTypeId();

    public static Account NewAcc 				= createAccount('Test1');
    public static Contact NewConCust 			= createContactCust(NewAcc.Id, 'UPHE Customer Account Contacts');
    public static Material__c Material1 		= createMaterial('1234567890', '1234567890', 'Material # 1', 'US');
    public static Material__c Material2 		= createMaterial('1234567891', '1234567891', 'Material # 2', 'US');
    public static Material__c Material3 		= createMaterial('1234567892', '1234567892', 'Material # 3', 'US');
    
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
    //Create Case Record
    public static Case CreateCase(Id CaseRecordTypeId, String IntegrationStatus, Id CustomerId, Id CaseContactId, String CaseStatus){
        Case NewCase = new Case(Subject 				= 'This is a Test Case',
                                Origin 					= 'Email',
                                Territory__c 			= 'US',
                                RecordTypeId 			= CaseRecordTypeId,
                                Customer__c 			= CustomerId,
                                PO_Number__c 			= '1234567890',
                                ContactId 				= CaseContactId,
                                Integration_Status__c 	= IntegrationStatus,
                                Status 					= CaseStatus
                               );
        return NewCase;
    }
    
    static testMethod void TestNonNewCaseCreation(){
        //Test Case creation with Status other than New
        try{
	        Case 	NewCase 	= CreateCase(POD_RecTypeId, 'N', NewAcc.Id, NewConCust.Id, 'Approved');
            insert 	NewCase;
        } catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Status can only be New when creating a Case') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    static testMethod void TestCaseStatusUpdates_1(){
        //Test Case Status transitions
        try{
	        Case 	NewCase 	= CreateCase(POD_RecTypeId, 'N', NewAcc.Id, NewConCust.Id, 'New');
            insert 	NewCase;
            NewCase.Status 		= 'Approved';
            update 	NewCase;
        } catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Status cannot be changed from New to Approved manually') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    static testMethod void TestCaseStatusUpdates_2(){
        //Test Case becoming read only once Approved
        BypassCS.Bypass_Validation_Rules__c = true;
        upsert BypassCS;
        
        try{
	        Case 	NewCase 	= CreateCase(POD_RecTypeId, 'N', NewAcc.Id, NewConCust.Id, 'New');
            insert 	NewCase;
            NewCase.Status 		= 'Approved';
            update 	NewCase;
            BypassCS.Bypass_Validation_Rules__c = false;
            upsert BypassCS;
            NewCase.Subject 	= 'Testing updates on Read Only Case';
            update 	NewCase;
        } catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('This case can no longer be edited') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    static testMethod void TestCaseAfterTriggers_1(){
        Program.Status__c 		= 'Queued';
        update Program;
        List <Case> CaseRecordList = new List <Case> ();
        test.startTest();
        for (Integer Counter = 0; Counter < 3; Counter++){
            Case NewRecord = CreateCase(PP_RecTypeId, 'N', NewAcc.Id, NewConCust.Id, 'New');
            NewRecord.Associated_Price_Protection_Program__c = Program.Id;
            insert NewRecord;
            CaseRecordList.add(NewRecord);
        }
        for (Integer Counter = 0; Counter < 2; Counter++){
            CaseRecordList[Counter].Subject = 'Test Updates';
        }
        update CaseRecordList;
        delete CaseRecordList[2];
        test.stopTest();
    }
}