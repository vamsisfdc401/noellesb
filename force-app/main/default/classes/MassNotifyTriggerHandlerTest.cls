/*****************************************************************************************
Class Name: MassNotifyTriggerHandlerTest 
Purpose: Test class for apex class  MassNotifyTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna                 Initial Development
******************************************************************************************/
@isTest(SeeAllData = FAlSE)
public class MassNotifyTriggerHandlerTest {
    
    @isTest
    public static void Scenario1(){
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',null);
        insert release;
        
        Set<Id> setRelIds = new Set<Id>();
        setRelIds.add(release.Id);
        System.AssertEquals(database.countquery('SELECT COUNT()'+' FROM Release__c '), 1);
        
        //MassNotifyTriggerHandler.massFollowRelease(setRelIds);  
    }
    
}