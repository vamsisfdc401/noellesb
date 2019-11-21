/*****************************************************************************************
Class Name: ReleaseTriggerHandlerTest
Purpose: Test class for apex class ReleaseTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/10/2016           Suman                    Initial Development
******************************************************************************************/
@isTest//(seeAllData=true)
private class ReleaseTriggerHandlerTest{
// Following method is used to prepare data setup. // Changed for Deal
    static void dataSetup() {
        Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
        // Inserting Sub-Label Codes.
        List<Sub_Label_Code__c> subLblList = new List<Sub_Label_Code__c>();
        Sub_Label_Code__c sLblCode = new Sub_Label_Code__c(Name='SNAG FILMS', Label_Code__c='87 - JOINT CORR/MULTI-STUDIO', Sub_Label_Code_ID__c='87');
        subLblList.add(sLblCode);
        Sub_Label_Code__c sLblCode2 = new Sub_Label_Code__c(Name='UP Features', Label_Code__c='61 - Universal Pictures', Sub_Label_Code_ID__c='61');
        subLblList.add(sLblCode2);
        Sub_Label_Code__c sLblCode3 = new Sub_Label_Code__c(Name='Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code_ID__c='62');
        subLblList.add(sLblCode3);
        insert subLblList;
        
        // Inserting Origin Codes.
        List<Origin_Code__c> insertableOriginCodes = new List<Origin_Code__c>();
        Origin_Code__c oCode1 = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insertableOriginCodes.add(oCode1);
        Origin_Code__c oCode2 = new Origin_Code__c(Origin_Code__c='025 - Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code__c=sLblCode3.Id);
        insertableOriginCodes.add(oCode2);
        insert insertableOriginCodes;
    }
    
    @isTest
    static void testMethod_1()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
              
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
        
        objRelease.First_Theatrical_Date__c = mat1.Theatrical_Release_Date__c;
        Update objRelease;
        
        mat1.Format__c= '08 - EST (ELECTRONIC SELL THRU)';
        update mat1;
        
        mat1.Format__c= '15 - DVDR';
        update mat1;
        
        mat1.Format__c = '02 - DVD';
        mat1.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        update mat1;
        
                
      Test.stopTest();    
        
    } 
@isTest
static void testMethod_2()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
        
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Submitted';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US';
       
        insert mat1;
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
             
        objRelease.First_Theatrical_Date__c = mat1.Theatrical_Release_Date__c;
        Update objRelease;    
        
      
        mat1.Format__c ='08 - EST (ELECTRONIC SELL THRU)';
        update mat1;
        
        mat1.Format__c = '15 - DVDR';
        update mat1;
      Test.stopTest();    
        
    }
@isTest
static void testMethod_3()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
        
        Material__c mat1 = new Material__c();
        mat1.Material_Status__c = 'Draft';
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addDays(-2);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US';
        insert mat1;
                    
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
                    
        mat1.Format__c='08 - EST (ELECTRONIC SELL THRU)';
        update mat1;
        
        
        mat1.Format__c='15 - DVDR';
        update mat1;
        
        Test.stopTest();    
        
    } 
    
@isTest
static void testMethod_4()
    {
       
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=Date.today().addDays(-2),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
        
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addDays(-2);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US';
        insert mat1;
        
        Test.startTest();
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
        
        objRelease.Internal_Announce_Date__c = System.today().addDays(-2);  
        update objRelease; 
        
      
        mat1.Format__c ='08 - EST (ELECTRONIC SELL THRU)';
        update mat1;
        
        mat1.Format__c = '15 - DVDR';
        update mat1;
      Test.stopTest();    
        
    }
    
 @isTest
static void testMethod_5()
    {
       
        dataSetup();
       
        Title__c objTitle = new Title__c(Name='DummyTitle',SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id, Origin_Code__c='010 - Universal Pictures',Label_Code__c='61 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=Date.today().addDays(-2),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
        
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addDays(-2);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US';
        insert mat1;
        
        Test.startTest();
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
        
        objRelease.Internal_Announce_Date__c = System.today().addDays(-2);  
        update objRelease;   
        
      
        mat1.Format__c ='08 - EST (ELECTRONIC SELL THRU)';
        update mat1;
        
        mat1.Format__c = '02 - DVD';
        mat1.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
      Test.stopTest();    
        
    }    
    
    static testmethod void testMethod_6()
    {
        dataSetup();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',SGENNO__c='12345');
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id, Origin_Code__c='010 - Universal Pictures',Label_Code__c='61 - Universal Pictures');
        insert deal;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=Date.today().addDays(-2),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
        
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addDays(-2);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Territory__c = 'US';
        insert mat1;
        
        Test.startTest();
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
        
        objRelease.Internal_Announce_Date__c = System.today().addDays(-2);  
        update objRelease;    
        
      
        mat1.Format__c ='08 - EST (ELECTRONIC SELL THRU)';
        update mat1;

        
        mat1.Format__c = '02 - DVD';
        mat1.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
      Test.stopTest();    
        
    }
    
    static testmethod void testMethod_7()
    {
       
        dataSetup();
        
        Title__c objTitle = new Title__c(Name='DummyTitle',SGENNO__c='12345');
        objTitle.Active_Flag__c = true;
        insert objTitle;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=true,Title__c=objTitle.id, Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures');
        deal.SGENNO__c = objtitle.SGENNO__c;
        insert deal;
        
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=Date.today().addDays(-2),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        objRelease.Title__c = objTitle.Id;
        insert objRelease;
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Internal_Announce_Date__c = System.today();
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;        
        mat1.Release__c = objRelease.Id;
        mat1.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        mat1.title__c = objTitle.id;
        mat1.deal__c = deal.id;
        mat1.Territory__c = 'US';
        mat1.Label_Code__c='61 - Universal Pictures';
        mat1.Format__c = '08 - EST (ELECTRONIC SELL THRU)';
      
        
        insert mat1;
        
        Classification__c classification = testClassUtility.getClassifications(mat1);// added on 27.12
        insert classification;
        
        Plant__c p = testClassUtility.getPlants(mat1); // added on 27.12
        insert p;
       
       
        
        
        Test.startTest();
        

        
        
        
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
       
        update mat1;        
        
        objRelease.EST_Date__c = System.today().addDays(2);
        objRelease.Brand_Group__c = 'Universal Pictures';
        objRelease.Street_Date__c =  System.today().addDays(-2);
        objRelease.Internal_Announce_Date__c = System.today().addDays(-2);  
        update objRelease;
        
        objRelease.Internal_Announce_Date__c = System.today().addDays(3);  
        update objRelease;
        
        objRelease.Internal_Announce_Date__c = System.today().addDays(-3);  
        update objRelease;

      Test.stopTest();    
        
    }
    
    
    
    public static testMethod void testReleaseDate(){
      Release__c releaseRrd = createData();
       releaseRrd.Windowed_Rental_Street_Date__c =  system.today();
       releaseRrd.Windowed_Rental_Pre_Order_Close_Date__c = system.today();
       releaseRrd.EST_Date__c =  system.today();
       releaseRrd.Internal_Announce_Date__c = system.today().addDays(-1);
       
       Test.startTest();
         update releaseRrd;
       Test.stopTest();
    
    }
    
    
    private static Release__c createData(){
        // Preparing Data setup
        List<Material__c> materialList = new List<Material__c>();
        
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        
       Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);

       
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Material_Integration_State__c  = 'P';
        material1.Material_Status__c = 'Sent to SAP';
        material1.recordTypeId = recTypeId;
        material1.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        material1.Territory__c = 'US';
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Territory__c = 'US';
        
        Material__c material3=testClassUtility.createMaterial('08 - EST (ELECTRONIC SELL THRU)','BD','dummy3','FERT',release.id,TRUE,'S (Single)','SS - SINGLE SELECTION');
        
        material3.Material_Integration_State__c = 'P';
        material3.Material_Status__c = 'Sent to SAP';
        material3.recordTypeId = recTypeId;
        material3.Territory__c = 'US';
        materialList.add(material1);
        materialList.add(material2);
        materialList.add(material3);
        
        insert materialList;
        
      return release;
    }
    
    
    // check release cancel
    private static  testMethod void testCancelReleaseNoMaterialAttached(){
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release','Materials Not Requested',title.id);

        insert release;
        TriggerUtility.checkFromCloning = false;
        
        Test.startTest();
            release.Cancel_Release__c=true;
            update release;
        Test.stopTest();
        
    } 
    
    static testmethod void testMethod_10()
    {
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
              
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
        
        objRelease.First_Theatrical_Date__c = mat1.Theatrical_Release_Date__c;
        objRelease.Brand_Group__c = 'Catalog';
        Update objRelease;
        
        ReleaseTriggerHandler.createChildViews();
                
      Test.stopTest();    
        
    }
    
    //usst-2477
    static testmethod void testMethod_11()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        
        Deal__c deal=new Deal__c(Name='Deal1',Finance_Default_Deal__c=false,Title__c=title.id,Label_Code__c='61 - Universal Pictures');
        insert deal;
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='61 - Universal Pictures';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Item_Type__c = 'S (Single)';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';        
        mat1.Territory__c = 'US';
        mat1.Release__c = release.Id;
        insert mat1;           
        
        TriggerUtility.checkFromCloning = false;
        Test.startTest();
            release.Deal__c = deal.Id;
            update release;
        Test.stopTest();
    }
    //usst-2477
    
    //REL-43
    public static  testMethod void testChatterPostOnFieldChange(){
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Catalog Record Type').getRecordTypeId();
        Date dt = System.today();
        List<Release__c> lstRel = new List<Release__c>();
        List<Release__c> lstnewRel = new List<Release__c>();
        Release__c rel3 = new Release__c();
        rel3.name = 'relTest';
        rel3.Brand_Group__c= 'Family';
        rel3.Label_Code__c= '61 - Universal Pictures';
        rel3.street_date__c= dt;
        rel3.Online_Consumer_Solicitation_Date__c= dt.addDays(-10);
        rel3.recordTypeId = CompRecordTypeId;
        
        Set<String> lstPublicGroup = new Set<String>();
        Set<Id> setUsersPublicGroup = new Set<Id>();
        lstPublicGroup.add('UPHE Biz Comm');
        lstPublicGroup.add('UPHE Tech Ops');
        setUsersPublicGroup = ReleaseTriggerHandler.userOfPublicGroup(lstPublicGroup);
        
        Release__c rel4 = new Release__c();
        rel4.name = 'relTest1';
        rel4.Brand_Group__c= 'Family';
        rel4.Label_Code__c= '61 - Universal Pictures';
        rel4.street_date__c= dt;
        rel4.Online_Consumer_Solicitation_Date__c= dt.addDays(-10);
        rel3.recordTypeId = CompRecordTypeId;
                
        lstRel.add(rel3);
        lstRel.add(rel4);
        insert lstRel;
        
        triggerUtility.sobjectExecutedEvents.remove('Release__c');
        
        rel3.street_date__c =dt.addDays(10);
        rel3.Online_Consumer_Solicitation_Date__c = dt.addDays(-63);
        rel4.Online_Consumer_Solicitation_Date__c = dt.addDays(-63);
        lstnewRel.add(rel3);
        lstnewRel.add(rel4);
        update lstRel;
    }
    
    public static  testMethod void testMethod_12(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        List<Release__c> lstRel = new List<Release__c>();
        Release__c rel1 = new Release__c();
        rel1.name = 'relTesting1';
        rel1.Brand_Group__c= 'Content Group';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '61 - Universal Pictures';
        rel1.street_date__c= Date.Today();
        rel1.First_Theatrical_Date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        lstRel.add(rel1);
        
        Release__c rel2 = new Release__c();
        rel2.name = 'relTesting2';
        rel2.Brand_Group__c= 'Content Group';
        rel2.Project_Type__c= 'New Release';
        rel2.Label_Code__c= '61 - Universal Pictures';
        rel2.street_date__c= Date.Today();
        rel2.First_Theatrical_Date__c= Date.Today();
        rel2.Territory__c='CDN';
        rel2.recordTypeId = TheatricalRecordTypeId;
        lstRel.add(rel2);
        
        Release__c rel3 = new Release__c();
        rel3.name = 'relTesting3';
        rel3.Brand_Group__c= 'Content Group';
        rel3.Project_Type__c= 'New Release';
        rel3.Label_Code__c= '61 - Universal Pictures';
        rel3.street_date__c= Date.Today();
        rel3.recordTypeId = TheatricalRecordTypeId;
        lstRel.add(rel3);
        
        insert lstRel;

    }
    
    public static testMethod void testMethod_13(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        
        Email_Notify_Label_Codes__c d8 = new Email_Notify_Label_Codes__c();
        d8.Name='61 - Universal Pictures';
        Insert d8;
        
        User u = new User(Alias = 'pU', Email='platformuser@testalphabetagamma.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = Label.BrandUserProfileId,
                              TimeZoneSidKey='America/Los_Angeles', UserName='platformuser@testalphabetagamma.com',Label_Code__c='61 - Universal Pictures');
        insert u;
                              
        Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_13';
        rel1.Brand_Group__c= 'Universal Pictures';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '61 - Universal Pictures';
        rel1.street_date__c= Date.Today();
        rel1.Creative_Contact__c = u.id;
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
        
        List<Release__c> lstRel = [Select Id, Street_Date__c from Release__c where Name = 'reltestMethod_13'];
        EntitySubscription es = new EntitySubscription();
        es.ParentId = lstRel[0].Id;
        es.SubscriberId = u.Id;
        insert es;

        rel1.Street_Date__c= Date.Today().addDays(20);

        TriggerUtility.checkMassChatterPost = false;
        update rel1;
    }
    
    public static testMethod void testMethod_14(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        
        Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_14';
        rel1.Brand_Group__c= 'PHE Acquisitions';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '59 - Paramount';
        rel1.street_date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
        
        rel1.Street_Date__c= Date.Today().addDays(20);

        TriggerUtility.checkMassChatterPost = false;
        update rel1;
    }
    
    public static testMethod void testMethod_15(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_15';
        rel1.Brand_Group__c= 'Universal Pictures';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '61 - Universal Pictures';
        rel1.street_date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
        
        List<Material__c> lstMat= new List<Material__c>();
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'mat1Test';
        mat1.Label_Code__c ='61 - Universal Pictures';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';      
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US';
        lstMat.add(mat1);
        
        Material__c mat2 = new Material__c();
        mat2.Name = 'mat2Test';
        mat2.Label_Code__c ='61 - Universal Pictures';
        mat2.Material_Status__c = 'Processed in SAP';
        mat2.Material_Type__c = 'FERT';
        mat2.Format_Description__c = 'CD';
        mat2.Format__c= '11 - ULTRA HD 4K';      
        mat2.Release__c = rel1.Id;
        mat2.Territory__c = 'US';  
        lstMat.add(mat2);
        
        insert lstMat;
        
        List<Release__c> lstRel = [select id, Cancel_Release__c from Release__c where Name = 'reltestMethod_15'];
        lstRel[0].Cancel_Release__c = true;
        TriggerUtility.checkFromCloning = false;
        update lstRel;
        ReleaseTriggerHandler.cancelRelease(lstRel);
    }
    
    public static testMethod void testMethod_16(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        User u = new User(Alias = 'pU', Email='platformuser@testalphabetagamma.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = Label.BrandUserProfileId,
                              TimeZoneSidKey='America/Los_Angeles', UserName='platformuser@testalphabetagamma.com',Label_Code__c='61 - Universal Pictures');
        insert u;
        
        Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_16';
        rel1.Brand_Group__c= 'Universal Pictures';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '61 - Universal Pictures';
        rel1.street_date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'mat1Test';
        mat1.Label_Code__c ='61 - Universal Pictures';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';      
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US';
        
        insert mat1;
        
        List<Release__c> lstRel = [select id, Manufacturing_Contact__c  from Release__c where Name = 'reltestMethod_16'];
        lstRel[0].Manufacturing_Contact__c = u.id;
        update lstRel;
        ReleaseTriggerHandler.udpateContactsToMaterial(new Set<ID>{lstRel[0].id});
    }
    
    public static testMethod void testMethod_17(){
        Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
        
        Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_17';
        rel1.Brand_Group__c= 'Universal Pictures';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '61 - Universal Pictures';
        rel1.Release_Status__c = 'Materials Requested';
        rel1.street_date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
        
        List<Material__c> lstMat = new List<Material__c>();
        
        Material__c mat1 = new Material__c();
        mat1.Name = 'mat1Test';
        mat1.Label_Code__c ='61 - Universal Pictures';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '02 - DVD';      
        mat1.Release__c = rel1.Id;
        mat1.Territory__c = 'US';
        lstMat.add(mat1);
        
        Material__c mat2 = new Material__c();
        mat2.Name = 'mat2Test';
        mat2.Label_Code__c ='61 - Universal Pictures';
        mat2.Material_Status__c = 'Processed in SAP';
        mat2.Material_Number__c = '61572462000';
        mat2.Material_Type__c = 'FERT';
        mat2.Format_Description__c = 'EST (ELECTRONIC SELL THRU)';
        mat2.Format__c= '08 - EST (ELECTRONIC SELL THRU)';      
        mat2.Release__c = rel1.Id;
        mat2.Territory__c = 'US';
        lstMat.add(mat2);
        
        Material__c mat3 = new Material__c();
        mat3.Name = 'mat3Test';
        mat3.Label_Code__c ='61 - Universal Pictures';
        mat3.Material_Status__c = 'Processed in SAP';
        mat3.Material_Number__c = '61577592000';
        mat3.Material_Type__c = 'FERT';
        mat3.Format_Description__c = 'CD';
        mat3.Format__c= '20 - CD (COMPACT DISC)';   
        mat3.Retailer_Rental__c = '28R (28-DAY WINDOW RENTAL)';
        mat3.Release__c = rel1.Id;
        mat3.Territory__c = 'US';
        lstMat.add(mat3);
        
        insert lstMat;
        
        TriggerUtility.checkFromCloning = false;
        
        Release__c newRel = new Release__c(Id= rel1.id);
        newRel.street_date__c= Date.Today().addDays(10);
        //newRel.est_date__c= Date.Today().addDays(10);
        //newRel.windowed_rental_street_date__c= Date.Today().addDays(10);
        //newRel.first_theatrical_date__c = Date.Today().addDays(10);
        Test.StartTest();
        update newRel;
        Test.StopTest();
    }
    static testmethod void testMethod_18()
    {
        User u = RFTest_TestDataFactory.createUser( RFTest_TestDataFactory.MasterDataProfile , 1);
        System.runAs(u) {//run as platform api user
            u.brand_group__c='Catalog';
            update u;
            User u1 = TriggerUtility.currentUser;
            
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Catalog',Project_Type__c = '',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
              
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
        
        objRelease.First_Theatrical_Date__c = mat1.Theatrical_Release_Date__c;
        objRelease.Brand_Group__c = 'Catalog';
        Update objRelease;
        
        ReleaseTriggerHandler.createChildViews();
          system.assertEquals(u1.brand_group__c, 'Catalog');
            //system.assertEquals(u1, null);
      Test.stopTest();    
        } 
    }
    static testmethod void testMethod_19()
    {
        User u = RFTest_TestDataFactory.createUser( RFTest_TestDataFactory.MasterDataProfile , 1);
        System.runAs(u) {//run as platform api user
            u.brand_group__c='Catalog';
            update u;
            User u1 = TriggerUtility.currentUser;
            
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Catalog',Project_Type__c = '',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
        mat1.Street_Date__c=date.today();
            update mat1;
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
        
        objRelease.First_Theatrical_Date__c = mat1.Theatrical_Release_Date__c;
        objRelease.Brand_Group__c = 'Catalog'; 
        Update objRelease;
         
        ReleaseTriggerHandler.createChildViews();
          system.assertEquals(u1.brand_group__c, 'Catalog'); 
            //system.assertEquals(u1, null);
      Test.stopTest();    
        } 
    }
    static testmethod void testMethod_20()
    {
        User u = RFTest_TestDataFactory.createUser( RFTest_TestDataFactory.MasterDataProfile , 1);
        System.runAs(u) {//run as platform api user
            u.brand_group__c='Catalog';
            update u;
            User u1 = TriggerUtility.currentUser;
            
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Content Group',Project_Type__c = '',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
        mat1.Street_Date__c=date.today();
            update mat1;
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
         
        ReleaseTriggerHandler.createChildViews();
      Test.stopTest();    
        } 
    }
    static testmethod void testMethod_21()
    {
        User u = RFTest_TestDataFactory.createUser( RFTest_TestDataFactory.MasterDataProfile , 1);
        System.runAs(u) {//run as platform api user
            u.brand_group__c='Catalog';
            update u;
            User u1 = TriggerUtility.currentUser;
            
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
        
        Release__c objRelease = new Release__c(In_Plant_Date__c = Date.today(),Windowed_Rental_Street_Date__c = Date.today(),Windowed_Rental_Pre_Order_Close_Date__c = Date.today(),Trade_Solicitation_Date__c = Date.today(),Pre_Order_Close_Date__c = Date.today(),EST_Date__c=Date.Today(),Internal_Announce_Date__c=System.today().addMonths(1),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='',Project_Type__c = '',Release_Status__c='Materials Not Requested',First_Theatrical_Date__c = Date.today());
        insert objRelease;
              
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Format__c= '11 - ULTRA HD 4K';
        mat1.Internal_Announce_Date__c = System.today().addMonths(1);
        mat1.Theatrical_Release_Date__c = objRelease.First_Theatrical_Date__c;
        mat1.Territory__c = 'US';
        mat1.Release__c = objRelease.id;
        
        mat1.Release__c = objRelease.Id;
       
        insert mat1;           
        mat1.Street_Date__c=date.today();
            update mat1;
        set<Id> relId = new Set<Id>();
        relId.add(objRelease.Id);
      
        Sales__c sales = new Sales__c();
        sales.Material__c = mat1.id;
        insert sales;    
         
        ReleaseTriggerHandler.createChildViews();
      Test.stopTest();    
        } 
    }
        static testmethod void testMethod_22()
    {
     User u = RFTest_TestDataFactory.createUser( RFTest_TestDataFactory.MasterDataProfile , 1);
        System.runAs(u) {
            u.brand_group__c='Catalog';
            update u;
            User u1 = TriggerUtility.currentUser;
            
       Test.startTest();
        Title__c objTitle = new Title__c(Name='DummyTitle');
        insert objTitle;
         Id TheatricalRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
       Release__c rel1 = new Release__c();
        rel1.name = 'reltestMethod_14';
        rel1.Brand_Group__c= 'PHE Acquisitions';
        rel1.Project_Type__c= 'New Release';
        rel1.Label_Code__c= '59 - Paramount';
        rel1.street_date__c= Date.Today();
        rel1.recordTypeId = TheatricalRecordTypeId;
        
        insert rel1;
                       
        Material__c mat1 = new Material__c();
        mat1.Label_Code__c ='24 - PURE FLIX';
        mat1.Material_Status__c = 'Draft';
        mat1.Material_Type__c = 'FERT';
        mat1.Format_Description__c = 'DVD';
        mat1.Territory__c = 'US';
        mat1.Release__c = rel1.id;
        
        insert mat1;           
        rel1.Street_Date__c= Date.Today().addDays(20);

        TriggerUtility.checkMassChatterPost = false;
        update rel1;
      
         Test.stopTest();    
    }
    }
 }