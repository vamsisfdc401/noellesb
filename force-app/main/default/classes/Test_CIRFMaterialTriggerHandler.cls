@isTest
public class Test_CIRFMaterialTriggerHandler {
    @isTest
    public static void testData1(){
        
        //RF_TestDataFactory.testMethod_1();
        	Material__c mat = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material', '1234', '61 - Universal Pictures', 'AA',null);
        	insert mat;
        	Material__c mat2 = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material2', '1265', '61 - Universal Pictures', 'AA',null);
        	insert mat2;       
        	Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'CA', 'Test', '1275');
        	insert acc;
        	date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
        	CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        	insert header;
        	CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        	cmat.Needs_Regie_Sticker__c = true;
        	insert cmat;
        	CIRF_Corrugate__c ccorr = CIRF_TestDataFactory.createCIRFCorrugate(header.id,'Test corrugate', 'Singles Request',2);
        	insert ccorr;
            CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.id, ccorr.id);
            insert corrmat;
            AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        	insert atm;
        	Test.startTest();
        	header.CIRF_Status__c = 'Submitted';        	
        	update header;
        	//cmat.Material_Name__c = mat2.id;
        	cmat.CIRF_Material_Status__c = 'Submitted';
        	cmat.Split_Forecast__c = false;
        	update cmat;
        	cmat.Split_Forecast__c = true;
        	cmat.CIRF_Material_Status__c = 'Loaded';
        	update cmat;   
        	cmat.CIRF_Material_Status__c = 'Merged';
        	update cmat;
        	Test.stopTest();

    }
    @isTest
    public static void testcancel(){
        
        //RF_TestDataFactory.testMethod_1();
        	Material__c mat = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material', '1234', '61 - Universal Pictures', 'AA',null);
        	insert mat;
        	Material__c mat2 = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material2', '1265', '61 - Universal Pictures', 'AA',null);
        	insert mat2;       
        	Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'CA', 'Test', '1275');
        	insert acc;
        	date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
        	CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        	insert header;
        	CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        	cmat.Needs_Regie_Sticker__c = true;
        	insert cmat;
        	CIRF_Corrugate__c ccorr = CIRF_TestDataFactory.createCIRFCorrugate(header.id,'Test corrugate', 'Singles Request',2);
        	insert ccorr;
            CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.id, ccorr.id);
            insert corrmat;
        	AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        	insert atm;
        	Test.startTest();
        	cmat.CIRF_Material_Status__c = 'Cancelled';      	
        	update cmat;     	
        	Test.stopTest();

    }
    @isTest
    public static void testsubmitted(){
        	
        	Material__c mat1 = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material', '1234', '61 - Universal Pictures', 'AA',null);
        	insert mat1;        	      
        	Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'CA', 'Test', '1275');
        	insert acc;
        	date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
        	CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        	insert header;       	        	        	
        	AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        	insert atm;
        	CIRF_Material__C cmat1 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat1.id, 'Draft', 2, 2);
        	insert cmat1;
        	Test.startTest();
        	CIRFMaterialTriggerHandler.allowedCIRFActions = true;
        	cmat1.Units_to_Order__c = 3;
        	update cmat1;
        	
        	delete cmat1;
        	Test.stopTest();
    }
       	
}