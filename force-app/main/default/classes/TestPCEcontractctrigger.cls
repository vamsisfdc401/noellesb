@isTest 
 private class TestPCEcontractctrigger { private static testMethod void Test_TestPCEcontractctrigger () { 
 contract__c fw = new contract__c(); 
 insert fw; 
 System.assertNotEquals(null, fw.id); 
 update fw; 
 delete fw;} 
}