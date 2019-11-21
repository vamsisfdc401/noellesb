@isTest
public class Test_CIRFMaterialStatusCheck {
    
    @testSetup
    public static void testData(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AC','86507199001');
        insert mat; 
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
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Material_Label_Code_Default__c md = new Material_Label_Code_Default__c();
        md.Label_Code_Key__c = '61 - Universal Pictures';
        md.CIRF_Customer_Marketing_Approval__c = true;
        insert md;
        
      }
    
    @isTest(SeeAllData = false)
    public static void testperformManualApprovalAction(){
        
		Material__c mat = [select id,CIRF_US_D_Chain_Spec__c,Item_Type__c,Item_Code__c from Material__c limit 1];		
        mat.CIRF_US_D_Chain_Spec__c = 'AC';
        mat.Item_Type__c = 'M (Multipack)';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        
        update mat;
        map<id,CIRF_Material__C> mapmat = New Map<id,CIRF_Material__C>([Select id,Material_Name__c,CIRF_Header__c,CIRF_Material_Status__c,Material_Label_Code__c,Customer_Marketing_Approval__c,Creator_Approval__c from CIRF_Material__C]);
        list< CIRF_Material__C> listmat = mapmat.values();
         CIRF_Header__c ch = [select id,CIRF_Status__c from CIRF_Header__c ];
        
        Test.startTest();
        
        CIRFHeaderApprovalController.checkValidations(ch.id);
        ch.CIRF_Status__c = 'Submitted';
        ch.RIM_Approval__c = true;
        ch.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update ch;
                
        CIRFHeaderApprovalController.checkValidations(ch.id);
        
        
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        //CIRFMaterialStatusCheck.SendEmailToPlannerGroup(listmat);
        CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(listmat);
        
        
        Test.stopTest();
    }
     @isTest(SeeAllData = false)
    public static void testStatusNotACRP(){
        Material__c mat = [select id,CIRF_US_D_Chain_Spec__c from Material__c limit 1];		
        mat.CIRF_US_D_Chain_Spec__c = 'NR';
        mat.D_Chain_Spec__c = 'NR';
        mat.Item_Type__c = 'M (Multipack)';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        
        update mat;
        map<id,CIRF_Material__C> mapmat = New Map<id,CIRF_Material__C>([Select id,Material_Name__c,CIRF_Header__c,CIRF_Material_Status__c from CIRF_Material__C]);
        list< CIRF_Material__C> listmat = mapmat.values();
        CIRF_Header__c ch = [select id,CIRF_Status__c from CIRF_Header__c ];
        
        Test.startTest();
        
        CIRFHeaderApprovalController.checkValidations(ch.id);
        ch.CIRF_Status__c = 'Submitted';
        ch.RIM_Approval__c = true;
        ch.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update ch;
        
        
        CIRFHeaderApprovalController.checkValidations(ch.id);                
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        mat.Item_Code__c = 'MS - TV MULTIPLE SERIES';
        update mat;
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        mat.Item_Type__c = 'S (Single)';
        update mat;
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        Test.stopTest();
    }
    
    @isTest
    public static void testNotMultipack(){
        
        Material__c mat = [select id,CIRF_US_D_Chain_Spec__c from Material__c limit 1];		
        mat.CIRF_US_D_Chain_Spec__c = 'NR';
        mat.D_Chain_Spec__c = 'NR';
        //mat.Item_Type__c = 'D (Display Vehicle)';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        
        update mat;
        map<id,CIRF_Material__C> mapmat = New Map<id,CIRF_Material__C>([Select id,Material_Name__c,CIRF_Header__c,CIRF_Material_Status__c from CIRF_Material__C]);
        list< CIRF_Material__C> listmat = mapmat.values();
        CIRF_Header__c ch = [select id,CIRF_Status__c from CIRF_Header__c ];
        ch.CIRF_Status__c = 'Draft';
        update ch;
        CIRF_Material__c cmat = [select id, CIRF_Material_Status__c from CIRF_Material__c limit 1];
        cmat.CIRF_Material_Status__c = 'Draft';
        //cmat.CIRF_Header__c = ch.id;
        update cmat;
        Test.startTest();
        
        CIRFHeaderApprovalController.checkValidations(ch.id);
        ch.CIRF_Status__c = 'Submitted';
        ch.RIM_Approval__c = true;
        ch.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update ch;
        
        
        CIRFHeaderApprovalController.checkValidations(ch.id);                
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        mat.Item_Code__c = 'MS - TV MULTIPLE SERIES';
        update mat;
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        mat.Item_Type__c = 'S (Single)';
        update mat;
        CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(listmat,mapmat);
        Test.stopTest();
        /*CIRFMaterialStatusCheck.S1DoNothing();
        CIRFMaterialStatusCheck.S2AProcess(new List<CIRF_Material__c>());
        CIRFMaterialStatusCheck.S2B1Process(new List<CIRF_Material__c>{cmat});
        CIRFMaterialStatusCheck.cmTaskCreated = false;
        try {
        	CIRFMaterialStatusCheck.S2B3Process(new List<CIRF_Material__c>{cmat});
        } catch(Exception ex) {
            
        }*/
    }
    
    @isTest
    public static void testMatException(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AC','86507199001');	
        mat.CIRF_US_D_Chain_Spec__c = 'DS';
        mat.D_Chain_Spec__c = 'DS';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        insert mat; 
        Account acc = [select id from account limit 1];
        date startDate1 = date.newInstance(2017, 12, 11);
        date endDate1 = date.newInstance(2019, 12, 12);
        CIRF_Material_Exceptions__c exc = CIRF_TestDataFactory.createCmatException(mat.id, acc.id,startDate1, endDate1);
        exc.Exception_Type__c = 'Temporary Status Exception';
        insert exc;
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Test.startTest();
        
        CIRFHeaderApprovalController.checkValidations(header1.id);
        header1.CIRF_Status__c = 'Submitted';
        header1.RIM_Approval__c = true;
        header1.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header1;
       
        Test.stopTest();
    }
    @isTest
    public static void testMatException2(){
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'AC','86507199001');	
        mat.CIRF_US_D_Chain_Spec__c = 'SD';
        mat.D_Chain_Spec__c = 'SD';
        //mat.Item_Type__c = 'S (Single)';
        mat.Item_Code__c = 'SS - SINGLE SELECTION';
        insert mat; 
        Account acc = [select id from account limit 1];
   
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        //cmat.Creator_Approval__c = true;
        //cmat.Planning_Approval__c = true;
        insert cmat;
        Test.startTest();
        
        CIRFHeaderApprovalController.checkValidations(header1.id);
        header1.CIRF_Status__c = 'Submitted';
        header1.RIM_Approval__c = true;
        header1.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header1;
       
        Test.stopTest();
    }
    @isTest
    public static void testMatException3(){
       Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'NR','86507199001');
        mat.CIRF_US_D_Chain_Spec__c = 'NR';
        mat.D_Chain_Spec__c = 'NR';
        //mat.Item_Type__c = 'M (Multipack)';
        //mat.Item_Code__c = 'XS - SPECIAL SINGLE';
        insert mat; 
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer12', 'US', 'Test', '1234555');
        //acc.CIRF_RIM_Approval__c = true;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        insert acc;
        //AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        //insert atm;
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Singles', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header1.id);
        header1.CIRF_Status__c = 'Submitted';
        header1.RIM_Approval__c = true;
        header1.RIM_Approval_Reason__c = 'RIM Approved CIRF';
        update header1;
        Test.stopTest();
    }
    
    /*@isTest
    public static void testMatException4(){
       Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'NR','86507199001');
        mat.CIRF_US_D_Chain_Spec__c = 'ID';
        mat.D_Chain_Spec__c = 'ID';
        insert mat; 
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer12', 'US', 'Test', '1234555');
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        insert acc;
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Singles', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header1.id);
        cmat.Creator_Approval__c = true;
        cmat.Planning_Approval__c = true;
        CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(new List<CIRF_Material__c>{cmat});
        cmat.Customer_Marketing_Approval__c = true;
        CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(new List<CIRF_Material__c>{cmat});
        //update cmat;
        Test.stopTest();
    }*/
    
    @isTest
    public static void testMatException5(){
       Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '86507199000', '61 - Universal Pictures', 'NR','86507199001');
        mat.CIRF_US_D_Chain_Spec__c = 'NR';
        mat.D_Chain_Spec__c = 'NR';
        mat.Item_Type__c = 'M (Multipack)';
        mat.Item_Code__c = 'XS - SPECIAL SINGLE';
        insert mat; 
        Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer12', 'US', 'Test', '1234555');
        //acc.CIRF_RIM_Approval__c = true;
        acc.CIRF_No_RIM_Approval__c = 'Universal';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('UPHE Retailer').getRecordTypeId();
        insert acc;
        //AccountTeamMember atm = CIRF_TestDataFactory.createRIMAccountTeam(acc.id,'Siddhesh','Jawale');
        //insert atm;
        date startDate = date.newInstance(2018, 12, 11);
        date endDate = date.newInstance(2018, 12, 12);
        date insStoreDate = date.newInstance(2018, 12, 10);
        CIRF_Header__c header1 = CIRF_TestDataFactory.createCIRFHeader('Test Header Draft', 'Singles', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
        header1.Studio__c = 'Universal';
        insert header1;
        CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header1.id, mat.id, 'Draft', 2, 2);
        insert cmat;
        Test.startTest();
        CIRFHeaderApprovalController.checkValidations(header1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetUserIdsFromGroup(){
        Group grp = new Group();
        grp.Name = 'Master_Data';
        grp.type = 'Queue';
        insert grp;
     	
        CIRFMaterialStatusCheck.GetUserIdsFromGroup(grp.id);
        CIRFMaterialStatusCheck.fetchGroupMembers(grp.id);
        
    }
}