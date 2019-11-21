@isTest
public class DGF_ReleaseTriggerTest {
    @TestSetup
    static void setupData()
    {
        //Added For Deal  Change logic - Start
        Execute_Material_Validation_Rule__c ins = new Execute_Material_Validation_Rule__c();
        ins.Execute_Rule__c = TRUE;
        insert ins;
        
        List<Sub_Label_Code__c> subLblList = new List<Sub_Label_Code__c>();
        Sub_Label_Code__c sLblCode = new Sub_Label_Code__c(Name='SNAG FILMS', Label_Code__c='87 - JOINT CORR/MULTI-STUDIO', Sub_Label_Code_ID__c='87');
        subLblList.add(sLblCode);
        Sub_Label_Code__c sLblCode2 = new Sub_Label_Code__c(Name='UP Features', Label_Code__c='61 - Universal Pictures', Sub_Label_Code_ID__c='61');
        subLblList.add(sLblCode2);
        Sub_Label_Code__c sLblCode3 = new Sub_Label_Code__c(Name='Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code_ID__c='62');
        subLblList.add(sLblCode3);
        insert subLblList;
        
        List<Origin_Code__c> insertableOriginCodes = new List<Origin_Code__c>();
        Origin_Code__c oCode1 = new Origin_Code__c(Origin_Code__c='010 - Universal Pictures', Label_Code__c='61 - Universal Pictures', Sub_Label_Code__c=sLblCode2.Id);
        insertableOriginCodes.add(oCode1);
        Origin_Code__c oCode2 = new Origin_Code__c(Origin_Code__c='025 - Focus Features', Label_Code__c='62 - Focus', Sub_Label_Code__c=sLblCode3.Id);
        insertableOriginCodes.add(oCode2);
        insert insertableOriginCodes;
        
        // Preparing material records
        Material__c objMaterial = testClassUtility.createMaterial('02 - DVD', 'DVDR', 'DummyComp', 'ROH', null, TRUE, 'C - Components', 'DS - DISC');
        objMaterial.Territory__c = 'US';
        objMaterial.Material_Number__c = '29017863';
        objMaterial.Name = 'TestMat-002';
        insert objMaterial;
        
        // Creating a template.
        List<Material_Template__c> matTempList = new List<Material_Template__c>();
        Material_Template__c mt1 = new Material_Template__c(Template_Name__c='UNI-TV: Temp1', Brand_Group__c='TV', Is_Active__c=true);
        matTempList.add(mt1);
        Material_Template__c mt2 = new Material_Template__c(Template_Name__c='UNI-TV: Temp2', Brand_Group__c='TV', Is_Active__c=true);
        matTempList.add(mt2);
        insert matTempList;
        
        // Creating child material details.
        List<Material_Detail__c> matDetList = new List<Material_Detail__c>();
        Material_Detail__c matDet1 = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Format__c='DVD', 
                                        Material_Template__c=mt1.Id, Quantity__c=1, Retailer_Rental__c='TGT (TARGET)');
        matDetList.add(matDet1);
        Material_Detail__c matDet2 = new Material_Detail__c(Item_Type__c='S (Single)', Item_Code__c='BF - BABY FERT', Format__c='DVD', 
                                        Material_Template__c=mt1.Id, Quantity__c=2, Retailer_Rental__c='TGT (TARGET)');
        matDetList.add(matDet2);
        insert matDetList;
        
        // Creating associated component details.
        // Creating associated component details.
        List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='DISC DVD'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='LITHO'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='INSERT'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Component_Type__c='STICKER'));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet1.Id, Existing_Component__c=objMaterial.Id));
        compDetList.add(new Component_Detail__c(Material_Detail__c=matDet2.Id, Component_Type__c='DISC DVD'));
        insert compDetList;
        
        insert DGF_TestDataUtility.createSyncDigitalRelease(true);
    }
    public static testmethod void testMethod_1()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        TriggerUtility.isSpecialCase = true;
        List<TM_Version__c> tmVersionList = DGF_TestDataUtility.createTmVersion(1,new List<Title__c> {title});
        insert tmVersionList;
        List<Distributor_Date__c> ddList = new List<Distributor_Date__c>();
        ddList.add(new Distributor_Date__c(Distributor__c = 'Test', HE_Major__c = true, Theatrical_to_BD_DVD__c = 4, Theatrical_to_VOD__c = 3, EST_to_BD_DVD__c = 1));
        ddList.add(new Distributor_Date__c(Distributor__c = 'All Others', HE_Major__c = true, Theatrical_to_BD_DVD__c = 4, Theatrical_to_VOD__c = 2, EST_to_BD_DVD__c = 1));
        insert ddList;
        Id recTypeId = Schema.Sobjecttype.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        List<Release__c> releaseList = new List<Release__c>();
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        release.recordtypeId = recTypeId;    
        release.Label_Code__c = '95 - Sony Pictures';    
        release.EST_Date__c = System.Today();
        release.First_Theatrical_Date__c = System.Today();
        release.Street_Date__c = System.Today();
        release.Alternate_Physical_Street_Date__c = System.Today();
        release.VOD_Street_Date__c = System.Today().addDays(30);
        release.Alternate_EST_Date__c = System.Today();
        release.Alternate_VOD_Date__c = System.Today();
        release.Distributor__c = 'Test';
        release.Brand_Group__c = 'Partners';
        Release__c release3=testClassUtility.createRelease('Test Release3','Family','New Release Mattel','Materials Not Requested',title.id);
        release3.recordtypeId = recTypeId;    
        release3.Label_Code__c = '95 - Sony Pictures';    
        release3.EST_Date__c = System.Today();
        release3.First_Theatrical_Date__c = System.Today();
        release3.Street_Date__c = System.Today();
        release3.Alternate_Physical_Street_Date__c = System.Today();
        release3.VOD_Street_Date__c = System.Today().addDays(30);
        release3.Alternate_EST_Date__c = System.Today();
        release3.Alternate_VOD_Date__c = System.Today();
        release3.Brand_Group__c = 'Partners';
        release3.Distributor__c = 'abc';
        Release__c release2=testClassUtility.createRelease('Test Release2','Family','New Release Mattel','Materials Not Requested',title.id);
        release2.recordtypeId = recTypeId;    
        release2.Label_Code__c = '95 - Sony Pictures';    
        release2.EST_Date__c = System.Today();
        release2.First_Theatrical_Date__c = System.Today();
        release2.Street_Date__c = System.Today();
        release2.Alternate_Physical_Street_Date__c = System.Today();
        release2.VOD_Street_Date__c = System.Today().addDays(30);
        release2.Alternate_EST_Date__c = System.Today();
        release2.Alternate_VOD_Date__c = System.Today();
        release2.Brand_Group__c = 'Partners';
        release2.Distributor__c = null;
        releaseList.add(release);
        releaseList.add(release2);
        releaseList.add(release3);
        insert releaseList;
        //Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = release.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
        //insert objMaterial1;
        List<Digital_Release__c> dgReleaseList = DGF_TestDataUtility.createDigitalRelease(1,Schema.Sobjecttype.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId());
        DGF_TriggerUtility.executeDigitalReleaseTrigger = false;
        insert dgReleaseList;
        List<Release_Date__c> releaseDateList = new List<Release_Date__c>();
        releaseDateList.add(createReleaseDate(release.Id,'Alternate Street Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Alternate EST Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Alternate VOD Street Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'EST Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Street Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Theatrical Release Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'VOD Street Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Theatrical Release Date',System.Today(),'95 - Sony Pictures'));
        releaseDateList.add(createReleaseDate(release.Id,'Theatrical Release Date',System.Today(),'95 - Sony Pictures'));
        insert releaseDateList;
        
        release.Alternate_Physical_Street_Date__c = System.Today();
        release.Street_Date__c = System.Today().addDays(10);
        release.Alternate_EST_Date__c = System.Today();
        release.Alternate_VOD_Date__c = System.Today();
        release.Acquisition__c = true;
        release.EST_Date__c = System.Today().addDays(10);
        release.First_Theatrical_Date__c = System.Today().addDays(10);
        release.Label_Code__c = '94 - BROAD GREEN';
        release.VOD_Street_Date__c = System.Today().addDays(30);
        release.TM_Version__c = tmVersionList[0].Id;
        TriggerUtility.sobjectExecutedEvents  = new Map<String, Set<String>>(); 
        update release;
        release.EST_Date__c = null;
        release.First_Theatrical_Date__c = null;
        release.Street_Date__c = null;
        release.First_Theatrical_Date__c = null;
        release.Alternate_Physical_Street_Date__c = null;
        release.Alternate_EST_Date__c = null;
        release.Alternate_VOD_Date__c = null;
        release.EST_Date__c = null;
        release.Creative_Contact__c = userInfo.getUserId();
        release.Manufacturing_Contact__c = userInfo.getUserId();
        release.Marketing_Contact__c = userInfo.getUserId();
        release.Master_Data_Contact__c = userInfo.getUserId();
        release.Tech_Ops_Contact__c = userInfo.getUserId();
        TriggerUtility.sobjectExecutedEvents  = new Map<String, Set<String>>(); 
        
        
        Test.startTest();
        update release;
        release.Alternate_Physical_Street_Date__c = System.Today();
        release.Street_Date__c = System.Today().addDays(10);
        release.Alternate_EST_Date__c = System.Today();
        release.Alternate_VOD_Date__c = System.Today();
        release.Acquisition__c = true;
        release.EST_Date__c = System.Today().addDays(10);
        release.First_Theatrical_Date__c = System.Today().addDays(10);
        release2.Alternate_Physical_Street_Date__c = System.Today();
        release2.Street_Date__c = System.Today().addDays(10);
        release2.Alternate_EST_Date__c = System.Today();
        release2.Alternate_VOD_Date__c = System.Today();
        release2.Acquisition__c = true;
        release2.EST_Date__c = System.Today().addDays(10);
        release2.First_Theatrical_Date__c = System.Today().addDays(10);
        TriggerUtility.sobjectExecutedEvents  = new Map<String, Set<String>>(); 
        update releaseList;
        ddList[0].Theatrical_to_VOD__c = null;
        ddList[0].EST_to_BD_DVD__c = null;
        ddList[0].Theatrical_to_BD_DVD__c = null;
        ddList[1].Theatrical_to_VOD__c = null;
        ddList[1].EST_to_BD_DVD__c = null;
        ddList[1].Theatrical_to_BD_DVD__c = null;
        update ddList;
        Release__c release4=testClassUtility.createRelease('Test Release4','Family','New Release Mattel','Materials Not Requested',title.id);
        release4.recordtypeId = recTypeId;    
        release4.Label_Code__c = '95 - Sony Pictures';    
        release4.EST_Date__c = System.Today();
        release4.First_Theatrical_Date__c = System.Today();
        release4.Street_Date__c = System.Today();
        release4.Alternate_Physical_Street_Date__c = System.Today();
        release4.VOD_Street_Date__c = System.Today().addDays(30);
        release4.Alternate_EST_Date__c = System.Today();
        release4.Alternate_VOD_Date__c = System.Today();
        release4.Brand_Group__c = 'Partners';
        release4.Distributor__c = 'Test';
        Release__c release5=testClassUtility.createRelease('Test Release5','Family','New Release Mattel','Materials Not Requested',title.id);
        release5.recordtypeId = recTypeId;    
        release5.Label_Code__c = '95 - Sony Pictures';    
        release5.EST_Date__c = System.Today();
        release5.First_Theatrical_Date__c = System.Today();
        release5.Street_Date__c = null;
        release5.Alternate_Physical_Street_Date__c = System.Today();
        release5.VOD_Street_Date__c = System.Today().addDays(30);
        release5.Alternate_EST_Date__c = System.Today();
        release5.Alternate_VOD_Date__c = System.Today();
        release5.Brand_Group__c = 'Partners';
        release5.Distributor__c = null;
        releaseList.add(release4);
        releaseList.add(release5);
        upsert releaseList;
        delete releaseList;
        Test.stopTest();
    }
    public static Release_Date__c createReleaseDate(Id ReleaseId, String ReleasedateType, Date ReleaseDate, String LabelCode) {
        return new Release_Date__c(Release__c = ReleaseId, Release_Date_Type__c = ReleasedateType, Release_Date__c = ReleaseDate, Label_Code__c = LabelCode);
    }
}