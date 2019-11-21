@isTest(seealldata=false)
public class test_UploadCIRFMaterialsController {
    
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
        CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header Submitted', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Submitted' , false);
        insert new List<CIRF_Header__c>{header1,header2};

    }
    
   	@isTest
    public Static void testUploadCIRFMaterials(){
       Id headerid = 'a3LM0000000XH2AMAW'; 
       String str = 'Material Description,Material Number,SRP,DRC,Account Retail Price,Promo Cost,Funding Notes,Units to Order,Replen Duration,Replen Units,Number of Regie Stickers,Fully Built,Exception End Date \n'+
		'"""12TH MAN BD""",86507199000,10,11,20,6,Need more,11,1,20,5,FALSE,1/1/2018\n'+
		'"""12TH MAN BD""",86507199000,10,11,20,6,Need more,12,1,20,5,FALSE,2/2/2018\n'+
		'12TH MAN DVD,24523535,20,21,40,6,Need more,21,2,20,5,FALSE,1/3/2018\n'+
		'12TH MAN DVD,3252353,20,21,40,6,Need more,22,2,20,5,FALSE,4/1/2018\n'+
		'"PAPILLON (2017) ,DVD CDN",32201090000,30,21,60,6,Need more,31,3,20,5,FALSE,5/1/2018\n'+
		'"PAPILLON (2017) ,DVD CDN",32201090000,30,21,60,6,Need more,32,3,20,5,FALSE,6/1/2018\n'+
		'"BUY  BUST,"" BDC",80199705000,20,31,80,6,Need more,41,4,20,5,FALSE\n'+
		'BUY  BUST BDC,80199705000,20,31,80,6,Need more,42,4,20,5,FALSE\n'+
		'"AFRAID, DVD",80199727000,10,11,100,6,Need more,51,5,20,5,FALSE\n'+
		'"AFRAID, DVD",80199727000,10,11,100,6,Need more,52,5,20,5,FALSE';
        	UploadCIRFMaterialsController.UploadCIRFMaterials(str,headerid);
    }   
    
    @isTest
    public Static void testUploadCIRFMaterialsAdditionalFunctions(){
       	System.AssertEquals('Material Number,SRP,DRC,Account Retail Price,Promo Cost,Funding Notes,Discount Type,Single Units,Replen Units,French Units Required,Sticker Price,Sticker Item Number,Genre/Location/Other Info',UploadCIRFMaterialsController.getCIRFMaterialTemplate());
        CIRF_Header__c header = [Select id from CIRF_Header__c where CIRF_Status__c = 'Draft'];
        System.assertEquals('success', UploadCIRFMaterialsController.checkValidations(header.id));
        header = [Select id from CIRF_Header__c where CIRF_Status__c = 'Submitted'];
        System.assertNotEquals('success', UploadCIRFMaterialsController.checkValidations(header.id));
    }   
}