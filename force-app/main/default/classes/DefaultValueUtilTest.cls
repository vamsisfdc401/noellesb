/*****************************************************************************************
Class Name: DefaultValueUtilTest
Purpose: Test class for apex class  DefaultValueUtil
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2016           Ipsita                    Initial Development
******************************************************************************************/
@isTest
private class DefaultValueUtilTest {

    static testMethod void isNullString() {
        sObject obj = new Material__c();
        String consColoumn = '1';
        DefaultValueUtil.IsFieldAvliable(obj,consColoumn); 
    }
}