@isTest
public class Test_CIRFMaterialForecastStatusBatch {
    
    @testSetup
    public static void testData(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        List<CIRF_Material_Forecast__c> CMFCList=new list<CIRF_Material_Forecast__c>();
        for(Integer i=0; i<50; i++){
    		CIRF_Material_Forecast__c CMFC=new CIRF_Material_Forecast__c(Archive_Date__c=system.today().addDays(-1),Calculated_Date__c=system.today().addDays(5),CIRF_Material__c=cmat.id,CIRF_Header__c=header.id,Stage__c='Loaded',Forecast_Type__c='Initial Ship');
        	CMFCList.add(CMFC);
        }
        for(Integer i=0; i<50; i++){
    		CIRF_Material_Forecast__c CMFC=new CIRF_Material_Forecast__c(Archive_Date__c=system.today().addDays(-1),Calculated_Date__c=system.today().addDays(-20),CIRF_Material__c=cmat.id,CIRF_Header__c=header.id,Stage__c='Loaded',Forecast_Type__c='Initial Ship');
        	CMFCList.add(CMFC);
        }
        insert CMFCList;
    }
    
    @isTest
    public static void testRunBatchCMFStatus(){
        Test.startTest();
        CIRFMaterialForecastStatusBatch cmfstatusBatch = new CIRFMaterialForecastStatusBatch();
        Database.executeBatch(cmfstatusBatch);
        Test.stopTest();
        System.assertEquals(50, [Select id from CIRF_Material_Forecast__c where Stage__c = 'Complete'].size());
        System.assertEquals(50, [Select id from CIRF_Material_Forecast__c where Archive_Date__c >= :system.today()].size());
    }
    
    @isTest
    public static void testRunScheduleBatchCMFStatus(){
        Test.startTest();
        CIRFMaterialForecastStatusSchedular cmfstatusBatch = new CIRFMaterialForecastStatusSchedular();
        System.schedule('CIRFMaterialForecastStatusSchedule', '0 0 0 * * ?', cmfstatusBatch);
        Test.stopTest();
    }
    
    /*@isTest
    public static void testRunBatchCHStatus(){
        Test.startTest();
        Statusupdatecirfheaderbatch chstatusBatch = new Statusupdatecirfheaderbatch();
        Database.executeBatch(chstatusBatch);
        Test.stopTest();
        
        System.assertEquals(1, [Select id from CIRF_Header__c where CIRF_Status__c = 'Complete'].size());
        //System.assertEquals(50, [Select id from CIRF_Material_Forecast__c where Archive_Date__c >= :system.today()].size());
    }*/
    
    @isTest
    public static void testRunScheduleBatchCIRFHeader(){
        Test.startTest();
        scheduleCIRFHeadersBatch chBatch = new scheduleCIRFHeadersBatch();
        System.schedule('CIRFHeaderBatchSchedule', '0 0 0 * * ?', chBatch);
        Test.stopTest();
    }
}