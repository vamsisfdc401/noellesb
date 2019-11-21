/***********************************************************************************
Class Name: DGF_SystemModeUtilityTest
Purpose: Test class for apex class DGF_SystemModeUtility
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             28/06/2017           Mohit                    Initial Development
******************************************************************************************/
@isTest(seeAllData = true)
public class DGF_SystemModeUtilityTest{
    
    /***********************************
    Method Name: scenario1
    Purpose: method to test code for DFOR-517
    ***********************************/ 
    static testMethod void scenario1(){
        
        //creating product chatter group 
        CollaborationGroup cg = new CollaborationGroup(name = 'TEST CLASS CHATTER GROUP',CollaborationType = 'Public');
        insert cg;
        
        //creating a user record
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = userInfo.getProfileId(), 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123##12@testorg.com');
        
        insert u;
        
        //adding member to chatter group
        CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cg.id,MemberId =u.Id );
        insert cgm;
        
        //getting record type for digital release
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        
        //getting list of digital release records to be created
        List<Digital_Release__c> insertDG = DGF_TestDataUtility.createDigitalRelease(1,FilmRecTypeId);
        insert insertDG;
        
        test.StartTest();
        	insertDG[0].Release_State__c = DGF_Constants.CANCELLED;
            update insertDG;
            
            delete cgm;
        test.StopTest();        
    }    
}