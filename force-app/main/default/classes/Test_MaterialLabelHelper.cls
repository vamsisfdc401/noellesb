@isTest
public class Test_MaterialLabelHelper {
	@isTest
    public static void testgetLabelCustMktApprovalMap(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AC','');
        mat.Label_Code__c = '61 - Universal Pictures';
        mat.Product_Class__c = '01 - CATALOG';
        insert mat;             
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');      
        insert acc;        
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2); 
        
        List<CIRF_Material__C> cmatList = new List<CIRF_Material__C>{cmat};            
        Material_Label_Code_Default__c matLabel = new   Material_Label_Code_Default__c();
        matLabel.Label_Code_Key__c = '61 - Universal Pictures';
        matLabel.Studio__c = 'Universal';
        matLabel.CIRF_Customer_Marketing_Approval__c = true;       
        insert matLabel;
             
        MaterialLabelHelper.getLabelCustMktApprovalMap(cmatList);
        MaterialLabelHelper.getLabelPlanningGroupMap(cmatList);
        //MaterialLabelHelper.getPlanningGroupByLabelCode2(mat);
              
        matLabel.Studio__c ='PHE';
        update matLabel;
        //MaterialLabelHelper.getPlanningGroupByLabelCode2(mat);
               
        //matLabel.Studio__c = 'Partners';
        //update matLabel;
        //MaterialLabelHelper.getPlanningGroupByLabelCode2(mat);       
    }
    @isTest
    public static void testgetPublicGroup(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AC','');
        mat.Label_Code__c = '61 - Universal Pictures';
        mat.Product_Class__c = '02 - HIT';
        insert mat;             
        
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');      
        insert acc;        
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header.Studio__c = 'Universal';
        insert header;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2); 
        
        List<CIRF_Material__C> cmatList = new List<CIRF_Material__C>{cmat};            
        Material_Label_Code_Default__c matLabel = new   Material_Label_Code_Default__c();
        matLabel.Label_Code_Key__c = '61 - Universal Pictures';
        matLabel.Studio__c = 'Universal';
        matLabel.CIRF_Customer_Marketing_Approval__c = true;       
        insert matLabel;
             
        //MaterialLabelHelper.getPlanningGroupByLabelCode2(mat);
              
        matLabel.Studio__c ='PHE';
        update matLabel;
        MaterialLabelHelper.getPlanningGroupByLabelCode('61 - Universal Pictures','02 - HIT');
        MaterialLabelHelper.getPublicGroup('Universal','01 - Catalog');
        MaterialLabelHelper.getPublicGroup('Partners','02 - HIT');
        MaterialLabelHelper.getPublicGroup('Partners','01 - Catalog');
        MaterialLabelHelper.getPublicGroup('PHE','02 - HIT');
        MaterialLabelHelper.getPublicGroup('PHE','01 - Catalog');
        
    }
}