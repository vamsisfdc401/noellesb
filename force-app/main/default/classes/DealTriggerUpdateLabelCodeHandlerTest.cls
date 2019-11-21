/*****************************************************************************************
Class Name: DealTriggerUpdateLabelCodeHandlerTest
Purpose: Test class for apex class DealTriggerUpdateLabelCodeHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/12/2016           Mohit                    Initial Development
******************************************************************************************/
@isTest
private class DealTriggerUpdateLabelCodeHandlerTest{
    
    // Following method is used to prepare data setup. // Changed for Deal
    @testSetup 
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
    
    static testmethod void testMethod_1()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
		deal.SGENNO__c=title.SGENNO__c;
        deal.Finance_Default_Deal__c = FALSE;
        deal.Primary_Deal__c= TRUE;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        deal.Deal_ID__c = '1234';
        insert deal; 
        
        Deal__c deal1 = new Deal__c();
        deal1.Name = 'Test Deal';
        deal1.Title__c = title.ID;
        deal1.Finance_Default_Deal__c = TRUE;
        deal1.Primary_Deal__c= TRUE;
		deal.SGENNO__c=title.SGENNO__c;
        deal1.Label_Code__c = '61 - Universal Pictures';
        deal1.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        deal1.Deal_ID__c = '1234';
        insert deal1; 
        
        deal.Finance_Default_Deal__c = TRUE;
        update deal;
        
        List<Deal__c> lstDealRecords = new List<Deal__c>();
        lstDealRecords.add(deal);
        lstDealRecords.add(deal1);
        
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        insert release;
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',release.id,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c = title.ID;
        material1.deal__c = deal.id;
        material1.Label_Code__c = '61 - Universal Pictures';
        material1.Territory__c = 'US';
        material1.Material_Status__c = 'Draft';
        insert material1;
        
        Material__c material2=testClassUtility.createMaterial('12 - VOD','BD-R','dummy2','ROH',release.id,TRUE,'C - Components','DS - DISC');
        material2.Title__c = title.ID;
        material2.deal__c = deal.id;
        material2.Label_Code__c = '61 - Universal Pictures';
        material2.Material_Status__c = 'Draft';
        material2.Territory__c = 'US';
        insert material2;  
        
        test.startTest();        
        dealTriggerUpdateLabelCodeHandler.updateDealIdonReleaseMaterial(lstDealRecords);        
        test.stopTest();
    }   
    
    static testmethod void testMethod_2()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = FALSE;
        deal.Primary_Deal__c= TRUE;
		deal.SGENNO__c=title.SGENNO__c;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        deal.Deal_ID__c = '1234';
        insert deal; 
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c = title.ID;
        material1.Deal__c = null;
        material1.Label_Code__c = '61 - Universal Pictures';
        material1.Territory__c = 'US';
        material1.Material_Status__c = 'Draft';
        material1.deal__c = deal.id;
        insert material1;      
        
        test.startTest();
        deal.Finance_Default_Deal__c = TRUE;
        update deal;
        
        List<Deal__c> lstDealRecords = new List<Deal__c>();
        lstDealRecords.add(deal);
        
        dealTriggerUpdateLabelCodeHandler.updateDealIdonReleaseMaterial(lstDealRecords);   
        test.stopTest();
    }     
    
    static testmethod void testMethod_3()
    {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;        
        
        Deal__c deal = new Deal__c();
        deal.Name = 'Test Deal';
        deal.Title__c = title.ID;
        deal.Finance_Default_Deal__c = FALSE;
        deal.Primary_Deal__c= TRUE;
		deal.SGENNO__c=title.SGENNO__c;
        deal.Label_Code__c = '61 - Universal Pictures';
        deal.Origin_Code__c = '010 - Universal Pictures'; // Changed for Deal
        deal.Deal_ID__c = '1234';
        insert deal; 
        
        Material__c material1=testClassUtility.createMaterial('02 - DVD','DVD','dummy1','FERT',null,TRUE,'S (Single)','SS (Single Selection)');
        material1.Title__c = title.ID;
        material1.Deal__c = deal.id;
        material1.Label_Code__c = '61 - Universal Pictures';
        material1.Territory__c = 'US';
        material1.Material_Status__c = 'Submitted';
        insert material1;      
        
        test.startTest();
        deal.Finance_Default_Deal__c = TRUE;
        update deal;
        
        List<Deal__c> lstDealRecords = new List<Deal__c>();
        lstDealRecords.add(deal);
        
        dealTriggerUpdateLabelCodeHandler.updateDealIdonReleaseMaterial(lstDealRecords);        
        
        test.stopTest();
    }     
    
}