@isTest 
Private class PCGBSContractTriggerTest {
    
    private static testMethod void Test_PCGBSContractTrigger () { 
        Contract__c fw = new Contract__c(); 
        insert fw; 

        System.assertNotEquals(null, fw.id); 
        update fw; 
        delete fw; 
    } 
}