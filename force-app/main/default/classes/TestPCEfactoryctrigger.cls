@isTest 
 private class TestPCEfactoryctrigger { private static testMethod void Test_TestPCEfactoryctrigger () { 
 factory__c fw = new factory__c(); 
 insert fw; 
 System.assertNotEquals(null, fw.id); 
 update fw; 
 delete fw;} 
}