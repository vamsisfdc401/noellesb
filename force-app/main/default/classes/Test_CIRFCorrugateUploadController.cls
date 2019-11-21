@isTest(seealldata=false)
public class Test_CIRFCorrugateUploadController {
    
    @testSetup
    public static void testData(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AA','');
        mat.RecordTypeId = Utility.getRecordTypeId('Material','Material__c');
        insert mat;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header Loaded', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Loaded' , false);
        insert new List<CIRF_Header__c>{header1,header2};
            CIRF_Material__C cmat2 = CIRF_TestDataFactory.createCIRFMaterial(header2.id, mat.id, 'Draft', 2, 3);
        insert cmat2;
        CIRF_Corrugate__c ccorr2 =CIRF_TestDataFactory.createCIRFCorrugate(header2.id,'test corrugate2','Singles Request', 2);
        insert ccorr2;
        CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.Id,ccorr2.Id);
        corrmat.Facings__c = 2;
        insert corrmat;
    }
    
    @isTest
    public Static void testCIRFCorrugateUpload(){
        Id headerid = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'].id;
        String str = 'Corrugate Request Name,Number of Stores,Corrugate Type,Street Date Sticker Required,PHE MPM Issue,Fully Built,Corrugate Material,Material Number,Facings,Units per Pocket,Number of Empties\n'+
            'Small,128,Pallet,,,FALSE,,86507199000,1,8,0\n'+
            'Small  Testing above 50 Characters That is the limit of the field for which this value is being assigned,128,Pallet,,,FALSE,,86507199000,1,7,0\n'+
            'Small,128,Pallet,,,FALSE,,59199424362436649000,1,6,0\n'+
            'Small,128,Pallet,,,FALSE,,61199504000,2,5,0\n'+
            ',128,Pallet,,,FALSE,,36198983000,2,9,0\n'+
            'Small,128,Pallet,,,1,,61199535000,1,10,0\n'+
            'Small,128,Pallet,,,0,,36200304000,1,-8,0\n'+
            'Small,128,Pallet,,,TRUE,,55198278000,-1,8,0\n'+
            'Small,1223543258,Pallet,,,TRUE,,26199167000,2,3,0\n'+
            'Medium,30,Pallet,,,TRUE,,88196700000,1,11,0\n'+
            'Medium,30,Pallet,,,TRUE,,,1,5643,0\n'+
            'Medium,30,Pallet,,,TRUE,,59199649000,1,9.5,0\n'+
            'Medium,30,Pallet,,,FALSE,,,2,13,0\n'+
            'Medium,-30,Pallet,,,FALSE,,24200101000,1,8,0\n'+
            'Medium,30,Pallet,,,FALSE,,36198988000,2,12,0\n'+
            'Medium,30,Pallet,,,FALSE,,57200038000,1,10,0\n'+
            'Medium,abc,Pallet,,,FALSE,,,1,8,0\n'+
            'Medium,30,Pallet,,,FALSE,,611995adsf35000,1,7,0\n'+
            ',,,,,,,,,,0\n'+
            'Medium,30,Pallet,,,FALSE,,null,2,11,0\n'+
            'Medium,30,Pallet,,,FALSE,,26199167000,1,4,0\n';
        Test.startTest();
        CIRFCorrugateUploadController.CIRFCorrugateUpload(str,headerid);
        Test.stopTest();
    }   
    
    @isTest
    public Static void testCIRFCorrugateUpload2(){
        Id headerid = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'].id;
        String str = 'Corrugate Request Name,Number of Stores,Corrugate Type,Street Date Sticker Required,PHE MPM Issue,Fully Built,Corrugate Material,Material Number,Facings,Units per Pocket,Number of Empties,Regie Required\n'+
            'Small,128,Pallet,,,FALSE,,,1,8,0,1\n'+
            'Small  Testing above 50 Characters That is the limit of the field for which this value is being assigned,128,Pallet,,,FALSE,,86507199000,1,7,0,0\n'+
            'Small,128,Pallet,,,FALSE,,59199424362436649000,1,6,0,true\n'+
            'Small,128,Pallet,,,FALSE,,61199504000,2,5,0,false\n'+
            ',128,Pallet,,,FALSE,,36198983000,2,9,0,1\n'+
            'Small,128,Pallet,,,1,,61199535000,1,10,0,0\n'+
            'Small,128,Pallet,,,0,,36200304000,1,-8,0,0\n'+
            'Small,128,Pallet,,,TRUE,,55198278000,-1,8,0,0\n'+
            'Small,1223543258,Pallet,,,TRUE,,26199167000,2,3,0,0\n'+
            'Medium,30,Pallet,,,TRUE,,88196700000,1,11,0,0\n'+
            'Medium,30,Pallet,,,TRUE,,,1,5643,0,1\n'+
            'Medium,30,Pallet,,,TRUE,,59199649000,1,9.5,0,1\n'+
            'Medium,30,Pallet,,,FALSE,,,2,13,0,1\n'+
            'Medium,-30,Pallet,,,FALSE,,24200101000,1,8,0,1\n'+
            'Medium,30,Pallet,,,FALSE,,36198988000,2,12,0,0\n'+
            'Medium,30,Pallet,,,FALSE,,57200038000,1,10,0,0\n'+
            'Medium,abc,Pallet,,,FALSE,,,1,8,0,0\n'+
            'Medium,30,Pallet,,,FALSE,,611995adsf35000,1,7,0,0\n'+
            ',,,,,,,,,,0,0\n'+
            'Medium,30,Pallet,,,FALSE,,null,2,11,0,1\n'+
            'Medium,30,Pallet,,,FALSE,,26199167000,1,4,0,1\n';
        Test.startTest();
        CIRFCorrugateUploadController.CIRFCorrugateUpload(str,headerid);
        Test.stopTest();
    }
    
    @isTest
    public Static void testCIRFCorrugateUploadBlank(){
        Id headerid = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'].id;
        String str = 'Corrugate Request Name,Number of Stores,Corrugate Type,Street Date Sticker Required,PHE MPM Issue,Fully Built,Corrugate Material,Material Number,Facings,Units per Pocket,Number of Empties,Regie Required\n';
        Test.startTest();
        CIRFCorrugateUploadController.CIRFCorrugateUpload(str,headerid);
        Test.stopTest();
    }
    
    @isTest
    public Static void testCIRFCorrugateUpload3(){
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer55', 'US', 'Test', '123455555');
        insert acc;
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header22', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        insert header;
        //Id headerid = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'].id;
        String str = 'Corrugate Request Name,Number of Stores,Corrugate Type,Street Date Sticker Required,PHE MPM Issue,Fully Built,Material Number,Facings,Units per Pocket,Number of Empties,Regie Required\n'+
            'test,5,Pallet,true,yes,0,86507199000,2,2,2,0';
        Test.startTest();
        System.debug(CIRFCorrugateUploadController.CIRFCorrugateUpload(str,header.id));
        Test.stopTest();
    }
    
    @isTest
    public Static void testCIRFCorrugateUploadAdditionalFunctions(){
        CIRFCorrugateUploadController.getCIRFCorrugateTemplate();
        CIRF_Header__c header = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'];
        System.assertEquals('success', CIRFCorrugateUploadController.checkValidations(header.id));
        header = [Select id from CIRF_Header__c where CIRF_Status__c = 'Loaded'];
        System.assertNotEquals('success', CIRFCorrugateUploadController.checkValidations(header.id));
        header.CIRF_Status__c = 'Complete';
        update header;
        System.assertNotEquals('success', CIRFCorrugateUploadController.checkValidations(header.id));
        
    }   
    
}