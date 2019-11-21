@isTest
public class Test_CIRFHeaderApprovalController {
    
    @isTest
    public static void testcheckValidation1(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        acc.CIRF_RIM_Approval__c = false;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        CIRF_Corrugate__c ccorr =CIRF_TestDataFactory.createCIRFCorrugate(header.id,'test corrugate','Singles Request', 2);
        insert ccorr;
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header.id);        
        Test.stopTest();
    }
    @isTest
    public static void testcheckValidation2(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        //scenario-3        	
        Account acc2 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer2', 'US', 'Test2', '1265');
        acc2.CIRF_RIM_Approval__c =true ;
        acc2.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc2;
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Corrugate', acc2.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header2.Studio__c= 'Universal';
        insert header2;
        CIRF_Material__C cmat2 = CIRF_TestDataFactory.createCIRFMaterial(header2.id, mat.id, 'Draft', 2, 3);
        insert cmat2;
        CIRF_Corrugate__c ccorr2 =CIRF_TestDataFactory.createCIRFCorrugate(header2.id,'test corrugate2','Singles Request', 2);
        insert ccorr2;        	        	
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header2.id);
        Test.stopTest();
    }
    @isTest
    public static void testcheckValidation3(){
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat1;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        //scenario-4        	
        Account acc3 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc3.CIRF_RIM_Approval__c =true ;
        acc3.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc3;
        CIRF_Header__c header3 = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc3.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header3.Studio__c= 'Universal';
        insert header3;
        CIRF_Material__C cmat3 = CIRF_TestDataFactory.createCIRFMaterial(header3.id, mat1.id, 'Draft', 2, 3);
        insert cmat3;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc3.id,'Siddhesh','Jawale');
        insert atm;
        
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header3.id);
        Test.stopTest();
    }
}