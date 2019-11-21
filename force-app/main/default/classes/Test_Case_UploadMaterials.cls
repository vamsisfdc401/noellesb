@isTest
public class Test_Case_UploadMaterials {
    //Setting Up Test Account
    public static Account createAccount(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        Account NewAccount = new Account(Name = 'Test1',
                                         //Sold_To__c = '25035',
                                         Territory__c = 'US',
                                         Promo_Country__c = 'US',
                                         //Ship_To_Code__c = '68221',
                                         recordtypeid = RecordTypeIdAccount
                                        );
        insert NewAccount;
        return NewAccount;
    }
    //Setting Up Test Contact
    public static Contact createContact(Id AccountId){
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Promo Order Contact').getRecordTypeId();
        Contact Con = new Contact( AccountId = AccountId,
                                  LastName = 'Syed',
                                  recordtypeid=RecordTypeIdContact,
                                  Promo_Country__c ='US',
                                  Territory__c ='US'
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
                                                  Street_Date__c =  Date.newInstance(2025,07,25)
                                                 );
        insert NewMaterial;
        return NewMaterial;
    }
    //Setting Up Price Protection Program
    public static Price_Protection_Program__c createProgram(String Territory, String ProgName){
        Price_Protection_Program__c Program = new Price_Protection_Program__c(program_name__c = ProgName,
                                                                              Territory__c = Territory,
                                                                              Status__c='Draft',
                                                                              Submission_Deadline__c=Date.newInstance(2018,12,15),
                                                                              AR_Use_Only__c=Date.newInstance(2018,12,10),
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
    
    static testMethod void TestProgramMassUpload (){
        Account Newt = createAccount();
        Contact Con = createContact(Newt.Id);
        Material__c Mat1 = createMaterial('56564556897', '12345698745', 'PromoTestMat1', 'US');
        Material__c Mat2 = createMaterial('56564556896', '12345698744', 'PromoTestMat2', 'CDN');
        Price_Protection_Program__c Program = createProgram('US', 'Test Program 1');
        String c = 'Material Number,UPC,Old SRP,New SRP,Old Price,New Price,PP Amount per unit\n56564556564,12345698745,29.98,19,17,11,6';
        String d = 'Material Number,UPC,Old SRP,New SRP,Old Price,New Price,PP Amount per unit\n56564556896,12345698744,29.98,19,17,11,6';
        test.startTest();
        Case_UploadMaterials.UploadPPMaterials(c,Program.Id);
        Case_UploadMaterials.UploadPPMaterials(d,Program.Id);
        test.stopTest();
    }
    
    static testMethod void TestProgramCaseMassUpload (){
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Price Protection').getRecordTypeId();
        Account Newt = createAccount();
        Contact Con = createContact(Newt.Id);
        Material__c Mat1 = createMaterial('56564556897', '12345698745', 'PromoTestMat1', 'US');
        Price_Protection_Program__c Program = createProgram('US', 'Test Program 1');
        Price_Protection_Materials__c PPMat = createProgramMaterial(Program.Id, Mat1.Id);
        Program.Status__c = 'Queued';
        update Program;
        Material__c Mat2 = createMaterial('56564556896', '12345698744', 'PromoTestMat2', 'CDN');
        Price_Protection_Program__c Program2 = createProgram('CDN', 'Test Program 2');
        Price_Protection_Materials__c PPMat2 = createProgramMaterial(Program2.Id, Mat2.Id);
        Program2.Status__c = 'Queued';
        update Program2;
        case cad = new case(Customer__c = Newt.id, Status = 'NEW',Territory__c = 'US',Origin = 'Email',Associated_Price_Protection_Program__c = Program.id, PO_Number__c = '12345', RecordTypeId=RecordTypeIdCase);
        insert cad;
        String c = 'UPC,New Price,Old Price,\n12345698745,30,17\n12345698744,30,17';
        test.startTest();
        Case_UploadMaterials.UploadPPCaseMaterials(c,cad.Id,false);
        test.stopTest();
    }
    
    static testMethod void TestPOCaseMassUpload (){
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('PO Discrepancies').getRecordTypeId();
        Account Newt = createAccount();
        Contact Con = createContact(Newt.Id);
        Material__c Mat1 = createMaterial('56564556897', '12345698745', 'PromoTestMat1', 'US');
        Material__c Mat2 = createMaterial('56564556564', '12345656895', 'PromoTestMat2', 'US');
        Material__c Mat3 = createMaterial('56564556896', '12345698744', 'PromoTestMat3', 'CDN');

        case cad = new case(Status = 'NEW',Territory__c = 'US',Origin = 'Email', recordtypeid=RecordTypeIdCase, PO_Number__c = '12345');
        insert cad;
        String c = 'UPC,Material Number,Quantity Ordered,Quantity Received,Unit Cost\n12345698745,56564556564,100,80,$8\n12345656895,56564556897,100,80,$8\n12345698744,56564556896,100,10,8';
        test.startTest();
        Case_UploadMaterials.UploadShippingCaseMaterials(c,cad.Id, false);
        test.stopTest();
    }
}