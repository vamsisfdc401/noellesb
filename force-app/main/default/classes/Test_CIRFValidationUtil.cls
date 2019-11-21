@isTest
public class Test_CIRFValidationUtil {
    @isTest
    public static void testData1(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Custom Standard User' LIMIT 1];
        User u = new User();
        String uName = 'Krishna' + 'Chaitanya';
        uName = uName.trim().replaceAll(' ','');
        u.alias = 'Krish';
        u.email= uName + '@xyz.com';
        u.username = u.email;
        u.emailencodingkey='UTF-8';
        u.lastname = 'Ramadugu';
        u.firstname = 'Chaitanya';
        u.languagelocalekey='en_US'; 
        u.localesidkey='en_US';
        u.profileid =  profileId.Id;
        u.timezonesidkey='America/Los_Angeles';
        //  u.profileId = Label.CIRF_Edit_Create_Delete;
        insert u;
        
        User su = new User();
        
        su.alias = 'Krish2';
        su.email= 'abcxyz@xyz.com.test';
        su.username = su.email;
        su.emailencodingkey='UTF-8';
        su.lastname = 'Ramadugu';
        su.firstname = 'Chaitanya2';
        su.languagelocalekey='en_US'; 
        su.localesidkey='en_US';
        su.timezonesidkey='America/Los_Angeles';
        su.profileId = Label.CIRF_Edit_Create_Delete;
        
        system.runAs(su) {
            Permissionset[] psList = [Select id from Permissionset where name IN ('CIRF_User_Platform','CIRF_Admin_User')];
            for(Permissionset p: psList) {
                PermissionSetAssignment permission = new PermissionSetAssignment();
                permission.AssigneeId = u.id;
                permission.PermissionSetId = p.Id;
                insert permission;
            }
        }
        
        CIRFCorrugateMaterialTriggerHandler.isFirstTime=true;
        
        
        Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
        insert mat;       
        String myLabel = System.Label.CIRF_Status_Validation_ON_OFF;
        system.assertEquals('ON', myLabel);
        date startDate = date.newInstance(2018, 11, 15);
        date endDate = date.newInstance(2018, 11, 28);
        date insStoreDate = date.newInstance(2018, 11, 1);
        System.runAs(u){
            
            //CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Loaded' , false);
            Account acc2 = CIRF_TestDataFactory.createRetailerAccount('Test Retailer2', 'US', 'Test2', '1265');
            acc2.CIRF_RIM_Approval__c =true ;
            acc2.CIRF_No_RIM_Approval__c = 'Universal';
            insert acc2;
            AccountTeamMember at = new AccountTeamMember();
            at.UserId = u.Id;
            at.AccountId = acc2.id;
            at.TeamMemberRole = 'CIRF RIM Team';
            at.AccountAccessLevel = 'Edit';
            at.CaseAccessLevel = 'Edit';
            at.OpportunityAccessLevel = 'Edit';
            insert at;
            
            CIRF_Header__c header2 = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Joint Corrugate', acc2.id, startDate, endDate, insStoreDate, 'Draft' , false);
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
            corrmat.Material_Name__c = mat2.id;
            corrmat.Facings__c= 3;
            update corrmat;
            cmat2.CIRF_Material_Status__c = 'Submitted';
            update cmat2;
            
            header2.CIRF_Status__c = 'Submitted';
            update header2;
            CIRFValidationUtil.isUnlockedField('CIRF_Corrugate__c','corrugate_status__c','Submitted');
            try {
            CIRFValidationUtil.getUpdFieldList('CIRF_Corrugate__c','Submitted',ccorr2);
            } catch(Exception ex) {
                
            }
            header2.CIRF_Status__c = 'Loaded';
            update header2;
            cmat2.width__c= 50;
            update cmat2;
            //no need to stopTest as we do not have any future/batch validations
        }
    }
    
}