public class CIRFAccountTriggerHandler extends TriggerHandler {
	public CIRFAccountTriggerHandler() {
         
    }
    
    public override void beforeInsert() {
        List<String> uniqueIds = new List<String>();
        Id cirfRecordTypeId = [select id, recordtype.name from recordtype where recordtype.name like :Label.CIRF_Account_RecordType].Id;
        List<Account> allCIRFAccounts = [select id, name, territory__c, recordtypeid from Account where 
                                         recordtypeid = :cirfRecordTypeId];
        for(Account ac : allCIRFAccounts) {
            System.debug(ac.name+ac.territory__c);
            uniqueIds.add(ac.name+ac.territory__c);
        }
        System.debug(uniqueIds);
        for(Account acc : (List<Account>)trigger.new) {
            if(acc.recordtypeid == cirfRecordTypeId) {
                String unique = acc.name+acc.territory__c;
                System.debug(unique);
                if(uniqueIds.contains(unique)){
                    acc.addError('Duplicate Account Found');
                }
            }
        }
    }
}