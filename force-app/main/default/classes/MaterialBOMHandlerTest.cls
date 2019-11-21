/*****************************************************************************************
Class Name: MaterialBOMHandlerTest
Purpose: Test class for apex class MaterialBOMHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0                                  Ipsita                 Initial Development
******************************************************************************************/

@isTest
private class MaterialBOMHandlerTest{
@isTest
static void testMethod_1()
    {
       
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today().addMonths(1),Territory__c = 'US',Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Material_Status__c = 'Draft',Format_Description__c = 'DVD',Release__c = objRelease.id,Territory__c = 'US & CDN');
        //objMaterial.Label_Code__c='16 - Broadway';
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        objMaterial.Material_Number__c='11111111000';
        objMaterial.Selection_Reference_Number__c='11111111000';
        insert objMaterial;
        
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',objRelease.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        insert materialComponent;
     
        BOM_Item__c b = new BOM_Item__c();
        b.Material__c = objMaterial.Id;
        b.Material_Component__c = objMaterial.Id;
        Insert b;
       
       
       Test.startTest();
         PageReference pageRef = Page.CreateBOMItemPage;
         Test.setCurrentPage(pageRef);
         string parentID = ApexPages.currentPage().getParameters().put('id', objMaterial.id);       
         
         //ApexPages.StandardController sc = new ApexPages.StandardController(b);
         //MaterialBOMHandler conv=new MaterialBOMHandler(sc);
         //ApexPages.currentPage().getParameters().put('retURL', '/001');
        
        MaterialBOMHandler conv = new MaterialBOMHandler(new ApexPages.StandardController(new BOM_Item__c()));
        conv.BOMItemList[0].Material__c = objMaterial.Id;
        //adding BOM Item
        conv.addBOMItem();
        System.assert(conv.BOMItemList.size() == 2);
        conv.BOMItemList[1].Material__c = objMaterial.Id;
        
        conv.itemIndex = 1;
        conv.removeBOMItem();
        conv.save();
        
        //system.assertNotEquals(null, conv.childMaterialId);
        System.assert([SELECT Id FROM BOM_Item__c WHERE Material__c = :objMaterial.Id].size() == 2);
        //system.assertNotEquals(null, b);
        //System.assertNotEquals(objMaterial.Id,null );
        
         
         //conv.btnUploadCSV();
         //con.csvAsString = 'SampleTest';
         //conv.csvFileBody=Blob.valueOf('Unit,11111111000,CSV,File,Body \n Unit2,Test2,CSV2,File2,Body2 \r\n');
         //conv.materialID = objMaterial.Id;
         //conv.lstMaterialDetails.add(objMaterial);
         //conv.btnUploadCSV();
         //con.parentId = objMaterial.Id;

         conv.cancel();
      Test.stopTest();          
    } 
    
    @isTest
    static void testMethod_2(){
        List<Material__c>materialList = new List<Material__c>();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true);
        insert objTitle;
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today().addMonths(1),Territory__c = 'US',Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Material_Status__c = 'Draft',Format_Description__c = 'DVD',Release__c = objRelease.id,Territory__c = 'US & CDN');
        //objMaterial.Label_Code__c='16 - Broadway';
        objMaterial.Label_Code__c ='24 - PURE FLIX';
        objMaterial.Material_Number__c='11111111000';
        objMaterial.Selection_Reference_Number__c='11111111000';
        
        Material__c materialComponent =  testClassUtility.createMaterial('03 - COMBO PACK','COMBO PACK','TESTcomponent','ROH',objRelease.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        materialList.ADD(materialComponent);
        materialList.ADD(objMaterial);
        
        insert materialList;
        /*
        BOM_Item__c b = new BOM_Item__c();
        b.Material__c = objMaterial.Id;
        b.Material_Component__c = objMaterial.Id;
        Insert b;
        */
        
       
       /*string csvLine1 = '11111111000,terrr';
       string csvLine2= 'Test1,dsfdsfsdfds';
       String blobCreator = csvLine1 + '\r\n' + csvLine2 ;  */ 
       
       Blob blobCreator = Blob.valueOf('11111111000 \n ,11111111000, Body \n Line 2 \n Line 3');     
       
        Test.startTest();
         Material__c material  = [select id,Material_Number__c from Material__c where ID  =: objMaterial.ID];
         system.assertNotEquals(null,material);
         system.assertNotEquals(null,material.Material_Number__c);
         PageReference pageRef = Page.CreateBOMItemPage;
         Test.setCurrentPage(pageRef);
         string parentID = ApexPages.currentPage().getParameters().put('id', material.id);       
         
         ApexPages.StandardController sc = new ApexPages.StandardController(material);
        
         MaterialBOMHandler conv = new MaterialBOMHandler(sc);
        
         conv.csvContentType = '.csv';
         
         conv.csvFileBody = blobCreator ;
         conv.csvAsString = 'TestFile';
         conv.btnUploadCSV();
         //system.assertNotEquals('',conv.csvFileBody);
         system.assertNotEquals(null,conv.csvFileBody);
         
         // as of now calling all methods
         conv.hasNext = false;
         conv.hasPrevious = true;
         conv.pageNumber = 1;
         conv.first();
         conv.last();
         conv.previous();
         conv.next();
         conv.resultSize =1;
         conv.mtRowNumber = 0;
         conv.paramID = material.id;
         conv.selectedRowNumber = 0;
         conv.setSelectedMaterial();
         conv.removeSelectedMaterial();
         
         conv.selectedFirst();
         conv.selectedNext();
         conv.selectedLast();
         conv.selectedPrevious();
         conv.selectedHasNext = false;
         conv.selectedHasPrevious =false;
         conv.selectedPageNumber = 1;
         conv.selectedResultSize = 1;
         
         
         conv.accept();
         conv.removeAll();

        Test.StopTest();
    
    }
    
 }