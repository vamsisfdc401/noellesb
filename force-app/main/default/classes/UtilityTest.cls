/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UtilityTest {

    static testMethod void isNullString() {
        // TO DO: implement unit test
        String strNull;
        String strBlank = '';
        String strVal = 'testdata';
        Utility.isNull(strNull);
        Utility.isNull(strBlank);
        Utility.isNull(strVal);
    }

    static testMethod void isEmptyString() {
        // TO DO: implement unit test
        String strNull;
        String strBlank = '';
        String strVal = 'testdata';
        list<Object> ob = new list<Object>();        
        ob.add('Material__c');
        set<Object> obSet = new set<Object>();        
        obSet.add('Material__c');
        set<String> obSetstr = new set<String>();        
        obSetstr.add('Material__c');
        
        map<Object,object> mapObj = new map<Object,object>();
        mapObj.put('Material__c','Material__c');
        
        Release__c objRelease = new Release__c(Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Universal Pictures',Project_Type__c = 'New Release');
        insert objRelease;
        
        Material__c objMaterial = new Material__c(name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial;
        
        Material__c objMaterial1 = new Material__c(name='dummy1',Material_Type__c= 'ROH',Release__c = objRelease.id,Association_Required__c=TRUE,Territory__c='US', Item_type__c= 'S (Single)', Item_Code__c='SS (Single Selection)');
        insert objMaterial1;
        
        BOM_Item__c bm = new BOM_Item__c();
        bm.Material__c = objMaterial.Id;
        bm.Material_Component__c= objMaterial1.Id;
        bm.Component_Quantity__c = '2';
        Insert bm;
        
        Release_Material__c rm = new Release_Material__c();
        rm.Material__c = objMaterial.Id;
        rm.Release__c = objRelease.Id;
        insert rm;
        
        
        List<String> idList = new list<String>();
        idlist.add(objMaterial.Id);
        List<String> bmidList = new list<String>();
        bmidlist.add(bm.Id);
        
        List<String> rmidList = new list<String>();
        rmidlist.add(rm.Id);
         
        Set<String> fieldsToIgnore = new set<String>();
        fieldsToIgnore.add('Material_Type__c'); 
        String releaseId = objRelease.Id;
        String recId = objMaterial.Id;
        
        Set<String> bmfieldsToIgnore = new set<String>();
        bmfieldsToIgnore.add('Component_Quantity__c');
        
        Utility.isEmpty(strNull);
        Utility.isEmpty(strBlank);
        Utility.isEmpty(strVal);
        Utility.isEmpty(ob);
        Utility.isEmpty(obSet);
        Utility.isEmpty(obSetstr);
        Utility.isEmpty(mapObj);
        Utility.cloneMaterialList(idList,fieldsToIgnore,releaseId);
        Utility.cloneBomList(bmidlist,bmfieldsToIgnore,releaseId);
        Utility.cloneReleaseMaterialList(rmidlist,fieldsToIgnore,releaseId);        
        Utility.clone(idList,fieldsToIgnore);
        Utility.clone(recId,fieldsToIgnore);
    } 

    static testMethod void isNullObject() {
        // TO DO: implement unit test
        Object objNull;
        Utility.isNull(objNull);
        // added on 08-03
        string toBeCleanedString = 'There is no meaning in reading this message \n please ignore';
        Utility.cleanString(toBeCleanedString);
        Utility.parseLongText(toBeCleanedString);
    } 

    static testMethod void getRecordTypeTest() {
        String recordTypeName = 'GBS Default';
        String sObjectTypeName = 'Account';
        String recordTypeName2 = '';
        Id recordTypeId = Utility.getRecordTypeId(recordTypeName, sObjectTypeName);
        if (recordTypeId != null)
            recordTypeName2 = Utility.getRecordTypeName(recordTypeId, sObjectTypeName);
        system.assertEquals(recordTypeName, recordTypeName2);
    }

    static testMethod void getGroupMembersTest() {
        //  Create a group
        String groupName = 'Master_Data';
        String groupType = 'Queue';
        List<Id> groupMemberList = Utility.getGroupMembers(groupName, groupType);

        groupName = 'Dreamworks';
        groupType = 'Role';
        groupMemberList = Utility.getGroupMembers(groupName, groupType);
        //system.assertNotEquals(groupMemberList.size(),0);
    }

    static testMethod void getGroupNameTest() {
        string groupName = Utility.getMasterDataGroupName();
        //system.assertEquals(groupName, 'Master_Data_Group');
        string groupName1 = Utility.getCustomerMarketingGroupName();
        //system.assertEquals(groupName,'CAR_Customer_Marketing');
        string groupName2 = Utility.getCustomerOperationsGroupName();
        //system.assertEquals(groupName2,'RF_Customer_Ops');
    }

    static testMethod void getUserEmailTest() {
        Id userId = UserInfo.getUserId();
        Map<Id, User> userMap = new Map<Id, User>([select id, userName from User where id = : UserInfo.getUserId()]);
        List<Id> userIdList = new List<Id>();
        userIdList.addAll(userMap.keySet());
        List<String> userEmailList = Utility.getUserEmails(userIdList);
        //system.assertNotEquals(userEmailList,null);
    }

    static testMethod void getUserIdTest() {
        String userName = userInfo.getName();
        Id userId = Utility.getUserId(userName);
    }

     
    static testMethod void sendEmailTest() {
        List<String> recipientList = new List<String>();
        recipientList.add(userInfo.getUserEmail());
        String subject = 'Test Email';
        String message = 'This is a test';
        String emailTemplate = null;
        Id relatedId = null;
        Utility.sendEmail(recipientList, subject, message, emailTemplate, relatedId);
    }


}