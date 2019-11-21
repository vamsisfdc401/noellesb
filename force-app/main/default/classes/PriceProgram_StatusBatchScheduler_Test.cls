@isTest
public class PriceProgram_StatusBatchScheduler_Test {
    static testMethod void TestBatchJob_Published (){
        //Insert Materials
        Id RecordTypeIdMaterial = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        Material__c MaterialRecord = new Material__c(Name = 'PromoTestMat1',
                                                     Format_Description__c = 'DVD',
                                                     Format__c = '02 - DVD',
                                                     Territory__c = 'US',
                                                     Material_Type__c = 'FERT',
                                                     UPC__c = '12345698745',
                                                     recordtypeid = RecordTypeIdMaterial,
                                                     Material_Number__c = '56564556897',
                                                     CIRF_US_D_Chain_Spec__c = 'NR - New Release',
                                                     CIRF_CDN_D_Chain_Spec__c = 'NR - New Release',
                                                     Street_Date__c = Date.newInstance(2025,12,05)
                                                    );
        insert MaterialRecord;
        Price_Protection_Program__c Program = new Price_Protection_Program__c(program_name__c = 'testname',
                                                                              Territory__c = 'US',
                                                                              Status__c='Draft',
                                                                              Submission_Deadline__c=System.today().adddays(-15),
                                                                              AR_Use_Only__c=System.today().adddays(-15),
                                                                              Studio_Partner__c='uphe',
                                                                              Effective_Date__c=System.today()
                                                                             );
        insert Program;
        Price_Protection_Materials__c PPMaterial = new Price_Protection_Materials__c(Price_Protection_Program__c = Program.Id,
                                                                                     New_Price__c =30 ,
                                                                                     NEW_SRP__c= 29,
                                                                                     Old_Price__c= 17	,
                                                                                     Old_SRP__c = 15,
                                                                                     Title__c = 'New Test',
                                                                                     Price_Protection_Amount_Per_Unit__c = 7,
                                                                                     Material_Description__c = MaterialRecord.Id
                                                                                    );
        
        insert PPMaterial;
        Program.Status__c = 'Queued';
        update Program;
        Test.StartTest();
        PriceProgram_StatusBatchScheduler sh1 = new PriceProgram_StatusBatchScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    static testMethod void TestBatchJob_Closed (){
        //Insert Materials
        Id RecordTypeIdMaterial = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        Material__c MaterialRecord = new Material__c(Name = 'PromoTestMat1',
                                                     Format_Description__c = 'DVD',
                                                     Format__c = '02 - DVD',
                                                     Territory__c = 'US',
                                                     Material_Type__c = 'FERT',
                                                     UPC__c = '12345698745',
                                                     recordtypeid = RecordTypeIdMaterial,
                                                     Material_Number__c = '56564556897',
                                                     CIRF_US_D_Chain_Spec__c = 'NR - New Release',
                                                     CIRF_CDN_D_Chain_Spec__c = 'NR - New Release',
                                                     Street_Date__c = Date.newInstance(2025,12,05)
                                                    );
        insert MaterialRecord;
        Price_Protection_Program__c Program = new Price_Protection_Program__c(program_name__c = 'testname',
                                                                              Territory__c = 'US',
                                                                              Status__c='Draft',
                                                                              Submission_Deadline__c=System.today().adddays(-15),
                                                                              AR_Use_Only__c=System.today().adddays(-15),
                                                                              Studio_Partner__c='uphe',
                                                                              Effective_Date__c=System.today().adddays(-20)
                                                                             );
        insert Program;
        Price_Protection_Materials__c PPMaterial = new Price_Protection_Materials__c(Price_Protection_Program__c = Program.Id,
                                                                                     New_Price__c =30 ,
                                                                                     NEW_SRP__c= 29,
                                                                                     Old_Price__c= 17	,
                                                                                     Old_SRP__c = 15,
                                                                                     Title__c = 'New Test',
                                                                                     Price_Protection_Amount_Per_Unit__c = 7,
                                                                                     Material_Description__c = MaterialRecord.Id
                                                                                    );
        
        insert PPMaterial;
        Program.Status__c = 'Queued';
        update Program;
        Test.StartTest();
        PriceProgram_StatusBatchScheduler sh1 = new PriceProgram_StatusBatchScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}