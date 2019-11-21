@isTest
public class test_CIRFMaterialExceptionsUpload {
    @testSetup
    public static void testData(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'IM','86507199001');
        mat.Item_Type__c = 'M (Multipack)';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        mat.RecordTypeId = Utility.getRecordTypeId('Material','Material__c');
        insert mat; 
        Material__c mat2= CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199002', '61 - Universal Pictures', 'RP','86507199003');
        mat.RecordTypeId = Utility.getRecordTypeId('Request','Material__c');
        insert mat2;
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
        acc.CIRF_RIM_Approval__c = true;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        insert acc;
        AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        insert atm;
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header Loaded', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Loaded' , false);
        insert new List<CIRF_Header__c>{header1,header2};
            }
    
    @isTest
    public static void testCIRFMaterialExceptionsUploadMethod(){
        CIRFMaterialExceptionsUpload.getCIRFMaterialExceptionTemplate();
        Account retailer = [Select id, name from Account Limit 1];
        CIRF_Header__c header = [Select id,name from CIRF_Header__c Limit 1]; 
        CIRF_Header__c header2 = [Select id,name from CIRF_Header__c where CIRF_Status__c = 'Loaded' Limit 1];
        String str = 'Material,CIRF Header,Retailer,Exception Type,Start Date,End Date\n'+
            '86507199000,'+header.name+','+retailer.name+',Temporary Status Exception,12/12/2018,12/24/2018\n'+
            '86507199000,'+header2.name+','+retailer.name+',Temporary Status Exception,12/12/2018,12/24/2018\n'+
            '86507199000,'+header.name+','+retailer.name+',Temporary Status Exception,12/24/2018,12/12/2018\n'+
            '86507199000,'+header.name+','+retailer.name+',,12/12/2018,12/24/2018\n'+
            '86507199000,,'+retailer.name+',Temporary Status Exception,12/12/2018,12/24/2018\n'+
            '86507199000,'+header.name+',,Temporary Status Exception,12/12/2018,12/24/2018\n'+
            ','+header.name+','+retailer.name+',Temporary Status Exception,12/12/2018,12/24/2018\n'+
            '86507199000,'+header.name+','+retailer.name+',Temporary Test,12/12/2018,12/24/2018\n'+
            '86507199000,'+header.name+','+retailer.name+',Temporary Status Exception,,12/24/2018\n'+
            '86507199000,'+header.name+','+retailer.name+',Temporary Status Exception,12/12/2018,0\n'+
            '86507199000,'+header.name+','+retailer.name+',,12/12/2018,12/24/2018\n'+
            '61208347000,'+header.name+','+retailer.name+',5235,12/12/2018,12/24/2018\n'+
            '86507199000,Test Header Loaded,Walmart - US,Temporary Status Exception,Test,12/24/2018';
        
        Test.startTest();
        CIRFMaterialExceptionsUpload.CIRFMaterialExceptionsUploadMethod(str);
        //System.assertEquals(1,[Select id from CIRF_Material_Exceptions__c].size());
        Test.stopTest();
    }
}