@isTest
public class Test_CIRFMaterialValidation {

    @isTest
    public static void test1(){
        Map<Id, CIRF_Material__c> CirfMaterialMapOld = new Map<Id, CIRF_Material__c>();
        Map<Id, CIRF_Material__c> CirfMaterialMapNew = new Map<Id, CIRF_Material__c>();
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat1.Forecasting_Relevant_Flag_US__c =true;
        
        insert mat1;
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1235', '61 - Universal Pictures', 'AA','');
         mat2.Forecasting_Relevant_Flag_US__c =true;
        //mat2.Old_Material_No__c = mat1.id; 
        insert mat2;
        date startDate = date.newInstance(2018, 12, 13);
        date endDate = date.newInstance(2018, 12, 14);
        date insStoreDate = date.newInstance(2018, 12, 12);
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc.CIRF_RIM_Approval__c =true ;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
       // system.assertEquals('001M0000012Vm8UIAS', acc.id);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c= 'Universal';
        
        insert header;
        header.Request_Type__c='Reset/Transition';
        header.CIRF_Status__c='Submitted';
        update header;
        CIRF_Material__C cirfmat1 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat1.id, 'Draft', 2, 3);
        insert cirfmat1;
        CIRF_Material__C cirfmat2 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat2.id, 'Draft', 2, 2);
        insert cirfmat2;
        
        SAPZCMAT__c sapzmat1 = new SAPZCMAT__c();
        sapzmat1.Z_MATERIAL__c=mat1.id;
        insert sapzmat1;
        SAPZCMAT__c sapzmat2 = new SAPZCMAT__c();
        sapzmat2.Z_MATERIAL__c=mat2.id;
        insert sapzmat2;
        
        List<CIRF_Material__c> currentCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapOld.values()){            
                currentCIRFMatList.add(cmat);
            }
        
        cirfmat1.CIRF_Material_Status__c='Submitted';
        update cirfmat1;
        List<CIRF_Material__c> newCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapNew.values()){            
                newCIRFMatList.add(cmat);
            }  
            
        Test.startTest();
        CIRFMaterialValidation.CIRFMaterialValidationBefore(CirfMaterialMapOld,CirfMaterialMapNew);
        CIRFMaterialValidation.CIRFMaterialValidationAfter(CirfMaterialMapOld,CirfMaterialMapNew);
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        Map<Id, CIRF_Material__c> CirfMaterialMapOld = new Map<Id, CIRF_Material__c>();
        Map<Id, CIRF_Material__c> CirfMaterialMapNew = new Map<Id, CIRF_Material__c>();
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        Mat1.UPC__c = '1234444';
        insert mat1;
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1235', '61 - Universal Pictures', 'AA','');
        insert mat2;
        date startDate = date.newInstance(2018, 12, 13);
        date endDate = date.newInstance(2018, 12, 14);
        date insStoreDate = date.newInstance(2018, 12, 12);
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc.CIRF_RIM_Approval__c =true ;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c= 'Universal';
        
        insert header;
        header.Request_Type__c='Singles';
        header.CIRF_Status__c='Submitted';
        update header;
        CIRF_Material__C cirfmat1 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat1.id, 'Draft', 2, 3);
        insert cirfmat1;
        CIRF_Material__C cirfmat2 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat2.id, 'Draft', 2, 2);
        insert cirfmat2;
        
        SAPZCMAT__c sapzmat1 = new SAPZCMAT__c();
        sapzmat1.Z_MATERIAL__c=mat1.id;
        insert sapzmat1;
        SAPZCMAT__c sapzmat2 = new SAPZCMAT__c();
        sapzmat2.Z_MATERIAL__c=mat2.id;
        insert sapzmat2;
         
         List<SAPZCMAT__c> SAPZCMATList = new List<SAPZCMAT__c>();
        SAPZCMATList.add(sapzmat1);
        SAPZCMATList.add(sapzmat2);
        SAPZCMATList[0].Z_SOLDTO__c=acc.Sold_To__c;
        SAPZCMATList[0].Z_MAT_VFR__c=startDate-10;
        SAPZCMATList[0].Z_MAT_VTO__c=startDate+10;
        update SAPZCMATList;
        
        List<CIRF_Material__c> currentCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapOld.values()){            
                currentCIRFMatList.add(cmat);
            }
        
        cirfmat1.CIRF_Material_Status__c='Submitted';
        update cirfmat1;
        List<CIRF_Material__c> newCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapNew.values()){            
                newCIRFMatList.add(cmat);
            }
        
        Test.startTest();
        CIRFMaterialValidation.CIRFMaterialValidationBefore(CirfMaterialMapOld,CirfMaterialMapNew);
        CIRFMaterialValidation.CIRFMaterialValidationAfter(CirfMaterialMapOld,CirfMaterialMapNew);
        Test.stopTest();  
    }
    @isTest(seeAllData=true)
    
    public static void test3(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        Map<Id, CIRF_Material__c> CirfMaterialMapOld = new Map<Id, CIRF_Material__c>();
        Map<Id, CIRF_Material__c> CirfMaterialMapNew = new Map<Id, CIRF_Material__c>();
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat1.UPC__c='12345678';
        mat1.Format_Description__c = 'BD';
        insert mat1;
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1235', '61 - Universal Pictures', 'AA','');
        insert mat2;
        date startDate = date.newInstance(2018, 12, 13);
        date endDate = date.newInstance(2018, 12, 14);
        date insStoreDate = date.newInstance(2018, 12, 12);
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'US', 'Test3', '1275');
        acc.CIRF_RIM_Approval__c =true ;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c= 'Universal';
        insert header;
        header.Request_Type__c='Singles';
        header.CIRF_Status__c='Submitted';
        update header;
        CIRF_Material__C cirfmat1 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat1.id, 'Draft', 2, 3);
        insert cirfmat1;
        CIRF_Material__C cirfmat2 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat2.id, 'Draft', 2, 2);
        insert cirfmat2;
        
        SAPZCMAT__c sapzmat1 = new SAPZCMAT__c();
        sapzmat1.Z_MATERIAL__c=mat1.id;
        insert sapzmat1;
        SAPZCMAT__c sapzmat2 = new SAPZCMAT__c();
        sapzmat2.Z_MATERIAL__c=mat2.id;
        insert sapzmat2;
        
         List<SAPZCMAT__c> SAPZCMATList = new List<SAPZCMAT__c>();
        SAPZCMATList.add(sapzmat1);
        SAPZCMATList.add(sapzmat2);
        SAPZCMATList[0].Z_SOLDTO__c=acc.Sold_To__c;
        SAPZCMATList[0].Z_MAT_VFR__c=startDate-10;
        SAPZCMATList[0].Z_MAT_VTO__c=startDate+10;
        update SAPZCMATList;
        
        List<CIRF_Material__c> currentCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapOld.values()){            
                currentCIRFMatList.add(cmat);
            }
        
        cirfmat1.CIRF_Material_Status__c='Submitted';
        update cirfmat1;
        List<CIRF_Material__c> newCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapNew.values()){            
                newCIRFMatList.add(cmat);
            }
        mat1.Forecasting_Relevant_Flag_US__c=true;
        mat2.Forecasting_Relevant_Flag_US__c=true;
        Test.startTest();
        CIRFMaterialValidation.CIRFMaterialValidationBefore(CirfMaterialMapOld,CirfMaterialMapNew);
        CIRFMaterialValidation.CIRFMaterialValidationAfter(CirfMaterialMapOld,CirfMaterialMapNew);
        //system.assertEquals(header.Territory__c, 'US');
        Test.stopTest();
        
    }
      @isTest
    public static void testmethod1(){
        test.startTest();
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat.Forecasting_Relevant_Flag_US__c =true;
            insert mat;
            Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material2', '1265', '61 - Universal Pictures', 'AA','');
            insert mat2;       
            Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1275');
            insert acc;
            date startDate = date.newInstance(2018, 12, 13);
            date endDate = date.newInstance(2018, 12, 14);
            date insStoreDate = date.newInstance(2018, 12, 12);
            CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        
        
            insert header;
       // CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        
            //insert header2;
        header.CIRF_Status__c = 'Submitted';            
            update header;
        //header2.CIRF_Status__c ='Submitted';
        //update header2;
            CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
            cmat.Needs_Regie_Sticker__c = true;
        
            insert cmat;
             
         map<id,CIRF_Material__C> oldmap = new map<id,CIRF_Material__C>();
        oldmap.put(cmat.id, cmat);
        
        cmat.CIRF_Material_Status__c = 'Submitted';         
        update cmat;
       
        map<id,CIRF_Material__C> newmap = new map<id,CIRF_Material__C>();
        newmap.put(cmat.id, cmat);
        
        /*CIRF_Material__C cmat3 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Submitted', 2, 2);
            cmat.Needs_Regie_Sticker__c = true;
            insert cmat3;
              CIRF_Material__C cmat4 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat2.id, 'Submitted', 2, 2);
            cmat.Needs_Regie_Sticker__c = true;
            insert cmat4; */ 
            AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Shweta','Meshram');
            insert atm;
            //header.CIRF_Status__c = 'Submitted';          
            //update header;
            //cmat.CIRF_Material_Status__c = 'Submitted';           
            //update cmat;
        
                    
        
         CIRFMaterialValidation.CIRFMaterialValidationBefore(newmap,oldmap);
            Test.stopTest();
        
    }
    @isTest
     public static void testmethod2(){
        test.startTest();
  Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat2.Material_Description_Unique__c='TestMaterial1231';
        mat2.Material_Type__c = 'FERT';
        Id RecordTypeIdMat = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        mat2.recordTypeId= RecordTypeIdMat;
         insert mat2;
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'TestMaterial', '1235', '61 - Universal Pictures', 'AA','');
        mat.Forecasting_Relevant_Flag_US__c =true;
        mat.Old_Material_No__c = mat2.id;
         //mat.Format_Description__c= 'New Material';
        mat.Material_Description_Unique__c='TestMaterial22';
        insert mat;
      //     system.assertEquals(mat.Material_Description_Unique__c, mat.Old_Material_No__c);         
         
            Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1275');
            insert acc;
            date startDate = date.newInstance(2018, 12, 13);
            date endDate = date.newInstance(2018, 12, 14);
            date insStoreDate = date.newInstance(2018, 12, 12);
         
            CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
            insert header;
            header.CIRF_Status__c = 'Submitted';            
            update header;
            CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
            cmat.Needs_Regie_Sticker__c = true;
        
            insert cmat;
             
         map<id,CIRF_Material__C> oldmap = new map<id,CIRF_Material__C>();
        oldmap.put(cmat.id, cmat);
        
        cmat.CIRF_Material_Status__c = 'Submitted';         
        update cmat;
       
        map<id,CIRF_Material__C> newmap = new map<id,CIRF_Material__C>();
        newmap.put(cmat.id, cmat);
        //system.assertEquals(mat.Material_Description_Unique__c, mat.Old_Material_No__c);
         CIRFMaterialValidation.CIRFMaterialValidationBefore(newmap,oldmap);
          CIRFMaterialValidation.CIRFMaterialValidationAfter(newmap,oldmap);
         
            Test.stopTest();
    }
    @isTest(seeAllData=true)
    
    public static void test4(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        Map<Id, CIRF_Material__c> CirfMaterialMapOld = new Map<Id, CIRF_Material__c>();
        Map<Id, CIRF_Material__c> CirfMaterialMapNew = new Map<Id, CIRF_Material__c>();
        Material__c mat1 = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat1.UPC__c='12345678';
        mat1.Format_Description__c = 'BD';
        insert mat1;
        Material__c mat2 = CIRF_TestDataFactory.createMaterial('CDN', 'Test Material', '1235', '61 - Universal Pictures', 'AA','');
        insert mat2;
        date startDate = date.newInstance(2018, 12, 13);
        date endDate = date.newInstance(2018, 12, 14);
        date insStoreDate = date.newInstance(2018, 12, 12);
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer3', 'CA', 'Test3', '1275');
        acc.CIRF_RIM_Approval__c =true ;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header3', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c= 'Universal';
        
        insert header;
        header.Request_Type__c='Singles';
        header.CIRF_Status__c='Submitted';
        update header;
        CIRF_Material__C cirfmat1 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat1.id, 'Draft', 2, 3);
        insert cirfmat1;
        CIRF_Material__C cirfmat2 = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat2.id, 'Draft', 2, 2);
        insert cirfmat2;
        
        SAPZCMAT__c sapzmat1 = new SAPZCMAT__c();
        sapzmat1.Z_MATERIAL__c=mat1.id;
        insert sapzmat1;
        SAPZCMAT__c sapzmat2 = new SAPZCMAT__c();
        sapzmat2.Z_MATERIAL__c=mat2.id;
        insert sapzmat2;
        
         List<SAPZCMAT__c> SAPZCMATList = new List<SAPZCMAT__c>();
        SAPZCMATList.add(sapzmat1);
        SAPZCMATList.add(sapzmat2);
        SAPZCMATList[0].Z_SOLDTO__c=acc.Sold_To__c;
        SAPZCMATList[0].Z_MAT_VFR__c=startDate-10;
        SAPZCMATList[0].Z_MAT_VTO__c=startDate+10;
        update SAPZCMATList;
        
        List<CIRF_Material__c> currentCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapOld.values()){            
                currentCIRFMatList.add(cmat);
            }
        
        cirfmat1.CIRF_Material_Status__c='Submitted';
        update cirfmat1;
        List<CIRF_Material__c> newCIRFMatList = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : CirfMaterialMapNew.values()){            
                newCIRFMatList.add(cmat);
            }
        mat1.Forecasting_Relevant_Flag_CDN__c=true;
        mat2.Forecasting_Relevant_Flag_CDN__c=true;
        Test.startTest();
        CIRFMaterialValidation.CIRFMaterialValidationBefore(CirfMaterialMapOld,CirfMaterialMapNew);
        CIRFMaterialValidation.CIRFMaterialValidationAfter(CirfMaterialMapOld,CirfMaterialMapNew);
        //system.assertEquals(header.Territory__c, 'CDN');
        Test.stopTest();
        
    }
    @isTest
     public static void testmethod5(){
        test.startTest();
  Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        mat2.Material_Description_Unique__c='TestMaterial1231';
      //mat2.Forecasting_Relevant_Flag_US__c = true;
        mat2.Material_Type__c = 'FERT';
        Id RecordTypeIdMat = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
        mat2.recordTypeId= RecordTypeIdMat;
         insert mat2;
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'TestMaterial2', '1235', '61 - Universal Pictures', 'AA',null);
        mat.Forecasting_Relevant_Flag_US__c =true;
        mat.Old_Material_No__c = mat2.id;
         //mat.Format_Description__c= 'New Material';
        mat.Material_Description_Unique__c='TestMaterial22';
        insert mat;
        //system.debug('++++++testtttt'+mat.Material_Description_Unique__c);
         //System.debug('++++test'+mat.Old_Material_No__r.Forecasting_Relevant_Flag_US__c);         
         
            Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1275');
            insert acc;
            date startDate = date.newInstance(2018, 12, 13);
            date endDate = date.newInstance(2018, 12, 14);
            date insStoreDate = date.newInstance(2018, 12, 12);
         
            CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
            insert header;
            header.CIRF_Status__c = 'Submitted';            
            update header;
            CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
            cmat.Needs_Regie_Sticker__c = true;
        
            insert cmat;
             
         map<id,CIRF_Material__C> oldmap = new map<id,CIRF_Material__C>();
        oldmap.put(cmat.id, cmat);
        
        cmat.CIRF_Material_Status__c = 'Submitted';         
        update cmat;
       
        map<id,CIRF_Material__C> newmap = new map<id,CIRF_Material__C>();
        newmap.put(cmat.id, cmat);
        //system.assertEquals(mat.Material_Description_Unique__c, mat.Old_Material_No__c);
         CIRFMaterialValidation.CIRFMaterialValidationBefore(newmap,oldmap);
         CIRFMaterialValidation.CIRFMaterialValidationAfter(newmap,oldmap);
         
            Test.stopTest();
    }
    
}