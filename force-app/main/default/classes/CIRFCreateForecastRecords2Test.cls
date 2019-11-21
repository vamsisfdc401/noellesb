@isTest
public class CIRFCreateForecastRecords2Test {
    static CIRF_Header__c CirfHeader;
    static CIRF_Header__c CirfHeader2;
    static Account acctRetailer;
    static CIRF_Corrugate__c CirfCorrugate;
    static Material__c Material;
    static Material__c Material2;
    static CIRF_Corrugate_Material__c CirfCorrMat;
    static CIRF_Material__c CirfMat;
    static CIRF_Material__c CirfMat2;
    static CIRF_Material__c CirfMat3;
    static CIRF_Material_Forecast__c CirfMatForeCast;
    static CIRF_Material_Forecast__c CirfMatForeCast2;
    static Bom_Item__C BomItem;
    static Sub_Label_Code__c SubLabelCode;
    
    static testmethod void  testMethod_1()
    {
        //try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest','Comingled Virtual Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            CirfHeader2=CIRF_TestDataFactory.createCIRFHeader('CIRFTest2','Singles',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Cancelled',true);
            insert CirfHeader2;
            CirfCorrugate=CIRF_TestDataFactory.createCIRFCorrugate(CirfHeader.Id,'Test Corrugate','Pallet', 90);
            insert CirfCorrugate;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','12324', '24 - PURE FLIX', '122',null);
            insert Material; 
            Material2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
            insert Material2; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Loaded',0,2);
            CirfMat2=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material2.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = false;
            CirfMat.Unique_vs_National__c = 'Unique';
            insert CirfMat;
            CirfMat2.Unique_vs_National__c = 'National';
        	CirfMat2.Fully_Built__c = true;
            insert CirfMat2;
            CirfMat3=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material2.id,'Loaded',0,2);
            insert CirfMat3;
            CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            insert CirfMatForeCast;
            insert CirfMatForeCast2;
            CirfCorrMat=CIRF_TestDataFactory.createCIRFCorrugateMaterial(CirfMat.Id, CirfCorrugate.Id);
            BomItem=CIRF_TestDataFactory.createBomItem(Material.id);
            insert BomItem;
            SubLabelCode=CIRF_TestDataFactory.createSublabelCode(true,'11 - TVA Films');
            insert SubLabelCode;
        /*}catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }*/
        system.debug('acctRetailer=='+acctRetailer+'==CirfHeader=='+CirfHeader+'=CirfCorrugate='+CirfCorrugate);
        system.debug('Material=='+Material+'==CirfMat=='+CirfMat+'=CirfCorrMat='+CirfCorrMat+'==CirfMatForeCast=='+CirfMatForeCast);
        
        //CIRFCreateForecastRecords2.CreateForecastRecords(CirfHeader.Id,CirfMat.id, false);
        //CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id, false);
        //CIRFCreateForecastRecords2.ReviseFrstRecords(system.today(),'ttt',CirfMat,2,null,false);
        //CIRFCreateForecastRecords2.CancelledCMATFrctRecords();
        //CIRFCreateForecastRecords2.CancelFrctRecords(CirfMat,CirfMatForeCast,2,'Initial Ship');
        //CIRFCreateForecastRecords2.ArchiveInsertFrstRecords(system.today(),'ttt','Initial Ship',CirfMat,null,2,false);
        
        CIRF_Material__c CirfMat4=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material.id,'Loaded',0,2);
        insert CirfMat4;
        
        Test.startTest();
        //scenario 1: Create Forecast
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id,false);
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader2.Id,false);
        //scenario 2: Revise
        CirfMat.Units_to_Order__c = 55;
        CirfMat.Replen_Units__c = 55;
        update CirfMat;
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id,false);
        //scenario 3: Cancel one of the CIRFMat
        //CirfMat2.CIRF_Material_Status__c = 'Cancelled';
        //update CirfMat2;
        CirfMat.CIRF_Material_Status__c = 'Merged';
        update CirfMat;
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id,false);
        
        //Scenario 4: Cancel header
        CirfMat3.CIRF_Material_Status__c = 'Draft';
        update CirfMat3;
        CirfMat3.CIRF_Material_Status__c = 'Cancelled';
        update CirfMat3;
        cirfheader2.CIRF_Status__c = 'Cancelled';
        update cirfheader2;
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader2.Id,false);
        
        
        Test.stopTest();
        
    }
    
    static testmethod void  testMethod_2()
    {
        //try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest3','Singles',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            CirfHeader2=CIRF_TestDataFactory.createCIRFHeader('CIRFTest4','Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Cancelled',true);
            insert CirfHeader2;
            CirfCorrugate=CIRF_TestDataFactory.createCIRFCorrugate(CirfHeader2.Id,'Test Corrugate','Pallet', 90);
            insert CirfCorrugate;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','123245', '24 - PURE FLIX', '122',null);
            insert Material; 
            Material2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '12346', '61 - Universal Pictures', 'AA','');
            insert Material2; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Loaded',0,2);
            CirfMat2=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material2.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = false;
            CirfMat.Unique_vs_National__c = 'Unique';
            insert CirfMat;
            CirfMat2.Unique_vs_National__c = 'National';
        	CirfMat2.Fully_Built__c = true;
            insert CirfMat2;
            CirfMat3=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material2.id,'Loaded',0,2);
            insert CirfMat3;
            CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            insert CirfMatForeCast;
            insert CirfMatForeCast2;
            CirfCorrMat=CIRF_TestDataFactory.createCIRFCorrugateMaterial(CirfMat.Id, CirfCorrugate.Id);
            BomItem=CIRF_TestDataFactory.createBomItem(Material.id);
            insert BomItem;
            SubLabelCode=CIRF_TestDataFactory.createSublabelCode(true,'11 - TVA Films');
            insert SubLabelCode;
        /*}catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }*/
        system.debug('acctRetailer=='+acctRetailer+'==CirfHeader=='+CirfHeader+'=CirfCorrugate='+CirfCorrugate);
        system.debug('Material=='+Material+'==CirfMat=='+CirfMat+'=CirfCorrMat='+CirfCorrMat+'==CirfMatForeCast=='+CirfMatForeCast);
        
        CIRF_Material__c CirfMat4=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material.id,'Loaded',0,2);
        insert CirfMat4;
        
        Test.startTest();
        //scenario 1: Create Forecast
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id,false);
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader2.Id,false);
        //scenario 2: Revise
        CirfMat.Units_to_Order__c = 0;
        CirfMat.Replen_Units__c = 55;
        update CirfMat;
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader.Id,false);
        //scenario 3: Cancel one of the CIRFMat
        //CirfMat2.CIRF_Material_Status__c = 'Cancelled';
        //update CirfMat2;
        
        //Scenario 4: Cancel header
        CirfMat3.CIRF_Material_Status__c = 'Draft';
        update CirfMat3;
        CirfMat3.CIRF_Material_Status__c = 'Cancelled';
        update CirfMat3;
        cirfheader2.CIRF_Status__c = 'Cancelled';
        update cirfheader2;
        CIRFCreateForecastRecords2.CreateForRecords(CirfHeader2.Id,false);
        CIRFCreateForecastRecords2.relCMF = new List<CIRF_Material_Forecast__c> {CirfMatForeCast2};
        CIRFCreateForecastRecords2.allrelCMF = CIRFCreateForecastRecords2.relCMF;
        CirfMat.CIRF_Material_Status__c = 'Cancelled';
        CIRFCreateForecastRecords2.InitForecastRecords(System.today(),'Group Z',CirfMat,cirfheader2.revision__c,'INIT', true);  
        CIRFCreateForecastRecords2.forecastToUpdate = new Map<Id,CIRF_Material_Forecast__c>();//added initialization by Kalyani
        CIRFCreateForecastRecords2.MergedCMATFrctRecords(CirfMat, 1);
        CIRFCreateForecastRecords2.header = cirfheader2;
        CIRFCreateForecastRecords2.forecastToInsert = new List<CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.forecastToUpdate  = new Map<Id,CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.CancelledCMATFrctRecords();
        Test.stopTest();
    }
    
    static testMethod void ArchiveInsertFrstRecordsTest() {
        //create test data
        //try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest3','Singles',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            CirfHeader2=CIRF_TestDataFactory.createCIRFHeader('CIRFTest4','Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Cancelled',true);
            insert CirfHeader2;
            CirfCorrugate=CIRF_TestDataFactory.createCIRFCorrugate(CirfHeader2.Id,'Test Corrugate','Pallet', 90);
            insert CirfCorrugate;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','123245', '24 - PURE FLIX', '122',null);
            insert Material; 
            Material2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '12346', '61 - Universal Pictures', 'AA','');
            insert Material2; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Loaded',0,2);
            CirfMat2=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material2.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = true;
            CirfMat.Unique_vs_National__c = 'Unique';
            insert CirfMat;
            CirfMat2.Unique_vs_National__c = 'National';
            insert CirfMat2;
            CirfMat3=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material2.id,'Loaded',0,2);
            insert CirfMat3;
            CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            insert CirfMatForeCast;
            insert CirfMatForeCast2;
            CirfCorrMat=CIRF_TestDataFactory.createCIRFCorrugateMaterial(CirfMat.Id, CirfCorrugate.Id);
            BomItem=CIRF_TestDataFactory.createBomItem(Material.id);
            insert BomItem;
            SubLabelCode=CIRF_TestDataFactory.createSublabelCode(true,'11 - TVA Films');
            insert SubLabelCode;
        /*}catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }*/
        system.debug('acctRetailer=='+acctRetailer+'==CirfHeader=='+CirfHeader+'=CirfCorrugate='+CirfCorrugate);
        system.debug('Material=='+Material+'==CirfMat=='+CirfMat+'=CirfCorrMat='+CirfCorrMat+'==CirfMatForeCast=='+CirfMatForeCast);
        
        CIRF_Material__c CirfMat4=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material.id,'Loaded',0,2);
        insert CirfMat4;
        Test.startTest();
        CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
        insert CirfMatForeCast;
        CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
        CirfMatForeCast2.Parent_Forecast_Material__c = CirfMatForeCast.Id;
        insert CirfMatForeCast2;
        CIRFCreateForecastRecords2.Bomlist = new List<BOM_Item__c>{BomItem};
        CIRFCreateForecastRecords2.SplitForecastreclist = new List<CIRF_Material_Forecast__c>{CirfMatForeCast2};
        CIRFCreateForecastRecords2.forecastToInsert = new List<CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.forecastToUpdate  = new Map<Id,CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.Matlist = new List<Material__c> {Material};
        
        CIRFCreateForecastRecords2.ReviseFrstRecords(System.today(),'Group Z',CirfMat,1, null, false);
                    
        CIRFCreateForecastRecords2.ArchiveInsertFrstRecords(System.today(),'Group Z','Initial Ship',CirfMat, CirfMatForeCast, 1, false);
        CIRFCreateForecastRecords2.ArchiveInsertFrstRecords(System.today(),'Group Z','Corrugate',CirfMat, CirfMatForeCast, 1, false);
        CIRFCreateForecastRecords2.ArchiveInsertFrstRecords(System.today(),'Group Z','Replenishment',CirfMat, CirfMatForeCast, 1, false);
        Test.stopTest();
    }
    
    static testMethod void ReplenFrstRecordsTest() {
        //create test data
        //try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest3','Singles',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            CirfHeader2=CIRF_TestDataFactory.createCIRFHeader('CIRFTest4','Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Cancelled',true);
            insert CirfHeader2;
            CirfCorrugate=CIRF_TestDataFactory.createCIRFCorrugate(CirfHeader2.Id,'Test Corrugate','Pallet', 90);
            insert CirfCorrugate;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','123245', '24 - PURE FLIX', '122',null);
            insert Material; 
            Material2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '12346', '61 - Universal Pictures', 'AA','');
            insert Material2; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Loaded',0,2);
            CirfMat2=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material2.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = true;
            CirfMat.Unique_vs_National__c = 'Unique';
            insert CirfMat;
            CirfMat2.Unique_vs_National__c = 'National';
            insert CirfMat2;
            CirfMat3=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material2.id,'Loaded',0,2);
            insert CirfMat3;
            CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            insert CirfMatForeCast;
            insert CirfMatForeCast2;
            CirfCorrMat=CIRF_TestDataFactory.createCIRFCorrugateMaterial(CirfMat.Id, CirfCorrugate.Id);
            BomItem=CIRF_TestDataFactory.createBomItem(Material.id);
            insert BomItem;
            SubLabelCode=CIRF_TestDataFactory.createSublabelCode(true,'11 - TVA Films');
            insert SubLabelCode;
        /*}catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }*/
        system.debug('acctRetailer=='+acctRetailer+'==CirfHeader=='+CirfHeader+'=CirfCorrugate='+CirfCorrugate);
        system.debug('Material=='+Material+'==CirfMat=='+CirfMat+'=CirfCorrMat='+CirfCorrMat+'==CirfMatForeCast=='+CirfMatForeCast);
        
        CIRF_Material__c CirfMat4=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material.id,'Loaded',0,2);
        insert CirfMat4;
        Test.startTest();
        CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
        insert CirfMatForeCast;
        CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
        CirfMatForeCast2.Parent_Forecast_Material__c = CirfMatForeCast.Id;
        insert CirfMatForeCast2;
        CIRFCreateForecastRecords2.Bomlist = new List<BOM_Item__c>{BomItem};
        CIRFCreateForecastRecords2.SplitForecastreclist = new List<CIRF_Material_Forecast__c>{CirfMatForeCast2};
        CIRFCreateForecastRecords2.forecastToInsert = new List<CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.forecastToUpdate  = new Map<Id,CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.Matlist = new List<Material__c> {Material};
        CIRFCreateForecastRecords2.relCMF = new List<CIRF_Material_Forecast__c> {CirfMatForeCast,CirfMatForeCast2};
        CIRFCreateForecastRecords2.allrelCMF = CIRFCreateForecastRecords2.relCMF;
        CIRFCreateForecastRecords2.ReplenFrstRecords(System.today(),'Group Z',CirfMat,  1, 'Initial Ship', false);
        CIRFCreateForecastRecords2.ReplenFrstRecords(System.today(),'Group Z',CirfMat,  1, 'Corrugate',true);
        
        Test.stopTest();
    }
    
    static testMethod void InitForecastRecordsTest() {
        //create test data
        //try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest3','Singles',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            CirfHeader2=CIRF_TestDataFactory.createCIRFHeader('CIRFTest4','Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Cancelled',true);
            insert CirfHeader2;
            CirfCorrugate=CIRF_TestDataFactory.createCIRFCorrugate(CirfHeader2.Id,'Test Corrugate','Pallet', 90);
            insert CirfCorrugate;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','123245', '24 - PURE FLIX', '122',null);
            insert Material; 
            Material2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '12346', '61 - Universal Pictures', 'AA','');
            insert Material2; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Loaded',0,2);
            CirfMat2=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material2.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = true;
            CirfMat.Unique_vs_National__c = 'Unique';
            CirfMat.Units_to_Order__c = 10;
            CirfMat.Corrugate_Units__c = 10;
            insert CirfMat;
            CirfMat2.Unique_vs_National__c = 'National';
            insert CirfMat2;
            CirfMat3=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material2.id,'Loaded',0,2);
            insert CirfMat3;
            CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Initial Ship',2,Material.Id,'Loaded',2);
            CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Corrugate',2,Material.Id,'Loaded',2);
            insert CirfMatForeCast;
            insert CirfMatForeCast2;
            CirfCorrMat=CIRF_TestDataFactory.createCIRFCorrugateMaterial(CirfMat.Id, CirfCorrugate.Id);
            BomItem=CIRF_TestDataFactory.createBomItem(Material.id);
            insert BomItem;
            SubLabelCode=CIRF_TestDataFactory.createSublabelCode(true,'11 - TVA Films');
            insert SubLabelCode;
        /*}catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }*/
        system.debug('acctRetailer=='+acctRetailer+'==CirfHeader=='+CirfHeader+'=CirfCorrugate='+CirfCorrugate);
        system.debug('Material=='+Material+'==CirfMat=='+CirfMat+'=CirfCorrMat='+CirfCorrMat+'==CirfMatForeCast=='+CirfMatForeCast);
        
        CIRF_Material__c CirfMat4=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader2.Id,Material.id,'Loaded',0,2);
        insert CirfMat4;
        Test.startTest();
        CirfMatForeCast=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Replenishment',2,Material.Id,'Loaded',2);
        insert CirfMatForeCast;
        CirfMatForeCast2=CIRF_TestDataFactory.createCIRFMaterialForecast(CirfHeader2.Id,CirfMat.Id,DateTime.now(),system.today(),'123','Replenishment',2,Material.Id,'Loaded',2);
        CirfMatForeCast2.Parent_Forecast_Material__c = CirfMatForeCast.Id;
        insert CirfMatForeCast2;
        CIRFCreateForecastRecords2.Bomlist = new List<BOM_Item__c>{BomItem};
        CIRFCreateForecastRecords2.SplitForecastreclist = new List<CIRF_Material_Forecast__c>{CirfMatForeCast2};
        CIRFCreateForecastRecords2.forecastToInsert = new List<CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.forecastToUpdate  = new Map<Id,CIRF_Material_Forecast__c>();
        CIRFCreateForecastRecords2.Matlist = new List<Material__c> {Material};
        CIRFCreateForecastRecords2.relCMF = new List<CIRF_Material_Forecast__c> {CirfMatForeCast,CirfMatForeCast2};
        CIRFCreateForecastRecords2.allrelCMF = CIRFCreateForecastRecords2.relCMF;
        CIRFCreateForecastRecords2.InitForecastRecords(System.today(),'Group Z',CirfMat,  1, 'Initial Ship', false);
        CIRFCreateForecastRecords2.InitForecastRecords(System.today(),'Group Z',CirfMat,  1, 'Corrugate',true);
        CIRFCreateForecastRecords2.CancelFrctRecords(CirfMat, CirfMatForeCast, 1, 'Initial Ship');
        Test.stopTest();
    }
}