@isTest
public class Test_CIRFCorrugateMaterialTriggerHandler {
   
     
    @isTest
public static void testmethod1(){
   CIRFCorrugateMaterialTriggerHandler.isFirstTime=true;

    Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
            insert mat;
       
            date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
         
            //CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Loaded' , false);
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
           
            CIRF_Corrugate_Material__c corrmat = CIRF_TestDataFactory.createCIRFCorrugateMaterial_New(mat.Id,ccorr2.Id);
            corrmat.Facings__c = 2;
            insert corrmat;//for CIRFCorrugateTriggerHandler beforeUpdate()
            Material__c mat2 = CIRF_TestDataFactory.createMaterial('US', 'Test Material2', '12348', '61 - Universal Pictures', 'AA','');
            insert mat2;

            Test.startTest();
         ccorr2.Number_Of_Stores__c = 3; 
            update ccorr2;//for CIRFCorrugateTriggerHandler beforeUpdate()
            //cmat2.Material_Name__c = mat2.Id;
            //update cmat2;
            CIRFCorrugateMaterialTriggerHandler.isFirstTime = true;
    		CIRFCorrugateMaterialTriggerHandler.UpdatedFromMaterial = false;
            corrmat.Material_Name__c = mat2.id;
            corrmat.Facings__c= 3;
            update corrmat;
      
       delete corrmat;
       
    Test.stopTest();
}
}