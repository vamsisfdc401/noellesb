@isTest
public class Test_UploadOrderMaterialsController {
    //Setting Up Test Account
    public static Account createAccount(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Promo Orders').getRecordTypeId();
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
                                                  Street_Date__c =  System.today().addDays(-300)
                                                 );
        insert NewMaterial;
        return NewMaterial;
    }
    static testMethod void UploadOrders1 (){
        Account Newt = createAccount();
        Contact Con = createContact(Newt.Id);
        Material__c Mat1 = createMaterial('56564556897', '12345698745', 'PromoTestMat1', 'US');
        Material__c Mat2 = createMaterial('56564556896', '56564556896', 'PromoTestMat2', 'US');
        Material__c Mat3 = createMaterial('56564556895', '12345698743', 'PromoTestMat3', 'CDN');
        Orders__c order = new Orders__c(Request_Name__c = 'testname',Sold_to_Name__c = Newt.id,Ship_To_Contact__c=Con.id,Requested_Delivery_Date__c=Date.newInstance(2025,11,30));
        insert order;
        String c = 'Material Number,UPC,Quantity\n56564556564,12345698745,10\n56564556896,56564556896,20\n56564556895,12345698743,20';
        test.startTest();
        UploadOrderMaterialsController.UploadOrderMaterials(c,order.Id);
        test.stopTest();
    }
}