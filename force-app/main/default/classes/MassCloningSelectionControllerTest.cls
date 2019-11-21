/*****************************************************************************************
Class Name: MassCloningSelectionControllerTest
Purpose: Test class for apex class MassCloningSelectionController 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/11/2016           Suman                    Initial Development
2.0             25/09/2017           Jyothsna                 added code changes for REL-40 
******************************************************************************************/
@isTest(seeallData = FALSE)
public class MassCloningSelectionControllerTest
{
    private static User userBrand;
    private static User userMasterDataAdmin;
    private static List<User> users;
    private static User sysAdminUser;
    
    static void dataSetup()
    {
        Profile objProfile=[Select Id from Profile where Name ='System Administrator'];        
        sysAdminUser = new User(alias = 'TestUser', 
                           email='test@test.com',
                           emailencodingkey='UTF-8', 
                           lastname='Testing', 
                           languagelocalekey='en_US',
                           localesidkey='en_US', 
                           //UserRoleId=objRole.Id, 
                           profileid=objProfile.ID,
                           country='United States',
                           timezonesidkey='America/Los_Angeles', 
                           username='testadmin345@test.com',
                           isActive = true);
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Database.insert(sysAdminUser);
        }        
        
        Profile profileBrand = [select id from profile where name='Brand User' ];        
        userBrand = new User(alias = 'testBD', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand@test.com.brand',
                             isActive = true);     
        Database.insert(userBrand);
        
        Profile profileMaster = [select id from profile where name='Master Data Admin' ];        
        userMasterDataAdmin = new User(alias = 'TestMa', 
                                       email='testmaster@test.com',
                                       emailencodingkey='UTF-8', 
                                       lastname='Testing', 
                                       languagelocalekey='en_US',
                                       localesidkey='en_US', 
                                       profileid=profileMaster.ID,
                                       country='United States',
                                       timezonesidkey='America/Los_Angeles', 
                                       username='testMaster@test.com.master',
                                       isActive = true);                 
        Database.insert(userMasterDataAdmin);
    }
    
    /************************************
    Method Name: scenario1
    Purpose: test method
    *************************************/   
    @isTest
    static void scenario1()
    {       
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c = 'New Release');
        insert objRelease; 
        
        List<Material__c> insertableMats = new List<Material__c>();
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Material_Status__c='Draft', Format_Description__c='DVD');
        //insertableMats.add(matFERT1);
        TriggerUtility.donotExecute = TRUE;
        insert matFERT1;
        
        Material__c matFERT2 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD');
        //insertableMats.add(matFERT2);
        insert matFERT2;
        
        Material__c matFERT3 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD', UPC__c = '01234567891');
        
        
        Material__c matFERT4 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD', UPC__c = '01234567891');
        
        
        Material__c matROH1 = new Material__c(name='Test ROH 1', Material_Description_Unique__c='Test ROH 1', Material_Type__c= 'ROH', Release__c=objRelease.id, Territory__c='US', Item_type__c='C - Components', Item_Code__c='PG - PACKAGING', Material_Status__c='Draft', Format_Description__c='DVD', Component_Type__c='LITHO');
        //insertableMats.add(matROH1);
        insert matROH1;
        TriggerUtility.donotExecute = FALSE;
        //insert insertableMats;
        
        List<BOM_Item__c> insertableBomItems = new List<BOM_Item__c>();
        
        BOM_Item__c bom1 = new BOM_Item__c(Material__c=matFERT1.Id, Material_Component__c=matFERT2.Id);
        insertableBomItems.add(bom1);
        
        BOM_Item__c bom2 = new BOM_Item__c(Material__c=matFERT2.Id, Material_Component__c=matROH1.Id);
        insertableBomItems.add(bom2);
        
        insert insertableBomItems;
        
        matFERT1.Material_Status__c = 'Processed in SAP';
        matFERT1.Material_Number__c = '59200098000';
        update matFERT1;
        
        matFERT2.Material_Status__c = 'Processed in SAP';
        matFERT2.Material_Number__c = '59200099000';
        //update matFERT2;
        
        matROH1.Material_Status__c = 'Processed in SAP';
        matROH1.Material_Number__c = '59200099000';
        update matROH1;
        
        Attachment attach=new Attachment();        
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Material Number \n 59200098000 \n 59200099000 \n 59200097000');
        attach.body=bodyBlob;
        attach.parentId=matFERT1.id;
        insert attach;
       
        Test.startTest();
        /**************** Test for Title Proccess *********************/      
        
        /**** Setting Page Reference ****/         
        PageReference pageRef = Page.MassCloningSelection;
        pageRef.getParameters().put('releaseId', objRelease.Id);
        Test.setCurrentPage(pageRef);
        
        /**** Constructing Controller Instance ****/
        MassCloningSelectionController extController = new MassCloningSelectionController();
        extController.searchCriteria = 'abc';
        extController.btnSearch();
        
        extController.manualAddCriterial='59200098000';       
        extController.btnManualAdd();
        
        extController.searchCriteria = '59200098000';
        extController.btnSearch();

        System.debug('*****lstMaterialDetails> '+extController.lstMaterialDetails);
        //added as part of REL-40
        List<Material__c> lstMat = new list<Material__c>();
        Set<Material__c> setMat = new Set<Material__c>();
        lstMat.add(matFERT3);
        lstMat.add(matFERT4);
        setMat.addAll(lstMat);
        extController.checkDuplicateMaterialDescription(lstMat);
        extController.checkDuplicateMaterialUPC(setMat);
        
        extController.errorPagination.firstPage();
        extController.errorPagination.lastPage();
        extController.errorPagination.updatePaginationCounter();
        extController.errorPagination.getRecordsInPage(1);
        extController.errorPagination.getData();
        extController.errorPagination.nextPage();
        extController.errorPagination.previousPage();
        extController.errorPagination.getDisableNext();
        extController.errorPagination.getDisablePrevious();
        extController.errorPagination.getPageList();
        
        extController.first();
        extController.last();
        extController.previous();
        extController.next();
         
        extController.ParamId = matFERT2.Id ;    
                  
        extController.mtRowNumber = 0 ;  
        extController.setSelectedMaterial();
        extController.mtRowNumber = 0 ;
        extController.removeSelectedMaterial();
        
        extController.csvFileBody = bodyBlob ;            
        extController.btnUploadCSV();
        
        extController.searchCriteria = '123';
        extController.btnSearch();
        
        extController.finalizeSelection();
        extController.submit();
        
        //extController.;
        extController.removeAll();
        extController.redirectPreviousPage();
        Boolean val1 = extController.hasNext;
        val1 = extController.hasPrevious;
        Integer val2 = extController.pageNumber;
        val2 = extController.resultSize;
        val1 = extController.selectedHasNext;
        val1 = extController.selectedHasPrevious;
        val2 = extController.selectedPageNumber;
        val2 = extController.selectedResultSize;
        extController.selectedFirst();
        extController.selectedLast();
        extController.selectedPrevious();
        extController.selectedNext();
        extController.cancelSelected();
        extController.cancelSelection();
        List<Material__c> matList = MassCloningUtility.fetchMaterialsForCriteria('59200098000');
        System.assertEquals(matList.size(), 1);
        
        Test.stopTest(); 
    }
}