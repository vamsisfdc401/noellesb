/*****************************************************************************************
Class Name: TemplateWizardControllerTest
Purpose: Test class for apex class Template Wizard functionality. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/09/2017           Suman                    Initial Development
******************************************************************************************/
@isTest(seeAllData = FALSE)
public class TemplateWizardControllerTest
{
    // Test data setup.
    @TestSetup
    static void setupData()
    {
        List<BrandGroupAbbreviationMapping__c> brandAbbrMappingList = new List<BrandGroupAbbreviationMapping__c>();
        
        // Creating Brand Group Abbreviation mapping configuration.
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='1440', Abbreviation__c='UNI-1440'));
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='Catalog', Abbreviation__c='UNI-CTG'));
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='Family', Abbreviation__c='UNI-FMY'));
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='Partners', Abbreviation__c='UNI-PTR'));
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='TV', Abbreviation__c='UNI-TV'));
        brandAbbrMappingList.add(new BrandGroupAbbreviationMapping__c(Name='Universal Pictures', Abbreviation__c='UNI-UP'));
        
        // Creating configuration data.
        insert brandAbbrMappingList;
        
        // Creating Universal Brand Groups sequence.
        List<Universal_Brand_Group__c> uniBrands = new List<Universal_Brand_Group__c>();
        uniBrands.add(new Universal_Brand_Group__c(Name='Universal Pictures', Sequence__c=1));
        uniBrands.add(new Universal_Brand_Group__c(Name='Partners', Sequence__c=2));
        uniBrands.add(new Universal_Brand_Group__c(Name='Family', Sequence__c=3));
        uniBrands.add(new Universal_Brand_Group__c(Name='TV', Sequence__c=4));
        uniBrands.add(new Universal_Brand_Group__c(Name='Catalog', Sequence__c=5));
        uniBrands.add(new Universal_Brand_Group__c(Name='1440', Sequence__c=6));
        insert uniBrands;
        
        // Creating Paramount Brand Groups sequence.
        List<Paramount_Brand_Group__c> paraBrands = new List<Paramount_Brand_Group__c>();
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Theatrical - New Release', Sequence__c=1));
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Theatrical - Catalog', Sequence__c=2));
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Acquisitions', Sequence__c=3));
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Comedy Central', Sequence__c=4));
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Showtime', Sequence__c=5));
        paraBrands.add(new Paramount_Brand_Group__c(Name='PHE Nickelodeon', Sequence__c=6));
        insert paraBrands;
    }
    
    // Template Wizard Creation Flow 
    @isTest
    static void testScenario1()
    {
        Material__c objMaterial;
        UserRole paraRole = [SELECT Id FROM UserRole WHERE DeveloperName='Paramount'];
        // Creating user.
        Profile profilePara = [select id from profile where name='Third Party User' ];        
        List<User> insUsers = new List<User>();
        User paramountUser = new User(alias = 'testPara', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara@test.com.para',
                             Brand_Group__c='Catalog',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        insUsers.add(paramountUser);
        User paramountUser2 = new User(alias = 'testPar2', 
                             email='testP2@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='TestingP2', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara2@test.com.para',
                             Brand_Group__c='Universal Pictures',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        insUsers.add(paramountUser2);
        Database.insert(insUsers);
        System.runAs(paramountUser)
        {
            // Preparing material records
            objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
            objMaterial.Territory__c = 'US';
            objMaterial.Material_Number__c = '29017863';
            objMaterial.Name = 'TestMat-002';
            insert objMaterial;
            
            // Creating a template.
            Material_Template__c mt1 = new Material_Template__c(Template_Name__c='UNI-UP: Temp1', Brand_Group__c='Universal Pictures', Is_Active__c=true);
            insert mt1;
        }
        
        Test.startTest();
        
        System.runAs(paramountUser)
        {   
            PageReference pageRef = Page.TemplateDescriptor;
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc = new ApexPages.StandardController(new Material_Template__c());
            TemplateWizardController con = new TemplateWizardController(sc);
            
            // Without providing anything.
            con.template.Template_Name__c = '';
            con.template.Brand_Group__c = null;
            con.redirectFirstToSecondPage();
            Boolean hasEditPermission = con.hasEditAccess;
            List<SelectOption> availList = con.availableBrandGroups;
            
            // Asserting page message.
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please provide the template name.')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Providing only name.
            con.template.Template_Name__c = 'Temp1';
            con.handleBrandGroupChange();
            con.redirectFirstToSecondPage();
            
            // Asserting page message.
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please choose the brand group.')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Providing invalid brand group.
            con.template.Brand_Group__c = 'UP';
            con.redirectFirstToSecondPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Brand Group abbreviation is not found.')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Providing proper data.
            con.template.Brand_Group__c = 'Universal Pictures';
            con.handleBrandGroupChange();
            con.redirectFirstToSecondPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Template Name: UNI-UP: Temp1 is duplicate in the system.')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Providing unique value.
            con.template.Template_Name__c = 'UNI-UP: Temp2';
            con.redirectFirstToSecondPage();
            
            Boolean val = con.isPHEUser;
            
            // Without providing any data in material.
            con.saveNavigateReviewPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please choose the material item code.')) 
                    foundError = true;
            }
            System.assert(foundError);
            
            // Format undefined issue.
            con.curMatDetail.Item_Code__c = 'BF - BABY FERT';
            con.saveNavigateReviewPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please choose the material format.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            // Baby FERT Format configuration issue.
            con.curMatDetail.Format__c = 'GWP';
            con.saveNavigateReviewPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Material format should be set to DVD when creating a Baby FERT.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            // Quantityy issue.
            con.curMatDetail.Format__c = 'DVD';
            con.curMatQty = 101;
            con.saveNavigateReviewPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please choose quantity between 1 to 100.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            con.curMatQty = 1;
            // Adding components.
            con.addComponent();
            con.addExistingComponent();
            
            // Iterating over components to populate data.
            Integer i = 0;
            for(TemplateWizardController.ComponentDetail comp : con.associatedComponents)
            {
                if(comp.isExisting)
                {
                    comp.instance.Existing_Component__c = objMaterial.Id;
                    con.compIndex = i;
                    con.fetchCompDetails();
                }
                else
                {
                    comp.instance.Component_Type__c = 'DISC DVD';
                }
                i ++;
            }
            
            // Adding an empty component.
            con.addComponent();
            con.saveNavigateReviewPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: Please choose component type or existing component, else remove the component line.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            con.redirectSecondToThirdPage();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Please save the changes, otherwise they will be lost. To still proceed, please click it again.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            con.compIndex = 2;
            con.removeComponent();
            con.saveNRepeatPage();
            con.redirectSecondToThirdPage();
            
            // Providing false material detail Id.
            con.selectedMatId = '000000000000000000';
            con.editMaterial();
            msgs = ApexPages.getMessages();
            foundError = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('ERROR: The material detail record is not found.'))
                    foundError = true;
            }
            System.assert(foundError);
            
            Id createdMatDetailId;
            // Get the material detail id.
            for(String matId : con.materials.keySet())
            {
                createdMatDetailId = matId;
            }
            
            Integer cnt = con.materials.get(createdMatDetailId).totalChildCount;
            // Editing created material.
            con.selectedMatId = createdMatDetailId;
            con.editMaterial();
            
            // Removing an existing component.
            con.compIndex = 1;
            con.removeComponent();
            con.saveNavigateReviewPage();
            
            Integer matCnt = con.totalMaterials;
            
            // Providing false material detail Id to delete.
            con.selectedMatId = '000000000000000000';
            con.deleteMaterial();
            
            // Removing created material.
            con.selectedMatId = createdMatDetailId;
            con.deleteMaterial();
            
            con.addMaterial();
            con.redirectSecondToFirstPage();
            con.redirectFirstToThirdPage();
            con.redirectThirdToFirstPage();
            con.completeTask();
            con.cancel();
            
            con.template.Brand_Group__c = 'Catalog';
            update con.template;
        }
        
        Test.stopTest();
    }
    
    // Template Wizard Clone Flow 
    @isTest
    static void testScenario2()
    {
        Material__c objMaterial;
        Material_Template__c mt1;
        UserRole paraRole = [SELECT Id FROM UserRole WHERE DeveloperName='Paramount'];
        // Creating user.
        Profile profilePara = [select id from profile where name='Third Party User' ];        
        User paramountUser = new User(alias = 'testPara', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara@test.com.para',
                             Brand_Group__c='Catalog',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        Database.insert(paramountUser);
        System.runAs(paramountUser)
        {
            // Preparing material records
            objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
            objMaterial.Territory__c = 'US';
            objMaterial.Material_Number__c = '29017863';
            objMaterial.Name = 'TestMat-002';
            insert objMaterial;
            
            // Creating a template.
            mt1 = new Material_Template__c(Template_Name__c='UNI-UP: Temp1', Brand_Group__c='Universal Pictures', Is_Active__c=true);
            insert mt1;
            
            // Creating child material details.
            Material_Detail__c matDet = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                            Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' ); //Added subformat and sales planning group for USST-2783
            insert matDet;
            
            // Creating associated component details.
            List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
            compDetList.add(new Component_Detail__c(Material_Detail__c=matDet.Id, Component_Type__c='DISC DVD'));
            compDetList.add(new Component_Detail__c(Material_Detail__c=matDet.Id, Existing_Component__c=objMaterial.Id));
            insert compDetList;
        }
        
        Test.startTest();
        
        System.runAs(paramountUser)
        {
            PageReference pageRef = Page.TemplateDescriptor;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('cloneSourceId', String.valueOf(mt1.Id));
            pageRef.getParameters().put('retURL', '/home/home.jsp');
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc = new ApexPages.StandardController(new Material_Template__c());
            TemplateWizardController con = new TemplateWizardController(sc);
            
            List<SelectOption> availList = con.availableBrandGroups;
            con.template.Template_Name__c = 'UNI-UP: Temp2';
            con.redirectFirstToSecondPage();
            con.redirectSecondToThirdPage();
            con.completeTask();
            con.cancel();
            con.retURL = '/TemplateDescriptor';
            con.completeTask();
            con.cancel();
            
            // Fetching child materials to assert.
            Integer srcTemplateChildCount = [SELECT count() FROM Material_Detail__c WHERE Material_Template__c=:mt1.Id];
            Integer clnTemplateChildCount = [SELECT count() FROM Material_Detail__c WHERE Material_Template__c=:con.template.Id];
            System.assert(srcTemplateChildCount == clnTemplateChildCount);
        }
        
        Test.stopTest();
    }
    
    // Template Wizard Edit Flow 
    @isTest
    static void testScenario3()
    {
        Material__c objMaterial;
        Material_Template__c mt1;
        Material_Detail__c matDet4;
        UserRole paraRole = [SELECT Id FROM UserRole WHERE DeveloperName='Paramount'];
        // Creating user.
        Profile profilePara = [select id from profile where name='Third Party User' ];        
        User paramountUser = new User(alias = 'testPara', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara@test.com.para',
                             Brand_Group__c='Catalog',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        Database.insert(paramountUser);
        System.runAs(paramountUser)
        {
            // Preparing material records
            objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
            objMaterial.Territory__c = 'US';
            objMaterial.Material_Number__c = '29017863';
            objMaterial.Name = 'TestMat-002';
            insert objMaterial;
            
            // Creating a template.
            mt1 = new Material_Template__c(Template_Name__c='UNI-UP: Temp1', Brand_Group__c='Universal Pictures', Is_Active__c=true);
            insert mt1;
            Material_Template__c mt2 = new Material_Template__c(Template_Name__c='UNI-UP: Temp2', Brand_Group__c='Universal Pictures', Is_Active__c=true);
            insert mt2;
            
            // Creating child material details.
            matDet4 = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', Material_Template__c=mt1.Id, 
                                             Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=4, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' ); //Added subformat and sales planning group for USST-2783
            List<Material_Detail__c> matDetList = new List<Material_Detail__c>();
            
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=1, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=2, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=3, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( matDet4 );
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=5, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=6, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=7, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=8, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=9, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=10, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            matDetList.add( new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                                    Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Sequence__c=11, Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' )); //Added subformat and sales planning group for USST-2783
            
            insert matDetList;
            
            List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
            compDetList.add(new Component_Detail__c(Component_Type__c='DISC DVD', Material_Detail__c=matDet4.Id, Sequence__c=1));
            compDetList.add(new Component_Detail__c(Component_Type__c='INSERT', Material_Detail__c=matDet4.Id, Sequence__c=2));
            insert compDetList;
        }
        
        Test.startTest();
        
        System.runAs(paramountUser)
        {
            PageReference pageRef = Page.TemplateDescriptor;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(mt1.Id));
            pageRef.getParameters().put('retURL', '/home/home.jsp');
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc = new ApexPages.StandardController(mt1);
            TemplateWizardController con = new TemplateWizardController(sc);
            
            Boolean hasEditPermission = con.hasEditAccess;
            con.template.Template_Name__c = 'UNI-UP: Temp2';
            con.redirectFirstToSecondPage();
            con.redirectFirstToThirdPage();
            con.template.Template_Name__c = 'UNI-UP: Temp3';
            con.redirectFirstToSecondPage();
            
            con.saveNavigateReviewPage();
            con.redirectSecondToFirstPage();
            con.redirectSecondToThirdPage();
            
            // Pagination Testing.
            Integer matCount = con.templatePagination.numberOfRecords;
            System.assertEquals(matCount, 11);
            
            con.templatePagination.updatePaginationCounter();
            con.templatePagination.nextPage();
            con.templatePagination.firstPage();
            con.templatePagination.lastPage();
            con.templatePagination.getDisableNext();
            con.templatePagination.getDisablePrevious();
            con.templatePagination.getPageList();
            
            List<TemplateWizardController.MaterialDetail> sortedList = con.sortedMaterials;
            List<SelectOption> availList = con.availableBrandGroups;
            
            TemplateWizardController.MaterialDetail matDet = con.materials.get(matDet4.Id);
            List<TemplateWizardController.ComponentDetail> compDetList = matDet.sortedComponentList;
            
            // Providing material detail Id to delete.
            con.selectedMatId = matDet4.Id;
            con.deleteMaterial();
            
            con.completeTask();
            con.cancel();
            con.retURL = '/TemplateDescriptor';
            con.completeTask();
            con.retURL = null;
            con.completeTask();
        }
        
        Test.stopTest();
    }
    
    // Template Wizard Create Flow - Brand User 
    @isTest
    static void testScenario4()
    {
        Material__c objMaterial;
        Material_Template__c mt1;
        Material_Detail__c matDet4;
        UserRole univRole = [SELECT Id FROM UserRole WHERE DeveloperName='UPHE_Brand'];
        // Creating user.
        Profile profileBrand = [select id from profile where name='Brand User'];        
        User brandUser = new User(alias = 'testBrnd', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profileBrand.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testBrand1@test.com.brand',
                             Brand_Group__c='Universal Pictures',
                             Label_Code__c='61 - Universal Pictures',
                             UserRoleId=univRole.Id,
                             isActive = true);
        Database.insert(brandUser);
        Test.startTest();
        
        System.runAs(brandUser)
        {   
            PageReference pageRef = Page.TemplateDescriptor;
            Test.setCurrentPage(pageRef);
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc = new ApexPages.StandardController(new Material_Template__c());
            TemplateWizardController con = new TemplateWizardController(sc);
            
            Boolean hasEditPermission = con.hasEditAccess;
            List<SelectOption> availList = con.availableBrandGroups;
            
            // Providing template name and clicking save button.
            con.template.Template_Name__c = 'Template1';
            con.saveAction();
            
            // Asserting page message.
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean savedProperly = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('Template is saved successfully.')) 
                    savedProperly = true;
            }
            System.assert(savedProperly);
        }
    }
    
    // Template Wizard Clone Flow from Save Action
    @isTest
    static void testScenario5()
    {
        Material__c objMaterial;
        Material_Template__c mt1;
        UserRole paraRole = [SELECT Id FROM UserRole WHERE DeveloperName='Paramount'];
        // Creating user.
        Profile profilePara = [select id from profile where name='Third Party User' ];        
        User paramountUser = new User(alias = 'testPara', 
                             email='test1@test.com',
                             emailencodingkey='UTF-8', 
                             lastname='Testing', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid=profilePara.ID,
                             country='United States',
                             timezonesidkey='America/Los_Angeles', 
                             username='testPara@test.com.para',
                             Brand_Group__c='Catalog',
                             Label_Code__c='59 - Paramount',
                             UserRoleId=paraRole.Id,
                             isActive = true);
        Database.insert(paramountUser);
        System.runAs(paramountUser)
        {
            // Preparing material records
            objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
            objMaterial.Territory__c = 'US';
            objMaterial.Material_Number__c = '29017863';
            objMaterial.Name = 'TestMat-002';
            insert objMaterial;
            
            // Creating a template.
            mt1 = new Material_Template__c(Template_Name__c='UNI-UP: Temp1', Brand_Group__c='Universal Pictures', Is_Active__c=true);
            insert mt1;
            
            // Creating child material details.
            Material_Detail__c matDet = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                            Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)', Subformat__c='001 - BD3BDD', Sales_Planning_Group__c='001 - 3-D BLU-RAY' ); //Added subformat and sales planning group for USST-2783
            insert matDet;
            
            // Creating associated component details.
            List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
            compDetList.add(new Component_Detail__c(Material_Detail__c=matDet.Id, Component_Type__c='DISC DVD'));
            compDetList.add(new Component_Detail__c(Material_Detail__c=matDet.Id, Existing_Component__c=objMaterial.Id));
            insert compDetList;
        }
        
        Test.startTest();
        
        System.runAs(paramountUser)
        {
            PageReference pageRef = Page.TemplateDescriptor;
            Test.setCurrentPage(pageRef);
            
            // Negative scenario with wrong Id.
            pageRef.getParameters().put('cloneSourceId', '000000');
            pageRef.getParameters().put('retURL', '/home/home.jsp');
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc1 = new ApexPages.StandardController(new Material_Template__c());
            TemplateWizardController con1 = new TemplateWizardController(sc1);
            
            // Positive scenario with proper Id.
            pageRef.getParameters().put('cloneSourceId', String.valueOf(mt1.Id));
            pageRef.getParameters().put('retURL', '/home/home.jsp');
            
            /**** Constructing Controller Instance ****/
            ApexPages.StandardController sc = new ApexPages.StandardController(new Material_Template__c());
            TemplateWizardController con = new TemplateWizardController(sc);
            
            List<SelectOption> availList = con.availableBrandGroups;
            con.template.Template_Name__c = 'UNI-UP: Temp2';
            con.template.Brand_Group__c = 'Family';
            con.handleBrandGroupChange();
            System.assertEquals(con.template.Template_Name__c, 'UNI-FMY: Temp2');
            con.saveAction();
            
            // Fetching child materials to assert.
            Integer srcTemplateChildCount = [SELECT count() FROM Material_Detail__c WHERE Material_Template__c=:mt1.Id];
            Integer clnTemplateChildCount = [SELECT count() FROM Material_Detail__c WHERE Material_Template__c=:con.template.Id];
            System.assert(srcTemplateChildCount == clnTemplateChildCount);
        }
        
        Test.stopTest();
    }
}